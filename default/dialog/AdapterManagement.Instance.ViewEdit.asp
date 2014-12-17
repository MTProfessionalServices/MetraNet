<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: IntervalManagement.ViewEdit.asp$
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
'  $Date: 11/14/2002 12:13:30 PM$
'  $Author: Rudi Perkins$
'  $Revision: 9$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/IntervalManagementLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%


mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

  if len(request("ReturnUrl"))>0 then
    Form.RouteTo = request("ReturnUrl")
  else
    Form.RouteTo = "welcome.asp"
  end if
  Response.Cookies ("previousPage") = Form.RouteTo

  Form("InstanceId") = request.querystring("ID")
  Form("IntervalDescription") = request.querystring("IntervalDescription")
  Form("DisableActions") = request.querystring("DisableActions")
  Form("IntervalId") = request.querystring("IntervalId")
  Form("BillingGroupId") = request.querystring("BillingGroupId")
  
  Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
                  
  Service.Properties.Add "InstanceId"     , "string", 10, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "DisplayName"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "DisplayNameEncoded"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ReverseMode"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "StatusCode"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "Status"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalDescription"      , "string", 1024, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  'Service.Properties.Add "IntervalType"      , "string", 255, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE

  Service.Properties.Add "ArgStartDate"      , MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ArgEndDate"      , MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "CHANGESTATE_HTML_LINK"      , "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "AUDITHISTORY_HTML"      , "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ADAPTERRUN_HTML"      , "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ACTION_HTML"      , "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE

 
  'Service.Properties("tx_typ_space").AddValidListOfValues "__GET_NAME_SPACE_TYPE_LIST__",,,,mom_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH")
  
    ' We only accept the following chars
  'Service("nm_space").StringID = TRUE
  'Service.LoadJavaScriptCode  
  
	Form_Initialize = form_Refresh(EventArg)
END FUNCTION

FUNCTION form_Refresh(EventArg)

  dim rowset
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\mom"
  rowset.SetQueryTag("__GET_ADAPTER_INSTANCE_INFORMATION__")
  rowset.AddParam "%%ID_INSTANCE%%", CLng(Form("InstanceId"))
  rowset.AddParam "%%ID_LANG_CODE%%", Session("FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME").LanguageId      
  rowset.Execute
    
  Service.Properties("InstanceID").Value       = rowset.value("InstanceID")
  Service.Properties("StatusCode").Value       = rowset.value("Status")
  Service.Properties("Status").Value       = mom_GetAdapterInstanceStatusMessage(rowset.value("Status"),mdm_Format(rowset.value("EffectiveDate"), mom_GetDictionary("DATE_TIME_FORMAT")))
  Service.Properties("DisplayName").Value       = rowset.value("tx_display_name")  
  Service.Properties("DisplayNameEncoded").Value       = server.urlencode(rowset.value("tx_display_name"))  
  Service.Properties("ReverseMode").Value       = rowset.value("ReverseMode")
  Service.Properties("ArgStartDate").Value       = rowset.value("ArgStartDate")
  Service.Properties("ArgEndDate").Value       = rowset.value("ArgEndDate")
  Service.Properties("IntervalDescription").Value       = Form("IntervalDescription")

  '//Don't show argdate information if this is an interval based instance
  '//If we have been passed an Interval description, just assume this is interval based
  if len(Form("IntervalDescription"))>0 then
    mdm_GetDictionary().Add "SHOW_SCHEDULED_ADAPTER_INFORMATION", 0
  else
    mdm_GetDictionary().Add "SHOW_SCHEDULED_ADAPTER_INFORMATION", 1
  end if

  Service.Properties("AUDITHISTORY_HTML") = "" 'getAuditHistoryHTML
  
  
  Service.Properties("ADAPTERRUN_HTML") = getRunHistoryHTML
  Service.Properties("ACTION_HTML") = getAvailableActionsHTML()
  
form_Refresh=true

END FUNCTION


FUNCTION getAvailableActionsHTML()
    dim sHTML
    dim bShowReverseOption, bShowRunOption, bShowForceOption, bShowMarkAsNotReadyToRun
    
    bShowReverseOption=false
    bShowRunOption=false
    bShowForceOption=false
    bShowMarkAsNotReadyToRun=false
    
    '// Determine button state
    select case Service.Properties("StatusCode").Value
    case "Failed"
      bShowReverseOption = true
    case "Succeeded"
      bShowReverseOption = true
    case "ReadyToRun", "ReadyToReverse"
      bShowMarkAsNotReadyToRun=true
    case "NotYetRun"
      bShowRunOption=true
    end select

    if Service.Properties("ReverseMode").Value = "NotImplemented" then
       bShowReverseOption = false
    end if
  
    if lcase(Form("DisableActions"))="true" then
        bShowReverseOption=false
        bShowRunOption=false
        bShowForceOption=false
        bShowMarkAsNotReadyToRun=false
    end if

    sHTML = sHTML & "<tr class='TableHeader'><td align='center' colspan='15'>"    


    if bShowRunOption then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueLarge' name='RunAdapters' onclick=""mdm_PVBPageUpdateSelectedIDs(null);mdm_RefreshDialog(this); return false;"">" & "Run Adapter" &  "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueLarge' id='EditMapping' onclick=""window.open('protoDefaultDialogFailedTransactionStatus.asp','', 'height=400,width=400, resizable=yes, scrollbars=yes, status=yes'); return false;"">" & "Run Adapter" &  "</button>" & vbNewLine
    end if

    if bShowRunOption then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueXLarge' name='RunAdaptersLater' onclick=""mdm_PVBPageUpdateSelectedIDs(null);mdm_RefreshDialog(this); return false;"">" & "Run Adapter Later" &  "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueXLarge' name='EditMapping' onclick=''>" & "Run Adapter Later" &  "</button>" & vbNewLine
    end if
    
    if bShowReverseOption then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueLarge' name='ReverseAdapters' onclick=""mdm_PVBPageUpdateSelectedIDs(null);mdm_RefreshDialog(this); return false;"">" & "Reverse Adapter" &  "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueLarge' name='ReverseAdapters' onclick=''>" & "Reverse Adapter" &  "</button>" & vbNewLine
    end if

    if bShowReverseOption then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueXLarge' name='ReverseAdaptersLater' onclick=""mdm_PVBPageUpdateSelectedIDs(null);mdm_RefreshDialog(this); return false;"">" & "Reverse Adapter Later" &  "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueXLarge' name='ReverseAdaptersLater' onclick=''>" & "Reverse Adapter" &  "</button>" & vbNewLine
    end if
    
    'if bShowForceOption then
    '  sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueLarge' name='ReverseAdaptersLater' onclick=""javascript:alert('Not implemented yet... hold your horses');"">" & "Force Adapter" &  "</button>" & vbNewLine
    'else
    '  sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueLarge' name='ReverseAdaptersLater' onclick=""window.open('protoDefaultDialogFailedTransactionStatus.asp','', 'height=400,width=400, resizable=yes, scrollbars=yes, status=yes')"">" & "Backout Adapter" &  "</button>" & vbNewLine
    'end if   
         
    if bShowMarkAsNotReadyToRun then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueXLarge' name='CancelPendingAction' onclick=""mdm_PVBPageUpdateSelectedIDs(null);mdm_RefreshDialog(this); return false;"">" & "Cancel Submitted Action" &  "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueXLarge' id='CancelPendingAction' onclick=""window.open('protoDefaultDialogFailedTransactionStatus.asp','', 'height=400,width=400, resizable=yes, scrollbars=yes, status=yes'); return false;"">" & "Cancel Submitted Action" &  "</button>" & vbNewLine
    end if      
    sHTML = sHTML & "<BR>"

    sHTML = sHTML & "</td></tr></table>"
    
    getAvailableActionsHTML = sHTML
END FUNCTION


FUNCTION getRunHistoryHTML
    dim sHTML
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  	rowset.Init "queries\mom"
  	rowset.SetQueryTag("__GET_ADAPTER_RUN_LIST_FOR_INSTANCE__")
    rowset.AddParam "%%ID_INSTANCE%%", CLng(Form("InstanceId"))   
  	rowset.Execute

    'rowset.Sort "Time", 1
    'sHTML = DumpRowsetHTML(rowset)
    'rowset.MoveFirst
    
    sHTML = sHTML & "<TABLE width='100%' BORDER='0'  CELLPADDING='0' CELLSPACING='0'>"        
    sHTML = sHTML & "<tr class='TableHeader'><td align='left' colspan='15'><strong><font size=4>Instance Run History</font></strong></td></tr>"    
    sHTML = sHTML & "<tr class='TableHeader' style='vertical-align:bottom;background-color=#688ABA'><td align='left'>Action</td><td align='left'>Status</td><td valign='bottom' align='left'>Summary Details</td><td align='left'>Start Time [Duration]</td><td align='left'>Machine</td></tr>"    

    dim sAdditionalParameters
    if len(Form("IntervalId"))>0 then
      sAdditionalParameters = "&BillingGroupId=" & Form("BillingGroupId") & "&IntervalId=" & Form("IntervalId")
    end if
    
    if rowset.eof then
      sHTML = sHTML & "<tr class='TableDetailCell'><td colspan='4'>No runs have been associated with this instance.</td></tr>"
    else  
      do while not rowset.eof 
          dim sToolTip, sTime, sStatusCode, sType, sMachine, sViewDetailsHTML
          
          sStatusCode = rowset.value("tx_status")
          sType = rowset.value("tx_type")
          '// Rowset no longer returns this information
          if sStatusCode="Failed" or sStatusCode="Running" or sStatusCode="Succeeded" then
            sTime = mom_GetDurationMessage(rowset.value("dt_start"),rowset.value("dt_end"))
          end if

          sViewDetailsHTML = "<A href=""#"" title=""View Run Details"" onclick=""window.open('AdapterManagement.RunDetails.List.asp?RunId=" & rowset.value("id_run") & "&AdapterName=" & Service.Properties("DisplayNameEncoded") & sAdditionalParameters & "','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')"">"
          if  len(rowset.value("tx_detail"))=0 then
            sViewDetailsHTML = sViewDetailsHTML & "View Run Details" & "</A>"
          else
            sViewDetailsHTML = sViewDetailsHTML & rowset.value("tx_detail") & "</A>"
          end if
                   
          sMachine = rowset.value("tx_machine")

          sToolTip = "Run Id: " & rowset.value("id_run") & vbNewLine & "Reversed Run Id: " & rowset.value("id_reversed_run")
          sHTML = sHTML & "<tr class='TableDetailCell' title='" & sToolTip & "'>"
          'sHTML = sHTML & "<td style='vertical-align: top'>" & "&nbsp;" & "</td>"            
          sHTML = sHTML & "<td style='vertical-align: top'>" & sType & "&nbsp;</td>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & sStatusCode & "&nbsp;</td>"  
          sHTML = sHTML & "<td style='vertical-align: top'>" & sViewDetailsHTML & "</td>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & sTime & "&nbsp;</td>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & sMachine & "&nbsp;</td></tr>"
          rowset.movenext
      loop 
    end if
    
    sHTML = sHTML & "</TABLE><BR>" & vbNewLine
    
    getRunHistoryHTML = sHTML
END FUNCTION


FUNCTION getAuditHistoryHTML
    dim sHTML
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  	rowset.Init "queries\audit"
  	rowset.SetQueryTag("__SELECT_AUDIT_LOG__")  
  	rowset.Execute
  
    
    '// Filter for only audit items related to this case
    If true Then
      dim objMTFilter
      Set objMTFilter = mdm_CreateObject(MTFilter)
      objMTFilter.Add "EntityType", OPERATOR_TYPE_EQUAL, 6
      objMTFilter.Add "EntityId", OPERATOR_TYPE_EQUAL, cstr(Form("BatchTableId"))
      set rowset.filter = objMTFilter
    End If
  
    rowset.Sort "Time", 1

    sHTML = "<TABLE width='100%' BORDER='0'  CELLPADDING='0' CELLSPACING='0'>"        
    sHTML = sHTML & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left' colspan='5'>Batch History</td></tr>"    
    sHTML = sHTML & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left'>Time</td><td align='left'>EventName</td><td align='left'>Details</td><td align='left'>User</td></tr>"    

    if rowset.eof then
      sHTML = sHTML & "<tr class='TableDetailCell'><td colspan='4'>No audit events have been recorded for this batch.</td></tr>"
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


 
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION xOK_Click(EventArg) ' As Boolean

    'On Error Resume Next
    
    Dim booRetVal    
    Dim objRowset
    
    Set objRowset = mdm_CreateObject(MTSQLRowset)
    
    booRetVal = Service.Tools.ExecSQL(mom_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH"), "__ADD_NAME_SPACE__", objRowset, "NM_SPACE", Service("NM_SPACE"), "TX_DESC", Service("TX_DESC"), "TX_TYP_SPACE", Service("TX_TYP_SPACE"))
    If(booRetVal) then
        
        OK_Click = TRUE
    Else            
        EventArg.Error.Description = mom_GetDictionary("MOM_ERROR_1006")
        OK_Click = FALSE
    End If
    Err.Clear   
END FUNCTION

FUNCTION RunAdapters_Click(EventArg) ' As Boolean

  dim sAdapterList 
  sAdapterList = "" & Form("InstanceId") & ","

  mdm_TerminateDialogAndExecuteDialog "IntervalManagement.RunReverseAdapter.asp?Action=Run&AdapterList=" & server.urlencode(sAdapterList) & "&ReturnUrl=" & Server.UrlEncode("AdapterManagement.Instance.ViewEdit.asp" & "?ID=" & Form("InstanceId") & "&ReturnUrl=" & Server.UrlEncode(Form.RouteTo) & "&IntervalDescription=" & Form("IntervalDescription"))
  
  RunAdapters_Click = true
END FUNCTION

FUNCTION RunAdaptersLater_Click(EventArg) ' As Boolean
  
  dim sAdapterList 
  sAdapterList = "" & Form("InstanceId") & ","

  mdm_TerminateDialogAndExecuteDialog "IntervalManagement.RunReverseAdapterLater.asp?Action=Run&AdapterList=" & server.urlencode(sAdapterList) & "&ReturnUrl=" & Server.UrlEncode("AdapterManagement.Instance.ViewEdit.asp" & "?ID=" & Form("InstanceId") & "&ReturnUrl=" & Server.UrlEncode(Form.RouteTo) & "&IntervalDescription=" & Form("IntervalDescription"))
  
  ReverseAdaptersLater_Click = true
END FUNCTION

FUNCTION ReverseAdapters_Click(EventArg) ' As Boolean

  dim sAdapterList 
  sAdapterList = "" & Form("InstanceId") & ","

  mdm_TerminateDialogAndExecuteDialog "IntervalManagement.RunReverseAdapter.asp?Action=Reverse&AdapterList=" &  server.urlencode(sAdapterList) & "&ReturnUrl=" & Server.UrlEncode("AdapterManagement.Instance.ViewEdit.asp" & "?ID=" & Form("InstanceId") & "&ReturnUrl=" & Server.UrlEncode(Form.RouteTo) & "&IntervalDescription=" & Form("IntervalDescription"))
  
  ReverseAdapters_Click = true
END FUNCTION

FUNCTION ReverseAdaptersLater_Click(EventArg) ' As Boolean
  
  dim sAdapterList 
  sAdapterList = "" & Form("InstanceId") & ","

  mdm_TerminateDialogAndExecuteDialog "IntervalManagement.RunReverseAdapterLater.asp?Action=Reverse&AdapterList=" & server.urlencode(sAdapterList) & "&ReturnUrl=" & Server.UrlEncode("AdapterManagement.Instance.ViewEdit.asp" & "?ID=" & Form("InstanceId") & "&ReturnUrl=" & Server.UrlEncode(Form.RouteTo) & "&IntervalDescription=" & Form("IntervalDescription"))
  
  ReverseAdaptersLater_Click = true
END FUNCTION

FUNCTION CancelPendingAction_Click(EventArg) ' As Boolean
  
  CancelPendingAction_Click = true
  
  dim objUSM
  set objUSM = mom_GetUsageServerClientObject
  objUSM.CancelSubmittedEvent clng(Form("InstanceId")), ""
  if not CheckError("") then
    CancelPendingAction_Click = false
  end if

  objUSM.NotifyServiceOfSubmittedEvents

END FUNCTION

FUNCTION Refresh_Click(EventArg) ' As Boolean
  Refresh_Click=true
END FUNCTION

PRIVATE FUNCTION CheckError(sErrorMessage) ' As Boolean

    CheckError = FALSE
    If(Err.Number)Then 
        EventArg.Error.Save Err 
        EventArg.Error.Description = sErrorMessage & ":" & EventArg.Error.Description
        Err.Clear 
        Exit Function
    End If        
    CheckError = TRUE
    
END FUNCTION
%>





