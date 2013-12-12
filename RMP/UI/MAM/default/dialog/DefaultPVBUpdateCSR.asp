<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
<% 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2005 by MetraTech Corporation
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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' MetraTech Dialog Manager Framework ASP Dialog Template
' 
' DIALOG	:
' DESCRIPTION	:
' AUTHOR	:
' VERSION	:
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.ServiceMsixdefFileName 	    = mam_GetAccountCreationMsixdefFileNameForSystemAccount()
Form.Page.MaxRow                  =  CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.RouteTo			                =  mam_GetDictionary("WELCOME_DIALOG")
Form.Page.NoRecordUserMessage     =  mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_Initialize
' PARAMETERS	:
' DESCRIPTION 	:
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean   

	ProductView.Clear  ' Set all the property of the service to empty or to the default value
        
  ' Select the properties I want to print in the PV Browser and the order
  ProductView.Properties.ClearSelection
  
  ProductView.Properties("_AccountId").Selected 			  = 1
  ProductView.Properties("UserName").Selected 			    = 2                                                                                                                                                                                                                                                        
  ProductView.Properties("firstname").Selected 			    = 3                                                                                                                                                                                                                                                        
  ProductView.Properties("lastname").Selected 			    = 4                                                                                                                                                                                                                                                        
  ProductView.Properties("EMail").Selected 		          = 5
  ProductView.Properties("AccountStatus").Selected 			= 6

  Set Session("CSRs")                 = ProductView  
  ProductView.RenderLocalizationMode  = TRUE ' We want all the enum type value to be localized while the HTML Rendering Process      
  Form.ShowExportIcon                 = TRUE
	Form_Initialize                     = TRUE
	
END FUNCTION


PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMAMFinder
  
  Form_LoadProductView          = FALSE

  ProductView.Properties.Flags  = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW ' Special case for Account because there is no product view The product view here initialized as a service there converted into a product view! This ABSOLUTLY MT UNDOCUMENTED!
  
  Set objMAMFinder              = New CMAMFinder
  
  'Pre-populate filter
  Call objMAMFinder.CreateFilter(true)
  objMAMFinder.NameSpaceType    = CSR_NAME_SPACE_TYPE
  objMAMFinder.MaxNumberOfRows  = 0 ' Return all the CSR Available
  
  If Not FrameWork.SecurityContext.IsSuperUser() Then
    objMAMFinder.AddFilter MAM_ACCOUNT_CREATION_ACCOUNT_TYPE_PROPERTY, MT_OPERATOR_TYPE_EQUAL , MAM_ACCOUNT_CREATION_ACCOUNT_TYPE_CSR
  End If
  
  If(objMAMFinder.Find(mam_GetGMTEndOfTheDayFormatted()))Then
      
      If(objMAMFinder.Rowset.RecordCount)Then
      
          Set ProductView.Properties.Rowset = objMAMFinder.Rowset
          Form_LoadProductView = TRUE
      Else
          Form_LoadProductView = FALSE
      End If      
  End If
  
	ProductView.Properties("UserName").Sorted = MTSORT_ORDER_ASCENDING

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_DisplayCell
' PARAMETERS	:
' DESCRIPTION 	: I implement this event so i can customize the 1 col which
'                 is the action column, where i put my link!
' RETURNS		: Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim strSelectorHTMLCode
    
    Select Case Form.Grid.Col
    
        'Case 1
        
         ' strSelectorHTMLCode   = "<A Name='Edit[USERNAME]' HRef='" & mam_GetDictionary("UPDATE_CSR_DIALOG") & "?AccountId=[ACCOUNTID]'><img src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif' Border='0'></A>"

         ' If FrameWork.CheckCoarseCapability("Manage CSR Auth") Then
				'	  strSelectorHTMLCode   = strSelectorHTMLCode & "&nbsp;&nbsp;<A Name='Security[USERNAME]' HRef='" & mam_GetDictionary("MANAGE_SECURITY_RELOAD_DIALOG") & "&NextPage=" & mam_GetDictionary("FIND_CSR_DIALOG") & "&Mode=CSR_ACTIVE_POLICY&AccountId=[ACCOUNTID]'><img alt='" & mam_GetDictionary("TEXT_MANAGE_SECURITY_HINT") & "' src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/security.gif' Border='0'></A>"
        '  End If
          
        '  strSelectorHTMLCode   = PreProcess(strSelectorHTMLCode,Array("ACCOUNTID",ProductView.Properties.RowSet.Value("_AccountId"),"USERNAME",ProductView.Properties.RowSet.Value("UserName")))
          
        '  EventArg.HTMLRendered = EventArg.HTMLRendered & "<td  class='" & Form.Grid.CellClass & "' width=40>" & strSelectorHTMLCode & "</td>"          
        '  Form_DisplayCell      = TRUE
        'Case 2
        '  mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the 
        '  Form_DisplayCell      = TRUE            
        Case Else
          Form_DisplayCell =  Inherited("Form_DisplayCell(EventArg)") ' Call the default implementation
    End Select    
   
END FUNCTION


%>
