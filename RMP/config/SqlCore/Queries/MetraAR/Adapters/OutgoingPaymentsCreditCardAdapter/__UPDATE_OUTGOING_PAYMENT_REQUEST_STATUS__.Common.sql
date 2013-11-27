
		  

				/* UPDATE payment distribution */
				UPDATE t_be_ar_pay_paymentdistrib
				SET c__version = pd.c__version + 1,
					c_UpdateDate = @c_UpdateDate,
					c_Status = @PDC_STATUS
				FROM t_be_ar_pay_paymentdistrib pd 
				inner join t_be_ar_all_paymtdistalloc pda on (pda.c_PaymentDistribution_Id = pd.c_PaymentDistribution_Id)
				inner join t_be_ar_pay_outgoingpaymen opr on (pda.c_OutgoingPaymentRequest_Id = opr.c_OutgoingPaymentRequest_Id)
				where opr.c_OutgoingPaymentRequest_Id = @c_OutgoingPaymentRequest_Id
				
				/* INSERT GAIN LOSS */
				INSERT INTO t_be_acc_tra_gainloss
				select NEWID(), 1, NEWID(), @c_UpdateDate, @c_UpdateDate, PD.c_DivAmount - (PD.c_Amount * @xchange_rate),
				PD.c_Amount, c_DivCurrency, PD.c_Currency, @GLOrigin, @XCHANGE_RATE, PD.c_Domain_Id, PDA.c_PaymentDistributionAlloc_Id
				FROM t_be_ar_pay_paymentdistrib pd 
				inner join t_be_ar_all_paymtdistalloc pda on (pda.c_PaymentDistribution_Id = pd.c_PaymentDistribution_Id)
				inner join t_be_ar_pay_outgoingpaymen opr on (pda.c_OutgoingPaymentRequest_Id = opr.c_OutgoingPaymentRequest_Id)
				where opr.c_OutgoingPaymentRequest_Id = @c_OutgoingPaymentRequest_Id
												
				/* UPDATE OUTGOING PAYMENT REQUEST */
				UPDATE	t_be_ar_pay_outgoingpaymen
				SET		c_ExchangeRate = @xchange_rate,
						c__Version = t_be_ar_pay_outgoingpaymen.c__version + 1,
						c_UpdateDate = @c_UpdateDate,
						c_status =  @OPRC_STATUS,
						c_StatusDate = @OPRC_STATUSDATE,
						c_DivisionAmount = ISNULL(GL.SUMGainLoss, 0)
				FROM (
					SELECT SUM(IGL.c_GainLossAmount) SUMGainLoss FROM  t_be_acc_tra_gainloss IGL 
					INNER JOIN t_be_ar_all_paymtdistalloc PDA ON (PDA.c_PaymentDistributionAlloc_Id = IGL.c_PaymentDistributionAlloc_Id)
					INNER JOIN t_be_ar_pay_outgoingpaymen OP ON (PDA.c_OutgoingPaymentRequest_Id = OP.c_OutgoingPaymentRequest_Id)
					WHERE OP.c_OutgoingPaymentRequest_Id = PDA.c_OutgoingPaymentRequest_Id
					AND OP.c_OutgoingPaymentRequest_Id = @c_OutgoingPaymentRequest_Id
					) GL 
				WHERE t_be_ar_pay_outgoingpaymen.c_OutgoingPaymentRequest_Id = @c_OutgoingPaymentRequest_Id;
      