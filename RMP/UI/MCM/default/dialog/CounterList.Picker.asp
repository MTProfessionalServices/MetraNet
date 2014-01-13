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
'  $Date: 5/17/00 12:00:08 PM$
'  $Author: $
'  $Revision: 1$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : DefaultDialogAddNameSpace.asp
' DESCRIPTION : Note that this dialog hit the SQL Server directly through MTSQLRowset Object and some query file.
'               We do not use MT Service or MT Product View. The Rowset is viewed as a product view.
'
'
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
  Form_Initialize = MDMPickerDialog.Initialize (EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog  

  Form_LoadProductView    = FALSE  
  Set objMTProductCatalog = GetProductCatalogObject
  
  Set ProductView.Properties.RowSet = objMTProductCatalog.FindCountersAsRowset()
      
  ' Select the properties I want to print in the PV Browser   Order
  ProductView.Properties.ClearSelection    
  ProductView.Properties("Name").Selected 			      = 1
  ProductView.Properties("id_prop").Selected 	        = 2
  ProductView.Properties("Description").selected      = 3
  ProductView.Properties("Formula").selected          = 4
  
  ProductView.Properties("Name").Sorted               = MTSORT_ORDER_ASCENDING
  
  Set Form.Grid.FilterProperty                        = ProductView.Properties("Name") ' Set the property on which to apply the filter  
  'ProductView.Properties("n_name").Caption           = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
   
  Form_LoadProductView                                = TRUE  
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

    dim strEndOfPageHTMLCode
    
    ' We do not call the inherited event because we have to add the hidden field PickerIDs    
    EventArg.HTMLRendered = "<INPUT Type='Hidden' Name='PickerIDs' Value=''></TABLE><BR><CENTER>" & vbNewLine

    EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON Name='OK' Class='clsOKButton' OnClick='OK_Click();'>" & FrameWork.GetDictionary("TEXT_OK") & "</BUTTON>&nbsp;&nbsp;&nbsp;" & vbNewLine	  
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON Name='CANCEL' Class='clsOKButton' OnClick='CANCEL_Click();'>" & FrameWork.GetDictionary("TEXT_CANCEL") & "</BUTTON></center>" & vbNewLine
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</center>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</FORM>" & vbNewLine
    
    MDMPickerDialog.GenerateHTMLEndOfPage EventArg
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    If(COMObject.Configuration.DebugMode)Then ' If in debug mode display the selection
    
       EventArg.HTMLRendered = EventArg.HTMLRendered & "<hr size=1>" & Replace(Form("SelectedIDs").ToString(),vbNewline,"<br>") & "<br>"
    End If    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>
