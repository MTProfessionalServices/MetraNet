<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
 <%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: OwnedAccounts.asp$
' 
'  Copyright 1998,2004 by MetraTech Corporation
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
'  Created by: K.Boucher
' 
'  $Date: 11/10/04 12:00:08 PM$
'  $Author: $
'  $Revision: 1$
'
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.Version = MDM_VERSION  
Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")
Form.Page.MaxRow  = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

session("CANCEL_ROUTETO") = mam_GetDictionary("SYSTEM_USER_OWNED_ACCOUNTS_DIALOG")

mdm_PVBrowserMain ' Invoke the mdm framework

PUBLIC FUNCTION Form_Initialize(EventArg) ' As Boolean
  Form.Grid.FilterMode = TRUE
  Form_Initialize = TRUE
END FUNCTION
		
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION     :  Form_LoadProductView
' PARAMETERS   :
' DESCRIPTION  : 
' RETURNS      :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
On Error Resume Next
  Form_LoadProductView = FALSE
	
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW 
  
	mdm_GetDictionary().add "OWNER_TITLE", mam_GetFieldIDFromAccountID(mam_GetSystemUser().AccountID)
		
  ' Get Ownership manager and list of owned acounts as rowset - based on the time in the UserHierarchy
  Dim mgr
  Set mgr = mam_GetSystemUser().GetOwnershipMgr()
  Set ProductView.Properties.RowSet = mgr.GetOwnedAccountsAsRowset(mam_GetSystemUserHierarchyTime())
  CheckAndWriteError
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet

  ProductView.Properties.ClearSelection    
 
 	' Select the properties I want to print in the PV Browser   Order
	'	ProductView.Properties.SelectAll
  ' {NL}id_owner   {NL}id_owned   {NL}id_relation_type   {NL}n_percent   {NL}hierarchyname   {NL}vt_start   {NL}vt_end   {NL}RelationType     id_relation_type
  ProductView.Properties("hierarchyname").Selected = 1
  ProductView.Properties("n_percent").Selected = 2
  ProductView.Properties("RelationType").Selected = 3
  ProductView.Properties("VT_Start").Selected = 4
  ProductView.Properties("VT_End").Selected   = 5
  
	ProductView.Properties("id_owner").Caption = mam_GetDictionary("TEXT_ID_OWNER")
  ProductView.Properties("id_owned").Caption = mam_GetDictionary("TEXT_ID_OWNED")
  ProductView.Properties("n_percent").Caption = mam_GetDictionary("TEXT_PERCENT_OWNERSHIP")
  ProductView.Properties("hierarchyname").Caption = mam_GetDictionary("TEXT_OWNED_HIERARCHYNAME")
  ProductView.Properties("VT_Start").Caption = mam_GetDictionary("TEXT_EFFECTIVE_START_DATE")  
  ProductView.Properties("VT_End").Caption   = mam_GetDictionary("TEXT_EFFECTIVE_END_DATE")		
  ProductView.Properties("RelationType").Caption = mam_GetDictionary("TEXT_OWNED_RELATION_TYPE")
    		
  ProductView.Properties("hierarchyname").Sorted = MTSORT_ORDER_ASCENDING
  mdm_SetMultiColumnFilteringMode TRUE
  Set Form.Grid.FilterProperty = ProductView.Properties("hierarchyname") ' Set the property on which to apply the filter    

  Form_LoadProductView = TRUE
  
END FUNCTION

    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : 
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean

    OK_Click = TRUE
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Form_DisplayCell
' PARAMETERS :
' DESCRIPTION :
' RETURNS    : 
PUBLIC FUNCTION Form_DisplayCell(EventArg) ' As Boolean   
    Dim m_objPP, HTML_LINK_EDIT
		Dim strHTML
    Dim strMsgBox
		  
    Select Case Form.Grid.Col
    
         Case 1
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='32'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<A HRef='" & mam_GetDictionary("OWNED_UPDATE_DIALOG") & "?Update=TRUE&id=" &  ProductView.Properties("id_owned") 
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "&Percentage=" &  ProductView.Properties("n_percent")
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "&Relationship=" &  ProductView.Properties("id_relation_type")
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "&OldStartDate=" &  ProductView.Properties("VT_Start")
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "&OldEndDate=" & ProductView.Properties("VT_End")
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "'><img src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>"						

' 				  	strMsgBox = mam_GetDictionary("TEXT_WOULD_YOU_LIKE_TO_REMOVE") & " " & server.HTMLEncode(Trim(ProductView.Properties("hierarchyname"))) & " " & mam_GetDictionary("TEXT_FROM") & " " & Server.HTMLEncode(mam_GetSystemUser().AccountName) & "?" 
'			  		HTML_LINK_EDIT = HTML_LINK_EDIT & "<A href='Javascript:msgBox("""
'	          HTML_LINK_EDIT = HTML_LINK_EDIT & strMsgBox
'	          HTML_LINK_EDIT = HTML_LINK_EDIT & """,""" 
'		    		HTML_LINK_EDIT = HTML_LINK_EDIT & mam_GetDictionary("OWNED_DELETE_DIALOG") & "?id=" &  ProductView.Properties("id_owned")
'						HTML_LINK_EDIT = HTML_LINK_EDIT  & "&StartDate=" &  ProductView.Properties("VT_Start")
'						HTML_LINK_EDIT = HTML_LINK_EDIT  & "&EndDate=" & ProductView.Properties("VT_End")            
'	          HTML_LINK_EDIT = HTML_LINK_EDIT & """);'>"
'	          HTML_LINK_EDIT = HTML_LINK_EDIT &  "<img src='" & mam_GetImagesPath() &  "/delete.gif' Border='0'></A>"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
						
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass
           
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE
        Case 2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the 
        
				Case 3
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='" & Form.Grid.CellClass & "'>"

            'Dim objYAAC
            'Set objYAAC = FrameWork.AccountCatalog.GetAccount(CLng(ProductView.Properties("id_owner")), mam_GetSystemUserHierarchyTime())
            
						HTML_LINK_EDIT = HTML_LINK_EDIT & mam_GetNameIDLink(Empty, ProductView.Properties("id_owned"), ProductView.Properties("hierarchyname"), Empty) 'objYAAC.IsFolder)
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"
						EventArg.HTMLRendered = HTML_LINK_EDIT						
						Form_DisplayCell = TRUE
							    	
        case 6
            EventArg.HTMLRendered = "<td class=" & Form.Grid.CellClass & ">" & mam_GetDisplayEndDate(ProductView.Properties("VT_Start")) & "</td>"
            Form_DisplayCell = TRUE                
        case 7
            EventArg.HTMLRendered = "<td class=" & Form.Grid.CellClass & ">" & mam_GetDisplayEndDate(ProductView.Properties("VT_End")) & "</td>"
            Form_DisplayCell = TRUE                
            
        Case Else        
            Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select
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
    
    '  add some code at the end of the product view UI
    ' ADD OWNED BUTTON
    strEndOfPageHTMLCode = "<br><div align='center'>"
'    If ProductView.Properties.RowSet.RecordCount > 0 Then
'      strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonLarge' name=""DELETEOWNED"" onclick=""window.location.href='" & "OwnedDeleteBatch.asp" & "?MDMReload=TRUE" & "'"">" & "Delete All Owned Accounts" & "</button>&nbsp;&nbsp;&nbsp;"
'    End If
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonLarge' name=""ADDOWNED"" onclick=""window.location.href='" & mam_GetDictionary("OWNED_ADD_DIALOG") & "?MDMReload=TRUE" & "'"">" & mam_GetDictionary("TEXT_ADD_OWNED_ACCOUNTS") & "</button>&nbsp;&nbsp;&nbsp;"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</div><br>"
        
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>

