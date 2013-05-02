
/*__GET_SUBLEDGER_ITEM_PAYMENTRECEIPT__*/
select 
    c.c_PaymentReceipt_Id id,
    c.c_Currency currency,
    c.c_Amount TotalOriginalAmount,
    c.c_DivCurrency DivisionCurrency,
    c.c_DivAmount DivisionTotalOriginalAmount,
    %%PAYMENT_RECEIPT%% /*'PaymentReceipt'*/ DocumentType,
    c.c_CreationDate DocumentDate, 
    myAcc.c_ExternalAccountId AccountExternalId,
    myAcc.c_HierarchyName AccountName,
    N'Missing Payment Receipt Id' DocumentNumber, -- need this
    SUM(CASE WHEN pd.c_CurrAcct_Id = c.c_ARAccount_id THEN pd.c_Amount ELSE 0 END) TotalAccountAmount,
    SUM(CASE WHEN pd.c_Status = %%PDSTATUS_OPEN%% THEN pd.c_Amount ELSE 0 END) OpenAmount,
    CAST(0 AS DECIMAL) DisputedAmount,
    SUM(CASE WHEN pd.c_CurrAcct_Id = c.c_ARAccount_id THEN pd.c_DivAmount ELSE 0 END) DivisionTotalAccountAmount,
    SUM(CASE WHEN pd.c_Status = %%PDSTATUS_OPEN%% THEN pd.c_DivAmount ELSE 0 END) DivisionOpenAmount,
    CAST(0 AS DECIMAL) DivisionDisputedAmount,
    case when MAX(CASE WHEN pd.c_Status IN (%%PDSTATUS_PENDING%%) THEN 1 ELSE 0 END) = 1 THEN 'Y' ELSE 'N' END InProgressIndicator
from 
    t_be_ar_pay_paymentreceipt c
    inner join t_be_ar_pay_paymentdistrib_h pd on pd.c_PaymentReceipt_Id = c.c_PaymentReceipt_Id
      and @snapshot >= pd.c__StartDate and @snapshot < pd.c__EndDate
    inner join t_be_ar_acct_araccount myAcc on c.c_ARAccount_Id = myAcc.c_ARAccount_Id
Where
    pd.c_Status not in (%%PDSTATUS_SPLIT_MERGE%%)
    and c.c_PaymentReceipt_Id in (
       select c.c_PaymentReceipt_Id
       from 
          t_be_ar_pay_paymentreceipt c
          inner join t_be_ar_pay_paymentdistrib_h pd on pd.c_PaymentReceipt_Id = c.c_PaymentReceipt_Id
            and @snapshot >= pd.c__StartDate and @snapshot < pd.c__EndDate
       where
           pd.c_Status not in (%%PDSTATUS_SPLIT_MERGE%%)
           and pd.c_CurrAcct_Id in (
             select myAcc.c_ARAccount_Id
             from t_be_ar_acct_araccount myAcc
             where myAcc.c_ExternalAccountId = @idAcc
             union
             select myAcc.c_ARAccount_Id
             from
               t_be_ar_acct_araccount myAcc
               inner join t_be_ar_acct_araccount mgrAcc on myAcc.c_ManagedBy_Id = mgrAcc.c_ARAccount_Id
             where mgrAcc.c_ExternalAccountId = @idAcc
            )
       group by c.c_PaymentReceipt_id
    )
group by
    c.c_PaymentReceipt_Id,
    c.c_Currency,
    c.c_Amount,
    c.c_DivCurrency,
    c.c_DivAmount,
    c.c_CreationDate, 
    myAcc.c_ExternalAccountId,
    myAcc.c_HierarchyName
      