
              select 
                pd.c_PaymentDistribution_Id ID,
                pd.c_Description PaymentString, /* WHat is this */
                pr.c_PaymentReceipt_Id PaymentReceiptId,
                pd.c_CreationDate PaymentDate,
                pd.c_Amount Amount,
                pd.c_Currency Currency,
                acc.c_ExternalAccountId ExternalAccountId,
                pr.c_PaymentType PaymentReceiptType 
              from t_be_ar_pay_paymentdistrib pd
              inner join t_be_ar_pay_paymentreceipt pr on pd.c_PaymentReceipt_Id = pr.c_PaymentReceipt_Id
              inner join t_be_ar_acct_araccount acc on pd.c_CurrAcct_Id = acc.c_ARAccount_Id
              where pd.c_Status = %%OPEN_STATUS%%
          