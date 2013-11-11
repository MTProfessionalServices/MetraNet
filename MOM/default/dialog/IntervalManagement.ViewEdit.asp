<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: IntervalManagement.ViewEdit.asp$
' 
'  Copyright 1998-2005 by MetraTech Corporation
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
'  Created by: Rudi, Kevin
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!--METADATA TYPE="TypeLib" NAME="MetraTech.UsageServer" UUID="{b6ad949f-25d4-4cd5-b765-3f6199ecc51c}" -->

<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/IntervalManagementLibrary.asp"-->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%
Form.ErrorHandler = TRUE 
Form.RouteTo = mom_GetDictionary("INTERVAL_MANAGEMENT_LIST_DIALOG") & "?MDMAction=" & MDM_ACTION_REFRESH 

mdm_Main

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg)

  If Len(Request.QueryString("ID")) > 0 Then
    Form("IntervalID") = Request.QueryString("ID")
  End If
  If Len(Request.QueryString("BillingGroupID")) > 0 Then  
    Form("BillingGroupID") = Request.QueryString("BillingGroupID")
  End If  

  Service.Clear 		
  Service.Properties.Add "BillingGroupID", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE                  
  Service.Properties.Add "BillingGroup", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "BillingGroupMemberCount", "string", 0, TRUE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalOnlyAdapterCount", "string", 0, TRUE, "0", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "AdapterCount", "string", 0, TRUE, "0", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "SucceededAdapterCount", "string", 0, TRUE, "0", eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "FailedAdapterCount", "string", 0, TRUE, "0", eMSIX_PROPERTY_FLAG_NONE
                        
  Service.Properties.Add "IntervalId", "string", 0, TRUE ,Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalStatus", "string", 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalStatusIcon", "string", 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalType", "string", 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalStartDateTime", MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "IntervalEndDateTime", MSIXDEF_TYPE_TIMESTAMP, 0, TRUE, Empty, eMSIX_PROPERTY_FLAG_NONE
  
  Service.Properties.Add "CHANGESTATE_HTML_LINK", "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "AUDITHISTORY_HTML", "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ADAPTERRUN_HTML", "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ACTION_HTML", "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
  
	Form_Initialize = Form_Refresh(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_Refresh
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
FUNCTION Form_Refresh(EventArg)


  Dim objUSM, bg
  Set objUSM = mom_GetUsageServerClientObject()
  Set bg = objUSM.GetBillingGroup(Form("BillingGroupID"))  

  Service.Properties("BillingGroupId").Value          = bg.BillingGroupID
  Service.Properties("BillingGroup").Value            = bg.Name
  Service.Properties("BillingGroupMemberCount").Value = bg.MemberCount
  Service.Properties("IntervalOnlyAdapterCount").Value  = bg.IntervalOnlyAdapterCount
  Service.Properties("AdapterCount").Value            = bg.AdapterCount 
  Service.Properties("SucceededAdapterCount").Value   = bg.SucceededAdapterCount
  Service.Properties("FailedAdapterCount").Value      = bg.FailedAdapterCount
  Service.Properties("IntervalId").Value              = CLng(Form("IntervalId"))
  Service.Properties("IntervalType").Value            = GetBillingGroupCycleType(bg.CycleType)
  Service.Properties("IntervalStartDateTime").Value   = bg.StartDate
  Service.Properties("IntervalEndDateTime").Value     = bg.EndDate

  Service.Properties("IntervalStatusIcon").Value =  "<img src='" & GetBillingGroupStateIcon(bg.Status) & "' align='absmiddle'>&nbsp;"

  Dim bShowChangeIntervalStateLink,bShowCreatePullListLink
  bShowChangeIntervalStateLink = false
  bShowCreatePullListLink = true
  
  select case bg.Status
    case BillingGroupStatus_Open
      bShowChangeIntervalStateLink = true  
      Service.Properties("IntervalStatus").Value = "Open"
    case BillingGroupStatus_SoftClosed
      bShowChangeIntervalStateLink = objUSM.CanOpenBillingGroup(Service.Properties("BillingGroupID").Value)
      Service.Properties("IntervalStatus").Value = "Soft Closed"
    case BillingGroupStatus_HardClosed  
      bShowChangeIntervalStateLink = objUSM.CanOpenBillingGroup(Service.Properties("BillingGroupID").Value)    
      Service.Properties("IntervalStatus").Value = "Hard Closed"
      bShowCreatePullListLink=false
  end select
  
  if bShowChangeIntervalStateLink then
    Service.Properties("CHANGESTATE_HTML_LINK") = "&nbsp;<A href=""#"" onclick=""window.open('IntervalManagement.StateChange.asp?MDMReload=TRUE&BillingGroupID=" & Service.Properties("BillingGroupID").Value & "&IntervalId=" & Service.Properties("IntervalId").Value & "&State=" & Server.URLEncode(Service.Properties("IntervalStatus").Value) & "&StateName=" & Server.URLEncode(Service.Properties("IntervalStatus").Value) & "&IntervalEndDate=" & Server.UrlEncode(Service.Properties("IntervalEndDateTime").Value) & "','', 'height=500,width=650, resizable=yes, scrollbars=yes, status=yes')"">" & "Change State" &  "</A>"
  else 
    if bg.CanBeHardClosed then
      Service.Properties("CHANGESTATE_HTML_LINK") = "&nbsp;&nbsp;<button class='clsButtonBlueLarge' name='ForceHardClosed'" & " onclick=""mdm_RefreshDialogUserCustom(this);"">" & "<span style='font-size: 10px;'>Force Hard Close</span>" &  "</button>"
    else
      Service.Properties("CHANGESTATE_HTML_LINK") = ""
    end if
  end if
  
  dim allowPullList
  allowPullList = objUSM.AllowPullLists()  
  if bShowCreatePullListLink and allowPullList then
     mdm_GetDictionary().Add "SHOW_CREATE_PULL_LIST_OPTION", 1
  else
     mdm_GetDictionary().Add "SHOW_CREATE_PULL_LIST_OPTION", 0
  end if
  
  Service.Properties("ADAPTERRUN_HTML") = getRecurringEventRunHTML

  Form_Refresh=true

END FUNCTION

FUNCTION getRecurringEventRunHTML
    dim sHTML
    dim rowset
    dim idBillingGroup 
    dim idInterval
    
    idBillingGroup = Clng(Form("BillingGroupId"))
    idInterval = Clng(Form("IntervalId"))
    
    dim objUSMInstances
  	set objUSMInstances = CreateObject("MetraTech.UsageServer.RecurringEventInstanceFilter")
	  objUSMInstances.UsageIntervalID = idInterval
	  objUSMInstances.BillingGroupID = idBillingGroup
	  set rowset = objUSMInstances.GetEndOfPeriodRowset(true, true)    

    dim objUSM
    set objUSM = mom_GetUsageServerClientObject()

    dim bDisableActions
    if Service.Properties("IntervalStatus").Value = "Hard Closed" or Service.Properties("IntervalStatus").Value = "Open" then
      bDisableActions = true
    else 
      bDisableActions = false
    end if
    
    dim sIntervalDescription
    sIntervalDescription = "Interval " & Service.Properties("IntervalId").Value & " " & Service.Properties("IntervalType").Value & " " & Service.Properties("IntervalStartDateTime").Value & " - " & Service.Properties("IntervalEndDateTime").Value

    'DEBUG - dump rowset 
    if false then
      sHTML = DumpRowsetHTML(rowset)
      rowset.movefirst
      getRecurringEventRunHTML = sHTML
      exit function
    end if
    
    Service.Properties("ACTION_HTML") = getAvailableActionsHTML(rowset)     

    sHTML = sHTML & "<TABLE width='100%' BORDER='0'  CELLPADDING='0' CELLSPACING='0'>"        
    sHTML = sHTML & "<tr class='TableHeader' style='background-color:#005DAA;color:white;'><td align='left' colspan='15'><strong><font size=4>Billing Process Adapters</font></strong></td></tr>"    
    sHTML = sHTML & "<tr class='TableHeader' style='vertical-align:bottom;'><td align='left' width='10px' style='padding: 0px 0px 0px 0px; '><input type='checkbox' name='selectAllAdapters' " & IIF(bDisableActions,"disabled ","") & "value='' onClick='DoSelectAllAdapters(this);'></td><td align='left'>Adapter</td><td align='left'>Instance Id</td><td valign='bottom' align='left'>Status</td><td align='left'>Last<br>Action</td><td align='left'>Start Time [Duration]</td><td align='left'>Result</td><td align='left'>Machine</td></tr>"    

    if rowset.eof then
      sHTML = sHTML & "<tr class='TableDetailCell'><td colspan='15'>No adapter event runs for this interval currently.</td></tr>"
    else  
      do while not rowset.eof
          dim sToolTip,sIcon,sStatus,sStatusCode,sInstanceId,sStyle,sTime,sSelectHTML,sLastRunActionHTML, sLastRunResultHTML
          sTime			= "&nbsp;"
          sToolTip		= "Component: " & rowset.value("ClassName") & vbCRLF & "Config File: " & rowset.value("ConfigFile") & vbCRLF
          sStatusCode	= rowset.value("Status")
          sStatus		= mom_GetAdapterInstanceStatusMessage(rowset.value("Status"),rowset.value("EffectiveDate"))
          if sStatusCode = "Failed" then
            sStatus = "<img border='0' height='16' src= '../localized/us/images/errorsmall.gif' align='absmiddle' width='16'>&nbsp;" & sStatus
          end if
          
          if rowset.value("EventType")="EndOfPeriod" then


            '// This is an adapter event
            sIcon = "../localized/us/images/adapters/" & rowset.value("BillGroupSupportType") & ".png"
            sInstanceId = rowset.value("InstanceId")
            'sInstanceId = "<A href=""#"" title=""View Adapter Instance Run History"" onclick=""window.open('AdapterManagement.Instance.ViewEdit.asp?ID=" & sInstanceId & "','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')"">" & sInstanceId & "</A>"
            sInstanceId = "<A href='AdapterManagement.Instance.ViewEdit.asp?ID=" & sInstanceId & "&BillingGroupId=" & idBillingGroup & "&IntervalId=" & idInterval & "&DisableActions=" & bDisableActions & "&IntervalDescription=" & Server.UrlEncode(sIntervalDescription) & "&ReturnUrl=" & Server.UrlEncode("IntervalManagement.ViewEdit.asp") & "' title='View Adapter Instance Run History'>" & sInstanceId & "</A>"
            sSelectHTML = "<input type='checkbox' name='MDM_CB_" & rowset.value("InstanceId") & "' " & IIF(bDisableActions,"disabled ","") & "value=''>"
            sStyle = "vertical-align: top;"
            
            '// Rowset no longer returns this information
            if sStatusCode="Failed" or sStatusCode="Running" or sStatusCode="Succeeded" then
            end if

            if not isNull(rowset.value("LastRunAction")) then
              if sStatusCode="InProgress" then
                sTime = rowset.value("LastRunStart")
              else
                sTime = mom_GetDurationMessage(rowset.value("LastRunStart"),rowset.value("LastRunEnd"))
              end if
              sLastRunActionHTML = rowset.value("LastRunAction") 
              dim sLastRunStatus
              dim sLastRunDetail
              if cint(rowset.value("LastRunWarnings")) = 0 then
                sLastRunStatus = rowset.value("LastRunStatus")
                sLastRunDetail = rowset.value("LastRunDetail")
              else
                if sStatusCode = "Succeeded" then
                  sLastRunStatus = "<img border='0' height='16' src= '../localized/us/images/errorsmall.gif' align='absmiddle' width='16'>" & "Succeeded With Warnings"
                else
                  sLastRunStatus = rowset.value("LastRunStatus")
                end if
                sLastRunDetail = "The run generated " & rowset.value("LastRunWarnings") & " warnings." & vbNewLine & rowset.value("LastRunDetail")
              end if  
              sLastRunResultHTML = "<A href=""#"" title=""" & sLastRunDetail & vbNewLine & "Click To View Run Details"" onclick=""window.open('AdapterManagement.RunDetails.List.asp?RunId=" & rowset.value("LastRunId") & "&BillingGroupId=" & idBillingGroup & "&IntervalId=" & idInterval & "&AdapterName=" & server.urlencode("<img alt='" & sToolTip & "' border='0' height='16' src= '" & sIcon & "' align='absmiddle' width='16'>&nbsp;" & rowset.value("EventDisplayName")) & "','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')"">" & sLastRunStatus & "</A>"
            else
              sTime = "&nbsp;"
              sLastRunActionHTML = "&nbsp;"
              sLastRunResultHTML = "&nbsp;"
            end if
                        
            if false then
            if CLng(rowset.value("BatchCount"))>0 then
              if CLng(rowset.value("BatchCount"))=1 then
                sStatus = sStatus & " (<A href=""#"" title=""View Batch Information"" onclick=""window.open('BatchManagement.ViewEdit.asp?BatchEncodedId=" & server.urlencode(rowset.value("HackBatchId")) & "','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')"">" & "1 batch" & "</A>)"
              else
                sStatus = sStatus & " (" & rowset.value("BatchCount") & " batches)"
              end if
            end if
            end if
          else
            '// This is a checkpoint event
            '// Determine if dependencies have been met - eventually it would be nice if this was returned from the rowset
            dim bDependenciesMet
            'dim objSingleInstance, objDependencyRowset
  	        'set objSingleInstance = CreateObject("MetraTech.UsageServer.RecurringEventInstanceFilter")
            'objSingleInstance.AddInstanceCriteria CLng(rowset.value("InstanceId"))
            'objSingleInstance.Apply
            'set objDependencyRowset = objUSM.GetCanExecuteEventDepsRowset((objSingleInstance))
            
            'if objDependencyRowset.RecordCount = 0 then
              bDependenciesMet = true
            'else
            '  bDependenciesMet = false
            'end if
            
            sToolTip = ""
            sInstanceId = "&nbsp;"
            sSelectHTML = "&nbsp;"
            sLastRunActionHTML = "&nbsp;"
            sLastRunResultHTML = "&nbsp;"
            sStyle = "height: 29px;text-align:middle;vertical-align: middle;BACKGROUND-COLOR:#CCDEF6; border-bottom: silver solid 1px;	BORDER-TOP: silver solid 1px;"            
            if sStatusCode = "NotYetRun" then
              'sStatus =  "<button  style='font-weight: bold;padding: 0px 0px 0px 0px;font-size: 8px;height=18px;width=60px;' name='AcknowledgeCheckPoint' onclick=""mdm_RefreshDialogUserCustom(this," & rowset.value("InstanceId") & ");"">" & "Acknowledge" &  "</button>" & vbNewLine
              sStatus =  "<button class='clsButtonBlueMedium' name='AcknowledgeCheckPoint'" & IIF(bDependenciesMet and not bDisableActions, ""," disabled") & " onclick=""mdm_RefreshDialogUserCustom(this," & rowset.value("InstanceId") & ");"">" & "<span style='font-size: 10px;'>Acknowledge</span>" &  "</button>" & vbNewLine
            end if
            if sStatusCode = "ReadyToRun" or sStatusCode = "Succeeded" then
              'sStatus =  "&nbsp;&nbsp;<button class='clsButtonBlueLarge' name='EditMapping' onclick=""javascript:alert('Not implemented yet... hold your horses');"">" & "Acknowledge" &  "</button>" & vbNewLine
              sStatus = "Acknowledged"
            end if
            
            
            sIcon = "../localized/us/images/adapter_checkpoint.gif"
          end if

          
          if UCase(rowset.value("IsGlobalAdapter")) = "Y" then
            sHTML = sHTML & "<tr class='TableDetailCell' title='" & sToolTip & "' style='" & sStyle & "'>"
            sHTML = sHTML & "<td align='left' width='10px' style='" & sStyle & "'>" & sSelectHTML & "</td><td style='vertical-align: middle;" & sStyle & "'><img alt='" & sToolTip & "' border='0' height='16' src= '" & sIcon & "' align='absmiddle' width='16'>&nbsp;Interval Only - <strong>" & rowset.value("EventDisplayName") & "</strong></td>"
            sHTML = sHTML & "<INPUT Type='Hidden' Name='" & rowset.value("EventDisplayName") & "' value='" & sStatusCode & "'>"
            sHTML = sHTML & "</td>"
            sHTML = sHTML & "<td style='" & sStyle & "'>" & sInstanceId & "</td>"  
            'sHTML = sHTML & "<td style='vertical-align: top;" & sStyle & "'>" & rowset.value("RunStart")  & "&nbsp;</td>"  
            'sHTML = sHTML & "<td style='vertical-align: top;" & sStyle & "'>" & rowset.value("RunEnd") & "&nbsp;</td>"  
            sHTML = sHTML & "<td style='" & sStyle & "'>" & sStatus & "</td>"  
            sHTML = sHTML & "<td style='" & sStyle & "'>" & sLastRunActionHTML  & "&nbsp;</td>"  
            sHTML = sHTML & "<td style='" & sStyle & "'>" & sTime & "</td>"  
            'sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("Details") & "&nbsp;</td>"
            'sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("UserName") & "&nbsp;</td></tr>"    
            sHTML = sHTML & "<td style='vertical-align: top;" & sStyle & "'>" & sLastRunResultHTML  & "&nbsp;</td>"
            sHTML = sHTML & "<td style='vertical-align: top;" & sStyle & "'>" & rowset.value("LastRunMachine")  & "&nbsp;</td>"  
          else
            sHTML = sHTML & "<tr class='TableDetailCell' title='" & sToolTip & "' style='" & sStyle & "'>"
            sHTML = sHTML & "<td align='left' width='10px' style='" & sStyle & "'>" & sSelectHTML & "</td><td style='vertical-align: middle;" & sStyle & "'><img alt='" & sToolTip & "' border='0' height='16' src= '" & sIcon & "' align='absmiddle' width='16'>&nbsp;<strong>" & rowset.value("EventDisplayName") & "</strong></td>"
            sHTML = sHTML & "<INPUT Type='Hidden' Name='" & rowset.value("EventDisplayName") & "' value='" & sStatusCode & "'>"
            sHTML = sHTML & "</td>"
            sHTML = sHTML & "<td style='" & sStyle & "'>" & sInstanceId & "</td>"  
            'sHTML = sHTML & "<td style='vertical-align: top;" & sStyle & "'>" & rowset.value("RunStart")  & "&nbsp;</td>"  
            'sHTML = sHTML & "<td style='vertical-align: top;" & sStyle & "'>" & rowset.value("RunEnd") & "&nbsp;</td>"  
            sHTML = sHTML & "<td style='" & sStyle & "'>" & sStatus & "</td>"  
            sHTML = sHTML & "<td style='" & sStyle & "'>" & sLastRunActionHTML  & "&nbsp;</td>"  
            sHTML = sHTML & "<td style='" & sStyle & "'>" & sTime & "</td>"  
            'sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("Details") & "&nbsp;</td>"
            'sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("UserName") & "&nbsp;</td></tr>"    
            sHTML = sHTML & "<td style='vertical-align: top;" & sStyle & "'>" & sLastRunResultHTML  & "&nbsp;</td>"
            sHTML = sHTML & "<td style='vertical-align: top;" & sStyle & "'>" & rowset.value("LastRunMachine")  & "&nbsp;</td>"  
          end if
          rowset.movenext

      loop 
    end if
    
    'sHTML = sHTML & "</TABLE><BR>" & vbNewLine
    
    getRecurringEventRunHTML = sHTML
END FUNCTION

FUNCTION getAvailableActionsHTML(rowset)
    dim sHTML
    dim bShowBackoutOption, bShowRunOption, bShowForceOption, bShowMarkAsNotReadyToRun, bShowRunLaterOption
    
    if rowset.recordcount=0 then
      getAvailableActionsHTML = ""
      exit function
    end if
    
    bShowBackoutOption=true
    bShowRunOption=true
    bShowRunLaterOption=true
    bShowForceOption=false
    bShowMarkAsNotReadyToRun=true

    if Service.Properties("IntervalStatus").Value = "Hard Closed" or Service.Properties("IntervalStatus").Value = "Open" then
      bShowBackoutOption=false
      bShowRunOption=false
      bShowRunLaterOption=false
      bShowForceOption=false
      bShowMarkAsNotReadyToRun=false
    end if
    
    sHTML = sHTML & "<tr class='TableHeader' style='background-color=silver;'><td align='center' colspan='15'>"    


    if bShowRunOption then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueXLarge' name='RunAdapters' onclick=""if (isAdapterSelected()) {mdm_PVBPageUpdateSelectedIDs(null);mdm_RefreshDialog(this);}else{window.alert('Please select one or more adapters');}"">" & "Run Adapter" &  "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueXLarge' name='EditMapping' onclick=""window.open('protoDefaultDialogFailedTransactionStatus.asp','', 'height=400,width=400, resizable=yes, scrollbars=yes, status=yes')"">" & "Backout Adapter" &  "</button>" & vbNewLine
    end if

    if bShowRunLaterOption then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueXLarge' name='RunAdaptersLater' onclick=""if (isAdapterSelected()) {mdm_PVBPageUpdateSelectedIDs(null);mdm_RefreshDialog(this);}else{window.alert('Please select one or more adapters');}"">" & "Run Adapter Later" &  "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueXLarge' name='EditMapping' onclick=''>" & "Run Adapter Later" &  "</button>" & vbNewLine
    end if
    
    if bShowBackoutOption then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueXLarge' name='ReverseAdapters' onclick=""if (isAdapterSelected()) {mdm_PVBPageUpdateSelectedIDs(null);mdm_RefreshDialog(this);}else{window.alert('Please select one or more adapters');}"">" & "Reverse Adapter" &  "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueXLarge' name='ReverseAdapters' onclick=''>" & "Reverse Adapter" &  "</button>" & vbNewLine
    end if

    if bShowBackoutOption then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueXLarge' name='ReverseAdaptersLater' onclick=""if (isAdapterSelected()) {mdm_PVBPageUpdateSelectedIDs(null);mdm_RefreshDialog(this);}else{window.alert('Please select one or more adapters');}"">" & "Reverse Adapter Later" &  "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueXLarge' name='ReverseAdaptersLater' onclick=''>" & "Reverse Adapter" &  "</button>" & vbNewLine
    end if

    if bShowMarkAsNotReadyToRun then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueXLarge' name='CancelPendingAction' onclick=""if (isAdapterSelected()) {mdm_PVBPageUpdateSelectedIDs(null);mdm_RefreshDialog(this);}else{window.alert('Please select one or more adapters');}"">" & "Cancel Submitted Action" &  "</button>" & vbNewLine
    else
      sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueXLarge' name='CancelPendingAction' onclick=""window.open('protoDefaultDialogFailedTransactionStatus.asp','', 'height=400,width=400, resizable=yes, scrollbars=yes, status=yes')"">" & "Cancel Submitted Action" &  "</button>" & vbNewLine
    end if  
    
    if bShowForceOption then
      sHTML = sHTML & "&nbsp;&nbsp;<button class='clsButtonBlueXLarge' name='ForceAdapters' onclick=""if (isAdapterSelected()) {mdm_PVBPageUpdateSelectedIDs(null);mdm_RefreshDialog(this);}else{window.alert('Please select one or more adapters');}"">" & "Force Run Adapter" &  "</button>" & vbNewLine
    else
      'sHTML = sHTML & "&nbsp;&nbsp;<button disabled class='clsButtonBlueLarge' name='ForceAdapters' onclick=""if (isAdapterSelected()) {mdm_PVBPageUpdateSelectedIDs(null);mdm_RefreshDialog(this);}else{window.alert('Please select one or more adapters');}"">" & "Force Run Adapter" &  "</button>" & vbNewLine
    end if
        
    sHTML = sHTML & "<BR>"

    sHTML = sHTML & "</td></tr></table>"
     
    getAvailableActionsHTML = sHTML
END FUNCTION

Function ForceHardClosed_Click(EventArg)

    Dim objUSM, bg
    Set objUSM = mom_GetUsageServerClientObject()

    objUSM.HardCloseBillingGroup(Form("BillingGroupID"))

    CheckError("")

    ForceHardClosed_Click = true
END FUNCTION

FUNCTION Refresh_Click(EventArg) ' As Boolean
  Refresh_Click=true
END FUNCTION

FUNCTION AcknowledgeCheckPoint_Click(EventArg) ' As Boolean
  
  AcknowledgeCheckPoint_Click=false
  dim idRun
  idRun = clng(mdm_UIValue("mdmUserCustom"))
  
  dim bForceCheckpointAcknowledge
  if lcase(mom_GetDictionary("MOM_INTERVAL_MANAGEMENT_ALLOW_PREACKNOWLEDGE_OF_CHECKPOINTS"))="false" then
    bForceCheckpointAcknowledge = false
  else
    bForceCheckpointAcknowledge = true
  end if
    
  on error resume next
  dim objUSM
  set objUSM = mom_GetUsageServerClientObject
  if bForceCheckpointAcknowledge then
    objUSM.SubmitEventForExecution_2 idRun, true, ""
  else
    objUSM.SubmitEventForExecution idRun, ""
  end if

  If Not mom_CheckError("Acknowledge Checkpoint") Then Exit Function  
  objUSM.NotifyServiceOfSubmittedEvents
  
  AcknowledgeCheckPoint_Click = true
END FUNCTION

FUNCTION RunAdapters_Click(EventArg) ' As Boolean
  dim sAdapterList
  sAdapterList = mdm_UIValue("mdmSelectedIDs")

  response.Redirect "IntervalManagement.RunReverseAdapter.asp?Action=Run&BillingGroupID=" & Service.Properties("IntervalId") & "&ID=" & Service.Properties("IntervalId") & "&AdapterList=" & server.urlencode(sAdapterList) & "&ReturnURL=" & server.urlencode("IntervalManagement.ViewEdit.asp")
  
  RunAdapters_Click = true
END FUNCTION

FUNCTION ForceAdapters_Click(EventArg) ' As Boolean

  dim sAdapterList
  sAdapterList = mdm_UIValue("mdmSelectedIDs")

  response.Redirect "IntervalManagement.RunReverseAdapter.asp?Action=Run&Force=true&ID=" & Service.Properties("IntervalId") & "&AdapterList=" & server.urlencode(sAdapterList) & "&ReturnURL=" & server.urlencode("IntervalManagement.ViewEdit.asp")
  
  ForceAdapters_Click = true
END FUNCTION

FUNCTION RunAdaptersLater_Click(EventArg) ' As Boolean
  
  dim sAdapterList
  sAdapterList = mdm_UIValue("mdmSelectedIDs")

  response.Redirect "IntervalManagement.RunReverseAdapterLater.asp?Action=Run&ID=" & Service.Properties("IntervalId") & "&AdapterList=" & server.urlencode(sAdapterList) & "&ReturnURL=" & server.urlencode("IntervalManagement.ViewEdit.asp")
  
  RunAdaptersLater_Click = true
END FUNCTION

FUNCTION ReverseAdapters_Click(EventArg) ' As Boolean

  dim sAdapterList, arrAdapterList, i
  sAdapterList = mdm_UIValue("mdmSelectedIDs")

  response.Redirect "IntervalManagement.RunReverseAdapter.asp?Action=Reverse&ID=" & Service.Properties("IntervalId") & "&AdapterList=" & server.urlencode(sAdapterList) & "&ReturnURL=" & server.urlencode("IntervalManagement.ViewEdit.asp")

  ReverseAdapters_Click = true
END FUNCTION

FUNCTION ReverseAdaptersLater_Click(EventArg) ' As Boolean
  
  dim sAdapterList, arrAdapterList, i
  sAdapterList = mdm_UIValue("mdmSelectedIDs")

  response.Redirect "IntervalManagement.RunReverseAdapterLater.asp?Action=Reverse&ID=" & Service.Properties("IntervalId") & "&AdapterList=" & server.urlencode(sAdapterList) & "&ReturnURL=" & server.urlencode("IntervalManagement.ViewEdit.asp")
 
  ReverseAdaptersLater_Click = true
END FUNCTION

FUNCTION CancelPendingAction_Click(EventArg) ' As Boolean
  
  CancelPendingAction_Click = true
  
  dim sAdapterList, arrAdapterList, i
  sAdapterList = mdm_UIValue("mdmSelectedIDs")

  if sAdapterList <> "" then
    dim objUSM
    set objUSM = mom_GetUsageServerClientObject
    arrAdapterList = split(sAdapterList, ",")
    for i = 0 to ubound(arrAdapterList)-1
      objUSM.CancelSubmittedEvent clng(arrAdapterList(i)), ""
      if not CheckError("") then
        CancelPendingAction_Click = false
        exit for
      end if
    next
  else
    '// No adapter selected
    CancelPendingAction_Click = false
  end if

  objUSM.NotifyServiceOfSubmittedEvents
  
END FUNCTION


PRIVATE FUNCTION Cancel_Click(EventArg) ' As Boolean
  Form.RouteTo = FrameWork.GetDictionary("INTERVAL_MANAGEMENT_SELECT_DIALOG") & "?MDMAction=" & MDM_ACTION_REFRESH & "&ID=" & Form("IntervalId")
  Cancel_Click = TRUE
End Function

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



