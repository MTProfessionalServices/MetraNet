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
' MetraTech Dialog Manager Page
' 
' DIALOG	    : RateSchedule Import Window
' DESCRIPTION	: 
' AUTHOR	    : Fabricio Pettena	
' VERSION	    : 1.0
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>

<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = FALSE
Form.RouteTo        = FrameWork.GetDictionary("RATES_PRICELIST_LIST_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Dim objMTProductCatalog, objParamTable, objRateSchedule, objPriceList, objProductOffering, objPriceableItem
  Set objMTProductCatalog = GetProductCatalogObject

  Service.Properties.Add "ParamTable", "String", 256, FALSE, ""
  Service.Properties.Add "PriceListOrProductOffering", "String", 256, FALSE, ""
  Service.Properties.Add "PriceListType", "String", 256, FALSE, ""
  Service.Properties.Add "StartDate", "String", 256, FALSE, ""
  Service.Properties.Add "EndDate", "String", 256, FALSE, ""
  Service.Properties.Add "PriceableItem", "String", 256, FALSE, ""
  Service.Properties.Add "Description", "String", 256, FALSE, ""
  Service.Properties.Add "Numberofrules", MSIXDEF_TYPE_INT32, 0, FALSE, 0  
  
  if len(Request("PT_ID")) then
    Form("PT_ID") = Request("PT_ID")
  end if
      
  Set objParamTable = objMTProductCatalog.GetParamTableDefinition(Form("PT_ID"))

  Dim strPTName
  strPTName = objParamTable.DisplayName
  if len("" & strPTName) = 0 then
    strPTName = objParamTable.Name
  end if
  Service.Properties("ParamTable") = strPTName

  FrameWork.Dictionary().Add "PT_ID", objParamTable.ID
  
  'Let's see if the user has chosen a rate schedule
  if Len(request.queryString("PickerIDs")) Then
    FrameWork.Dictionary().Add "SHOW_PRICELIST_INPUT", TRUE
    Form("SourceRschedID") = CLng(request.queryString("PickerIDs"))
    call ConfigureDialog(Form("SourceRschedID"), objMTProductCatalog, objParamTable)
  else
    FrameWork.Dictionary().Add "SHOW_PRICELIST_INPUT", FALSE
    Form("SourceRschedID") = ""
  end if
  
  Form.Modal = TRUE   ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will not terminate the dialog
                      ' but do a last rendering/refresh.
      
  Form_Initialize = TRUE
END FUNCTION

PRIVATE FUNCTION ConfigureDialog(lngSourceRschedID, objMTProductCatalog, objParamTable)
  
  Dim objPriceList, objRateSchedule, objEffDate, objPriceableItem
  Set objRateSchedule = objParamTable.GetRateSchedule(lngSourceRschedID)
  Set objPriceList = objMTProductCatalog.GetPriceList(objRateSchedule.PriceListID)

  If objPriceList.Type = PRICELIST_TYPE_REGULAR Then
    Service.Properties("PriceListType") = FrameWork.GetDictionary("TEXT_SHARED")
    Service.Properties("PriceListOrProductOffering") = objPriceList.Name
    FrameWork.Dictionary().Add "PRICELIST_TYPE_LABEL", FrameWork.GetDictionary("TEXT_KEYTERM_PRICE_LIST")
  Elseif objPriceList.Type = PRICELIST_TYPE_PO Then
    Service.Properties("PriceListType") = FrameWork.GetDictionary("TEXT_NONSHARED")
    Service.Properties("PriceListOrProductOffering") = objPriceList.GetOwnerProductOffering().Name
    FrameWork.Dictionary().Add "PRICELIST_TYPE_LABEL", FrameWork.GetDictionary("TEXT_KEYTERM_PRODUCT_OFFERING")        
  End If
  
  Set objEffDate =  objRateSchedule.EffectiveDate
  Service.Properties("StartDate") = GetEffectiveDateTextByType(objEffDate.StartDateType, objEffDate.StartDate, objEffDate.StartOffset, true)
  Service.Properties("EndDate") = GetEffectiveDateTextByType(objEffDate.EndDateType, objEffDate.EndDate, objEffDate.EndOffset, false)
  
  Service.Properties("Description") = objRateSchedule.Description
  
  Set objPriceableItem = objMTProductCatalog.GetPriceableItem(objRateSchedule.TemplateID)
  Service.Properties("PriceableItem") = objPriceableItem.Name
  
  Service.Properties("Numberofrules") = objRateSchedule.Ruleset.Count
  
  ConfigureDialog = TRUE
END FUNCTION




' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  On Error Resume Next
  
  If Clng(Form("SourceRschedID")) = 0 Then
	  EventArg.Error.Number = COMObject.Tools.MakeItUserVisibleMTCOMError(1005)
   	EventArg.Error.Description = FrameWork.GetDictionary("MCM_ERROR_1005")
   	OK_Click = FALSE
   	Exit Function
  End If
  
  Form("Parameters") = "PickerIDs|" & Form("SourceRschedID")
    
	If (Err.Number) Then
	  EventArg.Error.Save Err
	  OK_Click = FALSE
	  Err.Clear
  Else
	  OK_Click = TRUE
  End If    
END FUNCTION
%>
