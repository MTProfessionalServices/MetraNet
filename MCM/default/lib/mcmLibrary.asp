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
' NAME		        : MCM - MetraTech Catalog Manager - VBScript Library
' VERSION	        : 1.0
' CREATION_DATE   : 4/6/2001
' AUTHOR	        : UI Team
' DESCRIPTION	    : 
' ----------------------------------------------------------------------------------------------------------------------------------------

PUBLIC CONST MCM_TEST_MODE        = FALSE ' By turning off and on the bool some dialog behave for test mode...
PUBLIC CONST MCM_LOGIN_NAME_SPACE = "system_user" ' for 
CONST DEFAULT_END_DATE_TIME_24    =  "23:59:59"
CONST DEFAULT_END_DATE_TIME       =  "11:59:59 PM"


PUBLIC FUNCTION mcm_CheckEndDate(objEventArg,strProperty)

      If objEventArg.UIParameters.Exist(strProperty) Then      
      
          objEventArg.UIParameters(strProperty).Value = mdm_format(mcm_SetTimeToDefaultEndDateTimeIfTimeNotSet(objEventArg.UIParameters(strProperty).Value), mdm_GetDictionary().GetValue("DATE_FORMAT"))
      End If
      mcm_CheckEndDate = TRUE
END FUNCTION

'-----------------------------------------------------------------------------
' FUNCTION 			: mcm_IsDate
' PARAMETERS		: dateStr
' DESCRIPTION 	: Validates dateStr as a valid MCM date string.  In addition
'                 using the library function IsDate we also make sure that the
'                 date string contains no "."s as the Product Catalog objects
'                 don't like these.
' RETURNS			  : TRUE if dateStr contains a valid date string, FALSE if not.
' 
PUBLIC FUNCTION mcm_IsDate(dateStr)

  mcm_IsDate = FrameWork.IsValidDate(dateStr,true)
  if false then
  dim sValidChars,bValidChars
  sValidChars = Framework.GetDictionary("MDM_TYPE_TIMESTAMP_CHARS")
  bValidChars = true
  
  dim i
  for i=1 to len(dateStr) 
    if InStr(sValidChars,Mid(dateStr,i,1)) = 0 Then
      bValidChars=false
      response.write("Character [" & i & "]")
      response.end
      exit for
    end if
  next
  
  If IsDate(dateStr) and bValidChars Then
    mcm_IsDate = TRUE
  Else
    mcm_IsDate = FALSE
	End If
  End If
END FUNCTION


FUNCTION mcm_SetTimeToDefaultEndDateTimeIfTimeNotSet(strDate)

    Dim varDate
    
    If Len(Trim(strDate))=0 Then
        mcm_SetTimeToDefaultEndDateTimeIfTimeNotSet = strDate        
        Exit Function
    End If
    
    On Error Resume Next
    varDate = CDate(mdm_NormalDateFormat(strDate))
    
    If Err.Number Then ' Date convertion error we just give up the mdm will take care of it+
        Err.Clear
        mcm_SetTimeToDefaultEndDateTimeIfTimeNotSet = strDate        
        Exit Function
    End If

    If Hour(varDate)=0 And Minute(varDate)=0 And Second(varDate)=0 And Instr(strDate,":")=0 Then ' This mean the time is not in strDate
			If CBool(FrameWork.GetDictionary("MDM_USE_24HOUR_CLOCK")) Then
      	mcm_SetTimeToDefaultEndDateTimeIfTimeNotSet = Trim(strDate) & " " & DEFAULT_END_DATE_TIME_24
			Else
				mcm_SetTimeToDefaultEndDateTimeIfTimeNotSet = Trim(strDate) & " " & DEFAULT_END_DATE_TIME
			End if
    Else
      mcm_SetTimeToDefaultEndDateTimeIfTimeNotSet = strDate
    End If
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: mcm_IncludeCalendar
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PUBLIC FUNCTION mcm_IncludeCalendar() ' As Boolean

    ' Load the Calendar widget
    Form.Widgets.Add "Calendar", FrameWork.WidgetsPath() & "\Calendar\Calendar.Header.htm", FrameWork.WidgetsPath() & "\Calendar\Calendar.Footer.htm"
    mcm_IncludeCalendar = TRUE
END FUNCTION

PUBLIC FUNCTION NoTurnDownHTML(EventArg)
      EventArg.HTMLRendered     = "<td class='" & Form.Grid.CellClass & "' width='1'></td>" ' No Turn Down
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION          : Form_DisplayErrorMessage
' PARAMETERS        :
' DESCRIPTION       : Override the MDM event Form_DisplayErrorMessage, so we can define our own VBScript
'                     to print an error
' RETURNS           :
PUBLIC FUNCTION Form_DisplayErrorMessage(EventArg) ' As Boolean
  
  Dim strPath, strDetail

  strPath   = FrameWork.GetDictionary("DEFAULT_PATH_REPLACE")
    
  ' write clsErrorText style so MDM will pick it up
  Response.write "<br><br>" & vbNewLine
  Response.write "<style>" & vbNewLine
  Response.write ".ErrorCaptionBar{	BACKGROUND-COLOR: #FDFECF;	BORDER-BOTTOM:#9D9F0F solid 1px;	BORDER-LEFT: #9D9F0F solid 1px;	BORDER-RIGHT: #9D9F0F solid 1px;	BORDER-TOP:#9D9F0F solid 1px; COLOR: black;	FONT-FAMILY: Arial;	FONT-SIZE: 10pt;	FONT-WEIGHT: bold;	TEXT-ALIGN: left;	padding-left : 5px;	padding-right : 5px;	padding-top : 2px;	padding-bottom : 2px;}" & vbNewLine
  Response.write "</style>" & vbNewLine
  Response.write "  <center><TABLE BGCOLOR=""#FFFFC4"" BORDER=""0"" CELLSPACING=""0"" CELLPADDING=""0"" BORDERCOLOR=""Black"" style=""margin-top: 5px;"">" & vbNewLine
  Response.write "  <TR>" & vbNewLine
  Response.write "  <TD nowrap Class='ErrorCaptionBar'>"  & vbNewLine
  Response.write "   <IMG SRC='" & strPath & "/images/error.gif' valign=""center"" BORDER=""0"" >&nbsp;" & vbNewLine

	If(Not EventArg.Error.IsUserError)Then
	
			EventArg.Error.LocalizedDescription = FrameWork.GetDictionary("MCM_ERROR_999")
	End If
	
  If Len(EventArg.Error.LocalizedDescription) Then
	    
      Response.write  ConvertCRLFToHTMLBreak(FrameWork.Dictionary.PreProcess(EventArg.Error.LocalizedDescription)) ' The PreProcess takes care of the key word in the error message
			
  ElseIf Len(EventArg.Error.Description) Then   

      Response.write  ConvertCRLFToHTMLBreak(FrameWork.Dictionary.PreProcess(EventArg.Error.Description)) ' The PreProcess takes care of the key word in the error message
  Else
	
      Response.write ConvertCRLFToHTMLBreak(FrameWork.GetDictionary("MCM_ERROR_999"))
  End If

  'SECENG: CORE-4768 CLONE - MSOL 26810 Metracare: Reflected cross-site scripting [/mam/default/dialog/RoleAdd.asp in 'name' parameter] (Post-PB)
  'Added HTML encoding
  strDetail = "Number=" & EventArg.Error.Number & " Description=" & SafeForHtml(EventArg.Error.Description) & " Source=" & SafeForHtml(EventArg.Error.Source)
  
  strDetail = Replace(strDetail,"\","|")
  strDetail = Replace(strDetail,vbNewLine,"")
  strDetail = Replace(strDetail,Chr(13),"")
  strDetail = Replace(strDetail,Chr(10),"")
  strDetail = Replace(strDetail,"'","\'")
  strDetail = Replace(strDetail,"; ","\n")
  strDetail = Replace(strDetail,";","")
  
  Response.write "<BR><BR><CENTER><FONT size=2><A Name='butDetail' HREF='#' OnClick=""alert('" & strDetail & "')"">" & vbNewLine
  Response.write FrameWork.GetDictionary("MCM_ERROR_ERROR_DETAIL") & vbNewLine
  Response.write "</A></FONT></CENTER>"  & vbNewLine
  Response.write "    </TD>"  & vbNewLine
  Response.write "    </TR>" & vbNewLine
  Response.write "  </TABLE></center>" & vbNewLine
  
  Form_DisplayErrorMessage = TRUE
END FUNCTION

FUNCTION ConvertCRLFToHTMLBreak(s)
	    'SECENG: CORE-4768 CLONE - MSOL 26810 Metracare: Reflected cross-site scripting [/mam/default/dialog/RoleAdd.asp in 'name' parameter] (Post-PB)
	    'Added HTML encoding
		s = Replace(SafeForHtml(s),vbNewLine,"<br>")
		s = Replace(s,Chr(13),"<br>")
		s = Replace(s,Chr(10),"<br>")
		ConvertCRLFToHTMLBreak = s
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Shared_ContainedParameterTables_DisplayCell
' PARAMETERS		  :
' DESCRIPTION 		: This is a shared function for displaying pricelist mappings for parameter tables in a product offering. It is called
'                   from each of the priceable item view/edit screens.
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Shared_ContainedParameterTables_DisplayCell(EventArg) ' As Boolean

  Select Case lcase(EventArg.Grid.SelectedProperty.Name)
  Case "tpt_nm_name"

    dim sParamTableDisplayName,sParamTableName
    sParamTableDisplayName = EventArg.Grid.Rowset.Value("nm_display_name")
    sParamTableName = EventArg.Grid.Rowset.Value("tpt_nm_name")
    if isNull(sParamTableDisplayName) or len(sParamTableDisplayName) = 0 then
      sParamTableDisplayName = sParamTableName
    'else
    '  sParamTableName = sParamTableName & "&nbsp;(" & EventArg.Grid.Rowset.Value("tpt_nm_name") & ")"
    end if
    
    dim sIconHref
    sIconHref = GetIconUrlForParameterTable(sParamTableDisplayName,sParamTableName)

    dim sEditRatesHref
    sEditRatesHref =  "Rates.RateSchedule.List.asp?Title=TEXT_CHOOSE_RATE_SCHEDULE&ID=" & FORM("POID") & "&PT_ID=" & EventArg.Grid.Rowset.Value("id_paramtable") & "&PI_ID=" & FORM("ID") & "&&Parameters=Title|TEXT_CHOOSE_RATE_SCHEDULE;POBased|TRUE&POBased=TRUE&Rates=TRUE&mdmReload=True&PRICELISTNAME=" & server.urlencode (EventArg.Grid.Rowset.Value("tpl_nm_name"))
    
    dim sHoverText
    sHoverText = sParamTableName & vbCRLF & vbCRLF & "Click to edit or view rates for the parameter table on the mapped pricelist (" & EventArg.Grid.Rowset.Value("tpl_nm_name") & ")"
    EventArg.HTMLRendered     =  "<td title='" & sHoverText & "' class='" & EventArg.Grid.CellClass & "'><img align='absmiddle' src='" & sIconHref & "'>&nbsp;<a href='" & sEditRatesHref & "'>" & sParamTableDisplayName & "</a></td>"            
    ContainedParameterTables_DisplayCell = TRUE			

    Case "tpl_nm_name"
    
      dim strName
      strName = "" & EventArg.Grid.Rowset.Value("tpl_nm_name")          
      ' See if we have a pricelist mapping
      if LTRIM(RTRIM(strName)) = "" then
        strName = "<img align='top' border=0 src='" & FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/icons/warningSmall.gif'>" & FrameWork.GetDictionary("TEXT_NO_PRICE_LIST_MAPPING_MESSAGE")
      else
        if CLng(EventArg.Grid.Rowset.Value("id_pricelist")) = CLng(Form("NonSharedPLID")) then
          strName = "<em>" & FrameWork.GetDictionary("TEXT_NONSHARED") & "</em>"
        else
          strName = "" & EventArg.Grid.Rowset.Value("tpl_nm_name")
        end if
      end if    
      EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'>" & strName & "&nbsp;&nbsp;" & "</td>"
      ContainedParameterTables_DisplayCell = TRUE
          
    Case "id_pricelist"
      ' Hijacked this property/column to display the selct pricelist button in a separate column
      ' The button are named EditMapping1, EditMapping2 for fred runner
      dim strLinkParams
      strLinkParams = "ID|" & Request("ID") & ";EditMode|False;POBased|" & Request("POBased") & ";Kind|" & Request("Kind") & ";Automatic|" & Request("Automatic")
      EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'>"  & _
            "<button class='clsButtonBlueMedium' name=""EditMapping_" & EventArg.Grid.Rowset.Value("tpt_nm_name") & """ onclick=""window.open('PriceListMapping.Edit.asp?ID=" & EventArg.Grid.Rowset.Value("id_paramtable") & "&NonSharedPLID=" & Form("NonSharedPLID") & "&PI_ID=" & Request("ID") & "&NextPage=PriceableItem.Usage.ViewEdit.asp&MonoSelect=TRUE&Title=TEXT_SELECT_PRICELIST_MAPPING&Parameters=PickerAddMapping|TRUE;" & strLinkParams & ";PARAMTABLEID|" & EventArg.Grid.Rowset.Value("id_paramtable")  & "','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes')"">" & FrameWork.GetDictionary("TEXT_EDIT") & " Mapping" & "</button></td>"                       
            
      ContainedParameterTables_DisplayCell = TRUE      
                      
		Case "b_canicb" 
      if UCase(EventArg.Grid.SelectedProperty.Value) = "Y" then
        EventArg.HTMLRendered = ""
        EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "'>"
        'EventArg.HTMLRendered = EventArg.HTMLRendered & "<img src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/icons/check.gif'>"
        EventArg.HTMLRendered = EventArg.HTMLRendered & FrameWork.GetDictionary("TEXT_YES")
        EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>"
      else
        EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'>" & FrameWork.GetDictionary("TEXT_NO") & "</td>"
      end if
      ContainedParameterTables_DisplayCell = TRUE

    Case else
      ContainedParameterTables_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
  End Select

END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : mcmTriggerUpdateOfPONavigationPane
' PARAMETERS		  :
' DESCRIPTION 		: Quick short hand function for when a page needs to indicate that the navigation pane should be refreshed.
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION mcmTriggerUpdateOfPONavigationPane
  mdm_GetDictionary().Add "TRIGGER_UPDATE_OF_PO_NAVIGATION_PANE", "TRUE"
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : mcmTriggerUpdateOfPricelistNavigationPane
' PARAMETERS		  :
' DESCRIPTION 		: Quick short hand function for when a page needs to indicate that the navigation pane should be refreshed.
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION mcmTriggerUpdateOfPricelistNavigationPane
  mdm_GetDictionary().Add "TRIGGER_UPDATE_OF_PRICELIST_NAVIGATION_PANE", "TRUE"
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : 
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : 
PRIVATE FUNCTION mcmPriceableItemHasCustomOverviewScreen(sPriceableItemName)
  mcmPriceableItemHasCustomOverviewScreen = false
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : 
' PARAMETERS		  :
' DESCRIPTION 		: 
' RETURNS		      : 
PRIVATE FUNCTION mcmDrawTabsForPriceableItem(sPriceableItemName,iPriceableItemKind,iSelectedTab)
    
    dim sTabs
    
    dim sTypeLinkName
    Select Case iPriceableItemKind 
    Case PI_TYPE_USAGE, PI_TYPE_USAGE_AGGREGATE 
      sTypeLinkName = "USAGE"
    Case PI_TYPE_RECURRING
      sTypeLinkName = "RECURRING"
    Case PI_TYPE_NON_RECURRING
      sTypeLinkName = "NONRECURRING"
    Case PI_TYPE_DISCOUNT
      sTypeLinkName = "DISCOUNT"
    End Select
    
    ' Dynamically Add Tabs to template
    if mcmPriceableItemHasCustomOverviewScreen(sPriceableItemName) then
      gObjMTTabs.AddTab Framework.GetDictionary("TEXT_OVERVIEW_TAB"), "/mcm/default/dialog/PriceAbleItem.Usage.ViewEdit.Overview.asp?ID=" & FORM("ID") & "&POID=" & FORM("POID") & "&POBased=" & FORM("POBased") & "&Tab=0"
    else
      iSelectedTab = iSelectedTab - 1
    end if
    
    gObjMTTabs.AddTab Framework.GetDictionary("TEXT_GENERAL_TAB"), Framework.GetDictionary("PRICEABLE_ITEM_" & sTypeLinkName & "_VIEW_EDIT_DIALOG") & "?ID=" & FORM("ID") & "&POID=" & FORM("POID") & "&POBased=" & FORM("POBased") & "&Tab=1"
    gObjMTTabs.AddTab Framework.GetDictionary("TEXT_PARAMEETR_TABL_MAPPINGS_TAB"), Framework.GetDictionary("PRICEABLE_ITEM_PARAMTABLE_MAPPINGS_VIEW_EDIT_DIALOG") & "?ID=" & FORM("ID") & "&POID=" & FORM("POID") & "&POBased=" & FORM("POBased") & "&Tab=2"
    'FEAT-4216  Switch/Remove Legacy Discount and Aggregate Rating In Favor Of CDE
    'if iPriceableItemKind=40 then
    '  gObjMTTabs.AddTab Framework.GetDictionary("TEXT_COUNTERS_TAB"), Framework.GetDictionary("PRICEABLE_ITEM_DISCOUNT_COUNTERS_VIEW_EDIT_DIALOG") & "?ID=" & FORM("ID") & "&POID=" & FORM("POID") & "&POBased=" & FORM("POBased") & "&Tab=2"
    'end if    
    gObjMTTabs.Tab = iSelectedTab
    
    sTabs                 = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
    Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", sTabs)
 
END FUNCTION


PRIVATE FUNCTION mcm_GetRateSchedulesForPricelistAsRowsetWithSummaryInformation(objParamTabDef,idPL,idPI,idPT,sReturnedSummaryCaptionName,outShowSummaryAsFormattedCurrency)

      dim rowset
      set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  	  rowset.Init "queries\ProductCatalog"
      
  	  rowset.SetQueryTag("__FIND_RATE_SCHEDULES_FOR_PARAM_TBL_PL_WITH_SUMMARY_INFORMATION__")
      
      rowset.AddParam "%%PRICELIST%%", CLng(idPL)
		  rowset.AddParam "%%PT%%", CLng(idPT)
		  rowset.AddParam "%%PI_TEMPLATE%%", CLng(idPI)
		  rowset.AddParam "%%ID_LANG%%", 840

      dim sSummaryProperty, sSummaryJoin
      
      'Call the custom function for retrieving summary information for particular parameter tables (located in CustomCode.asp)
      mcm_GetCustomRateScheduleSummaryInformationForQuery objParamTabDef, sSummaryProperty, sSummaryJoin, sReturnedSummaryCaptionName, outShowSummaryAsFormattedCurrency

	  if len(sSummaryProperty)=0 then
	    sSummaryProperty = "0" 'Just a dummy value that won't be used/displayed
	  end if
	        
		  rowset.AddParam "%%SUMMARY_PROPERTY%%", sSummaryProperty, true
		  rowset.AddParam "%%SUMMARY_JOIN%%", sSummaryJoin, true
      
      rowset.Execute
      
      set mcm_GetRateSchedulesForPricelistAsRowsetWithSummaryInformation = rowset

END FUNCTION

PRIVATE FUNCTION mcm_GetRateSchedulesForPricelistMappingAsRowsetWithSummaryInformation(objPricelistMapping,sReturnedSummaryCaptionName,outShowSummaryAsFormattedCurrency)

	  dim rowset
      set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  	  rowset.Init "queries\ProductCatalog"
  	  rowset.SetQueryTag("__FIND_RATE_SCHEDULES_FOR_PL_MAPPING_WITH_SUMMARY_INFORMATION__")
      
      rowset.AddParam "%%PRICELIST%%", objPricelistMapping.PriceListID
		  rowset.AddParam "%%PT%%", objPricelistMapping.ParamTableDefinitionID
		  rowset.AddParam "%%PI_INSTANCE%%", objPricelistMapping.PriceableItemID
		  rowset.AddParam "%%ID_LANG%%", 840

   	  dim sSummaryProperty, sSummaryJoin
      
      'Call the custom function for retrieving summary information for particular parameter tables (located in CustomCode.asp)
	  mcm_GetCustomRateScheduleSummaryInformationForQuery objPricelistMapping.GetParameterTable, sSummaryProperty, sSummaryJoin, sReturnedSummaryCaptionName, outShowSummaryAsFormattedCurrency
      
	  if len(sSummaryProperty)=0 then
	    sSummaryProperty = "0" 'Just a dummy value that won't be used/displayed
	  end if
	  
	  rowset.AddParam "%%SUMMARY_PROPERTY%%", sSummaryProperty, true
	  rowset.AddParam "%%SUMMARY_JOIN%%", sSummaryJoin, true
      
      rowset.Execute
      
      set mcm_GetRateSchedulesForPricelistMappingAsRowsetWithSummaryInformation = rowset

END FUNCTION

'mcm_GetCustomRateScheduleSummaryInformationForQuery
'When displaying a list of rate schedules, this function returns the data necessary for displaying summary information for the particular rate schedule
'By default, a count of the number of rules is returned
'When customizing for your particular parameter table, remember to set/return:
'  outQuerySummaryProperty: the property name or calculated value to use for the summary value
'  outQuerySummaryJoin: the SQL for any joins neccessary; can be set to ""; refer to the %%SUMMARY_JOIN%% param of the __FIND_RATE_SCHEDULES_FOR_PL_MAPPING_WITH_SUMMARY_INFORMATION__ or the __FIND_RATE_SCHEDULES_FOR_PARAM_TBL_PL_WITH_SUMMARY_INFORMATION__ queries
'  outReturnedSummaryCaptionName: display name for the summary value column header; if this is returned as "" then no summary column will be displayed for this type of parameter table
'  outShowSummaryAsFormattedCurrency: boolean value that indicates if the returned value should be formatted as a currency value for the appropriate currency
'Please refer to mcm_GetRateSchedulesForPricelistAsRowsetWithSummaryInformation and mcm_GetRateSchedulesForPricelistMappingAsRowsetWithSummaryInformation for more information about how these values are used
PRIVATE FUNCTION mcm_GetCustomRateScheduleSummaryInformationForQuery(objParameterTable,outQuerySummaryProperty, outQuerySummaryJoin, outReturnedSummaryCaptionName, outShowSummaryAsFormattedCurrency)
  'This function can/should be overwridden with a custom version located in CustomCode.asp
  'This default implementation returns no summary informations   
  outQuerySummaryProperty = ""
  outQuerySummaryJoin = ""
  outReturnedSummaryCaptionName = ""
  outShowSummaryAsFormattedCurrency = false
END FUNCTION

PRIVATE FUNCTION mcm_FormatLocalizedCurrency(amount, sCurrencyCode)
  dim myDataAccessor
  dim localeTranslator
  
  ' create the data accessor com object
  set myDataAccessor = CreateObject("COMDataAccessor.COMDataAccessor.1")
  
  ' put the language code
  myDataAccessor.languageCode = "US"
   
  ' get the locale translator object
  set localeTranslator = myDataAccessor.GetLocaleTranslator
  
  if isNull(amount) then
    mcm_FormatLocalizedCurrency = ""
    exit function
  end if
  
  if len(cstr(amount))=0 then
    mcm_FormatLocalizedCurrency = ""
    exit function
  end if
  
  mcm_FormatLocalizedCurrency = localeTranslator.getCurrency (amount, sCurrencyCode) '"[" & sCurrencyCode & "]" & amount
  
END FUNCTION

PRIVATE FUNCTION mcm_DefaultFilterValueHandler(sValue)
  if Cstr(sValue)="" then
    mcm_DefaultFilterValueHandler = sValue
    exit function
  end if

  'ADO filter does not support a single wildcard... a single wildcard character * is the same as no filter criteria
  if Cstr(sValue)="*" then
    mcm_DefaultFilterValueHandler = ""
    exit function
  end if
    
  'If value has any wildcards, don't imply any... otherwise add an implied wildcard at the end
  if InStr(sValue,"*")=0 then
    mcm_DefaultFilterValueHandler = sValue & "*"
  else
    mcm_DefaultFilterValueHandler = sValue
  end if
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		:
' PARAMETERS	:
' DESCRIPTION :
' RETURNS			:
PUBLIC FUNCTION mcm_GetDictionary(strName) ' As String
	  mcm_GetDictionary = Session("mdm_LOCALIZATION_DICTIONARY").item(strName).value
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: mcm_FormatDate(strValue) 
' PARAMETERS	: Format the date.
' DESCRIPTION :
' RETURNS			:
Public Function mcm_FormatDate(varValue, varFormat)
  if len(varFormat) = 0 then
    mcm_FormatDate = FrameWork.MSIXTools.Format(varValue, mcm_GetDictionary("DATE_FORMAT"))
  else
    mcm_FormatDate = FrameWork.MSIXTools.Format(varValue, varFormat)
  end if
End Function
%>
