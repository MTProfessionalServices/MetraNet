Attribute VB_Name = "Globals"


Public lastPlugIn As String
Public lastStage As String
Public lastState As Long

Public Declare Function Sleep Lib "kernel32" _
(ByVal dwMilliseconds As Long) As Long

Public Declare Function GetCurrentThreadId Lib "kernel32" () As Long

'HANDLE CreateEvent(
'  LPSECURITY_ATTRIBUTES lpEventAttributes, // SD
'  BOOL bManualReset,                       // reset type
'  BOOL bInitialState,                      // initial state
'  LPCTSTR lpName                           // object name
');

Declare Function CreateEvent _
         Lib "kernel32" _
               Alias "CreateEventA" _
         (ByVal lpEventAttributes As Long, _
         ByVal bManualReset As Long, _
         ByVal bInitialState As Long, _
         ByVal lpName As String) As Long

'HANDLE CreateMutex(
'  LPSECURITY_ATTRIBUTES lpMutexAttributes,  // SD
'  BOOL bInitialOwner,                       // initial owner
'  LPCTSTR lpName                            // object name
');

Declare Function CreateMutex _
         Lib "kernel32" _
            Alias "CreateMutexA" _
         (ByVal lpMutexAttributes As Long, _
         ByVal bInitialOwner As Long, _
         ByVal lpName As String) As Long

'BOOL ReleaseMutex(
'  HANDLE hMutex   // handle to mutex
');

Declare Function GetLastError Lib "kernel32" () As Long

Declare Function ReleaseMutex _
         Lib "kernel32" (ByVal hMutex As Long) As Long

Declare Function CloseHandle _
         Lib "kernel32" _
         (ByVal hObject As Long) As Long

Declare Function WaitForMultipleObjects _
         Lib "kernel32" (ByVal nCount As Long, _
                         ByRef lpHandles As Long, _
                         ByVal bWaitAll As Long, _
                         ByVal dwMilliseconds As Long) As Long

Declare Function WaitForSingleObject _
         Lib "kernel32" (ByVal hHandle As Long, _
                         ByVal dwMilliseconds As Long) As Long


Declare Function SetEvent _
         Lib "kernel32" (ByVal hEvent As Long) As Long


Declare Function ResetEvent _
         Lib "kernel32" (ByVal hEvent As Long) As Long

Public Const INFINITE = &HFFFFFFFF

