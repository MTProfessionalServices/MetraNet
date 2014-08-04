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

    Framework.AssertCourseCapability "Manage Usage Intervals And Scheduled Adapters", EventArg

    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    MDMListDialog.Initialize EventArg
    'Form("NextPage")  = "AdapterManagement.Instance.ViewEdit.asp?ReturnUrl=" & Server.UrlEncode("ScheduledAdapter.Instance.List.asp?AdapterName=" & request.QueryString("AdapterName") & "&ID=" & request.QueryString("ID"))
    Form("NextPage")  = "AdapterManagement.Instance.ViewEdit.asp"
    Form("Parameters") = "ReturnUrl|" & Server.UrlEncode("ScheduledAdapter.Instance.List.asp?AdapterName=" & request.QueryString("AdapterName") & "&ID=" & request.QueryString("ID"))
    Form("LinkColumnMode")        = TRUE
    Form("IDColumnName")          = "InstanceID"
    
    Form("AdapterName") = request.QueryString("AdapterName")
    
    'response.write(Service.Properties.ToString)
    'response.end
    Form("EventId")=request.QueryString("ID")
    
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
  
  if false then
      dim objUSMInstances
  	set objUSMInstances = CreateObject("MetraTech.UsageServer.RecurringEventInstanceFilter")
	  'objUSMInstances.UsageIntervalID = Clng(Form("IntervalId"))
	  set rowset = objUSMInstances.GetScheduledRowset()    
    dim objMTFilter
    Set objMTFilter = mdm_CreateObject(MTFilter)
    objMTFilter.Add "EventId", OPERATOR_TYPE_EQUAL, cstr(Form("EventId"))
    set rowset.filter = objMTFilter
  else
   set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	 rowset.Init "queries\mom"
   rowset.SetQueryTag("__GET_ADAPTER_INSTANCE_LIST_FOR_EVENT__")
   rowset.AddParam "%%ID_EVENT%%", CLng(Form("EventId"))   
   rowset.Execute

  end if


  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  ProductView.Properties.AddPropertiesFromRowset rowset
  
  'ProductView.Properties.SelectAll
  ProductView.Properties.ClearSelection ' Select the properties I want to print in the PV Browser Order
  dim i
  i = 1
  
  ProductView.Properties("InstanceId").Selected     = i : i=i+1
  
  'ProductView.Properties("RunId").Selected          = i : i=i+1    
  ProductView.Properties("ArgStartDate").Selected          = i : i=i+1    
  ProductView.Properties("ArgEndDate").Selected          = i : i=i+1    
  ProductView.Properties("Status").Selected          = i : i=i+1    
  ProductView.Properties("LastRunAction").Selected          = i : i=i+1    
  ProductView.Properties("LastRunStart").Selected          = i : i=i+1    
  ProductView.Properties("LastRunStatus").Selected          = i : i=i+1    
  ProductView.Properties("LastRunMachine").Selected          = i : i=i+1    
  
'InstanceID	ArgStartDate	ArgEndDate	IgnoreDeps	EffectiveDate	Status	LastRunID	LastRunAction	LastRunStart	LastRunEnd	LastRunStatus	LastRunDetail


  ProductView.Properties("ArgStartDate").Sorted = MTSORT_ORDER_DESCENDING
  


  ProductView.Properties.CancelLocalization

  Service.Properties.Add "AdapterName", "string", 255, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("AdapterName").Value=Form("AdapterName")
  
  mdm_SetMultiColumnFilteringMode TRUE 
          
  Form_LoadProductView                                  = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION


PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

       if Form.Grid.Col<=3 then
          Form_DisplayCell = LinkColumnMode_DisplayCell(EventArg)
       else
         Select Case lcase(Form.Grid.SelectedProperty.Name)
         Case "status"
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>"  & mom_GetAdapterInstanceStatusMessage(ProductView.Properties.RowSet.Value("Status"),ProductView.Properties.RowSet.Value("EffectiveDate")) & "</td>" 
            
  			    Form_DisplayCell = TRUE
         Case "xstatus"
            dim strImage,strTooltip
            
            strImage = "../localized/en-us/images/adapter_scheduled.gif"
            strTooltip= "Run Id: " & ProductView.Properties.RowSet.Value("RunId") & vbNewLine & "Arg Start: " & ProductView.Properties.RowSet.Value("ArgStart") & vbNewLine & "Arg End: " & ProductView.Properties.RowSet.Value("ArgEnd") & vbNewLine
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "' title='" & strToolTip & "'>"  &_
                  "<img src='" & strImage & "' align='absmiddle'><strong>" & ProductView.Properties.RowSet.Value("DisplayName") & "</strong></td>" 
            
  			    Form_DisplayCell = TRUE
         Case "lastrunstart"
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>"  & mom_GetDurationMessage(ProductView.Properties.RowSet.Value("LastRunStart"),ProductView.Properties.RowSet.Value("LastRunEnd")) & "</td>" 
            
  			    Form_DisplayCell = TRUE
         Case "argstartdate"
             EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>"  & mdm_Format(ProductView.Properties.RowSet.Value("ArgStartDate"),mom_GetDictionary("DATE_TIME_FORMAT")) & "</td>" 
  			    Form_DisplayCell = TRUE
         Case "argenddate"
             EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>"  & mdm_Format(ProductView.Properties.RowSet.Value("ArgEndDate"),mom_GetDictionary("DATE_TIME_FORMAT")) & "</td>" 
  			    Form_DisplayCell = TRUE
  	     Case else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
      End Select
     end if

    Form_DisplayCell = true

END FUNCTION



%>
