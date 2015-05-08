Update t_failed_transaction
Set dt_Start_Resubmit = TO_TIMESTAMP(%%DT_Resubmit%%,'MM/dd/yyyy hh24:mi:ss.ff'),
	resubmit_Guid = '%%ResubmitGuid%%'
Where id_failed_transaction in (%%Ids%%) and (dt_Start_Resubmit IS NULL OR(dt_Start_Resubmit<TO_Timestamp(%%DateDiff%%,'MM/dd/yyyy hh24:mi:ss.ff')))