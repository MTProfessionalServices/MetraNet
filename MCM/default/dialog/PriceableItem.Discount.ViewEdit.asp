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
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
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
  Form("POBased") = UCase(Request.QueryString("POBased"))
  	
	mdm_GetDictionary().Add "CURRENT_PRICE_ABLE_ITEM_ID",Request.QueryString("ID")
	If lcase(Form("POBased"))="true" then
    mdm_GetDictionary().Add "CURRENT_PO_BASED",true
	else
    mdm_GetDictionary().Add "CURRENT_PO_BASED",false
  end if
  
  Service.Properties.Add "Body", "String",  256, FALSE, TRUE 
	Service.Properties("Body") = "<BODY>"
	
	if UCase(Request.QueryString("EditMode")) = "TRUE" Then
	  FrameWork.Dictionary().Add "ShowOKButton", TRUE
      FrameWork.Dictionary().Add "ShowCancelButton",TRUE
	  FrameWork.Dictionary().Add "ShowEditButton",FALSE
	else
	  FrameWork.Dictionary().Add "ShowOKButton", FALSE
   	  FrameWork.Dictionary().Add "ShowCancelButton",FALSE
	  FrameWork.Dictionary().Add "ShowEditButton",TRUE
	End if  
	
  '  Service.Properties.Add "ParameterMessage", "String",  256, FALSE, TRUE 
	'Service.Properties("ParameterMessage") = "This item has the following parameter tables"
  Form_Refresh EventArg

	If UCase(Request.QueryString("POBased")) <> "TRUE" Then

  		Service.Properties("Body") = "<BODY>"
        Service.Properties.Add "ParameterMessage", "String",  256, FALSE, TRUE 
  		Service.Properties("ParameterMessage") = ""
  		FrameWork.Dictionary().Remove "PARAMIf"
        FrameWork.Dictionary().Add "ShowCloseButton",TRUE

  Else
      mcmDrawTabsForPriceableItem COMObject.Instance.Name, COMObject.Instance.Kind, 1

  	  Service.Properties.Add "ParameterMessage", "String",  256, FALSE, TRUE 
  		Service.Properties("ParameterMessage") = FrameWork.GetDictionary("TEXT_DISCOUNT_PARAMETER_TABLE_TITLE")
  		FrameWork.Dictionary().Add "PARAMIf",1   
      FrameWork.Dictionary().Add "ShowCloseButton",FALSE

      Dim objMTProductCatalog, objProductOffering
      Set objMTProductCatalog = GetProductCatalogObject
      Set objProductOffering = objMTProductCatalog.GetProductOffering(FORM("POID"))
      Form("NonSharedPLID") = objProductOffering.NonSharedPriceListID      
	 End if	
    
    Service.Properties.Enabled =  CBool(UCase(Request("EditMode")) = "TRUE")
	  Form_Initialize = TRUE
END FUNCTION
' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Refresh
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean
  
  Dim objMTProductCatalog  

	if UCase(Request("PickerAddMapping")) = "TRUE" then
 		 COMObject.Instance.SetPriceListMapping Clng(Request("PARAMTABLEID")), Clng(Request("PICKERIDS"))
	end if

    Set objMTProductCatalog = GetProductCatalogObject
    
    ' Find the PriceableItem and store it into the MDM COM Object
    If(Request.QueryString("ID") <> 0) Then
        Set COMObject.Instance = objMTProductCatalog.GetPriceableItem(CLng(Request.QueryString("ID"))) ' We map the dialog with a COM Object not an MT Service
    End If    
    
    If Not IsValidObject(COMObject.Instance) Then
        response.write FrameWork.GetDictionary("ERROR_ITEM_NOT_FOUND") & Request.QueryString("ID")
        response.end
    End If
    
    ' Create and define the Extended Properties Grid
    Form.Grids.Add "ExtendedProperties", "Extended Properties"
    Set Form.Grids("ExtendedProperties").MTProperties(MTPROPERTY_EXTENDED) = COMObject.Instance.Properties
    Form.Grids("ExtendedProperties").Properties.ClearSelection
    Form.Grids("ExtendedProperties").Properties("Name").Selected    = 1
    Form.Grids("ExtendedProperties").Properties("Value").Selected   = 2
    
    Form.Grids("ExtendedProperties").Properties("Name").Caption 		= FrameWork.GetDictionary("TEXT_COLUMN_NAME")
    Form.Grids("ExtendedProperties").Properties("Value").Caption 	  = FrameWork.GetDictionary("TEXT_COLUMN_VALUE")

    Form.Grids("ExtendedProperties").ShowHeaders=False
    Form.Grids("ExtendedProperties").DefaultCellClass = "captionEW"
    Form.Grids("ExtendedProperties").DefaultCellClassAlt = "captionEW"
    
  
    ' Create and define the Compound Priceable Items Grid
    Form.Grids.Add "ContainedPriceableItems", "Compound Priceable Items"
    Set Form.Grids("ContainedPriceableItems").MTCollection = COMObject.Instance.GetChildren()
    If Not IsValidObject(Form.Grids("ContainedPriceableItems").Properties("name")) Then
    '    response.write "No Children..."
    Else    
      Form.Grids("ContainedPriceableItems").Properties.ClearSelection
      Form.Grids("ContainedPriceableItems").Properties("name").Selected 			  = 1
      Form.Grids("ContainedPriceableItems").Properties("description").Selected = 2
      Form.Grids("ContainedPriceableItems").Properties("glcode").Selected 	  	= 3 
      
      Form.Grids("ContainedPriceableItems").Properties("name").Caption 		= FrameWork.GetDictionary("TEXT_COLUMN_NAME")
      Form.Grids("ContainedPriceableItems").Properties("description").Caption 	  = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
      Form.Grids("ContainedPriceableItems").Properties("glcode").Caption = FrameWork.GetDictionary("TEXT_COLUMN_GLCODE")
      
      'Form.Grids("ContainedPriceableItems").Width = "100%"
      Form.Grids("ContainedPriceableItems").DefaultCellClass = "TableCell"
      Form.Grids("ContainedPriceableItems").DefaultCellClassAlt = "TableCellAlt"
    End If  

    Form.Grids.Add "ContainedParameterTables"
  	' Add a property that contains the 'rowset empty' message
    Service.Properties.Add "ParameterTableMessage", "String",  256, FALSE, TRUE  
    Service.Properties("ParameterTableMessage") = ""

    
    Form.Grids.Add "CounterDefinitions"
    ' Add a property that contains the 'rowset empty' message
    Service.Properties.Add "CounterDefinitionsMessage", "String",  256, FALSE, TRUE  
    Service.Properties("CounterDefinitionsMessage") = FrameWork.GetDictionary("TEXT_DISCOUNT_BASED_COUNTERS")
    Service.Properties.Add "NoCounterDefinitionsMessage", "String",  256, FALSE, TRUE  
    Service.Properties("NoCounterDefinitionsMessage") = ""
   
    'SECENG: Fixing problems with output encoding
    Service.Properties.Add "discount_name", "String",  1024, FALSE, TRUE  
    Service.Properties("discount_name") = SafeForHtml(COMObject.Instance.Name)
   
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


    'Set Form.Grids("ContainedParameterTables").Rowset = COMObject.Instance.GetNonICBPriceListMappingsAsRowset()
    
    'if Form.Grids("ContainedParameterTables").Rowset.recordcount = 0 then
	  '	If UCase(Request.QueryString("POBased")) = "TRUE" Then
		'      Service.Properties("ParameterTableMessage") = FrameWork.GetDictionary("ERROR_ITEM_NO_PARAMETER_TABLES")
		'else
		'	   Service.Properties("ParameterTableMessage") = ""
	  '  end if		   
    '  Form.Grids("ContainedParameterTables").Visible = false
    'Else
    
      'Form.Grids("ContainedParameterTables").Properties.ClearSelection
      'Form.Grids("ContainedParameterTables").Properties("tpt_nm_name").Selected  = 1
      'Form.Grids("ContainedParameterTables").Properties("tpl_nm_name").Selected = 2
      'Form.Grids("ContainedParameterTables").Properties("b_canICB").Selected = 3
      'Form.Grids("ContainedParameterTables").Properties("id_pricelist").Selected  = 4
      
  
      'Form.Grids("ContainedParameterTables").Properties("tpt_nm_name").Caption =  FrameWork.GetDictionary("TEXT_PARAMETER_TABLE")
      'Form.Grids("ContainedParameterTables").Properties("tpl_nm_name").Caption = FrameWork.GetDictionary("TEXT_PRICELIST_MAPPING")
      'Form.Grids("ContainedParameterTables").Properties("b_canICB").Caption = FrameWork.GetDictionary("TEXT_PERSONAL_RATES_ALLOWED")
      'Form.Grids("ContainedParameterTables").Properties("id_pricelist").Caption = "&nbsp;"
     
      'Form.Grids("ContainedParameterTables").DefaultCellClass = "TableCell"
      'Form.Grids("ContainedParameterTables").DefaultCellClassAlt = "TableCellAlt"
      
      'Form.Grids("ContainedParameterTables").Visible = true
     'end if 
     
     ProductCatalogBillingCycle.Form_Initialize Form
     COMObject.Properties.Enabled  = FALSE ' Set Enabled all the Property
	 Form.Grids("ExtendedProperties").Enabled  = CBool(UCase(Request("EditMode")) = "TRUE") 'FALSE
   
     Form_Refresh = TRUE

END FUNCTION


' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean
    On Error Resume Next
  If(COMObject.Properties.Enabled)Then  
	    Ok_Click = FALSE
  		If(Not ProductCatalogBillingCycle.UpdateProperties())Then Exit Function
      
	      COMObject.Instance.Save
   		 If(Err.Number)Then
            EventArg.Error.Save Err
    	    OK_Click = FALSE
        	Err.Clear
    	Else
        	OK_Click = TRUE
    	End If    

  Else
		OK_Click = TRUE
		' in view mode we do nothing
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
		Form.RouteTo = FrameWork.GetDictionary("DISCOUNT_LIST_DIALOG") 
	End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Edit_Click(EventArg) ' As Boolean
 If(Service.Properties.Enabled)Then
            ProductCatalogBillingCycle.UpdateProperties
  End If
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
           
            EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'><a href='PriceableItem.Usage.ViewEdit.asp?ID=" & _
                                         EventArg.Grid.Rowset.Value("ID") & "&POBased=" & MTPOBased & "&Kind="& PI_TYPE_USAGE & _
                                         "&mdmReload=True'>" & SafeForHtml(EventArg.Grid.Rowset.Value("name")) & "</a></td>"
                                         
            'EventArg.HTMLRendered     =  "<td class='GridCell'><a href='PriceableItem.Usage.ViewEdit.asp?ID=" & _
            '                             EventArg.Grid.Rowset.Value("ID") & "&Kind=" & Request("Kind") & _
            '                             "&mdmReload=True'><img border=0 src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif'>" & EventArg.Grid.Rowset.Value("name") & "</a></td>"

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
'PRIVATE FUNCTION ContainedParameterTables_DisplayCell(EventArg) ' As Boolean

'  Shared_ContainedParameterTables_DisplayCell EventArg

'END FUNCTION

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
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<button class='clsButtonBlueMedium' name=""EditCounter" & EventArg.Grid.Rowset.Value("CounterPropDefName") & """ onclick=""window.open('Counters.ViewEdit.asp?ID=" & EventArg.Grid.Rowset.Value("id_counter")  & "&CPD_ID=" & EventArg.Grid.Rowset.Value("id_prop") & "&PI_ID=" & ComObject.Instance.ID  & "&PreferredType=" & EventArg.Grid.Rowset.Value("PreferredCounterType") & "&NextPage=PriceableItem.Usage.ViewEdit.asp&AUTOMATIC=FALSE&MonoSelect=TRUE&Title=TEXT_SELECT_PRICELIST_MAPPING&Parameters=PickerAddMapping|TRUE;"   & "','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes'); return false;"">" &  FrameWork.GetDictionary("TEXT_EDIT") & "</button></td>"                                     
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
