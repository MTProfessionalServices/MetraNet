    
			select 
			  inv.c_InvoiceString          InvoiceNumber
			 ,iacc.c_FirstName             InvoiceAccountFirstName
			 ,iacc.c_LastName              InvoiceAccountLastName
			 ,iacc.c_Company	           InvoiceAccountCompanyName
			 ,iacc.c_ExternalAccountId     InvoiceAccountNumber
			 ,pd.c_Amount                  CreditAmount
			 ,pd.c_DivAmount               CreditDivisionAmount
			 ,pd.c_Status                  CurrentStatus
			 ,gl.c_GainLossAmount	       GainLossAmount
			 ,COALESCE(pd.c_IntendedDate, pd.c_CreationDate)  CreationDate
			from t_be_ar_pay_credit cr
			     inner join t_be_ar_pay_paymentdistrib pd
			     on cr.c_Credit_Id = pd.c_Credit_Id
			        and pd.c_Status <> %%__SPLIT__%% OR pd.c_Status = %%__OPEN__%%
			     left outer join t_be_ar_all_paymtdistalloc pda
			     on pda.c_PaymentDistribution_Id = pd.c_PaymentDistribution_Id
			        and pda.c_EndDate IS NULL
			     inner join t_be_ar_debt_demandforpayme dfp
			     on dfp.c_DemandForPayment_Id = pda.c_DemandForPayment_Id
			     inner join t_be_ar_debt_arinvoice inv
			     on dfp.c_ARInvoice_Id = inv.c_ARInvoice_Id
			     inner join t_be_ar_acct_araccount iacc
			     on inv.c_ARAccount_Id = iacc.c_ARAccount_Id
			     inner join t_be_acc_tra_gainloss gl
			     on gl.c_PaymentDistributionAlloc_Id = pda.c_PaymentDistributionAlloc_Id
				%%__WHERE_CLAUSE__%% 
        