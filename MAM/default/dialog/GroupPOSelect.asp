<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
 <%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: GroupPOSelect.asp$
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
'  $Date: 11/12/2002 2:00:02 PM$
'  $Author: Kevin Boucher$
'  $Revision: 6$
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
Form.RouteTo        						= mam_GetDictionary("GROUP_SUBSCRIPTIONS_DIALOG") 'Really only for the cancel event - Localize me
Form.Page.MaxRow                = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
  
  ProductView.Clear  ' Set all the property of the service to empty or to the default value
  ProductView.Properties.Clear
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW
  
  Form_Initialize = MDMPickerDialog.Initialize(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog  
  Dim acctID
  
  Form_LoadProductView = FALSE

  ' Init view date
  If IsEmpty(Form("datStartDate")) Then
      Form("datStartDate") = mam_GetHierarchyDate()
  End If
    
  Set objMTProductCatalog = GetProductCatalogObject
    
	' Get Group-subscribable POs as rowset
  Dim pc, bHierarchyRestrictedOperations
  Set pc = GetProductCatalogObject()  
  bHierarchyRestrictedOperations = pc.IsBusinessRuleEnabled(PCCONFIGLib.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations)
   
  If Not bHierarchyRestrictedOperations Then
    Set ProductView.Properties.RowSet = objMTProductCatalog.FindAvailableProductOfferingsAsRowset(,Form("datStartDate").Value)
  Else
    Set ProductView.Properties.RowSet = objMTProductCatalog.FindAvailableProductOfferingsForGroupSubscriptionAsRowset(MAM().Subscriber("_ACCOUNTID").Value,,Form("datStartDate").Value)
  End If
  
  ' Add Change Date
  Service.Properties.Add "mdm_PVBChangeDate", "TIMESTAMP", 0, FALSE, Empty, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET  
  Service.Properties("mdm_PVBChangeDate").Value = Form("datStartDate").value

  ProductView.Properties.ClearSelection    
  ' ProductView.Properties.SelectAll  
  ' Select the properties I want to print in the PV Browser   Order
  ProductView.Properties("nm_display_name").Selected          = 1
  ProductView.Properties("nm_desc").Selected                  = 2
  'ProductView.Properties("b_recurringcharge").Selected        = 3

  If Not bHierarchyRestrictedOperations Then
    ProductView.Properties("nm_currency_code").Selected 	   	= 3
    ProductView.Properties("nm_currency_code").Caption = mam_GetDictionary("TEXT_CURRENCY")
  End If
    
  ProductView.Properties("nm_display_name").Caption      = mam_GetDictionary("TEXT_SUBSCRIPTION")   
  ProductView.Properties("nm_desc").Caption              = mam_GetDictionary("TEXT_SUBSCRIPTION_DESCRIPTION")   
  'ProductView.Properties("b_recurringcharge").Caption    = mam_GetDictionary("TEXT_RECURRING_CHARGE")
      
  ProductView.Properties("nm_display_name").Sorted      = MTSORT_ORDER_ASCENDING
  Set Form.Grid.FilterProperty                          = ProductView.Properties("nm_display_name") ' Set the property on which to apply the filter  

  Service.LoadJavaScriptCode  ' This line is important to get JavaScript field validation
   
  ' Include Calendar javascript    
  mam_IncludeCalendar
    
  Form_LoadProductView = TRUE
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      : 
' PARAMETERS    :
' DESCRIPTION   :
' RETURNS       : Return TRUE if ok else FALSE
PRIVATE FUNCTION mdm_PVBChangeDateRefresh_Click(EventArg) ' As Boolean

    Form("datStartDate") =  Service.Properties("mdm_PVBChangeDate").Value 
    mdm_PVBChangeDateRefresh_Click = TRUE
END FUNCTION 

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION       : 
' PARAMETERS    :
' DESCRIPTION   :
' RETURNS        : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean

    OK_Click = MDMPickerDialog.OK_Click(EventArg)
END FUNCTION
%>

