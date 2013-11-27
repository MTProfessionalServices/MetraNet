
              select 
                c_DemandForPayment_Id Id,
                dfp.c_Description Comment,
                c_InvoiceString InvoiceNumber,
                dfp.c_Amount Amount,
                dfp.c_Currency Currency,
                dfp.c_Taxes Taxes,
                c_RootId RootId,
                c_Status Status,
                c_DueDate DueDate,
                c_OriginalDueDate OriginalDueDate,
                dfp.c_DivAmount DivAmount,
                dfp.c_DivCurrency DivCurrency,
                c_Disputed Disputed,
                c_PayingAcct_Id PayableAccountGuid,
                acc.c_ExternalAccountId ExternalAccountId
              from t_be_ar_debt_demandforpayme dfp
              inner join t_be_ar_acct_araccount acc on dfp.c_PayingAcct_Id = acc.c_ARAccount_Id
              inner join t_be_ar_debt_arinvoice inv on dfp.c_ARInvoice_Id = inv.c_ARInvoice_Id 
          