<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: BatchManagement.UpdateStatus.asp$
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
'  $Date: 11/13/2002 5:45:45 PM$
'  $Author: Rudi Perkins$
'  $Revision: 7$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

PRIVATE CONST enum_FT_BULK_CHANGE_ALL                   = 1
PRIVATE CONST enum_FT_BULK_CHANGE_IF_PREVIOUS_VALUE_IS  = 2

dim gDebug
gDebug = false

dim gIssueWithAdapter
dim gIssueWithAdapterDependency
dim gIssueWithAdapterDependencyOtherThanAdditionalWork 
dim gIssueWithAdapterDependencyOnlyCanContinueByForcing 'Indicates we can continue but only by forcing single adapter

Form.Version = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.Modal                      = FALSE
Form.ErrorHandler               = FALSE

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean
  Form("IntervalId") = request.querystring("ID")
  
	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  Form("AdapterList") = Request.QueryString("AdapterList")                  
  Form.RouteTo	= Request.querystring("ReturnURL")
  Form("Action") = ucase(Request.QueryString("Action"))  
  Form("ActionText") = Request.QueryString("Action")                  
  Form("RunDate") = Request.QueryString("RunDate")
  
  if ucase(request.querystring("Force"))="TRUE" then
    Form("Force") = true
  else
    Form("Force") = false
  end if
  
  Service.Properties.Add "PageTitle"     , "string", 255, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "Comment"     , "string", 255, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "AdapterList"     , "string", 0, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "AdapterListCount"     , "int", 0, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "AdditionalAdapterList"     , "string", 0, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "RunDate"    , MSIXDEF_TYPE_TIMESTAMP, 0   , FALSE, Empty
  Service.Properties.Add "ERROR_WARNING_MESSAGE"     , "string", 0, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ADAPTER_LIST_HTML"     , "string", 0, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ForceAdapters", "Boolean",  0, False, TRUE 
  
  Service.Properties("AdapterList").Value = Form("AdapterList")
  Service.Properties("ForceAdapters").Value = Form("Force")

  Service.Properties("RunDate").Value = Form("RunDate")
  
  'Set the title for the page

  if Form("Action") = "RUN" then
    Service.Properties("PageTitle").Value = mom_GetDictionary("TEXT_RUN_ADAPTER") 
  else
    Service.Properties("PageTitle").Value = mom_GetDictionary("TEXT_REVERCE_ADAPTER") 
  end if

  gIssueWithAdapter = false
  gIssueWithAdapterDependency = false
  gIssueWithAdapterDependencyOtherThanAdditionalWork = false
  gIssueWithAdapterDependencyOnlyCanContinueByForcing = false
  
  Service.Properties("ADAPTER_LIST_HTML").Value = getAdapterInformationHTML()

  'See if we can only continue by forcing single adapter
  if gIssueWithAdapterDependencyOnlyCanContinueByForcing then
    if Service.Properties("AdapterListCount").Value = 1 then
      Service.Properties("ForceAdapters").Value = true
      Service.Properties("ForceAdapters").Enabled = false
      mdm_GetDictionary().Add "ADAPTER_RUN_REVERSE_SHOW_CAN_CONTINUE_ONLY_BY_FORCING_MESSAGE", 1
    else
      'We have more than one adapter, can't continue
      gIssueWithAdapterDependencyOtherThanAdditionalWork = true
      mdm_GetDictionary().Add "ADAPTER_RUN_REVERSE_SHOW_CAN_CONTINUE_ONLY_BY_FORCING_MESSAGE", 0
    end if
  else
    mdm_GetDictionary().Add "ADAPTER_RUN_REVERSE_SHOW_CAN_CONTINUE_ONLY_BY_FORCING_MESSAGE", 0
  end if
  
  if gIssueWithAdapter or gIssueWithAdapterDependency or gDebug then
    if ucase(Form("Action"))="RUN" then
      if gIssueWithAdapter or gIssueWithAdapterDependencyOtherThanAdditionalWork then
        Service.Properties("ERROR_WARNING_MESSAGE").Value = mom_GetDictionary("TEXT_RUN_ERROR_WARNING_MESSAGE_1")
      else
        Service.Properties("ERROR_WARNING_MESSAGE").Value = mom_GetDictionary("TEXT_RUN_ERROR_WARNING_MESSAGE_2")
      end if  
    else
      if gIssueWithAdapter or gIssueWithAdapterDependencyOtherThanAdditionalWork then
        Service.Properties("ERROR_WARNING_MESSAGE").Value = mom_GetDictionary("TEXT_RUN_ERROR_WARNING_MESSAGE_3")
      else
        Service.Properties("ERROR_WARNING_MESSAGE").Value = mom_GetDictionary("TEXT_RUN_ERROR_WARNING_MESSAGE_4")
      end if
    end if
  
    '// Set these values for use by the MDM rendering
    mdm_GetDictionary().Add "ADAPTER_RUN_REVERSE_SHOW_MESSAGE", 1
    
    if gIssueWithAdapter or gIssueWithAdapterDependencyOtherThanAdditionalWork then
      mdm_GetDictionary().Add "ADAPTER_RUN_REVERSE_ERROR", 1
    else
      mdm_GetDictionary().Add "ADAPTER_RUN_REVERSE_ERROR", 0
    end if    
  else
    '// No errors or warnings so just run/reverse adapters and don't bother showing this dialog
    dim bActionResult
    bActionResult = RunReverseAdapters(EventArg)
    
    if bActionResult then
      mdm_TerminateDialogAndExecuteDialog Form.RouteTo
    else
      '// Error happened
    end if
    
    '// Because we store stuff in dictionary, need to reset even if they are not used this time around
    mdm_GetDictionary().Add "ADAPTER_RUN_REVERSE_SHOW_MESSAGE", 0
    mdm_GetDictionary().Add "ADAPTER_RUN_REVERSE_ERROR", 0
    mdm_GetDictionary().Add "ADAPTER_RUN_REVERSE_SHOW_CAN_CONTINUE_ONLY_BY_FORCING_MESSAGE", 0
  end if
  
  'PopulateThePropertyComboBox
  
  Service.LoadJavaScriptCode  
  mdm_IncludeCalendar
  
	Form_Initialize = TRUE
END FUNCTION

FUNCTION getAdapterInformationHTML
    dim sHTML
    dim rowset
    'set rowset = mom_GetAdapterRunReverseStatus(Form("Action"), left(Form("AdapterList"),len(Form("AdapterList"))-1))

    dim bRunning
    bRunning=(ucase(Form("Action"))="RUN")
    
    dim objUSM
    set objUSM = mom_GetUsageServerClientObject()
    
    dim objUSMInstances
  	set objUSMInstances = CreateObject("MetraTech.UsageServer.RecurringEventInstanceFilter")
    
        Dim arrInstances, i
        arrInstances = Split(Service.Properties("AdapterList").Value, ",") 
        
        For i = 0 to ubound(arrInstances)-1
          objUSMInstances.AddInstanceCriteria arrInstances(i)
        Next
   objUSMInstances.LanguageId = FrameWork.SessionContext.LanguageId   
   objUSMInstances.Apply

  
   'Set rowset= objUSM.GetCanExecuteEventDepsRowset((objUSMInstances))
   if bRunning then
    Set rowset=objUSM.GetCanExecuteEventRowset((objUSMInstances))
   else
    Set rowset=objUSM.GetCanReverseEventRowset((objUSMInstances))
   end if

   '//Use this to get the count of adapters that was selected
   Service.Properties("AdapterListCount").Value = rowset.RecordCount
     
    '// Temporary hack... our rowset is coming back but cursor is not at begining
    if rowset.RecordCount>0 then
      rowset.MoveFirst
    end if
    
    if gDebug then
      sHTML = DumpRowsetHTML(rowset)
      rowset.MoveFirst
    end if

    dim sActionText
    if Form("Action") = "RUN" then
      sActionText = mom_GetDictionary("TEXT_You_have_selected_to_run_the_following_adapter")
    else
      sActionText = mom_GetDictionary("TEXT_You_have_selected_to_reverse_the_following_adapter")
    end if
    
    sHTML = sHTML & "<TABLE width='100%' BORDER='0'  CELLPADDING='0' CELLSPACING='0'>"        
    sHTML = sHTML & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left' colspan='15'><strong><font size=2>" & sActionText & "</font></strong></td></tr>"    
    sHTML = sHTML & "<tr class='TableHeader' style='vertical-align:bottom;background-color=#688ABA'><td align='left'>" & mom_GetDictionary("TEXT_Adapter") & "</td><td align='left'>&nbsp;</td></tr>"    

    if rowset.eof then
      sHTML = sHTML & "<tr class='TableDetailCell'><td colspan='4'>" & mom_GetDictionary("TEXT_No_adapter_instances_selected") & "</td></tr>"
    else  
      do while not rowset.eof 
          dim sToolTip, sAdapterName, sErrorMessage, sIntervalInstanceMessage
          
          sAdapterName = "<img src='../localized/en-us/images/adapter.gif' width=16 align=absMiddle border=0>&nbsp;" & rowset.value("EventDisplayName")
          
          if isNull(rowset.value("Reason")) then
            sErrorMessage="&nbsp;"
          else
            dim sReason
            sReason = RTRIM(LTRIM(rowset.value("Reason")))
            '// Hack until rowset returns "OK" when reversing
            if not bRunning and sReason="Succeeded" then sReason="OK" end if
            if sReason<>"OK" then
              sErrorMessage = "<IMG SRC='/mcm/default/localized/en-us/images/icons/warningSmall.gif' align='center' BORDER='0' >&nbsp;" & mom_GetAdapterRunReverseStatusErrorMessage(sReason)
              gIssueWithAdapter = true
            else
              sErrorMessage="&nbsp;"
            end if
          end if
          
          'sToolTip = "Run Id: " & rowset.value("id_run") & vbNewLine & "Reversed Run Id: " & rowset.value("id_reversed_run")
          sHTML = sHTML & "<tr class='TableDetailCell' title='" & sToolTip & "'>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & sAdapterName & "</td>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & sErrorMessage & "</td></tr>"  
          rowset.movenext
      loop 
    end if
    
    sHTML = sHTML & "</TABLE><BR>" & vbNewLine


    dim sAdditionalAdapterList
    
    if bRunning then
      Set rowset= objUSM.GetCanExecuteEventDepsRowset((objUSMInstances))
    else
      Set rowset= objUSM.GetCanReverseEventDepsRowset((objUSMInstances))
    end if

    '// Temporary hack... our rowset is coming back but cursor is not at begining
    if rowset.RecordCount>0 then
      rowset.MoveFirst
    end if
      
    if gDebug then
      sHTML = sHTML & DumpRowsetHTML(rowset)
      if rowset.RecordCount>0 then
        rowset.MoveFirst
      end if
    end if
    
    if rowset.eof then
      gIssueWithAdapterDependency=false
      gIssueWithAdapterDependencyOtherThanAdditionalWork=false
    else
      gIssueWithAdapterDependency=true
      gIssueWithAdapterDependencyOtherThanAdditionalWork=false
      
      if Form("Action") = "RUN" then
        sActionText = mom_GetDictionary("TEXT_Because_of_run") 
      else
        sActionText = mom_GetDictionary("TEXT_Because_of_reverce") 
      end if
      sHTML = sHTML & "<TABLE width='100%' BORDER='0'  CELLPADDING='0' CELLSPACING='0'>"        
      sHTML = sHTML & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left' colspan='15'><strong><font size=2>" & sActionText & "</font></strong></td></tr>"    
      sHTML = sHTML & "<tr class='TableHeader' style='vertical-align:bottom;background-color=#688ABA'><td align='left'>" & mom_GetDictionary("TEXT_Adapter") & "</td><td align='left'>&nbsp;</td></tr>"    

      do while not rowset.eof 
          dim sEventType
          sEventType = UCASE(rowset.value("EventType"))
          
          select case sEventType
          case "CHECKPOINT"
            sAdapterName = "<img src='../localized/en-us/images/adapter_checkpoint.gif' width=16 align=absMiddle border=0>&nbsp;" & rowset.value("EventDisplayName")
          case "SCHEDULED"
            sAdapterName = "<img src='../localized/en-us/images/adapter_scheduled.gif' align=absMiddle border=0>&nbsp;" & rowset.value("EventDisplayName") & " (Scheduled Adapter)"
          case else
            sAdapterName = "<img src='../localized/en-us/images/adapter.gif' width=16 align=absMiddle border=0>&nbsp;" & rowset.value("EventDisplayName")
          end select
         

          sErrorMessage=""    
          if NOT isNull(rowset.value("Status")) then
            '//dim sReason
            sReason = RTRIM(LTRIM(rowset.value("Status")))
          
            if (bRunning and sReason<>"NotYetRun" and sReason<>"Missing") or ((not bRunning) and sReason <> "Succeeded" and sReason <> "ReadyToRun" and sReason <> "Failed") then
              if (sReason="NotCreated") then
                sErrorMessage = "<IMG SRC='/mcm/default/localized/en-us/images/icons/warningSmall.gif' align='center' BORDER='0' >&nbsp;" & mom_GetAdapterRunReverseStatusErrorMessage(sReason) & "[" & rowset.value("BillGroupName") & "]"
              else
                sErrorMessage = "<IMG SRC='/mcm/default/localized/en-us/images/icons/warningSmall.gif' align='center' BORDER='0' >&nbsp;" & mom_GetAdapterRunReverseStatusErrorMessage(sReason)
              end if
              gIssueWithAdapterDependencyOtherThanAdditionalWork = true
            else
              if (not bRunning) then
                if rowset.value("ReverseMode")="NotImplemented" and sReason<>"ReadyToRun" then
                  sErrorMessage = "<IMG SRC='/mcm/default/localized/en-us/images/icons/warningSmall.gif' align='center' BORDER='0' >&nbsp;" & mom_GetAdapterRunReverseStatusErrorMessage("NotImplemented")
                  gIssueWithAdapterDependencyOtherThanAdditionalWork = true
		            end if
              end if
                  
              '// This is just a warning about additional work
              if bRunning then
                '// We are running, what are the additional corrective actions?              
                select case sReason
                case "Missing"
                  if sEventType = "SCHEDULED" then
                    sErrorMessage =  mom_GetDictionary("TEXT_Missing_SCHEDULED_ERROR_1") & rowset.value("ArgStartDate") & mom_GetDictionary("TEXT_Missing_SCHEDULED_ERROR_2") & rowset.value("ArgEndDate") & mom_GetDictionary("TEXT_Missing_SCHEDULED_ERROR_3") & rowset.value("ArgEndDate")
                    sAdditionalAdapterList = sAdditionalAdapterList & rowset.value("EventId") & " CREATE " & rowset.value("ArgEndDate") & ","
                  else
                    'There might be additional intervals that are not closed or have adapter instances created, if this is the case then we cannot continue normally
                    if IsNull(rowset.value("InstanceId")) then
                      gIssueWithAdapterDependencyOnlyCanContinueByForcing = true
                    else
                      sAdditionalAdapterList = sAdditionalAdapterList & rowset.value("InstanceId") & " RUN" & IIF(sEventType="CHECKPOINT","CHECKPOINT","") & ","
                    end if
                  end if                 
                case "ReadyToReverse"
                 sErrorMessage = mom_GetDictionary("TEXT_ReadyToReverse_ERROR")
                 sAdditionalAdapterList = sAdditionalAdapterList & rowset.value("InstanceId") & " CANCEL,"
                case "NotYetRun"
                  sAdditionalAdapterList = sAdditionalAdapterList & rowset.value("InstanceId") & " RUN" & IIF(sEventType="CHECKPOINT","CHECKPOINT","") & ","
                case else
                  sErrorMessage="Unknown Action for [" & sReason & "] when running"
                  gIssueWithAdapterDependencyOtherThanAdditionalWork = true
                end select
                                                          
              else
                '// We are reversing, what are the additional corrective actions
                select case sReason
                case "Succeeded", "Failed"
                  sAdditionalAdapterList = sAdditionalAdapterList & rowset.value("InstanceId") & " REVERSE" & IIF(UCASE(rowset.value("EventType"))="CHECKPOINT","CHECKPOINT","") & ","
                case "ReadyToRun"
                 sErrorMessage = mom_GetDictionary("TEXT_ReadyToRun_ERROR")                 
                 sAdditionalAdapterList = sAdditionalAdapterList & rowset.value("InstanceId") & " CANCEL,"
                case else
                  sErrorMessage="Unknown Action for [" & sReason & "] when reversing"
                  gIssueWithAdapterDependencyOtherThanAdditionalWork = true
                end select
              end if
              
              'Construct Message with Interval and Instance Information
              dim sTemp
              sTemp=""
              if Not IsNull(rowset.value("ArgIntervalID")) then
                if Form("IntervalId") <> CStr(rowset.value("ArgIntervalID")) then
                  if bRunning then
                    sTemp = mom_GetDictionary("TEXT_In_a_previous_interval") & rowset.value("ArgIntervalID") & mom_GetDictionary("TEXT_the_adapter_was_not_run")
                  else
                    sTemp = mom_GetDictionary("TEXT_In_an_interval") & rowset.value("ArgIntervalID") & mom_GetDictionary("TEXT_after_this_interval_the_adapter_was_not_reversed")
                  end if
                end if
              end if
              if IsNull(rowset.value("InstanceID")) then
                if sEventType <> "SCHEDULED" then
                  sErrorMessage = sErrorMessage & "<IMG SRC='/mcm/default/localized/en-us/images/icons/warningSmall.gif' align='center' BORDER='0' >&nbsp;" & sTemp & mom_GetDictionary("TEXT_Instance_doesnt_exist")
                end if
              else
                sErrorMessage = sErrorMessage & sTemp & mom_GetDictionary("TEXT_Instance") & rowset.value("InstanceID") & "&nbsp; &nbsp; &nbsp; &nbsp; " & mom_GetDictionary("TEXT_Billing_Group") & rowset.value("BillGroupName")
              end if

            end if
          end if
          
          if len(sErrorMessage) = 0 then
            sErrorMessage = "&nbsp;"
          end if
          
          'sToolTip = "Run Id: " & rowset.value("id_run") & vbNewLine & "Reversed Run Id: " & rowset.value("id_reversed_run")
          sHTML = sHTML & "<tr class='TableDetailCell' title='" & sToolTip & "'>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & sAdapterName & "</td>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & sErrorMessage & "</td></tr>"  
          rowset.movenext
      loop 
    end if
    
    sHTML = sHTML & "</TABLE><BR>" & vbNewLine

    Service.Properties("AdditionalAdapterList").Value = sAdditionalAdapterList
    
    getAdapterInformationHTML = sHTML
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean
  mdm_TerminateDialogAndExecuteDialog Form.RouteTo
END FUNCTION

FUNCTION ProceedWithWarnings_Click(EventArg) ' As Boolean

  if RunReverseAdapters(EventArg) then
    mdm_TerminateDialogAndExecuteDialog Form.RouteTo
    ProceedWithWarnings_Click = true '// We won't get here
  else
    '// Error
    ProceedWithWarnings_Click = false
  end if
END FUNCTION

FUNCTION RunReverseAdapters(EventArg) ' As Boolean

  RunReverseAdapters = false

  dim sAdapterList, arrAdapterList, i, sAdapterAction, arrAdapterInformation, sAction, idInstance, sDate
  sAdapterList = Service.Properties("AdapterList").value
  // If we are not forcing, then run/reverse/cancel any additional adapters from the dependency list
  if not Service.Properties("ForceAdapters").value then
    sAdapterList = sAdapterList & Service.Properties("AdditionalAdapterList").value
  end if
  
  if sAdapterList <> "" then
    dim objUSM
    set objUSM = mom_GetUsageServerClientObject()
    set objUSM.SessionContext=FrameWork.SessionContext
    
    on error resume next
    arrAdapterList = split(sAdapterList, ",")
    for i = 0 to ubound(arrAdapterList)-1
      arrAdapterInformation = split(arrAdapterList(i), " ")
      select case ubound(arrAdapterInformation)
      case 0
        idInstance = Clng(arrAdapterInformation(0))
        sAction = ucase(Form("Action"))
        sDate = ""
      case 1
        idInstance = Clng(arrAdapterInformation(0))
        sAction = arrAdapterInformation(1)
        sDate = ""
      case 2,3,4
        idInstance = Clng(arrAdapterInformation(0))
        sAction = arrAdapterInformation(1)
        '// Now we need to parse and glue the date back together accounting for different date/formats
        sDate = arrAdapterInformation(2)
        if ubound(arrAdapterInformation)>=3 then
          sDate = sDate & " " & arrAdapterInformation(3)
        end if
        if ubound(arrAdapterInformation)=4 then
          sDate = sDate & " " & arrAdapterInformation(4)
        end if
        
      case else
        '// Format is incorrect
      end select
      
      dim bForce, bDoLater
      bForce = Service.Properties("ForceAdapters").value
      bDoLater = len(Form("RunDate"))>0  '// Were we passed a date for run later?
      
      select case sAction
      case "RUN","RUNCHECKPOINT"
        if sAction="RUNCHECKPOINT" then
          bForce = true
        end if
        '// Submit For Run
        if bDoLater then
          objUSM.SubmitEventForExecution_3 idInstance, bForce, CDate(Service.Properties("RunDate").value), ""
        else
          objUSM.SubmitEventForExecution_2 idInstance, bForce, ""
        end if
        If Not mom_CheckError("SubmitEventForExecution") Then Exit Function  

        objUSM.NotifyServiceOfSubmittedEvents
      case "REVERSE", "REVERSECHECKPOINT"
        if sAction="REVERSECHECKPOINT" then
          bForce = true
        end if
        '// Submit For Reverse
        if bDoLater then
          objUSM.SubmitEventForReversal_3 idInstance, bForce, CDate(Service.Properties("RunDate").value), ""
        else
          objUSM.SubmitEventForReversal_2 idInstance, bForce, ""
        end if
        If Not mom_CheckError("SubmitEventForReversal") Then Exit Function  
        objUSM.NotifyServiceOfSubmittedEvents
      case "CANCEL"
        objUSM.CancelSubmittedEvent idInstance, ""
        If Not mom_CheckError("CancelSubmittedEvent") Then Exit Function  
        objUSM.NotifyServiceOfSubmittedEvents        
      case "CREATE"
        '// In this case, we need to run a scheduled adapter where no instance has been created
        '// The idInstance variable actually holds the event id to start with
        idInstance = objUSM.InstantiateScheduledEvent(idInstance)
        If Not mom_CheckError("InstantiateScheduledEvent") Then Exit Function  
        objUSM.SubmitEventForExecution_3 idInstance, False, CDate(sDate), ""     
        If Not mom_CheckError("SubmitEventForExecution") Then Exit Function  
        objUSM.NotifyServiceOfSubmittedEvents
      case else
        '//Invalid action
      end select 
    next
  else
    '// No adapter selected
  end if
  
  RunReverseAdapters = true
END FUNCTION


PRIVATE FUNCTION CheckError(sBackoutStep) ' As Boolean


    CheckError = FALSE
    If(Err.Number)Then 
        EventArg.Error.Save Err 
        EventArg.Error.Description = EventArg.Error.Description & "; Step=" & sBackoutStep
        Err.Clear 
        Exit Function
    End If        
    CheckError = TRUE
    
    ' Wait a second to be sure that all action hace a different dt_action
    Dim objWinApi
    Set objWinApi = Server.CreateObject(CWindows)
    objWinApi.Sleep 1
END FUNCTION

%>



