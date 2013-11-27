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
Form.RouteTo        = FrameWork.GetDictionary("PRODUCT_OFFERING_LIST_DIALOG")
Form.ErrorHandler   = false

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

  If (Not IsEmpty(Request.QueryString("ID"))) Then
    Form("ID") = CLng(Request.QueryString("ID"))
  End if
  
  GetProductOffering TRUE

  Dim objMTProductCatalog, objMTProductOffering
  
  Set objMTProductCatalog                         = GetProductCatalogObject
  Set objMTProductOffering                        = objMTProductCatalog.GetProductOffering(Form("ID"))
  
  ' Save the id so we can use it on links in the page	
  mdm_GetDictionary().Add "CURRENT_PRODUCTOFFERING_ITEM_ID",Request.QueryString("ID")
  
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
  Form.Grids.Add "AccountTypeSubscriptionRestrictions", "Contained Priceable Items"
  
  ' Add property to for message if there are no Contained Priceable Items
  Service.Properties.Add "AccountTypeSubscriptionRestrictionsMessage", "String",  256, FALSE, TRUE 

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
    gObjMTTabs.AddTab "General", "/mcm/default/dialog/ProductOffering.ViewEdit.asp?ID=" & FORM("ID") & "&Tab=0"
  gObjMTTabs.AddTab "Properties", "/mcm/default/dialog/ProductOffering.Properties.asp?ID=" & FORM("ID")  & "&Tab=1"
  gObjMTTabs.AddTab "Included Items", "/mcm/default/dialog/ProductOffering.ViewEdit.Items.asp?ID=" & FORM("ID")  & "&Tab=2"
  gObjMTTabs.AddTab "Subscription Restrictions", "/mcm/default/dialog/ProductOffering.ViewEdit.SubscriptionRestrictions.asp?ID=" & FORM("ID")  & "&Tab=3"
      
    gObjMTTabs.Tab          = Clng(Request.QueryString("Tab"))		  
    strTabs                 = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
    Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)
  'SECENG: Fixing problems with output encoding  
  Service.Properties.Add "po_ve_rest_name", "String",  1024, FALSE, TRUE
  Service.Properties("po_ve_rest_name") = SafeForHtml(COMObject.Instance.Name)

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
      
    Set objMTProductCatalog                         = GetProductCatalogObject
    Dim objMTProductOffering
    Set objMTProductOffering                        = objMTProductCatalog.GetProductOffering(Form("ID"))
    dim rowset
    set rowset = objMTProductOffering.GetSubscribableAccountTypesAsRowset()
    'Set Form.Grids("AccountTypeSubscriptionRestrictions").MTCollection = COMObject.Instance.GetChildren()
    Set Form.Grids("AccountTypeSubscriptionRestrictions").Rowset = rowset 'COMObject.Instance.GetPriceableItemsAsRowset()
    'response.write "ContainedPriceableItems [" & Form.Grids("AccountTypeSubscriptionRestrictions").Rowset.RecordCount & "]<BR>"    
    'Form.Grids("AccountTypeSubscriptionRestrictions").Properties.SelectAll
    
    If Form.Grids("AccountTypeSubscriptionRestrictions").Rowset.RecordCount=0 Then
      Service.Properties("AccountTypeSubscriptionRestrictionsMessage") = FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_NO_ACCOUNT_TYPE_RESTRICTIONS_MESSAGE")
      Form.Grids("AccountTypeSubscriptionRestrictions").Visible = false
      FrameWork.Dictionary().Add "AccountTypeSubscriptionRestrictionsExist", FALSE
    Else   

        Form.Grids("AccountTypeSubscriptionRestrictions").Visible = true
        FrameWork.Dictionary().Add "AccountTypeSubscriptionRestrictionsExist", TRUE
        Service.Properties("AccountTypeSubscriptionRestrictionsMessage") = ""
   
        if false then 
          Form.Grids("AccountTypeSubscriptionRestrictions").Properties.SelectAll
        else     
          Form.Grids("AccountTypeSubscriptionRestrictions").Properties.ClearSelection
          Form.Grids("AccountTypeSubscriptionRestrictions").Properties("AccountTypeName").Selected 	  = 1
          Form.Grids("AccountTypeSubscriptionRestrictions").Properties("id_type").Selected 	  = 2
  
          Form.Grids("AccountTypeSubscriptionRestrictions").Properties("AccountTypeName").Caption = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
          Form.Grids("AccountTypeSubscriptionRestrictions").Properties("id_type").Caption = "&nbsp"
        end if				
        
        Form.Grids("AccountTypeSubscriptionRestrictions").Width = "100%"	
        Form.Grids("AccountTypeSubscriptionRestrictions").DefaultCellClass = "TableCell"
        Form.Grids("AccountTypeSubscriptionRestrictions").DefaultCellClassAlt = "TableCellAlt"
        
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
PRIVATE FUNCTION AccountTypeSubscriptionRestrictions_DisplayCell(EventArg) ' As Boolean
dim intKind, strJavaScript,strDicText

  'response.write  EventArg.Grid.SelectedProperty.Name & "<br>"
  Select Case lcase(EventArg.Grid.SelectedProperty.Name)
    Case "accounttypename"

      dim strIcon
      strIcon = "<img src='" & mdm_GetIconUrlForAccountType(EventArg.Grid.Rowset.Value("AccountTypeName")) & "' alt='' border='0' align='top'>&nbsp;"
      EventArg.HTMLRendered = "<td class='" & EventArg.Grid.CellClass & "'>" & strIcon & "&nbsp;" & EventArg.Grid.Rowset.Value("AccountTypeName") & "</td>"
                           
      AccountTypeSubscriptionRestrictions_DisplayCell = TRUE

  
    case "id_type"
      strDicText 	  = Replace(FrameWork.GetDictionary("TEXT_CONFIRM_REMOVE_PRICEABLE_ITEM"),"{PI_NAME}",EventArg.Grid.Rowset.Value("AccountTypeName"))			
      strJavaScript = strJavaScript & "if(confirm(""" & replace(strDicText,"'","") & """)){"
  
      strJavaScript = strJavaScript & "	document.mdm.mdmUserCustom.value = ""[ID]""; mdm_RefreshDialog(""RemoveAccountTypeRestriction"");"
      strJavaScript = strJavaScript & "	return true;"
      strJavaScript = strJavaScript & "}else{"
      strJavaScript = strJavaScript & "	return false;" ' By returning false we cancel the OnClick event
      strJavaScript = strJavaScript & "}"
  
      EventArg.HTMLRendered =  EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "'>"       
  
      EventArg.HTMLRendered =  EventArg.HTMLRendered & "<Button Name='RemoveAccountTypeRestriction' Class='clsButtonBlueMedium' OnClick='[JAVASCRIPT]'>"
      EventArg.HTMLRendered =  EventArg.HTMLRendered & FrameWork.GetDictionary("TEXT_BUTTON_REMOVE_PRICEABLE_ITEM")
      EventArg.HTMLRendered =  EventArg.HTMLRendered & "</Button>"
      
      EventArg.HTMLRendered =  EventArg.HTMLRendered & "</td>"
      
      EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"[JAVASCRIPT]", strJavaScript)
      EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"[ID]", EventArg.Grid.Rowset.Value("id_type")) ' Must be rendered after the JAVASCRIPT
      
      AccountTypeSubscriptionRestrictions_DisplayCell = TRUE
      ' EventArg.HTMLRendered  = EventArg.HTMLRendered & "</td>"   
    Case else
      AccountTypeSubscriptionRestrictions_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
  End Select

END FUNCTION

PRIVATE FUNCTION RemoveAccountTypeRestriction_Click(EventArg)

	If(Len(mdm_UIValue("mdmUserCustom")))Then
	
		If(IsNumeric(mdm_UIValue("mdmUserCustom")))Then
		
			On Error Resume Next
			COMObject.Instance.RemoveSubscribableAccountType(Clng(mdm_UIValue("mdmUserCustom")))
			If(Err.Number)Then
		    
		        EventArg.Error.Save Err
		        RemoveAccountTypeRestriction_Click = FALSE
		        'Err.Clear  Do not clear the error so it can be returned to the MDM error manager
		    Else
		        RemoveAccountTypeRestriction_Click = TRUE
		    End If
		End if
	End if						 
END FUNCTION
%>
