
CREATE PROCEDURE mtsp_rpt_calldtlsubttl
(@p_by_id_acc int,
 @p_id_acc int,
 @p_dt_start datetime,
 @p_dt_end datetime,
 @p_rpt_name varchar(500),
 @p_id_rpt int OUTPUT,
 @p_status int OUTPUT)
AS
BEGIN  -- of the SP
DECLARE @v_rpt_name varchar(500), @v_name varchar(100), @id_enum_data INT

SET @p_status = -1

-- Obtain the contact type
SELECT @id_enum_data = id_enum_data
FROM t_enum_data
WHERE nm_enum_data = 'METRATECH.COM/ACCOUNTCREATION/CONTACTTYPE/BILL-TO'

-- Obtain the contact name
SELECT @v_name = RTRIM(avc.c_firstname) + ' ' + RTRIM(avc.c_lastname)
FROM t_av_contact avc
WHERE avc.id_acc = @p_id_acc 
AND avc.c_contacttype = @id_enum_data

-- Obtain the report name
IF @p_rpt_name IS NULL
BEGIN
	SET @v_rpt_name = 'Call Detail Report with Subtotal - ' 
	+ RTRIM(CONVERT(CHAR(10), @p_dt_start, 101)) + ' ' + RTRIM(CONVERT(CHAR(8), @p_dt_start, 108)) + ' to '
	+ RTRIM(CONVERT(CHAR(10), @p_dt_end, 101)) + ' ' + RTRIM(CONVERT(CHAR(8), @p_dt_end, 108))
END
ELSE
	SET @v_rpt_name = @p_rpt_name

INSERT INTO dm_t_rptrst_calldtl_parent
(by_id_acc, rpt_dt_start, rpt_dt_end, rpt_name, rpt_status, parm_dt_start,
 parm_dt_end, parm_id_acc_for, rpt_acc_name_for, rpt_err_desc)
VALUES
(@p_by_id_acc, getdate(), NULL, @v_rpt_name, 'S', 
@p_dt_start, @p_dt_end, @p_id_acc, @v_name, NULL)
SET @p_id_rpt = @@IDENTITY

-- reporting results data
INSERT INTO dm_t_rptrst_calldtl_detail
(id_rpt, top_lvl_1, top_lvl_1_desc, top_lvl_2, top_lvl_2_desc, top_lvl_3, top_lvl_3_desc,
 top_lvl_4, top_lvl_4_desc, top_lvl_5, top_lvl_5_desc, top_lvl_6, top_lvl_6_desc,
 top_lvl_7, top_lvl_7_desc, top_lvl_8, top_lvl_8_desc, top_lvl_9, top_lvl_9_desc, top_lvl_10, top_lvl_10_desc,
 id_acc, id_payee, id_sess, id_parent_sess, c_calldate, c_calltime, c_calllength, c_callprice, lvl_num)
SELECT 
	@p_id_rpt,
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
	RTRIM(CONVERT(char(11), au.dt_session, 105)) c_calldate,
	RTRIM(CONVERT(char(11), au.dt_session, 109)) + ' GMT' c_calltime,
	--pvcc.C_DISCONNECTTIME - pvcc.C_CONNECTTIME c_calllength,
	RTRIM(CONVERT(char(10), FLOOR(DATEDIFF(minute, pvcc.C_CONNECTTIME, pvcc.C_DISCONNECTTIME)/60))) + ':' +
	RTRIM(CONVERT(char(2), FLOOR(DATEDIFF(second, pvcc.C_CONNECTTIME, pvcc.C_DISCONNECTTIME)/60)-FLOOR(DATEDIFF(minute, pvcc.C_CONNECTTIME, pvcc.C_DISCONNECTTIME)/60)*60)) + ':' +
	RTRIM(CONVERT(char(2), DATEDIFF(second, pvcc.C_CONNECTTIME, pvcc.C_DISCONNECTTIME)-FLOOR(DATEDIFF(second, pvcc.C_CONNECTTIME, pvcc.C_DISCONNECTTIME)/60)*60)) c_calllength,
	--pvcc.C_CONNECTIONMINUTES c_calllength,
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
WHERE	tmp.top_lvl_1 = @p_id_acc AND 
	au.id_payee = tmp.gen_0 AND
	au.dt_session BETWEEN @p_dt_start AND @p_dt_end AND 
	au.dt_session BETWEEN tmp.vt_start AND tmp.vt_end AND 
	pvcc.id_sess = au.id_sess and au.id_usage_interval=pvcc.id_usage_interval

-- Update the report status
UPDATE dm_t_rptrst_calldtl_parent
SET RPT_STATUS = 'C',
    RPT_DT_END = getdate()
WHERE ID_RPT = @p_id_rpt

SET @p_status = 0

RETURN

END
	   