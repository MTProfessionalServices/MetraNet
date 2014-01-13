 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
' 
'  Copyright 1998 - 2002 by MetraTech Corporation
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
'  Created by: K. Boucher
' 
'  $Date$
'  $Author$
'  $Revision$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : ManageDiscountCounters.asp
' DESCRIPTION : View and setup discount counter parameters
' VERSION     : V3.5 
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmPicker.Library.asp" -->
<%
Form.Version        = MDM_VERSION     
Form.ErrorHandler   = TRUE

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    Form_Initialize = MDMPickerDialog.Initialize (EventArg)
    Form.Modal = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :  EventArg
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog  

  Form_LoadProductView = FALSE
  
  Set objMTProductCatalog = GetProductCatalogObject

  'Create Filter
  Dim objMTFilter
  Set objMTFilter = mdm_CreateObject(MTFilter)
  'objMTFilter.Add "Shareable", OPERATOR_TYPE_EQUAL, "Y"
  
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = objMTProductCatalog.FindCounterParametersAsRowset(objMTFilter)

  ' Select the properties I want to print in the PV Browser   Order
  
  ProductView.Properties.ClearSelection    	
'   id_counter_param   Value   nm_name   nm_desc   nm_display_name  
  ProductView.Properties("nm_display_name").Selected 	   			= 1
  ProductView.Properties("nm_desc").Selected 	          			= 2
  ProductView.Properties("Value").Selected 	            			= 3
'  ProductView.Properties.SelectAll
	
  ProductView.Properties("nm_display_name").Sorted      			= MTSORT_ORDER_ASCENDING
  Set Form.Grid.FilterProperty                          			= ProductView.Properties("nm_display_name") ' Set the property on which to apply the filter  
	
  ProductView.Properties("nm_display_name").Caption        		= FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption               		= FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
  ProductView.Properties("Value").Caption                  		= "Value" 
  
  Form_LoadProductView                                  			= TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : 
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean  
    Dim strCounterParameterName

    strCounterParameterName = Request.Form("PickerItem")
    strCounterParameterName = MID(strCounterParameterName,2) ' Remove the first char the MDM PICKER put a I    
    
    Session("CounterParameterName") = strCounterParameterName
    
    OK_Click = MDMPickerDialog.OK_Click(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : 
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION CANCEL_Click(EventArg) ' As Boolean  
    
    Session("CounterParameterName")         = ""
    
    CANCEL_Click = True
END FUNCTION

%>

