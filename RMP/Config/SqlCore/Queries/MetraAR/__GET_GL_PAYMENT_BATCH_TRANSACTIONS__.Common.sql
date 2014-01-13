    
			select 
			  pay.c_PaymentReceipt_Id TransactionId
             ,pay.c_CreationDate             CreationDate
			 ,pay.c_ExternalId                   PaymentReceiptId
			 ,acc.c_FirstName		           AccountFirstName
			 ,acc.c_LastName                  AccountLastName
			 ,acc.c_Company			           AccountCompanyName
			 ,acc.c_ExternalAccountId     PaymentAccountNumber
			 ,pay.c_Amount			               Amount
			 ,pay.c_DivAmount		           DivisionAmount
			from t_be_ar_pay_paymentreceipt pay
				 inner join t_be_ar_acct_araccount acc
				 on pay.c_ARAccount_Id = acc.c_ARAccount_Id
				 where pay.c_BatchId = %%_BATCH_ID_%%
        