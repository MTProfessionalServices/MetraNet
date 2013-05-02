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
<!-- #INCLUDE FILE="../../default/lib/MamCreditLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CBatchError.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CAdjustmentHelper.asp" -->
<!-- #INCLUDE FILE="../../default/Lib/CTransactionUIFinder.asp" -->

<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
' Mandatory Constants
Form.RouteTo			                = mam_GetDictionary("ORPHAN_ADJUSTMENT_MANAGE_DIALOG")

PRIVATE AdjustmentHelper
Set AdjustmentHelper = New CAdjustmentHelper

mdm_Main ' Invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION 	:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

	  Service.Properties.Clear
    
    Service.Properties.Add "Description", "String", 255, TRUE, Empty
    Service.Properties("Description").Caption = FrameWork.Dictionary.Item("TEXT_DESCRIPTION").Value
    
    Form.HelpFile                                   = "Orphan.Manage.hlp.htm" ' Set the help file name    
    
	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Ok
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    Dim TransactionSet, WarningRowset
    
    Ok_Click = FALSE
  
    
    On Error Resume Next
    Set TransactionSet = FrameWork.AdjustmentCatalog.CreateOrphanAdjustments(AdjustmentHelper.OrphanSelected)
    If Err.Number Then EventArg.Error.Save Err : Exit Function
    
    TransactionSet.Description = Service.Properties("Description").Value
    If Err.Number Then EventArg.Error.Save Err : Exit Function

    Set WarningRowset  = TransactionSet.ApproveAndSave(nothing)    
    If Err.Number Then EventArg.Error.Save Err : Exit Function
    
    On Error Goto 0
    
    AdjustmentHelper.PopulateWarningRowsetInSession WarningRowset
    
    If WarningRowset.RecordCount>0 Then
    
        Form.RouteTo = FrameWork.Dictionary().Item("BATCH_ERROR_LIST_FILTER_OFF_NO_BACK_DIALOG").Value
    End If    
    'strMessage   = FrameWork.Dictionary().Item("TEXT_ORPHAN_ADJUSTMENT_WERE_APPROVED_DENIED_AS_MISC_ADJUSTMENT").Value
    'strMessage   = PreProcess(strMessage,Array("APPROVED_COUNT",lngApprovedTransaction,"PENDING_COUNT",lngPendingTransaction))
    'Form.RouteTo = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_CONFIRM_ADD_CHARGE_TITLE"), strMessage, form.routeto)
    
    Ok_Click     = TRUE    
END FUNCTION
    
PRIVATE FUNCTION Meter(EventArg, ByRef strStatus)    
    
    On Error Resume Next

    Dim objOutputSession, booOk
    
    Meter = FALSE
    booOK = Service.Meter(True,objOutPutSession)
    If(CBool(Err.Number = 0)) then    
        On Error Goto 0
        strStatus = objOutPutSession.GetProperty("Status") 'Get the output parameter
        Meter     = TRUE
    Else
        'Service.Properties("_Amount").Operation "*",-1 ' Support DECIMAL
        EventArg.Error.Save Err
    End If
    Err.Clear
END FUNCTION

'        'If pending, display a message to the user
 '       if UCase(strStatus) = UCase("Pending") then
  '        Form.RouteTo      = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_ISSUE_CREDIT_TITLE"), mam_GetDictionary("TEXT_ISSUE_MISC_ADJUSTEMENT_CONFIRM_PENDING"), Form.RouteTo)        
   '       OK_Click          = true
    '    else
     '     Service.Properties("_Amount").Operation "*",-1 ' Support DECIMAL
      '    Form.RouteTo      = mam_ConfirmDialogEncodeAllURL(mam_GetDictionary("TEXT_ISSUE_MISC_ADJUSTEMENT_DIALOG"), mam_GetDictionary("TEXT_ISSUE_MISC_ADJUSTEMENT_CONFIRM"), Form.RouteTo)
       '   OK_Click          = TRUE
        'end if



        'UserNamePayer   
'AdjustmentTemplateDisplayName   
'AdjustmentInstanceDisplayName   
'ReasonCodeName   
'ReasonCodeDescription   
'ReasonCodeDisplayName   
'id_adj_trx   
'id_sess   
'id_parent_sess   
'id_reason_code   
'id_acc_creator   
'id_acc_payer   
'c_status   
'n_adjustmenttype   
'dt_crt   
'dt_modified   
'id_aj_template   
'id_aj_instance   
'id_aj_type   
'id_usage_interval   
'AdjustmentAmount 
%>

