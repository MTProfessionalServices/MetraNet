    
			select
			  crr.c_CreditReversal_Id           TransactionId
			 ,crr.c_CreationDate                CreationDate 
			 ,crr.c_CreditReversalId            CreditReversalId
			 ,acc.c_FirstName                   AccountFirstName
			 ,acc.c_LastName                    AccountLastName
			 ,acc.c_Company                     AccountCompanyName
			 ,acc.c_ExternalAccountId           AccountNumber
			 ,crr.c_Amount                      Amount
			 ,crr.c_DivAmount                   DivisionAmount
			from t_be_ar_pay_creditreversal crr
			     inner join t_be_ar_acct_araccount acc
			     on crr.c_ARAccount_Id = acc.c_ARAccount_Id
			     where crr.c_BatchId = %%_BATCH_ID_%%
       