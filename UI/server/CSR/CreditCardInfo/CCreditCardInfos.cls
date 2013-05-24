VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CreditCardInfos"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private mCol As Collection

Public Property Get Item(vntKey As Variant) As CreditCardInfo
Attribute Item.VB_UserMemId = 0

   On Error GoTo ErrMgr
   If IsNumeric(vntKey) Then
        Set Item = mCol(vntKey)
   Else
        Set Item = mCol(UCase(vntKey))
   End If
   Exit Property
ErrMgr:
   Set Item = Nothing
End Property

Public Sub Remove(vntKey As Variant)

    On Error GoTo ErrMgr
    mCol.Remove vntKey
    Exit Sub
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
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

Public Function Add(objCreditCardInfo As CreditCardInfo, strID As String) As CreditCardInfo

    On Error GoTo ErrMgr
    
    If (objCreditCardInfo Is Nothing) Then
    
        Set objCreditCardInfo = New CreditCardInfo
    End If
    
    mCol.Add objCreditCardInfo, UCase("" & strID)
    objCreditCardInfo.Index = mCol.Count
    objCreditCardInfo.Id = strID
    
    Set Add = objCreditCardInfo
    
    Exit Function
ErrMgr:
    Set Add = Nothing
End Function

Public Function ToString() As String

    Dim objCreditCardInfo   As CreditCardInfo
    Dim strS                As String
    
    On Error GoTo ErrMgr
    
    For Each objCreditCardInfo In Me
    
        strS = strS & objCreditCardInfo.ToString() & vbCrLf
    Next
    ToString = strS
    Exit Function
ErrMgr:
    Debug.Print Err.Description: Debug.Assert False
End Function

