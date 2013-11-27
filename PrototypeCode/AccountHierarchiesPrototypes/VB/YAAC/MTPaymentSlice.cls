VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTPaymentSlice"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private mPayer As YAAC
Private mRefDate As Date
Private mSysDate As Date
Private Const E_FAIL As Long = &H80004005
Private Const E_NOTIMPL As Long = &H80004001

Private mCollection As New MTCollection
Private mCTX As MTSessionContext

Private Sub Class_Initialize()
  mSysDate = "1900"
End Sub



Public Sub Initialize(ctx As MTSessionContext, Payer As YAAC, RefDate As Date)
  
  Set mPayer = Payer
  mRefDate = RefDate
  Set mCTX = ctx
  
  LoadData

End Sub

Public Sub InitializeBitemporal(ctx As MTSessionContext, Payer As YAAC, RefDate As Date, SystemDate As Date)
  Call Err.Raise(E_NOTIMPL, "MTPaymentSlice", "Not Implemented")
End Sub


' COM Enumeration methods
'
Public Property Get Item(vntKey As Long) As MTPaymentAssociation
Attribute Item.VB_UserMemId = 0

  Set Item = mCollection.Item(vntKey)
End Property


Public Property Get Count() As Long
  Count = mCollection.Count
End Property


Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
  Set NewEnum = mCollection.[_NewEnum]
End Property


Private Sub LoadData()

  Dim Rs As New MTSQLRowset
  Rs.Init "queries\AccHierarchies"
  Rs.SetQueryTag "__FIND_PAYMENT_SLICE__"
  Rs.AddParam "%%ID_PAYER%%", mPayer.AccountID
  Rs.AddParam "%%REFDATE%%", Format(mRefDate, "YYYY-MM-DD HH:MM:SS")
  Rs.Execute
  
  Dim index As Long
  For index = 0 To Rs.RecordCount - 1
    Dim tempAssoc As New MTPaymentAssociation
    tempAssoc.Initialize mCTX, Rs.Value(0), Rs.Value(1), Rs.Value(2), Rs.Value(3)
    mCollection.Add tempAssoc
    
    Rs.MoveNext
  Next

End Sub
