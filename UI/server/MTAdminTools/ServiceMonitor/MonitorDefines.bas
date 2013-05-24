Attribute VB_Name = "MonitorDefines"
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Enum SERVICE_STATE
  SERVICE_UNKNOWN = 0 ' not a real status code
  SERVICE_STOPPED = &H1
  SERVICE_START_PENDING = &H2
  SERVICE_STOP_PENDING = &H3
  SERVICE_RUNNING = &H4
  SERVICE_CONTINUE_PENDING = &H5
  SERVICE_PAUSE_PENDING = &H6
  SERVICE_PAUSED = &H7
End Enum
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Type SERVICE_STATUS
  dwServiceType As Long
  dwCurrentState As Long
  dwControlsAccepted As Long
  dwWin32ExitCode As Long
  dwServiceSpecificExitCode As Long
  dwCheckPoint As Long
  dwWaitHint As Long
End Type
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Const SC_MANAGER_CONNECT = 1
Public Const SC_MANAGER_CREATE_SERVICE = 2
Public Const SC_MANAGER_ENUMERATE_SERVICE = 4
Public Const SC_MANAGER_LOCK = 8
Public Const SC_MANAGER_QUERY_LOCK_STATUS = 16
Public Const SC_MANAGER_MODIFY_BOOT_CONFIG = 32
Public Const STANDARD_RIGHTS_REQUIRED = &HF0000
Public Const SC_MANAGER_ALL_ACCESS = SC_MANAGER_CONNECT Or _
  SC_MANAGER_CREATE_SERVICE Or SC_MANAGER_ENUMERATE_SERVICE Or _
  SC_MANAGER_LOCK Or SC_MANAGER_QUERY_LOCK_STATUS Or _
  SC_MANAGER_MODIFY_BOOT_CONFIG Or STANDARD_RIGHTS_REQUIRED


'Stop the service
Public Const SERVICE_CONTROL_STOP = &H1

Public Const SERVER_ACCESS_ENUMERATE = &H2
Public Const SERVICE_QUERY_CONFIG = &H1
Public Const SERVICE_CHANGE_CONFIG = &H2
Public Const SERVICE_QUERY_STATUS = &H4
Public Const SERVICE_ENUMERATE_DEPENDENTS = &H8
Public Const SERVICE_START = &H10
Public Const SERVICE_STOP = &H20
Public Const SERVICE_PAUSE_CONTINUE = &H40
Public Const SERVICE_INTERROGATE = &H80
Public Const SERVICE_USER_DEFINED_CONTROL = &H100
Public Const SERVICE_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED Or _
  SERVICE_QUERY_CONFIG Or SERVICE_CHANGE_CONFIG Or _
  SERVICE_QUERY_STATUS Or SERVICE_ENUMERATE_DEPENDENTS Or _
  SERVICE_START Or SERVICE_STOP Or SERVICE_PAUSE_CONTINUE Or _
  SERVICE_INTERROGATE Or SERVICE_USER_DEFINED_CONTROL

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function Declarations                                                               '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Declare Function OpenSCManager _
  Lib "advapi32.dll" Alias "OpenSCManagerA" _
  (ByVal lpMachineName As String, _
  ByVal lpDatabaseName As String, _
  ByVal dwDesiredAccess As Long) _
  As Long
  
Declare Function CloseServiceHandle _
   Lib "advapi32.dll" _
   (ByVal hSCObject As Long) _
   As Long

Declare Function OpenService _
   Lib "advapi32.dll" Alias "OpenServiceA" _
   (ByVal hSCManager As Long, _
   ByVal lpServiceName As String, _
   ByVal dwDesiredAccess As Long) _
   As Long
   
Declare Function QueryServiceStatus _
   Lib "advapi32.dll" _
   (ByVal hService As Long, _
   lpServiceStatus As SERVICE_STATUS) _
   As Long
   
Declare Function StartService _
  Lib "advapi32.dll" Alias "StartServiceA" _
  (ByVal hService As Long, _
  ByVal ArgCount As Long, _
  ByVal lpArgVectors As Long) _
  As Long
  
Declare Function ControlService _
  Lib "advapi32.dll" _
  (ByVal hSCManager As Long, _
  ByVal dwControl As Long, _
  lpServiceStatus As SERVICE_STATUS) _
  As Long
    


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
