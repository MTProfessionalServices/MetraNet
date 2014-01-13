' Run DeployCEReports hook

Dim oHookHandler

On Error Resume Next

Set oHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")

If err.number <> 0 Then
  wscript.echo "Error " & err.number & " creating hook handler: " & err.description

Else
  wscript.echo "Running DeployCEReports hook"
  oHookHandler.RunHookWithProgid "MetraTech.Reports.Hooks.DeployCEReports",""

  If err.number <> 0 Then
    wscript.echo "Error " & err.number & " running hook: " & err.description

  Else
    wscript.echo "Completed"
  End If 

End If
