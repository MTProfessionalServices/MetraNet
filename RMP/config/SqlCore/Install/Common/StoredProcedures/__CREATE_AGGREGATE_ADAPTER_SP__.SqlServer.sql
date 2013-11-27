
CREATE PROCEDURE MTSP_RATE_AGGREGATE_CHARGE
@input_RUN_ID int,
@input_USAGE_INTERVAL int,
@input_BILLING_GROUP_ID int,
@input_TEMPLATE_ID int,
@input_FIRST_PASS_PV_VIEWID int,
@input_FIRST_PASS_PV_TABLE varchar(50),
@input_COUNTABLE_VIEWIDS varchar(2000),
@input_COUNTABLE_OJOINS varchar(2000),
@input_FIRST_PASS_PV_PROPERTIES_ALIASED varchar(4000),  --field names with alias
@input_COUNTABLE_PROPERTIES varchar(2000),                    --field names only
@input_COUNTER_FORMULAS varchar(2000),                  --counters
@input_ACCOUNT_FILTER varchar(2000),
@input_COMPOUND_ORDERING varchar(2000),
@input_COUNTER_FORMULAS_ALIASES varchar(2000),
@output_SQLStmt_SELECT varchar(4000) OUTPUT,
@output_SQLStmt_DROPTMPTBL1 varchar(200) OUTPUT,
@output_SQLStmt_DROPTMPTBL2 varchar(200) OUTPUT,
@return_code int OUTPUT
AS
BEGIN
/********************************************************************
** Procedure Name: MTSP_RATE_AGGREGATE_CHARGE
**
** Procedure Description:
**
** Parameters:
**
** Returns: 0 if successful
**          -1 if fatal error occurred
**
** Created By: Ning Zhuang
** Created On: 1/8/2002
**
** Last Modified On: 02/19/2003
** Last Modified On: 01/21/2003
** Last Modified On: 01/08/2003** Last Modified On: 01/02/2003
** Last Modified On: 12/10/2002
** Last Modified On: 11/18/2002
** Last Modified On: 11/14/2002
** Last Modified On: 10/31/2002
** Last Modified On: 6/12/2002
** Last Modified On: 6/10/2002
**
**********************************************************************/
DECLARE
@au_id_usage_interval int,
@au_id_usage_cycle int,
@au_bc_dt_start datetime,
@ag_dt_start datetime,
@SQLStmt nvarchar(4000),
@tmp_tbl_name_base varchar(50),

@tmp_tbl_name1 varchar(50),
@tmp_tbl_name12 varchar(50),
@tmp_tbl_name2 varchar(50),
@tmp_tbl_name3 varchar(50),
@debug_flag bit,
@SQLError int,

-- the following are added on 11/11/2002
-- I tried a number of ways to implement the performance change. Based on the testing
-- results of 3 versions of the implementations, both feature flexibility and script flexibility
-- (like using table variables) have processing cost associated with them. Since the purpose of
-- the coding change is to improve the performance, I thus decide to use the version
-- SPAggRate_OK_listed20.sql which provides the best performance improvement among the three new
-- versions. This stored procedure contains this version.
@max_loop_cnt int,
-- used to accumulate the counter values (SUM)
@countable_0 numeric(22,10),
@countable_1 numeric(22,10),
@countable_2 numeric(22,10),
@countable_3 numeric(22,10),
@countable_4 numeric(22,10),
@countable_5 numeric(22,10),
@countable_6 numeric(22,10),
@countable_7 numeric(22,10),
@countable_8 numeric(22,10),
@countable_9 numeric(22,10),
@countable_10 numeric(22,10),
@countable_11 numeric(22,10),
@countable_12 numeric(22,10),
@countable_13 numeric(22,10),
@countable_14 numeric(22,10),
@countable_15 numeric(22,10),
@countable_16 numeric(22,10),
@countable_17 numeric(22,10),
@countable_18 numeric(22,10),
@countable_19 numeric(22,10),
-- use to count the number of records (COUNT)
@rec_count_0 int,
@rec_count_1 int,
@rec_count_2 int,
@rec_count_3 int,
@rec_count_4 int,
@rec_count_5 int,@rec_count_6 int,
@rec_count_7 int,
@rec_count_8 int,
@rec_count_9 int,
@rec_count_10 int,
@rec_count_11 int,
@rec_count_12 int,
@rec_count_13 int,
@rec_count_14 int,
@rec_count_15 int,
@rec_count_16 int,
@rec_count_17 int,
@rec_count_18 int,
@rec_count_19 int,

@work_counter_formulas varchar(500),
@work_counter varchar(500),
@loop_index int,
@as_index int,
@comma_index int,
-- store the parsed counter formula
@countable_formula_0 varchar(500),
@countable_formula_1 varchar(500),
@countable_formula_2 varchar(500),
@countable_formula_3 varchar(500),
@countable_formula_4 varchar(500),
@countable_formula_5 varchar(500),
@countable_formula_6 varchar(500),
@countable_formula_7 varchar(500),
@countable_formula_8 varchar(500),
@countable_formula_9 varchar(500),
@countable_formula_10 varchar(500),
@countable_formula_11 varchar(500),
@countable_formula_12 varchar(500),
@countable_formula_13 varchar(500),
@countable_formula_14 varchar(500),
@countable_formula_15 varchar(500),
@countable_formula_16 varchar(500),
@countable_formula_17 varchar(500),
@countable_formula_18 varchar(500),
@countable_formula_19 varchar(500),
-- store the actual value of the calculated formula
@countable_formula_value_0 numeric(22,10),
@countable_formula_value_1 numeric(22,10),
@countable_formula_value_2 numeric(22,10),
@countable_formula_value_3 numeric(22,10),
@countable_formula_value_4 numeric(22,10),
@countable_formula_value_5 numeric(22,10),
@countable_formula_value_6 numeric(22,10),
@countable_formula_value_7 numeric(22,10),
@countable_formula_value_8 numeric(22,10),
@countable_formula_value_9 numeric(22,10),
@countable_formula_value_10 numeric(22,10),
@countable_formula_value_11 numeric(22,10),
@countable_formula_value_12 numeric(22,10),
@countable_formula_value_13 numeric(22,10),
@countable_formula_value_14 numeric(22,10),
@countable_formula_value_15 numeric(22,10),
@countable_formula_value_16 numeric(22,10),
@countable_formula_value_17 numeric(22,10),
@countable_formula_value_18 numeric(22,10),
@countable_formula_value_19 numeric(22,10),
-- store the parsed field names which will be used to create the "temp" table
@counter_resultfieldname_0 varchar(500),
@counter_resultfieldname_1 varchar(500),
@counter_resultfieldname_2 varchar(500),
@counter_resultfieldname_3 varchar(500),
@counter_resultfieldname_4 varchar(500),
@counter_resultfieldname_5 varchar(500),
@counter_resultfieldname_6 varchar(500),
@counter_resultfieldname_7 varchar(500),
@counter_resultfieldname_8 varchar(500),
@counter_resultfieldname_9 varchar(500),
@counter_resultfieldname_10 varchar(500),
@counter_resultfieldname_11 varchar(500),
@counter_resultfieldname_12 varchar(500),
@counter_resultfieldname_13 varchar(500),
@counter_resultfieldname_14 varchar(500),
@counter_resultfieldname_15 varchar(500),
@counter_resultfieldname_16 varchar(500),
@counter_resultfieldname_17 varchar(500),
@counter_resultfieldname_18 varchar(500),
@counter_resultfieldname_19 varchar(500),

@countable_count int,
@formula_count int, -- added on 12/10/2002
@insert_count int

-- added on 12/31/2002
DECLARE
@cur_id_pass int,
@cur_id_sess bigint,
@cur_id_acc int,
@cur_group_acc_flag tinyint,
@cur_group_acc_id int,
@cur_pci_id_interval int,
@cur_dt_session datetime,
@cur_ui_dt_start datetime,
@cur_ui_dt_end datetime,
@cur_pci_dt_start datetime,
@cur_pci_dt_end datetime,
@cur_countable_0 numeric(22,10),
@cur_countable_1 numeric(22,10),
@cur_countable_2 numeric(22,10),
@cur_countable_3 numeric(22,10),
@cur_countable_4 numeric(22,10),
@cur_countable_5 numeric(22,10),
@cur_countable_6 numeric(22,10),
@cur_countable_7 numeric(22,10),
@cur_countable_8 numeric(22,10),
@cur_countable_9 numeric(22,10),
@cur_countable_10 numeric(22,10),
@cur_countable_11 numeric(22,10),
@cur_countable_12 numeric(22,10),
@cur_countable_13 numeric(22,10),
@cur_countable_14 numeric(22,10),
@cur_countable_15 numeric(22,10),
@cur_countable_16 numeric(22,10),
@cur_countable_17 numeric(22,10),
@cur_countable_18 numeric(22,10),
@cur_countable_19 numeric(22,10),
@pre_group_acc_flag tinyint,
@pre_group_acc_id int,
@pre_pci_id_interval int,
@FetchStatusCalc int

SET NOCOUNT ON
SET @debug_flag = 1

------------------------------------------
-- Reguide transactions to subscriptions
-- that may have changed retroactively
------------------------------------------

-- CR12878 - a select into temp table approach is used here
-- because lock exhaustion issues ocurred when the same logic
-- was in the form of update joins
SELECT
  id_sess,
  ISNULL(plm1.id_pi_instance, plm2.id_pi_instance) id_pi_instance,
  ISNULL(s1.id_po, s2.id_po) id_prod
INTO #reguide_usage
FROM t_acc_usage
LEFT OUTER JOIN
	t_gsubmember gsm
	INNER JOIN t_sub s1 ON s1.id_group=gsm.id_group
	INNER JOIN t_pl_map plm1 ON plm1.id_po=s1.id_po AND plm1.id_paramtable IS NULL
ON gsm.id_acc=t_acc_usage.id_payee AND gsm.vt_start <= t_acc_usage.dt_session AND gsm.vt_end >= t_acc_usage.dt_session AND plm1.id_pi_template=t_acc_usage.id_pi_template
LEFT OUTER JOIN
	t_sub s2
	INNER JOIN t_pl_map plm2 ON plm2.id_po=s2.id_po AND plm2.id_paramtable IS NULL
ON s2.id_acc=t_acc_usage.id_payee AND s2.vt_start <= t_acc_usage.dt_session AND s2.vt_end >= t_acc_usage.dt_session AND s2.id_group IS NULL AND plm2.id_pi_template=t_acc_usage.id_pi_template
WHERE
t_acc_usage.id_usage_interval=@input_USAGE_INTERVAL AND
t_acc_usage.id_pi_template=@input_TEMPLATE_ID AND
t_acc_usage.id_view=@input_FIRST_PASS_PV_VIEWID
AND
(
	ISNULL(plm1.id_pi_instance, plm2.id_pi_instance) <> t_acc_usage.id_pi_instance
	OR
	ISNULL(s1.id_po, s2.id_po) <> t_acc_usage.id_prod
	OR
	(t_acc_usage.id_pi_instance IS NULL AND ISNULL(plm1.id_pi_instance, plm2.id_pi_instance) IS NOT NULL)
  OR
	(t_acc_usage.id_prod IS NULL AND ISNULL(plm1.id_po, plm2.id_po) IS NOT NULL)
)

IF @@rowcount > 0
BEGIN
  ALTER TABLE #reguide_usage ADD CONSTRAINT pk_reguide_usage PRIMARY KEY (id_sess)

  UPDATE t_acc_usage
  SET
    t_acc_usage.id_pi_instance = #reguide_usage.id_pi_instance,
    t_acc_usage.id_prod = #reguide_usage.id_prod
  FROM #reguide_usage
  WHERE t_acc_usage.id_sess = #reguide_usage.id_sess

  DROP TABLE #reguide_usage
END

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

------------------------------------------
-- Construct the temp. table names
------------------------------------------
SET @tmp_tbl_name_base = REPLACE(REPLACE(REPLACE(REPLACE
	(RTRIM(CAST(@@SPID AS CHAR) + '_' + CONVERT(CHAR, getdate(), 121)),
	 ' ', ''), ':', ''), '.', ''), '-','')
SET @tmp_tbl_name1 = 't' + @tmp_tbl_name_base + '_1'
SET @tmp_tbl_name12 = 't' + @tmp_tbl_name_base + '_12'
SET @tmp_tbl_name2 = 't' + @tmp_tbl_name_base + '_2'
SET @tmp_tbl_name3 = 't' + @tmp_tbl_name_base + '_3'
------------------------------------------
-- Obtain the billing start and end dates:
-- One billing interval has only one pair of start and end dates
-- Retrieve and then store them in local variables
-----------------------------------------------
SELECT
	@au_id_usage_interval=ui.id_interval,
	@au_id_usage_cycle=ui.id_usage_cycle,
	@au_bc_dt_start=ui.dt_start
FROM
	t_usage_interval ui
WHERE
	ui.id_interval = @input_USAGE_INTERVAL
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @debug_flag = 1 AND @input_RUN_ID IS NOT NULL
BEGIN
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
  VALUES (@input_RUN_ID, 'Debug', 'Finished selecting from the t_usage_interval table', getutcdate())
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
END
--PRINT @au_id_usage_interval
--PRINT @au_id_usage_cycle
--PRINT @au_bc_dt_start
--PRINT ' '
--PRINT 'started: to obtain the earliest aggragate starting date'
--PRINT CONVERT(char, getdate(), 109)
-----------------------------------------------
-- Obtain the earliest aggragate starting date:
-- Modified on 5/31/02 to take the group sub into consideration
-----------------------------------------------
SELECT au.dt_session,
ag.id_usage_cycle id_pc_cycle,
ISNULL(gs.id_usage_cycle,auc.id_usage_cycle) id_usage_cycle
INTO #tmp1
FROM
	t_acc_usage au
	INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = au.id_acc
	LEFT OUTER JOIN t_gsubmember gsm
	  INNER JOIN t_group_sub gs ON gs.id_group = gsm.id_group
	  INNER JOIN t_sub s on gs.id_group = s.id_group
  ON gsm.id_acc = au.id_payee AND s.id_po = au.id_prod AND au.dt_session BETWEEN gsm.vt_start AND gsm.vt_end,
	t_usage_interval ui,
	t_aggregate ag
WHERE
	au.id_view = @input_FIRST_PASS_PV_VIEWID AND
	au.id_usage_interval = @input_USAGE_INTERVAL AND
	au.id_pi_template = @input_TEMPLATE_ID AND
	ui.id_interval = au.id_usage_interval AND
	ui.id_interval = @input_USAGE_INTERVAL AND
	ag.id_prop = ISNULL(au.id_pi_instance, au.id_pi_template)
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

SELECT @ag_dt_start = MIN(pci.dt_start)
FROM #tmp1 tmp1
	LEFT OUTER JOIN t_pc_interval pci ON pci.id_cycle = ISNULL(tmp1.id_pc_cycle,tmp1.id_usage_cycle)
		AND tmp1.dt_session BETWEEN pci.dt_start AND pci.dt_end
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

DROP TABLE #tmp1
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @debug_flag = 1 AND @input_RUN_ID IS NOT NULL
BEGIN
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
  VALUES (@input_RUN_ID, 'Debug', 'Finished selecting the minimum pci.dt_start', getutcdate())
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
END
--PRINT @ag_dt_start
--PRINT 'completed: to obtain the earliest aggragate starting date'
--PRINT CONVERT(char, getdate(), 109)
-----------------------------------------------
-- If no aggregate cycle then use billing cycle
IF @ag_dt_start IS NULL SET @ag_dt_start = @au_bc_dt_start
--PRINT @ag_dt_start

-- creates the billing group join filter which is only valid during EOP runs (not estimate jobs)
DECLARE @billingGroupJoin NVARCHAR(256)
IF @input_RUN_ID IS NOT NULL
  SET @billingGroupJoin = N'INNER JOIN t_billgroup_member bgm ON bgm.id_acc = au.id_acc AND bgm.id_billgroup = ' + CAST(@input_BILLING_GROUP_ID AS NVARCHAR)
ELSE
  SET @billingGroupJoin = N''

----------------------------------------------------------------
-- Firstpass records
----------------------------------------------------------------
SET @SQLStmt = ''
SET @SQLStmt =
N'SELECT
	au.id_sess,
	au.id_acc,
	au.id_payee,
	au.dt_session,
	ui.dt_start ui_dt_start,
	ui.dt_end ui_dt_end,
	-- Changed on 5/3, 5/6/2002 to take the group subscription dates into consideration
	CASE WHEN
		gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
		THEN 1 ELSE 0
	END group_acc_flag,
	CASE WHEN
		gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
		THEN gsm.id_group ELSE au.id_payee
	END group_acc_id,
	ag.id_usage_cycle pci_id_cycle,
	ISNULL(gs.id_usage_cycle,auc.id_usage_cycle) ui_id_cycle
INTO ' + CAST(@tmp_tbl_name12 AS nvarchar(50)) + N'
FROM
	t_acc_usage au
	INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = au.id_acc
  ' + @billingGroupJoin + N'
	-- Changed on 5/3 to take the group subscription dates into consideration
	LEFT OUTER JOIN t_gsubmember gsm
	  INNER JOIN t_group_sub gs ON gs.id_group = gsm.id_group
	  INNER JOIN t_sub s on s.id_group = gs.id_group
  ON gsm.id_acc = au.id_payee AND s.id_po = au.id_prod AND au.dt_session BETWEEN gsm.vt_start AND gsm.vt_end,
	t_usage_interval ui,
	t_aggregate ag
WHERE
	au.id_view = @dinput_FIRST_PASS_PV_VIEWID AND
	au.id_usage_interval = @dinput_id_usage_interval AND
	au.id_pi_template = @dinput_TEMPLATE_ID AND
	ui.id_interval = au.id_usage_interval AND
	ag.id_prop = ISNULL(au.id_pi_instance, au.id_pi_template) AND
	au.dt_session >= @dag_dt_start '
	+ CAST(@input_ACCOUNT_FILTER AS nvarchar(2000))

EXEC sp_executesql @SQLStmt,
N'@dinput_FIRST_PASS_PV_VIEWID int, @dinput_id_usage_interval int, @dinput_TEMPLATE_ID int, @dag_dt_start datetime',
@input_FIRST_PASS_PV_VIEWID, @input_USAGE_INTERVAL, @input_TEMPLATE_ID, @ag_dt_start

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

SET @SQLStmt = ''
SET @SQLStmt =
N'SELECT
	tmp.id_sess,
	tmp.id_acc,
	tmp.id_payee,
	tmp.dt_session,
	tmp.ui_dt_start,
	tmp.ui_dt_end,
	pci.dt_start pci_dt_start,
	pci.dt_end pci_dt_end,
	pci.id_interval pci_id_interval,
	tmp.group_acc_flag,
	tmp.group_acc_id
INTO ' + CAST(@tmp_tbl_name1 AS nvarchar(50)) + N'
FROM ' + CAST(@tmp_tbl_name12 AS nvarchar(50)) + N' tmp
	LEFT OUTER JOIN t_pc_interval pci ON pci.id_cycle = ISNULL(tmp.pci_id_cycle,tmp.ui_id_cycle)
		AND tmp.dt_session BETWEEN pci.dt_start AND pci.dt_end '
--PRINT @SQLStmt
EXEC sp_executesql @SQLStmt
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

IF @debug_flag = 1 AND @input_RUN_ID IS NOT NULL
BEGIN
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
  VALUES (@input_RUN_ID, 'Debug', 'Finished inserting into the temp1 table', getutcdate())
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
END
--PRINT 'completed: to obtain the firstpass records'
--PRINT CONVERT(char, getdate(), 109)

SET @SQLStmt = 'DROP TABLE ' + @tmp_tbl_name12
EXEC sp_executesql @SQLStmt
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

----------------------------------------------------------------
-- Counter records
----------------------------------------------------------------
SET @SQLStmt = ''
IF RTRIM(@input_COUNTABLE_VIEWIDS) = '' OR @input_COUNTABLE_VIEWIDS IS NULL
BEGIN
SET @SQLStmt =
N'SELECT
	au.id_sess,
	au.id_acc,
	au.id_payee,
	au.dt_session,
	au.id_pi_template,
	ui.dt_start ui_dt_start,
	ui.dt_end ui_dt_end,
	pci.id_interval pci_id_interval,
	--Changed on 5/3 to take the group subscription dates into consideration
	CASE WHEN
		gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
		THEN 1 ELSE 0
	END group_acc_flag,
	CASE WHEN
		gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
		THEN gsm.id_group ELSE au.id_payee
	END group_acc_id '
	+ CAST(@input_COUNTABLE_PROPERTIES AS nvarchar(2000))
	+ N'
INTO ' + CAST(@tmp_tbl_name2 AS nvarchar(50)) + N'
FROM
	t_acc_usage au
	--Changed on 5/3 to take the group subscription dates into consideration
	LEFT OUTER JOIN t_gsubmember gsm
	  INNER JOIN t_group_sub gs ON gs.id_group = gsm.id_group
    INNER JOIN t_sub s ON gs.id_group = s.id_group
  ON gsm.id_acc = au.id_payee AND s.id_po = au.id_prod AND au.dt_session BETWEEN gsm.vt_start AND gsm.vt_end '
  + CAST(@input_COUNTABLE_OJOINS AS nvarchar(2000)) + N',
	t_usage_interval ui,
	(SELECT DISTINCT pci_id_interval FROM ' + CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' ) agi,
	t_pc_interval pci
WHERE
	au.id_view IS NULL AND
	ui.id_interval = au.id_usage_interval AND
	pci.id_interval = agi.pci_id_interval AND
	au.dt_session BETWEEN pci.dt_start AND pci.dt_end AND
	au.dt_session >= @dag_dt_start '
	+ CAST(@input_ACCOUNT_FILTER AS nvarchar(2000))
END
ELSE
BEGIN
SET @SQLStmt =
N'SELECT
	au.id_sess,
	au.id_acc,
	au.id_payee,
	au.dt_session,
	au.id_pi_template,
	ui.dt_start ui_dt_start,
	ui.dt_end ui_dt_end,
	pci.id_interval pci_id_interval,
	--Changed on 5/3 to take the group subscription dates into consideration
	CASE WHEN
		gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
		THEN 1 ELSE 0
	END group_acc_flag,
	CASE WHEN
		gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
		THEN gsm.id_group ELSE au.id_payee
	END group_acc_id '
	+ CAST(@input_COUNTABLE_PROPERTIES AS nvarchar(2000))
	+ N'
INTO ' + CAST(@tmp_tbl_name2 AS nvarchar(50)) + N'
FROM
	t_acc_usage au
	--Changed on 5/3 to take the group subscription dates into consideration
	LEFT OUTER JOIN t_gsubmember gsm
	  INNER JOIN t_group_sub gs ON gs.id_group = gsm.id_group
    INNER JOIN t_sub s ON s.id_group=gs.id_group
  ON gsm.id_acc = au.id_payee AND s.id_po = au.id_prod AND au.dt_session BETWEEN gsm.vt_start AND gsm.vt_end '
  + CAST(@input_COUNTABLE_OJOINS AS nvarchar(2000)) + N',
	t_usage_interval ui,
	(SELECT DISTINCT pci_id_interval FROM ' + CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' ) agi,
	t_pc_interval pci
WHERE
	(au.id_view IS NULL OR au.id_view in (' + CAST(@input_COUNTABLE_VIEWIDS AS nvarchar(2000)) + N')) AND
	ui.id_interval = au.id_usage_interval AND
	pci.id_interval = agi.pci_id_interval AND
	au.dt_session BETWEEN pci.dt_start AND pci.dt_end AND
	au.dt_session >= @dag_dt_start '
	+ CAST(@input_ACCOUNT_FILTER AS nvarchar(2000))
END
--PRINT @SQLStmt
EXEC sp_executesql @SQLStmt, N'@dag_dt_start datetime', @ag_dt_start

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @debug_flag = 1 AND @input_RUN_ID IS NOT NULL
BEGIN
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
  VALUES (@input_RUN_ID, 'Debug', 'Finished inserting into the temp2 table', getutcdate())
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
END
--PRINT 'completed: to obtain the counter records'
--PRINT CONVERT(char, getdate(), 109)

----------------------------------------------------------------
-- Calculate the counters
----------------------------------------------------------------
-- 11/11/2002
-- Check to see which method to use to calculate the counters
SET @max_loop_cnt = 0
SET @SQLStmt =
N'SELECT @max_loop_cnt = MAX(cnt) FROM '
+ N'(SELECT COUNT(*) cnt FROM ' + CAST(@tmp_tbl_name2 AS nvarchar(50))
+ N' GROUP BY group_acc_flag, group_acc_id) tmptbl'
--PRINT @SQLStmt
EXEC sp_executesql @SQLStmt,
	N'@max_loop_cnt int OUTPUT',
	@max_loop_cnt = @max_loop_cnt OUTPUT

SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

IF @input_COUNTER_FORMULAS IS NULL
   OR @input_COUNTER_FORMULAS = ''
   OR @max_loop_cnt IS NULL
-- 1/2/2003 Always use the linear approach.
-- Uncomment the following line if want to use either the selfjoin or the linear approach
-- depending on the data volume.
--   OR @max_loop_cnt <= 1000
-- Use the selfjoin approach
BEGIN
SET @SQLStmt = ''
SET @SQLStmt =
N'SELECT tp1.id_sess ' + @input_COUNTER_FORMULAS + N'
INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
+ N' FROM ' + CAST(@tmp_tbl_name1 AS nvarchar(50))
+ N' tp1 LEFT OUTER JOIN ' + CAST(@tmp_tbl_name2 AS nvarchar(50))
+ N' tp2 ON tp2.group_acc_flag = tp1.group_acc_flag AND tp2.group_acc_id = tp1.group_acc_id
	AND tp2.dt_session BETWEEN tp1.pci_dt_start AND tp1.pci_dt_end
	AND (tp2.ui_dt_end < tp1.ui_dt_end
		OR (tp2.ui_dt_end = tp1.ui_dt_end
		AND tp2.dt_session < tp1.dt_session)
		OR (tp2.ui_dt_end = tp1.ui_dt_end
		AND tp2.dt_session = tp1.dt_session
		AND tp2.id_sess < tp1.id_sess))
GROUP BY tp1.id_sess'

EXEC sp_executesql @SQLStmt
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @debug_flag = 1 AND @input_RUN_ID IS NOT NULL
BEGIN
  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)
  VALUES (@input_RUN_ID, 'Debug', 'Finished inserting into the temp3 table', getutcdate())
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
END
END -- End of the selfjoin approach
ELSE
-- Use the linear approach
BEGIN
SET @countable_0 = 0
SET @countable_1 = 0
SET @countable_2 = 0
SET @countable_3 = 0
SET @countable_4 = 0
SET @countable_5 = 0
SET @countable_6 = 0
SET @countable_7 = 0
SET @countable_8 = 0
SET @countable_9 = 0
SET @countable_10 = 0
SET @countable_11 = 0
SET @countable_12 = 0
SET @countable_13 = 0
SET @countable_14 = 0
SET @countable_15 = 0
SET @countable_16 = 0
SET @countable_17 = 0
SET @countable_18 = 0
SET @countable_19 = 0

SET @rec_count_0 = 0
SET @rec_count_1 = 0
SET @rec_count_2 = 0
SET @rec_count_3 = 0
SET @rec_count_4 = 0
SET @rec_count_5 = 0
SET @rec_count_6 = 0
SET @rec_count_7 = 0
SET @rec_count_8 = 0
SET @rec_count_9 = 0
SET @rec_count_10 = 0
SET @rec_count_11 = 0
SET @rec_count_12 = 0
SET @rec_count_13 = 0
SET @rec_count_14 = 0
SET @rec_count_15 = 0
SET @rec_count_16 = 0
SET @rec_count_17 = 0
SET @rec_count_18 = 0
SET @rec_count_19 = 0

SET @countable_count = LEN(RTRIM(@input_COUNTABLE_PROPERTIES)) - LEN(RTRIM(REPLACE(@input_COUNTABLE_PROPERTIES, ',' , '')))
--PRINT @countable_count
SET @formula_count = LEN(RTRIM(@input_COUNTER_FORMULAS_ALIASES)) - LEN(RTRIM(REPLACE(@input_COUNTER_FORMULAS_ALIASES, ',' , '')))
--PRINT @formula_count

-- Parse the @input_COUNTER_FORMULAS string to obtain the "temp" table column names
SET @work_counter_formulas = @input_COUNTER_FORMULAS
-- remove the leading comma and add the trailing comma
SET @work_counter_formulas = SUBSTRING(@work_counter_formulas,3,LEN(@work_counter_formulas)) + ', '
-- remove the ISNULL
SET @work_counter_formulas = REPLACE(REPLACE(@work_counter_formulas, 'ISNULL(', ''), ', 0)', '')

SET @loop_index = -1
WHILE LEN(@work_counter_formulas) > 0
BEGIN
	SET @loop_index = @loop_index + 1
	SET @as_index = PATINDEX('% AS %', @work_counter_formulas)
	SET @comma_index = PATINDEX('%, %', @work_counter_formulas)
	IF @loop_index = 0
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_0 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_0 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_0 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_0 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_0 = REPLACE(@countable_formula_0, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_0, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 1
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_1 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_1 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_1 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_1 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_1 = REPLACE(@countable_formula_1, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_1, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 2
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_2 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_2 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_2 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_2 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_2 = REPLACE(@countable_formula_2, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_2, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 3
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_3 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_3 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_3 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_3 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_3 = REPLACE(@countable_formula_3, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_3, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 4
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_4 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_4 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_4 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_4 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_4 = REPLACE(@countable_formula_4, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_4, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 5
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_5 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_5 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_5 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_5 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_5 = REPLACE(@countable_formula_5, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_5, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 6
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_6 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_6 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_6 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_6 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_6 = REPLACE(@countable_formula_6, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_6, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 7
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_7 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_7 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_7 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_7 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_7 = REPLACE(@countable_formula_7, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_7, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 8
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_8 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_8 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_8 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_8 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_8 = REPLACE(@countable_formula_8, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_8, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 9
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_9 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_9 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_9 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_9 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_9 = REPLACE(@countable_formula_9, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_9, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 10
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_10 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_10 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_10 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_10 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_10 = REPLACE(@countable_formula_10, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_10, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 11
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_11 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_11 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_11 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_11 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_11 = REPLACE(@countable_formula_11, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_11, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 12
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_12 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_12 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_12 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_12 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_12 = REPLACE(@countable_formula_12, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_12, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 13
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_13 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_13 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_13 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_13 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_13 = REPLACE(@countable_formula_13, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_13, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 14
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_14 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_14 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_14 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_14 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_14 = REPLACE(@countable_formula_14, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_14, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 15
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_15 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_15 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_15 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_15 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_15 = REPLACE(@countable_formula_15, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_15, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 16
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_16 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_16 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_16 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_16 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_16 = REPLACE(@countable_formula_16, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_16, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 17
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_17 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_17 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_17 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_17 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_17 = REPLACE(@countable_formula_17, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_17, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 18
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_18 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_18 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_18 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_18 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_18 = REPLACE(@countable_formula_18, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_18, 'countable_', '@rec_count_')
		END
	END
	ELSE IF @loop_index = 19
	BEGIN
		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)
		SET @counter_resultfieldname_19 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)

		IF PATINDEX('%(SUM(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_19 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END
		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0
		BEGIN			SET @countable_formula_19 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END
		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0
		BEGIN
			SET @countable_formula_19 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')
			SET @countable_formula_19 = REPLACE(@countable_formula_19, 'countable_', '@countable_')
				+ '/' + REPLACE(@countable_formula_19, 'countable_', '@rec_count_')
		END
	END

	SET @work_counter_formulas = SUBSTRING(@work_counter_formulas, @comma_index+2, LEN(@work_counter_formulas))
	--PRINT @work_counter_formulas
END
-- end of the string parsing to extract counter formulas

-- Create the @tmp_tbl_name3 table
IF @formula_count = 1
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 2
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 3
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 4
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 5
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 6
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 7
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 8
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_7 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 9
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_8 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 10
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_9 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 11
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_10 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 12
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_11 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 13
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_12 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 14
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_13 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 15
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_13 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_14 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 16
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_13 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_14 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_15 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 17
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_13 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_14 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_15 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_16 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 18
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_13 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_14 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_15 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_16 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_17 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 19
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_13 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_14 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_15 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_16 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_17 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_18 + N' NUMERIC (38,6) ) '
ELSE IF @formula_count = 20
	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess bigint, '
		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_13 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_14 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_15 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_16 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_17 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_18 + N' NUMERIC (38,6), '
		+ @counter_resultfieldname_19 + N' NUMERIC (38,6) ) '
--PRINT @SQLStmt
EXEC sp_executesql @SQLStmt
-- End of creating the table

-- Linear processing, 12/31/2002
IF @countable_count = 1
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 2
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 3
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 4
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 5
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 6
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 7
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 8
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6,'
	+ N' countable_7'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 9
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6,'
	+ N' countable_7,'
	+ N' countable_8'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 10
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6,'
	+ N' countable_7,'
	+ N' countable_8,'
	+ N' countable_9'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 11
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6,'
	+ N' countable_7,'
	+ N' countable_8,'
	+ N' countable_9,'
	+ N' countable_10'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 12
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6,'
	+ N' countable_7,'
	+ N' countable_8,'
	+ N' countable_9,'
	+ N' countable_10,'
	+ N' countable_11'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 13
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6,'
	+ N' countable_7,'
	+ N' countable_8,'
	+ N' countable_9,'
	+ N' countable_10,'
	+ N' countable_11,'
	+ N' countable_12'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 14
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6,'
	+ N' countable_7,'
	+ N' countable_8,'
	+ N' countable_9,'
	+ N' countable_10,'
	+ N' countable_11,'
	+ N' countable_12,'
	+ N' countable_13'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 15
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6,'
	+ N' countable_7,'
	+ N' countable_8,'
	+ N' countable_9,'
	+ N' countable_10,'
	+ N' countable_11,'
	+ N' countable_12,'
	+ N' countable_13,'
	+ N' countable_14'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 16
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6,'
	+ N' countable_7,'
	+ N' countable_8,'
	+ N' countable_9,'
	+ N' countable_10,'
	+ N' countable_11,'
	+ N' countable_12,'
	+ N' countable_13,'
	+ N' countable_14,'
	+ N' countable_15'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 17
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6,'
	+ N' countable_7,'
	+ N' countable_8,'
	+ N' countable_9,'
	+ N' countable_10,'
	+ N' countable_11,'
	+ N' countable_12,'
	+ N' countable_13,'
	+ N' countable_14,'
	+ N' countable_15,'
	+ N' countable_16'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 18
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6,'
	+ N' countable_7,'
	+ N' countable_8,'
	+ N' countable_9,'
	+ N' countable_10,'
	+ N' countable_11,'
	+ N' countable_12,'
	+ N' countable_13,'
	+ N' countable_14,'
	+ N' countable_15,'
	+ N' countable_16,'
	+ N' countable_17'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 19
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6,'
	+ N' countable_7,'
	+ N' countable_8,'
	+ N' countable_9,'
	+ N' countable_10,'
	+ N' countable_11,'
	+ N' countable_12,'
	+ N' countable_13,'
	+ N' countable_14,'
	+ N' countable_15,'
	+ N' countable_16,'
	+ N' countable_17,'
	+ N' countable_18'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
ELSE IF @countable_count = 20
BEGIN
	SET @SQLStmt =
	N'DECLARE calc_cursor CURSOR GLOBAL FOR '
	+ N' SELECT 1 id_pass, '
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM '
	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '
	+ N' SELECT 2 id_pass,'
	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' NULL,NULL,'
	+ N' countable_0,'
	+ N' countable_1,'
	+ N' countable_2,'
	+ N' countable_3,'
	+ N' countable_4,'
	+ N' countable_5,'
	+ N' countable_6,'
	+ N' countable_7,'
	+ N' countable_8,'
	+ N' countable_9,'
	+ N' countable_10,'
	+ N' countable_11,'
	+ N' countable_12,'
	+ N' countable_13,'
	+ N' countable_14,'
	+ N' countable_15,'
	+ N' countable_16,'
	+ N' countable_17,'
	+ N' countable_18,'
	+ N' countable_19'
	+ N' FROM '
	+ CAST(@tmp_tbl_name2 AS nvarchar(50))
	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'
END
-- PRINT @SQLStmt

EXEC sp_executesql @SQLStmt
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

OPEN calc_cursor
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError

IF @countable_count = 1
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0
END
ELSE IF @countable_count = 2
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1
END
ELSE IF @countable_count = 3
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2
END
ELSE IF @countable_count = 4
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3
END
ELSE IF @countable_count = 5
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4
END
ELSE IF @countable_count = 6
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5
END
ELSE IF @countable_count = 7
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6
END
ELSE IF @countable_count = 8
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7
END
ELSE IF @countable_count = 9
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8
END
ELSE IF @countable_count = 10
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9
END
ELSE IF @countable_count = 11
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10
END
ELSE IF @countable_count = 12
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11
END
ELSE IF @countable_count = 13
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12
END
ELSE IF @countable_count = 14
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13
END
ELSE IF @countable_count = 15
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13,@cur_countable_14
END
ELSE IF @countable_count = 16
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15
END
ELSE IF @countable_count = 17
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16
END
ELSE IF @countable_count = 18
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16,@cur_countable_17
END
ELSE IF @countable_count = 19
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16,@cur_countable_17,
	@cur_countable_18
END
ELSE IF @countable_count = 20
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16,@cur_countable_17,
	@cur_countable_18,@cur_countable_19
END

SET @FetchStatusCalc = @@FETCH_STATUS
SET @pre_group_acc_flag = 0
SET @pre_group_acc_id = 0
SET @pre_pci_id_interval = 0

WHILE @FetchStatusCalc <> -1
BEGIN
	-- Reset the counters when necessary
	IF @FetchStatusCalc = 0
		AND (@cur_group_acc_flag <> @pre_group_acc_flag
		     OR @cur_group_acc_id <> @pre_group_acc_id
		     OR @cur_pci_id_interval <> @pre_pci_id_interval
		    )
	BEGIN
		SET @pre_pci_id_interval = @cur_pci_id_interval
		SET @pre_group_acc_flag = @cur_group_acc_flag
		SET @pre_group_acc_id = @cur_group_acc_id

		IF @countable_count = 1
		BEGIN
			SET @countable_0 = 0

			SET @rec_count_0 = 0
		END
		ELSE IF @countable_count = 2
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
		END
		ELSE IF @countable_count = 3
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
		END
		ELSE IF @countable_count = 4
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
		END
		ELSE IF @countable_count = 5
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
		END
		ELSE IF @countable_count = 6
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
		END
		ELSE IF @countable_count = 7
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
		END
		ELSE IF @countable_count = 8
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0
			SET @countable_7 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
			SET @rec_count_7 = 0
		END
		ELSE IF @countable_count = 9
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0
			SET @countable_7 = 0
			SET @countable_8 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
			SET @rec_count_7 = 0
			SET @rec_count_8 = 0
		END
		ELSE IF @countable_count = 10
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0			SET @countable_7 = 0
			SET @countable_8 = 0
			SET @countable_9 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
			SET @rec_count_7 = 0
			SET @rec_count_8 = 0
			SET @rec_count_9 = 0
		END
		ELSE IF @countable_count = 11
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0
			SET @countable_7 = 0
			SET @countable_8 = 0
			SET @countable_9 = 0
			SET @countable_10 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
			SET @rec_count_7 = 0
			SET @rec_count_8 = 0
			SET @rec_count_9 = 0
			SET @rec_count_10 = 0
		END
		ELSE IF @countable_count = 12
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0
			SET @countable_7 = 0
			SET @countable_8 = 0
			SET @countable_9 = 0
			SET @countable_10 = 0
			SET @countable_11 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
			SET @rec_count_7 = 0
			SET @rec_count_8 = 0
			SET @rec_count_9 = 0
			SET @rec_count_10 = 0
			SET @rec_count_11 = 0
		END
		ELSE IF @countable_count = 13
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0
			SET @countable_7 = 0
			SET @countable_8 = 0
			SET @countable_9 = 0
			SET @countable_10 = 0
			SET @countable_11 = 0
			SET @countable_12 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
			SET @rec_count_7 = 0
			SET @rec_count_8 = 0
			SET @rec_count_9 = 0
			SET @rec_count_10 = 0
			SET @rec_count_11 = 0
			SET @rec_count_12 = 0
		END
		ELSE IF @countable_count = 14
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0
			SET @countable_7 = 0
			SET @countable_8 = 0
			SET @countable_9 = 0
			SET @countable_10 = 0
			SET @countable_11 = 0
			SET @countable_12 = 0
			SET @countable_13 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
			SET @rec_count_7 = 0
			SET @rec_count_8 = 0
			SET @rec_count_9 = 0
			SET @rec_count_10 = 0
			SET @rec_count_11 = 0
			SET @rec_count_12 = 0
			SET @rec_count_13 = 0
		END
		ELSE IF @countable_count = 15
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0
			SET @countable_7 = 0
			SET @countable_8 = 0
			SET @countable_9 = 0
			SET @countable_10 = 0
			SET @countable_11 = 0
			SET @countable_12 = 0
			SET @countable_13 = 0
			SET @countable_14 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
			SET @rec_count_7 = 0
			SET @rec_count_8 = 0
			SET @rec_count_9 = 0
			SET @rec_count_10 = 0
			SET @rec_count_11 = 0
			SET @rec_count_12 = 0
			SET @rec_count_13 = 0
			SET @rec_count_14 = 0
		END
		ELSE IF @countable_count = 16
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0
			SET @countable_7 = 0
			SET @countable_8 = 0
			SET @countable_9 = 0
			SET @countable_10 = 0
			SET @countable_11 = 0
			SET @countable_12 = 0
			SET @countable_13 = 0
			SET @countable_14 = 0
			SET @countable_15 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
			SET @rec_count_7 = 0
			SET @rec_count_8 = 0
			SET @rec_count_9 = 0
			SET @rec_count_10 = 0
			SET @rec_count_11 = 0
			SET @rec_count_12 = 0
			SET @rec_count_13 = 0
			SET @rec_count_14 = 0
			SET @rec_count_15 = 0
		END
		ELSE IF @countable_count = 17
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0
			SET @countable_7 = 0
			SET @countable_8 = 0
			SET @countable_9 = 0
			SET @countable_10 = 0
			SET @countable_11 = 0
			SET @countable_12 = 0
			SET @countable_13 = 0
			SET @countable_14 = 0
			SET @countable_15 = 0
			SET @countable_16 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
			SET @rec_count_7 = 0
			SET @rec_count_8 = 0
			SET @rec_count_9 = 0
			SET @rec_count_10 = 0
			SET @rec_count_11 = 0
			SET @rec_count_12 = 0
			SET @rec_count_13 = 0
			SET @rec_count_14 = 0
			SET @rec_count_15 = 0
			SET @rec_count_16 = 0
		END
		ELSE IF @countable_count = 18
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0
			SET @countable_7 = 0
			SET @countable_8 = 0
			SET @countable_9 = 0
			SET @countable_10 = 0
			SET @countable_11 = 0
			SET @countable_12 = 0
			SET @countable_13 = 0
			SET @countable_14 = 0
			SET @countable_15 = 0
			SET @countable_16 = 0
			SET @countable_17 = 0
			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
			SET @rec_count_7 = 0
			SET @rec_count_8 = 0
			SET @rec_count_9 = 0
			SET @rec_count_10 = 0
			SET @rec_count_11 = 0
			SET @rec_count_12 = 0
			SET @rec_count_13 = 0
			SET @rec_count_14 = 0
			SET @rec_count_15 = 0
			SET @rec_count_16 = 0
			SET @rec_count_17 = 0
		END
		ELSE IF @countable_count = 19
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0
			SET @countable_7 = 0
			SET @countable_8 = 0
			SET @countable_9 = 0
			SET @countable_10 = 0
			SET @countable_11 = 0
			SET @countable_12 = 0
			SET @countable_13 = 0
			SET @countable_14 = 0
			SET @countable_15 = 0
			SET @countable_16 = 0			SET @countable_17 = 0
			SET @countable_18 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
			SET @rec_count_7 = 0
			SET @rec_count_8 = 0
			SET @rec_count_9 = 0
			SET @rec_count_10 = 0
			SET @rec_count_11 = 0
			SET @rec_count_12 = 0
			SET @rec_count_13 = 0
			SET @rec_count_14 = 0
			SET @rec_count_15 = 0
			SET @rec_count_16 = 0
			SET @rec_count_17 = 0
			SET @rec_count_18 = 0
		END
		ELSE IF @countable_count = 20
		BEGIN
			SET @countable_0 = 0
			SET @countable_1 = 0
			SET @countable_2 = 0
			SET @countable_3 = 0
			SET @countable_4 = 0
			SET @countable_5 = 0
			SET @countable_6 = 0
			SET @countable_7 = 0
			SET @countable_8 = 0
			SET @countable_9 = 0
			SET @countable_10 = 0
			SET @countable_11 = 0
			SET @countable_12 = 0
			SET @countable_13 = 0
			SET @countable_14 = 0
			SET @countable_15 = 0
			SET @countable_16 = 0
			SET @countable_17 = 0
			SET @countable_18 = 0
			SET @countable_19 = 0

			SET @rec_count_0 = 0
			SET @rec_count_1 = 0
			SET @rec_count_2 = 0
			SET @rec_count_3 = 0
			SET @rec_count_4 = 0
			SET @rec_count_5 = 0
			SET @rec_count_6 = 0
			SET @rec_count_7 = 0
			SET @rec_count_8 = 0
			SET @rec_count_9 = 0
			SET @rec_count_10 = 0
			SET @rec_count_11 = 0
			SET @rec_count_12 = 0
			SET @rec_count_13 = 0
			SET @rec_count_14 = 0
			SET @rec_count_15 = 0
			SET @rec_count_16 = 0
			SET @rec_count_17 = 0
			SET @rec_count_18 = 0
			SET @rec_count_19 = 0
		END
	END -- reset the counters

	-- Processing the record
	IF @FetchStatusCalc = 0
	BEGIN
		IF @cur_id_pass = 1
		BEGIN
			-- Insert into the temp table

			-- obtain the actual value before the insertion
			SET @SQLStmt = N'DECLARE get_value_cursor CURSOR GLOBAL FOR SELECT '
			+ ISNULL(@countable_formula_0,0) + N',' + ISNULL(@countable_formula_1 ,0) + N',' + ISNULL(@countable_formula_2 ,0) + N','
			+ ISNULL(@countable_formula_3 ,0) + N',' + ISNULL(@countable_formula_4 ,0) + N',' + ISNULL(@countable_formula_5 ,0) + N','
			+ ISNULL(@countable_formula_6 ,0) + N',' + ISNULL(@countable_formula_7 ,0) + N',' + ISNULL(@countable_formula_8 ,0) + N','
			+ ISNULL(@countable_formula_9 ,0) + N',' + ISNULL(@countable_formula_10 ,0) + N',' + ISNULL(@countable_formula_11 ,0) + N','
			+ ISNULL(@countable_formula_12 ,0) + N',' + ISNULL(@countable_formula_13 ,0) + N',' + ISNULL(@countable_formula_14 ,0) + N','
			+ ISNULL(@countable_formula_15 ,0) + N',' + ISNULL(@countable_formula_16 ,0) + N',' + ISNULL(@countable_formula_17 ,0) + N','
			+ ISNULL(@countable_formula_18 ,0) + N',' + ISNULL(@countable_formula_19 ,0)
			--PRINT @SQLStmt

			EXEC sp_executesql @SQLStmt,
			N'@countable_0 numeric(22,10), @countable_1 numeric(22,10), @countable_2 numeric(22,10),
			@countable_3 numeric(22,10), @countable_4 numeric(22,10), @countable_5 numeric(22,10),
			@countable_6 numeric(22,10), @countable_7 numeric(22,10), @countable_8 numeric(22,10),
			@countable_9 numeric(22,10), @countable_10 numeric(22,10), @countable_11 numeric(22,10),
			@countable_12 numeric(22,10), @countable_13 numeric(22,10), @countable_14 numeric(22,10),
			@countable_15 numeric(22,10), @countable_16 numeric(22,10), @countable_17 numeric(22,10),
			@countable_18 numeric(22,10), @countable_19 numeric(22,10),
			@rec_count_0 int, @rec_count_1 int, @rec_count_2 int,
			@rec_count_3 int, @rec_count_4 int, @rec_count_5 int,
			@rec_count_6 int, @rec_count_7 int, @rec_count_8 int,
			@rec_count_9 int, @rec_count_10 int, @rec_count_11 int,
			@rec_count_12 int, @rec_count_13 int, @rec_count_14 int,
			@rec_count_15 int, @rec_count_16 int, @rec_count_17 int,
			@rec_count_18 int, @rec_count_19 int',
			@countable_0, @countable_1, @countable_2,
			@countable_3, @countable_4, @countable_5,
			@countable_6, @countable_7, @countable_8,
			@countable_9, @countable_10, @countable_11,
			@countable_12, @countable_13, @countable_14,
			@countable_15, @countable_16, @countable_17,
			@countable_18, @countable_19,
			@rec_count_0, @rec_count_1, @rec_count_2,
			@rec_count_3, @rec_count_4, @rec_count_5,
			@rec_count_6, @rec_count_7, @rec_count_8,
			@rec_count_9, @rec_count_10, @rec_count_11,
			@rec_count_12, @rec_count_13, @rec_count_14,
			@rec_count_15, @rec_count_16, @rec_count_17,
			@rec_count_18, @rec_count_19

			SELECT @SQLError = @@ERROR
			IF @SQLError <> 0 GOTO FatalErrorCursor_Calc

			OPEN get_value_cursor
			SELECT @SQLError = @@ERROR
			IF @SQLError <> 0 GOTO FatalErrorCursor_Calc

			FETCH NEXT FROM get_value_cursor INTO
			@countable_formula_value_0, @countable_formula_value_1, @countable_formula_value_2,
			@countable_formula_value_3, @countable_formula_value_4, @countable_formula_value_5,
			@countable_formula_value_6, @countable_formula_value_7, @countable_formula_value_8,
			@countable_formula_value_9, @countable_formula_value_10, @countable_formula_value_11,
			@countable_formula_value_12, @countable_formula_value_13, @countable_formula_value_14,
			@countable_formula_value_15, @countable_formula_value_16, @countable_formula_value_17,
			@countable_formula_value_18, @countable_formula_value_19

			CLOSE get_value_cursor
			DEALLOCATE get_value_cursor

			-- start insertions
			IF @formula_count = 1
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50)) + N')'
			ELSE IF @formula_count = 2
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 3
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 4
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 5
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 6
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 7
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 8
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 9
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 10
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 11
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 12
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 13
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 14
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 15
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_14 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 16
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_14 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_15 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 17
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_14 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_15 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_16 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 18
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_14 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_15 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_16 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_17 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 19
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_14 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_15 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_16 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_17 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_18 AS nvarchar(50))
				+ N')'
			ELSE IF @formula_count = 20
				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N','
				+ CAST(@countable_formula_value_0 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_14 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_15 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_16 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_17 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_18 AS nvarchar(50))
				+ N',' + CAST(@countable_formula_value_19 AS nvarchar(50))
				+ N')'

			EXEC sp_executesql @SQLStmt
			SELECT @SQLError = @@ERROR
			IF @SQLError <> 0 GOTO FatalErrorCursor_Calc
		END
		ELSE
		BEGIN
			-- Counter records to accumulate the counters
			IF @countable_count = 1
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 2
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 3
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 4
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 5
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 6
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 7
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 8
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)
				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 9
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)
				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)
				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 10
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)
				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)
				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)
				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 11
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)
				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)
				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)
				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)
				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 12
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)
				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)
				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)
				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)
				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)
				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 13
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)
				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)
				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)
				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)
				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)
				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)
				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 14
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)
				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)
				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)
				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)
				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)
				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)
				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)
				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 15
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)
				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)
				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)
				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)
				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)
				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)
				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)
				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)
				SET @countable_14 = @countable_14 + ISNULL(@cur_countable_14,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_14 = @rec_count_14 + CASE WHEN @cur_countable_14 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 16
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)
				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)
				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)
				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)
				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)
				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)
				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)
				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)
				SET @countable_14 = @countable_14 + ISNULL(@cur_countable_14,0)
				SET @countable_15 = @countable_15 + ISNULL(@cur_countable_15,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_14 = @rec_count_14 + CASE WHEN @cur_countable_14 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_15 = @rec_count_15 + CASE WHEN @cur_countable_15 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 17
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)
				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)
				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)
				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)
				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)
				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)
				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)
				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)
				SET @countable_14 = @countable_14 + ISNULL(@cur_countable_14,0)
				SET @countable_15 = @countable_15 + ISNULL(@cur_countable_15,0)
				SET @countable_16 = @countable_16 + ISNULL(@cur_countable_16,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_14 = @rec_count_14 + CASE WHEN @cur_countable_14 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_15 = @rec_count_15 + CASE WHEN @cur_countable_15 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_16 = @rec_count_16 + CASE WHEN @cur_countable_16 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 18
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)
				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)
				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)
				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)
				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)
				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)
				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)
				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)
				SET @countable_14 = @countable_14 + ISNULL(@cur_countable_14,0)
				SET @countable_15 = @countable_15 + ISNULL(@cur_countable_15,0)
				SET @countable_16 = @countable_16 + ISNULL(@cur_countable_16,0)
				SET @countable_17 = @countable_17 + ISNULL(@cur_countable_17,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_14 = @rec_count_14 + CASE WHEN @cur_countable_14 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_15 = @rec_count_15 + CASE WHEN @cur_countable_15 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_16 = @rec_count_16 + CASE WHEN @cur_countable_16 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_17 = @rec_count_17 + CASE WHEN @cur_countable_17 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 19
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)
				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)
				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)
				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)
				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)
				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)
				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)
				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)
				SET @countable_14 = @countable_14 + ISNULL(@cur_countable_14,0)
				SET @countable_15 = @countable_15 + ISNULL(@cur_countable_15,0)
				SET @countable_16 = @countable_16 + ISNULL(@cur_countable_16,0)
				SET @countable_17 = @countable_17 + ISNULL(@cur_countable_17,0)
				SET @countable_18 = @countable_18 + ISNULL(@cur_countable_18,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_14 = @rec_count_14 + CASE WHEN @cur_countable_14 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_15 = @rec_count_15 + CASE WHEN @cur_countable_15 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_16 = @rec_count_16 + CASE WHEN @cur_countable_16 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_17 = @rec_count_17 + CASE WHEN @cur_countable_17 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_18 = @rec_count_18 + CASE WHEN @cur_countable_18 IS NULL THEN 0 ELSE 1 END
			END
			ELSE IF @countable_count = 20
			BEGIN
				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)
				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)
				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)
				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)
				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)
				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)
				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)
				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)
				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)
				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)
				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)
				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)
				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)
				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)
				SET @countable_14 = @countable_14 + ISNULL(@cur_countable_14,0)
				SET @countable_15 = @countable_15 + ISNULL(@cur_countable_15,0)
				SET @countable_16 = @countable_16 + ISNULL(@cur_countable_16,0)
				SET @countable_17 = @countable_17 + ISNULL(@cur_countable_17,0)
				SET @countable_18 = @countable_18 + ISNULL(@cur_countable_18,0)
				SET @countable_19 = @countable_19 + ISNULL(@cur_countable_19,0)

				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_14 = @rec_count_14 + CASE WHEN @cur_countable_14 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_15 = @rec_count_15 + CASE WHEN @cur_countable_15 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_16 = @rec_count_16 + CASE WHEN @cur_countable_16 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_17 = @rec_count_17 + CASE WHEN @cur_countable_17 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_18 = @rec_count_18 + CASE WHEN @cur_countable_18 IS NULL THEN 0 ELSE 1 END
				SET @rec_count_19 = @rec_count_19 + CASE WHEN @cur_countable_19 IS NULL THEN 0 ELSE 1 END
			END -- up to 20 countables
		END -- pass 1 (count for) or 2 (contributing to the counters)
	END -- @FetchStatusCalc = 0

-- Process the next record
IF @countable_count = 1
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0
END
ELSE IF @countable_count = 2
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1
END
ELSE IF @countable_count = 3
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2
END
ELSE IF @countable_count = 4
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3
END
ELSE IF @countable_count = 5
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4
END
ELSE IF @countable_count = 6
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5
END
ELSE IF @countable_count = 7
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6
END
ELSE IF @countable_count = 8
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7
END
ELSE IF @countable_count = 9
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8
END
ELSE IF @countable_count = 10
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9
END
ELSE IF @countable_count = 11
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10
END
ELSE IF @countable_count = 12
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11
END
ELSE IF @countable_count = 13
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12
END
ELSE IF @countable_count = 14
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13
END
ELSE IF @countable_count = 15
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13,@cur_countable_14
END
ELSE IF @countable_count = 16
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15
END
ELSE IF @countable_count = 17
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16
END
ELSE IF @countable_count = 18
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16,@cur_countable_17
END
ELSE IF @countable_count = 19
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16,@cur_countable_17,
	@cur_countable_18
END
ELSE IF @countable_count = 20
BEGIN
	FETCH NEXT FROM calc_cursor INTO
	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,
	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,
	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,
	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16,@cur_countable_17,
	@cur_countable_18,@cur_countable_19
END -- fetch next

SET @FetchStatusCalc = @@FETCH_STATUS
END -- loop

CLOSE calc_cursor
DEALLOCATE calc_cursor

END -- of the linear approach 12/31/2002

----------------------------------------------------------------
-- Retrieve the result set
----------------------------------------------------------------
SET @SQLStmt = ''SET @SQLStmt =
N'SELECT tp1.id_sess, au.id_parent_sess,
   au.id_view AS c_ViewId,
   tp1.id_acc AS c__PayingAccount,
   tp1.id_payee AS c__AccountID,
   au.dt_crt AS c_CreationDate,
   tp1.dt_session AS c_SessionDate '
	+ CAST(@input_FIRST_PASS_PV_PROPERTIES_ALIASED AS nvarchar(4000))
	+ CAST(@input_COUNTER_FORMULAS_ALIASES AS nvarchar(2000)) + N',
   au.id_pi_template AS c__PriceableItemTemplateID,
   au.id_pi_instance AS c__PriceableItemInstanceID,
   au.id_prod AS c__ProductOfferingID,
   tp1.ui_dt_start AS c_BillingIntervalStart,
   tp1.ui_dt_end AS c_BillingIntervalEnd,
   tp1.pci_dt_start AS c_AggregateIntervalStart,
   tp1.pci_dt_end AS c_AggregateIntervalEnd
FROM ' + CAST(@tmp_tbl_name1 AS nvarchar(50)) + N' tp1, '
	+ CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' tp2, t_acc_usage au INNER JOIN '
	+ CAST(@input_FIRST_PASS_PV_TABLE AS nvarchar(2000))
	+ N' firstpasspv on firstpasspv.id_sess = au.id_sess and au.id_usage_interval=firstpasspv.id_usage_interval
WHERE tp2.id_sess = tp1.id_sess
AND au.id_sess = tp1.id_sess
ORDER BY ' + CAST(@input_COMPOUND_ORDERING AS nvarchar(2000)) + N' tp1.id_acc, tp1.dt_session'
SET @output_SQLStmt_SELECT = @SQLStmt
SET @SQLStmt = 'DROP TABLE ' + @tmp_tbl_name2
EXEC sp_executesql @SQLStmt
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
SET @output_SQLStmt_DROPTMPTBL1 = 'DROP TABLE ' + @tmp_tbl_name1
SET @output_SQLStmt_DROPTMPTBL2 = 'DROP TABLE ' + @tmp_tbl_name3

--PRINT 'completed: all'
--PRINT CONVERT(char, getdate(), 109)

SET @return_code = 0
RETURN 0

FatalErrorCursor_calc:
	CLOSE calc_cursor
	DEALLOCATE calc_cursor

FatalError:
	SET @return_code = -1

	-- Added on 2/19/2003
	SET @SQLStmt = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'''
			+ CAST(@tmp_tbl_name1 AS nvarchar(50))
			+ N''') and OBJECTPROPERTY(id, N''IsUserTable'') = 1)'
			+ N' DROP TABLE ' + CAST(@tmp_tbl_name1 AS nvarchar(50))
	-- PRINT @SQLStmt
	EXEC sp_executesql @SQLStmt

	SET @SQLStmt = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'''			+ CAST(@tmp_tbl_name12 AS nvarchar(50))
			+ N''') and OBJECTPROPERTY(id, N''IsUserTable'') = 1)'
			+ N' DROP TABLE ' + CAST(@tmp_tbl_name12 AS nvarchar(50))
	-- PRINT @SQLStmt
	EXEC sp_executesql @SQLStmt

	SET @SQLStmt = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'''
			+ CAST(@tmp_tbl_name2 AS nvarchar(50))
			+ N''') and OBJECTPROPERTY(id, N''IsUserTable'') = 1)'
			+ N' DROP TABLE ' + CAST(@tmp_tbl_name2 AS nvarchar(50))
	-- PRINT @SQLStmt
	EXEC sp_executesql @SQLStmt

	SET @SQLStmt = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'''
			+ CAST(@tmp_tbl_name3 AS nvarchar(50))
			+ N''') and OBJECTPROPERTY(id, N''IsUserTable'') = 1)'
			+ N' DROP TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50))
	-- PRINT @SQLStmt
	EXEC sp_executesql @SQLStmt

	RETURN -1
END
