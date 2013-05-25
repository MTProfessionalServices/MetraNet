VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MDMTabItem"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public TRACE_ID As Long
Public Key          As Variant
Public Tag          As Variant
Public Index        As Long
Public ToolTipText  As String
Public Parent       As MDMTabs
Public Enabled          As Boolean
Public Visible          As Boolean

Private m_strCaption    As Variant
Private m_booSelected   As Boolean

Public Property Get Caption() As String
    If (IsEmpty(m_strCaption)) Then
        Caption = Key
    Else
        Caption = m_strCaption
    End If
End Property

Public Property Let Caption(ByVal vNewValue As String)
    m_strCaption = vNewValue
End Property

Public Property Get Selected(Optional booUnSelectAll As Boolean = True) As Boolean
    Selected = m_booSelected
End Property

Public Property Let Selected(Optional booUnSelectAll As Boolean = True, ByVal vNewValue As Boolean)
    If (booUnSelectAll) Then Parent.ClearSelection
    m_booSelected = vNewValue
End Property

Public Function ToString() As String

End Function

Private Sub Class_Initialize()
    On Error GoTo ErrMgr

    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_CONSTRUCTOR_MODE
    #End If
    Enabled = True
    Visible = True
    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), TypeName(Me) & ".cls", "Class_Initialize", LOG_ERROR
End Sub
    


Friend Function Delete() As Boolean
    Set Parent = Nothing
    Delete = True
End Function

Private Sub Class_Terminate()

    On Error GoTo ErrMgr
    
    Delete
    #If LOG_OBJECT_INFO Then
        TRACE_CONSTRUCTOR_DESTRUCTOR Me, TRACE_DESTRUCTOR_MODE
    #End If
    Exit Sub
ErrMgr:
  TRACE MTMSIX_ERROR_01033 & GetVBErrorString(), TypeName(Me) & ".cls", "Class_Terminate", LOG_ERROR
End Sub
