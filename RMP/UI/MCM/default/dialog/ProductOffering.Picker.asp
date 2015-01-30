 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
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
'  $Date$
'  $Author$
'  $Revision$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : ProductOffering.Picker.asp
' DESCRIPTION : Allow to select a ProductOffering Item and execute a specific asp file if the user click on one.
' 
' PICKER INTERFACE : A Picker ASP File Interface is based on the QueryString Name/Value.
'                    NextPage : The url to execute if a user click a one item. This url must accept a querystring
'                    parameter ID. ID will contains this id of the Item.
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmPicker.Library.asp" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE
Form.RouteTo        = FrameWork.GetDictionary("WELCOME_DIALOG") ' This Should Change Some Time

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Form("ShowAvailableOnly") = request("ShowAvailableOnly")
    
    Form_Initialize = MDMPickerDialog.Initialize (EventArg)
    Form.Modal      = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog, objMTFilter 

  Form_LoadProductView = FALSE
  
  Set objMTProductCatalog = GetProductCatalogObject
  Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter.1")
  objMTFilter.Add "Hidden", OPERATOR_TYPE_EQUAL, "N"
  
  FrameWork.Dictionary().Add "TEXT_PRODUCT_OFFERING_TYPE", ""

  If CBool(Request("Master")) Then
    objMTFilter.Add "PartitionId", OPERATOR_TYPE_EQUAL, 0
    'objMTFilter.Add "MasterFlag", OPERATOR_TYPE_EQUAL, True
    FrameWork.Dictionary().Add "TEXT_PRODUCT_OFFERING_TYPE", "(Master)"
  ElseIf Session("isPartitionUser") Then
    objMTFilter.Add "PartitionId", OPERATOR_TYPE_EQUAL, Session("topLevelAccountId")
    FrameWork.Dictionary().Add "TEXT_PRODUCT_OFFERING_TYPE", "(Partition)"
  End If

  if UCASE(Form("ShowAvailableOnly"))="Y" then
    Set ProductView.Properties.RowSet = objMTProductCatalog.FindAvailableProductOfferingsAsRowset(objMTFilter,FrameWork.MetraTimeGMTNow())
  else  
    Set ProductView.Properties.RowSet = objMTProductCatalog.FindProductOfferingsAsRowset(objMTFilter)
  end if
    
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet
      
  ' Select the properties I want to print in the PV Browser   Order
  ProductView.Properties.ClearSelection    
  ProductView.Properties("nm_display_name").Selected 			      = 1
  ProductView.Properties("nm_desc").Selected 	          = 2

  '  ProductView.Properties.SelectAll  
  ProductView.Properties("nm_display_name").Sorted               = MTSORT_ORDER_ASCENDING

  Set Form.Grid.FilterProperty                          = ProductView.Properties("nm_display_name") ' Set the property on which to apply the filter  
  ProductView.Properties("nm_display_name").Caption             = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption             = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
  
  Form_LoadProductView = TRUE
  
END FUNCTION
    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : 
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean

    OK_Click = MDMPickerDialog.OK_Click(EventArg)
END FUNCTION  
%>

