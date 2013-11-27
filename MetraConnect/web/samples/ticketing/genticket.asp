<%
option explicit

dim accountNamespace
dim brandedSite
dim accountId
dim expirationOffset
dim encryptionKey
dim serverName
Dim serverURL
dim myURL

accountNamespace = Request("accountnamespace")
brandedSite      = Request("brandedsite")
accountId        = Request("accountid")
expirationOffset = Request("expiration")
encryptionKey    = Request("encryptionkey")
serverName       = Request("servername")

if accountNamespace="" then
  accountNamespace="mt"
end if

if brandedSite="" then
  if accountNamespace="mt" then
    brandedsite="samplesite"
  else
    brandedsite=accountNamespace
  end if
end if

if accountId="" then
  accountId="demo"
end if

if encryptionKey="" then
  encryptionKey="sharedsecret"
end if

if expirationOffset="" then
  expirationOffset="30"
end if

if Request("generateticket")<>"" then
  dim objTicketAgent
  set objTicketAgent = createObject ("MetraTech.TicketAgent.1")
  objTicketAgent.Key = encryptionKey
  
  dim ticket
  ticket=objTicketAgent.CreateTicket(accountNamespace,accountId,expirationOffset)
end if

If len(serverName & "") <> 0 and len(brandedSite & "") <> 0 then
  serverURL = "http://" & serverName & "/" & brandedSite & "/main.asp"
End if

myURL = "http://" & Request.ServerVariables("SERVER_NAME") & _
        "/MetraConnect/samples/ticketing"

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Untitled</title>
  <style type="text/css">
    body {
      font-family: Arial, Helvetica, sans-serif;
      background-color: #98C2EA;
      background-image: url(images/vanish1.jpg);
      background-position: left bottom;
      background-repeat: no-repeat;
      padding: 5px;
      width: 288px;
    }
    .title {
      font-weight: bold;
      font-size: 12pt;
      color: #012B53;
      padding: 3px 5px;
    }
    .text,.footer {
      font-size: 10pt;
      color: #012B53;
      padding: 8px 5px;
    }
    .footer {
      padding: 40px 5px;
    }
    .heading {
      font-weight: bold;
      font-size: 10pt;
      color: white;
      background-color: #89B3DB;
      border: 1px solid #387DB8;
      padding: 3px 5px;
      margin: 20px 0px 5px 0px;
    }
    .content {
      text-align: center;
      padding: 2px;
    }
    .label {
      font-weight: bold;
      font-size: 10pt;
      color: white;
      width: 120px;
    }
    .note {
      font-size: 10pt;
      color: white;
    }
    form {
      padding: 0px;
      margin: 0px;
    }
  </style>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"></head>
<body>

<div class="title">MetraConnect Ticketing Sample</div>
<div class="text">
MetraConnect gives you the ability to embed the MetraView online bill
into your company's web site.
</div>
<form action = "genticket.asp"
      name   = "TicketForm">
  <input type  = "hidden"
         name  = "generateticket"s
         value = "Y"
         />
  <div class="heading">1. Enter account information, encryption key, and server name</div>
  <div class="content">
  <table>
    <tr>
      <td class="label">Account Namespace</td>
      <td><input name  = "accountnamespace"
                 value = "<%=accountNamespace%>"
                 /></td>
    </tr>
    <tr>
      <td class="label">Branded Site</td>
      <td><input name  = brandedsite
                 value = "<%=brandedSite%>"
                 /></td>
    </tr>
    <tr>
      <td class="label">Account ID</td>
      <td><input name  = "accountid"
                 value = "<%=accountId%>"
                 /></td>
    </tr>
    <tr>
      <td class="label">Encryption Key</td>
      <td><input name  = "encryptionkey"
                 value = "<%=encryptionKey%>"
                 /></td>
    </tr>
    <tr>
      <td class="label">MetraView Server</td>
      <td><input name  = servername
                 value = "<%=serverName%>"
                 /></td>
    </tr>
    <tr>
      <td class="label">Expiration</td>
      <td><input name  = "expiration"
                 value = "<%=expirationOffset%>"
                 size  = "3" maxlength="5"
                 />
        &nbsp;<span class="note">(secs from now)</span></td>
    </tr>
  </table>
  </div>
  <div class="heading">2. Generate ticket</div>
  <div class="content">
  <input type  = "submit"
         name  = "Generate"
         value = "Generate"
         />
  </div>
</form>

<form action = "<%=serverURL%>"
      target = "hostingframe"
      name   = "LoginForm">
  <div class="content">
  <input name  = "ticket"
         value = "<%=ticket%>"
         size  = "41"
         />
  <input type  = "hidden"
         name  = "providerID"
         value = "<%=accountNamespace%>"
         />
  <input type  = "hidden"
         name  = "refUrl"
         value = "<%=myURL%>/hostingframe.asp"
         />
  <input type  = "hidden"
         name  = "HideBanner"
         value = "true"
         />
  </div>
  <div class="heading">3. Log in</div>
  <div class="content">
  <input name  = "Login"
         type  = "submit"
         value = "Log In"
         />
  </div>
</form>
<div class="footer">
Please refer to the Technical Note on
<a href="../../doc/MetraViewTicketing.pdf"
   target="_blank"
   >MetraView Ticket Authentication</a>
for more information.
</div>

</body>
</html>
