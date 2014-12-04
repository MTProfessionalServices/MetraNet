<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>

 <% 
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: Rates.RateSchedule.List.asp
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
'  $Date: 5/11/00 12:00:08 PM$
'  $Author: $
'  $Revision: 1$
'
' - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
'
' CLASS       : Rates.RateSchedule.List.asp
' DESCRIPTION : Displays rate schedules associated with parameter table.
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")

mdm_PVBrowserMain ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  getParamTablePage
' PARAMETERS:  parameter table id
' DESCRIPTION: looks up in the dictionary if a custom page exists for this parameter table.
' RETURNS:  URL of custom page or regular ruleeditor screen if none

FUNCTION getParamTablePage(pt_id)
	Dim objProdcat, objParamTableDef, destiny_url
	Set objProdcat = GetProductCatalogObject
	Set objParamTableDef = objProdcat.GetParamTableDefinition(pt_id)
	
	' We retrieve the parameter table name and check whether there is a special screen for it in the dictionary
	'destiny_url = mam_GetDictionaryDefault(objParamTableDef.Name, "")
	destiny_url=""
	' It the result is blank, we will go to the default MPTE url
	if destiny_url = "" then
		getParamTablePage = mam_GetDictionary("RULE_EDITOR_DIALOG")
	else
		getParamTablePage = destiny_url
	end if
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION: Initializes rowset to be displayed
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
  Dim objMTProductCatalog, objPriceableItem, objPricelistMap, objProdOff
  Dim booICBable
  
  booICBable = FALSE
  ' Save our querystring in the form, so the refresh works
  Form("ID")     	 = CLng(Request.QueryString("ID"))
  Form("Sub_ID") 	 = CLng(Request.QueryString("Sub_ID"))
  Form("PO_ID")  	 = CLng(Request.QueryString("PO_ID"))
  Form("PI_ID")  	 = CLng(Request.QueryString("PI_ID"))
  Form("PT_ID")  	 = CLng(Request.QueryString("PT_ID"))
	Form("Group_ID") = Request.QueryString("Group_ID")
	
	' Need to give the group id and sub id
	Form.RouteTo = mam_GetDictionary("RATES_DIALOG") & "?LinkColumnMode=TRUE" & "&id_group=" & Form("Group_ID") & "&id_sub=" & Form("Sub_ID") & "&BackToAccountSubs=" & Request.QueryString("BackToAccountSubs") & "&mdmPageAction=REDRAW" ' add refresh to restore page we were on
	
  session("ownerapp_return_page") = mam_GetDictionary("RATE_SCHEDULE_DIALOG") & "?" & request.QueryString()

  ' Set QueryString for New Rate Schedule dialog
  mdm_GetDictionary().remove "QUERYSTRING"
  mdm_GetDictionary().remove "RATESCHEDULETITLE"
  mdm_GetDictionary().add "QUERYSTRING", "?" & request.QueryString
  mdm_GetDictionary().add "RATESCHEDULETITLE", Request.QueryString("RateTitle")
  
  ' Can ICB?
  Set objMTProductCatalog = GetProductCatalogObject
  Set objProdOff = objMTProductCatalog.GetProductOffering(Form("PO_ID"))
  Set objPriceableItem = objProdOff.GetPriceableItem(Form("PI_ID"))
  Set objPricelistMap = objPriceableItem.GetPricelistMapping(Form("ID"))
  booICBable = CBool(objPricelistMap.CanICB)
	
	'First capability check
	If booICBable Then
		If Len(Form("Group_ID")) Then
			If not FrameWork.CheckCoarseCapability("Manage Group Custom Rates") Then
				booICBable = FALSE 'PLmap is ICBeable but user doesn't have the capability to do so
			End If
		Else
			If not FrameWork.CheckCoarseCapability("Manage Custom Rates") Then
				booICBable = FALSE 'PLmap is ICBeable but user doesn't have the capability to do so
			End If
		End If
	End If
	
  mdm_GetDictionary().add "CANICB"
  mdm_GetDictionary().add "CANICB", CStr(booICBable)   'Conditional render new personal rate button
    
	Form_Initialize = MDMListDialog.Initialize(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_LoadProductView
' PARAMETERS:  EventArg
' DESCRIPTION: 
' RETURNS:  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog, objPriceableItem, objPricelistMap, objProdOff
  Dim MTAccountReference, MTSubs
  Dim acctID
  Dim defaultRowset
  Dim ICBRowset
  
  Form_LoadProductView = FALSE
  
  Set objMTProductCatalog = GetProductCatalogObject

  ' Get ICBRowset
	' Here we need to see if this is a normal subscription or a group subscription. Then get the ICB PL mapping properly
	if Len(Form("Group_ID")) then
		Set MTSubs = objMTProductCatalog.GetGroupSubscriptionByID(CLng(Form("Group_ID")))
	else
		acctID = mam_GetSubscriberAccountID()
		Set MTAccountReference = objMTProductCatalog.GetAccount(acctID)
  	Set MTSubs = MTAccountReference.GetSubscription(Form("Sub_ID"))
	end if
	
  Set objPricelistMap = MTSubs.GetICBPriceListMapping(Form("PI_ID"), Form("PT_ID"))
  If IsValidObject(objPricelistMap) Then
    Form("PL_ID")  	 = objPricelistMap.PriceListId
    Set ICBRowset = objPricelistMap.FindRateSchedulesAsRowset()
  End If
  
  ' Get defaultRowset
  Set objProdOff = objMTProductCatalog.GetProductOffering(Form("PO_ID"))
  Set objPriceableItem = objProdOff.GetPriceableItem(Form("PI_ID"))
  Set objPricelistMap = objPriceableItem.GetPricelistMapping(Form("ID"))
  Set defaultRowset = objPricelistMap.FindRateSchedulesAsRowset()

  ' Join rowsets and set  
  Set ProductView.Properties.RowSet = JoinRowsets(defaultRowset, ICBRowset)

  ProductView.Properties.ClearSelection
 
  ProductView.Properties("nm_desc").Selected 			= 1
  ProductView.Properties("dt_start").Selected 	  = 2
  ProductView.Properties("dt_end").Selected 	    = 3
  ProductView.Properties("ICBed").Selected 	      = 4
  ProductView.Properties("id_sched").Selected 	  = 5

  ProductView.Properties("nm_desc").Caption			  = mam_GetDictionary("TEXT_COLUMN_DESCRIPTION")
  ProductView.Properties("dt_start").Caption	    = mam_GetDictionary("TEXT_START_DATE")
  ProductView.Properties("dt_end").Caption		    = mam_GetDictionary("TEXT_END_DATE")
  ProductView.Properties("ICBed").Caption		      = mam_GetDictionary("TEXT_PERSONAL_RATE")
  ProductView.Properties("id_sched").Caption		  = mam_GetDictionary("TEXT_OPTIONS")
    
  ProductView.Properties("dt_start").Sorted         = MTSORT_ORDER_DECENDING
 
  Set Form.Grid.FilterProperty                     = ProductView.Properties("nm_desc") ' Set the property on which to apply the filter
  Form_LoadProductView                            = TRUE ' Must Return TRUE To Render The Dialog
  
END FUNCTION

'----------------------------------------------------------------------------------------------------------------------------------------
Const MaxDate = #12/31/9999#

'----------------------------------------------------------------------------------------------------------------------------------------
Private Function GetEndDate(endDate)
    If IsNull(endDate) Then
       GetEndDate = MaxDate
    Else
       GetEndDate = endDate
    End If
End Function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: JoinRowsets
' PARAMETERS	:
' DESCRIPTION : Joins two rowsets together, default rowset and ICB rowsets
' RETURNS		  : Returns new rowset
Private Function JoinRowsets(rowsetDefault, rowsetICB)
    Dim newRowset

    Set newRowset = CreateObject("MTSQLRowset.MTSQLRowset.1")
    newRowset.InitDisconnected
    
    ' Add columns to new rowset
    newRowset.AddColumnDefinition "id_sched",  "int32",  10
    newRowset.AddColumnDefinition "nm_desc",   "string", 255
    newRowset.AddColumnDefinition "dt_start", "timestamp",  255
    newRowset.AddColumnDefinition "dt_end", "timestamp",  255
    newRowset.AddColumnDefinition "n_begintype", "string",  255
    newRowset.AddColumnDefinition "n_endtype",   "string",  255
    newRowset.AddColumnDefinition "n_beginoffset",   "string",  255    
    newRowset.AddColumnDefinition "n_endoffset",   "string",  255    
    newRowset.AddColumnDefinition "ICBed",    "int32",   10

    ' Fill new rowset
    newRowset.OpenDisconnected
    
    If IsValidObject(rowsetDefault) Then        
		If (rowsetDefault.RecordCount) Then 
		  rowsetDefault.MoveFirst
		  Do While Not rowsetDefault.EOF
          newRowset.AddRow
		      newRowset.AddColumnData "id_sched",CLng(rowsetDefault.Value("id_sched"))
		      newRowset.AddColumnData "nm_desc", "" & rowsetDefault.Value("nm_desc")
		      newRowset.AddColumnData "dt_start", rowsetDefault.Value("dt_start")
		      newRowset.AddColumnData "dt_end", GetEndDate(rowsetDefault.Value("dt_end"))
		      newRowset.AddColumnData "n_begintype","" & rowsetDefault.Value("n_begintype")
		      newRowset.AddColumnData "n_endtype",  "" & rowsetDefault.Value("n_endtype")
		      newRowset.AddColumnData "n_beginoffset",  "" & rowsetDefault.Value("n_beginoffset")          
		      newRowset.AddColumnData "n_endoffset",  "" & rowsetDefault.Value("n_endoffset")            
		      newRowset.AddColumnData "ICBed",   False
		      rowsetDefault.MoveNext
		  Loop
		End If 
    End If    

    If IsValidObject(rowsetICB) Then
		If (rowsetICB.RecordCount) Then 
		  rowsetICB.MoveFirst
		  Do While Not rowsetICB.EOF
		      newRowset.AddRow
		      newRowset.AddColumnData "id_sched", CLng(rowsetICB.Value("id_sched"))
		      newRowset.AddColumnData "nm_desc",  "" & rowsetICB.Value("nm_desc")
		      newRowset.AddColumnData "dt_start", rowsetICB.Value("dt_start")
		      newRowset.AddColumnData "dt_end", GetEndDate(rowsetICB.Value("dt_end"))
		      newRowset.AddColumnData "n_begintype", "" & rowsetICB.Value("n_begintype")
		      newRowset.AddColumnData "n_endtype",   "" & rowsetICB.Value("n_endtype")
		      newRowset.AddColumnData "n_beginoffset",   "" & rowsetICB.Value("n_beginoffset")          
		      newRowset.AddColumnData "n_endoffset",   "" & rowsetICB.Value("n_endoffset")           
		      newRowset.AddColumnData "ICBed",   True
		      rowsetICB.MoveNext
		  Loop
		End If 
    End IF

    set JoinRowsets = newRowset
            
End function

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: ViewEditMode_DisplayCell
' PARAMETERS	:
' DESCRIPTION :   We will override the MDM function that takes care of this,
' 				in orther to have better nnavigation control
' RETURNS		  : Return TRUE if ok else FALSE
PUBLIC FUNCTION ViewEditMode_DisplayCell(EventArg) ' As Boolean

    Dim HTML_LINK_EDIT
    
    Select Case Form.Grid.Col
    
        Case 1
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<td class='[CLASS]' width='40'>"

            If  CBool(ProductView.Properties.Rowset.Value("ICBed")) and CBool(mam_GetDictionary("CANICB")) Then
              HTML_LINK_EDIT = HTML_LINK_EDIT & "<A HREF='[ASP_PAGE]?EditMode=TRUE&Reload=TRUE&refresh=TRUE&PT_ID=[PT_ID]&RS_ID=[RS_ID]'><img Alt='[ALT_EDIT]' src='[IMAGE_EDIT]' Border='0'></A>&nbsp;"
            Else
              HTML_LINK_EDIT = HTML_LINK_EDIT & "<A HREF='[ASP_PAGE]?EditMode=FALSE&Reload=TRUE&refresh=TRUE&PT_ID=[PT_ID]&RS_ID=[RS_ID]'><img Alt='[ALT_VIEW]' src='[IMAGE_VIEW]' Border='0'></A>"
            End IF
            
      			HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
            
            MDMListDialog.PreProcessor.Clear
          
            MDMListDialog.PreProcessor.Add "CLASS"       , Form.Grid.CellClass        
            MDMListDialog.PreProcessor.Add "ASP_PAGE"    , getParamTablePage(Form("PT_ID"))
            MDMListDialog.PreProcessor.Add "IMAGE_EDIT"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/edit.gif"
            MDMListDialog.PreProcessor.Add "IMAGE_VIEW"  , Application("APP_HTTP_PATH") & "/default/localized/en-us/images/view.gif"
            MDMListDialog.PreProcessor.Add "ALT_VIEW"    , mam_GetDictionary("TEXT_VIEW")
            MDMListDialog.PreProcessor.Add "ALT_EDIT"    , mam_GetDictionary("TEXT_EDIT")
	      		MDMListDialog.PreProcessor.Add "PT_ID"    	 , Form("PT_ID")
			      MDMListDialog.PreProcessor.Add "RS_ID"    	 , ProductView.Properties.Rowset.Value("id_sched")
            
            EventArg.HTMLRendered           = MDMListDialog.PreProcess(HTML_LINK_EDIT)
            ViewEditMode_DisplayCell        = TRUE
        Case 2
            mdm_NoTurnDownHTML EventArg ' Takes Care Of Removing the TurnDown
            
        Case 4 'start date
            Dim dateStart
            dateStart = ProductView.Properties.Rowset.Value("dt_start")
            If CLng(ProductView.Properties.Rowset.Value("n_begintype")) = PCDATE_TYPE_SUBSCRIPTION Then
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' align='left'>"
              EventArg.HTMLRendered = EventArg.HTMLRendered & ProductView.Properties.Rowset.Value("n_beginoffset") & mam_GetDictionary("TEXT_DAYS_AFTER") & mam_FormatDate(dateStart, "") & " (" & GetDateFieldString(ProductView.Properties.Rowset.Value("n_begintype")) & ")"
              EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
            Else  
              'SECENG: ESR-5050: BCAN 6.5 : Can't view a rate schedule in MetraCare
              'Check for Null value added
              If len(ltrim(rtrim(ProductView.Properties.Rowset.Value("dt_start"))))=0 Or IsNull(ProductView.Properties.Rowset.Value("dt_start")) Then  
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' align='left'>"
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<img align='absmiddle' src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/infinity.gif" &"'>" & " (" & GetDateFieldString(ProductView.Properties.Rowset.Value("n_begintype")) & ")"
                EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
              Else
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' align='left'>"
                EventArg.HTMLRendered = EventArg.HTMLRendered & mam_FormatDate(dateStart, "") & " (" & GetDateFieldString(ProductView.Properties.Rowset.Value("n_begintype")) & ")"
                EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
              End IF
            End If
            ViewEditMode_DisplayCell        = TRUE  
            
        case 5 'end date  
            Dim dateEnd
            dateEnd = ProductView.Properties.Rowset.Value("dt_end") 
            If CLng(ProductView.Properties.Rowset.Value("n_endtype")) = PCDATE_TYPE_SUBSCRIPTION Then
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' align='left'>"
              EventArg.HTMLRendered = EventArg.HTMLRendered & ProductView.Properties.Rowset.Value("n_endoffset") & mam_GetDictionary("TEXT_DAYS_AFTER") & mam_FormatDate(dateEnd, "") & " (" & GetDateFieldString(ProductView.Properties.Rowset.Value("n_endtype")) & ")"
              EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
            Else 
              If CDate(ProductView.Properties.Rowset.Value("dt_end")) = MaxDate Then  
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' align='left'>"
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<img align='absmiddle' src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/infinity.gif" &"'>" & " (" & GetDateFieldString(ProductView.Properties.Rowset.Value("n_endtype")) & ")"
                EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
              Else
                EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' align='left'>"
                EventArg.HTMLRendered = EventArg.HTMLRendered & mam_FormatDate(dateEnd, "") & " (" & GetDateFieldString(ProductView.Properties.Rowset.Value("n_endtype")) & ")"
                EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
              End IF
            End If
            ViewEditMode_DisplayCell        = TRUE  
                    
        case 6
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & Form.Grid.CellClass & "' align='center' width='40'>"
            
            If CBool(ProductView.Properties.Rowset.Value("ICBed")) Then
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<img src='" & Application("APP_HTTP_PATH") & "/default/localized/en-us/images/check.gif'>"
            Else
              EventArg.HTMLRendered = EventArg.HTMLRendered & "--"
            End If
            
            EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
            ViewEditMode_DisplayCell        = TRUE  
            
        case 7 ' OPTIONS
            HTML_LINK_EDIT = HTML_LINK_EDIT & "<td nowrap class='[CLASS]'  align='left' >"

            If  CBool(ProductView.Properties.Rowset.Value("ICBed")) and CBool(mam_GetDictionary("CANICB")) Then
              HTML_LINK_EDIT = HTML_LINK_EDIT & "<button class='clsButtonBlueLarge' onclick='JavaScript:document.location.href=""[ASP_PAGE]?MDMReload=TRUE&EditMode=TRUE&Reload=TRUE&refresh=TRUE&PT_ID=[PT_ID]&RS_ID=[RS_ID]""; return false;'>[MY_BUTTON]</button>&nbsp;&nbsp;&nbsp;"
            Else
              'HTML_LINK_EDIT = HTML_LINK_EDIT & "&nbsp;"
            End IF

      			'HTML_LINK_EDIT = HTML_LINK_EDIT & "&nbsp;&nbsp;&nbsp;"
			      HTML_LINK_EDIT = HTML_LINK_EDIT & "<button name='viewhistory[RS_ID]' class='clsButtonBlueMedium' onclick=""window.open('Rates.RateSchedule.ViewHistory.asp?MDMReload=TRUE&EditMode=TRUE&Reload=TRUE&refresh=TRUE&PT_ID=[PT_ID]&RS_ID=[RS_ID]&PL_ID=[PL_ID]','_blank', 'height=600,width=800,resizable=yes,scrollbars=yes'); return false;"">View History</button>"
            
      			HTML_LINK_EDIT = HTML_LINK_EDIT & "</td>"
            
            MDMListDialog.PreProcessor.Clear
          
            MDMListDialog.PreProcessor.Add "CLASS"       , Form.Grid.CellClass        
            MDMListDialog.PreProcessor.Add "ASP_PAGE"    , mam_GetDictionary("RATE_SCHEDULE_PROPERTIES_DIALOG")
            MDMListDialog.PreProcessor.Add "MY_BUTTON"   , mam_GetDictionary("TEXT_EDIT_PROPERTIES")
	      		MDMListDialog.PreProcessor.Add "PT_ID"    	 , Form("PT_ID")
			      MDMListDialog.PreProcessor.Add "RS_ID"    	 , ProductView.Properties.Rowset.Value("id_sched")
			      MDMListDialog.PreProcessor.Add "PL_ID"    	 , Form("PL_ID")
            
            EventArg.HTMLRendered           = MDMListDialog.PreProcess(HTML_LINK_EDIT)
            ViewEditMode_DisplayCell        = TRUE            
        Case Else
        
           ViewEditMode_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation           
    End Select
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION      :  Form_DisplayEndOfPage
' PARAMETERS    :  
' DESCRIPTION   :  Over ride the MDM Default event Form_DisplayEndOfPage()
'                  If the client over ride this event it is not possible to call it as the Inherited event.
'                  Because the inherited event is the one defined in the file mdm\mdmPVBEvents.asp, this
'                  is a limitation of a picker.

' RETURNS       :  Return TRUE if ok else FALSE
PUBLIC FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean

    dim strEndOfPageHTMLCode
    
    ' Call the inherited event so we close the ProductVIew Browser as it should be
    ' Becare full this function is setting     EventArg.HTMLRendered
    Inherited("Form_DisplayEndOfPage()")
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<BR><CENTER><BUTTON Name='CANCEL' Class='clsOKButton' OnClick='mdm_RefreshDialog(this);'>Back</BUTTON></center>"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</FORM>"    
    EventArg.HTMLRendered= EventArg.HTMLRendered & strEndOfPageHTMLCode 
    
    If(COMObject.COnfiguration.DebugMode)Then ' If in debug mode display the selection
       EventArg.HTMLRendered = EventArg.HTMLRendered  & "<hr size=1>" & Replace(Form("SelectedIDs").ToString(),vbNewline,"<br>") & "<br>"
    End If
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION



%>

