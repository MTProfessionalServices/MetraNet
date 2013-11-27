    
            select
              opr.c_StatusDate                                                      CreationDate
		     ,pd.c_OriginType                                                        TransactionOrigin
			 ,opr.c_OriginalCreditReasonCode                        OriginalCreditType
			 ,opr.c_OriginalPaymentReceiptType                     OriginalPaymentType
			 ,COALESCE(pr.c_ExternalId, cr.c_DisputeId)      DocumentNumber
			 ,COALESCE(pr.c_Amount, cr.c_Amount)             TotalAmount
			 ,COALESCE(pr.c_DivAmount, cr.c_DivisionAmount)  TotalDivisionAmount
		     ,pd.c_Amount						                                       OutgoingPaymentAmount
		     ,pd.c_DivAmount					                                       OutgoingPaymentDivisionAmount
            from t_be_ar_pay_outgoingpaymen opr
				inner join t_be_ar_all_paymtdistalloc pda
				on pda.c_OutgoingPaymentRequest_Id = opr.c_OutgoingPaymentRequest_Id
				inner join t_be_ar_pay_paymentdistrib pd
				on pda.c_PaymentDistribution_Id = pd.c_PaymentDistribution_Id
				left outer join t_be_ar_pay_credit cr
				on pd.c_Credit_Id = cr.c_Credit_Id
				left outer join t_be_ar_pay_paymentreceipt pr
				on pd.c_PaymentReceipt_Id = pr.c_PaymentReceipt_Id
				%%__WHERE_CLAUSE__%% 
        