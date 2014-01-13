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
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmPicker.Library.asp" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE

mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
    
    if Request("Kind") = cstr(CounterType_PARAM_PRODUCT_VIEW) then
      Form("PICK_PROPERTY")= false
    else
      Form("PICK_PROPERTY")= true
    end if
    
 	  Form_Initialize = MDMPickerDialog.Initialize (EventArg)
    Form.Modal = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Form_LoadProductView = FALSE
  
  'Session("ProductViewPropertyPicker_Name")         = ""
  'Session("ProductViewPropertyPicker_PropertyName") = ""
    
  Set ProductView.Properties.RowSet = GetProductViewsAsRowset()
      
  ' Select the properties I want to print in the PV Browser   Order
  'ProductView.Properties.SelectAll
  ProductView.Properties.ClearSelection    
  ProductView.Properties("nm_name").Selected 			      = 1
  ProductView.Properties("nm_name").Caption             = FrameWork.GetDictionary("TEXT_PV_NAME") 
  
  if Form("PICK_PROPERTY") then
    ProductView.Properties("nm_property").Selected 	      = 2
    ProductView.Properties("nm_property").Caption         = FrameWork.GetDictionary("TEXT_PV_PROPERTY")     
    ProductView.Properties("nm_desc").Selected 	          = 3
    ProductView.Properties("nm_desc").Caption             = FrameWork.GetDictionary("TEXT_PV_DESCRIPTION") 
  else
    ProductView.Properties("nm_property").Selected 	      = 2
    ProductView.Properties("nm_property").Caption         = ""     
    ProductView.Properties("nm_desc").Selected 	          = 3
    ProductView.Properties("nm_desc").Caption             = FrameWork.GetDictionary("TEXT_PV_DESCRIPTION") 
  end if
  
  ProductView.Properties("nm_name").Sorted               = MTSORT_ORDER_ASCENDING  
  Set Form.Grid.FilterProperty                          = ProductView.Properties("nm_name") ' Set the property on which to apply the filter  
      
  Form_LoadProductView                                  = TRUE
  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  GetProductViewsAsRowset
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
Private Function GetProductViewsAsRowset()
    Dim newRowset
    Dim strTemp
    
    Dim objRCD
    Dim objXML
    Dim objXMLHelper

    Dim objFileList
    Dim strExtension
    Dim strFile

    Dim objNodeList
    Dim objNode
    
    Set newRowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
    
    Set objRCD = server.CreateObject("Metratech.RCD")
    Set objXML = server.CreateObject("Microsoft.XMLDOM")
    Set objXMLHelper = server.CreateObject("MTServiceWizard.XMLHelper")
    
    newRowset.InitDisconnected
    
    ' Add columns to new rowset
    newRowset.AddColumnDefinition "nm_name",     "string",  255
    newRowset.AddColumnDefinition "nm_property", "string",  64000
    newRowset.AddColumnDefinition "nm_desc",     "string",  255

    ' Fill new rowset
    newRowset.OpenDisconnected

    objXML.async = false
    objXML.validateOnParse = false
  
    for each strExtension in objRCD.ExtensionList
      Set objFileList = objRCD.RunQueryInAlternateFolder("*.msixdef", true, objRCD.ExtensionDir & "/" & strExtension & "/config/productview")
    
      for each strFile in objFileList
	  
        Set objNodeList = objXMLHelper.GetMultipleNodes(strFile, "/defineservice/ptype")
        
        ' Add Default Properties to each Product View
        strTemp = "amount,tax_federal,tax_state,tax_county,tax_local,tax_other,"
        for each objNode in objNodeList
          if UCase(objNode.selectSingleNode("type").text) = "INT32" or UCase(objNode.selectSingleNode("type").text) = "DECIMAL" then
            strTemp = strTemp & objNode.selectSingleNode("dn").text & ","
          end if
        next
        
        If Len(strTemp) Then
          strTemp =  left(strTemp, Len(strTemp) -1)       ' remove trailing comma
          
          ' don't add audit or error to list
          If (LCase(Trim(objXMLHelper.GetSingleNodeText(strFile, "/defineservice/name"))) <> "pipeline/error") Then
           If (LCase(Trim(objXMLHelper.GetSingleNodeText(strFile, "/defineservice/name"))) <> "metratech.com/audit") Then
              newRowset.AddRow
	            newRowset.AddColumnData "nm_name",     objXMLHelper.GetSingleNodeText(strFile, "/defineservice/name")
	            newRowset.AddColumnData "nm_desc",     objXMLHelper.GetSingleNodeText(strFile, "/defineservice/description")
              newRowset.AddColumnData "nm_property",  strTemp
            End If
          End If  
        Else
        
        End If

      next
    next
    
    newRowset.MoveFirst
    set GetProductViewsAsRowset = newRowset    

End Function
   
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : 
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean  
    Dim strPVName, strPropertyName

    strPVName = Request.Form("PickerItem")
    strPVName = MID(strPVName,2) ' Remove the first char the MDM PICKER put a I    
    strPropertyName = Request.Form(strPVName)
    
    Session("ProductViewPropertyPicker_Name")         = strPVName
    if Form("PICK_PROPERTY") then
      Session("ProductViewPropertyPicker_PropertyName") = strPropertyName
    else
      Session("ProductViewPropertyPicker_PropertyName") = ""
    end if
    
    OK_Click = MDMPickerDialog.OK_Click(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : 
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION CANCEL_Click(EventArg) ' As Boolean  
    
    Session("ProductViewPropertyPicker_Name")         = ""
    Session("ProductViewPropertyPicker_PropertyName") = ""
    
    CANCEL_Click = True
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
            
            m_objPP.Add "ID"          , TRIM(ProductView.Properties.Rowset.Value(MDMPickerDialog.GetIDColumnName()))
            'm_objPP.Add "KIND"        , ProductView.Properties.Rowset.Value("n_kind")
            'm_objPP.Add "KIND_STRING" , GetMTPriceableItemTypeString(ProductView.Properties.Rowset.Value("n_kind"))            
            
            strID = "I" & CStr(ProductView.Properties.Rowset.Value(MDMPickerDialog.GetIDColumnName()))
            If(Form("SelectedIDs").Exist(strID))Then
                strCheckStatus   =  IIF(Form("SelectedIDs").Item(strID).Value=1,"CHECKED",Empty)
            Else
                strCheckStatus  = Empty ' Not Selected
            End If
            m_objPP.Add "CHECK_STATUS" , strCheckStatus
            
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE
        Case 2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
        Case 5
            dim strHTML
            strHTML = "<td class='" & Form.Grid.CellClass & "'>" & TRIM(ProductView.Properties.Rowset.Value("nm_desc"))
            strHTML = strHTML & "</td>"
            EventArg.HTMLRendered = strHTML
        Case 4
            if Form("PICK_PROPERTY") then
              EventArg.HTMLRendered     = GetDropDown(EventArg)
            else
              EventArg.HTMLRendered = "<td class='" & Form.Grid.CellClass & "'>&nbsp;</td>"
            end if
        Case Else        
           Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : Form_DisplayHeaderCell 
' PARAMETERS  : 
' DESCRIPTION : Over ride the MDM Default event Form_DisplayHeaderCell() 
'               If the client over ride this event it is not possible to call it as the Inherited event.  
'               Because the inherited event is the one defined in the file mdm\mdmPVBEvents.asp, this 
'               is a limitation of a picker.  
' RETURNS     :

PUBLIC FUNCTION Form_DisplayHeaderCell(EventArg) ' As Boolean

    Select Case Form.Grid.Col

        Case 4
            ' Display caption with no link since we can't sort on this column
            EventArg.HTMLRendered  = "<td nowrap class='TableHeader'>" & Form.Grid.SelectedProperty.Caption & "</td>"
            Form_DisplayHeaderCell = TRUE

        Case Else        
            ' Call the default implementation
            Form_DisplayHeaderCell = Inherited("Form_DisplayHeaderCell()")

    End Select
END FUNCTION

PUBLIC FUNCTION GetDropDown(EventArg)
   Dim strHTML
   Dim arrProps
   Dim v
   
   arrProps = Split(TRIM(ProductView.Properties.Rowset.Value("nm_property")), ",")
   
   strHTML = "<td class='" & Form.Grid.CellClass & "'><select name='" & TRIM(ProductView.Properties.Rowset.Value("nm_name")) & "'>"
   
   For each v in arrProps
      strHTML = strHTML & "<option Value='" & v & "' >" & v & "</option>"
   Next
   
   strHTML = strHTML & "</select></td>"
   
   GetDropDown = strHTML
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  inheritedForm_DisplayEndOfPage
' PARAMETERS    :  EventArg
' DESCRIPTION   :  Override end of table to place add button
' RETURNS       :  Return TRUE if ok else FALSE
PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean    
    ' We do not call the inherited event because we have to make sure a radio button was selected from the grid before the OK button is clicked. Otherwise, we get
    ' COM errors when the previous page is refreshed because no value was selected for the product view property.    
    dim strEndOfPageHTMLCode

    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</TABLE>"
        
    MDMPickerDialog.GenerateHTMLEndOfPage EventArg
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<BR><CENTER>"
    
    If ProductView.Properties.Rowset.RecordCount > 0 Then
      ' Before refreshing the page, first check if the user selected any of the values from the grid. If not, stay on the page and show a message to the user.
      strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<BUTTON Name='OK'  Class='clsOKButton' OnClick='if(check_selected()){mdm_RefreshDialog(this)};return false;'>OK</BUTTON>&nbsp;&nbsp;&nbsp;"
    End If
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<BUTTON Name='CANCEL' Class='clsOKButton' OnClick='mdm_RefreshDialog(this);return false;'>Cancel</BUTTON>"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</center>"
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</FORM></HTML>"
        
    EventArg.HTMLRendered= EventArg.HTMLRendered & strEndOfPageHTMLCode 
    
    If(COMObject.Configuration.DebugMode)Then ' If in debug mode display the selection
       EventArg.HTMLRendered = EventArg.HTMLRendered  & "<hr size=1>" & Replace(Form("SelectedIDs").ToString(),vbNewline,"<br>") & "<br>"
    End If
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION
%>
