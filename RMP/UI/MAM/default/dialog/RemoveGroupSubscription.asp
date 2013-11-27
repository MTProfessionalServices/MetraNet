<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: RemoveSubscription.asp$
' 
'  Copyright 1998,2000 by MetraTech Corporation
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
'  Created by: Kevin A. Boucher
' 
'  $Date: 4/30/2002 6:26:34 PM$
'  $Author: Fabricio Pettena$
'  $Revision: 2$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
    
' Mandatory
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo				= mam_GetDictionary("GROUP_SUBSCRIPTIONS_DIALOG")
mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
	Dim objMTProductCatalog, objGroupSubscription
	
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

	Form("GroupID") = Request.QueryString("id_group")
																		
  ' Add dialog properties              
	Service.Properties.Add "GroupSubscription", "STRING", 510, TRUE, Empty
	Service.Properties.Add "RemoveGroupSubscriptionMessage", "STRING", 1024, TRUE, Empty
  Service.Properties.Add "OKCANCEL", "STRING", 256, TRUE, Empty  
	
	' Figure out subscription
  Set objMTProductCatalog = GetProductCatalogObject

	Set objGroupSubscription = objMTProductCatalog.GetGroupSubscriptionByID(Form("GroupID"))
	Service.Properties("GroupSubscription").Value = objGroupSubscription.Name
	Service.Properties("RemoveGroupSubscriptionMessage").Value = mam_GetDictionary("TEXT_DELETE_GROUP_SUBSCRIPTION_WARNING")
  Service.Properties("OKCANCEL").Value = mam_GetDictionary("TEXT_DELETE_MESSAGE_WARNING_COMPLEMENT")
		
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
	Dim objMTProductCatalog, objGroupSubscription

	On Error Resume Next
	
	' Get the objects
	Set objMTProductCatalog = GetProductCatalogObject
	objMTProductCatalog.DeleteGroupSubscription(Form("GroupID"))

  If (CBool(Err.Number = 0)) then
  	On Error Goto 0
    OK_Click = TRUE
	Else        
  	EventArg.Error.Save Err  
 		OK_Click = FALSE
	End If
  Err.Clear   
	
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Cancel_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean

	Cancel_Click = TRUE	
END FUNCTION

%>

