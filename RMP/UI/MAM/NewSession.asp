<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998 - 2002 by MetraTech Corporation
'  All rights reserved.
' 
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' 
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' 
' DIALOG	    :  NewSession.asp 
' DESCRIPTION	:  Gets ticket and new MetraCare url for currently logged on user
' AUTHOR	    :  K. Boucher
' VERSION	    :  V3.5
'
' Note:  Here we do not use MDM or MAM library - for speed  
'        However, we do have MTVBLIB, and objDictionary
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit

CONST  mAccountID     = ""                                                '- account to lookup, default is logon account

dim mLogon
mLogon = Session("CSR_YAAC").LoginName
dim mNamespace
mNamespace = Session("CSR_YAAC").Namespace 

CONST  mnamespaceType = "system_user"                                        '- namespace type
CONST  mURL           = "/mam/default/dialog/welcome.asp"                    '- page to load  
CONST  mLoadFrame     = "TRUE"                                               '- load frame 


' Check for timeout
if session("FRAMEWORK_SECURITY_IS_AUTHENTICATED_SESSION_NAME") <> TRUE then

  session.abandon

  response.Write "<timeout><![CDATA[ " & vbNewLine
	response.Write "if (window.opener != null) {" & vbNewLine
	response.Write "window.opener.location = window.opener.location;" & vbNewLine ' refresh the parent
	response.Write "window.close();" & vbNewLine			' close the window
	response.Write "} else {" & vbNewLine
  
	response.Write "if (document.images) {" & vbNewLine
  response.Write "  getFrameMetraNet().location.replace(""" & Session("objMAM").Dictionary("GLOBAL_DEFAULT_LOGIN") & "?Message=" & server.URLEncode(Session("objMAM").Dictionary("TEXT_NO_AUTH")) & """); }" & vbNewLine
  response.Write "else {" & vbNewLine
  response.Write "  getFrameMetraNet().location.href = """ & Session("objMAM").Dictionary("GLOBAL_DEFAULT_LOGIN") & "?Message=" & server.URLEncode(Session("objMAM").Dictionary("TEXT_NO_AUTH")) & """;" & vbNewLine
  response.Write "} }]]></timeout>" & vbNewLine
  
  response.end
else

  Dim mobjTicketAgent         'Used to create ticket
  Dim mobjSecureStore         'Used to get key for ticket
  Dim mobjRCD                 'Used to get config file for ticketing
  Dim mstrTicket              'The ticket
  Dim mstrURL                 'URL to redirect to
  
  Set mobjTicketAgent = server.CreateObject("MetraTech.TicketAgent.1")
  Set mobjSecureStore = server.CreateObject("COMSecureStore.GetProtectedProperty.1")
  Set mobjRCD         = server.CreateObject("MetraTech.RCD")
  
  'Initialize the secure store
  Call mobjSecureStore.Initialize("pipeline", mobjRCD.ConfigDir & "\serveraccess\protectedpropertylist.xml", "ticketagent")
  
  'Set the key
  mobjTicketAgent.Key = mobjSecureStore.GetValue()
  
  'Create the ticket
  mstrTicket = mobjTicketAgent.CreateTicket(mNamespace, mLogon, 1200)
  
  'Build the URL
  If UCase(request.ServerVariables("HTTPS")) = "OFF" Then
     mstrURL = "http://"
  Else
     mstrURL = "https://"
  End If  
  mstrURL = mstrURL & request.ServerVariables("SERVER_NAME") & Session("objMAM").Dictionary("APP_HTTP_PATH") & "/EntryPoint.asp" & "?logon=" & mLogon & "&namespace=" & mNamespace & "&ticket=" & server.URLEncode(mstrTicket) _
          & "&AccountID=" & mAccountID & "&namespaceType=" & mnamespaceType & "&loadFrame=" & mloadFrame & "&URL=" & server.URLEncode(mURL)
  
  response.ContentType = "text/xml"
  response.write "<URL><![CDATA[ " & mstrURL & "]]></URL>"
  response.end

end if
%>
