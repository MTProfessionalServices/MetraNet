Attribute VB_Name = "FredModule"
Option Explicit

Public Const CUST_MSG_0001 = "Before installing Test Harness you must uninstall the previous version."


Public m_strFlogViewerExeFileName  As String

Public Function RunAppInstallMode() As Boolean

    On Error Resume Next
    
    
    If (Len(m_strFlogViewerExeFileName)) Then
        
        Shell m_strFlogViewerExeFileName & " /I"
    End If
End Function
