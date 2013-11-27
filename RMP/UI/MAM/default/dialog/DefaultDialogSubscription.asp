<%@ LANGUAGE="VBscript" CODEPAGE=65001 %>
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
' MetraTech Account Manager 
' 
' DIALOG	    : MCM Dialog
' DESCRIPTION	: 
' AUTHOR	    : K.Boucher
' VERSION	    : 2.0
'
' ---------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE FILE="../../MamIncludeMDM.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MamLibrary.asp" -->
<!-- #INCLUDE FILE="../../default/lib/MTProductCatalog.Library.asp" -->
<!-- #INCLUDE FILE="../../default/lib/TabsClass.asp" -->
<!-- #INCLUDE FILE="../../custom/Lib/CustomCode.asp" -->
<%
Form.Version        = MDM_VERSION     ' Set the dialog version - we are version 2.0.
Form.RouteTo        = MAM_GetDictionary("WELCOME_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Form_Initialize
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Form_Initialize(EventArg) ' As Boolean
  Dim objMTProductCatalog  
  Dim MTAccountReference ' As MTAccountReference
  Dim acctID             ' As Long
  Dim subsRowset
	Dim CorpAccID
	Dim objMTFilter

  mdm_GetDictionary.Add "ShowSubs", false
  		
  session("SUBS_DATE_CANCEL_ROUTETO") = request.serverVariables("URL") & "?" & request.serverVariables("QUERY_STRING")
  	
  ' Add Properties
  Service.Properties.Add "Title", "String",  256, FALSE, ""  
  Service.Properties.Add "Message", "String",  256, FALSE, ""
	Service.Properties.Add "GroupMessage", "String",  256, FALSE, ""
	
  Form.Grids.Add "Subscriptions", "Subscriptions" 
  Form.Grids.Add "GroupSubscriptions", "GroupSubscriptions"
	  
  Service.Properties("Message") = ""
  Service.Properties("GroupMessage") = ""
		
  Set objMTProductCatalog = GetProductCatalogObject
  acctID = mam_GetSubscriberAccountID()
	mdm_GetDictionary.Add "AccountID", acctID
	
  ' Get account reference
  Set MTAccountReference = objMTProductCatalog.GetAccount(acctID)
	If UCase(session("SubscriberYAAC").AccountType) <> "IND" Then
		CorpAccID = session("SubscriberYAAC").CorporateAccountID
		mdm_GetDictionary.Add "CorpID", CorpAccID
		mdm_GetDictionary.Add "ShowGroupGrid", true
	Else
		mdm_GetDictionary.Add "ShowGroupGrid", false
	End If
        
  Service.Properties("Title") = mam_GetDictionary("TEXT_SUBSCRIPTIONS")  
  
	'Get Date Filter
	Set objMTFilter = GetSubscriptionDateFilter()
  
  ' Populate subscriptions grid from rowset    
  Set Form.Grids("Subscriptions").Rowset = MTAccountReference.GetSubscriptionsAsRowset	
  
  If IsValidObject(objMTFilter) Then Set Form.Grids("Subscriptions").Rowset.filter = objMTFilter
	
  Form.Grids("Subscriptions").Width      = "100%"	
  Form.Grids("Subscriptions").Properties.ClearSelection
	'Form.Grids("Subscriptions").Properties.SelectAll
 
  ' Setup columns
	Form.Grids("Subscriptions").Properties("id_acc").Selected								 = 1
	Form.Grids("Subscriptions").Properties("id_po").Selected								 = 2
  Form.Grids("Subscriptions").Properties("po_nm_display_name").Selected    = 3
  Form.Grids("Subscriptions").Properties("b_RecurringCharge").Selected     = 4
  Form.Grids("Subscriptions").Properties("b_Discount").Selected            = 5
  Form.Grids("Subscriptions").Properties("b_PersonalRate").Selected        = 6
  Form.Grids("Subscriptions").Properties("dt_start").Selected              = 7
  Form.Grids("Subscriptions").Properties("dt_end").Selected                = 8
  Form.Grids("Subscriptions").Properties("id_sub").Selected                = 9
          
  ' Localize columns
	Form.Grids("Subscriptions").Properties("id_acc").Caption 								= "&nbsp;" 
	Form.Grids("Subscriptions").Properties("id_po").Caption 								= "Status"
  Form.Grids("Subscriptions").Properties("po_nm_display_name").Caption 		= mam_GetDictionary("TEXT_SUBSCRIPTION")
  Form.Grids("Subscriptions").Properties("b_RecurringCharge").Caption 		= mam_GetDictionary("TEXT_RECURRING_CHARGE")
  Form.Grids("Subscriptions").Properties("b_Discount").Caption 		        = mam_GetDictionary("TEXT_DISCOUNT")
  Form.Grids("Subscriptions").Properties("b_PersonalRate").Caption 	    	= mam_GetDictionary("TEXT_PERSONAL_RATE")
	Form.Grids("Subscriptions").Properties("dt_start").Caption							= mam_GetDictionary("TEXT_START_DATE")
 	Form.Grids("Subscriptions").Properties("dt_end").Caption 								= mam_GetDictionary("TEXT_END_DATE")
 	Form.Grids("Subscriptions").Properties("id_sub").Caption 		          	= mam_GetDictionary("TEXT_OPTIONS")
  
  If Form.Grids("Subscriptions").Rowset.RecordCount = 0 Then ' Check to see if we have a subscription 
      Form.Grids("Subscriptions").Visible = FALSE      
      Service.Properties("Message") = mam_GetDictionary("TEXT_NO_SUBSCRIPTIONS")
  Else
      Form.Grids("Subscriptions").Visible = TRUE
  End If
  
  'Group Subscriptions
  Set Form.Grids("GroupSubscriptions").Rowset = MTAccountReference.GetGroupSubscriptionsAsRowset
  If IsValidObject(objMTFilter) Then SetForm.Grids("GroupSubscriptions").Rowset.filter = objMTFilter
	
  Form.Grids("GroupSubscriptions").Width      = "100%"	
  Form.Grids("GroupSubscriptions").Properties.ClearSelection
	'Form.Grids("GroupSubscriptions").Properties.SelectAll

	Form.Grids("GroupSubscriptions").Properties("id_acc").Selected							= 1
	Form.Grids("GroupSubscriptions").Properties("id_po").Selected								= 2
	Form.Grids("GroupSubscriptions").Properties("po_nm_display_name").Selected	= 3
  Form.Grids("GroupSubscriptions").Properties("tx_name").Selected 						= 4
  Form.Grids("GroupSubscriptions").Properties("tx_desc").Selected 						= 5
  Form.Grids("GroupSubscriptions").Properties("b_RecurringCharge").Selected   = 6
  Form.Grids("GroupSubscriptions").Properties("b_Discount").Selected          = 7
  Form.Grids("GroupSubscriptions").Properties("b_PersonalRate").Selected      = 8
	Form.Grids("GroupSubscriptions").Properties("dt_start").Selected 		  			= 9
	Form.Grids("GroupSubscriptions").Properties("dt_end").Selected 							= 10
	Form.Grids("GroupSubscriptions").Properties("id_group").Selected 						= 11
	
  Form.Grids("GroupSubscriptions").Properties("id_acc").Caption 							= "&nbsp;"
	Form.Grids("GroupSubscriptions").Properties("id_po").Caption 								= "Status"	
  Form.Grids("GroupSubscriptions").Properties("po_nm_display_name").Caption 	= mam_GetDictionary("TEXT_SUBSCRIPTION")
  Form.Grids("GroupSubscriptions").Properties("b_RecurringCharge").Caption 		= mam_GetDictionary("TEXT_RECURRING_CHARGE")
  Form.Grids("GroupSubscriptions").Properties("b_Discount").Caption 		      = mam_GetDictionary("TEXT_DISCOUNT")
  Form.Grids("GroupSubscriptions").Properties("b_PersonalRate").Caption 	    = mam_GetDictionary("TEXT_GROUPICB_RATE")	
  Form.Grids("GroupSubscriptions").Properties("tx_name").Caption 							= mam_GetDictionary("TEXT_GROUP_SUBSCRIPTIONS_NAME")
	Form.Grids("GroupSubscriptions").Properties("tx_desc").Caption							= mam_GetDictionary("TEXT_DESCRIPTION")
	Form.Grids("GroupSubscriptions").Properties("dt_start").Caption							= mam_GetDictionary("TEXT_START_DATE")
 	Form.Grids("GroupSubscriptions").Properties("dt_end").Caption 							= mam_GetDictionary("TEXT_END_DATE")
  Form.Grids("GroupSubscriptions").Properties("id_group").Caption 						= mam_GetDictionary("TEXT_OPTIONS")

  If Form.Grids("GroupSubscriptions").Rowset.RecordCount = 0 Then ' Check to see if we have a subscription 
      Form.Grids("GroupSubscriptions").Visible = FALSE      
      Service.Properties("GroupMessage") = mam_GetDictionary("TEXT_NO_GROUP_SUBSCRIPTIONS")
  Else
      Form.Grids("GroupSubscriptions").Visible = TRUE
  End If

	' Disable buttons according to capability  
	If Not FrameWork.CheckCoarseCapability("Create subscription") Then
	  mdm_GetDictionary.Add "JOIN_SUB_DISABLED", "disabled"
	  
	  If FrameWork.CheckCoarseCapability("Self Subscribe") Then 'CR14524
		  mdm_GetDictionary.Add "JOIN_SUB_DISABLED", ""
		End If
		  
	Else
		mdm_GetDictionary.Add "JOIN_GROUP_DISABLED", ""
	End If
	
	If Not FrameWork.CheckCoarseCapability("Add to group subscription") Then
		mdm_GetDictionary.Add "JOIN_GROUP_DISABLED", "disabled"
	Else
		mdm_GetDictionary.Add "JOIN_GROUP_DISABLED", ""
	End If
	
	
	
	' Handle the case when we come back from a screen that edits effective dates and the selected new date was overriden by the group subscription
	' or proudct offering effective date
	If Session("DateOverride") Then
		mam_ShowGuide(mam_GetDictionary("ROADMAP-OVERRIDESUBDATE"))
		Session("DateOverride") = false
	Elseif not Form("FilterSet") then ' If there is a date filter, we will want to display the filter information
		response.write "<script language=""JavaScript"">parent.hideGuide();</script>"
	End If	
	
  Form_Initialize = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : GetSubscriptionDateFilter
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return an MTFilter with the proper date interval according to a particular configuration in XML
PRIVATE FUNCTION GetSubscriptionDateFilter()
	dim objMTFilter, var_dayoffset, currentDate, limitDate

	var_dayoffset = mam_GetDictionary("SUBSCRIPTION_FILTERING_INTERVAL")
	currentDate = FrameWork.MetraTimeGMTNow()
	
	Form("FilterSet") = false
	Set objMTFilter = Nothing
	
	If len(trim(var_dayoffset)) > 0 Then
    Set objMTFilter = mdm_CreateObject(MTFilter)
		limitDate = DateAdd("d", -Clng(var_dayoffset), currentDate)
  	objMTFilter.Add "dt_end", OPERATOR_TYPE_GREATER, limitDate
		Form("FilterSet") = true
		mam_ShowGuideNoWarning(mam_GetDictionary("TEXT_SUBSCRIPTION_FILTER_MESSAGE"))
	End If
	
	Set GetSubscriptionDateFilter = objMTFilter
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : OK_Click
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Ok_Click(EventArg) ' As Boolean

   
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : GetPOID
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION GetPOID(nID) ' As Boolean
  Dim objMTProductCatalog
  Dim MTAccountReference
  Dim MTSubscription
  Dim PO
  Dim acctID

  Set objMTProductCatalog = GetProductCatalogObject
  acctID = mam_GetSubscriberAccountID()
 
  ' Get account reference
  Set MTAccountReference = objMTProductCatalog.GetAccount(acctID)

  ' Get Subscription
  Set MTSubscription = MTAccountReference.GetSubscription(CLng(nID))
  
  ' Get PO
  Set PO = MTSubscription.GetProductOffering()
  
  GetPOID = PO.ID
END FUNCTION

' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : GetStatusHTMLString
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return string with proper Status string, formated with proper style
Private Function GetStatusHTMLString(startDate,endDate)
	Dim strStatus, currentTime, strStyle
	currentTime = FrameWork.MetraTimeGMTNow()
	
	If currentTime < startDate Then
		strStatus = mam_GetDictionary("TEXT_FUTURE_SUBSCRIPTION")
		strStyle = "clsLabelFutureSubscription"
	Elseif currentTime > endDate Then
		strStatus = mam_GetDictionary("TEXT_PAST_SUBSCRIPTION")
		strStyle = "clsLabelPastSubscription"
	Else
		strStatus = mam_GetDictionary("TEXT_CURRENT_SUBSCRIPTION")
		strStyle = "clsLabelCurrentSubscription"		
	End If

	GetStatusHTMLString = "<a class='" & strStyle & "'>" & strStatus & "</a>"
End Function


' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : Subscriptions_DisplayCell
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION Subscriptions_DisplayCell(EventArg) ' As Boolean
	Dim url

	'EventArg.Grid.CellClass = GetStatusStyle(EventArg.Grid)
	
  Select Case lcase(EventArg.Grid.SelectedProperty.Name)
  	Case "id_po"
			EventArg.HTMLRendered = "<td name='SubscriptionStatus" & EventArg.Grid.Rowset.Value("id_sub") & "' class=" & EventArg.Grid.CellClass & " width='0'>"
			EventArg.HTMLRendered  = EventArg.HTMLRendered & GetStatusHTMLString(EventArg.Grid.Rowset.Value("dt_start"), EventArg.Grid.Rowset.Value("dt_end"))
			EventArg.HTMLRendered  = EventArg.HTMLRendered & "</td>"
			Subscriptions_DisplayCell = TRUE

  	Case "id_acc"
			EventArg.HTMLRendered = "<td class=" & EventArg.Grid.CellClass & " width='0'>"
			If FrameWork.CheckCoarseCapability("Update subscription") Then
				EventArg.HTMLRendered = EventArg.HTMLRendered  & "<A HRef='" & mam_GetDictionary("GET_SUBSCRIPTION_EFFECTIVE_DATE_DIALOG") & "?EditMode=TRUE&IDS=" & EventArg.Grid.Rowset.Value("id_po") & "&OPTIONALVALUES=" & Server.URLEncode(EventArg.Grid.Rowset.Value("po_nm_display_name")) & "&EditSubID=" & EventArg.Grid.Rowset.Value("id_sub") & "'><img src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>"
			End If
			EventArg.HTMLRendered  = EventArg.HTMLRendered & "</td>"
			Subscriptions_DisplayCell = TRUE
		
		Case "po_nm_display_name" 
    	EventArg.HTMLRendered = "<td class=" & EventArg.Grid.CellClass & ">"
			
      On Error Resume Next
      url = EventArg.Grid.Rowset.Value("t_ep__c_InternalInformationURL")
            
      If Len(Trim(url)) Then
      	EventArg.HTMLRendered  = EventArg.HTMLRendered & "<a href=""JavaScript:Info('" & url & "')""><img border='0' src='" & mam_GetImagesPath() & "/info.gif'></a>&nbsp;" 
      End If
      On Error Goto 0

      EventArg.HTMLRendered  = EventArg.HTMLRendered & EventArg.Grid.SelectedProperty.Value & "</td>"

      Subscriptions_DisplayCell = TRUE

		Case "id_sub"
			Dim strDisabled
			'This capability check will be made later on, on the rateschedule list screen
			'If FrameWork.CheckCoarseCapability("Manage Custom Rates") Then
				strDisabled = ""
			'Else
			'	strDisabled = " disabled "
			'End If
			
			EventArg.HTMLRendered = ""
      'View Rates Button
			EventArg.HTMLRendered = EventArg.HTMLRendered &	"<td align='center' class=" & EventArg.Grid.CellClass & ">"			
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<button class='clsButtonBlueMedium' name='rates' onclick=""document.location.href='" & mam_GetDictionary("RATES_DIALOG") & "?id_sub=" & EventArg.Grid.Rowset.Value("id_sub") & "&LinkColumnMode=TRUE'"" " & strDisabled & ">" & mam_GetDictionary("TEXT_RATES") & "</button>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & "&nbsp;"
      'Unsubscribe Button
      If FrameWork.CheckCoarseCapability("Update subscription") Then
  			EventArg.HTMLRendered = EventArg.HTMLRendered & "<button class='clsButtonBlueMedium' name='UnSubscribe" &  EventArg.Grid.Rowset.Value("id_po") & "' onclick=""document.location.href='" & mam_GetDictionary("GET_SUBSCRIPTION_EFFECTIVE_DATE_DIALOG") & "?unsubscribe=true&EditMode=TRUE&IDS=" & EventArg.Grid.Rowset.Value("id_po") & "&OPTIONALVALUES=" & Server.URLEncode(EventArg.Grid.Rowset.Value("po_nm_display_name")) & "&EditSubID=" & EventArg.Grid.Rowset.Value("id_sub") & "'" & """>" & mam_GetDictionary("TEXT_UNSUBSCRIBE") & "</button>"
      Else
  			EventArg.HTMLRendered = EventArg.HTMLRendered & "<button disabled class='clsButtonBlueMedium' name='UnSubscribe" &  EventArg.Grid.Rowset.Value("id_po") & "' onclick=""document.location.href='" & mam_GetDictionary("GET_SUBSCRIPTION_EFFECTIVE_DATE_DIALOG") & "?unsubscribe=true&EditMode=TRUE&IDS=" & EventArg.Grid.Rowset.Value("id_po") & "&OPTIONALVALUES=" & Server.URLEncode(EventArg.Grid.Rowset.Value("po_nm_display_name")) & "&EditSubID=" & EventArg.Grid.Rowset.Value("id_sub") & "'" & """>" & mam_GetDictionary("TEXT_UNSUBSCRIBE") & "</button>"
      End If
      'Delete Button
      If FrameWork.CheckCoarseCapability("Delete Subscription") Then
  			EventArg.HTMLRendered = EventArg.HTMLRendered & "<button class='clsButtonBlueMedium' name='DeleteSub" &  EventArg.Grid.Rowset.Value("id_po") & "' onclick=""document.location.href='" & mam_GetDictionary("REMOVE_SUBSCRIPTION_DIALOG") & "?id_sub=" & EventArg.Grid.Rowset.Value("id_sub") & "&id_acc=" & EventArg.Grid.Rowset.Value("id_acc") & "'" & """>" & mam_GetDictionary("TEXT_DELETE") & "</button>"
      Else
  			EventArg.HTMLRendered = EventArg.HTMLRendered & "<button disabled class='clsButtonBlueMedium' name='DeleteSub" &  EventArg.Grid.Rowset.Value("id_po") & "' onclick=""document.location.href='" & mam_GetDictionary("REMOVE_SUBSCRIPTION_DIALOG") & "?id_sub=" & EventArg.Grid.Rowset.Value("id_sub") & "&id_acc=" & EventArg.Grid.Rowset.Value("id_acc") & "'" & """>" & mam_GetDictionary("TEXT_DELETE") & "</button>"
      End If  

			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>"     
       
			Subscriptions_DisplayCell = TRUE

		Case "dt_start"
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "' align='left'>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & mam_GetDisplayEndDate(EventArg.Grid.Rowset.Value("dt_start"))
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
			Subscriptions_DisplayCell = TRUE 

		Case "dt_end"        
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "' align='left'>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & mam_GetDisplayEndDate(EventArg.Grid.Rowset.Value("dt_end"))
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
			Subscriptions_DisplayCell = TRUE 
            
		Case "b_personalrate", "b_recurringcharge", "b_discount"
			If UCase(EventArg.Grid.SelectedProperty.value) = "N" then
			  EventArg.HTMLRendered     =  "<td class=" & EventArg.Grid.CellClass & " align='center'>--&nbsp;</td>"
			Else
			  EventArg.HTMLRendered     =  "<td class=" & EventArg.Grid.CellClass & " align='center'><img src='" & mam_GetImagesPath() &  "/check.gif'></td>"
			End If
			Subscriptions_DisplayCell = TRUE

		Case else
			Subscriptions_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
	End Select
	 
END FUNCTION


' ---------------------------------------------------------------------------------------------------------
' FUNCTION 		    : GroupSubscriptions_DisplayCell
' PARAMETERS		  :
' DESCRIPTION 		:
' RETURNS		      : Return TRUE if ok else FALSE
PRIVATE FUNCTION GroupSubscriptions_DisplayCell(EventArg) ' As Boolean
	
	Dim url	

	Select Case lcase(EventArg.Grid.SelectedProperty.Name)
  	Case "id_po"
			EventArg.HTMLRendered = "<td name='GroupSubscriptionStatus" & EventArg.Grid.Rowset.Value("id_sub") & "' class=" & EventArg.Grid.CellClass & " width='0'>"
			EventArg.HTMLRendered  = EventArg.HTMLRendered & GetStatusHTMLString(EventArg.Grid.Rowset.Value("dt_start"), EventArg.Grid.Rowset.Value("dt_end"))
			EventArg.HTMLRendered  = EventArg.HTMLRendered & "</td>"
			GroupSubscriptions_DisplayCell = TRUE
  	Case "id_acc"
			EventArg.HTMLRendered = "<td class=" & EventArg.Grid.CellClass & " width='0'>"
			If FrameWork.CheckCoarseCapability("Modify groupsub membership") Then
				EventArg.HTMLRendered = EventArg.HTMLRendered  & "<A HRef='" & mam_GetDictionary("GROUP_MEMBER_EDIT_DIALOG") & "?Action=EDIT&id_group=" & EventArg.Grid.Rowset.Value("id_group") & "&IsSelfMode=TRUE&IsJoinMode=FALSE&id_acc=" &  mam_GetSubscriberAccountID() & "&start_date=" & EventArg.Grid.Rowset.Value("dt_start") &  "'><img src='" & mam_GetImagesPath() &  "/edit.gif' Border='0'></A>"
			End If
			EventArg.HTMLRendered  = EventArg.HTMLRendered & "</td>"
			GroupSubscriptions_DisplayCell = TRUE
	
  	Case "po_nm_display_name"
    	EventArg.HTMLRendered = "<td class=" & EventArg.Grid.CellClass & ">"

      On Error Resume Next
      url = EventArg.Grid.Rowset.Value("t_ep__c_InternalInformationURL")            
      If Len(Trim(url)) Then
      	EventArg.HTMLRendered  = EventArg.HTMLRendered & "<a href=""JavaScript:Info('" & url & "')""><img src='" & mam_GetImagesPath() &  "/info.gif'></a>&nbsp;"
      End If
      On Error Goto 0
      EventArg.HTMLRendered  = EventArg.HTMLRendered & EventArg.Grid.SelectedProperty.Value & "</td>"
      GroupSubscriptions_DisplayCell = TRUE	
  
		Case "dt_start"
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "' align='left' nowrap>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & Service.Tools.ConvertFromGMT(EventArg.Grid.Rowset.Value("dt_start"), MAM().CSR("TimeZoneId")) 
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>"
			GroupSubscriptions_DisplayCell = TRUE 

		Case "dt_end"
			EventArg.HTMLRendered = EventArg.HTMLRendered & "<td class='" & EventArg.Grid.CellClass & "' align='left' nowrap>"
			EventArg.HTMLRendered = EventArg.HTMLRendered & mam_GetDisplayEndDate(EventArg.Grid.Rowset.Value("dt_end"))
			EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" 
			GroupSubscriptions_DisplayCell = TRUE

		Case "id_group"
			Dim strDisabled
			'This capability check will be made later on, on the rateschedule list screen
			'If FrameWork.CheckCoarseCapability("Manage Group Custom Rates") Then
				strDisabled = ""
			'Else
			'	strDisabled = " disabled "
			'End If
			
			EventArg.HTMLRendered = EventArg.HTMLRendered  & "<td class=""" & EventArg.Grid.CellClass & """ align='center' nowrap>"
			EventArg.HTMLRendered = EventArg.HTMLRendered  & "<button class=""clsButtonBlueMedium"" name=""GroupRates"" onclick=""document.location.href='" & mam_GetDictionary("RATES_DIALOG") & "?BackToAccountSubs=TRUE&LinkColumnMode=TRUE&id_sub=" & EventArg.Grid.Rowset.Value("id_sub") & "&id_group=" &  EventArg.Grid.Rowset.Value("id_group") & "'"" " & strDisabled & ">" & mam_GetDictionary("TEXT_RATES") & "</button>"
			EventArg.HTMLRendered = EventArg.HTMLRendered  & "&nbsp;"
      If FrameWork.CheckCoarseCapability("Update group subscriptions") Then
   			EventArg.HTMLRendered = EventArg.HTMLRendered  & "<button class=""clsButtonBlueMedium"" name=""GroupUnsubscribe"" onclick=""document.location.href='" & mam_GetDictionary("GROUP_MEMBER_EDIT_DIALOG") & "?Action=EDIT&id_group=" & EventArg.Grid.Rowset.Value("id_group") & "&IsSelfMode=TRUE&IsJoinMode=FALSE&id_acc=" &  mam_GetSubscriberAccountID() & "&start_date=" & EventArg.Grid.Rowset.Value("dt_start") & "&unsubscribe=TRUE" & "'" & """>" & mam_GetDictionary("TEXT_UNSUBSCRIBE") & "</button>"			
      Else
   			EventArg.HTMLRendered = EventArg.HTMLRendered  & "<button disabled class=""clsButtonBlueMedium"" name=""GroupUnsubscribe"" onclick=""document.location.href='" & mam_GetDictionary("GROUP_MEMBER_EDIT_DIALOG") & "?Action=EDIT&id_group=" & EventArg.Grid.Rowset.Value("id_group") & "&IsSelfMode=TRUE&IsJoinMode=FALSE&id_acc=" &  mam_GetSubscriberAccountID() & "&start_date=" & EventArg.Grid.Rowset.Value("dt_start") & "&unsubscribe=TRUE" & "'" & """>" & mam_GetDictionary("TEXT_UNSUBSCRIBE") & "</button>"			      
      End If
			EventArg.HTMLRendered = EventArg.HTMLRendered  & "</td>"
			
			GroupSubscriptions_DisplayCell = TRUE
			
    Case "b_personalrate", "b_recurringcharge", "b_discount"
      If UCase(EventArg.Grid.SelectedProperty.value) = "N" then
	      EventArg.HTMLRendered     =  "<td class=" & EventArg.Grid.CellClass & " align='center'>--&nbsp;</td>"
			Else
        EventArg.HTMLRendered     =  "<td class=" & EventArg.Grid.CellClass & " align='center'><img src='" & mam_GetImagesPath() &  "/check.gif'></td>"
      End If      
    	GroupSubscriptions_DisplayCell = TRUE			
		Case else
			GroupSubscriptions_DisplayCell = Inherited("Grid_DisplayCell(EventArg)")
	End Select
	
END FUNCTION


%>


