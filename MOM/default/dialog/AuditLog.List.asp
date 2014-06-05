 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: s:\UI\MOM\default\dialog\AuditLog.List.asp$
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
'  $Date: 11/9/2002 10:20:47 AM$
'  $Author: Kevin Boucher$
'  $Revision: 6$
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
<%
Form.Version                    = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler               = FALSE  
Form.ShowExportIcon             = TRUE
Form.Page.MaxRow                = CLng(mom_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mom_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    'BreadCrumb.SetCrumb mom_GetDictionary("TEXT_VIEW_AUDIT_LOG")
    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    'response.write(Service.Properties.ToString)
    'response.end
    Form("EntityType") = request("EntityType")
    Form("EntityId") = request("EntityId")
    Form("Title") = request("Title")
    
	  Form_Initialize = true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
  
  'Set the screen title
  if len(Form("Title"))>0 then
    mdm_GetDictionary().Add "AUDIT_LOG_PAGE_TITLE", Form("Title")
  else
    mdm_GetDictionary().Add "AUDIT_LOG_PAGE_TITLE", mdm_GetDictionary().Item("TEXT_SYSTEM_AUDIT_LOG")
  end if

  '//Tell MDM not to apply the ADO filter when we set the rowset since we will use the filter in the backend
  Form.Grid.ApplyFilter = FALSE 
  
  dim objMTFilter
  Set objMTFilter = mdm_CreateObject(MTFilter)

  
  if len(Form("EntityId"))>0 Then
    objMTFilter.Add "EntityType", OPERATOR_TYPE_EQUAL, CLng(Form("EntityType"))
    objMTFilter.Add "EntityId", OPERATOR_TYPE_EQUAL, CLng(Form("EntityId"))
  else
    if len(Form("EntityType"))>0 then
      objMTFilter.Add "EntityType", OPERATOR_TYPE_EQUAL, CLng(Form("EntityType"))
    end if
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
  ProductView.Properties("Time").SetPropertyType("TIMESTAMP")
  ProductView.Properties("Time").Format  			        = mom_GetDictionary("DATE_TIME_FORMAT")

  ProductView.Properties("UserName").Selected 	      = 2
  ProductView.Properties("EventName").Selected 	      = 3
  ProductView.Properties("EntityName").Selected 	    = 4
  ProductView.Properties("Details").Selected 	        = 5

  ProductView.Properties("Time").Caption 		            = mom_GetDictionary("TEXT_AUDIT_TIME")
  ProductView.Properties("UserName").Caption 	          = mom_GetDictionary("TEXT_AUDIT_USERNAME")
  ProductView.Properties("EventName").Caption 	        = mom_GetDictionary("TEXT_AUDIT_EVENTNAME")
  ProductView.Properties("EntityName").Caption 	        = mom_GetDictionary("TEXT_AUDIT_ENTITYNAME")
  ProductView.Properties("Details").Caption 	          = mom_GetDictionary("TEXT_AUDIT_DETAILS")
  ProductView.Properties("LoggedInAs").Caption 	        = mom_GetDictionary("TEXT_AUDIT_LOGGED_IN_AS")
  ProductView.Properties("ApplicationName").Caption 	  = mom_GetDictionary("TEXT_AUDIT_APPLICATION_NAME")
  
  ProductView.Properties("EntityId").Caption 	          = mom_GetDictionary("TEXT_AUDIT_ENTITY_ID")
  ProductView.Properties("id_audit").Caption 	          = mom_GetDictionary("TEXT_AUDIT_AUDIT_ID")
  ProductView.Properties("id_Event").Caption 	          = mom_GetDictionary("TEXT_AUDIT_EVENT_ID")
  
  ProductView.Properties("UserId").Caption 	            = mom_GetDictionary("TEXT_AUDIT_USER_ID")
  ProductView.Properties("EventId").Caption 	          = mom_GetDictionary("TEXT_AUDIT_EVENT_ID")
  
  ProductView.Properties("EntityType").Caption 	        = mom_GetDictionary("TEXT_AUDIT_ENTITY_TYPE_ID")
  ProductView.Properties("id_UserId").Caption 	        = mom_GetDictionary("TEXT_AUDIT_USER_ID")
  ProductView.Properties("id_entitytype").Caption 	    = mom_GetDictionary("TEXT_AUDIT_ENTITY_TYPE_ID")
  ProductView.Properties("id_entity").Caption 	        = mom_GetDictionary("TEXT_AUDIT_ENTITY_ID")
  ProductView.Properties("dt_crt").Caption 	            = mom_GetDictionary("TEXT_AUDIT_DT_CRT")
  ProductView.Properties("tx_logged_in_as").Caption 	  = mom_GetDictionary("TEXT_AUDIT_TX_LOGGED_IN_AS")
  ProductView.Properties("tx_application_name").Caption = mom_GetDictionary("TEXT_AUDIT_TX_APPLICATION_NAME")
  ProductView.Properties("Time").Sorted                 = MTSORT_ORDER_DESCENDING
  mdm_SetMultiColumnFilteringModeWithCustomProperties "~Time~EntityName~UserName~EntityId~"

  'Set current time message
  '//dim strCurrentTime
  '//strCurrentTime = ProductView.Tools.Format(ProductView.Tools.GetCurrentGMTTime,strGMTDateFormat)
  '//Service.Properties.Add "CurrentGMTTimeMessage", "String",  256, FALSE, TRUE, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  '//Service.Properties("CurrentGMTTimeMessage") = mom_GetDictionary("TEXT_CURRENT_GMT_TIME_IS") & " " & strCurrentTime

  ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he
  ' wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date
  ' else one.
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

PRIVATE FUNCTION Form_Export(EventArg) ' As Boolean
  Form_Export = Form_Export_Transform(EventArg)
END FUNCTION

%>
