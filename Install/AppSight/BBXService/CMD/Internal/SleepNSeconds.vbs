  Option Explicit
  Const nSleepSec_Default = 5 ' Default is 5 sec
  Const nSleepSec_Min = 1     ' Min     is 1 sec
  Const nSleepSec_Max = 300   ' Max     is 5 min

  Dim   nSleepSec

  ' Retrieve Arguments
  Dim objArgs
  Set objArgs = WScript.Arguments
  If objArgs.Count = 1 Then
    nSleepSec= objArgs(0)
  End If
  Set objArgs = Nothing

  ' Validate Arguments
  If Not IsNumeric(nSleepSec) Then
    nSleepSec = nSleepSec_Default 
  Else
    nSleepSec = Round(nSleepSec,0)
  End If
  If nSleepSec <  0 Then
     nSleepSec = nSleepSec_Default 
  End If
  ' Keep within Min and Max
  If nSleepSec > nSleepSec_Max Then
     nSleepSec = nSleepSec_Max 
  End If
  If nSleepSec < nSleepSec_Min Then
     nSleepSec = nSleepSec_Min 
  End If

  Wscript.Echo "Waiting for " & nSleepSec & " sec ..."
  WScript.Sleep nSleepSec*1000
