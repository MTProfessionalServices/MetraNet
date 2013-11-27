<%

PRIVATE FUNCTION auth_GetApplicationName()

  auth_GetApplicationName = Mid(request.ServerVariables("SCRIPT_NAME"), 1, instr(2, request.ServerVariables("SCRIPT_NAME"), "/") - 1)
END FUNCTION

' // Purpose of this file is to ensure that a user has been
' // authenticated. If not, then re-direct to start-page
if session("FRAMEWORK_SECURITY_IS_AUTHENTICATED_SESSION_NAME") <> true then
  session.abandon

  response.Write "<script language=""JavaScript1.2"">" & vbNewLine
  response.Write "if (document.images) {" & vbNewLine
  response.Write "  top.location.replace('" & auth_GetApplicationName() & "'); " & vbNewLine
  response.Write "} else {" & vbNewLine
  response.Write "  top.location.href = '" & auth_GetApplicationName() & "';" & vbNewLine
  response.Write "} </script>" & vbNewLine
	
  response.end
end if

%>
