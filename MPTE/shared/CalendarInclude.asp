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
' // $Author: Fabricio Pettena$
' // $Revision: 1$
' //==========================================================================


'----------------------------------------------------------------------------
'
'DESCRIPTION: Library of functions related to Calendar manipulation
'
'ASSUMPTIONS: 
'
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
' CREATEFILE - Creates the corresponding file after the new calendar 
' has been created
' Needs the calendar to be created!!!
'----------------------------------------------------------------------------
FUNCTION CreateFile(fname)
	Dim fso, filename, path, templatefile, metratech_config
	Set metratech_config = Server.CreateObject("Metratech.RCD")
	path = metratech_config.ConfigDir & FrameWork.GetDictionary("CALENDAR_DIR")
	Set fso = Server.CreateObject("Scripting.FileSystemObject")
	templatefile = path & "\calendar_template.xml"
	filename = path & "\" & fname '" 'This line is ok. The '" is added just so Homesite doesn't get confused
	call fso.copyfile(templatefile, filename, true)
	CreateFile = TRUE
END FUNCTION

'----------------------------------------------------------------------------
' ADDRULE - Adds a rule to the rateschedule with the calendar_id action as
' the given CalendarID parameter
' Used when the rateschedule has no Calendar associated with it.
'----------------------------------------------------------------------------
FUNCTION AddRule(RateSched, CalendarID)
	dim newrule, tmpActionSet, tmpAction
	
	' Create Objects
	set newrule = Server.CreateObject("MTRule.MTRule.1")
	set tmpActionSet = Server.CreateObject("MTActionSet.MTActionSet.1")	
	set tmpConditionSet = Server.CreateObject("MTConditionSet.MTConditionSet.1")
	set tmpCondition = Server.CreateObject("MTSimpleCondition.MTSimpleCondition.1")	
	set tmpAction = Server.CreateObject("MTAssignmentAction.MTAssignmentAction.1")
	
	'// Theoretically we should read these from the parameter table metadata, and
	'// make this code more general. Since this is a custom screen, we will make
	'// this code specific to the calendar parameter table.
	tmpAction.PropertyName = "calendar_id"
	tmpAction.PropertyType = PROP_TYPE_INTEGER ' This constant is defined in Helpers.asp
	tmpAction.PropertyValue = CalendarID
	tmpActionSet.Add(tmpAction)
		
	' Add the rule to the Ruleset inside the current rateschedule
	RateSched.Ruleset.DefaultActions = tmpActionSet
	AddRule = TRUE
END FUNCTION

%>