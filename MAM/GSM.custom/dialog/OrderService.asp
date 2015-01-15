<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<% 
' ---------------------------------------------------------------------------------------------------------
'  Copyright 1998,2006 by MetraTech Corporation
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
' ---------------------------------------------------------------------------------------------------------
'
' MetraTech Account Manager 
' 
' DIALOG	    : OrderService.asp
' DESCRIPTION	: Custim order service screen for Ericsson demo
' AUTHOR	    : Kevin Boucher
' VERSION	    : 5.0
'
' ---------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/TabsClass.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
Form.Version = MDM_VERSION     
Form.RouteTo = MAM_GetDictionary("WELCOME_DIALOG")

Public CONST NAMESPACE = "mt"

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
 	Service.Properties.Clear()
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
  Form("InitialTemplate") = Form.HTMLTemplateSource  ' Save the initial template so we can use it to render a new dynamic template later
 
  mdm_GetDictionary().add "INVALID_SIM", FALSE		
  mdm_GetDictionary().add "VALID_SIM", FALSE		
  Form("NUMBERS_TO_GET") = 10
 
  ' Add Properties
  Service.Properties.Add "SimNumber", "String",  0, TRUE, ""  
  Service.Properties.Add "SimType", "String",  0, FALSE, "" 
  Service.Properties.Add "IMSI", "String",  0, FALSE, "" 
  Service.Properties.Add "SIMAccountID", "String",  0, FALSE, "" 
  Service.Properties.Add "IMEI", "String",  0, FALSE, "" 
	
	'Add Captions
	Service.Properties("SimNumber").Caption = "Subscriber Identity Module (SIM)"
	Service.Properties("SimType").Caption = "SIM Type"
	Service.Properties("IMSI").Caption = "International Mobile Subscriber Identity (IMSI)"
	Service.Properties("SIMAccountID").Caption = "Internal SIM ID"
	Service.Properties("IMEI").Caption =  "International Mobile Equipment Identity (IMEI)"
  

  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation

  Form_Initialize = DynamicTemplate(EventArg) ' Load the correct template for the dynmaic pieces
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION:  DynamicTemplate
' PARAMETERS:  EventArg
' DESCRIPTION:  This function determines what should be placed in the dialog template based on dynamic content
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION DynamicTemplate(EventArg)
  Dim rsPhoneNumbers
  Dim objDyn
	Dim strHTML

  if mam_GetDictionary("INVALID_SIM") = FALSE	AND mam_GetDictionary("VALID_SIM") = FALSE Then
    Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<DYNAMIC_TEMPLATE />", strHTML)
    DynamicTemplate = TRUE
    Exit Function
  End If

  Service.Properties("IMEI").Required = TRUE

  ' Setup initial template
  Form.HTMLTemplateSource = Form("InitialTemplate")
	
	' PHONE NUMBERS
	' -----------------------------------------------------------------------------------------------------------
  Set rsPhoneNumbers = ExecuteSQL("Select top " & Form("NUMBERS_TO_GET") & " * from t_msisdn where tx_status = 'Unassigned'")
  ' Dim phones
  ' Set phones = Server.CreateObject("Phone.PhoneDB")
  ' Set rsPhoneNumbers = phones.GetPhones(1, CInt(Form("NUMBERS_TO_GET"))) ' 1 = Unassigned in enum

	Set objDyn = mdm_CreateObject(CVariables)
	strHTML = strHTML & "<table width='70%'>"
  strHTML = strHTML & "<tr>"
	strHTML = strHTML & "	 <td colspan='2' class='clsStandardText'><span class='sectionCaptionBar'>Select a Phone Number:&nbsp;&nbsp;</span><hr></td></tr>"
  do while not rsPhoneNumbers.eof 
    dim number
    number = rsPhoneNumbers.value("id_msisdn")
    objDyn.Add number, number, , , number
    strHTML = strHTML & "<tr>"
    strHTML = strHTML & "	<td><input type='radio' name='PhoneNumber' value='" & number & "'>" & number & "</td>"
    rsPhoneNumbers.movenext
    if rsPhoneNumbers.eof then
      Exit Do
    end if
    number = rsPhoneNumbers.value("id_msisdn")
    objDyn.Add number, number, , , number
    strHTML = strHTML & "	<td><input type='radio' name='PhoneNumber' value='" & number & "'>" & number & "</td>"
    strHTML = strHTML & "</tr>"
    rsPhoneNumbers.movenext
  loop 
  strHTML = strHTML & "<tr><td colspan='2' align='right'><BUTTON onClick='mdm_RefreshDialog(this)' name='MoreNumbers' class='clsButtonBlueLarge'>More Numbers</BUTTON></td></tr>"
  strHTML = strHTML & "</table>"			 
  Service.Properties.Add "PhoneNumber", "String", 0, TRUE, ""
  Service.Properties("PhoneNumber").AddValidListOfValues objDyn	
		
	'PRODUCT OFFERINGS
	' -----------------------------------------------------------------------------------------------------------
	Dim objMTProductCatalog , MTAccountReference, acctID
  Form("StartDate") = mam_GetHierarchyDate()
  Form("EndDate") = FrameWork.RCD().GetMaxDate()
      
  Set objMTProductCatalog = GetProductCatalogObject
  acctID = MAM().TempAccount("_AccountID").Value
  Set MTAccountReference = objMTProductCatalog.GetAccount(acctID)

  ' Get PO rowset
  dim rsPOs
  'Set rsPOs = MTAccountReference.FindSubscribableProductOfferingsAsRowset(,Form("StartDate").Value)  
  set rsPOs = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  rsPOs.Init "queries\ProductCatalog"
  rsPOs.SetQueryTag "__FIND_SUBSCRIBABLE_PO_FOR_SVC_ACCT__"
  rsPOs.AddParam "%%ACC_ID%%", acctID
  rsPOs.AddParam "%%ACC_ID_PARENT%%", mam_GetSubscriberAccountID()
  rsPOs.AddParam "%%ID_LANG%%", 840
  rsPOs.AddParam "%%REFDATE%%", mam_GetHierarchyDate()
  rsPOs.Execute

  Dim objDyn1
	Set objDyn1 = mdm_CreateObject(CVariables)
	strHTML = strHTML & "<br /> <table width='70%'>"
  strHTML = strHTML & "<tr>"
	strHTML = strHTML & "	 <td colspan='3' class='clsStandardText'><span class='sectionCaptionBar'>Select Service Class:&nbsp;&nbsp;</span><hr></td></tr>"
  do while not rsPOs.eof 
    dim poID, displayName, desc
    poID = rsPOs.value("id_po")
    objDyn.Add poID, poID, , , poID
    displayName = rsPOs.value("nm_display_name")
    desc = rsPOs.value("nm_desc")
    strHTML = strHTML & "<tr>"
    strHTML = strHTML & "<td><input type='radio' name='PO' value='" & poID & "'>&nbsp;</td>"
    strHTML = strHTML & "<td>" & displayName & "</td>"
    strHTML = strHTML & "<td>" & desc & "</td>"
    strHTML = strHTML & "</tr>"
    rsPOs.movenext
  loop
  strHTML = strHTML & "</table>"		
  Service.Properties.Add "PO", "String", 0, TRUE, ""
  Service.Properties("PO").AddValidListOfValues objDyn	
		
	Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<DYNAMIC_TEMPLATE />", strHTML)
  
  DynamicTemplate = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Refresh
' PARAMETERS:  EventArg
' DESCRIPTION:  Loads the DynamicCapabilities using the initial saved template
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Refresh(EventArg) ' As Boolean
	Form_Refresh = DynamicTemplate(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION:  MoreNumbers_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION MoreNumbers_Click(EventArg) ' As Boolean
	Form("NUMBERS_TO_GET") = Form("NUMBERS_TO_GET") + 10
	MoreNumbers_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION:  Validate_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Validate_Click(EventArg) ' As Boolean
	on error resume next

	Dim bValid
	bValid = FALSE
	
  Dim objYaac
  Set objYaac = FrameWork.AccountCatalog.GetAccountByName(Service.Properties("SimNumber"), NAMESPACE, mam_ConvertToSysDate(mam_GetHierarchyTime()))

  If IsValidObject(objYaac)  Then
    mam_LoadTempAccount objYaac.AccountID
    Service.Properties("SimType").Value = MAM().TempAccount("AccountType").Value 
    Service.Properties("IMSI").Value = MAM().TempAccount("IMSI").Value 
    Service.Properties("SIMAccountID").Value = MAM().TempAccount("_AccountID").Value
    bValid = TRUE
  End If    
	
	If bValid Then
	  mdm_GetDictionary().add "INVALID_SIM", FALSE		
    mdm_GetDictionary().add "VALID_SIM", TRUE		
	Else
	  mdm_GetDictionary().add "INVALID_SIM", TRUE		
    mdm_GetDictionary().add "VALID_SIM", FALSE		
	End If
		
	Validate_Click = TRUE

	on error goto 0
END FUNCTION


' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean

  On Error Resume Next
  OK_Click = FALSE

  if mam_GetDictionary("INVALID_SIM") = FALSE	AND mam_GetDictionary("VALID_SIM") = FALSE Then
    Err.Description = "You must validate the SIM before you can Order Service."
    EventArg.Error.Save Err
    Service.Log EventArg.Error.ToString , eLOG_ERROR
    Exit Function
  End If

  Dim result
  result = MeterOrderService(EventArg)

  If (Err.Number <> 0 or result = FALSE) Then
    if result = FALSE then
      Err.Description = "Failed to Order Service.  Check IMEI and try a different phone number.  Also, make sure you have selected a service class."
    end if
    EventArg.Error.Save Err
    Service.Log EventArg.Error.ToString , eLOG_ERROR
  Else
    ' Success
     Form.RouteTo = mam_ConfirmDialogEncodeAllURL("Order Service Successful", "The service order was completed successfuly.", mam_GetDictionary("SUBSCRIBER_FOUND") & "?AccountID=" & Service.Properties("SIMAccountID").Value)
     OK_Click = TRUE
  End If
 
  On Error Goto 0  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : MeterOrderService
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :
PRIVATE FUNCTION MeterOrderService(EventArg) ' As Boolean
  MeterOrderService = FALSE
  
  Dim OrderService
  Dim strServiceMsixDefFile
  strServiceMsixDefFile = "metratech.com\GSMOrder.msixdef"
  Set OrderService = mdm_CreateObject(MSIXHandler)
  Set OrderService.SessionContext = FrameWork.SessionContext
  
  ' Load the OrderService Service for metering
  If (OrderService.Initialize(strServiceMsixDefFile,,mdm_GetSessionVariable("mdm_APP_LANGUAGE"),mdm_GetSessionVariable("mdm_APP_FOLDER"),mdm_GetMDMFolder(),mdm_InternalCache))Then

      OrderService.Properties("ActionType").Value          = OrderService.Properties("ActionType").EnumType.Entries("ACCOUNT").Value
      OrderService.Properties("Operation").Value           = OrderService.Properties("Operation").EnumType.Entries("Update").Value
      OrderService.Properties("AccountType").Value         = Service("SIMType")
      OrderService.Properties("ancestorAccountID").Value   = mam_GetSubscriberAccountID()
      OrderService.Properties("username")                  = Service("SimNumber")
      OrderService.Properties("name_space")                = NAMESPACE
      OrderService.Properties("IMEI").Value                = Service("IMEI")
      OrderService.Properties("MSISDN").Value              = Service("PhoneNumber")
      OrderService.Properties("ProductOfferingID").Value   = Service("PO")
      OrderService.Properties("hierarchy_startdate").Value = Form("StartDate")
      
      On Error Resume Next
      OrderService.Meter TRUE
      If (Err.Number <> 0) Then
        EventArg.Error.Save Err
        OrderService.Log EventArg.Error.ToString , eLOG_ERROR
      Else
        MeterOrderService = TRUE
      End If
      On Error Goto 0  
  End If
END FUNCTION


' ---------------------------------------------------------------------------------------------------------
' Execute SQL Query directly - FOR DEMO ONLY
PUBLIC FUNCTION ExecuteSQL(strSQL)
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.Init "queries\audit" 'dummy
    rowset.SetQueryString strSQL
    rowset.Execute
		set ExecuteSQL = rowset
END FUNCTION
%>


