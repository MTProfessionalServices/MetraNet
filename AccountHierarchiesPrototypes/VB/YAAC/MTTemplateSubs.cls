VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTAccountTemplateSubscriptions"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private mCol As Collection

Public Function CreateTemplateSubscription(ProductOffferingID As Long, GroupSubscription As Boolean, _
  Optional StartDate As Date, Optional EndDate As Date) As MTAccountTemplateSubscription
End Function

Public Sub Remove(vntKey As Variant)
    On Error GoTo ErrMgr
    mCol.Remove vntKey
    Exit Sub
ErrMgr:
End Sub

Public Property Get Count() As Long
    On Error GoTo ErrMgr
    Count = mCol.Count
    Exit Property
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
    On Error GoTo ErrMgr
    Set NewEnum = mCol.[_NewEnum]
    Exit Property
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

Private Sub Class_Initialize()
    On Error GoTo ErrMgr
    Set mCol = New Collection
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Private Sub Class_Terminate()
    On Error GoTo ErrMgr
    Clear
    Set mCol = Nothing
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Sub Clear()
    On Error GoTo ErrMgr
    Do While Count > 0
        Remove 1
    Loop
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Sub

Public Function Add() As MTAccountTemplateSubscription

    On Error GoTo ErrMgr
    
    Dim s As String
           
    Dim clsV As MTAccountTemplateSubscription
    Set clsV = New MTAccountTemplateSubscription
    mCol.Add clsV
    Set Add = clsV
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function

Public Function ToString() As String

    Dim clsV As MTAccountTemplateSubscription
    Dim strS As String
    
    For Each clsV In Me
    
        strS = strS & clsV.ToString() & vbNewLine
    Next
    ToString = strS
End Function

Public Property Get Exist(vntKey As Variant) As Boolean

   On Error GoTo ErrMgr
   
   Dim Itm As MTAccountTemplateSubscription
   
   Set Itm = Me.Item(vntKey)
   Exist = Not (Itm Is Nothing)
   Exit Property
ErrMgr:
   Err.Clear
End Property

Public Property Get Item(vntKey As Variant) As MTAccountTemplateSubscription
Attribute Item.VB_UserMemId = 0

   On Error GoTo ErrMgr
   
   Set Item = mCol(vntKey)
   Exit Property
ErrMgr:
    Set Item = Nothing
End Property

Public Property Get GetItemIndexWithProductOfferingID(ByVal lngPOID As Long) As Long

   On Error GoTo ErrMgr
   
   Dim i As Long
   
   For i = 1 To Me.Count
   
        If Item(i).ProductOfferingID = lngPOID Then
        
            GetItemIndexWithProductOfferingID = i
            Exit Property
        End If
   Next
   Exit Property
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Property

