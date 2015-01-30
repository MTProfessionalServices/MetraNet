<!-- #INCLUDE VIRTUAL = "/mpte/auth.asp" -->
<!-- #INCLUDE VIRTUAL = "/mpte/us/Calendar/CalendarGrid.asp" -->
<%
' //==========================================================================
' // @doc $Workfile$
' //
' // Copyright 1998 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //
' // Created by: Noah W. Cushing
' //
' // $Date: 05/18/01
' // $Author: Fabricio Pettena
' // $Revision$
' //==========================================================================

'Option Explicit

On Error Resume Next

'Buffer the response for printing error messages
response.buffer = true

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Global Variables                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Dim mbolIsConfigured	  'TRUE if ratechedule has calendar assigned to it
Dim strTMP

'Product Catalog Variables
dim objMTRateSched ' As MTRateSchedule
dim objMTParamTableDef ' As MTParamTableDef
dim objMTProductCatalog   ' as MTProductCatalog
dim objMTRule
dim objMTCalendar    ' As MTCalendar
dim dayID
dim intCalID

Const g_str_OPEN_TABLE_TAG_PARAMS =  "border=""0"" cellspacing=""1"" cellpadding=""1"" bgcolor=""#999999"""

'----------------------------------------------------------------------------
' METHODS
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
'   Name: GetPeriodlegend
'   Description:  
'   Parameters: none
'   Return Value: HTML with legend table
'-----------------------------------------------------------------------------
Function GetPeriodlegend
	dim strHTML, objEnumCfg, objEnumColl, varEnum, varEnumValue
	
	Set objEnumCfg = CreateObject("Metratech.MTEnumConfig")
	Set objEnumColl = objEnumCfg.GetEnumerators("metratech.com/calendar", "CalendarCode")
  Dim lang
  lang = session.Contents("FRAMEWORK_APP_LANGUAGE_SHORT")
  Set lc = Server.CreateObject("Metratech.LocaleConfig")
  lc.Initialize("Core")
  lc.LoadLanguage(lang)

	strHTML = ""
	strHTML = strHTML & "<table width='0'><tr>"	
	For Each varEnum in objEnumColl
		varEnumValue = objEnumCfg.GetEnumeratorValueByID(objEnumCfg.GetID("metratech.com/calendar", "CalendarCode", varEnum.Name))
		strHTML = strHTML & "<td width='" & Clng(100/objEnumColl.Count) & "%' class='clsCalendarGraph" & varEnumValue & "'>"  & lc.GetLocalizedString("metratech.com/calendar/CalendarCode/" & varEnum.Name, lang) & "</td>"
	Next
	strHTML = strHTML & "</tr></table>"

	GetPeriodlegend = strHTML
End Function

'----------------------------------------------------------------------------
'   Name: Draw_DayType_Menu
'   Description:  Draws the top choice between Weekdays & Weekends and Holidays
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
FUNCTION Draw_DayType_Menu()
	
	if false then 
	Dim strMenu
	Dim intSelected, tmpTab1, tmpTab2, tmpTab3
	strMenu = ""
	intSelected = CLng(session("CurrentCalendarTab"))

	tmpTab1 = ""
	tmpTab2 = ""
	tmpTab3 = ""

	if (intSelected = 0) then
		tmpTab1 = "checked"
	elseif (intSelected = 1) then
		tmpTab2 = "checked"
	else
		tmpTab3 = "checked"
	end if
		
	strMenu = strMenu & "<table align=""center""><tr nowrap><td class=""sectionCaptionBar"">"
	strMenu = strMenu & "<input type=""radio"" name=""DayType"" value=""0"" onClick=""javascript:reloadCalendar(0)"" " & tmpTab1 & ">" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_WEEKDAYS_CHOICE")
	strMenu = strMenu & "</td><td>&nbsp;&nbsp;&nbsp;</td><td class=""sectionCaptionBar"">"
	strMenu = strMenu & "<input type=""radio"" name=""DayType"" value=""2"" onClick=""javascript:reloadCalendar(1)"" " & tmpTab3 & ">"& FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_WEEKENDS_CHOICE")
	strMenu = strMenu & "</td><td>&nbsp;&nbsp;&nbsp;</td><td class=""sectionCaptionBar"">"
	strMenu = strMenu & "<input type=""radio"" name=""DayType"" value=""1"" onClick=""javascript:reloadCalendar(2)"" " & tmpTab2 & ">"& FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_HOLIDAYS_CHOICE")
	strMenu = strMenu & "</td></tr></table>"
	Response.Write(strMenu)
	end if
	
  DrawTabs
  

	Draw_DayType_Menu = TRUE
	
END FUNCTION

FUNCTION DrawTabs()
	' Dynamically Add Tabs to template
	Dim strTabs, gobjMTTabs
  Set objMTTabs = new CMTTabs
	objMTTabs.AddTab FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_WEEKDAYS_CHOICE"), "javascript:reloadCalendar(0);"
	objMTTabs.AddTab FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_WEEKENDS_CHOICE"), "javascript:reloadCalendar(1);"
	objMTTabs.AddTab FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_HOLIDAYS_CHOICE"), "javascript:reloadCalendar(2);"
	
	objMTTabs.Tab = CLng(session("CurrentCalendarTab"))
	
	strTabs = objMTTabs.DrawTabMenu(g_int_TAB_TOP)    
	strTabs = strTabs & "<table class=""clsTabAngleTopSelected"" cellspacing=""0"" cellpadding=""5"" width=""100%"" height=""90%""><tr valign=""top""><td>"
	strTabs = "<BR>" & strTabs
	Response.Write(strTabs)
	' Note that the table close is the last thing that happens in this page.
	DrawTabs = TRUE
END FUNCTION


'----------------------------------------------------------------------------
'   Name: DrawTitle
'   Description:  Draws the title string of the RateSchedule
'               
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
sub Draw_Title(Caption, Desc, EffDate)
	
	Dim strTitle
	
	'Write top part
	if not mbolIsConfigured then	  
		Dim sugestionMsg
		if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" then
			suggestionMsg = FrameWork.GetDictionary("TEXT_MPTE_NO_CALENDAR_CONFIGURED_SUGESTION_MSG")
		else
			suggestionMsg = FrameWork.GetDictionary("TEXT_MPTE_NO_CALENDAR_CONFIGURED_MAM_SUGESTION_MSG")
		end if
			
		strTitle = 			  FrameWork.GetDictionary("TEXT_MPTE_NO_CALENDAR_CONFIGURED") & "<BR>"
		strTitle = strTitle & suggestionMsg & "<br>"
	else
	    if not session("manageCalendars") = true  then
    		  'SECENG: Fixing problems with output encoding
    		  strTitle = 			  "This rate schedule is configured to use the calendar <b>" & SafeForHtml(Caption) & "</b> that is displayed below. You may also select to use a different existing calendar or to create a new calendar to use." 'FrameWork.GetDictionary("TEXT_MPTE_NO_CALENDAR_CONFIGURED") & "<BR>"
		  strTitle = strTitle & "<br>"
		else
		  strTitle = ""
		end if
	end if
	
	if UCase(session("RATES_EDITMODE")) = "TRUE" then
		strTitle = strTitle & "<br>"
		if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" and not session("manageCalendars") = true then
			strTitle = strTitle &			"<input type=""button"" class=""clsButtonLarge"" name=""butImport"" value=""" & FrameWork.GetDictionary("TEXT_MPTE_SELECTCALENDAR") & """ onClick=""javascript:OpenDialogWindow('Calendar.Picker.asp?Monoselect=TRUE','height=600, width=800');"">&nbsp;"
		end if
		
		'if not session("manageCalendars") = true then
		strTitle = strTitle &			"<input type=""button"" class=""clsButton"" name=""butNewCalendar""   value=""" & FrameWork.GetDictionary("TEXT_MPTE_NEWCALENDAR") & """ onClick=""javascript:OpenDialogWindow('gotoCalendarNewEdit.asp','');"">&nbsp;"
		'end if
		'if mbolIsConfigured then
		'	strTitle = strTitle &			"<input type=""button"" class=""clsButtonBlueLarge"" name=""Edit""   value=""" & FrameWork.GetDictionary("TEXT_MPTE_EDITCALENDAR") & """ onClick=""javascript:OpenDialogWindow('gotoCalendarNewEdit.asp?cal_id=" & intCalID & "','');"">&nbsp;"
		'end if
	end if 
	
	if len(strTitle)>0 then
		strTitle = strTitle & "<br><br>"
	end if
	
	'Write calendar title if we have one
	if mbolIsConfigured then
	Dim editcall
	strTitle = strTitle &  "<table border=""0"" cellpadding=""1"" cellspacing=""0"" width=""100%"">"
	strTitle = strTitle & 	"<tr>"
    strTitle = strTitle & 		"<td Class='CaptionBar' nowrap>"
    'SECENG: Fixing problems with output encoding
    strTitle = strTitle & 			SafeForHtml(Caption) & " - " & SafeForHtml(Desc) & "&nbsp;&nbsp;&nbsp;"
    
    if UCase(session("RATES_EDITMODE")) = "TRUE" AND mbolIsConfigured then
			strTitle = strTitle &			"<input type=""button"" class=""clsButtonBlueLarge"" name=""Edit""   value=""" & FrameWork.GetDictionary("TEXT_MPTE_EDITCALENDAR") & """ onClick=""javascript:OpenDialogWindow('gotoCalendarNewEdit.asp?cal_id=" & intCalID & "','');"">"
	end if

    strTitle = strTitle & "</td><tr><td>"
	'if UCase(session("RATES_EDITMODE")) = "TRUE" then
	'	if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" and not session("manageCalendars") = true then
	'		strTitle = strTitle &			"<input type=""button"" class=""clsButtonLarge"" name=""butImport"" value=""" & FrameWork.GetDictionary("TEXT_MPTE_SELECTCALENDAR") & """ onClick=""javascript:OpenDialogWindow('Calendar.Picker.asp?Monoselect=TRUE','height=600, width=800');"">&nbsp;"
		'end if
	'	strTitle = strTitle &			"<input type=""button"" class=""clsButtonLarge"" name=""butNewCalendar""   value=""" & FrameWork.GetDictionary("TEXT_MPTE_NEWCALENDAR") & """ onClick=""javascript:OpenDialogWindow('gotoCalendarNewEdit.asp','');"">&nbsp;"
		'if mbolIsConfigured then
		'	strTitle = strTitle &			"<input type=""button"" class=""clsButtonBlueLarge"" name=""Edit""   value=""" & FrameWork.GetDictionary("TEXT_MPTE_EDITCALENDAR") & """ onClick=""javascript:OpenDialogWindow('gotoCalendarNewEdit.asp?cal_id=" & intCalID & "','');"">&nbsp;"
		'end if
	'end if
	strTitle = strTitle & 		"</td>"
	strTitle = strTitle & 	"</tr>"
	strTitle = strTitle & "</table>"
	
	end if
	Response.Write (strTitle)					
end sub

'----------------------------------------------------------------------------
'   Name: DrawTitle
'   Description:  Draws the title string of the RateSchedule
'               
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
sub Draw_Title_Original(Caption, Desc, EffDate)
	
	Dim strTitle
	Dim editcall
	strTitle = 			  "<table border=""0"" cellpadding=""1"" cellspacing=""0"" width=""100%"">"
	strTitle = strTitle & 	"<tr>"
    strTitle = strTitle & 		"<td Class='sectionCaptionBar' nowrap>"
    strTitle = strTitle & 			Caption & " - " & Desc & "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
	if UCase(session("RATES_EDITMODE")) = "TRUE" then
		if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" and not session("manageCalendars") = true then
			strTitle = strTitle &			"<input type=""button"" class=""clsButtonLarge"" name=""butImport"" value=""" & FrameWork.GetDictionary("TEXT_MPTE_SELECTCALENDAR") & """ onClick=""javascript:OpenDialogWindow('Calendar.Picker.asp?Monoselect=TRUE','height=600, width=800');"">&nbsp;"
		end if
		strTitle = strTitle &			"<input type=""button"" class=""clsButton"" name=""butNewCalendar""   value=""" & FrameWork.GetDictionary("TEXT_MPTE_NEWCALENDAR") & """ onClick=""javascript:OpenDialogWindow('gotoCalendarNewEdit.asp','');"">&nbsp;"
		if mbolIsConfigured then
			strTitle = strTitle &			"<input type=""button"" class=""clsButtonBlueSmall"" name=""Edit""   value=""" & FrameWork.GetDictionary("TEXT_MPTE_EDITCALENDAR") & """ onClick=""javascript:OpenDialogWindow('gotoCalendarNewEdit.asp?cal_id=" & intCalID & "','');"">&nbsp;"
		end if
	end if
	strTitle = strTitle & 		"</td>"
	strTitle = strTitle & 	"</tr>"
	strTitle = strTitle & "</table>"
	Response.Write (strTitle)					
end sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Methods                                                                   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub         : WriteCalendarEdit()                                         '
' Description : Write the calendar editing screen.                          '
' Inputs      : none.                                                       '
' Outputs     : none.                                                       '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


Sub WriteCalendarEdit(objCalendar)

  Dim strHTML     'HTML string to write
	strHTML = GetCalendarGrid(objCalendar, CLng(session("CurrentCalendarTab")))
  
  'write the data
  call response.write(strHTML)
  
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Sub         : WriteMenu()                                                 '
' Description : Write the tab menu.                                         '
' Inputs      : none                                                        '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub WriteMenu()
  Dim arrLinks      'Array of links
  Dim arrNames      'Array of names
  Dim strLinkBase   'Link base
  
  strLinkBase = "gotoCalendar.asp?"
  arrLinks = Array(strLinkBase & "Tab=0", strLinkBase & "Tab=2", strLinkBase & "Tab=1")
  arrNames = Array(FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_WEEKDAYS"), FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_WEEKENDS"), FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_HOLYDAYS")) 	
  call WriteTabMenu(arrLinks, arrNames, clng(session("CurrentCalendarTab")))
End Sub

''''''''''''''''''' PAGE PROCESSING STARTS '''''''''''''''''''''''''''''''''''

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' The Tab parameter determines if we are editing holidays, weekdays or weekends
' If the session is empty, use the default of "0"
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

if len(request.QueryString("Tab")) > 0 then
	session("CurrentCalendarTab") = request.QueryString("Tab")
elseif session("CurrentCalendarTab") = "" then
	session("CurrentCalendarTab") = "0"
end if

'---------------------------------------------------------------------
' Now we will check for the existence of some entries on the querystring
' and if they exist, it means we should overwrite the session variable
' that holds that value. Otherwise, we simply use the stored value,
' meaning that the page has been reloaded but we should use the
' same objects as before
'---------------------------------------------------------------------  

'// This function call will make sure that if an argument has a new value in the querystring,
'// we will save it in the session and use that updated value when we load the product catalog
call LoadQueryString()
'// Now we are reloading objects.
'// Set objMTProductCatalog = Server.CreateObject("MetraTech.MTProductCatalog")
Set objMTProductCatalog = GetProductCatalogObject

'// We will load the parameter table object, unless we are coming from the edit calendars screen
if not session("manageCalendars") = true then
	set objMTParamTableDef = objMTProductCatalog.GetParamTableDefinition(Clng(session("RATES_PARAMTABLE_ID")))
	set session("CalendarParameterTable") = objMTParamTableDef
end if

'----------------------------------------------------------------------------------
' RELOAD
'----------------------------------------------------------------------------------
if Ucase(Request.QueryString("Reload")) = "TRUE" then
	if not session("manageCalendars") = true then
		set objMTRateSched = objMTParamTableDef.GetRateSchedule(Clng(session("RATES_RATESCHEDULE_ID")))
		set session("CalendarRateSchedule") = objMTRateSched
	end if
	session("UnsavedChanges") = false
else
	if not session("manageCalendars") = true then
		set objMTRateSched = session("CalendarRateSchedule")
	end if
end if

'----------------------------------------------------------
' FORM OK:SAVE THE CALENDAR - USER PRESSED SAVE
'----------------------------------------------------------

if UCase(request.Form("FormAction")) = "OK" then
	set objMTCalendar = session("objMTCalendar")
	
	'// We will only do this part if we are not comming from the manage calendars screen, 
	'// because if we are, then there is no rateschedule attached to it
	if not session("manageCalendars") = true then
		set objMTRateSched = session("CalendarRateSchedule")	
		' Create an action set, if it is not present	
		if objMTRateSched.Ruleset.DefaultActions Is Nothing then
			objMTRateSched.Ruleset.DefaultActions = CreateActionSet(objMTParamTableDef)		
		end if
	end if

	On Error resume next
	'Save the calendar configuration
	objMTCalendar.Save
	call WriteRunTimeError(FrameWork.GetDictionary("TEXT_MPTE_CANNOT_SAVE_CALENDAR"), true)
	
	' Now save the rateschedule 
	if Err.Number = 0 and not session("manageCalendars") = true then
		'Saves the current calendar mapping, whatever it is
		call SetRSActionValue(objMTRateSched.Ruleset.DefaultActions(1), objMTCalendar.ID)
		objMTRateSched.SaveWithRules
		call WriteRunTimeError(FrameWork.GetDictionary("TEXT_MPTE_CANNOT_LINK_TO_CALENDAR"), true)
	end if
			
	On Error goto 0
	if not err then
		session("UnsavedChanges") = false
		session("CalendarSaved") = true
	end if
	
	set session("objMTCalendar") = objMTCalendar
	
	if not session("manageCalendars") = true then
		set session("CalendarRateSchedule") = objMTRateSched
	end if
	
'----------------------------------------------------------
' QUERYSTRING:REMOVE DAY
'----------------------------------------------------------
elseif UCase(request.Form("FormAction")) = "REMOVEHOLIDAY" then
	dayID = request.Form("DayID")
	Set objMTCalendar = session("objMTCalendar")
	On Error Resume Next
	objMTCalendar.RemoveHoliday(dayID)
	call WriteRunTimeError(FrameWork.GetDictionary("TEXT_MPTE_CANNOT_REMOVE_HOLIDAY"), true)
	On Error Goto 0
	Set session("objMTCalendar") = objMTCalendar
	if not err then
		session("UnsavedChanges") = true
	end if

elseif UCase(request.Form("FormAction")) = "REMOVEWEEKDAY" then
	dayID = Clng(request.Form("DayID"))
	Set objMTCalendar = session("objMTCalendar")
	On Error Resume Next
	objMTCalendar.RemoveWeekday(dayID)
	call WriteRunTimeError(FrameWork.GetDictionary("TEXT_MTPE_CANNOT_SET_WEEKDAY_TO_DEFAULT"), true)
	On Error Goto 0	
	Set session("objMTCalendar") = objMTCalendar
	if not err then
		session("UnsavedChanges") = true
	end if
	
end if

'----------------------------------------------------------
' WE JUST CAME BACK FROM THE IMPORT CALENDAR DIALOG.
'----------------------------------------------------------
if len(request.queryString("PickerIDs")) then
	
	if not session("manageCalendars") = true then
		set objMTRateSched = session("CalendarRateSchedule")
	end if
	set objMTCalendar = session("objMTCalendar")
	
  intCalID = clng(request.queryString("PickerIDs"))
	
	if not session("manageCalendars") = true then
		' This takes care of creating a new rule to hold the calendar ID of the newly selected calendar
  	if objMTRateSched.Ruleset.DefaultActions Is Nothing then
			objMTRateSched.Ruleset.DefaultActions = CreateActionSet(objMTParamTableDef)
  	end if
 		objMTRateSched.Ruleset.DefaultActions(1).PropertyValue = intCalID
	end if
	
	On Error Resume Next
	set objMTCalendar = objMTProductCatalog.GetCalendar(intCalID)
	call WriteRunTimeError(FrameWork.GetDictionary("TEXT_MPTE_CANNOT_LOAD_CALENDAR"), false)
	On Error Goto 0
	
	if not err then
		session("UnsavedChanges") = true
	end if
	
	if not session("manageCalendars") = true then
		set session("CalendarRateSchedule") = objMTRateSched
	end if
	
	set session("objMTCalendar") = objMTCalendar
	
end if


'---------------------------------------------------------------------
' There are 2 ways to load up the calendar: from an id that is in the
' rateschedule, and from an id that comes with the link.
'---------------------------------------------------------------------

' Loading calendar from the rateschedule
if not session("manageCalendars") = true then
	'---------------------------------------------------------------------
	' If there is no default rule, we will simply display the template file
	'---------------------------------------------------------------------
	if objMTRateSched.Ruleset.DefaultActions is Nothing then
		intCalID = -1
		' Let's flag it so the page knows there are no calendars configured. Only the proper buttons will be displayed,
		' and we will know to create a new rule in the Rateschedule's ruleset when the user saves this calendar
		mbolIsConfigured = FALSE	
	
	'--------------------------------------------------------------------------------------------------------------	
	' Or we simply get the default actions and grab it's value (there should be only one there). We should be all set now.
	'--------------------------------------------------------------------------------------------------------------
	else
		set objMTRateSched = session("CalendarRateSchedule") 									
		On Error resume next
		intCalID = CLng(objMTRateSched.Ruleset.DefaultActions(1).PropertyValue)
		
		' Test if we should operate on a calendar in the session or just reload the old one
		if Ucase(Request.QueryString("Reload")) = "TRUE" then
			Set objMTCalendar = objMTProductCatalog.GetCalendar(intCalID)
			call WriteRunTimeError(FrameWork.GetDictionary("TEXT_MPTE_CANNOT_LOAD_CALENDAR") & " ID= " & intCalID, false)
			session("CurrentCalendarTab") = "0"
	
			if not err and len(request.queryString("PickerIDs")) = 0 then
				session("UnsavedChanges") = false
			end if
			' Just use the one in the session
		else
			Set objMTCalendar = session("objMTCalendar")
		end if		
	
		Set session("objMTCalendar") = objMTCalendar 'Save this guy in the session, since we might need it after a reload
		mbolIsConfigured = TRUE
		on error goto 0
	end if
else
' Loading calendar from the id (MEANS WE ARE UNDER "MANAGE CALENDARS")
	if Ucase(Request.QueryString("Reload")) = "TRUE" then
		intCalID = CLng(Request.QueryString("CALENDAR_ID"))
		Set objMTCalendar = objMTProductCatalog.GetCalendar(intCalID)
		call WriteRunTimeError(FrameWork.GetDictionary("TEXT_MPTE_CANNOT_LOAD_CALENDAR") & " ID= " & intCalID, false)
		if err.Number = 0 then
			Set session("objMTCalendar") = objMTCalendar
		end if
		session("CurrentCalendarTab") = "0"
	else
		Set objMTCalendar = session("objMTCalendar")
	end if
	mbolIsConfigured = TRUE
end if

' Override help file for this calendar
session("HelpContext")  = "gotoCalendar.hlp.htm"

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Function Main ' We will put the HTML writing in a function so we can catch unknown errors

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
  <head>
    <title><%=FrameWork.GetDictionary("TEXT_CALENDAR_CONFIGURATION")%></title>
		<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET1")%>">
  	<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET2")%>">
  	<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET3")%>">
	
    <script language="JavaScript" src="/mpte/shared/browsercheck.js">
    </script>
    
    <!-- Include for popup windows -->
    <script language="JavaScript" src="/mpte/shared/PopupEdit.js">
    </script>
    
    <!-- Include for loading divs -->
    <script language="JavaScript" src="/mpte/shared/Loading.js">
    </script>
	
	<script LANGUAGE="JavaScript1.2">
	function reloadCalendar(itab)
	{
		document.location.href = "gotoCalendar.asp?Tab=" + itab;
	}
		    
	function returnToCallerApp()
	{       
	 	var strMsg = <% Response.Write("'" & FrameWork.GetDictionary("TEXT_MPTE_UNSAVED_CHANGES") & "';")%>
	  <%
	 	Dim strURL
		strURL = "'" & session("ownerapp_return_page") & "';"                                    
		%>
		<%
		if session("UnsavedChanges") then
			Response.Write("if(confirm(strMsg))")
		  Response.Write("document.location.href =" & strURL)
		else
		  Response.Write("document.location.href =" & strURL)
		end if
		%>
	}
	
  function SubmitForm(istrAction, intDayID)
	{
  	document.main.FormAction.value = istrAction;
		document.main.DayID.value = intDayID;
    document.main.submit();
  }

	</script>
	

  </head>
  <body <% if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" and not session("manageCalendars") = true then response.write("class=""clsTabBody""") end if%> onUnload="CleanUp();" onFocus="GotFocus();" onBlur="LostFocus();">
  <FORM ACTION="gotoCalendar.asp" METHOD="POST" NAME="main" onFocus="javascript:InAForm(main);" onBlur="javascript:OutOfForm();">
	<INPUT TYPE="Hidden" NAME="FormAction" VALUE="">
	<INPUT TYPE="Hidden" NAME="DayID" VALUE="">

  <% 
  	' If the owner is MCM, we will draw the POBased or PLBased tabs. Then we will close the table at the end of this page
 	if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" and not session("manageCalendars") = true then 
		'call Tab_Initialize()
	end if
  %>
    
<%
	if mbolIsConfigured then	  
		call Draw_Title(objMTCalendar.Name, objMTCalendar.Description, "")
	else
		Dim sugestionMsg
		if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" then
			suggestionMsg = FrameWork.GetDictionary("TEXT_MPTE_NO_CALENDAR_CONFIGURED_SUGESTION_MSG")
		else
			suggestionMsg = FrameWork.GetDictionary("TEXT_MPTE_NO_CALENDAR_CONFIGURED_MAM_SUGESTION_MSG")
		end if
			
		call Draw_Title(FrameWork.GetDictionary("TEXT_MPTE_NO_CALENDAR_CONFIGURED"), suggestionMsg, "")
	end if 

  if session("CalendarSaved") then
    dim strSavedMessage
    ' if CalendarID in session is 0, we just saved a brand new calendar
    if session("CalendarID") = 0 then
      strSavedMessage = FrameWork.GetDictionary("TEXT_MPTE_NEW_CALENDAR_SAVED")
    else
      strSavedMessage = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_SAVED")
    end if
%>
    <br>
    <center>
    <div class="clsInfoBox"><%=strSavedMessage%></div>
    </center>
    <br>
<%
    session("CalendarSaved") = false
  end if

  if mbolIsConfigured then    
    session("CalendarID") = objMTCalendar.Id
  else
    session("CalendarID") = 0
  end if

	if not session("manageCalendars") = true then
		if len(objMTParamTableDef.HelpURL) > 0 then
			response.write "<DIV class=""clsInfoURL""><IMG SRC=""/mpte/us/images/info.gif""><A HREF=""javascript:OpenDialogWindow('" & objMTParamTableDef.HelpURL & "','height=600, width=800, resizable=yes,scrollbars=yes');"">" & FrameWork.GetDictionary("TEXT_MPTE_MOREINFO") & "</A></DIV>"
		end if
	end if
  
 	if mbolIsConfigured then
		Call Draw_DayType_Menu()
	end if
				
%>
      <br><br>
			<table align='CENTER' width='90%'>
<%

			if mbolIsConfigured then
				Call WriteCalendarEdit(objMTCalendar)
			end if  
%>
			</table>
			<br><br>
			<table align='CENTER' width='90%'>
				<tr><td align="right"><% if mbolIsConfigured then response.Write(GetPeriodlegend) end if%></td></tr>
        <tr><td align="right">
					<% 
						if session("CurrentCalendarTab") = "2" and mbolIsConfigured and UCase(session("RATES_EDITMODE")) = "TRUE" then
							response.write "<input type='button' class='clsButtonMedium' name='AddHoliday' value='" & FrameWork.GetDictionary("TEXT_MPTE_ADDHOLIDAY_BTN") & "' onClick=""javascript:OpenDialogWindow('gotoCalendarDayEdit.asp?daytype=HOLIDAY&newDay=TRUE&day_id=" & intCalID & "','');"">"
					  end if
					%>
        </td></tr>
      </table>
	  
	  	<table width="100%">
				<tr><td>&nbsp;</td></tr>
	  		<tr>
					<td align="center">
					<% if mbolIsConfigured and UCase(session("RATES_EDITMODE")) = "TRUE" then %> 
					
					  <% if session("UnsavedChanges") then %>
	  				  <input type="button" class="clsButtonSmall" name="Save" value="<%=FrameWork.GetDictionary("TEXT_MPTE_SAVE_BTN")%>" onClick="javascript:SubmitForm('OK','');">
	  				<% else %>
	  				  <input disabled="true" type="button" class="clsButtonSmall" name="Save" value="<%=FrameWork.GetDictionary("TEXT_MPTE_SAVE_BTN")%>" onClick="javascript:SubmitForm('OK','');">
	  				<% end if %>  
					<% end if %>
	  				<input type="button" class="clsButtonSmall" name="Cancel" value="<%=FrameWork.GetDictionary("TEXT_MPTE_CLOSE_BTN")%>" onClick="javascript:returnToCallerApp();">
	 				</td>
				</tr>
				<tr><td>&nbsp;</td></tr>
				<tr>
					<td align='center'>
					<%
          if mbolIsConfigured then    
					 	'Add warning message here
	  				if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" and UCase(session("RATES_EDITMODE")) = "TRUE" and objMTCalendar.Id <> 0 then
	  					response.write "<span class='ErrorMessageCaption'><img src=/mpte/us/images/warningSmall.gif>&nbsp;&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_WARNING_WHEN_EDITING") & "</span>"
	  				end if
          end if
					%>
					</td>
				</tr>
	  	</table>
  <% if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" and not session("manageCalendars") = true then  'We check what application called the MPTE - if it was MCM, we will close the tabs table %>
	</tr>
	</table>
  <%end if%>
  </body>
</html>

		<% 
		
		
END FUNCTION ' End Of Function Main

		On Error Resume next
		'// We are calling the function that processes the page.

		Main
			
		if err then 
		  call response.clear()
		  call WriteUnknownError("")
	    call response.end()
		else
		  call response.flush()
		  call response.end()
		end if
					
		On Error Goto 0	
%> 
    
