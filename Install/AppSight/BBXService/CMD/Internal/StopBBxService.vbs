Option Explicit
Dim strComputer
Dim objWMIService, objBBxService, colProcessStopTrace, objLatestEvent
Dim nResult, nProcessId

strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & _
    strComputer & "\root\cimv2")

' The AppSight Black Box Service may not be installed
On Error Resume Next
Set objBBxService = _
    objWMIService.Get("Win32_Service.Name='BBxService'")
If Err.Number <> 0 Then
  WScript.Echo "Error accessing service: BBxService"
  WScript.Echo "RC=" & Err.Number & " " & Err.Description
  WScript.Quit(Err.Number)
End If
On Error GoTo 0

nResult = -1 ' Init RC for Invalid State
WScript.Echo "BBxService state: " & objBBxService.State

' Only try to stop service when in the Running state
If objBBxService.State = "Running" Then
  nProcessId = objBBxService.ProcessId
  ' Important to do this before the StopService is issued
  ' so we don't miss the notification
  Set colProcessStopTrace = objWMIService.ExecNotificationQuery _
    ("SELECT * FROM Win32_ProcessStopTrace WHERE ProcessID =" & nProcessId )
  WScript.Echo "Stopping service: BBxService"
  nResult = objBBxService.StopService()
  ' When large ASL files are being generated, the StopService will often timeout.
  ' The following code will wait for the process to exit.
  WScript.Echo "StopService RC=" & nResult
  If nResult <> 0 Then
    WScript.Echo "Waiting for Process ID " & nProcessId & " to stop ..."
    WScript.Echo "This could take from 1 to 20 minutes (or more)    ..."
    Set objLatestEvent = colProcessStopTrace.NextEvent
    WScript.Echo "Process Stop Event Occurred"
    Wscript.Echo "Process Name: " & objLatestEvent.ProcessName
    Wscript.Echo "Process ID: " & objLatestEvent.ProcessId
    nResult = 0
    Set objLatestEvent = Nothing
  End If
  Set colProcessStopTrace = Nothing
End If

Set objBBxService = Nothing
Set objWMIService = Nothing

' Returns 0 if BBxService was actually stopped
WScript.Quit(nResult)
