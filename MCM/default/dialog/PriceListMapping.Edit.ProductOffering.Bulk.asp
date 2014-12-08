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
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE FILE="../lib/ProductCatalogXml.asp" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = FALSE

mdm_Main ' invoke the mdm framework


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form.Modal = False ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will no terminate the dialog
                      ' but do a last rendering/refresh. The client dialog must set the property         
                      ' Form.JavaScriptInitialize = "window.close();" & VBNEWLINE, see OK_CLICK Event in this file.


  Dim objMTProductCatalog
  Dim objMTPriceableItem
  Dim objMTPriceListMapping
  Dim objMTPriceList
  Set objMTProductCatalog = GetProductCatalogObject  

  Form("PRODUCT_OFFERING_ID") = Request.QueryString("ID")

  Form.RouteTo        = FrameWork.GetDictionary("PRODUCT_OFFERING_PRICELIST_MAPPING_BULK_EDIT_DIALOG") & "?ID=" & Form("PRODUCT_OFFERING_ID") & "&mdmReload=TRUE"

	if len(Request.QueryString("PI_ID")) then
		Form("PI_ID") = Request.QueryString("PI_ID")
	end if
	if len(Request.QueryString("ID")) then
		Form("ID") = Request.QueryString("ID")
	end if	
  
 
  'Javascript  don't understand the "." in date properties.That is the reason taking in to the temporary property and reassigning the value
  Service.Clear
  Service.Properties.Add "PriceListName", "String",  256, FALSE, TRUE 
  Service.Properties.Add "NonSharedPriceList", "Int32", 0, FALSE, TRUE
  Service.Properties.Add "PriceListId", "Int32", 0, FALSE, TRUE
  Service.Properties.Add "CanICB", "Boolean", 0, TRUE, FALSE
  Service.Properties.Add "UpdateICB", "Boolean", 0, FALSE, FALSE
  Service.Properties.Add "UpdatePricelist", "Boolean", 0, FALSE, FALSE

	'COMObject.Properties("PriceListName").Value =  objMTPriceList.Name
	Service.Properties("PriceListId").Value = IIF(len(Session("PriceListMappingBulk_DefaultPricelistId"))=0,-1,CLng(Session("PriceListMappingBulk_DefaultPricelistId")))
	Service.Properties("PriceListName").Value = Session("PriceListMappingBulk_DefaultPricelistName")
  Service.Properties("PriceListName").Caption = FrameWork.GetDictionary("TEXT_KEYTERM_PRICE_LIST")

  Dim objMTProductOffering
  Set objMTProductOffering  = objMTProductCatalog.GetProductOffering(Form("ID"))
  Service.Properties.Add "ProductOfferingCurrency", "String",  256, FALSE, TRUE 
  Service.Properties("ProductOfferingCurrency").Value = objMTProductOffering.GetCurrencyCode
  
  ' Check to see if this PO can be modified, if not display a warning  
  If Not CBool(objMTProductOffering.CanBeModified()) Then
    mdm_GetDictionary().Add "CAN_NOT_BE_MODIFIED", "TRUE"
  Else
    mdm_GetDictionary().Add "CAN_NOT_BE_MODIFIED", "FALSE"  
  End If
    
  Service.Properties("UpdatePricelist").Value = false
  Service.Properties("UpdateICB").Value = false	
  
  'COMObject.Properties("Name").Enabled = FALSE
  'COMObject.Properties.Enabled              = TRUE ' Every control is grayed
  'Form.Grids.Enabled                        = TRUE ' All Grid are not enabled
 
  '//Get the parameter table selector HTML and populate form
   Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, _
                                     "<PRODUCT_OFFERING_PARAM_TABLE_SELECTOR />", _
                                     getProductOfferingParamTableSelectorHTML(Form("ID")))
 
 
      
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
    	Service.Properties("PriceListId")= Clng(Request("PICKERIDS"))
  	end if
	end if

	if Service.Properties("PriceListId") <> -1 then
  	Dim objMTProductCatalog
  	Dim objMTPriceList
  	Set objMTProductCatalog = GetProductCatalogObject   
  	Set objMTPriceList = objMTProductCatalog.GetPriceList(Service.Properties("PriceListId"))
  	Service.Properties("PriceListName").Value =  objMTPriceList.Name
    Session("PriceListMappingBulk_DefaultPricelistName") = Service.Properties("PriceListId").Value    
    Session("PriceListMappingBulk_DefaultPricelistId") = Service.Properties("PriceListId").Value
	end if    
  
  If Clng(Form("NonSharedPLID")) = Service.Properties("PriceListId") Then
    Service.Properties("NonSharedPriceList").value = "1"
    Service.Properties("PriceListName").value = ""
  Else
    Service.Properties("NonSharedPriceList").value = "0"
  End If

  
  Form_Refresh = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

  dim bUpdatePriceListInformation
  dim bUpdateICBInformation
  bUpdatePriceListInformation = Service.Properties("UpdatePriceList")
  bUpdateICBInformation = Service.Properties("UpdateICB")

    Dim objMTProductCatalog, objPriceList
    'On Error Resume Next

    if Service.Properties("PriceListId")<>-1 then
      Session("PriceListMappingBulk_DefaultPricelistName") = Service.Properties("PriceListId").Value    
      Session("PriceListMappingBulk_DefaultPricelistId") = Service.Properties("PriceListId").Value
    end if
    
    Set objMTProductCatalog = GetProductCatalogObject
    
    dim idPriceList
    If bUpdatePriceListInformation then
      If Service.Properties("NonSharedPriceList").Value Then
        dim objProductOffering
        Set objProductOffering = objMTProductCatalog.GetProductOffering(CLng(Form("ID")))
        idPriceList = objProductOffering.NonSharedPriceListID
      Else
        idPriceList = Service.Properties("PriceListId")
      End if
    End if
    
    dim bCanICB
    if UCASE(Service.Properties("CanICB"))="TRUE" then
      bCanICB = true
    else
      bCanICB = false
    end if
    
    'response.write("paramtable_selected [" & request("paramtable_selected") & "]")
    'response.end
    
    dim arrParamTableList
    arrParamTableList = split(request("paramtable_selected"), ",")

    dim pi
    dim i
    for i = 0 to ubound(arrParamTableList)
      'response.write("ParamTable[" & i & "] [" & arrParamTableList(i) & "] ")
      dim arrPiPt,idPI, idParamTable
      arrPiPt = split(arrParamTableList(i),"~")
      idPI = arrPiPt(0)
      idParamTable = arrPiPt(1)
      
      Set pi = objMTProductCatalog.GetPriceableItem(idPI)
      Dim plm
      Set plm = pi.GetPriceListMapping( idParamTable )

      'response.write("Priceable Item[" & pi.Name & "]  Current Pricelist Id[" & plm.PriceListID & "]<BR>")

      if bUpdatePriceListInformation then
        plm.PriceListID = idPriceList
      end if
      
      if bUpdateICBInformation then
        plm.CanICB = bCanICB
      end if
      
      plm.Save
      
    next
 
  If(Err.Number)Then
    EventArg.Error.Save Err
    Err.Clear
    OK_Click = FALSE
  Else
    OK_Click = TRUE
  End If
END FUNCTION

function getProductOfferingParamTableSelectorHTML(idProductOffering)


dim objXML, objXSL, strPathXSL, strHTML
Set objXML = server.CreateObject("Microsoft.XMLDOM")
Set objXSL = server.CreateObject("Microsoft.XMLDOM")

dim strXML
strXML = mcm_GetProductOfferingXML(idProductOffering)

'strXML = "<?xml version=""1.0""?>" & vbCRLF & strXML

'response.write "<form><textarea cols='100' rows='40'>" & strXML & "</textarea></form>"
'response.end
'response.write "Done XML [" & Now & "]"

strPathXSL = server.MapPath(Application("APP_HTTP_PATH") & "\default\dialog\xsl\productoffering.param.checkbox.xsl")

'response.write ("Path is [" & strPathXSL & "]<BR>")
'response.end
Call objXML.LoadXML(strXML)


Call objXSL.Load(strPathXSL)
'Call objXSL.LoadXML(mdm_LocalizeString(objXSL.xml))

objXML.setProperty "SelectionLanguage", "XPath"
objXSL.setProperty "SelectionLanguage", "XPath"


getProductOfferingParamTableSelectorHTML = objXML.TransformNode(objXSL)

end function
%>

