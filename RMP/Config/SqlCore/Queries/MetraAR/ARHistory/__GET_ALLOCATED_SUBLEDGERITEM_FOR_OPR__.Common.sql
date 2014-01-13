
/*__GET_ALLOCATED_SUBLEDGERITEM_FOR_OPR__*/
select
    opr.c_OutgoingPaymentRequest_Id ID,
    opr.c_Currency Currency,
    opr.c_Amount TotalOriginalAmount,
    opr.c_DivisionCurrency DivisionCurrency, 
    opr.c_DivisionAmount DivisionTotalOriginalAmount,
    %%OPR%% /*'OutgoingPaymentRequest'*/ DocumentType,
    opr.c_CreationDate DocumentDate,
    myAcc.c_ExternalAccountId AccountExternalId,
    myAcc.c_HierarchyName AccountName,
    'Missing Number' DocumentNumber, -- need some
    SUM(CASE WHEN pd.c_CurrAcct_Id = opr.c_ARAccount_id THEN pd.c_Amount ELSE 0 END) TotalAccountAmount,
    SUM(CASE WHEN pd.c_Status = %%PDSTATUS_OPEN%% THEN pd.c_Amount ELSE 0 END) OpenAmount,
    CAST(0 AS DECIMAL) DisputedAmount,
    SUM(CASE WHEN pd.c_CurrAcct_Id = opr.c_ARAccount_id THEN pd.c_DivAmount ELSE 0 END) DivisionTotalAccountAmount,
    SUM(CASE WHEN pd.c_Status = %%PDSTATUS_OPEN%% THEN pd.c_DivAmount ELSE 0 END) DivisionOpenAmount,
    CAST(0 AS DECIMAL) DivisionDisputedAmount,
    case when MAX(CASE WHEN pd.c_Status IN (%%PDSTATUS_PENDING%%) THEN 1 ELSE 0 END) = 1 THEN 'Y' ELSE 'N' END InProgressIndicator
from 
    t_be_ar_pay_outgoingpaymen opr
    inner join t_be_ar_all_paymtdistalloc pda on opr.c_OutgoingPaymentRequest_Id = pda.c_OutgoingPaymentRequest_Id
      and @snapshot >= pda.c_StartDate and @snapshot < pda.c_EndDate
    inner join t_be_ar_pay_paymentdistrib_h pd on pda.c_PaymentDistribution_Id = pd.c_PaymentDistribution_Id
      and @snapshot >= pd.c__StartDate and @snapshot < pd.c__EndDate
    inner join t_be_ar_acct_araccount myAcc on opr.c_ARAccount_Id = myAcc.c_ARAccount_Id
Where
    pd.c_Status not in (%%PDSTATUS_SPLIT_MERGE%%)
    and opr.c_OutgoingPaymentRequest_Id = @id
group by
    opr.c_OutgoingPaymentRequest_Id,
    opr.c_Currency,
    opr.c_Amount,
    opr.c_DivisionCurrency,
    opr.c_DivisionAmount,
    opr.c_CreationDate, 
    myAcc.c_ExternalAccountId,
    myAcc.c_HierarchyName
      