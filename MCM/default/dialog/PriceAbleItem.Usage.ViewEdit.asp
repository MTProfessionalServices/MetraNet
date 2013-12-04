<% 
' ---------------------------------------------------------------------------------------------------------
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
' ---------------------------------------------------------------------------------------------------------
'
' MetraTech Dialog Manager Demo
' 
' DIALOG	    : MCM Dialog
' DESCRIPTION	: 
' AUTHOR	    : F.Torres, K.Boucher
' VERSION	    : 2.0
'
' ---------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE FILE="../lib/TabsClass.asp" -->
<%
'Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE
Form.RouteTo        = FrameWork.GetDictionary("SERVICE_CHARGES_USAGE_LIST")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
  
	Dim strTabs
  
	FORM("ID")      = Request.QueryString("ID")
	FORM("POID")    = Request.QueryString("POID")
  FORM("POBased") = UCase(Request.QueryString("POBased"))
  
	mdm_GetDictionary().Add "CURRENT_PO_BASED",Form("POBased")
  mdm_GetDictionary().Add "IS_PO_BASED", UCase(Form("POBased"))="TRUE"
	  
	if UCase(Request.QueryString("EditMode")) = "TRUE" Then
	  FrameWork.Dictionary().Add "ShowOKButton", TRUE
	  FrameWork.Dictionary().Add "ShowCancelButton",TRUE
	  FrameWork.Dictionary().Add "ShowEditButton",FALSE
	else
	  FrameWork.Dictionary().Add "ShowOKButton", FALSE
    FrameWork.Dictionary().Add "ShowCancelButton",FALSE
	  FrameWork.Dictionary().Add "ShowEditButton",TRUE
	End if   
  
 ' FrameWork.Dictionary().Add "ShowBillingCycle", CBool (len(UCase(Form("KIND")) = Cstr(PI_TYPE_USAGE_AGGREGATE)))

  Service.Properties.Add "TabStyle", "String",  256, FALSE, TRUE 
	Service.Properties("TabStyle") = ""
  
  Service.Properties.Add "ParameterMessage", "String",  256, FALSE, TRUE 
	Service.Properties("ParameterMessage") = FrameWork.GetDictionary("TEXT_PARAMETER_TABLE_TITLE")


 
  Service.Properties.Add "ContainedPriceableItemsMessage", "String",  256, FALSE, TRUE 
    
	mdm_GetDictionary().Add "CURRENT_PRICE_ABLE_ITEM_ID",Request.QueryString("ID")
  mdm_GetDictionary().Add "POID",Request.QueryString("POID")
'	mdm_GetDictionary().Add "CURRENT_PRICE_ABLE_ITEM_KIND",Form("KIND")
  
  Form.Grids.Add "ExtendedProperties"       ', "Extended Properties"
  Form.Grids.Add "ContainedPriceableItems"  ', "Compound Priceable Items"
  Form.Grids.Add "ContainedParameterTables" 
 
  Form_Refresh EventArg	
  
  If UCase(Request.QueryString("POBased")) <> "TRUE" Then
  
    Service.Properties("TabStyle") = "class='clsTabAngleTopSelected'"
    Service.Properties.Add "ParameterMessage", "String",  256, FALSE, TRUE 
    Service.Properties("ParameterMessage") = ""
    FrameWork.Dictionary().Add "PARAMIf",FALSE
    
    ' Dynamically Add Tabs to template
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_USAGE_CHARGES"), "[SERVICE_CHARGES_USAGE_LIST]"
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_RECURRING_CHARGES") , "[SERVICE_CHARGES_RECURRING_LIST]"
    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_NON_RECURRING_CHARGES") , "[SERVICE_CHARGES_NONRECURRING_LIST]"
      
    gObjMTTabs.Tab          = Clng(Request.QueryString("Tab"))		  
    strTabs                 = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
    Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)
      
	Else
  
    mcmDrawTabsForPriceableItem COMObject.Instance.Name, COMObject.Instance.Kind, 1

    Service.Properties.Add "ParameterMessage", "String",  256, FALSE, TRUE 
    Service.Properties("ParameterMessage") = FrameWork.GetDictionary("TEXT_PARAMETER_TABLE_TITLE")
    FrameWork.Dictionary().Add "PARAMIf",TRUE
    
    Dim objMTProductCatalog, objProductOffering
    Set objMTProductCatalog = GetProductCatalogObject
    Set objProductOffering = objMTProductCatalog.GetProductOffering(FORM("POID"))
    Form("NonSharedPLID") = objProductOffering.NonSharedPriceListID
      
	End if
  
  mdm_GetDictionary().Add "CURRENT_PRICE_ABLE_ITEM_KIND",Form("KIND") 
  FrameWork.Dictionary().Add "ShowBillingCycle", CBool ( UCase(Form("KIND")) = Cstr(PI_TYPE_USAGE_AGGREGATE) )
 
  FrameWork.Dictionary().Add "BulkMapButton", "<button class=""clsButtonBlueMedium"" name=""EditMapping"" onclick=""window.open('PriceListMapping.Edit.asp?MapAll=TRUE&NonSharedPLID=" & Form("NonSharedPLID") & "&PI_ID=" & FORM("ID") & "&NextPage=PriceableItem.Usage.ViewEdit.asp&MonoSelect=TRUE&Title=TEXT_SELECT_PRICELIST_MAPPING&Parameters=PickerAddMapping|TRUE;""','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes')"">" & FrameWork.GetDictionary("TEXT_EDIT") &  "</button></td>"                       

 
  Form.Grids.Enabled          =  CBool(UCase(Request("EditMode")) = "TRUE")
  Service.Properties.Enabled  =  CBool(UCase(Request("EditMode")) = "TRUE")
  'SECENG: Fixing problems with output encoding  
  Service.Properties.Add "pai_usage_ve_name", "String",  1024, FALSE, TRUE
  Service.Properties("pai_usage_ve_name") = SafeForHtml(COMObject.Instance.Name)
  
  Form_Initialize             = TRUE
END FUNCTION
' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Refresh
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean
    Dim objMTProductCatalog
    Set objMTProductCatalog = GetProductCatalogObject    
    
    ' Find the PriceableItem and store it into the MDM COM Object    
    Set COMObject.Instance = objMTProductCatalog.GetPriceableItem(CLng(Request.QueryString("ID"))) ' We map the dialog with a COM Object not an MT Service

    Form("Kind") = ComObject.Properties("Kind")

    If UCase(Form("KIND")) = Cstr(PI_TYPE_USAGE_AGGREGATE) Then
      ProductCatalogBillingCycle.Form_Initialize Form
    Else
      ProductCatalogBillingCycle.ClearInsertTag Form
	  End If    
	 	
    If Not IsValidObject(COMObject.Instance) Then
      response.write FrameWork.GetDictionary("ERROR_ITEM_NOT_FOUND") & Request.QueryString("ID")
      response.end
    End If
       
    ' Create and define the Extended Properties Grid    

    Set Form.Grids("ExtendedProperties").MTProperties(MTPROPERTY_EXTENDED) = COMObject.Instance.Properties
    Form.Grids("ExtendedProperties").Properties.ClearSelection
    Form.Grids("ExtendedProperties").Properties("Name").Selected    = 1
    Form.Grids("ExtendedProperties").Properties("Value").Selected   = 2
    
    Form.Grids("ExtendedProperties").Properties("Name").Caption 		= FrameWork.GetDictionary("TEXT_COLUMN_NAME")
    Form.Grids("ExtendedProperties").Properties("Value").Caption 	  = FrameWork.GetDictionary("TEXT_COLUMN_VALUE")

    Form.Grids("ExtendedProperties").ShowHeaders            = False
    Form.Grids("ExtendedProperties").DefaultCellClass       = "captionEW"
    Form.Grids("ExtendedProperties").DefaultCellClassAlt    = "captionEW"
    
    ' Create and define the Compound Priceable Items Grid
    Set Form.Grids("ContainedPriceableItems").MTCollection = COMObject.Instance.GetChildren()
    'response.write("child record count [" & COMObject.Instance.GetChildren.Count & "]<BR>")

    If Not IsValidObject(Form.Grids("ContainedPriceableItems").Properties("name")) Then
      Service.Properties("ContainedPriceableItemsMessage") = FrameWork.GetDictionary("TEXT_NO_CHILD_ITEMS")
      Form.Grids("ContainedPriceableItems").Visible = false
      FrameWork.Dictionary().Add "ChildItems",FALSE
    Else    
      Form.Grids("ContainedPriceableItems").Properties.ClearSelection
      Form.Grids("ContainedPriceableItems").Properties("name").Selected 			  = 1
      Form.Grids("ContainedPriceableItems").Properties("kind").Selected       = 2
      Form.Grids("ContainedPriceableItems").Properties("description").Selected  = 3
      
      'Form.Grids("ContainedPriceableItems").Properties("glcode").Selected 	  	= 3 
      'Form.Grids("ContainedPriceableItems").Properties.SelectAll

      Form.Grids("ContainedPriceableItems").Properties("name").Caption 		        = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
      Form.Grids("ContainedPriceableItems").Properties("kind").Caption 		= FrameWork.GetDictionary("TEXT_COLUMN_KIND")
      Form.Grids("ContainedPriceableItems").Properties("description").Caption 	  = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
      'Form.Grids("ContainedPriceableItems").Properties("glcode").Caption          = FrameWork.GetDictionary("TEXT_COLUMN_GLCODE")
      
      'Form.Grids("ContainedPriceableItems").Width = "100%"
      Form.Grids("ContainedPriceableItems").DefaultCellClass    = "TableCell"
      Form.Grids("ContainedPriceableItems").DefaultCellClassAlt = "TableCellAlt"
      Form.Grids("ContainedPriceableItems").Visible = true
      
      Service.Properties("ContainedPriceableItemsMessage") = "" 
      FrameWork.Dictionary().Add "ChildItems",TRUE

    End If  


    ' Add a property that contains the 'rowset empty' message
  	Service.Properties.Add "ParameterTableMessage", "String",  256, FALSE, TRUE  
   	Service.Properties("ParameterTableMessage") = Empty
  
	  if UCase(Request.QueryString("PickerAddMapping")) = "TRUE" then
    
		    'response.write("Adding pricelist mapping<BR>")
		    COMObject.Instance.SetPriceListMapping Clng(Request("PARAMTABLEID")), Clng(Request("PICKERIDS"))
	  end if

    Set Form.Grids("ContainedParameterTables").Rowset = COMObject.Instance.GetNonICBPriceListMappingsAsRowset()
    
    if Form.Grids("ContainedParameterTables").Rowset.recordcount = 0 then
    
  	  	If UCase(Form("POBased")) = "TRUE" Then
        
  		      Service.Properties("ParameterTableMessage") = FrameWork.GetDictionary("ERROR_ITEM_NO_PARAMETER_TABLES")
  		  else
        
  			   Service.Properties("ParameterTableMessage") = ""
  	    end if		   
        Form.Grids("ContainedParameterTables").Visible = false
        
    Else
    
        Form.Grids("ContainedParameterTables").Properties.ClearSelection
        Form.Grids("ContainedParameterTables").Properties("tpt_nm_name").Selected  = 1
        'Form.Grids("ContainedParameterTables").Properties("id_paramtable").Selected = 5
        Form.Grids("ContainedParameterTables").Properties("tpl_nm_name").Selected = 2
        Form.Grids("ContainedParameterTables").Properties("b_canICB").Selected = 3
        Form.Grids("ContainedParameterTables").Properties("id_pricelist").Selected  = 4
    
        Form.Grids("ContainedParameterTables").Properties("tpt_nm_name").Caption = FrameWork.GetDictionary("TEXT_PARAMETER_TABLE")
        'Form.Grids("ContainedParameterTables").Properties("id_paramtable").Caption = "id_paramtable"
        Form.Grids("ContainedParameterTables").Properties("tpl_nm_name").Caption = FrameWork.GetDictionary("TEXT_PRICELIST_MAPPING") 
        Form.Grids("ContainedParameterTables").Properties("b_canICB").Caption = FrameWork.GetDictionary("TEXT_PERSONAL_RATES_ALLOWED")     
        Form.Grids("ContainedParameterTables").Properties("id_pricelist").Caption = "&nbsp;"
       
        Form.Grids("ContainedParameterTables").DefaultCellClass = "TableCell"
        Form.Grids("ContainedParameterTables").DefaultCellClassAlt = "TableCellAlt"
        
        Form.Grids("ContainedParameterTables").Visible = TRUE
     End If
     
     COMObject.Properties.Enabled = FALSE

     Form_Refresh                 = TRUE

END FUNCTION


' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
	
	Ok_Click = FALSE

	if UCase(Form("KIND")) = Cstr(PI_TYPE_USAGE_AGGREGATE) Then
  		If(Not ProductCatalogBillingCycle.UpdateProperties())Then Exit Function
	END if

    On Error Resume Next
    COMObject.Instance.Save
    If(Err.Number)Then
    
        EventArg.Error.Save Err
        OK_Click = FALSE
        Err.Clear
    Else
        OK_Click = TRUE
    End If 
		SetRouteToPage	   
END FUNCTION

PRIVATE FUNCTION CANCEL_Click(EventArg) ' As Boolean
	SetRouteToPage	
END FUNCTION


PRIVATE FUNCTION SetRouteToPage()
	If Form("POBased") = "TRUE" Then
	    'PRODUCTOFFERING_VIEW_EDIT_DIALOG
				
		Form.RouteTo = FrameWork.GetDictionary("PRODUCTOFFERING_VIEW_EDIT_DIALOG") & "?ID=" & FORM("POID") 
	Else
		Form.RouteTo = FrameWork.GetDictionary("SERVICE_CHARGES_USAGE_LIST") 
	End If
END FUNCTION


' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Edit_Click(EventArg) ' As Boolean
    Service.Properties.Enabled = Not Service.Properties.Enabled 
    Form.Grids.Enabled            =     Service.Properties.Enabled 
    Edit_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : CompoundPriceableItems_DisplayCell
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION ContainedPriceableItems_DisplayCell(EventArg) ' As Boolean

Dim MTPOBased
   MTPOBased = Request.QueryString("POBased")
   if MTPOBased = "" then
      MTPOBased = FALSE
   End if

    Select Case lcase(EventArg.Grid.SelectedProperty.Name)
        Case "name"
            EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'><a name='" & EventArg.Grid.Rowset.Value("ID") & "' href='PriceableItem.Usage.ViewEdit.asp?ID=" & _
                                         EventArg.Grid.Rowset.Value("ID") & "&POBased=" & MTPOBased & "&POID=" & FORM("POID") & "&Kind=" & EventArg.Grid.Rowset.Value("KIND") &  _
                                         "&mdmReload=True'>" & EventArg.Grid.Rowset.Value("name") & "</a></td>"
                                         
            'EventArg.HTMLRendered     =  "<td class='GridCell'><a href='PriceableItem.Usage.ViewEdit.asp?ID=" & _
            '                             EventArg.Grid.Rowset.Value("ID") & "&Kind=" & Request("Kind") & _
            '                             "&mdmReload=True'><img border=0 src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif'>" & EventArg.Grid.Rowset.Value("name") & "</a></td>"

            ContainedPriceableItems_DisplayCell = TRUE
        

                    
        Case "kind"
           
            dim strValue
            dim intKind
            intKind = CLng(EventArg.Grid.Rowset.Value("kind"))
            
            Select Case intKind
              Case PI_TYPE_USAGE 
                strValue = FrameWork.GetDictionary("TEXT_KEYTERM_USAGE_CHARGE")
              Case PI_TYPE_USAGE_AGGREGATE 
                strValue = FrameWork.GetDictionary("TEXT_KEYTERM_USAGE_CHARGE_AGGREGATE")
              Case PI_TYPE_RECURRING
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
            
        Case else
            ContainedPriceableItems_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
    End Select

END FUNCTION


' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : ContainedParameterTables_DisplayCell
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION ContainedParameterTables_DisplayCell(EventArg) ' As Boolean

  Select Case lcase(EventArg.Grid.SelectedProperty.Name)
  Case "tpt_nm_name"

    dim sParamTableName
    sParamTableName = EventArg.Grid.Rowset.Value("nm_display_name")
    if isNull(sParamTableName) or len(sParamTableName) = 0 then
      sParamTableName = EventArg.Grid.Rowset.Value("tpt_nm_name")
    'else
    '  sParamTableName = sParamTableName & "&nbsp;(" & EventArg.Grid.Rowset.Value("tpt_nm_name") & ")"
    end if
    
    EventArg.HTMLRendered     =  "<td title='" & EventArg.Grid.Rowset.Value("tpt_nm_name") & "' class='" & EventArg.Grid.CellClass & "'>" & sParamTableName & "</td>"            
    ContainedParameterTables_DisplayCell = TRUE			

    Case "tpl_nm_name"
    
      dim strName
      strName = "" & EventArg.Grid.Rowset.Value("tpl_nm_name")          
      ' See if we have a pricelist mapping
      if LTRIM(RTRIM(strName)) = "" then
        strName = "<img align='top' border=0 src='" & FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/icons/warningSmall.gif'>" & FrameWork.GetDictionary("TEXT_NO_PRICE_LIST_MAPPING_MESSAGE")
      else
        if CLng(EventArg.Grid.Rowset.Value("id_pricelist")) = CLng(Form("NonSharedPLID")) then
          strName = "<em>" & FrameWork.GetDictionary("TEXT_NONSHARED") & "</em>"
        else
          strName = "" & EventArg.Grid.Rowset.Value("tpl_nm_name")
        end if
      end if    
      EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'>" & strName & "&nbsp;&nbsp;" & "</td>"
      ContainedParameterTables_DisplayCell = TRUE
          
    Case "id_pricelist"
      ' Hijacked this property/column to display the selct pricelist button in a separate column
      ' The button are named EditMapping1, EditMapping2 for fred runner
      dim strLinkParams
      strLinkParams = "ID|" & Request("ID") & ";EditMode|False;POBased|" & Request("POBased") & ";Kind|" & Request("Kind") & ";Automatic|" & Request("Automatic")
      EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'>"  & _
            "<button class='clsButtonBlueMedium' name=""EditMapping_" & EventArg.Grid.Rowset.Value("tpt_nm_name") & """ onclick=""window.open('PriceListMapping.Edit.asp?ID=" & EventArg.Grid.Rowset.Value("id_paramtable") & "&NonSharedPLID=" & Form("NonSharedPLID") & "&PI_ID=" & Request("ID") & "&NextPage=PriceableItem.Usage.ViewEdit.asp&MonoSelect=TRUE&Title=TEXT_SELECT_PRICELIST_MAPPING&Parameters=PickerAddMapping|TRUE;" & strLinkParams & ";PARAMTABLEID|" & EventArg.Grid.Rowset.Value("id_paramtable")  & "','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes')"">" & FrameWork.GetDictionary("TEXT_EDIT") & " Mapping" & "</button></td>"                       
            
      ContainedParameterTables_DisplayCell = TRUE      
                      
		Case "b_canicb" 
      if UCase(EventArg.Grid.SelectedProperty.Value) = "Y" then
        EventArg.HTMLRendered = ""
        EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "'>"
        'EventArg.HTMLRendered = EventArg.HTMLRendered & "<img src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/icons/check.gif'>"
        EventArg.HTMLRendered = EventArg.HTMLRendered & FrameWork.GetDictionary("TEXT_YES")
        EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>"
      else
        EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'>" & FrameWork.GetDictionary("TEXT_NO") & "</td>"
      end if
      ContainedParameterTables_DisplayCell = TRUE

    Case else
      ContainedParameterTables_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
  End Select

END FUNCTION

%>


