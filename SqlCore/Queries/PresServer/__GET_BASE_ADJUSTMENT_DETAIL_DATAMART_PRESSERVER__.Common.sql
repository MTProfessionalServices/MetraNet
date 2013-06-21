
Select 
/* __GET_BASE_ADJUSTMENT_DETAIL_DATAMART_PRESSERVER__ */
au.Amount UnadjustedAmount,
au.Amount + (case when au.is_implied_tax = 'N' then (au.tax_federal + au.tax_state + au.tax_county + au.tax_local + au.tax_other) else 0)
          - (case when au.tax_informational = 'Y' then (au.tax_federal + au.tax_state + au.tax_county + au.tax_local + au.tax_other) else 0)
 as UnadjustedAmountWithTax,

au.tax_federal,
au.tax_state,
au.tax_county,
au.tax_local,
au.tax_other,

adj.CompoundPostBillFedTaxAdjAmt,
adj.CompoundPostBillStateTaxAdjAmt,
adj.CompoundPostbillCntyTaxAdjAmt,
adj.CompoundPostBillLocalTaxAdjAmt,
adj.CompoundPostBillOtherTaxAdjAmt,

adj.CompoundPreBillFedTaxAdjAmt,
adj.CompoundPreBillStateTaxAdjAmt,
adj.CompoundPrebillCntyTaxAdjAmt,
adj.CompoundPreBillLocalTaxAdjAmt,
adj.CompoundPreBillOtherTaxAdjAmt,

CASE WHEN %%%UPPER%%%('%%IS_POSTBILL%%') = 'Y' THEN
  adj.PostbillAdjAmt
ELSE
  adj.PrebillAdjAmt 
END as AdjustmentAmount,
CASE WHEN %%%UPPER%%%('%%IS_POSTBILL%%') = 'Y' THEN
  au.Amount + adj.PostbillAdjAmt
ELSE
  au.Amount + adj.PrebillAdjAmt
END AS AdjustedAmount,

CASE WHEN %%%UPPER%%%('%%IS_POSTBILL%%') = 'Y' THEN
  adj.PostbillAdjAmt + 
  adj.CompoundPostBillFedTaxAdjAmt +
  adj.CompoundPostBillStateTaxAdjAmt +
  adj.CompoundPostbillCntyTaxAdjAmt +
  adj.CompoundPostBillLocalTaxAdjAmt +
  adj.CompoundPostBillOtherTaxAdjAmt 
ELSE
  adj.PrebillAdjAmt + 
  adj.CompoundPreBillFedTaxAdjAmt +
  adj.CompoundPreBillStateTaxAdjAmt +
  adj.CompoundPrebillCntyTaxAdjAmt +
  adj.CompoundPreBillLocalTaxAdjAmt +
  adj.CompoundPreBillOtherTaxAdjAmt
END as AdjustmentAmountWithTax,

CASE WHEN %%%UPPER%%%('%%IS_POSTBILL%%') = 'Y' THEN
  au.Amount + adj.PostbillAdjAmt +
  adj.CompoundPostBillFedTaxAdjAmt +
  adj.CompoundPostBillStateTaxAdjAmt +
  adj.CompoundPostbillCntyTaxAdjAmt +
  adj.CompoundPostBillLocalTaxAdjAmt +
  adj.CompoundPostBillOtherTaxAdjAmt 
ELSE
  au.Amount + adj.PrebillAdjAmt +
  adj.CompoundPreBillFedTaxAdjAmt +
  adj.CompoundPreBillStateTaxAdjAmt +
  adj.CompoundPrebillCntyTaxAdjAmt +
  adj.CompoundPreBillLocalTaxAdjAmt +
  adj.CompoundPreBillOtherTaxAdjAmt
END AS AdjustedAmountWithTax,

adj.id_reason_code ReasonCode,
adj.AdjustmentTemplateDisplayName,
adj.AdjustmentInstanceDisplayName,
adj.ReasonCodeName,
adj.ReasonCodeDescription,
adj.ReasonCodeDisplayName,
{fn IFNULL(adj.tx_desc, '')} Description
FROM
vw_adjustment_details_datamart adj
INNER JOIN t_acc_usage au on adj.id_sess = au.id_sess
%%FROM_CLAUSE%%
WHERE
%%TIME_PREDICATE%%
AND 
%%ACCOUNT_PREDICATE%%
AND
%%SESSION_PREDICATE%%
AND 
adj.n_adjustmenttype = case when '%%IS_POSTBILL%%' = 'N' then 0 else 1 end
AND 
adj.LanguageCode = %%ID_LANG_CODE%%
%%EXT%%
			 