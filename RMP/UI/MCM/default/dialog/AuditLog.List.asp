 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultPVBMapping.asp$
' 
'  Copyright 1998,2000 by MetraTech Corporation
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
Form.ErrorHandler               = FALSE  
Form.ShowExportIcon             = TRUE
Form.Page.MaxRow                = CLng(FrameWork.GetDictionary("MAX_ROW_PER_LIST_PAGE"))
Form.Page.NoRecordUserMessage   = FrameWork.GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    'response.write(Service.Properties.ToString)
    'response.end
    FORM("Filter") = Request("Filter")
    
	  Form_Initialize = true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
  
  '//Tell MDM not to apply the ADO filter when we set the rowset since we will use the filter in the backend
  Form.Grid.ApplyFilter = FALSE 
  
  dim objMTFilter
  Set objMTFilter = mdm_CreateObject(MTFilter)
  '//We want to only show changes to Product Catalog
  objMTFilter.Add "EntityType", OPERATOR_TYPE_EQUAL, 2
  
  '//If we passed in a query string indicator, then only show ruleset changes
  if len(Form("RulesetChangesOnlyFilter"))>0 then
    objMTFilter.Add "EventId", OPERATOR_TYPE_EQUAL, 1402
  end if
  
  '//Have the MDM add the user specified filter conditions to our filter
  mdm_SetFilterObjectFromCurrentFilterSettings objMTFilter

  dim objAuditLogManager
  set objAuditLogManager = mdm_CreateObject("MetraTech.Audit.AuditLogManager")
  
  dim rowset
  set rowset = objAuditLogManager.GetAuditLogAsRowset((objMTFilter))

  ' Check to see if items have been filtered and inform the user
  If rowset.RecordCount >= objAuditLogManager.MaximumNumberRecords Then
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", TRUE
  ELSE
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", FALSE      
  End If
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  ProductView.Properties.AddPropertiesFromRowset rowset

  'ProductView.Properties.SelectAll
  dim strGMTDateFormat
  strGMTDateFormat = "yyyy-mm-dd hh:mm:ssZ"
  ProductView.Properties.ClearSelection                       ' Select the properties I want to print in the PV Browser   Order
  ProductView.Properties("Time").Selected 			      = 1
  ProductView.Properties("Time").SetPropertyType "TIMESTAMP"
  ProductView.Properties("Time").Format  			        = FrameWork.GetDictionary("DATE_TIME_FORMAT")

  ProductView.Properties("UserName").Selected 	      = 2
  ProductView.Properties("EventName").Selected 	      = 3
  ProductView.Properties("EntityName").Selected 	    = 4
  ProductView.Properties("Details").Selected 	        = 5

  ProductView.Properties("Time").Caption 		          = FrameWork.GetDictionary("TEXT_AUDIT_TIME")
  ProductView.Properties("UserName").Caption 	        = FrameWork.GetDictionary("TEXT_AUDIT_USERNAME")
  ProductView.Properties("EventName").Caption 	      = FrameWork.GetDictionary("TEXT_AUDIT_EVENTNAME")
  ProductView.Properties("EntityName").Caption 	      = FrameWork.GetDictionary("TEXT_AUDIT_ENTITYNAME")
  ProductView.Properties("Details").Caption 	        = FrameWork.GetDictionary("TEXT_AUDIT_DETAILS")
  
  ProductView.Properties("EntityId").Caption 	        = FrameWork.GetDictionary("TEXT_AUDIT_ENTITY_ID")
  ProductView.Properties("id_audit").Caption 	        = FrameWork.GetDictionary("TEXT_AUDIT_AUDIT_ID")
  ProductView.Properties("id_Event").Caption 	        = FrameWork.GetDictionary("TEXT_AUDIT_EVENT_ID")
  
  ProductView.Properties("UserId").Caption 	          = FrameWork.GetDictionary("TEXT_AUDIT_USER_ID")
  ProductView.Properties("EventId").Caption 	        = FrameWork.GetDictionary("TEXT_AUDIT_EVENT_ID")
  
  ProductView.Properties("EntityType").Caption 	      = FrameWork.GetDictionary("TEXT_AUDIT_ENTITY_TYPE_ID")
  ProductView.Properties("id_UserId").Caption 	      = FrameWork.GetDictionary("TEXT_AUDIT_USER_ID")
  ProductView.Properties("id_entitytype").Caption 	  = FrameWork.GetDictionary("TEXT_AUDIT_ENTITY_TYPE_ID")
  ProductView.Properties("id_entity").Caption 	      = FrameWork.GetDictionary("TEXT_AUDIT_ENTITY_ID")
  ProductView.Properties("dt_crt").Caption 	          = FrameWork.GetDictionary("TEXT_AUDIT_DT_CRT")
  
  ProductView.Properties("Time").Sorted               = MTSORT_ORDER_DESCENDING
  
'  Set Form.Grid.FilterProperty                        = ProductView.Properties("UserName") ' Set the property on which to apply the filter  
  'mdm_SetMultiColumnFilteringMode TRUE  
  mdm_SetMultiColumnFilteringModeWithCustomProperties "~Time~EntityName~UserName~EntityId~"
 
    
  'Set current time message
  'dim strCurrentTime
  'strCurrentTime = ProductView.Tools.Format(ProductView.Tools.GetCurrentGMTTime,strGMTDateFormat)
  'Service.Properties.Add "CurrentGMTTimeMessage", "String",  256, FALSE, TRUE, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  'Service.Properties("CurrentGMTTimeMessage") = FrameWork.GetDictionary("TEXT_CURRENT_GMT_TIME_IS") & " " & strCurrentTime
  ProductView.LoadJavaScriptCode
      
  Form_LoadProductView                                  = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION


PRIVATE FUNCTION Form_DisplayDetailRow(EventArg) ' As Boolean

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
                  'SECENG: CORE-4792 CLONE - BSS 34776 MetraCare: Stored Cross-Site Scripting in [MAM/default/dialog/DefaultPVBApplicationAuditLog.asp]
                  'HTML encoding was added.
                  strValue = SafeForHtml(TRIM("" & objProperty.Value))
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

PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    'EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>" & ProductView.Properties.RowSet.Value("State") & "</td>"

       if Form.Grid.Col<=3 then
          Form_DisplayCell = Inherited("Form_DisplayCell()") ' Call the default implementation
       else
         Select Case lcase(Form.Grid.SelectedProperty.Name)
         Case "entityname"
           if ProductView.Properties("EventId") = 1402 then
            dim strEditStateButton
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>"  & _
              "<button class='clsButtonBlueLarge' onclick=""window.open('gotoRuleEditorViewDifference.asp?Title=" & "Rudi" & "&AUDIT_ID=" & ProductView.Properties("id_audit") & "&RS_ID_1=" & ProductView.Properties("EntityId") & "','_blank', 'height=800,width=1000,resizable=1,scrollbars=1'); return false;"">" & FrameWork.GetDictionary("TEXT_VIEW_CHANGES") & "</button>&nbsp;" & _
              "<button class='clsButtonBlueMedium' onclick=""window.open('Rates.RateSchedule.ViewHistory.asp?MDMReload=TRUE&Reload=TRUE&refresh=TRUE&RS_ID=" & ProductView.Properties("EntityId") & "','_blank', 'height=600,width=800,resizable=yes,scrollbars=yes'); return false;"">" & FrameWork.GetDictionary("TEXT_VIEW_HISTORY") & "</button>" & _
              "</td>"
                  
                  ' Info for FredRunner Smoke Test                  
            '      EventArg.HTMLRendered=EventArg.HTMLRendered & "<INPUT Name='[NAME].Completed' Type='Hidden' Value='[COMPLETED]'>"
            '      EventArg.HTMLRendered=EventArg.HTMLRendered & "<INPUT Name='[NAME].Failed' Type='Hidden' Value='[FAILED]'>"
            '      EventArg.HTMLRendered=PreProcess(EventArg.HTMLRendered,Array("NAME",ProductView.Properties.RowSet.Value("Name"),"COMPLETED",ProductView.Properties.RowSet.Value("Completed"),"FAILED",ProductView.Properties.RowSet.Value("Failed")))
  			    Form_DisplayCell = TRUE           
           else
             Form_DisplayCell = Inherited("Form_DisplayCell()") ' Call the default implementation   
           end if
            

        case "details"
            dim sDetails
            if len(ProductView.Properties("Details"))>256 then
              dim sTurndownLink, strPageAction
              If(Form.Grid.TurnDowns.Exist("R" & Form.Grid.Row))Then
                strPageAction       = MDM_ACTION_TURN_RIGHT
              Else
                strPageAction       = MDM_ACTION_TURN_DOWN
              End If

             'SECENG: CORE-4792 CLONE - BSS 34776 MetraCare: Stored Cross-Site Scripting in [MAM/default/dialog/DefaultPVBApplicationAuditLog.asp]
             'HTML encoding was added.
             sDetails = SafeForHtml(left(ProductView.Properties("Details"),256))
             sDetails = sDetails & "&nbsp;&nbsp;<b>[&nbsp;<A href='" & request.serverVariables("URL")  & "?mdmPageAction=" & strPageAction & "&mdmRowIndex=" & Form.Grid.Row &  "'>more</a>&nbsp;]</b>"

            else
              'SECENG: CORE-4792 CLONE - BSS 34776 MetraCare: Stored Cross-Site Scripting in [MAM/default/dialog/DefaultPVBApplicationAuditLog.asp]
              'HTML encoding was added.  
              sDetails = SafeForHtml(ProductView.Properties("Details"))
            end if
            EventArg.HTMLRendered = "<td class=" & Form.Grid.CellClass & ">" & replace("" & sDetails, vbNewLine, "<br>") & "</td>"
            Form_DisplayCell = TRUE                
  	     Case else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
      End Select
     end if

    Form_DisplayCell = true

END FUNCTION

'<button name='viewhistory1169' class='clsButtonBlueMedium' onclick="window.open('Rates.RateSchedule.ViewHistory.asp?MDMReload=TRUE&EditMode=TRUE&Reload=TRUE&refresh=TRUE&PT_ID=51&RS_ID=1169&PL_ID=604','_blank', 'height=600,width=800,resizable=yes,scrollbars=yes');">View History</button>
%>
