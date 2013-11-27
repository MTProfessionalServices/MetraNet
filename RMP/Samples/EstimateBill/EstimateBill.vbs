 '-------------------------------------------------------------------------------------
 ' Run this script with an interval id to rate aggregate usage.
 '-------------------------------------------------------------------------------------
 Dim objProductCatalog
 Set objProductCatalog = CreateObject("MetraTech.MTProductCatalog.1")

 If WScript.Arguments.Count <> 1 Then
   WScript.echo "USAGE:  EstimateBill.vbs intervalID" 
   WScript.quit
 End If

 WScript.echo "Rating all aggregate charges for interval " &  WScript.Arguments.Item(0) & "..."   

 ' NOTE: the second argument is the number of sessions per session set.
 '       this can be tuned to increase performance
 Call objProductCatalog.RateAllAggregateCharges(CLng(WScript.Arguments.Item(0)), 1000)

 WScript.sleep 5000
 WScript.echo "Estimation Done." 
