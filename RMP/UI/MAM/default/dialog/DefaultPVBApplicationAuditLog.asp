<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<% 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' MetraTech Dialog Manager Framework ASP Dialog Template
' 
' DIALOG	    :
' DESCRIPTION	:
' AUTHOR	    :
' VERSION	    :
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
'Redirect to new page
If(UCase(mdm_UIValueDefault("SubscriberMode",FALSE))="TRUE")Then
    Response.Redirect("/MetraNet/Audit/AuditLog.aspx?SubscriberMode=TRUE")
Else
     Response.Redirect("/MetraNet/Audit/AuditLog.aspx")
End If

Response.End



' Set a unique form key for the dialog before the form is loaded.
' This only needs to be set the first time the dialog loads,
' then it uses the hidden mdmFormUniqueKey.  This allows the 
' shared dialog to act as different dialogs.
'If(UCase(mdm_UIValueDefault("SubscriberMode",FALSE))="TRUE")Then
'    mdm_SetDialogID "SUBSCRIBER"
'Else
'     mdm_SetDialogID "APPLICATION"
'End If

%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.ProductViewMsixdefFileName 	= "metratech.com\Audit.msixdef"
Form.RouteTo			                =  mam_GetDictionary("WELCOME_DIALOG")
Form.Page.MaxRow                  =  CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage     =  mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

If(UCase(mdm_UIValueDefault("SubscriberMode",FALSE))="TRUE")Then
     Form.HelpFile = "DefaultPVBSubscriberAuditLog.hlp.htm"
Else
     Form.HelpFile = "DefaultPVBApplicationAuditLog.hlp.htm"
End If

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Export(EventArg) ' As Boolean
  Form_Export = Form_Export_Transform(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
  	ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
                    
    Form("SubscriberMode")  = CBool(UCase(Request.QueryString("SubscriberMode"))="TRUE")
    
    If(Form("SubscriberMode"))Then
    
        mdm_GetDictionary.Add "DYNAMIC_TEXT_AUDIT_LOG_TITLE",mam_GetDictionary("TEXT_ACCOUNT_AUDIT_LOG")
    Else
        mdm_GetDictionary.Add "DYNAMIC_TEXT_AUDIT_LOG_TITLE",mam_GetDictionary("TEXT_APPLICATION_AUDIT_LOG")
    End If    
    
    Form.ShowExportIcon = TRUE ' Export

 	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim i, booExecSucceed
  
  '//Tell MDM not to apply the ADO filter when we set the rowset since we will use the filter in the backend
  Form.Grid.ApplyFilter = FALSE 
  
  dim objMTFilter
  Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter")
  '//We want to only show changes to accounts
  objMTFilter.Add "EntityType", MT_OPERATOR_TYPE_EQUAL, 1
  
  dim iShowMaxRecords
  iShowMaxRecords = 1000
  
  If(Form("SubscriberMode"))Then
    objMTFilter.Add "EntityId", MT_OPERATOR_TYPE_EQUAL, Clng(MAM().Subscriber("_AccountId"))
  End If
  
  '//Have the MDM add the user specified filter conditions to our filter
  mdm_SetFilterObjectFromCurrentFilterSettings objMTFilter

  dim objAuditLogManager
  set objAuditLogManager = mdm_CreateObject("MetraTech.Audit.AuditLogManager")
  objAuditLogManager.MaximumNumberRecords = iShowMaxRecords
  
  dim rowset
  set rowset = objAuditLogManager.GetAuditLogAsRowset((objMTFilter))
  
  ' Check to see if items have been filtered and inform the user
  If iShowMaxRecords>0 AND rowset.RecordCount >= iShowMaxRecords Then
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", TRUE
  ELSE
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", FALSE      
  End If
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = rowset
  ProductView.Properties.AddPropertiesFromRowset rowset

  booExecSucceed = true
  
  If(booExecSucceed)Then
      
      IF FALSE THEN
      
          ' Select the properties I want to print in the PV Browser   Order
      	  ProductView.Properties.ClearSelection
          i=1
          ProductView.Properties("dt_crt").Selected                  = i : i=i+1
          ProductView.Properties("id_acc_subscriber").Selected 		   = i : i=i+1
          ProductView.Properties("tx_description").Selected          = i : i=i+1
          ProductView.Properties("tx_csrID").Selected 			         = i : i=i+1    
          ProductView.Properties("amount").Selected 			           = i : i=i+1
          
          ProductView.Properties("amount").Format                    = mam_GetDictionary("AMOUNT_FORMAT")
          ProductView.Properties("dt_crt").Format 			             = mam_GetDictionary("DATE_TIME_FORMAT")
              
          ProductView.Properties("dt_crt").Sorted                    = MTSORT_ORDER_DECENDING  ' Sort      
         
          Service.Properties.TimeZoneId                              = MAM().CSR("TimeZoneId") ' Set the TimeZone, so the dates will be printed for the CSR time zone  
          Service.Properties.DayLightSaving                          = mam_GetDictionary("DAY_LIGHT_SAVING")
          
          ProductView.Properties("amount").Alignment                 = "right"
          ProductView.Properties("tx_csrID").Alignment               = "right"
          ProductView.Properties("id_acc_subscriber").Alignment      = "right"
      
          ProductView.Properties("dt_crt").Caption                   = mam_GetDictionary("TEXT_TIMESTAMP")
          ProductView.Properties("tx_description").Caption           = mam_GetDictionary("TEXT_DESCRIPTION")
          ProductView.Properties("tx_csrID").Caption 			           = mam_GetDictionary("TEXT_CSR_ID")
          ProductView.Properties("id_acc_subscriber").Caption 		   = mam_GetDictionary("TEXT_ACCOUNT_ID")
          ProductView.Properties("amount").Caption 			             = mam_GetDictionary("TEXT_AMOUNT")        
      END IF
      
      ProductView.Properties.ClearSelection                       ' Select the properties I want to print in the PV Browser   Order
      ProductView.Properties("Time").Selected 			      = 1
      ProductView.Properties("UserName").Selected 	      = 2
      ProductView.Properties("EventName").Selected 	      = 3
      ProductView.Properties("EntityName").Selected 	    = 4
      ProductView.Properties("Details").Selected 	        = 5
      
      ProductView.Properties("Time").Caption 		          = mam_GetDictionary("TEXT_AUDIT_TIME")
      ProductView.Properties("UserName").Caption 	        = mam_GetDictionary("TEXT_AUDIT_USERNAME")
      ProductView.Properties("EventName").Caption 	      = mam_GetDictionary("TEXT_AUDIT_EVENTNAME")
      ProductView.Properties("EntityName").Caption 	      = mam_GetDictionary("TEXT_AUDIT_ENTITYNAME")
      ProductView.Properties("Details").Caption 	        = mam_GetDictionary("TEXT_AUDIT_DETAILS")      
      ProductView.Properties("EntityId").Caption 	        = mam_GetDictionary("TEXT_AUDIT_ENTITY_ID")
      ProductView.Properties("id_audit").Caption 	        = mam_GetDictionary("TEXT_AUDIT_AUDIT_ID")
      ProductView.Properties("id_Event").Caption 	        = mam_GetDictionary("TEXT_AUDIT_EVENT_ID")      
      ProductView.Properties("UserId").Caption 	          = mam_GetDictionary("TEXT_AUDIT_USER_ID")
      ProductView.Properties("EventId").Caption 	        = mam_GetDictionary("TEXT_AUDIT_EVENT_ID")      
      ProductView.Properties("EntityType").Caption 	      = mam_GetDictionary("TEXT_AUDIT_ENTITY_TYPE_ID")
      ProductView.Properties("id_UserId").Caption 	      = mam_GetDictionary("TEXT_AUDIT_USER_ID")
      ProductView.Properties("id_entitytype").Caption 	  = mam_GetDictionary("TEXT_AUDIT_ENTITY_TYPE_ID")
      ProductView.Properties("id_entity").Caption 	      = mam_GetDictionary("TEXT_AUDIT_ENTITY_ID")
      ProductView.Properties("dt_crt").Caption 	          = mam_GetDictionary("TEXT_AUDIT_DT_CRT")      
        
      ProductView.Properties("Time").Sorted               = MTSORT_ORDER_DESCENDING
      
      mdm_SetMultiColumnFilteringMode TRUE
    
      ' REQUIRED because we must generate the property type info in javascript. When the user change the property which he
      ' wants to use to do a filter we use the type of the property (JAVASCRIPT code) to show 2 textbox if it is a date
      ' else one.
      ProductView.LoadJavaScriptCode
    
      Form_LoadProductView = TRUE 
 End If 
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Form_DisplayCell
' PARAMETERS :
' DESCRIPTION :
' RETURNS    : 
PUBLIC FUNCTION Form_DisplayCell(EventArg) ' As Boolean
    Select Case Form.Grid.Col
        case 5
            dim sEventName, idEvent, sImageName
            sEventName = ProductView.Properties("EventName")
            idEvent = ProductView.Properties("id_event")
            
            select case idEvent
              case 5000
              sEventName = "<img border=0 align='absmiddle' src='\mam\default\localized\us\images\note_small.gif'>&nbsp;" & sEventName
              case 5001
              sEventName = "<img border=0 align='absmiddle' src='\mam\default\localized\us\images\phone_small.gif'>&nbsp;" & sEventName
            end select
              
            EventArg.HTMLRendered = "<td class=" & Form.Grid.CellClass & " nowrap>" & sEventName & "</td>"
            Form_DisplayCell = TRUE                
        
        case 7
            dim sDetails
            if len(ProductView.Properties("Details"))>256 then
              dim sTurndownLink,strImage,strPageAction
              If(Form.Grid.TurnDowns.Exist("R" & Form.Grid.Row))Then
                strPageAction       = MDM_ACTION_TURN_RIGHT
              Else
                strPageAction       = MDM_ACTION_TURN_DOWN
              End If
             
             sDetails = left(ProductView.Properties("Details"),256)
             sDetails = sDetails & "&nbsp;&nbsp;<b>[&nbsp;<A href='" & request.serverVariables("URL")  & "?mdmPageAction=" & strPageAction & "&mdmRowIndex=" & Form.Grid.Row &  "'>more</a>&nbsp;]</b>"

            else
              sDetails = ProductView.Properties("Details")
            end if
            EventArg.HTMLRendered = "<td class=" & Form.Grid.CellClass & ">" & replace("" & sDetails, vbNewLine, "<br>") & "</td>"
            Form_DisplayCell = TRUE                
        Case Else        
            Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select
END FUNCTION


PRIVATE FUNCTION Form_DisplayDetailRow(EventArg) ' As Boolean

    Dim objProperty
    Dim strSelectorHTMLCode
    Dim strValue
    Dim strCurrency
    Dim strHTMLAttributeName
    
    'Set objProperty = ProductView.Properties.Item(Form.Grid.PropertyName)
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td></td><td></td>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td ColSpan=" & (ProductView.Properties.Count+2) & " width=600>" & vbNewLine
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<TABLE width='100%' border=0 cellpadding=1 cellspacing=2>" & vbNewLine
    
    set objProperty = ProductView.Properties("Details")
    WriteDetailRow ProductView.Properties("Details"), EventArg
    WriteDetailRow ProductView.Properties("EntityId"), EventArg
    WriteDetailRow ProductView.Properties("id_audit"), EventArg
    WriteDetailRow ProductView.Properties("id_event"), EventArg
    
    if false then
      For Each objProperty In ProductView.Properties
  
          If(UCase(objProperty.Name)<>"MDMINTERVALID") And ((objProperty.Flags And eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET)=0) Then    
            ' Check the columns to exclude...
            If(InStr(UCase("UserId,EventId,id_entity,id_UserId,dt_crt,id_entitytype"),UCase(objProperty.Name))=0)Then 
            
              If(objProperty.UserVisible)Then
                 WriteDetailRow objProperty, EventArg
              End If
            End If        
          End If  
      Next
    end if
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</TABLE>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
    
    Form_DisplayDetailRow = TRUE
END FUNCTION
   
   
' -- NOT USED --
PRIVATE FUNCTION xForm_DisplayCell(EventArg) ' As Boolean

Dim strSelectorHTMLCode

Select Case Form.Grid.Col

    Case 2,1      
        EventArg.HTMLRendered = "<td style='display:none;' ></td>"
        Form_DisplayCell      = TRUE

    Case ProductView.Properties("id_acc_subscriber").Selected + 2
          strSelectorHTMLCode = ProductView.Properties("id_acc_subscriber") & " - " & GetUserNameFromAccountID(ProductView.Properties("id_acc_subscriber"))
          EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strSelectorHTMLCode & "</td>"
          Form_DisplayCell = TRUE
                        
    Case Else
        Form_DisplayCell = inherited("Form_DisplayCell()")
End Select
END FUNCTION                

' -- NOT USED --
PRIVATE FUNCTION xForm_DisplayHeaderCell(EventArg) ' As Boolean

    Dim strAspPage, strSortedImage, objPreProcessor, strHTMLTemplate
     
    Select Case Form.Grid.Col
        Case 1,2
            'EventArg.HTMLRendered = "<td nowrap class='TableHeader' width='1'></td>"
            EventArg.HTMLRendered ="<td style='display:none;' ></td>"
        Case Else
            Form_DisplayHeaderCell  = inherited("Form_DisplayHeaderCell()")
    End Select
    Form_DisplayHeaderCell = TRUE
END FUNCTION  

PRIVATE FUNCTION WriteDetailRow(objProperty,EventArg)
                
                dim strHTMLAttributeName,strValue
                strHTMLAttributeName  = "TurnDown." & objProperty.caption & "(" & Form.Grid.Row & ")"
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr>" & vbNewLine
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Class='TableDetailCell' valign='top' nowrap style='text-align:right;border:0px none' width='60px'><b>" & objProperty.caption & "</b></td>" & vbNewLine
                
                'strValue = TRIM("" & objProperty.NonLocalizedValue)
                strValue = TRIM("" & objProperty.value)
                If(Len(strValue)=0)Then
                    strValue  = "&nbsp;"
                End If
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Name='" & strHTMLAttributeName & "' Class='TableDetailCell' style='border:0px none'>" & replace("" & strValue, vbNewLine, "<br>") & " </td>" & vbNewLine
                EventArg.HTMLRendered = EventArg.HTMLRendered & "</tr>" & vbNewLine
END FUNCTION           

%>
