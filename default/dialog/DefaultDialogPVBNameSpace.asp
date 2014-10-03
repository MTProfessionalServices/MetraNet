 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultPVBMapping.asp$
' 
'  Copyright 1998-2003 by MetraTech Corporation
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
'  $Date: 5/11/00 12:00:08 PM$
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
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp"          -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->

<%

Form.Page.MaxRow                = CLng(mom_GetDictionary("PV_ROW_PER_PAGE"))
Form.RouteTo			              = mom_GetDictionary("WELCOME_DIALOG")
Form.Page.NoRecordUserMessage   = mom_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    Framework.AssertCourseCapability "Update Runtime Configuration", EventArg
	  ProductView.Clear  ' Set all the property of the service to empty or to the default value
	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

    ' Tell the product view object to behave like real MT Product View based on the data in the rowset
  ProductView.Properties.Flags            = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  If(ProductView.Properties.Load (0,"__SELECT_NAME_SPACE__",eMSIX_PROPERTIES_LOAD_FLAG_LOAD_SQL_SELECT+eMSIX_PROPERTIES_LOAD_FLAG_INIT_FROM_ROWSET,mom_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH")))Then
      
      ' Select the properties I want to print in the PV Browser   Order
    	ProductView.Properties.ClearSelection
                                 
      ProductView.Properties("nm_space").Selected 			    = 1
      ProductView.Properties("tx_desc").Selected 			      = 2
      ProductView.Properties("tx_typ_space").Selected 			= 3
      
      
      ProductView("nm_space").Caption           = mom_GetDictionary("TEXT_ADD_NAME_SPACE_NAME_SPACE")
      ProductView("tx_desc").Caption            = mom_GetDictionary("TEXT_ADD_NAME_SPACE_DESCRIPTION")
      ProductView("tx_typ_space").Caption       = mom_GetDictionary("TEXT_ADD_NAME_SPACE_TYPE")
      
      Form_LoadProductView  = TRUE
  End If    
        
END FUNCTION



' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_DisplayHeaderCell
' PARAMETERS:
' DESCRIPTION: I implement this event so i can customize the 2 columns which
'              are is the turn down column! We do not want it so I make it small...
'              For the other colunms I call the inherited event!
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION orm_DisplayHeaderCell(EventArg) ' As Boolean
    
    Select Case Form.Grid.Col
        Case 2
            EventArg.HTMLRendered = EventArg.HTMLRendered 
            Form_DisplayHeaderCell= TRUE
        
        Case Else        
            Form_DisplayHeaderCell  = inherited("Form_DisplayHeaderCell()")
    End Select    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_DisplayCell
' PARAMETERS    :  EventArg
' DESCRIPTION   :  
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION form_DisplayCell(EventArg) ' As Boolean

    Select Case Form.Grid.Col
        Case 2        
            Form_DisplayCell      = TRUE ' Cancel the turn down            
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
    strEndOfPageHTMLCode = "<br>"
    
    ' Need to pass in the current subscribers login and namespace
    'strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<A HRef='" & mom_GetDictionary("UPDATE_NAME_SPACE_DIALOG") & "'><img src='" & mom_GetImagesPath() &  "/add.gif' Border='0'></A>"
    
    strTmp = "<button  name='Add' Class='clsOkButton' OnClick='javascript:document.location.href=""[LINK]""'>[TEXT_ADD]</button>"
    strTmp = ProductView.Tools.PreProcess(strTmp,"LINK",mom_GetDictionary("UPDATE_NAME_SPACE_DIALOG"))
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp

    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>

