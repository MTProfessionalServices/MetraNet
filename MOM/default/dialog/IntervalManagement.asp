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
'  Created by: Rudi, Kevin
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!--METADATA TYPE="TypeLib" NAME="MetraTech.UsageServer.dll" UUID="{b6ad949f-25d4-4cd5-b765-3f6199ecc51c}" -->

<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/IntervalManagementLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

Form.RouteTo = mom_GetDictionary("INTERVAL_MANAGEMENT_LIST_DIALOG") & "?MDMAction=" & MDM_ACTION_REFRESH

mdm_Main 

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Form_Initialize
' PARAMETERS : EventArg
' DESCRIPTION:
' RETURNS    : Return TRUE / FALSE
FUNCTION Form_Initialize(EventArg) 
  Framework.AssertCourseCapability "Manage EOP Adapters", EventArg
  
  If Len(Request.QueryString("ID")) > 0 Then
    Form("IntervalID") = Request.QueryString("ID")
  End If
  If FrameWork.CheckCoarseCapability("Manage Intervals") Then
    mdm_GetDictionary.Add "CanSeeChangeLink", true
  Else
    mdm_GetDictionary.Add "CanSeeChangeLink", false
  End If  
  Service.Clear 
  Service.Properties.Add "IntervalID", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalType", "string", 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalStartDateTime", MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalEndDateTime", MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  'Service.Properties.Add "TotalIntervalOnlyAdapterCount", "string", 0, TRUE, "0", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "TotalBillingGroupAdapterCount", "string", 0, TRUE, "0", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "SucceededAdapterCount", "string", 0, TRUE, "0", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "FailedAdapterCount", "string", 0, TRUE, "0", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "OpenUnassignedAccountsCount", "string", 0, TRUE, "0", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "HardClosedUnassignedAccountsCount", "string", 0, TRUE, "0", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalBlockedToUsageFromNewAccountsMessage", "string", 0, TRUE, "0", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "Status", "string", 0, TRUE, "0", eMSIX_PROPERTY_FLAG_NONE
 
  'Service.Properties.Add "Percentage", "string", 0, TRUE, "0", eMSIX_PROPERTY_FLAG_NONE
  
  Form_Initialize = Form_Refresh(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Form_Refresh
' PARAMETERS : EventArg
' DESCRIPTION:
' RETURNS    : Return TRUE / FALSE
FUNCTION Form_Refresh(EventArg)

  Dim objUSM, objInterval
  Set objUSM = mom_GetUsageServerClientObject()

  dim partitionId 
  partitionId = Session("MOM_SESSION_CSR_PARTITION_ID")
  if IsEmpty(Session("MOM_SESSION_CSR_PARTITION_ID")) then
    'show no data if the partition id is empty
  elseif (partitionId = 1) then
    Set objInterval = objUSM.GetUsageIntervalWithoutAccountStats(Form("IntervalID"))
  else
    Set objInterval = objUSM.GetUsageIntervalWithoutAccountStatsForPartition(Form("IntervalID"),partitionId)
  end if
  
  Service.Properties("IntervalID").Value = CStr(objInterval.IntervalID)
  Service.Properties("IntervalType").Value = GetBillingGroupCycleType(objInterval.CycleType)
  Service.Properties("IntervalStartDateTime").Value = CDate(objInterval.StartDate)
  Service.Properties("IntervalEndDateTime").Value = CDate(objInterval.EndDate)
  'Service.Properties("TotalIntervalOnlyAdapterCount").Value = objInterval.TotalIntervalOnlyAdapterCount
  Service.Properties("TotalBillingGroupAdapterCount").Value = objInterval.TotalBillingGroupAdapterCount + objInterval.TotalIntervalOnlyAdapterCount
  Service.Properties("SucceededAdapterCount").Value = objInterval.SucceededAdapterCount
  Service.Properties("FailedAdapterCount").Value = objInterval.FailedAdapterCount
  Service.Properties("OpenUnassignedAccountsCount").Value = objInterval.OpenUnassignedAccountsCount
  Service.Properties("HardClosedUnassignedAccountsCount").Value = objInterval.HardClosedUnassignedAccountsCount
  'Service.Properties("Percentage").Value = objInterval.Progress
  Service.Properties("Status").Value = objInterval.Status
  if objInterval.IsBlockedForNewAccounts Then
    mdm_GetDictionary().Add "INTERVAL_IS_BLOCKED_TO_NEW_ACCOUNTS", 1
    Service.Properties("IntervalBlockedToUsageFromNewAccountsMessage").Value = "New Accounts Will Not Be Invoiced For This Interval"
  else
    mdm_GetDictionary().Add "INTERVAL_IS_BLOCKED_TO_NEW_ACCOUNTS", 0
    Service.Properties("IntervalBlockedToUsageFromNewAccountsMessage").Value = "New Accounts Can Be Invoiced For This Interval"
  end if
  
  If objInterval.OpenUnassignedAccountsCount>0 AND objInterval.HasBeenMaterialized AND FrameWork.CheckCoarseCapability("Manage Intervals") AND (IsEmpty(Session("MOM_SESSION_CSR_PARTITION_ID")) OR Session("MOM_SESSION_CSR_PARTITION_ID")=1) Then
    mdm_GetDictionary().Add "INTERVAL_ACCOUNTS_CAN_BE_MANUALLY_ASSIGNED", 1
  Else
    mdm_GetDictionary().Add "INTERVAL_ACCOUNTS_CAN_BE_MANUALLY_ASSIGNED", 0
  End If
 
  if objInterval.Status = UsageIntervalStatus_Open OR objInterval.Status = UsageIntervalStatus_Blocked Then
    Service.Properties("Status").Value = mom_GetDictionary("TEXT_BG_STATUS_OPEN")
  else
    if objInterval.Status = UsageIntervalStatus_HardClosed Then
      Service.Properties("Status").Value = mom_GetDictionary("TEXT_BG_STATUS_HARD_CLOSED")
    else
      Service.Properties("Status").Value = mom_GetDictionary("TEXT_BG_STATUS_UNKOWN")
    end if
  end if
    
  Form_Refresh = TRUE

END FUNCTION

%>



