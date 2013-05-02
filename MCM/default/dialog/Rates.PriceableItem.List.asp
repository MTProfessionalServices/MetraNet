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
' DESCRIPTION : This page allow to pick a price able item to then select and edit a parameter table. THIS CANNOT BE RE-USED in other
'               in the application. Because we hard code some stuff...
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
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
FOrm.ErrorHandler   = FALSE
mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	Dim strTabs

	' Dynamically Add Tabs to template
	gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_RATES_PRODUCT_OFFERING_LIST"), "[RATES_PRODUCT_OFFERING_LIST_DIALOG]"
	gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_RATES_PRICELIST_LIST"), "[RATES_PRICE_LIST_LIST_DIALOG]"

	Form("POBased") = Request.QueryString("POBASED")
	
	' Customize Tabs and Bread Crumb based on whetther we are editing PO Rates or PL rates	
	If UCase(Request.QueryString("POBASED")) = "TRUE" Then
		gObjMTTabs.Tab = 0
		Form("PO_ID") = Request.QueryString("ID")
    Dim objProductOffering
    Dim objMTProductCatalog
    Set objMTProductCatalog = GetProductCatalogObject
   	Set objProductOffering = objMTProductCatalog.GetProductOffering(Clng(Form("PO_ID")))
    Form.HelpFile   = "PO.Rates.PriceableItem.List.hlp.htm"
	Else
	  gObjMTTabs.Tab = 1
      Form.HelpFile   = "Rates.PriceableItem.List.hlp.htm"
	End If
	
  
	strTabs = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)
	Form.HTMLTemplateSource = Replace(Form.HTMLTemplateSource, "<MDMTAB />", strTabs)
	Form_Initialize = MDMListDialog.Initialize(EventArg)
	  
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :  EventArg
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog, objMTFilter, objProductOffering, objCol

  Form_LoadProductView = FALSE

  Set objMTProductCatalog = GetProductCatalogObject
  
  Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter.1")
  
  If(Not IsEmpty(Form("Kind")))Then
    Set objMTFilter = mcmGetFilterForPriceableItemKind(CLng(Form("Kind")))
  Else
    Set objMTFilter = Nothing   ' No Filter
  End If
  
  if UCase(Form("POBased")) = "TRUE" Then
	set objProductOffering = objMTProductCatalog.GetProductOffering(Clng(Form("PO_ID")))
	set ProductView.Properties.RowSet = objProductOffering.GetPriceableItemsAsRowset ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset  	
  else
  	set ProductView.Properties.RowSet = objMTProductCatalog.FindPriceableItemsAsRowset(objMTFilter) ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  end if
  
  ProductView.Properties.ClearSelection               ' Select the properties I want to print in the PV Browser   Order
  'ProductView.Properties.SelectAll
  ProductView.Properties("nm_name").Selected     	= 1
  ProductView.Properties("nm_desc").Selected 	  	= 2
  
  ProductView.Properties("nm_name").Sorted        = MTSORT_ORDER_DECENDING ' Set the default sorted property
  
  Set Form.Grid.FilterProperty                    = ProductView.Properties("nm_name") ' Set the property on which to apply the filter  
  ProductView.Properties("nm_name").Caption       = FrameWork.GetDictionary("TEXT_COLUMN_NAME")
  ProductView.Properties("nm_desc").Caption       = FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION")

  
  ' Get PO Information For Display and Create message indicating effected subscribers
  Service.Properties.Add "POID", "int32",  256, FALSE, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "NAME", "String",  256, FALSE, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "DESCRIPTION", "String",  256, FALSE, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "CURRENCYCODE", "String",  256, FALSE, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET
  Service.Properties.Add "DependencyCountMessage", "String",  256, FALSE, 0, eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET

  if UCase(Form("POBased")) = "TRUE" Then
    FrameWork.Dictionary().Add "POBased",TRUE
    Service.Properties("POID").value = objProductOffering.ID
    Service.Properties("NAME").value = objProductOffering.Name
    Service.Properties("DESCRIPTION").value = objProductOffering.Description
    Service.Properties("CURRENCYCODE").value = objProductOffering.GetCurrencyCode()
    
    If UCase(FrameWork.GetDictionary("APPSETTING_DISPLAY_RATE_SCHEDULE_DEPENDENCY_COUNTS"))="TRUE" then
  	  FrameWork.Dictionary().Add "DisplayDependencyCounts",TRUE
      FrameWork.Dictionary().Add "DisplayDependencyLinkOnly",FALSE
      Service.Properties("DependencyCountMessage").value= getNumberOfDependentSubscribers( Form("PO_ID") )
    Else
  	  FrameWork.Dictionary().Add "DisplayDependencyLinkOnly",TRUE
      FrameWork.Dictionary().Add "DisplayDependencyCounts",FALSE
      
      Service.Properties("DependencyCountMessage").value= ""
    End If
    
  else
    FrameWork.Dictionary().Add "POBased",FALSE
    FrameWork.Dictionary().Add "DisplayDependencyCounts",FALSE
    FrameWork.Dictionary().Add "DisplayDependencyLinkOnly",FALSE
  end if
  
  
  Form_LoadProductView = TRUE ' Must Return TRUE To Render The Dialog
END FUNCTION

function getNumberOfDependentSubscribers(idPO)
    
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  	rowset.Init "queries\productcatalog"
    rowset.SetQueryTag("__GET_DEPENDENT_SUBSCRIBERS_COUNT_FOR_PRODUCT_OFFERING__")  
    rowset.AddParam "%%ID_PO%%", CLng(idPO)
  	rowset.Execute
    
    getNumberOfDependentSubscribers = rowset.value("NumberDependentSubscribers")
    
end function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: LinkColumnMode_DisplayCell
' PARAMETERS	:
' DESCRIPTION :
' RETURNS		  : Return TRUE if ok else FALSE
PUBLIC FUNCTION LinkColumnMode_DisplayCell(EventArg) ' As Boolean
    Dim m_objPP, HTML_LINK_EDIT , strValue , strFormat, lngPos, strParameter 
    
        Select Case Form.Grid.Col
        
            Case 1,2
                mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
            Case 3
                Inherited("Form_DisplayCell()")
                lngPos                = InStr(EventArg.HTMLRendered,">") ' Find the first >
                EventArg.HTMLRendered = MDMListDialog.Tools.InsertAStringAt(EventArg.HTMLRendered,"<A Name='[ID]' HREF='[URL]?mdmReload=TRUE&ID=[ID]&PO_ID=[PO_ID]&Rates=TRUE&PoBased=[POBASED]&Title=[TITLE]&[PARAMETERS]'>",lngPos+1) ' Insert after >
                EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"</td>","</a></td>")
                
                MDMListDialog.PreProcessor.Clear

                MDMListDialog.PreProcessor.Add "URL"     , FrameWork.GetDictionary("RATES_PARAMTABLE_VIEW_EDIT_DIALOG")                
                MDMListDialog.PreProcessor.Add "ID"      , ProductView.Properties.Rowset.Value("id_prop")
                MDMListDialog.PreProcessor.Add "PO_ID"   , Form("PO_ID")
                MDMListDialog.PreProcessor.Add "POBased" , Form("PoBased")
				        MDMListDialog.PreProcessor.Add "TITLE"   , "TEXT_CHOOSE_PARAM_TABLE"                
                
                EventArg.HTMLRendered = MDMListDialog.PreProcess(EventArg.HTMLRendered)
    			
            Case Else
               LinkColumnMode_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation           
        End Select

END FUNCTION
%>
