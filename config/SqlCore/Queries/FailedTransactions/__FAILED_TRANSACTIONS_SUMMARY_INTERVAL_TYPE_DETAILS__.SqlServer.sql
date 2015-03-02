  
				select
					id_failed_transaction CaseNumber, 
					State as Status,
					tx_StateReasonCode StateReasonCode, 
					tx_FailureID_Encoded FailureSessionId, 
					tx_FailureCompoundID_Encoded FailureCompoundSessionId, 
					b_compound Compound, 
					id_PossiblePayeeID PossibleAccountId, 
					id_PossiblePayerID PossiblePayerAccountId, 
					uc.id_cycle_type as UsageCycleType,
					CASE WHEN uc.id_cycle_type IS NULL THEN 'UNDETERMINED' ELSE uct.tx_desc END as UsageCycleTypeName,
					(CASE uc.id_cycle_type
						WHEN 1 THEN CAST(uc.day_of_month AS varchar(5)) /*Monthly*/
						WHEN 3 THEN '' /*Daily*/
						WHEN 4 THEN CAST(uc.start_day AS varchar(5))  /*Weekly*/
						WHEN 5 THEN CAST(uc.start_day AS varchar(5)) + ' ' + CAST(uc.start_month AS varchar(5)) /*Bi-weekly*/
						WHEN 6 THEN CAST(uc.first_day_of_month AS varchar(5)) + ' ' + CAST(uc.second_day_of_month AS varchar(5)) /*Semi-monthly*/
						WHEN 7 THEN CAST(uc.start_day AS varchar(5)) + ' ' + CAST(uc.start_month AS varchar(5)) /*Quaterly*/
						WHEN 8 THEN CAST(uc.start_day AS varchar(5)) + ' ' + CAST(uc.start_month AS varchar(5))/*Annually*/
						ELSE '' END) as UsageCycleValue,					
					tx_FailureServiceName FailureServiceName,
					dbo.MTHexFormat(n_Code) Code, 
					n_Line Line, 
					dt_FailureTime FailureTime, 
					dt_MeteredTime MeteredTime, 
					tx_Sender Sender,
					tx_ErrorMessage ErrorMessage, 
					tx_StageName StageName, 
					tx_PlugIn Plugin, 
					tx_Module Module, 
					tx_Method Method, 
					tx_Batch_Encoded BatchId, 
					tx_errorcodemessage CodeMessage 
				from 
				  t_failed_transaction ft
				  left join t_acc_usage_cycle auc on auc.id_acc = ft.id_PossiblePayerID
				  left join t_usage_cycle uc on auc.id_usage_cycle = uc.id_usage_cycle
				  left join t_usage_cycle_type uct on uc.id_cycle_type = uct.id_cycle_type
				where
				  State in ('N','I', 'C')  and  (
                                         (dt_start_resubmit IS NULL) 
                                         OR 
                                         (dt_start_resubmit < CAST ('%%DiffTime%%' as datetime2))
                                        )      