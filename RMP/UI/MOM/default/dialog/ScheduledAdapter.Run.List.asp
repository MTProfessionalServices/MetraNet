 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: IntervalManagement.List.asp$
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
'  $Date: 10/29/2002 3:06:25 PM$
'  $Author: Rudi Perkins$
'  $Revision: 3$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : 
' DESCRIPTION : 
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"          -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->

<%
Form.Version                    = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler               = TRUE
Form.ShowExportIcon             = TRUE
'Form.Page.MaxRow                = CLng(FrameWork.GetDictionary("MAX_ROW_PER_LIST_PAGE"))
'Form.Page.NoRecordUserMessage   = FrameWork.GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

public iState

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Framework.AssertCourseCapability "Manage Scheduled Adapters", EventArg

    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    MDMListDialog.Initialize EventArg
    Form("NextPage")  = "AdapterManagement.Instance.ViewEdit.asp"
    Form("Parameters") = "ReturnUrl|" & Server.UrlEncode("ScheduledAdapter.Run.List.asp?MDMAction=" & MDM_ACTION_REFRESH)
    Form("LinkColumnMode")        = TRUE
    Form("IDColumnName")          = "InstanceId"
    
    Form("duration") = Request.QueryString("duration")
    
    'response.write(Service.Properties.ToString)
    'response.end
    'Form("Intervals")=request("Intervals")
    
	  Form_Initialize = true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
  
  dim rowset
  'set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	'rowset.Init "queries\audit"
  'rowset.SetQueryString("select ins.id_instance as 'InstanceId', r.id_run as 'RunId', ev.tx_display_name as 'DisplayName', ins.dt_arg_start as 'ArgStart',ins.dt_arg_end as 'ArgEnd', r.tx_status as 'Status', r.tx_detail as 'Details', r.dt_start as 'RunStart', r.dt_end as 'RunEnd' from t_recevent_run r left join t_recevent_inst ins on ins.id_instance = r.id_instance join t_recevent ev on ev.id_event = ins.id_event where ev.tx_type = 'Scheduled' and DATEDIFF(hh, ins.dt_arg_end, getUTCdate())<1024 order by ins.dt_arg_end")
	'rowset.Execute

  'evt.id_event EventID,
  'evt.tx_name EventName,
  'evt.tx_display_name EventDisplayName,
  'evt.tx_type EventType,
  'evt.tx_reverse_mode ReverseMode,
  'evt.tx_class_name ClassName,
  'evt.tx_config_file ConfigFile,
  'evt.tx_desc EventDescription,
  'inst.id_instance InstanceID,
  'inst.dt_arg_start ArgStartDate,
  'inst.dt_arg_end ArgEndDate,
  'inst.b_ignore_deps IgnoreDeps,
  'inst.dt_effective EffectiveDate,    
  'inst.tx_status Status,
  'run.id_run LastRunID,
  'run.tx_type LastRunAction,
  'run.dt_start LastRunStart,
  'run.dt_end LastRunEnd,
  'run.tx_status LastRunStatus,
  'run.tx_detail LastRunDetail,
  'ISNULL(batch.total, 0) LastRunBatches,
  'COUNT(dep.id_event) TotalDeps,
  'ISNULL(warnings.total, 0) LastRunWarnings
  
  dim objUSMInstances
	set objUSMInstances = Server.CreateObject("MetraTech.UsageServer.RecurringEventInstanceFilter")

  if Len(Form("duration")) > 0 then
    dim duration
    duration = CLng(Form("duration"))
    objUSMInstances.StartDate = DateAdd("h", duration, FrameWork.MetraTimeGMTNow())
  end if
  
  set rowset = objUSMInstances.GetScheduledRowset()    
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  ProductView.Properties.AddPropertiesFromRowset rowset
  'stop

  'ProductView.Properties.SelectAll
  ProductView.Properties.ClearSelection ' Select the properties I want to print in the PV Browser Order
  dim i
  i = 1
  
  ProductView.Properties("InstanceId").Selected     = i : i=i+1
  'ProductView.Properties("RunId").Selected          = i : i=i+1    
  ProductView.Properties("EventDisplayName").Selected    = i : i=i+1    
  ProductView.Properties("Status").Selected         = i : i=i+1    
  ProductView.Properties("ArgStartDate").Selected       = i : i=i+1    
  ProductView.Properties("ArgEndDate").Selected       = i : i=i+1 
  ProductView.Properties("LastRunStart").Selected       = i : i=i+1
  ProductView.Properties("LastRunMachine").Selected       = i : i=i+1         
  'ProductView.Properties("RunEnd").Selected         = i : i=i+1    

  ProductView.Properties("InstanceId").Caption = "InstanceId"
  ProductView.Properties("EventDisplayName").Caption = "EventDisplayName"
  ProductView.Properties("Status").Caption = "Status"
  ProductView.Properties("ArgStartDate").Caption = "ArgStartDate"
  ProductView.Properties("ArgEndDate").Caption = "ArgEndDate"
  ProductView.Properties("LastRunStart").Caption = "LastRunStart"
  ProductView.Properties("LastRunMachine").Caption = "LastRunMachine"
  
  ProductView.Properties("ArgStartDate").Sorted = MTSORT_ORDER_DESCENDING
  
  'ProductView.Properties.CancelLocalization
  
  ProductView.LoadJavascriptCode
  
  mdm_SetMultiColumnFilteringMode TRUE 
          
  Form_LoadProductView                                  = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION


PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

       if Form.Grid.Col<=3 then
          Form_DisplayCell = LinkColumnMode_DisplayCell(EventArg)
       else
         Select Case lcase(Form.Grid.SelectedProperty.Name)
         Case "lastrunstart"
            dim lastRunStart
            lastRunStart = mdm_Format(ProductView.Properties.RowSet.Value("LastRunStart"),mom_GetDictionary("DATE_TIME_FORMAT"))
            EventArg.HTMLRendered =  "<td class='" & Form.Grid.CellClass & "'>" & lastRunStart & "</td>" 
  			    Form_DisplayCell = TRUE
         Case "argstartdate"
            dim argStartdate
            argStartdate = mdm_Format(ProductView.Properties.RowSet.Value("ArgStartDate"),mom_GetDictionary("DATE_TIME_FORMAT"))
            EventArg.HTMLRendered =  "<td class='" & Form.Grid.CellClass & "'>" & argStartdate & "</td>" 
  			    Form_DisplayCell = TRUE
         Case "argenddate"
            dim argEnddate
            argEnddate = mdm_Format(ProductView.Properties.RowSet.Value("ArgEndDate"),mom_GetDictionary("DATE_TIME_FORMAT"))
            EventArg.HTMLRendered =  "<td class='" & Form.Grid.CellClass & "'>" & argEnddate & "</td>"
  			    Form_DisplayCell = TRUE
  	     Case else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
      End Select
     end if

    Form_DisplayCell = true

END FUNCTION

PRIVATE FUNCTION xForm_DisplayDetailRow(EventArg) ' As Boolean

    Dim objProperty
    Dim strSelectorHTMLCode
    Dim strValue
    Dim strCurrency
    Dim strHTMLAttributeName

    'Set objProperty = ProductView.Properties.Item(Form.Grid.PropertyName)
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td></td><td></td>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td ColSpan=" & (ProductView.Properties.Count+2) & ">" & vbNewLine

    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<TABLE width='100%' border=0 cellpadding=1 cellspacing=0>" & vbNewLine

    'Render Recurring Event Adapter Information
    dim idCurrentInterval
    idCurrentInterval = ProductView.Properties.RowSet.Value("Interval")
    
    dim sIntervalType
    sIntervalType = ProductView.Properties.RowSet.Value("Type")
    
    dim sIntervalState
    
    
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.Init "queries\audit"
    'rowset.SetQueryTag("__SELECT_AUDIT_LOG__")  
    rowset.SetQueryString("select rer.id_interval as ""Interval"", rer.tx_adapter_name as ""Adapter"", rer.tx_adapter_method as ""Method"", rer.tx_config_file as ""ConfigFile"", rer.dt_start as ""Start Time"", rer.dt_end as ""End Time"" from t_recurring_event_run rer where rer.id_interval = " & idCurrentInterval)
    rowset.Execute
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr class='TableHeader'><td align='left' colspan='3'>Recurring Event Run Information</td></tr>"    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr class='TableHeader'><td align='left'>Adapter</td><td>Start Time</td><td>End Time</td></tr>"    

    if rowset.eof then
      EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr class='TableDetailCell'><td colspan='3'>No adapters have been run for this interval.</td></tr>"
    else  
      do while not rowset.eof 
          dim sToolTip
          sToolTip = "Component: " & rowset.value("method") & vbCRLF & "Config File: " & rowset.value("configfile")
          EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr class='TableDetailCell' title='" & sToolTip & "'><td><img src='../localized/en-us/images/adapter.gif' width='16' height='16' alt='" & sToolTip & "' border='0'>&nbsp;" & rowset.value("adapter") & "</td>"    '(" & rowset.value("method") & ")
          EventArg.HTMLRendered = EventArg.HTMLRendered & "<td>" & rowset.value("Start Time") & "</td>"
          EventArg.HTMLRendered = EventArg.HTMLRendered & "<td>" & rowset.value("End Time") & "</td></tr>"    
          rowset.movenext
      loop 
    end if
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</TABLE>" & vbNewLine
    
    if ucase(mdm_GetDictionary().Item("INTERVAL_MANAGEMENT_ADVANCED_USER"))="TRUE" then
      EventArg.HTMLRendered = EventArg.HTMLRendered & "<br>&nbsp;&nbsp;<button class='clsButtonBlueXLarge' name='EditMapping' onclick=""window.open('DefaultDialogIntervalAdapterList.asp?IntervalId=" & idCurrentInterval & "&IntervalType=" & sIntervalType & "&IntervalState=" & iState & "','', 'height=400,width=400, resizable=yes, scrollbars=yes, status=yes')"">" & "Run Adapter..." &  "</button>" & vbNewLine
    end if
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
    
    Form_DisplayDetailRow = TRUE
END FUNCTION


%>
