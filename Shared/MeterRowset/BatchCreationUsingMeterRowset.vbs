
Option explicit

on error resume next

Const MTC_DT_WCHAR = 0
Const MTC_DT_CHAR = 1
Const MTC_DT_INT = 2
Const MTC_DT_FLOAT = 3
Const MTC_DT_DOUBLE = 4
Const MTC_DT_TIME = 5
Const MTC_DT_BOOL = 6
Const MTC_DT_DECIMAL = 7

'meter.AddColumnMapping "counter1", MTC_DT_DECIMAL, "TotalMinutes", True
'meter.AddColumnMapping "counter2", MTC_DT_DECIMAL, "TotalPages", true
'meter.AddCommonProperty "piid", MTC_DT_INT, CInt(12346)
'meter.AddCommonProperty "caption", MTC_DT_INT, "a simple test"

Dim myQuery
myQuery = " " & _ 
	"select " & _ 
		"ac.id_sess, " & _ 
		"ac.tx_UID, " & _
		"ac.id_acc, " & _
		"ac.id_usage_interval, " & _
		"ac.id_parent_sess,  " & _
		"ac.dt_session,  " & _
		"ac.amount, " & _
		"ac.am_currency, " & _
		"ac.tx_batch, " & _
		"ac.dt_crt, " & _
		"pv.c_description,  " & _
		"pv.c_time, " & _
		"pv.c_units, " & _
		"'demo' as c_accountname " & _
	"from  " & _
		"t_pv_testservice pv join t_acc_usage ac " & _
	"on  " & _
		"ac.id_sess = pv.id_sess and " & _ 
		"ac.id_sess = 10000 "
	
wscript.echo "Query = " & myQuery 
Dim myRowset
set myRowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
myRowset.Init "queries\Database"
myRowset.SetQueryString myQuery
myRowset.Execute

Dim meterrowset
set meterrowset= CreateObject("MetraTech.MeterRowset")
meterrowset.InitSDK "AggregateRatingServer"
meterrowset.InitForService "metratech.com/testservice"

Dim objBatch
Dim someStr
someStr = CStr(Int(Timer()))

wscript.echo "Seq. Number = " & someStr

set objBatch = meterrowset.CreateAdapterBatch (Int(someStr), "myadapter", someStr)
if err then
  wscript.echo "ERROR Saving Batch Information [Description = " & err.Description & "]"
   wscript.quit
else
 	wscript.echo "New batch created with UID = " & objBatch.UID
end if

wscript.echo "Metering rowset" 
meterrowset.MeterRowset myRowset
wscript.echo "Done metering rowset" 

wscript.echo "Refreshing batch" 
objBatch.Refresh

wscript.echo "Batch UID Encoded    " & objBatch.UID
wscript.echo "Batch Name           " & objBatch.Name
wscript.echo "Batch Namespace      " & objBatch.Namespace
wscript.echo "Batch Status         " & objBatch.Status
wscript.echo "Batch Creation Date  " & objBatch.CreationDate
wscript.echo "Batch Source         " & objBatch.Source
wscript.echo "Sequence Number      " & objBatch.SequenceNumber
wscript.echo "Completed Count      " & objBatch.CompletedCount
wscript.echo "Expected Count       " & objBatch.ExpectedCount
wscript.echo "Failure Count        " & objBatch.FailureCount
wscript.echo "Source Creation Date " & objBatch.SourceCreationDate

wscript.echo "Done refreshing batch" 

wscript.echo "SUCCESS!!" 

