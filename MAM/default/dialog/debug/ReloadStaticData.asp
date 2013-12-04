<%
Option Explicit
%>
<!-- #INCLUDE FILE="../../../MAMIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../../default/lib/MamLibrary.asp" -->
<HTML>
<HEAD>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <LINK rel="STYLESHEET" type="text/css" href="/mam/default/localized/en-us/styles/styles.css">
</HEAD>
<BODY>

<img src="/mam/default/localized/en-us/images/logo.gif">
<br>

<%

Set Service = Server.CreateObject("MTMSIX.MSIXHandler")

Response.write "<font face='fixedsys' size=1 color=navy>"

Response.write "About to call the GarbageCollector...<br>"
Response.write "About to clear the cache...<br>"
mdm_GarbageCollector

Response.write "About to reload the Dictionary...<br>"

Dim strLanguage
strLanguage = MAM().CSR("Language").Value
If(strLanguage="")Or(IsEmpty(strLanguage))Then

    strLanguage ="us"
End If

mam_LoadDictionary MAM() , strLanguage

Response.write "OK!"
mdm_Terminate

Response.write "<script language='JavaScript'>window.close();</script>"
%>

</BODY>
</HTML>