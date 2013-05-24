VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "PerfMon"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                  '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim hQuery As Long            'handle to the pdh query
Dim hCounter As Long          'handle to the counter


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Init(strQuery)                                                    '
'                                                                   '
' Description:                                                      '
'   Opens a pdh query and adds a counter for the data specified by  '
'   the string argument                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function Init(strQuery)
  On Error GoTo ErrorHandler
    
  Dim pdhStatus As PDH_STATUS   'status returned from calls
    
  hQuery = 0
  hCounter = 0
  
  'Open the pdh Query (remember to close!)
  If hQuery = 0 Then
    pdhStatus = PdhOpenQuery(CLng(0), CLng(0), hQuery)
  End If
  
  
  If pdhStatus <> ERROR_SUCCESS Then
    Err.Description = "Unable to Open the PDH Query <pdh error code:" & pdhStatus & ">"
    Err.Raise vbObjectError + 1
  End If
  
  
  'Add the counter
  pdhStatus = PdhVbAddCounter(hQuery, strQuery, hCounter)
  
  If pdhStatus <> ERROR_SUCCESS Then
    Err.Description = "Unable to Add PDH Counter <pdh error code:" & pdhStatus & "  pdh counter: " & strQuery & ">"
    Err.Raise vbObjectError + 1
  End If

ErrorHandler:
If Err Then
  CloseQuery
  Init = False
Else
  Init = True
End If

End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' GetValue()                                                        '
'                                                                   '
' Description:                                                      '
'   Retrieve the value of the counter that was added.               '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetValue()
  On Error GoTo ErrorHandler
  
  Dim pdhStatus As PDH_STATUS
  Dim dblValue As Double
  
  If hQuery <> 0 Then
    pdhStatus = PdhCollectQueryData(hQuery)
  
    If pdhStatus <> ERROR_SUCCESS Then
      Err.Description = "Unable to Get Query Data <pdh error code:" & pdhStatus & ">"
      Err.Raise vbObjectError + 1
    End If

    dblValue = PdhVbGetDoubleCounterValue(hCounter, pdhStatus)
                
  ' Verify that when we queried, the returned value was valid
    If pdhStatus <> PDH_CSTATUS_VALID_DATA And pdhStatus <> PDH_CSTATUS_NEW_DATA Then
      Err.Description = "Unable to Get Valid Data <pdh error code:" & pdhStatus & ">"
      Err.Raise vbObjectError + 1
    End If

    
  Else
    Err.Description = "No valid Query Handle"
    Err.Raise vbObjectError + 1
  End If
  
ErrorHandler:
  If Err Then
    CloseQuery
    GetValue = 0
  Else
    GetValue = dblValue
  End If
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub CloseQuery()
  PdhCloseQuery hQuery
  hQuery = 0
End Sub

