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
<!-- #INCLUDE FILE="../lib/ScriptIncludes.html" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE
Form.RouteTo        = FrameWork.GetDictionary("PRICE_LIST_LIST_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form("CURRENT_PRICELIST_ID") = CLng(Request.QueryString("ID"))

    ' Save the id so we can use it on links in the page	
    mdm_GetDictionary().Add "CURRENT_PRICELIST_ID",Request.QueryString("ID")

    Form.Grids.Enabled = FALSE ' Every control is grayed
	Form_Initialize = Form_Refresh(EventArg)
END FUNCTION


' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : 
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean

    Dim objMTProductCatalog
    Set objMTProductCatalog = GetProductCatalogObject
	
    ' Find the PriceableItem and store it into the MDM COM Object
    Set COMObject.Instance = objMTProductCatalog.GetPriceList(Form("CURRENT_PRICELIST_ID")) ' We map the dialog with a COM Object not an MT Service
    COMObject.Properties.Enabled = FALSE ' Every control is grayed

    Form_Refresh = TRUE
    
END FUNCTION
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

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

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Currency_Select
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Sets currency code after selection
PRIVATE FUNCTION CurrencyChange_Click(EventArg) ' As Boolean

    On Error Resume Next
    If(Err.Number)Then
        EventArg.Error.Save Err
		CurrencyChange_Click = FALSE
        Err.Clear
    Else
		' Set currency to be COMObject.Properties("CURRENCYCODE").value
		CurrencyChange_Click = TRUE
    End If    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Edit_Click(EventArg) ' As Boolean
    Service.Properties.Enabled = Not Service.Properties.Enabled 
	Form.Grids.Enabled =     Service.Properties.Enabled 
    Edit_Click = TRUE
END FUNCTION
%>