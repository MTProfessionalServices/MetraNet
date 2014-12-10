<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultDialogUsageStatisticsFilter.asp$
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
'  $Date: 10/17/2002 3:44:06 PM$
'  $Author: Rudi Perkins$
'  $Revision: 4$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%


' Mandatory
Form.RouteTo                      = mom_GetDictionary("USAGE_STATISTICS_QUERY_DIALOG")

mdm_Main ' invoke the mdm framework



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
  Framework.AssertCourseCapability "Manage Usage Processing", EventArg

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  Service.Properties.Add "TimestampStartDate", "TIMESTAMP",        0, TRUE,  Empty    
  Service.Properties.Add "TimestampEndDate",   "TIMESTAMP",        0, TRUE, Empty  
      
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation

  Service.Properties("TimestampStartDate") = session("UsageStatisticsFilter_TimestampStartDate") 
  Service.Properties("TimestampEndDate") = session("UsageStatisticsFilter_TimestampEndDate")
  Service.Properties("TimestampStartDate").Caption = "Start Date/Time"
  Service.Properties("TimestampEndDate").Caption = "End Date/Time"
  
  mdm_IncludeCalendar
        
	Form_Initialize = TRUE
  
  'Form("WarningStartDateInThePastSeen") = FALSE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    'On Error Resume Next
    
    Dim acctID
    Dim MTAccountReference
    Dim objMTProductCatalog
    Dim effDate ' As New MTTimeSpan 
  
    'session("UsageStatisticsFilter_BatchId") = Service.Properties("BatchId")
    'session("UsageStatisticsFilter_MeteredStartDate") = Service.Properties("MeteredStartDate")
    'session("UsageStatisticsFilter_MeteredEndDate") = Service.Properties("MeteredEndDate")
    session("UsageStatisticsFilter_TimestampStartDate") = Service.Properties("TimestampStartDate")
    session("UsageStatisticsFilter_TimestampEndDate") = Service.Properties("TimestampEndDate")
    
    'Set objMTProductCatalog = GetProductCatalogObject
    'response.write("BatchId:" & Service.Properties("BatchId") & "<BR>")
    
    'response.write("Metered Start Date:" & Service.Properties("MeteredStartDate") & "<BR>")
    'response.end

    dim sTitle
    sTitle= "Statistics from " & Service.Properties("TimestampStartDate") & " to " & Service.Properties("TimestampEndDate")
    Form.RouteTo                      = "Usage.Statistics.Frame.asp?Title=" & server.urlencode(sTitle) & "&StartTime=" & server.urlencode(Service.Properties("TimestampStartDate")) & "&EndTime=" & server.urlencode(Service.Properties("TimestampEndDate"))
    'mom_GetDictionary("USAGE_STATISTICS_QUERY_DIALOG")
    
    ' Make sure subscription start date is after po effective start date
    'If (CDate(Service.Properties("SubscriptionStartDate")) < CDate(Service.Properties("POEffectiveStartDate"))) Then
      '  EventArg.Error.Number= 1
      '  EventArg.Error.Description = mam_GetDictionary("MAM_ERROR_5005") & " [" & CDate(Service.Properties("POEffectiveStartDate")) & "]."
    '    OK_Click = FALSE
      '  Err.Clear
     '   Exit Function
    'End If
    
    ' Subscribe to Product Offering
    'acctID = mam_GetSubscriberAccountID()
  
    ' Get effective date
   ' Set effDate = Server.CreateObject(MTTimeSpan)  

   ' Check if Start Date is defined and in the past if yes ISSUE a WARNING... 
   'If Len(Service.Properties("SubscriptionStartDate")) Then
   
    '   If DateDiff("d", Now(), CDate(Service.Properties("SubscriptionStartDate"))) < 0 Then
       
    '        If Not Form("WarningStartDateInThePastSeen") Then
    
     '         EventArg.Error.Number = 1
     '         EventArg.Error.Description = mam_GetDictionary("MAM_WARNING_8000") 
     '         OK_Click = FALSE
     '         Form("WarningStartDateInThePastSeen") = TRUE
     '         Exit Function
     '       End If
   '    End If
 '  End If

    ' Check Effective Dates
 '   Dim strErrorMessage
 '   If Not CheckEffectiveDates(Service.Properties("SubscriptionStartDate"),Service.Properties("SubscriptionEndDate"), strErrorMessage, TRUE) Then
 '       EventArg.Error.Number= 1
 '       EventArg.Error.Description = strErrorMessage
 '       OK_Click = FALSE
 '       Err.Clear
 '       Exit Function
 '   End If
          
 '   effDate.StartDate = CDate(Service.Tools.ConvertToGMT(Service.Properties("SubscriptionStartDate"), MAM().CSR("TimeZoneId")))
'    If Len(Service.Properties("SubscriptionEndDate")) Then
 '     effDate.EndDate = CDate(Service.Tools.ConvertToGMT(Service.Properties("SubscriptionEndDate"), MAM().CSR("TimeZoneId")))
 '     If Service("EndNextBillingPeriod") Then 
 '       effDate.EndDateType = PCDATE_TYPE_BILLCYCLE 
 '     Else
 '       effDate.EndDateType = PCDATE_TYPE_ABSOLUTE 
 '     End IF
'    Else
'      effDate.SetEndDateNull
'    End If
     
'    If Service("StartNextBillingPeriod") Then 
'      effDate.StartDateType = PCDATE_TYPE_BILLCYCLE 
'    Else
'      effDate.StartDateType = PCDATE_TYPE_ABSOLUTE 
'    End IF


  
    ' Get account reference
 '   Set MTAccountReference = objMTProductCatalog.GetAccount(acctID)
   
    ' Subscribe
 '   MTAccountReference.Subscribe Service.Properties("SubscriptionID"), effDate
    
 '   If(CBool(Err.Number = 0)) then
 '       On Error Goto 0
        'AUDIT
        'mam_Audit mam_GetDictionary("AUDIT_SUBSCRIBE") & Service.Properties("Subscription"), 0
        OK_Click = TRUE
 '   Else        
 '       EventArg.Error.Save Err  
 '       OK_Click = FALSE
 '   End If
 '   Err.Clear      
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

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Cancel_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Cancel_Click(EventArg) ' As Boolean
  Form.Routeto = "welcome.asp"
  Cancel_Click = TRUE
END FUNCTION

%>

