VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTPaymentAssociation"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private mPayer As Long
Private mPayee As Long
Private mStartDate As Date
Private mEndDate As Date
Private mCTX As MTSessionContext

' duplicate
Private Const E_NOTIMPL As Long = &H80004001



' hidden
Public Sub Initialize(ctx As MTSessionContext, Payer As Long, payee As Long, _
    StartDate As Date, EndDate As Date)
Attribute Initialize.VB_MemberFlags = "40"
    
    mPayer = Payer
    mPayee = payee
    mStartDate = StartDate
    mEndDate = EndDate
    Set mCTX = ctx
End Sub


Public Property Get Payer() As Long
    Payer = mPayer
End Property

Public Property Get PayerYAAC() As YAAC
    Dim retYAAC As New YAAC
    retYAAC.InitAsSecuredResource mPayer, mCTX
End Property

Public Property Get payee() As Long
    payee = mPayee
End Property

Public Property Get PayeeYAAC() As YAAC
    Dim retYAAC As New YAAC
    retYAAC.InitAsSecuredResource mPayee, mCTX
End Property

Public Property Get StartDate() As Date
    StartDate = mStartDate
End Property

Public Property Get EndDate() As Date
    EndDate = mEndDate
End Property


