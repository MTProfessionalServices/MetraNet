 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: Adjustment.Type.Picker.asp$
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
'  $Date: 11/5/2002 3:24:10 PM$
'  $Author: Frederic Torres$
'  $Revision: 3$
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
<!-- #INCLUDE FILE="../lib/CMCMAdjustmentHelper.asp" -->
<%
Form.Version        = MDM_VERSION     
Form.ErrorHandler   = TRUE

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Form_Initialize = MDMPickerDialog.Initialize(EventArg)
    Form("MonoSelect")            = TRUE
    Form("IDColumnName")          = "ReasonCodeID"
    Form.Modal = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :  EventArg
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
   
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  Set ProductView.Properties.RowSet = FrameWork.AdjustmentCatalog.GetReasonCodesAsRowset()
  
  ProductView.Properties.SelectAll

  Dim i : i = 1
  
  ProductView.Properties.ClearSelection
  
  'ProductView.Properties("ReasonCodeName").Selected = i              : i=i+1
  ProductView.Properties("ReasonCodeDisplayName").Selected = i       : i=i+1  
  ProductView.Properties("ReasonCodeDescription").Selected = i       : i=i+1
 
  'ProductView.Properties("ReasonCodeName").Caption        = FrameWork.Dictionary().Item("TEXT_COLUMN_NAME").Value
  ProductView.Properties("ReasonCodeDisplayName").Caption = FrameWork.Dictionary().Item("TEXT_COLUMN_DISPLAY_NAME").Value
  ProductView.Properties("ReasonCodeDescription").Caption = FrameWork.Dictionary().Item("TEXT_COLUMN_DESCRIPTION").Value
 

  ProductView.Properties("ReasonCodeDisplayName").Sorted = MTSORT_ORDER_ASCENDING
  
'  ProductView.Properties.SelectALL
  
  Set Form.Grid.FilterProperty = ProductView.Properties("ReasonCodeDisplayName")
      
  Form_LoadProductView = TRUE ' Must Return TRUE To Render The Dialog  
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
