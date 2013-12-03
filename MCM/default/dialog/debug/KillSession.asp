<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../../MCMIncludes.asp"          -->
<HTML>
<HEAD>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <LINK rel="STYLESHEET" type="text/css" href="default/localized/en-us/styles/styles.css">
</HEAD>
<BODY>

<img src="/mcm/default/localized/en-us/images/header/logo.gif">
<br>

<%
Response.write "<font face='fixedsys' size=1 color=navy>"
Response.write "Terminating MDM...<br>"

mdm_Terminate

Response.write "Resetting the session...<br>"

session.abandon

Response.write "Done.<br><br>"
Response.write "<button onclick='top.location.href=""" & Application("APP_HTTP_PATH") & """'> - Reload MCM - </button>"
%>

</BODY>
</HTML>