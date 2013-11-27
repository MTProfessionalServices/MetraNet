
CREATE OR REPLACE PROCEDURE dearchive_files (
   p_interval_id              NUMBER,
   p_account_id_list         VARCHAR2,
   p_result          OUT   VARCHAR2,
   p_cur             OUT   sys_refcursor
)
AS
   v_accountidlist   VARCHAR2 (4000) := p_account_id_list;
   v_sql1            VARCHAR2 (4000);
   v_tab1            VARCHAR2 (1000);
   v_tab2            VARCHAR2 (1000);
   v_var1            VARCHAR2 (100);
   v_var2            number(10);
   v_str1            VARCHAR2 (1000);
   v_str2            VARCHAR2 (2000);
   v_vartime         DATE;
   v_maxtime         DATE;
   v_bucket          INT;
   v_dbname          VARCHAR2 (100);
   v_filename        VARCHAR2 (128);
   v_count           NUMBER          := 0;
   c1                sys_refcursor;
   c2                sys_refcursor;
BEGIN
   v_vartime := SYSDATE;
   v_maxtime := dbo.mtmaxdate ();

   /*how to run this procedure
in sqlplus issue the following commands:
sql> set autoprint on
sql> var p_cursor refcursor;
then run the following code:
DECLARE
  p_interval_id NUMBER;
  p_account_id_list VARCHAR2(200);
  p_result VARCHAR2(200);
BEGIN
  p_interval_id := 885653507;
  p_account_id_list := NULL;
  p_result := NULL;
  DEARCHIVE_FILES ( p_interval_id, p_account_id_list, p_result, :p_cursor );
    DBMS_OUTPUT.PUT_LINE(p_result);
    COMMIT;
END;
*/

/*
   Checking following Business rules :
   Interval should be archived
   Account is in archived state
   Verify the database name */

   SELECT table_name
     INTO v_tab2
     FROM user_tables
    WHERE UPPER (table_name) = 'T_ACC_USAGE';

   IF (v_tab2 IS NULL)
   THEN
      p_result :=
           '6000001-dearchive_files operation failed-->check the schema name';
      RETURN;
   END IF;

   v_count := 0;

   SELECT COUNT (1)
     INTO v_count
     FROM t_archive
    WHERE id_interval = p_interval_id AND status = 'A' AND tt_end = v_maxtime;

   IF v_count = 0
   THEN
      p_result :=
         '6000002-dearchive_files operation failed-->Interval is not archived';
      RETURN;
   END IF;

   /*TO GET LIST OF ACCOUNT*/
   BEGIN
      EXECUTE IMMEDIATE 'truncate TABLE tmp_file';
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'truncate TABLE tmp_AccountBucketsTable';
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END;

   IF (p_account_id_list IS NOT NULL)
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
                  '6000003-dearchive_files operation failed-->error in insert into tmp_AccountBucketsTable';
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
               '6000004-dearchive_files operation failed-->error in insert into tmp_AccountBucketsTable';
            RETURN;
      END;

      BEGIN
         UPDATE tmp_accountbucketstable tmp
            SET bucket =
                   (SELECT act.bucket
                      FROM t_acc_bucket_map act
                     WHERE tmp.ID = act.id_acc
                       AND act.id_usage_interval = p_interval_id);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '6000005-dearchive_files operation failed-->error in update tmp_AccountBucketsTable';
            RETURN;
      END;
   ELSE
      v_sql1 :=
            'insert into tmp_AccountBucketsTable(id,bucket) select id_acc,bucket from
        t_acc_bucket_map where id_acc not in (select distinct id_acc from t_acc_usage where id_usage_interval = '
         || CAST (p_interval_id AS VARCHAR2)
         || ')
         and status = ''A'' and tt_end = dbo.mtmaxdate';

      BEGIN
         EXECUTE IMMEDIATE v_sql1;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '6000006-dearchive_files operation failed-->error in insert into tmp_AccountBucketsTable';
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
         '6000007-dearchive_files operation failed-->one of the account is already dearchived';
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
         '6000008-dearchive_files operation failed-->one of the account does not have bucket mapping...check the accountid';
      RETURN;
   END IF;

   v_sql1 := 'select distinct bucket from tmp_AccountBucketsTable';

   OPEN c2 FOR v_sql1;

   LOOP
      FETCH c2
       INTO v_bucket;

      EXIT WHEN c2%NOTFOUND;
      /*Checking the existence of import files for each table*/
      v_filename :=
            't_acc_usage'
         || '_'
         || CAST (p_interval_id AS VARCHAR2)
         || '_'
         || CAST (v_bucket AS VARCHAR2)
         || '.txt';

      BEGIN
         INSERT INTO tmp_file
            SELECT v_filename, ID
              FROM tmp_accountbucketstable
             WHERE bucket = v_bucket;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '6000009-dearchive_files operation failed-->insert into file table for t_acc_usage';

            CLOSE c2;

            RETURN;
      END;

      v_sql1 :=
            'select distinct id_view from t_archive where id_interval = '
         || p_interval_id
         || ' and tt_end = dbo.mtmaxdate and id_view is not null';

      OPEN c1 FOR v_sql1;

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
            || '.txt';

         BEGIN
            INSERT INTO tmp_file
               SELECT v_filename, ID
                 FROM tmp_accountbucketstable
                WHERE bucket = v_bucket;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_result :=
                  '6000010-dearchive_files operation failed-->insert into file table for product views';
               CLOSE c1;
               CLOSE c2;
               RETURN;
         END;
      END LOOP;

      CLOSE c1;
   END LOOP;

   CLOSE c2;

   v_count := 0;

   IF v_count > 0
   THEN
      v_filename :=
               't_adj_trans' || '_' || CAST (p_interval_id AS VARCHAR2)
               || '.txt';

      BEGIN
         INSERT INTO tmp_file
            SELECT v_filename, ID
              FROM tmp_accountbucketstable
             WHERE bucket = v_bucket;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '6000011-dearchive_files operation failed-->insert into file table for t_adjustment_transaction';
            RETURN;
      END;
   END IF;

   v_sql1 :=
         'select distinct adj_name from t_archive where id_interval = '
      || p_interval_id
      || ' and tt_end = dbo.mtmaxdate and adj_name is not null and status=''A''';

   OPEN c1 FOR v_sql1;

   LOOP
      FETCH c1
       INTO v_var1;

      EXIT WHEN c1%NOTFOUND;
      v_sql1 := 'select id_view from t_prod_view where nm_table_name = replace(' || v_var1 || ',''pv'',''aj'')';
      execute immediate v_sql1 into v_var2;
      v_filename :=
             'aj_' || v_var2 || '_' || CAST (p_interval_id AS VARCHAR2)
             || '.txt';
      BEGIN
         INSERT INTO tmp_file
            SELECT v_filename, ID
              FROM tmp_accountbucketstable
             WHERE bucket = v_bucket;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result :=
               '6000012-dearchive_files operation failed-->insert into file table for t_aj_tables';

            CLOSE c1;

            RETURN;
      END;
   END LOOP;

   CLOSE c1;

   OPEN p_cur FOR 'select filename,id_acc from tmp_file order by id_acc';

   p_result := '0-dearchive_files operation successful';
END;
