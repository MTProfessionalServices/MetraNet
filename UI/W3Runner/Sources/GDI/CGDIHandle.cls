VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CGDIHandle"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Handle       As Long
Public OldHandle    As Long
Private m_HDC       As Long

Public Function Initialize(ByVal lngHDC As Long, ByVal lngHandle As Long) As Boolean

    Handle = lngHandle
    m_HDC = lngHDC
    OldHandle = SelectObject(m_HDC, Handle)
End Function


Private Sub Class_Terminate()
    If m_HDC Then
        SelectObject m_HDC, OldHandle
        DeleteObject Handle
        m_HDC = 0
    End If
End Sub
