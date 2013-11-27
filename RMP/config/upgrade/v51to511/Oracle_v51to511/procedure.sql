CREATE OR REPLACE PROCEDURE account_bucket_mapping (
   p_partition         NVARCHAR2 DEFAULT NULL,
   p_interval          INT DEFAULT NULL,
   p_hash              INT,
   p_result      OUT   NVARCHAR2
)
AS
   v_sql           VARCHAR2 (4000);
   v_count         NUMBER (10)      := 0;
   v_partname      NVARCHAR2 (2000);
   v_maxdate       VARCHAR2 (100);
   v_currentdate   VARCHAR2 (100);
BEGIN
/* Before we run the archving procedures, directory should exist and access is granted to MetraNet schema owner:
for example
CREATE DIRECTORY backup_dir AS '/usr/apps/datafiles';
GRANT READ,WRITE ON DIRECTORY backup_dir TO nmdbo;
*/

   /* How to run this procedure DECLARE    P_PARTITION NVARCHAR2(200);   P_INTERVAL NUMBER;   P_HASH NUMBER;   P_RESULT NVARCHAR2(200); BEGIN    P_PARTITION := NULL;   P_INTERVAL := 883621891;   P_HASH := 2;   P_RESULT := NULL;   ACCOUNT_BUCKET_MAPPING ( P_PARTITION, P_INTERVAL, P_HASH, P_RESULT );   dbms_output.put_line(p_result);   COMMIT;  END;   OR DECLARE    P_PARTITION NVARCHAR2(200);   P_INTERVAL NUMBER;   P_HASH NUMBER;   P_RESULT NVARCHAR2(200);  BEGIN    P_PARTITION := 'HS_20070131';   P_INTERVAL := null;   P_HASH := 2;   P_RESULT := NULL;   ACCOUNT_BUCKET_MAPPING ( P_PARTITION, P_INTERVAL, P_HASH, P_RESULT );   dbms_output.put_line(p_result);   COMMIT;  END;   */
   SELECT SYSDATE
     INTO v_currentdate
     FROM DUAL;

   SELECT dbo.mtmaxdate
     INTO v_maxdate
     FROM DUAL; /* Check that either Interval or Partition is specified */

   IF (   (p_partition IS NOT NULL AND p_interval IS NOT NULL)
       OR (p_partition IS NULL AND p_interval IS NULL)
      )
   THEN
      p_result :=
         '4000001-account_bucket_mapping operation failed-->Either Partition or Interval should be specified';
      ROLLBACK;
      RETURN;
   END IF;

   /* Run the following code if Interval is specified */
   IF (p_interval IS NOT NULL)
   THEN
      /*Check that Interval exists */
      SELECT COUNT (1)
        INTO v_count
        FROM t_usage_interval
       WHERE id_interval = p_interval;

      IF v_count = 0
      THEN
         p_result :=
            '4000002-account_bucket_mapping operation failed-->Interval Does not exists';
         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_usage_interval
       WHERE id_interval = p_interval AND tx_interval_status = 'H';

      IF v_count = 0
      THEN
         p_result :=
            '4000002a-account_bucket_mapping operation failed-->Interval is not Hard Closed';
         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_acc_bucket_map
       WHERE id_usage_interval = p_interval;

      IF v_count > 0
      THEN
         p_result :=
            '4000003-account_bucket_mapping operation failed-->Mapping already exists';
         ROLLBACK;
         RETURN;
      END IF;

/* We will apply the hash function on all the payers in the specified interval, we are using t_acc_usage_interval
to avoid scan of t_acc_usage */

      BEGIN
         v_sql :=
               'insert into t_acc_bucket_map(id_usage_interval,id_acc,bucket,status,tt_start,tt_end) 
                select distinct '
            || CAST (p_interval AS VARCHAR2)
            || ',id_acc,mod(id_acc,'
            || CAST (p_hash AS VARCHAR2)
            || '),''U'','''
            || v_currentdate
            || ''','''
            || v_maxdate
            || ''' from t_acc_usage_interval where id_usage_interval = '
            || CAST (p_interval AS VARCHAR2);

         EXECUTE IMMEDIATE v_sql;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '4000004-account_bucket_mapping operation failed-->error in insert into t_acc_bucket_map';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   IF (p_partition IS NOT NULL)
   THEN                 /* Get all the intervals in the specified Partition */
      IF table_exists ('tmp_acc_bucket_map')
      THEN
         exec_ddl ('truncate table tmp_acc_bucket_map');
      END IF;

      INSERT INTO tmp_acc_bucket_map
         SELECT id_interval
           FROM t_partition_interval_map MAP
          WHERE id_partition = (SELECT id_partition
                                  FROM t_partition
                                 WHERE partition_name = p_partition);

      SELECT COUNT (1)
        INTO v_count
        FROM t_usage_interval inte INNER JOIN tmp_acc_bucket_map MAP
             ON inte.id_interval = MAP.id_interval
           AND tx_interval_status <> 'H'
             ;

      IF (v_count > 0)
      THEN
         p_result :=
            '4000005-account_bucket_mapping operation failed-->Interval is not Hard Closed';
         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      /*Check that mapping should not already exists */
      SELECT COUNT (1)
        INTO v_count
        FROM t_acc_bucket_map inte INNER JOIN tmp_acc_bucket_map MAP
             ON inte.id_usage_interval = MAP.id_interval
             ;

      IF (v_count > 0)
      THEN
         p_result :=
            '4000006-account_bucket_mapping operation failed-->Mapping already exists';
         ROLLBACK;
         RETURN;
      END IF;

/* We will apply the hash function on all the payers in the all the intervals of partition,
 we are using t_acc_usage_interval to avoid scan of t_acc_usage */

      BEGIN
         v_sql :=
               'INSERT INTO t_acc_bucket_map
                     (id_usage_interval, id_acc, bucket, status, tt_start,
                      tt_end)
         select id_usage_interval,id_acc,mod(id_acc,'
            || CAST (p_hash AS VARCHAR2)
            || '),
            ''U'','''
            || v_currentdate
            || ''','''
            || v_maxdate
            || ''' from t_acc_usage_interval where id_usage_interval in (select id_interval
            from tmp_acc_bucket_map)';

         EXECUTE IMMEDIATE (v_sql);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '4000007-account_bucket_mapping operation failed-->error in insert into t_acc_bucket_map';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   p_result := '0-account_bucket_mapping operation successful';
END;
/
CREATE OR REPLACE PROCEDURE ARCHIVE_EXPORT (
   p_partition           NVARCHAR2 DEFAULT NULL,
   p_intervalid          INT DEFAULT NULL,
   p_path                VARCHAR2,
   p_avoid_rerun         VARCHAR2 DEFAULT 'N',
   p_result        OUT   VARCHAR2
)
AS
/* How to run this stored procedure DECLARE    P_PARTITION NVARCHAR2(200);   P_INTERVALID NUMBER;   P_PATH VARCHAR2(200);   P_AVOID_RERUN VARCHAR2(200);   P_RESULT VARCHAR2(200);  BEGIN    P_PARTITION := 'HS_20070131';   P_INTERVALID := NULL;   P_PATH := 'HS_DIR;   P_AVOID_RERUN := 'N';   P_RESULT := NULL;    ARCHIVE_EXPORT ( P_PARTITION, P_INTERVALID, P_PATH, P_AVOID_RERUN, P_RESULT );   DBMS_OUTPUT.PUT_LINE(P_RESULT);   COMMIT;  END; or DECLARE    P_PARTITION NVARCHAR2(200);   P_INTERVALID NUMBER;   P_PATH VARCHAR2(200);   P_AVOID_RERUN VARCHAR2(200);   P_RESULT VARCHAR2(200);  BEGIN    P_PARTITION := null;   P_INTERVALID := 885653507;   P_PATH := HS_DIR;   P_AVOID_RERUN := 'N';   P_RESULT := NULL;    ARCHIVE_EXPORT ( P_PARTITION, P_INTERVALID, P_PATH, P_AVOID_RERUN, P_RESULT );   DBMS_OUTPUT.PUT_LINE(P_RESULT);   COMMIT;  END; */
   v_sql1         VARCHAR2 (4000);
   v_sql2         VARCHAR2 (4000);
   v_tab1         VARCHAR2 (1000);
   v_var1         VARCHAR2 (1000);
   v_var2         NUMBER (10);
   v_vartime      DATE;
   v_maxtime      DATE;
   v_acc          INT;
   v_servername   VARCHAR2 (100);
   v_dbname       VARCHAR2 (100);
   v_count        NUMBER           := 0;
   v_table_name   VARCHAR2 (30);
   v_cur          sys_refcursor;
   v_cur1         sys_refcursor;
   interval_id    sys_refcursor;
   c1             sys_refcursor;
   c2             sys_refcursor;
   fname          VARCHAR2 (2000);
   v_partition1   NVARCHAR2 (2000);
   v_interval     INT;
   v_dummy        VARCHAR2 (1);
   v_dummy1       NUMBER (10)      := 0;
   vexists        BOOLEAN;
   vfile_length   INT;
   vblocksize     INT;
BEGIN
   v_vartime := SYSDATE;
   v_maxtime := dbo.mtmaxdate ();

   /* Check that either Interval or Partition is specified */
   IF (   (p_partition IS NOT NULL AND p_intervalid IS NOT NULL)
       OR (p_partition IS NULL AND p_intervalid IS NULL)
      )
   THEN
      p_result :=
         '1000001-archive_export operation failed-->Either Partition or Interval should be specified';
      ROLLBACK;
      RETURN;
   END IF;            /* Get the list of Intervals that need to be archived */

   IF (p_partition IS NOT NULL)
   THEN
      v_sql1 :=
            'select id_interval from t_partition_interval_map map where id_partition          = (select id_partition  from t_partition where partition_name = '''
         || p_partition
         || ''')';

      OPEN interval_id FOR v_sql1;
   ELSE
      v_sql1 := 'select ' || p_intervalid || ' from dual';

      FOR x IN (SELECT partition_name
                  FROM t_partition part INNER JOIN t_partition_interval_map MAP
                       ON part.id_partition = MAP.id_partition
                     AND MAP.id_interval = p_intervalid
                       )
      LOOP
         v_partition1 := x.partition_name;
      END LOOP;

      OPEN interval_id FOR v_sql1;
   END IF;

   LOOP
      FETCH interval_id
       INTO v_interval;

      EXIT WHEN interval_id%NOTFOUND;

      SELECT COUNT (1)
        INTO v_count
        FROM t_usage_interval
       WHERE id_interval = v_interval;

      IF v_count = 0
      THEN
         p_result :=
                 '1000002-archive operation failed-->Interval does not exist';

         CLOSE interval_id;

         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_usage_interval
       WHERE id_interval = v_interval AND tx_interval_status = 'H';

      IF v_count = 0
      THEN
         p_result :=
             '1000003-archive operation failed-->Interval is not Hard Closed';

         CLOSE interval_id;

         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_archive
       WHERE id_interval = v_interval
         AND status = 'A'
         AND tt_end = dbo.mtmaxdate ();

      IF v_count > 0
      THEN
         p_result :=
            '1000004-archive operation failed-->Interval is already archived-Deleted';

         CLOSE interval_id;

         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_acc_bucket_map
       WHERE id_usage_interval = v_interval;

      IF v_count = 0
      THEN
         p_result :=
            '1000005-archive operation failed-->Interval does not have bucket mappings';

         CLOSE interval_id;

         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_archive
       WHERE id_interval = v_interval
         AND status = 'D'
         AND tt_end = dbo.mtmaxdate ();

      IF v_count > 0
      THEN
         p_result :=
            '1000006-archive operation failed-->Interval is Dearchived and not be exported..run trash/delete procedure';

         CLOSE interval_id;

         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;
   END LOOP;

   CLOSE interval_id;

/* We need to declare the cursor dynamically on the intervals depending on the partition or interval is specified */
   IF (p_partition IS NOT NULL)
   THEN
      v_sql1 :=
            'select id_interval from t_partition_interval_map map where id_partition          = (select id_partition  from t_partition where partition_name = '''
         || p_partition
         || ''')';

      OPEN interval_id FOR v_sql1;
   ELSE
      v_sql1 := 'select ' || p_intervalid || ' from dual';

      FOR x IN (SELECT partition_name
                  FROM t_partition part INNER JOIN t_partition_interval_map MAP
                       ON part.id_partition = MAP.id_partition
                     AND MAP.id_interval = p_intervalid
                       )
      LOOP
         v_partition1 := x.partition_name;
      END LOOP;

      OPEN interval_id FOR v_sql1;
   END IF;

   LOOP
      FETCH interval_id
       INTO v_interval;

      EXIT WHEN interval_id%NOTFOUND;
/* we need to archive the interval for each bucket so the following cursor is getting list of all the buckets */
      v_sql1 :=
            'select distinct bucket from t_acc_bucket_map where          id_usage_interval =  '
         || v_interval
         || '          and (status = ''U'' or (status = ''E'' and '''
         || p_avoid_rerun
         || ''' = ''N''))         and tt_end = dbo.mtmaxdate order by bucket';

      OPEN c2 FOR v_sql1;

      LOOP
         FETCH c2
          INTO v_acc;

         EXIT WHEN c2%NOTFOUND;
         v_sql1 :=
               'SELECT /*+ use_hash(act au) */ au.* FROM                  t_acc_usage au inner join t_acc_bucket_map act on                  au.id_usage_interval = act.id_usage_interval and au.id_acc = act.id_acc                 where au.id_usage_interval='
            || CAST (v_interval AS VARCHAR2)
            || ' and act.bucket ='
            || CAST (v_acc AS VARCHAR2)
            || ' and act.status = ''U'''
            || ' and act.id_usage_interval ='
            || CAST (v_interval AS VARCHAR2);
         fname :=
               't_acc_usage_'
            || CAST (v_interval AS VARCHAR2)
            || '_'
            || CAST (v_acc AS VARCHAR2)
            || '.txt';
         v_table_name := SUBSTR (fname, 1, INSTR (fname, '.') - 1);
         v_count := 0;

/* If the external table already exists we need to drop it since we allow archive export to be run multiple times */
         SELECT COUNT (*)
           INTO v_count
           FROM user_external_tables
          WHERE table_name = UPPER (v_table_name);

         IF (v_count > 0)
         THEN
            BEGIN
               exec_ddl ('drop table ' || v_table_name);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '1000007a-archive operation failed-->Error in drop existing external table, check the user permissions';

                  CLOSE c2;

                  CLOSE interval_id;

                  ROLLBACK;
                  RETURN;
            END;
         END IF;

         UTL_FILE.fgetattr (UPPER (p_path),
                            fname,
                            vexists,
                            vfile_length,
                            vblocksize
                           );

         IF vexists
         THEN
            UTL_FILE.fremove (UPPER (p_path), fname);
         END IF;

         BEGIN
            v_sql2 :=
                  'create table '
               || v_table_name
               || '                  ORGANIZATION EXTERNAL                 (                 TYPE ORACLE_DATAPUMP                 DEFAULT DIRECTORY '
               || p_path
               || ' LOCATION ('''
               || fname
               || ''')                 ) as '
               || v_sql1;

            BEGIN
               exec_ddl (v_sql2);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '1000007b-archive operation failed-->Error in creating external table, check the user permissions';

                  CLOSE c2;

                  CLOSE interval_id;

                  ROLLBACK;
                  RETURN;
            END;

            DBMS_OUTPUT.put_line (   'File '
                                  || 't_acc_usage_'
                                  || CAST (v_interval AS VARCHAR2)
                                  || '_'
                                  || CAST (v_acc AS VARCHAR2)
                                  || '.txt'
                                  || ' open'
                                 );
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.put_line (SQLCODE || ': ' || SQLERRM);
               DBMS_OUTPUT.put_line ('File ' || fname || ' write not open');
               p_result :=
                  '1000007-archive operation failed-->Error in bcp out usage table, check the user permissions';

               CLOSE c2;

               CLOSE interval_id;

               ROLLBACK;
               RETURN;
         END;                            /*BCP out the data from t_acc_usage*/

         OPEN v_cur FOR 'SELECT count(1) FROM ' || v_table_name;

         FETCH v_cur
          INTO v_count;

         CLOSE v_cur;

         v_sql1 :=
               'SELECT count(1) FROM                  t_acc_usage au inner join t_acc_bucket_map act on                  au.id_usage_interval = act.id_usage_interval and au.id_acc = act.id_acc                 where rownum < 2 and au.id_usage_interval='
            || CAST (v_interval AS VARCHAR2)
            || ' and act.bucket ='
            || CAST (v_acc AS VARCHAR2)
            || ' and act.status = ''U'''
            || ' and act.id_usage_interval ='
            || CAST (v_interval AS VARCHAR2);

         EXECUTE IMMEDIATE v_sql1
                      INTO v_dummy1;

         IF (v_count = 0 AND v_dummy1 > 0)
         THEN
            p_result :=
               '1000008-archive operation failed-->Error in bcp out usage table, check the archive directory or hard disk space';

            CLOSE c2;

            CLOSE interval_id;

            ROLLBACK;
            RETURN;
         END IF;

/* We are using a temp table to store id_sess that are to be exported to avoid scan of t_acc_usage for each bucket */
         IF table_exists ('tmp_t_acc_usage')
         THEN
            BEGIN
               v_sql2 := 'truncate table tmp_t_acc_usage';
               exec_ddl (v_sql2);
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.put_line (SQLCODE);
                  DBMS_OUTPUT.put_line (SQLERRM);
                  p_result :=
                     '1000009a-archive operation failed-->Error in truncating tmp_t_acc_usage,check the user permissions';

                  CLOSE c2;

                  CLOSE interval_id;

                  ROLLBACK;
                  RETURN;
            END;
         END IF;

         v_sql1 :=
               'insert into tmp_t_acc_usage                  SELECT /*+ use_hash(act au) */ au.id_sess,au.id_usage_interval,au.id_acc FROM '
            || 't_acc_usage au inner join t_acc_bucket_map act on au.id_usage_interval = act.id_usage_interval                  and au.id_acc = act.id_acc where au.id_usage_interval='
            || CAST (v_interval AS VARCHAR2)
            || ' and act.status = ''U'' and act.bucket = '
            || CAST (v_acc AS VARCHAR2)
            || ' and act.id_usage_interval ='
            || CAST (v_interval AS VARCHAR2);

         BEGIN
            EXECUTE IMMEDIATE (v_sql1);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '1000009b-archive operation failed-->Error in inserting tmp_t_acc_usage,check the user permissions';

               CLOSE c2;

               CLOSE interval_id;

               ROLLBACK;
               RETURN;
         END;

         v_sql1 := 'analyze table tmp_t_acc_usage compute statistics';

         EXECUTE IMMEDIATE (v_sql1);

         v_sql1 :=
               'select distinct id_view from t_acc_usage where id_usage_interval = '
            || v_interval;

         OPEN c1 FOR v_sql1;

         LOOP
            FETCH c1
             INTO v_var1;

            EXIT WHEN c1%NOTFOUND;

            FOR i IN (SELECT nm_table_name
                        FROM t_prod_view
                       WHERE id_view = v_var1)
            /*and nm_table_name not like '%temp%'*/
            LOOP
               v_tab1 := i.nm_table_name;
            END LOOP;

            v_sql1 :=
                  'SELECT pv.* FROM '
               || v_tab1
               || ' pv inner join tmp_t_acc_usage au on                      pv.id_sess=au.id_sess                      and au.id_usage_interval = pv.id_usage_interval';
            fname :=
                  'pv_'
               || v_var1
               || '_'
               || CAST (v_interval AS VARCHAR2)
               || '_'
               || CAST (v_acc AS VARCHAR2)
               || '.txt';
            v_table_name :=
                  'pv_'
               || v_var1
               || '_'
               || CAST (v_interval AS VARCHAR2)
               || '_'
               || CAST (v_acc AS VARCHAR2);
            v_count := 0;

            SELECT COUNT (*)
              INTO v_count
              FROM user_external_tables
             WHERE table_name = UPPER (v_table_name);

            IF (v_count > 0)
            THEN
               BEGIN
                  v_sql2 := 'drop table ' || v_table_name;
                  exec_ddl (v_sql2);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_result :=
                        '1000009c-archive operation failed-->Error in dropping external table,check the user permissions';

                     CLOSE c2;

                     CLOSE interval_id;

                     ROLLBACK;
                     RETURN;
               END;
            END IF;

            UTL_FILE.fgetattr (UPPER (p_path),
                               fname,
                               vexists,
                               vfile_length,
                               vblocksize
                              );

            IF vexists
            THEN
               UTL_FILE.fremove (UPPER (p_path), fname);
            END IF;

            BEGIN
               /* Create an external table for each product view table for each bucket */
               v_sql2 :=
                     'create table '
                  || v_table_name
                  || '                      ORGANIZATION EXTERNAL                     (                     TYPE ORACLE_DATAPUMP                     DEFAULT DIRECTORY '
                  || p_path
                  || ' LOCATION ('''
                  || fname
                  || ''')                     )                     as '
                  || v_sql1;
               exec_ddl (v_sql2);
               DBMS_OUTPUT.put_line ('File ' || fname || ' open');
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.put_line (SQLCODE || ': ' || SQLERRM);
                  DBMS_OUTPUT.put_line ('File ' || fname || ' write not open');
                  p_result :=
                        '1000009-archive operation failed-->Error in bcp out '
                     || v_tab1
                     || ' , check the user permissions';

                  CLOSE c2;

                  CLOSE c1;

                  CLOSE interval_id;

                  ROLLBACK;
                  RETURN;
            END;                         /*BCP out the data from t_pv tables*/

            v_count := 0;
            v_dummy1 := 0;

            OPEN v_cur FOR 'SELECT count(1) FROM ' || v_table_name;

            FETCH v_cur
             INTO v_count;

            CLOSE v_cur;

            v_sql1 :=
                  'SELECT count(*) FROM '
               || v_tab1
               || ' pv inner join tmp_t_acc_usage au on                      pv.id_sess=au.id_sess                      and au.id_usage_interval = pv.id_usage_interval';

            EXECUTE IMMEDIATE v_sql1
                         INTO v_dummy1;

            IF (v_count = 0 AND v_dummy1 > 0)
            THEN
               p_result :=
                     '10000010a-archive operation failed-->Error in bcp out  '
                  || v_tab1
                  || ' table, check the user permissions, archive directory or hard disk space';

               CLOSE c1;

               CLOSE c2;

               CLOSE interval_id;

               ROLLBACK;
               RETURN;
            END IF;
         END LOOP;

         CLOSE c1;

         BEGIN                        /* update the archive metadata tables */
            UPDATE t_acc_bucket_map
               SET tt_end = dbo.subtractsecond (v_vartime)
             WHERE id_usage_interval = v_interval
               AND status IN ('E', 'U')
               AND tt_end = v_maxtime
               AND bucket = v_acc;
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.put_line (SQLCODE || ': ' || SQLERRM);
               p_result :=
                  '1000010-archive operation failed-->Error in update t_acc_bucket_map table';

               CLOSE c2;

               CLOSE interval_id;

               ROLLBACK;
               RETURN;
         END;

         BEGIN
            INSERT INTO t_acc_bucket_map
                        (id_usage_interval, id_acc, bucket, status, tt_start,
                         tt_end)
               SELECT v_interval, id_acc, bucket, 'E', v_vartime, v_maxtime
                 FROM t_acc_bucket_map
                WHERE id_usage_interval = v_interval
                  AND status IN ('E', 'U')
                  AND tt_end = dbo.subtractsecond (v_vartime)
                  AND bucket = v_acc;
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.put_line (SQLCODE || ': ' || SQLERRM);
               p_result :=
                  '1000011-archive operation failed-->Error in insert into t_acc_bucket_map table';

               CLOSE c2;

               CLOSE interval_id;

               ROLLBACK;
               RETURN;
         END;
      END LOOP;

      CLOSE c2;

      v_sql1 :=
            'SELECT * FROM t_adjustment_transaction where id_usage_interval='
         || CAST (v_interval AS VARCHAR2)
         || ' order by id_sess';
      /*BCP out the data from t_adjustment_transaction*/
      fname := 't_adj_trans' || '_' || CAST (v_interval AS VARCHAR2) || '.txt';
      v_table_name := 't_adj_trans' || '_' || CAST (v_interval AS VARCHAR2);

      IF (   (table_exists (v_table_name) AND p_avoid_rerun = 'N')
          OR (NOT table_exists (v_table_name))
         )
      THEN
         IF table_exists (v_table_name)
         THEN
            v_sql2 := 'drop table ' || v_table_name;
            exec_ddl (v_sql2);
         END IF;

         UTL_FILE.fgetattr (UPPER (p_path),
                            fname,
                            vexists,
                            vfile_length,
                            vblocksize
                           );

         IF vexists
         THEN
            UTL_FILE.fremove (UPPER (p_path), fname);
         END IF;

         BEGIN        /* Create external table for t_adjustment_transaction */
            v_sql2 :=
                  'create table '
               || v_table_name
               || '              ORGANIZATION EXTERNAL             (             TYPE ORACLE_DATAPUMP             DEFAULT DIRECTORY '
               || p_path
               || ' LOCATION ('''
               || fname
               || ''')             )             as '
               || v_sql1;
            exec_ddl (v_sql2);
            DBMS_OUTPUT.put_line ('File ' || fname || ' open');
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.put_line (SQLCODE || ': ' || SQLERRM);
               DBMS_OUTPUT.put_line ('File ' || fname || ' write not open');
               p_result :=
                  '1000012-archive operation failed-->Error in bcp out adjustment transaction table, check the hard disk space';
               RETURN;
         END;

         IF table_exists ('tmp_t_adjustment_transaction')
         THEN
            EXECUTE IMMEDIATE ('delete from tmp_t_adjustment_transaction');
         END IF;

         INSERT INTO tmp_t_adjustment_transaction
            SELECT   id_adj_trx
                FROM t_adjustment_transaction
               WHERE id_usage_interval = v_interval
            ORDER BY id_sess;

         IF table_exists ('tmp_adjustment')
         THEN
            EXECUTE IMMEDIATE ('delete from tmp_adjustment');
         END IF;

         OPEN v_cur FOR 'select table_name from user_tables where      upper(table_name) like ''T_AJ_%'' and table_name not in (''T_AJ_TEMPLATE_REASON_CODE_MAP'',''T_AJ_TYPE_APPLIC_MAP'')';

         LOOP
            FETCH v_cur
             INTO v_var1;

            EXIT WHEN v_cur%NOTFOUND;
            /*Get the name of t_aj tables that have usage in this interval*/
            v_sql1 :=
                  'select count(1) from '
               || v_var1
               || ' where id_adjustment in                  (select id_adj_trx from t_adjustment_transaction where id_usage_interval = '
               || CAST (v_interval AS VARCHAR2)
               || ') ';

            OPEN v_cur1 FOR v_sql1;

            v_count := 0;

            FETCH v_cur1
             INTO v_count;

            IF v_count > 0
            THEN
               INSERT INTO tmp_adjustment
                    VALUES (v_var1);
            END IF;

            CLOSE v_cur1;
         END LOOP;

         CLOSE v_cur;

         OPEN v_cur FOR 'select name from tmp_adjustment';

         LOOP
            FETCH v_cur
             INTO v_var1;

            EXIT WHEN v_cur%NOTFOUND;   /*BCP out the data from t_aj tables*/
            v_sql1 :=
                  'SELECT aj.* FROM '
               || v_var1
/*               || ' aj inner join tmp_t_adjustment_transaction trans on aj.id_adjustment=trans.id_adj_trx';*/
               || ' aj inner join t_adjustment_transaction trans on aj.id_adjustment=trans.id_adj_trx
                         where id_usage_interval='
               || CAST (v_interval AS VARCHAR2);
            v_sql2 :=
                  'select id_view from t_prod_view where upper(nm_table_name) = upper(replace('''
               || v_var1
               || ''',''AJ'',''PV''))';

            EXECUTE IMMEDIATE v_sql2
                         INTO v_var2;

            fname :=
               'aj_' || v_var2 || '_' || CAST (v_interval AS VARCHAR2)
               || '.txt';
            v_table_name :=
                       'aj_' || v_var2 || '_' || CAST (v_interval AS VARCHAR2);
            v_count := 0;

            SELECT COUNT (*)
              INTO v_count
              FROM user_external_tables
             WHERE table_name = UPPER (v_table_name);

            IF (v_count > 0)
            THEN
               v_sql2 := 'drop table ' || v_table_name;
               exec_ddl (v_sql2);
            END IF;

            UTL_FILE.fgetattr (UPPER (p_path),
                               fname,
                               vexists,
                               vfile_length,
                               vblocksize
                              );

            IF vexists
            THEN
               UTL_FILE.fremove (UPPER (p_path), fname);
            END IF;

            BEGIN              /* Create external table for each t_aj table */
               v_sql2 :=
                     'create table '
                  || v_table_name
                  || '                  ORGANIZATION EXTERNAL                 (                 TYPE ORACLE_DATAPUMP                 DEFAULT DIRECTORY '
                  || p_path
                  || ' LOCATION ('''
                  || fname
                  || ''')                 )                 as '
                  || v_sql1;
               exec_ddl (v_sql2);
               DBMS_OUTPUT.put_line ('File ' || fname || ' open');
            EXCEPTION
               WHEN OTHERS
               THEN
                  DBMS_OUTPUT.put_line (SQLCODE || ': ' || SQLERRM);
                  DBMS_OUTPUT.put_line ('File ' || fname || ' write not open');
                  p_result :=
                        '1000013-archive operation failed-->Error in bcp out '
                     || v_var1
                     || ' table, check the hard disk space';

                  CLOSE v_cur;

                  CLOSE interval_id;

                  ROLLBACK;
                  RETURN;
            END;
         END LOOP;

         CLOSE v_cur;
      END IF;

      IF table_exists ('tmp_id_view')
      THEN
         EXECUTE IMMEDIATE ('delete from tmp_id_view');
      END IF;

      INSERT INTO tmp_id_view
         SELECT DISTINCT id_view
                    FROM t_acc_usage
                   WHERE id_usage_interval = v_interval;

      BEGIN
         UPDATE t_archive
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE id_interval = v_interval
            AND (   id_view IN (SELECT id_view
                                  FROM tmp_id_view)
                 OR adj_name IN (SELECT NAME
                                   FROM tmp_adjustment)
                )
            AND status = 'E'
            AND tt_end = v_maxtime;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '1000014-archive operation failed-->Error in update t_archive table';

            CLOSE interval_id;

            ROLLBACK;
            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive
            SELECT v_interval, id_view, NULL, 'E', v_vartime, v_maxtime
              FROM tmp_id_view
            UNION ALL
            SELECT v_interval, NULL, NAME, 'E', v_vartime, v_maxtime
              FROM tmp_adjustment;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '1000015-archive operation failed-->Error in insert t_archive table';

            CLOSE interval_id;

            ROLLBACK;
            RETURN;
      END;
   END LOOP;

   CLOSE interval_id;

/* If all the intervals of partiton are exported, modify the t_archive_partition table */
   v_count := 0;

   SELECT b_partitioning_enabled
     INTO v_dummy
     FROM t_usage_server;

   SELECT COUNT (1)
     INTO v_dummy1
     FROM t_partition_interval_map MAP
    WHERE id_partition = (SELECT id_partition
                            FROM t_partition_interval_map
                           WHERE id_interval = p_intervalid)
      AND NOT EXISTS (
             SELECT 1
               FROM t_usage_interval inte
              WHERE inte.id_interval = MAP.id_interval
                AND tx_interval_status <> 'H')
      AND NOT EXISTS (
             SELECT 1
               FROM t_archive inte
              WHERE inte.id_interval = MAP.id_interval
                AND tt_end = v_maxtime
                AND status <> 'E')
      AND EXISTS (SELECT 1
                    FROM t_archive inte
                   WHERE inte.id_interval = MAP.id_interval);

   SELECT COUNT (*)
     INTO v_count
     FROM t_partition_interval_map MAP
    WHERE id_partition = (SELECT id_partition
                            FROM t_partition_interval_map
                           WHERE id_interval = p_intervalid);

   IF ((p_partition IS NOT NULL OR v_dummy1 = v_count) AND v_dummy = 'Y')
   THEN
      BEGIN
         UPDATE t_archive_partition
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE partition_name = NVL (p_partition, v_partition1)
            AND tt_end = v_maxtime
            AND status = 'E';
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '1000016-archive operation failed-->Error in update t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive_partition
              VALUES (NVL (p_partition, v_partition1), 'E', v_vartime,
                      v_maxtime);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '1000017-archive operation failed-->Error in insert into t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   p_result := '0-archive_export operation successful';
   COMMIT;
END;
/
CREATE OR REPLACE PROCEDURE archive_delete (
   p_partition          NVARCHAR2 DEFAULT NULL,
   p_intervalid         INT DEFAULT NULL,
   p_result       OUT   NVARCHAR2
)
AS
      /*How to run this stored procedure
   DECLARE
     P_PARTITION NVARCHAR2(200);
     P_INTERVALID NUMBER;
     P_RESULT VARCHAR2(200);
   BEGIN
     P_PARTITION := 'HS_20070131';
     P_INTERVALID := null;
     P_RESULT := NULL;

     ARCHIVE_DELETE ( P_PARTITION, P_INTERVALID, P_RESULT );
     DBMS_OUTPUT.PUT_LINE(P_RESULT);
     COMMIT;
   END;
   OR
   DECLARE
     P_PARTITION NVARCHAR2(200);
     P_INTERVALID NUMBER;
     P_RESULT VARCHAR2(200);
   BEGIN
     P_PARTITION := null;
     P_INTERVALID := 885653507;
     P_RESULT := NULL;

     ARCHIVE_DELETE ( P_PARTITION, P_INTERVALID, P_RESULT );
     DBMS_OUTPUT.PUT_LINE(P_RESULT);
     COMMIT;
   END;
    */
   v_sql1         VARCHAR2 (4000);
   v_tab1         VARCHAR2 (1000);
   v_var1         VARCHAR2 (1000);
   v_vartime      DATE;
   v_maxtime      DATE;
   v_acc          INT;
   v_count        NUMBER           := 0;
   v_count1        NUMBER           := 0;
   c1             sys_refcursor;
   c2             sys_refcursor;
   interval_id    sys_refcursor;
   v_cur          sys_refcursor;
   v_interval     INT;
   v_dummy        VARCHAR2 (1);
   v_dummy1       NUMBER (10)      := 0;
   v_dummy2       VARCHAR2 (1);
   v_partition1   NVARCHAR2 (2000);
   v_partition2   NVARCHAR2 (2000);
   v_dummy3       VARCHAR2 (2000);
   dummy_cur      sys_refcursor;
   v_ind          NVARCHAR2 (2000);
BEGIN
   v_vartime := SYSDATE;
   v_maxtime := dbo.mtmaxdate (); /* Checking the following Business rules */     /* Check that either Interval or Partition is specified */

   IF (   (p_partition IS NOT NULL AND p_intervalid IS NOT NULL)
       OR (p_partition IS NULL AND p_intervalid IS NULL)
      )
   THEN
      p_result :=
         '2000001-archive_delete operation failed-->Either Partition or Interval should be specified';
      ROLLBACK;
      RETURN;
   END IF;

   IF (p_partition IS NOT NULL)
   THEN
      SELECT COUNT (id_interval)
        INTO v_count
        FROM t_partition_interval_map MAP
       WHERE id_partition IN (SELECT id_partition
                                FROM t_partition
                               WHERE partition_name = p_partition);

      IF (v_count = 0)
      THEN
         p_result :=
            '2000002-archive_delete operation failed-->None of the Intervals in the Partition needs to be archived';
         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0; /* Partition should not already by archived */

      SELECT COUNT (*)
        INTO v_count
        FROM t_archive_partition
       WHERE partition_name = p_partition
         AND status = 'A'
         AND tt_end = v_maxtime;

      IF (v_count > 0)
      THEN
         p_result :=
            '2000003-archive_delete operation failed-->Partition already archived';
         ROLLBACK;
         RETURN;
      END IF; /* Get the list of intervals that need to be archived */

      v_sql1 :=
            'select id_interval from t_partition_interval_map map where id_partition 
        = (select id_partition  from t_partition where partition_name = '''
         || p_partition
         || ''')';

      OPEN interval_id FOR v_sql1;
   ELSE
      v_sql1 := 'select ' || p_intervalid || ' from dual';

      SELECT b_partitioning_enabled
        INTO v_dummy
        FROM t_usage_server;

      IF (v_dummy = 'Y')
      THEN
         SELECT partition_name
           INTO v_partition1
           FROM t_partition part INNER JOIN t_partition_interval_map MAP
                ON part.id_partition = MAP.id_partition
              AND MAP.id_interval = p_intervalid
                ;
      END IF;

      OPEN interval_id FOR v_sql1;
   END IF;

   LOOP
      FETCH interval_id
       INTO v_interval;

      EXIT WHEN interval_id%NOTFOUND;
      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_archive
       WHERE id_interval = v_interval
         AND status = 'A'
         AND tt_end = dbo.mtmaxdate ();

      IF v_count > 0
      THEN
         p_result :=
            '2000004-archive operation failed-->Interval is already archived';

         CLOSE interval_id;

         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_archive
       WHERE id_interval = v_interval
         AND status = 'E'
         AND tt_end = dbo.mtmaxdate;

      SELECT COUNT (1)
        INTO v_count1
        FROM t_acc_usage
       WHERE id_usage_interval = v_interval;

      IF (v_count = 0 and v_count1 > 0)
      THEN
         p_result :=
            '2000005-archive operation failed-->Interval is not exported..run the archive_export procedure';

         CLOSE interval_id;

         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_archive
       WHERE id_interval = v_interval
         AND status = 'D'
         AND tt_end = dbo.mtmaxdate;

      IF v_count > 0
      THEN
         p_result :=
            '2000006-archive operation failed-->Interval is Dearchived..run the trash procedure';

         CLOSE interval_id;

         ROLLBACK;
         RETURN;
      END IF;
   END LOOP;

   CLOSE interval_id; /* Open a dynamic cursor to get the list of intervals that need to be archived */

   IF (p_partition IS NOT NULL)
   THEN
      v_sql1 :=
            'select id_interval from t_partition_interval_map map where id_partition 
        = (select id_partition  from t_partition where partition_name = '''
         || p_partition
         || ''')';

      OPEN interval_id FOR v_sql1;
   ELSE
      v_sql1 := 'select ' || p_intervalid || ' from dual';

      OPEN interval_id FOR v_sql1;
   END IF;

   LOOP
      FETCH interval_id
       INTO v_interval;

      EXIT WHEN interval_id%NOTFOUND; /* Populate the temporary table with the records in t_adjustment_transaction that are going to be deleted */

      IF table_exists ('tmp_t_adjustment_transaction')
      THEN
         execute immediate 'delete from tmp_t_adjustment_transaction';
      END IF;

      v_sql1 :=
            'insert into tmp_t_adjustment_transaction SELECT id_adj_trx FROM t_adjustment_transaction where id_usage_interval= '
         || CAST (v_interval AS VARCHAR2);

      EXECUTE IMMEDIATE v_sql1;

      IF table_exists ('tmp_adjustment')
      THEN
         exec_ddl ('truncate table tmp_adjustment');
      END IF;

      OPEN c2 FOR 'select table_name from user_tables where 
    upper(table_name) like ''T_AJ_%'' and table_name not in (''T_AJ_TEMPLATE_REASON_CODE_MAP'',''T_AJ_TYPE_APPLIC_MAP'')';

      LOOP
         FETCH c2
          INTO v_var1;

         EXIT WHEN c2%NOTFOUND; /*Get the name of t_aj tables that have usage in this interval*/
         v_count := 0;

         OPEN v_cur FOR    'select count(1) from '
                        || v_var1
                        || ' where id_adjustment in 
                (select id_adj_trx from t_adjustment_transaction where id_usage_interval = '
                        || CAST (v_interval AS VARCHAR2)
                        || ')';

         FETCH v_cur
          INTO v_count;

         CLOSE v_cur;

         IF v_count > 0
         THEN
            INSERT INTO tmp_adjustment
                 VALUES (v_var1);
         END IF;
      END LOOP;

      CLOSE c2;

      OPEN c1 FOR 'select distinct name from tmp_adjustment';

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND; /*Delete from t_aj tables */

         BEGIN
            v_sql1 :=
                  'delete FROM '
               || v_var1
               || ' aj where exists (select 1 from tmp_t_adjustment_transaction tmp where aj.id_adjustment = tmp.id_adj_trx)';

            EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '2000007-archive operation failed-->Error in t_aj tables Delete operation';
               ROLLBACK;

               CLOSE c1;

               CLOSE interval_id;

               RETURN;
         END;
      END LOOP;

      CLOSE c1; /*Delete from t_adjustment_transaction table*/

      BEGIN
         DELETE FROM t_adjustment_transaction
               WHERE id_usage_interval = v_interval;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
                '2000008-Error in Delete from t_adjustment_transaction table';
            ROLLBACK;

            CLOSE interval_id;

            RETURN;
      END; /*Checking for post bill adjustments that have corresponding usage archived*/

      IF table_exists ('tmp_t_adjust_txn_temp')
      THEN
         execute immediate 'delete from tmp_t_adjust_txn_temp';
      END IF;

      BEGIN
         INSERT INTO tmp_t_adjust_txn_temp
            SELECT id_sess
              FROM t_adjustment_transaction
             WHERE n_adjustmenttype = 1
               AND id_sess IN (SELECT id_sess
                                 FROM t_acc_usage
                                WHERE id_usage_interval = v_interval);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000009-archive operation failed-->Error in populating adjustment temp table operation';
            ROLLBACK;

            CLOSE interval_id;

            RETURN;
      END;

      v_count := 0;

      SELECT COUNT (*)
        INTO v_count
        FROM tmp_t_adjust_txn_temp;

      IF (v_count > 0)
      THEN
         BEGIN
            UPDATE t_adjustment_transaction
               SET archive_sess = id_sess,
                   id_sess = NULL
             WHERE id_sess IN (SELECT id_sess
                                 FROM tmp_t_adjust_txn_temp);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '2000010-archive operation failed-->Error in Update adjustment operation';
               ROLLBACK;
               RETURN;
         END;
      END IF;

      BEGIN
         UPDATE t_acc_bucket_map
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE id_usage_interval = v_interval
            AND status = 'E'
            AND tt_end = dbo.mtmaxdate;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000011-archive operation failed-->Error in update t_acc_bucket_map table';
            ROLLBACK;

            CLOSE interval_id;

            RETURN;
      END;

      BEGIN
         INSERT INTO t_acc_bucket_map
            SELECT v_interval, id_acc, bucket, 'A', v_vartime, v_maxtime
              FROM t_acc_bucket_map
             WHERE id_usage_interval = v_interval
               AND status = 'E'
               AND tt_end = dbo.subtractsecond (v_vartime);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000012-archive operation failed-->Error in insert into t_acc_bucket_map table';
            ROLLBACK;

            CLOSE interval_id;

            RETURN;
      END;

      BEGIN
         UPDATE t_archive
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE id_interval = v_interval
            AND status = 'E'
            AND tt_end = dbo.mtmaxdate;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000013-archive operation failed-->Error in update t_archive table';
            ROLLBACK;

            CLOSE interval_id;

            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive
            SELECT v_interval, id_view, adj_name, 'A', v_vartime, v_maxtime
              FROM t_archive
             WHERE id_interval = v_interval
               AND status = 'E'
               AND tt_end = dbo.subtractsecond (v_vartime);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000014-archive operation failed-->Error in insert t_archive table';
            ROLLBACK;

            CLOSE interval_id;

            RETURN;
      END;
   END LOOP;

   CLOSE interval_id; /* This step is just an optimization if the user specifis interval but that interval is the only interval in the partition then we can truncate the tables/partition instead of delete */

   IF (p_partition IS NULL)
   THEN
      v_dummy1 := 0;

      SELECT COUNT (*)
        INTO v_dummy1
        FROM t_partition_interval_map MAP
       WHERE id_partition = (SELECT id_partition
                               FROM t_partition_interval_map
                              WHERE id_interval = p_intervalid);

      SELECT b_partitioning_enabled
        INTO v_dummy2
        FROM t_usage_server;

      IF (v_dummy1 <= 1 AND v_dummy2 = 'Y')
      THEN
         v_partition2 := v_partition1;
      END IF;
   END IF;

   IF (NVL (p_partition, v_partition2) IS NOT NULL)
   THEN
      OPEN c1 FOR    'select distinct id_view from t_acc_usage where id_usage_interval = '
                  || v_interval;

      IF table_exists ('tmp_id_view')
      THEN
         exec_ddl ('truncate table tmp_id_view');
      END IF;

      INSERT INTO tmp_id_view
         SELECT DISTINCT id_view
                    FROM t_acc_usage
                   WHERE id_usage_interval = v_interval;

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;

         FOR i IN
            (SELECT nm_table_name
               FROM t_prod_view
              WHERE id_view = v_var1) /*and nm_table_name not like '%temp%'*/
         LOOP
            v_tab1 := i.nm_table_name;
         END LOOP;

         BEGIN /*Delete from product view tables*/
            v_sql1 :=
                  'select partition_name from user_tab_partitions where table_name = upper('''
               || v_tab1
               || ''') 
                  and tablespace_name = '''
               || NVL (p_partition, v_partition2)
               || '''';

            EXECUTE IMMEDIATE v_sql1
                         INTO v_dummy3;

            v_sql1 :=
                'alter table ' || v_tab1 || ' truncate partition ' || v_dummy3;
            exec_ddl (v_sql1);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '2000015-archive operation failed-->Error in product view Delete operation';
               ROLLBACK;

               CLOSE c1;

               RETURN;
         END;

         v_sql1 :=
               'select index_name from user_indexes where table_name = upper('''
            || v_tab1
            || ''')  
            AND partitioned = ''NO'' and status <> ''VALID''';

         OPEN dummy_cur FOR v_sql1;

         LOOP
            FETCH dummy_cur
             INTO v_ind;

            EXIT WHEN dummy_cur%NOTFOUND;

            BEGIN
               v_sql1 := 'alter index ' || v_ind || ' rebuild';
               exec_ddl (v_sql1);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '2000015a-archive operation failed-->Error in product view index rebuild operation';
                  ROLLBACK;

                  CLOSE dummy_cur;

                  CLOSE c1;

                  RETURN;
            END;
         END LOOP;

         CLOSE dummy_cur;
      END LOOP;

      CLOSE c1; /*Delete from t_acc_usage table*/

      BEGIN
         v_dummy3 := '';
         v_sql1 :=
               'select partition_name from user_tab_partitions where table_name = ''T_ACC_USAGE'' 
            and tablespace_name = '''
            || NVL (p_partition, v_partition2)
            || '''';

         EXECUTE IMMEDIATE v_sql1
                      INTO v_dummy3;

         v_sql1 := 'alter table t_acc_usage truncate partition ' || v_dummy3;
         exec_ddl (v_sql1);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000016-archive operation failed-->Error in Delete t_acc_usage operation';
            ROLLBACK;
            RETURN;
      END;

      v_sql1 :=
         'select index_name from user_indexes where table_name = ''T_ACC_USAGE''  
        AND partitioned = ''NO'' and status <> ''VALID''';

      OPEN dummy_cur FOR v_sql1;

      LOOP
         FETCH dummy_cur
          INTO v_ind;

         EXIT WHEN dummy_cur%NOTFOUND;

         BEGIN
            v_sql1 := 'alter index ' || v_ind || ' rebuild';
            exec_ddl (v_sql1);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '2000016a-archive operation failed-->Error in Usage index rebuild operation';
               ROLLBACK;

               CLOSE dummy_cur;

               RETURN;
         END;
      END LOOP;

      CLOSE dummy_cur;
   END IF;

   IF ((NVL (p_partition, v_partition2) IS NULL) AND p_intervalid IS NOT NULL
      )
   THEN
      OPEN c1 FOR    'select distinct id_view from t_acc_usage where id_usage_interval = '
                  || v_interval;

      IF table_exists ('tmp_id_view')
      THEN
         exec_ddl ('truncate table tmp_id_view');
      END IF;

      INSERT INTO tmp_id_view
         SELECT DISTINCT id_view
                    FROM t_acc_usage
                   WHERE id_usage_interval = v_interval;

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;

         FOR i IN
            (SELECT nm_table_name
               FROM t_prod_view
              WHERE id_view = v_var1) /*and nm_table_name not like '%temp%'*/
         LOOP
            v_tab1 := i.nm_table_name;
         END LOOP;

         BEGIN /*Delete from product view tables*/
            v_sql1 :=
                  'delete FROM '
               || v_tab1
               || ' where exists (select 1 from t_acc_usage au where '
               || v_tab1
               || '.id_sess = au.id_sess 
                        and au.id_usage_interval = '
               || v_tab1
               || '.id_usage_interval)';

            EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '2000017-archive operation failed-->Error in product view Delete operation';
               ROLLBACK;

               CLOSE c1;

               RETURN;
         END;
      END LOOP;

      CLOSE c1; /*Delete from t_acc_usage table*/

      BEGIN
         v_sql1 :=
               'delete from t_acc_usage where id_usage_interval = '
            || p_intervalid;

         EXECUTE IMMEDIATE v_sql1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000018-archive operation failed-->Error in Delete t_acc_usage operation';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   v_count := 0;

   SELECT b_partitioning_enabled
     INTO v_dummy
     FROM t_usage_server;

   SELECT COUNT (1)
     INTO v_dummy1
     FROM t_partition_interval_map MAP INNER JOIN t_archive inte
          ON inte.id_interval = MAP.id_interval
        AND inte.tt_end = v_maxtime
        AND inte.status = 'A'
    WHERE MAP.id_partition = (SELECT id_partition
                                FROM t_partition_interval_map
                               WHERE id_interval = p_intervalid);

   SELECT COUNT (*)
     INTO v_count
     FROM t_partition_interval_map MAP
    WHERE id_partition = (SELECT id_partition
                            FROM t_partition_interval_map
                           WHERE id_interval = p_intervalid); /* if all the intervals are archived, modify the status in t_archive_partition table */

   IF ((p_partition IS NOT NULL OR v_dummy1 = v_count) AND v_dummy = 'Y')
   THEN
      BEGIN
         UPDATE t_archive_partition
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE partition_name = NVL (p_partition, v_partition1)
            AND tt_end = v_maxtime
            AND status = 'E';
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000021-archive operation failed-->Error in update t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive_partition
              VALUES (NVL (p_partition, v_partition1), 'A', v_vartime,
                      v_maxtime);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000022-archive operation failed-->Error in insert into t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         UPDATE t_partition
            SET b_active = 'N'
          WHERE partition_name = NVL (p_partition, v_partition1);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '2000023-archive operation failed-->Error in update t_partition table';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   p_result := '0-archive_delete operation successful';
   COMMIT;
END;
/
CREATE OR REPLACE PROCEDURE archive_trash (
   p_partition             NVARCHAR2 DEFAULT NULL,
   p_intervalid            INT,
   p_accountidlist         VARCHAR2,
   p_result          OUT   VARCHAR2
)
AS
       /*        How to run this stored procedure
   DECLARE
     P_PARTITION NVARCHAR2(200);
     P_INTERVALID NUMBER;
     p_accountIDList varchar2(2000);
     P_RESULT VARCHAR2(200);
   BEGIN
     p_accountIDList := null;
     P_PARTITION := 'HS_20070131';
     P_INTERVALID := null;
     P_RESULT := NULL;

     ARCHIVE_trash ( P_PARTITION, P_INTERVALID,p_accountIDList, P_RESULT );
     DBMS_OUTPUT.PUT_LINE(P_RESULT);
     COMMIT;
   END;
   or
   DECLARE
     P_PARTITION NVARCHAR2(200);
     P_INTERVALID NUMBER;
     p_accountIDList varchar2(2000);
     P_RESULT VARCHAR2(200);
   BEGIN
     p_accountIDList := null;
     P_PARTITION := null;
     P_INTERVALID := 885653507;
     P_RESULT := NULL;

     ARCHIVE_trash ( P_PARTITION, P_INTERVALID,p_accountIDList, P_RESULT );
     DBMS_OUTPUT.PUT_LINE(P_RESULT);
     COMMIT;
   END;
   */
   v_sql1            VARCHAR2 (4000);
   v_tab1            NVARCHAR2 (1000);
   v_var1            NVARCHAR2 (1000);
   v_vartime         DATE;
   v_maxtime         DATE;
   v_dbname          NVARCHAR2 (100);
   v_count           NUMBER (10)      := 0;
   v_accountidlist   VARCHAR2 (4000)  := p_accountidlist;
   c1                sys_refcursor;
   c2                sys_refcursor;
   v_dummy3          VARCHAR2 (2000);
   dummy_cur         sys_refcursor;
   v_ind             NVARCHAR2 (2000);
   interval_id       sys_refcursor;
   v_cur             sys_refcursor;
   v_interval        INT;
   v_partname        VARCHAR2 (30);
   v_dummy			 VARCHAR2 (1);
BEGIN
   v_vartime := SYSDATE;
   v_maxtime := dbo.mtmaxdate;

   /*Checking the following Business rules */

   /* Either Partition or IntervalId/AccountId can be specified */
   IF (   (p_partition IS NOT NULL AND p_intervalid IS NOT NULL)
       OR (p_partition IS NULL AND p_intervalid IS NULL)
       OR (p_partition IS not NULL AND p_accountidlist IS NOT NULL)
      )
   THEN
      p_result :=
         '3000001-archive_trash operation failed-->Either Partition or Interval/AccountId should be specified';
      ROLLBACK;
      RETURN;
   END IF;

   IF (p_partition IS NOT NULL)
   THEN
      /*partition should be already archived or Dearchived */
      SELECT COUNT (1)
        INTO v_count
        FROM t_archive_partition
       WHERE partition_name = p_partition
         AND status IN ('A', 'D')
         AND tt_end = v_maxtime;

      IF (v_count = 0)
      THEN
         p_result :=
            '3000002-trash operation failed-->partition is not already archived/dearchived';
         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;

      /* partition should have atleast 1 Interval that is dearchived */
      SELECT COUNT (*)
        INTO v_count
        FROM t_archive
       WHERE status = 'D'
         AND tt_end = v_maxtime
         AND id_interval IN (SELECT id_interval
                               FROM t_partition_interval_map MAP INNER JOIN t_partition part
                                    ON MAP.id_partition = part.id_partition
                              WHERE part.partition_name = p_partition);

      IF (v_count = 0)
      THEN
         p_result :=
            '3000002a-trash operation failed-->none of the intervals of partition is dearchived';
         ROLLBACK;
         RETURN;
      END IF;
   END IF;

   IF (p_partition IS NOT NULL)
   THEN
      v_count := 0;
      v_sql1 :=
            'select id_interval from t_partition_interval_map map where id_partition 
				in (select id_partition  from t_partition where partition_name = '''
         || p_partition
         || ''')';

      OPEN interval_id FOR v_sql1;

      LOOP
         FETCH interval_id
          INTO v_interval;

         EXIT WHEN interval_id%NOTFOUND;

         OPEN c1 FOR    'select distinct id_view from t_acc_usage where id_usage_interval = '
                     || v_interval;

         IF table_exists ('tmp_id_view')
         THEN
            execute immediate ('delete from tmp_id_view');
         END IF;

         INSERT INTO tmp_id_view
            SELECT DISTINCT id_view
                       FROM t_acc_usage
                      WHERE id_usage_interval = v_interval;

         LOOP
            FETCH c1
             INTO v_var1;

            EXIT WHEN c1%NOTFOUND;

            FOR i IN
               (SELECT nm_table_name
                  FROM t_prod_view
                 WHERE id_view = v_var1)
                                      /*and nm_table_name not like '%temp%'*/
            LOOP
               v_tab1 := i.nm_table_name;
            END LOOP;

            BEGIN
               /*Delete from product view tables*/
               v_sql1 :=
                     'select partition_name from user_tab_partitions where table_name = upper('''
                  || v_tab1
                  || ''') 
                  and tablespace_name = '''
                  || p_partition
                  || '''';

               EXECUTE IMMEDIATE v_sql1
                            INTO v_dummy3;

               v_sql1 :=
                  'alter table ' || v_tab1 || ' truncate partition '
                  || v_dummy3;
               exec_ddl (v_sql1);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '3000003-archive trash operation failed-->Error in product view Delete operation';
                  ROLLBACK;

                  CLOSE c1;

                  RETURN;
            END;

            v_sql1 :=
                  'select index_name from user_indexes where table_name = upper('''
               || v_tab1
               || ''')  
            AND partitioned = ''NO'' and status <> ''VALID''';

            OPEN dummy_cur FOR v_sql1;

            LOOP
               FETCH dummy_cur
                INTO v_ind;

               EXIT WHEN dummy_cur%NOTFOUND;

               BEGIN
                  v_sql1 := 'alter index ' || v_ind || ' rebuild';
                  exec_ddl (v_sql1);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     p_result :=
                        '3000003a-archive trash operation failed--->Error in product view index rebuild operation';
                     ROLLBACK;

                     CLOSE dummy_cur;

                     CLOSE c1;

                     RETURN;
               END;
            END LOOP;

            CLOSE dummy_cur;
         END LOOP;

         CLOSE c1;

         v_count := 0;

         IF table_exists ('tmp_adjustment')
         THEN
            execute immediate ('delete from tmp_adjustment');
         END IF;

         OPEN c2 FOR 'select table_name from user_tables where 
        upper(table_name) like ''T_AJ_%'' and table_name not in (''T_AJ_TEMPLATE_REASON_CODE_MAP'',''T_AJ_TYPE_APPLIC_MAP'')';

         LOOP
            FETCH c2
             INTO v_var1;

            EXIT WHEN c2%NOTFOUND;
            v_sql1 :=
                  'select count(1) from '
               || v_var1
               || ' where id_adjustment in 
                (select id_adj_trx from t_adjustment_transaction where id_usage_interval = '
               || CAST (v_interval AS VARCHAR2)
               || ')';

            OPEN v_cur FOR v_sql1;

            FETCH v_cur
             INTO v_count;

            CLOSE v_cur;

            IF v_count > 0
            THEN
               INSERT INTO tmp_adjustment
                    VALUES (v_var1);
            END IF;
         END LOOP;

         CLOSE c2;

         IF table_exists ('tmp_t_adjustment_transaction')
         THEN
            execute immediate ('delete from tmp_t_adjustment_transaction');
         END IF;

         v_sql1 :=
               'insert into tmp_t_adjustment_transaction SELECT id_adj_trx FROM t_adjustment_transaction where id_usage_interval= '
            || CAST (v_interval AS VARCHAR2);

         EXECUTE IMMEDIATE v_sql1;

         OPEN c1 FOR 'select distinct name from tmp_adjustment';

         LOOP
            FETCH c1
             INTO v_var1;

            EXIT WHEN c1%NOTFOUND;

            /*Delete from t_aj tables */
            BEGIN
               v_sql1 :=
                     'delete FROM '
                  || v_var1
                  || ' aj where exists (select 1 from tmp_t_adjustment_transaction tmp where aj.id_adjustment = tmp.id_adj_trx)';

               EXECUTE IMMEDIATE (v_sql1);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '3000004-archive operation failed-->Error in t_aj tables Delete operation';
                  ROLLBACK;

                  CLOSE c1;

                  RETURN;
            END;
         END LOOP;

         CLOSE c1;

         /*Delete from t_adjustment_transaction table*/
         BEGIN
            DELETE FROM t_adjustment_transaction
                  WHERE id_usage_interval = v_interval;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000005-Error in Delete from t_adjustment_transaction table';
               ROLLBACK;
               RETURN;
         END;

         /*Checking for post bill adjustments that have corresponding usage archived*/
         IF table_exists ('tmp_t_adjust_txn_temp')
         THEN
            execute immediate ('delete from tmp_t_adjust_txn_temp');
         END IF;

         BEGIN
            INSERT INTO tmp_t_adjust_txn_temp
               SELECT id_sess
                 FROM t_adjustment_transaction
                WHERE n_adjustmenttype = 1
                  AND id_sess IN (SELECT id_sess
                                    FROM t_acc_usage
                                   WHERE id_usage_interval = v_interval);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000006-archive operation failed-->Error in create adjustment temp table operation';
               ROLLBACK;

               CLOSE interval_id;

               RETURN;
         END;

         v_count := 0;

         SELECT COUNT (*)
           INTO v_count
           FROM tmp_t_adjust_txn_temp;

         IF (v_count > 0)
         THEN
            BEGIN
               UPDATE t_adjustment_transaction
                  SET archive_sess = id_sess,
                      id_sess = NULL
                WHERE id_sess IN (SELECT id_sess
                                    FROM tmp_t_adjust_txn_temp);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '3000007-archive operation failed-->Error in Update adjustment operation';
                  ROLLBACK;
                  RETURN;
            END;
         END IF;

         /*Delete from t_acc_usage table*/
         BEGIN
            v_dummy3 := '';
            v_sql1 :=
                  'select partition_name from user_tab_partitions where table_name = ''T_ACC_USAGE'' 
            and tablespace_name = '''
               || p_partition
               || '''';

            EXECUTE IMMEDIATE v_sql1
                         INTO v_dummy3;

            v_sql1 :=
                     'alter table t_acc_usage truncate partition ' || v_dummy3;
            exec_ddl (v_sql1);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000008-archive operation failed-->Error in Delete t_acc_usage operation';
               ROLLBACK;
               RETURN;
         END;

         v_sql1 :=
            'select index_name from user_indexes where table_name = ''T_ACC_USAGE''  
        AND partitioned = ''NO'' and status <> ''VALID''';

         OPEN dummy_cur FOR v_sql1;

         LOOP
            FETCH dummy_cur
             INTO v_ind;

            EXIT WHEN dummy_cur%NOTFOUND;

            BEGIN
               v_sql1 := 'alter index ' || v_ind || ' rebuild';
               exec_ddl (v_sql1);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '3000008a-archive operation failed-->Error in Usage index rebuild operation';
                  ROLLBACK;

                  CLOSE dummy_cur;

                  RETURN;
            END;
         END LOOP;

         CLOSE dummy_cur;

         BEGIN
            UPDATE t_archive
               SET tt_end = dbo.subtractsecond (v_vartime)
             WHERE id_interval = v_interval
               AND status = 'D'
               AND tt_end = v_maxtime;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000009-archive operation failed-->Error in update t_archive table';
               ROLLBACK;

               CLOSE interval_id;

               RETURN;
         END;

         BEGIN
            INSERT INTO t_archive
               SELECT v_interval, id_view, adj_name, 'A', v_vartime,
                      v_maxtime
                 FROM t_archive
                WHERE id_interval = v_interval
                  AND status = 'D'
                  AND tt_end = dbo.subtractsecond (v_vartime);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000010-archive operation failed-->Error in insert t_archive table';
               ROLLBACK;

               CLOSE interval_id;

               RETURN;
         END;

         BEGIN
            UPDATE t_acc_bucket_map
               SET tt_end = dbo.subtractsecond (v_vartime)
             WHERE id_usage_interval = v_interval
               AND status = 'D'
               AND tt_end = dbo.mtmaxdate;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000011-archive operation failed-->Error in update t_acc_bucket_map table';
               ROLLBACK;

               CLOSE interval_id;

               RETURN;
         END;

         BEGIN
            INSERT INTO t_acc_bucket_map
               SELECT v_interval, id_acc, bucket, 'A', v_vartime, v_maxtime
                 FROM t_acc_bucket_map
                WHERE id_usage_interval = v_interval
                  AND status = 'D'
                  AND tt_end = dbo.subtractsecond (v_vartime);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000012-archive operation failed-->Error in insert into t_acc_bucket_map table';
               ROLLBACK;

               CLOSE interval_id;

               RETURN;
         END;
      END LOOP;

      CLOSE interval_id;

      BEGIN
         UPDATE t_archive_partition
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE partition_name = p_partition
            AND tt_end = v_maxtime
            AND status = 'D';
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '3000012a-archive operation failed-->Error in update t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive_partition
              VALUES (p_partition, 'A', v_vartime, v_maxtime);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '3000012b-archive operation failed-->Error in insert into t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         UPDATE t_partition
            SET b_active = 'N'
          WHERE partition_name = p_partition;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '3000012c-archive operation failed-->Error in update t_partition table';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   IF (p_intervalid IS NOT NULL)
   THEN
      v_count := 0;

/*      Interval should be already archived*/
      SELECT COUNT (1)
        INTO v_count
        FROM t_archive
       WHERE id_interval = p_intervalid
         AND status IN ('A', 'D')
         AND tt_end = dbo.mtmaxdate;

      IF v_count = 0
      THEN
         p_result :=
            '30000013-trash operation failed-->Interval is not already archived/dearchived';
         RETURN;
      END IF;

      IF table_exists ('tmp_accountidstable')
      THEN
         BEGIN
            execute immediate ('delete from tmp_accountidstable');
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

/* This is to populate the temp table with all the accounts that needs to be deleted */

      IF (v_accountidlist IS NOT NULL)
      THEN
         WHILE INSTR (v_accountidlist, ',') > 0
         LOOP
            INSERT INTO tmp_accountidstable
                        (ID)
               SELECT SUBSTR (v_accountidlist,
                              1,
                              (INSTR (v_accountidlist, ',') - 1)
                             )
                 FROM DUAL;

            v_accountidlist :=
               SUBSTR (v_accountidlist,
                       (INSTR (v_accountidlist, ',') + 1),
                       (  LENGTH (v_accountidlist)
                        - (INSTR (v_accountidlist, ','))
                       )
                      );
         END LOOP;

         INSERT INTO tmp_accountidstable
                     (ID
                     )
              VALUES (v_accountidlist
                     );
      ELSE
         v_sql1 :=
               'insert into tmp_AccountIDsTable(ID) select distinct id_acc from t_acc_usage where id_usage_interval = '
            || CAST (p_intervalid AS VARCHAR2);

         EXECUTE IMMEDIATE v_sql1;
      END IF;

   v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_acc_bucket_map
       WHERE id_usage_interval = p_intervalid
         AND status = 'D'
         AND tt_end = dbo.mtmaxdate;

      IF v_count = 0
      THEN
         p_result :=
            '3000014-trash operation failed-->account in the list is not dearchived';
         ROLLBACK;
         RETURN;
      END IF;

      IF table_exists ('tmp_t_acc_usage')
      THEN
         BEGIN
            EXECUTE IMMEDIATE 'delete from tmp_t_acc_usage';
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      IF table_exists ('tmp_t_adjustment_transaction')
      THEN
         BEGIN
            EXECUTE IMMEDIATE 'delete from tmp_t_adjustment_transaction';
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      EXECUTE IMMEDIATE    'insert into tmp_t_acc_usage
        SELECT id_sess,id_usage_interval,id_acc  FROM t_acc_usage where id_usage_interval='
                        || CAST (p_intervalid AS VARCHAR2)
                        || ' and id_acc in (select id from tmp_AccountIDsTable)';

      OPEN c1 FOR    'select distinct id_view from t_acc_usage 
        where id_usage_interval = '
                  || p_intervalid;

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;

         FOR i IN
            (SELECT nm_table_name
               FROM t_prod_view
              WHERE id_view = v_var1)
                                     /*and nm_table_name not like '%temp%' */
         LOOP
            v_tab1 := i.nm_table_name;
         END LOOP;

         /*Delete from product view tables*/
         BEGIN
            v_sql1 :=
                  'delete '
               || v_tab1
               || ' pv where exists (select 1 from 
                              tmp_t_acc_usage tmp where pv.id_sess = tmp.id_sess)';

            EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000015-trash operation failed-->Error in PV Delete operation';
               ROLLBACK;

               CLOSE c1;

               RETURN;
         END;
      END LOOP;

      CLOSE c1;

      v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_acc_usage
       WHERE id_usage_interval = p_intervalid
         AND id_acc NOT IN (SELECT ID
                              FROM tmp_accountidstable);

      IF (v_count = 0)
      THEN
         EXECUTE IMMEDIATE 'delete from tmp_id_view';

         INSERT INTO tmp_id_view
            SELECT DISTINCT id_view
                       FROM t_acc_usage
                      WHERE id_usage_interval = p_intervalid;

         EXECUTE IMMEDIATE    'insert into tmp_t_adjustment_transaction SELECT id_adj_trx FROM
            t_adjustment_transaction where id_usage_interval='
                           || CAST (p_intervalid AS VARCHAR2);

         OPEN c1 FOR
            SELECT table_name
              FROM user_tables
             WHERE UPPER (table_name) LIKE 'T_AJ_%'
               AND table_name NOT IN
                      ('T_AJ_TEMPLATE_REASON_CODE_MAP',
                       'T_AJ_TYPE_APPLIC_MAP');

         LOOP
            FETCH c1
             INTO v_var1;

            EXIT WHEN c1%NOTFOUND;
            /*Get the name of t_aj tables that have usage in this interval*/
            v_count := 0;
            v_sql1 :=
                  'select count(1) from '
               || v_var1
               || ' where id_adjustment in (select id_adj_trx from t_adjustment_transaction where id_usage_interval = '
               || CAST (p_intervalid AS VARCHAR2)
               || ')';

            OPEN c2 FOR v_sql1;

            FETCH c2
             INTO v_count;

            CLOSE c2;

            IF v_count > 0
            THEN
               INSERT INTO tmp_adjustment
                    VALUES (v_var1);
            END IF;
         END LOOP;

         CLOSE c1;

         OPEN c1 FOR 'select distinct name from tmp_adjustment';

         LOOP
            FETCH c1
             INTO v_var1;

            EXIT WHEN c1%NOTFOUND;
            /*Delete from t_aj tables*/
            v_sql1 :=
                  'delete '
               || v_var1
               || ' aj where exists (select 1 from tmp_t_adjustment_transaction tmp
                        where aj.id_adjustment = tmp.id_adj_trx)';

            BEGIN
               EXECUTE IMMEDIATE v_sql1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '30000016-trash operation failed-->Error in Delete from t_aj tables';
                  ROLLBACK;

                  CLOSE c1;

                  RETURN;
            END;
         END LOOP;

         CLOSE c1;

         /* Delete from t_adjustment_transaction table */
         BEGIN
            DELETE FROM t_adjustment_transaction
                  WHERE id_usage_interval = p_intervalid;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '30000017-Error in Delete from t_adjustment_transaction table';
               ROLLBACK;
               RETURN;
         END;

         /*Checking for post bill adjustments that have corresponding usage archived*/
         IF table_exists ('tmp_t_adjust_txn_temp')
         THEN
            execute immediate ('delete from tmp_t_adjust_txn_temp');
         END IF;

         BEGIN
            INSERT INTO tmp_t_adjust_txn_temp
               SELECT id_sess
                 FROM t_adjustment_transaction
                WHERE n_adjustmenttype = 1
                  AND id_sess IN (SELECT id_sess
                                    FROM t_acc_usage
                                   WHERE id_usage_interval = p_intervalid);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '30000018-archive operation failed-->Error in create adjustment temp table operation';
               ROLLBACK;
               RETURN;
         END;

         v_count := 0;

         SELECT COUNT (1)
           INTO v_count
           FROM tmp_t_adjust_txn_temp;

         IF (v_count > 0)
         THEN
            BEGIN
               UPDATE t_adjustment_transaction
                  SET archive_sess = id_sess,
                      id_sess = NULL
                WHERE id_sess IN (SELECT id_sess
                                    FROM tmp_t_adjust_txn_temp);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                     '3000019-trash operation failed-->Error in Update adjustment operation';
                  ROLLBACK;
                  RETURN;
            END;
         END IF;

         BEGIN
            UPDATE t_archive
               SET tt_end = dbo.subtractsecond (v_vartime)
             WHERE id_interval = p_intervalid
               AND status = 'D'
               AND tt_end = dbo.mtmaxdate;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000020-trash operation failed-->error in update t_acc_bucket_map';
               ROLLBACK;
               RETURN;
         END;

         BEGIN
            INSERT INTO t_archive
               SELECT p_intervalid, id_view, NULL, 'A', v_vartime, v_maxtime
                 FROM tmp_id_view
               UNION ALL
               SELECT DISTINCT p_intervalid, NULL, NAME, 'A', v_vartime,
                               v_maxtime
                          FROM tmp_adjustment;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000021-trash operation failed-->error in insert into t_acc_bucket_map';
               ROLLBACK;
               RETURN;
         END;
      END IF;

      /* Delete from t_acc_usage table */
      BEGIN
         DELETE      t_acc_usage au
               WHERE EXISTS (SELECT 1
                               FROM tmp_t_acc_usage tmp
                              WHERE au.id_sess = tmp.id_sess);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '3000022-trash operation failed-->Error in Delete t_acc_usage operation';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         UPDATE t_acc_bucket_map
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE id_usage_interval = p_intervalid
            AND id_acc IN (SELECT ID
                             FROM tmp_accountidstable)
            AND status = 'D'
            AND tt_end = v_maxtime;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '3000023-trash operation failed-->error in update t_acc_bucket_map';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
        insert into t_acc_bucket_map(id_usage_interval,id_acc,bucket,status,tt_start,tt_end)
            select p_intervalid,id,bucket,'A',v_vartime,v_maxtime
            from tmp_AccountIDsTable tmp
            inner join t_acc_bucket_map act on tmp.id = act.id_acc
            and act.id_usage_interval = p_intervalid
            and act.status = 'D'
            and tt_end = dbo.subtractsecond(v_vartime);
      EXCEPTION
         WHEN OTHERS
         THEN
            dbms_output.put_line(sqlerrm);
            p_result :=
               '3000024-trash operation failed-->error in insert into t_acc_bucket_map';
            ROLLBACK;
            RETURN;
      END;

      v_count := 0;

     SELECT b_partitioning_enabled
     INTO v_dummy
     FROM t_usage_server;
     if (v_dummy = 'Y')
	 THEN
		SELECT partition_name
        INTO v_partname
        FROM t_partition_interval_map MAP INNER JOIN t_partition part
             ON MAP.id_partition = part.id_partition
		WHERE id_interval = p_intervalid;

		SELECT COUNT (*)
        INTO v_count
        FROM t_partition part INNER JOIN t_partition_interval_map MAP
             ON part.id_partition = MAP.id_partition
           AND part.partition_name = v_partname
             INNER JOIN t_archive_partition back
             ON part.partition_name = back.partition_name
           AND back.status = 'D'
           AND tt_end = v_maxtime
           AND MAP.id_interval NOT IN (
                                    SELECT id_interval
                                      FROM t_archive
                                     WHERE status <> 'A'
                                           AND tt_end = v_maxtime)
             ;
	 END IF;	
      IF (v_count > 0)
      THEN
         BEGIN
            UPDATE t_archive_partition
               SET tt_end = dbo.subtractsecond (v_vartime)
             WHERE partition_name = v_partname
               AND tt_end = v_maxtime
               AND status = 'D';
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000025-archive operation failed-->Error in update t_archive_partition table';
               ROLLBACK;
               RETURN;
         END;

         BEGIN
            INSERT INTO t_archive_partition
                 VALUES (v_partname, 'A', v_vartime, v_maxtime);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000026-archive operation failed-->Error in insert into t_archive_partition table';
               ROLLBACK;
               RETURN;
         END;

         BEGIN
            UPDATE t_partition
               SET b_active = 'N'
             WHERE partition_name = v_partname;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '3000027-archive operation failed-->Error in update t_partition table';
               ROLLBACK;
               RETURN;
         END;
      END IF;
   END IF;

   p_result := '0-archive_trash operation successful';
   COMMIT;
END;
/
CREATE OR REPLACE PROCEDURE dearchive_account (
   p_interval              INT,
   p_accountidlist         VARCHAR2,
   p_path                  VARCHAR2,
   p_constraint            CHAR DEFAULT 'Y',
   p_result          OUT   VARCHAR2
)
AS
   v_change          VARCHAR2 (4000);
   v_c_id            NUMBER (10);
   v_count           NUMBER           := 0;
   v_sql1            VARCHAR2 (4000);
   v_sql2            VARCHAR2 (4000);
   v_tab1            VARCHAR2 (1000);
   v_tab2            VARCHAR2 (1000);
   v_var1            VARCHAR2 (100);
   v_var2            NUMBER (10);
   v_str1            VARCHAR2 (1000);
   v_str2            VARCHAR2 (2000);
   v_bucket          INT;
   v_dbname          VARCHAR2 (100);
   v_vartime         DATE             := SYSDATE;
   v_maxtime         DATE             := dbo.mtmaxdate;
   v_accountidlist   VARCHAR2 (4000)  := p_accountidlist;
   c1                sys_refcursor;
   c2                sys_refcursor;
   c3                sys_refcursor;
   v_filename        VARCHAR2 (128);
   v_i               NUMBER (10);
   v_file            VARCHAR2 (2000);
   vexists           BOOLEAN;
   vfile_length      INT;
   vblocksize        INT;
   v_table_name      VARCHAR2 (30);
   v_dir_name        VARCHAR2 (30);
   v_partition       NVARCHAR2 (2000);
   v_dummy           VARCHAR2 (1);
   v_dummy1          NUMBER (10)      := 0;
BEGIN /*         how to run this procedure DECLARE    P_INTERVALID NUMBER;   p_accountIDList varchar2(2000);   P_PATH VARCHAR2(200);   p_constraint VARCHAR2(1);   P_RESULT VARCHAR2(200);  BEGIN    P_INTERVALID := 885653507;   p_accountIDList := null;   P_PATH := 'HS_DIR';   p_constraint := 'Y';   P_RESULT := NULL;    DEARCHIVE_ACCOUNT (  P_INTERVALID,p_accountIDList, P_PATH,p_constraint, P_RESULT );   DBMS_OUTPUT.PUT_LINE(P_RESULT);   COMMIT;  END;  */     /*Checking following Business rules :      Interval should be archived      Account is in archived state      Verify the database name  */
   SELECT table_name
     INTO v_tab2
     FROM user_tables
    WHERE UPPER (table_name) = 'T_ACC_USAGE';

   IF (v_tab2 IS NULL)
   THEN
      p_result :=
               '5000001-dearchive operation failed-->check the database name';
      ROLLBACK;
      RETURN;
   END IF;

   SELECT COUNT (1)
     INTO v_count
     FROM t_archive
    WHERE id_interval = p_interval AND status = 'A' AND tt_end = v_maxtime;

   IF v_count = 0
   THEN
      p_result :=
              '5000002-dearchive operation failed-->Interval is not archived';
      ROLLBACK;
      RETURN;
   END IF; /*TO GET LIST OF ACCOUNT */

   BEGIN
      exec_ddl ('truncate table tmp_AccountBucketsTable');
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END; /* This is to populate the temp table with all the accounts that needs to be dearchived */

   IF (v_accountidlist IS NOT NULL)
   THEN
      WHILE INSTR (v_accountidlist, ',') > 0
      LOOP
         BEGIN
            INSERT INTO tmp_accountbucketstable
                        (ID
                        )
                 VALUES (SUBSTR (v_accountidlist,
                                 1,
                                 (INSTR (v_accountidlist, ',') - 1)
                                )
                        );

            v_accountidlist :=
               SUBSTR (v_accountidlist,
                       (INSTR (v_accountidlist, ',') + 1),
                       (  LENGTH (v_accountidlist)
                        - (INSTR (v_accountidlist, ','))
                       )
                      );
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '5000003-dearchive operation failed-->error in insert into tmp_AccountBucketsTable';
               ROLLBACK;
               RETURN;
         END;
      END LOOP;

      BEGIN
         INSERT INTO tmp_accountbucketstable
                     (ID
                     )
              VALUES (v_accountidlist
                     );
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000004-dearchive operation failed-->error in insert into tmp_AccountBucketsTable';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         UPDATE tmp_accountbucketstable tmp
            SET bucket =
                   (SELECT act.bucket
                      FROM t_acc_bucket_map act
                     WHERE tmp.ID = act.id_acc
                       AND act.id_usage_interval = p_interval
                       AND act.status = 'A'
                       AND act.tt_end = v_maxtime);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000005-dearchive operation failed-->error in update tmp_AccountBucketsTable';
            ROLLBACK;
            RETURN;
      END;
   ELSE
      BEGIN
         INSERT INTO tmp_accountbucketstable
                     (ID, bucket)
            SELECT id_acc, bucket
              FROM t_acc_bucket_map
             WHERE status = 'A'
               AND tt_end = v_maxtime
               AND id_acc NOT IN (
                      SELECT DISTINCT id_acc
                                 FROM t_acc_usage
                                WHERE id_usage_interval =
                                            CAST (p_interval AS VARCHAR2 (20)))
               AND id_usage_interval = CAST (p_interval AS VARCHAR2 (20));
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000006-dearchive operation failed-->error in insert into tmp_AccountBucketsTable';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   v_count := 0;

   SELECT COUNT (1)
     INTO v_count
     FROM t_acc_bucket_map
    WHERE id_usage_interval = p_interval
      AND status = 'D'
      AND tt_end = v_maxtime
      AND id_acc IN (SELECT ID
                       FROM tmp_accountbucketstable);

   IF v_count > 0
   THEN
      p_result :=
         '5000007-dearchive operation failed-->one of the account is already dearchived';
      ROLLBACK;
      RETURN;
   END IF;

   v_count := 0;

   SELECT COUNT (1)
     INTO v_count
     FROM tmp_accountbucketstable
    WHERE bucket IS NULL;

   IF v_count > 0
   THEN
      p_result :=
         '5000008-dearchive operation failed-->one of the account does not have bucket mapping...check the accountid';
      ROLLBACK;
      RETURN;
   END IF;

   OPEN c2 FOR 'select distinct bucket from tmp_AccountBucketsTable';

   LOOP
      FETCH c2
       INTO v_bucket;

      EXIT WHEN c2%NOTFOUND; /*Checking the existence of import files for each table*/
      v_filename :=
            't_acc_usage'
         || '_'
         || CAST (p_interval AS VARCHAR2)
         || '_'
         || CAST (v_bucket AS VARCHAR2)
         || '.txt'; /* v_File := p_path || '\' || v_filename; */
      UTL_FILE.fgetattr (UPPER (p_path),
                         v_filename,
                         vexists,
                         vfile_length,
                         vblocksize
                        );

      IF NOT vexists
      THEN
         p_result :=
            '5000009-dearchive operation failed-->bcp usage file does not exist';

         CLOSE c2;

         RETURN;
      END IF;

      v_count := 0;
      v_table_name := SUBSTR (v_filename, 1, INSTR (v_filename, '.') - 1);

      SELECT COUNT (*)
        INTO v_count
        FROM user_external_tables
       WHERE table_name = UPPER (v_table_name);

      IF (v_count = 0)
      THEN
         p_result :=
            '5000009a-dearchive operation failed-->bcp usage exported table does not exist, external table missing';

         CLOSE c2;

         ROLLBACK;
         RETURN;
      END IF;

      SELECT default_directory_name
        INTO v_dir_name
        FROM user_external_tables
       WHERE table_name = UPPER (v_table_name);

      IF (v_dir_name <> p_path)
      THEN
         v_sql2 :=
            'ALTER TABLE ' || v_table_name || ' DEFAULT DIRECTORY ' || p_path;
         exec_ddl (v_sql2);
      END IF;

      OPEN c1 FOR    'select distinct id_view from t_archive where id_interval = '
                  || p_interval
                  || ' and tt_end = dbo.mtmaxdate and id_view is not null';

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;
         v_filename :=
               'pv_'
            || v_var1
            || '_'
            || CAST (p_interval AS VARCHAR2)
            || '_'
            || CAST (v_bucket AS VARCHAR2)
            || '.txt'; /*select @File = p_path || '\' || v_filename*/
         UTL_FILE.fgetattr (UPPER (p_path),
                            v_filename,
                            vexists,
                            vfile_length,
                            vblocksize
                           );

         IF NOT vexists
         THEN
            p_result :=
                  '5000010-dearchive operation failed-->bcp '
               || v_filename
               || ' file does not exist';

            CLOSE c1;

            CLOSE c2;

            ROLLBACK;
            RETURN;
         END IF;

         v_count := 0;
         v_table_name := SUBSTR (v_filename, 1, INSTR (v_filename, '.') - 1);

         SELECT COUNT (*)
           INTO v_count
           FROM user_external_tables
          WHERE table_name = UPPER (v_table_name);

         IF (v_count = 0)
         THEN
            p_result :=
               '50000010a-dearchive operation failed-->bcp pv exported table does not exist, external table missing';

            CLOSE c1;

            CLOSE c2;

            ROLLBACK;
            RETURN;
         END IF;

         SELECT default_directory_name
           INTO v_dir_name
           FROM user_external_tables
          WHERE table_name = UPPER (v_table_name);

         IF (v_dir_name <> p_path)
         THEN
            v_sql2 :=
               'ALTER TABLE ' || v_table_name || ' DEFAULT DIRECTORY '
               || p_path;
            exec_ddl (v_sql2);
         END IF;
      END LOOP;

      CLOSE c1;
   END LOOP;

   CLOSE c2;

   v_count := 0;

   SELECT COUNT (id_adj_trx)
     INTO v_count
     FROM t_adjustment_transaction
    WHERE id_usage_interval = p_interval;

   IF v_count = 0
   THEN
      v_filename :=
               't_adj_trans' || '_' || CAST (p_interval AS VARCHAR2)
               || '.txt'; /*select @File = p_path || '\' || v_filename*/
      UTL_FILE.fgetattr (UPPER (p_path),
                         v_filename,
                         vexists,
                         vfile_length,
                         vblocksize
                        );

      IF NOT vexists
      THEN
         p_result :=
            '5000011-dearchive operation failed-->bcp t_adjustment_transaction file does not exist';
         ROLLBACK;
         RETURN;
      END IF;

      v_count := 0;
      v_table_name := SUBSTR (v_filename, 1, INSTR (v_filename, '.') - 1);

      SELECT COUNT (*)
        INTO v_count
        FROM user_external_tables
       WHERE table_name = UPPER (v_table_name);

      IF (v_count = 0)
      THEN
         p_result :=
            '50000011a-dearchive operation failed-->bcp t_adjustment_transaction exported table does not exist, external table missing';
         ROLLBACK;
         RETURN;
      END IF;

      SELECT default_directory_name
        INTO v_dir_name
        FROM user_external_tables
       WHERE table_name = UPPER (v_table_name);

      IF (v_dir_name <> p_path)
      THEN
         v_sql2 :=
            'ALTER TABLE ' || v_table_name || ' DEFAULT DIRECTORY ' || p_path;
         exec_ddl (v_sql2);
      END IF;

      OPEN c1 FOR
         SELECT DISTINCT adj_name
                    FROM t_archive
                   WHERE id_interval = p_interval
                     AND tt_end = v_maxtime
                     AND adj_name IS NOT NULL
                     AND status = 'A';

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;
         v_sql1 :=
               'select id_view from t_prod_view where upper(nm_table_name) = upper(replace('''
            || v_var1
            || ''',''AJ'',''PV''))';

         EXECUTE IMMEDIATE v_sql1
                      INTO v_var2;

         v_filename :=
              'aj_' || v_var2 || '_' || CAST (p_interval AS VARCHAR2)
              || '.txt'; /*select @File = p_path || '\' || v_filename*/
         UTL_FILE.fgetattr (UPPER (p_path),
                            v_filename,
                            vexists,
                            vfile_length,
                            vblocksize
                           );

         IF NOT vexists
         THEN
            p_result :=
                  '5000012-dearchive operation failed-->bcp '
               || v_filename
               || ' file does not exist';

            CLOSE c1;

            ROLLBACK;
            RETURN;
         END IF;

         v_count := 0;
         v_table_name := SUBSTR (v_filename, 1, INSTR (v_filename, '.') - 1);

         SELECT COUNT (*)
           INTO v_count
           FROM user_external_tables
          WHERE table_name = UPPER (v_table_name);

         IF (v_count = 0)
         THEN
            p_result :=
               '50000012a-dearchive operation failed-->bcp t_aj exported table does not exist, external table missing';

            CLOSE c1;

            ROLLBACK;
            RETURN;
         END IF;

         SELECT default_directory_name
           INTO v_dir_name
           FROM user_external_tables
          WHERE table_name = UPPER (v_table_name);

         IF (v_dir_name <> p_path)
         THEN
            v_sql2 :=
               'ALTER TABLE ' || v_table_name || ' DEFAULT DIRECTORY '
               || p_path;
            exec_ddl (v_sql2);
         END IF;
      END LOOP;

      CLOSE c1;
   END IF; /* Insert data into t_acc_usage */

   OPEN c2 FOR 'select distinct bucket from tmp_AccountBucketsTable';

   LOOP
      FETCH c2
       INTO v_bucket;

      EXIT WHEN c2%NOTFOUND;

      BEGIN
         EXECUTE IMMEDIATE ('delete from tmp_tmp_t_acc_usage');
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000012b--dearchive operation failed-->error in dropping tmp_tmp_t_acc_usage';
            ROLLBACK;
            RETURN;
      END; /*select * into tmp_tmp_t_acc_usage from t_acc_usage where 0=1       if (@@error <> 0)       begin           set p_result = '5000012b-dearchive operation failed-->error in creating tmp_tmp_t_acc_usage'           rollback tran           return       end*/

      BEGIN
         v_sql1 :=
               'insert into tmp_tmp_t_acc_usage select * from t_acc_usage'
            || '_'
            || CAST (p_interval AS VARCHAR2)
            || '_'
            || CAST (v_bucket AS VARCHAR2);

         EXECUTE IMMEDIATE v_sql1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000013-dearchive operation failed-->error in usage bulk insert operation';
            ROLLBACK;

            CLOSE c2;

            RETURN;
      END; /*create unique clustered index idx_tmp_t_acc_usage on #tmp_t_acc_usage(id_sess)       create index idx1_tmp_t_acc_usage on #tmp_t_acc_usage(id_acc)*/

      IF (p_constraint = 'Y')
      THEN
         v_count := 0;

         SELECT COUNT (1)
           INTO v_count
           FROM tmp_tmp_t_acc_usage
          WHERE id_pi_template NOT IN (SELECT id_template
                                         FROM t_pi_template);

         IF v_count > 0
         THEN
            p_result :=
               '5000014-dearchive operation failed-->id_pi_template key violation';
            ROLLBACK;

            CLOSE c2;

            RETURN;
         END IF;

         v_count := 0;

         SELECT COUNT (1)
           INTO v_count
           FROM tmp_tmp_t_acc_usage
          WHERE id_pi_instance NOT IN (SELECT id_pi_instance
                                         FROM t_pl_map);

         IF v_count > 0
         THEN
            p_result :=
               '5000015-dearchive operation failed-->id_pi_instance key violation';
            ROLLBACK;

            CLOSE c2;

            RETURN;
         END IF;

         v_count := 0;

         SELECT COUNT (1)
           INTO v_count
           FROM tmp_tmp_t_acc_usage
          WHERE id_view NOT IN (SELECT id_view
                                  FROM t_prod_view);

         IF v_count > 0
         THEN
            p_result :=
                 '5000016-dearchive operation failed-->id_view key violation';
            ROLLBACK;
            RETURN;
         END IF;
      END IF;

      INSERT INTO t_acc_usage
         SELECT *
           FROM tmp_tmp_t_acc_usage
          WHERE id_acc IN (SELECT ID
                             FROM tmp_accountbucketstable); /*Insert data into product view tables*/

      OPEN c1 FOR 'select distinct id_view from tmp_tmp_t_acc_usage where id_acc in
        (select id from tmp_AccountBucketsTable)';

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;

         FOR i IN (SELECT nm_table_name
                     FROM t_prod_view
                    WHERE id_view = v_var1)
         LOOP
            v_tab1 := i.nm_table_name;
         END LOOP;

         v_sql2 := 'tmp_' || v_bucket || '_' || v_var1;

         IF table_exists (v_sql2)
         THEN
            v_sql1 := 'drop table ' || v_sql2;
            exec_ddl (v_sql1);
         END IF;

         v_count := 0; /* We have to check for the schame changes since the archiving was done and then use the old schema to import the data and then apply all the schema changes that happened*/

         SELECT COUNT (1)
           INTO v_count
           FROM t_query_log pv INNER JOIN t_archive arc
                ON pv.c_id_view = arc.id_view
              AND pv.c_id_view = v_var1
              AND pv.c_timestamp > arc.tt_start
              AND arc.id_interval = p_interval
              AND arc.status = 'E'
              AND NOT EXISTS (
                     SELECT 1
                       FROM t_archive arc1
                      WHERE arc.id_interval = arc1.id_interval
                        AND arc.id_view = arc1.id_view
                        AND arc1.status = 'E'
                        AND arc1.tt_start > arc.tt_start)
                ;

         IF v_count > 0
         THEN
            FOR i IN (SELECT   c_old_schema
                          FROM t_query_log pv INNER JOIN t_archive arc
                               ON pv.c_id_view = arc.id_view
                             AND pv.c_id_view = v_var1
                             AND pv.c_timestamp > arc.tt_start
                             AND arc.id_interval = p_interval
                             AND arc.status = 'E'
                             AND pv.c_old_schema IS NOT NULL
                      ORDER BY pv.c_timestamp, c_id)
            LOOP
               v_sql1 := i.c_old_schema;
               EXIT;
            END LOOP;

            BEGIN
               v_sql1 := REPLACE (v_sql1, v_tab1, 'tmp_' || v_var1);
               exec_ddl (v_sql1);
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_result :=
                        '5000017-dearchive operation failed-->error in creating temp pv table'
                     || v_tab1;
                  ROLLBACK;
                  RETURN;
            END;

            v_sql2 :=
               'select distinct c_query,c_id from t_query_log pv inner join t_archive 
                arc on pv.c_id_view = arc.id_view 
                and pv.c_id_view = v_var1
                and pv.c_timestamp > arc.tt_start
                and arc.id_interval = p_interval
                and arc.status =''E''
                and pv.c_query is not null
                order by c_id';
         ELSE
            v_sql1 :=
                  'create table tmp_' || v_bucket || '_'
               || v_var1
               || ' as select * from '
               || v_tab1
               || ' where 0=1';
            exec_ddl (v_sql1);
         END IF;

         BEGIN
            v_sql1 :=
                  'insert into tmp_' || v_bucket || '_'
               || v_var1
               || ' select * from pv_'
               || v_var1
               || '_'
               || CAST (p_interval AS VARCHAR2)
               || '_'
               || CAST (v_bucket AS VARCHAR2);

            EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                     '5000019-dearchive operation failed-->error in bulk insert operation for table '
                  || v_tab1;
               ROLLBACK;
               RETURN;
         END;

         v_count := 0;

         SELECT COUNT (1)
           INTO v_count
           FROM t_query_log pv INNER JOIN t_archive arc
                ON pv.c_id_view = arc.id_view
              AND pv.c_id_view = v_var1
              AND pv.c_timestamp > arc.tt_start
              AND arc.id_interval = p_interval
              AND arc.status = 'E'
                ;

         IF v_count > 0
         THEN
            OPEN c3 FOR v_sql1;

            LOOP
               FETCH c3
                INTO v_change, v_c_id;

               EXIT WHEN c3%NOTFOUND;
               v_change := REPLACE (v_change, v_tab1, 'tmp_' || v_var1);
               exec_ddl (v_change);
            END LOOP;

            CLOSE c3;
         END IF;

         BEGIN
            v_sql1 :=
                  'insert into '
               || v_tab1
               || ' select * from tmp_' || v_bucket || '_'
               || v_var1
               || ' where id_sess
                        in (select id_sess from tmp_tmp_t_acc_usage where id_acc in (select id from tmp_AccountBucketsTable))';

            EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                     '5000020-dearchive operation failed-->error in insert into pv table from temp table '
                  || v_tab1;
               ROLLBACK;

               CLOSE c1;

               CLOSE c2;

               RETURN;
         END;
      END LOOP;

      CLOSE c1;
   END LOOP;

   CLOSE c2;

   v_count := 0;

   SELECT COUNT (id_adj_trx)
     INTO v_count
     FROM t_adjustment_transaction
    WHERE id_usage_interval = p_interval;

   IF v_count = 0
   THEN /*Insert data into t_adjustment_transaction */
      BEGIN
         IF table_exists ('tmp2_t_adjustment_transaction')
         THEN
             exec_ddl ('drop table tmp2_t_adjustment_transaction');
         end if;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         exec_ddl
            ('create table tmp2_t_adjustment_transaction as select * from t_adjustment_transaction where 0=1'
            );
         v_sql1 :=
               'insert into tmp2_t_adjustment_transaction select * from t_adj_trans'
            || '_'
            || CAST (p_interval AS VARCHAR2);

         EXECUTE IMMEDIATE v_sql1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000021-dearchive operation failed-->error in adjustment bulk insert operation';
            ROLLBACK;
            RETURN;
      END; /*update t_adjustment_transaction to copy data from archive_sess to id_sess if usage is already in t_acc_usage*/

      BEGIN
         v_sql1 :=
            'UPDATE tmp2_t_adjustment_transaction trans
            SET id_sess = archive_sess,
                archive_sess = NULL
          WHERE trans.id_sess IS NULL
            AND EXISTS (SELECT 1
                          FROM t_acc_usage au
                         WHERE trans.archive_sess = au.id_sess)';

         EXECUTE IMMEDIATE (v_sql1);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000022-dearchive operation failed-->error in update adjustment transaction';
            ROLLBACK;
            RETURN;
      END; /*This update is to cover the scenario if post bill adjustments are archived before usage and now dearchive before usage interval */

      BEGIN
         v_sql1 :=
               'UPDATE tmp2_t_adjustment_transaction trans
            SET archive_sess = id_sess,
                id_sess = NULL
          WHERE NOT EXISTS (SELECT 1
                              FROM t_acc_usage au
                             WHERE au.id_sess = trans.id_sess)
            AND trans.archive_sess IS NULL /* and n_adjustmenttype = 1 */
            AND id_usage_interval = '
            || p_interval;

         EXECUTE IMMEDIATE (v_sql1);
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (SQLERRM);
            p_result :=
               '5000023-dearchive operation failed-->error in update adjustment transaction';
            ROLLBACK;
            RETURN;
      END;

      v_sql1 :=
         'INSERT INTO t_adjustment_transaction
         SELECT *
           FROM tmp2_t_adjustment_transaction'; /*Insert data into t_aj tables*/

      EXECUTE IMMEDIATE (v_sql1);

      v_sql1 :=
            'select distinct adj_name from t_archive 
        where id_interval = '
         || p_interval
         || ' and tt_end = dbo.mtmaxdate and adj_name is not null and status=''A''';

      OPEN c1 FOR v_sql1;

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;
         v_sql1 :=
               'insert into '
            || v_var1
            || ' select * from aj_'
            || v_var2
            || '_'
            || CAST (p_interval AS VARCHAR2);

         BEGIN
            EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                     '5000024-dearchive operation failed-->error in bulk insert operation for table '
                  || v_var1;
               ROLLBACK;
               RETURN;
         END;
      END LOOP;

      CLOSE c1;
   END IF;

   BEGIN
        UPDATE t_acc_bucket_map act
           SET tt_end = dbo.subtractsecond (v_vartime)
         WHERE id_usage_interval = p_interval
           AND status ='A'
           AND tt_end = v_maxtime
           and exists (select 1 from tmp_AccountBucketsTable tmp where act.id_acc = tmp.id);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '5000025-dearchive operation failed-->error in update t_acc_bucket_map';
         ROLLBACK;
         RETURN;
   END;

   BEGIN
      v_sql1 :=
            'insert into t_acc_bucket_map(id_usage_interval,id_acc,bucket,status,tt_start,tt_end)
        select '
         || p_interval
         || ' ,id,bucket,''D'','''
         || v_vartime
         || ''' , '''
         || v_maxtime
         || ''' from tmp_AccountBucketsTable';

      EXECUTE IMMEDIATE (v_sql1);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '5000026-dearchive operation failed-->error in insert into t_acc_bucket_map';
         ROLLBACK;
         RETURN;
   END;

   v_count := 0;

   SELECT COUNT (1)
     INTO v_count
     FROM t_acc_bucket_map MAP LEFT OUTER JOIN t_acc_usage au
          ON MAP.id_acc = au.id_acc
        AND MAP.id_usage_interval = au.id_usage_interval
    WHERE MAP.status = 'A' AND tt_end = v_maxtime;

   IF v_count = 0
   THEN
      BEGIN /*Update t_archive table to record the fact that interval is no longer archived*/
         UPDATE t_archive
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE id_interval = p_interval AND status = 'A'
                AND tt_end = v_maxtime;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000027-dearchive operation failed-->error in update t_archive';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive
            SELECT p_interval, id_view, NULL, 'D', v_vartime, v_maxtime
              FROM t_archive
             WHERE id_interval = p_interval
               AND status = 'A'
               AND tt_end = dbo.subtractsecond (v_vartime)
               AND id_view IS NOT NULL
            UNION ALL
            SELECT p_interval, NULL, adj_name, 'D', v_vartime, v_maxtime
              FROM t_archive
             WHERE id_interval = p_interval
               AND status = 'A'
               AND tt_end = dbo.subtractsecond (v_vartime)
               AND adj_name IS NOT NULL;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000028-dearchive operation failed-->error in insert t_archive';
            ROLLBACK;
            RETURN;
      END;
   END IF; /*Following update will be required for post bill adjustments that      are already in system when current usage is dearchived*/

   BEGIN
      UPDATE t_adjustment_transaction trans
         SET id_sess = archive_sess,
             archive_sess = NULL
       WHERE trans.id_sess IS NULL
         AND EXISTS (SELECT 1
                       FROM t_acc_usage au
                      WHERE trans.archive_sess = au.id_sess);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_result :=
            '5000029-dearchive operation failed-->error in update adjustment transaction';
         ROLLBACK;
         RETURN;
   END;

   v_count := 0;

   SELECT b_partitioning_enabled
     INTO v_dummy
     FROM t_usage_server;

   IF (v_dummy = 'Y')
   THEN
       SELECT partition_name
         INTO v_partition
         FROM t_partition part INNER JOIN t_partition_interval_map MAP
              ON part.id_partition = MAP.id_partition
        WHERE MAP.id_interval = p_interval;
   end if;
   
   SELECT COUNT (1)
     INTO v_dummy1
     FROM t_partition part INNER JOIN t_partition_interval_map MAP
          ON part.id_partition = MAP.id_partition
        AND part.partition_name = v_partition
          INNER JOIN t_archive_partition back
          ON part.partition_name = back.partition_name
        AND back.status = 'A'
        AND tt_end = v_maxtime
        AND MAP.id_interval NOT IN (
                                    SELECT id_interval
                                      FROM t_archive
                                     WHERE status <> 'D'
                                           AND tt_end = v_maxtime)
          ;

   IF (v_dummy1 > 0 AND v_dummy = 'Y')
   THEN
      BEGIN
         UPDATE t_archive_partition
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE partition_name = v_partition
            AND tt_end = v_maxtime
            AND status = 'A';
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000030-archive operation failed-->Error in update t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive_partition
              VALUES (v_partition, 'D', v_vartime, v_maxtime);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000031-archive operation failed-->Error in insert into t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         UPDATE t_partition
            SET b_active = 'Y'
          WHERE partition_name = v_partition;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '5000032-archive operation failed-->Error in update t_partition table';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   p_result := '0-dearchive operation successful';
   COMMIT;
END;
/
CREATE OR REPLACE PROCEDURE archive_queue (
   p_update_stats           CHAR DEFAULT 'N',
   p_sampling_ratio         VARCHAR2 DEFAULT '30',
   p_result           OUT   VARCHAR2
)
AS
   v_sql1                    VARCHAR2 (4000);
   v_tab1                    VARCHAR2 (1000);
   v_var1                    VARCHAR2 (1000);
   v_vartime                 DATE;
   v_maxtime                 DATE;
   v_count                   NUMBER;
   c1                        sys_refcursor;
   v_nu_varstatpercentchar   int;
   v_user_name							 varchar2(30);
BEGIN 
	/* How to run this stored procedure      
	DECLARE      P_RESULT VARCHAR2(200);    
	BEGIN      P_RESULT := NULL;      
	ARCHIVE_QUEUE ( p_result => P_RESULT );    
	dbms_output.put_line(p_result);      
	COMMIT;    
	END;    
	OR      
	DECLARE      
	P_UPDATE_STATS VARCHAR2(200);      
	P_SAMPLING_RATIO VARCHAR2(200);      
	P_RESULT VARCHAR2(200);    
	BEGIN      
	P_UPDATE_STATS := 'Y';      
	P_SAMPLING_RATIO := 100;      
	P_RESULT := NULL;      
	ARCHIVE_QUEUE ( P_UPDATE_STATS, P_SAMPLING_RATIO, P_RESULT );     
	dbms_output.put_line(p_result);      
	COMMIT;    
	END;       
	*/
  v_maxtime := dbo.mtmaxdate();
  v_count := 0;

  BEGIN
  IF table_exists('tmp_t_session_state') THEN
    EXECUTE IMMEDIATE 'truncate table tmp_t_session_state';
  END IF;
  EXCEPTION
  WHEN others THEN
    p_result := '7000001--archive_queues operation failed-->error in dropping tmp_t_session_state';
    ROLLBACK;
    RETURN;
  END;

  BEGIN
    IF table_exists('tmp2_t_session_state') THEN
      EXECUTE IMMEDIATE 'truncate table tmp2_t_session_state';
    END IF;
  EXCEPTION
	  WHEN others THEN
    p_result := '7000001a--archive_queues operation failed-->error in dropping tmp2_t_session_state';
    ROLLBACK;
    RETURN;
  END;

  OPEN c1 FOR
  SELECT nm_table_name
  FROM t_service_def_log;
  LOOP
    FETCH c1
    INTO v_tab1;
    EXIT
  WHEN c1 % NOTFOUND;
  EXECUTE IMMEDIATE('lock table ' || v_tab1 || ' in exclusive mode');
	END LOOP;
	CLOSE c1;

	EXECUTE IMMEDIATE('lock table t_message in exclusive mode');
	EXECUTE IMMEDIATE('lock table t_session_set in exclusive mode');
	EXECUTE IMMEDIATE('lock table t_session in exclusive mode');
	EXECUTE IMMEDIATE('lock table t_session_state in exclusive mode');
	BEGIN
		INSERT
		INTO tmp_t_session_state
		SELECT sess.id_source_sess
		FROM t_session sess
		WHERE NOT EXISTS
			(SELECT 1
			FROM t_session_state state
			WHERE state.id_sess = sess.id_source_sess)
		UNION ALL
		SELECT id_sess
		FROM t_session_state state
		WHERE tx_state IN('F',   'R')
		AND state.dt_end = v_maxtime;
	EXCEPTION
		WHEN others THEN
		p_result := '7000002-archive_queues operation failed-->Error in populating tmp_t_session_state';
		ROLLBACK;
		RETURN;
	END;

	SELECT COUNT(*)
	INTO v_count
	FROM t_prod_view
	WHERE b_can_resubmit_from = 'N'
	AND nm_table_name NOT LIKE 't_acc_usage';

	IF(v_count > 0) THEN
  BEGIN
    INSERT
    INTO tmp_t_session_state
    SELECT state.id_sess
    FROM t_acc_usage au
    INNER JOIN t_session_state state ON au.tx_uid = state.id_sess
    INNER JOIN t_prod_view prod ON au.id_view = prod.id_view
     AND prod.b_can_resubmit_from = 'N'
    WHERE state.dt_end = v_maxtime
     AND au.id_usage_interval IN
      (SELECT DISTINCT id_usage_interval
       FROM t_acc_usage_interval
       WHERE tx_status <> 'H')
    ;
  EXCEPTION
  WHEN others THEN
    p_result := '7000003-archive_queues operation failed-->Error in populating tmp_t_session_state';
    ROLLBACK;
    RETURN;
  END;
	END IF;

	v_count := 0;
/*Delete from t_svc tables*/

	OPEN c1 FOR
	SELECT nm_table_name
	FROM t_service_def_log;
	LOOP
		FETCH c1
		INTO v_tab1;
		EXIT
	WHEN c1 % NOTFOUND;
	BEGIN
		IF table_exists('tmp_svc') THEN
			EXECUTE IMMEDIATE 'drop table tmp_svc';
		END IF;
	EXCEPTION
	WHEN others THEN
		p_result := '7000005--archive_queues operation failed-->error in dropping tmp_svc table';
		ROLLBACK;
		CLOSE c1;
		RETURN;
	END;
	
	BEGIN
		v_sql1 := 'create table tmp_svc as select svc.* from ' || v_tab1 || ' svc inner join tmp_t_session_state au
									on svc.id_source_sess = au.id_sess';
		EXECUTE IMMEDIATE v_sql1;
	EXCEPTION
	WHEN others THEN
		p_result := '7000006-archive_queues operation failed-->Error in t_svc Delete operation';
		ROLLBACK;
		CLOSE c1;
		RETURN;
	END;

	BEGIN
		EXECUTE IMMEDIATE 'truncate table ' || v_tab1;
	EXCEPTION
	WHEN others THEN
		p_result := '7000007-archive_queues operation failed-->Error in t_svc Delete operation';
		ROLLBACK;
		CLOSE c1;
		RETURN;
	END;

	v_sql1 := 'insert into ' || v_tab1 || ' select * from tmp_svc';
	BEGIN
		EXECUTE IMMEDIATE v_sql1;
	EXCEPTION
	WHEN others THEN
		p_result := '7000008-archive_queues operation failed-->Error in t_svc Delete operation';
		ROLLBACK;
		CLOSE c1;
		RETURN;
	END;

	BEGIN
		INSERT
		INTO t_archive_queue(id_svc,   status,   tt_start,   tt_end)
		VALUES(v_tab1,   'A',   v_vartime,   v_maxtime);
	EXCEPTION
	WHEN others THEN
		p_result := '7000009-archive_queues operation failed-->Error in insert t_archive table';
		ROLLBACK;
		CLOSE c1;
		RETURN;
	END;
	END LOOP;
	CLOSE c1;

/*Delete from t_session, t_session_state, t_session_set and t_message tables table*/

	BEGIN
	IF table_exists('tmp_t_session') THEN
		EXECUTE IMMEDIATE 'truncate table tmp_t_session';
	END IF;
	EXCEPTION
	WHEN others THEN
		p_result := '7000010A--archive_queues operation failed-->error in dropping tmp_t_session';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	EXECUTE IMMEDIATE 'insert into tmp_t_session
					select * from t_session where id_source_sess
					in (select id_sess from tmp_t_session_state)';
	EXCEPTION
	WHEN others THEN
		p_result := '7000010-archive_queues operation failed-->Error in insert into tmp_t_session';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	EXECUTE IMMEDIATE 'truncate table t_session';
	EXCEPTION
	WHEN others THEN
		p_result := '7000011-archive_queues operation failed-->Error in Delete from t_session';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	INSERT
	INTO t_session
	SELECT *
	FROM tmp_t_session;
	EXCEPTION
	WHEN others THEN
		p_result := '7000012-archive_queues operation failed-->Error in insert into t_session';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	IF table_exists('tmp_t_session_set') THEN
		EXECUTE IMMEDIATE 'truncate table tmp_t_session_set';
	END IF;
	EXCEPTION
	WHEN others THEN
		p_result := '7000013A--archive_queues operation failed-->error in dropping tmp_t_session_set';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	EXECUTE IMMEDIATE 'Insert into tmp_t_session_set select * from t_session_set where id_ss in
					(select id_ss from t_session)';
	EXCEPTION
	WHEN others THEN
		p_result := '7000013-archive_queues operation failed-->Error in insert into tmp_t_session_set';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	EXECUTE IMMEDIATE 'truncate table t_session_set';
	EXCEPTION
	WHEN others THEN
		p_result := '7000014-archive_queues operation failed-->Error in Delete from t_session_set';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	INSERT
	INTO t_session_set
	SELECT *
	FROM tmp_t_session_set;
	EXCEPTION
	WHEN others THEN
		p_result := '7000015-archive_queues operation failed-->Error in insert into t_session_set';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	IF table_exists('tmp_t_message') THEN
		EXECUTE IMMEDIATE 'truncate table tmp_t_message';
	END IF;
	EXCEPTION
	WHEN others THEN
		p_result := '7000016a--archive_queues operation failed-->error in dropping tmp_t_message';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	EXECUTE IMMEDIATE 'Insert into tmp_t_message select * from t_message where id_message in
					(select id_message from t_session_set)';
	EXCEPTION
	WHEN others THEN
		p_result := '7000016-archive_queues operation failed-->Error in insert into tmp_t_message';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	EXECUTE IMMEDIATE 'truncate table t_message';
	EXCEPTION
	WHEN others THEN
		p_result := '7000017-archive_queues operation failed-->Error in Delete from t_message';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	INSERT
	INTO t_message
	SELECT *
	FROM tmp_t_message;
	EXCEPTION
	WHEN others THEN
		p_result := '7000018-archive_queues operation failed-->Error in insert into t_message';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	IF table_exists('tmp2_t_session_state') THEN
		EXECUTE IMMEDIATE 'truncate table tmp2_t_session_state';
	END IF;
	EXCEPTION
	WHEN others THEN
		p_result := '7000019a--archive_queues operation failed-->error in dropping tmp2_t_session_state';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	EXECUTE IMMEDIATE 'Insert into tmp2_t_session_state 
  			select state.* from t_session_state state  
  			where state.id_sess in  
  			(select id_sess from tmp_t_session_state)';
	EXCEPTION
	WHEN others THEN
		p_result := '7000019-archive_queues operation failed-->Error in insert into tmp2_t_session_state';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	EXECUTE IMMEDIATE 'truncate table t_session_state';
	EXCEPTION
	WHEN others THEN
		p_result := '7000020-archive_queues operation failed-->Error in Delete from t_session_state table';
		ROLLBACK;
		RETURN;
	END;

	BEGIN
	INSERT
	INTO t_session_state
	SELECT *
	FROM tmp2_t_session_state;
	EXCEPTION
	WHEN others THEN
		p_result := '7000021-archive_queues operation failed-->Error in insert into t_session_state table';
		ROLLBACK;
		RETURN;
	END;

	IF table_exists('tmp_t_session_state') THEN
	EXECUTE IMMEDIATE 'truncate table tmp_t_session_state';
	END IF;

	IF table_exists('tmp2_t_session_state') THEN
	EXECUTE IMMEDIATE 'truncate table tmp2_t_session_state';
	END IF;

	IF table_exists('tmp_t_session') THEN
	EXECUTE IMMEDIATE 'truncate table tmp_t_session';
	END IF;

	IF table_exists('tmp_t_session_set') THEN
	EXECUTE IMMEDIATE 'truncate table tmp_t_session_set';
	END IF;

	IF table_exists('tmp_t_message') THEN
	EXECUTE IMMEDIATE 'truncate table tmp_t_message';
	END IF;

	IF table_exists('tmp_svc') THEN
	EXECUTE IMMEDIATE 'drop table tmp_svc';
	END IF;

  IF(p_update_stats = 'Y') THEN
		SELECT sys_context('USERENV', 'SESSION_USER') into v_user_name FROM dual;
		OPEN c1 FOR
			SELECT nm_table_name
			FROM t_service_def_log;
			LOOP
			FETCH c1 INTO v_tab1;
			EXIT WHEN c1 % NOTFOUND;
      IF(p_sampling_ratio < 5) 
				THEN v_nu_varstatpercentchar := 5;
				ELSIF(p_sampling_ratio >= 100) THEN v_nu_varstatpercentchar := 100;
				ELSE v_nu_varstatpercentchar := p_sampling_ratio;
      END IF;
			v_sql1 := 'begin dbms_stats.gather_table_stats(ownname=> ''' || v_user_name || ''',
                 tabname=> ''' || v_tab1 || ''', estimate_percent=> ' || v_nu_varstatpercentchar || ',
                 cascade=> TRUE); end;';
      BEGIN
	      EXECUTE IMMEDIATE v_sql1;
        EXCEPTION
        WHEN others THEN
					p_result := '7000022-archive_queues operation failed-->Error in update stats';
					ROLLBACK;
					RETURN;
       END;
       END LOOP;
       CLOSE c1;
       
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_SESSION'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000023-archive_queues operation failed-->Error in t_session update stats';
             ROLLBACK;
             RETURN;
       END;
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_SESSION_SET'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000024-archive_queues operation failed-->Error in t_session_set update stats';
             ROLLBACK;
             RETURN;
       END;
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_SESSION_STATE'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000025-archive_queues operation failed-->Error in t_session_state update stats';
             ROLLBACK;
             RETURN;
       END;
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_MESSAGE'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000026-archive_queues operation failed-->Error in t_message update stats';
             ROLLBACK;
             RETURN;
       END;
    END IF;

p_result := '0-archive_queue operation successful';
COMMIT;
END;
/
CREATE OR REPLACE PROCEDURE CREATEADJUSTMENTTABLE(
  p_id_pi_type         integer,
  p_status       out   integer,
  p_err_msg      out   varchar2,
  p_replace            boolean := false   /* drop and create flag */
)
as
  
  /* var decls */
  ntabs    int;
  ncols    int;
  ddl      varchar2(4000);
  colsep   varchar2(5)    := ',' || chr(10) || '   ';
begin
  p_status := 0;

  for x in (select pi1.nm_productview as pv, bp.nm_name as piname,
                   bpnew.nm_name as newpiname
              from t_pi pi1 inner join t_pi pi2 on pi1.nm_productview =
                                                           pi2.nm_productview
                   inner join t_base_props bp on bp.id_prop = pi2.id_pi
                   inner join t_base_props bpnew on bpnew.id_prop = pi1.id_pi
             where pi1.id_pi = p_id_pi_type and pi2.id_pi <> pi1.id_pi) loop
    p_status := 1;
    p_err_msg :=
      'Product View [' || x.pv || '] is shared between [' || x.newpiname
      || '] and [' || x.piname || ']' || '. If [' || x.newpiname
      || '] is adjustable, make sure that charges in these priceable'
      || ' item types are the same.';
  end loop;

  /* all of the product views referenced by priceable items */
  /* BP changed next join on t_charge to 'left outer' from 'inner'
     in order to support Amount adjustments for PIs that don't
     have any charges */
  ntabs := 0;

  for tab in (select distinct pv.nm_table_name as pvname,
                              't_aj_'
                              || substr(pv.nm_table_name, 6) as adjname,
                              t_pi.id_pi as idpi
                         from t_pi inner join t_prod_view pv on upper(pv.nm_name) =
                                                                 upper(t_pi.nm_productview)
                              left outer join t_charge on t_charge.id_pi =
                                                                    t_pi.id_pi
                        where t_pi.id_pi = p_id_pi_type) loop
    ntabs := ntabs + 1;
    /* start create stable dll stmt */
    ddl := 'create table ' || tab.adjname || '(' || chr(10)
           || '   id_adjustment number(10)';
    /* get columns for table */
    ncols := 0;

    for col in (select prop.nm_column_name as colname,
                       prop.nm_data_type as coltype
                  from t_charge join t_prod_view_prop prop on prop.id_prod_view_prop =
                                                               t_charge.id_amt_prop
                 where id_pi = tab.idpi) loop
      ncols := ncols + 1;

      /* all columns are expected to have type numeric(18,6). all
      other type are disallowed */
      if replace(col.coltype, ' ') <> 'numeric(18,6)' then
        p_status := 1;
        p_err_msg := 'Column type of ' || tab.pvname || '.' || col.colname
                     || ' must be numeric(18,6)' || ', not ' || col.coltype;
        return;
      end if;

      /* add column to ddl statement; transform c_ prefix to c_aj_ */
      ddl := ddl || colsep || 'c_aj_' || substr(col.colname, 3)
             || ' number(18,6)';
    end loop;   /* over columns */

    /* close ddl stmt and create this table */
    ddl := ddl || ')';

    if p_replace and table_exists(tab.adjname) then
      exec_ddl2('drop table ' || tab.adjname, p_status, p_err_msg);

      dbms_output.put_line('dropping: ' || tab.adjname);
    end if;

    if not table_exists(tab.adjname) then
      exec_ddl2(ddl, p_status, p_err_msg);

      dbms_output.put_line('creating: ' || tab.adjname);
    end if;
  end loop;   /* over tables */
end createadjustmenttable;
/
CREATE OR REPLACE
procedure updatedataforstringtoenum(
  p_table varchar2,   
			p_column varchar2,
			p_enum_string varchar2)
			AS
  inclusion varchar2(4000);
  upd varchar2(4000);
  fqenumval varchar2(4000);
  cnt int;
  
			begin

  fqenumval := ''''||p_enum_string||'/'' || ' || p_column;

  /* all values in the string column must be found in the t_enum_data */
    inclusion := '
        select sum(case when mydata is null then 0 else 1 end)  
        from (
          select distinct ' || fqenumval || ' as mydata
          from '|| p_table ||'
          ) data
        where not exists  (
          select 1
          from t_enum_data 
          where nm_enum_data = data.mydata
          )';
          
    execute immediate inclusion into cnt;
          
    if cnt > 0 then 
      raise_application_error(-20000, 
        'Invalid enum values in table ' || p_table || ', column ' || p_column);
				end if;
  
  upd := '
      update '|| p_table || ' set 
        '|| p_column || ' = (select id_enum_data 
                from t_enum_data 
                where nm_enum_data = '||fqenumval||')
      where exists (
                select 1 
                from t_enum_data 
                where nm_enum_data = '||fqenumval||')';

  execute immediate upd;

			end;
/
