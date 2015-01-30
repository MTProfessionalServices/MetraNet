 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: IntervalManagement.RunHistory.List.asp$
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
'  Created by: Kevin A. Boucher
' 
'  $Date: 11/14/2002 12:13:29 PM$
'  $Author: Rudi Perkins$
'  $Revision: 3$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%
Form.ErrorHandler = false
Form.ShowExportIcon = TRUE

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:     Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
Framework.AssertCourseCapability "Manage EOP Adapters", EventArg
    Form.Modal = TRUE

    ProductView.Clear 
   	ProductView.Properties.ClearSelection
    ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW

    Form("BillingGroupID") = Request.QueryString("BillingGroupID")
    Form("IntervalID") = Request.QueryString("IntervalID")
    Form("Title") = Request.QueryString("Title")
    
    Dim title
    'Set the screen title
    If Len(Form("Title"))>0 Then
      title = Form("Title") 
    Else
      title = mom_GetDictionary("TEXT_Locate_Payer") 
    End If

    mdm_GetDictionary().Add "BILLING_GROUPS_FIND_PAYER_TITLE", title
    
	  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:     Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
  
  Dim objUSM, objMTFilter
  Set objUSM = mom_GetUsageServerClientObject()
  Set objMTFilter = Server.CreateObject("MTSQLRowset.MTDataFilter.1")
  
  
' TODO:  Create filter to be applied when query is run  
'    Dim objMTFilter
'    If mdm_UIValue("mdmPVBFilter") <> "" Then
'      Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter.1")
'      objMTFilter.Add "Name", OPERATOR_TYPE_LIKE, "%" + mdm_UIValue("mdmPVBFilter") + "%"
'      Set ProductView.Properties.RowSet = objMTProductCatalog.GetGroupSubscriptionsAsRowset(mam_GetHierarchyDate(), objMTFilter)
'    Else
'      Set ProductView.Properties.RowSet = objMTProductCatalog.GetGroupSubscriptionsAsRowset(mam_GetHierarchyDate())
'    End If
  

  Set ProductView.Properties.RowSet = objUSM.GetBillingGroupMembersRowset(CLng(Form("BillingGroupID")), (objMTFilter))
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet

  ' Check to see if items have been filtered and inform the user
  If ProductView.Properties.RowSet.RecordCount >= 1000 Then
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", TRUE
  ELSE
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", FALSE      
  End If
  
  ProductView.Properties.ClearSelection                    
  'ProductView.Properties.SelectAll
  dim i
  i=1
  ProductView.Properties("DisplayName").Selected = i : i=i+1
  ProductView.Properties("AccountID").Selected =   i : i=i+1  
  ProductView.Properties("UserName").Selected =    i : i=i+1
  ProductView.Properties("NameSpace").Selected =   i : i=i+1

  ProductView.Properties("DisplayName").Caption = mom_GetDictionary("TEXT_Account")
  ProductView.Properties("AccountID").Caption 	= mom_GetDictionary("TEXT_Account_ID")
  ProductView.Properties("UserName").Caption    = mom_GetDictionary("TEXT_User_Name")
  ProductView.Properties("NameSpace").Caption    = mom_GetDictionary("TEXT_Namespace") 
 
  mdm_SetMultiColumnFilteringMode TRUE  
  ProductView.LoadJavaScriptCode
  
  Form_LoadProductView = TRUE
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_DisplayCell
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:     Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean
  
  Select Case Form.Grid.Col
  
    Case 2
        Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
      
		Case else
			Form_DisplayCell = Inherited("Form_DisplayCell(EventArg)")
      
	End Select

END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:    Form_DisplayEndOfPage
' PARAMETERS:  EventArg
' DESCRIPTION: Override end of table to place add button
' RETURNS:     Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    Dim html
    html = html & "</table><div align=center><BR><BR>"
    'html = html & "<button  name='REFRESH' Class='clsOkButton' onclick='window.location=window.location'>Refresh</button>"
    html = html & "<button  name='CLOSE' Class='clsOkButton' onclick='window.close();'>" & mom_GetDictionary("TEXT_CLOSE") & "</button>"
    html = html & "</FORM></BODY></HTML>"
    
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & REPLACE(html,"[LOCALIZED_IMAGE_PATH]",mom_GetLocalizeImagePath())
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION




%>
