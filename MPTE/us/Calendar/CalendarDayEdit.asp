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
' // $Author$
' // $Revision$
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
' none


'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
dim objMTRateSched 			' As MTRateSchedule
dim objMTRuleset				' As MTRuleset
dim objMTParamTable			' As MTParamTableDefintion
dim objMTCalendar 	    ' As MTCalendar
dim objDay							' As MTCalendarDay
dim objMTProductCatalog ' As MTProductCatalog
dim intDayID 						
dim tabNumber
dim newDay							' As boolean
dim mstrErrors

FUNCTION GetTitle(Caption)
	Dim strTitle
	strTitle = 			  "<table border=""0"" cellpadding=""1"" cellspacing=""0"" width=""100%"">"
	strTitle = strTitle & 	"<tr>"
  strTitle = strTitle & 		"<td Class='CaptionBar' nowrap>"
  strTitle = strTitle & 			Server.HTMLEncode(Caption)
	strTitle = strTitle & 		"</td>"
	strTitle = strTitle & 	"</tr>"
	strTitle = strTitle & "</table>"	
	GetTitle = strTitle
END FUNCTION

Function GetCalendarCodeSelect()
	Dim strHTML
	Dim objEnumCfg
	Dim objEnumColl
	Dim varEnum
	Dim enumVal
	Set objEnumCfg = CreateObject("Metratech.MTEnumConfig")
	Set objEnumColl = objEnumCfg.GetEnumerators("metratech.com/calendar", "CalendarCode")

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
		strHTML = strHTML & "<option value=" & CStr(enumVal) & ">" & lc.GetLocalizedString("metratech.com/calendar/CalendarCode/" & varEnum.Name, lang) & "</option>"
	Next
	
	strHTML = strHTML & "</select>"
	GetCalendarCodeSelect = strHTML
End Function

Function GetDayConfiguration(CalendarDay, strDayType)

	dim strHTML
	strHTML = ""
	strHTML = strHTML & "<table width=""100%"">"
	if UCase(strDayType) = "HOLIDAY" then ' It is a holiday
		dim strName, strDate
		if not IsObject(CalendarDay) then 	' This means we are adding a new holiday
			strName = Request.Form("hname")
			strDate = Request.Form("hdate")
		else
			strName = CalendarDay.Name
			strDate = CalendarDay.Date
		end if
		strHTML = strHTML & "<tr><td nowrap class=""CaptionEWRequired"" align=""right"">" & FrameWork.GetDictionary("TEXT_MPTE_HOLIDAY_NAME") & "</td>" & vbNewLine
		strHTML = strHTML & "<td nowrap align=""left""><input type=""text"" name=""hname"" class=""clsInputBox"" value=""" & strName & """></td></tr>" & vbNewLine		
		strHTML = strHTML & "<tr><td nowrap class=""CaptionEWRequired"" align=""right"">"  & FrameWork.GetDictionary("TEXT_MPTE_HOLIDAY_DATE") & "</td>" & vbNewLine
		strHTML = strHTML & "<td nowrap align=""left""><input type=""text"" name=""hdate"" class=""clsInputBox"" value=""" & strDate & """>" & vbNewLine
		
		strHTML = strHTML &	"<A HREF=""#"" onClick=""getCalendarForTimeOpt(document.main.hdate, '', false);return false"">"  & vbNewLine
		strHTML = strHTML &	"	<img src=""/mcm/default/localized/en-us/images/popupcalendar.gif"" width=16 height=16 border=0 alt="""">" & vbNewLine
		strHTML = strHTML &	"</A></td></tr>" & vbNewLine

	else
		strHTML = strHTML & "<tr><td nowrap class=""CaptionEWRequired"" align=""right"">" & FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_CODE") & "</td>"
		strHTML = strHTML & "<td align=""left"">"	
		strHTML = strHTML & GetCalendarCodeSelect()
		strHTML = strHTML & "</td></tr>"
	end if
	strHTML = strHTML & "</table>"	
	GetDayConfiguration = strHTML
End Function

Function GetDayName(intDayIndex)
	Select Case intDayIndex
		Case 0
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_SUNDAY")
		Case 1
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_MONDAY")
		Case 2
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_TUESDAY")
		Case 3
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_WEDNESDAY")
		Case 4
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_THURSDAY")
		Case 5
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_FRIDAY")
		Case 6
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_SATURDAY")
		Case 7
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_DEFAULTWEEKDAY")
		Case 8
			GetDayName = FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_DEFAULTWEEKEND")
		Case else
			GetDayName = "Not a valid weekday"
	End Select	
End Function

'----------------------------------------------------------------------------
' PAGE PROCESSING STARTS
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
' OK - CREATE CALENDAR IN DATABASE, CREATE FILE ON DISK, CREATE MAPPING IN
' RATESCHEDULE BY EDITING FIRST RULE IN RULESET. IF THERE ARE O RULES, THEN
' ADD FIRST RULE AND CREATE MAPPING
'---------------------------------------------------------------------------- 


' Save the day id we are operating on
Dim strDayID, strDayType
strDayID = Request.QueryString("day_id")
strDayType = Request.QueryString("daytype")
newDay = Request.QueryString("newDay")

if Len(TRIM(Request.Form("day_id"))) > 0 then
	strDayID = Request.Form("day_id")
end if

if Len(TRIM(Request.Form("daytype"))) > 0 then
	strDayType = Request.Form("daytype")
end if

if Len(TRIM(Request.Form("newday"))) > 0 then
	newDay = Request.Form("newday")
end if

'Weekday version
set objMTCalendar = session("objMTCalendar")

if UCase(strDayType) = "HOLIDAY" then
	if not UCase(newDay) = "TRUE" then
		set objDay = objMTCalendar.GetHoliday(CStr(strDayID))
	end if
else ' Weekday
	if not UCase(newDay) = "TRUE" then
		set objDay = objMTCalendar.GetWeekday(CLng(strDayID))
	end if
end if
	
' Let's see if we should return to the caller page
if request.Form("FormAction") = "OK" then
	On Error Resume Next
	mstrErrors = ""
	
	if UCase(strDayType) = "WEEKDAY" then
		if UCase(newDay) = "TRUE" then
			set objDay = objMTCalendar.CreateWeekday(CLng(strDayID))
		end if
		objDay.Code = Clng(Request.Form("selectCalCode"))
	else ' Holiday
		dim tmpName, tmpDate			
			
			'Validate Name
			tmpName = Request.Form("hname")
			tmpDate = Request.Form("hdate")
			
			if InStr(tmpName, Chr(34)) then
				mstrErrors = mstrErrors & FrameWork.GetDictionary("TEXT_MPTE_HOLIDAYNAME_INVALID") & "<br>"
			end if
			if len(Trim(tmpName)) = 0 then
				mstrErrors = mstrErrors & FrameWork.GetDictionary("TEXT_MPTE_HOLIDAYNAME_BLANK") & "<br>"
			end if
			
			'Do date validation function
			if Not FrameWork.IsValidDate(tmpDate, FALSE) then
				mstrErrors = mstrErrors & FrameWork.GetDictionary("TEXT_MPTE_HOLIDAYDATE_INVALID") & "<br>"
			end if
			
			' Let's see if there is a holiday with this name already on this calendar
			if len(mstrErrors) = 0 then
				Dim tmpHoliday
				Set tmpHoliday = objMTCalendar.GetHoliday(tmpName)
				if not tmpHoliday Is Nothing then
					if not objDay Is Nothing then
						if objDay.Name <> tmpHoliday.Name then
							mstrErrors = mstrErrors & FrameWork.GetDictionary("TEXT_MPTE_HOLIDAYNAME_DUPLICATE") & "<br>"	
						end if
					else 
						mstrErrors = mstrErrors & FrameWork.GetDictionary("TEXT_MPTE_HOLIDAYNAME_DUPLICATE") & "<br>"
					end if
				end if
			end if
					
			if len(mstrErrors) = 0 then
				if UCase(newDay) = "TRUE" then
					set objDay = objMTCalendar.CreateHoliday(tmpName)
				else
					objDay.Name = tmpName
				end if
				objDay.Date = CDate(tmpDate)
			end if
				
	end if
	
	If len(mstrErrors) = 0 Then ' If there is no user error, then print out a possible system error
		call WriteRunTimeError("", true)
	End If
	
	If len(mstrErrors) = 0 and Err.Number = 0 Then
		set session("objMTCalendar") = objMTCalendar
		session("UnsavedChanges") = true
		call response.write("<script LANGUAGE=""JavaScript1.2"">window.opener.location=""gotoCalendar.asp?Action=AfterEditDay"";</script>")
  	call response.end
	End If
	On Error goto 0
end if



'----------------------------------------------------------------------------
' HTML WRITING STARTS
'----------------------------------------------------------------------------

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
  <head>
	<title><%=FrameWork.GetDictionary("TEXT_CALENDAR_DAY")%></title>
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
            SubmitForm('OK','<%=Replace(strDayID,"'","\'")%>','<%=strDayType%>','<%=newDay%>');
          }
        
      }
      
  	function SubmitForm(istrAction, day_id, daytype, newday)
    {
    	document.main.FormAction.value = istrAction;
			document.main.daytype.value = daytype;
			document.main.day_id.value = day_id;
			document.main.newday.value = newday;
      document.main.submit();
    }
		
  </script>

  </head>
  <body onBlur="javascript:LostFocus();" onFocus="javascript:GotFocus('window');" onLoad="javascript:SizeWindow();">
  <FORM ACTION="gotoCalendarDayEdit.asp" METHOD="POST" NAME="main" onFocus="javascript:InAForm(main);" onBlur="javascript:OutOfForm();">
	<INPUT TYPE="Hidden" NAME="FormAction" VALUE="">
	<INPUT TYPE="Hidden" NAME="daytype" VALUE="">
	<INPUT TYPE="Hidden" NAME="day_id" VALUE="">
	<INPUT TYPE="Hidden" NAME="newday" VALUE="">
	
	<table width="100%">	 
	<%
	
	call WriteError(mstrErrors)
	
	if UCase(strDayType) = "HOLIDAY" then
		if UCase(newDay) = "TRUE" then
			response.write GetTitle(FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_NEW_HOLIDAY"))
		else	
			response.write GetTitle(objDay.Name)
		end if
	else ' Adding a Weekday
		if UCase(newDay) = "TRUE" then
			response.write GetTitle(FrameWork.GetDictionary("TEXT_MPTE_ADDWEEKDAY"))
		else	
      response.write GetTitle(GetDayName(objDay.DayofWeek))
		end if
	end if
	
	response.write("<table width=""250""><tr><td>&nbsp;</td></tr><tr><td>&nbsp;</td></tr></table>")
	response.write GetDayConfiguration(objDay, strDayType)
	response.write("<table width=""250""><tr><td>&nbsp;</td></tr></table>")

	%>
  </table>  
  <br>
  <table width="100%">
  <tr>		 
    <td align="center" NOWRAP>
	  	<input type="button" class="clsButtonSmall" name="OK" value="<%=FrameWork.GetDictionary("TEXT_MPTE_OK_BTN")%>" onClick="javascript:SubmitForm('OK','<%=Replace(strDayID,"'","\'")%>','<%=strDayType%>','<%=newDay%>');">
	  	<input type="button" class="clsButtonSmall" name="cancel" value="<%=FrameWork.GetDictionary("TEXT_MPTE_CANCEL_BTN")%>" onClick="javascript:window.close();">
    </td>
  </tr>
  </table>
  </FORM>
  </body>
</html>