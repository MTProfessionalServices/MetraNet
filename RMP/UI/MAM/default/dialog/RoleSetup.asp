<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
 <%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
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
'  $Date$
'  $Author$
'  $Revision$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : RoleSetup.asp
' DESCRIPTION : View capabilities on role
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
Form.ErrorHandler=TRUE

mdm_PVBrowserMain ' invoke the mdm framework

PUBLIC FUNCTION Form_Initialize(EventArg) ' As Boolean
  Form.Grid.FilterMode = TRUE
 	Form("RoleName") =  request.QueryString("RoleName")
	Form("id") = request.QueryString("id") 
	Session("LastRolePage") = mam_GetDictionary("ROLE_SETUP_DIALOG") & "?RoleName=" & server.URLEncode(Form("RoleName")) & "&id=" & Form("id")
  mdm_GetDictionary().add "LAST_ROLE_PAGE", Session("LastRolePage") ' This is used in a error resolution roadmap link
	Form("ReadOnly") = request.QueryString("ReadOnly")	
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

  'SECENG: CORE-4768 CLONE - MSOL 26810 Metracare: Reflected cross-site scripting [/mam/default/dialog/RoleAdd.asp in 'name' parameter] (Post-PB)
  'Added HTML encoding
  If UCase(Form("ReadOnly")) = "TRUE" Then
  	mdm_GetDictionary().add "ROLE_SETUP_TITLE", mam_GetDictionary("TEXT_ROLE_SETUP_READONLY") & " " & SafeForHtml(Form("RoleName"))
  Else
  	mdm_GetDictionary().add "ROLE_SETUP_TITLE", mam_GetDictionary("TEXT_ROLE_SETUP") & " " & SafeForHtml(Form("RoleName"))
  End If
  
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW 
	
  ' Get capabilities on role as rowset
  set objRole = FrameWork.Policy.GetRoleByID(FrameWork.SessionContext, Form("id"))
	Set ProductView.Properties.RowSet = objRole.GetActivePolicy(FrameWork.SessionContext).GetCapabilitiesAsRowset()
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet

  ProductView.Properties.ClearSelection    

 ' Select the properties I want to print in the PV Browser   Order
 ' ProductView.Properties.SelectAll
'  ProductView.Properties("tx_name").Selected = 1
  ProductView.Properties("tx_desc").Selected = 1
  ProductView.Properties("tx_progid").Selected = 2
  ProductView.Properties("num_atomic").Selected = 3
	ProductView.Properties("umbrella_sensitive").Selected = 4
  	
  ProductView.Properties("tx_name").Caption = mam_GetDictionary("TEXT_CAPABILITY_NAME")
  ProductView.Properties("tx_desc").Caption = mam_GetDictionary("TEXT_CAPABILITY_DESCRIPTION")
  ProductView.Properties("tx_progid").Caption = mam_GetDictionary("TEXT_PROG_ID")
  ProductView.Properties("umbrella_sensitive").Caption = mam_GetDictionary("TEXT_REQUIRES_MANAGE_ACCOUNT_HIERARCHIES")
  	
	' Show parameters when we are in read only mode
	If UCase(Form("ReadOnly")) = "TRUE" Then
	  ProductView.Properties("num_atomic").Caption = "Parameters"
	Else
    ProductView.Properties("num_atomic").Caption = mam_GetDictionary("TEXT_NUMBER_OF_ATOMICS")
  End IF
				
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
		Dim strHTML
    Dim strDialog
		Dim strMsgBox
		Dim composite
		Dim atomic
					    
    Select Case Form.Grid.Col
         Case 1
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td nowrap class='[CLASS]' Width='32'>"

					  strDialog = mam_GetDictionaryDefault(Trim(ProductView.Properties("tx_editor")), mam_GetDictionary("DEFAULT_CAPABILITY_EDITOR_DIALOG"))						
						If UCase(Form("ReadOnly")) = "TRUE" Then
							' don't edit in read only mode
						Else
	            ' check to see if we have any atomic capabilities - if yes then show edit pencil
	  				  If CLng(ProductView.Properties("num_atomic")) > 0 Then
		  				   HTML_LINK_EDIT = HTML_LINK_EDIT  & "<A HRef='" & strDialog & "?MDMRefresh=TRUE&Update=TRUE&RoleID=" & Form("id") & "&CapabilityID=" &  ProductView.Properties("id_cap_type") & "'><img src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>"						
							Else	 
	               HTML_LINK_EDIT = HTML_LINK_EDIT  & "&nbsp;&nbsp;&nbsp;&nbsp;"
	            End If
							 
							' popup javascript message to ensure delete operation
							'SECENG	ESR-4039: MetraCare - Update the Javascript encode method used to mitigate MetraCare XSS bugs inside of javascript (ESR for 27233) (Post-PB)						
							'strMsgBox = mam_GetDictionary("TEXT_WOULD_YOU_LIKE_TO_REMOVE") & " " & server.HTMLEncode(Trim(Service.Properties("tx_name"))) & " " & mam_GetDictionary("TEXT_FROM") & " " & Server.HTMLEncode(Trim(Form("RoleName"))) & "?" 
							strMsgBox = mam_GetDictionary("TEXT_WOULD_YOU_LIKE_TO_REMOVE") & " " & SafeForHtml(Trim(Service.Properties("tx_name"))) & " " & mam_GetDictionary("TEXT_FROM") & " " & SafeForHtml(Trim(Form("RoleName"))) & "?" 
							HTML_LINK_EDIT = HTML_LINK_EDIT & "<A href='Javascript:msgBox("""
	            HTML_LINK_EDIT = HTML_LINK_EDIT & strMsgBox
	            HTML_LINK_EDIT = HTML_LINK_EDIT & """,""" 
							HTML_LINK_EDIT = HTML_LINK_EDIT & mam_GetDictionary("ROLE_CAPABILITY_DELETE_DIALOG") & "?RoleID=" & Form("id") & "&CapabilityID=" &  ProductView.Properties("id_cap_type") 
	            HTML_LINK_EDIT = HTML_LINK_EDIT & """);'>"
	            HTML_LINK_EDIT = HTML_LINK_EDIT &  "<img src='" & mam_GetImagesPath() &  "/delete.gif' Border='0'></A>"
						End If

            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"                 
					  Set m_objPP = mdm_CreateObject(CPreProcessor)
	          m_objPP.Add "CLASS"       , Form.Grid.CellClass
	           
	          EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
													
            Form_DisplayCell          = TRUE
        Case 2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the 
				Case 5 'num_atomic
				
				  ' If we are in read only mode then we take the time to display all the parameters
					If UCase(Form("ReadOnly")) = "TRUE" Then
           	
            On error resume next
            Form("AuthAccount") = FrameWork.Policy.GetAccountByID(FrameWork.SessionContext, Session("SecurityAccountID"), mam_ConvertToSysDate(mam_GetHierarchyTime()))
            If err.number <> 0 then
              Call WriteUnableToLoad(mam_GetDictionary("TEXT_UNABLE_TO_MANAGE_ACCOUNT"),  mam_GetDictionary("SUBSCRIBER_FOUND"))
            End If
            On error goto 0     
            
 	          Form("AccountPolicy") = Form("AuthAccount").GetActivePolicy(FrameWork.SessionContext)
						'Form("CompositeCapabilityType") = FrameWork.Policy.GetCapabilityTypeByID(CLng(ProductView.Properties("id_cap_type")))
          	'Form("CompositeCollection") = Form("AccountPolicy").GetCapabilitiesOfType(Form("CompositeCapabilityType").ID)
  	
        		Form("Role") = FrameWork.Policy.GetRoleByID(FrameWork.SessionContext, Form("id"))
	          Form("CompositeCapabilityType") = FrameWork.Policy.GetCapabilityTypeByID(CLng(ProductView.Properties("id_cap_type")))
            Form("CompositeCollection") = Form("Role").GetActivePolicy(FrameWork.SessionContext).GetCapabilitiesOfType(Form("CompositeCapabilityType").ID)
						    
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td nowrap class='[CLASS]'>"

						For Each composite in Form("CompositeCollection")
	         		For Each atomic in composite.AtomicCapabilities
          	    Select Case UCase(atomic.capabilityType.name)
								  Case "MTACCESSTYPECAPABILITY"
         	   				HTML_LINK_EDIT = HTML_LINK_EDIT & atomic.GetParameter() & "<br>"
          		 		Case "MTPATHCAPABILITY"
 									  HTML_LINK_EDIT = HTML_LINK_EDIT & atomic.GetParameter().Path & " - "
										Select Case atomic.GetParameter().WildCard
										  Case 0
											  HTML_LINK_EDIT = HTML_LINK_EDIT & mam_GetDictionary("TEXT_CURRENT_NODE") & "<br>"
											Case 1
											  HTML_LINK_EDIT = HTML_LINK_EDIT & mam_GetDictionary("TEXT_DIRECT_DESCENDANTS") & "<br>"
											Case 2
											  HTML_LINK_EDIT = HTML_LINK_EDIT & mam_GetDictionary("TEXT_ALL_DESCENDANTS") & "<br>"
										End Select	
						  	  Case "MTDECIMALCAPABILITY"	
      									HTML_LINK_EDIT = HTML_LINK_EDIT & atomic.GetParameter().Test & "&nbsp;" & atomic.GetParameter().Value & "<br>"					
          				Case "MTENUMTYPECAPABILITY"
      									HTML_LINK_EDIT = HTML_LINK_EDIT & atomic.GetParameter().Value  & " : "		
                  Case Else
	  							  HTML_LINK_EDIT = HTML_LINK_EDIT & atomic.capabilityType.name & "<br>"
						    End Select
							Next
						Next		
 					  HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"   
					  Set m_objPP = mdm_CreateObject(CPreProcessor)
	          m_objPP.Add "CLASS", Form.Grid.CellClass
	          EventArg.HTMLRendered = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell = TRUE
            
					Else
            Form_DisplayCell = Inherited("Form_DisplayCell()") ' Call the default implementation
					End If
				Case 6
          If UCase(ProductView.Properties("umbrella_sensitive")) = "N" then
              EventArg.HTMLRendered     =  "<td class=" & Form.Grid.CellClass & " align='center'>--&nbsp;</td>"
            Else
              EventArg.HTMLRendered     =  "<td class=" & Form.Grid.CellClass & " align='center'><img src='../localized/en-us/images/check.gif'></td>"
            End If
            Form_DisplayCell          = TRUE			        	
        Case Else        
            Form_DisplayCell = Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  inheritedForm_DisplayEndOfPage
' PARAMETERS :  EventArg
' DESCRIPTION:  Override end of table to place add button
' RETURNS    :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean
    Dim strEndOfPageHTMLCode
    
    ' Call the inherited event so we close the ProductVIew Browser as it should be
    ' Becare full this function is setting     EventArg.HTMLRendered
    Inherited("Form_DisplayEndOfPage()")
    
    '  add some code at the end of the product view UI
    ' ADD Capability 
    strEndOfPageHTMLCode = "<br><div align='center'>"
		If UCase(Form("ReadOnly")) = "TRUE" Then
      strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonMedium' name=""Back"" onclick=""window.location.href='" & mam_GetDictionary("MANAGE_SECURITY_RELOAD_DIALOG") & "&MODE=" & Session("MODE") & "&AccountID=" & Session("SecurityAccountID") & "&CSRDefault=" & Session("CSRDefault") & "'"">" & mam_GetDictionary("TEXT_BACK_SECURITY") & "</button>&nbsp;&nbsp;&nbsp;"		
		Else
      strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonLarge' name=""Back"" onclick=""window.location.href='" & mam_GetDictionary("MANAGE_ROLES_DIALOG") & "'"">" & mam_GetDictionary("TEXT_BACK_TO_MANAGE_ROLES") & "</button>&nbsp;&nbsp;&nbsp;"
      strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class='clsButtonLarge' name=""AddCapability"" onclick=""window.location.href='" & mam_GetDictionary("ROLE_ADD_CAPABILITY_DIALOG") & "?RoleID=" & Form("id") & "&NextPage=" & mam_GetDictionary("GOTO_CAPABILITY_EDITOR_DIALOG") & "&MonoSelect=TRUE&OptionalColumn=tx_editor&IDColumnName=id_cap_type" & "'"">" & mam_GetDictionary("TEXT_ROLE_ADD_CAPABILITY") & "</button>&nbsp;&nbsp;&nbsp;"
    End If
    strEndOfPageHTMLCode =  strEndOfPageHTMLCode & "</div>"		    
    
		' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>

