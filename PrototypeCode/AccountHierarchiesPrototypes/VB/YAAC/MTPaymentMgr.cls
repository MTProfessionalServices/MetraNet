VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTPaymentMgr"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private mCTX As MTSessionContext
Private Const E_FAIL As Long = &H80004005
Private Const E_NOTIMPL As Long = &H80004001

Private mBillable As Boolean
Private mPayerYAAC As YAAC
Private mRCD As New MTRcd


Private Sub Class_Initialize()
  mBillable = False
End Sub



'hidden
Sub Initialize(myctx As MTSessionContext, BillableFlag As Boolean, Payer As YAAC)
Attribute Initialize.VB_MemberFlags = "40"
  Set mCTX = myctx
  mBillable = BillableFlag
  Set mPayerYAAC = Payer
End Sub



Public Sub PayForAccount(ByVal Account As Long, ByVal StartDate As Date, Optional ByVal EndDate As Variant)
  ' check auth
  Dim status As Variant
  Dim RealEndDate As Date
  If IsMissing(EndDate) Then
    RealEndDate = CDate("1/1/9999")
  Else
    RealEndDate = CDate(EndDate)
  End If
  
  ' database will check if target account is a payer or not, check status code from stored procedure
  Dim Rs As New MTSQLRowset
  Rs.Init "queries\\AccHierarchies"
  Rs.InitializeForStoredProc "CreatePaymentRecord"
  Rs.AddInputParameterToStoredProc "Payer", MTTYPE_INTEGER, INPUT_PARAM, mPayerYAAC.AccountID
  Rs.AddInputParameterToStoredProc "NPA", MTTYPE_INTEGER, INPUT_PARAM, Account
  Rs.AddInputParameterToStoredProc "startdate", MTTYPE_DATE, INPUT_PARAM, StartDate
  Rs.AddInputParameterToStoredProc "enddate", MTTYPE_DATE, INPUT_PARAM, RealEndDate
  Rs.AddOutputParameterToStoredProc "status", MTTYPE_DECIMAL, OUTPUT_PARAM
  Rs.ExecuteStoredProc
  status = Rs.GetParameterFromStoredProc("status")
  If status <> 1 Then
    ' get the error code and report it back to the user
    Call Err.Raise(status, "MTPaymentMgr", mRCD.ErrorMessage(status))
  End If
  
End Sub

Public Sub ChangePaymentEffectiveDate(ByVal Account As Long, OldStartdate As Date, OldEndDate As Date, _
  StartDate As Date, EndDate As Date)
  
  Dim Rs As New MTSQLRowset
  Rs.Init "queries\AccHierarchies"
  Rs.SetQueryTag "__UPDATE_PAYMENTRECORD__"
  Rs.AddParam "%%STARTDATE%%", Format(StartDate, "YYYY-MM-DD HH:MM:SS")
  Rs.AddParam "%%ENDDATE%%", Format(EndDate, "YYYY-MM-DD HH:MM:SS")
  Rs.AddParam "%%ID_PAYER%%", mPayerYAAC.AccountID
  Rs.AddParam "%%ID_PAYEE%%", Account
  Rs.AddParam "%%ORIGINAL_START_DATE%%", Format(OldStartdate, "YYYY-MM-DD HH:MM:SS")
  Rs.AddParam "%%ORIGINAL_END_DATE%%", Format(OldEndDate, "YYYY-MM-DD HH:MM:SS")
  Rs.Execute

End Sub


Public Sub PayForAccountBatch(ByVal AccountCollection As Object, StartDate As Date, Optional EndDate As Date)
  Call Err.Raise(E_FAIL, "MTAncestorMgr", "Failed to move account in hierarchy")

End Sub


Public Function PaymentSliceNow() As MTPaymentSlice
  Dim slice As New MTPaymentSlice
  slice.Initialize mCTX, mPayerYAAC, Now
  Set PaymentSliceNow = slice

End Function

Public Function PaymentSlice(ByVal RefDate As Date) As MTPaymentSlice
  Dim slice As New MTPaymentSlice
  slice.Initialize mCTX, mPayerYAAC, RefDate
  Set PaymentSlice = slice
End Function

Public Function PaymentSliceAtSystemDate(ByVal RefDate As Date, ByVal SystemDate As Date)
  Dim slice As New MTPaymentSlice
  slice.InitializeBitemporal mCTX, mPayerYAAC, RefDate, SystemDate
  Set PaymentSliceAtSystemDate = slice
End Function



Public Property Get AccountIsBillable() As Boolean
    AccountIsBillable = mBillable
End Property



Public Sub SetAccountAsBillable()

  ' check if account is already billable... if it is do nothing
  If Not mBillable Then
  
    ' check authority to change the billable flag
    Dim Rs As New MTSQLRowset
    Rs.Init "queries\AccHierarchies"
    Rs.SetQueryTag "__SET_ACCOUNT_AS_BILLABLE"
    Rs.AddParam "%%ID_ACC%%", mPayerYAAC.AccountID
    Rs.Execute
    
    mBillable = True
  End If
End Sub


Public Sub SetAccountAsNonBillable()

  ' check if account is already non billable... if it is do nothing
  If mBillable Then
  ' check authority to change the billable flag

  ' check business rule that non billable accounts can not have payers
    Dim Rs As New MTSQLRowset
    Rs.Init "queries\AccHierarchies"
    Rs.SetQueryTag "__SET_ACCOUNT_AS_NON_BILLABLE"
    Rs.AddParam "%%ID_ACC%%", mPayerYAAC.AccountID
    Rs.Execute
    mBillable = False
  End If
End Sub


