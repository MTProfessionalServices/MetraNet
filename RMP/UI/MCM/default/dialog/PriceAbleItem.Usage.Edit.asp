<% 
' ---------------------------------------------------------------------------------------------------------
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
' ---------------------------------------------------------------------------------------------------------
'
' MetraTech Dialog Manager Demo
' 
' DIALOG	    : MCM Dialog
' DESCRIPTION	: 
' AUTHOR	    : F.Torres, K.Boucher
' VERSION	    : 2.0
'
' ---------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE
Form.RouteTo        = FrameWork.GetDictionary("SERVICE_CHARGES_USAGE_LIST")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Dim objMTProductCatalog  
    Set objMTProductCatalog = GetProductCatalogObject
    
    Form.Modal = TRUE ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will no terminate the dialog
                      ' but do a last rendering/refresh. The client dialog must set the property         
                      ' Form.JavaScriptInitialize = "window.close();" & VBNEWLINE, see OK_CLICK Event in this file.
    
    ' Find the PriceableItem and store it into the MDM COM Object
	FORM("POBased") = Request.QueryString("POBased")
	
	Form("KIND") = Request.QueryString("KIND")
	if UCase(Form("KIND")) = Cstr(PI_TYPE_USAGE_AGGREGATE) Then
	    FrameWork.Dictionary().Add "ShowBillingCycle", TRUE	
	ELSE
		    FrameWork.Dictionary().Add "ShowBillingCycle",FALSE
	END if	
	
	' Because we use this dialog for usage charge kind=15 (aggregate) and kind=10 (usage charge)
	' we must clear the MSIX Properties each time else we have compound properties not found
	' usage charge does not have a cycle object for example.
	If(IsValidObject(COMObject.Instance))Then
		COMObject.Properties.Clear
	End If	
	
    Set COMObject.Instance = objMTProductCatalog.GetPriceableItem(CLng(Request.QueryString("ID"))) ' We map the dialog with a COM Object not an MT Service
    
   
    
    If Not IsValidObject(COMObject.Instance) Then
        Response.write FrameWork.GetDictionary("ERROR_ITEM_NOT_FOUND") & Request.QueryString("ID")
        Response.end
    End If
    
  FORM("Kind") = COMObject.Properties("Kind")
	
	If UCase(Form("KIND")) = Cstr(PI_TYPE_USAGE_AGGREGATE) Then
		ProductCatalogBillingCycle.Form_Initialize Form
  Else
    ProductCatalogBillingCycle.ClearInsertTag Form
	End If
    
    ' Create and define the Extended Properties Grid
    Form.Grids.Add "ExtendedProperties", "Extended Properties"
    Set Form.Grids("ExtendedProperties").MTProperties(MTPROPERTY_EXTENDED) = COMObject.Instance.Properties
    Form.Grids("ExtendedProperties").Properties.ClearSelection
    Form.Grids("ExtendedProperties").Properties("Name").Selected    = 1
    Form.Grids("ExtendedProperties").Properties("Value").Selected   = 2
    
    Form.Grids("ExtendedProperties").Properties("Name").Caption 		= FrameWork.GetDictionary("TEXT_COLUMN_NAME")
    Form.Grids("ExtendedProperties").Properties("Value").Caption 	  = FrameWork.GetDictionary("TEXT_COLUMN_VALUE")

    Form.Grids("ExtendedProperties").ShowHeaders=False
    Form.Grids("ExtendedProperties").DefaultCellClass     = "captionEW"
    Form.Grids("ExtendedProperties").DefaultCellClassAlt  = "captionEW"    

	Form_Initialize = TRUE
	ProductCatalogHelper.CheckAttributesForUI COMObject, COMObject.Instance, Form("POBased")="TRUE" , Empty  
END FUNCTION


' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    Dim s

   	Ok_Click = FALSE

	if UCase(Form("KIND")) = Cstr(PI_TYPE_USAGE_AGGREGATE) Then
  		If(Not ProductCatalogBillingCycle.UpdateProperties())Then Exit Function
	END if

    On Error Resume Next
    COMObject.Instance.Save
    If(Err.Number)Then
    
        EventArg.Error.Save Err
        OK_Click = FALSE
        Err.Clear
    Else
        OK_Click = TRUE        
    End If
END FUNCTION




%>


