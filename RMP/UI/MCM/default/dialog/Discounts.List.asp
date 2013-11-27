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
'  Created by: K.Boucher
' 
'  $Date: 5/11/00 12:00:08 PM$
'  $Author: $
'  $Revision: 1$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' DIALOG      : Discounts.asp
' DESCRIPTION : 
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../lib/TabsClass.asp" -->
<!-- #INCLUDE FILE="../lib/ScriptIncludes.html" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = FALSE
mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    FrameWork.Log "Getting Discounts...", LOGGER_DEBUG 
	  ProductView.Clear  ' Set all the property of the service to empty or to the default value
    
        Dim strTabs
    
    ' Dynamically Add Tabs to template
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_USAGE_CHARGES"), "[SERVICE_CHARGES_USAGE_LIST]"
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_RECURRING_CHARGES"), "[SERVICE_CHARGES_RECURRING_LIST]"
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_NON_RECURRING_CHARGES"), "[SERVICE_CHARGES_NONRECURRING_LIST]"
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_DISCOUNTS"), "[DISCOUNT_LIST_DIALOG]"
          
    gObjMTTabs.Tab = Clng(Request.QueryString("Tab"))
    
    ' Setup tabs
    Select Case gObjMTTabs.Tab
      Case 0
        Framework.Dictionary.Add "TAB_LIST_HEADING", FrameWork.GetDictionary("TEXT_KEYTERM_USAGE_CHARGES")
      Case 1
        Framework.Dictionary.Add "TAB_LIST_HEADING", FrameWork.GetDictionary("TEXT_KEYTERM_RECURRING_CHARGES")
      Case 2         
        Framework.Dictionary.Add "TAB_LIST_HEADING", FrameWork.GetDictionary("TEXT_KEYTERM_NON_RECURRING_CHARGES")
      Case 3 
        Framework.Dictionary.Add "TAB_LIST_HEADING", FrameWork.GetDictionary("TEXT_MENU_PRICEABLE_ITEM_CHARGES")
      Case Else 
        Framework.Dictionary.Add "TAB_LIST_HEADING", FrameWork.GetDictionary("TEXT_KEYTERM_DISCOUNTS")

    End Select  
    
    strTabs = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
  
    Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)

	  Form_Initialize = MDMListDialog.Initialize(EventArg)	  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog ,objMTFilter

  Form_LoadProductView = FALSE
  
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW ' Tell the product view object to behave like real MT Product View based on the data in the rowset
  
  Set objMTProductCatalog = GetProductCatalogObject
  
  If(Not IsEmpty(Form("Kind")))Then
  
      Set objMTFilter = mdm_CreateObject(MTFilter)
      objMTFilter.Add "Kind", OPERATOR_TYPE_EQUAL, CLng(Form("Kind"))
  Else
      Set objMTFilter = Nothing   ' No Filter
  End If
  
  Set ProductView.Properties.RowSet = objMTProductCatalog.FindPriceableItemsAsRowset(objMTFilter) ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset 
    
  ' Select the properties I want to print in the PV Browser   Order
  ProductView.Properties.ClearSelection
  ProductView.Properties("nm_name").Selected 			             = 1
  ProductView.Properties("nm_desc").Selected 	                 = 2
  'ProductView.Properties("nm_glcode").Selected 		             = 3
  
  ProductView.Properties("nm_name").Caption 		= FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption 	  = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
  'ProductView.Properties("nm_glcode").Caption = FrameWork.GetDictionary("TEXT_COLUMN_GLCODE")
  
'  ProductView.Properties.SelectAll       ' get all columns
  
  ProductView.Properties("nm_name").Sorted               = MTSORT_ORDER_ASCENDING
  set Form.Grid.FilterProperty = ProductView.Properties("nm_name")  
  Form_LoadProductView                                  = TRUE
  
END FUNCTION
%>

