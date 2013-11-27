    
			select
			  gl.c_GainLoss_Id         TransactionId
			 ,gl.c_CreationDate        CreationDate 
			 ,gl.c_GainLossAmount	   GainLossAmount
			 ,gl.c_TransactionAmount   PDAmount
			 ,gl.c_Origin			   Origin
			 ,pacc.c_FirstName         PaymentAccountFirstName
			 ,pacc.c_LastName          PaymentAccountLastName
			 ,pacc.c_Company           PaymentAccountCompanyName
			 ,pacc.c_ExternalAccountId PaymentAccountNumber
			 ,iacc.c_FirstName         InvoiceAccountFirstName
			 ,iacc.c_LastName          InvoiceAccountLastName
			 ,iacc.c_Company	       InvoiceAccountCompanyName
			 ,iacc.c_ExternalAccountId InvoiceAccountNumber
			 ,inv.c_InvoiceString      InvoiceNumber
			from t_be_acc_tra_gainloss gl
			     inner join t_be_ar_all_paymtdistalloc pda
			     on gl.c_PaymentDistributionAlloc_Id = pda.c_PaymentDistribution_Id
			     inner join t_be_ar_pay_paymentdistrib pd
			     on pda.c_PaymentDistribution_Id = pd.c_PaymentDistribution_Id
			     left outer join t_be_ar_pay_paymentreceipt pr
			     on pd.c_PaymentReceipt_Id = pr.c_PaymentReceipt_Id
			     left outer join t_be_ar_pay_credit cr
			     on pd.c_Credit_Id = cr.c_Credit_Id
			     inner join t_be_ar_acct_araccount pacc
			     on pr.c_ARAccount_Id = pacc.c_ARAccount_Id or
			        cr.c_ARAccount_Id = pacc.c_ARAccount_Id
			     left join t_be_ar_debt_demandforpayme dfp
			     on pda.c_DemandForPayment_Id = dfp.c_DemandForPayment_Id
			     inner join t_be_ar_debt_arinvoice inv
			     on dfp.c_ARInvoice_Id = inv.c_ARInvoice_Id
			     inner join t_be_ar_acct_araccount iacc
			     on inv.c_ARAccount_Id = iacc.c_ARAccount_Id
			     where gl.c_BatchId = %%_BATCH_ID_%%
        