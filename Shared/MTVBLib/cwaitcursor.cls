VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CWaitCursor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private m_screen As Object

Private Sub Class_Initialize()
    Clear
End Sub

Private Sub Class_Terminate()
    Clear
    Set m_screen = Nothing
End Sub

Public Function Wait(objScreen As Object) As Boolean

    Set m_screen = objScreen
    m_screen.MousePointer = 11
    DoEvents
End Function

Public Function Clear() As Boolean

    If (Not m_screen Is Nothing) Then
    
        m_screen.MousePointer = 0
        Clear = True
    End If
End Function
