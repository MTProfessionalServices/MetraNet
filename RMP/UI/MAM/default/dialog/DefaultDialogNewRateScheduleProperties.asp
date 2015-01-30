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
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo        = session("ownerapp_return_page")

mdm_Main ' invoke the mdm framework



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Populate()
' PARAMETERS		  : 
' DESCRIPTION 		: Check if the time for the end date was set if not we set 23:59:59.
' RETURNS		      : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Populate(EventArg) ' As Boolean
    
      Inherited("Form_Populate") ' First Let us call the inherited event
      
      mam_CheckEndDate EventArg, "EndDate"
      Form_Populate = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
  Dim objMTProductCatalog
  Dim objParamTableDef
    
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  ' Save our querystring in the form
  Form("PT_ID")  = CLng(Request.QueryString("PT_ID"))
  Form("RS_ID")  = CLng(Request.QueryString("RS_ID"))
  
  Set objMTProductCatalog = GetProductCatalogObject
  Set objParamTableDef = objMTProductCatalog.GetParamTableDefinition(Form("PT_ID"))
  Set Form("objMTRateSched") = objParamTableDef.GetRateSchedule(Form("RS_ID"))
  
  ' Add dialog properties
  Service.Properties.Add "Description",           "String",    256, TRUE,  ""                   
  Service.Properties.Add "StartDate",             "String",    0,   FALSE, Empty    
  Service.Properties.Add "EndDate",               "String",    0,   FALSE, Empty  
  Service.Properties.Add "StartNextBillingPeriod","boolean",   0,   FALSE, FALSE  
  Service.Properties.Add "EndNextBillingPeriod",  "boolean",   0,   FALSE, FALSE  

  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
      
  ' Set default values  
  Service.Properties("Description")            = Form("objMTRateSched").Description
  If Form("objMTRateSched").EffectiveDate.IsStartDateNull Then
    Service.Properties("StartDate")            = Empty
  Else
    Service.Properties("StartDate")            = mdm_Format(Service.Tools.ConvertFromGMT(Form("objMTRateSched").EffectiveDate.StartDate, MAM().CSR("TimeZoneId")),mam_GetDictionary("DATE_TIME_FORMAT"))
  End If
  
  If Form("objMTRateSched").EffectiveDate.IsEndDateNull Then
    Service.Properties("EndDate")              = Empty
  Else
    Service.Properties("EndDate")              = mdm_Format(Service.Tools.ConvertFromGMT(Form("objMTRateSched").EffectiveDate.EndDate, MAM().CSR("TimeZoneId")),mam_GetDictionary("DATE_TIME_FORMAT"))
  End If
    
  If Form("objMTRateSched").EffectiveDate.StartDateType = PCDATE_TYPE_BILLCYCLE Then 
      Service.Properties("StartNextBillingPeriod") = TRUE
  Else
      Service.Properties("StartNextBillingPeriod") = FALSE    
  End IF

  If Form("objMTRateSched").EffectiveDate.EndDateType = PCDATE_TYPE_BILLCYCLE Then 
      Service.Properties("EndNextBillingPeriod") = TRUE
  Else
      Service.Properties("EndNextBillingPeriod") = FALSE    
  End IF
    
  ' Set required fields
  Service.Properties("Description").Required = TRUE
     
  ' Localize captions  
  Service.Properties("Description").Caption            = mam_GetDictionary("TEXT_DESCRIPTION")
  Service.Properties("StartDate").Caption              = mam_GetDictionary("TEXT_RATE_START_DATE")  
  Service.Properties("EndDate").Caption                = mam_GetDictionary("TEXT_RATE_END_DATE")
  Service.Properties("StartNextBillingPeriod").Caption = mam_GetDictionary("TEXT_NEXT_BILLING_PERIOD")  
  Service.Properties("EndNextBillingPeriod").Caption   = mam_GetDictionary("TEXT_NEXT_BILLING_PERIOD")    
      
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

    On Error Resume Next

    Dim strLink
    Dim effDate ' As New MTTimeSpan 
  
    ' Get effective date
    Set effDate = Server.CreateObject(MTTimeSpan)    
    
    ' Check Effective Dates
    Dim strErrorMessage
    If Not CheckEffectiveDates(Service.Properties("StartDate"),Service.Properties("EndDate"), strErrorMessage, FALSE) Then
        EventArg.Error.Number= 1
        EventArg.Error.Description = strErrorMessage
        OK_Click = FALSE
        Err.Clear
        Exit Function
    End If

    If Len(Service.Properties("StartDate")) Then
      effDate.StartDate = mdm_Format(CDate(Service.Tools.ConvertToGMT(Service.Properties("StartDate"), MAM().CSR("TimeZoneId"))),mam_GetDictionary("DATE_TIME_FORMAT"))
      'ESR-6316
      'Issue - Rate schedule End date selection with popup calendar
      effDate.StartDate=DateAdd("h",-Hour(effDate.StartDate), effDate.StartDate)
      effDate.StartDate=DateAdd("n",-Minute(effDate.StartDate), effDate.StartDate)
      effDate.StartDate=DateAdd("s",-Second(effDate.StartDate), effDate.StartDate)
      If Service("StartNextBillingPeriod") Then 
        effDate.StartDateType = PCDATE_TYPE_BILLCYCLE 
      Else
        effDate.StartDateType = PCDATE_TYPE_ABSOLUTE 
      End IF      
    Else
      effDate.SetStartDateNull
    End If    

    If Len(Service.Properties("EndDate")) Then
      effDate.EndDate = mdm_Format(CDate(Service.Tools.ConvertToGMT(Service.Properties("EndDate"), MAM().CSR("TimeZoneId"))),mam_GetDictionary("DATE_TIME_FORMAT"))
      'ESR-6316
      'Issue - Rate schedule End date selection with popup calendar 
      effDate.EndDate=DateAdd("h",23-Hour(effDate.EndDate), effDate.EndDate)
      effDate.EndDate=DateAdd("n",59-Minute(effDate.EndDate), effDate.EndDate)
      effDate.EndDate=DateAdd("s",59-Second(effDate.EndDate), effDate.EndDate)
      If Service("EndNextBillingPeriod") Then 
        effDate.EndDateType = PCDATE_TYPE_BILLCYCLE 
      Else
        effDate.EndDateType = PCDATE_TYPE_ABSOLUTE 
      End IF      
    Else
      effDate.SetEndDateNull
    End If
       
    ' SAVE
    Form("objMTRateSched").EffectiveDate.StartDate     = effDate.StartDate
    Form("objMTRateSched").EffectiveDate.StartDateType = effDate.StartDateType
    Form("objMTRateSched").EffectiveDate.EndDate       = effDate.EndDate
    Form("objMTRateSched").EffectiveDate.EndDateType   = effDate.EndDateType    
    Form("objMTRateSched").Description = Service.Properties("Description")
    Form("objMTRateSched").Save
    
    If(CBool(Err.Number = 0)) then
        On Error Goto 0
        
        'AUDIT
        'mam_Audit mam_GetDictionary("AUDIT_NEW_RATE_SCHEDULE_PROPERTIES") & Service.Properties("Description"), 0 
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

