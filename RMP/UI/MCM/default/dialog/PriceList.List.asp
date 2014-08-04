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
<!-- #INCLUDE FILE="../lib/ScriptIncludes.html" -->
<!--METADATA TYPE="TypeLib" NAME="PCCONFIGLib" UUID="{A4175A41-AF24-4F1E-B408-00CF83690549}" VERSION="1.0" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = FALSE

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
  Form_Initialize = MDMListDialog.Initialize(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :  EventArg
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog
	Dim b_showoptionscolumn

  Form_LoadProductView = FALSE
  
  Set objMTProductCatalog = GetProductCatalogObject

  'Create a filter so we display only non-ICB price lists
  Dim objMTFilter
  Set objMTFilter = mdm_CreateObject(MTFilter)
  objMTFilter.Add "Type", OPERATOR_TYPE_EQUAL, PRICELIST_TYPE_REGULAR
	
	'Check if we should display the options column
	b_showoptionscolumn = objMTProductCatalog.IsBusinessRuleEnabled(PCCONFIGLib.MTPC_BUSINESS_RULE_Rates_DeleteOverride) 
	if (b_showoptionscolumn) then
		b_showoptionscolumn = FrameWork.CheckCoarseCapability("Delete Rates")
	end if
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = objMTProductCatalog.FindPriceListsAsRowset(objMTFilter)

  ' Select the properties I want to print in the PV Browser   Order
  
  ProductView.Properties.ClearSelection    	
  ProductView.Properties("nm_name").Selected 			      			= 1
  ProductView.Properties("nm_desc").Selected 	          			= 2
  ProductView.Properties("nm_currency_code").Selected 				= 3
	
	if b_showoptionscolumn then
		ProductView.Properties("n_name").Selected 			      			= 4
	end if
 ' ProductView.Properties.SelectAll
	
  ProductView.Properties("nm_name").Sorted               			= MTSORT_ORDER_ASCENDING
  
  Set Form.Grid.FilterProperty                          			= ProductView.Properties("nm_name") ' Set the property on which to apply the filter  
	
  ProductView.Properties("nm_name").Caption              			= FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption              			= FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
	ProductView.Properties("nm_currency_code").Caption          = FrameWork.GetDictionary("TEXT_COLUMN_CURRENCY_CODE")
	if b_showoptionscolumn then
		ProductView.Properties("n_name").Caption          					= FrameWork.GetDictionary("TEXT_RATES_COLUMN_OPTIONS") 
	end if
  Form_LoadProductView                                  			= TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION

PUBLIC FUNCTION ViewEditMode_DisplayCell(EventArg) ' As Boolean
	Dim HTML_LINK_EDIT
	  
	'We are drawing column based on their positions on the Rowset.
	'Ideally this should be based on column names, but we need to display
	'the edit gif, so we can't do that.
  Select Case Form.Grid.Col
  	Case 1
    	HTML_LINK_EDIT = HTML_LINK_EDIT & "<td class='[CLASS]' width='5'>"                                                         
      HTML_LINK_EDIT = HTML_LINK_EDIT & "<A HREF=""javascript:editSelectedItem('[ASP_PAGE]?ID=[ID]');""><img Alt='[ALT_EDIT]' src='[IMAGE_EDIT]' Border='0'></A>&nbsp;"
			HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
			
			MDMListDialog.PreProcessor.Clear
			MDMListDialog.PreProcessor.Add "CLASS"       , Form.Grid.CellClass        
			MDMListDialog.PreProcessor.Add "ASP_PAGE"    , FrameWork.GetDictionary("PRICELIST_EDIT_PROPERTIES_DIALOG")
			MDMListDialog.PreProcessor.Add "IMAGE_EDIT"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif"
			MDMListDialog.PreProcessor.Add "ALT_EDIT"    , mdm_GetDictionary().Item("TEXT_EDIT").Value
			MDMListDialog.PreProcessor.Add "ID"	    	   , ProductView.Properties.Rowset.Value("id_prop")
			
			EventArg.HTMLRendered           = MDMListDialog.PreProcess(HTML_LINK_EDIT)
			ViewEditMode_DisplayCell        = TRUE
			
    Case 2
      mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
	
		Case 6
			HTML_LINK_EDIT = ""
			HTML_LINK_EDIT = HTML_LINK_EDIT & "<td nowrap align='center' class='[CLASS]'>"
      HTML_LINK_EDIT = HTML_LINK_EDIT & "<button name='delete[ID]' class='clsButtonBlueMedium' onclick=""OpenDialogWindow('[DELETE_POPUP]?ID=[ID]', '_blank', 'height=100,width=100,resizable=yes,scrollbars=yes');"">[DELETE_BUTTON]</button>"
      HTML_LINK_EDIT = HTML_LINK_EDIT & "<button name='copy[ID]' class='clsButtonBlueMedium' onclick=""OpenDialogWindow('http://localhost/mcm/default/dialog/PriceList.Copy.asp?ID=[ID]', '_blank', 'height=100,width=100,resizable=yes,scrollbars=yes');"">Copy</button>"
			HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
	
			MDMListDialog.PreProcessor.Clear
			MDMListDialog.PreProcessor.Add "CLASS"       , Form.Grid.CellClass        
			MDMListDialog.PreProcessor.Add "DELETE_POPUP"    , FrameWork.GetDictionary("PRICELIST_DELETE_DIALOG")
			MDMListDialog.PreProcessor.Add "DELETE_BUTTON"   , FrameWork.GetDictionary("TEXT_DELETE")
			MDMListDialog.PreProcessor.Add "ID"    	 		 , ProductView.Properties.Rowset.Value("id_prop")
			EventArg.HTMLRendered = MDMListDialog.PreProcess(HTML_LINK_EDIT)
			
			ViewEditMode_DisplayCell        = TRUE
		Case else
			ViewEditMode_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
			
	End Select
	
END FUNCTION
%>

