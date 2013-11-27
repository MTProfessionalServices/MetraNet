<% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
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
'  $Date$
'  $Author$
'  $Revision$
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' CLASS       : RateSchedule.Picker.asp
' DESCRIPTION : Allow to select a Rate Schedule and execute a specific asp file if the user click on one.
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
Form.ErrorHandler   = TRUE
Form.RouteTo        = FrameWork.GetDictionary("WELCOME_DIALOG") ' This Should Change Some Time

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	Form("PT_ID") = Request.QueryString("PT_ID")
  Form_Initialize = MDMPickerDialog.Initialize (EventArg)
	Form.Grid.FilterMode          = FALSE ' We don't want filter capability on this product view
END FUNCTION
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :  EventArg
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog, objMTFilter, objParamTable, bShared

  Form_LoadProductView = FALSE
  
  Set objMTProductCatalog = GetProductCatalogObject
  
  Set objParamTable = objMTProductCatalog.GetParamTableDefinition(Clng(Form("PT_ID")))
 
  bShared = CBool(Request.QueryString("Shared"))
  Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter.1")
  
  If bShared Then
    objMTFilter.Add "Type", OPERATOR_TYPE_EQUAL, PRICELIST_TYPE_REGULAR
  Else
    objMTFilter.Add "Type", OPERATOR_TYPE_EQUAL, PRICELIST_TYPE_PO
  End if
    
  Set ProductView.Properties.RowSet = objParamTable.GetRateSchedulesAsRowset(objMTFilter, false)
	 
  ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  
  ProductView.Properties.ClearSelection          ' Select the properties I want to print in the PV Browser   Order  
  'ProductView.Properties.SelectAll

  If bShared Then
    ProductView.Properties("pl_nm_name").Selected 	= 1
    Set Form.Grid.FilterProperty          	        = ProductView.Properties("pl_nm_name")
  Else
    ProductView.Properties("po_nm_name").Selected 	= 1
    Set Form.Grid.FilterProperty          	        = ProductView.Properties("po_nm_name")    
  End If
  
  ProductView.Properties("pi_nm_name").Selected 	= 2
  ProductView.Properties("rs_nm_desc").Selected   = 3
  ProductView.Properties("dt_start").Selected 		= 4
  ProductView.Properties("dt_end").Selected		 		= 5
  
  ProductView.Properties("pl_nm_name").Sorted     = MTSORT_ORDER_ASCENDING ' Set the default sorted property
  
  ProductView.Properties("rs_nm_desc").Caption    = FrameWork.GetDictionary("TEXT_RATESCHEDULE_DESCRIPTION")
  ProductView.Properties("pi_nm_name").Caption    = FrameWork.GetDictionary("TEXT_KEYTERM_PRICEABLE_ITEM")
  If bShared Then
    ProductView.Properties("pl_nm_name").Caption    = FrameWork.GetDictionary("TEXT_KEYTERM_PRICE_LIST")
  Else
    ProductView.Properties("po_nm_name").Caption    = FrameWork.GetDictionary("TEXT_KEYTERM_PRODUCT_OFFERING")
  End If
  ProductView.Properties("dt_start").Caption	 		= FrameWork.GetDictionary("TEXT_RATES_COLUMN_START_DATE")
	ProductView.Properties("dt_end").Caption 				= FrameWork.GetDictionary("TEXT_RATES_COLUMN_END_DATE")
	
  Form_LoadProductView                           = TRUE ' Must return true to display any result.
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: Form_DisplayCell
' PARAMETERS	:
' DESCRIPTION : Over ride the MDM Default event Form_DisplayCell()
'               If the client over ride this event it is not possible to call it as the Inherited event.
'               Because the inherited event is the one defined in the file mdm\mdmPVBEvents.asp, this
'               is a limitation of a picker.
' RETURNS		  :
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
      Elseif Form.Grid.Row = 1 Then ' If no value was previously selected, then select the first element on the list
				strCheckStatus = "CHECKED"
			Else
        strCheckStatus  = Empty ' Not Selected
      End If
      m_objPP.Add "CHECK_STATUS" , strCheckStatus
      
      EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
      Form_DisplayCell          = TRUE
            
    Case 2  
      mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
            
		' Localize these guys
    
		Case 6 ' This is the "STARTS" field 
			Set m_objPP = mdm_CreateObject(CPreProcessor)
			HTML_LINK_EDIT = HTML_LINK_EDIT & "<td nowrap class='[CLASS]'>"
      HTML_LINK_EDIT = HTML_LINK_EDIT & GetEffectiveDateTextByType(ProductView.Properties.Rowset.Value("n_begintype"), ProductView.Properties.Rowset.Value("dt_start"), ProductView.Properties.Rowset.Value("n_beginoffset"), true)
			HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
			m_objPP.Clear
      m_objPP.Add "CLASS", Form.Grid.CellClass	
			EventArg.HTMLRendered           = m_objPP.Process(HTML_LINK_EDIT)
			
		Case 7 ' This is the "ENDS" field
			Set m_objPP = mdm_CreateObject(CPreProcessor)
			HTML_LINK_EDIT = HTML_LINK_EDIT & "<td nowrap class='[CLASS]'>"
      HTML_LINK_EDIT = HTML_LINK_EDIT & GetEffectiveDateTextByType(ProductView.Properties.Rowset.Value("n_endtype"), ProductView.Properties.Rowset.Value("dt_end"), ProductView.Properties.Rowset.Value("n_endoffset"), false)
			HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
			m_objPP.Clear
      m_objPP.Add "CLASS", Form.Grid.CellClass	
			EventArg.HTMLRendered           = m_objPP.Process(HTML_LINK_EDIT)
    Case Else
      Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select
    
END FUNCTION
    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Override to MDM OK_Click
' PARAMETERS		:
' DESCRIPTION 		: Sets an extra session variable so we know we wanted to copy rules.
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean

    OK_Click = MDMPickerDialog.OK_Click(EventArg)
END FUNCTION   

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_DisplayEndOfPage
' PARAMETERS    :  EventArg
' DESCRIPTION   :  Override end of table to place add button
' RETURNS       :  Return TRUE if ok else FALSE
PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    ' We do not call the inherited event because we have to add the hidden field PickerID    
    EventArg.HTMLRendered = "<INPUT Type='Hidden' Name='PickerID' Value=''></TABLE><BR><CENTER>" & vbNewLine
    
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
