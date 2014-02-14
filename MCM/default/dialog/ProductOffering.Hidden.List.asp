 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: s:\UI\MCM\default\dialog\ProductOffering.Hidden.List.asp$
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
'  $Date: 11/13/2002 6:10:21 PM$
'  $Author: Fabricio Pettena$
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
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../lib/ScriptIncludes.html" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
  Form_Initialize = MDMListDialog.Initialize(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog, objMTFilter
  Form_LoadProductView = FALSE
	
  Set objMTProductCatalog = GetProductCatalogObject
	
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter.1")
  objMTFilter.Add "Hidden", OPERATOR_TYPE_EQUAL, "Y"

  If Session("isPartitionUser") Then
    objMTFilter.Add "PartitionId", OPERATOR_TYPE_EQUAL, Session("topLevelAccountId")
  End If

  Set ProductView.Properties.RowSet = objMTProductCatalog.FindProductOfferingsAsRowset(objMTFilter)
  
  
  ProductView.Properties.ClearSelection                       ' Select the properties I want to print in the PV Browser   Order
  'ProductView.Properties.SelectAll
  ProductView.Properties("nm_name").Selected 			      = 1
  ProductView.Properties("nm_desc").Selected 	          = 2
  ProductView.Properties("n_name").Selected 			      = 3
	

  ProductView.Properties("nm_name").Caption 		          = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption 	            = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
  ProductView.Properties("n_name").Caption 	            	= FrameWork.GetDictionary("TEXT_COLUMN_OPTIONS")
   
  ProductView.Properties("nm_name").Sorted               = MTSORT_ORDER_ASCENDING
  
  Set Form.Grid.FilterProperty                          = ProductView.Properties("nm_name") ' Set the property on which to apply the filter  
  
  Form_LoadProductView                                  = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION


PUBLIC FUNCTION Form_DisplayCell(EventArg) ' As Boolean

	Dim m_objPP, HTML_LINK_EDIT , strValue , strFormat, lngPos, strParameter 
	  
  Select Case Form.Grid.Col
  	Case 1,2
      mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
				
		Case 5
			HTML_LINK_EDIT = ""
			HTML_LINK_EDIT = HTML_LINK_EDIT & "<td nowrap align='center' class='[CLASS]'>"
      HTML_LINK_EDIT = HTML_LINK_EDIT & "<button name='delete[ID]' class='clsButtonBlueMedium' onclick=""OpenDialogWindow('[HIDEUNHIDE_POPUP]?ID=[ID]&Hide=FALSE','_blank', 'height=300,width=300,resizable=yes,scrollbars=yes');"">[UNHIDE_BUTTON]</button>"
			HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
	
			MDMListDialog.PreProcessor.Clear
			MDMListDialog.PreProcessor.Add "CLASS"						, Form.Grid.CellClass 
			MDMListDialog.PreProcessor.Add "HIDEUNHIDE_POPUP"	, FrameWork.GetDictionary("HIDEUNHIDE_POPUP_DIALOG")
			MDMListDialog.PreProcessor.Add "UNHIDE_BUTTON"		, FrameWork.GetDictionary("TEXT_UNHIDE")
			MDMListDialog.PreProcessor.Add "ID"								, ProductView.Properties.Rowset.Value("id_prop")
			EventArg.HTMLRendered = MDMListDialog.PreProcess(HTML_LINK_EDIT)
			
			Form_DisplayCell        = TRUE
		Case else
			Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
			
	End Select
	
END FUNCTION

%>
