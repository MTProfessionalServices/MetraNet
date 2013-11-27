<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: GroupMemberRemove.asp$
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
'  Created by: David A. Blair
' 
'  $Date: 5/11/00 12:00:08 PM$
'  $Author: Kevin A. Boucher$
'  $Revision: 1$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/DropAccountsLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
' Mandatory
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Session("BATCH_ERROR_RETURN_PAGE") = Form.RouteTo

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

	Dim objMTProductCatalog, objGroupSubscription

	if len(Request.QueryString("Action")) > 0 then
		Form("Action") = Request.QueryString("Action")
	end if
	
  Form.RouteTo = mam_GetDictionary("GROUP_MEMBER_LIST_DIALOG")
		
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
									
  ' Initialize Drop Grid -  bFolderOptions, bFoldersOnly
  InitDropGrid TRUE, FALSE

  ' Add dialog properties
  Service.Properties.Add "EndDate",          "TIMESTAMP", 0,   TRUE, Empty
	Service.Properties.Add "GroupSubName",     "STRING", 510,   TRUE, Empty
	
	Set objMTProductCatalog = GetProductCatalogObject
	Set objGroupSubscription = objMTProductCatalog.GetGroupSubscriptionByID(Clng(Session("Group_id")))
	Service.Properties("GroupSubName") = objGroupSubscription.Name
			
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
    
  ' Set required fields
     
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
	
	Dim objMTProductCatalog, objGroupSubscription, objNewMember, objMemberCollection
	On Error Resume Next

	' Get the objects
	Set objMTProductCatalog = GetProductCatalogObject
	Set objGroupSubscription = objMTProductCatalog.GetGroupSubscriptionByID(Clng(Session("Group_id")))
	
  Form.Grids("DropGrid").Rowset.MoveFirst    		  
	'Walk over the grid, adding accouts with the selected effective date  

	If Form.Grids("DropGrid").Rowset.recordCount = 0 then
		EventArg.Error.number = 1031
		EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1031")
		OK_Click = FALSE       
		Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
		Response.Redirect mdm_GetCurrentFullURL()             
		Exit Function
		
	ElseIf Form.Grids("DropGrid").Rowset.recordCount = 1 and Not CBool(Form.Grids("DropGrid").Properties("icon").Value) Then
		Set objNewMember = Server.CreateObject("MTProductCatalog.MTGSubMember") ' TODO: need version especific one?
		objNewMember.AccountID = CLng(Form.Grids("DropGrid").Properties("id").value)
		objNewMember.StartDate = #1/1/1970#
   	objNewMember.EndDate = CDate(Service.Properties("EndDate").Value)  	
		call objGroupSubscription.UnsubscribeMember(objNewMember)
		
  Else ' Batch Membership Add
	
		Set objMemberCollection	= GetMemberCollection(GetAccountIDCollection(), #1/1/1970#, Service.Properties("EndDate").Value)
    dim bDateModified
    Set Session("LAST_BATCH_ERRORS") = objGroupSubscription.UnsubscribeMemberBatch(objMemberCollection, nothing)
		Session("DateOverride") = bDateModified
		
		If Err.Number <> 0 Then
			Session("DateOverride") = false
			EventArg.Error.Save Err
			OK_Click = FALSE       
			Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
			Response.Redirect mdm_GetCurrentFullURL()            
			Exit Function
		End If
    
		' Get Batch Errors  
		If Session("LAST_BATCH_ERRORS").RecordCount > 0 Then
			Session("DateOverride") = false
			EventArg.Error.number = 2015
			EventArg.Error.description = mam_GetDictionary("MAM_ERROR_2015")
			OK_Click = FALSE       
			Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
			Response.Redirect mdm_GetCurrentFullURL()             
			Exit Function
		End If
		
  End If
	
  If(CBool(Err.Number = 0)) then
		On Error Goto 0
		OK_Click = TRUE
    Response.Redirect Form.RouteTo 	      
  Else
		Session("DateOverride") = false
    EventArg.Error.Save Err
    OK_Click = FALSE       
    Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
    Response.Redirect mdm_GetCurrentFullURL()   
  End If
	
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  GetMemberCollection
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return a collection of members for a group subscription
FUNCTION GetMemberCollection(objIdCollection, startdate, enddate)
	Dim i, gsubmember, objMTCollection, id_acc
	i = 1
	set objMTCollection = Server.CreateObject("Metratech.MTCollection.1")
	For Each id_acc in objIdCollection
		set gsubmember = Server.CreateObject("MTProductCatalog.MTGSubMember.1")
		gsubmember.AccountID = CLng(id_acc)
		gsubmember.StartDate = startdate
		if len(trim(enddate)) then
			gsubmember.EndDate = enddate
		end if
		objMTCollection.Add gsubmember
	Next

	Set GetMemberCollection = objMTCollection
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

