VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CCommandLine"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private mCol                        As Collection

Public Property Get Item(vntKey As Long) As String
Attribute Item.VB_UserMemId = 0
   On Error GoTo ErrMgr
   Item = mCol(vntKey)
   Exit Property
ErrMgr:
   Item = Empty
End Property

Public Sub Remove(vntKey As Variant)
    On Error GoTo ErrMgr
    mCol.Remove vntKey
    Exit Sub
ErrMgr:

End Sub

Public Property Get Count() As Long
   Count = mCol.Count
End Property

Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
   Set NewEnum = mCol.[_NewEnum]
End Property

Private Sub Class_Initialize()
    Set mCol = New Collection
End Sub

Private Sub Class_Terminate()
    Clear
    Set mCol = Nothing
End Sub

Public Sub Clear()
    Do While Count > 0
        Remove 1
    Loop
End Sub

Public Function Add(s As String) As Variant
    
    On Error GoTo ErrMgr
    mCol.Add s
    Add = s
    Exit Function
ErrMgr:
    Add = Empty
End Function


Public Function Init(strCommand As String) As Boolean
    Dim l       As New CByteSyntaxAnalyser
    Dim tok     As String
    
    l.Init strCommand
    
    Do
        l.PushBytesIndex
        
        ' Test if we have a string
        If (l.GetChar("""") = rSUCCEED) Then
            l.PopBytesIndex
            If l.GetString(tok) = rFAILED Then Exit Function
        Else
            If l.GetUpToChar(" ", tok) = rFAILED Then Exit Function
            'l.PopBytesIndex
        End If
        If (Len(tok)) Then
            Me.Add tok
        Else
            Exit Do
        End If
        l.KillSpace
        If (l.EOS() = rSUCCEED) Then Exit Do
    Loop
    Init = True
    
End Function
