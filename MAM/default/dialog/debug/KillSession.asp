<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../../MAMIncludeMDM.asp"          -->
<!-- #INCLUDE FILE="../../../auth.asp" --> 
<HTML>
<HEAD>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <LINK rel="STYLESHEET" type="text/css" href="/mam/default/localized/en-us/styles/styles.css">
</HEAD>
<BODY>

<img src="/mam/default/localized/en-us/images/logo.gif">
<br>

<%
Response.write "<font face='fixedsys' size=1 color=navy>"
Response.write "Terminating MAM...<br>"

mdm_Terminate

Response.write "Resetting the session...<br>"

session.abandon

Response.write "Done.<br><br>"
Response.write "<button onclick='getFrameMetraNet().location.href=""" & Application("APP_HTTP_PATH") & """'> - Reload MAM - </button>"
%>

</BODY>
</HTML>