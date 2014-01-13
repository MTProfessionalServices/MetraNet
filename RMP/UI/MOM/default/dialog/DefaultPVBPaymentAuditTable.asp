 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: $
' 
'  Copyright 1998-2003 by MetraTech Corporation
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
'  $Date: 5/11/00 12:00:08 PM$
'  $Author: $
'  $Revision: 1$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : DefaultPVBPaymentAuditTable.asp
' DESCRIPTION : Browse the payment server table t_payment_audit! We directly run a SQL query no product view is involve.
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"          -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<%

Form.Page.MaxRow                = CLng(mom_GetDictionary("PV_ROW_PER_PAGE"))
Form.RouteTo			              = mom_GetDictionary("WELCOME_DIALOG")
Form.Page.NoRecordUserMessage   = mom_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    :  Form_Initialize
' PARAMETERS  :
' DESCRIPTION : 
' RETURNS     :
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    
	  ProductView.Clear  ' Set all the property of the service to empty or to the default value
	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    :  Form_LoadProductView
' PARAMETERS  :  EventArg
' DESCRIPTION : 
' RETURNS     :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objProperty,i
  ' Tell the product view object to behave like real MT Product View based on the data in the rowset
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  If(ProductView.Properties.Load(0,"__SELECT_PAYMENT_AUDIT__",eMSIX_PROPERTIES_LOAD_FLAG_LOAD_SQL_SELECT+eMSIX_PROPERTIES_LOAD_FLAG_INIT_FROM_ROWSET,mom_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH")))Then
      
      ' Select the properties I want to print in the PV Browser   Order
    	ProductView.Properties.ClearSelection
      i = 1
      ProductView("dt_occurred").Selected         = i : i = i + 1
      ProductView("id_acc").Selected              = i : i = i + 1
      ProductView("nm_lastfourdigits").Selected   = i : i = i + 1
      ProductView("nm_action").Selected           = i : i = i + 1
      ProductView("nm_routingnumber").Selected    = i : i = i + 1
      ProductView("tx_IP_subscriber").Selected    = i : i = i + 1
      'ProductView("tx_IP_CSR").Selected           = i : i = i + 1
  
      Form_LoadProductView  = TRUE
      
      For Each objProperty In ProductView.Properties
          objProperty.Caption = objProperty.Name
      Next
      
      ' Sort
      ProductView.Properties("dt_occurred").Sorted                  = MTSORT_ORDER_DECENDING

  End If
END FUNCTION

%>

