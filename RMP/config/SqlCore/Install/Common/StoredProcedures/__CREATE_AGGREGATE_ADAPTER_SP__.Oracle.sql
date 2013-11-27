
CREATE OR REPLACE PROCEDURE MTSP_RATE_AGGREGATE_CHARGE
(v_in_USAGE_INTERVAL number,
v_in_TEMPLATE_ID number,
v_in_FIRST_PASS_PV_VIEWID number,
v_in_FIRST_PASS_PV_TABLE varchar2,
v_in_COUNTABLE_VIEWIDS varchar2,
v_in_COUNTABLE_OJOINS varchar2,
v_in_1STPASS_PV_PROP_ALIASED varchar2,
v_in_COUNTABLE_PROPERTIES varchar2,
v_in_COUNTER_FORMULAS varchar2,
v_in_ACCOUNT_FILTER varchar2,
v_in_COMPOUND_ORDERING varchar2,
v_in_COUNTER_FORMULAS_ALIASES varchar2,
v_out_SQLStmt_SELECT OUT varchar2,
v_out_SQLStmt_DROPTMPTBL1 OUT varchar2,
v_out_SQLStmt_DROPTMPTBL2 OUT varchar2,
v_return_code OUT number)
IS
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
** Created On: 1/15/2002
** Last Modified On: 2/25/2002
** Last Modified On: 5/7/2002
** Last Modified On: 5/31/2002
** Last Modified On: 6/7/2002
** Last Modified On: 6/10/2002
** Last Modified On: 6/13/2002
**
**********************************************************************/
DECLARE
v_au_id_usage_interval number(12);
v_au_id_usage_cycle number(12);
v_au_bc_dt_start date;
v_au_bc_dt_end date;
v_ag_dt_start date;
v_SQLStmt varchar2(4000);
v_sessionid VARCHAR2(30);
v_timestamp VARCHAR2(30);
v_tmp_tbl_name0 varchar2(30);
v_tmp_tbl_name1 varchar2(30);
v_tmp_tbl_name12 varchar2(30);
v_tmp_tbl_name2 varchar2(30);
v_tmp_tbl_name3 varchar2(30);
/* v_tmp_tbl_name4 varchar2(30); */
v_debug_flag number(1);
v_sqlcode number(12);
v_sqlerrm varchar2(200);

BEGIN
v_debug_flag := 1;

IF v_debug_flag = 1 THEN
  INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc)
  VALUES ('AggRate', SYSDATE, 'Started at ' || TO_CHAR(SYSDATE, 'mm/dd/yyyy hh24:mi:ss'));
END IF;

/* ---------------------------------------- */
/*  Construct the temp. table names */
/* ---------------------------------------- */
SELECT RTRIM(TO_CHAR(USERENV('sessionid'))),RTRIM(TO_CHAR(SYSTIMESTAMP, 'YYYYDDDHHMISSFF'))
INTO v_sessionid, v_timestamp
FROM dual;
v_tmp_tbl_name0 := 't' || RTRIM(v_timestamp) || '_' || RTRIM(v_sessionid) || '_0';
v_tmp_tbl_name1 := 't' || RTRIM(v_timestamp) || '_' || RTRIM(v_sessionid) || '_1';
v_tmp_tbl_name12 := 't' || RTRIM(v_timestamp) || '_' || RTRIM(v_sessionid) || '_12';
v_tmp_tbl_name2 := 't' || RTRIM(v_timestamp) || '_' || RTRIM(v_sessionid) || '_2';
v_tmp_tbl_name3 := 't' || RTRIM(v_timestamp) || '_' || RTRIM(v_sessionid) || '_3';
/* v_tmp_tbl_name4 := 't' || RTRIM(v_timestamp) || '_' || RTRIM(v_sessionid) || '_4'; */

/* ---------------------------------------- */
/*  Obtain the billing start and end dates: */
/*  One billing number(12)erval has only one pair of start and end dates */
/*  Retrieve and then store them in local variables */
/* --------------------------------------------- */
BEGIN
SELECT
  ui.id_interval,
  ui.id_usage_cycle,
  ui.dt_start,
  ui.dt_end
INTO
  v_au_id_usage_interval,
  v_au_id_usage_cycle,
  v_au_bc_dt_start,
  v_au_bc_dt_end
FROM
  t_usage_interval ui
WHERE
  ui.id_interval = v_in_USAGE_INTERVAL;

EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
END;

IF v_debug_flag = 1 THEN
  INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc)
  VALUES ('AggRate', SYSDATE, 'After selecting from the t_usage_interval table: ' || TO_CHAR(SYSDATE, 'mm/dd/yyyy hh24:mi:ss'));
END IF;

/* DBMS_OUTPUT.PUT_LINE( v_au_id_usage_interval); */
/* DBMS_OUTPUT.PUT_LINE( v_au_id_usage_cycle); */
/* DBMS_OUTPUT.PUT_LINE( to_char(v_au_bc_dt_start, 'mm/dd/yyyy hh24:mi:ss')); */
/* DBMS_OUTPUT.PUT_LINE( to_char(v_au_bc_dt_end, 'mm/dd/yyyy hh24:mi:ss')); */
/* DBMS_OUTPUT.PUT_LINE( ' '); */

/* --------------------------------------------- */
/*  Obtain the earliest aggragate starting date: */
/*  Modified on 5/31/02 to take the group sub into consideration */
/*  Modified on 6/7/02 to make the fix */
/* --------------------------------------------- */
v_SQLStmt := '';
v_SQLStmt :=
'CREATE TABLE ' || v_tmp_tbl_name0 ||
' AS SELECT au.dt_session, ag.id_usage_cycle id_pc_cycle,
NVL(gs.id_usage_cycle,auc.id_usage_cycle) id_usage_cycle
FROM
  t_acc_usage au
  INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = au.id_payee
  INNER JOIN t_usage_interval ui ON ui.id_interval = au.id_usage_interval
  INNER JOIN t_aggregate ag ON ag.id_prop = NVL(au.id_pi_instance, au.id_pi_template)
  LEFT OUTER JOIN t_gsubmember gsm ON gsm.id_acc = au.id_payee
    AND au.dt_session BETWEEN gsm.vt_start AND gsm.vt_end
  LEFT OUTER JOIN t_group_sub gs ON gs.id_group = gsm.id_group
WHERE
  au.id_view = ' || v_in_FIRST_PASS_PV_VIEWID || ' AND
  au.id_usage_interval = ' || v_in_USAGE_INTERVAL || ' AND
  au.id_pi_template = ' || v_in_TEMPLATE_ID || ' AND
  ui.id_interval = ' || v_in_USAGE_INTERVAL;
EXECUTE IMMEDIATE (v_SQLStmt);
v_SQLStmt := '';
v_SQLStmt :=
'SELECT MIN(CASE WHEN tmp1.id_pc_cycle IS NULL THEN ui.dt_start ELSE pci.dt_start END)
FROM ' || v_tmp_tbl_name0 || ' tmp1
  LEFT OUTER JOIN t_pc_interval pci ON pci.id_cycle = tmp1.id_pc_cycle
    AND tmp1.dt_session BETWEEN pci.dt_start AND pci.dt_end
  LEFT OUTER JOIN t_usage_interval ui ON ui.id_usage_cycle = tmp1.id_usage_cycle
    AND tmp1.dt_session BETWEEN ui.dt_start AND ui.dt_end ';
EXECUTE IMMEDIATE (v_SQLStmt) INTO v_ag_dt_start;
EXECUTE IMMEDIATE ('DROP TABLE ' || v_tmp_tbl_name0 );

IF v_debug_flag = 1 THEN
  INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc)
  VALUES ('AggRate', SYSDATE, 'After selecting the minimum pci.dt_start: ' || TO_CHAR(SYSDATE, 'mm/dd/yyyy hh24:mi:ss'));

END IF;

/* --------------------------------------------- */
/*  If no aggregate cycle then use billing cycle */
IF v_ag_dt_start IS NULL THEN
  v_ag_dt_start := v_au_bc_dt_start;
END IF;

/* ----- */
/*  Firstpass records */
/* ----- */
/*  Added on 6/7/2002 */
v_SQLStmt := '';
v_SQLStmt :=
'CREATE TABLE ' || v_tmp_tbl_name12 ||
' AS SELECT
  au.id_sess,
  au.id_acc,
  au.id_payee,
  au.dt_session,
  ui.dt_start ui_dt_start,
  ui.dt_end ui_dt_end,
  /* Changed on 5/7/2002 to take the group subscription dates into consideration */
  CASE WHEN
  CASE WHEN
    gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
    THEN 1 ELSE 0
  END group_acc_flag,
  CASE WHEN
    gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
    THEN gsm.id_group ELSE au.id_payee
  END group_acc_id,
  ag.id_usage_cycle pci_id_cycle,
  NVL(gs.id_usage_cycle,auc.id_usage_cycle) ui_id_cycle
FROM
  t_acc_usage au
  INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = au.id_payee
  LEFT OUTER JOIN t_gsubmember gsm ON gsm.id_acc = au.id_payee
    AND au.dt_session BETWEEN gsm.vt_start AND gsm.vt_end
  LEFT OUTER JOIN t_group_sub gs ON gs.id_group = gsm.id_group,
  t_usage_interval ui,
  t_aggregate ag
WHERE
  au.id_view = ' || v_in_FIRST_PASS_PV_VIEWID || ' AND
  au.id_usage_interval = ' || v_in_USAGE_INTERVAL || ' AND
  au.id_pi_template = ' || v_in_TEMPLATE_ID || ' AND
  ui.id_interval = au.id_usage_interval AND
  ag.id_prop = NVL(au.id_pi_instance, au.id_pi_template) AND
  au.dt_session BETWEEN TO_DATE(''' || TO_CHAR(v_ag_dt_start, 'mmddyyyyhh24miss') || ''',''mmddyyyyhh24miss'')
            AND TO_DATE(''' || TO_CHAR(v_au_bc_dt_end, 'mmddyyyyhh24miss') || ''',''mmddyyyyhh24miss'')'
  || v_in_ACCOUNT_FILTER;

/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,1,250)); */
/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,251,250)); */
/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,501,250)); */
/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,751,250)); */

EXECUTE IMMEDIATE (v_SQLStmt);

v_SQLStmt := '';
v_SQLStmt :=
'CREATE TABLE ' || v_tmp_tbl_name1 ||
' AS SELECT
  tmp.id_sess,
  tmp.id_acc,
  tmp.id_payee,
  tmp.dt_session,
  tmp.ui_dt_start,
  tmp.ui_dt_end,
  CASE WHEN pci.id_cycle IS NOT NULL THEN pci.dt_start ELSE ui.dt_start END pci_dt_start,
  CASE WHEN pci.id_cycle IS NOT NULL THEN pci.dt_end ELSE ui.dt_end END pci_dt_end,
  tmp.group_acc_flag,
  tmp.group_acc_id
FROM ' || v_tmp_tbl_name12 || ' tmp
  LEFT OUTER JOIN t_pc_interval pci ON pci.id_cycle = tmp.pci_id_cycle
    AND tmp.dt_session BETWEEN pci.dt_start AND pci.dt_end
  LEFT OUTER JOIN t_usage_interval ui ON ui.id_usage_cycle = tmp.ui_id_cycle
    AND tmp.dt_session BETWEEN ui.dt_start AND ui.dt_end ';

/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,1,250)); */
/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,251,250)); */
/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,501,250)); */
/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,751,250)); */

EXECUTE IMMEDIATE (v_SQLStmt);

IF v_debug_flag = 1 THEN
  INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc)
  VALUES ('AggRate', SYSDATE, 'After inserting to the zn_ningtemp table: '|| TO_CHAR(SYSDATE, 'mm/dd/yyyy hh24:mi:ss'));
END IF;

EXECUTE IMMEDIATE ('DROP TABLE ' || v_tmp_tbl_name12 );


/* ----- */
/*  Counter records */
/* ----- */
v_SQLStmt := '';
/* Changed on 5/3 to take the group subscription dates into consideration */
IF RTRIM(v_in_COUNTABLE_VIEWIDS) = '' OR v_in_COUNTABLE_VIEWIDS IS NULL THEN
v_SQLStmt :=
'CREATE TABLE ' || v_tmp_tbl_name2 ||
' AS SELECT
  au.id_sess,
  au.id_acc,
  au.id_payee,
  au.dt_session,
  au.id_pi_template,
  ui.dt_start ui_dt_start,
  ui.dt_end ui_dt_end,
  CASE WHEN
    gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
    THEN 1 ELSE 0
  END group_acc_flag,
  CASE WHEN
    gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
    THEN gsm.id_group ELSE au.id_payee
  END group_acc_id '
  || v_in_COUNTABLE_PROPERTIES ||
' FROM
  t_acc_usage au
  /* Changed on 5/7 to take the group subscription dates into consideration */
  LEFT OUTER JOIN t_gsubmember gsm ON gsm.id_acc = au.id_payee
    AND au.dt_session BETWEEN gsm.vt_start AND gsm.vt_end
  LEFT OUTER JOIN t_group_sub gs ON gs.id_group = gsm.id_group ' || v_in_COUNTABLE_OJOINS || ',
  t_usage_interval ui,
  t_aggregate ag
WHERE
  au.id_view IS NULL AND
  ui.id_interval = au.id_usage_interval AND
  ag.id_prop = NVL(au.id_pi_instance, au.id_pi_template) AND
  au.dt_session BETWEEN TO_DATE(''' || TO_CHAR(v_ag_dt_start, 'mmddyyyyhh24miss') || ''',''mmddyyyyhh24miss'')
            AND TO_DATE(''' || TO_CHAR(v_au_bc_dt_end, 'mmddyyyyhh24miss') || ''',''mmddyyyyhh24miss'')'
  || v_in_ACCOUNT_FILTER ;
ELSE
v_SQLStmt :=
'CREATE TABLE ' || v_tmp_tbl_name2 ||
' AS SELECT
  au.id_sess,
  au.id_acc,
  au.id_payee,
  au.dt_session,
  au.id_pi_template,
  ui.dt_start ui_dt_start,
  ui.dt_end ui_dt_end,
  /* Changed on 5/7 to take the group subscription dates into consideration */
  CASE WHEN
    gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
    THEN 1 ELSE 0
  END group_acc_flag,
  CASE WHEN
    gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
    THEN gsm.id_group ELSE au.id_payee
  END group_acc_id '
  || v_in_COUNTABLE_PROPERTIES ||
' FROM
  t_acc_usage au
  /* Changed on 5/7 to take the group subscription dates into consideration */
  LEFT OUTER JOIN t_gsubmember gsm ON gsm.id_acc = au.id_payee
    AND au.dt_session BETWEEN gsm.vt_start AND gsm.vt_end
  LEFT OUTER JOIN t_group_sub gs ON gs.id_group = gsm.id_group ' || v_in_COUNTABLE_OJOINS || ',
  t_usage_interval ui,
  t_aggregate ag
WHERE
  (au.id_view IS NULL OR au.id_view in (' || v_in_COUNTABLE_VIEWIDS || ')) AND
  ui.id_interval = au.id_usage_interval AND
  ag.id_prop = NVL(au.id_pi_instance, au.id_pi_template) AND
  au.dt_session BETWEEN TO_DATE(''' || TO_CHAR(v_ag_dt_start, 'mmddyyyyhh24miss') || ''',''mmddyyyyhh24miss'')
            AND TO_DATE(''' || TO_CHAR(v_au_bc_dt_end, 'mmddyyyyhh24miss') || ''',''mmddyyyyhh24miss'')'
  || v_in_ACCOUNT_FILTER ;
END IF;

EXECUTE IMMEDIATE (v_SQLStmt);

IF v_debug_flag = 1 THEN
  INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc)
  VALUES ('AggRate', SYSDATE, 'After inserting to the zn_ningtemp1 table: '|| TO_CHAR(SYSDATE, 'mm/dd/yyyy hh24:mi:ss'));
END IF;

/* ----- */
/*  Calculate the counters */
/* ----- */
v_SQLStmt := '';
v_SQLStmt :=
'CREATE TABLE ' || v_tmp_tbl_name3 ||
' AS SELECT tp1.id_sess ' || v_in_COUNTER_FORMULAS ||
' FROM ' || v_tmp_tbl_name1 ||
' tp1 LEFT OUTER JOIN ' || v_tmp_tbl_name2 ||
  ' tp2 ON tp2.group_acc_flag = tp1.group_acc_flag AND tp2.group_acc_id = tp1.group_acc_id
  AND tp2.id_pi_template = ' || v_in_TEMPLATE_ID ||
' AND tp2.dt_session BETWEEN tp1.pci_dt_start AND tp1.pci_dt_end
  AND (tp2.ui_dt_end < tp1.ui_dt_end
    OR (tp2.ui_dt_end = tp1.ui_dt_end
    AND tp2.dt_session < tp1.dt_session)
    OR (tp2.ui_dt_end = tp1.ui_dt_end
    AND tp2.dt_session = tp1.dt_session
    AND tp2.id_sess < tp1.id_sess))
GROUP BY tp1.id_sess';

/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,1,250)); */
/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,251,250)); */
/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,501,250)); */
/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,751,250)); */

EXECUTE IMMEDIATE (v_SQLStmt);
EXECUTE IMMEDIATE ('DROP TABLE ' || v_tmp_tbl_name2 );

IF v_debug_flag = 1 THEN
  INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc)
  VALUES ('AggRate', SYSDATE, 'After inserting to the zn_ningtemp2 table: '|| TO_CHAR(SYSDATE, 'mm/dd/yyyy hh24:mi:ss'));
END IF;

/* ----- */
/*  Retrieve the result set */
/* ----- */
v_SQLStmt := '';
v_SQLStmt :=
'SELECT tp1.id_sess, au.id_parent_sess,
   au.id_view AS c_ViewId,
   tp1.id_acc AS c__AccountID,
   au.dt_crt AS c_CreationDate,
   tp1.dt_session AS c_SessionDate '
  || v_in_1STPASS_PV_PROP_ALIASED
  || v_in_COUNTER_FORMULAS_ALIASES || ',
   au.id_pi_template AS c__PriceableItemTemplateID,
   au.id_pi_instance AS c__PriceableItemInstanceID,
   au.id_prod AS c__ProductOfferingID,
   tp1.ui_dt_start AS c_BillingIntervalStart,
   tp1.ui_dt_end AS c_BillingIntervalEnd,
   tp1.pci_dt_start AS c_AggregateIntervalStart,
   tp1.pci_dt_end AS c_AggregateIntervalEnd
FROM ' || v_tmp_tbl_name1 || ' tp1, '
  || v_tmp_tbl_name3 || ' tp2, t_acc_usage au INNER JOIN '
  || v_in_FIRST_PASS_PV_TABLE
  || ' firstpasspv on firstpasspv.id_sess = au.id_sess
WHERE tp2.id_sess = tp1.id_sess
AND au.id_sess = tp1.id_sess
ORDER BY ' || v_in_COMPOUND_ORDERING || ' tp1.id_acc, tp1.dt_session';

/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,1,250)); */
/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,251,250)); */
/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,501,250)); */
/* DBMS_OUTPUT.PUT_LINE(substr(v_SQLStmt,751,250)); */

/* EXECUTE IMMEDIATE (v_SQLStmt); */
/* COMMIT; */
/* EXECUTE IMMEDIATE ('DROP TABLE ' || v_tmp_tbl_name1 ); */
/* EXECUTE IMMEDIATE ('DROP TABLE ' || v_tmp_tbl_name3 ); */

v_out_SQLStmt_SELECT := v_SQLStmt;
v_out_SQLStmt_DROPTMPTBL1 := 'DROP TABLE ' || v_tmp_tbl_name1 ;
v_out_SQLStmt_DROPTMPTBL2 := 'DROP TABLE ' || v_tmp_tbl_name3 ;

IF v_debug_flag = 1 THEN
  INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc)
  VALUES ('AggRate', SYSDATE, 'Completed at: '|| TO_CHAR(SYSDATE, 'mm/dd/yyyy hh24:mi:ss'));
END IF;

v_return_code := 0;
RETURN;

EXCEPTION WHEN OTHERS THEN
  v_sqlcode := SQLCODE;
  v_sqlerrm := SQLERRM;
  v_return_code := -1;
  IF v_debug_flag = 1 THEN
    INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) VALUES
    ('AggRate', SYSDATE,
    'Completed abnormally at '
    || TO_CHAR(SYSDATE,'mm/dd/yyyy hh24:mi:ss')
    || 'ErrCode=' || TO_CHAR(v_sqlcode ) || '; ErrMsg=' || v_sqlerrm );
  END IF;
  RETURN;

END;
END MTSP_RATE_AGGREGATE_CHARGE;

