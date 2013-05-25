VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CError"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
' ****************************************************************************************************************************************************
'
'  Copyright 1998-2000 by MetraTech Corporation
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
'  CLASS        : CError
'  AUTHOR       : Frederic Torres
'  DATE         : 09/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit


Public Number           As Long
Public Description      As String
Public Source           As String
Public LastDllError     As Long
Public Time             As Date
Public ModuleName       As String
Public FunctionName     As String
Public UserMessage      As String
Public ApplicationInfo  As String
Public LogTraceMode     As eLOG_TRACE_MODE

Public Enum eLOG_TRACE_MODE ' MetraTech Logger Mode
    LOG_TRACE = 6
    LOG_DEBUG = 5
    LOG_INFO = 4
    LOG_WARNING = 3
    LOG_ERROR = 2
    LOG_FATAL = 1
    LOG_OFF = 0
End Enum

Private m_strLogTraceModeStringArray As Variant

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Save
' PARAMETERS    :
'                    lngErrorNumber         - Err.Number or your own error code
'                    strErrorDescription    - Err.Description or your own description
'                    strErrorSource         - Err.Source
'                    strUserMessage         - Another extended message
'                    strModuleName          - The Module/Class/Form file where the error occured
'                    strFunctionName        - The Function/Sub/Property where the error occured
'                    lngLastDllError        - Err.LastDllError
'                    eLogTraceMode          - The MetraTech Logger Mode Value
' DESCRIPTION   : Save the Visual Basic Err object.
' RETURN        : TRUE
Public Function Save(lngErrorNumber As Long, ByVal strErrorDescription As String, ByVal strErrorSource As String, Optional ByVal strUserMessage As String, Optional ByVal strModuleName As String, Optional ByVal strFunctionName As String, Optional ByVal lngLastDllError As Long, Optional eLogTraceMode As eLOG_TRACE_MODE = LOG_ERROR, Optional objApp As Variant) As Boolean

    If (lngErrorNumber) Then
        
        Number = lngErrorNumber
        Description = strErrorDescription
        Source = strErrorSource
        'Description = Description & vbNewLine & strUserMessage
        LastDllError = lngLastDllError
        Time = Now()
        ModuleName = strModuleName
        FunctionName = strFunctionName
        UserMessage = strUserMessage
        LogTraceMode = eLogTraceMode
        
        If (Not IsMissing(objApp)) Then
        
            ApplicationInfo = GetAppInfo(objApp)
        End If
        Save = True
        Err.Clear
    End If
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : ToString()
' PARAMETERS    :
' DESCRIPTION   : Return the error information into a string.
' RETURN        :
Public Function ToString() As String

    Dim strS    As String

    If (Number) Then
    
        strS = strS & "Error: number=" & Me.Number & "; Description=" & Me.Description & "; Source=" & Me.Source & ";" & " LogMode=" & LogTraceModeString()
        
        If (Len(UserMessage)) Then strS = strS & " UserMessage=" & UserMessage & "; "
        
        strS = strS & "Time=" & Me.Time & "; LastDllError=" & Me.LastDllError & "; "
        strS = strS & "Module=" & ModuleName & "; Function=" & Me.FunctionName & "; "
        If (Len(ApplicationInfo)) Then
            strS = strS & ApplicationInfo
        End If
    End If
    ToString = strS
End Function


' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Log
' PARAMETERS    :
' DESCRIPTION   : Log the error in MTLOG.TXT
' RETURN        : TRUE
Public Function Log() As Boolean
    TRACE Me.ToString(), , , Me.LogTraceMode
    Log = True
End Function


' --------------------------------------------------------------------------------------------------------------------------------------------------------------
'   Method:         UserAndComputerStringInfo
'   Description:    Return user and computer info when an error is logged!
'   Author:         FAT
'   Last Modified:  03/23/1999
'
'   NOTES:
Private Function UserAndComputerStringInfo() As String

    Dim s       As String
    Dim clsFile As New cTextFile
    Dim clsWin  As New cWindows
    Dim clsTool As New cTool
    
    s = s & "UserName=" & clsWin.UserName & vbCrLf
    s = s & "OS=" & clsWin.GetVersion32 & vbCrLf
    s = s & "ComputerName=" & clsWin.ComputerName & vbCrLf
    s = s & "WinDir=" & clsWin.GetWinDir & vbCrLf
    s = s & "NetUserName=" & clsWin.NetUserName & vbCrLf
    s = s & "ExeName=" & App.path & "\" & App.EXEName & ".exe" & " Version=" & clsTool.appVersion(App) & vbCrLf
    s = s & "CurrentDir=" & CurDir
    
    UserAndComputerStringInfo = "ComputerInfo{" & s & "}"

End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Clear
' PARAMETERS    :
' DESCRIPTION   : Clear the error
' RETURN        : TRUE
Public Function Clear() As Boolean
    Me.Number = 0
    Me.Description = ""
    Me.Source = ""
    Clear = True
End Function

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Raise
' PARAMETERS    :
' DESCRIPTION   : Raise the error, the description is the ToString() function
' RETURN        : TRUE
Public Sub Raise()
    Err.Raise Number, Source, ToString()
End Sub

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : LogTraceModeString
' PARAMETERS    :
' DESCRIPTION   : Return the Error Logger Mode as string format
' RETURN        : String
Public Property Get LogTraceModeString() As String
    LogTraceModeString = (m_strLogTraceModeStringArray(Me.LogTraceMode))
End Property

' --------------------------------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : Class_Initialize
' PARAMETERS    :
' DESCRIPTION   :
' RETURN        :
Private Sub Class_Initialize()
    m_strLogTraceModeStringArray = Array("OFF", "FATAL", "ERROR", "WARNING", "INFO", "DEBUG", "TRACE")
End Sub

Public Function GetAppInfo(objApp As Variant) As String

    Dim strInfo As String
    Dim objTool As New cTool
    
    strInfo = strInfo & "Bin.File=" & objApp.path & "\" & objApp.EXEName & ";"
    strInfo = strInfo & "Bin.Version=" & objTool.appVersion(objApp)
    strInfo = strInfo & "Bin.Title=" & objApp.title & ";"
    strInfo = strInfo & "Bin.HInstance=" & objApp.hInstance & ";"
    strInfo = strInfo & "Bin.ThreadID=" & objApp.ThreadID & ";"
End Function
