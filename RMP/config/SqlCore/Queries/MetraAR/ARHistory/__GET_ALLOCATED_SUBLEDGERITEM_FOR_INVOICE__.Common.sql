
/*__GET_ALLOCATED_SUBLEDGERITEM_FOR_INVOICE__*/
  select 
    s.c_arStatement_id id,
    s.c_Currency currency, 
    s.c_Amount TotalOriginalAmount,
    s.c_DivCurrency DivisionCurrency,
    s.c_DivAmount DivisionTotalOriginalAmount,
    %%INVOICE%% /*'Invoice'*/ DocumentType,
    i.c_IssueDate DocumentDate, -- need to be moved to statement
    myAcc.c_ExternalAccountId AccountExternalId,
    myAcc.c_HierarchyName AccountName,
    s.c_StatementString DocumentNumber,
    SUM(CASE WHEN dfp.c_PayingAcct_Id = s.c_ARAccount_id THEN dfp.c_Amount ELSE 0 END) TotalAccountAmount,
    SUM(CASE WHEN dfp.c_Status = %%DFPSTATUS_OPEN%% /*open*/ THEN dfp.c_Amount ELSE 0 END) OpenAmount,
    SUM(CASE WHEN dfp.c_Disputed = 'Y' or dfp.c_Disputed = 'T' THEN dfp.c_Amount ELSE 0 END) DisputedAmount,
    SUM(CASE WHEN dfp.c_PayingAcct_Id = s.c_ARAccount_id THEN dfp.c_DivAmount ELSE 0 END) DivisionTotalAccountAmount,
    SUM(CASE WHEN dfp.c_Status = %%DFPSTATUS_OPEN%% /*open*/ THEN dfp.c_DivAmount ELSE 0 END) DivisionOpenAmount,
    SUM(CASE WHEN dfp.c_Disputed = 'Y' or dfp.c_Disputed = 'T' THEN dfp.c_DivAmount ELSE 0 END) DivisionDisputedAmount,
    case when MAX(CASE WHEN dfp.c_Status in (%%DFPSTATUS_PENDING%%) /*pending*/ THEN 1 ELSE 0 END) = 1 THEN 'Y' ELSE 'N' END InProgressIndicator
  from 
    t_be_ar_debt_arstatement s
    inner join t_be_ar_debt_arinvoice i on i.c_ARStatement_Id = s.c_ARStatement_Id
    inner join t_be_ar_debt_demandforpaym_h dfp on dfp.c_ARInvoice_Id = i.c_ARInvoice_Id 
      and @snapshot >= dfp.c__StartDate and @snapshot < dfp.c__EndDate
    inner join t_be_ar_acct_araccount myAcc on s.c_ARAccount_Id = myAcc.c_ARAccount_Id
  where 
    dfp.c_Status not in (%%DFPSTATUS_SPLIT_MERGE%%) /*split and merged*/
    and s.c_ARStatement_Id = @id
  group by 	
    s.c_ARStatement_Id,
    s.c_Currency,
    s.c_Amount,
    s.c_DivCurrency,
    s.c_DivAmount,
    s.c_StatementString,
    myAcc.c_ExternalAccountId,
    myAcc.c_HierarchyName,
    i.c_IssueDate
      