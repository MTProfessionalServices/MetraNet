 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
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
'  $Date$
'  $Author$
'  $Revision$
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
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<%
Form.Version                    = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler               = TRUE  
Form.ShowExportIcon             = TRUE
'Form.Page.MaxRow                = CLng(FrameWork.GetDictionary("MAX_ROW_PER_LIST_PAGE"))
'Form.Page.NoRecordUserMessage   = FrameWork.GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    'BreadCrumb.SetCrumb FrameWork.GetDictionary("TEXT_VIEW_AUDIT_LOG")
    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

 	  Form_Initialize = MDMListDialog.Initialize(EventArg)
    Form.Grid.FilterMode = false
    
    if len(request("UsageStatisticsFilter_BatchId"))>0 then
      session("UsageStatisticsFilter_BatchId")=request("UsageStatisticsFilter_BatchId")
    end if
    
    'response.write(Service.Properties.ToString)
    'response.end
    Form("NextPage") = "DefaultDialogUsageStatisticsQueryChild.asp"
    Form("IDColumnName") = "View Id"
    Form("LinkColumnMode") = true
	  Form_Initialize = true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
  
  dim sQueryString
  dim sWhereClause
  
  dim sBatchId
  sBatchId = session("UsageStatisticsFilter_BatchId")
  
  if len(sBatchId) then
    'sWhereClause = sWhereClause & " au.tx_batch like '" & sBatchId & "'"
    '// Convert batchid to hex for database query
    dim objMSIXUtils
    dim result
    set objMSIXUtils = CreateObject("MetraTech.MSIXUtilsInterop")
    result = objMSIXUtils.DecodeUIDAsString(sBatchId)
    sWhereClause = sWhereClause & " au.tx_batch = 0x" &  result
  end if
  
  dim sMeteredStartDate, sMeteredEndDate
  sMeteredStartDate = session("UsageStatisticsFilter_MeteredStartDate")
  sMeteredEndDate = session("UsageStatisticsFilter_MeteredEndDate")

  if len(sMeteredStartDate) then
    if len(sMeteredEndDate) then
      'We have start and end date
      sWhereClause = sWhereClause & " au.dt_crt between '" & sMeteredStartDate & "' and '" & sMeteredEndDate & "'"
    else
      'We have only the start date
      sWhereClause = sWhereClause & " au.dt_crt between '" & sMeteredStartDate & "' and dbo.MTEndOfDay('" & sMeteredStartDate & "')"
    end if
  end if

  dim sTimestampStartDate, sTimestampEndDate
  sTimestampStartDate = session("UsageStatisticsFilter_TimestampStartDate")
  sTimestampEndDate = session("UsageStatisticsFilter_TimestampEndDate")

  if len(sTimestampStartDate) then
    if len(sTimestampEndDate) then
      'We have start and end date
      sWhereClause = sWhereClause & " au.dt_session between '" & sTimestampStartDate & "' and '" & sTimestampEndDate & "'"
    else
      'We have only the start date
      sWhereClause = sWhereClause & " au.dt_session between '" & sTimestampStartDate & "' and dbo.MTEndOfDay('" & sTimestampStartDate & "')"
    end if
  end if
  
  session("UsageStatisticsFilter_WhereClause") = sWhereClause
  
  dim rowset
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\audit"
  'rowset.SetQueryString("select au.id_view as 'View Id', d.tx_desc as 'View Name', count(*) as 'Count', sum(au.amount) as 'Amount' from t_acc_usage au join t_description d on au.id_view = d.id_desc and d.id_lang_code =840 group by au.id_view,d.tx_desc")
  
  sQueryString = "select d.tx_desc as ""View Name"", au.id_view as ""View Id"",  count(*) as ""Count"", sum(au.amount) as ""Amount"" from t_acc_usage au join t_description d on au.id_view = d.id_desc and d.id_lang_code =840"
  if len(sWhereClause) then
    sQueryString = sQueryString & " where " & sWhereClause
  end if
  sQueryString = sQueryString & " group by au.id_view,d.tx_desc"
  rowset.SetQueryString(sQueryString)
  
  'rowset.SetQueryString("select * from t_acc_usage")
  
  rowset.Execute

  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  ProductView.Properties.AddPropertiesFromRowset rowset
  
  ProductView.Properties.SelectAll
  ProductView.Properties.CancelLocalization
        
  Form_LoadProductView                                  = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION


PRIVATE FUNCTION xForm_DisplayDetailRow(EventArg) ' As Boolean

    Dim objProperty
    Dim strSelectorHTMLCode
    Dim strValue
    Dim strCurrency
    Dim strHTMLAttributeName
    
    'Set objProperty = ProductView.Properties.Item(Form.Grid.PropertyName)
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td></td><td></td>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td ColSpan=" & (ProductView.Properties.Count+2) & " width=20>" & vbNewLine
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<TABLE  width='100%' border=0 cellpadding=1 cellspacing=0>" & vbNewLine
    
    For Each objProperty In ProductView.Properties
    
        If(UCase(objProperty.Name)<>"MDMINTERVALID") And ((objProperty.Flags And eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET)=0) Then
        
            ' Check the columns to exclude...
            If(InStr(UCase("UserId,EventId,id_entity,id_UserId,dt_crt,id_entitytype"),UCase(objProperty.Name))=0)Then 
            
              If(objProperty.UserVisible)Then
              
                  strHTMLAttributeName  = "TurnDown." & objProperty.Name & "(" & Form.Grid.Row & ")"
                  EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr>" & vbNewLine
                  EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Class='TableDetailCell' nowrap>" & objProperty.Caption & "</td>" & vbNewLine
                  
                  'strValue = TRIM("" & objProperty.NonLocalizedValue)
                  strValue = TRIM("" & objProperty.Value)
                  If(Len(strValue)=0)Then
                      strValue  = "&nbsp;"
                  End If
                  EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Name='" & strHTMLAttributeName & "' Class='TableDetailCell' nowrap>" & strValue & " </td>" & vbNewLine
                  EventArg.HTMLRendered = EventArg.HTMLRendered & "</tr>" & vbNewLine
              End If
            End If        
        End If
    Next
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</TABLE>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
    
    Form_DisplayDetailRow = TRUE
END FUNCTION


%>
