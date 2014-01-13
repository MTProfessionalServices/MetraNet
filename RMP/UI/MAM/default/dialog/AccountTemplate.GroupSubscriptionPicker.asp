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
' AccountTemplate.GroupSubscriptionPicker.asp                               '
' Allows the user to select groups subscriptions to add to an account       '
' template.                                                                 '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Option Explicit
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
  <!-- METADATA type="TypeLib" UUID="{A4175A41-AF24-4F1E-B408-00CF83690549}" -->

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
   Form("IDColumnName")="ID_GROUP"
   
   Form_Initialize = true
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : Form_LoadProductView(EventArg)                              '
' Description :                                                             '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function Form_LoadProductView(EventArg)

  ' Create filter to be applied when query is run  
  Dim objMTFilter, filter
  If mdm_UIValue("mdmPVBFilter") <> "" Then
    Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter.1")
    objMTFilter.Add "tg.tx_name", OPERATOR_TYPE_LIKE, "%" + mdm_UIValue("mdmPVBFilter") + "%"
    filter = " and " & objMTFilter.FilterString
  Else
    filter = ""
  End If

  ' Execute Query
  dim rowset
  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\Acchierarchies"
	rowset.SetQueryTag "__FIND_AVAILABLE_GROUPSUBS_FOR_TEMPLATE_FILTERED__"  
  rowset.AddParam "%%REFDATE%%", mam_GetHierarchyTime()
  rowset.AddParam "%%ID_ACC%%", AccountTemplateHelper.AccountTemplate().AccountID
  rowset.AddParam "%%ACC_TEMPLATE%%", AccountTemplateHelper.AccountTemplate().ID

  ' Check cross corporate business rule
  Dim pc
  Set pc = GetProductCatalogObject()  
  If pc.IsBusinessRuleEnabled(PCCONFIGLib.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) Then
    rowset.AddParam "%%CORPORATEACCOUNT%%", Session("SubscriberYAAC").CorporateAccountID    
  Else
    rowset.AddParam "%%CORPORATEACCOUNT%%", MAM_HIERARCHY_ROOT_ACCOUNT_ID
  End If
  
  rowset.AddParam "%%FILTERS%%", filter, TRUE
  rowset.Execute
  Set ProductView.Properties.Rowset = rowset

  ' Check to see if items have been filtered and inform the user
  If ProductView.Properties.RowSet.RecordCount >= 1000 Then
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", TRUE
  ELSE
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", FALSE      
  End If
	
  'ProductView.Properties.SelectAll
  Call ProductView.Properties.ClearSelection()
  ProductView.Properties("tx_name").Selected  = 1
  ProductView.Properties("tx_desc").Selected 	= 2

  ProductView.Properties("tx_name").Caption   = mam_GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("tx_desc").Caption 	= mam_GetDictionary("TEXT_COLUMN_DESCRIPTION")
   
  ProductView.Properties("tx_name").Sorted    = MTSORT_ORDER_ASCENDING
  
  Set Form.Grid.FilterProperty                = ProductView.Properties("tx_name") ' Set the property on which to apply the filter  
    
  Form_LoadProductView = true
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : OK_Click(EventArg)                                          '
' Description :                                                             '
' Inputs      :                                                             '
' Outputs     :                                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function OK_Click(EventArg)
  OK_Click = MDMPickerDialog.OK_Click(EventArg)
End Function
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
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

%>

