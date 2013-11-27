
						select 
							credit.c_DisputeID CreditBKId,
							credit.c_DocumentNumber CreditNoteNumber,
							pd.c_PaymentDistribution_Id PaymentDistributionId,
							credit.c_CreationDate CreditDate,
							credit.c_Amount Amount,
							credit.c_Currency Currency,
							acc.c_ExternalAccountId ExternalAccountId
						from 
						t_be_ar_pay_credit credit
						%%JOIN%% join t_be_ar_pay_paymentdistrib pd on credit.c_Credit_Id = pd.c_Credit_Id
						inner join t_be_ar_acct_araccount acc on credit.c_ARAccount_Id = acc.c_ARAccount_Id
					