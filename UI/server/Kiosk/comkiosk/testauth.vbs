
On Error Resume Next

dim sTicketNamespace
'sTicketNamespace="metratech.com/external1"	
sTicketNamespace="mt"

dim sMpsNamespace
sMpsNamespace="mt"	

dim sloginID
'sLoginID="gl123"
sLoginID="demo"
'sLoginID="binky"

dim sPassword
sPassword="demo123"

rem -----------------------------------------------------------------
wscript.echo "-- Testing com ticket agent object creation --"
dim objTicketAgent
set objTicketAgent = createObject ("MetraTech.TicketAgent.1")
if err then
wscript.echo ("Failed --> " & err.description)
end if
err.clear

objTicketAgent.Key = "sharedsecret"

dim sTicket
sTicket=objTicketAgent.CreateTicket(sTicketNamespace,sLoginID,60*5)
wscript.echo "Ticket is [" & sTicket & "]"

rem -----------------------------------------------------------------
wscript.echo "-- Testing com credential object creation --"
dim objCredential
set objCredential = createObject ("ComCredentials.ComCredentials.1")
if err then
wscript.echo ("Failed --> " & err.description)
end if
err.clear

'//objCredential.loginID = sLoginID
'//objCredential.pwd = sPassword
objCredential.name_space = sMpsNamespace
objCredential.ticket = sTicket



rem -----------------------------------------------------------------
wscript.echo "-- Testing com vendor kiosk object creation --"
dim objVendorKiosk
set objVendorKiosk = createObject ("ComVendorKiosk.ComVendorKiosk.1")
if err then
wscript.echo ("Failed --> " & err.description)
end if
err.clear

objVendorKiosk.Initialize sMpsNamespace,80
if err then
wscript.echo ("Failed --> " & err.description)
end if
err.clear

wscript.echo "Vendor Kiosk Authentication Method is [" & objVendorKiosk.authmethod & "]"

rem -----------------------------------------------------------------
wscript.echo "-- Testing com vendor kiosk authentication --"
dim objUserConfig
set objUserConfig = objVendorKiosk.getUserConfig(objCredential)
if err then
wscript.echo ("Failed --> " & err.description)
end if
err.clear

wscript.echo "Username [" & objCredential.loginID & "]"
wscript.echo "AccountId [" & objUserConfig.accountID & "]"

wscript.quit


