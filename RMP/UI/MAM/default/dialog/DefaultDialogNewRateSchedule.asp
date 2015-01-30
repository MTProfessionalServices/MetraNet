<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
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
'  $Date$
'  $Author$
'  $Revision$
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
Form.RouteTo        = mam_GetDictionary("RULE_EDITOR_DIALOG")

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

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  ' Save our querystring in the form
  Form("ID")     = CLng(Request.QueryString("ID"))
  Form("Sub_ID") = CLng(Request.QueryString("Sub_ID"))
	Form("Group_ID") = Request.QueryString("Group_ID")
  Form("PO_ID")  = CLng(Request.QueryString("PO_ID"))
  Form("PI_ID")  = CLng(Request.QueryString("PI_ID"))
  Form("PT_ID")  = CLng(Request.QueryString("PT_ID"))
  
  
  ' Add dialog properties
  Service.Properties.Add "Description",           "String",    256, TRUE,  ""                   
  Service.Properties.Add "StartDate",             "String",    0,   FALSE, Empty    
  Service.Properties.Add "EndDate",               "String",    0,   FALSE, Empty  
  Service.Properties.Add "StartNextBillingPeriod","boolean",   0,   FALSE, FALSE  
  Service.Properties.Add "EndNextBillingPeriod",  "boolean",   0,   FALSE, FALSE  
  
	If Len(Form("Group_ID")) > 0 Then
		Service.Properties("StartNextBillingPeriod").Value = false
		Service.Properties("EndNextBillingPeriod").Value = false
		Service.Properties("StartNextBillingPeriod").Enabled = false
		Service.Properties("EndNextBillingPeriod").Enabled = false
		mdm_GetDictionary.Add "SHOW_NEXTBILLINGPERIOD_CHOICE", false
	Else
		mdm_GetDictionary.Add "SHOW_NEXTBILLINGPERIOD_CHOICE", true
	End If
	
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
    
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

FUNCTION getParamTablePage(pt_id)
	Dim objProdcat, objParamTableDef, destiny_url
	Set objProdcat = GetProductCatalogObject
	Set objParamTableDef = objProdcat.GetParamTableDefinition(pt_id)
	
	' We retrieve the parameter table name and check whether there is a special screen for it in the dictionary
	destiny_url = mam_GetDictionaryDefault(objParamTableDef.Name, "")
	
	' It the result is blank, we will go to the default MPTE url
	if destiny_url = "" then
		getParamTablePage = mam_GetDictionary("RULE_EDITOR_DIALOG")
	else
		getParamTablePage = destiny_url
	end if
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    On Error Resume Next
		
    Dim rsID
    Dim strLink
    Dim acctID
    Dim MTAccountReference
		Dim objMTSubscription
    Dim objMTProductCatalog
    Dim effDate ' As New MTTimeSpan 
    Set objMTProductCatalog = GetProductCatalogObject
    
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
      effDate.StartDate = mdm_Format(CDate(Service.Tools.ConvertToGMT(Service.Properties("StartDate"), CLng(MAM().CSR("TimeZoneId")))), mam_GetDictionary("DATE_TIME_FORMAT"))
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
      effDate.EndDate = mdm_Format(CDate(Service.Tools.ConvertToGMT(Service.Properties("EndDate"), CLng(MAM().CSR("TimeZoneId")))), mam_GetDictionary("DATE_TIME_FORMAT"))
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
		
		' 2 possible modes - Group Subscription or Account Subscription
		if Len(Form("Group_ID")) then ' GSub
			Set objMTSubscription = objMTProductCatalog.GetGroupSubscriptionByID(CLng(Form("Group_ID")))
		else
			acctID = mam_GetSubscriberAccountID()
			Set MTAccountReference = objMTProductCatalog.GetAccount(acctID)
  		Set objMTSubscription = MTAccountReference.GetSubscription(Form("Sub_ID"))
		end if
		
    ' Get New Rate Schedule ID for ICB pricelist and go to Rule Editor
    rsID = GetNewRateScheduleID(EventArg, objMTSubscription, effDate)
    
    If(CBool(Err.Number = 0)) then
        On Error Goto 0

        ' Got to Rule Editor        
        strLink = "[ASP_PAGE]?EditMode=TRUE&Reload=TRUE&refresh=TRUE&PT_ID=[PT_ID]&RS_ID=[RS_ID]"
      
        strLink = Replace(strLink, "[ASP_PAGE]", getParamTablePage(Form("PT_ID")))
        strLink = Replace(strLink, "[PT_ID]", Form("PT_ID"))
        strLink = Replace(strLink, "[RS_ID]", rsID)
         
        Form.RouteTo = strLink
        
        'AUDIT
        'mam_Audit mam_GetDictionary("AUDIT_NEW_RATE_SCHEDULE") & Service.Properties("Description"), 0 
        OK_Click = TRUE
    Else        
        EventArg.Error.Save Err  
        OK_Click = FALSE
    End If
    Err.Clear      
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  GetNewRateScheduleID
' PARAMETERS:  
' DESCRIPTION:
' RETURNS:  new rate schedule id
Function GetNewRateScheduleID(EventArg, MTSubscription, effDate)

  Dim PricelistMap        ' As MTPricelistMapping
  Dim NewRateSchedule     ' As MTRateSchedule

  set PriceListMap = MTSubscription.GetICBPriceListMapping(Form("PI_ID"), Form("PT_ID"))
  if PriceListMap is nothing then
	   'MTSubscription.SetICBPriceListMapping Form("PI_ID"), Form("PT_ID"), MAM().Subscriber("currency") 'TODO:  type mismatch if no default pricelist
	   MTSubscription.SetICBPriceListMapping Form("PI_ID"), Form("PT_ID"), ""
     set PriceListMap = MTSubscription.GetICBPriceListMapping(Form("PI_ID"), Form("PT_ID"))
  End If
   
  Set NewRateSchedule = PricelistMap.CreateRateSchedule()
  
  NewRateSchedule.Description      = Service("Description")
  NewRateSchedule.ParameterTableID = Clng(Form("PT_ID"))
  
  NewRateSchedule.EffectiveDate.StartDateType = effDate.StartDateType
  NewRateSchedule.EffectiveDate.EndDateType   = effDate.EndDateType
  NewRateSchedule.EffectiveDate.StartDate     = CDate(effDate.StartDate)
  NewRateSchedule.EffectiveDate.EndDate       = CDate(effDate.EndDate)
  
  NewRateSchedule.Save
  
  GetNewRateScheduleID = NewRateSchedule.ID
  
  ' Save any errors we got
  If (Err) then
    EventArg.Error.Save Err  
  End If

End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Cancel_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Cancel_Click(EventArg) ' As Boolean

  Form.RouteTo = session("ownerapp_return_page")

  Cancel_Click = TRUE
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

