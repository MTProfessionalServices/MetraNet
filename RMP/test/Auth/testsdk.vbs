Dim loginctx
Dim ctx
Dim id

Dim SECURITY_POLICY_PROGID
Dim SECURITY_CONTEXT_PROGID
Dim COMPOSITE_TYPE_PROGID
Dim ATOMIC_TYPE_PROGID
Dim COMPOSITE_PROGID
Dim ROLE_PROGID
Dim ACCOUNT_PROGID
Dim secctx


SECURITY_POLICY_PROGID = "MTAuthProto.MTSecurityPolicy"
ACCOUNT_PROGID = "MTAuthProto.MTAuthAccount"
ROLE_PROGID = "MTAuthProto.MTRole"
SECURITY_CONTEXT_PROGID = "Metratech.MTSecurityContext"
COMPOSITE_TYPE_PROGID = "MTAuthProto.MTCompositeCapabilityType"
ATOMIC_TYPE_PROGID = "MTAuthProto.MTAtomicCapabilityType"
COMPOSITE_PROGID = "MTAuthProto.MTCompositeCapability"
PATH_CAP_PROGID = "MTAuthProto.MTPathCapability"
LOGIN_CTX_PROGID = "Metratech.MTLoginContext"
SESSION_CTX_PROGID = "Metratech.MTSessionContext"

Dim objMeter
Dim sessionset
Dim session

set objMeter = CreateObject("MetraTechSDK.Meter")
objMeter.HTTPTimeout = 120
objMeter.HTTPRetries = 9
Call objMeter.AddServer(0, "bima", 80, 0, "", "")
Call objMeter.Startup

Set loginctx = CreateObject(LOGIN_CTX_PROGID)
Set ctx = loginCtx.Login("jcsr", "csr", "csr123")
wscript.echo ctx.SecurityContext.AccountID
Set secctx = ctx.SecurityContext

Dim demand
Set demand = CreateObject("Metratech.MTManageAH")

Set sessionset = objmeter.CreateSessionSet()
Dim base64
base64 = secctx.ToXML()

Set secondCtx = Nothing
Set secondSC = CreateObject(SECURITY_CONTEXT_PROGID)
secondSC.FromXML(base64)


Set session = sessionset.CreateSession("metratech.com/testservice")
sessionset.SessionContext = base64
session.RequestResponse = 1
session.InitProperty "accountname", "demo"
session.InitProperty "units", 10
sessionset.Close()

Set ctx = loginCtx.Login("demo", "mt", "demo123")
base64 = ctx.ToXML()
Set secondCtx = Nothing
Set secondSC = CreateObject(SECURITY_CONTEXT_PROGID)
secondSC.FromXML(base64)
b = secondSC.CoarseCheckAccess(demand)
wscript.echo "Can Do: " & CStr(b)



' sessionset.UserName = "su"
' sessionset.NameSpace = "csr"
' sessionset.Password = "csr123"


Set session = sessionset.CreateSession("metratech.com/testservice")
session.RequestResponse = 1
session.InitProperty "accountname", "demo"
session.InitProperty "units", 10
'sessionset.Close()

' sessionid = session.SessionID

' session.InitProperty "accountname", accountname
