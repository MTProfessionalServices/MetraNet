<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: OwnedUpdate.asp$
' 
'  Copyright 1998,2004 by MetraTech Corporation
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
'  $Date: 11/12/2004 9:40:37 AM$
'  $Author: Alon Becker$
'  $Revision: 17$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
    
' Mandatory
Form.Version = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo = session("CANCEL_ROUTETO")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
	Dim objYAAC, strName
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  ' Add dialog properties
  Service.Properties.Add "Account", "String", 0, TRUE, Empty   
  Service.Properties.Add "Relationship", "String", 0, TRUE, Empty 
  Service.Properties("Relationship").SetPropertyType "ENUM", "metratech.com", "SaleForceRelationship"	
  Service.Properties.Add "Percentage", "DECIMAL", 0, FALSE, Empty 
  Service.Properties.Add "StartDate", "String", 0, TRUE, Empty  
  Service.Properties.Add "EndDate", "String", 0, FALSE, Empty    	
  
	' Set Captions 
  Service.Properties("Account").caption = mam_GetDictionary("TEXT_OWNED_HIERARCHYNAME")  
  Service.Properties("Relationship").caption = mam_GetDictionary("TEXT_OWNED_RELATION_TYPE")
	Service.Properties("Percentage").caption = mam_GetDictionary("TEXT_PERCENT_OWNERSHIP")	
	Service.Properties("StartDate").caption = mam_GetDictionary("TEXT_START_DATE")
	Service.Properties("EndDate").caption = mam_GetDictionary("TEXT_END_DATE")	
	
  If FrameWork.IsInfinity(request.QueryString("OldStartDate")) Then
    Form("OldStartDate") = Empty
  Else
  	Form("OldStartDate") = request.QueryString("OldStartDate")
  End If
  If FrameWork.IsInfinity(request.QueryString("OldEndDate")) Then
    Form("OldEndDate") = Empty
    Service.Properties("EndDate").Value = Empty
  Else
	  Form("OldEndDate") = request.QueryString("OldEndDate")
    Service.Properties("EndDate").Value = mam_FormatDate(CDate(Form("OldEndDate")), mam_GetDictionary("DATE_FORMAT"))
  End If

  Service.Properties("StartDate").Value = mam_FormatDate(CDate(Form("OldStartDate")), mam_GetDictionary("DATE_FORMAT")) 
	 
  
  Form("AccountID") = request.QueryString("ID")
  Service.Properties("Account").Value = mam_GetFieldIDFromAccountID(CLng(Form("AccountID")))

  Service.Properties("Percentage").Value = request.QueryString("Percentage")
  Service.Properties("Relationship").Value = request.QueryString("Relationship")
	
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation

  ' Include Calendar javascript    
  mam_IncludeCalendar

	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

	 On Error Resume Next

   dim mgr
   Set mgr = Session("SubscriberYAAC").GetOwnershipMgr()
   Call mgr.AddOwnership(GetAssociationAsOwned(mgr, CLng(Form("AccountID"))))
      
    If(CBool(Err.Number = 0)) then
        On Error Goto 0
        OK_Click = TRUE
    Else        
        EventArg.Error.Save Err  
        OK_Click = FALSE
    End If
END FUNCTION


%>

