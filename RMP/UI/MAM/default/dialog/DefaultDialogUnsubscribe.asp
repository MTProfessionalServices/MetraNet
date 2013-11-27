<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultPVBMapping.asp$
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
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%

' Mandatory
Form.RouteTo                      = mam_GetDictionary("SETUP_SUBSCRIPTIONS_DIALOG")

mdm_Main ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Populate()
' PARAMETERS		  : 
' DESCRIPTION 		: Check if the time for the end date was set if not we set 23:59:59.
' RETURNS		      : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Populate(EventArg) ' As Boolean
    
      Inherited("Form_Populate") ' First Let us call the inherited event
      
      mam_CheckEndDate EventArg, "SubscriptionEndDate"
      Form_Populate = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  Service.Properties.Add "SubscriptionID",      "Long",      0,   TRUE,  -1                   
  Service.Properties.Add "Subscription",        "String",    256, TRUE,  ""
  Service.Properties.Add "SubscriptionEndDate", "TIMESTAMP", 0,   TRUE,  Empty  
  Service.Properties.Add "EndNextBillingPeriod","boolean", 0,   FALSE, FALSE
  Service.Properties.Add "IsGroupSub",					"boolean", 0,   FALSE, FALSE	

  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
    
  Service.Properties("SubscriptionID")         = Request.QueryString("SubscriptionID")  
  Service.Properties("Subscription")           = Request.QueryString("Subscription")
  Service.Properties("SubscriptionEndDate")    = Empty
  Service.Properties("EndNextBillingPeriod")   = FALSE
	
  Service.Properties("IsGroupSub") 						 = CBool(Request.QueryString("ISGROUP"))
	mdm_GetDictionary.Add "ShowGroupConfiguration", Service.Properties("IsGroupSub")
	  
  Service.Properties("SubscriptionEndDate").Required  = TRUE
      
  Service.Properties("SubscriptionID").Caption       = mam_GetDictionary("TEXT_SUBSCRIPTION_ID")
  Service.Properties("Subscription").Caption         = mam_GetDictionary("TEXT_SUBSCRIPTION")
  Service.Properties("SubscriptionEndDate").Caption  = mam_GetDictionary("TEXT_SUBSCRIPTION_END_DATE")
  Service.Properties("EndNextBillingPeriod").Caption = mam_GetDictionary("TEXT_SUBSCRIPTION_NEXT_BILLING_PERIOD_END")  
      
  mam_IncludeCalendar
  
  Form("WarningEndDateInThePastSeen") = FALSE
	Form_Initialize                   = TRUE
	
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    On Error Resume Next
    
    Dim acctID
    Dim MTAccountReference
    Dim objMTProductCatalog
    dim bDateModified
     
    ' Unsubscribe Subscription
    Set objMTProductCatalog = GetProductCatalogObject
    acctID = mam_GetSubscriberAccountID()
  
    ' Get account reference
    Set MTAccountReference = objMTProductCatalog.GetAccount(acctID)
    
    '
    ' NO MORE USE FULL
    '
    ' Check Effective Dates
    'Dim strErrorMessage
    'If Not CheckEffectiveDates(DateAdd("d", -1, FrameWork.MetraTimeGMTNow()),Service.Properties("SubscriptionEndDate"), strErrorMessage, TRUE) Then
    '    EventArg.Error.Number= 1
    '    EventArg.Error.Description = strErrorMessage
    '    OK_Click = FALSE
    '    Err.Clear
    '    Exit Function
    'End If

    
   ' -- Check if Start Date is defined and in the past if yes ISSUE a WARNING --
   If Len(Service.Properties("SubscriptionEndDate")) Then
   
       If DateDiff("d", FrameWork.MetraTimeGMTNow(), CDate(Service.Properties("SubscriptionEndDate"))) < 0 Then
       
            If Not Form("WarningEndDateInThePastSeen") Then
    
              EventArg.Error.Number = 1
              EventArg.Error.Description = mam_GetDictionary("MAM_WARNING_8001") 
              OK_Click = FALSE
              Form("WarningEndDateInThePastSeen") = TRUE
              Exit Function
            End If
       End If
   End If    
        
    If Service("EndNextBillingPeriod") Then 
      bDateModified = MTAccountReference.Unsubscribe Service.Properties("SubscriptionID"), CDate(Service.Tools.ConvertToGMT(Service.Properties("SubscriptionEndDate"), MAM().CSR("TimeZoneId"))), PCDATE_TYPE_BILLCYCLE      
    Else
      bDateModified = MTAccountReference.Unsubscribe Service.Properties("SubscriptionID"), CDate(Service.Tools.ConvertToGMT(Service.Properties("SubscriptionEndDate"), MAM().CSR("TimeZoneId"))), PCDATE_TYPE_ABSOLUTE
    End IF
    
    If(CBool(Err.Number = 0)) then
        On Error Goto 0
        'AUDIT
        'mam_Audit mam_GetDictionary("AUDIT_UNSUBSCRIBE") & Service.Properties("Subscription"), 0
        OK_Click = TRUE
    Else        
        EventArg.Error.Save Err  
        OK_Click = FALSE
    End If
    Err.Clear      
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		  : Form_Error
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Error(EventArg) ' As Boolean

    Select Case  EventArg.Error.Number
        Case 738197503
           EventArg.Error.Number= 7004
           EventArg.Error.Description = mam_GetDictionary("MAM_ERROR_7004") 
    End Select

    Form_Error = TRUE
END FUNCTION
%>

