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
' CLASS       : DefaultDialogSubscribe.asp
' DESCRIPTION : 
' 
' PICKER INTERFACE : A Picker ASP File Interface is based on the QueryString Name/Value.
'                    NextPage : The url to execute if a user click a one item. This url must accept a querystring
'                    parameter ID. ID will contains this id of the Item.
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/common/mdmList.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" --> 
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.Page.NoRecordUserMessage   = mam_GetDictionary("PRODUCT_VIEW_BROWSER_NO_RECORDS_FOUND")
mdm_PVBrowserMain ' invoke the mdm framework

PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
	Form("Sub_ID") 	 = Request.QueryString("id_sub")
	Form("Group_ID") = Request.QueryString("id_group")
	
	If Len(Request.QueryString("NewMetraCare")) > 0 Then
	  if Len(Form("Group_ID")) = 0 Then
	    Form.RouteTo = "/MetraNet/StartWorkFlow.aspx?WorkFlowName=SubscriptionsWorkflow"
	  else
	     Form.RouteTo = "/MetraNet/StartWorkFlow.aspx?WorkFlowName=GroupSubscriptionsWorkflow"
	  end if
	Else
	
	  Form("BackToAccountSubs") = CBool(Request.QueryString("BackToAccountSubs"))
  	
	  ' We are going back to different places depending on where we came from
	  if Len(Form("Group_ID")) = 0 or Form("BackToAccountSubs") then
		  Form.RouteTo = mam_GetDictionary("SETUP_SUBSCRIPTIONS_DIALOG")
	  else
		  Form.RouteTo = mam_GetDictionary("GROUP_SUBSCRIPTIONS_DIALOG")
	  end if
	
	End If
	
	Form_Initialize = MDMListDialog.Initialize(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION        :  Form_LoadProductView
' PARAMETERS      :
' DESCRIPTION     : 
' RETURNS         :  Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean

  Dim objMTProductCatalog  
  Dim MTAccountReference
	Dim mtSQLRowset
  Dim acctID
  dim currentSub
	
  Form_LoadProductView = FALSE
  
  Set objMTProductCatalog = GetProductCatalogObject

	if Len(Form("Group_ID")) = 0 then
  	Set MTAccountReference = objMTProductCatalog.GetAccount(mam_GetSubscriberAccountID())
	  set currentSub = MTAccountReference.GetSubscription(CLng(Form("Sub_ID")))
	  FrameWork.Dictionary.Remove "SUBSCRIPTION_NAME"
      FrameWork.Dictionary.Add "SUBSCRIPTION_NAME", ""
	else
		set currentSub = objMTProductCatalog.GetGroupSubscriptionByID(CLng(Form("Group_ID")))
        FrameWork.Dictionary.Remove "SUBSCRIPTION_NAME"
		FrameWork.Dictionary.Add "SUBSCRIPTION_NAME", currentSub.Name
	end if
  
  Set ProductView.Properties.RowSet = currentSub.GetParamTablesAsRowset
	
  ProductView.Properties.ClearSelection
  
  if false then
  ProductView.Properties.SelectAll
  else
' Select the properties I want to print in the PV Browser   Order
  ProductView.Properties("instance_nm_name").Selected        = 1
  ProductView.Properties("pt_nm_display_name").Selected 	   = 2
  ProductView.Properties("po_nm_name").Selected 	         	 = 3
  ProductView.Properties("dt_start").Selected                = 4
  ProductView.Properties("dt_end").Selected 	             	 = 5
  ProductView.Properties("b_PersonalRate").Selected 	     	 = 6
  ProductView.Properties("b_canICB").Selected 	             = 7
    
  ProductView.Properties("instance_nm_name").Caption         = mam_GetDictionary("TEXT_PRICEABLE_ITEM")
  ProductView.Properties("po_nm_name").Caption 	             = mam_GetDictionary("TEXT_SUBSCRIPTION")
  ProductView.Properties("pt_nm_display_name").Caption 	     = mam_GetDictionary("TEXT_PARAMETER_TABLE")
  ProductView.Properties("dt_start").Caption                 = mam_GetDictionary("TEXT_RATES_COLUMN_START_DATE")
  ProductView.Properties("dt_end").Caption 	                 = mam_GetDictionary("TEXT_RATES_COLUMN_END_DATE")
  ProductView.Properties("b_PersonalRate").Caption 	         = mam_GetDictionary("TEXT_HAS_PERSONAL_RATES")
  ProductView.Properties("b_canICB").Caption 	             	 = mam_GetDictionary("TEXT_CAN_ICB")  
  Service.Properties("dt_start").Format = FrameWork.GetDictionary("DATE_FORMAT") 
  Service.Properties("dt_end").Format = FrameWork.GetDictionary("DATE_FORMAT")
  end if
      
  ProductView.Properties("instance_nm_name").Sorted = MTSORT_ORDER_ASCENDING
  Set Form.Grid.FilterProperty           = ProductView.Properties("instance_nm_name") ' Set the property on which to apply the filter  
  
  Form_LoadProductView = TRUE
  
END FUNCTION


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
            'SECENG: Added HTML encoding
            EventArg.HTMLRendered  =  "<td class=" & Form.Grid.CellClass & "><img src='" & mdm_GetIconUrlForPriceableItem(ProductView.Properties.Rowset.Value("nm_name"),ProductView.Properties.Rowset.Value("n_kind")) & "' alt='' border='0' align='top'>&nbsp;" & SafeForHtml(ProductView.Properties.Rowset.Value("instance_nm_name")) & "</td>"

        Case 4
            Inherited("Form_DisplayCell()")
            lngPos                = InStr(EventArg.HTMLRendered,">") ' Find the first >
            EventArg.HTMLRendered = MDMListDialog.Tools.InsertAStringAt(EventArg.HTMLRendered, "<img src='" & mdm_GetIconUrlForParameterTable(ProductView.Properties.Rowset.Value("pt_nm_name")) & "' alt='' border='0' align='top'>&nbsp;<A Name='[ANCHOR_NAME]' HREF='[URL]?RateTitle=[RateTitle]&POBased=TRUE&ID=[ID]&PT_ID=[PT_ID]&PI_ID=[PI_ID]&PO_ID=[PO_ID]&Sub_ID=[Sub_ID]&Group_ID=[Group_ID]&BackToAccountSubs=" & Form("BackToAccountSubs") & "'>",lngPos+1) ' Insert after >
            EventArg.HTMLRendered = Replace(EventArg.HTMLRendered,"</td>","</a></td>")
            
            MDMListDialog.PreProcessor.Clear
            MDMListDialog.PreProcessor.Add "URL"        , mam_GetDictionary("RATE_SCHEDULE_DIALOG")
            MDMListDialog.PreProcessor.Add "ID"         , ProductView.Properties.Rowset.Value("id_paramtable")
            MDMListDialog.PreProcessor.Add "PT_ID"      , ProductView.Properties.Rowset.Value("id_paramtable")
            MDMListDialog.PreProcessor.Add "PI_ID"      , ProductView.Properties.Rowset.Value("id_pi_instance")
            MDMListDialog.PreProcessor.Add "PO_ID"      , ProductView.Properties.Rowset.Value("id_po")
            MDMListDialog.PreProcessor.Add "Sub_ID"     , ProductView.Properties.Rowset.Value("id_sub")
						MDMListDialog.PreProcessor.Add "Group_ID"   , Form("Group_ID")
            'SECENG: Added HTML encoding
            MDMListDialog.PreProcessor.Add "RateTitle"  , ProductView.Properties.Rowset.Value("pt_nm_display_name")
						MDMListDialog.PreProcessor.Add "ANCHOR_NAME", "apt_" & SafeForHtmlAttr(ProductView.Properties.Rowset.Value("instance_nm_name"))

            EventArg.HTMLRendered = MDMListDialog.PreProcess(EventArg.HTMLRendered)

			  case 8  ' has personal rates?
            If ProductView.Properties.Rowset.Value("b_PersonalRate") = "Y" Then
              EventArg.HTMLRendered     =  "<td class=" & Form.Grid.CellClass & " align='center'><img src='../localized/en-us/images/check.gif'></td>"
            Else
              EventArg.HTMLRendered     =  "<td class=" & Form.Grid.CellClass & " align='center'>--&nbsp;</td>"
            End If
          
        case 9  ' can ICB?
            If ProductView.Properties.Rowset.Value("b_canICB") = "Y" Then
              EventArg.HTMLRendered     =  "<td class=" & Form.Grid.CellClass & " align='center'><img src='../localized/en-us/images/check.gif'></td>"
            Else
              EventArg.HTMLRendered     =  "<td class=" & Form.Grid.CellClass & " align='center'>--&nbsp;</td>"
            End If
        
        Case Else
           LinkColumnMode_DisplayCell =  Inherited("Form_DisplayCell()") ' Call the default implementation           
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
    
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<BR><CENTER><BUTTON Name='CANCEL' Class='clsOKButton' OnClick='mdm_RefreshDialog(this); return false;'>Back</BUTTON></center>"
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</FORM>"    
    EventArg.HTMLRendered= EventArg.HTMLRendered & strEndOfPageHTMLCode 
    
    If(COMObject.COnfiguration.DebugMode)Then ' If in debug mode display the selection
       EventArg.HTMLRendered = EventArg.HTMLRendered  & "<hr size=1>" & Replace(Form("SelectedIDs").ToString(),vbNewline,"<br>") & "<br>"
    End If
    
    Form_DisplayEndOfPage = TRUE
END FUNCTION



%>

