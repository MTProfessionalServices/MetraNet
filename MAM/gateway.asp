<%
' //==========================================================================
' // Copyright 1998 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //==========================================================================

Option Explicit
On Error Resume Next

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' gateway3_5.asp                                                            '
' Sample page illustrating how to authenticate a user and ticket to an      '
' online bill site based on the user's namespace.                           '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'Constants used on the page
Const CONST_PROTECTED_PROPERTY_LIST_PATH    = "/serveraccess/protectedpropertylist.xml"   'Path relative to [INSTALL_DIR]/config
Const CONST_TIMEOUT_VALUE                   = 1200                                        'Number of seconds the ticket is valid
Const CONST_GATEWAY_PATH                    = "/presserver/gateway.xml"                   'Path relative to [INSTALL_DIR]/config
Const CONST_SITE_MAIN_PAGE                  = "/main.asp"                                 'Path of main page of online bill site (main.asp)
Const CONST_XML_APP_OBJ_NAME                = "GatewayXMLObject"                          'Name of application object with XML data

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' This page expects the following inputs as the result of a form submision: '
'   1) Logon                                                                '
'   2) Password                                                             '
'   3) ProviderID                                                           '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim mobjTicketAgent                     'Ticketing agent
Dim mobjSecureStore                     'Secure store object
Dim mobjRCD                             'Used to get system configuration paths
Dim mobjXML                             'MS XML Dom object
Dim mobjXMLNode                         'XML node
Dim mobjXMLNodeList                     'List of XML Nodes

Dim mstrProtectedPropertyList           'Path to protectedproeprtylist.xml
Dim mstrTicket                          'User's ticket
Dim mstrRefURL                          'URL of the referrer.  Redirect to this page on error
Dim mstrGateway                         'URL of the gateway.xml
Dim mstrSite                            'Site to redirect to
Dim mstrRedirectURL                     'URL to redirect to

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Determine the referring URL                                               '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

mstrRefURL = GetURLArg("refURL")

'If no referring URL is specified, attempt to deduce it
if len(mstrRefURL) = 0 then
  mstrRefURL = request.ServerVariables("HTTP_REFERER")

  'Strip out any URL parameters that may exist from previous login failures
  'Take everything before the ?
  if instr(mstrRefURL, "?") > 0 then
    mstrRefURL = mid(mstrRefURL, 1, instr(mstrRefURL, "?") - 1)
  end if
end if

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Create the RCD object                                                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Set mobjRCD = server.CreateObject("MetraTech.RCD")
  


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Generate a ticket, if necessary                                           '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

mstrTicket = GetURLArg("ticket")

if len(mstrTicket) = 0 then
  Set mobjTicketAgent = server.CreateObject("MetraTech.TicketAgent.1")
  Set mobjSecureStore = server.CreateObject("COMSecureStore.GetProtectedProperty.1")
  
  mstrProtectedPropertyList = mobjRCD.ConfigDir & CONST_PROTECTED_PROPERTY_LIST_PATH
  
  'Get the key for the ticket agent
  Call mobjSecureStore.Initialize("pipeline", mstrProtectedPropertyList, "ticketagent")
  mobjTicketAgent.Key = mobjSecureStore.GetValue

  if err then
    response.redirect mstrRefURL & "?errorCode=8"
  end if
  
  'Create the ticket
  mstrTicket = mobjTicketAgent.CreateTicket(GetURLArg("ProviderID"), GetURLArg("Logon"), 1200)
  
  if err then
    response.redirect mstrRefURL & "?errorCode=9"
  end if
end if


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Based on the provider ID, determine the site to redirect to.             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'Create the XML object or get it from the Application object

if not isObject(Application(CONST_XML_APP_OBJ_NAME)) then
  Set mobjXML = server.CreateObject("MSXML2.FreeThreadedDOMDocument.4.0")

  'Set up the XML object
  mobjXML.async = false
  mobjXML.validateOnParse = false
  mobjXML.resolveExternals = false

  Set Application(CONST_XML_APP_OBJ_NAME) = mobjXML
else
  if not Application(CONST_XML_APP_OBJ_NAME) is nothing then
    Set mobjXML = Application(CONST_XML_APP_OBJ_NAME)
  else
    Set mobjXML = server.CreateObject("MSXML2.DOMDocument.4.0")

    'Set up the XML object
    mobjXML.async = false
    mobjXML.validateOnParse = false
    mobjXML.resolveExternals = false
  
    Set Application(CONST_XML_APP_OBJ_NAME) = mobjXML
  end if
end if

'Get the path to the gateway.xml
mstrGateway = mobjRCD.ConfigDir & CONST_GATEWAY_PATH

'Load the XML
Call mobjXML.Load(mstrGateway)

'Check for an error
if mobjXML.parseError then
  response.redirect mstrRefURL & "?errorCode=10"
else
  'Get a collection of sites
  Set mobjXMLNodeList = mobjXML.selectNodes("/xmlconfig/mtconfigdata/site")
  
  'Find the matching provider_name
  for each mobjXMLNode in mobjXMLNodeList
    if UCase(mobjXMLNode.selectSingleNode("provider_name").text) = UCase(GetURLArg("ProviderID")) then
      mstrSite = mobjXMLNode.selectSingleNode("WebURL").text
      Exit For
    end if
  next
end if

'Check for a valid site name
if len(mstrSite) = 0 then
  if err then
    response.redirect mstrRefURL & "?errorCode=11"
  end if
end if

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Redirect to the site with the ticket for login                           '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Generate the URL, passing along any query params
mstrRedirectURL = mstrSite & CONST_SITE_MAIN_PAGE & "?" & request.serverVariables("QUERY_STRING")

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Add query params generated by this page, but don't overwrite any that 
'  might already be there
mstrRedirectURL = AddURLArg(mstrRedirectURL, "Login", GetURLArg("Logon"))
mstrRedirectURL = AddURLArg(mstrRedirectURL, "Namespace", GetURLArg("ProviderID"))
mstrRedirectURL = AddURLArg(mstrRedirectURL, "Ticket", server.URLEncode(mstrTicket))
mstrRedirectURL = AddURLArg(mstrRedirectURL, "refURL", server.URLEncode(mstrRefURL))

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Do the redirect
Call response.redirect(mstrRedirectURL)
                       
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : GetURLArg(strArg)                                         '
' Description   : Return the value of the URL parameter, first checking the '
'               : form collection, then the querystring collection.         '
' Inputs        : strArg -- Name of the argument to get the value of.       '
' Outputs       : Value of the argument.                                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function GetURLArg(strArg)
  Dim strVal
  
  strVal = request.form(strArg)
  
  if len(strVal) > 0 then
    GetURLArg = strVal
  else
    GetURLArg = request.queryString(strArg)
  end if

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : AddURLArg(strURL, strArg, strValue)                       '
' Description   : Add an argument to the URL string if it not already part  '
'               : of the URL string.                                        '
' Inputs        : strURL    --  URL to add arguments to                     '
'               : strArg    --  Name of argument to add                     '
'               : strValue  --  Value of the added argument                 '
' Outputs       : New URL with added argument                               '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function AddURLArg(strURL, strArg, strValue)
  
  'Check if arguement is already in URL
  if instr(UCase(strURL), UCase(strArg & "=")) > 0 then
    AddURLArg = strURL
    Exit Function
  end if
  
  'Add the argument, checking if it is the first argument or an additional argument
  if instr(strURL, "?") > 0 then
    AddURLArg = strURL & "&" & strArg & "=" & strValue
  else
    AddURLArg = strURL & "?" & strArg & "=" & strValue
  end if

End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
