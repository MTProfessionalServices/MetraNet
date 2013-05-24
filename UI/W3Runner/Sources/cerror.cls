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
Attribute VB_Exposed = False
' ****************************************************************************************************************************************************
'
'  Written (W) by Frederic Torres 2001-2002
'  ARR.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : xx/xx/2001
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Public Enum CERROR_SEVERITY
    CERROR_WARNING = 1
    CERROR_ERROR = 2
    CERROR_FATAL_ERROR = 4
    CERROR_APPLICATION_ERROR = 8
End Enum

Public Enum CERROR_SHOW_MODE
    CERROR_SHOW_MODE_SHOW = 1
    CERROR_SHOW_MODE_ASK_TO_CANCEL = 2
End Enum


Public Number       As Long
Public Description  As String
Public Source       As String
Public LogErrorFileName As String
Public LastDllError As Long

Public Function Save(objError As Variant, Optional strDefaultSource As String) As Boolean
    
    ' I cannot put any error handler so I do not clear the err object
    
    Me.Number = objError.Number
    Me.Description = objError.Description
    Me.Source = objError.Source
    If Len(Me.Source) = 0 Then Me.Source = strDefaultSource
    Save = True
End Function

Public Function ToString()
    ToString = "error=" & CStr(Number) & " description=" & Description & " source=" & Source
End Function

Public Function Clear() As Boolean
    Number = 0
    Description = ""
    Source = ""
    Clear = True
End Function


Public Function SaveEx(lngErrorNumber As Long, strErrorDescription As String, strErrorSource As String, Optional strUserMsg As String, Optional strModuleName As String, Optional strFunctionName As String, Optional lngApplicationError As Long = 0, Optional eSeverity As CERROR_SEVERITY = CERROR_ERROR, Optional eShowMode As CERROR_SHOW_MODE) As Boolean

    Dim strError As String
    
    If ((lngErrorNumber <> 0) Or (strUserMsg <> "")) Then
        
        If (lngErrorNumber <> 0) Then
            
            strError = "Error Number:" & lngErrorNumber & " Description:" & strErrorDescription & " Source:" & strErrorSource
        Else
            strError = "Error Number:" & lngApplicationError & " Description:" & strUserMsg & " Source:" & App.EXEName
        End If
        
        strError = strError & " LastDllError:" & Err.LastDllError
        strError = strError & " Module:" & strModuleName
        strError = strError & " Function:" & strFunctionName
        strError = strError & " UserMsg:" & strUserMsg
        
        If eSeverity = CERROR_WARNING Then
            strError = strErrorDescription
        End If
        
        Err.Clear
        
        If (eSeverity = CERROR_APPLICATION_ERROR) Or (eSeverity = CERROR_ERROR) Then
        
            If (Len(LogErrorFileName)) Then Me.LogError strError
        End If
        
        If eShowMode = CERROR_SHOW_MODE_SHOW Then
        
            MsgBox strError, vbOKOnly + IIf(eSeverity = CERROR_ERROR Or eSeverity = CERROR_APPLICATION_ERROR, vbCritical, vbInformation), App.EXEName
        End If
    End If
    SaveEx = True
End Function

Public Function LogError(strError As String)

    Dim objTextFile As New cTextFile
    LogError = objTextFile.LogFile(Me.LogErrorFileName, strError)
End Function

Private Sub Class_Initialize()

    LogErrorFileName = App.path & "\" & App.EXEName & ".error.log"
End Sub
