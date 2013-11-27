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
' AUTHOR	    : F.torres
' VERSION	    : 1.0
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>

<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE FILE="../lib/CMCMAdjustmentHelper.asp" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler   = TRUE
Form.RouteTo        = FrameWork.GetDictionary("RATES_PRICELIST_LIST_DIALOG")
Form.Modal          = TRUE

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form("AdjustmentTemplateID") = mdm_UIValue("AdjustmentTemplateID") ' if passed we must return it to the caller
   
  Form("New") = UCase(mdm_UIValue("New")) = "TRUE"
  
  If Form("New") Then
      Form("ID") = -1
      AdjustmentTemplateHelper.CreateAGlobalBlankNewReasonCode      
  Else
      Form("ID") = mdm_UIValue("ID")
      AdjustmentTemplateHelper.LoadReasonCode Form("ID")      
  End If
  Set COMObject.Instance  = AdjustmentTemplateHelper.CurrentReasonCodeInstance
  
  '
  ' Remove all the required unused fields
  '  
  Dim MSIXProperty
  For Each MSIXProperty In COMObject.Properties  
      MSIXProperty.Required = FALSE
  Next
  
  COMObject.Properties("Name").Required        = TRUE
  'COMObject.Properties("DisplayName").Required = TRUE
  COMObject.Properties("Description").Required = FALSE

	If Not Form("New") Then
	  COMObject.Properties("Name").Enabled = FALSE
	End If
  'SECENG: Fixing problems with output encoding  
  Service.Properties.Add "adjReason_name", "String",  1024, FALSE, TRUE
  Service.Properties("adjReason_name") = SafeForHtml(COMObject.Instance.Name)
  
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
  AdjustmentTemplateHelper.CurrentReasonCodeInstance.Save
    
	If (Err.Number) Then
	  EventArg.Error.Save Err
	  OK_Click = FALSE
	  Err.Clear
  Else
    ' Pass the new ReasonCode id to the parent dialog
    Form("Parameters") = "IDs|" &   AdjustmentTemplateHelper.CurrentReasonCodeInstance.ID & ";NewReasonCodeMode|TRUE;AdjustmentTemplateID|" & Form("AdjustmentTemplateID")
	  OK_Click = TRUE
  End If    
END FUNCTION
%>
