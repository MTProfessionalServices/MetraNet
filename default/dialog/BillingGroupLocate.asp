<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: BillingGroupLocate.asp$
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

Form.RouteTo = ""
Form.Modal = True
Form.ErrorHandler = false

mdm_Main 

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) 
Framework.AssertCourseCapability "Manage EOP Adapters", EventArg

  ' If we are passed in an interval id store it in the form and clear any old results
  If Len(Request.QueryString("IntervalID")) > 1 Then
    Form("IntervalID") = CLng(Request.QueryString("IntervalID"))
    FrameWork.Dictionary.Add "BILLING_GROUP_FOUND_HTML", ""
  End If

  Service.Clear 
  Service.Properties.Add "UserName", "string", 0, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "NameSpace", "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "AccountID", "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "SearchType", "string", 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalID", "string", 0, TRUE, Form("IntervalID"), eMSIX_PROPERTY_FLAG_NONE
  
  Service.Properties("SearchType") = "AccountID"
  Service.LoadJavaScriptCode  

  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Search_Click
' PARAMETERS:  EventArg
' DESCRIPTION: Run Search
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg)
  On Error Resume Next
  
  Dim objUSM, billingGroupID
  Set objUSM = mom_GetUsageServerClientObject()
  
  dim sSQL
  dim rowset
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  rowset.Init "queries\statistics"
	  
  If UCase(Service.Properties("SearchType")) = "ACCOUNTID" Then
    billingGroupID = objUSM.FindBillingGroupIDByMember_2(CLng(Service.Properties("AccountID")), Form("IntervalID"))
  Else
    if len(Service.Properties("UserName"))=0 OR len(Service.Properties("NameSpace"))=0 then
      EventArg.Error.Number = -99
      EventArg.Error.Description = mom_GetDictionary("TEXT_Both_the_User_Name_and_Namespace_are_required_when_not_searching_by_account_id")
      OK_Click = FALSE
      On Error Goto 0
      exit function
    end if
    
    billingGroupID = objUSM.FindBillingGroupIDByMember(Service.Properties("UserName"), Service.Properties("NameSpace"), Form("IntervalID"))  
  End If
  
  ' Check for errors
  If(CBool(Err.Number <> 0)) then
    EventArg.Error.Save Err 
    OK_Click = FALSE 
    exit function 
  end if

  If billingGroupID = -1 Then
    EventArg.Error.Number = -99
    EventArg.Error.Description = mom_GetDictionary("TEXT_Payer_not_found_in_billing_group_for_interval_") & Form("IntervalID")
    OK_Click = FALSE
    on error goto 0
    exit function
  End If
  
  Dim bg
  Set bg = objUSM.GetBillingGroup(CLng(billingGroupID))
  
  Dim status
  Select Case bg.Status
    Case BillingGroupStatus_Open
      status = mom_GetDictionary("TEXT_OPEN") 
    Case BillingGroupStatus_SoftClosed
      status = mom_GetDictionary("TEXT_Soft_Closed")
    Case BillingGroupStatus_HardClosed
      status = mom_GetDictionary("TEXT_Hard_Closed")
    Case Else
      status = mom_GetDictionary("TEXT_unknown")
  End Select  
          
  Dim html
  html = html & "<table border='0' cellpadding='3' cellspacing='0' width='100%'>"
  html = html & "<tr>"
  html = html & "<td nowrap Class='TableHeader'>" & mom_GetDictionary("TEXT_BILLING_GROUP") & "</td>"
  html = html & "<td nowrap Class='TableHeader'>" & mom_GetDictionary("TEXT_STATUS") & "</td>"
  html = html & "<td nowrap Class='TableHeader'>" & mom_GetDictionary("TEXT_MEMBERS") & "</td>"
  html = html & "<td nowrap Class='TableHeader'>" & mom_GetDictionary("TEXT_ADAPTERS") & "</td>"
  html = html & "<td nowrap Class='TableHeader'>" & mom_GetDictionary("TEXT_SUCCEEDED") & "</td>"
  html = html & "<td nowrap Class='TableHeader'>" & mom_GetDictionary("TEXT_FAILED") & "</td>"
  html = html & "</tr>"
  html = html & "<tr>"
  html = html & "<td class='TableCell' align='left'><b><a target='fmeMain' onclick='window.close()' href='IntervalManagement.ViewEdit.asp?BillingGroupID=" & billingGroupID & "&ID=" & Form("IntervalID")& "'>" & bg.Name & "</a></b><br>" & bg.Description & "<br><br>" & "<button OnClick='window.opener.location = ""IntervalManagement.ViewEdit.asp?BillingGroupID=" & billingGroupID & "&ID=" & Form("IntervalID")& """;window.close();' name='goto' Class='clsButtonBlueLarge' ID='Button1'>" & mom_GetDictionary("TEXT_Go_to_this_Group") & "</button>" & "</td>"
  html = html & "<td class='TableCell'><img src='" & GetIntervalStateIcon(status) & "' align='absmiddle'>" & status & "</td>"
  html = html & "<td style='text-align:right;' class='TableCell'>" & bg.MemberCount & "</td>"
  html = html & "<td name='AdapterCount(1)' class='TableCell' align='RIGHT'>" & bg.AdapterCount & "</td>"
  html = html & "<td name='AdapterSucceededCount(1)' class='TableCell' align='RIGHT'>" & bg.SucceededAdapterCount & "</td>"
  html = html & "<td name='AdapterFailedCount(1)' class='TableCell' align='RIGHT'>" & bg.FailedAdapterCount & "</td>"
  html = html & "</tr>"
  html = html & "</TABLE>"
	  
  FrameWork.Dictionary.Add "BILLING_GROUP_FOUND_HTML", html
      
  If(CBool(Err.Number <> 0)) Then
    EventArg.Error.Save Err 
    OK_Click = FALSE        
    On Error Goto 0
    Exit Function
  End If

  OK_Click = FALSE      
  On Error Goto 0

END FUNCTION

%>



