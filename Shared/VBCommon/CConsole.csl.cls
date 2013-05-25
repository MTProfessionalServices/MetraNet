VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CConsole"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private m_lngStdout As Long
Private Const STD_OUTPUT_HANDLE = -11&

Private Declare Function StdOut Lib "kernel32" Alias "GetStdHandle" (Optional ByVal Handletype As Long = STD_OUTPUT_HANDLE) As Long
Private Declare Function WriteFile Lib "kernel32" (ByVal hFile As Long, ByVal lpBuffer As Any, ByVal nNumberOfBytesToWrite As Long, lpNumberOfBytesWritten As Long, Optional ByVal lpOverlapped As Long = 0&) As Long

Private Sub Class_Initialize()
    m_lngStdout = StdOut()
'    MsgBox m_lngStdout
End Sub

Public Function WriteLn(strS As String) As Boolean
    Debug.Print strS
    WriteLn = WriteChars(strS & vbNewLine)
End Function

Public Function WriteChars(strS As String) As Boolean
    Dim lBytesWritten As Long
    
    Call WriteFile(m_lngStdout, (strS), Len(strS), lBytesWritten, 0&)
    WriteChars = True
End Function
