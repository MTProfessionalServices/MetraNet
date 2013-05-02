<%
'//==========================================================================
' // Copyright 1998-2001 by MetraTech Corporation
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
'//==========================================================================

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Page:         ticketToMAM.asp                                             '
' Description:  This is a sample page showing how to create a ticket and    '
'               use an entry point to get into MetraCare                    '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit
On Error Resume Next

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Global Variables                                                         '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
CONST  mAccountID     = ""                                                   '- account to lookup, default is logon account
CONST  mLogon         = ""                                                   '- account to logon as
CONST  mNamespace     = "system_user"                                        '- logon account namespace
CONST  mnamespaceType = "system_user"                                        '- namespace type
CONST  mURL           = "/mam/default/dialog/defaultdialogupdateaccount.asp" '- page to load  
CONST  mLoadFrame     = "TRUE"                                               '- load frame 

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
mstrURL = "/mam/EntryPoint.asp" & "?logon=" & mLogon & "&namespace=" & mNamespace & "&ticket=" & server.URLEncode(mstrTicket) _
        & "&AccountID=" & mAccountID & "&namespaceType=" & mnamespaceType & "&loadFrame=" & mloadFrame & "&URL=" & server.URLEncode(mURL)

'Redirect
Call response.redirect(mstrURL)

%>

