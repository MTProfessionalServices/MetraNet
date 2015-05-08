Select  id_failed_transaction, tx_failurecompoundid_encoded
From t_failed_transaction
Where id_failed_transaction In (%%Ids%%) and (dt_start_resubmit IS NULL OR(dt_start_resubmit<TO_Timestamp(%%DateDiff%%,'MM/dd/yyyy hh24:mi:ss.ff'))) 