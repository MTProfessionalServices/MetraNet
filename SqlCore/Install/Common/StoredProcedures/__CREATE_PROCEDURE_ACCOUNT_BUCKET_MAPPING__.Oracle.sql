
CREATE OR REPLACE PROCEDURE account_bucket_mapping (
   p_partition_name         NVARCHAR2 DEFAULT NULL,
   p_interval_id          INT DEFAULT NULL,
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

   /* How to run this procedure DECLARE    p_partition_name NVARCHAR2(200);   p_interval_id NUMBER;   p_hash NUMBER;   p_result NVARCHAR2(200); BEGIN    p_partition_name := NULL;   p_interval_id := 883621891;   p_hash := 2;   p_result := NULL;   ACCOUNT_BUCKET_MAPPING ( p_partition_name, p_interval_id, p_hash, p_result );   dbms_output.put_line(p_result);   COMMIT;  END;   OR DECLARE    p_partition_name NVARCHAR2(200);   p_interval_id NUMBER;   p_hash NUMBER;   p_result NVARCHAR2(200);  BEGIN    p_partition_name := 'HS_20070131';   p_interval_id := null;   p_hash := 2;   p_result := NULL;   ACCOUNT_BUCKET_MAPPING ( p_partition_name, p_interval_id, p_hash, p_result );   dbms_output.put_line(p_result);   COMMIT;  END;   */
   SELECT SYSDATE
     INTO v_currentdate
     FROM DUAL;

   SELECT dbo.mtmaxdate
     INTO v_maxdate
     FROM DUAL; /* Check that either Interval or Partition is specified */

   IF (   (p_partition_name IS NOT NULL AND p_interval_id IS NOT NULL)
       OR (p_partition_name IS NULL AND p_interval_id IS NULL)
      )
   THEN
      p_result :=
         '4000001-account_bucket_mapping operation failed-->Either Partition or Interval should be specified';
      ROLLBACK;
      RETURN;
   END IF;

   /* Run the following code if Interval is specified */
   IF (p_interval_id IS NOT NULL)
   THEN
      /*Check that Interval exists */
      SELECT COUNT (1)
        INTO v_count
        FROM t_usage_interval
       WHERE id_interval = p_interval_id;

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
       WHERE id_interval = p_interval_id AND tx_interval_status = 'H';

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
       WHERE id_usage_interval = p_interval_id;

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
            || CAST (p_interval_id AS VARCHAR2)
            || ',id_acc,mod(id_acc,'
            || CAST (p_hash AS VARCHAR2)
            || '),''U'','''
            || v_currentdate
            || ''','''
            || v_maxdate
            || ''' from t_acc_usage_interval where id_usage_interval = '
            || CAST (p_interval_id AS VARCHAR2);

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

   IF (p_partition_name IS NOT NULL)
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
                                 WHERE partition_name = p_partition_name);

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
    