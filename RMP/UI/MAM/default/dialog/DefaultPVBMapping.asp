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
'  Created by: Kevin A. Boucher
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
    
	ProductView.Clear  ' Set all the property of the service to empty or to the default value
  
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW ' Tell the ProductView object to behave like a ProductView
   
  Form_LoadProductView  = ProductView.Properties.Load (MAM().Subscriber("_AccountId"),"__GET_MAPPING_LIST__",eMSIX_PROPERTIES_LOAD_FLAG_LOAD_SQL_SELECT+eMSIX_PROPERTIES_LOAD_FLAG_INIT_FROM_ROWSET,mam_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH"))
  
  ' Select the properties I want to print in the PV Browser   Order
	ProductView.Properties.ClearSelection
  ProductView.Properties("nm_login").Selected 			    = 1
	ProductView.Properties("tx_desc").Selected 	          = 2
  
  ' Localize Headers
  ProductView.Properties("nm_login").Caption            = mam_GetDictionary("TEXT_ALIAS") 
	ProductView.Properties("tx_desc").Caption 	          = mam_GetDictionary("TEXT_EXTERNAL_SYSTEM")   
  
  ' Sort
  ProductView.Properties("nm_login").Sorted             = MTSORT_ORDER_DECENDING
    
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_DisplayCell
' PARAMETERS:  EventArg
' DESCRIPTION: I implement this event so i can customize the 1,2 columns which
'              are the action column and the turn down column (I do not want it), 
'              where i put my link! For the other colunms I call the inherited event!
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim strSelectorHTMLCode
    Dim strMsgBox
    
    Select Case Form.Grid.Col
    
        Case 1
        
            ' Action Icons
            ' Update Mapping
            strSelectorHTMLCode = "<A HRef='"& mam_GetDictionary("UPDATE_ACCOUNT_MAPPING_DIALOG")  &"?nm_login="  & server.URLEncode(Service.Properties.RowSet.Value("nm_login")) & "&nm_space=" & server.URLEncode(Service.Properties.RowSet.Value("nm_space")) & "'><img src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>"
            strSelectorHTMLCode = strSelectorHTMLCode & "&nbsp;&nbsp;&nbsp;"
   
            strMsgBox = Replace(mam_GetDictionary("TEXT_CONFIRM_DELETE_ACCOUNT_MAPPING"),"[MAPPING_NAME]",Service.Properties.RowSet.Value("nm_space"))
            strMsgBox = Replace(strMsgBox,"[LOGIN_NAME]",Service.Properties.RowSet.Value("nm_login"))
   
            ' Delete Mapping
             strSelectorHTMLCode = strSelectorHTMLCode & "<A href='Javascript:msgBox("""
             strSelectorHTMLCode = strSelectorHTMLCode & strMsgBox
             strSelectorHTMLCode = strSelectorHTMLCode & """,""" & mam_GetDictionary("DELETE_ACCOUNT_MAPPING_DIALOG") & "?nm_login="
             strSelectorHTMLCode = strSelectorHTMLCode &  server.URLEncode(ProductView.Properties.RowSet.Value("nm_login"))
             strSelectorHTMLCode = strSelectorHTMLCode &  "&nm_space=" & server.URLEncode(ProductView.Properties.RowSet.Value("nm_space")) & """);'>"
             strSelectorHTMLCode = strSelectorHTMLCode &  "<img src='" & mam_GetImagesPath() &  "/delete.gif' Border='0'></A>"
             
            ' Selector code
            EventArg.HTMLRendered = "<td  class='" & Form.Grid.CellClass & "' Width=50>" & strSelectorHTMLCode & "</td>"           
            Form_DisplayCell      = TRUE
            
        Case 2
        
            EventArg.HTMLRendered = "<td class='" & Form.Grid.CellClass & "'>&nbsp;</td>"
            Form_DisplayCell      = TRUE
            
        Case Else        
            
            Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select    
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  inheritedForm_DisplayEndOfPage
' PARAMETERS:  EventArg
' DESCRIPTION:  Override end of table to place add button
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    dim strEndOfPageHTMLCode, strTmp
    
    ' Call the inherited event so we close the ProductVIew Browser as it should be
    ' Becare full this function is setting     EventArg.HTMLRendered
    Inherited("Form_DisplayEndOfPage()")
    
    '  add some code at the end of the product view UI
        
    ' Place Add Account Mapping button at bottom of page  
    strEndOfPageHTMLCode = "<tr><td colspan=""4"" align=""center""><br>"
    
    ' Need to pass in the current subscribers login and namespace
    strTmp = "<center><button  name='Add' Class='clsOkButton' OnClick='javascript:document.location.href=""[LINK]""; return false;'>"&mam_GetDictionary("TEXT_ADD")&"</button></center>"
    strTmp = ProductView.Tools.PreProcess(strTmp,"LINK",mam_GetDictionary("ADD_ACCOUNT_MAPPING_DIALOG"))
        
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
    
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    ' CORE-4906, include the button as an additional table row and concat *before* the EventArg.HTMLRendered so that the button is contained within the </FORM></BODY></HTML> on the page. When the button used to be below the </HTML> tag, the button would jump by a few pixels on click the first time in IE.
    EventArg.HTMLRendered =  strEndOfPageHTMLCode & "</td></tr>" & EventArg.HTMLRendered
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>
