 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: $
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
'  $Date: 5/11/00 12:00:08 PM$
'  $Author: $
'  $Revision: 1$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : PriceableItem.Picker.asp
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
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE

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

  Dim objMTProductCatalog, objMTFilter

  Form_LoadProductView = FALSE

  Set objMTProductCatalog = GetProductCatalogObject
  
  If(Not IsEmpty(Form("Kind")))Then
      Set objMTFilter = mcmGetFilterForPriceableItemKind(CLng(Form("Kind")))
  Else
      Set objMTFilter = Nothing   ' No Filter
  End If
  
  Set ProductView.Properties.RowSet = objMTProductCatalog.FindPriceableItemsAsRowset(objMTFilter) ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  
  ProductView.Properties.ClearSelection               ' Select the properties I want to print in the PV Browser   Order  
  ProductView.Properties("n_name").Selected     = 1
  ProductView.Properties("n_desc").Selected 	  = 2
  ProductView.Properties("nm_glcode").Selected  = 3
  
  ProductView.Properties("n_name").Sorted       = MTSORT_ORDER_ASCENDING ' Set the default sorted property
  
  Set Form.Grid.FilterProperty                          = ProductView.Properties("n_name") ' Set the property on which to apply the filter  

  ProductView.Properties("nm_name").Caption 		          = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption 	            = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")

  Form_LoadProductView = TRUE ' Must Return TRUE To Render The Dialog
END FUNCTION
%>

