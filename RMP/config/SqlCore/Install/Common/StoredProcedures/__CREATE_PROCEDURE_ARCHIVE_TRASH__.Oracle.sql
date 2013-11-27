
CREATE OR REPLACE PROCEDURE archive_trash (
   p_partition_name             NVARCHAR2 DEFAULT NULL,
   p_interval_id            INT,
   p_account_id_list         VARCHAR2,
   p_result          OUT   VARCHAR2
)
AS
       /*        How to run this stored procedure
   DECLARE
     p_partition_name NVARCHAR2(200);
     p_interval_id NUMBER;
     p_account_id_list varchar2(2000);
     P_RESULT VARCHAR2(200);
   BEGIN
     p_account_id_list := null;
     p_partition_name := 'HS_20070131';
     p_interval_id := null;
     P_RESULT := NULL;

     ARCHIVE_trash ( p_partition_name, p_interval_id,p_account_id_list, P_RESULT );
     DBMS_OUTPUT.PUT_LINE(P_RESULT);
     COMMIT;
   END;
   or
   DECLARE
     p_partition_name NVARCHAR2(200);
     p_interval_id NUMBER;
     p_account_id_list varchar2(2000);
     P_RESULT VARCHAR2(200);
   BEGIN
     p_account_id_list := null;
     p_partition_name := null;
     p_interval_id := 885653507;
     P_RESULT := NULL;

     ARCHIVE_trash ( p_partition_name, p_interval_id,p_account_id_list, P_RESULT );
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
   v_accountidlist   VARCHAR2 (4000)  := p_account_id_list;
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
   IF (   (p_partition_name IS NOT NULL AND p_interval_id IS NOT NULL)
       OR (p_partition_name IS NULL AND p_interval_id IS NULL)
       OR (p_partition_name IS not NULL AND p_account_id_list IS NOT NULL)
      )
   THEN
      p_result :=
         '3000001-archive_trash operation failed-->Either Partition or Interval/AccountId should be specified';
      ROLLBACK;
      RETURN;
   END IF;

   IF (p_partition_name IS NOT NULL)
   THEN
      /*partition should be already archived or Dearchived */
      SELECT COUNT (1)
        INTO v_count
        FROM t_archive_partition
       WHERE partition_name = p_partition_name
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
                              WHERE part.partition_name = p_partition_name);

      IF (v_count = 0)
      THEN
         p_result :=
            '3000002a-trash operation failed-->none of the intervals of partition is dearchived';
         ROLLBACK;
         RETURN;
      END IF;
   END IF;

   IF (p_partition_name IS NOT NULL)
   THEN
      v_count := 0;
      v_sql1 :=
            'select id_interval from t_partition_interval_map map where id_partition
				in (select id_partition  from t_partition where partition_name = '''
         || p_partition_name
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
                  || p_partition_name
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
               || p_partition_name
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
          WHERE partition_name = p_partition_name
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
              VALUES (p_partition_name, 'A', v_vartime, v_maxtime);
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
          WHERE partition_name = p_partition_name;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '3000012c-archive operation failed-->Error in update t_partition table';
            ROLLBACK;
            RETURN;
      END;
   END IF;

   IF (p_interval_id IS NOT NULL)
   THEN
      v_count := 0;

/*      Interval should be already archived*/
      SELECT COUNT (1)
        INTO v_count
        FROM t_archive
       WHERE id_interval = p_interval_id
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
            || CAST (p_interval_id AS VARCHAR2);

         EXECUTE IMMEDIATE v_sql1;
      END IF;

   v_count := 0;

      SELECT COUNT (1)
        INTO v_count
        FROM t_acc_bucket_map
       WHERE id_usage_interval = p_interval_id
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
                        || CAST (p_interval_id AS VARCHAR2)
                        || ' and id_acc in (select id from tmp_AccountIDsTable)';

      OPEN c1 FOR    'select distinct id_view from t_acc_usage
        where id_usage_interval = '
                  || p_interval_id;

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
       WHERE id_usage_interval = p_interval_id
         AND id_acc NOT IN (SELECT ID
                              FROM tmp_accountidstable);

      IF (v_count = 0)
      THEN
         EXECUTE IMMEDIATE 'delete from tmp_id_view';

         INSERT INTO tmp_id_view
            SELECT DISTINCT id_view
                       FROM t_acc_usage
                      WHERE id_usage_interval = p_interval_id;

         EXECUTE IMMEDIATE    'insert into tmp_t_adjustment_transaction SELECT id_adj_trx FROM
            t_adjustment_transaction where id_usage_interval='
                           || CAST (p_interval_id AS VARCHAR2);

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
               || CAST (p_interval_id AS VARCHAR2)
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
                  WHERE id_usage_interval = p_interval_id;
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
                                   WHERE id_usage_interval = p_interval_id);
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
             WHERE id_interval = p_interval_id
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
               SELECT p_interval_id, id_view, NULL, 'A', v_vartime, v_maxtime
                 FROM tmp_id_view
               UNION ALL
               SELECT DISTINCT p_interval_id, NULL, NAME, 'A', v_vartime,
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
          WHERE id_usage_interval = p_interval_id
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
            select p_interval_id,id,bucket,'A',v_vartime,v_maxtime
            from tmp_AccountIDsTable tmp
            inner join t_acc_bucket_map act on tmp.id = act.id_acc
            and act.id_usage_interval = p_interval_id
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
		WHERE id_interval = p_interval_id;

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
    