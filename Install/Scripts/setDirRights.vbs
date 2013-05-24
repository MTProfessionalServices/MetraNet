Function SetDirectoryPermissions (who, what, where)
  Dim intRunError, objShell, objFSO

  Set objShell = CreateObject("Wscript.Shell")
  Set objFSO = CreateObject("Scripting.FileSystemObject")
  'If objFSO.FolderExists(where) Then
    intRunError = objShell.Run("%COMSPEC% /c Echo Y| xcacls.vbs " _
    & where & " /i enable /t /e /g " & who & ":"& what & " ", 2, True)

    If intRunError <> 0 Then
      Wscript.Echo("Error assigning " & what & " permissions for user " _
      & who & " to home folder " & where)
    End If
  'Else
	'Wscript.Echo("Error assigning " & what & " permissions for user " _
  '    & who & " to home folder " & where & ", Directory not found")
  'End If
End Function

Function SetPermission (what, where)
	If SetDirectoryPermissions("IIS_WPG", what, where) Then
	  If Not IsISActive() Then
		'Command line invocation
		Main()
	  End If
	End If
	If SetDirectoryPermissions("""NETWORK SERVICE""", what, where) Then
	  If Not IsISActive() Then
		'Command line invocation
		Main()
	  End If
	End If
End Function


Set oShell = CreateObject( "WScript.Shell" )
systemRoot=oShell.ExpandEnvironmentStrings("%systemroot%")

'Set permissions for iisHelp
iisHelp=systemRoot & "\Help\iisHelp"
If SetPermission ("r", iisHelp) Then
	Script.Echo "Processed " & iisHelp
End If

'Set permissions for inetsrv
inetsrv=systemRoot & "\system32\inetsrv"
If SetPermission ("f", inetsrv) Then
	WScript.Echo "Processed " & inetsrv
End If

'Set permissions for iisTempCompressed
iisTempCompressed=Chr(34) & systemRoot & "\IIS Temporary Compressed Files"""
If SetPermission ("f", iisTempCompressed) Then
	WScript.Echo "Processed " & inetsrv
End If

'Set permissions for Inetpub\wwwroot
wwwroot="c:\Inetpub\wwwroot"
If SetPermission ("rx", wwwroot) Then
	WScript.Echo "Processed " & wwwroot
End If

WScript.Quit


