 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
' 
'  Copyright 1998,2001 by MetraTech Corporation
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
'  Created by: The UI Team
' 
'  $Date$
'  $Author$
'  $Revision$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : Rates.ProductOffering.asp
' DESCRIPTION : Allow to select a Priceable Item and execute a specific asp file if the user click on one.
' 
' PICKER INTERFACE : A Picker ASP File Interface is based on the QueryString Name/Value.
'                    NextPage : The url to execute if a user click a one item. This url must accept a querystring
'                    parameter ID. ID will contains this id of the Item.
'
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../lib/TabsClass.asp" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE
mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
  Dim strTabs
	
  ' Dynamically Add Tabs to template
  gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_RATES_PRODUCT_OFFERING_LIST"), "[RATES_PRODUCT_OFFERING_LIST_DIALOG]"
  gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_RATES_PRICELIST_LIST"), "[RATES_PRICE_LIST_LIST_DIALOG]"
  gObjMTTabs.Tab = 0
    
  strTabs = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)

  Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)
	Form_Initialize = MDMListDialog.Initialize(EventArg)
	  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :  EventArg
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog, objMTFilter

  Form_LoadProductView = FALSE
  
  Set objMTProductCatalog = GetProductCatalogObject
  Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter.1")
  objMTFilter.Add "Hidden", OPERATOR_TYPE_EQUAL, "N"
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = objMTProductCatalog.FindProductOfferingsAsRowset(objMTFilter)
  
  ProductView.Properties.ClearSelection               ' Select the properties I want to print in the PV Browser   Order  
  ProductView.Properties("nm_name").Selected     	= 1
  ProductView.Properties("nm_desc").Selected 	  	= 2
  
  ProductView.Properties("nm_name").Sorted       	= MTSORT_ORDER_ASCENDING ' Set the default sorted property
  
  Set Form.Grid.FilterProperty                      = ProductView.Properties("nm_name") ' Set the property on which to apply the filter  
  ProductView.Properties("nm_name").Caption         = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption         = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
  
  Form_LoadProductView = TRUE ' Must Return TRUE To Render The Dialog
END FUNCTION
%>
