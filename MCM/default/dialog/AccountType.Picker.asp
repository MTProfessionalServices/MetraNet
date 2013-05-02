 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: $
' 
'  Copyright 1998,2001 by MetraTech Corporation
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
'  Created by: The UI Team
' 
'  $Date: 5/11/00 12:00:08 PM$
'  $Author: $
'  $Revision: 1$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : PriceableItem.Picker.asp
' DESCRIPTION : Allow to select a Priceable Item and execute a specific asp file if the user click on one.
' 
' PICKER INTERFACE : A Picker ASP File Interface is based on the QueryString Name/Value.
'                    NextPage : The url to execute if a user click a one item. This url must accept a querystring
'                    parameter ID. ID will contains this id of the Item.
'
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->

<!-- #INCLUDE VIRTUAL="/mdm/common/mdmPicker.Library.asp" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = false
Form.RouteTo        = FrameWork.GetDictionary("WELCOME_DIALOG") ' This Should Change Some Time

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Form_Initialize = MDMPickerDialog.Initialize(EventArg)
	Form.Modal = false
	
    If(UCase(Request.QueryString("ProxyMode"))="TRUE")Then
    
       MDMPickerDialog.NextPage = "Proxy.ProductOffering.asp"   ' Proxy Page
       MDMPickerDialog.Parameters = "POID|" & Request.QueryString("ID") & ";UpdateAccountRestrictions|" & "TRUE" 
    End If    
END FUNCTION
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :  EventArg
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  'Dim objYAAC
  'Set objYAAC = mdm_CreateObject("MetraTech.MTYAAC.1")
  
  
  
    
  dim rowset
  'Set rowset = objYAAC.GetAccountTypesAsRowset()
  

  set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\mcm"
	'rowset.SetQueryString "select * from t_account_type where b_CanSubscribe=1"   
  rowset.SetQueryTag "__SELECT_ACCOUNT_TYPES_TO_DISPLAY_IN_PO_RESTRICTION_PICKER__"
  rowset.Execute

  

  
  Set ProductView.Properties.RowSet = rowset 'objMTProductCatalog.FindPriceableItemsAsRowset(objMTFilter) ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  
  if false then
    ProductView.Properties.SelectAll
  else
  
  ProductView.Properties.ClearSelection               ' Select the properties I want to print in the PV Browser   Order  
  ProductView.Properties("name").Selected     = 1
  ProductView.Properties("nm_description").Selected 	  = 2
  'ProductView.Properties("nm_glcode").Selected  = 3
  
  ProductView.Properties("name").Sorted       = MTSORT_ORDER_ASCENDING ' Set the default sorted property
  
  Set Form.Grid.FilterProperty                  = ProductView.Properties("name") ' Set the property on which to apply the filter  
  ProductView.Properties("name").Caption      = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_description").Caption      = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
  end if
  
  Form_LoadProductView                          = TRUE ' Must return trueto display any result.
END FUNCTION

PUBLIC FUNCTION Form_DisplayCell(EventArg) ' As Boolean

    Dim m_objPP, strCheckStatus, strID,HTML_LINK_EDIT

    Select Case Form.Grid.Col

        Case 1
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='16'>"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<INPUT Type='[CONTROL_TYPE]' Name='PickerItem' value='I[ID]' [CHECK_STATUS] [ON_CLICK] >"

            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"

            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass

            m_objPP.Add "CONTROL_TYPE"  , IIF(Form("MonoSelect"),"Radio","CheckBox")
            m_objPP.Add "ON_CLICK"      , IIF(Form("MonoSelect"),"","OnClick='mdm_RefreshDialog(this);'")

            m_objPP.Add "ID"          , ProductView.Properties.Rowset.Value(MDMPickerDialog.GetIDColumnName())

            strID = "I" & CStr(ProductView.Properties.Rowset.Value(MDMPickerDialog.GetIDColumnName()))
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
        Case 3
              EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>" & _
              "<img src='" & mdm_GetIconUrlForAccountType(ProductView.Properties.RowSet.Value("name")) & "' alt='' border='0' align='top'>&nbsp;" & ProductView.Properties.RowSet.Value("name") & "&nbsp;&nbsp;</td>"
              '  ProductView.Properties.RowSet.Value("State") & "<button class='clsButtonBlueSmall' name='EditMapping' onclick=""window.open('protoIntervalManagement.asp?','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes')"">" & "Change" &  "</button></td>" 
         
  			    Form_DisplayCell = TRUE
        Case Else
           Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select
END FUNCTION
    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : 
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean
    OK_Click = MDMPickerDialog.OK_Click(EventArg)
END FUNCTION   

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  inheritedForm_DisplayEndOfPage
' PARAMETERS    :  EventArg
' DESCRIPTION   :  Override end of table to place add button
' RETURNS       :  Return TRUE if ok else FALSE
PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    
    ' We do not call the inherited event because we have to add the hidden field PickerIDs    
    EventArg.HTMLRendered = "<INPUT Type='Hidden' Name='PickerIDs' Value=''></TABLE><BR><CENTER>" & vbNewLine
	If ProductView.Properties.Rowset.RecordCount > 0 Then
      EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON Name='OK' Class='clsOKButton' OnClick='OK_Click();'>" & FrameWork.GetDictionary("TEXT_OK") & "</BUTTON>&nbsp;&nbsp;&nbsp;" & vbNewLine
	End if
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<BUTTON Name='CANCEL' Class='clsOKButton' OnClick='CANCEL_Click();'>" & FrameWork.GetDictionary("TEXT_CANCEL") & "</BUTTON></center>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</center>" & vbNewLine    
    MDMPickerDialog.GenerateHTMLEndOfPage EventArg
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</FORM>" & vbNewLine
    
    
    If(COMObject.Configuration.DebugMode)Then ' If in debug mode display the selection
    
       EventArg.HTMLRendered = EventArg.HTMLRendered & "<hr size=1>" & Replace(Form("SelectedIDs").ToString(),vbNewline,"<br>") & "<br>"
    End If    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>

