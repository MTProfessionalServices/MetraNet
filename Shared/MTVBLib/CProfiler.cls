VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CProfiler"
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
'  CLASS        : CProfiler
'  AUTHOR       : Frederic Torres
'  DATE         : 08/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************

Option Explicit

Private m_lngStartTime              As Long
Private m_lngEndTime                As Long
Private m_objWindowsApi             As cWindows
Private m_Flags                     As ePROFILER_FLAG
Private m_strModuleName             As String
Private m_strFunctionName           As String
Private m_strUserDefinedText        As String
Private m_booExecMode               As Boolean

Public Enum ePROFILER_FLAG
    ePROFILER_FLAG_TRACE = 1
    ePROFILER_FLAG_DEBUG_PRINT = 2
End Enum

Public Function Start(ByVal booExecMode As Boolean, _
                        Optional ByVal strModuleName As String, _
                        Optional ByVal strFunctionName As String, _
                        Optional ByVal strUserDefinedText As String, _
                        Optional ByVal eFlags As ePROFILER_FLAG = ePROFILER_FLAG_DEBUG_PRINT + ePROFILER_FLAG_TRACE _
                        ) As Boolean

    m_booExecMode = booExecMode
    
    'TRACE "CPROFILE.START() " & m_booExecMode, strModuleName, strFunctionName, LOG_WARNING
    
    If (m_booExecMode) Then
        
        Set m_objWindowsApi = New cWindows
    
        m_lngStartTime = m_objWindowsApi.GetTickCount()
        m_strModuleName = strModuleName
        m_strFunctionName = strFunctionName
        m_strUserDefinedText = strUserDefinedText
        m_Flags = eFlags
    End If
    
    Start = True

End Function

Private Sub Class_Terminate()

    Dim strS As String
    
    If (m_booExecMode) Then

        m_lngEndTime = m_objWindowsApi.GetTickCount() - m_lngStartTime
        
        strS = "PROFILER{Time=[TIME]; Module=[MODULE]; function=[FUNCTION]; Text=[TEXT];}"
        
        strS = Replace(strS, "[TIME]", CStr(m_lngEndTime))
        strS = Replace(strS, "[MODULE]", m_strModuleName)
        strS = Replace(strS, "[FUNCTION]", m_strFunctionName)
        strS = Replace(strS, "[TEXT]", m_strUserDefinedText)
        
        If (m_Flags And ePROFILER_FLAG_DEBUG_PRINT) Then
            Debug.Print strS
        End If
        If (m_Flags And ePROFILER_FLAG_TRACE) Then
            TRACE strS, , , eMTGLOBAL_LOG_TRACE_MODE.LOG_DEBUG
        End If
        Set m_objWindowsApi = Nothing
    End If
End Sub



Public Property Get UserDefinedText() As String
    UserDefinedText = m_strUserDefinedText
End Property

Public Property Let UserDefinedText(ByVal vNewValue As String)
    m_strUserDefinedText = vNewValue
End Property
