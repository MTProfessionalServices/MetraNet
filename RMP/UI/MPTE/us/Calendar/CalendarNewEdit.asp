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

On Error Resume Next

'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
dim objMTRateSched 			' As MTRateSchedule
dim objMTRuleset				' As MTRuleset
dim objMTParamTable			' As MTParamTableDefintion
dim objMTCalendar 	    ' As MTCalendar
dim objMTProductCatalog ' As MTProductCatalog
dim objMTRule 					' As MTRule
dim intCalID  					' As Calendar ID
dim mstrErrors

dim strCalName
dim strCalDesc

' Check whether we are accessing this screen via the manage calendars option
strTMP = Request.QueryString("Manage")
if Len(strTMP) > 0 then
    session("manageCalendars") = CBool(strTMP)
end if

'----------------------------------------------------------------------------
' METHODS
'----------------------------------------------------------------------------
FUNCTION Draw_Title(Caption)
	Dim strTitle
	strTitle = 			  "<table border=""0"" cellpadding=""1"" cellspacing=""0"" width=""100%"">"
	strTitle = strTitle & 	"<tr>"
    strTitle = strTitle & 		"<td Class='CaptionBar' nowrap>"
    'SECENG: Fixing problems with output encoding
    strTitle = strTitle & 			SafeForHtml(Caption)
	strTitle = strTitle & 		"</td>"
	strTitle = strTitle & 	"</tr>"
	strTitle = strTitle & "</table>"
	Response.Write (strTitle)					
	Draw_Title = TRUE
END FUNCTION

'----------------------------------------------------------------------------
' PAGE PROCESSING STARTS
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
' OK - CREATE CALENDAR IN DATABASE, CREATE FILE ON DISK, CREATE MAPPING IN
' RATESCHEDULE BY EDITING FIRST RULE IN RULESET. IF THERE ARE O RULES, THEN
' ADD FIRST RULE AND CREATE MAPPING
'---------------------------------------------------------------------------- 
if request.Form("FormAction") = "OK" then
	'stop
	' Let's see if we are editing or adding a new Calendar
	intCalID = clng(Request.Form("CalendarID"))
	mstrErrors = ""
	' Let's instantiate the Calendar object and create a new calendar
	
	Set objMTProductCatalog = GetProductCatalogObject
	
	if intCalID < 0 then	' We are creating a new calendar
		On Error Resume Next
		Set objMTCalendar = objMTProductCatalog.CreateCalendar()
		call WriteRunTimeError (FrameWork.GetDictionary("TEXT_MPTE_CANNOT_CREATE_CALENDAR"), true)
		On Error Goto 0
	else					' We are editing an exiting calendar
		Set objMTCalendar = session("objMTCalendar")	
	end if
	
	strCalName = Request.Form("CalendarName")
	strCalDesc = Request.Form("CalendarDescription")
	
	if len(Trim(strCalName)) = 0 then
		mstrErrors = mstrErrors & FrameWork.GetDictionary("TEXT_MPTE_CALENDARNAME_BLANK") & "<br>"
	else
		' First see if there is a calendar on the system with the same name as the one being modified
		Dim objTmpCalendar

		Set objTmpCalendar = objMTProductCatalog.GetCalendarByName(strCalName)
		if not objTmpCalendar Is Nothing and not IsNull(objTmpCalendar) then
			if objTmpCalendar.ID <> objMTCalendar.ID then
				mstrErrors = mstrErrors & FrameWork.GetDictionary("TEXT_MPTE_ERROR_CALENDAR_NAME_DUPLICATE")
			end if
		end if
		
		' Ok, the desired calendar name is unique, so we will go ahead and change it
		if len(mstrErrors) = 0 then
			objMTCalendar.Name = strCalName
			objMTCalendar.Description = strCalDesc
			' TODO: figure out if/how these should be configurable
			objMTCalendar.TimeZoneOffset = 0
			objMTCalendar.CombinedWeekend = false
		
			' The following things happen when we are under the context of a rate schedule only.
			if not session("manageCalendars") = true then
				Set objMTRateSched = session("CalendarRateSchedule")
				Set objMTParamTableDef = session("CalendarParameterTable")
			 	if objMTRateSched.Ruleset.DefaultActions Is Nothing then
					objMTRateSched.Ruleset.DefaultActions = CreateActionSet(objMTParamTableDef)
			 	end if
			 	if not objMTCalendar.ID > 0 then 
					call SetRSActionValue(objMTRateSched.Ruleset.DefaultActions(1), -1)
				end if
				set session("CalendarRateSchedule") = objMTRateSched
			end if
			
			set session("objMTCalendar") = objMTCalendar
			
            On Error resume next
	        'Save the calendar configuration
	        objMTCalendar.Save
	        call WriteRunTimeError(FrameWork.GetDictionary("TEXT_MPTE_CANNOT_SAVE_CALENDAR"), true)

            session("RATES_EDITMODE") = true
			session("UnsavedChanges") = false
			call response.write("<script LANGUAGE=""JavaScript1.2"">window.opener.location=""gotoCalendar.asp?Action=AfterEditProps""</script>")
            call response.write("<script LANGUAGE=""JavaScript1.2"">window.close()</script>")
		 	call response.end
		end if
	end if
end if

'//----------------------------------------------------------
'// EDIT MODE
'// If we were passed an ID, then it means we are in Edit Mode
'//----------------------------------------------------------

if len(request.QueryString("cal_id")) = 0 then
	intCalID = -1
else
	intCalID = clng(request.QueryString("cal_id"))
	set objMTCalendar = session("objMTCalendar")
	strCalName = objMTCalendar.Name
	strCalDesc = objMTCalendar.Description
end if

'----------------------------------------------------------------------------
' HTML WRITING STARTS
'----------------------------------------------------------------------------
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
  <head>
	<title><%=FrameWork.GetDictionary("TEXT_CREATE_NEW_CALENDAR")%></title>
	<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET1")%>">
  	<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET2")%>">
  	<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET3")%>">
	
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
            SubmitForm('OK','<%=intCalID%>');
          }
        
      }
          
      function SubmitForm(istrAction, intCalID)
      {
        document.main.FormAction.value = istrAction;
				document.main.CalendarID.value = intCalID;
        document.main.submit();
      }
    </SCRIPT>

  </head>
  <body onBlur="javascript:LostFocus();" onFocus="javascript:GotFocus('window');" onLoad="javascript:SizeWindow();">
  <FORM ACTION="gotoCalendarNewEdit.asp" METHOD="POST" NAME="main" onFocus="javascript:InAForm(main);" onBlur="javascript:OutOfForm();">
  <INPUT TYPE="Hidden" NAME="FormAction" VALUE="">
	<INPUT TYPE="Hidden" NAME="CalendarID" VALUE="">
	
  <table width="100%">
  <tr>
	<% call WriteError(mstrErrors) %>
  <% call Draw_Title(FrameWork.GetDictionary("TEXT_CALENDAR_PROPERTIES")) %>
  </tr>
  </table>
  <BR>
  <table width="100%">
  <tr>
  	<td>&nbsp;</td>
  </tr>
  <tr>
  	<td class="CaptionEWRequired" nowrap>
		<%= FrameWork.GetDictionary("TEXT_CALENDAR_NAME") & ":" %>
	</td>
	<td align="left" nowrap>
		<input type="text" class="clsInputBox" name="CalendarName" value="<%=SafeForHtmlAttr(strCalName)%>"size="40">
	</td>
  </tr>
  <tr>
  	<td>&nbsp;</td>
	<td>&nbsp;</td>
  </tr>
  <tr>
  	<td class="CaptionEW" style="vertical-align: top;" nowrap>
		<%= FrameWork.GetDictionary("TEXT_CALENDAR_DESCRIPTION") & ":" %>
	</td>
	<td align="left" nowrap>
		<textarea class="TEXTAREA.required" cols="40" rows="4" name="CalendarDescription" size="30"><%=SafeForHtml(strCalDesc)%></textarea>
	</td>
	
  </tr>
  </table>
  <br>
  <table width="100%">
  <tr>		 
    <td align="center" NOWRAP>
	  	<input type="button" class="clsButtonSmall" name="OK" value="<%=FrameWork.GetDictionary("TEXT_MPTE_OK_BTN")%>" onClick="javascript:SubmitForm('OK','<%=intCalID%>');">
	  	<input type="button" class="clsButtonSmall" name="cancel" value="<%=FrameWork.GetDictionary("TEXT_MPTE_CANCEL_BTN")%>" onClick="javascript:window.close();">
    </td>
  </tr>
  </table>
  </FORM>
  </body>
</html>

<% 
On Error Goto 0
%>