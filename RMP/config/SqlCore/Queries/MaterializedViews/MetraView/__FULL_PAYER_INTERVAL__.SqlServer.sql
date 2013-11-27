
Truncate table %%PAYER_INTERVAL%%

/* Insert the records into MV based on payee_session table */

Insert into %%PAYER_INTERVAL%%
select id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_instance,id_pi_template,
am_currency,id_se,
SUM(TotalAmount) TotalAmount,
SUM(TotalFederalTax) TotalFederalTax, 
sum(TotalCountyTax) TotalCountyTax,
sum(TotalLocalTax) TotalLocalTax,
sum(TotalOtherTax) TotalOtherTax,
SUM(TotalStateTax) TotalStateTax, 
SUM(TotalTax) TotalTax, 
SUM(TotalImpliedTax) TotalImpliedTax,
SUM(TotalInformationalTax) TotalInformationalTax,
SUM(TotalImplInfTax) TotalImplInfTax, 
SUM(PrebillAdjAmt) PrebillAdjAmt, 
SUM(PrebillFedTaxAdjAmt) PrebillFedTaxAdjAmt,
SUM(PrebillStatetaxAdjAmt) PrebillStatetaxAdjAmt,
SUM(PrebillCntytaxAdjAmt) PrebillCntytaxAdjAmt,
SUM(PrebillLocaltaxAdjAmt) PrebillLocaltaxAdjAmt,
SUM(PrebillOthertaxAdjAmt) PrebillOthertaxAdjAmt,
SUM(PrebillTotaltaxAdjAmt) PrebillTotaltaxAdjAmt,
SUM(PrebillImpliedTaxAdjAmt) PrebillImpliedTaxAdjAmt,
SUM(PrebillInformationalTaxAdjAmt) PrebillInformationalTaxAdjAmt,
SUM(PrebillImplInfTaxAdjAmt) PrebillImplInfTaxAdjAmt,
SUM(PostbillAdjAmt) PostbillAdjAmt, 
SUM(PostbillFedTaxAdjAmt) PostbillFedTaxAdjAmt,
SUM(PostbillStatetaxAdjAmt) PostbillStatetaxAdjAmt,
SUM(PostbillCntytaxAdjAmt) PostbillCntytaxAdjAmt,
SUM(PostbillLocaltaxAdjAmt) PostbillLocaltaxAdjAmt,
SUM(PostbillOthertaxAdjAmt) PostbillOthertaxAdjAmt,
SUM(PostbillTotaltaxAdjAmt) PostbillTotaltaxAdjAmt,
SUM(PostbillImpliedTaxAdjAmt) PostbillImpliedTaxAdjAmt,
SUM(PostbillInformationalTaxAdjAmt) PostbillInformationalTaxAdjAmt,
SUM(PostbillImplInfTaxAdjAmt) PostbillImplInfTaxAdjAmt,
SUM(PrebillAdjustedAmount) PrebillAdjustedAmount, 
SUM(PostbillAdjustedAmount) PostbillAdjustedAmount, 
sum(NumPrebillAdjustments) NumPrebillAdjustments, 
sum(NumPostbillAdjustments) NumPostbillAdjustments, 
sum(NumTransactions) NumTransactions
from %%PAYEE_SESSION%%
group by 
id_acc, 
id_dm_acc, 
id_usage_interval, 
id_prod, 
id_view, 
id_pi_instance, 
id_pi_template, 
am_currency, 
id_se
			