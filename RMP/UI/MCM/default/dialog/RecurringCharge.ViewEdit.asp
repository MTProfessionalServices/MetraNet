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
' DIALOG	    : MCM Dialog
' DESCRIPTION	: 
' AUTHOR	    : Srinivasa Kolla
' VERSION	    : 1.0
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../MCMIncludes.asp" -->
<!-- #INCLUDE FILE="../lib/TabsClass.asp" -->
<%
'Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
'FOrm.ErrorHandler   = FALSE
'on error goto 0
mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean

	Dim strTabs
  
	FORM("ID")        = Request.QueryString("ID")
	FORM("POID")      = Request.QueryString("POID")
  Form("POBased")   = UCase(Request.QueryString("POBased"))
	
	IF UCase(Request.QueryString("EditMode")) = "TRUE" Then
  
	    FrameWork.Dictionary().Add "ShowOKButton"       , TRUE
  	  FrameWork.Dictionary().Add "ShowCancelButton"   , TRUE
	    FrameWork.Dictionary().Add "ShowEditButton"     , FALSE
	Else
  	  FrameWork.Dictionary().Add "ShowOKButton"       , FALSE
	    FrameWork.Dictionary().Add "ShowCancelButton"   , FALSE
	    FrameWork.Dictionary().Add "ShowEditButton"     , TRUE
	End If
	
	'Building Dynamic Body tag ,because to differentiate the Tabs  to display in Service Charges
	Service.Properties.Add "TabStyle", "String",  256, FALSE, TRUE 
	Service.Properties("TabStyle") = ""
		
	'Building dynamic Text for parameter tables
  If UCase(Request.QueryString("POBased")) = "TRUE" Then
  
			Service.Properties.Add "ParameterTable", "String",  256, FALSE, TRUE 
			Service.Properties("ParameterTable") =  FrameWork.GetDictionary("TEXT_PARAMETER_TABLE_TITLE")
			FrameWork.Dictionary().Add "PARAMIf",TRUE
  Else
   	 Service.Properties.Add "ParameterTable", "String",  256, FALSE, TRUE 
	   Service.Properties("ParameterTable") = ""
		 FrameWork.Dictionary().Add "PARAMIf",FALSE
	End if
	
	If UCase(Request.QueryString("POBased")) <> "TRUE" Then
	
			Service.Properties("TabStyle") = "class='clsTabAngleTopSelected'"
    	' Dynamically Add Tabs to template
	    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_USAGE_CHARGES"), "[SERVICE_CHARGES_USAGE_LIST]"
    	gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_RECURRING_CHARGES"), "[SERVICE_CHARGES_RECURRING_LIST]"
	    gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_NON_RECURRING_CHARGES"), "[SERVICE_CHARGES_NONRECURRING_LIST]"
			
    	gObjMTTabs.Tab          = Clng(Request.QueryString("Tab"))
     	strTabs                 = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
  		Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)
      Form.HelpFile           = Empty
  Else
      Form.HelpFile = "PO.RecurringCharge.ViewEdit.hlp.htm"
 	End If

  Form.Grids.Add "UDRCUnitValueEnumerations", "UDRCUnitValueEnumerations"
  
	mdm_GetDictionary().Add "CURRENT_RECURRING_ITEM_ID"     , Request.QueryString("ID")
	mdm_GetDictionary().Add "CURRENT_PO_BASED"              , FORM("POBASED")
	
  'mcm_IncludeCalendar ' Support calendar
  Form.Grids.Add "ContainedParameterTables"
	Service.Properties.Add "ParameterTableMessage", "String",  256, FALSE, TRUE  
 	Service.Properties("ParameterTableMessage") = ""

	RefreshData EventArg , TRUE
		
  Form.Grids("ExtendedProperties").Enabled  = CBool(UCase(Request("EditMode")) = "TRUE") 'FALSE
  Service.Properties.Enabled 				        = CBool(UCase(Request("EditMode")) = "TRUE")
	Form_Initialize 						              = TRUE
END FUNCTION

PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean
	RefreshData EventArg , FALSE
END FUNCTION

PRIVATE FUNCTION RefreshData(EventArg,booInitializeEvent) ' As Boolean

		Dim objMTProductCatalog, objRecurringCharge

  	Set objMTProductCatalog 					= GetProductCatalogObject
    Set objRecurringCharge  					= objMTProductCatalog.GetPriceableItem(CLng(FORM("ID"))) ' We map the dialog with a COM Object not an MT Service
    Set COMObject.Instance            = objRecurringCharge ' init or update the msixhandler object based on the product catalog com object
    
    ProductCatalogHelper.CheckAndInitializeForUDRC(FALSE)  ' -- UDRC Support --   
    
		If(booInitializeEvent)Then
			Form.Grids.Add "ExtendedProperties" ' Create and define the Extended Properties Grid
		End If
	
    Set Form.Grids("ExtendedProperties").MTProperties(MTPROPERTY_EXTENDED) = COMObject.Instance.Properties
    Form.Grids("ExtendedProperties").Properties.ClearSelection
    Form.Grids("ExtendedProperties").Properties("Name").Selected    = 1
    Form.Grids("ExtendedProperties").Properties("Value").Selected   = 2
    Form.Grids("ExtendedProperties").ShowHeaders 					= False
    Form.Grids("ExtendedProperties").DefaultCellClass 				= "captionEW"
    Form.Grids("ExtendedProperties").DefaultCellClassAlt 			= "captionEW"
	
		Set Form.Grids("ContainedParameterTables").Rowset = COMObject.Instance.GetNonICBPriceListMappingsAsRowset()

    If Form.Grids("ContainedParameterTables").Rowset.recordcount = 0 then
	  	If UCase(Request.QueryString("POBased")) = "TRUE" Then
		      Service.Properties("ParameterTableMessage") = FrameWork.GetDictionary("ERROR_ITEM_NO_PARAMETER_TABLES") 
		Else
			   Service.Properties("ParameterTableMessage") = ""
	    end if		   
      Form.Grids("ContainedParameterTables").Visible = false
    Else
    
      Form.Grids("ContainedParameterTables").Properties.ClearSelection
      Form.Grids("ContainedParameterTables").Properties("tpt_nm_name").Selected  = 1
      'Form.Grids("ContainedParameterTables").Properties("id_paramtable").Selected = 2
      Form.Grids("ContainedParameterTables").Properties("tpl_nm_name").Selected = 2
      Form.Grids("ContainedParameterTables").Properties("b_canICB").Selected = 3
      Form.Grids("ContainedParameterTables").Properties("id_pricelist").Selected  = 4
      
  
      Form.Grids("ContainedParameterTables").Properties("tpt_nm_name").Caption = FrameWork.GetDictionary("TEXT_PARAMETER_TABLE") 
      'Form.Grids("ContainedParameterTables").Properties("id_paramtable").Caption = "Price List"
      Form.Grids("ContainedParameterTables").Properties("tpl_nm_name").Caption = FrameWork.GetDictionary("TEXT_PRICELIST_MAPPING")  
      Form.Grids("ContainedParameterTables").Properties("b_canICB").Caption = FrameWork.GetDictionary("TEXT_PERSONAL_RATES_ALLOWED")     
      Form.Grids("ContainedParameterTables").Properties("id_pricelist").Caption = "&nbsp;"
     
      Form.Grids("ContainedParameterTables").DefaultCellClass = "TableCell"
      Form.Grids("ContainedParameterTables").DefaultCellClassAlt = "TableCellAlt"
      
      Form.Grids("ContainedParameterTables").Visible = true
     End if 
	
	'If(booInitializeEvent)Then
	
		ProductCatalogBillingCycle.Form_Initialize Form	    
    ' else
'          ProductCatalogBillingCycle.ClearInsertTag Form	      
	 ' End If		
	  SetMSIXPropertyTypeToPriceableItemEnumType  COMObject.Properties("Kind") ' Set some dynamic enum types...
    SetMSIXPropertyTypeToChargeInEnumType       COMObject.Properties("ChargeInAdvance")		
    SetMSIXPropertyTypeToProrationLengthOnEnumType COMObject.Properties("FixedProrationLength")

  
 	  COMObject.Properties.Enabled  = FALSE ' Set Enabled all the Property
    RefreshData = TRUE		
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
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
		Form.RouteTo = FrameWork.GetDictionary("SERVICE_CHARGES_RECURRING_LIST") 
	End If
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Edit_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Edit_Click(EventArg) ' As Boolean
	
    If(Service.Properties.Enabled)Then
        ProductCatalogBillingCycle.UpdateProperties
    End If
    
   'Service.Properties.Enabled                = Not Service.Properties.Enabled
    Form.Grids("ExtendedProperties").Enabled  = Service.Properties.Enabled
    Edit_Click                                = TRUE
END FUNCTION

PRIVATE FUNCTION DebugMode_Click(EventArg) ' As Boolean

    Service.Configuration.DebugMode     = Service.Properties("DebugMode")
    DebugMode_Click                     = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : ChargeInAdvance_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Sets currency code after selection
PRIVATE FUNCTION ChargeInAdvance_Click(EventArg) ' As Boolean

    On Error Resume Next
    If(Err.Number)Then
        EventArg.Error.Save Err
		ChargeInAdvance_Click = FALSE
        Err.Clear
    Else
		' Set currency to be COMObject.Properties("ChargeInAdvance").value
		ChargeInAdvance_Click = TRUE
    End If    
	
	
	If Form("POBased")  <> "TRUE" Then		
	Else
	End If
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : CompoundPriceableItems_DisplayCell
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION ContainedPriceableItems_DisplayCell(EventArg) ' As Boolean

	Dim MTPOBased
  MTPOBased = Request.QueryString("POBased")
  If MTPOBased = "" then
      MTPOBased = FALSE
  End if

  Select Case lcase(EventArg.Grid.SelectedProperty.Name)
        Case "name"
           
            EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'><a href='RecurringCharge.ViewEdit.asp?ID=" & _
                                         EventArg.Grid.Rowset.Value("ID") & "&POBased=" & MTPOBased & "&Kind="& PI_TYPE_RECURRING & _
                                         "&mdmReload=True'>" & EventArg.Grid.Rowset.Value("name") & "</a></td>"
                                         
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
PRIVATE FUNCTION ContainedParameterTables_DisplayCell(EventArg) ' As Boolean

    Select Case lcase(EventArg.Grid.SelectedProperty.Name)
    Case "tpt_nm_name"
            dim sParamTableName
            sParamTableName = EventArg.Grid.Rowset.Value("nm_display_name")
            if isNull(sParamTableName) or len(sParamTableName)=0 then
              sParamTableName = EventArg.Grid.Rowset.Value("tpt_nm_name")
            'else
            '  sParamTableName = sParamTableName & "&nbsp;(" & EventArg.Grid.Rowset.Value("tpt_nm_name") & ")"
            end if
            EventArg.HTMLRendered     =  "<td title='" & EventArg.Grid.Rowset.Value("tpt_nm_name") & "' class='" & EventArg.Grid.CellClass & "'>" & sParamTableName & "</td>"
            
            ContainedParameterTables_DisplayCell = TRUE
			
        Case "tpl_nm_name"
            dim strName
            strName = "" & EventArg.Grid.Rowset.Value("tpl_nm_name")
            dim bICBable
            bICBable = true 'CBool(EventArg.Grid.Rowset.Value("b_canICB") = 1)
            
            ' See if we have a pricelist mapping
            If LTRIM(RTRIM(strName)) = "" then
              strName = "<img align='top' border=0 src='" & FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/icons/warningSmall.gif'>" & FrameWork.GetDictionary("TEXT_NO_PRICE_LIST_MAPPING_MESSAGE")
            Else
              If bICBable then
                strName = strName '& "(ICBable)"
              Else
                strName = strName '& "(Not ICBable)"
              End if
            End if
            
            EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'>" & strName & "&nbsp;&nbsp;" & "</td>"
                  '"<button name=""BtnCounter"" onclick=""window.open('PriceList.Picker.asp?MonoSelect=TRUE&Title=TEXT_SELECT_PRICELIST_MAPPING&Parameters=PickerAddMapping|TRUE;PARAMTABLEID|" & EventArg.Grid.Rowset.Value("id_prop")  & "','', 'height=600,width=800, resizable=yes, scrollbars=yes, status=yes')"">Select Price List</button></td>"

            ContainedParameterTables_DisplayCell = TRUE
            
        Case "id_pricelist"
            ' Hijacked this property/column to display the selct pricelist button in a separate column
            ' The button are called EditMapping1,2,3 for FredRunner
            dim strLinkParams
            strLinkParams = "ID|" & Request("ID") & ";EditMode|False;POBased|" & Request("POBased") & ";Kind|" & Request("Kind") & ";Automatic|" & Request("Automatic")
            EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'>"  & _
                  "<!--button name=""BtnCounter"" onclick=""window.open('PriceList.Picker.asp?NextPage=RecurringCharge.ViewEdit.asp&MonoSelect=TRUE&Title=TEXT_SELECT_PRICELIST_MAPPING&Parameters=PickerAddMapping|TRUE;" & strLinkParams & ";PARAMTABLEID|" & EventArg.Grid.Rowset.Value("id_paramtable")  & "','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes')"">Select Price List</button-->" & _
                  "<button class='clsButtonBlueSmall' name=""EditMapping" & EventArg.Grid.Row & """ onclick=""window.open('PriceListMapping.Edit.asp?ID=" & EventArg.Grid.Rowset.Value("id_paramtable")  & "&PI_ID=" & Request("ID") & "&NextPage=RecurringCharge.ViewEdit.asp&MonoSelect=TRUE&Title=TEXT_SELECT_PRICELIST_MAPPING&Parameters=PickerAddMapping|TRUE;" & strLinkParams & ";PARAMTABLEID|" & EventArg.Grid.Rowset.Value("id_paramtable")  & "','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes')"">" & FrameWork.GetDictionary("TEXT_EDIT") & "</button></td>"                       
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
