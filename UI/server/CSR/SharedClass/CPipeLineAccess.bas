Attribute VB_Name = "PipeLineAccessModule"
'**************************************************************************
'
'  Copyright 1998 by MetraTech Corporation
'  All rights reserved.
'
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  MODULE       : PipeLineAccess.bas
'  AUTHOR       : Frederic Torres
'  DATE         : 03/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'  DEPENDENCY   :
'
'**************************************************************************
Option Explicit

Private m_LogFile As String
'Private m_objMTLogger As Object

Public Enum eLOG_MODE

    LOG_DEBUG = 5
    LOG_ERROR = 2
    LOG_FATAL = 1
    LOG_INFO = 4
    LOG_OFF = 0
    LOG_TRACE = 6
    LOG_WARNING = 3
End Enum

Public Function SQLRun(ByVal strSQL As String) As MTSQLRowset
    Dim objRowSet As New MTSQLRowset
    objRowSet.Init "Queries\database"
    objRowSet.SetQueryString strSQL
    objRowSet.Execute
    Set SQLRun = objRowSet
End Function

Public Function LogError(Optional strFileName As String, Optional strFunctionName As String, Optional strUserErrorMsg As String) As Boolean

    ' First things first - let us save the error
    Dim ErrNumber       As Long: ErrNumber = Err.Number
    Dim ErrDescription  As String: ErrDescription = Err.Description
    Dim ErrSource       As String: ErrSource = Err.Source
    Dim ErrLastDllError As Long: ErrLastDllError = Err.LastDllError
    Dim strE            As String
        
    On Error GoTo ErrMgr
    
    If (ErrNumber) Then ' Log a vb error
   
        strE = "[ERROR]"
        strE = strE & "RunTimeError=" & ErrNumber & " " & ErrDescription & "; source=" & ErrSource & "; DllError=" & ErrLastDllError & "; "
        If (Len(strUserErrorMsg)) Then strE = strE & " Message=" & strUserErrorMsg & "; "
        GoSub BuildFileAndFunctionInfo
        LogError = True
    Else
        If (Len(strUserErrorMsg)) Then ' Log a application error
        
            strE = "[ERROR]"
            strE = strE & strUserErrorMsg
            GoSub BuildFileAndFunctionInfo
            LogError = True
        End If
    End If
    Logger strE
    Exit Function
    
    
BuildFileAndFunctionInfo:
    If (Len(strFileName)) Then strE = strE & "file=" & strFileName & "; "
    If (Len(strFunctionName)) Then strE = strE & "function=" & strFunctionName & "; "
Return

ErrMgr:
    ' my god what do we do...
End Function

Public Function GetErrorInfoEx(Optional strFileName As String, Optional strFunctionName As String, Optional strUserErrorMsg As String) As String
    Dim strE As String
    strE = " "
    If (Len(strUserErrorMsg)) Then strE = strE & "Message=" & strUserErrorMsg & "; "
    If (Len(strFileName)) Then strE = strE & "file=" & strFileName & "; "
    If (Len(strFunctionName)) Then strE = strE & "function=" & strFunctionName & "; "
    GetErrorInfoEx = strE
End Function


Public Function Logger(ByVal strE As String, Optional ByVal eLogMode As eLOG_MODE = LOG_DEBUG) As Boolean
    
  Dim m_objMTLogger As Object

        Set m_objMTLogger = CreateObject("MTLogger.MTLogger.1")
        ' DUMMY_NAME mean that since DUMMY_NAME.XML does not exist we log into the default
        ' log file MTLOG.TXT
        m_objMTLogger.Init "DUMMY_NAME", "[MPS(" & App.EXEName & ".Dll)]"

    strE = Replace(strE, vbCrLf, "")
    m_objMTLogger.LogThis eLogMode, Format(Now(), "mm/dd/yy hh:mm:ss") & " " & strE
    Logger = True
    Exit Function
ErrMgr:
End Function

Public Function TRACE(ByVal strM As String, Optional strFileName As String, Optional strFunction As String) As Boolean
    
    If (Len(strFileName)) Then strM = strM & " file=" & strFileName & "; "
    If (Len(strFunction)) Then strM = strM & "function=" & strFunction & "; "
    Logger strM
    Debug.Print strM
    TRACE = True
End Function

Public Property Get LogFile() As String
    If (m_LogFile = "") Then m_LogFile = "c:\temp\mtlog.txt"
    LogFile = m_LogFile
End Property

Public Property Let LogFile(ByVal vNewValue As String)
    m_LogFile = vNewValue
End Property
