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
' DIALOG	    : RateSchedule Edit Window
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
FOrm.ErrorHandler   = TRUE
Form.RouteTo        = FrameWork.GetDictionary("RATES_PRICELIST_LIST_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject
	
	Set COMObject.Instance = objMTProductCatalog.GetPricelist(CLng(Request.QueryString("ID")))
	If Not IsValidObject(COMObject.Instance) Then
      Response.write FrameWork.GetDictionary("ERROR_ITEM_NOT_FOUND") & Request.QueryString("ID")
      Response.end
  End If
	
	COMObject.Properties("CurrencyCode").Enabled = FALSE
	COMObject.Properties("CurrencyCode").SetPropertyType "ENUM","Global/SystemCurrencies","SystemCurrencies"
		
  Form.Modal = TRUE   ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will not terminate the dialog
                      ' but do a last rendering/refresh.
  'SECENG: Fixing problems with output encoding  
  Service.Properties.Add "pl_edit_name", "String",  1024, FALSE, TRUE
  Service.Properties("pl_edit_name") = SafeForHtml(COMObject.Instance.Name)
      
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
  On Error Resume Next
	
	'This is a RateSchedule, so we will call SaveWithRules
	call COMObject.Instance.Save
    
	If (Err.Number) Then
	  EventArg.Error.Save Err
	  OK_Click = FALSE
	  Err.Clear
  Else
	  OK_Click = TRUE
  End If    
END FUNCTION
%>
