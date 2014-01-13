
CREATE OR REPLACE PROCEDURE ARCHIVE_EXPORT (
   p_partition_name      NVARCHAR2 DEFAULT NULL,
   p_interval_id         INT DEFAULT NULL,
   p_path                VARCHAR2,
   p_avoid_rerun         VARCHAR2 DEFAULT 'N',
   p_result        OUT   VARCHAR2
)
AS
/* How to run this stored procedure DECLARE    p_partition_name NVARCHAR2(200);   p_interval_id NUMBER;   P_PATH VARCHAR2(200);   P_AVOID_RERUN VARCHAR2(200);   P_RESULT VARCHAR2(200);  BEGIN    p_partition_name := 'HS_20070131';   p_interval_id := NULL;   P_PATH := 'HS_DIR;   P_AVOID_RERUN := 'N';   P_RESULT := NULL;    ARCHIVE_EXPORT ( p_partition_name, p_interval_id, P_PATH, P_AVOID_RERUN, P_RESULT );   DBMS_OUTPUT.PUT_LINE(P_RESULT);   COMMIT;  END; or DECLARE    p_partition_name NVARCHAR2(200);   p_interval_id NUMBER;   P_PATH VARCHAR2(200);   P_AVOID_RERUN VARCHAR2(200);   P_RESULT VARCHAR2(200);  BEGIN    p_partition_name := null;   p_interval_id := 885653507;   P_PATH := HS_DIR;   P_AVOID_RERUN := 'N';   P_RESULT := NULL;    ARCHIVE_EXPORT ( p_partition_name, p_interval_id, P_PATH, P_AVOID_RERUN, P_RESULT );   DBMS_OUTPUT.PUT_LINE(P_RESULT);   COMMIT;  END; */
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
   IF (   (p_partition_name IS NOT NULL AND p_interval_id IS NOT NULL)
       OR (p_partition_name IS NULL AND p_interval_id IS NULL)
      )
   THEN
      p_result :=
         '1000001-archive_export operation failed-->Either Partition or Interval should be specified';
      ROLLBACK;
      RETURN;
   END IF;            /* Get the list of Intervals that need to be archived */

   IF (p_partition_name IS NOT NULL)
   THEN
      v_sql1 :=
            'select id_interval from t_partition_interval_map map where id_partition          = (select id_partition  from t_partition where partition_name = '''
         || p_partition_name
         || ''')';

      OPEN interval_id FOR v_sql1;
   ELSE
      v_sql1 := 'select ' || p_interval_id || ' from dual';

      FOR x IN (SELECT partition_name
                  FROM t_partition part INNER JOIN t_partition_interval_map MAP
                       ON part.id_partition = MAP.id_partition
                     AND MAP.id_interval = p_interval_id
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
   IF (p_partition_name IS NOT NULL)
   THEN
      v_sql1 :=
            'select id_interval from t_partition_interval_map map where id_partition          = (select id_partition  from t_partition where partition_name = '''
         || p_partition_name
         || ''')';

      OPEN interval_id FOR v_sql1;
   ELSE
      v_sql1 := 'select ' || p_interval_id || ' from dual';

      FOR x IN (SELECT partition_name
                  FROM t_partition part INNER JOIN t_partition_interval_map MAP
                       ON part.id_partition = MAP.id_partition
                     AND MAP.id_interval = p_interval_id
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
                           WHERE id_interval = p_interval_id)
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
                           WHERE id_interval = p_interval_id);

   IF ((p_partition_name IS NOT NULL OR v_dummy1 = v_count) AND v_dummy = 'Y')
   THEN
      BEGIN
         UPDATE t_archive_partition
            SET tt_end = dbo.subtractsecond (v_vartime)
          WHERE partition_name = NVL (p_partition_name, v_partition1)
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
              VALUES (NVL (p_partition_name, v_partition1), 'E', v_vartime,
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
    