<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: BatchManagement.ViewEdit.asp$
' 
'  Copyright 1998-2003 by MetraTech Corporation
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
'  Created by: Rudi
' 
'  $Date: 11/14/2002 7:18:18 PM$
'  $Author: Rudi Perkins$
'  $Revision: 10$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

' Mandatory
Form.RouteTo			              = mom_GetDictionary("BATCH_MANAGEMENT_LIST_DIALOG") & "?MDMAction=" & MDM_ACTION_REFRESH
Form.ErrorHandler               = TRUE
mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

  Form("BatchEncodedId") = request.querystring("BatchEncodedId")
  Form("BatchTableId") = request.querystring("ID")


	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
                  
  Service.Properties.Add "BatchTableId"     , "string", 10, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchId"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchName"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchDisplayName"      , "string", 767, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchNamespace"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchStatus"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchCompletedCount"      , "int32", 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchFailedCount"      , "int32", 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchDeletedCount"      , "int32", 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchExpectedCount"      , "int32", 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
 
  Service.Properties.Add "BatchExpectedMessage"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchDifferenceMessage"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
 
  Service.Properties.Add "BatchSource"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchSequence"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchCreatedDateTime"      , MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchFirstDateTime"      , MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BatchRecentDateTime"      , MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE

  Service.Properties.Add "METERINGSTATISTICS_HTML_LINK"      , "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE  
  Service.Properties.Add "FAILEDTRANSACTIONS_HTML_LINK"      , "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE  
  Service.Properties.Add "AUDITHISTORY_HTML"      , "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ACTION_HTML"      , "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BACKOUTRERUN_HISTORY_HTML"      , "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE

	Form_Initialize = form_Refresh(EventArg)
END FUNCTION

FUNCTION form_Refresh(EventArg)

  dim rowset, sQuery
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\mom"
  
  if len(Form("BatchTableId"))>0 then
    rowset.SetQueryTag("__GET_BATCH_MANANAGEMENT_BATCH_INFORMATION_BY_BATCH_TABLE_ID__")  
    rowset.AddParam "%%ID_BATCH_TABLE%%", Clng(Form("BatchTableId"))

  else
    if len(Form("BatchEncodedId"))>0 then
      rowset.SetQueryTag("__GET_BATCH_MANANAGEMENT_BATCH_INFORMATION_BY_BATCH_ID_ENCODED__")  
      rowset.AddParam "%%ID_BATCH_ENCODED%%", Form("BatchEncodedId")
    else
      '// Error
    end if
  end if
  
	rowset.Execute
    
  Service.Properties("BatchTableId").Value       = rowset.value("BatchTableId")
  Service.Properties("BatchId").Value       = rowset.value("BatchId")
  Service.Properties("BatchName").Value       = rowset.value("Name")
  Service.Properties("BatchDisplayName").Value = rowset.value("Namespace") & "\" & rowset.value("Name")
  if len(rowset.value("Sequence"))>0 then
   Service.Properties("BatchDisplayName").Value = Service.Properties("BatchDisplayName").Value & "\" & rowset.value("Sequence")
  end if
  Service.Properties("BatchNamespace").Value       = rowset.value("Namespace")  
  Service.Properties("BatchStatus").Value       = rowset.value("Status")
  Service.Properties("BatchCompletedCount").Value       = rowset.value("Completed")
  Service.Properties("BatchFailedCount").Value       = rowset.value("Failed")
  Service.Properties("BatchDeletedCount").Value       = rowset.value("Dismissed")
  Service.Properties("BatchExpectedCount").Value       = rowset.value("Expected")
  
  '//Calculate difference in what was expected
  if Service.Properties("BatchExpectedCount").Value = 0 then
    Service.Properties("BatchExpectedMessage").Value       = "N/A"
    Service.Properties("BatchDifferenceMessage").Value       = "N/A"
  else
    Service.Properties("BatchExpectedMessage").Value       = rowset.value("Expected")
    Service.Properties("BatchDifferenceMessage").Value       = rowset.value("Expected") - rowset.value("Completed") - rowset.value("Failed") - rowset.value("Dismissed")
  end if

  Service.Properties("BatchSource").Value       = rowset.value("Source")
  Service.Properties("BatchSequence").Value       = rowset.value("Sequence")
  Service.Properties("BatchCreatedDateTime").Value       = rowset.value("Creation")
  Service.Properties("BatchCreatedDateTime").Format          = mom_GetDictionary("DATE_TIME_FORMAT")
  Service.Properties("BatchFirstDateTime").Value       = rowset.value("First")
  Service.Properties("BatchFirstDateTime").Format          = mom_GetDictionary("DATE_TIME_FORMAT")
  Service.Properties("BatchRecentDateTime").Value       = rowset.value("Recent")
  Service.Properties("BatchRecentDateTime").Format          = mom_GetDictionary("DATE_TIME_FORMAT")
  
  Service.Properties("METERINGSTATISTICS_HTML_LINK") = "BatchManagement.Statistics.Frame.asp?Title=" & server.urlencode(Service.Properties("BatchDisplayName").Value) & "&BatchId=" &  Server.UrlEncode(Service.Properties("BatchId").Value)

  'if rowset.value("Completed")>0 then
  '  Service.Properties("METERINGSTATISTICS_HTML_LINK") = "<A href=""#"" onclick=""window.open('BatchManagement.Statistics.Frame.asp?Title=" & server.urlencode(Service.Properties("BatchDisplayName").Value) & "&BatchId=" &  Server.UrlEncode(Service.Properties("BatchId").Value) & " ','', 'height=700,width=1000, resizable=yes, scrollbars=yes, status=yes');"">View Statistics</button><BR>"
  'else
  '  Service.Properties("METERINGSTATISTICS_HTML_LINK") = ""
  'end if

  if rowset.value("Failed")>0 then
    'Service.Properties("FAILEDTRANSACTIONS_HTML_LINK") = "<A href=""#"" onclick=""window.open('FailedTransaction.List.asp?BatchView_ID=" & Server.UrlEncode(Service.Properties("BatchId").Value) & "','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')"">" & "View Failed Transactions" & "</A>"
    Service.Properties("FAILEDTRANSACTIONS_HTML_LINK") = "<A href=""#"" onclick=""window.open('/MetraNet/MetraControl/FailedTransactions/FailedTransactionViewFromBatch.aspx?Filter_FailedTransactionList_BatchId=" & Server.UrlEncode(Service.Properties("BatchId").Value) & "&PageTitle=" & Server.UrlEncode(mdm_GetDictionary().Item("TEXT_FAILED_TRANSACTIONS_FOR_BATCH") & " " & Service.Properties("BatchId").Value) & "','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')"">"& mom_GetDictionary("TEXT_View_Failed_Transactions") & "</A>"
    ' "<button class='clsButtonBlueLarge' name='ViewMeteringStatistics' onclick=""window.open('DefaultDialogUsageStatisticsQuery.asp?UsageStatisticsFilter_BatchId=" & Service.Properties("BatchId").Value & "','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')"">" & "Metering Statistics" &  "</button>"
  else
    Service.Properties("FAILEDTRANSACTIONS_HTML_LINK") = ""
  end if
  
  Service.Properties("AUDITHISTORY_HTML") = getAuditHistoryHTML
  Service.Properties("BACKOUTRERUN_HISTORY_HTML") = getBackoutRerunHistoryHTML
  Service.Properties("ACTION_HTML") = getAvailableActionsHTML(rowset) 
form_Refresh=true

END FUNCTION

FUNCTION getAuditHistoryHTML
    dim sHTML
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  	rowset.Init "queries\audit"
  	rowset.SetQueryTag("__SELECT_AUDIT_LOG_FOR_SPECIFIC_ENTITY__")  
    rowset.AddParam "%%ENTITY_TYPE_ID%%", 6
    rowset.AddParam "%%ENTITY_ID%%", CLng(Service.Properties("BatchTableId").Value)
  	rowset.Execute
  
    rowset.Sort "Time", 1

    sHTML = "<TABLE width='100%' BORDER='0'  CELLPADDING='0' CELLSPACING='0'>"        
    sHTML = sHTML & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left' colspan='5'>"& mom_GetDictionary("TEXT_Batch_History") & "</td></tr>"    
    sHTML = sHTML & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left'>"& mom_GetDictionary("TEXT_Time1") & "</td><td align='left'>"& mom_GetDictionary("TEXT_EventName") & "</td><td align='left'>"& mom_GetDictionary("TEXT_Details") & "</td><td align='left'>"& mom_GetDictionary("TEXT_User") & "</td></tr>"    

    if rowset.eof then
      sHTML = sHTML & "<tr class='TableDetailCell'><td colspan='4'>"& mom_GetDictionary("TEXT_No_audit_events") & "</td></tr>"
    else  
      do while not rowset.eof 
          dim sToolTip
          'sToolTip = rowset.value("Details")
          sHTML = sHTML & "<tr class='TableDetailCell' title='" & sToolTip & "'><td style='vertical-align: top'>" & rowset.value("Time") & "</td>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("EventName") & "</td>"  
          sHTML = sHTML & "<td width='350px' style='vertical-align: top'>" & rowset.value("Details") & "&nbsp;</td>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("UserName") & "&nbsp;</td></tr>"    
          rowset.movenext
      loop 
    end if
    
    sHTML = sHTML & "</TABLE><BR>" & vbNewLine
    
    getAuditHistoryHTML = sHTML
END FUNCTION


FUNCTION getBackoutRerunHistoryHTML
    dim sHTML
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  	rowset.Init "queries\mom"
    rowset.SetQueryTag("__GET_BATCH_MANANAGEMENT_BATCH_BACKOUT_RERUN_INFORMATION__")  
    rowset.AddParam "%%ID_BATCH_ENCODED%%", CStr(Service.Properties("BatchId").Value)
    
  	rowset.Execute
  
    'sHTML = DumpRowsetHTML(rowset)
    'rowset.movefirst
    'getBackoutRerunHistoryHTML = sHTML
    'exit function
        
    rowset.Sort "Time", MTSORT_ORDER_ASCENDING

    sHTML = sHTML & "<TABLE width='100%' BORDER='0'  CELLPADDING='0' CELLSPACING='0'>"        
    sHTML = sHTML & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left' colspan='10'>"& mom_GetDictionary("TEXT_Batch_Backout_Rerun_List") & "</td></tr>"    
    sHTML = sHTML & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left'>"& mom_GetDictionary("TEXT_RerunId1") & "</td><td align='left'>"& mom_GetDictionary("TEXT_Time1") & "</td><td align='left'>"& mom_GetDictionary("TEXT_LastAction1") & "</td><td align='left'>"& mom_GetDictionary("TEXT_User") & "</td><td align='left'>"& mom_GetDictionary("TEXT_Details") & "</td><td align='left'>&nbsp;</td></tr>"    

    if rowset.eof then
      sHTML = sHTML & "<tr class='TableDetailCell'><td colspan='8'>"& mom_GetDictionary("TEXT_No_backouts") & "</td></tr>"
    else  
      do while not rowset.eof 
          dim sToolTip, sActionHTML
          'sToolTip = rowset.value("Details")
          select case ucase(rowset.value("Last Action"))
            case "END ANALYZE"
              'sActionHTML = "<button <A href='BackoutRerun.BackoutStep2.asp?Rerunid=" & rowset.value("Rerun Id") & "&ReturnUrl=" & Server.urlencode("BatchManagement.ViewEdit.asp?BatchEncodedId=" & Form("BatchEncodedId") & "&ID=" & Form("BatchTableId")) & "'>" & "Resume Backout" & "</A>"
            
              sActionHTML = "<A href='BackoutRerun.BackoutStep2.asp?Rerunid=" & rowset.value("Rerun Id") & "&ReturnUrl=" & Server.urlencode("BatchManagement.ViewEdit.asp?BatchEncodedId=" & Service.Properties("BatchId").Value & "&ID=" & Form("BatchTableId")) & "'>" & mom_GetDictionary("TEXT_Resume_Backout") & "</A>"
              sActionHTML = sActionHTML & "&nbsp;&nbsp;<A href='#' Title='"& mom_GetDictionary("TEXT_Remove_Title") & "' onclick='mdm_RefreshDialogUserCustom(this,""" & rowset.value("Rerun Id") & """);' name='BackoutAbandon'>" & mom_GetDictionary("TEXT_Abandon") & "</a>"
            case "END EXTRACT"
              'sActionHTML = " <button onclick='mdm_RefreshDialogUserCustom(this,""" & rowset.value("Rerun Id") & """);' name='BackoutResubmit' Class='clsButtonBlueSmall'>Resubmit</button>"
              sActionHTML = "<A href='#' Title='"& mom_GetDictionary("TEXT_Resubmit_the_records") & "' onclick='mdm_RefreshDialogUserCustom(this,""" & rowset.value("Rerun Id") & """);' name='BackoutResubmit'>" & mom_GetDictionary("TEXT_Resubmit") & "</a>"
              sActionHTML = sActionHTML & "&nbsp;&nbsp;<A href='#' Title='"& mom_GetDictionary("TEXT_Delete_the_records") & "' onclick='mdm_RefreshDialogUserCustom(this,""" & rowset.value("Rerun Id") & """);' name='BackoutDelete'>" & mom_GetDictionary("TEXT_Delete") & "</a>"
            case else
              sActionHTML = "&nbsp;"
          end select
          sHTML = sHTML & "<tr class='TableDetailCell' title='" & sToolTip & "'><td style='vertical-align: top'>" & rowset.value("Rerun Id") & "</td>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("Time") & "</td>"  
          sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("Last Action") & "</td>" 
          sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("UserName") & "</td>" 
          sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("Comment") & "&nbsp;</td>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & sActionHTML & "&nbsp;</td></tr>"    
          rowset.movenext
      loop 
    end if
    
    sHTML = sHTML & "</TABLE><BR>" & vbNewLine
    
    getBackoutRerunHistoryHTML = sHTML
END FUNCTION

FUNCTION getAvailableActionsHTML(rowset)
    dim sHTML
    dim bShowBackoutOption, bShowResubmitOption, bShowFailedOption, bShowMarkAsFailed, bShowMarkAsCompleted, bShowDismiss
    dim sBatchId, sBatchTableId
    
    sBatchId=Server.UrlEncode(rowset.value("BatchId"))
    sBatchTableId = rowset.value("BatchTableId")
   
    bShowFailedOption=false
    bShowBackoutOption=false
    bShowResubmitOption=false
    bShowMarkAsFailed=false
    bShowMarkAsCompleted=false
    bShowDismiss=false
    
    'Show failed link?
    if RowSet.Value("Failed")<>"" then
      if CLng(RowSet.Value("Failed"))>0 Then
        bShowFailedOption=true
        'Need to get batch id and build link to failed transaction screen
        'bShowBackoutOption=true
      end if
    end if

    'Show backout/resubmit link?
    if RowSet.Value("Status")="Active" then
      'bShowBackoutOption=true
      bShowMarkAsCompleted=true
      bShowMarkAsFailed=true
    end if    
    if RowSet.Value("Status")="Backed Out" then
      bShowDismiss=true
      bShowBackoutOption=true
      bShowResubmitOption=true
    end if    
    
    if RowSet.Value("Status")="Resubmitted" then
      bShowBackoutOption=true
    end if    
    if RowSet.Value("Status")="Completed" then
      bShowBackoutOption=true
      bShowMarkAsFailed=true
    end if    
    if RowSet.Value("Status")="Failed" then
      bShowBackoutOption=true
      bShowMarkAsCompleted=true
    end if  
    
    if bShowMarkAsCompleted then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueXLarge' name=MarkAsCompleted onclick='mdm_RefreshDialog(this)'>" & mom_GetDictionary("TEXT_Mark_As_Completed") & "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueXLarge' name='MarkAsCompleted'>" & mom_GetDictionary("TEXT_Mark_As_Completed") & "</button>" & vbNewLine
    end if
     
    if bShowMarkAsFailed then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueLarge' name='MarkAsFailed' onclick='mdm_RefreshDialog(this)'>" & mom_GetDictionary("TEXT_Mark_As_Failed") & "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueLarge' name='Backout'>" & mom_GetDictionary("TEXT_Mark_As_Failed") & "</button>" & vbNewLine
    end if

    if bShowBackoutOption then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueLarge' name='Backout' onclick='mdm_RefreshDialog(this)'>" & mom_GetDictionary("TEXT_Backout") & "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueLarge' name='Backout' onclick=""window.open('protoDefaultDialogFailedTransactionStatus.asp','', 'height=400,width=400, resizable=yes, scrollbars=yes, status=yes'); return false;"">" & mom_GetDictionary("TEXT_Backout") & "</button>" & vbNewLine
    end if
    
    if bShowDismiss then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueLarge' name='MarkAsDismissed' onclick='mdm_RefreshDialog(this)'>" & mom_GetDictionary("TEXT_Dismiss") & "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueLarge' name='Backout'>" & mom_GetDictionary("TEXT_Dismiss") & "</button>" & vbNewLine
    end if
    
    sHTML = sHTML & "<BR>"

    getAvailableActionsHTML = sHTML
END FUNCTION

FUNCTION Refresh_Click(EventArg) ' As Boolean
  Refresh_Click=true
END FUNCTION

FUNCTION MarkAsCompleted_Click(EventArg) ' As Boolean
  dim strUrl
  strUrl = "BatchManagement.UpdateStatus.asp?BatchAction=C&BatchDisplayName=" & server.urlencode(Service.Properties("BatchDisplayName").Value) & "&BatchStatus=" & Service.Properties("BatchStatus").Value & "&BatchId=" & server.urlencode(Service.Properties("BatchId").Value) & "&BatchTableId=" & Service.Properties("BatchTableId").Value 
  mdm_TerminateDialogAndExecuteDialog strUrl
  MarkAsCompleted_Click=true
END FUNCTION

FUNCTION MarkAsFailed_Click(EventArg) ' As Boolean
  dim strUrl
  strUrl = "BatchManagement.UpdateStatus.asp?BatchAction=F&BatchDisplayName=" & server.urlencode(Service.Properties("BatchDisplayName").Value) & "&BatchStatus=" & Service.Properties("BatchStatus").Value & "&BatchId=" & server.urlencode(Service.Properties("BatchId").Value) & "&BatchTableId=" & Service.Properties("BatchTableId").Value 
  mdm_TerminateDialogAndExecuteDialog strUrl
  MarkAsFailed_Click=true
END FUNCTION

FUNCTION Backout_Click(EventArg) ' As Boolean
  dim strBackoutUrl
  strBackoutUrl = "BatchManagement.UpdateStatus.asp?BatchAction=B&BatchDisplayName=" & server.urlencode(Service.Properties("BatchDisplayName").Value) & "&BatchStatus=" & Service.Properties("BatchStatus").Value & "&BatchId=" & server.urlencode(Service.Properties("BatchId").Value) & "&BatchTableId=" & Service.Properties("BatchTableId").Value 
  mdm_TerminateDialogAndExecuteDialog strBackoutUrl
  Backout_Click=true
END FUNCTION

FUNCTION MarkAsDismissed_Click(EventArg) ' As Boolean
  dim strUrl
  strUrl = "BatchManagement.UpdateStatus.asp?BatchAction=D&BatchDisplayName=" & server.urlencode(Service.Properties("BatchDisplayName").Value) & "&BatchStatus=" & Service.Properties("BatchStatus").Value & "&BatchId=" & server.urlencode(Service.Properties("BatchId").Value) & "&BatchTableId=" & Service.Properties("BatchTableId").Value 
  mdm_TerminateDialogAndExecuteDialog strUrl
  MarkAsDismissed_Click=true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Resubmit_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION BackoutResubmit_Click(EventArg) ' As Boolean
	
  BackoutResubmit_Click = false
  
  dim objRerun
  set objRerun = mom_RetrieveBackoutRerunObject(mdm_UIValue("mdmUserCustom"))
  objRerun.Rerun ""
  If Not mom_CheckError("Batch Backout Rerun") Then Exit Function
    
  BackoutResubmit_Click =true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  BackoutDelete_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION BackoutDelete_Click(EventArg) ' As Boolean
  
  BackoutDelete_Click = false
  
  dim objRerun
  set objRerun = mom_RetrieveBackoutRerunObject(mdm_UIValue("mdmUserCustom"))
  objRerun.Delete ""
  If Not mom_CheckError("Batch Backout Delete") Then Exit Function
  
  BackoutDelete_Click =true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  BackoutAbandon_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION BackoutAbandon_Click(EventArg) ' As Boolean
	
  BackoutAbandon_Click = false
  
  dim objRerun
  set objRerun = mom_RetrieveBackoutRerunObject(mdm_UIValue("mdmUserCustom"))
  objRerun.Abandon ""
  If Not mom_CheckError("Batch Backout Abandon") Then Exit Function
  
  BackoutAbandon_Click =true
END FUNCTION


%>


