 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
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
'  $Date$
'  $Author$
'  $Revision$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : DefaultDialogAddNameSpace.asp
' DESCRIPTION : Note that this dialog hit the SQL Server directly through MTSQLRowset Object and some query file.
'               We do not use MT Service or MT Product View. The Rowset is viewed as a product view.
'
'
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../lib/TabsClass.asp" -->
<!-- #INCLUDE FILE="../lib/ScriptIncludes.html" -->
<!--METADATA TYPE="TypeLib" NAME="PCCONFIGLib" UUID="{A4175A41-AF24-4F1E-B408-00CF83690549}" VERSION="1.0" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE
mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	  Form("PT_ID") = Request.QueryString("ID")
	  Form("PI_ID") = Request.QueryString("PI_ID")
	  Form("POBased") = Request.QueryString("POBased")
  
 	  Form_Initialize = MDMListDialog.Initialize(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :  EventArg
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog, objParamTableDef  

  Form_LoadProductView = FALSE
  
  Set objMTProductCatalog = GetProductCatalogObject
  
  'Create a filter so we display only non-ICB price lists
  Dim objMTFilter
  Set objMTFilter = mdm_CreateObject(MTFilter)
	
  objMTFilter.Add "Type", OPERATOR_TYPE_EQUAL, PRICELIST_TYPE_REGULAR
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = objMTProductCatalog.FindPriceListsForMappingAsRowset(Clng(Form("PT_ID")), Clng(Form("PI_ID")), objMTFilter)
	
  'Set COMObject.Instance  = objMTProductCatalog.GetParamTableDefinition(Form("PT_ID"))
	Set objParamTableDef = objMTProductCatalog.GetParamTableDefinition(Form("PT_ID"))
	
  ' Dynamically Add Tabs to template
  Dim strTabs
  gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_RATES_PRODUCT_OFFERING_LIST"), "[RATES_PRODUCT_OFFERING_LIST_DIALOG]"
  gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_RATES_PRICELIST_LIST"), "[RATES_PRICE_LIST_LIST_DIALOG]"
  gObjMTTabs.Tab = 1 ' We only get to this screen if we are in the context of pricelist based rates
  strTabs = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
  Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)
  
  ' Select the properties I want to print in the Rowset Browser   Order
  ProductView.Properties.ClearSelection    
  'ProductView.Properties.SelectAll
  ProductView.Properties("nm_name").Selected 											= 1
  ProductView.Properties("nm_desc").Selected 											= 2
  ProductView.Properties("nm_currency_code").Selected 						= 3
	ProductView.Properties("n_type").Selected 											= 5 ' We will use this column to place the edit properties button
  ProductView.Properties("rateschedules").Selected								= 4
	 
  ProductView.Properties("nm_name").Sorted              = MTSORT_ORDER_DECENDING
  
	' On what should we filter on this page?
  Set Form.Grid.FilterProperty                          = ProductView.Properties("nm_name") ' Set the property on which to apply the filter  
	
	' Set the caption for each of the selected properties
  ProductView.Properties("nm_name").Caption            	= FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption         		= FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
  ProductView.Properties("nm_currency_code").Caption   	= FrameWork.GetDictionary("TEXT_COLUMN_CURRENCY_CODE")
	ProductView.Properties("n_type").Caption							= FrameWork.GetDictionary("TEXT_COLUMN_RATES_OPTIONS") ' We are using this column to display the buttons
  ProductView.Properties("rateschedules").Caption	    	= FrameWork.GetDictionary("TEXT_COLUMN_NUMBER_OF_RATES")
 	
  Form_LoadProductView                                  = TRUE ' Must Return TRUE To Render The Dialog
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: LinkColumnMode_DisplayCell
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PUBLIC FUNCTION LinkColumnMode_DisplayCell(EventArg) ' As Boolean
	Dim m_objPP, HTML_LINK_EDIT , strValue , strFormat, lngPos, strParameter, objProdCat, b_delete
	 
	' Check if this system allows deletion of rate schedules and pricelists by checking a business rule
	' Then check if the user has the necessary capability to do so
	' Then use this information when deciding to hide the Delete button or not. Only check cap if system allows deletion in the first place.
	Set objProdCat = GetProductCatalogObject
	b_delete = objProdCat.IsBusinessRuleEnabled(PCCONFIGLib.MTPC_BUSINESS_RULE_Rates_DeleteOverride) 
	if (b_delete) then
		b_delete = FrameWork.CheckCoarseCapability("Delete Rates")
	end if
	 
  Select Case Form.Grid.Col
    Case 1,2
      mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
    Case 3
      Inherited("Form_DisplayCell()")
      lngPos                = InStr(EventArg.HTMLRendered,">") ' Find the first >
      EventArg.HTMLRendered = MDMListDialog.Tools.InsertAStringAt(EventArg.HTMLRendered,"<A HREF='[URL]?ID=[ID]&PL_ID=[PL_ID]&PI_ID=[PI_ID]&PT_ID=[PT_ID]&PoBased=[POBASED]&Title=[TITLE]&LinkColumMode=True'>",lngPos+1) ' Insert after >

      EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"</td>","</a></td>")
      
      MDMListDialog.PreProcessor.Clear

      MDMListDialog.PreProcessor.Add "URL"     , FrameWork.GetDictionary("RATES_RATESCHEDULE_LIST_DIALOG")                
      MDMListDialog.PreProcessor.Add "PL_ID"   , ProductView.Properties.Rowset.Value("id_prop")
      MDMListDialog.PreProcessor.Add "ID"   	 , ProductView.Properties.Rowset.Value("id_prop")
      MDMListDialog.PreProcessor.Add "PT_ID"   , Form("PT_ID")
		MDMListDialog.PreProcessor.Add "PI_ID"   , Form("PI_ID")
      MDMListDialog.PreProcessor.Add "POBased" , Form("POBased")
			MDMListDialog.PreProcessor.Add "TITLE"   , "TEXT_CHOOSE_PRICEABLE_ITEM"      
      EventArg.HTMLRendered = MDMListDialog.PreProcess(EventArg.HTMLRendered)
	Case 6
		strValue = "<td nowrap class='" & Form.Grid.CellClass & "'>"
		if len(TRIM(ProductView.Properties.Rowset.Value("rateschedules"))) > 0 then
			strValue = strValue & ProductView.Properties.Rowset.Value("rateschedules") & "&nbsp;"
			if Clng(ProductView.Properties.Rowset.Value("rateschedules")) = 1 then
				strValue = strValue & FrameWork.GetDictionary("TEXT_KEYTERM_RATE_SCHEDULE")
			else
				strValue = strValue & FrameWork.GetDictionary("TEXT_KEYTERM_RATE_SCHEDULES")
			end if
		else
			strValue = strValue & FrameWork.GetDictionary("TEXT_HAS_NO_RATES")
		end if
		strValue = strValue & "</td>"
		EventArg.HTMLRendered = strValue				
	Case 7 ' This is the column that will display a button, regardless of its contents
		HTML_LINK_EDIT = HTML_LINK_EDIT & "<td nowrap align='center' class='[CLASS]'>"
		HTML_LINK_EDIT = HTML_LINK_EDIT & "	<button id='properties[ID]' class='clsButtonBlueLarge' onclick=""OpenDialogWindow('[PROPERTIES_POPUP]?ID=[ID]','_blank', 'height=100,width=100,resizable=yes,scrollbars=yes'); return false;"">[PROPERTIES_BUTTON]</button>"

		' Use the stored business rule and capability checks to decide whether to display the delete button or not
		if b_delete then
			HTML_LINK_EDIT = HTML_LINK_EDIT & "&nbsp;&nbsp;&nbsp;" 
			HTML_LINK_EDIT = HTML_LINK_EDIT & "<button id='delete[ID]' class='clsButtonBlueMedium' onclick=""OpenDialogWindow('[DELETE_POPUP]?ID=[ID]','_blank', 'height=100,width=100,resizable=yes,scrollbars=yes'); return false;"">[DELETE_BUTTON]</button>"
		end if
		
		HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
		
		MDMListDialog.PreProcessor.Clear
		MDMListDialog.PreProcessor.Add "CLASS"       , Form.Grid.CellClass        
		MDMListDialog.PreProcessor.Add "PROPERTIES_POPUP"    , FrameWork.GetDictionary("PRICELIST_EDIT_PROPERTIES_DIALOG")
		MDMListDialog.PreProcessor.Add "PROPERTIES_BUTTON"   , FrameWork.GetDictionary("TEXT_RATESCHEDULE_EDIT_PROPERTIES")
		MDMListDialog.PreProcessor.Add "DELETE_POPUP"    , FrameWork.GetDictionary("PRICELIST_DELETE_DIALOG")
		MDMListDialog.PreProcessor.Add "DELETE_BUTTON"   , FrameWork.GetDictionary("TEXT_DELETE")
		MDMListDialog.PreProcessor.Add "ID"    	 		 , ProductView.Properties.Rowset.Value("id_prop")
		EventArg.HTMLRendered = MDMListDialog.PreProcess(HTML_LINK_EDIT)
    Case Else
      LinkColumnMode_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation           
  End Select

END FUNCTION

%>

