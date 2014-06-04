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
<!-- #INCLUDE FILE="../lib/CMCMAdjustmentHelper.asp" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler   = TRUE
Form.Modal          = TRUE

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form("AdjustmentInstanceID") = mdm_UIValue("AdjustmentInstanceID")  
  
  COMObject.Properties.Clear  
  Set COMObject.Instance  = AdjustmentTemplateHelper.GetAdjustmentInstanceFromID(Form("AdjustmentInstanceID"))
  '
  ' Remove all the required unused fields
  '  
  Dim MSIXProperty
  For Each MSIXProperty In COMObject.Properties  
      MSIXProperty.Required = FALSE
  Next
  Form_Initialize = TRUE
END FUNCTION

PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    On Error Resume Next
    Dim displayName
        For each displayName In COMObject.Instance.DisplayNames
                if displayName.LanguageCode = "US" And displayName.Value <> "" Then COMObject.Instance.DisplayName = displayName.Value End If  
        Next
    AdjustmentTemplateHelper.Instance.Save
    If(Err.Number)Then
        
        EventArg.Error.Save Err
        OK_Click = FALSE
        Err.Clear
    Else
        OK_Click = TRUE
    End If 
END FUNCTION

%>

