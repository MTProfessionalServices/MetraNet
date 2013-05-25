' This unit test will test every proptery type through MeterRowset.

' To run it:
'  cmdstage testprops writeproductview -routefrom routingqueue
'  autosdk localhost r:\extensions\perftest\test\autosdk\metratech.com\testprops.xml
'  MeterRowsetPropTest.vbs


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

Dim myQuery
myQuery = "select pv.id_sess, pv.c_TestCase, pv.c_IntProp1, pv.c_StringProp1, pv.c_StringProp2, pv.c_DecProp1," & _
       "pv.c_DoubleProp1, pv.c_BoolProp1, pv.c_BoolProp1Default, pv.c_EnumProp1," & _
       "pv.c_TimestampProp1 from t_pv_testprops pv inner join t_acc_usage au on au.id_sess = pv.id_sess"
wscript.echo "Query = " & myQuery 
Dim myRowset
set myRowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
myRowset.Init "queries\Database"
myRowset.SetQueryString myQuery
myRowset.Execute

Dim meterrowset
set meterrowset= CreateObject("MetraTech.MeterRowset")
meterrowset.InitSDK "AggregateRatingServer"
meterrowset.InitForService "metratech.com/testprops"

meterrowset.MeterRowset myRowset
wscript.echo "metering rowset" 
