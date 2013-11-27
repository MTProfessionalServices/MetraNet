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
Form.RouteTo        = FrameWork.GetDictionary("RATES_RATESCHEDULE_LIST_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Dim objMTProductCatalog, objParamTable
  Set objMTProductCatalog = GetProductCatalogObject    
	
  Form.Modal = TRUE   ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will not terminate the dialog
                      ' but do a last rendering/refresh.

	Form("RS_ID") = Request.QueryString("RS_ID")
	Form("PT_ID") = Request.QueryString("PT_ID")								
  FrameWork.Dictionary().Add "RSDeleteErrorMode", FALSE

	Set objParamTable = objMTProductCatalog.GetParamTableDefinition(Form("PT_ID"))
  Set COMObject.Instance = objParamTable.GetRateSchedule(Form("RS_ID"))
  
  FrameWork.Dictionary().Add "START_DATE_AS_STRING", GetEffectiveDateTextByType(COMObject.Properties("EffectiveDate__StartDateType").Value, COMObject.Properties("EffectiveDate__StartDate").Value, COMObject.Properties("EffectiveDate__StartOffset").Value, TRUE)
  FrameWork.Dictionary().Add "END_DATE_AS_STRING", GetEffectiveDateTextByType(COMObject.Properties("EffectiveDate__EndDateType").Value, COMObject.Properties("EffectiveDate__EndDate").Value, COMObject.Properties("EffectiveDate__EndOffset").Value, FALSE)
  
  COMObject.Properties.Enabled              = FALSE ' Every control is grayed  
  
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
	Dim objParamTable
  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject    
	
	On Error Resume Next
	Set objParamTable = objMTProductCatalog.GetParamTableDefinition(Form("PT_ID"))
	objParamTable.RemoveRateSchedule(Form("RS_ID"))

	If(Err.Number)Then
    FrameWork.Dictionary().Add "RSDeleteErrorMode", TRUE
		EventArg.Error.Save Err
		OK_Click = FALSE
		Err.Clear
	Else
		OK_Click = TRUE
	End If

END FUNCTION
%>



