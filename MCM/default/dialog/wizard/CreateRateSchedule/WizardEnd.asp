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

Option Explicit
response.expires = 0

%>
  <!-- #INCLUDE FILE="../../../lib/WizardClass.asp" -->
  <!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
  <!-- #INCLUDE VIRTUAL="/mdm/mdmLibrary.asp" -->
  <!-- #INCLUDE VIRTUAL="/mcm/default/lib/ProductCatalog/MTProductCatalog.Library.asp"-->
  
<%

'const PCDATE_TYPE_ABSOLUTE		= 1
'const PCDATE_TYPE_SUBSCRIPTION	= 2
'const PCDATE_TYPE_BILLCYCLE		= 3
'const PCDATE_TYPE_NULL			= 4

Dim strWizardName
strWizardName = gobjMTWizard.Name

Dim objProdCat		     ' As MTProductCatalog
Dim objProdOff		     ' As MTProductOffering
Dim objPriceableItem     ' As MTPriceableItem
Dim objPricelist         ' As MTPriceList
Dim objParamTable		 ' As MTParamTableDefinition
Dim objPricelistMapping  ' As MTPricelistMapping
Dim objNewRateSchedule   ' As MTRateSchedule
Dim RuleEditorURL		 ' As String

Dim pi_id, pt_id, pl_id ' Temp vars to make the code more readable

On Error Resume Next

Set objProdCat = GetProductCatalogObject

'Let's temporarily retrieve the IDs from the session
pi_id = Clng(session("RATES_PRICEABLEITEM_ID"))
pt_id = Clng(session("RATES_PARAMTABLE_ID"))
pl_id = Clng(session("RATES_PRICELIST_ID"))

'We need this object anyway to look up the Editing Screen for this particular parameter table
Set objParamTable = objProdCat.GetParamTableDefinition(pt_id)
if (Err.Number) OR (NOT IsValidObject(objParamTable)) then
  'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
  'Adding HTML Encoding
  'session(strWizardName & "__ErrorMessage") = "Unable to get parameter table definition with id [" & pt_id & "]&nbsp;" & Err.Description
  session(strWizardName & "__ErrorMessage") = "Unable to get parameter table definition with id [" & pt_id & "]&nbsp;" & SafeForHtmlAttr(Err.Description)
  response.redirect("Wizard.asp?Path=/mcm/default/dialog/wizard/CreateRateSchedule&PageID=description&Error=Y")    
End If

if UCase(session("RATES_POBASED")) = "TRUE" then
	Set objPriceableItem = objProdCat.GetPriceableItem(pi_id)
	if (Err.Number) OR (NOT IsValidObject(objPriceableItem)) then
    'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
    'Adding HTML Encoding
    'session(strWizardName & "__ErrorMessage") = "Unable to get priceable item with id [" & pi_id & "]&nbsp;" & Err.Description
    session(strWizardName & "__ErrorMessage") = "Unable to get priceable item with id [" & pi_id & "]&nbsp;" & SafeForHtmlAttr(Err.Description)
    response.redirect("Wizard.asp?Path=/mcm/default/dialog/wizard/CreateRateSchedule&PageID=description&Error=Y")    
  End If
	Set objPricelistMapping = objPriceableItem.GetPriceListMapping(pt_id)
	if (Err.Number) OR (NOT IsValidObject(objPricelistMapping)) then
    session(strWizardName & "__ErrorMessage") = "Unable to get pricelist mapping for parameter table with id [" & pt_id & "] for priceable item with id [" & pi_id & "]&nbsp;" & SafeForHtmlAttr(Err.Description)
    response.redirect("Wizard.asp?Path=/mcm/default/dialog/wizard/CreateRateSchedule&PageID=description&Error=Y")    
  End If
	Set objNewRateSchedule = objPricelistMapping.CreateRateSchedule()
else
	Set objNewRateSchedule = objParamTable.CreateRateSchedule(pl_id, pi_id)
end if

	if (Err.Number) OR (NOT IsValidObject(objNewRateSchedule)) then
    'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
    'Adding HTML Encoding
    'session(strWizardName & "__ErrorMessage") = "Unable to create rate schedule&nbsp;" & Err.Description
    session(strWizardName & "__ErrorMessage") = "Unable to create rate schedule&nbsp;" & SafeForHtmlAttr(Err.Description)
    response.redirect("Wizard.asp?Path=/mcm/default/dialog/wizard/CreateRateSchedule&PageID=description&Error=Y")    
  End If
  
objNewRateSchedule.Description = session(strWizardName & "_rs_comment")

dim tmpVal
'Set up effective start date
Select Case UCase(session(strWizardName & "_startdate_pick"))
	Case "NULL"
		objNewRateSchedule.EffectiveDate.StartDateType = PCDATE_TYPE_NULL
		objNewRateSchedule.EffectiveDate.SetStartDateNull()
	Case "ABS"
		objNewRateSchedule.EffectiveDate.StartDateType = PCDATE_TYPE_ABSOLUTE
		tmpVal = session(strWizardName & "_abs_startdate_tf")
		if (tmpVal = "") then	' In the future, add validation here

		else 
			objNewRateSchedule.EffectiveDate.StartDate = CDate(tmpVal)
		end if
	Case "SUBS"
		objNewRateSchedule.EffectiveDate.StartDateType = PCDATE_TYPE_SUBSCRIPTION
		tmpVal = session(strWizardName & "_subs_startdate_tf")
		if (tmpVal = "") then	' In the future, add validation here

		else 
			objNewRateSchedule.EffectiveDate.StartOffSet = CDate(tmpVal)
		end if
	Case "BILL"
		objNewRateSchedule.EffectiveDate.StartDateType = PCDATE_TYPE_BILLCYCLE
		tmpVal = session(strWizardName & "_bill_startdate_tf")
		if (tmpVal = "") then	' In the future, add validation here

		else 
			objNewRateSchedule.EffectiveDate.StartDate = CDate(tmpVal)
		end if
End Select

' Set up effective end date
Select Case UCase(session(strWizardName & "_enddate_pick"))
	Case "NULL"
		objNewRateSchedule.EffectiveDate.EndDateType = PCDATE_TYPE_NULL
		objNewRateSchedule.EffectiveDate.SetEndDateNull()
	Case "ABS"
		objNewRateSchedule.EffectiveDate.EndDateType = PCDATE_TYPE_ABSOLUTE
		tmpVal = session(strWizardName & "_abs_enddate_tf")
		if (tmpVal = "") then	' In the future, add validation here

		else 
			objNewRateSchedule.EffectiveDate.EndDate = CDate(tmpVal)
		end if
	Case "SUBS"
		objNewRateSchedule.EffectiveDate.EndDateType = PCDATE_TYPE_SUBSCRIPTION
		tmpVal = session(strWizardName & "_subs_enddate_tf")
		if (tmpVal = "") then	' In the future, add validation here

		else 
			objNewRateSchedule.EffectiveDate.EndOffSet = CDate(tmpVal)
		end if
	Case "BILL"
		objNewRateSchedule.EffectiveDate.EndDateType = PCDATE_TYPE_BILLCYCLE
		tmpVal = session(strWizardName & "_bill_enddate_tf")
		if (tmpVal = "") then	' In the future, add validation here

		else 
			objNewRateSchedule.EffectiveDate.EndDate = CDate(tmpVal)
		end if
End Select

' If we are copying an existing rate schedule we need to retrieve the other ruleset and save it with this rate schedule
if len(session("CopyRateScheduleId"))<>0 then

  dim idOriginalRateSchedule
  dim objOriginalRateSchedule

  idOriginalRateSchedule = Clng(session("CopyRateScheduleId"))
  Set objOriginalRateSchedule = objParamTable.GetRateSchedule(idOriginalRateSchedule)
  
  'Can't set the ruleset directly so this is how we copy it
  dim objConfigPropSet
  set objConfigPropSet = objOriginalRateSchedule.RuleSet.WriteToSet
  objConfigPropSet.Reset
  objNewRateSchedule.RuleSet.ReadFromSet objConfigPropSet
  
  ' Save the newly created RateSchedule with the rules
  objNewRateSchedule.SaveWithRules
else
  ' Save the newly created RateSchedule
  objNewRateSchedule.Save
end if




if (Err.Number) then
'	Response.write ("Error")
'	Response.end
  'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
  'Adding HTML Encoding
  'session(strWizardName & "__ErrorMessage") = Err.Description
  session(strWizardName & "__ErrorMessage") = SafeForHtmlAttr(Err.Description)
  response.redirect("Wizard.asp?Path=/mcm/default/dialog/wizard/CreateRateSchedule&PageID=description&Error=Y")    
End If


' We will save this guy, in case we need to filter, add, set effective date, etc...
Set session("CurrMTRateSchedule") = objNewRateSchedule

'We will check if the user wants to use a custom screen to edit the Rates inside this RateSchedule
RuleEditorURL = FrameWork.GetDictionary(objParamTable.Name) & "?"	

' If this condition is true, we didn't find a custom screen, so we will edit with the default screen
if RuleEditorURL = "?" then
	RuleEditorURL = FrameWork.GetDictionary("MPTE_DEFAULT_SCREEN") & "?"
end if

RuleEditorURL = RuleEditorURL & "Refresh=TRUE"
RuleEditorURL = RuleEditorURL & "&Reload=TRUE"
RuleEditorURL = RuleEditorURL & "&EditMode=True"
RuleEditorURL = RuleEditorURL & "&POBased=" & session("RATES_POBASED")
RuleEditorURL = RuleEditorURL & "&RS_ID=" & CStr(objNewRateSchedule.ID)
RuleEditorURL = RuleEditorURL & "&PT_ID=" & session("RATES_PARAMTABLE_ID")



'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : ClearWizardSession()                                      '
' Description   : Clear all session variables associated with this wizard.  '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ClearWizardSession()
  Dim strWizard
  Dim xSessionItem
  
  strWizard = gobjMTWizard.Name
  
  for each xSessionItem in Session.Contents
    if len(xSessionItem) >= len(strWizard) then
      if left(xSessionItem, len(strWizard)) = strWizard then
        
        if isobject(Session.Contents(xSessionItem)) then
          Set Session.Contents(xSessionItem) = nothing
        else
          Session.Contents(xSessionItem) = ""
        end if
      
      end if
    end if
  next
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''               Page Processing                     '''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
<html>
  <head>
    <script language="Javascript">
	  window.opener.location = "<% Response.Write(RuleEditorURL) %>";
	  window.close();
    </script>
  </head>
  <body>
  </body>
</html>

