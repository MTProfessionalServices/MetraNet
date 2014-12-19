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

Form.Version = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.Modal                      = False

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.

  Form("AdapterList") = Request.QueryString("AdapterList")  
  Form("Action") = ucase(Request.QueryString("Action"))
  Form("ActionText") = Request.QueryString("Action")
                  
  Form.RouteTo	=  Request.querystring("ReturnURL")
  
  
  Service.Properties.Add "PageTitle"     , "string", 255, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "Comment"     , "string", 255, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "AdapterList"     , "string", 1024, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ADAPTER_LIST_HTML"     , "string", 50000, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ActionText"    , "string", 20, FALSE , Empty, eMSIX_PROPERTY_FLAG_NONE
  Service.Properties.Add "ActionDatetime"    , "string", 30   , FALSE, Empty

  Service.Properties("AdapterList").Value = Form("AdapterList")
  Service.Properties("ADAPTER_LIST_HTML").Value = getAdapterInformationHTML()
  
  Service.Properties("ActionDatetime").Value = mdm_Format(Framework.MetraTimeGMTNow(), mom_GetDictionary("DATE_TIME_FORMAT"))

  'Set the title for the page

  Service.Properties("PageTitle").Value = Form("ActionText") & " Adapter(s) At Scheduled Time"
  'Service.Properties("ActionText").Value = Form("ActionText")

  if Form("Action") = "RUN" then
    Service.Properties("PageTitle").Value = mom_GetDictionary("TEXT_RUN") 
    Form("ActionText") = mom_GetDictionary("TEXT_RUN") 
  else
    Service.Properties("PageTitle").Value = mom_GetDictionary("TEXT_REVERSE") 
    Form("ActionText") = mom_GetDictionary("TEXT_REVERSE") 
  end if

  Service.Properties("PageTitle").Value = Service.Properties("PageTitle").Value & mom_GetDictionary("TEXT_Adapter_At_Scheduled_Time") 

  'PopulateThePropertyComboBox
  
  Service.LoadJavaScriptCode  
  mdm_IncludeCalendar
  
	Form_Initialize = TRUE
END FUNCTION

FUNCTION getAdapterInformationHTML
    dim sHTML
    dim rowset

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
   
    '// Temporary hack... our rowset is coming back but cursor is not at begining
    if rowset.RecordCount>0 then
      rowset.MoveFirst
    end if
    
    if false then
      sHTML = DumpRowsetHTML(rowset)
      rowset.MoveFirst
      getAdapterInformationHTML = sHTML
      exit function
    end if

    
    dim sActionText
    if Form("Action") = "RUN" then
      sActionText = mom_GetDictionary("TEXT_You_have_selected_to_run_the_following_adapter")
    else
      sActionText = mom_GetDictionary("TEXT_You_have_selected_to_reverse_the_following_adapter")
    end if
    
    sHTML = sHTML & "<TABLE width='100%' BORDER='0'  CELLPADDING='0' CELLSPACING='0'>"        
    'sHTML = sHTML & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left' colspan='15'><strong><font size=2>" & sActionText & "</font></strong></td></tr>"    
    'sHTML = sHTML & "<tr class='TableHeader' style='vertical-align:bottom;background-color=#688ABA'><td align='left'>Adapter</td><td align='left'>&nbsp;</td></tr>"    

    if rowset.eof then
      sHTML = sHTML & "<tr class='TableDetailCell'><td colspan='4'>" & mom_GetDictionary("TEXT_No_adapter_instances_selected") & "</td></tr>"
    else  
      do while not rowset.eof 
          dim sToolTip, sAdapterName, sErrorMessage
          
          sAdapterName = "<img src='../localized/en-us/images/adapter.gif' width=16 align=absMiddle border=0>&nbsp;" & rowset.value("EventDisplayName")
          
          sHTML = sHTML & "<tr title='" & sToolTip & "'>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & sAdapterName & "</td>"
          'sHTML = sHTML & "<td style='vertical-align: top'>" & sErrorMessage & "</td></tr>"  
          rowset.movenext
      loop 
    end if
    
    sHTML = sHTML & "</TABLE><BR>" & vbNewLine

    getAdapterInformationHTML = sHTML

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

    'On Error Resume Next

  dim sAdapterList, arrAdapterList, i
  sAdapterList = Service.Properties("AdapterList").value

  mdm_TerminateDialogAndExecuteDialog "IntervalManagement.RunReverseAdapter.asp?Action=" & Form("Action") & "&AdapterList=" & server.urlencode(sAdapterList) & "&ReturnURL=" & server.urlencode(Form.RouteTo) & "&RunDate=" & server.urlencode(CDate(Service.Properties("ActionDatetime").Value))


  '//Submit them right now without checking dependencies  
  if false then
  if sAdapterList <> "" then
    dim objUSM
    set objUSM = mom_GetUsageServerClientObject
    arrAdapterList = split(sAdapterList, ",")
    for i = 0 to ubound(arrAdapterList)-1
      if ucase(Form("Action"))="RUN" then
        objUSM.SubmitEventForExecution_3 clng(arrAdapterList(i)), False, CDate(Service.Properties("ActionDatetime").value), ""
      else
        objUSM.SubmitEventForReversal_3 clng(arrAdapterList(i)), False, CDate(Service.Properties("ActionDatetime").value), ""
      end if
    next
  else
    '// No adapter selected
  end if
  end if
  
  OK_Click = TRUE

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



