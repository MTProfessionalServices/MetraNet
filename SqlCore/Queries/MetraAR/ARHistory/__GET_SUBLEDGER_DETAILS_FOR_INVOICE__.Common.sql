
/*__GET_SUBLEDGER_DETAILS_FOR_INVOICE__*/
select 
  dfp.c_DemandForPayment_Id ID,
  dfp.c_DueDate DocumentDate,
  'DFP' DocumentType,
  'Missing Document Number' DocumentNumber, -- need one
  PayingAcc.c_ExternalAccountId AccountExternalId,
  PayingAcc.c_HierarchyName AccountHierarchyName,
  dfp.c_Status Status,
  dfp.c_Disputed IsDisputed,
  OriginalAcc.c_ExternalAccountId OriginalAccountExternalId,
  OriginalAcc.c_HierarchyName OriginalAccountHierarchyName,
  dfp.c_Currency Currency,
  dfp.c_DivCurrency DivisionCurrency,
  dfp.c_Amount Amount,
  dfp.c_DivAmount DivisionAmount
from 
  t_be_ar_debt_arstatement s
  inner join t_be_ar_debt_arinvoice i on i.c_ARStatement_Id = s.c_ARStatement_Id
  inner join t_be_ar_debt_demandforpaym_h dfp on dfp.c_ARInvoice_Id = i.c_ARInvoice_Id
      and @snapshot >= dfp.c__StartDate and @snapshot < dfp.c__EndDate
  inner join t_be_ar_acct_araccount PayingAcc on PayingAcc.c_ARAccount_Id = dfp.c_PayingAcct_Id
  left outer join t_be_ar_acct_araccount OriginalAcc on OriginalAcc.c_ARAccount_Id = dfp.c_OriginalPayingAcct_Id
where
  dfp.c_Status not in (%%DFPSTATUS_SPLIT_MERGE%%) /*split and merged*/
  and s.c_ARStatement_Id = @id
      