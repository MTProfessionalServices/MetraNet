<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
 <%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
' 
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
'  Created by: K.Boucher
' 
'  $Date$
'  $Author$
'  $Revision$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : GroupSubscriptions.asp
' DESCRIPTION : 
' 
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- METADATA type="TypeLib" UUID="{A4175A41-AF24-4F1E-B408-00CF83690549}" -->

<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
Form.Version 										= MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo 										= mam_GetDictionary("WELCOME_DIALOG")
Form.Page.MaxRow  							= CLng(mam_GetDictionary("PV_ROW_PER_PAGE"))
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

PUBLIC FUNCTION Form_Initialize(EventArg) ' As Boolean
  Form.Grid.FilterMode = TRUE
  Form_Initialize = TRUE
END FUNCTION
		
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION     :  Form_LoadProductView
' PARAMETERS   :
' DESCRIPTION  : 
' RETURNS      :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
	Dim objMTProductCatalog, objYAAC, corpAccRowset
  Form_LoadProductView = FALSE
	
	Set objMTProductCatalog = GetProductCatalogObject
	
  ' Check business rule to see if cross corporate is allowed,
  ' if it is then we do not filter on corp account id
  Dim pc, bHierarchyRestrictedOperations
  Set pc = GetProductCatalogObject()  
  bHierarchyRestrictedOperations = pc.IsBusinessRuleEnabled(PCCONFIGLib.MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations)
  
  If Not bHierarchyRestrictedOperations Then
    Form("CorpID") = 1

    ' Create filter to be applied when query is run  
    Dim objMTFilter
    If mdm_UIValue("mdmPVBFilter") <> "" Then
      Set objMTFilter = mdm_CreateObject("MTSQLRowset.MTDataFilter.1")
      objMTFilter.Add "Name", OPERATOR_TYPE_LIKE, "%" + mdm_UIValue("mdmPVBFilter") + "%"
      Set ProductView.Properties.RowSet = objMTProductCatalog.GetGroupSubscriptionsAsRowset(mam_GetHierarchyDate(), objMTFilter)
    Else
      Set ProductView.Properties.RowSet = objMTProductCatalog.GetGroupSubscriptionsAsRowset(mam_GetHierarchyDate())
    End If

    ' Check to see if items have been filtered and inform the user
    If ProductView.Properties.RowSet.RecordCount >= 1000 Then
      mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", TRUE
    ELSE
      mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", FALSE      
    End If
    
  Else   
    Form("CorpID") = CLng(SubscriberYAAC().CorporateAccountID)
  	Set ProductView.Properties.RowSet = objMTProductCatalog.GetGroupSubscriptionByCorporateAccount(CLng(Form("CorpID")))
    mdm_GetDictionary().Add "SHOW_ROWSET_FILTERED_MESSAGE", FALSE     
  End If  
  
  ProductView.Properties.AddPropertiesFromRowset ProductView.Properties.RowSet
	
	'--- Configure Product View
  ProductView.Properties.Flags = eMSIX_PROPERTIES_FLAG_PRODUCTVIEW 
	
	ProductView.Properties.ClearSelection
	'ProductView.Properties.SelectAll
  ProductView.Properties("tx_name").Selected 									= 1
  ProductView.Properties("tx_desc").Selected 									= 2
	ProductView.Properties("vt_start").Selected 								= 3
	ProductView.Properties("vt_end").Selected 									= 4
  
  If Not bHierarchyRestrictedOperations Then
    ProductView.Properties("nm_currency_code").Selected 	   	= 5
    ProductView.Properties("nm_currency_code").Caption = mam_GetDictionary("TEXT_CURRENCY")
    ProductView.Properties("id_group").Selected 							= 6
  else
    ProductView.Properties("id_group").Selected  							= 5
  End If
 
  ProductView.Properties("tx_name").Caption = mam_GetDictionary("TEXT_GROUP_SUBSCRIPTIONS_NAME")
	ProductView.Properties("tx_desc").Caption = mam_GetDictionary("TEXT_DESCRIPTION")
	ProductView.Properties("vt_start").Caption = mam_GetDictionary("TEXT_RATE_START_DATE")
	ProductView.Properties("vt_end").Caption = mam_GetDictionary("TEXT_RATE_END_DATE")
  ProductView.Properties("id_group").Caption = mam_GetDictionary("TEXT_ACTION")
	
	ProductView.Properties("tx_name").Sorted = MTSORT_ORDER_ASCENDING
  Set Form.Grid.FilterProperty = ProductView.Properties("tx_name") ' Set the property on which to apply the filter  
  
	' Handle the case when we come back from a screen that edits effective dates and the selected new date was overriden by the group subscription
	' or proudct offering effective date
	If Session("OverrrideGroupSubscriptionDate") Then
		mam_ShowGuide(mam_GetDictionary("ROADMAP-OVERRIDEGROUPSUBDATE"))
		Session("OverrrideGroupSubscriptionDate") = false
	Else
		response.write "<script language=""JavaScript"">parent.hideGuide();</script>"
	End If
		
  Form_LoadProductView = TRUE
  
END FUNCTION

    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION    : 
' PARAMETERS  :
' DESCRIPTION :
' RETURNS     : Return TRUE if ok else FALSE
PRIVATE FUNCTION OK_Click(EventArg) ' As Boolean

    OK_Click = TRUE
END FUNCTION  

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   : Form_DisplayCell
' PARAMETERS :
' DESCRIPTION :
' RETURNS    : 
PUBLIC FUNCTION Form_DisplayCell(EventArg) ' As Boolean
    Dim m_objPP, HTML_LINK_EDIT
		Dim strHTML
    
    Select Case Form.Grid.Col
    
         Case 1
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='16'>"
						If FrameWork.CheckCoarseCapability("Update group subscriptions") Then
           		HTML_LINK_EDIT = HTML_LINK_EDIT  & "<A HRef='" & mam_GetDictionary("GROUP_ADD_DIALOG") & "?Action=EDIT&id=" &  ProductView.Properties("id_group") & "'><img src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>"
						Else
							HTML_LINK_EDIT = HTML_LINK_EDIT  & "&nbsp;"
						End If
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass
           
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE
						Exit Function						
        Case 2
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='16'>"
						If FrameWork.CheckCoarseCapability("View group subscriptions") Then
            	HTML_LINK_EDIT = HTML_LINK_EDIT  & "<A HRef='" & mam_GetDictionary("GROUP_MEMBER_LIST_DIALOG") & "?id=" &  ProductView.Properties("id_group") & "'><img src='" & mam_GetImagesPath() &  "/group.gif' Border='0'></A>"						
						Else
							HTML_LINK_EDIT = HTML_LINK_EDIT  & "&nbsp;"
						End If
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass
           
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE
						Exit Function
  End Select						 

	' Rest of selected columns by column name
	Select Case lcase(Form.Grid.SelectedProperty.Name)

				Case "tx_name"
				    strHTML = ProductView.Properties("tx_name")		
						EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strHTML & "</td>"
						Form_DisplayCell = TRUE
				Case "tx_desc"
				    strHTML = ProductView.Properties("tx_desc")		
						EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "'>" & strHTML & "</td>"
						Form_DisplayCell = TRUE						
				Case "id_group"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' Width='200' align='center'>"
						If FrameWork.CheckCoarseCapability("Manage Group Custom Rates") Then
							HTML_LINK_EDIT = HTML_LINK_EDIT  & "<button name='butRate" & ProductView.Properties("id_group") & "' class='clsButtonBlueMedium' onclick=""document.location.href='" & mam_GetDictionary("RATES_DIALOG") & "?LinkColumnMode=TRUE&id_sub=" & ProductView.Properties("id_sub") & "&id_group=" &  ProductView.Properties("id_group") & "';return false;"" >" & mam_GetDictionary("TEXT_RATES") & "</button>"
            End If
						If FrameWork.CheckCoarseCapability("Delete Subscription") Then
  	    			HTML_LINK_EDIT = HTML_LINK_EDIT  & "<button name='butDelete" & ProductView.Properties("id_group") & "' class='clsButtonBlueMedium' onclick=""document.location.href='" & mam_GetDictionary("REMOVE_GROUP_SUBSCRIPTION_DIALOG") & "?id_group=" &  ProductView.Properties("id_group") & "';return false;"" >" & mam_GetDictionary("TEXT_DELETE") & "</button>"
            End If
						
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "&nbsp;"
						
            
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass
           
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE
				
				Case "vt_start"
				    strHTML = mam_GetDisplayEndDate(ProductView.Properties("vt_start"))
						EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' nowrap>" & strHTML & "</td>"
						Form_DisplayCell = TRUE		
				Case "vt_end"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' align='left' nowrap>"
						HTML_LINK_EDIT = HTML_LINK_EDIT  & mam_GetDisplayEndDate(ProductView.Properties("vt_end"))
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"
						
						Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass
           
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE

				Case "b_visable"
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "<td class='[CLASS]' align='center'>"
						HTML_LINK_EDIT = HTML_LINK_EDIT  & "<button class='clsButtonBlueMedium' onclick=""document.location.href='" & mam_GetDictionary("GROUP_MEMBER_LIST_DIALOG") & "?id=" &  ProductView.Properties("id_group") & "'"" name='membership'>" & "Membership" & "</button>" ' Localize me
            HTML_LINK_EDIT = HTML_LINK_EDIT  & "</td>"        
            
            Set m_objPP = mdm_CreateObject(CPreProcessor)
            m_objPP.Add "CLASS"       , Form.Grid.CellClass
           
            EventArg.HTMLRendered     = m_objPP.Process(HTML_LINK_EDIT)
            Form_DisplayCell          = TRUE

        Case Else        
            Form_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation
    End Select
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION   :  inheritedForm_DisplayEndOfPage
' PARAMETERS :  EventArg
' DESCRIPTION:  Override end of table to place add button
' RETURNS    :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    dim strEndOfPageHTMLCode
    
    ' Call the inherited event so we close the ProductVIew Browser as it should be
    ' Becare full this function is setting     EventArg.HTMLRendered
    Inherited("Form_DisplayEndOfPage()")
		
    strEndOfPageHTMLCode = "<br><div align='center'>"
        		
    '  add some code at the end of the product view UI
    ' ADD GROUP 
		If FrameWork.CheckCoarseCapability("Create group subscriptions") Then
    	strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<button " & Form("DisabledAdd") & " class='clsButtonLarge' name=""ADDGROUP"" onclick=""window.location.href='" & mam_GetDictionary("GROUP_PRODUCT_OFFERING_SELECT_DIALOG") & "?MDMReload=TRUE&MONOSELECT=TRUE&NextPage=" & mam_GetDictionary("GROUP_ADD_DIALOG") & "&Parameters=Action|New;CorpAccID|" & Form("CorpID") & "';retrun false;"">" & mam_GetDictionary("TEXT_BUTTON_ADD_NEW_GROUP_SUBSCRIPTION") & "</button>"
    End If
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "&nbsp;&nbsp;<BUTTON Name='CANCEL' Class='clsOKButton' OnClick='mdm_RefreshDialog(this);'>Cancel</BUTTON>"
   	strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</div>"
    	    
    ' Here we must not forget to concat rather than set because we want to keep the result of the inherited event.
    EventArg.HTMLRendered = EventArg.HTMLRendered & strEndOfPageHTMLCode
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION

%>


