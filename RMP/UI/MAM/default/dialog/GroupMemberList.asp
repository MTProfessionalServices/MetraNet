<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
 <%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: GroupMemberList.asp$
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
'  $Date: 5/13/2002 3:45:26 PM$
'  $Author: Fabricio Pettena$
'  $Revision: 13$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : GroupSubscriptions.asp
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
Form.RouteTo = mam_GetDictionary("WELCOME_DIALOG")
Form.Page.MaxRow  = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PUBLIC FUNCTION Form_Initialize(EventArg) ' As Boolean
  Form.ShowExportIcon = TRUE ' Export
    
	if Len(Request.QueryString("id")) > 0 then
		Session("Group_id") = Clng(Request.QueryString("id"))
	end if

  Form.Grid.FilterMode = TRUE
  Form_Initialize = TRUE
END FUNCTION

PRIVATE FUNCTION ExecuteRemove(EventArg, objMTProductatalog, objGroupSub) ' As Boolean

	ExecuteRemove = FALSE
	' Handle the delete case
	if Request.QueryString("Action") = "REMOVE" then
		Dim acc_id
    Dim dt_start
    acc_id = 0
    dt_start = ""

		acc_id = CLng(Request.QueryString("id_acc"))
    if Len(Request.QueryString("dt_start")) then
      dt_start = CDate(Request.QueryString("dt_start"))
	  end if
    
  	On Error Resume Next
    if Len(dt_start) = 0 then
  		objGroupSub.DeleteMember acc_id
    else
      objGroupSub.DeleteMember acc_id, dt_start
    end if
		if err then
			EventArg.Error.Save Err
			Form_DisplayErrorMessage EventArg
			exit function
		end if
		On Error goto 0
	end if
	
	ExecuteRemove = TRUE
END FUNCTION		
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION     :  Form_LoadProductView
' PARAMETERS   :
' DESCRIPTION  : 
' RETURNS      :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
	
	Dim objMTProductCatalog, objGroupSub, objMembershipSlice, intSubscriptionID
  Form_LoadProductView = FALSE
	
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW 
			
  ' Get members rowset
	Set objMTProductCatalog = GetProductCatalogObject
	
	'For  we are using the GS name, but we have to change it to the id as soon as method is ready - TODO
	Set objGroupSub = objMTProductCatalog.GetGroupSubscriptionByID(Session("Group_id"))

	'Call function that handles removing accounts
	Form_LoadProductView = ExecuteRemove(EventArg, objMTProductCatalog, objGroupSub)

	Set objMembershipSlice = objGroupSub.MemberShip()
	Set ProductView.Properties.RowSet = objMembershipSlice.GroupMembersAsRowset
		
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet
	
  ProductView.Properties.ClearSelection
	'ProductView.Properties.SelectAll    
 	'Select the properties I want to print in the PV Browser   Order
 
  ProductView.Properties("acc_name").Selected = 1
	ProductView.Properties("vt_start").Selected = 2
	ProductView.Properties("vt_end").Selected = 3
'	ProductView.Properties("c_folder").Selected = 4

  ProductView.Properties("acc_name").Caption = mam_GetDictionary("TEXT_ACCOUNT_ID")
  ProductView.Properties("vt_start").Caption = mam_GetDictionary("TEXT_EFFECTIVE_START_DATE")
	ProductView.Properties("vt_end").Caption = mam_GetDictionary("TEXT_EFFECTIVE_END_DATE")
'  ProductView.Properties("c_folder").Caption = mam_GetDictionary("TEXT_IS_FOLDER")
	
	ProductView.Properties("acc_name").Sorted = MTSORT_ORDER_ASCENDING
  Set Form.Grid.FilterProperty = ProductView.Properties("acc_name") ' Set the property on which to apply the filter  
  
	' Handle the case when we come back from a screen that edits effective dates and the selected new date was overriden by the group subscription
	' or proudct offering effective date
	If Session("DateOverride") Then
		mam_ShowGuide(mam_GetDictionary("ROADMAP-OVERRIDEMEMBERSHIPDATE"))
		Session("DateOverride") = false
	Else
		response.write "<script language=""JavaScript"">parent.hideGuide();</script>"
	End If	
	
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
  
	Select Case Form.Grid.Col
		Case 1
			HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='16'>"
			If FrameWork.CheckCoarseCapability("Modify groupsub membership") Then
				HTML_LINK_EDIT = HTML_LINK_EDIT  & "<A HRef='" & mam_GetDictionary("GROUP_MEMBER_EDIT_DIALOG") & "?Action=EDIT&IsJoinMode=FALSE&id_group=" & Form("Group_id") & "&id_acc=" &  ProductView.Properties("id_acc") & "&start_date=" & ProductView.Properties("vt_start") &  "'><img src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>"
			Else
				HTML_LINK_EDIT = HTML_LINK_EDIT  & "&nbsp;"
			End If
			HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"     

			Set m_objPP = mdm_CreateObject(CPreProcessor)
			m_objPP.Add "CLASS"       , Form.Grid.CellClass

			EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
			Form_DisplayCell          = TRUE
			Exit Function						
		Case 2
			' How do I add the noturndown event here
			'mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
			HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='16'>"
			If FrameWork.CheckCoarseCapability("Modify groupsub membership") Then
				Dim displayName,strMsgBox
				' popup javascript message to ensure delete operation 
				'displayName = ProductView.Properties("acc_name") & " (" & ProductView.Properties("id_acc") & ")"
				
				strMsgBox = mam_GetDictionary("TEXT_WOULD_YOU_LIKE_TO_REMOVE") & " " & ProductView.Properties("id_acc") & " " & mam_GetDictionary("TEXT_FROM") & " " & mam_GetDictionary("TEXT_THIS") & " " & mam_GetDictionary("TEXT_KEYTERM_GROUP_SUBSCRIPTION") & "?"
		 		HTML_LINK_EDIT = HTML_LINK_EDIT & "<A href='Javascript:msgBox("""
	      HTML_LINK_EDIT = HTML_LINK_EDIT & strMsgBox
	      HTML_LINK_EDIT = HTML_LINK_EDIT & """,""" 
	  		HTML_LINK_EDIT = HTML_LINK_EDIT & mam_GetDictionary("GROUP_MEMBER_LIST_DIALOG") & "?Action=REMOVE&id_acc=" &  ProductView.Properties("id_acc") & "&dt_start=" & ProductView.Properties("vt_start")
	      HTML_LINK_EDIT = HTML_LINK_EDIT & """);'>"
	      HTML_LINK_EDIT = HTML_LINK_EDIT &  "<img src='" & mam_GetImagesPath() &  "/delete.gif' Border='0'></A>"
	      HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        			
				
			Else
				HTML_LINK_EDIT = HTML_LINK_EDIT  & "&nbsp;"
			End If
			HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"     

			Set m_objPP = mdm_CreateObject(CPreProcessor)
			m_objPP.Add "CLASS"       , Form.Grid.CellClass

			EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)

			Form_DisplayCell          = TRUE	
			Exit Function
  End Select						 
	Select Case lcase(Form.Grid.SelectedProperty.Name)
		Case "acc_name"
			HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='" & Form.Grid.CellClass & "'>"
			HTML_LINK_EDIT = HTML_LINK_EDIT & mam_GetNameIDLink(Empty, ProductView.Properties("id_acc"), ProductView.Properties("acc_name"), ProductView.Properties("c_folder"))
			HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"
			EventArg.HTMLRendered = HTML_LINK_EDIT						
			Form_DisplayCell = TRUE
    'Start: cr11006  
		Case "vt_start"
		    strHTML = mam_GetDisplayEndDate(ProductView.Properties("vt_start"))
				EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' nowrap>" & strHTML & "</td>"
				Form_DisplayCell = TRUE		
		Case "vt_end"
          HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' align='left' nowrap>"
				HTML_LINK_EDIT = HTML_LINK_EDIT  & mam_GetDisplayEndDate(ProductView.Properties("vt_end"))
          HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"
				
				Set m_objPP = mdm_CreateObject(CPreProcessor)
          m_objPP.Add "CLASS"       , Form.Grid.CellClass
         
          EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
          Form_DisplayCell          = TRUE      
     'End: cr11006       
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
		
		If FrameWork.CheckCoarseCapability("Add to group subscription") Then
      Session("BATCH_ERROR_RETURN_PAGE") =  mam_GetDictionary("GROUP_MEMBER_ADD_DIALOG") & "?MDMRELOAD=TRUE&action=add&Group_id=" & Form("Group_id")
    	strEndOfPageHTMLCode = "<br><div align='center'>"
    	strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class=""clsButtonLarge"" name=""ADDMEMBERS"" onclick=""window.location.href='" & mam_GetDictionary("GROUP_MEMBER_ADD_DIALOG") & "?MDMRELOAD=TRUE&action=add&Group_id=" & Form("Group_id") & "';return false;"">" & mam_GetDictionary("TEXT_ADD_MEMBERS_TO_GROUP_SUBSCRIPTION_BUTTON") & "</button>"
			strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</div>"
		End If
		If FrameWork.CheckCoarseCapability("Modify groupsub membership") Then
    	strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<br><div align='center'>"
    	strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class=""clsButtonLarge"" name=""REMOVEMEMBERS"" onclick=""window.location.href='" & mam_GetDictionary("GROUP_MEMBER_REMOVE_DIALOG") & "?MDMRELOAD=TRUE&action=add&Group_id=" & Form("Group_id") & "';return false;"">" & mam_GetDictionary("TEXT_REMOVE_MEMBERS_FROM_GROUP_SUBSCRIPTION_BUTTON") & "</button>"
			strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</div>"
		End If
		strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<br><br><div align='center'>"
		strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button class=""clsOkButton"" name=""CANCEL"" onclick=""window.location.href='" & mam_GetDictionary("GROUP_SUBSCRIPTIONS_DIALOG") & "'return false;"">" & mam_GetDictionary("TEXT_CANCEL") & "</button>"		
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</div>"
        
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>

