Sub TestPCConfig

On Error Resume Next

Set mConfig = CreateObject("MetraTech.MTPCConfiguration.1")
If Err Then
	wscript.echo "Can not create MetraTech.MTPCConfiguration.1 " & err.Description
End If

mConfig.Load()
If Err Then
	wscript.echo "Failed in Load " & err.Description
End If


chain = mConfig.GetPLChaining()
If Err Then
	wscript.echo "Failed in GetPLChaining " & err.Description
Else
	wscript.echo "Current Pricelist chaining is: " & chain
End If

timeout = mConfig.GetBatchSubmitTimeout()
If Err Then
	wscript.echo "Failed in GetBatchSubmitTimeout " & err.Description
Else
	wscript.echo "Current GetBatchSubmitTimeout value (in secs) is: " & timeout
End If


wscript.echo "Checking if EnforceCounterConfig rule is enabled "
bAvail = mConfig.IsBusinessRuleEnabled(1)
If Err Then
	wscript.echo "Failed in IsBusinessRuleEnabled(1) " & err.Description
Else
	wscript.echo "EnforceCounterConfig rule enablement: " & bAvail
End If

wscript.echo "Checking if EnforceRateScheduleDates rule is enabled "
bAvail = mConfig.IsBusinessRuleEnabled(2)
If Err Then
	wscript.echo "Failed in EnforceRateScheduleDates(1) " & err.Description
Else
	wscript.echo "EnforceRateScheduleDates rule enablement: " & bAvail
End If

End Sub

TestPCConfig