<%
Option Explicit
%>
<!-- #INCLUDE FILE="auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"         -->
<!-- #INCLUDE FILE="default/lib/mamLibrary.asp"          -->
<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <LINK rel="STYLESHEET" type="text/css" href="<% =application("APP_HTTP_PATH") %>/default/localized/en-us/styles/styles.css">
</HEAD>
<BODY Class='clsBackGround'>

<TABLE BORDER="0" WIDTH="100%" BGCOLOR="white" CELLPADDING="0" CELLSPACING="0">
    <TR><TD Class="CaptionBar">
        &nbsp;&nbsp;Reload Static Data</font>
    </TD></TR>
</TABLE>

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

%>

</BODY>
</HTML>