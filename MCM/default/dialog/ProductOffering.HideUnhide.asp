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
Form.ErrorHandler   = TRUE
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
  
  FrameWork.Dictionary().Add "DeleteErrorMode", FALSE
	
  Form.Modal = TRUE   ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will not terminate the dialog
                      ' but do a last rendering/refresh.

  Form("PO_ID") = Request.QueryString("ID")
  Form("Hide") = CBool(Request.QueryString("Hide"))
  
  If Form("Hide") Then
    FrameWork.Dictionary().Add "HIDEORUNHIDE", FrameWork.GetDictionary("TEXT_HIDE") & " " & FrameWork.GetDictionary("TEXT_KEYTERM_PRODUCT_OFFERING")
    FrameWork.Dictionary().Add "HIDEORUNHIDE_CONFIRM", FrameWork.GetDictionary("TEXT_CONFIRM_HIDE_PRODUCT_OFFERING")
    Form.RouteTo        = FrameWork.GetDictionary("PRODUCT_OFFERING_LIST_DIALOG")
  Else
    FrameWork.Dictionary().Add "HIDEORUNHIDE", FrameWork.GetDictionary("TEXT_UNHIDE") & " " & FrameWork.GetDictionary("TEXT_KEYTERM_PRODUCT_OFFERING")  
    FrameWork.Dictionary().Add "HIDEORUNHIDE_CONFIRM", FrameWork.GetDictionary("TEXT_CONFIRM_UNHIDE_PRODUCT_OFFERING")
    Form.RouteTo        = FrameWork.GetDictionary("VIEW_HIDDEN_POS_DIALOG")
  End If
    
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
	Dim objParamTable
  Dim objMTProductCatalog, objProductOffering
  Set objMTProductCatalog = GetProductCatalogObject    
	
	On Error Resume Next

	Set objProductOffering = objMTProductCatalog.GetProductOffering(Form("PO_ID"))
  objProductOffering.Hidden = CBool(Form("Hide"))
  objProductOffering.Save
  
	If(Err.Number)Then
    FrameWork.Dictionary().Add "DeleteErrorMode", TRUE
		EventArg.Error.Save Err
		OK_Click = FALSE
		Err.Clear
	Else
        Response.Write "<script language='JavaScript'>"
        Response.Write "if (window.opener.top.MainContentIframe.LoadStoreWhenReady_ctl00_ContentPlaceHolder1_MTFilterGrid1) {"
        Response.Write "  window.opener.top.MainContentIframe.LoadStoreWhenReady_ctl00_ContentPlaceHolder1_MTFilterGrid1();"
        Response.Write "} else {"
        Response.Write "  window.opener.parent.location.href = '/MetraNet/MetraOffer/ProductOfferings/ProductOfferingsList.aspx'"
        Response.Write "}"
        Response.Write "window.close();"
        Response.Write "</script>"
        Response.End

		OK_Click = TRUE
	End If

END FUNCTION
%>



