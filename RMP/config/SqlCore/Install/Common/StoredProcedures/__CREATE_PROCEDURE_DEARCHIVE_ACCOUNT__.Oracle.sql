
CREATE OR REPLACE PROCEDURE dearchive_account (
   p_interval_id              INT,
   p_account_id_list         VARCHAR2,
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
   v_accountidlist   VARCHAR2 (4000)  := p_account_id_list;
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
BEGIN /*         how to run this procedure DECLARE    p_interval_idID NUMBER;   p_account_id_list varchar2(2000);   p_path VARCHAR2(200);   p_constraint VARCHAR2(1);   p_result VARCHAR2(200);  BEGIN    p_interval_idID := 885653507;   p_account_id_list := null;   p_path := 'HS_DIR';   p_constraint := 'Y';   p_result := NULL;    DEARCHIVE_ACCOUNT (  p_interval_idID,p_account_id_list, p_path,p_constraint, p_result );   DBMS_OUTPUT.PUT_LINE(p_result);   COMMIT;  END;  */     /*Checking following Business rules :      Interval should be archived      Account is in archived state      Verify the database name  */
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
    WHERE id_interval = p_interval_id AND status = 'A' AND tt_end = v_maxtime;

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
                       AND act.id_usage_interval = p_interval_id
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
                                            CAST (p_interval_id AS VARCHAR2 (20)))
               AND id_usage_interval = CAST (p_interval_id AS VARCHAR2 (20));
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
    WHERE id_usage_interval = p_interval_id
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
         || CAST (p_interval_id AS VARCHAR2)
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
                  || p_interval_id
                  || ' and tt_end = dbo.mtmaxdate and id_view is not null';

      LOOP
         FETCH c1
          INTO v_var1;

         EXIT WHEN c1%NOTFOUND;
         v_filename :=
               'pv_'
            || v_var1
            || '_'
            || CAST (p_interval_id AS VARCHAR2)
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
    WHERE id_usage_interval = p_interval_id;

   IF v_count = 0
   THEN
      v_filename :=
               't_adj_trans' || '_' || CAST (p_interval_id AS VARCHAR2)
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
                   WHERE id_interval = p_interval_id
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
              'aj_' || v_var2 || '_' || CAST (p_interval_id AS VARCHAR2)
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
            || CAST (p_interval_id AS VARCHAR2)
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
              AND arc.id_interval = p_interval_id
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
                             AND arc.id_interval = p_interval_id
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
                and arc.id_interval = p_interval_id
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
               || CAST (p_interval_id AS VARCHAR2)
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
              AND arc.id_interval = p_interval_id
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
    WHERE id_usage_interval = p_interval_id;

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
            || CAST (p_interval_id AS VARCHAR2);

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
            || p_interval_id;

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
         || p_interval_id
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
            || CAST (p_interval_id AS VARCHAR2);

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
         WHERE id_usage_interval = p_interval_id
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
         || p_interval_id
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
          WHERE id_interval = p_interval_id AND status = 'A'
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
            SELECT p_interval_id, id_view, NULL, 'D', v_vartime, v_maxtime
              FROM t_archive
             WHERE id_interval = p_interval_id
               AND status = 'A'
               AND tt_end = dbo.subtractsecond (v_vartime)
               AND id_view IS NOT NULL
            UNION ALL
            SELECT p_interval_id, NULL, adj_name, 'D', v_vartime, v_maxtime
              FROM t_archive
             WHERE id_interval = p_interval_id
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
        WHERE MAP.id_interval = p_interval_id;
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
    