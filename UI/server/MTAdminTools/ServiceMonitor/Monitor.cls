VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Monitor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Dim hSCManager As Long

Dim mstrUserName As String
Dim mstrDomain As String
Dim mstrPassword As String

Dim mobjNetUser As Object




'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function GetAllAccessService(strServiceName)                                                '
'                                                                                             '
' Description:                                                                                '
'   Get an all-access handle to a service.                                                    '
'                                                                                             '
' Arguments:                                                                                  '
'   strServiceName -- name of the service to get the handle of                                '
'                                                                                             '
' Returns:                                                                                    '
'   The handle to the service                                                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function GetAllAccessService(strServiceName) As Long
  Dim hService As Long
  Const SC_CONNECT_MASK = SC_MANAGER_CONNECT Or SC_MANAGER_ENUMERATE_SERVICE
  Const SC_SERVICE_MASK = SERVICE_QUERY_STATUS Or SERVICE_START Or SERVICE_STOP
'  On Error Resume Next
      
  'Open the service manager
   hSCManager = OpenSCManager(vbNullString, vbNullString, SC_CONNECT_MASK)
  
  'Check for error
  If hSCManager = 0 Then
    Err.Description = "Unable to open Service Manager"
    Err.Raise vbObjectError + 1
    Exit Function
  End If
  
  hService = OpenService(hSCManager, strServiceName, SC_SERVICE_MASK)
  
  If hService = 0 Then
    CloseServiceHandle hSCManager
    Err.Description = "Unable to open Service: " & strServiceName
    Err.Raise vbObjectError + 2
    Exit Function
  End If
  
  GetAllAccessService = hService

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function GetServiceState(strServiceName)                                                    '
'                                                                                             '
' Description:                                                                                '
'   Open the service manager and get the status of a service.                                 '
'                                                                                             '
' Arguments:                                                                                  '
'   strServiceName -- name of the service to get the status of                                '
'                                                                                             '
' Returns:                                                                                    '
'   The status of the service, STARTED, STOPPED, PENDING, or UNKNOWN                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function GetServiceState(strServiceName)
  'On Error Resume Next
  Dim hService As Long
  Dim hStatus As SERVICE_STATUS
  Dim hState As SERVICE_STATE
  
  'Logon
  If Len(mstrUserName) > 0 Then
    Call mobjNetUser.CheckLogon(mstrUserName, mstrPassword, mstrDomain)
  End If
  
  hService = GetAllAccessService(strServiceName)
  
  If QueryServiceStatus(hService, hStatus) = 1 Then
    hState = hStatus.dwCurrentState
  Else
    CloseServiceHandle hService
    CloseServiceHandle hSCManager
    Err.Description = "Unable to Query Service Status: " & strServiceName
    Err.Raise vbObjectError + 3
    Exit Function
  End If
  
  'Cleanup
  CloseServiceHandle hService
  CloseServiceHandle hSCManager
  
  'Get the return value
  If hState = SERVICE_CONTINUE_PENDING Or _
     hState = SERVICE_PAUSE_PENDING Or _
     hState = SERVICE_START_PENDING Or _
     hState = SERVICE_STOP_PENDING Then
    
    GetServiceState = "PENDING"
  
  ElseIf hState = SERVICE_RUNNING Then
    GetServiceState = "STARTED"
    
  ElseIf hState = SERVICE_PAUSED Or hState = SERVICE_STOPPED Then
    GetServiceState = "STOPPED"
  
  Else
    GetServiceState = "UNKNOWN"
  End If
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function ServiceStart(strServiceName)                                                       '
'                                                                                             '
' Description:                                                                                '
'   Start the specified service.                                                              '
'                                                                                             '
' Arguments:                                                                                  '
'   strServiceName -- name of the service to start                                            '
'                                                                                             '
' Returns:                                                                                    '
'   none                                                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function ServiceStart(strServiceName)
  'On Error Resume Next
  Dim hService As Long
  Dim hStatus As SERVICE_STATUS
  Dim strState
  Dim Temp
  Dim ErrorNum
  
  strState = GetServiceState(strServiceName)
  
  If strState = "STOPPED" Then
    hService = GetAllAccessService(strServiceName)
    Temp = StartService(hService, 0, 0)
    'Temp = ControlService(hService, SERVICE_START, hStatus)

    If Temp <> 1 Then
      CloseServiceHandle hService
      CloseServiceHandle hSCManager
      Err.Description = "Unable to Start Service: " & strServiceName
      Err.Raise vbObjectError + 3
      Exit Function
    End If
  
  'cleanup
  CloseServiceHandle hService
  CloseServiceHandle hSCManager
  
  End If
      
      
  
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function ServiceStop(strServiceName)                                                        '
'                                                                                             '
' Description:                                                                                '
'   Stop the specified service.                                                               '
'                                                                                             '
' Arguments:                                                                                  '
'   strServiceName -- name of the service to stop                                             '
'                                                                                             '
' Returns:                                                                                    '
'   none                                                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ServiceStop(strServiceName)
  On Error Resume Next
  Dim hService
  Dim strState
  Dim hStatus As SERVICE_STATUS
  
  strState = GetServiceState(strServiceName)
  
  If strState = "STARTED" Then
  hService = GetAllAccessService(strServiceName)
  
    If ControlService(hService, SERVICE_CONTROL_STOP, hStatus) <> 1 Then
      CloseServiceHandle hService
      CloseServiceHandle hSCManager
      Err.Description = "Unable to Start Service: " & strServiceName
      Err.Raise vbObjectError + 3
      Exit Function
    End If
  
  End If
  
  'cleanup
  CloseServiceHandle hService
  CloseServiceHandle hSCManager
    
End Function



Public Property Let UserName(ByVal strVal As String)
  strVal = Replace(strVal, "/", "\")
  
  If InStr(strVal, "\") > 0 Then
    mstrDomain = Left(strVal, InStr(strVal, "\") - 1)
    mstrUserName = Mid(strVal, InStr(strVal, "\") + 1)
  Else
    mstrDomain = ""
    mstrUserName = strVal
  End If
End Property

Public Property Let Password(ByVal strPassword As String)
  Let mstrPassword = strPassword
End Property

Private Sub Class_Initialize()
  Set mobjNetUser = CreateObject("MTNetUser.UserInfo")
End Sub
