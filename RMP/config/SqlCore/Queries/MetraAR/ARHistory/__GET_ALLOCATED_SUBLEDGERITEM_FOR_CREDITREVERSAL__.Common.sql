
/*__GET_ALLOCATED_SUBLEDGERITEM_FOR_CREDITREVERSAL__*/
select 
    cr.c_CreditReversal_Id Id,
    cr.c_Currency Currency,
    cr.c_Amount TotalOriginalAmount,
    cr.c_DivCurrency DivisionCurrency,
    cr.c_DivAmount DivisionTotalOriginalAmount,
    %%CREDIT_REVERSAL%% /*'CreditReversal'*/ DocumentType,
    cr.c_CreationDate DocumentDate,
    myAcc.c_ExternalAccountId AccountExternalId,
    myAcc.c_HierarchyName AccountName,
    'Missing' DocumentNumber,
    SUM(CASE WHEN pd.c_CurrAcct_Id = cr.c_ARAccount_id THEN pd.c_Amount ELSE 0 END) TotalAccountAmount,
    SUM(CASE WHEN pd.c_Status = %%PDSTATUS_OPEN%% THEN pd.c_Amount ELSE 0 END) OpenAmount,
    CAST(0 AS DECIMAL) DisputedAmount,
    SUM(CASE WHEN pd.c_CurrAcct_Id = cr.c_ARAccount_id THEN pd.c_DivAmount ELSE 0 END) DivisionTotalAccountAmount,
    SUM(CASE WHEN pd.c_Status = %%PDSTATUS_OPEN%% THEN pd.c_DivAmount ELSE 0 END) DivisionOpenAmount,
    CAST(0 AS DECIMAL) DivisionDisputedAmount,
    case when MAX(CASE WHEN pd.c_Status IN (%%PDSTATUS_PENDING%%) THEN 1 ELSE 0 END) = 1 THEN 'Y' ELSE 'N' END InProgressIndicator
from 
    t_be_ar_pay_creditreversal cr
    inner join t_be_ar_all_paymtdistalloc pda on cr.c_CreditReversal_Id = pda.c_CreditReversal_Id
      and @snapshot >= pda.c_StartDate and @snapshot < pda.c_EndDate
    inner join t_be_ar_pay_paymentdistrib_h pd on pda.c_PaymentDistribution_Id = pd.c_PaymentDistribution_Id
      and @snapshot >= pd.c__StartDate and @snapshot < pd.c__EndDate
    inner join t_be_ar_acct_araccount myAcc on cr.c_ARAccount_Id = myAcc.c_ARAccount_Id
Where
    pd.c_Status not in (%%PDSTATUS_SPLIT_MERGE%%)
    and cr.c_CreditReversal_Id = @id
group by
    cr.c_CreditReversal_Id,
    cr.c_Currency,
    cr.c_Amount,
    cr.c_DivCurrency,
    cr.c_DivAmount,
    cr.c_CreationDate, 
    myAcc.c_ExternalAccountId,
    myAcc.c_HierarchyName
      