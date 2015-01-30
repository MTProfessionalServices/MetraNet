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
' CLASS       : ManageSecurity.asp
' DESCRIPTION : View roles and capabilites on a subscriber account
'               CSR account, folder, or default policy of a folder 
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


mdm_Main ' invoke the mdm framework
	 
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Initialize
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     :
PUBLIC FUNCTION Form_Initialize(EventArg) ' As Boolean
  Dim YAAC
  Dim objAuthAccount
  
  Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")
    
  If Len(Request.QueryString("NextPage")) Then 
    Form.RouteTo = Request.QueryString("NextPage")
	End If
  
  '------------------------------------------------------------------------------------------------
	' This dialog has 4 modes:  
	'      1.  SUBSCRIBER_OR_FOLDER_ACTIVE_POLICY - Subscriber / folder account  (roles and capabilities) on active policy 
	'      2.  FOLDER_DEFAULT_POLICY - CSR account (roles and capabilities) on active policy - AccountID = csrid
	'      3.  FOLDER_DEFAULT_POLICY - Default Policy on Folder (roles only) - DefaultPolicy = "TRUE" 
  '      4.  FOLDER_DEFAULT_POLICY - Default Policy on the CSR Folder (roles only) - DefaultPolicy = "TRUE", CSRDefault = "TRUE"
	'------------------------------------------------------------------------------------------------
  Select Case UCase(Request.QueryString("MODE"))
    Case "SUBSCRIBER_OR_FOLDER_ACTIVE_POLICY"
      Session("CSRDefault") = "FALSE"    
    	Session("IsCSR") = "FALSE"
      Session("DefaultPolicy") = "FALSE" 
      Session("MODE") = "SUBSCRIBER_OR_FOLDER_ACTIVE_POLICY"
  	  Session("SecurityAccountID") = mam_GetSubscriberAccountID()
		  mdm_GetDictionary().add "USER_TITLE", mam_GetFieldIDFromAccountID(mam_GetSubscriberAccountID())

    Case "FOLDER_DEFAULT_POLICY"    
      Session("CSRDefault") = "FALSE"    
    	Session("IsCSR") = "FALSE"
      Session("DefaultPolicy") = "TRUE"     
      Session("MODE") = "FOLDER_DEFAULT_POLICY"        
  	  Session("SecurityAccountID") = mam_GetSubscriberAccountID()
		  mdm_GetDictionary().add "USER_TITLE", "Default"

    Case "CSR_ACTIVE_POLICY"
      Session("CSRDefault") = "FALSE"
  	  Session("IsCSR") = "TRUE"
      Session("DefaultPolicy") = "FALSE"   
      Session("MODE") = "CSR_ACTIVE_POLICY"    
      Session("SecurityAccountID") = Request.QueryString("AccountId")
      If (Len(Session("SecurityAccountID")) = 0) Then
        Session("SecurityAccountID") = mam_GetSystemUser().AccountID
      End IF    
  	  mdm_GetDictionary().add "USER_TITLE", GetUserNameFromAccountID(Session("SecurityAccountID"))

    Case "CSR_DEFAULT_POLICY"
      Session("CSRDefault") = "TRUE"
  	  Session("IsCSR") = "TRUE"
      Session("DefaultPolicy") = "TRUE"       
      Session("MODE") = "CSR_DEFAULT_POLICY"  
	    Set YAAC = FrameWork.Policy.GetCSRFolder(FrameWork.SessionContext)
      Session("SecurityAccountID") = YAAC.AccountID          
 		  mdm_GetDictionary().add "USER_TITLE", mam_GetDictionary("TEXT_CSR_DEFAULT_POLICY")

  End Select

  On error resume next
	Set	objAuthAccount = FrameWork.Policy.GetAccountByID(FrameWork.SessionContext,CLng(Session("SecurityAccountID")), mam_ConvertToSysDate(mam_GetHierarchyTime()))
  If err.number <> 0 then
    Call WriteUnableToLoad(mam_GetDictionary("TEXT_UNABLE_TO_MANAGE_ACCOUNT"),  mam_GetDictionary("SUBSCRIBER_FOUND"))
  End If
  On error goto 0 
        	
	' Determine if we should use the default policy or the active policy
	If UCase(Session("DefaultPolicy")) = "TRUE" Then
	  Set Form("AccountPolicy") = objAuthAccount.GetDefaultPolicy(FrameWork.SessionContext)
	Else
	  Set Form("AccountPolicy") = objAuthAccount.GetActivePolicy(FrameWork.SessionContext)
  End If

	Form.Grids.Add "AccountRolesGrid"
  Form.Grids.Add "AccountCapabilitiesGrid"
	
  Form_Initialize = Load_Grids(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Load_Grids
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     :
PRIVATE FUNCTION Load_Grids(EventArg)
  Load_Grids = FALSE
	
	Session("IsAccount") = "TRUE" 'this is used to determine if we are working on an account or a role
  Session("LastRolePage") = mam_GetDictionary("MANAGE_SECURITY_RELOAD_DIALOG") & "&MODE=" & Session("MODE") & "&AccountID=" & Session("SecurityAccountID") & "&NextPage=" & Form.RouteTo	

  Service.Properties.Add "AccountRolesGridEmpty", "String",  256, FALSE, "" 
  Service.Properties.Add "AccountCapabilitiesGridEmpty", "String",  256, FALSE, "" 
  
	' don't show capabilities for default policy
 	mdm_GetDictionary.Add "ShowDefaultPolicy" , Not Session("DefaultPolicy")

  ' Set page to come back to after add role dynamically, because it is different if we are default policy or not
	mdm_GetDictionary.Add "DYNAMIC_MANAGE_SECURITY_DIALOG", mam_GetDictionary("MANAGE_SECURITY_RELOAD_DIALOG") & "&Parameters=NextPage|" & Form.RouteTo & ";AccountID|" & Session("SecurityAccountID") & ";DefaultPolicy|" & Session("DefaultPolicy")	& ";MODE|" & Session("MODE")	
	
	'Load Role Grid	
	Set Form.Grids("AccountRolesGrid").RowSet = Form("AccountPolicy").GetRolesAsRowset() 
	
  If Form.Grids("AccountRolesGrid").Rowset.RecordCount = 0 Then
		Service.Properties("AccountRolesGridEmpty") =  mam_GetDictionary("TEXT_NO_ROLES")
	  Form.Grids("AccountRolesGrid").Visible = FALSE
	Else
	  Form.Grids("AccountRolesGrid").Properties.ClearSelection
	'	Form.Grids("AccountRolesGrid").Properties.SelectAll
	  Form.Grids("AccountRolesGrid").Properties("id_role").Selected = 1
    Form.Grids("AccountRolesGrid").Properties("tx_name").Selected = 2
		Form.Grids("AccountRolesGrid").Properties("tx_desc").Selected = 3
	
 	  Form.Grids("AccountRolesGrid").Properties("id_role").Caption = mam_GetDictionary("TEXT_ACTION")
	  Form.Grids("AccountRolesGrid").Properties("tx_name").Caption = mam_GetDictionary("TEXT_ROLE_NAME")
	  Form.Grids("AccountRolesGrid").Properties("tx_desc").Caption = mam_GetDictionary("TEXT_ROLE_DESCRIPTION")
	
	  Form.Grids("AccountRolesGrid").Properties("tx_name").Sorted = MTSORT_ORDER_ASCENDING
		Form.Grids("AccountRolesGrid").Width = "100%"
	  Form.Grids("AccountRolesGrid").Visible = TRUE
  End If 

	
	'Load Capability Grid
	Set Form.Grids("AccountCapabilitiesGrid").RowSet = Form("AccountPolicy").GetCapabilitiesAsRowset()

  If Form.Grids("AccountCapabilitiesGrid").Rowset.RecordCount = 0 Then
		Service.Properties("AccountCapabilitiesGridEmpty") = mam_GetDictionary("TEXT_NO_CAPABILITIES")
	  Form.Grids("AccountCapabilitiesGrid").Visible = FALSE	
	Else
	  Form.Grids("AccountCapabilitiesGrid").Properties.ClearSelection
	 '	Form.Grids("AccountCapabilitiesGrid").Properties.SelectAll	
	  Form.Grids("AccountCapabilitiesGrid").Properties("id_cap_type").Selected = 1
	  Form.Grids("AccountCapabilitiesGrid").Properties("tx_desc").Selected = 2
	  Form.Grids("AccountCapabilitiesGrid").Properties("umbrella_sensitive").Selected = 3    
  		
	  Form.Grids("AccountCapabilitiesGrid").Properties("id_cap_type").Caption = mam_GetDictionary("TEXT_ACTION")		
	  Form.Grids("AccountCapabilitiesGrid").Properties("tx_name").Caption = mam_GetDictionary("TEXT_CAPABILITY_NAME")
	  Form.Grids("AccountCapabilitiesGrid").Properties("tx_desc").Caption = mam_GetDictionary("TEXT_CAPABILITY_DESCRIPTION")
	  Form.Grids("AccountCapabilitiesGrid").Properties("umbrella_sensitive").Caption = mam_GetDictionary("TEXT_MANAGE_ACCOUNT_HIERARCHIES")	
  
	  Form.Grids("AccountCapabilitiesGrid").Properties("tx_name").Sorted = MTSORT_ORDER_ASCENDING	
		Form.Grids("AccountCapabilitiesGrid").Width = "100%"
		Form.Grids("AccountCapabilitiesGrid").Visible = TRUE
	End If
	
	Load_Grids = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_Refresh
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     :
PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean
	Form_Refresh = Load_Grids(EventArg)
END FUNCTION		

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : AccountRolesGrid_DisplayCell
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : 
PRIVATE FUNCTION AccountRolesGrid_DisplayCell(EventArg) ' As Boolean
    Dim m_objPP, HTML_LINK_EDIT
    Dim strMsgBox
		
		Select Case lcase(EventArg.Grid.SelectedProperty.Name) 
         Case "id_role" 'Action Icons
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td nowrap class='[CLASS]' Width='40px'>"
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "<a href='" & mam_GetDictionary("ROLE_SETUP_DIALOG") & "?MDMReload=True&ReadOnly=TRUE&id=" &  EventArg.Grid.SelectedProperty.Value & "&DefaultPolicy=" & Session("DefaultPolicy") & "&RoleName=" & server.URLEncode(EventArg.Grid.Rowset.Value("tx_name")) & "'>" 
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<img border='0' src='/mam/default/localized/en-us/images/view.gif'></a>" 
						
			' popup javascript message to ensure delete operation
			'SECENG	ESR-4039: MetraCare - Update the Javascript encode method used to mitigate MetraCare XSS bugs inside of javascript (ESR for 27233) (Post-PB)
            'strMsgBox = mam_GetDictionary("TEXT_WOULD_YOU_LIKE_TO_REMOVE") & " " & server.HTMLEncode(Trim(EventArg.Grid.Properties("tx_name"))) & " " & mam_GetDictionary("TEXT_FROM") & " " & CStr(GetUserNameFromAccountID(Session("SecurityAccountID"))) & "?" 						
            strMsgBox = mam_GetDictionary("TEXT_WOULD_YOU_LIKE_TO_REMOVE") & " " & SafeForHtml(Trim(EventArg.Grid.Properties("tx_name"))) & " " & mam_GetDictionary("TEXT_FROM") & " " & CStr(GetUserNameFromAccountID(Session("SecurityAccountID"))) & "?" 						

						HTML_LINK_EDIT = HTML_LINK_EDIT & "<A href='Javascript:msgBox("""
            HTML_LINK_EDIT = HTML_LINK_EDIT & strMsgBox
            HTML_LINK_EDIT = HTML_LINK_EDIT & """,""" 
						HTML_LINK_EDIT = HTML_LINK_EDIT & mam_GetDictionary("ROLE_CAPABILITY_DELETE_DIALOG") & "?AccountID=" & Session("SecurityAccountID") & "&RoleID=" & EventArg.Grid.SelectedProperty.Value & "&DefaultPolicy=" & Session("DefaultPolicy")
            HTML_LINK_EDIT = HTML_LINK_EDIT & """);'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT &  "<img Name='Role" & EventArg.Grid.SelectedProperty.Value & ".Delete' src='" & mam_GetImagesPath() &  "/delete.gif' Border='0'></A>"
						
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS", EventArg.Grid.CellClass
           
            EventArg.HTMLRendered = m_objPP.Process(HTML_LINK_EDIT)
            AccountRolesGrid_DisplayCell = TRUE							
         Case "tx_name"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='250px'>"
			'SECENG: CORE-4768 CLONE - MSOL 26810 Metracare: Reflected cross-site scripting [/mam/default/dialog/RoleAdd.asp in 'name' parameter] (Post-PB)
			'Added HTML encoding
			HTML_LINK_EDIT = HTML_LINK_EDIT  & SafeForHtml(EventArg.Grid.SelectedProperty.Value)
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS", EventArg.Grid.CellClass
           
            EventArg.HTMLRendered = m_objPP.Process(HTML_LINK_EDIT)
            AccountRolesGrid_DisplayCell = TRUE
        Case Else        
            AccountRolesGrid_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
    End Select
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : AccountCapabilitiesGrid_DisplayCell
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : 
PRIVATE FUNCTION AccountCapabilitiesGrid_DisplayCell(EventArg) ' As Boolean
    Dim m_objPP, HTML_LINK_EDIT
    Dim strDialog
		Dim strMsgBox

		Select Case lcase(EventArg.Grid.SelectedProperty.Name) 
   		 Case "id_cap_type" ' Action Icons

            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td nowrap class='[CLASS]' Width='40px'>"

					  strDialog = mam_GetDictionaryDefault(Trim(EventArg.Grid.Properties("tx_editor")), mam_GetDictionary("DEFAULT_CAPABILITY_EDITOR_DIALOG"))						
						
            ' check to see if we have any atomic capabilities - if yes then show edit pencil
  				  If CLng(EventArg.Grid.Properties("num_atomic")) > 0 Then
	  				   HTML_LINK_EDIT = HTML_LINK_EDIT  & "<A href='" & strDialog & "?MDMRefresh=TRUE&Update=TRUE&MODE=" & Session("MODE") & "&CSRDefault=" & Session("CSRDefault") & "&CapabilityID=" &  EventArg.Grid.SelectedProperty.Value & "'><img src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>"						
						Else	 
               HTML_LINK_EDIT = HTML_LINK_EDIT  & "&nbsp;&nbsp;&nbsp;&nbsp;"
            End If
						 
			' popup javascript message to ensure delete operation
			'SECENG	ESR-4039: MetraCare - Update the Javascript encode method used to mitigate MetraCare XSS bugs inside of javascript (ESR for 27233) (Post-PB)
            'strMsgBox = mam_GetDictionary("TEXT_WOULD_YOU_LIKE_TO_REMOVE") & " " & server.HTMLEncode(Trim(EventArg.Grid.Properties("tx_name"))) & " " & mam_GetDictionary("TEXT_FROM") & " " & CStr(GetUserNameFromAccountID(Session("SecurityAccountID"))) & "?" 
            strMsgBox = mam_GetDictionary("TEXT_WOULD_YOU_LIKE_TO_REMOVE") & " " & SafeForHtml(Trim(EventArg.Grid.Properties("tx_name"))) & " " & mam_GetDictionary("TEXT_FROM") & " " & CStr(GetUserNameFromAccountID(Session("SecurityAccountID"))) & "?"

						HTML_LINK_EDIT = HTML_LINK_EDIT & "<A href='Javascript:msgBox("""
            HTML_LINK_EDIT = HTML_LINK_EDIT & strMsgBox
            HTML_LINK_EDIT = HTML_LINK_EDIT & """,""" 
						HTML_LINK_EDIT = HTML_LINK_EDIT & mam_GetDictionary("ROLE_CAPABILITY_DELETE_DIALOG") & "?AccountID=" & Session("SecurityAccountID") & "&CapabilityID=" & EventArg.Grid.SelectedProperty.Value 						
            HTML_LINK_EDIT = HTML_LINK_EDIT & """);'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT &  "<img name='Capability" & EventArg.Grid.SelectedProperty.Value & ".Delete' src='" & mam_GetImagesPath() &  "/delete.gif' Border='0'></A>"

            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS", EventArg.Grid.CellClass
           
            EventArg.HTMLRendered = m_objPP.Process(HTML_LINK_EDIT)
            AccountCapabilitiesGrid_DisplayCell = TRUE					
            
          Case "tx_desc"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]'><b>" & Replace(SafeForHtml(EventArg.Grid.Properties("tx_desc")), ":", ":</b><br>")
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS", EventArg.Grid.CellClass
           
            EventArg.HTMLRendered = m_objPP.Process(HTML_LINK_EDIT)
            AccountCapabilitiesGrid_DisplayCell = TRUE					      

          Case "umbrella_sensitive"

            If UCase(EventArg.Grid.Properties("umbrella_sensitive")) = "N" then
              EventArg.HTMLRendered     =  "<td class=" & EventArg.Grid.CellClass & " align='center'>--&nbsp;</td>"
            Else
              EventArg.HTMLRendered     =  "<td class=" & EventArg.Grid.CellClass & " align='center'><img src='../localized/en-us/images/check.gif'></td>"
            End If
            AccountCapabilitiesGrid_DisplayCell = TRUE	
            													
        Case Else       
            AccountCapabilitiesGrid_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
    End Select
END FUNCTION


%>

