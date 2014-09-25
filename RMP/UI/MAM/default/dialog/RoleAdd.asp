<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
' 
'  Copyright 1998,2000,2001 by MetraTech Corporation
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
'  $Date$
'  $Author$
'  $Revision$
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
Form.Version        = MDM_VERSION     ' Set the dialog version
Form.RouteTo        = mam_GetDictionary("MANAGE_ROLES_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
  Dim objDyn
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
                  
	If UCase(Request.QueryString("Update")) = "TRUE" Then
	  Form("Role") = FrameWork.Policy.GetRoleByID(FrameWork.SessionContext, Request.QueryString("ID"))
    Service.Properties.Add "Description", "String", 255, TRUE, Form("Role").Description                   
    Service.Properties.Add "Name",        "String", 255, TRUE, Form("Role").Name       
    Service.Properties.Add "SubscriberAssignable", "BOOLEAN", 0, FALSE, Form("Role").SubscriberAssignable
    Service.Properties.Add "CSRAssignable", "BOOLEAN", 0, FALSE, Form("Role").CSRAssignable
  Else		
    Form("Role") = FrameWork.Policy.CreateRole(FrameWork.SessionContext)
    Service.Properties.Add "Description", "String", 255, TRUE, ""
    Service.Properties.Add "Name",        "String", 255, TRUE, ""       
    Service.Properties.Add "SubscriberAssignable", "BOOLEAN", 0, FALSE, FALSE
    Service.Properties.Add "CSRAssignable", "BOOLEAN", 0, FALSE, FALSE
  End IF
	
    
  ' Localize captions  
  Service.Properties("Description").Caption = mam_GetDictionary("TEXT_ROLE_DESCRIPTION")
  Service.Properties("Name").Caption = mam_GetDictionary("TEXT_ROLE_NAME")
	Service.Properties("SubscriberAssignable").Caption = mam_GetDictionary("TEXT_SUBSCRIBER_ASSIGNABLE")
	Service.Properties("CSRAssignable").Caption = mam_GetDictionary("TEXT_CSR_ASSIGNABLE")	

	' If we are in update mode disable the name field
	If UCase(Request.QueryString("Update")) = "TRUE" Then
   	Service.Properties("Name").Enabled = FALSE
	End If
	
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
		      
	Form_Initialize                   = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
    On Error Resume Next

	  Form("Role").Name = Service.Properties("Name")
	  Form("Role").Description = Service.Properties("Description")
		Form("Role").CSRAssignable = Service.Properties("CSRAssignable")
	  Form("Role").SubscriberAssignable = Service.Properties("SubscriberAssignable")

    Form("Role").Save()
								
    If (Err.Number) Then
        EventArg.Error.Save Err  
        OK_Click = FALSE
        Err.Clear
    Else        
       OK_Click = TRUE
       Response.Redirect Form.RouteTo
    End If
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

