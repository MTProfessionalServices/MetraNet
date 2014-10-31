
create or replace force  view T_VW_ACCTRES_BYID
(ID_ACC, PAYER_ID_USAGE_CYCLE, C_PRICELIST, ID_PAYER, PAYER_START, PAYER_END,  STATUS, STATE_START, STATE_END, CURRENCY ) 
AS SELECT	
 acc.id_acc,
 payer_uc.id_usage_cycle,
 payeeinternal.c_pricelist,
 pr.id_payer,
 case when pr.vt_start is NULL then dbo.MTMinDate() else pr.vt_start end,
 case when pr.vt_end is NULL then dbo.MTMaxDate() else pr.vt_end end, 
 st.status,
 st.vt_start,
 st.vt_end,
 payerinternal.c_currency
from t_account acc
inner join t_payment_redirection pr on acc.id_acc = pr.id_payee	
inner join t_account_state st on st.id_acc = acc.id_acc         
inner join t_av_internal payeeinternal on payeeinternal.id_acc = acc.id_acc
left outer join t_av_internal payerinternal on payerinternal.id_acc = pr.id_payer
left outer join t_acc_usage_cycle payer_uc on payer_uc.id_acc = pr.id_payer
  