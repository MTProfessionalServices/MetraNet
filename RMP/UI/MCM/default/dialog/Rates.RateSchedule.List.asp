 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: Rates.RateSchedule.List.asp
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
'  Created by: Fabricio Pettena
' 
'  $Date$
'  $Author$
'  $Revision$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : Rates.RateSchedule.List.asp
' DESCRIPTION : Displays rate schedules associated with parameter table.
' NOTE		  : File overrides MDM functions. Do not reuse unless you know what you are doing.
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../lib/TabsClass.asp" -->
<!-- #INCLUDE FILE="../lib/ScriptIncludes.html" -->
<!--METADATA TYPE="TypeLib" NAME="PCCONFIGLib" UUID="{A4175A41-AF24-4F1E-B408-00CF83690549}" VERSION="1.0" -->
<%
dim bShowSummaryAsFormattedCurrency
    
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler   = TRUE
mdm_PVBrowserMain ' invoke the mdm framework

' This function uses the dictionary to find out if there is a special screen to be used with a specific parameter table
FUNCTION getParamTablePage(pt_id)

	Dim objProdcat, objParamTableDef, destiny_url
	Set objProdcat = GetProductCatalogObject
	Set objParamTableDef = objProdcat.GetParamTableDefinition(pt_id)
	
	' We retrieve the parameter table name and check whether there is a special screen for it in the dictionary
	'destiny_url = FrameWork.GetDictionary(objParamTableDef.Name)
  destiny_url = ""
	' It the result is blank, we will go to the default MPTE url
	if destiny_url = "" then
		getParamTablePage = FrameWork.GetDictionary("MPTE_DEFAULT_SCREEN")
	else
		getParamTablePage = destiny_url
	end if
END FUNCTION

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    
	' Save our querystring in the form, so the refresh works
	Form("POBased") = Request.QueryString("POBased")
	Form("ID")      = CLng(Request.QueryString("ID"))
	Form("PI_ID")   = CLng(Request.QueryString("PI_ID"))
	Form("PT_ID")   = CLng(Request.QueryString("PT_ID"))
	Form("PL_ID")  =   CLng(Request.QueryString("PL_ID"))
  
  if FrameWork.GetDictionary("SHOW_SUMMARY_INFORMATION_WHEN_LISTING_RATE_SCHEDULES") = "TRUE" Then
    Form("ShowSummaryInformation") = true
  else
    Form("ShowSummaryInformation") = false  
  end if
  
  If UCase(Form("POBased")) = "TRUE" Then
    ' Let's save the paramtable id that was selected in the screen before, in case we go to the wizard
  	session("RATES_PARAMTABLE_ID") = Request.QueryString("PT_ID")
  	gObjMTTabs.Tab = 0    
    'Form.HelpFile   = "PO.Rates.RateSchedule.List.hlp.htm"
	Else
    ' Let's save the price list and paramtable id that was selected in the screen before, in case we go to the wizard
    session("RATES_PRICELIST_ID") = Request.QueryString("PL_ID")
    session("RATES_PARAMTABLE_ID") = Request.QueryString("PT_ID")
    gObjMTTabs.Tab = 1
    'Form.HelpFile   = "Rates.RateSchedule.List.hlp.htm"
	end If
		
	' Let's save the ids in the session in case we go to the wizard
	' I wish there was a better way to do this
	session("RATES_PRICEABLEITEM_ID") = Request.QueryString("PI_ID")
	session("RATES_POBASED") = Request.QueryString("POBased")
		
	' Dynamically Add Tabs to template
  If UCase(Form("POBased")) = "FALSE" Then
  '//New Navigation-If we are coming from Product Offering screens, don't show the tabs
    dim strTabs
  	gObjMTTabs.AddTab "Pricelists", "[RATES_ALLPRICELISTS_LIST_DIALOG]"
  	gObjMTTabs.AddTab "Pricelists for a particular Priceable Item", "[RATES_PRICE_LIST_LIST_DIALOG]"
    
  	strTabs = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
  	Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)
  End If
	'  we are going to store this page's call in the session, so the ruleeditor knows 
	' where to come back to when the user clicks on Cancel or Close.
	session("ownerapp_return_page") = FrameWork.GetDictionary("RATES_RATESCHEDULE_LIST_DIALOG") & "?" & Request.QueryString()
	

  Form.Page.NoRecordUserMessage     = FrameWork.GetDictionary("TEXT_NO_RATE_SCHEDULES")
  
	Form_Initialize = MDMListDialog.Initialize(EventArg)
	Form.Grid.FilterMode          = FALSE ' We don't want filter capability on this product view
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog, objPriceableItem, objPricelistMap, objProdOff, objParamTabDef

  Form_LoadProductView = FALSE
  
  Set objMTProductCatalog = GetProductCatalogObject
  ' First get back the priceable item, for both cases
  Set objPriceableItem = objMTProductCatalog.GetPriceableItem(Form("PI_ID"))
	
  dim sPricelistInformation
  dim sSummaryCaption
  dim sPricelistCurrency 'Used to format currency of summary
  Form("isEditable") = True
  
	' Now branch on POBased = TRUE|FALSE
  If UCase(Form("POBased")) = "TRUE" Then
  	' We are editing rates on the context of a product offering. 
		' The rates are only for that priceable item instance.
  	Set objPricelistMap = objPriceableItem.GetPricelistMapping(Form("PT_ID"))
    
    if Form("ShowSummaryInformation") then
      Set ProductView.Properties.RowSet = mcm_GetRateSchedulesForPricelistMappingAsRowsetWithSummaryInformation(objPricelistMap, sSummaryCaption, bShowSummaryAsFormattedCurrency)
	  if len(sSummaryCaption)=0 then
        Form("ShowSummaryInformation") = false  
      end if
    else
	  Set ProductView.Properties.RowSet = objPricelistMap.FindRateSchedulesAsRowset
    end if
        
		Set COMObject.Instance  = objMTProductCatalog.GetParamTableDefinition(Form("PT_ID"))
    
    ' Now we need the price list name for display purposes
    dim objPricelist
    set objPricelist = objPricelistMap.GetPricelist()

    If Session("isPartitionUser") Then 
      Form("isEditable") = Session("topLevelAccountId") = objPricelist.PLPartitionId
    End If

    sPricelistCurrency = objPriceList.CurrencyCode
    dim objParameterTable
    set objParameterTable = objPricelistMap.GetParameterTable()

    dim sParamTableName
    if len(objParameterTable.DisplayName)=0 then
      sParamTableName = objParameterTable.Name
    else
      sParamTableName = objParameterTable.DisplayName
    end if
   
    if not objPricelist.GetOwnerProductOffering() is nothing then
      sPricelistInformation = FrameWork.GetDictionary("TEXT_PARAMETER_TABLE") & sParamTableName & FrameWork.GetDictionary("TEXT_RATES_STORED_ON_PO")
    else
      'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
      'Adding HTML Encoding
      'sPricelistInformation = "Parameter Table: <b>" & sParamTableName & "</b><br>Rates are stored on the shared price list '<b>" & objPricelist.Name & "</b>'.<br>"  
      sPricelistInformation = FrameWork.GetDictionary("TEXT_PARAMETER_TABLE") & sParamTableName & FrameWork.GetDictionary("TEXT_RATES_STORED_ON_SHARED_PL") & SafeForHtml(objPricelist.Name) & "</b>'.<br>"
    end if    
  Else
   	' We are editing rates on the context of a price list
		' These rates are for the priceable item template!!!
		Set objParamTabDef = objMTProductCatalog.GetParamTableDefinition(Form("PT_ID"))
    if Form("ShowSummaryInformation") then
      Set ProductView.Properties.RowSet = mcm_GetRateSchedulesForPricelistAsRowsetWithSummaryInformation(objParamTabDef,Form("PL_ID"),Form("PI_ID"),Form("PT_ID"), sSummaryCaption, bShowSummaryAsFormattedCurrency)
    else
		  Set ProductView.Properties.RowSet = objParamTabDef.GetRateSchedulesByPriceListAsRowset(Form("PL_ID"), Form("PI_ID"))
    end if
		Set COMObject.Instance  = objMTProductCatalog.GetPriceList(Form("PL_ID"))
    sPricelistCurrency = COMObject.Instance.CurrencyCode
    
    if len(objParamTabDef.DisplayName)=0 then
      sParamTableName = objParamTabDef.Name
    else
      sParamTableName = objParamTabDef.DisplayName
    end if
    
    sPricelistInformation = FrameWork.GetDictionary("TEXT_PARAMETER_TABLE") & sParamTableName & "</b><br>" 
  End If

  Dim strButton
  strButton = "<br><br>"
  If Form("isEditable") Then 
    strButton = "<button class=""clsButtonLarge"" name=""butNewRateSchedule"" onClick=""javascript:OpenDialogWindow('[NEW_RATESCHEDULE_WIZARD]', 'height=400,width=600,resizable=yes,scrollbars=yes'); return false;"">"
    strButton = strButton & "<MDMLABEL Name='TEXT_RATES_NEW_RATE'></MDMLABEL></button>"
  End If
  Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<DYNAMIC_BUTTON_TEMPLATE />", strButton)    

  ProductView.Properties.ClearSelection
  'ProductView.Properties.SelectAll
  dim i
  i = 1
	ProductView.Properties("dt_start").Selected 	    = i  : i=i+1
  ProductView.Properties("dt_end").Selected 	      = i  : i=i+1

  
  ProductView.Properties("n_desc").Selected 			  = i  : i=i+1

  if Form("ShowSummaryInformation") then
    ProductView.Properties("Summary").Selected   = i  : i=i+1
    ProductView.Properties("Summary").Caption = sSummaryCaption
  end if

  ProductView.Properties("n_begintype").Selected 		= i  : i=i+1 ' We are using this column as a dummy column to display the button
  
  ProductView.Properties("n_desc").Caption				  = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
  ProductView.Properties("dt_start").Caption			  = FrameWork.GetDictionary("TEXT_RATES_COLUMN_START_DATE")
  ProductView.Properties("dt_end").Caption				  = FrameWork.GetDictionary("TEXT_RATES_COLUMN_END_DATE")
  ProductView.Properties("n_begintype").Caption			= FrameWork.GetDictionary("TEXT_RATES_COLUMN_OPTIONS")
  
  ProductView.Properties("dt_start").Sorted         = MTSORT_ORDER_DECENDING

  Service.Properties.Add "PricelistInformation", "String",  0, FALSE, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("PricelistInformation").value = sPricelistInformation

  Service.Properties.Add "PricelistCurrency", "String",  10, FALSE, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("PricelistCurrency").value = sPricelistCurrency

  Service.Properties.Add "PT_ID", "String",  0, FALSE, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("PT_ID").value = Form("PT_ID")

  'CORE-5190: JS error in MetraOffer
  'Fixed selected item ID format
  Service.Properties.Add "PI_ID", "String",  0, FALSE, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties("PI_ID").value = Form("PI_ID")

  'mdm_GetDictionary.Add "RATES_IS_USAGE" , false

  ' Create message indicating effected subscribers
  Service.Properties.Add "PT_ID", "int32",  256, FALSE, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "PI_ID", "int32",  256, FALSE, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "PL_ID", "int32",  256, FALSE, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "DependencyCountMessage", "String",  0, FALSE, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
    
  Service.Properties("PT_ID").value = Form("PT_ID")
  Service.Properties("PI_ID").value = Form("PI_ID")

  If UCase(Form("POBased")) = "TRUE" Then
    Service.Properties("PL_ID").value = objPricelistMap.PriceListId
  Else
    Service.Properties("PL_ID").value = Form("PL_ID")
  End If
  
    If UCase(FrameWork.GetDictionary("APPSETTING_DISPLAY_RATE_SCHEDULE_DEPENDENCY_COUNTS"))="TRUE" then
  	  FrameWork.Dictionary().Add "DisplayDependencyCounts",TRUE
      FrameWork.Dictionary().Add "DisplayDependencyLinkOnly",FALSE
      Service.Properties("DependencyCountMessage").value= getNumberOfDependentSubscribers( Form("PT_ID"), Service.Properties("PL_ID").value )
    Else
  	  FrameWork.Dictionary().Add "DisplayDependencyLinkOnly",TRUE
      FrameWork.Dictionary().Add "DisplayDependencyCounts",FALSE
      
      Service.Properties("DependencyCountMessage").value= ""
    End If 
  
  Form_LoadProductView = TRUE ' Must Return TRUE To Render The Dialog
	
END FUNCTION

function getNumberOfDependentSubscribers(idParamTable, idPricelist)
    
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  	rowset.Init "queries\productcatalog"
    rowset.SetQueryTag("__GET_DEPENDENT_SUBSCRIBERS_COUNT_FOR_PRICELIST_AND_PARAMTABLE__")  
    rowset.AddParam "%%ID_PARAMTABLE%%", CLng(idParamTable)
    rowset.AddParam "%%ID_PRICELIST%%", CLng(idPriceList)
  	rowset.Execute
    
    getNumberOfDependentSubscribers = rowset.value("NumberDependentSubscribers")
    
end function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: ViewEditMode_DisplayCell
' PARAMETERS	:
' DESCRIPTION :   We will override the MDM function that takes care of this,
' 				in orther to have better nnavigation control
' RETURNS		  : Return TRUE if ok else FALSE
PUBLIC FUNCTION ViewEditMode_DisplayCell(EventArg) ' As Boolean

	Dim HTML_LINK_EDIT, objProdCat, b_delete
	
	' Check if this system allows deletion of rate schedules and price lists by checking a business rule
	' Then check if the user has the necessary capability to do so
	' Then use this information when deciding to hide the Delete button or not. Only check cap if system allows deletion in the first place.
	Set objProdCat = GetProductCatalogObject
	b_delete = objProdCat.IsBusinessRuleEnabled(PCCONFIGLib.MTPC_BUSINESS_RULE_Rates_DeleteOverride) 
	if (b_delete) then
		b_delete = FrameWork.CheckCoarseCapability("Delete Rates")
	end if
	   	
	'We are drawing column based on their positions on the Rowset.
	'Ideally this should be based on column names, but we need to display
	'the view and edit gifs, so we can't do that.
  Select Case Form.Grid.Col
    
  Case 1
  	HTML_LINK_EDIT = HTML_LINK_EDIT & "<td class='[CLASS]' width='40'>"     
        
    If Form("isEditable") Then
      HTML_LINK_EDIT = HTML_LINK_EDIT & "<A HREF='[ASP_PAGE]?Reload=TRUE&EditMode=True&Rates=TRUE&Manage=False&ID=[ID]&PI_ID=[PI_ID]&PT_ID=[PT_ID]&RS_ID=[RS_ID]&POBased=[POBASED]'><img Alt='[ALT_EDIT]' Name='[IMAGE_EDIT_NAME]'  src='[IMAGE_EDIT]' Border='0'></A>&nbsp;"
    End If

    HTML_LINK_EDIT = HTML_LINK_EDIT & "<A HREF='[ASP_PAGE]?Reload=TRUE&EditMode=False&Rates=TRUE&Manage=False&ID=[ID]&PI_ID=[PI_ID]&PT_ID=[PT_ID]&RS_ID=[RS_ID]&POBased=[POBASED]'><img Alt='[ALT_VIEW]' src='[IMAGE_VIEW]' Border='0'></A>"
		HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
			
		MDMListDialog.PreProcessor.Clear
		MDMListDialog.PreProcessor.Add "CLASS"       , Form.Grid.CellClass        
		MDMListDialog.PreProcessor.Add "ASP_PAGE"    , getParamTablePage(Clng(Form("PT_ID")))
		MDMListDialog.PreProcessor.Add "IMAGE_VIEW"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/icons/view.gif"
		MDMListDialog.PreProcessor.Add "ALT_VIEW"    , mdm_GetDictionary().Item("TEXT_VIEW").Value

    If Form("isEditable") Then
      MDMListDialog.PreProcessor.Add "IMAGE_EDIT"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif"
      MDMListDialog.PreProcessor.Add "IMAGE_EDIT_NAME" , "EditIcon" & Form.Grid.Row ' For FredRunner
      MDMListDialog.PreProcessor.Add "ALT_EDIT"    , mdm_GetDictionary().Item("TEXT_EDIT").Value
    End If

		MDMListDialog.PreProcessor.Add "ID"	    	   , ProductView.Properties.Rowset.Value("id_sched")
		MDMListDialog.PreProcessor.Add "PT_ID"    	 , Form("PT_ID")
		MDMListDialog.PreProcessor.Add "PI_ID"    	 , Form("PI_ID")
		MDMListDialog.PreProcessor.Add "RS_ID"    	 , ProductView.Properties.Rowset.Value("id_sched")
		MDMListDialog.PreProcessor.Add "POBASED"     , Form("POBased")
		
		EventArg.HTMLRendered           = MDMListDialog.PreProcess(HTML_LINK_EDIT)
		ViewEditMode_DisplayCell        = TRUE
			
  Case 2
    mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown

  Case 3 ' This is the "STARTS" field
    HTML_LINK_EDIT = HTML_LINK_EDIT & "<td nowrap class='[CLASS]'>"
    HTML_LINK_EDIT = HTML_LINK_EDIT & GetEffectiveDateTextByType(ProductView.Properties.Rowset.Value("n_begintype"), ProductView.Properties.Rowset.Value("dt_start"), ProductView.Properties.Rowset.Value("n_beginoffset"), TRUE)
    HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
		
    MDMListDialog.PreProcessor.Clear
    MDMListDialog.PreProcessor.Add "CLASS", Form.Grid.CellClass	
    EventArg.HTMLRendered = MDMListDialog.PreProcess(HTML_LINK_EDIT)
			
  Case 4 ' This is the "ENDS" field			
    HTML_LINK_EDIT = HTML_LINK_EDIT & "<td nowrap class='[CLASS]'>"
    HTML_LINK_EDIT = HTML_LINK_EDIT & GetEffectiveDateTextByType(ProductView.Properties.Rowset.Value("n_endtype"), ProductView.Properties.Rowset.Value("dt_end"), ProductView.Properties.Rowset.Value("n_endoffset"), FALSE)
    HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
    		
    MDMListDialog.PreProcessor.Clear
    MDMListDialog.PreProcessor.Add "CLASS", Form.Grid.CellClass
    EventArg.HTMLRendered           = MDMListDialog.PreProcess(HTML_LINK_EDIT)

	Case 5
		'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
		'Adding HTML Encoding
		'EventArg.HTMLRendered = "<td class='" & Form.Grid.CellClass & "'>" & ProductView.Properties.Rowset.Value("nm_desc") & "</td>"
		EventArg.HTMLRendered = "<td class='" & Form.Grid.CellClass & "'>" & SafeForHtml(ProductView.Properties.Rowset.Value("nm_desc")) & "</td>"
    

 	Case 6,7 ' This is the column that will display a button, regardless of its contents
    If Form.Grid.Col=6 AND Form("ShowSummaryInformation") then
      if bShowSummaryAsFormattedCurrency then 
 		    EventArg.HTMLRendered = "<td nowrap class='" & Form.Grid.CellClass & "' style='text-align:right;'>" & mcm_FormatLocalizedCurrency(ProductView.Properties.Rowset.Value("Summary"),Service.Properties("PricelistCurrency")) & "</td>"
      else
 		    EventArg.HTMLRendered = "<td nowrap class='" & Form.Grid.CellClass & "' style='text-align:left;'>" & ProductView.Properties.Rowset.Value("Summary") & "</td>"
      end if        
    Else
  		HTML_LINK_EDIT = HTML_LINK_EDIT & "<td nowrap class='[CLASS]' align='center'>"

      If Form("isEditable") Then
  		  HTML_LINK_EDIT = HTML_LINK_EDIT & "<button id='copy[RS_ID]' class='clsButtonXLarge' onclick=""OpenDialogWindow('[NEW_RATESCHEDULE_WIZARD]&CopyRateScheduleId=[RS_ID]', 'height=400,width=600,resizable=yes,scrollbars=yes'); return false;"" title=""[CREATE_RATE_SCHEDULE_TITLE]""><span style='font-size:8pt;'>[CREATE_RATE_SCHEDULE]</span></button>"
 			  HTML_LINK_EDIT = HTML_LINK_EDIT & "&nbsp;&nbsp;"
        HTML_LINK_EDIT = HTML_LINK_EDIT & "<button id='properties[RS_ID]' class='clsButtonBlueLarge' onclick=""OpenDialogWindow('[PROPERTIES_POPUP]?MDMReload=TRUE&EditMode=TRUE&Reload=TRUE&refresh=TRUE&PT_ID=[PT_ID]&RS_ID=[RS_ID]','_blank', 'height=100,width=100,resizable=yes,scrollbars=yes'); return false;"">[PROPERTIES_BUTTON]</button>"
        HTML_LINK_EDIT = HTML_LINK_EDIT & "&nbsp;&nbsp;"
        ' Use the stored business rule and capability checks to decide whether to display the delete button or not
        If b_delete Then
          HTML_LINK_EDIT = HTML_LINK_EDIT & "<button id='delete[RS_ID]' class='clsButtonBlueMedium' onclick=""OpenDialogWindow('[DELETE_POPUP]?MDMReload=TRUE&EditMode=TRUE&Reload=TRUE&refresh=TRUE&PT_ID=[PT_ID]&RS_ID=[RS_ID]','_blank', 'height=100,width=100,resizable=yes,scrollbars=yes'); return false;"">[DELETE_BUTTON]</button>"
          HTML_LINK_EDIT = HTML_LINK_EDIT & "&nbsp;&nbsp;"
        End If
      End If
  		      
  		HTML_LINK_EDIT = HTML_LINK_EDIT & "<button id='viewhistory[RS_ID]' class='clsButtonBlueMedium' onclick=""window.open('Rates.RateSchedule.ViewHistory.asp?MDMReload=TRUE&EditMode=TRUE&Reload=TRUE&refresh=TRUE&PT_ID=[PT_ID]&RS_ID=[RS_ID]&PL_ID=[PL_ID]','_blank', 'height=600,width=800,resizable=yes,scrollbars=yes'); return false;"">[VIEW_HISTORY_BUTTON]</button>"
  
  		MDMListDialog.PreProcessor.Clear
  		MDMListDialog.PreProcessor.Add "CLASS"       , Form.Grid.CellClass        
  		MDMListDialog.PreProcessor.Add "PROPERTIES_POPUP"    , FrameWork.GetDictionary("RATES_RATESCHEDULE_PROPERTIES_DIALOG")
  		MDMListDialog.PreProcessor.Add "DELETE_POPUP"    , FrameWork.GetDictionary("RATESCHEDULE_DELETE_DIALOG")
  		MDMListDialog.PreProcessor.Add "PROPERTIES_BUTTON"   , FrameWork.GetDictionary("TEXT_RATESCHEDULE_EDIT_PROPERTIES")
  		MDMListDialog.PreProcessor.Add "DELETE_BUTTON"   , FrameWork.GetDictionary("TEXT_DELETE")
      MDMListDialog.PreProcessor.Add "VIEW_HISTORY_BUTTON"   , FrameWork.GetDictionary("TEXT_VIEW_HISTORY")
      MDMListDialog.PreProcessor.Add "PT_ID"    	 , Form("PT_ID")
  		MDMListDialog.PreProcessor.Add "RS_ID"    	 , ProductView.Properties.Rowset.Value("id_sched")
  		MDMListDialog.PreProcessor.Add "PL_ID"    	 , Service.Properties("PL_ID").value
      MDMListDialog.PreProcessor.Add "CREATE_RATE_SCHEDULE_TITLE"   , FrameWork.GetDictionary("TEXT_CREATE_RATE_SCHEDULE_TITLE")
      MDMListDialog.PreProcessor.Add "CREATE_RATE_SCHEDULE"   , FrameWork.GetDictionary("TEXT_CREATE_RATE_SCHEDULE")
      
      
  		EventArg.HTMLRendered = MDMListDialog.PreProcess(HTML_LINK_EDIT)
		End If
    
	Case Else
    ViewEditMode_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation           
		   
  End Select
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION CreateDefaultRateSchedule_Click(EventArg) ' As Boolean
    'On Error Resume Next
    'response.end
    
Dim objProdCat		     ' As MTProductCatalog
Dim objProdOff		     ' As MTProductOffering
Dim objPriceableItem     ' As MTPriceableItem
Dim objPricelist         ' As MTPriceList
Dim objParamTable		 ' As MTParamTableDefinition
Dim objPricelistMapping  ' As MTPricelistMapping
Dim objNewRateSchedule   ' As MTRateSchedule

    Dim pi_id, pt_id, pl_id ' Temp vars to make the code more readable

On Error Resume Next

Set objProdCat = GetProductCatalogObject

'Let's temporarily retrieve the IDs from the session
'pi_id = Form("PI_ID")
'pt_id = Clng(session("RATES_PARAMTABLE_ID"))
'pl_id = Clng(session("RATES_PRICELIST_ID"))

'We need this object anyway to look up the Editing Screen for this particular parameter table

'response.write("POBased[" & Form("POBased") & "]<BR>")
'response.write("PI_ID[" & Form("PI_ID") & "]<BR>")
'response.write("PT_ID[" & Form("PT_ID") & "]<BR>")
'response.write("PL_ID[" & Form("PL_ID") & "]<BR>")
'response.end

if UCase(Form("POBased")) = "TRUE" then
	Set objPriceableItem = objProdCat.GetPriceableItem(Form("PI_ID"))
	Set objPricelistMapping = objPriceableItem.GetPriceListMapping(Form("PT_ID"))
	Set objNewRateSchedule = objPricelistMapping.CreateRateSchedule()
else
  Set objParamTable = objProdCat.GetParamTableDefinition(Form("PT_ID"))
	Set objNewRateSchedule = objParamTable.CreateRateSchedule(Form("PL_ID"), Form("PI_ID"))
end if

    objNewRateSchedule.Description = "Default Rate Schedule"

		objNewRateSchedule.EffectiveDate.StartDateType = PCDATE_TYPE_NULL
		objNewRateSchedule.EffectiveDate.SetStartDateNull()
    
		objNewRateSchedule.EffectiveDate.EndDateType = PCDATE_TYPE_NULL
		objNewRateSchedule.EffectiveDate.SetEndDateNull()

    objNewRateSchedule.Save

if (Err.Number) then
Response.write ("Error")
Response.end
  'session(strWizardName & "__ErrorMessage") = Err.Description
  'response.redirect("Wizard.asp?Path=/mcm/default/dialog/wizard/CreateRateSchedule&PageID=description&Error=Y")    
End If

		CreateDefaultRateSchedule_Click = TRUE

END FUNCTION
%>
