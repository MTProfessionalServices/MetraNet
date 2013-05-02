
begin

/* Delete all the records that are not archived, we can not use truncate since we cannot refresh MV for archived records */

Delete from %%PAYEE_SESSION%% where id_usage_interval not in 
(select id_interval from t_archive where status = 'A' and tt_end = dbo.mtmaxdate());

Insert into %%PAYEE_SESSION%%
(
id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
TotalAmount,TotalFederalTax,TotalCountyTax,TotalLocalTax,TotalOtherTax,TotalStateTax,TotalTax,
PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,NumPrebillAdjustments,
PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
PostbillTotalTaxAdjAmt,NumPostbillAdjustments,PrebillAdjustedAmount,PostbillAdjustedAmount,NumTransactions
)
select au.id_acc,acc.id_dm_acc,au.id_usage_interval,au.id_prod,au.id_view,au.id_pi_template,au.id_pi_instance,
au.am_currency,au.id_se,trunc(au.dt_session),
SUM(nvl(au.Amount, 0.0)),
SUM(nvl(au.Tax_Federal, 0.0)),
SUM(nvl(au.Tax_County, 0.0)),
SUM(nvl(au.Tax_Local, 0.0)),
SUM(nvl(au.Tax_Other, 0.0)),
SUM(nvl(au.Tax_State, 0.0)),
SUM(nvl(au.Tax_Federal, 0.0)) + SUM(nvl(au.Tax_State, 0.0)) + SUM(nvl(au.Tax_County, 0.0)) + 
SUM(nvl(au.Tax_Local, 0.0)) + SUM(nvl(au.Tax_Other, 0.0)),
cast (0.0 as numeric(38,6)) as PrebillAdjAmt,
cast (0.0 as numeric(38,6)) as PrebillFedTaxAdjAmt,cast (0.0 as numeric(38,6)) as  PrebillStateTaxAdjAmt,cast (0.0 as numeric(38,6)) as  PrebillCntyTaxAdjAmt,
cast (0.0 as numeric(38,6)) as PrebillLocalTaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillOtherTaxAdjAmt,cast (0.0 as numeric(38,6)) as PrebillTotalTaxAdjAmt,
cast (0.0 as numeric(38,6)) as NumPrebillAdjustments,cast (0.0 as numeric(38,6)) as PostbillAdjAmt,cast (0.0 as numeric(38,6)) as PostbillFedTaxAdjAmt,
cast (0.0 as numeric(38,6)) as PostbillStateTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillCntyTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillLocalTaxAdjAmt,
cast (0.0 as numeric(38,6)) as PostbillOtherTaxAdjAmt,cast (0.0 as numeric(38,6)) as PostbillTotalTaxAdjAmt,cast (0.0 as numeric(38,6)) as NumPostbillAdjustments,
SUM(nvl(au.Amount,0.0)) PrebillAdjustedAmount,
SUM(nvl(au.Amount,0.0)) PostbillAdjustedAmount,
COUNT(*) NumTransactions
from  T_ACC_USAGE au inner join t_dm_account acc on au.id_payee=acc.id_acc
and dt_session between vt_start and vt_end
where id_parent_sess is null
group by au.id_acc,acc.id_dm_acc,au.id_usage_interval,trunc(au.dt_session),au.id_prod,au.id_view, 
au.id_pi_instance,au.id_pi_template,au.am_currency,au.id_se;

/* Cleanup the delta tables*/

delete from %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session;

/* Insert the records into Delta table for the adjustments */

Insert into %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session
(
id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,
PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillAdjustedAmount,
NumPrebillAdjustments,
PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
PostbillTotalTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments
)
select au.id_acc,acc.id_dm_acc,au.id_usage_interval,au.id_prod,au.id_view,au.id_pi_template,au.id_pi_instance,
au.am_currency,au.id_se,trunc(au.dt_session),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs. ADJUSTMENTAMOUNT
ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_federal
ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_state
ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_county
ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_local
ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL AND billajs.n_adjustmenttype=0) THEN billajs.aj_tax_other
ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL AND billajs.n_adjustmenttype=0) THEN (billajs.aj_tax_federal + billajs.aj_tax_state + billajs.aj_tax_county + billajs.aj_tax_local + billajs.aj_tax_other)
ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL  AND billajs.n_adjustmenttype=0) THEN billajs.ADJUSTMENTAMOUNT
ELSE 0 END),
SUM(CASE WHEN (au.id_parent_sess IS NULL AND billajs.id_adj_trx IS NOT NULL AND billajs.n_adjustmenttype=0)	
THEN 1 ELSE 0 END) + 
SUM(CASE WHEN (au.id_parent_sess IS NOT NULL AND billajs.ADJUSTMENTAMOUNT IS NOT NULL AND billajs.n_adjustmenttype=0) THEN 1 ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.ADJUSTMENTAMOUNT ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_federal ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_state ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_county ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_local ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL AND billajs.n_adjustmenttype=1) THEN billajs.aj_tax_other ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL and billajs.n_adjustmenttype=1) THEN (billajs.aj_tax_federal + billajs.aj_tax_state + 
billajs.aj_tax_county + billajs.aj_tax_local + billajs.aj_tax_other) ELSE 0 END),
SUM(CASE WHEN (billajs.ADJUSTMENTAMOUNT IS NOT NULL) THEN billajs.ADJUSTMENTAMOUNT
ELSE 0 END),
SUM(CASE WHEN (au.id_parent_sess IS NULL AND billajs.id_adj_trx IS NOT NULL AND billajs.n_adjustmenttype=1) THEN 1 ELSE 0 END) + 
SUM(CASE WHEN (au.id_parent_sess IS NOT NULL AND billajs.ADJUSTMENTAMOUNT IS NOT NULL AND billajs.n_adjustmenttype=1)  THEN 1 ELSE 0 END)
from
T_ACC_USAGE au1 inner join t_dm_account acc on au1.id_payee=acc.id_acc
and dt_session between vt_start and vt_end
inner join T_ADJUSTMENT_TRANSACTION billajs on billajs.id_sess=au1.id_sess AND billajs.c_status = 'A'
inner join T_ACC_USAGE au on au.id_sess=nvl(au1.id_parent_sess,au1.id_sess)
where au1.id_usage_interval not in (select id_interval from t_archive where
status = 'A' and tt_end = dbo.mtmaxdate())
and au.id_usage_interval not in (select id_interval from t_archive where
status = 'A' and tt_end = dbo.mtmaxdate())
group by au.id_acc,acc.id_dm_acc,au.id_usage_interval,trunc(au.dt_session),au.id_prod,au.id_view, 
au.id_pi_instance,au.id_pi_template,au.am_currency,au.id_se;

/* Update the MV for records that exists in Delta table */

update %%PAYEE_SESSION%% dm_1 set (PrebillAdjAmt,PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,
 PrebillLocalTaxAdjAmt,PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PostbillAdjAmt,PostbillFedTaxAdjAmt,
PostbillStateTaxAdjAmt,PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
PostbillTotalTaxAdjAmt,PrebillAdjustedAmount,PostbillAdjustedAmount,NumPrebillAdjustments,
NumPostbillAdjustments,NumTransactions) = (select 
dm_1.PrebillAdjAmt + nvl(tmp2.PrebillAdjAmt, 0.0),
      dm_1.PrebillFedTaxAdjAmt + nvl(tmp2.PrebillFedTaxAdjAmt, 0.0), 
      dm_1.PrebillStateTaxAdjAmt + nvl(tmp2.PrebillStateTaxAdjAmt, 0.0), 
      dm_1.PrebillCntyTaxAdjAmt + nvl(tmp2.PrebillCntyTaxAdjAmt, 0.0), 
      dm_1.PrebillLocalTaxAdjAmt + nvl(tmp2.PrebillLocalTaxAdjAmt, 0.0), 
      dm_1.PrebillOtherTaxAdjAmt + nvl(tmp2.PrebillOtherTaxAdjAmt, 0.0), 
      dm_1.PrebillTotalTaxAdjAmt + nvl(tmp2.PrebillTotalTaxAdjAmt, 0.0), 
      dm_1.PostbillAdjAmt + nvl(tmp2.PostbillAdjAmt, 0.0), 
      dm_1.PostbillFedTaxAdjAmt + nvl(tmp2.PostbillFedTaxAdjAmt, 0.0), 
      dm_1.PostbillStateTaxAdjAmt + nvl(tmp2.PostbillStateTaxAdjAmt, 0.0), 
      dm_1.PostbillCntyTaxAdjAmt + nvl(tmp2.PostbillCntyTaxAdjAmt, 0.0), 
      dm_1.PostbillLocalTaxAdjAmt + nvl(tmp2.PostbillLocalTaxAdjAmt, 0.0), 
      dm_1.PostbillOtherTaxAdjAmt + nvl(tmp2.PostbillOtherTaxAdjAmt, 0.0), 
      dm_1.PostbillTotalTaxAdjAmt + nvl(tmp2.PostbillTotalTaxAdjAmt, 0.0), 
      dm_1.PrebillAdjustedAmount + nvl(tmp2.PrebillAdjustedAmount, 0.0), 
      dm_1.PostbillAdjustedAmount + nvl(tmp2.PostbillAdjustedAmount, 0.0), 
      dm_1.NumPrebillAdjustments + nvl(tmp2.NumPrebillAdjustments, 0.0), 
      dm_1.NumPostbillAdjustments + nvl(tmp2.NumPostbillAdjustments, 0.0), 
      dm_1.NumTransactions + nvl(tmp2.NumTransactions, 0.0) 
      from  %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session tmp2 
      where dm_1.id_dm_acc=tmp2.id_dm_acc 
      and dm_1.id_acc=tmp2.id_acc 
      and dm_1.id_usage_interval=tmp2.id_usage_interval 
      and dm_1.id_view=tmp2.id_view 
      and dm_1.am_currency=tmp2.am_currency 
      and dm_1.id_se=tmp2.id_se 
      and dm_1.dt_session=tmp2.dt_session
      and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
      and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
      and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0))
where exists (select 1
      from  %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payee_session tmp2 
      where dm_1.id_dm_acc=tmp2.id_dm_acc 
      and dm_1.id_acc=tmp2.id_acc 
      and dm_1.id_usage_interval=tmp2.id_usage_interval 
      and dm_1.id_view=tmp2.id_view 
      and dm_1.am_currency=tmp2.am_currency 
      and dm_1.id_se=tmp2.id_se 
      and dm_1.dt_session=tmp2.dt_session
      and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
      and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
      and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0));

/* Insert the MV for records that exists in Delta table */

Insert into %%PAYEE_SESSION%%
(
id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,PrebillAdjAmt,
PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
PostbillTotalTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments,NumTransactions
)
select id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_template,id_pi_instance,am_currency,id_se,dt_session,PrebillAdjAmt,
PrebillFedTaxAdjAmt,PrebillStateTaxAdjAmt,PrebillCntyTaxAdjAmt,PrebillLocalTaxAdjAmt,
PrebillOtherTaxAdjAmt,PrebillTotalTaxAdjAmt,PrebillAdjustedAmount,NumPrebillAdjustments,
PostbillAdjAmt,PostbillFedTaxAdjAmt,PostbillStateTaxAdjAmt,
PostbillCntyTaxAdjAmt,PostbillLocalTaxAdjAmt,PostbillOtherTaxAdjAmt,
PostbillTotalTaxAdjAmt,PostbillAdjustedAmount,NumPostbillAdjustments,NumTransactions
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
      and nvl(dm_1.id_prod,0)=nvl(tmp2.id_prod,0) 
      and nvl(dm_1.id_pi_instance,0)=nvl(tmp2.id_pi_instance,0) 
      and nvl(dm_1.id_pi_template,0)=nvl(tmp2.id_pi_template,0));
end;
	