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
'  Created by: K.Boucher
' 
'  $Date$
'  $Author$
'  $Revision$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : SecurityAddRole.asp
' DESCRIPTION : 
' 
' PICKER INTERFACE : A Picker ASP File Interface is based on the QueryString Name/Value.
'                    NextPage : The url to execute if a user click a one item. This url must accept a querystring
'                    parameter ID. ID will contains this id of the Item.
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmPicker.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.Version     = MDM_VERSION     ' Set the dialog version 
Form.RouteTo     = Session("LastRolePage") 
Form.Page.MaxRow = CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  On error resume next
 	Form("AuthAccount") = FrameWork.Policy.GetAccountByID(FrameWork.SessionContext,Session("SecurityAccountID"), mam_ConvertToSysDate(mam_GetHierarchyTime()))
  If err.number <> 0 then
    Call WriteUnableToLoad(mam_GetDictionary("TEXT_UNABLE_TO_MANAGE_ACCOUNT"),  mam_GetDictionary("SUBSCRIBER_FOUND"))
  End If
  On error goto 0     
  
	' Are we dealing with the Default Account or the Active Policy?
  If UCase(Session("DefaultPolicy")) = "TRUE" Then
	  Form("AccountPolicy") = Form("AuthAccount").GetDefaultPolicy(FrameWork.SessionContext)
	Else
	  Form("AccountPolicy") = Form("AuthAccount").GetActivePolicy(FrameWork.SessionContext)
  End If
	
  Form_Initialize = MDMPickerDialog.Initialize(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
  Form_LoadProductView = FALSE

  ' Send policy type - 0 for active, 1 for default
  If UCase(Session("DefaultPolicy")) = "TRUE" Then
	Set ProductView.Properties.RowSet = FrameWork.Policy.GetAvailableRolesAsRowset(FrameWork.SessionContext, Form("AuthAccount"), 1)   
  else
	Set ProductView.Properties.RowSet = FrameWork.Policy.GetAvailableRolesAsRowset(FrameWork.SessionContext, Form("AuthAccount"), 0)   
  end if
	
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet

  ProductView.Properties.ClearSelection    
 ' Select the properties I want to print in the PV Browser   Order
 ' ProductView.Properties.SelectAll
  ProductView.Properties("tx_name").Selected = 1
  ProductView.Properties("tx_desc").Selected = 2
	
  ProductView.Properties("tx_name").Caption = mam_GetDictionary("TEXT_ROLE_NAME")
  ProductView.Properties("tx_desc").Caption = mam_GetDictionary("TEXT_ROLE_DESCRIPTION")
			
  ProductView.Properties("tx_name").Sorted = MTSORT_ORDER_ASCENDING
  Set Form.Grid.FilterProperty = ProductView.Properties("tx_name") ' Set the property on which to apply the filter  
  
  Form_LoadProductView = TRUE
  
END FUNCTION
    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION       : 
' PARAMETERS    :
' DESCRIPTION   :
' RETURNS        : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean
		Dim arrIds
    Dim ID
		Dim objRole
    
    On Error Resume Next
    
		OK_Click = MDMPickerDialog.OK_Click(EventArg)
		arrIds = Split(MDMPickerDialog.GetIDsCsvString(), ",")

		For Each ID in arrIds
		  Set objRole = FrameWork.Policy.GetRoleByID(FrameWork.SessionContext, CLng(ID))
		  Form("AccountPolicy").AddRole(objRole)
		Next

		Form("AuthAccount").Save
						
		If(CBool(Err.Number = 0)) then
	      On Error Goto 0
	      OK_Click = TRUE
	  Else        
	      EventArg.Error.Save Err  
	      OK_Click = FALSE
	  End If		
		
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Form_DisplayCell
' PARAMETERS :
' DESCRIPTION :
' RETURNS    : 
PUBLIC FUNCTION Form_DisplayCell(EventArg) ' As Boolean
    Dim url
    Dim m_objPP, strCheckStatus, strID,HTML_LINK_EDIT
    
    Select Case Form.Grid.Col
    
         Case 1
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='16'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<INPUT Type='[CONTROL_TYPE]' Name='PickerItem' value='I[ID]' [CHECK_STATUS] [ON_CLICK] >"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<INPUT Type='Hidden' Name='Role.[NAME]' value='[ID]'>"

            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass
            
            m_objPP.Add "CONTROL_TYPE"  , IIF(Form("MonoSelect"),"Radio","CheckBox")
            m_objPP.Add "ON_CLICK"      , IIF(Form("MonoSelect"),"","OnClick='mdm_RefreshDialog(this);'")
            m_objPP.Add "ID"            , ProductView.Properties.Rowset.Value("id_role")
            m_objPP.Add "NAME"          , ProductView.Properties.Rowset.Value("tx_name")
            
            strID = "I" & CStr(ProductView.Properties.Rowset.Value("id_role"))
            If(Form("SelectedIDs").Exist(strID))Then
                strCheckStatus   =  IIF(Form("SelectedIDs").Item(strID).Value=1,"CHECKED",Empty)
            Else
                strCheckStatus  = Empty ' Not Selected
            End If
            
            If(Form("MonoSelect"))THen
              If(Form("SelectedIDs").Count=0)and(Form.Grid.Row = 1)Then
                  strCheckStatus   =  "CHECKED"
              End If
            End If
            
            m_objPP.Add "CHECK_STATUS" , strCheckStatus
            
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE
						
        Case 2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
        
        Case 3, 4
            'SECENG: CORE-4768 CLONE - MSOL 26810 Metracare: Reflected cross-site scripting [/mam/default/dialog/RoleAdd.asp in 'name' parameter] (Post-PB)
            'Added HTML encoding
            EventArg.HTMLRendered     =  "<td class=" & Form.Grid.CellClass & " align='left'>" & SafeForHtml(Form.Grid.SelectedProperty.Value) & "</td>"
            Form_DisplayCell          = TRUE
                                        
        Case Else        
           Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select
END FUNCTION

%>

