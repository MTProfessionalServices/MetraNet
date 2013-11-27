  
        select 
				  id_failed_transaction CaseNumber, 
					State as Status,
					tx_StateReasonCode StateReasonCode, 
					tx_FailureID_Encoded FailureSessionId, 
					tx_FailureCompoundID_Encoded FailureCompoundSessionId, 
					b_compound Compound, 
					id_PossiblePayeeID PossibleAccountId, 
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
				  t_failed_transaction 
				where 
				  state='N'
      