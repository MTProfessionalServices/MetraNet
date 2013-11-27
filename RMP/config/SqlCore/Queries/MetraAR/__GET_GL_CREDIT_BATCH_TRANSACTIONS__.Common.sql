    
			select
			  cr.c_Credit_Id                     TransactionId
             ,cr.c_CreationDate             CreationDate
			 ,cr.c_DisputeId                    CreditId
			 ,cr.c_DocumentNumber    DocumentNumber
			 ,acc.c_FirstName		         AccountFirstName
			 ,acc.c_LastName                AccountLastName
			 ,acc.c_Company			         AccountCompanyName
			 ,acc.c_ExternalAccountId   AccountNumber
			 ,cr.c_Amount			             Amount
			 ,cr.c_DivisionAmount	         DivisionAmount
			from t_be_ar_pay_credit cr				 
				 inner join t_be_ar_acct_araccount acc
				 on cr.c_ARAccount_Id = acc.c_ARAccount_Id
				 where cr.c_BatchId = %%_BATCH_ID_%%
        