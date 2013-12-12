<%
Option Explicit
%>
<!-- #INCLUDE FILE="default/lib/CFrameWork.Events.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdmIncludes.asp" -->
<!-- #INCLUDE FILE="default/lib/mcmLibrary.asp" -->
<%
FrameWork.Initialize TRUE
FrameWork.Language = "en-us"
FrameWork.LoadDictionary

Session("ValidSession") = "TRUE"

FrameWork.Log "[DEFAULT.ASP]QueryString=" & server.URLEncode(Request.QueryString()) , LOGGER_INFO

'Set the server locale
dim sLCID
sLCID = FrameWork.getDictionary("SESSION_LCID")
if len(rtrim(ltrim(sLCID)))>0 then
  Session.LCID = CLng(sLCID)
end if

'Handle Timeout Message if it exists
If Len(request.QueryString("Message")) > 0 Then

		Response.ReDirect FrameWork.getDictionary("GLOBAL_DEFAULT_LOGIN") & "?Message=" & server.URLEncode(request.QueryString("Message")) 
Else
		Response.ReDirect FrameWork.getDictionary("GLOBAL_DEFAULT_LOGIN") 
End If
%>
