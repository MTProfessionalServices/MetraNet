<% 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' MetraTech Dialog Manager Demo
' 
' DIALOG	    : MCM Dialog
' DESCRIPTION	: 
' AUTHOR	    : F.Torres
' VERSION	    : 1.0
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE
Form.RouteTo        = FrameWork.GetDictionary("PRODUCT_OFFERING_LIST_DIALOG")

mdm_Main ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form.Modal = TRUE ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will no terminate the dialog
                      ' but do a last rendering/refresh. The client dialog must set the property         
                      ' Form.JavaScriptInitialize = "window.close();" & VBNEWLINE, see OK_CLICK Event in this file.

  Dim objMTProductCatalog
  Dim objMTPriceableItem
  Dim objMTPriceListMapping
  Dim objMTPriceList
  Dim objMTProductOffering
  Set objMTProductCatalog = GetProductCatalogObject  

	if len(Request.QueryString("PI_ID")) then
		Form("PI_ID") = Request.QueryString("PI_ID")
	end if
	if len(Request.QueryString("ID")) then
		Form("ID") = Request.QueryString("ID")
	end if	
	if len(Request.QueryString("NonSharedPLID")) then
		Form("NonSharedPLID") = Request.QueryString("NonSharedPLID")
	end if	

  'response.write("PI [" & CLng(Request.QueryString("PI_ID")) & "]<BR>")
  'response.write("PARAMTABLE [" & CLng(Request.QueryString("ID")) & "]<BR>")
  'response.write("PI [" & CLng(Form("PI_ID")) & "]<BR>")
  'response.write("PARAMTABLE [" & CLng(Form("ID")) & "]<BR>")

  Set objMTPriceableItem = objMTProductCatalog.GetPriceableItem(CLng(Form("PI_ID")))
  Set objMTPriceListMapping = objMTPriceableItem.GetPriceListMapping(CLng(Form("ID")))
  
  'response.write("Price List Mapping[" & objMTPriceListMapping.PriceListId & "]<BR>")
  'response.write("Price List Name[" & objMTPriceList.Name & "]<BR>")
    
  Set COMObject.Instance = objMTPriceListMapping
	  
  If Not IsValidObject(COMObject.Instance) Then
    Response.write FrameWork.GetDictionary("ERROR_ITEM_NOT_FOUND") & Request.QueryString("ID")
    Response.end
  End If
  
  'We need to know if the product offering can be modified
  set objMTProductOffering = objMTPriceableItem.GetProductOffering()
  If Not IsValidObject(COMObject.Instance) Then
    Response.write FrameWork.GetDictionary("ERROR_ITEM_NOT_FOUND") & "Could not load product offering for priceable item with id & " & Form("PI_ID")
    Response.end
  End If
  
  ' Check to see if this PO can be modified, if not display a warning  
  If Not CBool(objMTProductOffering.CanBeModified()) Then
    mdm_GetDictionary().Add "CAN_NOT_BE_MODIFIED", "TRUE"
  Else
    mdm_GetDictionary().Add "CAN_NOT_BE_MODIFIED", "FALSE"  
  End If
  
  'Javascript  don't understand the "." in date properties.That is the reason taking in to the temporary property and reassigning the value
  COMObject.Properties.Add "PriceListName", "String",  256, FALSE, TRUE 
  COMObject.Properties.Add "NonSharedPriceList", "Int32", 0, FALSE, TRUE
  COMObject.Properties.Add "MapAll", "Boolean", 0, FALSE, FALSE
  
	'COMObject.Properties("PriceListName").Value =  objMTPriceList.Name
	COMObject.Properties("PriceListName").Caption = FrameWork.GetDictionary("TEXT_KEYTERM_PRICE_LIST")
  	
  'COMObject.Properties("Name").Enabled = FALSE
  'COMObject.Properties.Enabled              = TRUE ' Every control is grayed
  'Form.Grids.Enabled                        = TRUE ' All Grid are not enabled
      
	Form_Initialize = Form_Refresh(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Refresh
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean

	'response.write("PickerAddMapping[" & Request("PickerAddMapping") & "]<BR>")
	'response.write("PRICELIST PICKERIDS[" & Request("PICKERIDS") & "]<BR>")
  
	if Left(UCase(Request("PickerAddMapping")),4) = "TRUE" then
  	'response.write("Adding pricelist mapping<BR>")
  	'response.write("PRICELIST PICKERIDS[" & Request("PICKERIDS") & "]<BR>")
		if Request("PICKERIDS") <> "" then
    	COMObject.Instance.PriceListId = Clng(Request("PICKERIDS"))
  	end if
	end if

	if COMObject.Instance.PriceListId <> -1 then
  	Dim objMTProductCatalog
  	Dim objMTPriceList
  	Set objMTProductCatalog = GetProductCatalogObject   
  	Set objMTPriceList = objMTProductCatalog.GetPriceList(COMObject.Instance.PriceListID)
  	COMObject.Properties("PriceListName").Value =  objMTPriceList.Name
	end if    
  
  If Clng(Form("NonSharedPLID")) = COMObject.Instance.PriceListID Then
    COMObject.Properties("NonSharedPriceList").value = "1"
    COMObject.Properties("PriceListName").value = ""
  Else
    COMObject.Properties("NonSharedPriceList").value = "0"
  End If

  Form_Refresh = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  Dim objMTProductCatalog, objPriceList
  On Error Resume Next

  If ComObject.Properties("NonSharedPriceList").Value Then
    Set objMTProductCatalog = GetProductCatalogObject
    COMObject.Instance.PriceListID = Form("NonSharedPLID")
  End If
  
  COMObject.Instance.Save
  
  If(Err.Number)Then
    EventArg.Error.Save Err
    Err.Clear
    OK_Click = FALSE
  Else
    OK_Click = TRUE
  End If
END FUNCTION
%>

