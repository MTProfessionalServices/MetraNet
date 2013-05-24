Sub TestCounterTypeHook
On Error Resume Next
Set mConfig = CreateObject("MetraTech.MTConfig.1")
If Err Then
	wscript.echo "Can not create MetraTech.MTConfig.1 " & err.Description
End If

Set aPropSet = mConfig.ReadConfigurationFromString("<xmlconfig><hook>MetraHook.ConfigRefresh.1</hook></xmlconfig>", False)
If Err Then
	wscript.echo "Failed in ReadConfigurationFromString " & err.Description
End If
    
Set aHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")
If Err Then
	wscript.echo "Error while creating MTHookHandler.MTHookHandler.1 " & err.Description
End If

aHookHandler.Read (aPropSet)
If Err Then
	wscript.echo "Error in HookHandler.Read(aPropSet) " & err.Description
End If

aHookHandler.ExecuteAllHooks "", 0
If Err Then
	wscript.echo "Error in HookHandler.ExecuteAllHooks " & err.Description
End If

End Sub


TestCounterTypeHook