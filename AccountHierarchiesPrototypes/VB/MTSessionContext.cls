VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTSessionContext"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private mAccountID As Integer
Private mSc As MTSecurityContext

Public Property Let AccountID(vData As Integer)
  mAccountID = vData
End Property

Public Property Get AccountID() As Integer
  AccountID = mAccountID
End Property

Public Property Set SecurityContext(vData As MTSecurityContext)
  Set mSc = vData
  AccountID = mSc.AccountID
End Property

Public Property Get SecurityContext() As MTSecurityContext
  Set SecurityContext = mSc
End Property



Public Function ToXML() As String
  ToXML = mSc.ToXML()
End Function
