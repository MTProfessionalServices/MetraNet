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
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../lib/TabsClass.asp" -->
<!-- #INCLUDE FILE="../lib/ScriptIncludes.html" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = FALSE
mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

    Framework.Dictionary.Add "SHOW_RECURRING_CHARGE_NEW_BUTTON", CSTR(Request.QueryString("Tab"))="1"
    Framework.Dictionary.Add "SHOW_NON_RECURRING_CHARGE_NEW_BUTTON", CSTR(Request.QueryString("Tab"))="2"
    Framework.Dictionary.Add "SHOW_DISCOUNT_NEW_BUTTON", CSTR(Request.QueryString("Tab"))="3"
    
    Dim strTabs
    
    ' Dynamically Add Tabs to template
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_USAGE_CHARGES"), "[SERVICE_CHARGES_USAGE_LIST]"
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_RECURRING_CHARGES"), "[SERVICE_CHARGES_RECURRING_LIST]"
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_NON_RECURRING_CHARGES"), "[SERVICE_CHARGES_NONRECURRING_LIST]"
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_DISCOUNTS"), "[SERVICE_CHARGES_DISCOUNT_LIST]"
          
    gObjMTTabs.Tab = Clng(Request.QueryString("Tab"))
    
    Select Case gObjMTTabs.Tab
      Case 0
        Framework.Dictionary.Add "TAB_LIST_HEADING", FrameWork.GetDictionary("TEXT_KEYTERM_USAGE_CHARGES")
        Form("NextPage1") = FrameWork.GetDictionary("PRICEABLE_ITEM_USAGE_EDIT_DIALOG")
        Form.HelpFile   = "PriceAbleItem.Usage.ViewEdit.hlp.htm"
      Case 1
        Framework.Dictionary.Add "TAB_LIST_HEADING", FrameWork.GetDictionary("TEXT_KEYTERM_RECURRING_CHARGES")
        Form("NextPage1") = FrameWork.GetDictionary("RECURRING_EDIT_DIALOG")
        Form.HelpFile   = "PriceAbleItem.RecurringCharge.ViewEdit.hlp.htm"
      Case 2         
        Framework.Dictionary.Add "TAB_LIST_HEADING", FrameWork.GetDictionary("TEXT_KEYTERM_NON_RECURRING_CHARGES")
        Form("NextPage1") = FrameWork.GetDictionary("NON_RECURRING_EDIT_DIALOG")
        Form.HelpFile   = "PriceAbleItem.NonRecurring.ViewEdit.hlp.htm"
      Case Else 
        Framework.Dictionary.Add "TAB_LIST_HEADING", FrameWork.GetDictionary("TEXT_KEYTERM_DISCOUNTS")
        Form("NextPage1") = FrameWork.GetDictionary("DISCOUNTS_VIEW_EDIT_DIALOG") '& "?EditMode=True&PoBased=False"
        Form.HelpFile   = "PriceableItem.Discount.ViewEdit.hlp.htm"

    End Select  
    
    strTabs = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
  
    Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)
    Form.Page.NoRecordUserMessage     = FrameWork.GetDictionary("NO_RECORD_USER_MESSAGE")
    
	  Form_Initialize = MDMListDialog.Initialize(EventArg)
    Form("NextPage") = Form("NextPage1")
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :  EventArg
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog, objMTFilter

  Form_LoadProductView = FALSE

  Set objMTProductCatalog = GetProductCatalogObject
  
  If(Not IsEmpty(Form("Kind")))Then
      Set objMTFilter = mcmGetFilterForPriceableItemKind(CLng(Form("Kind")))
  Else
      Set objMTFilter = Nothing   ' No Filter
  End If
  
  Set ProductView.Properties.RowSet = objMTProductCatalog.FindPriceableItemsAsRowset(objMTFilter) ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  
  if false then
  ProductView.Properties.SelectAll
  else
    ProductView.Properties.ClearSelection               ' Select the properties I want to print in the PV Browser   Order  
    ProductView.Properties("nm_display_name").Selected     = 1
    ProductView.Properties("nm_desc").Selected 	  = 2
    'Need extra column for rc and nrc for configure adjustments button
    if CLng(Form("Kind"))=PI_TYPE_RECURRING OR CLng(Form("Kind"))=PI_TYPE_NON_RECURRING Then
      ProductView.Properties("id_prop").Selected  = 3
      ProductView.Properties("id_prop").Caption 	            = ""
    end if
  end if
  
  ProductView.Properties("nm_display_name").Sorted       = MTSORT_ORDER_ASCENDING ' Set the default sorted property
  
  Set Form.Grid.FilterProperty                          = ProductView.Properties("nm_display_name") ' Set the property on which to apply the filter  

  ProductView.Properties("nm_display_name").Caption 		          = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption 	            = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")

  
  Form_LoadProductView = TRUE ' Must Return TRUE To Render The Dialog
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean
    
    Dim strSelectorHTMLCode
    Dim strValue, strTDHTMLAttributeName, strImageHTMLAttributeName
    Dim strCurrency    
    Dim strImage, strPageAction    
    Dim strFormat
    
    ' Get the MSIXProperty object
    
    strTDHTMLAttributeName     = "Reserved(" & Form.Grid.Row & "," & Form.Grid.Col & ")"
    strImageHTMLAttributeName  = "TurnDown(" & Form.Grid.Row & ")"
    EventArg.HTMLRendered      = ""
    
    Select Case Form.Grid.Col
        Case 1
            
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<td name='" & strTDHTMLAttributeName & "' nowrap class='" & Form.Grid.CellClass & "' width=20>&nbsp;</td>"
        
        Case 2
          if (ProductView.Properties.Rowset.Value("NumberChildren")<>"0") then
            If(Form.Grid.TurnDowns.Exist("R" & Form.Grid.Row))Then
            
                strImage            = MDM_PRODUCT_VIEW_TOOL_BAR_TURN_DOWN_HTTP_FILE_NAME
                strPageAction       = MDM_ACTION_TURN_RIGHT
            Else
                strImage            = MDM_PRODUCT_VIEW_TOOL_BAR_TURN_RIGHT_HTTP_FILE_NAME
                strPageAction       = MDM_ACTION_TURN_DOWN
            End If
             
            EventArg.HTMLRendered = EventArg.HTMLRendered  & "<td name='" & strTDHTMLAttributeName & "' nowrap class='" & Form.Grid.CellClass & "' width=10><A href='" & request.serverVariables("URL")  & "?mdmPageAction=" & strPageAction & "&mdmRowIndex=" & Form.Grid.Row &  "'><img alt='" & MDM_PRODUCT_VIEW_TOOL_BAR_TURN_DOWN_TOOL_TIP & "' name='" & strImageHTMLAttributeName &  "' src='" & strImage & "' Border='0'></a></td>"
          else
            EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>&nbsp;</td>"
          end if
        Case 3
            'Form_DisplayCell = LinkColumnMode_DisplayCell(EventArg)
            Inherited("Form_DisplayCell()")

            dim strIcon
            strIcon = "<img src='" & mdm_GetIconUrlForPriceableItem(ProductView.Properties.Rowset.Value("nm_display_name"),ProductView.Properties.Rowset.Value("n_kind")) & "' alt='' border='0' align='top'>&nbsp;"

            dim lngPos
            lngPos                = InStr(EventArg.HTMLRendered,">") ' Find the first >
            EventArg.HTMLRendered = MDMListDialog.Tools.InsertAStringAt(EventArg.HTMLRendered,strIcon & "<A Name='Link[ID]' onclick='javascript:OpenDialogWindow(""[URL]?ID=[ID][PARAMETERS]"",""height=600,width=800,resizable=yes,scrollbars=yes"");' HREF='javascript:void(0);'>",lngPos+1) ' Insert after >
            EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"</td>","</a></td>")
            
            MDMListDialog.PreProcessor.Clear
            MDMListDialog.PreProcessor.Add "URL" , Form("NextPage")
            MDMListDialog.PreProcessor.Add "ID"  , ProductView.Properties.Rowset.Value(MDMListDialog.GetIDColumnName())

            EventArg.HTMLRendered = MDMListDialog.PreProcess(EventArg.HTMLRendered)
            


            'onclick='javascript:OpenDialogWindow(""[URL]?ID=[ID][PARAMETERS]"",""height=400,width=600,resizable=yes,scrollbars=yes"");'
              
        Case Else
         Select Case lcase(Form.Grid.SelectedProperty.Name)
         Case "id_prop"
           'Show 'Configure Adjustments' button for RCs and NRCs
           if CLng(Form("Kind"))=PI_TYPE_RECURRING OR CLng(Form("Kind"))=PI_TYPE_NON_RECURRING Then
              EventArg.HTMLRendered     =  "<td class='" & Form.Grid.CellClass & "'>"  & _
                "<button id='EditAdjustment[ID]' class='clsButtonBlueXLarge' onclick=""window.open('[ADJUSTMENT_TEMPLATES_EDIT_DIALOG]?ID=[ID]','_blank', 'height=800,width=1000,resizable=1,scrollbars=1'); return false;"">[TEXT_BUTTON_SET_UP_ADJUSTMENTS]</button>&nbsp;" & _
                "</td>"
  
              MDMListDialog.PreProcessor.Clear
              MDMListDialog.PreProcessor.Add "ID"  , ProductView.Properties.Rowset.Value(MDMListDialog.GetIDColumnName())
  
              EventArg.HTMLRendered = MDMListDialog.PreProcess(EventArg.HTMLRendered)
            else
              Form_DisplayCell = Inherited("Form_DisplayCell()") ' Call the default implementation   
            end if

         Case else                
            strTDHTMLAttributeName = Form.Grid.SelectedProperty.Name  & "(" & Form.Grid.Row & ")"
            

            If(Form.Grid.SelectRowMode)Then ' User can select a row
        
                EventArg.HTMLRendered =  EventArg.HTMLRendered  & "<td name='" & strTDHTMLAttributeName & "' class='" & Form.Grid.CellClass & "' align='" & Form.Grid.SelectedProperty.Alignment & "' OnClick='mdm_TDOnClick(this.parentNode,""[IDROW]"",""[LABELID]"");' OnMouseOver='mdm_TDMouseOver(this);' OnMouseOut='mdm_TDMouseOut(this,""[CLASS]"")'; >"
                EventArg.HTMLRendered =  PreProcess(EventArg.HTMLRendered,Array("LABELID",Form.Grid.LabelID,"IDROW",Form.Grid.PropertyID.Value,"CLASS",Form.Grid.CellClass,"CLASS_SELECTED",Form.Grid.CellClass & "Selected"))

            Else            
                EventArg.HTMLRendered =  EventArg.HTMLRendered  & "<td name='" & strTDHTMLAttributeName & "' class='" & Form.Grid.CellClass & "' align='" & Form.Grid.SelectedProperty.Alignment & "' >"
            End If
            
            If(Form.Grid.SelectedProperty.IsEnumType())Then
                'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
                'Adding HTML Encoding
                'strValue = Form.Grid.SelectedProperty.LocalizedValue
                strValue = SafeForHtmlAttr(Form.Grid.SelectedProperty.LocalizedValue)
            Else
                'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
                'Adding HTML Encoding
                'strValue = Form.Grid.SelectedProperty.Value
                strValue = SafeForHtmlAttr(Form.Grid.SelectedProperty.Value)
            End If
            
            ' Test if the property has a format assigned, if yes format the value
            strFormat = Form.Grid.SelectedProperty.Format
            If(Len(strFormat))Then
            
                'strValue = ProductView.Tools.Format(strValue,strFormat)
                ' 3.6 - support decimal localization
                strValue = Service.Tools.Format(strValue, FrameWork.Dictionary())
        
            End If
            
            If (Len(strValue)=0) Then strValue = "&nbsp;"
            
            
            If(IsArray(strValue))Then
                strValue=REPLACE(mdm_GetMDMLocalizedError("MDM_ERROR_1017"),"COLUMNS",Form.Grid.SelectedProperty.Name)
            End If

            EventArg.HTMLRendered =  EventArg.HTMLRendered  &  strValue & "</td>"
          End Select
    End Select
    Form_DisplayCell = TRUE
END FUNCTION


PRIVATE FUNCTION Form_DisplayDetailRow(EventArg) ' As Boolean

    Dim objProperty
    Dim strSelectorHTMLCode
    Dim strValue
    Dim strCurrency
    Dim strHTMLAttributeName
    
    'Set objProperty = ProductView.Properties.Item(Form.Grid.PropertyName)
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class=" & Form.Grid.CellClass & "></td><td class=" & Form.Grid.CellClass & "></td>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class=" & Form.Grid.CellClass & " ColSpan=" & (ProductView.Properties.Count+2) & ">" & vbNewLine
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<TABLE class=" & Form.Grid.CellClass & " width='100%' border=0 cellpadding=1 cellspacing=0>" & vbNewLine
    
    if false then
    For Each objProperty In ProductView.Properties
    
        If(UCase(objProperty.Name)<>"MDMINTERVALID") And ((objProperty.Flags And eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET)=0) Then
        
            ' Check the columns to exclude...
            If(InStr(UCase("UserId,EventId,id_entity,id_UserId,dt_crt,id_entitytype"),UCase(objProperty.Name))=0)Then 
            
              If(objProperty.UserVisible)Then
              
                  strHTMLAttributeName  = "TurnDown." & objProperty.Name & "(" & Form.Grid.Row & ")"
                  EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr>" & vbNewLine
                  EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Class='TableDetailCell' nowrap>" & objProperty.Caption & "</td>" & vbNewLine
                  
                  'strValue = TRIM("" & objProperty.NonLocalizedValue)
                  strValue = TRIM("" & objProperty.Value)
                  If(Len(strValue)=0)Then
                      strValue  = "&nbsp;"
                  End If
                  EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Name='" & strHTMLAttributeName & "' Class='TableDetailCell' nowrap>" & strValue & " </td>" & vbNewLine
                  EventArg.HTMLRendered = EventArg.HTMLRendered & "</tr>" & vbNewLine
              End If
            End If        
        End If
    Next
    else
      EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class=" & Form.Grid.CellClass & " colspan=3><table>"
      
        Dim objMTProductCatalog,objMTPriceableItem,objChildPriceableItemRowset
        Set objMTProductCatalog = GetProductCatalogObject
        set objMTPriceableItem = objMTProductCatalog.GetPriceableItem(ProductView.Properties.Rowset.Value("id_prop"))
        set objChildPriceableItemRowset = objMTPriceableItem.GetChildrenAsRowset()
        
        dim i
        for i=0 to objChildPriceableItemRowset.RecordCount-1
        
         'EventArg.HTMLRendered = EventArg.HTMLRendered & "child " & objChildPriceableItemRowset.value("nm_display_name") & "<br>"
         
            'dim lngPos
            'lngPos                = InStr(EventArg.HTMLRendered,">") ' Find the first >
            'EventArg.HTMLRendered = MDMListDialog.Tools.InsertAStringAt(EventArg.HTMLRendered,"<A Name='Link[ID]' HREF='[URL]?ID=[ID][PARAMETERS]'>",lngPos+1) ' Insert after >
            'EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"</td>","</a></td>")
            dim sBuffer
            'sBuffer = "<A Name='Link[ID]' HREF='[URL]?ID=[ID][PARAMETERS]'>[DISPLAYNAME]</a><br>"
            dim strIcon
            strIcon = "<img src='" & mdm_GetIconUrlForPriceableItem(objChildPriceableItemRowset.value("nm_display_name"),Form("Kind")) & "' alt='' border='0' align='top'>&nbsp;"

            sBuffer = "<tr><td>" & strIcon & "</td><td><a Name='Link[ID]' onclick='javascript:OpenDialogWindow(""[URL]?ID=[ID][PARAMETERS]"",""height=400,width=600,resizable=yes,scrollbars=yes"");' href='javascript:void(0);'>[DISPLAYNAME]</a></td><tr><td>&nbsp;</td><td>[DESCRIPTION]</td></tr>"
            MDMListDialog.PreProcessor.Clear
            MDMListDialog.PreProcessor.Add "URL" , Form("NextPage")
            MDMListDialog.PreProcessor.Add "ID"  , objChildPriceableItemRowset.value("id_template")
            MDMListDialog.PreProcessor.Add "DISPLAYNAME"  , objChildPriceableItemRowset.value("nm_display_name")
            MDMListDialog.PreProcessor.Add "DESCRIPTION"  , objChildPriceableItemRowset.value("nm_desc")

            EventArg.HTMLRendered = EventArg.HTMLRendered & MDMListDialog.PreProcess(sBuffer)

         objChildPriceableItemRowset.MoveNext
        next
        
        EventArg.HTMLRendered = EventArg.HTMLRendered & "</table></td>"
      
    end if
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</TABLE>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
    
    Form_DisplayDetailRow = TRUE
END FUNCTION

PRIVATE FUNCTION xForm_DisplayBeginOfPage(EventArg) ' As Boolean

	Dim objPreProcessor
	
	Inherited("Form_DisplayBeginOfPage(EventArg)")
	
	Set objPreProcessor = mdm_CreateObject(CPreProcessor)
	

	
	Select Case Request.QueryString("Tab")
		Case "1" '  Recurring Charge
			objPreProcessor.Add "ASP_PAGE",FrameWork.GetDictionary("NEW_RECURRING_WIZARD")
			objPreProcessor.Add "TEXT", FrameWork.GetDictionary("TEXT_CREATE_NEW_RECURRING_CHARGE")
			objPreProcessor.Add "APP_HTTP_PATH", FrameWork.GetDictionary("APP_HTTP_PATH")
			
			EventArg.HTMLRendered = objPreProcessor.Process(NEW_BUTTON_TEMPLATE) & vbNewLine & EventArg.HTMLRendered
						
		Case "2" ' Non Recurring Charge
			objPreProcessor.Add "ASP_PAGE",FrameWork.GetDictionary("NEW_NON_RECURRING_WIZARD")
			objPreProcessor.Add "TEXT", FrameWork.GetDictionary("TEXT_CREATE_NEW_NON_RECURRING_CHARGE")
			objPreProcessor.Add "APP_HTTP_PATH", FrameWork.GetDictionary("APP_HTTP_PATH")
			EventArg.HTMLRendered = objPreProcessor.Process(NEW_BUTTON_TEMPLATE) & vbNewLine & EventArg.HTMLRendered
	End Select
  Form_DisplayBeginOfPage = TRUE
END FUNCTION
%>
