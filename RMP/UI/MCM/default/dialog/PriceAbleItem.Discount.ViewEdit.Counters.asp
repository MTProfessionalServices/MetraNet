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
FOrm.ErrorHandler   = FALSE
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
  
 
  Form_Refresh EventArg	

	If UCase(Request.QueryString("POBased")) <> "TRUE" Then
  
    Service.Properties("TabStyle") = "class='clsTabAngleTopSelected'"
    Service.Properties.Add "ParameterMessage", "String",  256, FALSE, TRUE 
    Service.Properties("ParameterMessage") = ""
    FrameWork.Dictionary().Add "PARAMIf",FALSE
    
    ' Dynamically Add Tabs to template
    gObjMTTabs.AddTab "Icon View" , "/mcm/default/dialog/PriceAbleItem.Usage.ViewEdit.Overview.asp?ID=" & FORM("ID") & "&POID=" & FORM("POID") & "&POBased=" & FORM("POBased") & "&Tab=0"
    gObjMTTabs.AddTab "General", "/mcm/default/dialog/PriceAbleItem.Usage.ViewEdit.WithTabs.asp?ID=" & FORM("ID") & "&POID=" & FORM("POID") & "&POBased=" & FORM("POBased") & "&Tab=1"
    gObjMTTabs.AddTab "Mappings", "/mcm/default/dialog/PriceAbleItem.Usage.ViewEdit.Page2.asp?ID=" & FORM("ID") & "&POID=" & FORM("POID") & "&POBased=" & FORM("POBased") & "&Tab=2"
      
    gObjMTTabs.Tab          = Clng(Request.QueryString("Tab"))		  
    strTabs                 = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
    Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)
      
    Form.HelpFile = Empty
    
	Else
  
    mcmDrawTabsForPriceableItem COMObject.Instance.Name, COMObject.Instance.Kind,  3

    Service.Properties.Add "ParameterMessage", "String",  256, FALSE, TRUE 
    Service.Properties("ParameterMessage") = FrameWork.GetDictionary("TEXT_PARAMETER_TABLE_TITLE")
    FrameWork.Dictionary().Add "PARAMIf",TRUE
    
    Form.HelpFile = "PO.PriceAbleItem.Usage.ViewEdit.hlp.htm"

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
  Service.Properties.Add "pai_disc_ve_name", "String",  1024, FALSE, TRUE
  Service.Properties("pai_disc_ve_name") = SafeForHtml(Service.Instance.Name)  
  
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
       
 

    ' Add a property that contains the 'rowset empty' message
  	Service.Properties.Add "ParameterTableMessage", "String",  256, FALSE, TRUE  
   	Service.Properties("ParameterTableMessage") = Empty
  
	  if UCase(Request.QueryString("PickerAddMapping")) = "TRUE" then
    
		    'response.write("Adding pricelist mapping<BR>")
		    COMObject.Instance.SetPriceListMapping Clng(Request("PARAMTABLEID")), Clng(Request("PICKERIDS"))
	  end if


    Form.Grids.Add "CounterDefinitions"
    ' Add a property that contains the 'rowset empty' message
    Service.Properties.Add "CounterDefinitionsMessage", "String",  256, FALSE, TRUE  
    Service.Properties("CounterDefinitionsMessage") = FrameWork.GetDictionary("TEXT_DISCOUNT_BASED_COUNTERS")
    Service.Properties.Add "NoCounterDefinitionsMessage", "String",  256, FALSE, TRUE  
    Service.Properties("NoCounterDefinitionsMessage") = ""
   
    Set Form.Grids("CounterDefinitions").Rowset = COMObject.Instance.GetCountersAsRowset()
    if Form.Grids("CounterDefinitions").Rowset.recordcount = 0 then
		  Service.Properties("NoCounterDefinitionsMessage") = FrameWork.GetDictionary("TEXT_NO_COUNTER_FOR_DISCOUNT")
      Form.Grids("CounterDefinitions").Visible = false
    Else
      Service.Properties("NoCounterDefinitionsMessage") = ""
			
      Form.Grids("CounterDefinitions").Properties.ClearSelection
			'Form.Grids("CounterDefinitions").Properties.SelectAll
      Form.Grids("CounterDefinitions").Properties("CounterPropDefName").Selected  = 1
      Form.Grids("CounterDefinitions").Properties("CounterPropDefDisplayName").Selected = 2
      Form.Grids("CounterDefinitions").Properties("CounterDescription").Selected = 3
			Form.Grids("CounterDefinitions").Properties("fordistribution").Selected  = 4
      Form.Grids("CounterDefinitions").Properties("id_prop").Selected = 5
      'Form.Grids("CounterDefinitions").Properties("id_counter").Selected  = 6

      Form.Grids("CounterDefinitions").Properties("CounterPropDefName").Caption = FrameWork.GetDictionary("TEXT_KEYTERM_COUNTER")
      Form.Grids("CounterDefinitions").Properties("CounterPropDefDisplayName").Caption = FrameWork.GetDictionary("TEXT_DISCOUNT_COUNTER_DESCRIPTION")
      Form.Grids("CounterDefinitions").Properties("CounterDescription").Caption = FrameWork.GetDictionary("TEXT_DISCOUNT_COUNTER_CONFIGURATION_DESCRIPTION")
			Form.Grids("CounterDefinitions").Properties("fordistribution").Caption = "Discount Distribution" ' TODO: LOCALIZE ME
      Form.Grids("CounterDefinitions").Properties("id_prop").Caption = "&nbsp;"     
      'Form.Grids("CounterDefinitions").Properties("id_counter").Caption = "&nbsp;"
     
      Form.Grids("CounterDefinitions").DefaultCellClass = "TableCell"
      Form.Grids("CounterDefinitions").DefaultCellClassAlt = "TableCellAlt"
      
      Form.Grids("CounterDefinitions").Visible = true
     end if 
     
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
' FUNCTION 		    : ContainedParameterTables_DisplayCell
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION CounterDefinitions_DisplayCell(EventArg) ' As Boolean

  Dim bPOBased
  if Request.QueryString("POBased") = "" then
    bPOBased=false
  else
    bPOBased=true
  end if


    Select Case lcase(EventArg.Grid.SelectedProperty.Name)
        Case "id_prop"
            ' Hijacked this property/column to display the selct pricelist button in a separate column
            dim strLinkParams
            'strLinkParams = "ID|" & Request("ID") & ";EditMode|False;POBased|" & Request("POBased") & ";Kind|" & Request("Kind") & ";Automatic|" & Request("Automatic")
            EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'>"
            if bPOBased then
              ' if this is an instance, don't display the edit button
              EventArg.HTMLRendered = EventArg.HTMLRendered & "&nbsp;</td>"
            else
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<button class='clsButtonBlueMedium' name=""EditCounter" & EventArg.Grid.Rowset.Value("CounterPropDefName") & """ onclick=""window.open('Counters.ViewEdit.asp?ID=" & EventArg.Grid.Rowset.Value("id_counter")  & "&CPD_ID=" & EventArg.Grid.Rowset.Value("id_prop") & "&PI_ID=" & ComObject.Instance.ID  & "&PreferredType=" & EventArg.Grid.Rowset.Value("PreferredCounterType") & "&NextPage=PriceableItem.Usage.ViewEdit.asp&AUTOMATIC=FALSE&MonoSelect=TRUE&Title=TEXT_SELECT_PRICELIST_MAPPING&Parameters=PickerAddMapping|TRUE;"   & "','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes')"">" &  FrameWork.GetDictionary("TEXT_EDIT") & "</button></td>"                                     
            end if
            
            CounterDefinitions_DisplayCell = TRUE
				Case "fordistribution"
						if UCase(EventArg.Grid.SelectedProperty.Value) = "Y" then
							EventArg.HTMLRendered = ""
							EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "'>"
							EventArg.HTMLRendered = EventArg.HTMLRendered & "<img src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/icons/check.gif'>"
							EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>"
						else
							EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'>&nbsp;</td>"
						end if
						CounterDefinitions_DisplayCell = TRUE
        Case else
            CounterDefinitions_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
    End Select

END FUNCTION
%>


