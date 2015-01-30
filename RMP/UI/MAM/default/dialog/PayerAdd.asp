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
<!-- #INCLUDE FILE="../../default/lib/DropAccountsLib.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
    
' Mandatory
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo        = mam_GetDictionary("PAYER_SETUP_DIALOG")

Session("BATCH_ERROR_RETURN_PAGE") = Form.RouteTo

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
  Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  ' Initialize Drop Grid -  bFolderOptions, bFoldersOnly
  InitDropGrid TRUE, FALSE
  								
  ' Add dialog properties
  Service.Properties.Add "StartDate",        "String", 0,   TRUE, Empty    
  Service.Properties.Add "EndDate",          "String", 0,   FALSE, Empty    	
  
	' Set Captions 
  Service.Properties("StartDate").caption = mam_GetDictionary("TEXT_START_DATE")
  Service.Properties("EndDate").caption = mam_GetDictionary("TEXT_END_DATE")	
	
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation

  ' Include Calendar javascript    
  mam_IncludeCalendar

  Form_Initialize = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
  Dim PaymentMgr
  Dim StartDateValue
  Dim EndDateValue

  On Error Resume Next

  ' CORE-8563 - CDate converts properly in all localizations. It only does not like "." symbols
  StartDateValue = mam_DateFromLocaleString(Service.Properties("StartDate").Value)
  EndDateValue = mam_DateFromLocaleString(Service.Properties("EndDate").Value)

  Form.Grids("DropGrid").Rowset.MoveFirst
    
 	' Get Payment Manager
  Set PaymentMgr = Session("SubscriberYAAC").GetPaymentMgr

  ' Make sure we have at least one account to act on
  If Form.Grids("DropGrid").Rowset.recordCount = 0 Then
      EventArg.Error.number = 1033
      EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1033")
      OK_Click = FALSE       
      Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
      Response.Redirect mdm_GetCurrentFullURL()             
      Exit Function  
  End IF
    
  If Form.Grids("DropGrid").Rowset.recordCount = 1 and Not CBool(Form.Grids("DropGrid").Properties("icon").Value) Then

	    If Len(Service.Properties("EndDate")) > 0 Then
        Call PaymentMgr.PayForAccount(CLng(Form.Grids("DropGrid").Properties("id").value), StartDateValue, EndDateValue)
      Else
        Call PaymentMgr.PayForAccount(CLng(Form.Grids("DropGrid").Properties("id").value), StartDateValue)
      End IF

  Else
      ' Batch Update  
      If Len(Service.Properties("EndDate")) > 0 Then
        Set Session("LAST_BATCH_ERRORS") = PaymentMgr.PayForAccountBatch(GetAccountIDCollection(), nothing, StartDateValue, EndDateValue)
      Else
        Set Session("LAST_BATCH_ERRORS") = PaymentMgr.PayForAccountBatch(GetAccountIDCollection(), nothing, StartDateValue)
      End IF

      If Err.Number <> 0 Then
        EventArg.Error.Save Err
          
        OK_Click = FALSE       
        Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
        Response.Redirect mdm_GetCurrentFullURL()            
        Exit Function
      End If
              
      ' Get Batch Errors  
      If Session("LAST_BATCH_ERRORS").RecordCount > 0 Then
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
      Response.Redirect Form.RouteTo 	      
      OK_Click = TRUE
  Else
      EventArg.Error.Save Err 
        
      OK_Click = FALSE       
      Set Session(mdm_EVENT_ARG_ERROR) = EventArg 
      Response.Redirect mdm_GetCurrentFullURL()   
  End If
    
END FUNCTION


%>

