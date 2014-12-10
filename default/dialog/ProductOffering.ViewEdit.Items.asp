<% 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' MetraTech Dialog Manager Demo
' 
' DIALOG	    : MCM Dialog
' DESCRIPTION	: 
' AUTHOR	    : F.Torres
' VERSION	    : 1.0
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE FILE="../lib/TabsClass.asp" -->

<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler   = true

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  If (Not IsEmpty(Request.QueryString("ID"))) Then
    Form("ID") = CLng(Request.QueryString("ID"))
  Else
    Form("ID") = session("POID")
  End if
  
  Form.Modal = TRUE   ' Tell the MDM this dialog is open in a  pop up window. 
                      ' The OK and CANCEL event will not terminate the dialog
                      ' but do a last rendering/refresh.
  
  GetProductOffering TRUE

  Dim objMTProductCatalog, objMTProductOffering
  
  Set objMTProductCatalog                         = GetProductCatalogObject
  'Set objMTProductOffering                        = objMTProductCatalog.GetProductOffering(Form("ID"))
  
  ' Save the id so we can use it on links in the page
  If (Not IsEmpty(Request.QueryString("ID"))) Then
     mdm_GetDictionary().Add "CURRENT_PRODUCTOFFERING_ITEM_ID",Request.QueryString("ID")
  Else
     mdm_GetDictionary().Add "CURRENT_PRODUCTOFFERING_ITEM_ID",Form("ID")
  End If
  
  ' Find the ProductOffering and store it into the MDM COM Object, this will take care of the sub object like EffectiveDate  
  'response.write("PO Properties count [" & objMTProductOffering.Properties.count &"]<BR>")
  'response.write("MDM Properties count [" & COMObject.Properties.count &"]<BR>")
  'response.end
  
  COMObject.Properties("SelfUnSubscribable").Caption        = FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_SELFUNSUBSCRIBABLE")
  COMObject.Properties("SelfSubscribable").Caption          = FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_SELFSUBSCRIBABLE")
  COMObject.Properties("EffectiveDate__StartDate").Caption   = FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_EFFECTIVEDATE_STARTDATE")
  COMObject.Properties("EffectiveDate__EndDate").Caption     = FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_EFFECTIVEDATE_ENDDATE")
  COMObject.Properties("AvailabilityDate__StartDate").Caption = FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_AVAILABILITYDATE_STARTDATE")
  COMObject.Properties("AvailabilityDate__EndDate").Caption  = FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_AVAILABILITYDATE_ENDDATE")
  

  ' Create and define the Contained Priceable Items Grid that is populated in the Form_Refresh()
  Form.Grids.Add "ContainedPriceableItems", "Contained Priceable Items"
  
  ' Add property to for message if there are no Contained Priceable Items
  Service.Properties.Add "ContainedPriceableItemsMessage", "String",  256, FALSE, TRUE 

  ' Add property to for message if there are no Contained Priceable Items
  COMObject.Properties.Add "CURRENCYCODE", "String",  256, FALSE, TRUE
  COMObject.Properties("CURRENCYCODE") = COMObject.Instance.GetCurrencyCode()

  ' Create and define the Extended Properties Grid
  Form.Grids.Add "ExtendedProperties", "Extended Properties"
  Set Form.Grids("ExtendedProperties").MTProperties(MTPROPERTY_EXTENDED) = COMObject.Instance.Properties

  Form.Grids("ExtendedProperties").Properties.ClearSelection
  Form.Grids("ExtendedProperties").Properties("Name").Selected    = 1
  Form.Grids("ExtendedProperties").Properties("Value").Selected   = 2
  
  Form.Grids("ExtendedProperties").ShowHeaders=False
  Form.Grids("ExtendedProperties").DefaultCellClass = "captionEW"
  Form.Grids("ExtendedProperties").DefaultCellClassAlt = "captionEW"
  COMObject.Properties.Enabled              = FALSE ' Every control is grayed
  Form.Grids.Enabled                        = FALSE ' All Grid are not enabled    

  ' Dynamically Add Tabs to template
  Dim strTabs  
  gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_GENERAL_TAB"), "/mcm/default/dialog/ProductOffering.ViewEdit.asp?ID=" & FORM("ID") & "&Tab=0"
  
  If Not(Session("isPartitionUser")) Then
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_PROPERTIES_TAB"), "/mcm/default/dialog/ProductOffering.Properties.asp?ID=" & FORM("ID")  & "&Tab=1"
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_INCLUDED_ITEMS_TAB"), "/mcm/default/dialog/ProductOffering.ViewEdit.Items.asp?ID=" & FORM("ID")  & "&Tab=2"
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_SUBSCRIPTION_RESTRICTIONS_TAB"), "/mcm/default/dialog/ProductOffering.ViewEdit.SubscriptionRestrictions.asp?ID=" & FORM("ID")  & "&Tab=3"
  End If
      
    gObjMTTabs.Tab          = Clng(Request.QueryString("Tab"))		  
    strTabs                 = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
    Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)
  'SECENG: Fixing problems with output encoding
  Service.Properties.Add "po_ve_items_name", "String",  1024, FALSE, TRUE
  Service.Properties("po_ve_items_name") = SafeForHtml(COMObject.Instance.Name)
  
 Form_Initialize = Form_Refresh(EventArg)
    
END FUNCTION


PRIVATE FUNCTION GetProductOffering(booFromInitializeEvent) ' As Boolean

    Dim objMTProductCatalog, objMTProductOffering
  
    Set objMTProductCatalog                         = GetProductCatalogObject
    Set objMTProductOffering                        = objMTProductCatalog.GetProductOffering(Form("ID"))
    Set COMObject.Instance(booFromInitializeEvent)  = objMTProductOffering
    GetProductOffering                              = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : 
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean

    
    GetProductOffering FALSE ' False called from refresh event...

    If COMObject.Instance.Hidden Then
      Response.redirect Form.RouteTo
    End If
    
    ' Check to see if this PO can be modified, if not display a warning  
    If Not CBool(COMObject.Instance.CanBeModified()) Then
      mdm_GetDictionary().Add "CAN_NOT_BE_MODIFIED", "TRUE"
    Else
      mdm_GetDictionary().Add "CAN_NOT_BE_MODIFIED", "FALSE"  
    End If

    ' Check to see if this PO can be modified, if not display a warning  
    If len(Request("UpdateNav"))>0 Then
      mcmTriggerUpdateOfPONavigationPane
    End If

     
    Dim objMTProductCatalog, objMTPriceableItem
    

    ' See if we need to Add a recurring charge
    If len(Request("AddItem")) <> 0 Then
        'response.write("Adding recurring charge<BR>")
        dim intRecurringChargeId
        intRecurringChargeId = Clng(Request("AddItem"))
        
  
        Set objMTProductCatalog = GetProductCatalogObject
        Set objMTPriceableItem = objMTProductCatalog.GetPriceableItem(intRecurringChargeId)
        
        COMObject.Instance.AddPriceableItem objMTPriceableItem
        COMObject.Instance.Save
        
        'COMObject.Instance.SetPriceListMapping Clng(Request("PARAMTABLEID")), Clng(Request("PICKERIDS"))
    End If
 
  
    If len(Request("PICKERIDS")) <> 0 Then
    
        'Dim objMTProductCatalog, objMTPriceableItem
  
        Set objMTProductCatalog = GetProductCatalogObject

        dim strPickerIDs, arrPickerIDs
        strPickerIDs = request("PICKERIDS")
        arrPickerIDs = Split(strPickerIDs, ",", -1, 1)
        
        ' "Picker returned [" & strPickerIDs & "]<BR>"
        
        dim intPriceableItemId
        dim i
        for i=0 to ubound(arrPickerIDs)
          intPriceableItemId = CLng(arrPickerIDs(i))
          'response.write("Adding PI [" & intPriceableItemId & "]<BR>")
          set objMTPriceableItem = objMTProductCatalog.GetPriceableItem(intPriceableItemId)
          COMObject.Instance.AddPriceableItem objMTPriceableItem
        next
        
        COMObject.Instance.Save
        
    End If
    
    
    'Set Form.Grids("ContainedPriceableItems").MTCollection = COMObject.Instance.GetChildren()
    Set Form.Grids("ContainedPriceableItems").Rowset = COMObject.Instance.GetPriceableItemsAsRowset()
    'response.write "ContainedPriceableItems [" & Form.Grids("ContainedPriceableItems").Rowset.RecordCount & "]<BR>"    
    'Form.Grids("ContainedPriceableItems").Properties.SelectAll
        
    If Form.Grids("ContainedPriceableItems").Rowset.RecordCount=0 Then
      Service.Properties("ContainedPriceableItemsMessage") = "<img align='top' border=0 src='" & FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/icons/warningSmall.gif'>&nbsp;" & FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_NO_CHILD_ITEMS")
      Form.Grids("ContainedPriceableItems").Visible = false
      FrameWork.Dictionary().Add "ChildItems", FALSE
    Else   

        Form.Grids("ContainedPriceableItems").Visible = true
        FrameWork.Dictionary().Add "ChildItems", TRUE
        Service.Properties("ContainedPriceableItemsMessage") = ""
   
        if false then 
          Form.Grids("ContainedPriceableItems").Properties.SelectAll
        else     
          Form.Grids("ContainedPriceableItems").Properties.ClearSelection
          Form.Grids("ContainedPriceableItems").Properties("nm_name").Selected 	  = 1
          Form.Grids("ContainedPriceableItems").Properties("n_kind").Selected       = 2
          Form.Grids("ContainedPriceableItems").Properties("nm_desc").Selected      = 3
    		  Form.Grids("ContainedPriceableItems").Properties("nm_display_name").Selected  = 4
        end if
        'Form.Grids("ContainedPriceableItems").Properties("nm_glcode").Selected 	   = 4 
        
        Form.Grids("ContainedPriceableItems").Properties("nm_name").Caption 		= FrameWork.GetDictionary("TEXT_COLUMN_NAME")
        Form.Grids("ContainedPriceableItems").Properties("n_kind").Caption 		= FrameWork.GetDictionary("TEXT_COLUMN_KIND")
        Form.Grids("ContainedPriceableItems").Properties("nm_desc").Caption 	  = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
				If FrameWork.GetDictionary("TEXT_COLUMN_OPTIONS") <> "" Then
    	  	Form.Grids("ContainedPriceableItems").Properties("nm_display_name").Caption = FrameWork.GetDictionary("TEXT_COLUMN_OPTIONS")
				Else
    	  	Form.Grids("ContainedPriceableItems").Properties("nm_display_name").Caption = "&nbsp"
				End If
				
        
        'Form.Grids("ContainedPriceableItems").Properties("nm_glcode").Caption = FrameWork.GetDictionary("TEXT_COLUMN_GLCODE")
        
        
        Form.Grids("ContainedPriceableItems").Width = "100%"	
        Form.Grids("ContainedPriceableItems").DefaultCellClass = "TableCell"
        Form.Grids("ContainedPriceableItems").DefaultCellClassAlt = "TableCellAlt"
        
    End If  
    Form_Refresh = TRUE
    
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

    On Error Resume Next
    COMObject.Instance.Save
    If(Err.Number)Then
    
        EventArg.Error.Save Err
        OK_Click = FALSE
        Err.Clear
    Else
        OK_Click = TRUE
    End If    
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Edit_Click(EventArg) ' As Boolean

    Service.Properties.Enabled                = Not Service.Properties.Enabled 
    Form.Grids("ExtendedProperties").Enabled  = Service.Properties.Enabled
    Edit_Click = TRUE
END FUNCTION



' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : CompoundPriceableItems_DisplayCell
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION ContainedPriceableItems_DisplayCell(EventArg) ' As Boolean
dim intKind, strJavaScript,strDicText

  'response.write  EventArg.Grid.SelectedProperty.Name & "<br>"
  Select Case lcase(EventArg.Grid.SelectedProperty.Name)
    Case "nm_name"

      dim strUrl
      intKind = CLng(EventArg.Grid.Rowset.Value("n_kind"))
      Select Case intKind
        Case PI_TYPE_USAGE 
          strUrl = "PriceAbleItem.Usage.ViewEdit.asp"
        Case PI_TYPE_USAGE_AGGREGATE 
          strUrl = "PriceAbleItem.Usage.ViewEdit.asp"                
        Case PI_TYPE_RECURRING, PI_TYPE_RECURRING_UNIT_DEPENDENT
          strUrl = "PriceAbleItem.RecurringCharge.ViewEdit.asp"
        Case PI_TYPE_NON_RECURRING
          strUrl = "PriceAbleItem.NonRecurring.ViewEdit.asp"
        Case PI_TYPE_DISCOUNT
          strUrl = "PriceAbleItem.Discount.ViewEdit.asp"
      End Select
      dim strIcon
      strIcon = "<img src='" & mdm_GetIconUrlForPriceableItem(EventArg.Grid.Rowset.Value("nm_name"),intKind) & "' alt='' border='0' align='top'>&nbsp;"
    ' We put a name of the anchor for FredRunner
      'SECENG: Added HTML encoding
      EventArg.HTMLRendered = "<td class='" & EventArg.Grid.CellClass & "'>" & strIcon & "<a Name='" & EventArg.Grid.Rowset.Value("id_prop") & "' href='" & strUrl & "?ID=" & _
                                EventArg.Grid.Rowset.Value("id_prop") & "&EditMode=False&POBased=True&AUTOMATIC=False&Kind=" & EventArg.Grid.Rowset.Value("n_kind") & _
                                "&mdmReload=True&POID=" & Form("ID") & "'>" & SafeForHtml(EventArg.Grid.Rowset.Value("nm_name")) & "</a></td>"
                           
      ContainedPriceableItems_DisplayCell = TRUE
    Case "n_kind"
  
      dim strValue
      intKind = CLng(EventArg.Grid.Rowset.Value("n_kind"))
  
      Select Case intKind
        Case PI_TYPE_USAGE 
          strValue = FrameWork.GetDictionary("TEXT_KEYTERM_USAGE_CHARGE")
        Case PI_TYPE_USAGE_AGGREGATE 
          strValue = FrameWork.GetDictionary("TEXT_KEYTERM_USAGE_CHARGE_AGGREGATE")
        Case PI_TYPE_RECURRING, PI_TYPE_RECURRING_UNIT_DEPENDENT
          strValue = FrameWork.GetDictionary("TEXT_KEYTERM_RECURRING_CHARGE")
        Case PI_TYPE_NON_RECURRING
          strValue = FrameWork.GetDictionary("TEXT_KEYTERM_NON_RECURRING_CHARGE")
        Case PI_TYPE_DISCOUNT
          strValue = FrameWork.GetDictionary("TEXT_KEYTERM_DISCOUNT")
        Case else
          strValue = ""
      End Select
  
  
      EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'>" & strValue & "</td>"
      ContainedPriceableItems_DisplayCell = TRUE
  
    case "nm_display_name"
      'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
      'Adding HTML Encoding
      'strDicText 	  = Replace(FrameWork.GetDictionary("TEXT_CONFIRM_REMOVE_PRICEABLE_ITEM"),"{PI_NAME}",EventArg.Grid.Rowset.Value("nm_name"))
      strDicText 	  = Replace(FrameWork.GetDictionary("TEXT_CONFIRM_REMOVE_PRICEABLE_ITEM"),"{PI_NAME}",SafeForJS(EventArg.Grid.Rowset.Value("nm_name")))			
      strJavaScript = strJavaScript & "if(confirm(""" & replace(strDicText,"'","") & """)){"
  
      strJavaScript = strJavaScript & "	document.mdm.mdmUserCustom.value = ""[ID]""; mdm_RefreshDialog(""RemovePriceableItem"");"
      strJavaScript = strJavaScript & "	return true;"
      strJavaScript = strJavaScript & "}else{"
      strJavaScript = strJavaScript & "	return false;" ' By returning false we cancel the OnClick event
      strJavaScript = strJavaScript & "}"
  
      EventArg.HTMLRendered =  EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "'>"       
  
      EventArg.HTMLRendered =  EventArg.HTMLRendered & "<Button Name='RemovePriceableItem' Class='clsButtonBlueMedium' OnClick='[JAVASCRIPT]'>"
      EventArg.HTMLRendered =  EventArg.HTMLRendered & FrameWork.GetDictionary("TEXT_BUTTON_REMOVE_PRICEABLE_ITEM")
      EventArg.HTMLRendered =  EventArg.HTMLRendered & "</Button>"
      
      EventArg.HTMLRendered =  EventArg.HTMLRendered & "</td>"
      
      EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"[JAVASCRIPT]", strJavaScript)
      EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"[ID]", EventArg.Grid.Rowset.Value("id_prop")) ' Must be rendered after the JAVASCRIPT
      
      ContainedPriceableItems_DisplayCell = TRUE
      ' EventArg.HTMLRendered  = EventArg.HTMLRendered & "</td>"   
    Case "nm_desc"
      EventArg.HTMLRendered =  EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "'>"
      EventArg.HTMLRendered =  EventArg.HTMLRendered & SafeForHtml(EventArg.Grid.Rowset.Value("nm_desc"))
      EventArg.HTMLRendered =  EventArg.HTMLRendered & "</td>"
      ContainedPriceableItems_DisplayCell = TRUE
    Case else
      ContainedPriceableItems_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
  End Select

END FUNCTION

PRIVATE FUNCTION RemovePriceableItem_Click(EventArg)

	If(Len(mdm_UIValue("mdmUserCustom")))Then
	
		If(IsNumeric(mdm_UIValue("mdmUserCustom")))Then
		
			On Error Resume Next
			Dim objPI
      set objPI = COMObject.Instance.GetPriceableItem(Clng(mdm_UIValue("mdmUserCustom")))
      If not IsEmpty(objPI)  then
          COMObject.Instance.RemovePriceableItem(Clng(mdm_UIValue("mdmUserCustom")))
			    If(Err.Number)Then
		    
		            EventArg.Error.Save Err
		            RemovePriceableItem_Click = FALSE
		            'Err.Clear  Do not clear the error so it can be returned to the MDM error manager
		        Else
                mcmTriggerUpdateOfPONavigationPane
		            RemovePriceableItem_Click = TRUE
		        End If
     End if
		End if
	End if						 
END FUNCTION
%>
