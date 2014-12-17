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
Form.ErrorHandler               = false  
Form.ShowExportIcon             = TRUE
Form.Page.MaxRow                = CLng(FrameWork.GetDictionary("MAX_ROW_PER_LIST_PAGE"))
Form.Page.NoRecordUserMessage   = FrameWork.GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework


PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    'BreadCrumb.SetCrumb FrameWork.GetDictionary("TEXT_VIEW_AUDIT_LOG")
    ProductView.Clear  ' Set all the property of the service to empty or to the default value
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    Form("RS_ID")   = CLng(Request.QueryString("RS_ID"))
    Form("PT_ID")   = CLng(Request.QueryString("PT_ID"))
    'Form("PL_ID")   = CLng(Request.QueryString("PL_ID"))
    
    'response.write(Form("RS_ID") )
    'response.end

	  Form_Initialize = true
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
  
  dim rowset2
  set rowset2 = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  rowset2.Init "queries\audit"
  rowset2.SetQueryTag("__SELECT_RATE_SCHEDULE_DISPLAY_INFORMATION__")
  'rowset2.SetQueryString("select nm_name from t_base_props bp join t_rsched rs on bp.id_prop = rs.id_pricelist and rs.id_sched=%%RS_ID%%")
  rowset2.AddParam "%%RS_ID%%", Clng(Form("RS_ID"))
  rowset2.AddParam "%%TX_LANG_CODE%%", GetFrameworkAppLanguageFromPageLanguage(Session("FRAMEWORK_APP_LANGUAGE"))
  rowset2.Execute

    dim pt_id
  if rowset2.RecordCount=0 then
    set rowset2 = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset2.Init "queries\audit"
    rowset2.SetQueryTag("__SELECT_RATE_SCHEDULE_DISPLAY_INFORMATION__")
    rowset2.AddParam "%%RS_ID%%", Clng(Form("RS_ID"))
    rowset2.AddParam "%%TX_LANG_CODE%%", GetFrameworkAppLanguageFromPageLanguage("en-us")
    rowset2.Execute
  end if
    pt_id = rowset2.value("ParamTableId")


    Form("PT_ID") = pt_id 
  
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
    rowset.Init "queries\audit"
    rowset.SetQueryTag("__GET_PARAMTABLE_TABLENAME_FROM_PARAMTABLE_ID__")
    rowset.AddParam "%%PT_ID%%", Clng(Form("PT_ID"))
    rowset.Execute
  
    dim sPT
    sPT = rowset.Value("nm_instance_tablename")
  
    rowset.SetQueryTag("__SELECT_AUDIT_ENTRIES_FOR_RULESET_UPDATE_ON_PARAMETER_TABLE__")
    rowset.AddParam "%%RS_ID%%", Clng(Form("RS_ID"))
    rowset.AddParam "%%PARAM_TABLE_DB_NAME%%", sPT
    rowset.Execute
  
    ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
    Set ProductView.Properties.RowSet = rowset
    ProductView.Properties.AddPropertiesFromRowset rowset
  
  'ProductView.Properties.SelectAll
  ProductView.Properties.ClearSelection                       ' Select the properties I want to print in the PV Browser   Order
  ProductView.Properties("Time").Selected 			      = 1

  ProductView.Properties("UserName").Selected 	      = 2
  ProductView.Properties("EventName").Selected 	      = 3
  ProductView.Properties("EntityName").Selected 	    = 4
  'ProductView.Properties("Details").Selected 	        = 5

  ProductView.Properties("Time").Caption 		          = FrameWork.GetDictionary("TEXT_AUDIT_TIME")
  ProductView.Properties("UserName").Caption 	        = FrameWork.GetDictionary("TEXT_AUDIT_USERNAME")
  ProductView.Properties("EventName").Caption 	      = FrameWork.GetDictionary("TEXT_AUDIT_EVENTNAME")
  ProductView.Properties("EntityName").Caption 	      = " " 'FrameWork.GetDictionary("TEXT_AUDIT_ENTITYNAME")
  'ProductView.Properties("Details").Caption 	        = FrameWork.GetDictionary("TEXT_AUDIT_DETAILS")
  
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
  
  Set Form.Grid.FilterProperty                        = ProductView.Properties("UserName") ' Set the property on which to apply the filter  

  '//Get the name of the pricelist and the parameter table for screen display
  Service.Properties.Add "PriceListName", "string", 1024, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "ParamTableName", "string", 1024, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "ParamTableDisplayName", "string", 1024, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "ParamTableIcon", "string", 0, False, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  
  'dim rowset2
  'set rowset2 = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  'rowset2.Init "queries\audit"
  'rowset2.SetQueryString("select nm_name from t_base_props bp join t_rsched rs on bp.id_prop = rs.id_pricelist and rs.id_sched=%%RS_ID%%")
  'rowset2.AddParam "%%RS_ID%%", Clng(Form("RS_ID"))
  'rowset2.Execute

  if len(rowset2.value("PriceListName"))>0 then
    'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
    'Adding HTML Encoding
    'Service.Properties("PriceListName") = rowset2.value("PriceListName")   
    Service.Properties("PriceListName") = SafeForHtml(rowset2.value("PriceListName"))
  else
    '//If the pricelist name is blank, we infer it must be an ICB pricelist
    Service.Properties("PriceListName") = FrameWork.GetDictionary("TEXT_ICB_PRICELIST_DISPLAY_NAME")
  end if
  
  'rowset2.SetQueryString("select nm_display_name, nm_name from t_vw_base_props bp join t_language lang on bp.id_lang_code=lang.id_lang_code where id_prop=%%PT_ID%% and lang.tx_lang_code='%%TX_LANG_CODE%%'")
  'rowset2.AddParam "%%PT_ID%%", Clng(Form("PT_ID"))
  'rowset2.AddParam "%%TX_LANG_CODE%%", Session("FRAMEWORK_APP_LANGUAGE")
  'rowset2.Execute

  Service.Properties("ParamTableName") = rowset2.value("ParamTableName")
  Service.Properties("ParamTableDisplayName") = rowset2.value("ParamTableDisplayName")
  Service.Properties("ParamTableIcon") = mdm_GetIconUrlForParameterTable(rowset2.value("ParamTableName"))
   
  Form_LoadProductView = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION

PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

       if Form.Grid.Col<=2 then
          if Form.Grid.Col=22222 then
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "' nowrap>&nbsp;</td>"
          else
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)") 
          end if
       else
         Select Case lcase(Form.Grid.SelectedProperty.Name)
         Case "entityname"
            dim EventId, RuleSetStartDate, strHTML
            EventId = ProductView.Properties.RowSet.Value("EventId")
            RuleSetStartDate = ProductView.Properties.RowSet.Value("RuleSetStartDate")
            if EventId=1402 then 'Ruleset Update
              dim sPageInfo
              'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
              sPageInfo = "Price list <strong>" & SafeForHtml(Service.Properties("PriceListName")) & "</strong><br>modified by <strong>" & SafeForHtml(ProductView.Properties.RowSet.Value("UserName")) & "</strong> at <strong>" & SafeForHtml(ProductView.Properties.RowSet.Value("Time")) & "</strong>"
              sPageInfo = SafeForHtmlAttr(SafeForUrl(sPageInfo))
              'Updating HTML Encoding
              'strHTML = "<button name='viewchanges12' class='clsButtonBlueLarge' onclick=""window.open('gotoRuleEditorViewDifference.asp?Title=" & sPageInfo & "&PT_ID=" & Form("PT_ID") & "&RS_ID_1=" & Form("RS_ID") & "&RS_STARTDATE_1=" & Server.UrlEncode(RuleSetStartDate) & "','_blank', 'height=800,width=1000,resizable=1,scrollbars=1');"">View Changes</button>"
              strHTML = "<button id='viewchanges12' class='clsButtonBlueLarge' onclick=""window.open('gotoRuleEditorViewDifference.asp?Title=" & sPageInfo & "&PT_ID=" & Form("PT_ID") & "&RS_ID_1=" & Form("RS_ID") & "&RS_STARTDATE_1=" & SafeForHtmlAttr(RuleSetStartDate) & "','_blank', 'height=800,width=1000,resizable=1,scrollbars=1'); return false;"">View Changes</button>"
            else
              strHTML = "&nbsp;"       
            end if
            
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>"  & strHTML & "</td>" 
            
  			    Form_DisplayCell = TRUE
  	     Case else
            'EventArg.HTMLRendered = "<td class='" & Form.Grid.CellClass & "'>"  & Form.Grid.SelectedProperty.Name & "</td>" 
            'Form_DisplayCell = TRUE
            Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
      End Select
     end if

    Form_DisplayCell = true

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
              
                  'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
                  'Adding HTML Encoding
                  strHTMLAttributeName  = "TurnDown." & SafeForHtmlAttr(objProperty.Name) & "(" & Form.Grid.Row & ")"
                  EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr>" & vbNewLine
                  EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Class='TableDetailCell' nowrap>" & objProperty.Caption & "</td>" & vbNewLine
                  
                  'strValue = TRIM("" & objProperty.NonLocalizedValue)
                  strValue = TRIM("" & objProperty.Value)
                  If(Len(strValue)=0)Then
                      strValue  = "&nbsp;"
                  End If
                  'EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Name='" & strHTMLAttributeName & "' Class='TableDetailCell' nowrap>" & strValue & " </td>" & vbNewLine
                  EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Name='" & strHTMLAttributeName & "' Class='TableDetailCell' nowrap>" & SafeForHtmlAttr(strValue) & " </td>" & vbNewLine
                  EventArg.HTMLRendered = EventArg.HTMLRendered & "</tr>" & vbNewLine
              End If
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
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp
    
    
    strTmp = "</table><div align=center><BR><BR><button  name='CLOSE' Class='clsOkButton' onclick='window.close();'>" & FrameWork.GetDictionary("TEXT_CLOSE") & "</button><BR>" & vbNewLine
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
        
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</FORM>"
    
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION

PUBLIC FUNCTION GetFrameworkAppLanguageFromPageLanguage(strPageLanguage)
  IF (LCASE(strPageLanguage) = "pt-br" OR LCASE(strPageLanguage) = "es-mx") THEN
    GetFrameworkAppLanguageFromPageLanguage = strPageLanguage
  END IF
  Dim dashIndex 
  dashIndex = INSTR(strPageLanguage,"-")
  IF ( dashIndex > 0)  THEN
    GetFrameworkAppLanguageFromPageLanguage = LCASE(CSTR(MID(strPageLanguage, dashIndex + 1, LEN(strPageLanguage))))
  ELSE
    GetFrameworkAppLanguageFromPageLanguage = strPageLanguage
  END IF
END FUNCTION

%>
