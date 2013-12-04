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
'Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = TRUE
mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	
	Dim strTabs
	FORM("ID") = Request.QueryString("ID")
	FORM("POID") = Request.QueryString("POID")
	Form("POBased") = UCase(Request.QueryString("POBased"))
	
	if UCase(Request.QueryString("EditMode")) = "TRUE" Then
	  FrameWork.Dictionary().Add "ShowOKButton", TRUE
	  FrameWork.Dictionary().Add "ShowCancelButton",TRUE
	  FrameWork.Dictionary().Add "ShowEditButton",FALSE
	else
	  FrameWork.Dictionary().Add "ShowOKButton", FALSE
	  FrameWork.Dictionary().Add "ShowCancelButton",FALSE
	  FrameWork.Dictionary().Add "ShowEditButton",TRUE
	End if   
	
	Service.Properties.Add "TabStyle", "String",  256, FALSE, TRUE 
	Service.Properties("TabStyle") = ""
	
	'Building dynamic Text for parameter tables
  If UCase(Request.QueryString("POBased")) = "TRUE" Then
    
    FrameWork.Dictionary().Add "PriceAbleItem.NonRecurring.ViewEdit.ADJUSTMENT_TEMPLATES_EDIT_DIALOG",    FrameWork.Dictionary().Item("ADJUSTMENT_INSTANCES_EDIT_DIALOG").Value
    FrameWork.Dictionary().Add "POID",FORM("POID")
  
		Service.Properties.Add "ParameterTable", "String",  256, FALSE, TRUE 
		Service.Properties("ParameterTable") = FrameWork.GetDictionary("TEXT_PARAMETER_TABLE_TITLE") 
		FrameWork.Dictionary().Add "PARAMIf",TRUE
    
  Else
  
    FrameWork.Dictionary().Add "PriceAbleItem.NonRecurring.ViewEdit.ADJUSTMENT_TEMPLATES_EDIT_DIALOG",    FrameWork.Dictionary().Item("ADJUSTMENT_TEMPLATES_EDIT_DIALOG").Value
  
  
   	 Service.Properties.Add "ParameterTable", "String",  256, FALSE, TRUE 
	   Service.Properties("ParameterTable") = ""
		FrameWork.Dictionary().Add "PARAMIf",FALSE
	End if
	

	
	mdm_GetDictionary().Add "CURRENT_NON_RECURRING_ITEM_ID",Request.QueryString("ID")
	mdm_GetDictionary().Add "CURRENT_PO_BASED",FORM("POBASED") 
	
	RefreshData EventArg , TRUE

  If UCase(Request.QueryString("POBased")) <> "TRUE" Then
	    Service.Properties("TabStyle") = "class='clsTabAngleTopSelected'"
		
	    ' Dynamically Add Tabs to template
			
  		gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_USAGE_CHARGES"), "[SERVICE_CHARGES_USAGE_LIST]"
  		gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_RECURRING_CHARGES") , "[SERVICE_CHARGES_RECURRING_LIST]"
  		gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_KEYTERM_NON_RECURRING_CHARGES") , "[SERVICE_CHARGES_NONRECURRING_LIST]"

	    gObjMTTabs.Tab = Clng(Request.QueryString("Tab"))
	      
	    strTabs = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
	  
	    Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)
      
  Else      
    mcmDrawTabsForPriceableItem COMObject.Instance.Name, COMObject.Instance.Kind, 1

    Dim objMTProductCatalog, objProductOffering
    Set objMTProductCatalog = GetProductCatalogObject
    Set objProductOffering = objMTProductCatalog.GetProductOffering(FORM("POID"))
    Form("NonSharedPLID") = objProductOffering.NonSharedPriceListID
	End if	
  
	Form.Grids("ExtendedProperties").Enabled  = CBool(UCase(Request("EditMode")) = "TRUE")  'FALSE
	Service.Properties.Enabled 				  =  CBool(UCase(Request("EditMode")) = "TRUE")    
    'SECENG: Fixing problems with output encoding	
    Service.Properties.Add "pai_nr_ve_name", "String",  1024, FALSE, TRUE
    Service.Properties("pai_nr_ve_name") = SafeForHtml(COMObject.Instance.Name)
	
	Form_Initialize = TRUE
END FUNCTION


PRIVATE FUNCTION Form_Refresh(EventArg) ' As Boolean
	RefreshData EventArg , FALSE
END FUNCTION

PRIVATE FUNCTION RefreshData(EventArg,booInitializeEvent) ' As Boolean
	Dim objMTProductCatalog  
	
	Set objMTProductCatalog = GetProductCatalogObject
    ' Find the PriceableItem and store it into the MDM COM Object
    Set COMObject.Instance = objMTProductCatalog.GetPriceableItem(CLng(Request.QueryString("ID"))) ' We map the dialog with a COM Object not an MT Service
	
    ' Create and define the Extended Properties Grid
  If(booInitializeEvent)Then
		Form.Grids.Add "ExtendedProperties" ' Create and define the Extended Properties Grid
	End If
	
  Set Form.Grids("ExtendedProperties").MTProperties(MTPROPERTY_EXTENDED) = COMObject.Instance.Properties
  Form.Grids("ExtendedProperties").Properties.ClearSelection
  Form.Grids("ExtendedProperties").Properties("Name").Selected    = 1
  Form.Grids("ExtendedProperties").Properties("Value").Selected   = 2
	
  Form.Grids("ExtendedProperties").ShowHeaders=False
  Form.Grids("ExtendedProperties").DefaultCellClass = "captionEW"
  Form.Grids("ExtendedProperties").DefaultCellClassAlt = "captionEW"
    

    COMObject.Properties.Enabled              = FALSE ' Every control is grayed
    
    SetMSIXPropertyTypeToPriceableItemEnumType COMObject.Properties("Kind")
    SetMSIXPropertyTypeToRecurringChargeEnumType COMObject.Properties("NonRecurringChargeEvent")
'    mcm_IncludeCalendar

    RefreshData = TRUE
End Function

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
		Form.RouteTo = FrameWork.GetDictionary("SERVICE_CHARGES_NONRECURRING_LIST") 
	End If
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Edit_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Edit_Click(EventArg) ' As Boolean

    Service.Properties.Enabled = Not Service.Properties.Enabled 
    Form.Grids("ExtendedProperties").Enabled  = Service.Properties.Enabled 
    Edit_Click = TRUE

END FUNCTION

PRIVATE FUNCTION DebugMode_Click(EventArg) ' As Boolean

    Service.Configuration.DebugMode     = Service.Properties("DebugMode")
    DebugMode_Click                     = TRUE
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
           
            EventArg.HTMLRendered     =  "<td class='" & EventArg.Grid.CellClass & "'><a href='PriceAbleItem.NonRecurringCharge.ViewEdit.asp?ID=" & _
                                         EventArg.Grid.Rowset.Value("ID") & "&POBased=" & MTPOBased & "&Kind=" & PI_TYPE_NON_RECURRING & _
                                         "&mdmReload=True'>" & EventArg.Grid.Rowset.Value("name") & "</a></td>"
                                         
            'EventArg.HTMLRendered     =  "<td class='GridCell'><a href='PriceableItem.Usage.ViewEdit.asp?ID=" & _
            '                             EventArg.Grid.Rowset.Value("ID") & "&Kind=" & Request("Kind") & _
            '                             "&mdmReload=True'><img border=0 src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif'>" & EventArg.Grid.Rowset.Value("name") & "</a></td>"

            ContainedPriceableItems_DisplayCell = TRUE
        Case else
            ContainedPriceableItems_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
    End Select

END FUNCTION

%>
