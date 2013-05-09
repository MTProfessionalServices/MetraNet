VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "MTLoginContext"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit


Public Function Login(ByVal aAlias As String, ByVal aNamespace As String, ByVal aPwd As String) As MTSessionContext
  Dim ctx As New MTSecurityContext
  Dim sessctx As New MTSessionContext
  Dim a As New COMAccount
  Dim credObj
  Dim kiosk
  
  Set credObj = CreateObject(COMCredentials) ' Create a credentials object object to authenticate the user
  Set kiosk = CreateObject(COMKioskAuth)
 
  credObj.LoginID = aAlias
  credObj.pwd = aPwd
  credObj.Name_Space = aNamespace
  '???
  'credObj.Ticket = CStr(strTicket)

  
  kiosk.Initialize
  
  'why doesn't it throw if not authentic?
  kiosk.IsAuthentic (credObj)
  
  a.Initialize
  a.GetAccountInfo aAlias, aNamespace
  ctx.Init (a.AccountID)
  Set sessctx.SecurityContext = ctx
  Set Login = sessctx
End Function

Public Function LoginSystem() As MTSessionContext
  Dim ctx As New MTSecurityContext
  Dim a As New COMAccount
  a.Initialize
  a.GetAccountInfo "system", "system"
  ctx.Init (a.AccountID)
  Set LoginSystem = ctx
End Function

Public Function LoginAnonymous() As MTSessionContext
  Dim ctx As New MTSecurityContext
  Dim a As New COMAccount
  a.Initialize
  a.GetAccountInfo "anonymous", "anonymous"
  ctx.Init (a.AccountID)
  Set LoginAnonymous = ctx
End Function

Public Function LoginWithTicket(aTicket As Object)
  Set LoginWithTicket = New MTSessionContext
End Function

Public Function Logout(aCtx As MTSessionContext)

End Function


