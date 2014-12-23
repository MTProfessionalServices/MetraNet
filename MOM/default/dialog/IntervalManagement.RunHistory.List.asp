 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: IntervalManagement.RunHistory.List.asp$
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
'  $Date: 11/14/2002 12:13:29 PM$
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
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->

<%
Form.Version                    = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler               = FALSE  
Form.ShowExportIcon             = TRUE
Form.Page.MaxRow                = CLng(mom_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mom_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    'BreadCrumb.SetCrumb mom_GetDictionary("TEXT_VIEW_AUDIT_LOG")
    Framework.AssertCourseCapability "Manage EOP Adapters", EventArg
    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    'response.write(Service.Properties.ToString)
    'response.end
    Form("InstanceId") = CLng(request("InstanceId"))
    Form("IntervalId") = CLng(request("IntervalId"))
    Form("BillingGroupId") = CLng(request("BillingGroupId"))
    Form("Title") = request("Title")
    
    'Set the screen title
    if len(Form("Title"))>0 then
      mdm_GetDictionary().Add "ADAPTER_RUN_PAGE_TITLE", Form("Title") 
    else
      mdm_GetDictionary().Add "ADAPTER_RUN_PAGE_TITLE", "" 
    end if

    
	  Form_Initialize = true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
  
  dim rowset, sQuery
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  rowset.Init "queries\mom"
 
  if Form("BillingGroupId") > 0 then
    rowset.SetQueryTag("__GET_BILLINGGROUP_ADAPER_HISTORY__")  
    rowset.AddParam "%%ID_BILLGROUP%%", CLng(Form("BillingGroupId"))
    mdm_GetDictionary().Add "ADAPTER_RUN_PAGE_TITLE", mom_GetDictionary("TEXT_HISTORY_FOR_BG") & " " & Form("Title")  'Adapter Run History For Bill Group
  else 
	  if Form("InstanceId") > 0 then
		  rowset.SetQueryTag("__GET_ADAPTER_INSTANCE_HISTORY__")  
		  rowset.AddParam "%%ID_INSTANCE%%", CLng(Form("InstanceId"))
		  mdm_GetDictionary().Add "ADAPTER_RUN_PAGE_TITLE", mom_GetDictionary("TEXT_HISTORY_FOR") & " " & Form("Title") 'Adapter Run History For
	  else
		  if Form("IntervalId") > 0 then
		    rowset.SetQueryTag("__GET_INTERVAL_ADAPER_HISTORY__")  
		    rowset.AddParam "%%ID_INTERVAL%%", CLng(Form("IntervalId"))
		    mdm_GetDictionary().Add "ADAPTER_RUN_PAGE_TITLE", mom_GetDictionary("TEXT_HISTORY_FOR_INTERVAL") & " " & Form("Title") 'Adapter Run History For Interval
		  else
		    response.write("Instance Id or Interval Id Not Passed")
		    response.end
		  end if
	  end if
  end if
	rowset.Execute
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  ProductView.Properties.AddPropertiesFromRowset rowset  
  ProductView.Properties.SelectAll
  ProductView.Properties.CancelLocalization
  ProductView.Properties.ClearSelection      ' Select the properties I want to print in the PV Browser Order
  ProductView.Properties("InstanceId").Caption = mom_GetDictionary("TEXT_INSTANCE_ID")
  ProductView.Properties("Time").Caption       = mom_GetDictionary("TEXT_AUDIT_TIME")   
  ProductView.Properties("Action").Caption     = mom_GetDictionary("TEXT_Action1")
  ProductView.Properties("UserName").Caption   = mom_GetDictionary("TEXT_AUDIT_USERNAME")
  ProductView.Properties("AuditId").Caption    = mom_GetDictionary("TEXT_AUDIT_AUDIT_ID")
  ProductView.Properties("Type").Caption       = mom_GetDictionary("TEXT_TYPE")
  ProductView.Properties("UserID").Caption     = mom_GetDictionary("TEXT_AUDIT_USER_ID")
  ProductView.Properties("Details").Caption    = mom_GetDictionary("TEXT_AUDIT_DETAILS")
  ProductView.Properties("Forced").Caption     = mom_GetDictionary("TEXT_FORCED") 

  if Form("IntervalId") > 0 then 
    dim i
    i=1    
    ProductView.Properties("InstanceId").Selected = i : i = i + 1
    ProductView.Properties("Time").Selected 			= i : i = i + 1
    ProductView.Properties("Adapter").Selected 		= i : i = i + 1
    ProductView.Properties("Action").Selected 		= i : i = i + 1
    ProductView.Properties("UserName").Selected 	= i : i = i + 1
    ProductView.Properties("Adapter").Caption 	 = mom_GetDictionary("TEXT_ADAPTER")
  
    mdm_SetMultiColumnFilteringMode TRUE  
    Set Form.Grid.FilterProperty = ProductView.Properties("UserName") ' Set the property on which to apply the filter  
  else
    ProductView.Properties.SelectAll
    Form.Grid.FilterMode = 0' MDM_FILTER_MODE_ON ' Filter
  end if
   
  ProductView.Properties("Time").Sorted               = MTSORT_ORDER_DESCENDING

  ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he
  ' wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date
  ' else one.
  ProductView.LoadJavaScriptCode    
  Form_LoadProductView = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION

PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

  if Form.Grid.Col<=3 then
    Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
  else
    Select Case lcase(Form.Grid.SelectedProperty.Name)
      Case "action"
        dim strForced
            
        if ProductView.Properties.RowSet.Value("Forced")="Y" and UCASE(ProductView.Properties.RowSet.Value("type"))<>"CHECKPOINT" then
          strForced = "<br><img src='../localized/en-us/images/errorsmall.gif' align='absmiddle' border='0'><strong> [TEXT_BG_RUN_ACTION_WAS_FORCED]</strong>"
        else
          strForced = ""
        end if
        strForced = mom_GetDictionary("TEXT_BG_RUN_ACTION_" & UCase(Replace(ProductView.Properties.RowSet.Value("Action"), " ", "_"))) & strForced
        EventArg.HTMLRendered = "<td class='" & Form.Grid.CellClass & "'>" & strForced & "</td>"
        Form_DisplayCell = TRUE
      
      Case "time"
        EventArg.HTMLRendered = "<td class='" & Form.Grid.CellClass & "'>" & mdm_Format(ProductView.Properties.RowSet.Value("time"),mom_GetDictionary("DATE_TIME_FORMAT")) & "</td>"
        Form_DisplayCell = TRUE

  	  Case else
        Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
    End Select
  End if

  Form_DisplayCell = TRUE
END FUNCTION

PRIVATE FUNCTION Form_DisplayDetailRow (EventArg) ' As Boolean

  Dim forced, typedesc
  
  If (ProductView.Properties.RowSet.Value("forced") = "Y") Then
    forced = mom_GetDictionary("TEXT_YES") 
  Else 
    forced = mom_GetDictionary("TEXT_NO")
  End If

  typedesc = mom_GetDictionary("TEXT_BG_RUN_TYPE_" & UCase(Replace(ProductView.Properties.RowSet.Value("type"), " ", "_")))

  EventArg.HTMLRendered = EventArg.HTMLRendered & "<td></td><td></td>" & vbNewLine
  EventArg.HTMLRendered = EventArg.HTMLRendered & "<td ColSpan=" & (ProductView.Properties.Count+2) & ">" & vbNewLine    
  EventArg.HTMLRendered = EventArg.HTMLRendered & "<TABLE border=0 cellpadding=1 cellspacing=1>" & vbNewLine
  EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr Class='TableDetailCell'><td nowrap>&nbsp;" & ProductView.Properties("AuditId").Caption & ":&nbsp;&nbsp;</td><td nowrap>" & ProductView.Properties.RowSet.Value("AuditId") & "&nbsp;</td></tr>" & vbNewLine
  EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr Class='TableDetailCell'><td nowrap>&nbsp;" & ProductView.Properties("Type").Caption & ":&nbsp;&nbsp;</td><td nowrap>" & typedesc & "&nbsp;</td></tr>" & vbNewLine
  EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr Class='TableDetailCell'><td nowrap>&nbsp;" & ProductView.Properties("Forced").Caption & ":&nbsp;&nbsp;</td><td nowrap>" & forced & "&nbsp;</td></tr>" & vbNewLine
  EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr Class='TableDetailCell'><td nowrap>&nbsp;" & ProductView.Properties("UserID").Caption & ":&nbsp;&nbsp;</td><td nowrap>" & ProductView.Properties.RowSet.Value("UserID") & "&nbsp;</td></tr>" & vbNewLine
  EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr Class='TableDetailCell'><td nowrap>&nbsp;" & ProductView.Properties("Details").Caption & ":&nbsp;&nbsp;</td><td nowrap>" & ProductView.Properties.RowSet.Value("Details") & "&nbsp;</td></tr>" & vbNewLine
  EventArg.HTMLRendered = EventArg.HTMLRendered & "</TABLE><BR>"

  Form_DisplayDetailRow = TRUE

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  inheritedForm_DisplayEndOfPage
' PARAMETERS    :  EventArg
' DESCRIPTION   :  Override end of table to place add button
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp
    
    
    strTmp = "</table><div align=center><BR><BR><button  name='REFRESH' Class='clsOkButton' onclick='window.location=window.location'>" & _ 
      mom_GetDictionary("TEXT_REFRESH") & "</button><button  name='CLOSE' Class='clsOkButton' onclick='window.close();'>" & mom_GetDictionary("TEXT_CLOSE") & "</button>" & vbNewLine
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
        
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</FORM></BODY></HTML>"
    
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & REPLACE(strEndOfPageHTMLCode,"[LOCALIZED_IMAGE_PATH]",mom_GetLocalizeImagePath())
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION




%>
