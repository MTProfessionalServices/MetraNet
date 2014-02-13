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

  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject    
	
  Form.Modal = TRUE   ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will not terminate the dialog
                      ' but do a last rendering/refresh.

	Form("PO_ID") = Request.QueryString("ID")

  Set COMObject.Instance = objMTProductCatalog.GetProductOffering(Form("PO_ID"))
  COMObject.Properties.Enabled              = FALSE ' Every control is grayed

  FrameWork.Dictionary().Add "PODeleteErrorMode", FALSE				
  
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  Dim objMTProductCatalog
  
	Set objMTProductCatalog = GetProductCatalogObject    
	
	On Error Resume Next
	objMTProductCatalog.RemoveProductOffering(Form("PO_ID"))
			
	If(Err.Number)Then
    FrameWork.Dictionary().Add "PODeleteErrorMode", TRUE
		EventArg.Error.Save Err
		OK_Click = FALSE
		Err.Clear
	Else
    response.write "<script language='JavaScript1.2'>"
    'response.write "alert('rudi');stop;"
    '//function NavigateToPreviousSearchResults()
'//{
'    if ((parent.document.all("ProductOfferingView")) && (parent.document.all("ProductOfferingView").all("ProductOfferingNav")))
'      parent.document.all("ProductOfferingView").all("ProductOfferingNav").rows = '*,0';
'    parent.frames["ProductOfferingMain"].location = "ProductOffering.List.asp?NextPage=/mcm/default/dialog/ProductOffering.ViewEdit.Frame.asp&amp;Title=TEXT_KEYTERM_PRODUCT_OFFERINGS&amp;LinkColumnMode=TRUE&amp;mdmAction=REFRESH";
'}
    'response.write "opener.parent.document.all(""ProductOfferingView"").all(""ProductOfferingSelected"").NavigateToPreviousSearchResults();"
    response.write "opener.parent.ProductOfferingSelected.NavigateToPreviousSearchResults();"
    response.write "window.close();"
    response.write "</script>"
    response.end
    
		OK_Click = TRUE
	End If

END FUNCTION
%>