<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../../MCMIncludes.asp" -->
<HTML>
<HEAD>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <LINK rel="STYLESHEET" type="text/css" href="default/localized/en-us/styles/styles.css">
</HEAD>
<BODY>

<img src="/mcm/default/localized/en-us/images/header/logo.gif">
<br>

<%

Set Service = Server.CreateObject("MTMSIX.MSIXHandler")

Response.write "<font face='fixedsys' size=1 color=navy>"
Response.write "Reloading the Dictionary...<br>"

FrameWork.LoadDictionary 

Response.write "OK!<br><br>"
mdm_Terminate

Response.write "<script language='JavaScript'>window.close();</script>"
%>

</BODY>
</HTML>