<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
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
' MetraTech Dialog Manager Framework ASP Dialog Template
' 
' DIALOG	:
' DESCRIPTION	:
' AUTHOR	:
' VERSION	:
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CBatchError.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CAdjustmentHelper.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CTransactionUIFinder.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%

Form.Version = MDM_VERSION     ' Set the dialog version

Form.RouteTo = mam_GetDictionary("ADJUSTMENT_PVB_DIALOG")


PRIVATE AdjustmentHelper
Set AdjustmentHelper        = New CAdjustmentHelper

mdm_Main                                            ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION 	:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Dim s, R
  
  Form("DialogType") = mdm_UIValue("DialogType")
  Form("Message")    = mdm_UIValue("Message")
  Service.Clear 	' Set all the property values of the service to empty.
  Service.Properties.Add "Message", "String"  , 0, False, ""
  
                               
  If Len(Form("Message")) Then  
      s = Form("Message")
  Else
      Set R = AdjustmentHelper.SaveWarningRowset 
      if IsValidObject(R) then
        R.MoveFirst 
        Do While Not R.EOF
          s = s & r.Value(0) & "-" & r.Value(1) & "<br>"
          R.MoveNext
        Loop
      end if
  End If
  
  Service.Properties("message").Value     = s
  Service.Properties("message").Caption   = " "
	Form_Initialize = TRUE
END FUNCTION

PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean

  'Form.Modal = TRUE ' Use the modal mecanism to force the current dialog to be rendered
  'AdjustmentHelper.SetJavaScriptInitialize Form("DialogType")
  If(Form("DialogType").Value = "BulkAdjustment") Then
	  Form.RouteTo = mam_GetDictionary("BULKADJUSTMENT_PVB_DIALOG")	
   End If 
  OK_Click = TRUE
END FUNCTION

%>

