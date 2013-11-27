<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<%
' SECENG: Fix CORE-4793 CLONE - MSOL BSS 30015 MetraOffer - Insecure XML Loading which allows for file discloure, DoS and XSS
' In exported XML pages ClickJacking protection code not needed 
if InStr(LCase(request.ServerVariables("SCRIPT_NAME")),"/gotoruleeditor.asp") = 0 then
' SECENG: Fix CORE-4827 CLONE - MSOL BSS 18388 Metracare: No clickjacking protection (SecEx, Public-beta, 3)
  response.write CjProtectionCode
end if

PUBLIC CONST TIME_OUT_MESSAGE = "Your session has timed out.  Please Log In again."

PRIVATE FUNCTION auth_GetApplicationName()

  auth_GetApplicationName = Mid(request.ServerVariables("SCRIPT_NAME"), 1, instr(2, request.ServerVariables("SCRIPT_NAME"), "/") - 1)
  'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
  'Updating HTML Encoding  
  'auth_GetApplicationName = auth_GetApplicationName & "/default.asp?Message=" & server.URLEncode(TIME_OUT_MESSAGE)
   auth_GetApplicationName = auth_GetApplicationName & "/default.asp?Message=" & SafeForUrl(TIME_OUT_MESSAGE)	
END FUNCTION

If(session("isAuthenticated")<>TRUE)then ' Purpose of this file is to ensure that a user has been authenticated. If not, then re-direct to start-page
  response.Write "<script language=""JavaScript1.2"">" & vbNewLine
	
	response.Write "if (window.opener != null) {" & vbNewLine
		  
			response.Write "window.opener.top.location = '" & auth_GetApplicationName() & "';" & vbNewLine ' refresh the parent
			response.Write "window.close();" & vbNewLine			' close the window
			
	response.Write "} else " & vbNewLine
			response.Write "if (document.images) {" & vbNewLine
		  response.Write "  top.location.replace('" & auth_GetApplicationName() & "'); " & vbNewLine
		  response.Write "} else {" & vbNewLine
		  response.Write "  top.location.href = '" & auth_GetApplicationName() & "';" & vbNewLine
		  response.Write "} </script>" & vbNewLine  
  response.end
end if

'SECENG: 
'RUN SAFE INPUT FILTER ONLY FOR AUTHENTICATED SESSIONS
RunSafeInputFilter("Invalid input data. Please check your URL.")
%>
