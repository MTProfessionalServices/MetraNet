<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<%
' SECENG: Fix CORE-4827 CLONE - MSOL BSS 18388 Metracare: No clickjacking protection (SecEx, Public-beta, 3)
response.write CjProtectionCode
' // Purpose of this file is to ensure that a user has been
' // authenticated. If not, then re-direct to start-page
if session("FRAMEWORK_SECURITY_IS_AUTHENTICATED_SESSION_NAME") <> TRUE then

  session.abandon

  response.Write "<script language=""JavaScript1.2"">" & vbNewLine
	
	response.Write "if (window.opener != null) {" & vbNewLine
	response.Write "window.opener.location = window.opener.location;" & vbNewLine ' refresh the parent
	response.Write "window.close();" & vbNewLine			' close the window
	response.Write "} else {" & vbNewLine
  
	response.Write "if (document.images) {" & vbNewLine
  response.Write "  top.location.replace(""" & Session("objMAM").Dictionary("GLOBAL_DEFAULT_LOGIN") & "?Message=" & server.URLEncode(Session("objMAM").Dictionary("TEXT_NO_AUTH")) & """); }" & vbNewLine
  response.Write "else {" & vbNewLine
  response.Write "  top.location.href = """ & Session("objMAM").Dictionary("GLOBAL_DEFAULT_LOGIN") & "?Message=" & server.URLEncode(Session("objMAM").Dictionary("TEXT_NO_AUTH")) & """;" & vbNewLine
  response.Write "} }</script>" & vbNewLine
  
  response.end
Else
'SECENG: 
'RUN SAFE INPUT FILTER ONLY FOR AUTHENTICATED SESSIONS
RunSafeInputFilter("Invalid input data. Please check your URL.")
End If

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Timing
if Application("PERF_GENERATE_RESULTS") then
  session("PERF_TIMER_SCRIPT_TIMER").ScriptName = request.ServerVariables("SCRIPT_NAME")
end if

%>
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->


