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
Form.RouteTo			              = "/mom/default/dialog/ScheduledAdapter.Run.List.asp"

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

  Framework.AssertCourseCapability "Manage Usage Intervals And Scheduled Adapters", EventArg

	Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
                  
  Service.Properties.Add "ADAPTER_LIST_HTML"      , "string", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE

	Form_Initialize = form_Refresh(EventArg)
END FUNCTION

FUNCTION form_Refresh(EventArg)

  Service.Properties("ADAPTER_LIST_HTML") = getScheduledAdapterListHTML

form_Refresh=true

END FUNCTION

FUNCTION getScheduledAdapterListHTML
    dim sHTML
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  	rowset.Init "queries\mom"
    rowset.SetQueryTag("__GET_SCHEDULED_ADAPTER_LIST_WITH_RUNTIME__")
    'rowset.SetQueryString("select evt.id_event as 'EventId', evt.tx_display_name as 'Display Name', evt.tx_name as 'Name', evt.tx_desc as 'Description', max(evi.dt_arg_end) as 'InstanceLastArgEndDate' from t_recevent evt left join t_recevent_inst evi on evt.id_event=evi.id_event where evt.tx_type = 'Scheduled' AND   evt.dt_activated <= %%%SYSTEMDATE%%% AND (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) group by evt.id_event, evt.tx_display_name, evt.tx_name, evt.tx_desc order by evt.tx_display_name")
  	rowset.Execute
  
    'sHTML = DumpRowsetHTML(rowset)
    'exit function
    'rowset.movefirst 
  
    sHTML = sHTML & "<TABLE width='100%' BORDER='0'  cellspacing='1' cellpadding='2'>"        
    'sHTML = sHTML & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left' colspan='5'>Scheduled Adapters</td></tr>"    
    sHTML = sHTML & "<tr class='TableHeader' style='background-color=#688ABA'><td valign='bottom' align='left'><input type='checkbox' name='selectAllAdapters' value='' onClick='DoSelectAllAdapters(this);'></td><td valign='bottom' align='left'>Adapter</td><td align='left'>Start Date For<BR>New Instance</td><td valign='bottom' align='left'>Description</td></tr>"    

    if rowset.eof then
      sHTML = sHTML & "<tr class='TableDetailCell'><td colspan='4'>No scheduled adapters currently in the system.</td></tr>"
    else  
      do while not rowset.eof 
          dim sToolTip,sSelectHTML
          sSelectHTML = "<input type='checkbox' name='MDM_CB_" & rowset.value("EventID") & "' value=''>"

          'sToolTip = rowset.value("Details")
          sHTML = sHTML & "<tr class='TableDetailCell' title='" & sToolTip & "'><td style='vertical-align: top'>" & sSelectHTML & "</td>"
          sHTML = sHTML & "<td style='vertical-align: top' nowrap><strong>" & "<img alt='' border='0' src= '" & "../localized/en-us/images/adapter_scheduled.gif" & "' align='absmiddle'>&nbsp;" & rowset.value("Display Name") & "</strong></td>"  
          sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("InstanceLastArgEndDate") & "&nbsp;</td>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("Description") & "&nbsp;</td></tr>"
          rowset.movenext
      loop 
    end if
    
    sHTML = sHTML & "</TABLE><BR>" & vbNewLine
    
    getScheduledAdapterListHTML = sHTML
END FUNCTION


FUNCTION RunAdapters_Click(EventArg) ' As Boolean

  dim sAdapterList, arrAdapterList, i
  sAdapterList = mdm_UIValue("mdmSelectedIDs")

  if sAdapterList <> "" then
    dim objUSM, idInstance
    set objUSM = mom_GetUsageServerClientObject
    arrAdapterList = split(sAdapterList, ",")
    for i = 0 to ubound(arrAdapterList)-1
      idInstance = objUSM.InstantiateScheduledEvent(arrAdapterList(i))
      objUSM.SubmitEventForExecution idInstance, ""
      'objUSM.SubmitEventForReversal_3 clng(arrAdapterList(i)), False, CDate(Service.Properties("ActionDatetime").value), ""
    next

    objUSM.NotifyServiceOfSubmittedEvents

  else
    '// No adapter selected
  end if
  
  mdm_TerminateDialogAndExecuteDialog Form.RouteTo
  
  RunAdapters_Click = true
END FUNCTION

%>


