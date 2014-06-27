<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: ManageRoles.asp$
' 
'  Copyright 1998,2000,2001 by MetraTech Corporation
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
'  $Date: 12/21/2001 12:00:08 PM$
'  $Author: $
'  $Revision: 1$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : ManageRoles.asp
' DESCRIPTION : View roles in the system for editing
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
Form.Version = MDM_VERSION     ' Set the dialog version
Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")
Form.Page.MaxRow  = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

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
  Form_LoadProductView = FALSE

  Session("IsAccount") = "FALSE" 'this is used to determine if we are working on an account or a role

  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW 
	
  ' Get roles as rowset
	Set ProductView.Properties.RowSet = FrameWork.Policy.GetAllRolesAsRowset(FrameWork.SessionContext) 
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet

  ProductView.Properties.ClearSelection    
 ' Select the properties I want to print in the PV Browser   Order
 ' ProductView.Properties.SelectAll 
  'ProductView.Properties("tx_name").Selected = 1
	ProductView.Properties("tx_desc").Selected = 1
  ProductView.Properties("csr_assignable").Selected = 2
  ProductView.Properties("subscriber_assignable").Selected = 3
	ProductView.Properties("id_role").Selected = 4
  	
  'ProductView.Properties("tx_name").Caption = mam_GetDictionary("TEXT_ROLE_NAME")
  ProductView.Properties("tx_desc").Caption = mam_GetDictionary("TEXT_ROLE_NAME") & " and Description"
  ProductView.Properties("csr_assignable").Caption = mam_GetDictionary("TEXT_CSR_ASSIGNABLE")
  ProductView.Properties("subscriber_assignable").Caption = mam_GetDictionary("TEXT_SUBSCRIBER_ASSIGNABLE")
  ProductView.Properties("id_role").Caption = mam_GetDictionary("TEXT_ACTION")
  				
  ProductView.Properties("tx_desc").Sorted = MTSORT_ORDER_ASCENDING
  Set Form.Grid.FilterProperty = ProductView.Properties("tx_desc") ' Set the property on which to apply the filter  
  
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
		Dim strHTML, strMsgBox
    
		' Handle first 2 columns
    Select Case Form.Grid.Col
         Case 1  ' Action
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td nowrap class='[CLASS]' Width='70'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<A Name='EditRoleID[ROLE_ID]' href='" & mam_GetDictionary("ROLE_ADD_DIALOG") & "?Update=TRUE&id=[ROLE_ID]&RoleName=" & server.URLEncode(ProductView.Properties("tx_name")) & "'><img alt='" & mam_GetDictionary("TEXT_EDIT") & "' src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>&nbsp;&nbsp;"						
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<A Name='MembersRoldeID[ROLE_ID]' href='" & mam_GetDictionary("ROLE_MEMBER_SETUP_DIALOG") & "?MDMReload=TRUE&id=" &  ProductView.Properties("id_role") & "&RoleName=" & server.URLEncode(ProductView.Properties("tx_name")) & "'><img alt='" & mam_GetDictionary("TEXT_MEMBERS") & "' src='" & mam_GetImagesPath() &  "/group.gif' Border='0'></A>&nbsp;&nbsp;"						

						' popup javascript message to ensure delete operation 
					'SECENG ESR-4039: MetraCare - Update the Javascript encode method used to mitigate MetraCare XSS bugs inside of javascript (ESR for 27233) (Post-PB)
	   				'strMsgBox = mam_GetDictionary("TEXT_WOULD_YOU_LIKE_TO_REMOVE") & " " & server.HTMLEncode(Trim(Service.Properties("tx_name"))) & "?"
	   				strMsgBox = mam_GetDictionary("TEXT_WOULD_YOU_LIKE_TO_REMOVE") & " " & SafeForHtml(Trim(Service.Properties("tx_name"))) & "?"
			  		HTML_LINK_EDIT = HTML_LINK_EDIT & "<A href='Javascript:msgBox("""
	          HTML_LINK_EDIT = HTML_LINK_EDIT & strMsgBox
	          HTML_LINK_EDIT = HTML_LINK_EDIT & """,""" 
				  	HTML_LINK_EDIT = HTML_LINK_EDIT & "RoleDelete.asp" & "?RoleID=[ROLE_ID]&RoleName=" & server.URLEncode(ProductView.Properties("tx_name"))
	          HTML_LINK_EDIT = HTML_LINK_EDIT & """);'>"
	          HTML_LINK_EDIT = HTML_LINK_EDIT &  "<img alt='" & mam_GetDictionary("TEXT_DELETE") & "' src='" & mam_GetImagesPath() &  "/delete.gif' Border='0'></A>"

            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
              
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass
            m_objPP.Add "ROLE_ID"     , ProductView.Properties("id_role")            
           
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)

            Form_DisplayCell          = TRUE
						Exit Function
        Case 2 ' TurnDown
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the 
						Exit Function
		End Select
		
		' Rest of selected columns by column name
		Select Case lcase(Form.Grid.SelectedProperty.Name) 
        Case "csr_assignable"
            If UCase(ProductView.Properties("csr_assignable")) = "N" then
              EventArg.HTMLRendered     =  "<td class=" & Form.Grid.CellClass & " align='center'>--&nbsp;</td>"
            Else
              EventArg.HTMLRendered     =  "<td class=" & Form.Grid.CellClass & " align='center'><img src='../localized/en-us/images/check.gif' localized='True'></td>"
            End If
            Form_DisplayCell          = TRUE	     							
      
        Case "tx_desc"
            'HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='" & Form.Grid.CellClass & "'><b>" & Replace(ProductView.Properties.Rowset.Value("tx_desc"), ":", ":</b><br>")
			'SECENG: CORE-4768 CLONE - MSOL 26810 Metracare: Reflected cross-site scripting [/mam/default/dialog/RoleAdd.asp in 'name' parameter] (Post-PB)
			'Added HTML encoding
			HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='" & Form.Grid.CellClass & "'><b>" & SafeForHtml(ProductView.Properties.Rowset.Value("tx_name")) & "</b><br>" & SafeForHtml(ProductView.Properties.Rowset.Value("tx_desc"))
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"   
            EventArg.HTMLRendered =  HTML_LINK_EDIT
            Form_DisplayCell          = TRUE				        

        Case "subscriber_assignable"
            If UCase(ProductView.Properties("subscriber_assignable")) = "N" then
              EventArg.HTMLRendered     =  "<td class=" & Form.Grid.CellClass & " align='center'>--&nbsp;</td>"
            Else
              EventArg.HTMLRendered     =  "<td class=" & Form.Grid.CellClass & " align='center'><img src='../localized/en-us/images/check.gif' localized='True'></td>"
            End If            
            Form_DisplayCell          = TRUE					

         Case "id_role"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='16'>"
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "	 <button onclick=""location.href='" & mam_GetDictionary("ROLE_SETUP_DIALOG") & "?id=" &  ProductView.Properties("id_role") & "&RoleName=" & server.URLEncode(ProductView.Properties("tx_name")) & "';return false;"" name='EditCapabilities." & ProductView.Properties("id_role") & "' Class='clsButtonBlueMedium'>" & mam_GetDictionary("TEXT_KEYTERM_CAPABILITIES") & "</button>"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass
           
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE			
      				
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
    ' ADD GROUP 
    strEndOfPageHTMLCode = "<tr><td colspan=""6"" align=""center""><br>"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonMedium' name=""ADDROLE"" onclick=""window.location.href='" & mam_GetDictionary("ROLE_ADD_DIALOG") & "'; return false;"">" & mam_GetDictionary("TEXT_ADD_ROLE") & "</button>&nbsp;&nbsp;&nbsp;"
    strEndOfPageHTMLCode =  strEndOfPageHTMLCode & "</div>"
        
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    ' CORE-4906, include the button as an additional table row and concat *before* the EventArg.HTMLRendered so that the button is contained within the </FORM></BODY></HTML> on the page. When the button used to be below the </HTML> tag, the button would jump by a few pixels on click the first time in IE.
    EventArg.HTMLRendered =  strEndOfPageHTMLCode & "</td></tr>" & EventArg.HTMLRendered
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>

