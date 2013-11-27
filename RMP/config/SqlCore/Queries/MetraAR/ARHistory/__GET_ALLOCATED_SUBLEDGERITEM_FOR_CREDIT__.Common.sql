
/*__GET_ALLOCATED_SUBLEDGERITEM_FOR_CREDIT__*/
select 
    c.c_Credit_Id id,
    c.c_Currency currency,
    c.c_Amount TotalOriginalAmount,
    c.c_DivisionCurrency DivisionCurrency,
    c.c_DivisionAmount DivisionTotalOriginalAmount,
    %%CREDIT%% /*'Credit'*/ DocumentType,
    c.c_IntendedDate DocumentDate, 
    myAcc.c_ExternalAccountId AccountExternalId,
    myAcc.c_HierarchyName AccountName,
    c.c_DocumentNumber DocumentNumber, 
    SUM(CASE WHEN pd.c_CurrAcct_Id = c.c_ARAccount_id THEN pd.c_Amount ELSE 0 END) TotalAccountAmount,
    SUM(CASE WHEN pd.c_Status = %%PDSTATUS_OPEN%% THEN pd.c_Amount ELSE 0 END) OpenAmount,
    CAST(0 AS DECIMAL) DisputedAmount,
    SUM(CASE WHEN pd.c_CurrAcct_Id = c.c_ARAccount_id THEN pd.c_DivAmount ELSE 0 END) DivisionTotalAccountAmount,
    SUM(CASE WHEN pd.c_Status = %%PDSTATUS_OPEN%% THEN pd.c_DivAmount ELSE 0 END) DivisionOpenAmount,
    CAST(0 AS DECIMAL) DivisionDisputedAmount,
    case when MAX(CASE WHEN pd.c_Status IN (%%PDSTATUS_PENDING%%) THEN 1 ELSE 0 END) = 1 THEN 'Y' ELSE 'N' END InProgressIndicator
from 
    t_be_ar_pay_credit c
    inner join t_be_ar_pay_paymentdistrib_h pd on pd.c_Credit_Id = c.c_Credit_Id
      and @snapshot >= pd.c__StartDate and @snapshot < pd.c__EndDate
    inner join t_be_ar_acct_araccount myAcc on c.c_ARAccount_Id = myAcc.c_ARAccount_Id
Where
    pd.c_Status not in (%%PDSTATUS_SPLIT_MERGE%%)
    and c.c_Credit_Id = @id
group by
    c.c_Credit_Id,
    c.c_Currency,
    c.c_Amount,
    c.c_DivisionCurrency,
    c.c_DivisionAmount,
    c.c_IntendedDate, 
    myAcc.c_ExternalAccountId,
    myAcc.c_HierarchyName,
    c.c_DocumentNumber
      