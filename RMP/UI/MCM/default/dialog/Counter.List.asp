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
'  Created by: Srinivasa Rao Kolla
' 
'  $Date: 4/13/01 12:00:08 PM$
'  $Author: $
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

  Dim objMTProductCatalog 

  Form_LoadProductView      = FALSE
  Set objMTProductCatalog   = GetProductCatalogObject
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = objMTProductCatalog.FindCountersAsRowset()
 
  ProductView.Properties.ClearSelection                       ' Select the properties I want to print in the PV Browser   Order
  ProductView.Properties("Name").Selected 			      = 1
  ProductView.Properties("id_prop").Selected 	        = 2
  ProductView.Properties("Description").selected      = 3
  ProductView.Properties("Formula").selected          = 4
    
  ProductView.Properties("name").Sorted               = MTSORT_ORDER_ASCENDING
  
  Set Form.Grid.FilterProperty                        = ProductView.Properties("Name") ' Set the property on which to apply the filter    '
  ProductView.Properties("name").Caption              = "Name"
  ProductView.Properties("id_prop").Caption           = "ID"
  ProductView.Properties("Description").Caption       = "Description"
  ProductView.Properties("Formula").Caption           = "Formula"
  
  Form_LoadProductView                                = TRUE ' Must Return TRUE To Render The Dialog  
END FUNCTION
%>