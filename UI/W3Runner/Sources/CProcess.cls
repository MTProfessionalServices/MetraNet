VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CProcess"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' ****************************************************************************************************************************************************
'
'  Written (W) by Frederic Torres 2001-2002
'  ARR.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : 6/xx/2001
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Public ProcessID        As Long
Public ModuleName       As String

Private m_ProcessHandle As Long
Private m_strName       As String
Private m_strShortName  As String

Public Function Initialize(Optional ByVal strName As String, Optional ByVal lngProcessID As Long, Optional ByVal strShortName As String, Optional ByRef lngProcessCount As Long) As Boolean

'    Debug.Assert 0
        
    m_strShortName = strShortName
    
    If (Len(strName)) Then
        m_strName = strName
        ProcessID = GetProcessIDFromName(strName, lngProcessCount)
        Initialize = ProcessID <> 0
    Else
        If (lngProcessID) Then
            ProcessID = lngProcessID
        Else
            ProcessID = GetCurrentProcessId()
        End If
        Initialize = True
    End If
End Function

Public Function GetProcessIDFromName(ByVal strName As String, ByRef lngProcessCount As Long) As Long

    Const MAX_MODULES As Long = 200
    Dim cb                  As Long
    Dim cbNeeded            As Long
    Dim NumElements         As Long
    Dim ProcessIDs()        As Long
    Dim cbNeeded2           As Long
    Dim Modules(1 To MAX_MODULES)   As Long
    Dim lRet                As Long
    Dim nSize               As Long
    Dim hProcess            As Long
    Dim i                   As Long
    
    Dim lngProcessID        As Long
    
    strName = UCase$(strName)
    lngProcessCount = 0
    
    ' Read all the ProcessID and store them in an array
    cb = 8
    cbNeeded = cb + 1
    Do While cb <= cbNeeded
       cb = cb * 2
       ReDim ProcessIDs(cb / 4) As Long
       lRet = EnumProcesses(ProcessIDs(1), cb, cbNeeded)
    Loop
    NumElements = cbNeeded / 4
    
    ' Loop around all the process and for each process around their module and get their name
    For i = 1 To NumElements
    
        Debug.Print ProcessIDs(i)
    
        hProcess = OpenProcess(PROCESS_QUERY_INFORMATION Or PROCESS_VM_READ, 0, ProcessIDs(i)) 'Get a handle to the Process
        If hProcess <> 0 Then 'Got a Process handle
        
            lRet = EnumProcessModules(hProcess, Modules(1), MAX_MODULES, cbNeeded2) 'Get an array of the module handles for the specified process
            If lRet <> 0 Then 'If the Module Array is retrieved, Get the ModuleFileName
            
               ModuleName = Space(MAX_PATH)
               nSize = 500 ' why this ?
               lRet = GetModuleFileNameExA(hProcess, Modules(1), ModuleName, nSize)
               
               ModuleName = UCase$(Left(ModuleName, lRet))
               'Debug.Print ModuleName
               If InStr(ModuleName, strName) Then
                    lngProcessID = ProcessIDs(i)
                    lngProcessCount = lngProcessCount + 1
               End If
            End If
        End If
        lRet = CloseHandle(hProcess) 'Close the handle to the process
        If (lngProcessID) Then Exit For
    Next
    GetProcessIDFromName = lngProcessID
End Function

Public Function getMemoryInfo() As String

   Dim lReturn     As Long
   Dim uMemory     As PROCESS_MEMORY_COUNTERS
   Dim s           As String
   Dim MS          As MEMORYSTATUS


   lReturn = GetProcessMemoryInfo(OpenProcessHandle(), VarPtr(uMemory), Len(uMemory)) 'GetCurrentProcess()
      
   MS.dwLength = Len(MS)
   GlobalMemoryStatus MS
   
   ''635476 201048 2018236 0.0595703125 885416 523832 2097024
   
  's = MS.dwAvailPageFile / 1024 & " " & MS.dwAvailPhys / 1024 & " " & MS.dwAvailVirtual / 1024 & " " & MS.dwMemoryLoad & " " & MS.dwTotalPageFile / 1024 & " " & MS.dwTotalPhys / 1024 & " " & MS.dwTotalVirtual / 1024 & " "
   'Clipboard.Clear
   'Clipboard.SetText s
      
   getMemoryInfo = uMemory.WorkingSetSize / 1024 & "," & uMemory.PagefileUsage / 1024 & "," & MS.dwAvailPhys / 1024 & "," & MS.dwAvailVirtual / 1024
   
   CloseProcessHandle

   's = s & "Structure size: " & uMemory.cb & " "
   's = s & "Working set: " & uMemory.WorkingSetSize / 1024 & " "
   's = s & "Page file usage: " & uMemory.PagefileUsage / 1024 & " "
   's = s & "Page faults: " & uMemory.PageFaultCount & " "
End Function

Public Function OpenProcessHandle() As Long
    
    m_ProcessHandle = OpenProcess(PROCESS_QUERY_INFORMATION Or PROCESS_VM_READ, 0, ProcessID) 'Get a handle to the Process
    OpenProcessHandle = m_ProcessHandle
End Function
        
Public Function CloseProcessHandle() As Long
    If (m_ProcessHandle) Then
        CloseHandle m_ProcessHandle
        m_ProcessHandle = 0
    End If
End Function

Public Function GetMemoryUsage() As String
    Dim v As Variant
'    Debug.Assert 0
    v = Split(getMemoryInfo(), ",")
    GetMemoryUsage = v(0)
End Function

Public Function GetGlobalMemoryUsage() As String
    Dim v As Variant
'    Debug.Assert 0
    v = Split(getMemoryInfo(), ",")
    GetGlobalMemoryUsage = v(2)
End Function

Public Function GetGlobalVirtualMemoryUsage() As String
    Dim v As Variant
'    Debug.Assert 0
    v = Split(getMemoryInfo(), ",")
    GetGlobalVirtualMemoryUsage = v(3)
End Function

Public Function GetVirtualMemoryUsage() As String
    Dim v As Variant
'    Debug.Assert 0
    v = Split(getMemoryInfo(), ",")
    GetVirtualMemoryUsage = v(1)
End Function

Public Function FreeUnusedLibraries() As Boolean
    CoFreeUnusedLibraries
    FreeUnusedLibraries = True
End Function

Public Property Get Name() As String
    Name = m_strName
End Property


Public Property Get ShortName() As String
    If Len(m_strShortName) Then
        ShortName = m_strShortName
    Else
        ShortName = Name
    End If
End Property

Public Property Get GraphForm(ByVal lngMaxYData As Long) As Variant
'    Dim f As frmMTVBSysLibProcessForm
'    Set f = New frmMTVBSysLibProcessForm
'    f.Initialize Me, lngMaxYData
'    Set GraphForm = f
End Property

