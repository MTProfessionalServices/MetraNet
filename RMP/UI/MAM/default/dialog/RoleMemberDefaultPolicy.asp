<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
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
'  Created by: K.Boucher
' 
'  $Date: 5/11/00 12:00:08 PM$
'  $Author: $
'  $Revision: 1$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : PayerSetup.asp
' DESCRIPTION : 
' 
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.Version = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.Page.MaxRow  = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PUBLIC FUNCTION Form_Initialize(EventArg) ' As Boolean
  Form.Grid.FilterMode = TRUE
  Form("RoleName") = request.QueryString("RoleName")
  Form("id") = request.QueryString("id")
  Set Session("Role") = FrameWork.Policy.GetRoleByID(FrameWork.SessionContext, Form("id"))
  Form_Initialize = TRUE
END FUNCTION
		
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION     :  Form_LoadProductView
' PARAMETERS   :
' DESCRIPTION  : 
' RETURNS      :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
  Dim objRole
  
  Form_LoadProductView = FALSE
	
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW 
  
	mdm_GetDictionary().add "ROLE_MEMBER_SETUP_TITLE", Form("RoleName") & " Default Security Owners"

 ' Get members on role as rowset
 ' additional '1' parameter (DEFAULT_POLICY) to GetMembersAsRowset method means that we want to get default policies
  Set ProductView.Properties.RowSet = Session("Role").GetMembersAsRowset(FrameWork.SessionContext, 1)
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet

  ProductView.Properties.ClearSelection    
 
 ' Select the properties I want to print in the PV Browser   Order
 ' ProductView.Properties.SelectAll 	
  ProductView.Properties("displayname").Selected = 1
	
	ProductView.Properties("displayname").Caption = mam_GetDictionary("TEXT_USER")
			
  ProductView.Properties("displayname").Sorted = MTSORT_ORDER_ASCENDING
  Set Form.Grid.FilterProperty = ProductView.Properties("displayname") ' Set the property on which to apply the filter  
  
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
    
        Case 2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the
				Case 3
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='" & Form.Grid.CellClass & "'>"
            If UCase(ProductView.Properties("nm_space")) <> "AUTH" Then
	  					HTML_LINK_EDIT = HTML_LINK_EDIT & mam_GetNameIDLink(ProductView.Properties("DISPLAYNAME"), ProductView.Properties("id_acc"), Empty, ProductView.Properties("c_folder"))
            Else
  						HTML_LINK_EDIT = HTML_LINK_EDIT & ProductView.Properties("DISPLAYNAME") & " <span class=""clsNavy"">(" & mam_GetDictionary("TEXT_SYSTEM_FOLDER") & ")</span>"
            End If
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"
						EventArg.HTMLRendered = HTML_LINK_EDIT						
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
    ' Add Members 
    strEndOfPageHTMLCode = "<br><div align='center'>"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonMedium' name=""Back"" onclick=""window.location.href='" & "RoleMemberSetup.asp?id=" & Session("Role").id & "&RoleName=" & server.URLEncode(Session("Role").name) & "'"">" & mam_GetDictionary("TEXT_BACK") & "</button>"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</div>"
        
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>

