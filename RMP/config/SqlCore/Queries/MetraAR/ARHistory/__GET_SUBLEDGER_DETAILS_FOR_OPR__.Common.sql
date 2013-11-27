
/*__GET_SUBLEDGER_DETAILS_FOR_OPR__*/
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
  t_be_ar_pay_outgoingpaymen opr
  inner join t_be_ar_all_paymtdistalloc pda on pda.c_OutgoingPaymentRequest_Id = opr.c_OutgoingPaymentRequest_Id
      and @snapshot >= pda.c_StartDate and @snapshot < pda.c_EndDate
  inner join t_be_ar_pay_paymentdistrib_h pd on pd.c_PaymentDistribution_Id = pda.c_PaymentDistribution_Id
      and @snapshot >= pd.c__StartDate and @snapshot < pd.c__EndDate
  inner join t_be_ar_acct_araccount PayingAcc on PayingAcc.c_ARAccount_Id = pd.c_CurrAcct_Id
  left outer join t_be_ar_acct_araccount OriginalAcc on OriginalAcc.c_ARAccount_Id = pd.c_OrigAcct_Id
where
  opr.c_OutgoingPaymentRequest_Id = @id
      