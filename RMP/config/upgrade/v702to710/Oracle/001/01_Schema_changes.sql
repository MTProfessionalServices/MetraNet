SET DEFINE OFF

DECLARE
    last_upgrade_id NUMBER;
BEGIN
    SELECT (NVL(MAX(upgrade_id), 0) + 1)
    INTO   last_upgrade_id
    FROM   t_sys_upgrade;

    INSERT INTO t_sys_upgrade
      (
        upgrade_id,
        target_db_version,
        dt_start_db_upgrade,
        db_upgrade_status
      )
    VALUES
      (
        last_upgrade_id,
        '7.1.0',
        SYSDATE(),
        'R'
      );
END;
/

CREATE TABLE rg_temp_733134584_0 (
  id_payment_transaction VARCHAR2(87 BYTE) NOT NULL,
  nm_invoice_num NVARCHAR2(50) NOT NULL,
  n_amount NUMBER(22,10),
  dt_invoice TIMESTAMP NOT NULL,
  nm_po_number NVARCHAR2(30)
)
/

INSERT INTO rg_temp_733134584_0(id_payment_transaction,nm_invoice_num,n_amount,dt_invoice,nm_po_number) SELECT id_payment_transaction,nm_invoice_num,CAST(LEAST(n_amount, 999999999999.9999999999) as NUMBER(22,10)),dt_invoice,nm_po_number FROM t_pending_ach_trans_details
/

DROP TABLE t_pending_ach_trans_details
/

ALTER TABLE rg_temp_733134584_0 RENAME TO t_pending_ach_trans_details
/

/* t_pending_ach_trans_details had auotgenerated PK name. It is not suitable for upgrade script and for MN in general, so it will be "pk_t_pending_ach_trans_details" from this moment */
ALTER TABLE t_pending_ach_trans_details
ADD CONSTRAINT pk_t_pending_ach_trans_details PRIMARY KEY (id_payment_transaction,nm_invoice_num)
    USING INDEX (
        CREATE UNIQUE INDEX pk_t_pending_ach_trans_details ON t_pending_ach_trans_details (id_payment_transaction,nm_invoice_num)
    )
/

COMMENT ON TABLE t_pending_ach_trans_details IS 'Holds details of pending ACH transactions. (Package:Pending Payment)'
/

COMMENT ON COLUMN t_pending_ach_trans_details.id_payment_transaction IS 'Link to the transaction in t_pending_ach_transaction'
/

COMMENT ON COLUMN t_pending_ach_trans_details.nm_invoice_num IS 'Invoice #'
/

COMMENT ON COLUMN t_pending_ach_trans_details.n_amount IS 'Amount to pay'
/

COMMENT ON COLUMN t_pending_ach_trans_details.dt_invoice IS 'Date of the invoice'
/

COMMENT ON COLUMN t_pending_ach_trans_details.nm_po_number IS 'Product offering #'
/

CREATE TABLE rg_temp_733134584_1 (
  id_payment_transaction VARCHAR2(87 BYTE) NOT NULL,
  n_days NUMBER(10) NOT NULL,
  id_payment_instrument NVARCHAR2(72) NOT NULL,
  id_acc NUMBER(10) NOT NULL,
  n_amount NUMBER(22,10) NOT NULL,
  nm_description NVARCHAR2(100),
  dt_create TIMESTAMP NOT NULL,
  nm_ar_request_id NVARCHAR2(256)
)
/

INSERT INTO rg_temp_733134584_1(id_payment_transaction,n_days,id_payment_instrument,id_acc,n_amount,nm_description,dt_create,nm_ar_request_id) SELECT id_payment_transaction,n_days,id_payment_instrument,id_acc,CAST(LEAST(n_amount, 999999999999.9999999999) as NUMBER(22,10)),nm_description,dt_create,nm_ar_request_id FROM t_pending_ach_trans
/

DROP TABLE t_pending_ach_trans
/

ALTER TABLE rg_temp_733134584_1 RENAME TO t_pending_ach_trans
/

/* t_pending_ach_trans had auotgenerated PK name. It is not suitable for upgrade script and for MN in general, so it will be "pk_t_pending_ach_trans" from this moment */
ALTER TABLE t_pending_ach_trans
ADD CONSTRAINT pk_t_pending_ach_trans PRIMARY KEY (id_payment_transaction)
    USING INDEX (
        CREATE UNIQUE INDEX pk_t_pending_ach_trans ON t_pending_ach_trans(id_payment_transaction)
    )
/

COMMENT ON TABLE t_pending_ach_trans IS 'Holds details of pending ACH transactions. (Package:Pending Payment)'
/

COMMENT ON COLUMN t_pending_ach_trans.id_payment_transaction IS 'Transaction ID'
/

COMMENT ON COLUMN t_pending_ach_trans.n_days IS 'Days that this transactions is unsettled'
/

COMMENT ON COLUMN t_pending_ach_trans.id_payment_instrument IS 'ID of ACH account'
/

COMMENT ON COLUMN t_pending_ach_trans.id_acc IS 'ID of ACH account'
/

COMMENT ON COLUMN t_pending_ach_trans.n_amount IS 'Amount to pay'
/

COMMENT ON COLUMN t_pending_ach_trans.nm_description IS 'Payment info description'
/

COMMENT ON COLUMN t_pending_ach_trans.dt_create IS 'Date this row was created'
/

COMMENT ON COLUMN t_pending_ach_trans.nm_ar_request_id IS 'Account receivable request ID'
/

CREATE TABLE t_archive_queue_partition (
  current_id_partition NUMBER(*,0) NOT NULL,
  last_run DATE NOT NULL,
  next_allow_run DATE,
  CONSTRAINT pk_current_id_partition PRIMARY KEY (current_id_partition)
)
/

DROP PROCEDURE removegroupsub_quoting
/

ALTER TABLE t_tax_run ADD (is_audited NVARCHAR2(10) DEFAULT 'Y')
/

CREATE TABLE rg_temp_1542056139_0 (
  id_acc NUMBER NOT NULL,
  id_usage_interval NUMBER NOT NULL,
  interval_start NUMBER,
  interval_end NUMBER,
  decision_unique_id VARCHAR2(400 BYTE) NOT NULL,
  decision_type VARCHAR2(4000 BYTE),
  start_date DATE,
  end_date DATE NOT NULL,
  rollover_end_date DATE,
  rollover_interval_end NUMBER,
  rolled_over_units NUMBER(18,6),
  expired_units NUMBER(18,6),
  rollover_date DATE,
  rollover_action VARCHAR2(25 BYTE) NOT NULL
)
/

INSERT INTO rg_temp_1542056139_0(id_acc,id_usage_interval,interval_start,interval_end,decision_unique_id,decision_type,start_date,end_date,rollover_end_date,rollover_interval_end,rolled_over_units,expired_units,rollover_date,rollover_action) SELECT id_acc,id_usage_interval,interval_start,interval_end,decision_unique_id,decision_type,start_date,end_date,rollover_end_date,rollover_interval_end,CAST(LEAST(rolled_over_units, 999999999999.999999) as NUMBER(18,6)),CAST(LEAST(expired_units, 999999999999.999999) as NUMBER(18,6)),rollover_date,'rollover' FROM agg_decision_rollover
/

DROP TABLE agg_decision_rollover
/

ALTER TABLE rg_temp_1542056139_0 RENAME TO agg_decision_rollover
/

ALTER TABLE agg_decision_rollover
ADD CONSTRAINT agg_dec_rollover_pk PRIMARY KEY (id_acc,id_usage_interval,end_date,decision_unique_id,rollover_action)
    USING INDEX (
        CREATE UNIQUE INDEX agg_dec_rollover_pk ON agg_decision_rollover(id_acc,id_usage_interval,end_date,decision_unique_id,rollover_action)
    )
/


ALTER TABLE mvm_resubmit_runs ADD (msg_count NUMBER(*,0),ss_count NUMBER(*,0),s_count NUMBER(*,0))
/

CREATE TABLE mvm_cluster_history (
  physical_cluster VARCHAR2(100 BYTE) NOT NULL,
  dt_started DATE NOT NULL,
  dt_stopped DATE
)
/

CREATE TABLE mvm_cluster_run_history (
  physical_cluster VARCHAR2(100 BYTE) NOT NULL,
  dt_started DATE NOT NULL,
  dt_stopped DATE,
  CONSTRAINT mvm_cluster_run_history_pk PRIMARY KEY (physical_cluster,dt_started)
)
/

CREATE TABLE agg_bundle_new_pos (
  id_po NUMBER
)
/

CREATE TABLE agg_bundle_old_pos (
  id_po NUMBER
)
/

DROP INDEX mvm_scheduled_tasks_ndx2
/

DROP INDEX mvm_scheduled_tasks_ndx1
/

DROP TABLE mvm_scheduled_tasks
/

DROP TABLE mvm_resubmitted_messages
/

CREATE INDEX agg_bundle_new_pos_ndx ON agg_bundle_new_pos(id_po)
/

CREATE INDEX agg_bundle_old_pos_ndx ON agg_bundle_old_pos(id_po)
/

CREATE INDEX acc_template_valid_subs_idx1 ON t_acc_template_valid_subs(id_acc_template_session,id_po)
/

CREATE INDEX acc_template_valid_subs_idx2 ON t_acc_template_valid_subs(id_acc_template_session,id_group)
/

CREATE TABLE metadata (
  timecreate DATE NOT NULL,
  "CONTENT" NCLOB NOT NULL,
  CONSTRAINT pk_metadata PRIMARY KEY (timecreate)
)
/

ALTER TABLE tmp_nrc DROP (c__collectionid)
/

ALTER TABLE tmp_newrw ADD (c__isallowgenchargebytrigger NUMBER(*,0))
/

/* WAS: is_implied NVARCHAR2(10) DEFAULT 'N', */
ALTER TABLE t_tax_details MODIFY (is_implied DEFAULT NULL)
/

CREATE GLOBAL TEMPORARY TABLE tmp_nrc_pos_for_run (
  id_po NUMBER(10)
)
ON COMMIT PRESERVE ROWS
/

CREATE GLOBAL TEMPORARY TABLE tmp_rc_pos_for_run (
  id_po NUMBER(10)
)
ON COMMIT PRESERVE ROWS
/

CREATE OR REPLACE FUNCTION RetrieveEnumCode
(
  enum_string VARCHAR2
)
RETURN INTEGER
IS
return_enum INTEGER;
BEGIN
  SELECT id_enum_data INTO return_enum
  FROM t_enum_data
  WHERE upper(nm_enum_data) = upper(enum_string);
  RETURN return_enum;
END;
/

/* New */
CREATE OR REPLACE FUNCTION
 prtn_GetMeterPartFileGroupName
 /*Full prtn_GetMeterPartitionFileGroupName function name uses in MSSQL*/
RETURN VARCHAR2
IS
	v_partitionname VARCHAR2(50);
BEGIN
 
	select user || '_MeterFileGroup'
    into v_partitionname from dual;
	
	return v_partitionname;
END;
/

/* New */
CREATE OR REPLACE FUNCTION CheckEBCRCycleTypeCompat ( EBCRCycleType INT,OtherCycleType INT )  RETURN INT
  AS
  BEGIN
    -- checks weekly based cycle types
    IF (((EBCRCycleType = 4) OR (EBCRCycleType = 5)) AND
      ((OtherCycleType = 4) OR (OtherCycleType = 5))) THEN
        RETURN 1;   -- success
    END IF;
    -- checks monthly based cycle types
    IF ((EBCRCycleType in (1,7,8,9)) AND
      (OtherCycleType  in (1,7,8,9))) THEN
        RETURN 1;   -- success
    END IF;

    RETURN 0;
  END;
/

CREATE OR REPLACE PROCEDURE GetAccountsWithPermission
  (
    AccountID IN NUMBER)
AS
  pathval   VARCHAR2(2000);
  accessval NUMBER(10,0);
  CURSOR cur
  IS
    SELECT '/1'
      || TO_CHAR(tpc.param_value) AS pathval,
      tec.param_value             AS accessval
    FROM
      (SELECT MAX(
        CASE
          WHEN tact.tx_progid = 'Metratech.MTPathCapability'
          THEN tci.id_cap_instance
          ELSE NULL
        END) AS pc_id ,
        MAX(
        CASE
          WHEN tact.tx_progid = 'Metratech.MTEnumTypeCapability'
          THEN tci.id_cap_instance
          ELSE NULL
        END) AS ec_id ,
        tci.id_policy ,
        tci.id_parent_cap_instance
      FROM t_capability_instance tci
      JOIN t_atomic_capability_type tact
      ON tci.id_cap_type                = tact.id_cap_type
      WHERE tci.id_parent_cap_instance IS NOT NULL
      GROUP BY tci.id_policy,
        tci.id_parent_cap_instance
      ) tmp
  JOIN t_path_capability tpc
  ON tpc.id_cap_instance = tmp.pc_id
  JOIN t_enum_capability tec
  ON tec.id_cap_instance = tmp.ec_id
  JOIN t_principal_policy tpp
  ON tpp.id_policy = tmp.id_policy
  WHERE tmp.pc_id IS NOT NULL
  AND tpp.id_acc   = AccountID;
  
  idx         NUMBER        :=1;
  Str         VARCHAR2(2000):= NULL;
  Slice       VARCHAR2(2000):= NULL;
  Lst         VARCHAR2(2000):= NULL;
  accessLevel NUMBER;
  accID       NUMBER;
  isSuperUser NUMBER;
BEGIN
  DELETE FROM TMP_ACC_PERMISSION;
  DELETE FROM TMP_ACC_PERMISSION_GROUPED;
  
  SELECT COUNT(*)
  INTO isSuperUser
  FROM t_principal_policy pp
	JOIN t_policy_role pr on pp.id_policy = pr.id_policy AND pp.id_acc = AccountID
	JOIN t_role r on pr.id_role = r.id_role AND r.tx_name = 'Super User';
  
  IF isSuperUser <> 0 THEN
	  RETURN;
  END IF;
  
  OPEN cur;
  LOOP
    FETCH cur INTO pathval, accessval;
    
    EXIT
  WHEN cur%NOTFOUND;
    idx := 1;
    Str       := pathval;
    WHILE idx <> 0
    LOOP
      idx     := INSTR(Str, '/', 1);
      IF idx  <> 0 THEN
        Slice := SUBSTR(Str,1, idx - 1);
      ELSE
        Slice := Str;
      END IF;
      dbms_output.put_line('Slice=' || Slice);
      IF Slice       = '-' THEN
        accessLevel := 2;
        accID       := CAST(Lst AS NUMBER);
      END IF;
      IF Slice       = '*' THEN
        accessLevel := 1;
        accID       := CAST(Lst AS NUMBER);
      END IF;
      IF Slice      IS NULL AND (Str IS NULL OR LENGTH(Str) <> LENGTH(pathval)) THEN
        accessLevel := 0;
        accID       := CAST(Lst AS NUMBER);
      END IF;
      IF Slice NOT IN ('-', '*') AND Slice IS NOT NULL THEN
        INSERT
        INTO TMP_ACC_PERMISSION
          (
            AccountID,
            Permission
          )
          VALUES
          (
            CAST(Slice AS NUMBER),
            1
          );
      END IF;
      IF Slice IS NOT NULL THEN
        Lst := Slice;
      END IF;
      Str := SUBSTR(Str,idx+1);
    END LOOP;
    INSERT
    INTO TMP_ACC_PERMISSION
      (
        AccountID,
        Permission
      )
      VALUES
      (
        accID,
        accessval
      );
    INSERT INTO TMP_ACC_PERMISSION
      (AccountID, Permission
      )
    SELECT id_descendent,
      accessval
    FROM t_account_ancestor
    WHERE id_ancestor  = accID
    AND accessLevel    > 0
    AND (accessLevel   = 2
    OR num_generations = 1);
  END LOOP;
  CLOSE cur;
  INSERT INTO TMP_ACC_PERMISSION_GROUPED
    (AccountID, WritePermission
    )
  SELECT t1.AccountID ,
    CASE
      WHEN Perm > 2
      THEN 1
      ELSE 0
    END
  FROM
    (SELECT AccountID,
      MAX(Permission) AS Perm
    FROM TMP_ACC_PERMISSION
    GROUP BY AccountID
    ) t1;
  
END;
/

CREATE PROCEDURE mvm_create_uk_table(
    p_table  VARCHAR2,           -- table to bulk update
    p_prefix VARCHAR2,           -- prefix on blk_upd_table name
    p_mvm_run_id NUMBER,           --  identifier of mvm run
    p_node_id VARCHAR2,           --  identifier of mvm node_id
    p_tmp_table OUT VARCHAR2 -- table we created
  )
AS
  CURSOR cur_columns
  IS
    -- RAW needs 1 added to datalength to work around OracleBulkCopy bug:
    -- http://forums.oracle.com/forums/thread.jspa?threadID=968824
    SELECT column_name
      ||' '
      ||data_type
      || DECODE(data_type,'NUMBER',DECODE(data_precision, NULL, '','('
      ||data_precision
      ||','
      ||data_scale
      ||')'),'CHAR','('
      ||data_length
      ||')','VARCHAR2','('
      ||data_length
      ||')','NVARCHAR2','('
      ||char_length
      ||')','RAW','('
      ||(data_length+1)
      ||')',' ') col_string
    FROM user_tab_columns a
    WHERE table_name = upper(p_table) and column_name not in('ID_USAGE_INTERVAL', 'ID_SESS', 'TX_UID')
    ORDER BY column_id;
  CURSOR au_columns
  IS
    -- RAW needs 1 added to datalength to work around OracleBulkCopy bug:
    -- http://forums.oracle.com/forums/thread.jspa?threadID=968824
    SELECT column_name
      ||' '
      ||data_type
      || DECODE(data_type,'NUMBER',DECODE(data_precision, NULL, '','('
      ||data_precision
      ||','
      ||data_scale
      ||')'),'CHAR','('
      ||data_length
      ||')','VARCHAR2','('
      ||data_length
      ||')','NVARCHAR2','('
      ||char_length
      ||')','RAW','('
      ||(data_length+1)
      ||')',' ') col_string
    FROM user_tab_columns a
    WHERE table_name = upper('T_ACC_USAGE') and column_name = 'TX_UID'
    ORDER BY column_id;
  sql_stmt LONG;
  v_col_string VARCHAR2(4000);
  v_curr_count NUMBER;
  field_prefix VARCHAR2(4000);
  temp_prefix  VARCHAR2(1000);
BEGIN
  -- name of tmp bulk update table
   mvm_generate_table_name(p_prefix, p_tmp_table);
   
  -- create statement
  sql_stmt     := 'create table '||p_tmp_table||' (';
  field_prefix := '';
  FOR v_rec    IN au_columns
  LOOP
    sql_stmt     := sql_stmt||field_prefix||' '||v_rec.col_string;
    field_prefix := ',';
  END LOOP;
  FOR v_rec    IN cur_columns
  LOOP
    sql_stmt     := sql_stmt||field_prefix||' '||v_rec.col_string;
    field_prefix := ',';
  END LOOP;

  
  --end the create
  sql_stmt := sql_stmt||')';
  dbms_output.put_line(sql_stmt);
  EXECUTE IMMEDIATE (sql_stmt);
  insert into amp_staging_tables (mvm_run_id, node_id, staging_table_name, create_dt) values(p_mvm_run_id, p_node_id, p_tmp_table, SYSDATE);
END;
/

CREATE OR REPLACE FORCE VIEW account_qualification_groups (account_qualification_group,row_num,"INCLUDE",include_filter,source_field,target_field,output_field,append_to_list,"FILTER") AS
select
        a.c_Name as account_qualification_group,
        b.c_ExecutionSequence as row_num,
        b.c_Include as include,
        b.c_IncludeFilter as include_filter,
        b.c_SourceField as source_field,
        b.c_MatchField as target_field,
        b.c_OutputField as output_field,
        CASE WHEN b.c_AppendRows = 0 THEN 'no' ELSE 'yes' END as append_to_list,
        b.c_Filter as filter
        from t_amp_accountqualgro a
        left outer join t_amp_accountqualifi b on a.c_AccountQualGroup_Id = b.c_AccountQualGroup_Id;
/

/* New */
CREATE OR REPLACE PROCEDURE arch_q_p_next_part_single_tab(
	p_table_name			VARCHAR2,
	p_id_partition			INT,
	p_tablespace_name		VARCHAR2,
	p_partition_field_name	VARCHAR2
)
AUTHID CURRENT_USER
AS
    sql_command				VARCHAR2(1000);
    partition_name			VARCHAR2(100);
BEGIN
	partition_name := 'p' || p_id_partition;

    DBMS_OUTPUT.PUT_LINE(
    'Applying next partition for "' || p_table_name || '" table');

    sql_command :=    ' ALTER TABLE ' || p_table_name
                   || ' ADD PARTITION ' || partition_name
                   || ' VALUES ('|| p_id_partition ||')'
                   || ' TABLESPACE ' || p_tablespace_name;
    EXECUTE IMMEDIATE sql_command;

    sql_command :=   ' ALTER TABLE ' || p_table_name
                  || ' MODIFY ' || p_partition_field_name
                  || ' DEFAULT ' || p_id_partition;
    EXECUTE IMMEDIATE sql_command;

END;
/

/* New */
CREATE OR REPLACE PROCEDURE arch_q_p_rollback_single_tab(
    p_table_name			VARCHAR2,
    p_id_partition			INT,
    p_partition_field_name	VARCHAR2
)
AUTHID CURRENT_USER
AS
    sql_command				VARCHAR2(1000);
    part_name				VARCHAR2(100);
    is_partition_exists		INT;
BEGIN
    part_name := 'P' || p_id_partition;

    DBMS_OUTPUT.PUT_LINE('Rollback next partition for "' || p_table_name || '" table');

    sql_command :=   ' ALTER TABLE ' || p_table_name
                    || ' MODIFY ' || p_partition_field_name
                    || ' DEFAULT ' || (p_id_partition - 1);
    EXECUTE IMMEDIATE sql_command;

	SELECT COUNT(1) INTO is_partition_exists
	FROM   user_tab_partitions
	WHERE  table_name = UPPER(p_table_name)
		   AND partition_name = part_name;

	IF is_partition_exists > 0 THEN

		sql_command :=   ' ALTER TABLE ' || p_table_name || ' ENABLE ROW movement';
		EXECUTE IMMEDIATE sql_command;

		sql_command :=     ' UPDATE ' || p_table_name
						|| ' PARTITION (' || part_name || ')'
						|| ' SET ' || p_partition_field_name || ' = ' || (p_id_partition - 1);
		EXECUTE IMMEDIATE sql_command;

		sql_command :=   ' ALTER TABLE ' || p_table_name || ' DISABLE ROW movement';
		EXECUTE IMMEDIATE sql_command;

		sql_command :=    ' ALTER TABLE ' || p_table_name
					   || ' DROP PARTITION ' || part_name;
		EXECUTE IMMEDIATE sql_command;
	END IF;

END;
/

/* New */
CREATE OR REPLACE PROCEDURE arch_q_p_rollback_next_prtn(
    p_id_partition			INT,
    p_partition_field_name	VARCHAR2
)
AUTHID CURRENT_USER
AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Exception occured on execution "arch_q_p_apply_next_partition" SP. Rollback newly created partition...');

    DELETE FROM t_archive_queue_partition
	WHERE current_id_partition = p_id_partition;

    FOR x IN (  SELECT   nm_table_name
                FROM     t_service_def_log
                ORDER BY nm_table_name)
    LOOP
        arch_q_p_rollback_single_tab(
            P_TABLE_NAME => x.nm_table_name,
            P_ID_PARTITION => p_id_partition,
            P_PARTITION_FIELD_NAME => p_partition_field_name);
    END LOOP;

    arch_q_p_rollback_single_tab(
        P_TABLE_NAME => 't_message',
        P_ID_PARTITION => p_id_partition,
        P_PARTITION_FIELD_NAME => p_partition_field_name);

    arch_q_p_rollback_single_tab(
        P_TABLE_NAME => 't_session',
        P_ID_PARTITION => p_id_partition,
        P_PARTITION_FIELD_NAME => p_partition_field_name);

    arch_q_p_rollback_single_tab(
        P_TABLE_NAME => 't_session_set',
        P_ID_PARTITION => p_id_partition,
        P_PARTITION_FIELD_NAME => p_partition_field_name);

    arch_q_p_rollback_single_tab(
        P_TABLE_NAME => 't_session_state',
        P_ID_PARTITION => p_id_partition,
        P_PARTITION_FIELD_NAME => p_partition_field_name);

EXCEPTION
  WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE( 'Rollback of newly created partition is failed.
This tasks should be done manually for t_session, t_session_set, t_session_state,t_message and all t_svc_* tables:
1. Ensure Default values of "id_partition" field is "' || (p_id_partition - 1) || '";
2. Drop partition "P' || p_id_partition || '" with moving data to partition "P' || p_id_partition || '";
3. Run: DELETE FROM t_archive_queue_partition WHERE current_id_partition = '|| p_id_partition);
	RAISE;
END;
/

/* New */
CREATE OR REPLACE PROCEDURE arch_q_p_apply_next_partition(
    p_new_current_id_partition		INT,
    p_current_time					DATE,
    p_meter_tablespace_name			VARCHAR2,
    p_meter_partition_field_name	VARCHAR2
)
AUTHID CURRENT_USER
AS
BEGIN
    
    DBMS_OUTPUT.PUT_LINE(
    'Begin execution of "archive_queue_partition_apply_next_partition"...');

    FOR x IN (  SELECT   nm_table_name
                FROM     t_service_def_log
                ORDER BY nm_table_name)
    LOOP
        arch_q_p_next_part_single_tab(
            P_TABLE_NAME => x.nm_table_name,
            P_ID_PARTITION => p_new_current_id_partition,
            P_TABLESPACE_NAME => p_meter_tablespace_name,
            P_PARTITION_FIELD_NAME => p_meter_partition_field_name);
    END LOOP;

    arch_q_p_next_part_single_tab(
        P_TABLE_NAME => 't_message',
        P_ID_PARTITION => p_new_current_id_partition,
        P_TABLESPACE_NAME => p_meter_tablespace_name,
        P_PARTITION_FIELD_NAME => p_meter_partition_field_name);

    arch_q_p_next_part_single_tab(
        P_TABLE_NAME => 't_session_set',
        P_ID_PARTITION => p_new_current_id_partition,
        P_TABLESPACE_NAME => p_meter_tablespace_name,
        P_PARTITION_FIELD_NAME => p_meter_partition_field_name);

    arch_q_p_next_part_single_tab(
        P_TABLE_NAME => 't_session',
        P_ID_PARTITION => p_new_current_id_partition,
        P_TABLESPACE_NAME => p_meter_tablespace_name,
        P_PARTITION_FIELD_NAME => p_meter_partition_field_name);

    arch_q_p_next_part_single_tab(
        P_TABLE_NAME => 't_session_state',
        P_ID_PARTITION => p_new_current_id_partition,
        P_TABLESPACE_NAME => p_meter_tablespace_name,
        P_PARTITION_FIELD_NAME => p_meter_partition_field_name);

    /* Update Default id_partition in [t_archive_queue_partition] table */
    INSERT INTO t_archive_queue_partition
    VALUES
      (
        p_new_current_id_partition,
        p_current_time,
        NULL
      );
    
    EXCEPTION
      WHEN OTHERS THEN
        arch_q_p_rollback_next_prtn(
			P_ID_PARTITION => p_new_current_id_partition,
			P_PARTITION_FIELD_NAME => p_meter_partition_field_name);
		RAISE;
END;
/

/* New */
CREATE OR REPLACE PROCEDURE arch_q_p_drop_temp_tables(
	p_old_id_partition	INT
)
authid current_user
AS
    preserved_partition	INT	:= p_old_id_partition - 1;
	v_temp_tab_name		VARCHAR2(30);
    cur_keep_sess_tabs	SYS_REFCURSOR;
BEGIN
	DBMS_OUTPUT.put_line ('Dropping of temp.tables with switched out Meter data...');

    OPEN cur_keep_sess_tabs FOR 'SELECT TEMP_TAB_NAME FROM tt_tab_names_with_sess_to_keep';
    LOOP
		FETCH cur_keep_sess_tabs INTO v_temp_tab_name;
		EXIT WHEN cur_keep_sess_tabs%NOTFOUND;

		/* Drop table with exchanged data of 'Old' partition */
		EXECUTE IMMEDIATE 'DROP TABLE ' || v_temp_tab_name;
    END LOOP;
	CLOSE cur_keep_sess_tabs;

	DBMS_OUTPUT.put_line ('Switched out Meter data was dropped.');
END;
/

/* New */
CREATE OR REPLACE PROCEDURE arch_q_p_get_id_sess_to_keep(
	p_old_id_partition		INT
)
AUTHID CURRENT_USER
AS
	max_time				DATE	:= dbo.mtmaxdate();
	preserved_id_partition	INT		:= p_old_id_partition - 1;
	sql_stmt				VARCHAR2(4000);
	sess_count				INT;
BEGIN

	DBMS_OUTPUT.PUT_LINE('Starting population of "tt_id_sess_to_keep" table...');

	BEGIN
		EXECUTE IMMEDIATE 'DROP TABLE tt_id_sess_to_keep';
	EXCEPTION
	  WHEN OTHERS THEN
		IF SQLCODE != -942 THEN
			RAISE;
		END IF;
	END;

	sql_stmt := 'CREATE TABLE tt_id_sess_to_keep AS
		SELECT DISTINCT(id_sess)
		FROM t_session_state st
		WHERE  st.id_partition IN (' || p_old_id_partition || ', ' || preserved_id_partition || ')
			AND tx_state IN (''F'', ''R'')
			AND dt_end = TO_TIMESTAMP('''
			|| TO_CHAR(max_time, 'dd/mm/yyyy hh24:mi')
			|| ''', ''dd/mm/yyyy hh24:mi'')';

	-- dbms_output.put_line( sql_stmt );
	EXECUTE IMMEDIATE sql_stmt;

	sql_stmt := 'INSERT INTO tt_id_sess_to_keep
	SELECT sess.id_source_sess
	FROM   t_session sess
	WHERE  sess.id_partition IN ('|| p_old_id_partition || ', ' || preserved_id_partition || ')
		   AND NOT EXISTS (
				   SELECT 1
				   FROM   t_session_state st
				   WHERE  st.id_partition IN (' || p_old_id_partition || ', ' || preserved_id_partition || ')
						  AND st.id_sess = sess.id_source_sess
			   )';

	-- dbms_output.put_line( sql_stmt );
	EXECUTE IMMEDIATE sql_stmt;

	sql_stmt := 'INSERT INTO tt_id_sess_to_keep
	SELECT DISTINCT(ts.id_source_sess)
	FROM   t_usage_interval ui
		   JOIN t_acc_usage au
				ON  au.id_usage_interval = ui.id_interval
		   JOIN t_session ts
				ON  ts.id_source_sess = au.tx_UID
	WHERE  ts.id_partition IN (' || p_old_id_partition || ', ' || preserved_id_partition || ')
		   AND ui.tx_interval_status <> ''H''';

	-- dbms_output.put_line( sql_stmt );
	EXECUTE IMMEDIATE sql_stmt;

	EXECUTE IMMEDIATE 'CREATE INDEX pk_tt_id_sess_to_keep ON tt_id_sess_to_keep(id_sess)';

	EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM tt_id_sess_to_keep' INTO sess_count;

	DBMS_OUTPUT.PUT_LINE('Population of "tt_id_sess_to_keep" table finished. ');
	DBMS_OUTPUT.PUT_LINE( sess_count || ' sessions of partitions P' || preserved_id_partition || ' and P' || p_old_id_partition
		|| ' will be preserved in partition P' || p_old_id_partition);
END;
/

/* New */
CREATE OR REPLACE PROCEDURE arch_q_p_get_status(
    p_current_time                    DATE,
    p_next_allow_run_time       OUT   DATE,
    p_current_id_partition      OUT   INT,
    p_new_current_id_partition  OUT   INT,
    p_old_id_partition          OUT   INT,
    p_no_need_to_run            OUT   INT
)
AUTHID CURRENT_USER
AS
    message			VARCHAR2(4000);
    is_data_exist	INT;
BEGIN

    p_no_need_to_run := 0;
    
    SELECT COUNT(1) INTO is_data_exist FROM t_archive_queue_partition WHERE ROWNUM = 1;
    IF is_data_exist = 0 THEN
        raise_application_error(-20000, 't_archive_queue_partition must contain at least one record.
Try to execute "USM CREATE" command in cmd.
First record inserts to this table on creation of Partition Infrastructure for metering tables');
    END IF;
    
    SELECT MAX(current_id_partition)
	INTO p_current_id_partition
    FROM    t_archive_queue_partition;
    
    SELECT next_allow_run
	INTO p_next_allow_run_time
    FROM t_archive_queue_partition
    WHERE current_id_partition = p_current_id_partition;
    
    IF p_next_allow_run_time IS NOT NULL THEN
		BEGIN
			/* Period of full partition cycle should pass since last execution of [archive_queue_partition] */
			IF p_current_time < p_next_allow_run_time THEN
			BEGIN
				p_no_need_to_run := 1;
				DBMS_OUTPUT.PUT_LINE('No need to run archive functionality. '
					|| 'Time of cycle period not elapsed yet since the last run. '
					|| 'Try execute the procedure after "'
					|| p_next_allow_run_time || '" date.');
			END;
			END IF;

			p_new_current_id_partition  := p_current_id_partition + 1;
			p_old_id_partition          := p_current_id_partition - 1;
		END;
    ELSE
		BEGIN
			DBMS_OUTPUT.PUT_LINE('Warning: previouse execution of [archive_queue_partition] failed.
The oldest partition was not archived, but new data already written to new partition with ID: "'
|| p_current_id_partition || '".
Retrying archivation of the oldest partition...');

			p_new_current_id_partition  := p_current_id_partition;
			p_current_id_partition      := p_new_current_id_partition - 1;
			p_old_id_partition          := p_new_current_id_partition - 2;
		END;
    END IF;
END;
/

/* New */
CREATE OR REPLACE PROCEDURE arch_q_p_clone_ind_and_cons(
	source_table		VARCHAR2,
	destination_tables	str_tab
)
authid current_user
AS
	pk_ddl				str_tab;
	uc_ddl				str_tab;
	idx_ddl				str_tab;
	random_string		VARCHAR2(10);
	sql_stmt			VARCHAR2(4000);
BEGIN

	/* Get ddl for all indexes from source table. */
	SELECT	'create '
		|| DECODE(uniqueness, 'NONUNIQUE', ' ', 'UNIQUE')
		|| ' index ' || SUBSTR(index_name, 0, 20) || ':2 '
		|| ' on :1 '
		|| ' ('
		|| LISTAGG(column_name, ',') WITHIN GROUP (ORDER BY column_position)
		|| ')'
	BULK COLLECT INTO idx_ddl
		FROM (
                SELECT uic.index_name,
                       column_name,
                       column_position,
					   ui.uniqueness
                FROM   user_ind_columns uic
                       JOIN user_indexes ui
                            ON  uic.index_name = ui.index_name
                WHERE  LOWER(uic.table_name) = LOWER(source_table)
                ORDER BY uic.index_name
		)
	GROUP BY index_name, uniqueness;

	/* Get primary key constraint ddl from source table */
	SELECT	'alter table :1 '
		|| ' add constraint ' || SUBSTR(constraint_name, 0, 20) || ':2 '
		|| ' primary key ('
		|| LISTAGG(column_name, ',') WITHIN GROUP (ORDER BY POSITION)
		|| ')'
	BULK COLLECT INTO pk_ddl
	FROM (
	         SELECT uc.constraint_name,
	                column_name,
					POSITION
	         FROM   user_cons_columns ucc
	                JOIN user_constraints uc
	                     ON  uc.constraint_name = ucc.constraint_name
	         WHERE  constraint_type = 'P'
	                AND LOWER(uc.table_name) = LOWER(source_table)
	     )
	GROUP BY constraint_name;

	/* Get unique constraint ddl from source table */
	SELECT	'alter table :1 '
		|| ' add constraint ' || SUBSTR(constraint_name, 0, 20) || ':2 '
		|| ' unique ('
		|| LISTAGG(column_name, ',') WITHIN GROUP (ORDER BY POSITION)
		|| ')'
	BULK COLLECT INTO uc_ddl
	FROM (
	         SELECT uc.constraint_name,
	                column_name,
					POSITION
	         FROM   user_cons_columns ucc
	                JOIN user_constraints uc
	                     ON  uc.constraint_name = ucc.constraint_name
	         WHERE  constraint_type = 'U'
	                AND LOWER(uc.table_name) = LOWER(source_table)
	     )
	GROUP BY constraint_name;

	FOR i_tab IN destination_tables.FIRST .. destination_tables.LAST
	LOOP
		random_string := DBMS_RANDOM.string('x',10);

		DBMS_OUTPUT.put_line('		Clonning all indexes...');
		IF idx_ddl.FIRST IS NOT NULL
		THEN
		  FOR ix IN idx_ddl.FIRST .. idx_ddl.LAST
		  LOOP
			 sql_stmt := idx_ddl (ix);
			 SELECT REPLACE(sql_stmt, ':1', destination_tables(i_tab)) INTO sql_stmt FROM dual;
			 SELECT REPLACE(sql_stmt, ':2', random_string) INTO sql_stmt FROM dual;
			 DBMS_OUTPUT.put_line ('  ' || sql_stmt);
			 EXECUTE IMMEDIATE sql_stmt;
		  END LOOP;
		END IF;

		DBMS_OUTPUT.put_line('		Clonning primary key...');
		IF pk_ddl.FIRST IS NOT NULL
		THEN
		  FOR ix IN pk_ddl.FIRST .. pk_ddl.LAST
		  LOOP
			 sql_stmt := pk_ddl (ix);
			 SELECT REPLACE(sql_stmt, ':1', destination_tables(i_tab)) INTO sql_stmt FROM dual;
			 SELECT REPLACE(sql_stmt, ':2', random_string) INTO sql_stmt FROM dual;
			 DBMS_OUTPUT.put_line ('  ' || sql_stmt);
			 EXECUTE IMMEDIATE sql_stmt;
		  END LOOP;
		END IF;

		DBMS_OUTPUT.put_line('		Clonning unique constraints...');
		IF uc_ddl.FIRST IS NOT NULL
		THEN
		  FOR ix IN uc_ddl.FIRST .. uc_ddl.LAST
		  LOOP
			 sql_stmt := uc_ddl (ix);
			 SELECT REPLACE(sql_stmt, ':1', destination_tables(i_tab)) INTO sql_stmt FROM dual;
			 SELECT REPLACE(sql_stmt, ':2', random_string) INTO sql_stmt FROM dual;
			 DBMS_OUTPUT.put_line ('  ' || sql_stmt);
			 EXECUTE IMMEDIATE sql_stmt;
		  END LOOP;
		END IF;

	END LOOP;
END;
/

/* New */
CREATE OR REPLACE PROCEDURE arch_q_p_prep_sess_to_keep_tab(
	p_old_partition					INT,
	p_table_name					VARCHAR2,
	table_with_sess_to_keep			VARCHAR2
)
AUTHID CURRENT_USER
AS
	preserved_partition				INT := p_old_partition - 1;
	WHERE_clause_for_sess_to_keep	VARCHAR2(1000);
	sqlCommand						VARCHAR2(4000);
BEGIN

	IF p_table_name = 'T_SESSION_SET' THEN
		WHERE_clause_for_sess_to_keep  :=
		' WHERE  tab.id_ss IN (SELECT s.id_ss
							FROM   tt_id_sess_to_keep t
								JOIN t_session s
									ON  s.id_source_sess = t.id_sess)';
	ELSIF p_table_name = 'T_SESSION_STATE' THEN
		WHERE_clause_for_sess_to_keep  :=
		' WHERE tab.id_sess IN (SELECT t.id_sess
			FROM   tt_id_sess_to_keep t)';
	ELSIF p_table_name = 'T_MESSAGE' THEN
		WHERE_clause_for_sess_to_keep  :=
		' WHERE tab.id_message IN (SELECT ss.id_message
								FROM   t_session_set ss
									   JOIN t_session s
											ON  s.id_ss = ss.id_ss
									   JOIN tt_id_sess_to_keep t
											ON  s.id_source_sess = t.id_sess)';
	/* For T_SESSION and all T_SVC_* tables using default WHERE clause */
	ELSE
		WHERE_clause_for_sess_to_keep  :=
		' WHERE tab.id_source_sess IN (SELECT t.id_sess
		   FROM   tt_id_sess_to_keep t)';
	END IF;
	
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE ' || table_with_sess_to_keep;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
    END;
	
	DBMS_OUTPUT.PUT_LINE('	Preparing "' || table_with_sess_to_keep || '" for EXCHANGE PARTITION operation...');
    /* Create temp table for storing sessions that should not be deleted */
    sqlCommand :=  'CREATE TABLE ' || table_with_sess_to_keep
                || ' AS SELECT * FROM ' || p_table_name || ' tab '
				|| WHERE_clause_for_sess_to_keep
                || ' AND id_partition = ' || preserved_partition;
    EXECUTE IMMEDIATE sqlCommand;

    sqlCommand :=  'UPDATE ' || table_with_sess_to_keep
                || ' SET id_partition =  ' || p_old_partition;
    EXECUTE IMMEDIATE sqlCommand;

    sqlCommand :=  'INSERT INTO ' || table_with_sess_to_keep
                || ' SELECT * FROM ' || p_table_name || ' tab '
				|| WHERE_clause_for_sess_to_keep
                || ' AND id_partition = ' || p_old_partition;
    EXECUTE IMMEDIATE sqlCommand;

	arch_q_p_clone_ind_and_cons(
		SOURCE_TABLE => p_table_name,
		DESTINATION_TABLES => str_tab( table_with_sess_to_keep ) );
END;
/

CREATE OR REPLACE PROCEDURE arch_q_p_prep_all_keep_ses_tab(
	p_old_id_partition	INT
)
AUTHID CURRENT_USER
AS
	v_tab_name			VARCHAR2(30);
	v_temp_tab_name		VARCHAR2(30);
    cur_keep_sess_tabs	SYS_REFCURSOR;
	old_part_row_count	INT := 0;
	pres_part_row_count	INT := 0;
	kept_row_count		INT := 0;
	rows_to_archive		INT := 0;
BEGIN

	DBMS_OUTPUT.put_line ('Preparation of table that will bind meter table names with auto-generated unique temp-table names...');
	LOOP
		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE tt_tab_names_with_sess_to_keep';
		EXCEPTION
		  WHEN OTHERS THEN
			IF SQLCODE != -942 THEN
				RAISE;
			END IF;
		END;

		EXECUTE IMMEDIATE 'CREATE TABLE tt_tab_names_with_sess_to_keep
		AS
		SELECT UPPER(nm_table_name) TAB_NAME, SUBSTR(UPPER(nm_table_name), 0, 20) || DBMS_RANDOM.string(''x'',10) TEMP_TAB_NAME
		FROM t_service_def_log
		UNION ALL
		SELECT ''T_SESSION'', ''T_SESSION'' || DBMS_RANDOM.string(''x'',10) FROM dual
		UNION ALL
		SELECT ''T_SESSION_SET'', ''T_SESSION_SET'' || DBMS_RANDOM.string(''x'',10) FROM dual
		UNION ALL
		SELECT ''T_SESSION_STATE'', ''T_SESSION_STATE'' || DBMS_RANDOM.string(''x'',10) FROM dual
		UNION ALL
		SELECT ''T_MESSAGE'', ''T_MESSAGE'' || DBMS_RANDOM.string(''x'',10) FROM dual';

		/* Ensure auto-generated names are unique */
		BEGIN
			EXECUTE IMMEDIATE'ALTER TABLE tt_tab_names_with_sess_to_keep ADD CONSTRAINT cons_check_unique UNIQUE (TEMP_TAB_NAME)';
			EXECUTE IMMEDIATE'ALTER TABLE tt_tab_names_with_sess_to_keep DROP CONSTRAINT cons_check_unique';
			EXIT;
		EXCEPTION
		  WHEN OTHERS THEN
			IF SQLCODE != -2299 THEN
				RAISE;
			END IF;
			/* Recreate "tt_tab_names_with_sess_to_keep" if "TEMP_TAB_NAME" is not unique */
		END;
    END LOOP;

	DBMS_OUTPUT.put_line ('Preparation of temp tables with sessions to keep...');

    OPEN cur_keep_sess_tabs FOR 'SELECT TAB_NAME, TEMP_TAB_NAME FROM tt_tab_names_with_sess_to_keep';
    LOOP
		FETCH cur_keep_sess_tabs INTO v_tab_name, v_temp_tab_name;
		EXIT WHEN cur_keep_sess_tabs%NOTFOUND;

		arch_q_p_prep_sess_to_keep_tab(
			p_old_partition => p_old_id_partition,
			p_table_name => v_tab_name,
			table_with_sess_to_keep => v_temp_tab_name );

		EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_temp_tab_name INTO kept_row_count;
		EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_name || ' PARTITION (P' || p_old_id_partition || ')' INTO old_part_row_count;

		BEGIN
			EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_name || ' PARTITION (P' || (p_old_id_partition - 1) || ')' INTO pres_part_row_count;
		EXCEPTION
		  WHEN OTHERS THEN
			/* Ignore exception "ORA-02149: Specified partition does not exist" */
			IF SQLCODE != -2149 THEN
				RAISE;
			END IF;
		END;

		rows_to_archive := (old_part_row_count + pres_part_row_count) - kept_row_count;
		DBMS_OUTPUT.put_line ('<' || rows_to_archive || '> rows should be archived from "' || v_tab_name || '" table.');

    END LOOP;
	CLOSE cur_keep_sess_tabs;

	DBMS_OUTPUT.put_line ('All temp tables with sessions to keep prepared.');
END;
/

CREATE OR REPLACE PROCEDURE arch_q_p_switch_out_part_all(
	p_old_id_partition	INT
)
authid current_user
AS
    preserved_partition	INT	:= p_old_id_partition - 1;
	v_tab_name			VARCHAR2(30);
	v_temp_tab_name		VARCHAR2(30);
    cur_keep_sess_tabs	SYS_REFCURSOR;
BEGIN
	DBMS_OUTPUT.put_line ('Starting switching out old data for all Meter tables...');

    OPEN cur_keep_sess_tabs FOR 'SELECT TAB_NAME, TEMP_TAB_NAME FROM tt_tab_names_with_sess_to_keep';
    LOOP
		FETCH cur_keep_sess_tabs INTO v_tab_name, v_temp_tab_name;
		EXIT WHEN cur_keep_sess_tabs%NOTFOUND;

		/* EXCHANGE 'Old' partition and table with sessions to keep ('Old' becomes a new 'Preserved' partition) */
		DBMS_OUTPUT.PUT_LINE('	Processing "' || v_tab_name || '"...');
		EXECUTE IMMEDIATE 'ALTER TABLE ' || v_tab_name
						|| ' EXCHANGE PARTITION P' || p_old_id_partition
						|| ' WITH TABLE ' || v_temp_tab_name
						|| ' INCLUDING INDEXES '
						|| ' WITHOUT VALIDATION';

		/* Drop old 'Preserved' partition. As it's data was copied to next 'Preserved' partition or going to be archived.*/
		BEGIN
			EXECUTE IMMEDIATE 'ALTER TABLE ' || v_tab_name || ' DROP PARTITION P' || preserved_partition;
		EXCEPTION
		  WHEN OTHERS THEN
			/* Ignore exception "ORA-02149: Specified partition does not exist" */
			IF SQLCODE != -2149 THEN
				RAISE;
			END IF;
		END;
    END LOOP;
	CLOSE cur_keep_sess_tabs;

	DBMS_OUTPUT.put_line ('Old data was switched out from all Meter tables.');
END;
/

CREATE OR REPLACE PROCEDURE prtn_get_next_allow_run_date(
	current_datetime DATE DEFAULT SYSDATE,
	next_allow_run_date OUT DATE)
AS
    days_to_add INT;
BEGIN
	
	SELECT tuc.n_proration_length INTO days_to_add
	FROM   t_usage_server tus
	       INNER JOIN t_usage_cycle_type tuc
	            ON  tuc.tx_desc = tus.partition_type;
	
	next_allow_run_date := current_datetime + days_to_add;
	
END;
/

CREATE OR REPLACE PROCEDURE PausePipelineProcessing(
    p_state INT
)
authid current_user
AS
    v_status INT := CASE p_state WHEN 0 THEN 0 ELSE 1 END; /* ensure only 0 or 1 is a valid status */
    v_timeout INT := 0;
    v_pipline_processing int := 1;
BEGIN
    
    UPDATE t_pipeline SET b_paused = v_status;
    COMMIT;
    
    WHILE ((v_pipline_processing > 0) AND (v_status = 1)) LOOP
     SELECT COUNT(*)
     INTO v_pipline_processing
     FROM t_pipeline
     WHERE b_processing = 1;
     
        IF v_timeout > 12 THEN /* wait up to 2 minutes for pipeline state */
            raise_application_error (-20002, 'Unable to pause pipeline. Try to do it manually.');
        END IF;

        DBMS_LOCK.SLEEP(10);
        v_timeout := v_timeout + 1;
    END LOOP;
    
    /* silently let the process continue if we exceed 2 minutes to let core processes run */
END;
/

CREATE OR REPLACE PROCEDURE archive_queue_partition(
    p_update_stats		VARCHAR2 DEFAULT 'N',
    p_sampling_ratio	VARCHAR2 DEFAULT '30',
    p_current_time		DATE DEFAULT NULL,
    p_result		OUT VARCHAR2
)
AUTHID CURRENT_USER
AS
    /* This SP is called from from basic SP - [archive_queue] if DB is partitioned */

    /*
    How to run this stored procedure:   
	DECLARE
		v_result VARCHAR2(2000);
	BEGIN
		archive_queue_partition ( p_result => v_result );
		DBMS_OUTPUT.put_line (v_result);
	END;
    
    Or if we want to update statistics and change current date/time also:   
    DECLARE 
        v_result            VARCHAR2(2000),
        v_current_time  DATE
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
    v_current_time				DATE;
    v_next_allow_run_time		DATE;
    v_current_id_partition		INT;
    v_new_current_id_partition	INT;
    v_old_id_partition			INT;
    v_no_need_to_run			INT;
    v_meter_tablespace_name		VARCHAR2(50);
    v_count_records				INT;
	v_time_count				NUMBER;
	
BEGIN
    
    /* Force using single processor's core */
	EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DDL';
	EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL DML';
	EXECUTE IMMEDIATE 'ALTER SESSION DISABLE PARALLEL QUERY';
	
    SELECT UPPER(b_partitioning_enabled) INTO v_is_part_enabled FROM t_usage_server;
    /* Nothing to do if system isn't enabled for partitioning */
    IF v_is_part_enabled <> 'Y' THEN
        dbms_output.put_line('Partitioning is not enabled, so can not execute archive_queue_partition sp.');
        RETURN;
    END IF;
    
    DBMS_OUTPUT.put_line ('Starting archive queue process for partitioned Meter tables ');
    
    IF p_current_time IS NULL THEN
         v_current_time := SYSDATE;
    ELSE
         v_current_time := p_current_time;
    END IF;
    
    arch_q_p_get_status(
		p_current_time => v_current_time,
		p_next_allow_run_time => v_next_allow_run_time,
		p_current_id_partition => v_current_id_partition,
		p_new_current_id_partition  => v_new_current_id_partition,
		p_old_id_partition => v_old_id_partition,
		p_no_need_to_run => v_no_need_to_run );
    
    IF v_no_need_to_run = 1 THEN
        dbms_output.put_line('No need to run archive operation.');
        RETURN;
    END IF;
    
    IF v_next_allow_run_time IS NULL THEN
         dbms_output.put_line('Partition Schema and Default "id_partition" had already been updated. Skipping this step...');
    ELSE
        v_meter_tablespace_name := prtn_GetMeterPartFileGroupName();

        arch_q_p_apply_next_partition(
            p_new_current_id_partition => v_new_current_id_partition,
            p_current_time => v_current_time,
            p_meter_tablespace_name => v_meter_tablespace_name,
            p_meter_partition_field_name =>  'id_partition' );
	END IF;
	
	/* If it is the 1-st time of running [archive_queue_partition] there are only 2 partitions.
	* It is early to archive data.
	* When 3-rd partition is created the oldest one is archiving.
	* So, meter tables always have 2 partition.*/
	SELECT COUNT(current_id_partition)
	INTO v_count_records
	FROM   t_archive_queue_partition;

	IF ( v_count_records  > 2 ) THEN

		/* Append temp table tt_id_sess_to_keep with IDs of sessions from the 'oldest' partition that should not be archived */
		arch_q_p_get_id_sess_to_keep( p_old_id_partition => v_old_id_partition );

		arch_q_p_prep_all_keep_ses_tab( p_old_id_partition => v_old_id_partition );
		
		BEGIN
			dbms_output.put_line('Pausing pipeline...');
			v_time_count := dbms_utility.get_time;
			PausePipelineProcessing( p_state => 1 );
			dbms_output.put_line('Pipeline was paused after ' || ((dbms_utility.get_time-v_time_count)/100) || ' seconds.');
			v_time_count := dbms_utility.get_time;

			/* Switch out old data, switch in preserved sessions for alll Meter tables. */
			arch_q_p_switch_out_part_all( p_old_id_partition => v_old_id_partition );

			PausePipelineProcessing( p_state => 0 );
			dbms_output.put_line('Pipeline was resumed after ' || ((dbms_utility.get_time-v_time_count)/100) || ' seconds.');
		EXCEPTION
		  WHEN OTHERS THEN
			PausePipelineProcessing( p_state => 0);
			dbms_output.put_line('Pipeline was resumed after exception! "Paused" period: ' || ((dbms_utility.get_time-v_time_count)/100) || ' seconds.');
			RAISE;
		END;

		/* Drop all old data of Meter tables. */
		arch_q_p_drop_temp_tables( p_old_id_partition => v_old_id_partition );

		/*	Rebuild GLOBAL indexes, that became UNUSABLE after EXCHANGE PARTITION operation.
			They can appear if unique constraint was added to any Service Definition*/
		dbms_output.put_line('Check for UNUSABLE indexes...');
		FOR x IN (  SELECT INDEX_NAME
					FROM   USER_INDEXES
					WHERE  TABLE_NAME IN (	SELECT UPPER(nm_table_name)
											FROM   t_service_def_log)
						AND STATUS = 'UNUSABLE' )
		LOOP
			dbms_output.put_line('Rebuilding UNUSABLE index: "' || x.INDEX_NAME || '"');
			EXECUTE IMMEDIATE 'ALTER INDEX ' || x.INDEX_NAME || ' REBUILD ONLINE';
		END LOOP;

		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE tt_tab_names_with_sess_to_keep';
		EXCEPTION
		  WHEN OTHERS THEN
			IF SQLCODE != -942 THEN
				RAISE;
			END IF;
		END;

		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE tt_id_sess_to_keep';
		EXCEPTION
		  WHEN OTHERS THEN
			IF SQLCODE != -942 THEN
				RAISE;
			END IF;
		END;

	END IF;

	/* Update next_allow_run value in [t_archive_queue_partition] table.
	* This is an indicator of successful archivation*/
	prtn_get_next_allow_run_date(
			current_datetime => v_current_time,
			next_allow_run_date => v_next_allow_run_time );

	UPDATE t_archive_queue_partition
	SET next_allow_run = v_next_allow_run_time
	WHERE current_id_partition = v_new_current_id_partition;

	COMMIT;

/* [TBD] Remove specification of sampling_ratio for update stats.
5 and 1 % can be hardly too big percent for some meter table and for some - very small */

/* Use the same update stats approach as in archive_queue_nonpartition */

  IF(p_update_stats = 'Y') THEN
  dbms_output.put_line(' update stats - started');
  
  DECLARE
	v_nu_varstatpercentchar	INT;
	v_tab1					VARCHAR2 (30);
	v_user_name				VARCHAR2 (30);
	v_sql1					VARCHAR2 (4000);
	c1						sys_refcursor;
  BEGIN
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
      dbms_output.put_line(' executing gather_table_stats for table -> ' || UPPER(v_tab1) );
			v_sql1 := 'begin dbms_stats.gather_table_stats(ownname=> ''' || v_user_name || ''',
                 tabname=> ''' || v_tab1 || ''', estimate_percent=> ' || v_nu_varstatpercentchar || ',
                 cascade=> TRUE); end;';
      BEGIN
	      EXECUTE IMMEDIATE v_sql1;
        EXCEPTION
        WHEN others THEN
					p_result := '7000022-archive_queues operation failed->Error in update stats';
					ROLLBACK;
					RETURN;
       END;
       END LOOP;
       CLOSE c1;
       
       dbms_output.put_line(' executing gather_table_stats for table t_session' );
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_SESSION'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000023-archive_queues operation failed->Error in t_session update stats';
             ROLLBACK;
             RETURN;
       END;
       
       dbms_output.put_line(' executing gather_table_stats for table t_session_set' );
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_SESSION_SET'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000024-archive_queues operation failed->Error in t_session_set update stats';
             ROLLBACK;
             RETURN;
       END;
       
       dbms_output.put_line(' executing gather_table_stats for table t_session_state' );
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_SESSION_STATE'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000025-archive_queues operation failed->Error in t_session_state update stats';
             ROLLBACK;
             RETURN;
       END;
       
       dbms_output.put_line(' executing gather_table_stats for table t_message' );
       v_sql1 := 'begin dbms_stats.gather_table_stats( 
 				ownname=> ''' || v_user_name || ''',tabname=> ''T_MESSAGE'', 
 				estimate_percent=> ' || v_nu_varstatpercentchar || ',cascade=> TRUE); end;';
       BEGIN
         EXECUTE IMMEDIATE v_sql1;
         EXCEPTION
         WHEN others THEN
             p_result := '7000026-archive_queues operation failed->Error in t_message update stats';
             ROLLBACK;
             RETURN;
       END;
  END;
  
  dbms_output.put_line(' update stats - completed');
  END IF;

	dbms_output.put_line('Archive Process - completed');
    p_result := '0-archive_queue_partition operation successful';
END;
/
