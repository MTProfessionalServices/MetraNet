	
<%


Function GetDayName(intDayIndex)
	Select Case intDayIndex
		Case CALENDARDAY_SUNDAY
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_SUNDAY")
		Case CALENDARDAY_MONDAY
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_MONDAY")
		Case CALENDARDAY_TUESDAY
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_TUESDAY")
		Case CALENDARDAY_WEDNESDAY
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_WEDNESDAY")
		Case CALENDARDAY_THURSDAY
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_THURSDAY")
		Case CALENDARDAY_FRIDAY
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_FRIDAY")
		Case CALENDARDAY_SATURDAY
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_SATURDAY")
		Case CALENDARDAY_DEFAULTWEEKDAY
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_DEFAULTWEEKDAY")
		Case CALENDARDAY_DEFAULTWEEKEND
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_DEFAULTWEEKEND")
		Case else
			GetDayName = "Not a valid weekday"
	End Select	
End Function

Function GetCalendarGridHeader(intGridType)
	Dim strHtml
	strHTML = ""
	strHTML = strHTML & "<tr>"		

	if intGridType = 2 then
		' Holidays																																						
		strHTML = strHTML & "<td colspan='2' class='clsCalendarGridHeader' nowrap>&nbsp;</td>"									
		strHTML = strHTML &	"<td class='clsCalendarGridHeader' nowrap>" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_HOLIDAY") & "</td>"
		strHTML = strHTML & "<td class='clsCalendarGridHeader' nowrap>" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_DATE") & "</td>"							  
	else
		' Weekdays and Weekends
		strHTML = strHTML & "<td class='clsCalendarGridHeader' nowrap>&nbsp;</td>"
		strHTML = strHTML &	"<td class='clsCalendarGridHeader' nowrap>" & FrameWork.GetDictionary("TEXT_MPTE_DAY_OF_WEEK") & "</td>"					
		strHTML = strHTML & "<td colspan='2' class='clsCalendarGridHeader' nowrap>" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_DEFCODE") & "</td>"
	end if

	strHTML = strHTML & "<td class='clsCalendarGridHeader' nowrap align='center'>" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_GRAPH") & "</td>"
	strHTML = strHTML & "<td class='clsCalendarGridHeader' nowrap colspan='2'>" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_PERIODS") & "</td>"				
	strHTML = strHTML & "</tr>"
	GetCalendarGridHeader = strHTML
End Function	

Function GetPeriodGraphTimeScale()
	Dim strHTML
  
  if GetDisplayTimeInAMPMFormat() then
  	strHTML = strHTML & "<tr><td colspan='100'><table width='100%'><tr>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>12AM</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>3AM</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>6AM</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>9AM</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>12PM</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>3PM</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>6PM</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>9PM</td>"
  	strHTML = strHTML & "</tr></table></td></tr>"
  else
  	strHTML = strHTML & "<tr><td colspan='100'><table width='100%'><tr>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>0:00</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>3:00</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>6:00</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>9:00</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>12:00</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>15:00</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>18:00</td>"
  	strHTML = strHTML & "<td width='12.5%' class='clsCalendarGraphScale'>21:00</td>"
  	strHTML = strHTML & "</tr></table></td></tr>"
   end if
     
	GetPeriodGraphTimeScale = strHTML
End Function

Function GetPeriodGraphAlt(objPeriodCollection, objCalCode)
	Dim lenPeriods(100)
	Dim calCodes(100)
	Dim strHTML
	Dim ii, p_begin, p_end, p_color, total_len
	
	ii = 1
	strHTML = ""
	total_len = 0
	
	p_begin = 0 'First second of the day
	for each objPeriod in objPeriodCollection
		p_end = objPeriod.StartTime
		lenPeriods(ii) = p_end - p_begin
		calCodes(ii) = objCalCode
		total_len = total_len + lenPeriods(ii)
		ii = ii+1
		p_begin = objPeriod.StartTime
		p_end = objPeriod.EndTime	
		lenPeriods(ii) = p_end - p_begin
		total_len = total_len + lenPeriods(ii)
		calCodes(ii) = objPeriod.Code
		ii = ii+1
		p_begin = objPeriod.EndTime
	next
	
	p_end = 86399 'Last second of the day
	lenPeriods(ii) = p_end - p_begin
	calCodes(ii) = objCalCode
	total_len = total_len + lenPeriods(ii)
	
	strHTML = strHTML & "<table width='100%'>"
	strHTML = strHTML & GetPeriodGraphTimeScale
	strHTML = strHTML & "<tr>"
	for ii = 1 to 2*objPeriodCollection.Count + 1
		if lenPeriods(ii) > 0 then
			strHTML = strHTML & "<td class='clsCalendarGraph" & calCodes(ii) & "' width='" & 100*lenPeriods(ii)/total_len & "%' height='20'></td>"
		end if
	next
	strHTML = strHTML & "</tr></table>"
	
	GetPeriodGraphAlt = strHTML
	
End Function
	
Function GetPeriodsTable(objMTPeriodCollection, localEnum, lang)
	Dim strHTML, objPeriod
	strHTML = ""
	strHTML = strHTML & "<table>"
	if objMTPeriodCollection.Count = 0 then
		strHTML = strHTML & "<tr nowrap><td>" & FrameWork.GetDictionary("TEXT_MPTE_NO_PERIODS_CONFIGURED")  & "</td></tr>"
	else
		for each objPeriod in objMTPeriodCollection
			strHTML = strHTML & "<tr nowrap>"
			strHTML = strHTML & "<td align='right' nowrap>" & FormatTimeString(objPeriod.StartTime) & "<td>"
			strHTML = strHTML & "<td align='center' nowrap>&nbsp;-&nbsp;<td>"
			strHTML = strHTML & "<td align='right' nowrap>" & FormatTimeString(objPeriod.EndTime) & "</td>"
			strHTML = strHTML & "<td nowrap>" & localEnum.GetLocalizedString("metratech.com/calendar/CalendarCode/" & objPeriod.GetCodeAsString, lang) & "<td>"
			strHTML = strHTML & "</tr>"
		next
	End if
	strHTML = strHTML & "</table>"
	GetPeriodsTable = strHTML
End Function	
	
Function GetCalendarWeekdayRow(objMTCalendarWeekday, clsStyle, booIsConfigured, intDayofWeek, localEnum, lang)
	Dim strHTML, strExtraOpts, strDisabledDay
	strHTML = ""
	if UCase(session("RATES_EDITMODE")) = "TRUE" then
		strEditDayOpt = ""
		strDisabledDay = ""
		strExtraOpts = ""
	else
		strEditDayOpt = " disabled"
		strDisabledDay = " disabled"
		strExtraOpts = " disabled"
	end if
	strHTML = strHTML & "<tr>" & vbNewLine
	strHTML = strHTML & "<td class=""" & clsStyle & """>"
	
	if booIsConfigured and objMTCalendarWeekday.DayofWeek <> CALENDARDAY_DEFAULTWEEKDAY and objMTCalendarWeekday.DayofWeek <> CALENDARDAY_DEFAULTWEEKEND then
		strHTML = strHTML & "<input type=""button"" class=""clsButtonBlueMedium"" name=""removeday" & intDayofWeek & """ value=""" & FrameWork.GetDictionary("TEXT_MPTE_SET_DAY_TO_DEFAULT") & """ "	
		strHTML = strHTML & " onClick=""javascript:SubmitForm('RemoveWeekday','" & intDayofWeek & "');"""
		strHTML = strHTML & strEditDayOpt & ">" & vbNewLine
	elseif not booIsConfigured then		
		strHTML = strHTML & "<input type=""button"" class=""clsButtonBlueMedium"" name=""addday" & intDayofWeek & """ value=""" & FrameWork.GetDictionary("TEXT_MPTE_CUSTOMIZE_DAY") & """ "	
		strHTML = strHTML & " onClick=""javascript:OpenDialogWindow('gotoCalendarDayEdit.asp?daytype=Weekday&newDay=TRUE&day_id=" & intDayofWeek & "','');"""
		strHTML = strHTML & strEditDayOpt & ">" & vbNewLine
	end if
	strHTML = strHTML & "</td>"
	
	strHTML = strHTML & "<td class='"& clsStyle &"'>" & GetDayName(intDayofWeek) & "</td>" & vbNewLine
	strHTML = strHTML & "<td class='"& clsStyle &"'>" & localEnum.GetLocalizedString("metratech.com/calendar/CalendarCode/" & objMTCalendarWeekday.GetCodeAsString, lang) & "</td>" & vbNewLine
	' If this day of the week is not configured, we don't allow editing the calendar code on it
	if not booIsConfigured then
		strDisabledDay = " disabled"
	end if
	strHTML = strHTML & "<td class='"& clsStyle &"'><input type='button' class='clsButtonBlueSmall' name='editday" & intDayofWeek & "' value='" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_EDITDAY") & "'"	
	strHTML = strHTML & " onClick=""javascript:OpenDialogWindow('gotoCalendarDayEdit.asp?daytype=Weekday&day_id=" & objMTCalendarWeekday.DayofWeek & "','');"" "
	strHTML = strHTML & "" & strDisabledDay & "><br>" & vbNewLine	
	strHTML = strHTML & "<td class='"& clsStyle &"' width='25%'>" & GetPeriodGraphAlt(objMTCalendarWeekday.GetPeriods, objMTCalendarWeekday.Code) & "</td>" & vbNewLine
	strHTML = strHTML & "<td class='"& clsStyle &"' align='right'>" & GetPeriodsTable(objMTCalendarWeekday.GetPeriods, localEnum, lang) & "</td>" & vbNewLine
	strHTML = strHTML & "<td class='"& clsStyle &"'><input type='button' class='clsButtonBlueSmall' name='AddPeriod" & intDayofWeek & "' value='" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_ADDPERIOD") & "'"
	strHTML = strHTML & " onClick=""javascript:OpenDialogWindow('gotoPeriodAddRemove.asp?daytype=Weekday&action=Add&day_id=" & intDayofWeek & "','');"" "
	strHTML = strHTML & "" & strDisabledDay & "><br>" & vbNewLine
	' If there are no period to remove, or the day is not configured, we disable the buttons
	if objMTCalendarWeekday.GetPeriods.Count = 0 or not booIsConfigured then
		strExtraOpts = " disabled"
	end if
	strHTML = strHTML & "<input type='button' class='clsButtonBlueSmall' name='RemovePeriod" & intDayofWeek & "' value='" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_REMOVEPERIOD") & "'"
	strHTML = strHTML & " onClick=""javascript:OpenDialogWindow('gotoPeriodAddRemove.asp?daytype=Weekday&action=Remove&day_id=" & objMTCalendarWeekday.DayofWeek & "','');"" "
	strHTML = strHTML & strExtraOpts & ">" & vbNewLine
	
	strHTML = strHTML & "</tr>" & vbNewLine
	GetCalendarWeekdayRow = strHTML
End Function

Function GetCalendarHolidayRow(objMTCalendarHoliday, clsStyle)
	Dim strHTML, strExtraOpts, strHolidayName
	
	strHolidayName = Replace(objMTCalendarHoliday.Name, "'", "\'")
	
	if UCase(session("RATES_EDITMODE")) = "TRUE" then
		strExtraOpts = ""
	else
		strExtraOpts = " disabled"
	end if
	
	strHTML = ""
	strHTML = strHTML & "<tr>" & vbNewLine
	strHTML = strHTML & "<td class=""" & clsStyle & """><input type=""button"" class=""clsButtonBlueSmall"" name=""removeday"" value=""" & FrameWork.GetDictionary("TEXT_MPTE_REMOVEDAY") & """ "
	strHTML = strHTML & " onClick=""javascript:SubmitForm('RemoveHoliday','" & strHolidayName & "');"""
	strHTML = strHTML & strExtraOpts & ">" & vbNewLine
	strHTML = strHTML & "<td class='"& clsStyle &"'><input type=""button"" class=""clsButtonBlueSmall"" name=""editday" & strHolidayName & """ value=""" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_EDITDAY") & """ "	
	strHTML = strHTML & " onClick=""javascript:OpenDialogWindow('gotoCalendarDayEdit.asp?daytype=Holiday&day_id=" & Server.URLEncode(objMTCalendarHoliday.Name) & "','');"" "
	strHTML = strHTML & strExtraOpts & ">" & vbNewLine
	strHTML = strHTML & "<td class='"& clsStyle &"'>" & Server.HTMLEncode(objMTCalendarHoliday.Name) & "</td>" & vbNewLine
	strHTML = strHTML & "<td class='"& clsStyle &"'>" & objMTCalendarHoliday.Date & "</td>" & vbNewLine
	strHTML = strHTML & "<td class='"& clsStyle &"' width='25%'>" & GetPeriodGraphAlt(objMTCalendarHoliday.GetPeriods, objMTCalendarHoliday.Code) & "</td>"
	strHTML = strHTML & "<td class='"& clsStyle &"' align='right'>" & GetPeriodsTable(objMTCalendarHoliday.GetPeriods, localEnum, lang) & "</td>" & vbNewLine
	strHTML = strHTML & "<td class=""" & clsStyle & """><input type=""button"" class=""clsButtonBlueSmall"" name=""AddPeriod" & strHolidayName & """ value=""" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_ADDPERIOD") & """ "
	strHTML = strHTML & " onClick=""javascript:OpenDialogWindow('gotoPeriodAddRemove.asp?daytype=Holiday&action=Add&day_id=" & Server.URLEncode(objMTCalendarHoliday.Name) & "','');"" "
	strHTML = strHTML & strExtraOpts & "><br>" & vbNewLine
	if objMTCalendarHoliday.GetPeriods.Count = 0 then
		strExtraOpts = " disabled"
	end if
	strHTML = strHTML & "<input type=""button"" class=""clsButtonBlueSmall"" name=""RemovePeriod" & strHolidayName & """ value=""" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_REMOVEPERIOD") & """ "
	strHTML = strHTML & " onClick=""javascript:OpenDialogWindow('gotoPeriodAddRemove.asp?daytype=Holiday&action=Remove&day_id=" & Server.URLEncode(objMTCalendarHoliday.Name) & "','');"" "
	strHTML = strHTML & strExtraOpts & ">" & vbNewLine
	strHTML = strHTML & "</tr>" & vbNewLine
	GetCalendarHolidayRow = strHTML	
End Function	
	
Function GetCalendarGrid(objMTCalendar, intGridType)
	Dim strHTML, objDay, i, cellstyle, booIsConfigured, objDayColl
	strHTML = ""

  Dim lang
  lang = session.Contents("FRAMEWORK_APP_LANGUAGE_SHORT")
  Set lc = Server.CreateObject("Metratech.LocaleConfig")
  lc.Initialize("Core")
  lc.LoadLanguage(lang)

	strHTML = strHTML & GetCalendarGridHeader(intGridType)

	i = 0	

	' Holiday Grid
	if intGridType = 2 then
		for each objDay in objMTCalendar.GetHolidays
			cellstyle = "clsCalendarCell"
			strHTML = strHTML & GetCalendarHolidayRow(objDay, cellstyle)
		next		
	' Days of the week Grid: Mon - Fri, plus Default Weekday
	elseif intGridType = 0 then
		set objDay = objMTCalendar.GetWeekdayorDefault(CALENDARDAY_DEFAULTWEEKDAY)
		cellstyle = "clsCalendarCell"
		booIsConfigured = true
		strHTML = strHTML & GetCalendarWeekdayRow(objDay, cellstyle, booIsConfigured, CALENDARDAY_DEFAULTWEEKDAY, lc, lang)
		
		for i = CALENDARDAY_MONDAY to CALENDARDAY_FRIDAY ' 1 to 5
									 ' with 0, while the collection index starts at 1!!!
			cellstyle = "clsCalendarCell" 
			set objDay = objMTCalendar.GetWeekdayorDefault(i)
			'response.write "i = " & i & " DayofWeek = " & objDay.DayofWeek & "<br>"
			if objDay.DayofWeek = CALENDARDAY_DEFAULTWEEKDAY then ' If this day of the week is default
				cellstyle = "clsCalendarCellDisabled"
				booIsConfigured = false							
			else
				cellstyle = "clsCalendarCell"
				booIsConfigured = true										
			end if
			strHTML = strHTML & GetCalendarWeekdayRow(objDay, cellstyle, booIsConfigured, i, lc, lang)
		next
		
	' Weekend Grid : Sat, Sun + Default Weekend
	else 
		set objDay = objMTCalendar.GetWeekdayorDefault(CALENDARDAY_DEFAULTWEEKEND)
		cellstyle = "clsCalendarCell"
		booIsConfigured = true
		strHTML = strHTML & GetCalendarWeekdayRow(objDay, cellstyle, booIsConfigured, CALENDARDAY_DEFAULTWEEKEND,  lc, lang)
		
		' Saturday
		set objDay = objMTCalendar.GetWeekdayorDefault(CALENDARDAY_SATURDAY)
		if objDay.DayofWeek = CALENDARDAY_DEFAULTWEEKEND then ' If this day of the week is default
			cellstyle = "clsCalendarCellDisabled"
			booIsConfigured = false							
		else
			cellstyle = "clsCalendarCell"
			booIsConfigured = true										
		end if
		strHTML = strHTML & GetCalendarWeekdayRow(objDay, cellstyle, booIsConfigured, CALENDARDAY_SATURDAY,  lc, lang)

		' Sunday
		set objDay = objMTCalendar.GetWeekdayorDefault(CALENDARDAY_SUNDAY)
		if objDay.DayofWeek = CALENDARDAY_DEFAULTWEEKEND then ' If this day of the week is default
			cellstyle = "clsCalendarCellDisabled"
			booIsConfigured = false							
		else
			cellstyle = "clsCalendarCell"
			booIsConfigured = true										
		end if
		strHTML = strHTML & GetCalendarWeekdayRow(objDay, cellstyle, booIsConfigured, CALENDARDAY_SUNDAY,  lc, lang)
				
	end if
	GetCalendarGrid = strHTML
End Function

%>