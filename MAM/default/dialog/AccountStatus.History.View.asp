<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
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
'  Created by: F.TORRES.
' 
'  $Date$
'  $Author$
'  $Revision$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
Form.Version                    = MDM_VERSION
Form.RouteTo			              = mam_GetDictionary("WELCOME_DIALOG")
Form.Page.MaxRow                = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    
	ProductView.Clear  			' Set all the property of the service to empty or to the default value
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW ' Tell the ProductView object to behave like a ProductView
   
	Set ProductView.Properties.Rowset = SubscriberYAAC().GetStateHistory()
	 
   ' Select the properties I want to print in the PV Browser   Order
 	ProductView.Properties.ClearSelection
  ProductView.Properties("vt_start").Selected 			    = 1
	ProductView.Properties("vt_end").Selected 	          = 2
	ProductView.Properties("status").Selected 	          = 3
	
  Service.Properties("status").SetPropertyType "ENUM", FrameWork.Dictionary.Item("ACCOUNT_CREATION_SERVICE_ENUM_TYPE_LOADING").Value , "AccountStatus"
	
  ' Localize Headers
  ProductView.Properties("vt_start").Caption            = mam_GetDictionary("TEXT_START_DATE")
	ProductView.Properties("vt_end").Caption 	            = mam_GetDictionary("TEXT_END_DATE")
	ProductView.Properties("status").Caption 	            = mam_GetDictionary("TEXT_STATUS")
	
  ' Sort
  ProductView.Properties("vt_start").Sorted = MTSORT_ORDER_DECENDING
	Form_LoadProductView                      = TRUE
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  inheritedForm_DisplayEndOfPage
' PARAMETERS :  EventArg
' DESCRIPTION:  Override end of table to place add button
' RETURNS    :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    dim strEndOfPageHTMLCode
    
    ' Call the inherited event so we close the ProductVIew Browser as it should be
    ' Becare full this function is setting     EventArg.HTMLRendered
    Inherited("Form_DisplayEndOfPage()")
    
    ' add some code at the end of the product view UI
    ' ADD GROUP 
    strEndOfPageHTMLCode = "<br><div align='center'>"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonSmall' name='CLOSE' onclick='window.close();'>" & mam_GetDictionary("TEXT_CLOSE") & "</button>"
    strEndOfPageHTMLCode =  strEndOfPageHTMLCode & "</div>"
        
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION

%>
