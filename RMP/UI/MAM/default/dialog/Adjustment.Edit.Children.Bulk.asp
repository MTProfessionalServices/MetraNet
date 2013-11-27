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
' DIALOG	    :
' DESCRIPTION	:
' AUTHOR	    :
' VERSION	    :
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

PRIVATE AdjustmentHelper
Set AdjustmentHelper        = New CAdjustmentHelper
AdjustmentHelper.BulkMode   = TRUE
AdjustmentHelper.ParentMode = FALSE

Form.Version = MDM_VERSION     ' Set the dialog version
Form.RouteTo = mam_GetDictionary("ADJUSTMENT_PVB_DIALOG")



mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form("SessionID")           = mdm_UIValue("SessionID")
  Form("PITemplate")          = mdm_UIValue("PITemplate")
  Form("PITemplateChildren")  = mdm_UIValue("PITemplateChildren")
  Form("ChildType")           = mdm_UIValue("ChildType")
  Form("ViewId")              = mdm_UIValue("ViewId")
  
  If(Not AdjustmentHelper.FindTransactionInRowset(Form("SessionID")))Then
      Form_Initialize = FALSE
      Exit Function
  End If
  
  If Not AdjustmentHelper.LoadAdjustmentTypes(Form("PITemplateChildren"),Form("SessionID"),Service) Then
      Form_Initialize = FALSE
      Exit Function
  End If
    
  If Not AdjType_Click(EventArg) Then Exit Function
  If Not Form_Refresh(EventArg)  Then Exit Function
  
  Dim strMessage
  If AdjustmentHelper.CheckIfTransactionHasAlreadyAdjustment(Form("ViewId"), Form("SessionID"),strMessage) Then
      Service.Properties("UserWarningMessage").Value = strMessage
  End If
  
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
  
  mam_IncludeCalendar
  
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    :
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : 
PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean
  Form_Refresh = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click()
' PARAMETERS		  :
' DESCRIPTION 		: ' RETURNS		      : 
' IMPLEMENT THE SAVE ADJUSTMENT
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    Ok_Click = FALSE
    
    If(Not AdjustmentHelper.Save(EventArg))Then Exit Function
    
    AdjustmentHelper.SetRouteToForConfirmDialog "Bulk",FrameWork.Dictionary.Item("TEXT_ADJUSTMENT(s)_HAS_BEEN_APPROVED").Value
    
    OK_Click                  = TRUE      
END FUNCTION

PRIVATE FUNCTION Cancel_Click(EventArg) ' As Boolean

  Form.Modal   = FALSE
  Cancel_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : AdjType_Click
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : 
PUBLIC FUNCTION AdjType_Click(EventArg)

    AdjustmentHelper.SelectAdjustmentType(Service.Properties("AdjType").Value)
    AdjType_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : butCompute_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      :
PRIVATE FUNCTION butCompute_Click(EventArg) ' As Boolean

    butCompute_Click = FALSE

    If (Service.RequiredFieldsOK(EventArg.Error)) Then ' Check to see if all the required field are set

        AdjustmentHelper.CalculateAndUpdateServiceProperties
        
        If AdjustmentHelper.WarningsCounter Then
        
              Form.JavaScriptInitialize = "window.open('[BATCH_ERROR_LIST_DIALOG]&WarningMode=TRUE&Close=TRUE&FilterOff=TRUE&PopUpWindowMode=TRUE','','height=300,width=570,resizable=yes,scrollbars=yes,status=yes');"
              Form.JavaScriptInitialize = FrameWork.Dictionary.PreProcess(Form.JavaScriptInitialize)
        End If
        butCompute_Click = TRUE
    End If
END FUNCTION

PRIVATE FUNCTION butViewDetails_Click(EventArg) ' As Boolean

    butViewDetails_Click = FALSE
    
    If AdjustmentHelper.Calculated Then
    
        Form.JavaScriptInitialize = FrameWork.Dictionary.PreProcess("window.open('[ADJUSTMENT_VIEW_OUTPUT_DETAILS_DIALOG]','','height=300,width=1000,resizable=yes,scrollbars=yes,status=yes');")
        butViewDetails_Click = TRUE
    Else
        AdjustmentHelper.NotReadyToBeSave EventArg       
    End If    
END FUNCTION

%>

