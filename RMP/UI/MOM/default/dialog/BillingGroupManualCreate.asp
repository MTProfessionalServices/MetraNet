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

Form.RouteTo = mom_GetDictionary("INTERVAL_MANAGEMENT_LIST_DIALOG") & "?MDMAction=" & MDM_ACTION_REFRESH

mdm_Main 

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form.Modal = TRUE
  
  Call FrameWork.Dictionary().Add("SERIALIZED_CONTEXT", FrameWork.SessionContext.ToXML)
    
  Form("IntervalID") = Request.QueryString("IntervalID")

  ' Properties
	Service.Clear
  Service.Properties.Add "IntervalID", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalType", "string", 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalStartDateTime", MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalEndDateTime", MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "Name", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE                  
  Service.Properties.Add "Description", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE     
  Service.Properties.Add "Accounts", "string", 0, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE             
  Service.Properties.Add "RadioType", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE                  
  Service.Properties.Add "SearchOn","String",0,TRUE,Empty,eMSIX_PROPERTY_FLAG_NONE
       
  ' Captions
  Service.Properties("IntervalID").Caption = "Interval ID"
  Service.Properties("IntervalType").Caption = "Type"
  Service.Properties("IntervalStartDateTime").Caption = "Start"
  Service.Properties("IntervalEndDateTime").Caption = "End"         
  Service.Properties("Name").Caption = "New Group Name"
  Service.Properties("Description").Caption = "Description"
  Service.Properties("Accounts").Caption = "Specify Accounts"
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
 
  Dim objUSM, objInterval
  Set objUSM = mom_GetUsageServerClientObject()
  Set objInterval = objUSM.GetUsageInterval(CLng(Form("IntervalID")))

  Service.Properties("IntervalID").Value = CStr(objInterval.IntervalID)

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
    Case CycleType_SemiAnnual
      Service.Properties("IntervalType").Value = "Semi-Annual"
    Case CycleType_Annual
      Service.Properties("IntervalType").Value = "Annual"
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
  
  Dim objUSM, materializationID
  Set objUSM = mom_GetUsageServerClientObject()
    
  Select Case UCase(Service.Properties("RadioType"))  
    
    Case "ALL_UNASSIGNED_ACCOUNTS"
      materializationID = objUSM.CreateUserDefinedBillingGroupFromAllUnassignedAccounts(CLng(Service.Properties("IntervalID")), Service.Properties("Name"), Service.Properties("Description"))
        
    Case "SPECIFY_ACCOUNTS"
      materializationID = objUSM.CreateUserDefinedBillingGroupFromAccounts(CLng(Service.Properties("IntervalID")), Service.Properties("Name"), Service.Properties("Description"), Service.Properties("Accounts"))
    
    Case "CREATE_GROUP_FROM_FILE"
      'materializationID = objUSM.CreateUserDefinedBillingGroupFromFile(CLng(Service.Properties("IntervalID")), Service.Properties("Name"), Service.Properties("Description"), Service.Properties("FileName"))
      
      Session("PULL_LIST_FROM_FILE_BILLINGGROUP_ID") = "" 'CLng(Service.Properties("BillingGroupID"))
      Session("PULL_LIST_FROM_FILE_INTERVAL_ID") = Form("IntervalID")
      Session("PULL_LIST_FROM_FILE_NAME") = Service.Properties("Name")
      Session("PULL_LIST_FROM_FILE_DESCRIPTION") = Service.Properties("Description")
      Form.Modal = FALSE
      Form.RouteTo = "BillingGroupPullListFromFile.asp"
	  OK_Click = TRUE
      Exit Function
        
  End Select
  
  ' Check for errors
  If(CBool(Err.Number = 0)) Then
    On Error Goto 0  
    OK_Click = TRUE
  Else
    EventArg.Error.Save Err 
    OK_Click = FALSE       
  End If
      
END FUNCTION


%>



