
SELECT * FROM (
Select 
/* __GET_BASE_ADJUSTMENT_DETAIL__ */
ad.id_sess SessionID,
ad.am_currency Currency,
ad.Amount UnadjustedAmount,
ad.Amount + {fn IFNULL(ad.tax_federal, 0.0)} + {fn IFNULL(ad.tax_state, 0.0)} + {fn IFNULL(ad.tax_county, 0.0)} + {fn IFNULL(ad.tax_local, 0.0)} + {fn IFNULL(ad.tax_other, 0.0)} as UnadjustedAmountWithTax,

{fn IFNULL(ad.tax_federal, 0.0)} TotalFederalTax,
{fn IFNULL(ad.tax_state, 0.0)} TotalStateTax,
{fn IFNULL(ad.tax_county, 0.0)} TotalCountyTax,
{fn IFNULL(ad.tax_local, 0.0)} TotalLocalTax,
{fn IFNULL(ad.tax_other, 0.0)} TotalOtherTax,

ad.CompoundPostBillFedTaxAdjAmt PostBillFedTaxAdjAmt,
ad.CompoundPostBillStateTaxAdjAmt PostBillStateTaxAdjAmt,
ad.CompoundPostbillCntyTaxAdjAmt PostBillCntyTaxAdjAmt,
ad.CompoundPostBillLocalTaxAdjAmt PostBillLocalTaxAdjAmt,
ad.CompoundPostBillOtherTaxAdjAmt PostBillOtherTaxAdjAmt,

ad.CompoundPreBillFedTaxAdjAmt PreBillFedTaxAdjAmt,
ad.CompoundPreBillStateTaxAdjAmt PreBillStateTaxAdjAmt,
ad.CompoundPrebillCntyTaxAdjAmt PreBillCntyTaxAdjAmt,
ad.CompoundPreBillLocalTaxAdjAmt PreBillLocalTaxAdjAmt,
ad.CompoundPreBillOtherTaxAdjAmt PreBillOtherTaxAdjAmt,

CASE WHEN %%%UPPER%%%(@IsPostbill) = 'Y' THEN
  ad.PostbillAdjAmt
ELSE
  ad.PrebillAdjAmt
END as AdjustmentAmount,

CASE WHEN %%%UPPER%%%(@IsPostbill) = 'Y' THEN
  ad.Amount + ad.PostbillAdjAmt
ELSE
  ad.Amount + ad.PrebillAdjAmt
END AS AdjustedAmount,

CASE WHEN %%%UPPER%%%(@IsPostbill) = 'Y' THEN
  ad.PostbillAdjAmt + 
  ad.AtomicPostBillFedTaxAdjAmt +
  ad.AtomicPostBillStateTaxAdjAmt +
  ad.AtomicPostbillCntyTaxAdjAmt +
  ad.AtomicPostBillLocalTaxAdjAmt +
  ad.AtomicPostBillOtherTaxAdjAmt 
ELSE
  ad.PrebillAdjAmt + 
  ad.AtomicPreBillFedTaxAdjAmt +
  ad.AtomicPreBillStateTaxAdjAmt +
  ad.AtomicPrebillCntyTaxAdjAmt +
  ad.AtomicPreBillLocalTaxAdjAmt +
  ad.AtomicPreBillOtherTaxAdjAmt
END as AdjustmentAmountWithTax,

CASE WHEN %%%UPPER%%%(@IsPostbill) = 'Y' THEN
  ad.Amount + ad.PostbillAdjAmt +
  ad.AtomicPostBillFedTaxAdjAmt +
  ad.AtomicPostBillStateTaxAdjAmt +
  ad.AtomicPostbillCntyTaxAdjAmt +
  ad.AtomicPostBillLocalTaxAdjAmt +
  ad.AtomicPostBillOtherTaxAdjAmt 
ELSE
  ad.Amount + ad.PrebillAdjAmt +
  ad.AtomicPreBillFedTaxAdjAmt +
  ad.AtomicPreBillStateTaxAdjAmt +
  ad.AtomicPrebillCntyTaxAdjAmt +
  ad.AtomicPreBillLocalTaxAdjAmt +
  ad.AtomicPreBillOtherTaxAdjAmt
END AS AdjustedAmountWithTax,

ad.AdjustmentTemplateDisplayName,
ad.AdjustmentInstanceDisplayName,

{fn IFNULL(ad.tx_desc, '')} Description,

ad.id_reason_code ReasonCode,
ad.ReasonCodeName,
ad.ReasonCodeDescription,
ad.ReasonCodeDisplayName, 
AdjustmentUsageInterval id_usage_interval, 
ad.id_acc, 
ad.n_adjustmenttype, 
ad.LanguageCode, 
ad.dt_session
FROM
vw_adjustment_details ad) au
%%FROM_CLAUSE%%
WHERE
%%TIME_PREDICATE%%
AND 
%%ACCOUNT_PREDICATE%%
AND 
au.n_adjustmenttype = case when %%%UPPER%%%(@IsPostbill) = 'N' then 0 else 1 end
