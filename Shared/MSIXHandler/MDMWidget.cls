VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MDMWidget"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public TRACE_ID             As Long
Public Name             As String
Public HeaderFileName   As String
Public FooterFileName   As String
Public Version          As String
Public Enabled          As Boolean

Public Function GetHeader() As String

    On Error GoTo ErrMgr
    
    Dim objTextFile As New cTextFile
    If (Len(HeaderFileName)) Then
        GetHeader = objTextFile.LoadFile(HeaderFileName)
    End If
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMWidget.cls", "GetHeader", LOG_ERROR
End Function

Public Function GetFooter() As String

    On Error GoTo ErrMgr
    
    Dim objTextFile As New cTextFile
    If (Len(FooterFileName)) Then
        GetFooter = objTextFile.LoadFile(FooterFileName)
    End If
    Exit Function
ErrMgr:
    TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), "MDMWidget.cls", "GetHeader", LOG_ERROR
End Function

Private Sub Class_Initialize()
    Version = MDM_VERSION_20
    Enabled = True
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
End Sub

Public Function ToString() As String
    ToString = "Name=" & Name & ";" & vbNewLine
End Function

Private Sub Class_Terminate()
    TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
End Sub
