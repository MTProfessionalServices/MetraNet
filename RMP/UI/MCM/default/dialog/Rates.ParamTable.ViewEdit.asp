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
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../lib/TabsClass.asp" -->
<%


Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.ErrorHandler   = FALSE
If UCase(Request.QueryString("POBASED")) = "TRUE" Then
	Form.RouteTo        = FrameWork.GetDictionary("RATES_PRODUCT_OFFERING_LIST_DIALOG")
Else
	Form.RouteTo        = FrameWork.GetDictionary("RATES_PRICE_LIST_LIST_DIALOG")
End If



mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
  
  If UCase(Request.QueryString("POBASED")) = "TRUE" Then
		gObjMTTabs.Tab  = 0      
    Form.HelpFile   = "PO.Rates.ParamTable.ViewEdit.hlp.htm" 
  Else
		gObjMTTabs.Tab  = 1
    Form.HelpFile   = "Rates.ParamTable.ViewEdit.hlp.htm"
  End If
  
  'Save querystrings in the form so it will work when we refresh the screen
  Form("POBased") = Request.QueryString("POBased")
  Form("ID") = Request.QueryString("ID")
  Form("ID_PO") = Request.QueryString("PO_ID")
  
	' Add a new properties to hold error message
	Service.Properties.Add "ContainedPriceableItemsMessage", "String",  256, FALSE, Empty
	Service.Properties.Add "ContainedParameterTablesMessage", "String",  256, FALSE, Empty
	
  'We will call the function that create the grids and tell it that this is not a refresh (boolean arg = TRUE)
  CreateGrids TRUE
  
  ' Dynamically Add Tabs to template
  Dim strTabs
  gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_RATES_PRODUCT_OFFERING_LIST"), "[RATES_PRODUCT_OFFERING_LIST_DIALOG]"
  gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_RATES_PRICELIST_LIST"), "[RATES_PRICE_LIST_LIST_DIALOG]"
  
  strTabs = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
  Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)
  Form_Initialize 							= TRUE
  
END FUNCTION

PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean
  CreateGrids FALSE
  Form_Refresh = TRUE
END FUNCTION

PRIVATE FUNCTION CreateGrids(booInitialize)

  Dim objMTProductCatalog ' As MTProductCatalog
  Set objMTProductCatalog   = GetProductCatalogObject
  Dim objMTPriceableItem ' As MTPriceableItem
  Dim objMTPriceableItemType ' As MTPriceableItemType

  Set objMTPriceableItem  = objMTProductCatalog.GetPriceableItem(Clng(Form("ID"))) 
  Set COMObject.Instance  = objMTPriceableItem
  
  If CBool(Form("POBased")) Then
    Form("NonSharedPLID") = objMTProductCatalog.GetProductOffering(Clng(Form("ID_PO"))).NonSharedPriceListID
  End If
  
  ' We will only try to retrieve the children IF the PI type is usage. Check is there is a better way to test this

  FrameWork.Dictionary().Add "ChildItems",FALSE
  if (COMObject.Instance.Kind = PI_TYPE_USAGE or COMObject.Instance.Kind = PI_TYPE_USAGE_AGGREGATE) then
  	  mdm_GetDictionary.Add "RATES_IS_USAGE" , true
	  'Settting up the grid
	  if (booInitialize) then ' If we are refreshing, we won't add the grid again
	  	Form.Grids.Add "ContainedPriceableItems"
	  end if
	  
	  Set Form.Grids("ContainedPriceableItems").Rowset = COMObject.Instance.GetChildrenAsRowset()
		
	  ' Create and define the Contained Priceable Items Grid
		'If Not IsValidObject(Form.Grids("ContainedPriceableItems").Properties("name")) Then
		If Form.Grids("ContainedPriceableItems").Rowset.RecordCount = 0 then
      Service.Properties("ContainedPriceableItemsMessage") = FrameWork.GetDictionary("TEXT_NO_CHILD_ITEMS")
      Form.Grids("ContainedPriceableItems").Visible = false	
	  Else
			FrameWork.Dictionary().Add "ChildItems",TRUE
			Service.Properties("ContainedPriceableItemsMessage") = Empty
			Form.Grids("ContainedPriceableItems").Properties.ClearSelection
			Form.Grids("ContainedPriceableItems").Properties("nm_name").Selected 				= 1
		  Form.Grids("ContainedPriceableItems").Properties("nm_desc").Selected 	      = 2
'			Form.Grids("ContainedPriceableItems").Properties("n_kind").Selected 				= 3
       
			Form.Grids("ContainedPriceableItems").Properties("nm_name").Caption          = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
			Form.Grids("ContainedPriceableItems").Properties("nm_desc").Caption          = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")
'		  Form.Grids("ContainedPriceableItems").Properties("n_kind").Caption 					 = FrameWork.GetDictionary("TEXT_COLUMN_KIND")
			Form.Grids("ContainedPriceableItems").Visible = true
	  End If
	  Form.Grids("ContainedPriceableItems").DefaultCellClass = "TableCell"
    Form.Grids("ContainedPriceableItems").DefaultCellClassAlt = "TableCellAlt"
  Else ' Clean up grid from previous PIs
  	  mdm_GetDictionary.Add "RATES_IS_USAGE" , false
  End If
  
  if (booInitialize) then ' If we are refreshing, we won't add the grid again
  	Form.Grids.Add "ContainedParameterTables"
  end if
  
  if UCase(Form("POBASED")) = "TRUE" then
	  ' In POBased rates, we  show an extra piece of information: the pricelist that the parameter table is attached to
	  Set Form.Grids("ContainedParameterTables").Rowset = COMObject.Instance.GetNonICBPriceListMappingsAsRowset
		
		if Form.Grids("ContainedParameterTables").Rowset.recordcount = 0 then
			Service.Properties("ContainedParameterTablesMessage") = FrameWork.GetDictionary("ERROR_ITEM_NO_PARAMETER_TABLES")
			Form.Grids("ContainedParameterTables").Visible = false
		else
			Service.Properties("ContainedParameterTablesMessage") = Empty
    	Form.Grids("ContainedParameterTables").Properties.ClearSelection
	  	'Form.Grids("ContainedParameterTables").Properties.SelectAll
	  	Form.Grids("ContainedParameterTables").Properties("tpt_nm_name").Selected  = 1
	  	Form.Grids("ContainedParameterTables").Properties("tpt_nm_name").Caption   = FrameWork.GetDictionary("TEXT_PARAMETER_TABLE")
	  	Form.Grids("ContainedParameterTables").Properties("tpl_nm_name").Selected  = 2
	  	Form.Grids("ContainedParameterTables").Properties("tpl_nm_name").Caption 	 = FrameWork.GetDictionary("TEXT_PRICELIST_MAPPING")
	  	Form.Grids("ContainedParameterTables").Properties("b_canICB").Selected 		 = 3
	  	Form.Grids("ContainedParameterTables").Properties("b_canICB").Caption 		 = FrameWork.GetDictionary("TEXT_PERSONAL_RATES_ALLOWED")
			Form.Grids("ContainedParameterTables").Visible = true
		end if
  else		
  	Set Form.Grids("ContainedParameterTables").Rowset = COMObject.Instance.PriceableItemType.GetParamTableDefinitionsAsRowset
		if Form.Grids("ContainedParameterTables").Rowset.recordcount = 0 then
			Service.Properties("ContainedParameterTablesMessage") = FrameWork.GetDictionary("ERROR_ITEM_NO_PARAMETER_TABLES")
			Form.Grids("ContainedParameterTables").Visible = false
		else
		  Form.Grids("ContainedParameterTables").Properties.ClearSelection
		  Form.Grids("ContainedParameterTables").Properties("nm_name").Selected  = 1
  		Form.Grids("ContainedParameterTables").Properties("nm_name").Caption   = FrameWork.GetDictionary("TEXT_PARAMETER_TABLE")
			Form.Grids("ContainedParameterTables").Visible = true
	  	'No pricelist here
		end if
  end if
  
  Form.Grids("ContainedParameterTables").DefaultCellClass = "TableCell"
  Form.Grids("ContainedParameterTables").DefaultCellClassAlt = "TableCellAlt"
		
  COMObject.Properties.Enabled              = FALSE ' Every control is grayed
  Form.Grids.Enabled                        = FALSE ' All Grid are not enabled
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : ContainedPriceableItems_DisplayCell
' PARAMETERS		: EventArg
' DESCRIPTION 		: Displays cells in the children PI grid correctly
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION ContainedPriceableItems_DisplayCell(EventArg) ' As Boolean

    'response.write  EventArg.Grid.SelectedProperty.Name & "<br>"
    Select Case lcase(EventArg.Grid.SelectedProperty.Name)
      Case "nm_name"
				EventArg.HTMLRendered = ""
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "<td class=" & EventArg.Grid.CellClass &">"
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "<a href='Rates.ParamTable.ViewEdit.asp?Title=TEXT_CHOOSE_PARAMETER_TABLE"
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "&LinkColumnMode=TRUE"
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "&POBased=" & Form("POBased")
        if UCase(Form("POBased")) = "TRUE" then
				  EventArg.HTMLRendered	= EventArg.HTMLRendered & "&ID=" & EventArg.Grid.Rowset.Value("id_pi_instance")
        else
          EventArg.HTMLRendered	= EventArg.HTMLRendered & "&ID=" & EventArg.Grid.Rowset.Value("id_template")
        end if
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "&PO_ID=" & Form("ID_PO")         
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "&Kind=" & EventArg.Grid.Rowset.Value("n_kind")
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "&mdmReload=True'>"
				'EventArg.HTMLRendered	= EventArg.HTMLRendered & "<img border=0 src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif'>"
				EventArg.HTMLRendered	= EventArg.HTMLRendered & EventArg.Grid.Rowset.Value("nm_name")
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "</a></td>"
        ContainedPriceableItems_DisplayCell = TRUE
      Case else
        ContainedPriceableItems_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
    End Select

END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : ContainedParameterTables_DisplayCell
' PARAMETERS		:
' DESCRIPTION 		: Displays cells in the Parameter Table grid correctly
' RETURNS		    : Return TRUE if ok else FALSE
PRIVATE FUNCTION ContainedParameterTables_DisplayCell(EventArg) ' As Boolean

        dim sParamTableName
	Select Case lcase(EventArg.Grid.SelectedProperty.Name)

' The following is not consistent with the rest of the
' application and furthermore uses a Microsoft icon.
'		Case "b_canicb" 
'			EventArg.HTMLRendered = 												"<td align=""center"" class=" & EventArg.Grid.CellClass & ">"
'			if EventArg.Grid.Rowset.Value("b_canICB") = "N" then
'				EventArg.HTMLRendered = EventArg.HTMLRendered & 	"<img border=0 src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/delete.gif'>"
'			else
'				EventArg.HTMLRendered = EventArg.HTMLRendered & 	"<img border=0 src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/check.gif'>"
'			end if
'			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>"
'			ContainedParameterTables_DisplayCell = TRUE
			
		Case "tpt_nm_name"
	    	' Only POBased rates use this column name, so we will omit the "POBased" test
      EventArg.HTMLRendered	= 						  "<td title='" & EventArg.Grid.Rowset.Value("tpt_nm_name") & "' class="& EventArg.Grid.CellClass & ">"
      sParamTableName = EventArg.Grid.Rowset.Value("nm_display_name")
      if isNull(sParamTableName) or len(sParamTableName)=0 then
        sParamTableName = EventArg.Grid.Rowset.Value("tpt_nm_name")
      'else
      '  sParamTableName = sParamTableName & "&nbsp;(" & EventArg.Grid.Rowset.Value("tpt_nm_name") & ")"
      end if
			if Len(EventArg.Grid.Rowset.Value("id_pricelist")) > 0 then
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "<a href='Rates.RateSchedule.List.asp?"
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "Title=TEXT_CHOOSE_RATE_SCHEDULE"
		 		EventArg.HTMLRendered	= EventArg.HTMLRendered & "&ID=" & EventArg.Grid.Rowset.Value("id_paramtable")
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "&PI_ID=" & Form("ID")
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "&PT_ID=" & EventArg.Grid.Rowset.Value("id_paramtable")
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "&Parameters=Title|TEXT_CHOOSE_RATE_SCHEDULE;POBased|TRUE"
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "&POBased=" & Form("POBased")
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "&Rates=TRUE"
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "&mdmReload=True'>"
				'EventArg.HTMLRendered	= EventArg.HTMLRendered & "<img border=0 src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif'>"
				EventArg.HTMLRendered	= EventArg.HTMLRendered & sParamTableName
				EventArg.HTMLRendered	= EventArg.HTMLRendered & "</a>"
			else
				EventArg.HTMLRendered	= EventArg.HTMLRendered & sParamTableName
			end if
			
			EventArg.HTMLRendered	= EventArg.HTMLRendered & "</nobr></td>"
			ContainedParameterTables_DisplayCell = TRUE
			
		Case "nm_name"
			' Only Pricelist Based rates use this column name, so we will omit the "POBased" test
      sParamTableName = EventArg.Grid.Rowset.Value("nm_display_name")
      if isNull(sParamTableName) or len(sParamTableName)=0 then
        sParamTableName = EventArg.Grid.Rowset.Value("nm_name")
      end if
			EventArg.HTMLRendered	= "<td class="& EventArg.Grid.CellClass &">" 
			EventArg.HTMLRendered	= EventArg.HTMLRendered & "<a href='Rates.Pricelist.List.asp?"
			EventArg.HTMLRendered	= EventArg.HTMLRendered & "Title=TEXT_CHOOSE_PRICELIST"
			EventArg.HTMLRendered	= EventArg.HTMLRendered & "&ID=" & EventArg.Grid.Rowset.Value("id_pt")
			EventArg.HTMLRendered	= EventArg.HTMLRendered & "&PI_ID=" & Form("ID")
			EventArg.HTMLRendered	= EventArg.HTMLRendered & "&LinkColumnMode=TRUE"
			EventArg.HTMLRendered	= EventArg.HTMLRendered & "&POBased=" & Form("POBased")
			EventArg.HTMLRendered	= EventArg.HTMLRendered & "&Rates=TRUE"
			EventArg.HTMLRendered	= EventArg.HTMLRendered & "&mdmReload=True'>"
			EventArg.HTMLRendered	= EventArg.HTMLRendered & "<img border=0 src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif'>"
			EventArg.HTMLRendered	= EventArg.HTMLRendered & sParamTableName
			EventArg.HTMLRendered	= EventArg.HTMLRendered & "</a></nobr></td>"
			ContainedParameterTables_DisplayCell = TRUE
			
    Case "tpl_nm_name"
	    ' Only POBased rates use this column name, so we will omit the "POBased" test
		  dim strName
      ' See if we have a pricelist mapping
			if Len(EventArg.Grid.Rowset.Value("id_pricelist")) > 0 then
        if CLng(EventArg.Grid.Rowset.Value("id_pricelist")) = CLng(Form("NonSharedPLID")) then
          strName = "<em>" & FrameWork.GetDictionary("TEXT_NONSHARED_PRICE_LIST") & "</em>"
        else
  				strName = EventArg.Grid.Rowset.Value("tpl_nm_name")
        end if
			else
        strName = "<img align='top' border=0 src='" & FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/icons/warningSmall.gif'>" & FrameWork.GetDictionary("TEXT_NO_PRICE_LIST_MAPPING_MESSAGE")
      end if
			EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'>" & strName & "&nbsp;&nbsp;" & "</td>"                			
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
