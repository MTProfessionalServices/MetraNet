
/*__GET_SUBLEDGER_DETAILS_FOR_PAYMENTRECEIPT__*/
select
  pd.c_PaymentDistribution_Id ID,
  pd.c_IntendedDate DocumentDate,
  'PD' DocumentType,
  'Missing Document Number' DocumentNumber, -- need one
  PayingAcc.c_ExternalAccountId AccountExternalId,
  PayingAcc.c_HierarchyName AccountHierarchyName,
  pd.c_Status Status,
  'N' IsDisputed,
  OriginalAcc.c_ExternalAccountId OriginalAccountExternalId,
  OriginalAcc.c_HierarchyName OriginalAccountHierarchyName,
  pd.c_Currency Currency,
  pd.c_DivCurrency DivisionCurrency,
  pd.c_Amount Amount,
  pd.c_DivAmount DivisionAmount 
from 
  t_be_ar_pay_paymentreceipt pr
  inner join t_be_ar_pay_paymentdistrib_h pd on pd.c_PaymentReceipt_Id = pr.c_PaymentReceipt_Id
      and @snapshot >= pd.c__StartDate and @snapshot < pd.c__EndDate
  inner join t_be_ar_acct_araccount PayingAcc on PayingAcc.c_ARAccount_Id = pd.c_CurrAcct_Id
  left outer join t_be_ar_acct_araccount OriginalAcc on OriginalAcc.c_ARAccount_Id = pd.c_OrigAcct_Id
where
  pd.c_Status not in (%%PDSTATUS_SPLIT_MERGE%%)
  and pr.c_PaymentReceipt_Id = @id
      