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
<%

Form.Page.MaxRow                = CLng(mom_GetDictionary("PV_ROW_PER_PAGE"))
Form.RouteTo			              = mom_GetDictionary("WELCOME_DIALOG")
Form.Page.NoRecordUserMessage   = mom_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

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

    ' Tell the product view object to behave like real MT Product View based on the data in the rowset
  ProductView.Properties.Flags            = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  If(ProductView.Properties.Load (0,"__GET_PRESENTATION_NAME_SPACE_LIST_MOM__",eMSIX_PROPERTIES_LOAD_FLAG_LOAD_SQL_SELECT+eMSIX_PROPERTIES_LOAD_FLAG_INIT_FROM_ROWSET,mom_GetDictionary("SQL_QUERY_STRING_RELATIVE_PATH")))Then
      
      ' Select the properties I want to print in the PV Browser   Order
    	ProductView.Properties.ClearSelection
                                 
      ProductView("nm_space").Selected 			    = 1      
      ProductView("tx_typ_space").Selected 			= 2
      ProductView("tx_desc").Selected 			    = 3
      
      ProductView("nm_space").Caption           = mom_GetDictionary("TEXT_ADD_NAME_SPACE_NAME_SPACE")
      ProductView("tx_desc").Caption            = mom_GetDictionary("TEXT_ADD_NAME_SPACE_DESCRIPTION")
      ProductView("tx_typ_space").Caption       = mom_GetDictionary("TEXT_ADD_NAME_SPACE_TYPE")
      
      Form_LoadProductView  = TRUE
  End If
END FUNCTION


CONST HTML_LINK_EDIT = "<td class='[CLASS]'width=20><A HRef='[ASP_PAGE]?NameSpace=[NAME_SPACE]'><img Alt='[ALT]' src='[IMAGE]' Border='0'></A></td>"

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_DisplayCell
' PARAMETERS    :  EventArg
' DESCRIPTION   :  
' RETURNS       :  Return TRUE if ok else FALSE
PRIVATE FUNCTION form_DisplayCell(EventArg) ' As Boolean
    Dim objPP

    Select Case Form.Grid.Col
        Case 1        
            Set objPP = mdm_CreateObject(CPreProcessor)
            
            objPP.Add "IMAGE"       , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/view.gif"
            objPP.Add "ASP_PAGE"    , mom_GetDictionary("REPORT_DIALOG")
            objPP.Add "ALT"         , mom_GetDictionary("TEXT_EDIT")
            objPP.Add "NAME_SPACE"  , ProductView("nm_space")
            objPP.Add "CLASS"       , Form.Grid.CellClass
            EventArg.HTMLRendered   = objPP.Process(HTML_LINK_EDIT)
                
            Form_DisplayCell      = TRUE ' Cancel the turn down                
        Case 2        
            EventArg.HTMLRendered = "<td class='" & Form.Grid.CellClass & "' width='1'></td>"
            Form_DisplayCell      = TRUE ' Cancel the turn down            
        Case Else
            Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select    
END FUNCTION

%>

