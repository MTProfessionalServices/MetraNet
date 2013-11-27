
<%

' //==========================================================================
' // @doc $Workfile: CalendarInclude.asp
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
' COMMON CONSTANTS
'----------------------------------------------------------------------------

const CALENDARDAY_SUNDAY 					= 0
const CALENDARDAY_MONDAY 					= 1
const CALENDARDAY_TUESDAY 				= 2
const CALENDARDAY_WEDNESDAY 			= 3
const CALENDARDAY_THURSDAY 				= 4
const CALENDARDAY_FRIDAY 					= 5
const CALENDARDAY_SATURDAY 				= 6
const CALENDARDAY_DEFAULTWEEKDAY  = 7
const CALENDARDAY_DEFAULTWEEKEND 	= 8 

dim DISPLAYTIMEINAMPMFORMAT


FUNCTION GetDisplayTimeInAMPMFormat()

  if IsEmpty(DISPLAYTIMEINAMPMFORMAT) then
    if lcase(FrameWork.GetDictionary("MDM_USE_24HOUR_CLOCK"))="true" then
      DISPLAYTIMEINAMPMFORMAT = false
    else
      DISPLAYTIMEINAMPMFORMAT = true
    end if
  end if
  
  GetDisplayTimeInAMPMFormat = DISPLAYTIMEINAMPMFORMAT

END FUNCTION


'----------------------------------------------------------------------------
'   Name: Draw_Header
'   Description:  Draws a Header in the default style
'               
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
FUNCTION Draw_Header(strSourceHdr, colspan, clsClass)
	Dim strTitle, strHdr
	strHdr = strSourceHdr
    strTitle = strTitle & 		"<td colspan=" & colspan & " Class='" & clsClass & "' nowrap>"
    strTitle = strTitle & 			strHdr
	strTitle = strTitle & 		"</td>"
	Response.Write (strTitle)					
END FUNCTION

'----------------------------------------------------------------------------
'   Name: GetDateWarning
'   Description: Outputs string telling the user that she might be editing
'								 rates with effective dates that are current or in the past.
'               
'   Parameters: EffectiveDate obj from the RateSchedule
'   Return Value: none
'-----------------------------------------------------------------------------
FUNCTION GetDateWarning(effDateObj)
	Dim strHTML
	strHTML = ""
		
	if effDateObj.StartDateType = PCDATE_TYPE_ABSOLUTE  or effDateObj.StartDateType = PCDATE_TYPE_BILLCYCLE then
		if CLng(CDate(effDateObj.StartDate)) < Clng(Now()) then
			strHTML	= FrameWork.GetDictionary("TEXT_MPTE_WARNING_EDIT_PAST_RATES")
		end if
	elseif effDateObj.EndDateType = PCDATE_TYPE_ABSOLUTE or effDateObj.EndDateType = PCDATE_TYPE_BILLCYCLE then
		if CLng(CDate(effDateObj.EndDate)) < Clng(Now()) then
			strHTML	= FrameWork.GetDictionary("TEXT_MPTE_WARNING_EDIT_PAST_RATES")
		end if
	end if
	GetDateWarning = strHTML
END FUNCTION

'---------------------------------------------------------------------
' FUNCTION: LoadQueryString
'
' Now we will check for the existence of some entries on the querystring
' and if they exist, it means we should overwrite the session variable
' that holds that value. Otherwise, we simply use the stored value,
' meaning that the page has been reloaded but we should use the
' same objects as before
'---------------------------------------------------------------------
  
FUNCTION LoadQueryString()
  
  ' Determine whether we want to view or edit the rules
  strTMP = Request.QueryString("EditMode")
  if Len(strTMP) > 0 then
  	session("RATES_EDITMODE") = strTMP
  end if
  
  'Determine whether we are in pricelist mode or product offering mode
  strTMP = Request.QueryString("POBased")
  if Len(strTMP) > 0 then
  	session("RATES_POBASED") = strTMP
  end if
  
  ' Add selected RateSchedule to the dictionary
  strTMP = Request.QueryString("ID")
  if Len(strTMP) > 0 then
  	session("RATES_RATESCHEDULE_ID") = strTMP
  end if
  
  ' Check whether we want to override the previous variable
  strTMP = Request.QueryString("RS_ID")
  if Len(strTMP) > 0 then
  	session("RATES_RATESCHEDULE_ID") = strTMP
  end if
  
  ' Check whether we want to override the previous variable
  strTMP = Request.QueryString("PT_ID")
  if Len(strTMP) > 0 then
  	session("RATES_PARAMTABLE_ID") = strTMP
  end if
	
  ' Check whether we are accessing this screen via the manage calendars option
  strTMP = Request.QueryString("Manage")
  if Len(strTMP) > 0 then
  	session("manageCalendars") = CBool(strTMP)
  end if
	
END FUNCTION

'----------------------------------------------------------------------------
'   Name: DrawTitle
'   Description:  Draws the title string of the RateSchedule
'               
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------

FUNCTION DisplaySimpleTitle(Caption, cssClass)	
	Dim strTitle
	strTitle = 			  "<table border=""0"" cellpadding=""1"" cellspacing=""0"" width=""100%"">"
	strTitle = strTitle & 	"<tr>"
    strTitle = strTitle & 		"<td Class='" & cssClass & "' nowrap>"
    strTitle = strTitle & 			Caption  
	strTitle = strTitle & 		"</td>"
	strTitle = strTitle & 	"</tr>"
	strTitle = strTitle & "</table>"
	Response.Write (strTitle)
	DisplayTitle = TRUE					
END FUNCTION

'----------------------------------------------------------------------------
'   Name: DisplayTitle
'   Description:  Draws the title string of the RateSchedule. I placed this function
' 
'               
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------

FUNCTION DisplayTitle(Caption, cssClass, RateSched, boolIsGMT)
	
	'TODO: ASSIGN THESE TO CONSTANTS AND LOCALIZE
	
	Dim objTools, dtStartDate, dtEndDate

	dtStartDate = RateSched.EffectiveDate.StartDate
	dtEndDate   = RateSched.EffectiveDate.EndDate
	
	if not boolIsGMT then ' If we are asked to display the converted time, we will do so here. The RateSchedule is always in GMT!!!
	  set objTools   = Server.CreateObject("MTMSIX.MSIXTools")
		if RateSched.EffectiveDate.StartDateType = PCDATE_TYPE_ABSOLUTE or RateSched.EffectiveDate.StartDateType = PCDATE_TYPE_BILLCYCLE then
	  	dtStartDate 	 = objTools.ConvertFromGMT(RateSched.EffectiveDate.StartDate, session("objMAM").CSR("TimeZoneId"))
		end if
		if RateSched.EffectiveDate.EndDateType = PCDATE_TYPE_ABSOLUTE or RateSched.EffectiveDate.StartDateType = PCDATE_TYPE_BILLCYCLE then
	  	dtEndDate		 	 = objTools.ConvertFromGMT(RateSched.EffectiveDate.EndDate, session("objMAM").CSR("TimeZoneId"))
		end if
	else				' else just display GMT
		if RateSched.EffectiveDate.StartDateType = PCDATE_TYPE_ABSOLUTE or RateSched.EffectiveDate.StartDateType = PCDATE_TYPE_BILLCYCLE then
	  	dtStartDate 	 = RateSched.EffectiveDate.StartDate
		end if
		if RateSched.EffectiveDate.EndDateType = PCDATE_TYPE_ABSOLUTE or RateSched.EffectiveDate.StartDateType = PCDATE_TYPE_BILLCYCLE then		
	 		dtEndDate		 	 = RateSched.EffectiveDate.EndDate
		end if
	end if
	
	dim strEffDate
	strEffDate = FrameWork.GetDictionary("TEXT_RATES_START_DATE") & ":"
	
	Select Case RateSched.EffectiveDate.StartDateType
		Case PCDATE_TYPE_NULL
			strEffDate = strEffDate & "&nbsp;" & FrameWork.GetDictionary("TEXT_NULL_START_DATE_TYPE") & "&nbsp;"
		Case PCDATE_TYPE_ABSOLUTE
			strEffDate = strEffDate & FrameWork.GetDictionary("TEXT_ABSOLUTE_DATE_TYPE") & "&nbsp;" & CStr(dtStartDate) 
		Case PCDATE_TYPE_SUBSCRIPTION
			strEffDate = strEffDate & CStr(RateSched.EffectiveDate.StartOffSet) & "&nbsp;" & FrameWork.GetDictionary("TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE")
		Case PCDATE_TYPE_BILLCYCLE
			strEffDate = strEffDate & FrameWork.GetDictionary("TEXT_BILLINGCYCLE_DATE_TYPE") & "&nbsp;" & CStr(dtStartDate)
	End Select
	
	strEffDate = strEffDate & "&nbsp;&nbsp;" & FrameWork.GetDictionary("TEXT_RATES_END_DATE") & ":"
	
	Select Case RateSched.EffectiveDate.EndDateType
		Case PCDATE_TYPE_NULL
			strEffDate = strEffDate & "&nbsp;" & FrameWork.GetDictionary("TEXT_NULL_END_DATE_TYPE") & "&nbsp;"
		Case PCDATE_TYPE_ABSOLUTE
			strEffDate = strEffDate & FrameWork.GetDictionary("TEXT_ABSOLUTE_DATE_TYPE") & "&nbsp;" & CStr(dtEndDate)
		Case PCDATE_TYPE_SUBSCRIPTION
			strEffDate = strEffDate & CStr(RateSched.EffectiveDate.EndOffSet) & "&nbsp;" & FrameWork.GetDictionary("TEXT_SUBSCRIPTIONRELATIVE_DATE_TYPE")
		Case PCDATE_TYPE_BILLCYCLE
			strEffDate = strEffDate & FrameWork.GetDictionary("TEXT_BILLINGCYCLE_DATE_TYPE") & "&nbsp;" & CStr(dtEndDate)
	End Select
	
	Dim strTitle
	strTitle = 			  "<table border=""0"" cellpadding=""1"" cellspacing=""0"" width=""100%"">"
	strTitle = strTitle & 	"<tr>"
    strTitle = strTitle & 		"<td Class='" & cssClass & "' nowrap>"
    strTitle = strTitle & 			Caption & "   -   " & RateSched.Description & "   -   " & strEffDate & "&nbsp;&nbsp;&nbsp;"  
	strTitle = strTitle & 		"</td>"
	strTitle = strTitle & 	"</tr>"
	strTitle = strTitle & "</table>"
	Response.Write (strTitle)
	DisplayTitle = TRUE					
END FUNCTION


'----------------------------------------------------------------------------
'   Name: AddCustomRulesetRow
'   Description: This function will add a rule to the Rateschedule.
'   It will add a simple rule with one action 
'   and one condition. This is an example of how one would
'   manipulate the ruleset in a custom way.
'               
'   Parameters: objRatesched - RateSchedule to be altered
' 				objParamTable - current ParameterTableDef
'				actionVal - value to be assigned to the action
'				conditionVal - value to be assigned to the condition
'   Return Value: none
'-----------------------------------------------------------------------------

FUNCTION AddCustomRulesetRow(objRatesched, objParamTable, actionVal, conditionVal)
	
	dim newrule, tmpActionSet, tmpConditionSet, tmpCondition, tmpAction, ptable, mobjTRReader, intRuleIndex
	
	' Create Objects
	set newrule = Server.CreateObject("MTRule.MTRule.1")
	set tmpActionSet = Server.CreateObject("MTActionSet.MTActionSet.1")	
	set tmpConditionSet = Server.CreateObject("MTConditionSet.MTConditionSet.1")
	set tmpCondition = Server.CreateObject("MTSimpleCondition.MTSimpleCondition.1")	
	set tmpAction = Server.CreateObject("MTAssignmentAction.MTAssignmentAction.1")
	set mobjTRReader = Server.CreateObject("MTTabRulesetReader.RulesetHandler")
	
	call mobjTRReader.InitializeFromProdCat(objParamTable.ID)
	
	' We are always interested in the first action and condition.
	' Therefore, all the indexes are 1.
	
	intRuleIndex = 1
	
	tmpAction.PropertyName = mobjTRReader.ActionDatas(intRuleIndex).PropertyName
	if CLng(mobjTRReader.ActionDatas(intRuleIndex).PType) = PROP_TYPE_ENUM then
		tmpAction.EnumSpace	   = mobjTRReader.ActionDatas(intRuleIndex).EnumSpace
		tmpAction.EnumType 	   = mobjTRReader.ActionDatas(intRuleIndex).EnumType
	end if
	tmpAction.PropertyType = mobjTRReader.ActionDatas(intRuleIndex).PType
	call SetRSActionValue(tmpAction, actionVal)
	tmpActionSet.Add(tmpAction)
	
	tmpCondition.PropertyName = mobjTRReader.ConditionDatas(intRuleIndex).PropertyName
	if CLng(mobjTRReader.ConditionDatas(intRuleIndex).PType) = PROP_TYPE_ENUM then
      tmpCondition.EnumSpace = mobjTRReader.ConditionDatas(intRuleIndex).EnumSpace
      tmpCondition.EnumType = mobjTRReader.ConditionDatas(intRuleIndex).EnumType
    end if
	tmpCondition.ValueType = mobjTRReader.ConditionDatas(intRuleIndex).PType
	call SetRSConditionValue(tmpCondition, conditionVal)
    tmpConditionSet.Add(tmpCondition)
	
	' Set the newly created sets in the rule 
	newrule.Actions = tmpActionSet
	newrule.Conditions = tmpConditionSet
	
	' Add the rule to the Ruleset inside the current rateschedule
	objRateSched.Ruleset.Add(newrule)
	
	AddRulesetRow = TRUE
END FUNCTION

'----------------------------------------------------------------------------
'   Name: CreateActionSet
'   Description: This function will create a ActionSet with default values
'	and return it.
'
'	Parameters  : objParamTable    
'   Return Value: none
'-----------------------------------------------------------------------------
FUNCTION CreateActionSet (objParamTable)
	
	dim tmpActionSet, tmpAction, ptable, mobjTRReader, iAction, ii
	
	set tmpActionSet = Server.CreateObject("MTActionSet.MTActionSet.1")	
	set mobjTRReader = Server.CreateObject("MTTabRulesetReader.RulesetHandler")
	
	call mobjTRReader.InitializeFromProdCat(objParamTable.ID)
	
	ii = 1	
	for each iAction in mobjTRReader.ActionDatas
		set tmpAction = Server.CreateObject("MTAssignmentAction.MTAssignmentAction.1")
		tmpAction.PropertyName = mobjTRReader.ActionDatas(ii).PropertyName
		if CLng(mobjTRReader.ActionDatas(ii).PType) = PROP_TYPE_ENUM then
			tmpAction.EnumSpace	   = mobjTRReader.ActionDatas(ii).EnumSpace
			tmpAction.EnumType 	   = mobjTRReader.ActionDatas(ii).EnumType
		end if
		tmpAction.PropertyType = mobjTRReader.ActionDatas(ii).PType
		' Make sure the default value exists
		call SetRSDefaultActionValue(tmpAction, mobjTRReader.ActionDatas(ii).DefaultValue)
		tmpActionSet.Add(tmpAction)
		ii = ii + 1
    next
		
	' Add the rule to the Ruleset inside the current rateschedule
	
	Set CreateActionSet = tmpActionSet
END FUNCTION

FUNCTION InitializeApprovalsClient()

dim tmpApprovalsClient, tmpSessionContext
set tmpApprovalsClient = CreateObject("MetraTech.Approvals.SimplifiedClient")
set tmpSessionContext = Session(FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME)
set tmpApprovalsClient.SessionContext = tmpSessionContext
set InitializeApprovalsClient = tmpApprovalsClient
END FUNCTION

'----------------------------------------------------------------------------
'   Name: GetAMPMTimeString
'   Description: Create an AM/PM time string based on the number of elapsed
'		seconds from the beginning of the day
'
'		Parameters  : intNumSecs - unmber of seconds from the beginning of the day
'   Return Value: string with the am/pm time format
'-----------------------------------------------------------------------------
FUNCTION GetAMPMTimeString (intNumSecs)
	dim tmpStr
	dim intHours, intMinutes, intSeconds
	dim strHours, strMinutes, strSeconds, strAMorPM
	
	intHours = Int(intNumSecs/3600)
	intMinutes = Int((intNumSecs - intHours*3600)/60)
	intSeconds = Int(intNumSecs - intHours*3600 - intMinutes*60)
	
	if intHours = 0 or intHours = 24 then
		strHours = "12"
		strAMorPM = "AM"
	elseif intHours > 12 then
		strHours = CStr(intHours - 12)
		strAMorPM = "PM"
	elseif intHours <> 12 then
		strHours = CStr(intHours)
		strAMorPM = "AM"
	else
		strHours = CStr(intHours)
		strAMorPM = "PM"	
	end if
	strMinutes = CStr(intMinutes)
	strSeconds = CStr(intSeconds)
	if len(strMinutes) = 1 then
		tmpStr = strMinutes
		strMinutes = "0" & tmpStr
	end if		
	if len(strSeconds) = 1 then
		tmpStr = strSeconds
		strSeconds = "0" & tmpStr
	end if		
	
	GetAMPMTimeString = strHours & ":" & strMinutes & ":" & strSeconds & "&nbsp;" & strAMorPM
END FUNCTION

'----------------------------------------------------------------------------
'   Name: FormatTimeString
'   Description: Create an AM/PM time string or 24hour clock time string based on the number of elapsed
'		seconds from the beginning of the day
'
'		Parameters  : intNumSecs - number of seconds from the beginning of the day
'   Return Value: string with the time format
'-----------------------------------------------------------------------------
FUNCTION FormatTimeString (intNumSecs)
	dim tmpStr
	dim intHours, intMinutes, intSeconds
	dim strHours, strMinutes, strSeconds, strAMorPM
	
	intHours = Int(intNumSecs/3600)
	intMinutes = Int((intNumSecs - intHours*3600)/60)
	intSeconds = Int(intNumSecs - intHours*3600 - intMinutes*60)
  
  strHours = CStr(intHours)
	strMinutes = CStr(intMinutes)
	strSeconds = CStr(intSeconds)	
  
  if GetDisplayTimeInAMPMFormat() then
  	if intHours = 0 or intHours = 24 then
  		strHours = "12"
  		strAMorPM = "AM"
  	elseif intHours > 12 then
  		strHours = CStr(intHours - 12)
  		strAMorPM = "PM"
  	elseif intHours <> 12 then
  		strHours = CStr(intHours)
  		strAMorPM = "AM"
  	else
  		strHours = CStr(intHours)
  		strAMorPM = "PM"	
  	end if
  end if

	if len(strMinutes) = 1 then
		tmpStr = strMinutes
		strMinutes = "0" & tmpStr
	end if		
	if len(strSeconds) = 1 then
		tmpStr = strSeconds
		strSeconds = "0" & tmpStr
	end if		
	
  if GetDisplayTimeInAMPMFormat() then
    FormatTimeString = strHours & ":" & strMinutes & ":" & strSeconds & "&nbsp;" & strAMorPM
  else
	  FormatTimeString = strHours & ":" & strMinutes & ":" & strSeconds
  end if
END FUNCTION

%>
