Attribute VB_Name = "ProcessKing"
Option Explicit

' Declarations
Public Type PROCESS_INFORMATION
        hProcess As Long
        hThread As Long
        dwProcessId As Long
        dwThreadId As Long
End Type

Public Type STARTUPINFO
        cb As Long
        lpReserved As String
        lpDesktop As String
        lpTitle As String
        dwX As Long
        dwY As Long
        dwXSize As Long
        dwYSize As Long
        dwXCountChars As Long
        dwYCountChars As Long
        dwFillAttribute As Long
        dwFlags As Long
        wShowWindow As Integer
        cbReserved2 As Integer
        lpReserved2 As Long
        hStdInput As Long
        hStdOutput As Long
        hStdError As Long
End Type

Public Type SECURITY_ATTRIBUTES
        nLength As Long
        lpSecurityDescriptor As Long
        bInheritHandle As Long
End Type


' constants used
Public Const STILL_ACTIVE = &H103
'Public Const INFINITE = -1&
Public Const INFINITE = &HFFFF      '  Infinite timeout

Public Const SYNCHRONIZE = &H100000
Public Const STANDARD_RIGHTS_REQUIRED = &HF0000
Public Const PROCESS_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED Or SYNCHRONIZE Or &HFFF
Public Const WAIT_FAILED = &HFFFFFFFF
Public Const ERROR_ABNORMAL_EXIT = -1&

' some api functions
Public Declare Function WaitForSingleObject Lib "kernel32" (ByVal hHandle As Long, ByVal dwMilliseconds As Long) As Long
Public Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long
Public Declare Function OpenProcess Lib "kernel32" (ByVal dwDesiredAccess As Long, ByVal bInheritHandle As Long, ByVal dwProcessId As Long) As Long
Public Declare Function GetExitCodeProcess Lib "kernel32" (ByVal hProcess As Long, lpExitCode As Long) As Long
Public Declare Function TerminateProcess Lib "kernel32" (ByVal hProcess As Long, ByVal uExitCode As Long) As Long
Public Declare Function CreateProcess Lib "kernel32" Alias "CreateProcessA" (ByVal lpApplicationName As String, ByVal lpCommandLine As String, lpProcessAttributes As SECURITY_ATTRIBUTES, lpThreadAttributes As SECURITY_ATTRIBUTES, ByVal bInheritHandles As Long, ByVal dwCreationFlags As Long, lpEnvironment As Any, ByVal lpCurrentDriectory As String, lpStartupInfo As STARTUPINFO, lpProcessInformation As PROCESS_INFORMATION) As Long
Public Declare Function CreateProcessFlat Lib "kernel32" Alias "CreateProcessA" (ByVal lpApplicationName As Long, ByVal lpCommandLine As String, ByVal lpProcessAttributes As Long, ByVal lpThreadAttributes As Long, ByVal bInheritHandles As Long, ByVal dwCreationFlags As Long, ByVal lpEnvironment As Long, ByVal lpCurrentDirectory As Long, lpStartupInfo As STARTUPINFO, lpProcessInformation As PROCESS_INFORMATION) As Long
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)




'-------------------------------------------------------------------------
'
'  KillProgram : routine to brutally kill a program.
'                uses TerminateProcess.
'  Returns     : the program's exit code.
'  Errors      : Raises VB error on any api error.
'
'-------------------------------------------------------------------------
Public Function KillProgram(ByVal hProcess As Long, Optional ByVal ExitCode As Long = ERROR_ABNORMAL_EXIT)
    Dim iResult     As Long

    ' kill
    If TerminateProcess(hProcess, ExitCode) <> 0 Then
        ' get exit code
        iResult = GetExitCodeProcess(hProcess, ExitCode)
    End If

    Call CloseHandle(hProcess)

    If iResult = 0 Then
        Err.Raise Err.LastDllError
    End If
    
    ' return the exit code
    KillProgram = ExitCode
End Function



'-------------------------------------------------------------------------
'
'  ShellEx : routine to run a program and wait for it's exit code.
'            uses CreateProcess, WaitForSingleObject, GetExitCodeProcess
'            and CloseHandle.
'  Returns : the program's exit code.
'  Errors  : Raises VB error on any api error.
'
'-------------------------------------------------------------------------
Public Function ShellEx(ByVal CmdLine As String, Optional ByVal WaitDead As Boolean) As Long
    Dim iExit       As Long
    Dim iResult     As Long
    Dim STARTUPINFO As STARTUPINFO
    Dim ProcessInfo As PROCESS_INFORMATION
    
    ' run it
    STARTUPINFO.cb = Len(STARTUPINFO)
    If CreateProcessFlat(0, CmdLine, 0, 0, 0, 0, 0, 0, STARTUPINFO, ProcessInfo) <> 0 Then
    
        ' initialize the exit code to default error value
        iExit = ERROR_ABNORMAL_EXIT

        If WaitDead Then
            ' freeze until process terminates
            iResult = WaitForSingleObject(ProcessInfo.hProcess, INFINITE)
            If iResult = WAIT_FAILED Then
                iResult = 0
            Else
                ' get the exit code
                iResult = GetExitCodeProcess(ProcessInfo.hProcess, iExit)
            End If
        Else
            ' try getting the exit code
            iResult = GetExitCodeProcess(ProcessInfo.hProcess, iExit)
            ' wait...
            Do While (iExit = STILL_ACTIVE) And (iResult <> 0)
                DoEvents
                Call GetExitCodeProcess(ProcessInfo.hProcess, iExit)
            Loop
        End If

        ' close the handle - just in case
        Call CloseHandle(ProcessInfo.hProcess)

    End If
    
    ' error check
    If iResult = 0 Then
        Err.Raise Err.LastDllError
    End If
    
    ' return the exit code
    ShellEx = iExit
End Function
