<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: FailedTransactionChangeStatus.asp$
' 
'  Copyright 1998-2003 by MetraTech Corporation
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
'  Created by: Rudi
' 
'  $Date: 9/20/2002 4:08:33 PM$
'  $Author: Rudi Perkins$
'  $Revision: 3$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/FailedTransactionLibrary.asp"-->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%
Server.ScriptTimeout = 60 * 15 
Form.RouteTo = mom_GetDictionary("FAILED_TRANSACTION_BROWSER_DIALOG") & "?MDMAction=" & MDM_ACTION_REFRESH

mdm_Main 

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  Form_Initialize
' PARAMETERS :  EventArg
' DESCRIPTION:
' RETURNS    :  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

  Framework.AssertCourseCapability "Update Failed Transactions", EventArg
  Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
                  
  Service.Properties.Add "NewStatus", "string", 1, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "Comment", "string", 255, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "InvestigationReasonCode", "string", 255, FALSE, "", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "DismissedReasonCode", "string", 255, FALSE, "", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ResubmitNow", "boolean", 0, FALSE, false, eMSIX_PROPERTY_FLAG_NONE
  
  Service.Properties("NewStatus").Caption = mom_GetDictionary("TEXT_FAILED_TRANSACTIONS_NEW_STATUS")
  Service.Properties("InvestigationReasonCode").SetPropertyType "ENUM", "metratech.com/failedtransaction", "InvestigationReasonCode"	
  Service.Properties("DismissedReasonCode").SetPropertyType "ENUM", "metratech.com/failedtransaction", "DismissedReasonCode"	

  Service.LoadJavaScriptCode  
  
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  OK_Click
' PARAMETERS :  EventArg
' DESCRIPTION:  Update failed transaction status and do resubmit if needed
' RETURNS    :  TRUE / FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
  On Error Resume Next
  OK_Click = FALSE
    
  Dim strNewStatus, strReasonCode

  strNewStatus = Service.Properties("NewStatus").Value
   
  Select Case UCase(strNewStatus)
    Case "P" 
      strReasonCode = Service.Properties("DismissedReasonCode").Value
    Case "I"
      strReasonCode = Service.Properties("InvestigationReasonCode").Value
  End Select
        
  Dim FailureCompoundIDs
  Set FailureCompoundIDs = session("FailedTransactionChangeStatusCollection")
  If Not BulkUpdateFailedTransactionStatus(FailureCompoundIDs, strNewStatus, strReasonCode, Service.Properties("Comment").Value) Then Exit Function
  
  If Service.Properties("ResubmitNow") Then
    If Not BulkResubmitFailedTransactions(FailureCompoundIDS) Then Exit Function
  End If
          
  If(CBool(Err.Number = 0)) then
    On Error Goto 0
    OK_Click = TRUE
  Else        
    EventArg.Error.Save Err  
    OK_Click = FALSE
  End If
  
END FUNCTION

%>


