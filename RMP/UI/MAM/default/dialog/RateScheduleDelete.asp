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
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler   = TRUE
Form.RouteTo        = "/mam/default/dialog/Rates.RateSchedule.List.asp"

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
  FrameWork.Dictionary().Add "END_DATE_AS_STRING", GetEffectiveDateTextByType(COMObject.Properties("EffectiveDate__EndDateType").Value, COMObject.Properties("EffectiveDate__EndDate").Value, COMObject.Properties("EffectiveDate__EndOffset").Value, TRUE)
  
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


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: GetEffectiveDateTextByType
' PARAMETERS		:
' DESCRIPTION 	: 
' RETURNS			  :
PUBLIC FUNCTION GetEffectiveDateTextByType(a_type, dt_date, int_offset, bStart)
  Dim strText
  strText = ""
  
  Select Case Clng(a_type)
  Case PCDATE_TYPE_NULL
    if bStart then
      strText = strText & FrameWork.GetDictionary("TEXT_NULL_START_DATE_TYPE")
    else
  	  strText = strText & FrameWork.GetDictionary("TEXT_NULL_END_DATE_TYPE")
    end if
  Case PCDATE_TYPE_ABSOLUTE
  	strText = strText & FrameWork.GetDictionary("TEXT_ABSOLUTE_DATE_TYPE") & " " & dt_date
  Case PCDATE_TYPE_SUBSCRIPTION
  	strText = strText & CStr(int_offset) & " " & FrameWork.GetDictionary("TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE")
  Case PCDATE_TYPE_BILLCYCLE
  	strText = strText & FrameWork.GetDictionary("TEXT_BILLINGCYCLE_DATE_TYPE") & " " & dt_date
  End Select
  
  GetEffectiveDateTextByType = strText
  
END FUNCTION
%>



