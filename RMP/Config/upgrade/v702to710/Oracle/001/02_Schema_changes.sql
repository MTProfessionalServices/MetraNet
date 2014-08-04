CREATE OR REPLACE PROCEDURE archive_queue(
    p_update_stats		VARCHAR2	DEFAULT 'N',
    p_sampling_ratio	VARCHAR2	DEFAULT '30',
    p_current_time		DATE		DEFAULT NULL,
    p_result		OUT VARCHAR2
)
AUTHID CURRENT_USER
AS
    /*
    How to run this stored procedure:   
    DECLARE 
		v_result VARCHAR2(2000);
    BEGIN
		archive_queue ( p_result => v_result );
		DBMS_OUTPUT.put_line (v_result);
    END;
    
    Or if we want to update statistics and change current date/time also:   
    DECLARE 
        v_result		VARCHAR2(2000),
        v_current_time	DATE
    BEGIN
        v_current_time := SYSDATE;
        archive_queue_partition (
             p_update_stats => 'Y',
             p_sampling_ratio => 30,
             p_current_time => v_current_time,
             p_result => v_result
             );
        DBMS_OUTPUT.put_line (v_result);
    END;
    */
    v_is_part_enabled			VARCHAR2(1);
BEGIN

    SELECT UPPER(b_partitioning_enabled) INTO v_is_part_enabled FROM t_usage_server;
    /* Nothing to do if system isn't enabled for partitioning */
    IF v_is_part_enabled <> 'Y' THEN
        dbms_output.put_line('Partitioning is not enabled, so can not execute archive_queue sp.');
        RETURN;
    END IF;

	archive_queue_partition(
		P_UPDATE_STATS => p_update_stats,
		P_SAMPLING_RATIO => p_sampling_ratio,
		P_CURRENT_TIME => p_current_time,
		P_RESULT => p_result);
END;
/

DROP PROCEDURE getnonarchiverecords
/

DROP PROCEDURE deployallpartitionedtables
/

DROP PROCEDURE deploypartitionedtable
/

DROP PROCEDURE duppartitionedtable
/

DROP PROCEDURE createusagepartitions
/

ALTER TYPE tab_id_instance COMPILE 
/

ALTER PACKAGE dbo COMPILE 
/

ALTER FUNCTION metratime COMPILE 
/

CREATE OR REPLACE FUNCTION AllowInitialArrersCharge(
p_b_advance IN char,
p_id_acc IN integer,
p_sub_end IN date,
p_current_date IN date)
RETURN smallint
IS
p_is_allow_create  smallint;
begin
	if p_b_advance = 'Y' then
		/* allows to create initial for ADVANCE */
		p_is_allow_create := 1;
	else
		/* Creates Initial charges in case it fits inder current interval*/
		select case when exists(select 1 from t_usage_interval us_int
					join t_acc_usage_cycle acc
					on us_int.id_usage_cycle = acc.id_usage_cycle
					where acc.id_acc = p_id_acc
					AND NVL(p_current_date, metratime(1,'RC')) BETWEEN DT_START AND DT_END
					AND p_sub_end BETWEEN DT_START AND DT_END
					)
				then 1
				else 0
			  end
		into p_is_allow_create
		from dual;
	  
	end	if;
	  
	return p_is_allow_create;
end;
/

CREATE OR REPLACE PROCEDURE updatebatchstatus (
   tx_batch           IN   RAW,
   tx_batch_encoded   IN   VARCHAR2,
   n_completed        IN   INT,
   sysdate_           IN   DATE
)
AS
   tx_batch_           RAW (255)      := tx_batch;
   tx_batch_encoded_   VARCHAR2 (24)  := tx_batch_encoded;
   n_completed_        NUMBER (10, 0) := n_completed;
   sysdate__           DATE           := sysdate_;
   stoo_selcnt         INTEGER;
   initialstatus       CHAR (1);
   finalstatus         CHAR (1);

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
      stoo_selcnt := 0;

      SELECT count(1)
        INTO stoo_selcnt
                    FROM t_batch
                   WHERE tx_batch =
                                           hextoraw(updatebatchstatus.tx_batch_)
                                           ;
   IF stoo_selcnt = 0
   THEN
      INSERT INTO t_batch
                  (id_batch, tx_namespace,
                   tx_name,
                   tx_batch,
                   tx_batch_encoded, tx_status, n_completed, n_failed,
                   dt_first, dt_crt
                  )
           VALUES (seq_t_batch.NEXTVAL, 'pipeline',
                   updatebatchstatus.tx_batch_encoded_,
                   updatebatchstatus.tx_batch_,
                   updatebatchstatus.tx_batch_encoded_, 'A', 0, 0,
                   updatebatchstatus.sysdate__, updatebatchstatus.sysdate__
                  );
   END IF;

   SELECT tx_status into initialstatus
                 FROM t_batch
                WHERE tx_batch= hextoraw(updatebatchstatus.tx_batch_)
                for update;

   UPDATE t_batch
      SET t_batch.n_completed =
                          t_batch.n_completed + updatebatchstatus.n_completed_,
          t_batch.tx_status =
             CASE
                WHEN (   UPPER(t_batch.tx_status) = 'A' and (t_batch.n_failed > 0)
                     )
                   THEN 'F'
                WHEN (   (  t_batch.n_completed
                          + t_batch.n_failed
                          + nvl(t_batch.n_dismissed, 0)
                          + updatebatchstatus.n_completed_
                         ) = t_batch.n_expected
                      OR (    ((  t_batch.n_completed
                                + t_batch.n_failed
                                + nvl(t_batch.n_dismissed, 0)
                                + updatebatchstatus.n_completed_
                               ) = t_batch.n_metered
                              )
                          AND t_batch.n_expected = 0
                         )
                     )
                   THEN 'C'
                WHEN (   (  t_batch.n_completed
                          + t_batch.n_failed
                          + nvl(t_batch.n_dismissed, 0)
                          + updatebatchstatus.n_completed_
                         ) < t_batch.n_expected
                      OR (    ((  t_batch.n_completed
                                + t_batch.n_failed
                                + nvl(t_batch.n_dismissed, 0)
                                + updatebatchstatus.n_completed_
                               ) < t_batch.n_metered
                              )
                          AND t_batch.n_expected = 0
                         )
                     )
                   THEN 'A'
                WHEN ((  t_batch.n_completed
                       + t_batch.n_failed
                       + nvl(t_batch.n_dismissed, 0)
                       + updatebatchstatus.n_completed_
                      ) > t_batch.n_expected
                     )
                AND t_batch.n_expected > 0
                   THEN 'F'
                ELSE t_batch.tx_status
             END,
          t_batch.dt_last = updatebatchstatus.sysdate__,
          t_batch.dt_first =
             CASE
                WHEN t_batch.n_completed = 0
                   THEN updatebatchstatus.sysdate__
                ELSE t_batch.dt_first
             END
    WHERE tx_batch = hextoraw(updatebatchstatus.tx_batch_);

   SELECT tx_status into finalstatus
                 FROM t_batch
                WHERE tx_batch = hextoraw(updatebatchstatus.tx_batch_);
				 COMMIT;
END updatebatchstatus;
/

CREATE OR REPLACE PROCEDURE prtn_create_meter_partitions
authid current_user
AS

  meter_tablespace_name varchar2(50);  /* name of tablespace to create */

--OPT
  data_size int := 50;   /* size of each data file */
  log_size int := 12;   /* size of each log file */

-- DEL?
  cnt int;
  ts_ddl varchar2(4000);
  ts_name varchar2(2000);
  ts_opts varchar2(200);

  df_name varchar2(2000);
  df_size varchar2(200);
  df_opts varchar2(200);
  
  ix int;
  path varchar2(2000);
  paths str_tab;
  distrib_method varchar2(20);

begin

    select prtn_GetMeterPartFileGroupName() into meter_tablespace_name from dual;

  select partition_data_size, partition_log_size
    into data_size, log_size
  from t_usage_server;
  
  /* Abort if tablespace already exists */
  select count(1) into cnt from dual
  where exists (
    select 1 from user_tablespaces
    where tablespace_name = upper(meter_tablespace_name));
    
  if (cnt > 0) then
    dbms_output.put_line('Tablespace '|| meter_tablespace_name ||' already exists.');
    return;
  end if;

  /* Create tablespace statement should look like this:
  
    create tablespace n_abcd
      datafile 
          'c:\oradata\01\n_abcd.dbf' size 5m reuse autoextend on next 100m maxsize unlimited,
          'c:\oradata\02\n_abcd.dbf' size 5m reuse autoextend on next 100m maxsize unlimited,
          'c:\oradata\03\n_abcd.dbf' size 5m reuse autoextend on next 100m maxsize unlimited,
          'c:\oradata\04\n_abcd.dbf' size 5m reuse  autoextend on next 100m maxsize unlimited
      logging extent management local segment space management auto 
  */

  ts_ddl := 'create tablespace ' || meter_tablespace_name || ' datafile ';
  df_size := ' size '|| data_size ||'m';
  df_opts := ' reuse autoextend on next 100m maxsize unlimited,';
  ts_opts:= ' logging extent management local segment space management auto';

  
  /* eventually distrib_method will come from t_usage_server table */
  distrib_method := 'roundrobin';

  if lower(distrib_method) = 'roundrobin' then
    GetNextStoragePath(path);
    paths := str_tab(path);
  elsif lower(distrib_method) = 'parallel' then
    select path
    bulk collect into paths
    from t_partition_storage;
  else
    raise_application_error(-20000, 'Invalid distribution method: ' || distrib_method );
  end if;

  /* At least one data storage path must be defined */
  if paths.first is null then
    raise_application_error(-20000, 'There are no storage paths defined.');
  end if;

    dbms_output.put_line(paths(1));

    /* build datafile full path name; check and fix trailing path sep */
    df_name := '''' || rtrim(paths(1), '/\') || '/'
      || meter_tablespace_name || '.dbf''';
    
    /* append filename, size and options */
    ts_ddl := ts_ddl || chr(10) || chr(9)
      || df_name || df_size || df_opts;
    
  /* remove trailing comma, append tablespace opts */
  ts_ddl := rtrim(ts_ddl, ',') || chr(10) || chr(9) || ts_opts;

  dbms_output.put_line('CreatePartitionDatabase: ts_ddl=' || ts_ddl);

  exec_ddl(ts_ddl);

end prtn_create_meter_partitions;
/

CREATE OR REPLACE PROCEDURE prtn_create_tax_partitions
        as
        begin
          dbms_output.put_line('Invoked prtn_create_tax_partitions().');
        end prtn_create_tax_partitions;
/

CREATE OR REPLACE PROCEDURE prtn_create_usage_partitions(
  p_cur out sys_refcursor
  )
authid current_user
as
  /* Specs for creating partitions */
  enabled char(1);
  cycleid int;
  datasize int;
  logsize int;
  path varchar2(2000);
  intervalstatus varchar2(10);
  
  /* Vars for iterating through the new partition list */
  partns sys_refcursor;
  partitionname varchar2(30);
  dtstart date;
  dtend date;
  intervalstart int;
  intervalend int;
  result varchar2(2000);

  cnt int;
begin
  
  /* Abort if system isn't enabled for partitioning */
  if dbo.IsSystemPartitioned() = 0 then
    dbms_output.put_line('System not enabled for partitioning.');
    open p_cur for select * from tmp_partns where 1=0;
    return;
  end if;
  
  /* Get database size params */
  select partition_data_size, partition_log_size
  into datasize, logsize
  from t_usage_server;
  
  /* Determine if this is a conversion and include 
    hard-closed intervals if so. */

  /* Is t_acc_usage partitioned? */
  select count(1) into cnt from dual
    where exists (select 1
      from user_part_tables
      where table_name like upper('t_acc_usage'));

  intervalstatus := case cnt
    when 0 then '[BO]' else '[HBO]' end;

  /* Get list of new partition names*/
  /* Returns a cursor containing:
      dt_start,
      dt_end,
      interval_start,
      interval_end
  */
  GeneratePartitionSequence(partns);

  /* Iterate through partition sequence */
  loop
    fetch partns into dtstart, dtend, intervalstart, intervalend;
    exit when partns%notfound;

    dbms_output.put_line('dtstart=' || to_char(dtstart));
    dbms_output.put_line('dtend=' || to_char(dtend));
    dbms_output.put_line('intervalstart=' || to_char(intervalstart));
    dbms_output.put_line('intervalend=' || to_char(intervalend));

    /* Construct database name */
    select user || '_' || to_char(dtend, 'yyyymmdd')
    into partitionname from dual;
    dbms_output.put_line('partitionname=' || partitionname);

    /* Create the partition database and check exception */
    CreatePartitionDatabase(partitionname, datasize, logsize);
  
    /* Insert partition metadata */
    insert into t_partition (id_partition,
        partition_name, b_default,
        dt_start, dt_end, id_interval_start, id_interval_end, b_active)
      values (seq_t_partition.nextval,
        trim(partitionname), 'N',
        dtstart, dtend, intervalstart, intervalend, 'Y');
      
    if not sql%found then
      raise_application_error(-20000, 'Cannot insert partition metadata into t_partition.');
    end if;
    
    commit;

    /* Save partition info for reporting */
    insert into tmp_partns values (partitionname, dtstart, dtend,
      intervalstart, intervalend, result);
  
  end loop;
  
  close partns;
  
  /* Create or fixup the default partition  */
  CreateDefaultPartition;
  
  /* Finished creating databases. 
  
    Include default partition info with new partition list 
    if new partitions were created. Return the list as result 
    set for reporting.
  */

  insert into tmp_partns
    select partition_name, dt_start, dt_end,
           id_interval_start, id_interval_end, ''
    from t_partition
    where b_default  = 'Y'
      and exists (select 1 from tmp_partns);
  
  open p_cur for
    select * from tmp_partns order by dt_start;

end prtn_create_usage_partitions;
/

CREATE OR REPLACE PROCEDURE prtn_deploy_table(
    p_tab                       VARCHAR2,       /* Table to convert */
    p_tab_type                  VARCHAR2        /* Takes only 2 values: "USAGE" or "METER" */
)
authid current_user
AS
    partn_tab                   VARCHAR2 (30);  /* temp name for new partitioned table */
    def_partn_name              VARCHAR2 (30);  /* default partition name */
    partn_ddl                   VARCHAR2 (4000);
    exchg_ddl                   VARCHAR2 (4000);
    partition_by_clause         VARCHAR2 (100); /* Example: 'partition by LIST (id_partition)' */
    def_prtn_condition          VARCHAR2 (100); /* Condition for default partition */
    is_part_enabled     		VARCHAR2(1);
    current_id_part             INT;
    idx_ddl                     str_tab;
    cons_ddl                    str_tab;
    cons_ddl1                   str_tab;
    idx_drop                    str_tab;
    cons_drop                   str_tab;
    cons_drop1                  str_tab;
    cnt                         INT;
    ix                          INT;
    nl                          CHAR (1) := CHR (10);
    tab                         CHAR (2) := '  ';
    nlt                         CHAR (3) := nl || tab;
BEGIN

    DBMS_OUTPUT.put_line ('prtn_deploy_table: ' || p_tab);
    
    SELECT UPPER(b_partitioning_enabled) INTO is_part_enabled FROM t_usage_server;
    /* Nothing to do if system isn't enabled for partitioning */
    IF is_part_enabled <> 'Y' THEN
        dbms_output.put_line('System not enabled for partitioning.');
        RETURN;
    END IF;

    /* Make sure this table isn't already partitioned */
    SELECT COUNT(1) INTO cnt
    FROM   DUAL
    WHERE  EXISTS ( SELECT 1
                    FROM   user_part_tables
                    WHERE  UPPER(table_name) = UPPER(p_tab));

    IF cnt > 0 THEN
        DBMS_OUTPUT.put_line ('prtn_deploy_table: ' || p_tab || ' is already partitioned.');
        RETURN;
    END IF;

   /* Temp name for new table, expecting name with form 't_whatever' */
   partn_tab := 'p' || SUBSTR (p_tab, 2);
   
    /* Initialize Default Partition info (tablespace, parition values) for Usage or Meter table tablespace name */
    IF p_tab_type = 'USAGE' THEN
        BEGIN
            partition_by_clause := 'partition by RANGE (id_usage_interval)';
            def_prtn_condition := 'less than (9999999999)';
			def_partn_name := 'd' || SUBSTR (p_tab, 2);
        END;
    ELSE
    	IF p_tab_type = 'METER' THEN
			BEGIN
			partition_by_clause := 'partition by LIST (id_partition)';

			SELECT MAX(current_id_partition) INTO current_id_part FROM t_archive_queue_partition;
			def_prtn_condition := '(' || current_id_part || ')';
			def_partn_name := 'p' || current_id_part;
			END;
		ELSE
			raise_application_error (-20000, '"p_tab_type" input parameter may take only 2 values: "USAGE" or "METER"');
		END IF;
    END IF;

    /* 1. Gather ddl commands for partition table conversion      2. Execute ddl   */
    /* For Usage Partitioning:
    * Get the 'create table' ddl         Create DDL:         create table p_acc_usage           partition by range (id_usage_interval) (             partition d_acc_usage values less than (9999999999)             )                  Oracle defines range partitions using:            VALUES LESS THAN (<rangespec>)            The <rangespec> is one more than the value in id_interval_end        in t_partition for that partition and 9999999999 if it's the
    default partition.
    */

   /* ddl for partitioned table with default partition only */
   partn_ddl :=
         '  create table '
      || partn_tab
      || nlt
      || partition_by_clause || ' ('
      || nlt
      || '    partition '
      || def_partn_name
      || ' values ' || def_prtn_condition || ')'
      || nlt
      || '  as select * from '
      || p_tab
      || ' where 1=0';
   /* ddl for exchange partition operation. the real convert step. */
   exchg_ddl :=
         'alter table '
      || partn_tab
      || ' exchange partition '
      || def_partn_name
      || ' with table '
      || p_tab;

   /* Get primary key constraint ddl from source table */
   SELECT      'alter table '
            || partn_tab
            || ' add constraint '
            || constraint_name
            || ' primary key ('
            || dbo.strtabtocsv (CAST (COLLECT (column_name) AS str_tab))
            || ')'
            || ' using index (create index '
            || constraint_name
            || ' on '
            || partn_tab
            || ' ('
            || dbo.strtabtocsv (CAST (COLLECT (column_name) AS str_tab))
            || ') local)',                  /* todo: logging or nologging ? */
               'alter table '
            || table_name
            || ' drop constraint '
            || constraint_name
   BULK COLLECT INTO cons_ddl,
            cons_drop
       FROM (SELECT   uc.table_name, uc.constraint_name, uc.constraint_type,
                      column_name, POSITION
                 FROM user_cons_columns ucc JOIN user_constraints uc
                      ON uc.constraint_name = ucc.constraint_name
                WHERE constraint_type = 'P'
                  AND LOWER (uc.table_name) = LOWER (p_tab)
             ORDER BY POSITION)
   GROUP BY table_name, constraint_name;

   /* Get unique constraint ddl from source table */
   SELECT      'alter table '
            || partn_tab
            || ' add constraint '
            || constraint_name
            || ' unique ('
            || dbo.strtabtocsv (CAST (COLLECT (column_name) AS str_tab))
            || ')'
            || ' disable',                  /* todo: logging or nologging ? */
               'alter table '
            || table_name
            || ' drop constraint '
            || constraint_name
   BULK COLLECT INTO cons_ddl1,
            cons_drop1
       FROM (SELECT   uc.table_name, uc.constraint_name, uc.constraint_type,
                      column_name, POSITION
                 FROM user_cons_columns ucc JOIN user_constraints uc
                      ON uc.constraint_name = ucc.constraint_name
                WHERE constraint_type = 'U'
                  AND LOWER (uc.table_name) = LOWER (p_tab)
             ORDER BY POSITION)
   GROUP BY table_name, constraint_name;

   /* Get ddl for non-unique indexes on source table. */
   SELECT      'create index '
            || index_name
            || ' on '
            || partn_tab
            || ' ('
            || dbo.strtabtocsv (CAST (COLLECT (column_name) AS str_tab))
            || ') local ',                  /* todo: logging or nologging ? */
            'drop index ' || index_name
   BULK COLLECT INTO idx_ddl,
            idx_drop
       FROM (SELECT   uic.table_name, uic.index_name, column_name,
                      column_position
                 FROM user_ind_columns uic JOIN user_indexes ui
                      ON uic.index_name = ui.index_name
                    AND ui.uniqueness = 'NONUNIQUE'
                WHERE LOWER (uic.table_name) = LOWER (p_tab)
             ORDER BY uic.table_name, uic.index_name, uic.column_position)
   GROUP BY table_name, index_name;

   /* CORE-6638. Some workaround about this issue. */
   /* Get default constraint ddl from source table */
   /*
   SELECT      'ALTER TABLE '
            || partn_tab
            || ' MODIFY '
            || COLUMN_NAME
            || ' DEFAULT '
            || DATA_DEFAULT  -- an error here. Long should be converted to varchar
   BULK COLLECT INTO def_cons_ddl1
       FROM (
            SELECT COLUMN_NAME,
                    DATA_DEFAULT
            FROM   USER_TAB_COLUMNS
            WHERE  LOWER(TABLE_NAME) = LOWER(p_tab)
       );
    */


   /* Collected all the ddl statements we need, time to exec.

       1. Create new partitioned table with default partition only.
       2. Drop constraints from old table.
       3. Add constraints to new table (disabled)
       4. Exchange old table with the default partition
       5. Drop old table, rename new to old

   */

   /* Create new partitioned table with default partition only. */
   DBMS_OUTPUT.put_line ( 'prtn_deploy_table: Creating partitioned table '
                         || partn_tab );
   DBMS_OUTPUT.put_line (partn_ddl);

   EXECUTE IMMEDIATE partn_ddl;

   /* Drop constraints from old table. */
   DBMS_OUTPUT.put_line
               ('prtn_deploy_table: Dropping primary key/unique constraints');

   IF cons_drop.FIRST IS NOT NULL
   THEN
      FOR ix IN cons_drop.FIRST .. cons_drop.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || cons_drop (ix));

         EXECUTE IMMEDIATE cons_drop (ix);
      END LOOP;
   END IF;

   IF cons_drop1.FIRST IS NOT NULL
   THEN
      FOR ix IN cons_drop1.FIRST .. cons_drop1.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || cons_drop1 (ix));

         EXECUTE IMMEDIATE cons_drop1 (ix);
      END LOOP;
   END IF;

   DBMS_OUTPUT.put_line ('prtn_deploy_table: Dropping non-unique indexes');

   IF idx_drop.FIRST IS NOT NULL
   THEN
      FOR ix IN idx_drop.FIRST .. idx_drop.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || idx_drop (ix));

         EXECUTE IMMEDIATE idx_drop (ix);
      END LOOP;
   END IF;

   /* Add primary key/unqiue constraints  in disabled mode to avoid
      validation during exchange operation.  No need to build the
      underlying indexes at this moment. */
   DBMS_OUTPUT.put_line
      ('prtn_deploy_table: Adding primary key/unique constraints (disabled)');

   IF cons_ddl.FIRST IS NOT NULL
   THEN
      FOR ix IN cons_ddl.FIRST .. cons_ddl.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || cons_ddl (ix));

         EXECUTE IMMEDIATE cons_ddl (ix);
      END LOOP;
   END IF;

   IF cons_ddl1.FIRST IS NOT NULL
   THEN
      FOR ix IN cons_ddl1.FIRST .. cons_ddl1.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || cons_ddl1 (ix));

         EXECUTE IMMEDIATE cons_ddl1 (ix);
      END LOOP;
   END IF;

   /* Add non-unique local indexes
   */
   DBMS_OUTPUT.put_line
                     ('prtn_deploy_table: Creating non-unique local indexes');

   IF idx_ddl.FIRST IS NOT NULL
   THEN
      FOR ix IN idx_ddl.FIRST .. idx_ddl.LAST
      LOOP
         DBMS_OUTPUT.put_line ('  ' || idx_ddl (ix));

         EXECUTE IMMEDIATE idx_ddl (ix);
      END LOOP;
   END IF;

	IF p_tab_type = 'METER' THEN
		/* Add DEFAULT constraint 'id_partition' column for METER tables
		*/
		DBMS_OUTPUT.put_line('prtn_deploy_table: Apply DEFAULT constraint "id_partition" column');

		EXECUTE IMMEDIATE 'ALTER TABLE ' || partn_tab
						|| ' MODIFY id_partition'
						|| ' DEFAULT ' || current_id_part;
	END IF;

   DBMS_OUTPUT.put_line (   'prtn_deploy_table: Exchanging '
                         || p_tab
                         || ' and default partition'
                        );
   DBMS_OUTPUT.put_line ('  ' || exchg_ddl);

   EXECUTE IMMEDIATE exchg_ddl;

   /* Partiton table is created and loaded. Drop the old and rename new.
   */
   DBMS_OUTPUT.put_line ('prtn_deploy_table: Dropping table ' || p_tab);

   EXECUTE IMMEDIATE 'drop table ' || p_tab || ' cascade constraints purge';

   DBMS_OUTPUT.put_line ( 'prtn_deploy_table: Renaming ' || partn_tab
                         || ' to ' || p_tab );

   EXECUTE IMMEDIATE 'alter table ' || partn_tab || ' rename to ' || p_tab;

END prtn_deploy_table;
/

CREATE OR REPLACE PROCEDURE prtn_deploy_serv_def_table(
    p_tab               VARCHAR2
)
authid CURRENT_USER
AS
    is_not_partitioned  INT;  /* is table not partitioned yet? */
    current_id_part     INT;
    is_part_enabled     VARCHAR2(1);
BEGIN

    SELECT UPPER(b_partitioning_enabled) INTO is_part_enabled FROM t_usage_server;
    /* Nothing to do if system isn't enabled for partitioning */
    IF is_part_enabled <> 'Y' THEN
        dbms_output.put_line('System not enabled for partitioning.');
        RETURN;
    END IF;

    /* If the table is not yet parititoned, then this a conversion */
    SELECT COUNT(1) INTO is_not_partitioned
    FROM   dual
    WHERE  NOT EXISTS (
               SELECT 1
               FROM   user_part_tables
               WHERE  UPPER(table_name) = UPPER(p_tab)
           );

    IF is_not_partitioned = 1 THEN

        /* Do the converstion.  Only once per table.
        When this call completes the table will be partitioned with
        a default paritions only.  The split op still has to be done. */
        prtn_deploy_table(
            p_tab => p_tab,
            p_tab_type => 'METER');

        /* Rebuild UNUSABLE global indexes */
        RebuildGlobalIndexes(p_tab);

        /* Enable all unique constraints (that are DISABLED) */
        AlterTableUniqueConstraints(p_tab, 'enable');

        /* Rebuild UNUSABLE local index partitions. */
        RebuildLocalIndexParts(p_tab);

        dbms_output.put_line('First partition was created for "' || p_tab || '" with current id_partition = ' || current_id_part);

    END IF;

END prtn_deploy_serv_def_table;
/

CREATE OR REPLACE PROCEDURE prtn_deploy_all_meter_tables
authid current_user
AS
	current_id_part INT;
BEGIN

	/* Abort if system isn't enabled for partitioning */
	IF dbo.IsSystemPartitioned() = 0 THEN
		raise_application_error(-20000, 'System not enabled for partitioning.');
	END IF;

	dbms_output.put_line('prtn_deploy_all_meter_tables: Starting depolying meter tables');

	FOR x IN (	SELECT   nm_table_name
				FROM     t_service_def_log
				ORDER BY nm_table_name)
	LOOP
		prtn_deploy_serv_def_table(	p_tab => x.nm_table_name );
	END LOOP;

	/* Deploy message and session tables */
	prtn_deploy_serv_def_table(p_tab => 't_message');
	prtn_deploy_serv_def_table(p_tab => 't_session');
	prtn_deploy_serv_def_table(p_tab => 't_session_set');
	prtn_deploy_serv_def_table(p_tab => 't_session_state');

END prtn_deploy_all_meter_tables;
/

CREATE OR REPLACE PROCEDURE prtn_deploy_usage_table(
	p_tab		VARCHAR2
)
authid current_user
AS
	cnt			INT;
	rowcnt		INT;
	defdb		VARCHAR2(30);	/* default part info */
	defstart	INT;
	defend		INT;
	isconv		INT;			/* Is table corrently not under partition? (Should be converted) */
BEGIN

	/* Nothing to do if system isn't enabled for partitioning */
	IF dbo.isSystemPartitioned() = 0 THEN
		dbms_output.put_line('System not enabled for partitioning.');
		RETURN;
	END IF;

	/* Count active partitions. */
	SELECT COUNT(1) INTO cnt
	FROM   t_partition
	WHERE  b_active = 'Y';

	IF (cnt < 2) THEN
		raise_application_error(-20000, 'Found '|| cnt ||' active partitions. Expected at least 2 (including default).');
	END IF;
  
	/* Make sure there's only one default partition. */
	SELECT COUNT(1) INTO cnt
	FROM   t_partition
	WHERE  b_default = 'Y' AND b_active = 'Y';

	IF (cnt != 1) THEN
		raise_application_error(-20000,'Found ' || cnt || ' default partitions. Expected one.');
	END IF;

	/* If the table is not yet parititoned, then this a conversion */
	SELECT COUNT(1) INTO isconv
	FROM   dual
	WHERE  NOT EXISTS (
				SELECT 1
				FROM   user_part_tables
				WHERE  UPPER(table_name) = UPPER(p_tab));

	IF isconv = 1 THEN
		/* Do the converstion.  Only once per table.
		When this call completes the table will be partitioned with
		a default paritions only.  The split op still has to be done. */
		prtn_deploy_table(
			p_tab => p_tab,
			p_tab_type => 'USAGE');
	END IF;

	/* Add as many partitions as needed. */
	ExtendPartitionedTable(p_tab);

	/* Rebuild UNUSABLE global indexes */
	RebuildGlobalIndexes(p_tab);

	/* Enable all unique constraints (that are DISABLED) */
	AlterTableUniqueConstraints(p_tab, 'enable');

	/* Rebuild UNUSABLE local index partitions. */
	RebuildLocalIndexParts(p_tab);

END prtn_deploy_usage_table;
/

CREATE OR REPLACE PROCEDURE prtn_deploy_all_usage_tables authid current_user  as begin
/* Abort if system isn't enabled for partitioning */

  if dbo.IsSystemPartitioned() = 0 then
    raise_application_error(-20000, 'System not enabled for partitioning.');
  end if;

  for x in (select nm_table_name
        from t_prod_view
        order by nm_table_name)
  loop

    dbms_output.put_line('prtn_deploy_all_usage_tables: Depolying '|| x.nm_table_name);
    prtn_deploy_usage_table(x.nm_table_name);

  end loop;

end prtn_deploy_all_usage_tables;
/

CREATE OR REPLACE PROCEDURE prtn_insert_meter_part_info(
    id_partition INT,
    current_datetime DATE DEFAULT SYSDATE)
AS
    next_allow_run DATE;
BEGIN

    prtn_get_next_allow_run_date (
        current_datetime => current_datetime,
        next_allow_run_date => next_allow_run);
         
    INSERT INTO t_archive_queue_partition
    VALUES
      (
        id_partition,
        current_datetime,
        next_allow_run
      );
END;
/

ALTER PROCEDURE getcurrentid COMPILE 
/

CREATE OR REPLACE PROCEDURE inserttemplatesession
(
    id_template_owner INT,
    nm_acc_type VARCHAR2,
    id_submitter INT,
    nm_host VARCHAR2,
    n_status INT,
    n_accts INT,
    n_subs INT,
    session_id OUT INT,
    doCommit CHAR DEFAULT 'Y'
)
AS
BEGIN
     getcurrentid(
            p_nm_current => 'id_template_session',
            p_id_current => session_id
        );
     insert into t_acc_template_session(id_session, id_template_owner, nm_acc_type, dt_submission, id_submitter, nm_host, n_status, n_accts, n_subs)
    values (session_id, id_template_owner, nm_acc_type, CURRENT_DATE, id_submitter, nm_host, n_status, n_accts, n_subs);
    IF (doCommit = 'Y') THEN
        COMMIT;
    END IF;
END;
/

ALTER PROCEDURE insertauditevent COMPILE 
/

CREATE OR REPLACE PROCEDURE InsertAuditEvent2 (
    temp_id_userid number,
    temp_id_event number,
    temp_id_entity_type number,
    temp_id_entity number,
    temp_dt_timestamp date,
    temp_tx_details varchar2,
    temp_id_audit number,
    tx_logged_in_as nvarchar2,
    tx_application_name nvarchar2,
    id_audit_out OUT number
)
AS
BEGIN
    IF (temp_id_audit IS NULL OR temp_id_audit = 0) THEN
		 getcurrentid(
            p_nm_current => 'id_audit',
            p_id_current => id_audit_out
        );
    ELSE
        id_audit_out := temp_id_audit;
    END IF;

    InsertAuditEvent(
        temp_id_userid      => temp_id_userid,
        temp_id_event       => temp_id_event,
        temp_id_entity_type => temp_id_entity_type,
        temp_id_entity      => temp_id_entity,
        temp_dt_timestamp   => temp_dt_timestamp,
        temp_id_audit       => id_audit_out,
        temp_tx_details     => temp_tx_details,
        tx_logged_in_as     => tx_logged_in_as,
        tx_application_name => tx_application_name
    );
END;
/

ALTER PROCEDURE getidblock COMPILE 
/
