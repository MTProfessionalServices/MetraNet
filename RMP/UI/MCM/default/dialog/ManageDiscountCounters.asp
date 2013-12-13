 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
' 
'  Copyright 1998 - 2002 by MetraTech Corporation
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
'  Created by: K. Boucher
' 
'  $Date$
'  $Author$
'  $Revision$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : ManageDiscountCounters.asp
' DESCRIPTION : View and setup discount counter parameters
' VERSION     : V3.5 
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>

<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../lib/ScriptIncludes.html" -->

<%
Form.Version        = MDM_VERSION     
Form.ErrorHandler   = TRUE

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

  Form_LoadProductView = FALSE
  
  Set objMTProductCatalog = GetProductCatalogObject

  'Create Filter
  Dim objMTFilter
  Set objMTFilter = mdm_CreateObject(MTFilter)
  'objMTFilter.Add "Shareable", OPERATOR_TYPE_EQUAL, "Y"
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = objMTProductCatalog.FindCounterParametersAsRowset(objMTFilter)

  ' Select the properties I want to print in the PV Browser   Order
  
  ProductView.Properties.ClearSelection    	
'   id_counter_param   Value   nm_name   nm_desc   nm_display_name  
  ProductView.Properties("nm_display_name").Selected 	   			= 1
  ProductView.Properties("nm_desc").Selected 	          			= 2
  ProductView.Properties("Value").Selected 	            			= 3
'  ProductView.Properties.SelectAll
	
  ProductView.Properties("nm_display_name").Sorted      			= MTSORT_ORDER_ASCENDING
  Set Form.Grid.FilterProperty                          			= ProductView.Properties("nm_display_name") ' Set the property on which to apply the filter  
	
  ProductView.Properties("nm_display_name").Caption        		= FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption               		= FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
  ProductView.Properties("Value").Caption                  		= "Value" 
  
  Form_LoadProductView                                  			= TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION

PUBLIC FUNCTION ViewEditMode_DisplayCell(EventArg) ' As Boolean
	Dim HTML_LINK_EDIT
    
	'We are drawing column based on their positions on the Rowset.
	'Ideally this should be based on column names, but we need to display
	'the edit gif, so we can't do that.
  Select Case Form.Grid.Col
  Case 1
  	HTML_LINK_EDIT = HTML_LINK_EDIT & "<td class='[CLASS]' width='40'>"                                                         
    'HTML_LINK_EDIT = HTML_LINK_EDIT & "<A HREF='[ASP_PAGE]?Reload=TRUE&EditMode=True&Manage=True&CALENDAR_ID=[ID]'><img Alt='[ALT_EDIT]' Name='[IMAGE_EDIT_NAME]'  src='[IMAGE_EDIT]' Border='0'></A>&nbsp;"
    HTML_LINK_EDIT = HTML_LINK_EDIT & "<A HREF='[ASP_PAGE]?Reload=TRUE&EditMode=False&Manage=True&COUNTER_PARAM_ID=[ID]'><img Alt='[ALT_VIEW]' Name='[IMAGE_VIEW_NAME]' src='[IMAGE_VIEW]' Border='0'></A>"
		HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
			
		MDMListDialog.PreProcessor.Clear
		MDMListDialog.PreProcessor.Add "CLASS"       , Form.Grid.CellClass        
		MDMListDialog.PreProcessor.Add "ASP_PAGE"    , "CounterParameter.Edit.asp"
		MDMListDialog.PreProcessor.Add "IMAGE_EDIT"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif"
		MDMListDialog.PreProcessor.Add "IMAGE_VIEW"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/icons/view.gif"
		MDMListDialog.PreProcessor.Add "ALT_VIEW"    , mdm_GetDictionary().Item("TEXT_VIEW").Value

    MDMListDialog.PreProcessor.Add "IMAGE_EDIT_NAME" , "EditIcon" & Form.Grid.Row ' For FredRunner
    MDMListDialog.PreProcessor.Add "IMAGE_VIEW_NAME" , "ViewIcon" & Form.Grid.Row ' For FredRunner
		
		MDMListDialog.PreProcessor.Add "ALT_EDIT"    , mdm_GetDictionary().Item("TEXT_EDIT").Value
		MDMListDialog.PreProcessor.Add "ID"	    	   , ProductView.Properties.Rowset.Value("id_counter_param")
		
		EventArg.HTMLRendered           = MDMListDialog.PreProcess(HTML_LINK_EDIT)
		ViewEditMode_DisplayCell        = TRUE
    
    Case 2
      mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown

		Case else
			ViewEditMode_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
			
	End Select
	
END FUNCTION
%>

