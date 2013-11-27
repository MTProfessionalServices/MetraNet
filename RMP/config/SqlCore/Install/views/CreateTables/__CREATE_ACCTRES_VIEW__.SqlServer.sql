
CREATE VIEW T_VW_ACCTRES
(ID_ACC, NM_LOGIN, NM_SPACE, PAYER_ID_USAGE_CYCLE, C_PRICELIST, 
ID_PAYER, PAYER_START, PAYER_END,  STATUS, STATE_START, STATE_END, CURRENCY ) 
AS SELECT
	amap.id_acc, amap.nm_login, amap.nm_space, payer_uc.id_usage_cycle, avi.c_pricelist,
	redir.id_payer, 
	case when redir.vt_start is NULL then dbo.MTMinDate() else redir.vt_start end,
	case when redir.vt_end is NULL then dbo.MTMaxDate() else redir.vt_end end,
	ast.status, ast.vt_start, ast.vt_end, tav.c_currency
FROM dbo.t_account_mapper amap
INNER JOIN dbo.t_av_internal avi ON avi.id_acc = amap.id_acc
INNER JOIN dbo.t_account_state ast ON ast.id_acc = amap.id_acc
INNER JOIN t_payment_redirection redir on redir.id_payee = avi.id_acc
LEFT OUTER JOIN t_av_internal tav on tav.id_acc = redir.id_payer
LEFT OUTER JOIN t_acc_usage_cycle payer_uc on payer_uc.id_acc = redir.id_payer
	