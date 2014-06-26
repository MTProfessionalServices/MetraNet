select 	tx_FailureID_Encoded,
		tx_FailureCompoundID_encoded,
		tx_FailureID,
        tx_FailureCompoundID,
		tx_FailureServiceName, 
		n_Code, 
		n_Line, 
		tx_ErrorMessage,
        tx_StageName, 
		tx_Plugin, 
		tx_Module, 
		tx_Method, 
		tx_Batch, 
		tx_Batch_Encoded,
        b_compound, 
		dt_FailureTime, 
		dt_MeteredTime, 
		id_PossiblePayeeID, 
		id_PossiblePayerID, 
		id_sch_ss, 
		ed.id_enum_data,
        tx_Sender
from t_failed_transaction ft
inner join t_enum_data ed
on upper(ft.tx_failureServiceName) = upper(ed.nm_enum_data)
where ft.state in ('N', 'I', 'C', 'P', 'R')
%%FILTER%%
order by id_failed_transaction DESC