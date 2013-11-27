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
<!-- #INCLUDE FILE="../../default/Lib/CReBillHelper.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/Adjustments.OverRideAble.Customization.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%

PRIVATE AdjustmentHelper
Set AdjustmentHelper        = New CAdjustmentHelper
AdjustmentHelper.BulkMode   = TRUE
AdjustmentHelper.ParentMode = FALSE

Form.Version = MDM_VERSION     ' Set the dialog version
Form.RouteTo = mam_GetDictionary("BULKADJUSTMENT_PVB_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Returns TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
On Error Resume Next
  Dim varRetVal
  
  Form_Initialize             = FALSE
  Form("SessionID")           = AdjustmentHelper.SelectedIDs 'mdm_UIValue("SessionID")
  Form("PriceAbleItemType")   = TransactionUIFinder.SelectedPriceAbleItemTypeID
  
  If Not ReBillHelper.Initialize(CStr(Form("PriceAbleItemType")),Form("SessionID")) Then
   CheckAndWriteError
  End If
  
  Service.Properties("RebilledTransactionInfo").Value    = Form("SessionID")

  ' Global Mecanism To Call a Custom Function
  Form("PriceAbleItemParentFQN") = mdm_MakeName(FrameWork.GetPricteAbleItemTypeFQN(TransactionUIFinder.SelectedPriceAbleItemTypeID))
  mdm_CallFunctionIfExist Form("PriceAbleItemParentFQN") & "_Adjustment_SelectColumns(Form.Grids(""TransactionInfoGrid""))" , varRetVal
  
  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation  
  mam_IncludeCalendar

  Form_Initialize = Form_Refresh(EventArg)
END FUNCTION

PUBLIC FUNCTION Form_Refresh(EventArg)
    ReBillHelper.GenerateUI
    Form_Refresh = TRUE
END FUNCTION

PUBLIC FUNCTION ActionType_Click(EventArg) ' As Boolean
    ActionType_Click = TRUE
END FUNCTION

PUBLIC FUNCTION Cancel_Click(EventArg) ' As Boolean
    Form.RouteTo = FrameWork.Dictionary.Item("BULKADJUSTMENT_PVB_DIALOG").Value
    Cancel_Click = TRUE
END FUNCTION

 
  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click()
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : 
' IMPLEMENT THE SAVE ADJUSTMENT
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    Ok_Click = FALSE
    Session("BATCH_ERROR_RETURN_PAGE") = FrameWork.Dictionary.Item("BULKADJUSTMENT_PVB_DIALOG").Value 
    OK_Click = ReBillHelper.SaveAll(EventArg)   

END FUNCTION

%>
