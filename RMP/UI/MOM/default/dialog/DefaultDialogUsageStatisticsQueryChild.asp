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
'  Created by: F.Torres
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
<%
Form.Version                    = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler               = FALSE  
Form.ShowExportIcon             = TRUE
'Form.Page.MaxRow                = CLng(FrameWork.GetDictionary("MAX_ROW_PER_LIST_PAGE"))
'Form.Page.NoRecordUserMessage   = FrameWork.GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    'BreadCrumb.SetCrumb FrameWork.GetDictionary("TEXT_VIEW_AUDIT_LOG")
    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    'response.write(Service.Properties.ToString)
    'response.end
    Form("PVID") = request("ID")
    
    'mdm_GetDictionary().Add "METERING_STATISTICS_QUERY_CHILD_PAGE_TITLE", mdm_GetDictionary().Item("TEXT_INTERVAL_MANANAGEMENT_HARDCLOSED")

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
  dim sProductViewName
  dim sProductViewTableName
  
  dim sUsagePropertiesToDisplay
  sUsagePropertiesToDisplay = "au.amount"
    
  dim objNameId
  set objNameId = server.createobject("MetraPipeline.MTNameID.1")
  sProductViewName=objNameId.getName(Form("PVID"))

  dim sBatchId
  sBatchId = session("UsageStatisticsFilter_BatchId")
  
  if len(sBatchId) then
    'sWhereClause = sWhereClause & " au.tx_batch like '" & sBatchId & "'"
    '// Convert batchid to hex for database query
    dim objMSIXUtils
    dim result
    set objMSIXUtils = CreateObject("MetraTech.MSIXUtilsInterop")
    result = objMSIXUtils.DecodeUIDAsString(sBatchId)
    sWhereClause = sWhereClause & " and au.tx_batch = 0x" &  result
  end if
  
  dim objDataAccessorUtil
  set objDataAccessorUtil = server.CreateObject("MetraTech.DataAccessorUtil.1")
  sProductViewTableName = objDataAccessorUtil.GetProductViewTableName(sProductViewName)
  
  sQueryString = "select " & sUsagePropertiesToDisplay & " , pv.* from t_acc_usage au, " & sProductViewTableName & " pv where au.id_sess=pv.id_sess " & sWhereClause
  
  dim rowset
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\audit"
  
  rowset.SetQueryString(sQueryString)

	rowset.Execute

  
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  ProductView.Properties.AddPropertiesFromRowset rowset
  
  ProductView.Properties.SelectAll

  ProductView.Properties.CancelLocalization

'dim i
'for i=0 to ProductView.Properties.Rowset.Count-1
' response.write ProductView.Properties.Rowset.Name(i) & "<BR>"
 'response.write ProductView.Properties.Rowset.Value(i) & "<BR>"
'next
'response.write "++++++" & MDMListDialog.GetIDColumnName()
'  response.write ProductView.Properties.Rowset.Value("View Id") & "<BR>"
'response.end

        
  Form_LoadProductView                                  = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION


PRIVATE FUNCTION xForm_DisplayCell(EventArg) ' As Boolean

    EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>" & ProductView.Properties.RowSet.Value("State") & "</td>"
       
       if Form.Grid.Col<3 then
          Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
       else
         Select Case lcase(Form.Grid.SelectedProperty.Name)
         'Select Case Form.Grid.Col
         'Case 8
         Case "state"
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>" & _
              ProductView.Properties.RowSet.Value("State") & "&nbsp;&nbsp;<a href=''><img src='../localized/en-us/images/edit.gif' width='11' height='17' alt='' border='0'></a></td>"
              '  ProductView.Properties.RowSet.Value("State") & "<button class='clsButtonBlueSmall' name='EditMapping' onclick=""window.open('protoIntervalManagement.asp?','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes')"">" & "Change" &  "</button></td>" 
         
  			    Form_DisplayCell = TRUE
  	     Case else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
      End Select
     end if
        'Select Case lcase(ProductView.Properties.RowSet.Name)
        'Case "state"
            
             ' We put a name of the anchor for FredRunner
         '   EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>" & _
         '         ProductView.Properties.RowSet.Value("State") & "<button class='clsButtonBlueSmall' name=""EditMapping" & ProductView.Properties.RowSet.Row & """ onclick=""window.open('protoIntervalManagement.asp?"','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes')"">" & "Change" &  "</button></td>" 
       '
			  '    Form_DisplayDetailRow = TRUE
			
	     ' Case else
       '     Form_DisplayDetailRow = Inherited("Form_DisplayCell(EventArg)")
    'End Select
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
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td ColSpan=" & (ProductView.Properties.Count+2) & " width=20>" & vbNewLine
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<TABLE  width='100%' border=0 cellpadding=1 cellspacing=0>" & vbNewLine
    
    For Each objProperty In ProductView.Properties
        
        If(UCase(objProperty.Name)<>"MDMINTERVALID") And ((objProperty.Flags And eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET)=0) Then
        
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
    Next
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</TABLE>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
    
    Form_DisplayDetailRow = TRUE
END FUNCTION


%>
