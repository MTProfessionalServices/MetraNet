
SELECT * FROM (
Select 
/* __GET_BASE_ADJUSTMENT_DETAIL_DATAMART__ */
acc.id_sess SessionID,
acc.am_currency Currency,
acc.Amount UnadjustedAmount,
acc.amount + 
	      /*If implied taxes, then taxes are already included, don't add them again */
	      (case when acc.is_implied_tax = 'N' then 
              ({fn IFNULL(acc.tax_federal, 0.0)} + {fn IFNULL(acc.tax_state, 0.0)} + {fn IFNULL(acc.tax_county, 0.0)} + 
                  {fn IFNULL(acc.tax_local, 0.0)} + {fn IFNULL(acc.tax_other, 0.0)}) else 0.0 end)
	      /*If informational taxes, then they shouldn't be in the total */
			  - (CASE WHEN (acc.tax_informational = 'Y') THEN 
              ({fn IFNULL(acc.tax_federal, 0.0)} + {fn IFNULL(acc.tax_state, 0.0)} + {fn IFNULL(acc.tax_county, 0.0)} + 
                  {fn IFNULL(acc.tax_local, 0.0)} + {fn IFNULL(acc.tax_other, 0.0)}) else 0.0 end) 
  as UnadjustedAmountWithTax,
{fn IFNULL(acc.tax_federal, 0.0)} TotalFederalTax,
{fn IFNULL(acc.tax_state, 0.0)} TotalStateTax,
{fn IFNULL(acc.tax_county, 0.0)} TotalCountyTax,
{fn IFNULL(acc.tax_local, 0.0)} TotalLocalTax,
{fn IFNULL(acc.tax_other, 0.0)} TotalOtherTax,

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

CASE WHEN %%%UPPER%%%(:IsPostbill) = 'Y' THEN
  ad.PostbillAdjAmt
ELSE
  ad.PrebillAdjAmt
END as AdjustmentAmount,

CASE WHEN %%%UPPER%%%(:IsPostbill) = 'Y' THEN
  acc.Amount + ad.PostbillAdjAmt
ELSE
  acc.Amount + ad.PrebillAdjAmt
END AS AdjustedAmount,

CASE WHEN %%%UPPER%%%(:IsPostbill) = 'Y' THEN
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

CASE WHEN %%%UPPER%%%(:IsPostbill) = 'Y' THEN
  acc.Amount + ad.PostbillAdjAmt +
  ad.AtomicPostBillFedTaxAdjAmt +
  ad.AtomicPostBillStateTaxAdjAmt +
  ad.AtomicPostbillCntyTaxAdjAmt +
  ad.AtomicPostBillLocalTaxAdjAmt +
  ad.AtomicPostBillOtherTaxAdjAmt 
ELSE
  acc.Amount + ad.PrebillAdjAmt +
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
acc.dt_session
FROM
vw_adjustment_details_datamart ad
INNER JOIN t_acc_usage acc on ad.id_sess = acc.id_sess) au
%%FROM_CLAUSE%%
WHERE
%%TIME_PREDICATE%%
AND 
%%ACCOUNT_PREDICATE%%
AND 
au.n_adjustmenttype = case when %%%UPPER%%%(:IsPostbill) = 'N' then 0 else 1 end
-- TODO Uncomment this during FEAT-4238 implementation
--AND 
--au.LanguageCode = :langCode
