<%
' //==========================================================================
' // @doc $Workfile: CalendarNewEdit.asp
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
' // Created by: Fabricio Pettena
' //
' // $Date: Thursday, May 17 2001
' // $Author: Fabricio Pettena$
' // $Revision: 1$
' //==========================================================================


'----------------------------------------------------------------------------
'
'DESCRIPTION:   This files collects the information to create a new calendar
'
'ASSUMPTIONS: 
'
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
' CONSTANTS
'----------------------------------------------------------------------------
const CALENDARPERIODPRECISION			= 96 ' Determines the increment in the calendar period select
const CALENDARPERIODMINUTEPRECISION = 4

'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
dim objMTRateSched 			' As MTRateSchedule
dim objMTRuleset				' As MTRuleset
dim objMTParamTable			' As MTParamTableDefintion
dim objMTCalendar 	    ' As MTCalendar
dim objDay							' As MTCalendarDay
dim objPeriod						' As MTCalendarPeriod
dim objMTProductCatalog ' As MTProductCatalog
dim objMTRule 					' As MTRule
dim intCalID  					' As Calendar ID
dim tabNumber
dim mstrErrors

Function GetTitle(Caption)
	Dim strTitle
	strTitle = 			  "<table border=""0"" cellpadding=""1"" cellspacing=""0"" width=""100%"">"
	strTitle = strTitle & 	"<tr>"
    strTitle = strTitle & 		"<td Class='CaptionBar' nowrap>"
    strTitle = strTitle & 			Caption
	strTitle = strTitle & 		"</td>"
	strTitle = strTitle & 	"</tr>"
	strTitle = strTitle & "</table>"	
	GetTitle = strTitle
End Function

Function AddZeroIfNecessary(intVal)
	if intVal < 10 then
		AddZeroIfNecessary = "0" & Cstr(intVal)
	else
		AddZeroIfNecessary = Cstr(intVal)
	end if
End Function

Function GetNumberOfSecondsFromSelects(strType)
	Dim intHourVal, intMinuteVal, intAMorPM, totalSeconds
	
	intHourVal = Clng(Request.Form("selectCalPeriodHour" & strType))
	intMinuteVal = Clng(Request.Form("selectCalPeriodMinute" & strType))
	
	if GetDisplayTimeInAMPMFormat() then
		intAMorPM = Clng(Request.Form("selectCalPeriodAMorPM" & strType))
		if intHourVal = 12 then
			if intAMorPM = 0 then
				if strType = "Start" then ' This means it is 12AM, so we set the number of hours to 0
					intHourVal = 0
				elseif strType = "End" then
					intHourVal = 24
				end if		
			elseif intAMorPM = 12 then
				intAMorPM = 0
			end if
		end if
	else
		intAMorPM = 0
	end if
	totalSeconds = 60*60*(intHourVal + intAMorPM) + 60*intMinuteVal
	GetNumberOfSecondsFromSelects = totalSeconds
End Function

Function GetPeriodsSeparateSelect(strType)
	Dim strHTML, ii, bottom_hour, top_hour, strExtraOpts
	
	if GetDisplayTimeInAMPMFormat() then
    bottom_hour = 1
		top_hour = 12
	else
    bottom_hour = 0
		top_hour = 24
	end if
	
	strHTML = strHTML & "<select class='clsInputBox' name='selectCalPeriodHour" & strType & "'>"
	for ii = bottom_hour to top_hour
		if len(Request.Form("selectCalPeriodHour" & strType)) then
			if CStr(ii) = Request.Form("selectCalPeriodHour" & strType) then
				strExtraOpts = " selected"
			end if
		elseif CStr(ii) = "8" then
			strExtraOpts = " selected"
		end if
		strHTML = strHTML & "<option value='" & ii & "'" & strExtraOpts & ">" & ii & "</option>" & vbNewLine
		strExtraOpts = ""		
	next
	strHTML = strHTML & "</select>"
	strHTML = strHTML & ":"
	strHTML = strHTML & "<select class='clsInputBox' name='selectCalPeriodMinute" & strType & "'>"
	for ii = 0 to CALENDARPERIODMINUTEPRECISION-1
		if AddZeroIfNecessary(ii*60/CALENDARPERIODMINUTEPRECISION) = Request.Form("selectCalPeriodMinute" & strType) then
			strExtraOpts = " selected"
		end if
		strHTML = strHTML & "<option value='" & AddZeroIfNecessary(ii*60/CALENDARPERIODMINUTEPRECISION) & "'" & strExtraOpts & ">" & AddZeroIfNecessary(ii*60/CALENDARPERIODMINUTEPRECISION) & "</option>" & vbNewLine		
		strExtraOpts = ""
	next
	strHTML = strHTML & "</select>"
	strHTML = strHTML & "&nbsp;"
	if GetDisplayTimeInAMPMFormat() then
		
		strHTML = strHTML & "<select class='clsInputBox' name='selectCalPeriodAMorPM" & strType & "'>"

		if Request.Form("selectCalPeriodAMorPM" & strType) = "0" or (not len(Request.Form("selectCalPeriodAMorPM" & strType)) and strType = "Start") then
			strExtraOpts = " selected"
		end if
		strHTML = strHTML & "<option value='0'" & strExtraOpts & ">" & "AM" & "</option>" & vbNewLine
		strExtraOpts = ""
		
		if Request.Form("selectCalPeriodAMorPM" & strType) = "12" or (not len(Request.Form("selectCalPeriodAMorPM" & strType)) and strType = "End") then
			strExtraOpts = " selected"
		end if
		strHTML = strHTML & "<option value='12'" & strExtraOpts & ">" & "PM" & "</option>" & vbNewLine
		
		strHTML = strHTML & "</select>"
	end if
	
	GetPeriodsSeparateSelect = strHTML
End Function

' This function returns a select with time increments specified by the constant CALENDARPERIODPRECISION
Function GetPeriodsSelect(strType)
	Dim strHTML
	Dim ii
	strHTML = strHTML & "<select class='clsInputBox' name='selectCalPeriod" & strType & "'>"
	
	for ii = 0 to CALENDARPERIODPRECISION 

		' calculate number of seconds for period, then parse hours, minutes and seconds out of it 
		intPeriodSeconds = Int(ii*24*60*60/Clng(CALENDARPERIODPRECISION))
		intHours = Int(intPeriodSeconds/(60*60))
		intMinutes = Int((intPeriodSeconds - intHours*60*60)/60)
		'intSeconds = intPeriodSeconds - intHours*60*60 - intMinutes*60
		
		if GetDisplayTimeInAMPMFormat() then
			' Display stuff in AM/PM format
			if intHours > 11 and intHours < 24 then
				strAMorPM = "PM"
			else
				strAMorPM = "AM"
			end if
			if intHours > 12 then
				intHours = intHours - 12
			end if
		else
			strAMorPM = ""
		end if
		
		'Display whole system string
		strHTML = strHTML & "<option value='" & AddZeroIfNecessary(intPeriodSeconds) & "'>" & intHours & ":" & AddZeroIfNecessary(intMinutes) & "&nbsp;" & strAMorPM & "</option>" & vbNewLine
	next	
	
	strHTML = strHTML & "</select>"
	GetPeriodsSelect = strHTML
End Function

Function GetCalendarCodeSelect()
	Dim strHTML
	Dim objEnumCfg
	Dim objEnumColl
	Dim varEnum
	Dim enumVal  
	Set objEnumCfg = Server.CreateObject("Metratech.MTEnumConfig")
	Set objEnumColl = objEnumCfg.GetEnumerators("metratech.com/calendar", "CalendarCode")
	' TODO: Check if enum was successfully loaded
  Dim lang
  lang = session.Contents("FRAMEWORK_APP_LANGUAGE_SHORT")
  Set lc = Server.CreateObject("Metratech.LocaleConfig")
  lc.Initialize("Core")
  lc.LoadLanguage(lang)

	strHTML = ""
	strHTML = strHTML & "<select class='clsInputBox' name='selectCalCode'>"
	For Each varEnum in objEnumColl
		' First figure out the enum value
		enumVal = objEnumCfg.GetEnumeratorValueByID(objEnumCfg.GetID("metratech.com/calendar", "CalendarCode", varEnum.Name))
		strHTML = strHTML & "<option value=" & CStr(enumVal) & ">" & lc.GetLocalizedString("metratech.com/calendar/CalendarCode/" & varEnum.Name, lang)  & "</option>"
	Next
	
	strHTML = strHTML & "</select>"
	GetCalendarCodeSelect = strHTML
End Function

Function RemovePeriodConfig()
	dim strHTML
	dim varDayID	
	strHTML = ""

	' This can be either a weekday of holiday - we treat them both as a calendar day
	set objMTCalendar = session("objMTCalendar")
	
	if UCase(session("periodAddRem_daytype")) = "HOLIDAY" then 
		varDayID = CStr(session("periodAddRem_dayid"))
		set objDay = objMTCalendar.GetHoliday(varDayID)
	else
		varDayID = CLng(session("periodAddRem_dayid"))
		set objDay = objMTCalendar.GetWeekday(varDayID)
	end if
	
	strHTML = strHTML & "<table>"
	for each objPeriod in objDay.GetPeriods
		strHTML = strHTML & "<tr>"
		strHTML = strHTML & "<td><input type='checkbox' name='checkday_" & objPeriod.StartTime & "' value='in_form'></td>"
		strHTML = strHTML & "<td>" & FormatTimeString(objPeriod.StartTime) & "</td>"
		strHTML = strHTML & "<td>" & "&nbsp;-&nbsp;" & "</td>"
		strHTML = strHTML & "<td>" & FormatTimeString(objPeriod.EndTime) & "</td>"
		strHTML = strHTML & "<td>" & objPeriod.GetCodeAsString & "</td>"
		strHTML = strHTML & "</tr>"	
	next
	strHTML = strHTML & "</table>"
	RemovePeriodConfig = strHTML
End Function

Function AddPeriodConfig()
	dim strHTML
	strHTML = "<table>"
	strHTML = strHTML & "<tr><td nowrap class='CaptionEWRequired' align='right'>"
	strHTML = strHTML & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_STARTTIME")
	strHTML = strHTML & "</td><td nowrap align='left'>"
	strHTML = strHTML & GetPeriodsSeparateSelect("Start")
	'strHTML = strHTML & "<input class='clsInputBox' type='text' name='textStartTime' maxlength='12'>"
	strHTML = strHTML & "</td></tr>"
	strHTML = strHTML & "<tr><td nowrap class='CaptionEWRequired' align='right'>"
	strHTML = strHTML & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_ENDTIME")
	strHTML = strHTML & "</td><td nowrap align='left'>"
	strHTML = strHTML & GetPeriodsSeparateSelect("End")
	'strHTML = strHTML & "<input class='clsInputBox' type='text' name='textEndTime' maxlength='12'>"
	strHTML = strHTML & "</td></tr>"
	strHTML = strHTML & "<tr><td nowrap class='CaptionEWRequired' align='right'>"
	strHTML = strHTML & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_CODE")
	strHTML = strHTML & "</td><td nowrap align='left'>"
	strHTML = strHTML & GetCalendarCodeSelect()
	strHTML = strHTML & "</td></tr>"
  strHTML = strHTML & "</table>"
	AddPeriodConfig = strHTML
End Function

'----------------------------------------------------------------------------
' PAGE PROCESSING STARTS
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
' OK - CREATE CALENDAR IN DATABASE, CREATE FILE ON DISK, CREATE MAPPING IN
' RATESCHEDULE BY EDITING FIRST RULE IN RULESET. IF THERE ARE O RULES, THEN
' ADD FIRST RULE AND CREATE MAPPING
'---------------------------------------------------------------------------- 

set objMTCalendar = session("objMTCalendar")

' Save the day id we are operating on
if Len(TRIM(Request.QueryString("day_id"))) > 0 then
	session("periodAddRem_dayid") = Request.QueryString("day_id")
end if
if Len(TRIM(Request.QueryString("action"))) > 0 then
	session("periodAddRem_action") = Request.QueryString("action")
end if
if Len(TRIM(Request.QueryString("daytype"))) > 0 then
	session("periodAddRem_daytype") = Request.QueryString("daytype")
end if

	
if UCase(session("periodAddRem_daytype")) = "WEEKDAY" then
	set objDay = objMTCalendar.GetWeekday(Clng(session("periodAddRem_dayid")))
else	' Holiday
	set objDay = objMTCalendar.GetHoliday(CStr(session("periodAddRem_dayid")))
end if

' Processing the submitted page
if request.Form("FormAction") = "OK" then

	if session("periodAddRem_action") = "Remove" then
		' First we save all starttimes of periods that should be removed
		dim remove_ids(100)
		dim ii
		ii = 1
		for each objPeriod in objDay.GetPeriods
			if Request.Form("checkday_" & objPeriod.StartTime) = "in_form" then
				remove_ids(ii) = objPeriod.StartTime
				ii = ii+1
			end if
		next
		' Then we call the remove method with each of those starttimes
		dim count
		count = ii
		for ii = 1 to count-1
			objDay.RemovePeriod(remove_ids(ii))
		next
		if count > 0 then
			session("UnsavedChanges") = true
		end if
	else ' Adding a new period
		
		Dim starttime, endtime

		starttime = GetNumberOfSecondsFromSelects("Start")
		endtime = GetNumberOfSecondsFromSelects("End")
    
  		'stop
	 	On Error Resume Next
    Dim isValid
 		isValid = objDay.ValidatePeriodTimes(starttime, endtime)
'  	call WriteRunTimeError(FrameWork.GetDictionary("TEXT_MPTE_CANNOT_CREATE_PERIOD"), true)
    if err.Number = 0 then
 		  set objPeriod = objDay.CreatePeriod
      objPeriod.StartTime = starttime
      objPeriod.EndTime = endtime
      objPeriod.Code = Request.Form("selectCalCode")
      session("UnsavedChanges") = true
    else
      Call WriteError("<b>" & FrameWork.GetDictionary("TEXT_MPTE_CANNOT_CREATE_PERIOD") & ":</b><br>" & err.description)    
  	end if
	end if
		
	if err.Number = 0 then
		set session("objMTCalendar") = objMTCalendar
		call response.write("<script LANGUAGE=""JavaScript1.2"">window.opener.location='gotoCalendar.asp?Action=AfterEditPeriod';</script>")
	 	call response.end
	end if
	On Error Goto 0
end if

'----------------------------------------------------------------------------
' HTML WRITING STARTS
'----------------------------------------------------------------------------

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
  <head>
  
	<title><%=FrameWork.GetDictionary("TEXT_CALENDAR_PERIOD")%></title>
	<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET1")%>">
  <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET2")%>">
  <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET3")%>">
	<meta charset="UTF-8">
  
  <script language="JavaScript1.2" src="/mpte/shared/browsercheck.js"></script>    
  <script language="JavaScript1.2" src="/mpte/shared/PopupModalDialog.js"></script>
  <script LANGUAGE="JavaScript1.2">  
  
        //Added key handlers for ESC and ENTER key
      document.onkeypress = keyhandler;
    
      function keyhandler(e) {
          if (document.layers)
              Key = e.which;
          else
              Key = window.event.keyCode;
          //if (Key != 0) alert("Key pressed! ASCII-value: " + Key);
          
          if(Key==27){ // Handle ESC key
            window.close();
          }
          
          if(Key==13){ // Handle ENTER key
            SubmitForm('OK');
          }
      }
      
  	function SubmitForm(istrAction)
    {
    	document.main.FormAction.value = istrAction;
      document.main.submit();
    }
  </script>

  </head>
  <body onBlur="javascript:LostFocus();" onFocus="javascript:GotFocus('window');" onLoad="javascript:SizeWindow();">
  <FORM ACTION="gotoPeriodAddRemove.asp?" METHOD="POST" NAME="main" onFocus="javascript:InAForm(main);" onBlur="javascript:OutOfForm();">
	<INPUT TYPE="Hidden" NAME="FormAction" VALUE="">
	
	<table width="100%">
		 
		<%
		call WriteError(mstrErrors)
		
		if session("periodAddRem_action") = "Remove" then
			response.write "<tr><td align='center' NOWRAP>"
			response.write GetTitle(FrameWork.GetDictionary("TEXT_MPTE_REMOVE_PERIODS_TITLE"))
			response.write "<td></tr>"
			response.write "<tr><td align='center' NOWRAP>"
			response.write RemovePeriodConfig()
			response.write "<td></tr>"
		else
			response.write "<tr><td align='center' NOWRAP>"
			response.write GetTitle(FrameWork.GetDictionary("TEXT_MPTE_ADD_PERIOD_TITLE"))
			response.write "<td></tr>"
			response.write "<tr><td align='center' NOWRAP>"
			response.write AddPeriodConfig()
			response.write "<td></tr>"
		end if
		%>
  </table>  
  <br>
  <table width="100%">
  <tr>		 
    <td align="center" NOWRAP>
	  	<input type="button" class="clsButtonSmall" name="OK" value="<%=FrameWork.GetDictionary("TEXT_MPTE_OK_BTN")%>" onClick="javascript:SubmitForm('OK');">
	  	<input type="button" class="clsButtonSmall" name="cancel" value="<%=FrameWork.GetDictionary("TEXT_MPTE_CANCEL_BTN")%>" onClick="javascript:window.close();">
    </td>
  </tr>
  </table>
  </FORM>
  </body>
</html>