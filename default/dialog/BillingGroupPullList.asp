<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: IntervalManagement.ViewEdit.asp$
' 
'  Copyright 1998-2005 by MetraTech Corporation
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
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!--METADATA TYPE="TypeLib" NAME="MetraTech.UsageServer" UUID="{b6ad949f-25d4-4cd5-b765-3f6199ecc51c}" -->

<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/IntervalManagementLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

Form.RouteTo = mom_GetDictionary("INTERVAL_MANAGEMENT_SELECT_DIALOG") & "?MDMAction=" & MDM_ACTION_REFRESH

mdm_Main 

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
  Framework.AssertCourseCapability "Manage EOP Adapters", EventArg

  Call FrameWork.Dictionary().Add("SERIALIZED_CONTEXT", FrameWork.SessionContext.ToXML)
  
  Form.Modal = TRUE
  
  Form("IntervalID") = Request.QueryString("IntervalID")
  Form("BillingGroupID") = Request.QueryString("BillingGroupID")
  
  ' If we have a Run ID then only allow the All Failed Accounts option
  If Len(Request.QueryString("RunID")) Then
    FrameWork.Dictionary.Add "USE_RUNID", TRUE
    Form("RunID") = Request.QueryString("RunID")
  Else
    FrameWork.Dictionary.Add "USE_RUNID", FALSE
  End If  

  ' Properties
	Service.Clear
  Service.Properties.Add "IntervalID", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BillingGroupID", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BillingGroupName", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE  
  Service.Properties.Add "IntervalType", "string", 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalStartDateTime", MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalEndDateTime", MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "Name", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE                  
  Service.Properties.Add "Description", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE     
  Service.Properties.Add "Accounts", "string", 0, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE             
  'Service.Properties.Add "FileName", "string", 0, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE               
  Service.Properties.Add "RadioType", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE                  
  Service.Properties.Add "SearchOn","String",0,TRUE,Empty,eMSIX_PROPERTY_FLAG_NONE
  
  ' Captions
  Service.Properties("IntervalID").Caption = "Interval ID"
  Service.Properties("BillingGroupID").Caption = "Billing Group ID"
  Service.Properties("BillingGroupName").Caption = "Billing Group"
  Service.Properties("IntervalType").Caption = "Type"
  Service.Properties("IntervalStartDateTime").Caption = "Start"
  Service.Properties("IntervalEndDateTime").Caption = "End"         
	Service.Properties("Name").Caption = "New Group Name"
	Service.Properties("Description").Caption = "Description"
	Service.Properties("Accounts").Caption = "Specify Accounts"
	'Service.Properties("FileName").Caption = "File Name"
	Service.Properties("RadioType").Caption = "Account Radio"
	Service.Properties("SearchOn").Caption = "Search On"

  Call mom_AddQuickSearchFieldsForAccounts("SearchOn") 

  'Perhaps the list of accounts has been passed to us (Unassigned Account Screen)
  if len(Request.QueryString("AccountsInSession"))>0 then
    Service.Properties("Accounts").Value = Session("BillingGroupAccountList")
    Service.Properties("RadioType").Value = "SPECIFY_ACCOUNTS"
  end if
  	         
	Form_Initialize = Form_Refresh(EventArg)
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_Refresh
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION Form_Refresh(EventArg)

  Dim objUSM, objInterval, objBillingGroup
  Set objUSM = mom_GetUsageServerClientObject()
  Set objInterval = objUSM.GetUsageInterval(CLng(Form("IntervalID")))
  Set objBillingGroup = objUSM.GetBillingGroup(CLng(Form("BillingGroupID")))
  
  Service.Properties("IntervalID").Value = CStr(objInterval.IntervalID)
  Service.Properties("BillingGroupID").Value = CStr(objBillingGroup.BillingGroupID)
  Service.Properties("BillingGroupName").Value = objBillingGroup.Name
    
  Dim cycle
  cycle = objInterval.CycleType
  Select Case cycle
    Case CycleType_Monthly
      Service.Properties("IntervalType").Value = "Monthly"
    Case CycleType_Daily
      Service.Properties("IntervalType").Value = "Daily"
    Case CycleType_Weekly
      Service.Properties("IntervalType").Value = "Weekly"
    Case CycleType_BiWeekly
      Service.Properties("IntervalType").Value = "BiWeekly"
    Case CycleType_Quarterly
      Service.Properties("IntervalType").Value = "Quarterly"
    Case CycleType_Annual
      Service.Properties("IntervalType").Value = "Annual"
    Case CycleType_SemiAnnual
      Service.Properties("IntervalType").Value = "Semi-Annually"
    Case CycleType_All
      Service.Properties("IntervalType").Value = "All"
    Case Else
      Service.Properties("IntervalType").Value = "(unknown cycle type)"
  End Select    
   
  Service.Properties("IntervalStartDateTime").Value = CDate(objInterval.StartDate)
  Service.Properties("IntervalEndDateTime").Value = CDate(objInterval.EndDate)
  
  Form_Refresh = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg)
  On Error Resume Next
  
  Dim objUSM, materializationID, needsExtraAccounts
  Set objUSM = mom_GetUsageServerClientObject()
  
  Select Case UCase(Service.Properties("RadioType"))  
    
    Case "ALL_FAILED_ACCOUNTS"
      materializationID = objUSM.StartChildGroupCreationFromFailedRunID(Service.Properties("Name"), Service.Properties("Description"), CLng(Form("RunID")), needsExtraAccounts)
        
    Case "SPECIFY_ACCOUNTS"
      materializationID = objUSM.StartChildGroupCreationFromAccounts(Service.Properties("Name"), Service.Properties("Description"), CLng(Service.Properties("BillingGroupID")), Service.Properties("Accounts"), needsExtraAccounts)
    
    Case "CREATE_GROUP_FROM_FILE"
      'materializationID = objUSM.StartChildGroupCreationFromFile(Service.Properties("Name"), Service.Properties("Description"), CLng(Service.Properties("BillingGroupID")), Service.Properties("FileName"), needsExtraAccounts)
      Session("PULL_LIST_FROM_FILE_BILLINGGROUP_ID") = CLng(Service.Properties("BillingGroupID"))
      Session("PULL_LIST_FROM_FILE_INTERVAL_ID") = Form("IntervalID")
      Session("PULL_LIST_FROM_FILE_NAME") = Service.Properties("Name")
      Session("PULL_LIST_FROM_FILE_DESCRIPTION") = Service.Properties("Description")
      Form.Modal = FALSE
      Form.RouteTo = "BillingGroupPullListFromFile.asp"
	  OK_Click = TRUE
      Exit Function
  
  End Select

  If CBool(needsExtraAccounts) Then 
    ' Go to screen listing extra accounts - this screen will call abort or finish
    Form.Modal = FALSE
    Form.RouteTo = "BillingGroupsExtraAccounts.asp?MaterializationID=" & materializationID 
    Exit Function
  End If
  
  ' Check for errors
  If(CBool(Err.Number = 0)) Then
    Dim billingGroupID
    billingGroupID = objUSM.FinishChildGroupCreation(materializationID)  
    
    If(CBool(Err.Number <> 0)) Then
      EventArg.Error.Save Err 
      OK_Click = FALSE   
      Exit Function
    End If
        
    On Error Goto 0
    'Because we are modal, returning true will just close this window and refresh the opener... need to add javascript for opener to go to new location
    Form.JavaScriptInitialize = "window.opener.location='" & Form.RouteTo & "&ID=" & Service.Properties("IntervalID") & "';window.close();"
    OK_Click = TRUE
  Else
    EventArg.Error.Save Err 
    OK_Click = FALSE       
  End If
      
END FUNCTION

%>



