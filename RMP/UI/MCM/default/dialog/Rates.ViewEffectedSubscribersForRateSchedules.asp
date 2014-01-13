 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultPVBMapping.asp$
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
'  $Date: 5/11/00 12:00:08 PM$
'  $Author: $
'  $Revision: 1$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : 
' DESCRIPTION : 
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<%
Form.Version                    = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler               = TRUE  
Form.ShowExportIcon             = TRUE
'Form.Page.MaxRow                = CLng(FrameWork.GetDictionary("MAX_ROW_PER_LIST_PAGE"))
'Form.Page.NoRecordUserMessage   = FrameWork.GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    'response.write(Service.Properties.ToString)
    'response.end
    
    Form("ParamTableId") = request("ParamTableId")
    Form("PriceListId") = request("PriceListId")
    
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
  

    if len(request("ParamTableId"))>0 then
      Form("ParamTableId") = request("ParamTableId")
      Form("PriceListId") = request("PriceListId")
    end if
    
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  	rowset.Init "queries\productcatalog"
    'rowset.SetQueryString("select h.hierarchyname as 'Subscriber', sub.id_acc as 'Account Id', 'Type' = case when sub.id_group is not NULL THEN 'Group Subscription: ' + gsub.tx_name ELSE 'Subscription' END, bp.nm_name as 'Name', vt_start as 'Start', vt_end as 'End' from t_vw_allrateschedules_po rspo join t_vw_expanded_sub sub on rspo.id_po=sub.id_po join vw_hierarchyname h on sub.id_acc = h.id_acc join t_base_props bp on sub.id_po=bp.id_prop left join t_group_sub gsub on sub.id_group = gsub.id_group  where id_paramtable=" & Form("ParamTableId") & " and id_pricelist=" & Form("PriceListId") & " union select h.hierarchyname as 'Subscriber', acc.id_acc as 'Account Id', 'Default Price List' as 'Type', bp.nm_name as 'Name', NULL as 'Start', NULL as 'End' from t_vw_allrateschedules_pl rspl join t_av_internal acc on rspl.id_pricelist=acc.c_pricelist join vw_hierarchyname h on acc.id_acc = h.id_acc join t_base_props bp on rspl.id_pricelist=bp.id_prop where id_paramtable="  & Form("ParamTableId") & " and id_pricelist=" & Form("PriceListId") )

    rowset.SetQueryTag("__GET_DEPENDENT_SUBSCRIBERS_FOR_PRICELIST_AND_PARAMTABLE__")  
    rowset.AddParam "%%ID_PARAMTABLE%%", CLng(Form("ParamTableId"))
    rowset.AddParam "%%ID_PRICELIST%%", CLng(Form("PriceListId"))
  	rowset.Execute


  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  ProductView.Properties.AddPropertiesFromRowset rowset
  
  ProductView.Properties.SelectAll

  ProductView.Properties.CancelLocalization

  mdm_SetMultiColumnFilteringMode TRUE 
        
  Form_LoadProductView                                  = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION


PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    'EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>" & ProductView.Properties.RowSet.Value("State") & "</td>"
     dim tempDate
     
       if Form.Grid.Col<2 then
          Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
       else
         if Form.Grid.Col>2 then
         Select Case lcase(Form.Grid.SelectedProperty.Name)
         'Select Case Form.Grid.Col
         'Case 8
         Case "start"
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>"
            tempDate = ProductView.Properties.RowSet.Value("start")
            if not IsNull(tempDate) then
              if not FrameWork.IsMinusInfinity(tempDate) then
                EventArg.HTMLRendered = EventArg.HTMLRendered & tempDate 
              end if  
            end if
            EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>"
         
  			    Form_DisplayCell = TRUE
         Case "end"
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>"
            tempDate = ProductView.Properties.RowSet.Value("end")
            if not IsNull(tempDate) then
              if not FrameWork.IsInfinity(tempDate) then
                EventArg.HTMLRendered = EventArg.HTMLRendered & tempDate 
              end if  
            end if
            EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>"
              '  ProductView.Properties.RowSet.Value("State") & "<button class='clsButtonBlueSmall' name='EditMapping' onclick=""window.open('protoIntervalManagement.asp?','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes')"">" & "Change" &  "</button></td>" 
         
  			    Form_DisplayCell = TRUE
  	     Case else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
         End Select
         end if
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

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  inheritedForm_DisplayEndOfPage
' PARAMETERS    :  EventArg
' DESCRIPTION   :  Override end of table to place add button
' RETURNS       :  Return TRUE if ok else FALSE
PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    EventArg.HTMLRendered = "<INPUT Type='Hidden' Name='PickerIDs' Value=''></TABLE><BR><CENTER><BR><BR>" & vbNewLine

    EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON Name='CANCEL' Class='clsOKButton' OnClick='window.close();'>" & "Close" & "</BUTTON></center>" & vbNewLine

    EventArg.HTMLRendered = EventArg.HTMLRendered & "</FORM>" & vbNewLine
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION


%>
