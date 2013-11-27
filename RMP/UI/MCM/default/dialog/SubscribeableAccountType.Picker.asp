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
'  Created by: Kevin A. Boucher
' 
'  $Date: 5/11/00 12:00:08 PM$
'  $Author: $
'  $Revision: 1$
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

    Form_Initialize = MDMPickerDialog.Initialize(EventArg)

    If(UCase(Request.QueryString("ProxyMode"))="TRUE")Then
    
       MDMPickerDialog.NextPage = "Proxy.ProductOffering.asp"   ' Proxy Page
       MDMPickerDialog.Parameters = "POID|" & Request.QueryString("ID") 
    End If    
    
    Form("IDColumnName") = "ID"
    Form.Modal = TRUE
    
    'Form("SelectedIDs").Add "1", 1
    
END FUNCTION
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :  EventArg
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog

  Form_LoadProductView = FALSE

  ProductView.Properties.Flags  = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW ' Tell the product view object to behave like real MT Product View based on the data in the rowset!  
  Set objMTProductCatalog       = GetProductCatalogObject
  
  Dim rowset
  Set rowset = ExecuteSQL("select * from t_account_types_proto") 
  Set ProductView.Properties.RowSet = rowset
  
  ProductView.Properties.ClearSelection         ' Select the properties I want to print in the PV Browser   Order  
  ProductView.Properties("nm_name").Selected    = 1
  ProductView.Properties("nm_desc").Selected    = 2
  
  ProductView.Properties("nm_name").Caption     = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption     = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
    
  ProductView.Properties("nm_name").Sorted      = MTSORT_ORDER_ASCENDING ' Set the default sorted property
    
  mdm_SetMultiColumnFilteringMode TRUE 
  

  
  Form_LoadProductView                          = TRUE ' Must return trueto display any result.
END FUNCTION
    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : 
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean
    OK_Click = MDMPickerDialog.OK_Click(EventArg)
END FUNCTION   

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  inheritedForm_DisplayEndOfPage
' PARAMETERS    :  EventArg
' DESCRIPTION   :  Override end of table to place add button
' RETURNS       :  Return TRUE if ok else FALSE
PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    
    ' We do not call the inherited event because we have to add the hidden field PickerIDs    
    EventArg.HTMLRendered = "<INPUT Type='Hidden' Name='PickerIDs' Value=''></TABLE><BR><CENTER>" & vbNewLine
	If ProductView.Properties.Rowset.RecordCount > 0 Then
      EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON Name='OK' Class='clsOKButton' OnClick='OK_Click();'>" & FrameWork.GetDictionary("TEXT_OK") & "</BUTTON>&nbsp;&nbsp;&nbsp;" & vbNewLine
	End if
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON Name='CANCEL' Class='clsOKButton' OnClick='CANCEL_Click();'>" & FrameWork.GetDictionary("TEXT_CANCEL") & "</BUTTON></center>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</center>" & vbNewLine    
    MDMPickerDialog.GenerateHTMLEndOfPage EventArg
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</FORM>" & vbNewLine
    
    
    If(COMObject.Configuration.DebugMode)Then ' If in debug mode display the selection
    
       EventArg.HTMLRendered = EventArg.HTMLRendered & "<hr size=1>" & Replace(Form("SelectedIDs").ToString(),vbNewline,"<br>") & "<br>"
    End If    
    Form_DisplayEndOfPage = TRUE
END FUNCTION

' PROTOTYPE
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : ExecuteSQL
' PARAMETERS  : strSQL
' DESCRIPTION : Run SQL statement
' RETURNS     : Rowset
PUBLIC FUNCTION ExecuteSQL(strSQL)
  Dim objRowSet
  
  On Error Resume Next
  
  Set objRowSet = Nothing
  Set objRowSet = Server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  
  objRowSet.init("queries\audit") 'dummy
  objRowSet.SetQueryString(strSQL)
  objRowSet.Execute()

  On Error Goto 0
  
  Set ExecuteSQL = objRowSet
END FUNCTION
%>

