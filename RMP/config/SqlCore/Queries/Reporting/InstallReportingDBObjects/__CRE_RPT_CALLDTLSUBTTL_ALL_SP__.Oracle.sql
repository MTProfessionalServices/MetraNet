
CREATE OR REPLACE PROCEDURE MTSP_RPT_CALLDTLSUBTTL_ALL
(p_status OUT number,
 p_sqlcode OUT number,
 p_sqlerrm OUT varchar2)
AS
BEGIN  /* of the SP */
DECLARE
	v_id_rpt number(38);
	v_name varchar2(100);
	/* p_by_id_acc number; */
	/* p_id_acc number; */
	p_dt_start date;
	p_dt_end date;
	p_rpt_name varchar2(500);

BEGIN  /* of the main block */
p_status := -1;

p_dt_start := TO_DATE('1/1/1970','mm/dd/yyyy');
p_dt_end := TO_DATE('1/1/2038','mm/dd/yyyy')+numtodsinterval(-1,'second');

/*
p_dt_start := SYSDATE;
p_dt_start := TRUNC(p_dt_start)-1;
p_dt_end := TRUNC(p_dt_start)+numtodsinterval(-1,'second');
*/
p_rpt_name := 'Call Detail Report with Subtotal - ' || RTRIM(TO_CHAR(p_dt_start,'mm/dd/yyyy hh24:mi:ss')) || ' to '
	|| RTRIM(TO_CHAR(p_dt_end,'mm/dd/yyyy hh24:mi:ss'));
/* DBMS_OUTPUT.PUT_LINE('Started: ' || TO_CHAR(SYSTIMESTAMP, 'mm-dd-yyyy hh24:mi:ssxff')); */
SELECT seq_dm_rpt_calldtl.NEXTVAL INTO v_id_rpt FROM DUAL;

/*  Empty the reporting tables for now only */
EXECUTE IMMEDIATE ('TRUNCATE TABLE dm_t_rptrst_calldtl_detail');
EXECUTE IMMEDIATE ('DELETE FROM dm_t_rptrst_calldtl_parent');
COMMIT;

INSERT INTO dm_t_rptrst_calldtl_parent
(ID_RPT, BY_ID_ACC, RPT_DT_START, RPT_DT_END, RPT_NAME, RPT_STATUS, PARM_DT_START,
 PARM_DT_END, PARM_ID_ACC_FOR, RPT_ACC_NAME_FOR, RPT_ERR_DESC)
VALUES
(v_id_rpt, -1, SYSDATE, NULL, p_rpt_name, 'S', 
p_dt_start, p_dt_end, NULL, NULL, NULL);
COMMIT;

/* DBMS_OUTPUT.PUT_LINE('After insert into the report parent table: ' || TO_CHAR(SYSTIMESTAMP, 'mm-dd-yyyy hh24:mi:ssxff')); */

/*  reporting results data */
INSERT INTO dm_t_rptrst_calldtl_detail 
(id_rpt, top_lvl_1, top_lvl_1_desc, top_lvl_2, top_lvl_2_desc, top_lvl_3, top_lvl_3_desc,
 top_lvl_4, top_lvl_4_desc, top_lvl_5, top_lvl_5_desc, top_lvl_6, top_lvl_6_desc,
 top_lvl_7, top_lvl_7_desc, top_lvl_8, top_lvl_8_desc, top_lvl_9, top_lvl_9_desc, top_lvl_10, top_lvl_10_desc,
 id_acc, id_payee, id_sess, id_parent_sess, c_calldate, c_calltime, c_calllength, c_callprice, lvl_num)
SELECT 
	v_id_rpt,
	tmp.TOP_LVL_1, tmp.TOP_LVL_1_DESC, 
	tmp.TOP_LVL_2, tmp.TOP_LVL_2_DESC, 
	tmp.TOP_LVL_3, tmp.TOP_LVL_3_DESC, 
	tmp.TOP_LVL_4, tmp.TOP_LVL_4_DESC, 
	tmp.TOP_LVL_5, tmp.TOP_LVL_5_DESC, 
	tmp.TOP_LVL_6, tmp.TOP_LVL_6_DESC, 
	tmp.TOP_LVL_7, tmp.TOP_LVL_7_DESC, 
	tmp.TOP_LVL_8, tmp.TOP_LVL_8_DESC, 
	tmp.TOP_LVL_9, tmp.TOP_LVL_9_DESC, 
	tmp.TOP_LVL_10, tmp.TOP_LVL_10_DESC, 
	au.id_acc, 
	au.id_payee,
	au.id_sess,
	au.id_parent_sess,
	TO_CHAR(au.dt_session, 'dd-Mon-yyyy') c_calldate,
	RTRIM(TO_CHAR(au.dt_session, 'hh:mi:ss AM'))||' GMT' c_calltime,
	/* pvcc.C_DISCONNECTTIME - pvcc.C_CONNECTTIME c_calllength, */
	LTRIM(RTRIM(TO_CHAR(FLOOR((pvcc.C_DISCONNECTTIME - pvcc.C_CONNECTTIME)*24)))) || ':' ||
	LTRIM(RTRIM(TO_CHAR(FLOOR((pvcc.C_DISCONNECTTIME - pvcc.C_CONNECTTIME)*24*60) - FLOOR((pvcc.C_DISCONNECTTIME - pvcc.C_CONNECTTIME)*24) * 60, '09'))) || ':' ||
	LTRIM(RTRIM(TO_CHAR((pvcc.C_DISCONNECTTIME - pvcc.C_CONNECTTIME)*24*60*60 - FLOOR((pvcc.C_DISCONNECTTIME - pvcc.C_CONNECTTIME)*24*60)*60, '09' ))) c_calllength, 
	/* pvcc.C_CONNECTIONMINUTES c_calllength, */
	au.amount callprice,
	CASE
	WHEN tmp.TOP_LVL_10 > -1 THEN 10
	WHEN tmp.TOP_LVL_10 = -1 AND tmp.TOP_LVL_9 > -1 THEN 9
	WHEN tmp.TOP_LVL_10 = -1 AND tmp.TOP_LVL_9 = -1 AND tmp.TOP_LVL_8 > -1 THEN 8
	WHEN tmp.TOP_LVL_10 = -1 AND tmp.TOP_LVL_9 = -1 AND tmp.TOP_LVL_8 = -1 AND tmp.TOP_LVL_7 > -1 THEN 7
	WHEN tmp.TOP_LVL_10 = -1 AND tmp.TOP_LVL_9 = -1 AND tmp.TOP_LVL_8 = -1 
		AND tmp.TOP_LVL_7 = -1 AND tmp.TOP_LVL_6 > -1 THEN 6
	WHEN tmp.TOP_LVL_10 = -1 AND tmp.TOP_LVL_9 = -1 AND tmp.TOP_LVL_8 = -1 
		AND tmp.TOP_LVL_7 = -1 AND tmp.TOP_LVL_6 = -1 AND tmp.TOP_LVL_5 > -1 THEN 5
	WHEN tmp.TOP_LVL_10 = -1 AND tmp.TOP_LVL_9 = -1 AND tmp.TOP_LVL_8 = -1 
		AND tmp.TOP_LVL_7 = -1 AND tmp.TOP_LVL_6 = -1 AND tmp.TOP_LVL_5 = -1 AND tmp.TOP_LVL_4 > -1 THEN 4
	WHEN tmp.TOP_LVL_10 = -1 AND tmp.TOP_LVL_9 = -1 AND tmp.TOP_LVL_8 = -1 
		AND tmp.TOP_LVL_7 = -1 AND tmp.TOP_LVL_6 = -1 AND tmp.TOP_LVL_5 = -1 AND tmp.TOP_LVL_4 = -1 AND tmp.TOP_LVL_3 > -1 THEN 3
	WHEN tmp.TOP_LVL_10 = -1 AND tmp.TOP_LVL_9 = -1 AND tmp.TOP_LVL_8 = -1 
		AND tmp.TOP_LVL_7 = -1 AND tmp.TOP_LVL_6 = -1 AND tmp.TOP_LVL_5 = -1 AND tmp.TOP_LVL_4 = -1 AND tmp.TOP_LVL_3 = -1 
		AND tmp.TOP_LVL_2 > -1 THEN 2
	ELSE 1
	END
FROM
	t_acc_usage au,
	t_pv_audioconfconnection pvcc,
	DM_T_SUM_ACC_LVL_FLAT tmp
WHERE	/* tmp.top_lvl_1 = p_id_acc AND  */
	au.id_payee = tmp.gen_0 AND
	au.dt_session BETWEEN p_dt_start AND p_dt_end AND 
	au.dt_session BETWEEN tmp.vt_start AND tmp.vt_end AND 
	pvcc.id_sess = au.id_sess and au.id_usage_interval=pvcc.id_usage_interval;
UPDATE dm_t_rptrst_calldtl_parent
SET RPT_STATUS = 'C',
    RPT_DT_END = SYSDATE
WHERE ID_RPT = v_id_rpt;
COMMIT;
p_status := 0;

RETURN;

EXCEPTION WHEN OTHERS THEN
	p_sqlcode := SQLCODE;
	p_sqlerrm := SQLERRM;

	UPDATE dm_t_rptrst_calldtl_parent
	SET RPT_STATUS = 'Failed',
	    RPT_ERR_DESC = 'Error code: ' || RTRIM(TO_CHAR(p_sqlcode)) || '. Error Message: ' || RTRIM(p_sqlerrm)
	WHERE ID_RPT = v_id_rpt;

	COMMIT;
	RETURN;
END;  /* of the main block */

END;  /* of the SP */
	   