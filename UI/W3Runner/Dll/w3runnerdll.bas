Attribute VB_Name = "W3RunnerDllMOdule"
Option Explicit

' Thread safe queue
Public q As New CQueue
Public Declare Function WaitForSingleObject Lib "kernel32" (ByVal hHandle As Long, ByVal dwMilliseconds As Long) As Long
Public Declare Function CreateMutex Lib "kernel32" Alias "CreateMutexA" (ByVal lpMutexAttributes As Long, ByVal bInitialOwner As Long, ByVal lpName As String) As Long
Public Declare Function ReleaseMutex Lib "kernel32" (ByVal hMutex As Integer) As Integer
Public Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long
Public Const ERROR_ALREADY_EXISTS = 183&
Public Const QueueMutex = "W3Runner Lock"
Public Const QUEUE_INFINITE = &HFFFF
Public Const QUEUE_WAIT_OBJECT_0 = 0
Public Const QUEUE_WAIT_TIMEOUT = &H102
 


Public Type PROCESS_MEMORY_COUNTERS
    cb                          As Long
    PageFaultCount              As Long
    PeakWorkingSetSize          As Long
    WorkingSetSize              As Long
    QuotaPeakPagedPoolUsage     As Long
    QuotaPagedPoolUsage         As Long
    QuotaPeakNonPagedPoolUsage  As Long
    QuotaNonPagedPoolUsage      As Long
    PagefileUsage               As Long
    PeakPagefileUsage           As Long
End Type

Private Type MEMORYSTATUS
    dwLength As Long
    dwMemoryLoad As Long
    dwTotalPhys As Long
    dwAvailPhys As Long
    dwTotalPageFile As Long
    dwAvailPageFile As Long
    dwTotalVirtual As Long
    dwAvailVirtual As Long
End Type

Private Declare Sub GlobalMemoryStatus Lib "kernel32" (lpBuffer As MEMORYSTATUS)
   


Public Declare Function GetCurrentProcess Lib "kernel32" () As Long
Public Declare Function GetProcessMemoryInfo Lib "psapi.dll" (ByVal lHandle As Long, ByVal lpStructure As Long, ByVal lSize As Long) As Integer

Public Declare Function GetCurrentProcessId Lib "kernel32" () As Long

      Public Declare Function Process32First Lib "kernel32" ( _
         ByVal hSnapshot As Long, lppe As PROCESSENTRY32) As Long

      Public Declare Function Process32Next Lib "kernel32" ( _
         ByVal hSnapshot As Long, lppe As PROCESSENTRY32) As Long

      
      
      Public Declare Function EnumProcesses Lib "psapi.dll" _
         (ByRef lpidProcess As Long, ByVal cb As Long, _
            ByRef cbNeeded As Long) As Long

      Public Declare Function GetModuleFileNameExA Lib "psapi.dll" _
         (ByVal hProcess As Long, ByVal hModule As Long, _
            ByVal ModuleName As String, ByVal nSize As Long) As Long

      Public Declare Function EnumProcessModules Lib "psapi.dll" _
         (ByVal hProcess As Long, ByRef lphModule As Long, _
            ByVal cb As Long, ByRef cbNeeded As Long) As Long

      Public Declare Function CreateToolhelp32Snapshot Lib "kernel32" ( _
         ByVal dwFlags As Long, ByVal th32ProcessID As Long) As Long

      Public Declare Function GetVersionExA Lib "kernel32" _
         (lpVersionInformation As OSVERSIONINFO) As Integer

      Public Type PROCESSENTRY32
         dwSize As Long
         cntUsage As Long
         th32ProcessID As Long           ' This process
         th32DefaultHeapID As Long
         th32ModuleID As Long            ' Associated exe
         cntThreads As Long
         th32ParentProcessID As Long     ' This process's parent process
         pcPriClassBase As Long          ' Base priority of process threads
         dwFlags As Long
         szExeFile As String * 260       ' MAX_PATH
      End Type

'      Public Type OSVERSIONINFO
'         dwOSVersionInfoSize As Long
'         dwMajorVersion As Long
'         dwMinorVersion As Long
'         dwBuildNumber As Long
'         dwPlatformId As Long           '1 = Windows 95.
'                                        '2 = Windows NT
'
'         szCSDVersion As String * 128
'      End Type

      
      
      'Public Const MAX_PATH = 260
      Public Const STANDARD_RIGHTS_REQUIRED = &HF0000
      'Public Const SYNCHRONIZE = &H100000
      'STANDARD_RIGHTS_REQUIRED Or SYNCHRONIZE Or &HFFF
      Public Const PROCESS_ALL_ACCESS = &H1F0FFF
      Public Const TH32CS_SNAPPROCESS = &H2&
      Public Const hNull = 0


Public Function GetCurrentGMTTime(Optional ByVal strDateSeparator As String = "/", Optional ByVal strTimeSeparator As String = ":") As Variant

    On Error GoTo errmgr

    Dim usrTime As SYSTEMTIME
   
    ' Call the procedure to load the SYSTEMTIME structure.
    GetSystemTime usrTime

    With usrTime
        GetCurrentGMTTime = Format(.Year, "0000") & strDateSeparator & Format(.Month, "00") & strDateSeparator & Format(.Day, "00") & " " & Format(.Hour, "00") & strTimeSeparator & Format(.Minute, "00") & strTimeSeparator & Format(.Second, "00")
    End With

    Exit Function
errmgr:

End Function

