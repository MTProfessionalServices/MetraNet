<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: PayerUpdate.asp$
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
'  $Date: 09/11/2002 9:40:37 AM$
'  $Author: Alon Becker$
'  $Revision: 17$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
    
' Mandatory
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo        = session("CANCEL_ROUTETO")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
	Dim objYAAC, strName
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  ' Add dialog properties
  Service.Properties.Add "Payer",      "String",    256, TRUE,  ""                   
  Service.Properties.Add "StartDate",  "TIMESTAMP", 0,   TRUE, Empty    
  Service.Properties.Add "EndDate",    "TIMESTAMP", 0,   FALSE, Empty    	
	
  If FrameWork.IsInfinity(request.QueryString("OldStartDate")) Then
    Form("OldStartDate") = Empty
  Else
  	Form("OldStartDate") = request.QueryString("OldStartDate")
  End If
  If FrameWork.IsInfinity(request.QueryString("OldEndDate")) Then
    Form("OldEndDate") = Empty
  Else
	  Form("OldEndDate") = request.QueryString("OldEndDate")
  End If

 	Form("AccountID") = request.QueryString("ID")
	
  Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(Form("AccountID")), CDate(mam_GetDictionary("END_OF_TIME")))
  strName = objYAAC.AccountName
  
  mdm_GetDictionary.Add "TEXT_UPDATE_PAYER", replace(mam_GetDictionary("TEXT_UPDATE_PAYER_TITLE"), "[USERNAME]", strName)
  
  Form("OldPayer") = request.QueryString("PayerID")
      
  If Len(request.QueryString("PayerID")) > 0 Then
    Service.Properties("Payer").Value = mam_GetFieldIDFromAccountIDAtTime(request.QueryString("PayerID"), Form("OldStartDate"))
  Else
    If UCase(request.QueryString("NewPayer")) <> "TRUE" Then  
   	  Service.Properties("Payer").Value = mam_GetFieldIDFromAccountID(mam_GetSubscriberAccountID())
    End If  
  End If

  Service.Properties("StartDate").Value = CDate(Form("OldStartDate"))
	Service.Properties("EndDate").Value = CDate(Form("OldEndDate"))	
			 
	' Set Captions 
  Service.Properties("Payer").caption = mam_GetDictionary("TEXT_ACCOUNTS")
	Service.Properties("StartDate").caption = mam_GetDictionary("TEXT_START_DATE")
	Service.Properties("EndDate").caption = mam_GetDictionary("TEXT_END_DATE")	
	
	'CR 10488 - always allow update
  'If UCase(request.Querystring("Update")) = "TRUE" Then
  '  Service.Properties("Payer").Enabled = FALSE
  'End If
  
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
	 Dim objYAAC
   Dim PayerAccountID
   Dim strEndDate
	 On Error Resume Next

   strEndDate = Service.Properties("EndDate")
   If Len(strEndDate) = 0 Then
      strEndDate = mam_GetDictionary("END_OF_TIME")
   End If

   If FrameWork.DecodeFieldID(Service.Properties("Payer").value, PayerAccountID) Then
   
  	 If CLng(PayerAccountID) = CLng(mam_GetSubscriberAccountID()) Then  ' Should we use the Subscribers Yaac
           
      	Set PaymentMgr = Session("SubscriberYAAC").GetPaymentMgr
                   
        If Len(Form("OldStartDate")) = 0 Then
          ' No start date so create new 
  	      Call PaymentMgr.PayForAccount(Form("AccountID"), CDate(Service.Properties("StartDate")), CDate(strEndDate))
        Else
    		  ' Payer is the same so just do ChangePaymentEffectiveDate
          PaymentMgr.ChangePaymentEffectiveDate Form("AccountID"), CDate(Form("OldStartDate")), CDate(Form("OldEndDate")), CDate(Service.Properties("StartDate")), CDate(strEndDate)
        End If
        
  		Else
        Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(PayerAccountID), mam_GetHierarchyTime())
        If err.number <> 0 then
          EventArg.Error.number = 1037
          EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1037")
          OK_Click = FALSE       
          Exit Function
        end if
     
        Set PaymentMgr = objYAAC.GetPaymentMgr
           
        If CLng(Form("OldPayer")) = CLng(PayerAccountID) Then
    		  ' Payer is the same so just do ChangePaymentEffectiveDate
          PaymentMgr.ChangePaymentEffectiveDate Form("AccountID"), CDate(Form("OldStartDate")), CDate(Form("OldEndDate")), CDate(Service.Properties("StartDate")), CDate(strEndDate)
        Else
    		  ' There is a new payer so create new pay for account record
    	     Call PaymentMgr.PayForAccount(Form("AccountID"), CDate(Service.Properties("StartDate")), CDate(strEndDate))
        End If 
 							
  		End If
   Else
      EventArg.Error.number = 1037
      EventArg.Error.description = mam_GetDictionary("MAM_ERROR_1037")
      OK_Click = FALSE       
      Exit Function
   End IF
   
    If(CBool(Err.Number = 0)) then
        On Error Goto 0
        OK_Click = TRUE
    Else        
        EventArg.Error.Save Err  
        OK_Click = FALSE
    End If
END FUNCTION


%>

