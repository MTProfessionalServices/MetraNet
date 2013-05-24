Dim loginctx
Dim ctx
Dim id

LOGIN_CTX_PROGID = "Metratech.MTLoginContext"
SESSION_CTX_PROGID = "Metratech.MTSessionContext"

Dim objMeter
Dim sessionset
Dim session

set objMeter = CreateObject("MetraTechSDK.Meter")
objMeter.HTTPTimeout = 120
objMeter.HTTPRetries = 9
Call objMeter.AddServer(0, "localhost", 80, 0, "", "")
Call objMeter.Startup

Set loginctx = CreateObject(LOGIN_CTX_PROGID)
Set ctx = loginCtx.Login("demo", "mt", "demo123")
'Set ctx = loginCtx.Login("su", "system_user", "su123")
wscript.echo ctx.SecurityContext.AccountID
Set secctx = ctx.SecurityContext

Set sessionset = objmeter.CreateSessionSet()
Dim base64
base64 = secctx.ToXML()

Set session = sessionset.CreateSession("metratech.com/login")
session.RequestResponse = 1
session.InitProperty "username", "demo"
session.InitProperty "namespace", "mt"
session.InitProperty "password_", "demo123"
sessionset.Close()

' this should return serialized context for demo user
' it should match the one that's stored in base64 variable

dim returnedctx
returnedctx = session.ResultSession.GetProperty("sessioncontext")

if(base64 = returnedctx) then
	wscript.echo("Returned session context matches the one created locally")
else
	wscript.echo("Returned session context does not match the one created locally")
end if

wscript.echo "Length 1: " & len(base64)
wscript.echo "Length 2: " & len(returnedctx)