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
Form.ServiceMsixdefFileName 	= mam_GetAccountCreationMsixdefFileName()

Form.Page.MaxRow                = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.RouteTo			              = mam_GetDictionary("WELCOME_DIALOG")
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_Initialize
' PARAMETERS    :  EventArg
' DESCRIPTION   :
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

	ProductView.Clear  ' Set all the property of the service to empty or to the default value
        
  ' Select the properties I want to print in the PV Browser   Order
	ProductView.Properties.ClearSelection
  ProductView.Properties("ContactType").Selected 			  = 1
  ProductView.Properties("lastname").Selected 			    = 2
  ProductView.Properties("middleinitial").Selected 			= 3  
	ProductView.Properties("firstname").Selected 	        = 4
  ProductView.Properties("address1").Selected 	        = 5
  ProductView.Properties("City").Selected 	            = 6
  ProductView.Properties("state").Selected 	            = 7
  ProductView.Properties("zip").Selected 	              = 8
  ProductView.Properties("country").Selected 	          = 9
  ProductView.Properties("email").Selected 	            = 10
    
	Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_LoadProductView
' PARAMETERS    :  EventArg
' DESCRIPTION   : 
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW ' AccountCreation has no product view no we load first the service that say to the object : you are a product view

    Dim objMAMFinder
    Set objMAMFinder = New CMAMFinder
    
    'Pre-populate filter
    Call objMAMFinder.CreateFilter(true)
    
    objMAMFinder.AddFilter MAM_ACCOUNT_CREATION_ACCOUNT_ID_PROPERTY , MT_OPERATOR_TYPE_DEFAULT, CLNG(MAM().Subscriber(MAM_ACCOUNT_CREATION_ACCOUNT_ID_PROPERTY).Value)
    
    objMAMFinder.AccountTypes = "'" & Session("SubscriberYAAC").AccountType & "'" 'format: "'CORESUBSCRIBER', 'GSMSERVICEACCOUNT'"
    
    objMAMFinder.ContactType = Empty ' Not filter on contact type

    If objMAMFinder.Find(mam_GetHierarchyTime()) Then
    
        ' Clone the Subscriber(S) rowset and filter only the rows that deals with the selected subscriber...
        Set ProductView.Properties.RowSet = objMAMFinder.RowSet
        
        ' Store the rowset in the session to pass it to the sub dialog.
        Set Session(MAM_SESSION_SUBSCRIBER_CONTACTS_ROWSET) = ProductView.Properties.RowSet
        Form_LoadProductView = TRUE
    End If
    
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_DisplayHeaderCell
' PARAMETERS:
' DESCRIPTION: I implement this event so i can customize the 2 columns which
'              are is the turn down column! We do not want it so I make it small...
'              For the other colunms I call the inherited event!
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayHeaderCell(EventArg) ' As Boolean
    
    Select Case Form.Grid.Col
'        Case 2
 '           EventArg.HTMLRendered = EventArg.HTMLRendered 
  '          Form_DisplayHeaderCell= TRUE
        
        Case Else        
            Form_DisplayHeaderCell  = inherited("Form_DisplayHeaderCell()")
    End Select    
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
        
            ' Get the MSIXProperty object
            EventArg.HTMLRendered = Empty        
        
            ' We do not allow to edit the none account type...
            If(ProductView("ContactType")<>ProductView("ContactType").EnumType("None"))Then
            
                strSelectorHTMLCode = "<A HRef='"& mam_GetDictionary("ADD_CONTACT_DIALOG")  & "?UIUpDateMode=TRUE&ContactType=" & ProductView("ContactType") & "'><img src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>"
            End If
            
            strSelectorHTMLCode = strSelectorHTMLCode & "&nbsp;&nbsp;&nbsp;"
             
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<td  class='" & Form.Grid.CellClass & "' >" & strSelectorHTMLCode & "</td>"
            
            Form_DisplayCell = TRUE
            
'        Case 2        
 '           EventArg.HTMLRendered = Empty        
  '          EventArg.HTMLRendered = EventArg.HTMLRendered ' & "<td width=1></td>"
   '         Form_DisplayCell      = TRUE
            
        Case Else        
            ' Call the default implementation
            Form_DisplayCell =  Inherited("Form_DisplayCell()")
    End Select    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  inheritedForm_DisplayEndOfPage
' PARAMETERS:  EventArg
' DESCRIPTION:  Override end of table to place add button
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    dim strEndOfPageHTMLCode
    
    ' Call the inherited event so we close the ProductVIew Browser as it should be
    ' Becare full this function is setting     EventArg.HTMLRendered
    Inherited("Form_DisplayEndOfPage()")
    
    '  add some code at the end of the product view UI
        
    ' Place Add Account Mapping button at bottom of page  
    strEndOfPageHTMLCode = "<br>"
  
    ' If the number of contact is less that the number of contact type -1 we can add another one
    ' We have to do -1 because we do not count the value none.    
    If(ProductView.Properties.Rowset.RecordCount < ProductView("ContactType").EnumType.Entries.Count-1)Then
    
      ' Need to pass in the current subscribers login and namespace
      'strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<A HRef='" & mam_GetDictionary("ADD_CONTACT_DIALOG") & "'><img src='" & mam_GetImagesPath() &  "/add.gif' Border='0'></A>"
      'strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<br>" & vbNewLine
      strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<center><BUTTON class='clsButtonSmall' Name='Add' OnCLick=""javascript:document.location.href='" & mam_GetDictionary("ADD_CONTACT_DIALOG") & "'"">" & mam_GetDictionary("TEXT_ADD") & "</BUTTON></center>"
    End If

    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION

PRIVATE FUNCTION Form_Terminate(EventArg) ' As Boolean

       Set Session(MAM_SESSION_SUBSCRIBER_CONTACTS_ROWSET)  = Nothing
END FUNCTION       

%>

