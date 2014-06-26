<%
' //==========================================================================
' // @doc $Workfile: D:\source\development\UI\MTAdmin\us\checkIn.asp$
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
' // Created by: Noah Cushing
' //
' // $Date: 5/11/00 11:51:14 AM$
' // $Author: Noah Cushing$
' // $Revision: 6$
' //==========================================================================

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  WizardInclude.asp                                                        '
'  Functions for the dynamic wizard that are specific to rendering screens. '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
  <!-- #INCLUDE FILE="../../../../mcmIncludes.asp" -->
	<!-- #INCLUDE FILE="../FormsClass.asp" -->
  <!-- #INCLUDE FILE="../GridClass.asp" -->
  <!-- #INCLUDE FILE="../Styles.asp"-->

  <!-- #////INCLUDE VIRTUAL="/mdm/Common/Widgets/Calendar/Calendar.header.htm" -->
  <!-- #INCLUDE VIRTUAL="/mdm/Common/Widgets/Calendar/Calendar.footer.htm" -->
  
  
<%

'// This code is to replace the include of Calendar.header.htm from above
'// We need to process the file using the dictionary object before outputting it in the response.
Dim objTextFile, strHTMLP
Set objTextFile = mdm_CreateObject(CTextFile)

strHTMLP = objTextFile.LoadFile(server.mappath("/mdm/Common/Widgets/Calendar/Calendar.header.htm"))
strHTMLP = FrameWork.Dictionary.PreProcess(strHTMLP)
Response.write strHTMLP

'  <!-- #INCLUDE FILE="Styles.asp"-->
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Global Variables                                                         '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
FUNCTION ValidateDescription(strWizardName)
  dim bValid
  bValid = true	 ' We don't care about what they put in the description right , but we might in the future
	ValidateDescription = bValid
End Function

FUNCTION ValidateEffectiveDates(strWizardName)
  dim bStartValid, bEndValid, istartdate_pick, ienddate_pick

  bStartValid = false ' By default, this dialog fails
	bEndValid		= false
	
	istartdate_pick = session(strWizardName & "_startdate_pick")
	ienddate_pick 	= session(strWizardName & "_enddate_pick")
	
	set session(strWizardName & "__ErrorMessage") = CreateObject("Scripting.Dictionary")
  session(strWizardName & "__ErrorMessage").Add "X",FrameWork.GetDictionary("ERROR_WIZARD_NOTIFICATION")
	
	Select Case istartdate_pick
		Case "NULL"
			'No rules here... for ...
			bStartValid = true
		Case "ABS"
			if mcm_IsDate(session(strWizardName & "_abs_startdate_tf")) then
      
				if CDate(session(strWizardName & "_abs_startdate_tf")) > FrameWork.MetraTimeGMTNow then 
					bStartValid = true
				else
					if not UCase(session(strWizardName & "_CommitPastStartDate")) = "TRUE" then
						session(strWizardName & "__ErrorMessage").Add "StartDate", FrameWork.GetDictionary("MCM_ERROR_STARTDATE_IN_PAST")
						session(strWizardName & "_CommitPastStartDate") = "TRUE"
					else
						session(strWizardName & "_CommitPastStartDate") = "FALSE"
						bStartValid = true
					end if
				end if
			else
				session(strWizardName & "__ErrorMessage").Add "StartDate", FrameWork.GetDictionary("MCM_ERROR_STARTDATE_INVALID") 
			end if
		Case "SUBS"
			if IsNumeric(session(strWizardName & "_subs_startdate_tf")) then
				bStartValid = true
			else
				session(strWizardName & "__ErrorMessage").Add "StartDate", FrameWork.GetDictionary("MCM_ERROR_STARTDATE_INVALID") 
			end if
		Case "BILL"
			if mcm_IsDate(session(strWizardName & "_bill_startdate_tf")) then
				if CDate(session(strWizardName & "_bill_startdate_tf")) > FrameWork.MetraTimeGMTNow then 
					bStartValid = true
				else
					if not UCase(session(strWizardName & "_CommitPastStartDate")) = "TRUE" then
						session(strWizardName & "__ErrorMessage").Add "StartDate", FrameWork.GetDictionary("MCM_ERROR_STARTDATE_IN_PAST")
						session(strWizardName & "_CommitPastStartDate") = "TRUE"
					else
						bStartValid = true
					end if
				end if
			else
				session(strWizardName & "__ErrorMessage").Add "StartDate", FrameWork.GetDictionary("MCM_ERROR_STARTDATE_INVALID") 
			end if
	End Select	

	Select Case ienddate_pick
		Case "NULL"
			'No rules here... for ...
			bEndValid = true
		Case "ABS"
    
      session(strWizardName & "_abs_enddate_tf") = mcm_SetTimeToDefaultEndDateTimeIfTimeNotSet(session(strWizardName & "_abs_enddate_tf"))
      
			if mcm_IsDate(session(strWizardName & "_abs_enddate_tf")) then
				if CDate(session(strWizardName & "_abs_enddate_tf")) > FrameWork.MetraTimeGMTNow then 
					bEndValid = true
					if bStartValid and (istartdate_pick = "ABS" or istartdate_pick = "BILL") then
						if CDate(session(strWizardName & "_" & istartdate_pick & "_startdate_tf")) > CDate(session(strWizardName & "_abs_enddate_tf")) then
							bEndValid = false
							session(strWizardName & "__ErrorMessage").Add "StartDate", FrameWork.GetDictionary("MCM_ERROR_START_AFTER_END") 
						end if
					end if
				else
					if not UCase(session(strWizardName & "_CommitPastEndDate")) = "TRUE" then
						session(strWizardName & "__ErrorMessage").Add "EndDate", FrameWork.GetDictionary("MCM_ERROR_ENDDATE_IN_PAST")
						session(strWizardName & "_CommitPastEndDate") = "TRUE"
					else
						bEndValid = true
					end if
				end if
			else
				session(strWizardName & "__ErrorMessage").Add "EndDate", FrameWork.GetDictionary("MCM_ERROR_ENDDATE_INVALID") 
			end if
		Case "SUBS"
			if IsNumeric(session(strWizardName & "_subs_enddate_tf")) then
				bEndValid = true
			else
				session(strWizardName & "__ErrorMessage").Add "EndDate", FrameWork.GetDictionary("MCM_ERROR_ENDDATE_INVALID") 
			end if
		Case "BILL"
			if mcm_IsDate(session(strWizardName & "_bill_enddate_tf")) then
				if CDate(session(strWizardName & "_bill_enddate_tf")) > FrameWork.MetraTimeGMTNow then 
					bEndValid = true
					if bStartValid and istartdate_pick = "BILL" then
						if CDate(session(strWizardName & "_" & istartdate_pick & "_startdate_tf")) > CDate(session(strWizardName & "_bill_enddate_tf")) then
							bEndValid = false
							session(strWizardName & "__ErrorMessage").Add "StartDate", FrameWork.GetDictionary("MCM_ERROR_START_AFTER_END") 
						end if
					end if
				else
					if not UCase(session(strWizardName & "_CommitPastEndDate")) = "TRUE" then
						session(strWizardName & "__ErrorMessage").Add "EndDate", FrameWork.GetDictionary("MCM_ERROR_ENDDATE_IN_PAST")
					else
						bEndValid = true
					end if
				end if
			else
				session(strWizardName & "__ErrorMessage").Add "EndDate", FrameWork.GetDictionary("MCM_ERROR_ENDDATE_INVALID") 
			end if
	End Select
	
	ValidateEffectiveDates = bStartValid and bEndValid
End Function

Function gobjMTFormsAddInputHint(strInput)
	gobjMTFormsAddInputHint = "<tr><td colspan=""2"" align=""center"" class=""clsWizardPrompt""><b>" & strInput & "</b></td></tr>"
End FUNCTION

FUNCTION WriteChecked(selDateType, currentRadioBtn)
	if selDateType = currentRadioBtn then
		WriteChecked = " checked " ' We need spaces to avoid typos
	else
		WriteChecked = ""
	end if
END FUNCTION

FUNCTION WriteDisabled(selDateType, currentRadioBtn)
	if not selDateType = "SUBS" then
		if currentRadioBtn = "SUBS" then
			WriteDisabled = " disabled " ' We need spaces to avoid typos
		else
			WriteDisabled = ""
		end if
	else
		if currentRadioBtn = "SUBS" then
			WriteDisabled = "" ' We need spaces to avoid typos
		else
			WriteDisabled = " disabled "
		end if
	end if
END FUNCTION 

'// This function is used to populate (or not) the textfields if the user clicks on "Previous" and comes back to the eff. dates screen
'// We will simply make the value of the textfield have the value stored in the session. 
'// We build the string on the fly, like in session(WizardName_abs_startdate_tf) for example.
FUNCTION WriteValue(selDateType, currentTextField, strStartOrEnd, strWizardName)
	
	if selDateType = currentTextField then
		writeValue = session(strWizardName & "_" & LCase(selDateType) & "_" & strStartOrEnd & "date_tf")
	else
		WriteValue = ""
	end if
END FUNCTION 

FUNCTION WriteEffectiveDates(strWizardName) 'PLug this in
	dim strHTML, inputClass, inputRadioClass, promptClass, istart_checked, iend_checked
	
	inputRadioClass = gobjMTForms.RadioClass
	inputClass 			= gobjMTForms.InputClass
	promptClass 		= gobjMTForms.PromptClass
	
	'// We will check these to make sure that, if the user comes back to this wizard screen,
	'// He will see the configuration he had before 
	istart_checked = session(strWizardName & "_startdate_pick")
	iend_checked 	 = session(strWizardName & "_enddate_pick")
	
	'// Now 
	if istart_checked = "" then
		istart_checked = "NULL"
	end if

	if iend_checked = "" then
		iend_checked = "NULL"
	end if
	
	'// Start date display
	
	strHTML = ""
	strHTML = strHTML & "<TABLE class=" & gobjMTForms.TableBodyClass & " width=""100%"">"  & vbNewLine
	strHTML = strHTML &	"	</TR>"  & vbNewLine
	strHTML = strHTML & "		<TD colspan=""2"" align=""center"" class=" & promptClass & ">"  & vbNewLine
	strHTML = strHTML &				FrameWork.GetDictionary("TEXT_RATES_WIZARD_STARTDATE_TITLE") & vbNewLine
	strHTML = strHTML & "		</TD>"  & vbNewLine
	strHTML = strHTML & "	</TR>"  & vbNewLine

	strHTML = strHTML & " <TR>"  & vbNewLine
	strHTML = strHTML & " 	<TD width=""0"">"  & vbNewLine
	strHTML = strHTML &	"			<INPUT type=""radio"" onclick=""javascript:ConfigureDate(4);"" class=""" & inputRadioClass & """ value=""NULL"" name=""" & strWizardName & "_startdate_pick""" & writeChecked(istart_checked, "NULL") & ">"  & vbNewLine
	strHTML = strHTML & 			FrameWork.GetDictionary("TEXT_NULL_START_DATE_TYPE") & vbNewLine
	strHTML = strHTML &	"		</TD>"  & vbNewLine
	strHTML = strHTML & " </TR>" & vbNewLine
	
	strHTML = strHTML & "	<TR>" & vbNewLine
	strHTML = strHTML & " 	<TD width=""0"">"  & vbNewLine
	strHTML = strHTML &	"			<INPUT type=""radio"" onclick=""javascript:ConfigureDate(1);"" class=""" & inputRadioClass & """ value=""ABS"" name=""" & strWizardName & "_startdate_pick""" & writeChecked(istart_checked, "ABS") & ">"  & vbNewLine
	strHTML = strHTML &				FrameWork.GetDictionary("TEXT_ABSOLUTE_DATE_TYPE") & vbNewLine
	strHTML = strHTML &	"			<INPUT type=""text"" class=" & inputClass & " name=""" & strWizardName & "_abs_startdate_tf"" value=""" & writeValue (istart_checked, "ABS", "start", strWizardName) & """ size=""22"" maxlength=""22"">"  & vbNewLine
	strHTML = strHTML &	"			<A HREF=""#"" onClick=""getCalendarForStartDate(document.WizardForm." & strWizardName & "_abs_startdate_tf);return false"">"  & vbNewLine
	strHTML = strHTML &	"				<img src='../../../localized/en-us/images/popupcalendar.gif' width=16 height=16 border=0 alt=''>" & vbNewLine
	strHTML = strHTML &	"			</A>" & vbNewLine
	strHTML = strHTML & " 	</TD>" & vbNewLine
	strHTML = strHTML & " </TR>" & vbNewLine

	strHTML = strHTML & " <TR>"  & vbNewLine
	strHTML = strHTML & " 	<TD width=""0"">"  & vbNewLine
	strHTML = strHTML &	"			<INPUT type=""radio"" onclick=""javascript:ConfigureDate(2);"" class=" & inputRadioClass & " value=""SUBS"" name=""" & strWizardName & "_startdate_pick""" & writeChecked(istart_checked, "SUBS") & ">" & vbNewLine
	strHTML = strHTML &	"			<INPUT type=""text"" class=" & inputClass & " name=""" & strWizardName & "_subs_startdate_tf"" value=""" & writeValue (istart_checked, "SUBS", "start", strWizardName) & """ size=""3"">" & vbNewLine
	strHTML = strHTML &				FrameWork.GetDictionary("TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE") & vbNewLine
	strHTML = strHTML &	"		</TD>" & vbNewLine
	strHTML = strHTML & " </TR>" & vbNewLine

	strHTML = strHTML & "	<TR>" & vbNewLine
	strHTML = strHTML & " 	<TD width=""0"">"  & vbNewLine
	strHTML = strHTML & "			<INPUT type=""radio"" onclick=""javascript:ConfigureDate(3);"" class=" & inputRadioClass & " value=""BILL"" name=""" & strWizardName & "_startdate_pick""" & writeChecked(istart_checked, "BILL") & ">" & vbNewLine
	strHTML = strHTML &	"			Next billing cycle after" & vbNewLine
	strHTML = strHTML & "  		<INPUT type=""text"" class=" & inputClass & " name=""" & strWizardName & "_bill_startdate_tf"" value=""" & writeValue (istart_checked, "BILL", "start", strWizardName) & """ size=""22"" maxlength=""22"">" & vbNewLine
	strHTML = strHTML & "			<A HREF=""#"" onClick=""getCalendarForStartDate(document.WizardForm." & strWizardName & "_bill_startdate_tf);return false"">" & vbNewLine
	strHTML = strHTML &	"				<img src='../../../localized/en-us/images/popupcalendar.gif' width=16 height=16 border=0 alt=''>" & vbNewLine
	strHTML = strHTML &	"			</A>" & vbNewLine
	strHTML = strHTML & "		</TD>" & vbNewLine
	strHTML = strHTML & "	</TR>" & vbNewLine
	
	strHTML = strHTML & "	<TR><TD>&nbsp;</td></tr>" & vbNewLine
	
	'// End date display
	
	strHTML = strHTML &	"	</TR>"  & vbNewLine
	strHTML = strHTML & "		<TD colspan=""2"" align=""center"" class=" & promptClass & ">"  & vbNewLine
	strHTML = strHTML &				FrameWork.GetDictionary("TEXT_RATES_WIZARD_ENDDATE_TITLE") & vbNewLine
	strHTML = strHTML & "		</TD>"  & vbNewLine
	strHTML = strHTML & "	</TR>"  & vbNewLine

	strHTML = strHTML & " <TR>"  & vbNewLine
	strHTML = strHTML & " 	<TD width=""0"">"  & vbNewLine
	strHTML = strHTML &	"			<INPUT type=""radio"" class=" & inputRadioClass & " value=""NULL"" name=""" & strWizardName & "_enddate_pick""" & writeChecked(iend_checked, "NULL") & " " & writeDisabled(iend_checked, "NULL") & ">"  & vbNewLine
	strHTML = strHTML &				FrameWork.GetDictionary("TEXT_NULL_END_DATE_TYPE") & vbNewLine
	strHTML = strHTML &	"		</TD>"  & vbNewLine
	strHTML = strHTML & " </TR>" & vbNewLine
	
	strHTML = strHTML & "	<TR>" & vbNewLine
	strHTML = strHTML & " 	<TD width=""0"">"  & vbNewLine
	strHTML = strHTML &	"			<INPUT type=""radio"" class=" & inputRadioClass & " value=""ABS"" name=""" & strWizardName & "_enddate_pick""" & writeChecked(iend_checked, "ABS") & " " & writeDisabled(iend_checked, "ABS") & ">"  & vbNewLine
	strHTML = strHTML &				FrameWork.GetDictionary("TEXT_ABSOLUTE_DATE_TYPE") & vbNewLine
	strHTML = strHTML &	"			<INPUT type=""text"" class=" & inputClass & " name=""" & strWizardName & "_abs_enddate_tf"" value=""" & writeValue (iend_checked, "ABS", "end", strWizardName) & """ size=""22"" maxlength=""22"" " & writeDisabled(iend_checked, "ABS") & ">"  & vbNewLine
	strHTML = strHTML &	"			<A HREF=""#"" onClick=""setEndDateTimeAndShowCalendar(document.WizardForm." & strWizardName & "_abs_enddate_tf);return false"">"  & vbNewLine
	strHTML = strHTML &	"				<img src='../../../localized/en-us/images/popupcalendar.gif' width=16 height=16 border=0 alt=''>" & vbNewLine
	strHTML = strHTML &	"			</A>" & vbNewLine
	strHTML = strHTML & " 	</TD>" & vbNewLine
	strHTML = strHTML & " </TR>" & vbNewLine

	strHTML = strHTML & " <TR>"  & vbNewLine
	strHTML = strHTML & " 	<TD width=""0"">"  & vbNewLine
	strHTML = strHTML &	"			<INPUT type=""radio"" class=" & inputRadioClass & " value=""SUBS"" name=""" & strWizardName & "_enddate_pick""" & writeChecked(iend_checked, "SUBS") & " " & writeDisabled(iend_checked, "SUBS") & ">" & vbNewLine
	strHTML = strHTML &	"			<INPUT type=""text"" class=" & inputClass & " name=""" & strWizardName & "_subs_enddate_tf"" value=""" & writeValue (iend_checked, "SUBS", "end", strWizardName) & """  size=""3"" " & writeDisabled(iend_checked, "SUBS") & ">" & vbNewLine
	strHTML = strHTML &				FrameWork.GetDictionary("TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE") & vbNewLine
	strHTML = strHTML &	"		</TD>" & vbNewLine
	strHTML = strHTML & " </TR>" & vbNewLine

	strHTML = strHTML & "	<TR>" & vbNewLine
	strHTML = strHTML & " 	<TD width=""0"">"  & vbNewLine
	strHTML = strHTML & "			<INPUT type=""radio"" class=" & inputRadioClass & " value=""BILL"" name=""" & strWizardName & "_enddate_pick""" & writeChecked(iend_checked, "BILL") & " " & writeDisabled(iend_checked, "BILL") & ">" & vbNewLine
	strHTML = strHTML & 			FrameWork.GetDictionary("TEXT_BILLINGCYCLE_DATE_TYPE")
	strHTML = strHTML & "  		<INPUT type=""text"" class=" & inputClass & " name=""" & strWizardName & "_bill_enddate_tf"" value=""" & writeValue (iend_checked, "BILL", "end", strWizardName) & """ size=""22"" maxlength=""22"" " & " " & writeDisabled(iend_checked, "BILL") & ">" & vbNewLine
	strHTML = strHTML & "			<A HREF=""#"" onClick=""getCalendarForEndDate(document.WizardForm." & strWizardName & "_bill_enddate_tf);return false"">" & vbNewLine
	strHTML = strHTML &	"				<img src='../../../localized/en-us/images/popupcalendar.gif' width=16 height=16 border=0 alt=''>" & vbNewLine
	strHTML = strHTML &	"			</A>" & vbNewLine
	strHTML = strHTML & "		</TD>" & vbNewLine
	strHTML = strHTML & "	</TR>" & vbNewLine
		
	strHTML = strHTML & "</TABLE>" & vbNewLine

	WriteEffectiveDates = strHTML
	
END FUNCTION

FUNCTION WriteEffectiveDatesLeftPane()
	dim strHTML
	
	strHTML = 					"<TABLE>"
	strHTML = strHTML & "	<TR>"
	strHTML = strHTML & " 	<TD colspan=""2"" class=" & gobjMTForms.PromptClass & ">"
	strHTML = strHTML &	"<B>"	&	FrameWork.GetDictionary("TEXT_WIZARD_EFFECTIVE_DATE_TIP") & "</B>"
	strHTML = strHTML & "		</TD>"
	strHTML = strHTML & "	</TR>"
	strHTML = strHTML & "<tr><td></td></tr>"
	strHTML = strHTML & "	<TR>"
	strHTML = strHTML & "		<TD>"
	strHTML = strHTML &				FrameWork.GetDictionary("TEXT_WIZARD_EFFECTIVE_DATE_NULL_TIP")
	strHTML = strHTML & "		</TD>"
	strHTML = strHTML & "	</TR>"
	strHTML = strHTML & "</TABLE>"	
	WriteEffectiveDatesLeftPane = strHTML
END FUNCTION

FUNCTION WriteDescriptionPage(strWizardName)
	dim strHTML, inputClass, promptClass
	
	inputClass 			= gobjMTForms.InputClass
	promptClass 		= gobjMTForms.PromptClass
	strHTML = "<BR>"
	strHTML = strHTML & "<TABLE class=" & gobjMTForms.TableBodyClass & " width=""100%"">" & vbNewLine
	strHTML = strHTML & " <TR>" & vbNewLine
	strHTML = strHTML & " 	<TD colspan=""2"" align=""center"" class=" & promptClass & ">" & vbNewLine
	strHTML = strHTML &			FrameWork.GetDictionary("TEXT_RATES_WIZARD_DESCRIPTION_TITLE") & vbNewLine
	strHTML = strHTML & "		</TD>" & vbNewLine
	strHTML = strHTML & "	</TR>" & vbNewLine
	strHTML = strHTML & "	<TR><TD>&nbsp;</TD></TR>" & vbNewLine
	strHTML = strHTML & "	<TR>" & vbNewLine
	strHTML = strHTML & "		<TD align=""right"" valign=""top"">" & vbNewLine
	strHTML = strHTML & 		FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION") & vbNewLine
	strHTML = strHTML & "		</TD>" & vbNewLine
	strHTML = strHTML & "		<TD align=""left"" valign=""top"">" & vbNewLine
	strHTML = strHTML & "			<textarea class=" & inputClass & " cols=""35"" rows=""4"" name=""" & strWizardName & "_rs_comment"" size=""40"">" & SafeForHtmlAttr(session(strWizardName & "_rs_comment")) & "</textarea>" & vbNewLine
	strHTML = strHTML & "		</TD>" & vbNewLine
	strHTML = strHTML & "	</TR>" & vbNewLine
	strHTML = strHTML & "</TABLE>" & vbNewLine
	
	WriteDescriptionPage = strHTML
END FUNCTION

FUNCTION WriteDescriptionLeftPane()
	
	dim strHTML 
	strHTML = "<BR><B>"
	strHTML = strHTML & FrameWork.GetDictionary("TEXT_WIZARD_DESCRIPTION_TIP")
	strHTML = strHTML & "</B>"
	WriteDescriptionLeftPane = strHTML
END FUNCTION


%>
