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
' ****************************************************************************************************************************************************
'
'  Written (W) by Frederic Torres 2001-2002
'  ARR.
'
'  CLASS        :
'  AUTHOR       : Frederic Torres
'  DATE         : 09/xx/2000
'  DESCRIPTION  :
'  VERSION      : none.
'
' ****************************************************************************************************************************************************
Option Explicit

Private mCol                        As Collection

Public CommandString As String

Public Property Get Item(ByVal vntKey As Long) As String
Attribute Item.VB_UserMemId = 0

   On Error GoTo errmgr
   
   
   Dim i As Long
   
   If (IsNumeric(vntKey)) Then
        Item = mCol(vntKey)
   Else
        
   End If
   Exit Property
errmgr:
   Item = Empty
End Property

Public Sub Remove(ByVal vntKey As Variant)
    On Error GoTo errmgr
    mCol.Remove vntKey
    Exit Sub
errmgr:

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

Public Function Add(ByVal s As String) As Variant
    
    On Error GoTo errmgr
    mCol.Add s
    Add = s
    Exit Function
errmgr:
    Add = Empty
End Function


Public Function Init(ByVal strCommand As String) As Boolean
    Dim l       As New CByteSyntaxAnalyser
    Dim tok     As String
    
    CommandString = strCommand
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


Public Function Exist(ByVal vntKey As Variant) As Long

   On Error GoTo errmgr
   
    Dim s As String
    Dim i As Long
    
    If (IsNumeric(vntKey)) Then
    
        s = mCol(vntKey) ' if no error
        Exist = CLng(vntKey)
    Else
    
        For i = 1 To Me.Count
        
            If UCase(Item(i)) = UCase(vntKey) Then
            
                Exist = i
                Exit Function
            End If
        Next
    End If
    Exit Function
errmgr:

End Function


Public Function GetValue(ByVal vntKey As Variant, Optional ByVal vntDefaultValue As Variant) As Variant
    Dim lngIndex As Long
    
    lngIndex = Me.Exist(vntKey)
    
    If (lngIndex) Then
        GetValue = Item(lngIndex + 1)
    Else
       GetValue = vntDefaultValue
    End If
End Function
