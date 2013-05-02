
/* Delete all the records that are not archived, we can not use truncate since we cannot refresh MV for archived records */

Delete from %%PAYEE_SESSION%% where id_usage_interval not in 
(select id_interval from t_archive where status = 'A' and tt_end = dbo.mtmaxdate())

/* Insert the records into MV based on t_acc_usage and account table */
Insert into %%PAYEE_SESSION%%
(
id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
TotalAmount,TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,
PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStatetaxAdjAmt,PrebillCntytaxAdjAmt,
PrebillLocaltaxAdjAmt,PrebillOthertaxAdjAmt,PrebillTotaltaxAdjAmt,NumPrebillAdjustments,
PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStatetaxAdjAmt,
PostbillCntytaxAdjAmt,PostbillLocaltaxAdjAmt,PostbillOthertaxAdjAmt,
PostbillTotaltaxAdjAmt,NumPostbillAdjustments,PrebillAdjustedAmount,PostbillAdjustedAmount,NumTransactions
)
select au.id_acc,acc.id_dm_acc,au.id_usage_interval,au.id_prod,au.id_view,au.id_pi_template,au.id_pi_instance,
au.am_currency,au.id_se,convert(datetime,convert(char(10),au.dt_session,120)),
SUM(isnull(au.Amount, 0.0)),
SUM(isnull(au.Tax_Federal, 0.0)),
SUM(isnull(au.Tax_County, 0.0)),
SUM(isnull(au.Tax_Local, 0.0)),
SUM(isnull(au.Tax_Other, 0.0)),
SUM(isnull(au.Tax_State, 0.0)),
SUM(isnull(au.Tax_Federal, 0.0)) + SUM(isnull(au.Tax_State, 0.0)) + SUM(isnull(au.Tax_County, 0.0)) + 
SUM(isnull(au.Tax_Local, 0.0)) + SUM(isnull(au.Tax_Other, 0.0)),
cast (0.0 as numeric(38,6)) as PrebillAdjAmt,
cast (0.0 as numeric(38,6)) as PrebillFedTaxAdjAmt,cast (0.0 as numeric(38,6)) as  PrebillStatetaxAdjAmt,cast (0.0 as numeric(38,6)) as  PrebillCntytaxAdjAmt,
cast (0.0 as numeric(38,6)) as PrebillLocaltaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillOthertaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillTotaltaxAdjAmt,
cast (0.0 as numeric(38,6)) as NumPrebillAdjustments,cast (0.0 as numeric(38,6)) as PostbillAdjAmt,cast (0.0 as numeric(38,6)) as PostbillFedTaxAdjAmt,
cast (0.0 as numeric(38,6)) as PostbillStatetaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillCntytaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillLocaltaxAdjAmt,
cast (0.0 as numeric(38,6)) as PostbillOthertaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillTotaltaxAdjAmt,cast (0.0 as numeric(38,6)) as NumPostbillAdjustments,
SUM(isnull(au.Amount,0.0)) PrebillAdjustedAmount,
SUM(isnull(au.Amount,0.0)) PostbillAdjustedAmount,
COUNT(*) NumTransactions
from  T_ACC_USAGE au inner join t_dm_account acc on au.id_payee=acc.id_acc
and dt_session between vt_start and vt_end
where id_parent_sess is null
group by au.id_acc,acc.id_dm_acc,au.id_usage_interval,convert(datetime,convert(char(10),au.dt_session,120)),au.id_prod,au.id_view, 
au.id_pi_instance,au.id_pi_template,au.am_currency,au.id_se

/* Cleanup the delta tables*/

delete from %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session

/* Insert the records into Delta table for the adjustments */

Insert into %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session
(
id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStatetaxAdjAmt,PrebillCntytaxAdjAmt,
PrebillLocaltaxAdjAmt,PrebillOthertaxAdjAmt,PrebillTotaltaxAdjAmt,PrebillAdjustedAmount,
NumPrebillAdjustments,
PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStatetaxAdjAmt,
PostbillCntytaxAdjAmt,PostbillLocaltaxAdjAmt,PostbillOthertaxAdjAmt,
PostbillTotaltaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments
)
select au.id_acc,acc.id_dm_acc,au.id_usage_interval,au.id_prod,au.id_view,au.id_pi_template,au.id_pi_instance,
au.am_currency,au.id_se,convert(datetime,convert(char(10),au.dt_session,120)),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.AdjustmentAmount
ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_federal
ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_state
ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_county
ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_local
ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_other
ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=0) THEN (billajs.aj_tax_federal + billajs.aj_tax_state + billajs.aj_tax_county + billajs.aj_tax_local + billajs.aj_tax_other)
ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.AdjustmentAmount
ELSE 0 END),
SUM(CASE WHEN (au.id_parent_sess IS NULL AND billajs.id_adj_trx IS NOT NULL AND billajs.n_adjustmenttype=0)	
THEN 1 ELSE 0 END) + 
SUM(CASE WHEN (au.id_parent_sess IS NOT NULL AND billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=0) THEN 1 ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.AdjustmentAmount ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_federal ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_state ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_county ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_local ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_other ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL and billajs.n_adjustmenttype=1) THEN (billajs.aj_tax_federal + billajs.aj_tax_state + 
billajs.aj_tax_county + billajs.aj_tax_local + billajs.aj_tax_other) ELSE 0 END),
SUM(CASE WHEN (billajs.AdjustmentAmount IS NOT NULL) THEN billajs.AdjustmentAmount
ELSE 0 END),
SUM(CASE WHEN (au.id_parent_sess IS NULL AND billajs.id_adj_trx IS NOT NULL AND billajs.n_adjustmenttype=1) THEN 1 ELSE 0 END) + 
SUM(CASE WHEN (au.id_parent_sess IS NOT NULL AND billajs.AdjustmentAmount IS NOT NULL AND billajs.n_adjustmenttype=1)  THEN 1 ELSE 0 END)
from
T_ACC_USAGE au1 inner join t_dm_account acc on au1.id_payee=acc.id_acc
and dt_session between vt_start and vt_end
inner join T_ADJUSTMENT_TRANSACTION billajs on billajs.id_sess=au1.id_sess AND billajs.c_status = 'A'
inner join T_ACC_USAGE au on au.id_sess=isnull(au1.id_parent_sess,au1.id_sess)
where au1.id_usage_interval not in (select id_interval from t_archive where
status = 'A' and tt_end = dbo.mtmaxdate())
and au.id_usage_interval not in (select id_interval from t_archive where
status = 'A' and tt_end = dbo.mtmaxdate())
group by au.id_acc,acc.id_dm_acc,au.id_usage_interval,convert(datetime,convert(char(10),au.dt_session,120)),au.id_prod,au.id_view, 
au.id_pi_instance,au.id_pi_template,au.am_currency,au.id_se

/* Update the MV for records that exists in Delta table */

update dm_1 set dm_1.PrebillAdjAmt = dm_1.PrebillAdjAmt + IsNULL(tmp2.PrebillAdjAmt, 0.0),
      dm_1.PrebillFedTaxAdjAmt = dm_1.PrebillFedTaxAdjAmt + IsNULL(tmp2.PrebillFedTaxAdjAmt, 0.0), 
      dm_1.PrebillStatetaxAdjAmt = dm_1.PrebillStatetaxAdjAmt + IsNULL(tmp2.PrebillStatetaxAdjAmt, 0.0), 
      dm_1.PrebillCntytaxAdjAmt = dm_1.PrebillCntytaxAdjAmt + IsNULL(tmp2.PrebillCntytaxAdjAmt, 0.0), 
      dm_1.PrebillLocaltaxAdjAmt = dm_1.PrebillLocaltaxAdjAmt + IsNULL(tmp2.PrebillLocaltaxAdjAmt, 0.0), 
      dm_1.PrebillOthertaxAdjAmt = dm_1.PrebillOthertaxAdjAmt + IsNULL(tmp2.PrebillOthertaxAdjAmt, 0.0), 
      dm_1.PrebillTotaltaxAdjAmt = dm_1.PrebillTotaltaxAdjAmt + IsNULL(tmp2.PrebillTotaltaxAdjAmt, 0.0), 
      dm_1.PostbillAdjAmt = dm_1.PostbillAdjAmt + IsNULL(tmp2.PostbillAdjAmt, 0.0), 
      dm_1.PostbillFedTaxAdjAmt = dm_1.PostbillFedTaxAdjAmt + IsNULL(tmp2.PostbillFedTaxAdjAmt, 0.0), 
      dm_1.PostbillStatetaxAdjAmt = dm_1.PostbillStatetaxAdjAmt + IsNULL(tmp2.PostbillStatetaxAdjAmt, 0.0), 
      dm_1.PostbillCntytaxAdjAmt = dm_1.PostbillCntytaxAdjAmt + IsNULL(tmp2.PostbillCntytaxAdjAmt, 0.0), 
      dm_1.PostbillLocaltaxAdjAmt = dm_1.PostbillLocaltaxAdjAmt + IsNULL(tmp2.PostbillLocaltaxAdjAmt, 0.0), 
      dm_1.PostbillOthertaxAdjAmt = dm_1.PostbillOthertaxAdjAmt + IsNULL(tmp2.PostbillOthertaxAdjAmt, 0.0), 
      dm_1.PostbillTotaltaxAdjAmt = dm_1.PostbillTotaltaxAdjAmt + IsNULL(tmp2.PostbillTotaltaxAdjAmt, 0.0), 
      dm_1.PrebillAdjustedAmount = dm_1.PrebillAdjustedAmount + IsNULL(tmp2.PrebillAdjustedAmount, 0.0), 
      dm_1.PostbillAdjustedAmount = dm_1.PostbillAdjustedAmount + IsNULL(tmp2.PostbillAdjustedAmount, 0.0), 
      dm_1.NumPrebillAdjustments = dm_1.NumPrebillAdjustments + IsNULL(tmp2.NumPrebillAdjustments, 0.0), 
      dm_1.NumPostbillAdjustments = dm_1.NumPostbillAdjustments + IsNULL(tmp2.NumPostbillAdjustments, 0.0), 
      dm_1.NumTransactions = dm_1.NumTransactions + IsNULL(tmp2.NumTransactions, 0.0) 
      from %%PAYEE_SESSION%% dm_1 inner join  %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session tmp2 
      on dm_1.id_dm_acc=tmp2.id_dm_acc 
      and dm_1.id_acc=tmp2.id_acc 
      and dm_1.id_usage_interval=tmp2.id_usage_interval 
      and dm_1.id_view=tmp2.id_view 
      and dm_1.am_currency=tmp2.am_currency 
      and dm_1.id_se=tmp2.id_se 
      and dm_1.dt_session=tmp2.dt_session
      and isnull(dm_1.id_prod,0)=isnull(tmp2.id_prod,0) 
      and isnull(dm_1.id_pi_instance,0)=isnull(tmp2.id_pi_instance,0) 
      and isnull(dm_1.id_pi_template,0)=isnull(tmp2.id_pi_template,0) 

/* Insert the MV for records that exists in Delta table */

Insert into %%PAYEE_SESSION%%
(
id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,PrebillAdjAmt,
PrebillFedTaxAdjAmt,PrebillStatetaxAdjAmt,PrebillCntytaxAdjAmt,PrebillLocaltaxAdjAmt,
PrebillOthertaxAdjAmt,PrebillTotaltaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStatetaxAdjAmt,
PostbillCntytaxAdjAmt,PostbillLocaltaxAdjAmt,PostbillOthertaxAdjAmt,
PostbillTotaltaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments,NumTransactions
)
select id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,PrebillAdjAmt,
PrebillFedTaxAdjAmt,PrebillStatetaxAdjAmt,PrebillCntytaxAdjAmt,PrebillLocaltaxAdjAmt,
PrebillOthertaxAdjAmt,PrebillTotaltaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStatetaxAdjAmt,
PostbillCntytaxAdjAmt,PostbillLocaltaxAdjAmt,PostbillOthertaxAdjAmt,
PostbillTotaltaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments,NumTransactions
from
%%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session tmp2 where not exists 
      (select 1 from %%PAYEE_SESSION%% dm_1 where 
      dm_1.id_dm_acc=tmp2.id_dm_acc 
      and dm_1.id_acc=tmp2.id_acc 
      and dm_1.id_usage_interval=tmp2.id_usage_interval 
      and dm_1.id_view=tmp2.id_view 
      and dm_1.am_currency=tmp2.am_currency 
      and dm_1.id_se=tmp2.id_se 
      and dm_1.dt_session=tmp2.dt_session
      and isnull(dm_1.id_prod,0)=isnull(tmp2.id_prod,0) 
      and isnull(dm_1.id_pi_instance,0)=isnull(tmp2.id_pi_instance,0) 
      and isnull(dm_1.id_pi_template,0)=isnull(tmp2.id_pi_template,0))
	