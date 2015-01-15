<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
 <%
'//==========================================================================
'//  Copyright 1998-2002 by MetraTech Corporation
'//  All rights reserved.
'// 
'//  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'//  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'//  example, but not limitation, MetraTech Corporation MAKES NO
'// REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'//  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'//  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'//  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'// 
'//  Title to copyright in this software and any associated
'// documentation shall at all times remain with MetraTech Corporation,
'//  and USER agrees to preserve the same.
'//==========================================================================

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' AccountTemplate.ProductOfferingPicker.asp                                 '
' Picker to add (non-group) subscriptions to a template. The ID of the      '
' product offering to subscribe to is returned.                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmPicker.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/CAccountTemplateHelper.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'MDM Stuff
Form.Version        							= MDM_VERSION
Form.RouteTo                      = Session("MAM_TEMPLATE_START_DIALOG")
Form.Page.MaxRow               		= CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   	= mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

Call mdm_PVBrowserMain()

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Form_Initialize(EventArg)                                   '
' Description :                                                             '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function Form_Initialize(EventArg)
	 Form("NextPage") = Request.QueryString("NextPage")
   Form_Initialize  = MDMPickerDialog.Initialize(EventArg)
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Form_LoadProductView(EventArg)                              '
' Description :                                                             '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function Form_LoadProductView(EventArg)
  Dim objProductCatalog
  
  Form_LoadProductView = false

  'Get the product offerings available as of the hierarchy date
  Set ProductView.Properties.Rowset = AccountTemplateHelper.GetAvailableProductOfferingsAsRowset(mam_GetHierarchyTime())
  
  'Add the properties
  Call ProductView.Properties.AddPropertiesFromRowset(ProductView.Properties.Rowset)
  
  'Setup the grid
  Call ProductView.Properties.ClearSelection()
  
  ProductView.Properties("nm_display_name").Selected = 1
  ProductView.Properties("nm_desc").Selected = 2

  ProductView.Properties("nm_display_name").Caption	= mam_GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption	= mam_GetDictionary("TEXT_COLUMN_DESCRIPTION")
   
  ProductView.Properties("nm_display_name").Sorted = MTSORT_ORDER_ASCENDING
  
  Set Form.Grid.FilterProperty = ProductView.Properties("nm_display_name") ' Set the property on which to apply the filter  
    
  Form_LoadProductView = true
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Ok_Click(EventArg)                                          '
' Description :                                                             '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function OK_Click(EventArg)
  OK_Click = MDMPickerDialog.OK_Click(EventArg)
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Cancel_Click(EventArg)                                      '
' Description :                                                             '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function Cancel_Click(EventArg)
  Form.RouteTo = Form("NextPage")
  Cancel_Click = true
End Function


%>

