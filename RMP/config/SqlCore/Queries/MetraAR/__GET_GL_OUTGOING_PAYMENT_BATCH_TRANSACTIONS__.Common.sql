    
			select
			  opr.c_OutgoingPaymentRequest_Id   TransactionId
			 ,opr.c_StatusDate                                    CreationDate
			 ,opr.c_OutgoingPaymentId                    OutgoingPaymentId
			 ,opr.c_OriginType                                    TransactionOrigin  
			 ,opr.c_OriginalPaymentReceiptType   OriginalPaymentType 
			 ,opr.c_OriginalCreditReasonCode      OriginalCreditType  
			 ,opr.c_PaymentType                                PaymentType         
			 ,opr.c_Amount                                           Amount
			 ,opr.c_DivisionAmount                            DivisionAmount
			 ,opr.c_DivisionAmount - opr.c_OriginalDivisionAmount  GainLossAmount
			 ,acc.c_FirstName                                     AccountFirstName
			 ,acc.c_LastName                                     AccountLastName
			 ,acc.c_Company                                       AccountCompanyName
			 ,acc.c_ExternalAccountId                        AccountNumber
			from t_be_ar_pay_outgoingpaymen opr	     
			     inner join t_be_ar_acct_araccount acc
			     on opr.c_ARAccount_Id = acc.c_ARAccount_Id
			     where opr.c_BatchId = %%_BATCH_ID_%%
       