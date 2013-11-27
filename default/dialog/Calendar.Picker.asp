<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
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
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' CLASS       : Calendar.Picker.asp
' DESCRIPTION : Allow to select a Calendar and execute a specific asp file if the user click on one.
' 
' PICKER INTERFACE : A Picker ASP File Interface is based on the QueryString Name/Value.
'                    NextPage : The url to execute if a user click a one item. This url must accept a querystring
'                    parameter ID. ID will contains this id of the Item.
'
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmPicker.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo        = mam_GetDictionary("WELCOME_DIALOG") ' This Should Change Some Time
Form.Page.MaxRow    = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    Form_Initialize = MDMPickerDialog.Initialize (EventArg)
END FUNCTION
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :  EventArg
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog, objMTFilter, objParamTable

  Form_LoadProductView = FALSE
  
  Set objMTProductCatalog       = GetProductCatalogObject
  
  Set ProductView.Properties.RowSet = objMTProductCatalog.GetCalendarsAsRowset
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  
  ProductView.Properties.ClearSelection          ' Select the properties I want to print in the PV Browser   Order  
  'ProductView.Properties.SelectAll
  
  ProductView.Properties("nm_name").Selected     	= 1
  ProductView.Properties("nm_desc").Selected    	= 2
  'ProductView.Properties("nm_filename").Selected  = 3
  
  ProductView.Properties("nm_name").Sorted       	= MTSORT_ORDER_ASCENDING ' Set the default sorted property
  
  Set Form.Grid.FilterProperty          	        = ProductView.Properties("nm_name") ' Set the property on which to apply the filter  
  
  ' Localize this
  ProductView.Properties("nm_desc").Caption      	= mam_GetDictionary("TEXT_CALENDAR_DESCRIPTION")
  ProductView.Properties("nm_name").Caption 		  = mam_GetDictionary("TEXT_CALENDAR_NAME")
  'ProductView.Properties("nm_filename").Caption   = mam_GetDictionary("TEXT_CALENDAR_SOURCE_FILE")
  
  Form_LoadProductView                           = TRUE ' Must return true to display any result.
END FUNCTION
    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Override to MDM OK_Click
' PARAMETERS		:
' DESCRIPTION 		: Sets an extra session variable so we know we wanted to copy rules.
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean
    OK_Click = MDMPickerDialog.OK_Click(EventArg)
END FUNCTION   

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  inheritedForm_DisplayEndOfPage
' PARAMETERS    :  EventArg
' DESCRIPTION   :  Override end of table to place add button
' RETURNS       :  Return TRUE if ok else FALSE
PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    ' We do not call the inherited event because we have to add the hidden field PickerID    
    EventArg.HTMLRendered = "<INPUT Type='Hidden' Name='PickerID' Value=''></TABLE><BR><CENTER>" & vbNewLine
	If ProductView.Properties.Rowset.RecordCount > 0 Then
    	EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON Name='OK' Class='clsOKButton' OnClick='OK_Click();'>OK</BUTTON>&nbsp;&nbsp;&nbsp;" & vbNewLine
	End if
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON Name='CANCEL' Class='clsOKButton' OnClick='CANCEL_Click();'>Cancel</BUTTON></center>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</center>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</FORM>" & vbNewLine
    
    If(COMObject.Configuration.DebugMode)Then ' If in debug mode display the selection
       EventArg.HTMLRendered = EventArg.HTMLRendered & "<hr size=1>" & Replace(Form("SelectedIDs").ToString(),vbNewline,"<br>") & "<br>"
    End If    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>
