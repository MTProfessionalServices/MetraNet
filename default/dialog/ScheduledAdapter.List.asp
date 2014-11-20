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
Form.ErrorHandler               = FALSE 
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
    'Form("NextPage")  = "ScheduledAdapter.Instance.List.asp"
    'Form("LinkColumnMode")        = FALSE
    'Form("IDColumnName")          = "EventID"
    
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
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\mom"
  rowset.SetQueryTag("__GET_SCHEDULED_ADAPTER_LIST__")
  rowset.AddParam "%%ID_LANG_CODE%%", Session("FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME").LanguageId
  rowset.Execute
  
  if false then
      dim objUSMInstances
  	set objUSMInstances = CreateObject("MetraTech.UsageServer.RecurringEventInstanceFilter")
	  'objUSMInstances.UsageIntervalID = Clng(Form("IntervalId"))
	  set rowset = objUSMInstances.GetScheduledRowset()    
  end if
  
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  ProductView.Properties.AddPropertiesFromRowset rowset
  
  'ProductView.Properties.SelectAll
  ProductView.Properties.ClearSelection ' Select the properties I want to print in the PV Browser Order
  dim i
  i = 1
  
  'ProductView.Properties("EventId").Selected          = i : i=i+1
  
  ProductView.Properties("DisplayName").Selected          = i : i=i+1    
  ProductView.Properties("DisplayName").Caption = "Adapter"
  ProductView.Properties("IntervalType").Selected = i : i=i+1
  ProductView.Properties("IntervalType").Caption = "Schedule"
  ProductView.Properties("IsPaused").Selected = i : i=i+1
  ProductView.Properties("IsPaused").Caption = "Next Run"
  ProductView.Properties("Description").Selected = i : i=i+1
  ProductView.Properties("Description").Caption = "Description"
  
  ProductView.Properties("DisplayName").Sorted = MTSORT_ORDER_ASCENDING
  'ProductView.Properties.CancelLocalization
  
  mdm_SetMultiColumnFilteringMode TRUE 
          
  Form_LoadProductView                                  = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION


PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

       if Form.Grid.Col<=2 then
          if Form.Grid.Col=2 then
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "' nowrap>&nbsp;</td>"
          else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)") 'LinkColumnMode_DisplayCell(EventArg)
          end if
       else
            dim strScheduleName
            dim strIntervalType
            dim interval
            dim executionTimes
            dim daysOfWeek
            dim daysOfMonth
            strScheduleName = "Unknown"
            strIntervalType = ProductView.Properties.RowSet.Value("IntervalType")
            if isNull(ProductView.Properties.RowSet.Value("Interval")) then
              interval = "1"
            else
              interval = ProductView.Properties.RowSet.Value("Interval")
            end if
            if isNull(ProductView.Properties.RowSet.Value("ExecutionTimes")) then
              executionTimes = ""
            else
              executionTimes = ProductView.Properties.RowSet.Value("ExecutionTimes")
            end if
            if isNull(ProductView.Properties.RowSet.Value("DaysOfWeek")) then
              daysOfWeek = ""
            else
              daysOfWeek = ProductView.Properties.RowSet.Value("DaysOfWeek")
            end if
            if isNull(ProductView.Properties.RowSet.Value("DaysOfMonth")) then
              daysOfMonth = ""
            else
              daysOfMonth = ProductView.Properties.RowSet.Value("DaysOfMonth")
            end if
           
            Select Case lcase(strIntervalType)
            Case "daily"
              StrScheduleName = "Every " & interval & " day(s) at " &   mdm_Format(executionTimes,mom_GetDictionary("TIME_FORMAT"))  
            Case "monthly"
              StrScheduleName = "Every " & interval & " month(s) at " &  mdm_Format(executionTimes,mom_GetDictionary("TIME_FORMAT")) & " on " & daysOfMonth
            Case "weekly"
              StrScheduleName = "Every " & interval & " week(s) at " & mdm_Format(executionTime,mom_GetDictionary("TIME_FORMAT")) & " on " & daysOfWeek
            Case "minutely"
              StrScheduleName = "Every " & interval & " minutes "
            Case "manual"
              StrScheduleName = "Manual"
            End Select

         Select Case lcase(Form.Grid.SelectedProperty.Name)
         Case "intervaltype"

            dim scheduleLink
            scheduleLink = "/MetraNet/MetraControl/ScheduledAdapters/RecurrencePattern.aspx?EventID=" & ProductView.Properties.RowSet.Value("EventId") & "&ScheduleName=" & server.urlencode(StrScheduleName) & "&AdapterName=" & ProductView.Properties.RowSet.Value("DisplayName")
            EventArg.HTMLRendered  =  "<td class='" & Form.Grid.CellClass & "'><a href='" & scheduleLink & "'>" & strScheduleName & "</a></td>"
            
  			    Form_DisplayCell = TRUE
         Case "ispaused"
            dim nextRunLink, nextRunText, isPaused
            if isNull(ProductView.Properties.RowSet.Value("IsPaused")) then
              isPaused = "N"
            else
              isPaused = ProductView.Properties.RowSet.Value("IsPaused")
            end if
            if isPaused = "N" then
              if isNull(ProductView.Properties.RowSet.Value("OverrideDate")) then
                nextRunText = "On Schedule"
              else 
                nextRunText = ProductView.Properties.RowSet.Value("OverrideDate")
              end if
            else 
              nextRunText = "Paused"
            end if
            nextRunLink = "/MetraNet/MetraControl/ScheduledAdapters/OverrideSchedule.aspx?EventID=" & ProductView.Properties.RowSet.Value("EventId") & "&ScheduleName=" & server.urlencode(StrScheduleName) & "&AdapterName=" & ProductView.Properties.RowSet.Value("DisplayName")
            EventArg.HTMLRendered  =  "<td class='" & Form.Grid.CellClass & "' nowrap><a href='" & nextRunLink & "'>" & NextRunText & "</a></td>"
            
  			    Form_DisplayCell = TRUE
         Case "displayname"
            dim strName,strLink            
            strName = "<img src='../localized/en-us/images/adapter_scheduled.gif' align='absmiddle' border='0'><strong>" & ProductView.Properties.RowSet.Value("DisplayName") & "</strong>"
            strLink = "ScheduledAdapter.Instance.List.asp?ID=" & ProductView.Properties.RowSet.Value("EventId") & "&AdapterName=" & server.urlencode(strName)
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "' nowrap><a href='" & strLink & "'>"  & strName & "</a></td>" 
  			    Form_DisplayCell = TRUE
            
  	     Case else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
      End Select
     end if

    Form_DisplayCell = true

END FUNCTION



%>
