<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
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
' CLASS       : DefaultDialogSubscribe.asp
' DESCRIPTION : 
' 
' PICKER INTERFACE : A Picker ASP File Interface is based on the QueryString Name/Value.
'                    NextPage : The url to execute if a user click a one item. This url must accept a querystring
'                    parameter ID. ID will contains this id of the Item.
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- METADATA type="TypeLib" UUID="{A4175A41-AF24-4F1E-B408-00CF83690549}" -->

<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmPicker.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.Version        						= MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo        						= mam_GetDictionary("SETUP_SUBSCRIPTIONS_DIALOG")
Form.Page.MaxRow                = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	Form_Initialize = MDMPickerDialog.Initialize(EventArg)
	If Len(Request.QueryString("CorpAccountID")) > 0 Then
		Form("CorpID") = CLng(Request.QueryString("CorpAccountID"))
	End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim acctID
  Dim yaac
  
  set yaac =  Session("SubscriberYAAC")
  'response.Write "Corp Account ID " & Form("CorpID")
  'response.End
  
  Form_LoadProductView = FALSE
  
  
	' Get Group-subscribable POs as rowset
  Dim pc, bHierarchyRestrictedOperations
  Set pc = GetProductCatalogObject()  
  bHierarchyRestrictedOperations = pc.IsBusinessRuleEnabled(PCCONFIGLib.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations)

  Dim objMTFilter
  If mdm_UIValue("mdmPVBFilter") <> "" Then
    Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter.1")
    objMTFilter.Add "Name", OPERATOR_TYPE_LIKE, "%" + mdm_UIValue("mdmPVBFilter") + "%"
    Set ProductView.Properties.RowSet = yaac.GetAvailableGroupSubscriptionsAsRowset(mam_GetHierarchyDate(), objMTFilter)
  Else
    Set ProductView.Properties.RowSet = yaac.GetAvailableGroupSubscriptionsAsRowset(mam_GetHierarchyDate())
  End If
  
  ' Check to see if items have been filtered and inform the user
  If ProductView.Properties.RowSet.RecordCount >= 1000 Then
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", TRUE
  ELSE
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", FALSE      
  End If
        
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet

  ProductView.Properties.ClearSelection    
  'ProductView.Properties.SelectAll  

  ProductView.Properties("tx_name").Selected 									= 1
  ProductView.Properties("tx_desc").Selected 									= 2
	ProductView.Properties("vt_start").Selected 								= 3
	ProductView.Properties("vt_end").Selected 									= 4
  'ProductView.Properties("id_group").Selected 								= 5
  
  If Not bHierarchyRestrictedOperations Then
    ProductView.Properties("nm_currency_code").Selected 	   	= 5
    ProductView.Properties("nm_currency_code").Caption = mam_GetDictionary("TEXT_CURRENCY")
  End If

  ProductView.Properties("tx_name").Caption = mam_GetDictionary("TEXT_GROUP_SUBSCRIPTIONS_NAME")
	ProductView.Properties("tx_desc").Caption = mam_GetDictionary("TEXT_DESCRIPTION")
	ProductView.Properties("vt_start").Caption = mam_GetDictionary("TEXT_RATE_START_DATE")
	ProductView.Properties("vt_end").Caption = mam_GetDictionary("TEXT_RATE_END_DATE")
  'ProductView.Properties("id_group").Caption = mam_GetDictionary("TEXT_ACTION")
      
  ProductView.Properties("tx_name").Sorted      = MTSORT_ORDER_ASCENDING
  Set Form.Grid.FilterProperty                          = ProductView.Properties("tx_name") ' Set the property on which to apply the filter  
  
  Form_LoadProductView = TRUE
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Form_DisplayCell
' PARAMETERS :
' DESCRIPTION :
' RETURNS    : 
PUBLIC FUNCTION Form_DisplayCell1(EventArg) ' As Boolean
  Dim m_objPP, HTML_LINK_EDIT
	Dim strHTML

  Select Case Form.Grid.Col
	
	End Select
	  
	Select Case lcase(Form.Grid.Col)
		'Case "tx_name"
		Case 3
	    strHTML = ProductView.Properties("tx_name")		
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strHTML & "</td>"
			Form_DisplayCell = TRUE
		'Case "tx_desc"
		Case 4
	    strHTML = ProductView.Properties("tx_desc")		
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strHTML & "</td>"
			Form_DisplayCell = TRUE						
    Case Else        
      Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
  End Select
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION       : 
' PARAMETERS    :
' DESCRIPTION   :
' RETURNS        : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean
	Form.RouteTo        						= mam_GetDictionary("GROUP_MEMBER_EDIT_DIALOG")
	OK_Click = MDMPickerDialog.OK_Click(EventArg)
END FUNCTION



%>

