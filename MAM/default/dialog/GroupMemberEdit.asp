<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: GroupMemberEdit.asp$
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
'  $Date: 7/9/2002 3:55:36 PM$
'  $Author: Alon Becker$
'  $Revision: 14$
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

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
	Dim objMTProductCatalog, objGroupSubscription, objMember, intAccID, objAccount, objSubscription

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
	
	mdm_GetDictionary().Add "WARNING_EBCR", false
	
	' This screen can be called from more than one place. Therefore we try to detect which "mode" we should be in:
	' If someone is trying access this screen from his/her subscriptions page
	Form("IsSelfMode") = CBool(UCase(Request.QueryString("IsSelfMode")) = "TRUE")
	' And if that access is to create a membership on the group subscription
	Form("IsJoinMode") = CBool(Request.QueryString("IsJoinMode"))
	
	' If this is unsubscribe mode - usually just grey-out the start date choice, since unsubscribe means set a subscription end date and click ok
	Form("unsubscribe") = CBool(UCase(Request.QueryString("unsubscribe")) = "TRUE")
	
	Form("SubscriptionID") = CLng(Request.QueryString("id_sub"))
	
	Form("AccID") = CLng(Request.QueryString("id_acc"))	
	If Len(Request.QueryString("id_group")) > 0 Then
		Session("Group_id") = CLng(Request.QueryString("id_group"))
	End If
																		
  ' Add dialog properties              
  Service.Properties.Add "MemberName",	"STRING", 	 256, TRUE, Empty
	Service.Properties.Add "StartDate",   "TIMESTAMP", 0, TRUE, Empty    
  Service.Properties.Add "EndDate",     "TIMESTAMP", 0, FALSE, Empty
	
	' By default, do not show delete subscription button unless we overide it later
	mdm_GetDictionary().Add "EDIT_MODE", false
  
  ' Until we know for sure what we want to do, we will disable the delete button in this dialog
  mdm_GetDictionary().Add "DELETE_MODE", false

	if Form("IsJoinMode") then
		Session("Group_id") = Clng(Request.QueryString("IDS"))
		mdm_GetDictionary().Add "JOIN_OR_EDIT_MEMBERSHIP", mam_GetDictionary("TEXT_GROUP_SUBSCRIPTION_JOIN")
		Service.Properties("MemberName").Value = session("SUBSCRIBERYAAC").AccountName
		Form.RouteTo = mam_GetDictionary("SETUP_SUBSCRIPTIONS_DIALOG")
		mdm_GetDictionary().Add "UNSUB_MODE", false
	Else		
		Service.Properties("StartDate").Value = CDate(Request.QueryString("start_date"))

		Set objMTProductCatalog = GetProductCatalogObject
		Set objGroupSubscription = objMTProductCatalog.GetGroupSubscriptionByID(Session("Group_id"))
		Set objMember = objGroupSubscription.FindMember(Form("AccID"), Service.Properties("StartDate").Value)

		' Set required fields
		if CBool(objGroupSubscription.WarnOnEBCRMemberStartDateChange(objMember)) then 
			mdm_GetDictionary().Add "WARNING_EBCR", true
		else
			mdm_GetDictionary().Add "WARNING_EBCR", false
		end if


		Service.Properties("MemberName").Value = objMember.AccountName
		Service.Properties("EndDate").Value = objMember.EndDate
		If FrameWork.IsInfinity(Service.Properties("EndDate").Value) Then
			Service.Properties("EndDate").Value = Null
		End If

		Set session("GROUPMEMBEREDIT_MEMBER") = objMember
		
		if Form("unsubscribe") then
			mdm_GetDictionary().Add "JOIN_OR_EDIT_MEMBERSHIP", mam_GetDictionary("TEXT_GROUP_SUBSCRIPTION_UNSUBSCRIBE")
			Service.Properties("StartDate").Enabled = false			
			mdm_GetDictionary().Add "UNSUB_MODE", true
		else
			mdm_GetDictionary().Add "JOIN_OR_EDIT_MEMBERSHIP", mam_GetDictionary("TEXT_GROUP_SUBSCRIPTION_EDIT_MEMBERSHIP")
			' Show delete subscription button
			mdm_GetDictionary().Add "EDIT_MODE", true
			mdm_GetDictionary().Add "UNSUB_MODE", false
		end if		
		
		Form.RouteTo = mam_GetDictionary("GROUP_MEMBER_LIST_DIALOG") & "?ID=" & Session("Group_id")
	End if

	mdm_GetDictionary.Add "REMOVE_GROUP_ID", Session("Group_id")
	mdm_GetDictionary.Add "REMOVE_ACC_ID", mam_GetSubscriberAccountID()
	mdm_GetDictionary.Add "REMOVE_SUB_ID", Form("SubscriptionID")

	' This line is important to get JavaScript field validation	
	Service.LoadJavaScriptCode	   
  
	' Include Calendar javascript    
  mam_IncludeCalendar
		
	Form_Initialize                   = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
	Dim objMTProductCatalog, objGroupSubscription, objMemberOrSub, i, objMember

	On Error Resume Next

	' Get the objects
	Set objMTProductCatalog = GetProductCatalogObject
	Set objGroupSubscription = objMTProductCatalog.GetGroupSubscriptionByID(Session("Group_id"))
	
	Form.RouteTo = mam_GetDictionary("SETUP_SUBSCRIPTIONS_DIALOG")
	
	if Form("IsJoinMode") then
		
		set objMember = Server.CreateObject("MTProductCatalog.MTGSubMember.1")
		
		'Configure new membership properties
		objMember.AccountID = Form("AccID")
		objMember.StartDate = CDate(Service.Properties("StartDate").Value)
	  If Len(Service.Properties("EndDate")) > 0 Then
    	objMember.EndDate = CDate(Service.Properties("EndDate").Value)  	
    End IF
		
		' Add member
		Session("DateOverride") =  objGroupSubscription.AddAccount(objMember)
	else
		if not Form("IsSelfMode") then
			Form.RouteTo        = mam_GetDictionary("GROUP_MEMBER_LIST_DIALOG") & "?ID=" & Session("Group_id")
		end if
		
		Set objMemberOrSub = session("GROUPMEMBEREDIT_MEMBER")		
		' In this case, just set new start and end date for membership
		objMemberOrSub.NewDateRange Service.Properties("StartDate").Value,Service.Properties("EndDate").Value
		Session("DateOverride") = objGroupSubscription.ModifyMembership(objMemberOrSub)
	end if
	
	Set session("GROUPMEMBEREDIT_GSUB") = Nothing
	Set session("GROUPMEMBEREDIT_MEMBER") = Nothing

  If (CBool(Err.Number = 0)) then
  	On Error Goto 0
    OK_Click = TRUE
	Else        
		Session("DateOverride") = false
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
	Set session("GROUPMEMBEREDIT_GSUB") = Nothing
	Set session("GROUPMEMBEREDIT_MEMBER") = Nothing
	Cancel_Click = TRUE
	
	if Form("IsJoinMode") or Form("IsSelfMode") then
		Form.RouteTo = mam_GetDictionary("SETUP_SUBSCRIPTIONS_DIALOG")
	else
		Form.RouteTo = mam_GetDictionary("GROUP_MEMBER_LIST_DIALOG") & "?ID=" & Session("Group_id")
	end if
	
END FUNCTION

%>

