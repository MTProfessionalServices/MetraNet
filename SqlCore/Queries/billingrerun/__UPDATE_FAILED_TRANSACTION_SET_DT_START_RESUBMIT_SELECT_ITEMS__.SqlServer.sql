Update t_failed_transaction
Set dt_Start_Resubmit = CAST('%%DT_Resubmit%%' as datetime2),
	resubmit_Guid = %%ResubmitGuid%%
Where id_failed_transaction in (%%Ids%%) and (dt_Start_Resubmit IS NULL OR(dt_Start_Resubmit<Cast('%%DateDiff%%' as datetime2)))