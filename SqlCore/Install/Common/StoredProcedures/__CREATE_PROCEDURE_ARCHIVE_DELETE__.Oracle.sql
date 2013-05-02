
CREATE OR REPLACE PROCEDURE archive_delete (
   p_partition_name          NVARCHAR2 DEFAULT NULL,
   p_interval_id         INT DEFAULT NULL,
   p_result       OUT   NVARCHAR2
)
AS
      /*How to run this stored procedure
   DECLARE
     p_partition_name NVARCHAR2(200);
     p_interval_id NUMBER;
     p_result VARCHAR2(200);
   BEGIN
     p_partition_name := 'HS_20070131';
     p_interval_id := null;
     p_result := NULL;

     ARCHIVE_DELETE ( p_partition_name, p_interval_id, p_result );
     DBMS_OUTPUT.PUT_LINE(p_result);
     COMMIT;
   END;
   OR
   DECLARE
     p_partition_name NVARCHAR2(200);
     p_interval_id NUMBER;
     p_result VARCHAR2(200);
   BEGIN
     p_partition_name := null;
     p_interval_id := 885653507;
     p_result := NULL;

     ARCHIVE_DELETE ( p_partition_name, p_interval_id, p_result );
     DBMS_OUTPUT.PUT_LINE(p_result);
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

   IF (   (p_partition_name IS NOT NULL AND p_interval_id IS NOT NULL)
       OR (p_partition_name IS NULL AND p_interval_id IS NULL)
      )
   THEN
      p_result :=
         '2000001-archive_delete operation failed-->Either Partition or Interval should be specified';
      ROLLBACK;
      RETURN;
   END IF;

   IF (p_partition_name IS NOT NULL)
   THEN
      SELECT COUNT (id_interval)
        INTO v_count
        FROM t_partition_interval_map MAP
       WHERE id_partition IN (SELECT id_partition
                                FROM t_partition
                               WHERE partition_name = p_partition_name);

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
       WHERE partition_name = p_partition_name
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
         || p_partition_name
         || ''')';

      OPEN interval_id FOR v_sql1;
   ELSE
      v_sql1 := 'select ' || p_interval_id || ' from dual';

      SELECT b_partitioning_enabled
        INTO v_dummy
        FROM t_usage_server;

      IF (v_dummy = 'Y')
      THEN
         SELECT partition_name
           INTO v_partition1
           FROM t_partition part INNER JOIN t_partition_interval_map MAP
                ON part.id_partition = MAP.id_partition
              AND MAP.id_interval = p_interval_id
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

   IF (p_partition_name IS NOT NULL)
   THEN
      v_sql1 :=
            'select id_interval from t_partition_interval_map map where id_partition
        = (select id_partition  from t_partition where partition_name = '''
         || p_partition_name
         || ''')';

      OPEN interval_id FOR v_sql1;
   ELSE
      v_sql1 := 'select ' || p_interval_id || ' from dual';

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

   IF (p_partition_name IS NULL)
   THEN
      v_dummy1 := 0;

      SELECT COUNT (*)
        INTO v_dummy1
        FROM t_partition_interval_map MAP
       WHERE id_partition = (SELECT id_partition
                               FROM t_partition_interval_map
                              WHERE id_interval = p_interval_id);

      SELECT b_partitioning_enabled
        INTO v_dummy2
        FROM t_usage_server;

      IF (v_dummy1 <= 1 AND v_dummy2 = 'Y')
      THEN
         v_partition2 := v_partition1;
      END IF;
   END IF;

   IF (NVL (p_partition_name, v_partition2) IS NOT NULL)
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
               || NVL (p_partition_name, v_partition2)
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
            || NVL (p_partition_name, v_partition2)
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

   IF ((NVL (p_partition_name, v_partition2) IS NULL) AND p_interval_id IS NOT NULL
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
            || p_interval_id;

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
                               WHERE id_interval = p_interval_id);

   SELECT COUNT (*)
     INTO v_count
     FROM t_partition_interval_map MAP
    WHERE id_partition = (SELECT id_partition
                            FROM t_partition_interval_map
                           WHERE id_interval = p_interval_id); /* if all the intervals are archived, modify the status in t_archive_partition table */

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
               '2000021-archive operation failed-->Error in update t_archive_partition table';
            ROLLBACK;
            RETURN;
      END;

      BEGIN
         INSERT INTO t_archive_partition
              VALUES (NVL (p_partition_name, v_partition1), 'A', v_vartime,
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
          WHERE partition_name = NVL (p_partition_name, v_partition1);
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
    