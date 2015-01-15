<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: C:\builds\v3.5\Development\UI\MAM\default\dialog\UDRCUpdate.asp$
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
'  $Date: 11/01/2002 3:26:49 PM$
'  $Author: Kevin Boucher$
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
Form.RouteTo        = session("UDRC_CANCEL_ROUTETO")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
  Dim objMTProductCatalog
  
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  Form("InitialTemplate") = Form.HTMLTemplateSource  ' Save the initial template so we can use it to render a new dynamic template later
                      
  ' Add dialog properties
  Service.Properties.Add "ChargeAccount", "STRING", 255, TRUE, Empty    
  Service.Properties.Add "Name", "STRING", 255, TRUE, Empty    
  Service.Properties.Add "StartDate", "STRING", 0, FALSE, Empty    
  Service.Properties.Add "EndDate", "STRING", 0, FALSE, Empty    	
  
 	' Set Captions 
  Service.Properties("Name").caption = "Name"
  Service.Properties("ChargeAccount").caption = "Charge Account"
 	Service.Properties("StartDate").caption = mam_GetDictionary("TEXT_START_DATE")
  Service.Properties("EndDate").caption = mam_GetDictionary("TEXT_END_DATE")	
  
  ' Get Values
  Form("id_prop") = request.QueryString("id_prop")
  Set objMTProductCatalog = GetProductCatalogObject()
  Set Form("GroupSubscription") = objMTProductCatalog.GetGroupSubscriptionByID(Session("EDIT_ID")) 
     
  ' Set Values
  Service.Properties("Name").Value = request.QueryString("Name")
  If FrameWork.IsMinusInfinity(CDate(request.QueryString("StartDate"))) Then
    Service.Properties("StartDate").Value = ""
  Else
    Service.Properties("StartDate").Value = CDate(request.QueryString("StartDate"))
  End If
  If FrameWork.IsInfinity(CDate(request.QueryString("EndDate"))) Then
    Service.Properties("EndDate").Value = ""
  Else
    Service.Properties("EndDate").Value = FrameWork.RemoveTime(CDate(request.QueryString("EndDate"))) & " " & FrameWork.Dictionary().Item("END_OF_DAY").Value
  End If
 	Service.Properties("ChargeAccount").Value = mam_GetFieldIDFromAccountID(request.QueryString("id_acc"))
  
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
	  On Error Resume Next
    Dim nID

    If Service.Properties("StartDate").Value = "" Then
      Service.Properties("StartDate").Value = FrameWork.GetMinDate()
    End If

    Dim datEndDate
    If Service.Properties("EndDate").Value = "" Then
      Service.Properties("EndDate").Value = FrameWork.RCD().GetMaxDate()
      datEndDate = FrameWork.RCD().GetMaxDate()
    Else
     datEndDate   = CDate(Service.Properties("EndDate").Value)
     datEndDate   = FrameWork.RemoveTime(datEndDate)
     datEndDate   = CStr(datEndDate) & " " & FrameWork.Dictionary().Item("END_OF_DAY").Value
    End If


    If FrameWork.DecodeFieldID(Service.Properties("ChargeAccount"), nID) Then    
        Call Form("GroupSubscription").SetChargeAccount(Form("id_prop"), nID, Service.Properties("StartDate").Value, CDate(datEndDate))
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

