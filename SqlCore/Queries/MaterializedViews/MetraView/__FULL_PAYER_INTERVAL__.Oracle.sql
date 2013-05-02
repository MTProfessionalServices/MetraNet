
begin
exec_ddl ('truncate table %%PAYER_INTERVAL%%');

/* Insert the records into MV based on payee_session table */

Insert into %%PAYER_INTERVAL%%
select id_acc,id_dm_acc,id_usage_interval,id_prod,id_view,id_pi_instance,id_pi_template,
am_currency,id_se,
SUM(TotalAmount) TotalAmount,
SUM(TotalFederalTax) TotalFederalTax, 
SUM(TotalCountyTax),
SUM(TotalLocalTax),
SUM(TotalOtherTax),
SUM(TotalStateTax) TotalStateTax, 
SUM(TotalTax) TotalTax, 
SUM(PrebillAdjAmt) PrebillAdjAmt, 
SUM(PrebillFedTaxAdjAmt) PrebillFedTaxAdjAmt,
SUM(PrebillStateTaxAdjAmt) PrebillStateTaxAdjAmt,
SUM(PrebillCntyTaxAdjAmt) PrebillCntyTaxAdjAmt,
SUM(PrebillLocalTaxAdjAmt) PrebillLocalTaxAdjAmt,
SUM(PrebillOtherTaxAdjAmt) PrebillOtherTaxAdjAmt,
SUM(PrebillTotalTaxAdjAmt) PrebillTotalTaxAdjAmt,
SUM(PostbillAdjAmt) PostbillAdjAmt, 
SUM(PostbillFedTaxAdjAmt) PostbillFedTaxAdjAmt,
SUM(PostbillStateTaxAdjAmt) PostbillStateTaxAdjAmt,
SUM(PostbillCntyTaxAdjAmt) PostbillCntyTaxAdjAmt,
SUM(PostbillLocalTaxAdjAmt) PostbillLocalTaxAdjAmt,
SUM(PostbillOtherTaxAdjAmt) PostbillOtherTaxAdjAmt,
SUM(PostbillTotalTaxAdjAmt) PostbillTotalTaxAdjAmt,
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
id_se;

end;
			