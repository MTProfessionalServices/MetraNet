<%
' //==========================================================================
' // @doc $Workfile: WizardInclude.asp$
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
' // $Date: 11/18/2002 3:52:07 PM$
' // $Author: Frederic Torres$
' // $Revision: 46$
' //==========================================================================

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  WizardInclude.asp                                                        '
'  Functions for the dynamic wizard that are specific to rendering screens. '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%>
<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<!-- #INCLUDE FILE="../../../../mcmIncludes.asp" -->
<!-- #INCLUDE FILE="../FormsClass.asp" -->
<!-- #INCLUDE FILE="../GridClass.asp" -->
<!-- #INCLUDE FILE="../Styles.asp"-->


<%
'  <!-- #INCLUDE FILE="Styles.asp"-->
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Global Variables                                                         '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'Cycle Mode - replaces the boolean property "Relative" on the MTPCCycle object
'PUBLIC CONST CYCLE_MODE_FIXED			      = 0
'PUBLIC CONST CYCLE_MODE_BCR				      = 1
'PUBLIC CONST CYCLE_MODE_BCR_CONSTRAINED = 2
'PUBLIC CONST CYCLE_MODE_EBCR			      = 3



'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : gobjMTFormsAddInputHint                                   '
' Description : html helper                     '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function gobjMTFormsAddInputHint(strInput)
gobjMTFormsAddInputHint = "<tr><td colspan=""2"" align=""center"" class=""clsWizardPrompt""><b>" & strInput & "</b></td></tr>"
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteGeneralConfiguration                                   '
' Description : Write the general configuration page.                       '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteGeneralConfiguration(strWizardName) 
  Dim strInput      'Name of the input
  Dim strHTML

  'Write javascript to populate Display Name with Name
  strHTML = strHTML &    "<script language=""javascript"">function PopulateDisplayName() {if (document.WizardForm." & strWizardName & "_displayname.value == """")  {document.WizardForm." & strWizardName & "_displayname.value = document.WizardForm." & strWizardName & "_name.value  }    }	</script>"

  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
  
  'Add the name field
  strInput = strWizardName & "_name"
  'strHTML = strHTML & gobjMTFormsAddInputHint("How should this Product Offering appear in the product catalog?")
  'SECENG: CORE-4862 Problems with Encoding on pressing Back in AddRecurringCharge/wizard.asp
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, session(strInput), FrameWork.GetDictionary("TEXT_COLUMN_NAME"), 25, "onChange=""javascript:PopulateDisplayName();""")
  strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, SafeForHtmlAttr(session(strInput)), FrameWork.GetDictionary("TEXT_COLUMN_NAME"), 25, "onChange=""javascript:PopulateDisplayName();""")

  strInput = strWizardName & "_displayname"
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")
  'strHTML = strHTML & gobjMTFormsAddInputHint("How should this Product Offering appear outside of the product catalog?")
  dim sLanguageInfo
  sLanguageInfo = Framework.GetLanguageDisplayInformation(Session("FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME").LanguageId)

  'SECENG: CORE-4862 Problems with Encoding on pressing Back in AddRecurringCharge/wizard.asp
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTForms.AddTextInputRequiredEx(strInput, session(strInput),FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"), 50, "", sLanguageInfo)
  strHTML = strHTML & gobjMTForms.AddTextInputRequiredEx(strInput, SafeForHtmlAttr(session(strInput)),FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"), 50, "", sLanguageInfo)
  
'  response.write "Name: " & session(strInput) & " :: " & strInput
  
  'Add the description
  strInput = strWizardName & "_description"
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")

  'strHTML = strHTML & gobjMTForms.AddTextInput(strInput, session(strInput), "Description", 25, "")
  'strHTML = strHTML & "<TEXTAREA class='clsInputBox' name='" & strInput & "' cols='52' rows='4'>"
  'SECENG: CORE-4862 Problems with Encoding on pressing Back in AddRecurringCharge/wizard.asp
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTForms.AddTextAreaInput(strInput, session(strInput),FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION"), 52, 4, "")
  strHTML = strHTML & gobjMTForms.AddTextAreaInput(strInput, SafeForHtmlAttr(session(strInput)),FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION"), 52, 4, "")
  
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  

  strHTML = strHTML &  "               <br><br>" & vbNewline


  WriteGeneralConfiguration = strHTML
End Function


Function ValidateGeneralConfiguration(strWizardName)
  dim bValid
  bValid = true
   
  
  Dim lngTypeID
  
  lngTypeID                         = CLng(Session("AddRecurring_NewType"))
  Session("AddRecurring_IsUDRC")    = "" & UCase(ProductCatalogHelper.IsTypeIdUDRC(lngTypeID))
  
  set session(strWizardName & "__ErrorMessage") = CreateObject("Scripting.Dictionary")
  session(strWizardName & "__ErrorMessage").Add "X",FrameWork.GetDictionary("ERROR_WIZARD_NOTIFICATION")

  if session(strWizardName & "_Name") = "" then
    bValid = false
    session(strWizardName & "__ErrorMessage").Add "Name",replace(FrameWork.GetDictionary("MCM_ERROR_1001"),"[FIELD_NAME]",FrameWork.GetDictionary("TEXT_FIELD_NAME"))
  end if

  if session(strWizardName & "_DisplayName") = "" then
    bValid = false
    session(strWizardName & "__ErrorMessage").Add "DisplayName",replace(FrameWork.GetDictionary("MCM_ERROR_1001"),"[FIELD_NAME]",FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"))
  end if
 
  ValidateGeneralConfiguration = bValid
End Function



Function WriteUDRCDialog(strWizardName) 

  Dim strHTML, strInput
  
  strHTML = strHTML &    "<script language=""javascript"">function GetDataType(strName){if(strName == """ & strWizardName & "_MinUnitValue"" || strName == """ & strWizardName & "_MaxUnitValue""){return ""DECIMAL"";}return ""STRING"";}</script>"
  'Write javascript to populate UnitDisplayName with UnitName
  strHTML = strHTML &    "<script language=""javascript"">function PopulateUnitDisplayName() {if (document.WizardForm." & strWizardName & "_UnitDisplayName.value == """")  {document.WizardForm." & strWizardName & "_UnitDisplayName.value = document.WizardForm." & strWizardName & "_UnitName.value  }    }	</script>"

  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
      
  strInput = strWizardName & "_UnitName"
  
  strHTML = strHTML & "<tr><td></td><td>"    
  strHTML = strHTML & "<table align=""center"" valign=""center"" border=""0"">" & vbNewLine
  strHTML = strHTML   & "<tr><td>"
  'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, session(strInput), FrameWork.GetDictionary("TEXT_UNIT_NAME"), 50, " onChange=""javascript:PopulateUnitDisplayName();""")
  strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, SafeForHtmlAttr(session(strInput)), FrameWork.GetDictionary("TEXT_UNIT_NAME"), 50, " onChange=""javascript:PopulateUnitDisplayName();""")

  strInput = strWizardName & "_UnitDisplayName"
  'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, session(strInput), FrameWork.GetDictionary("TEXT_UNIT_DISPLAY_NAME"), 50, "")
  strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, SafeForHtmlAttr(session(strInput)), FrameWork.GetDictionary("TEXT_UNIT_DISPLAY_NAME"), 50, "")
  
  strHTML = strHTML   & "</td></tr>"
  strHTML = strHTML & "</table>" & vbNewLine
  strHTML = strHTML & "</td></tr>"
 
  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "") 
  
  'Add the name field
  strInput = strWizardName & "_name"
  'strHTML = strHTML & gobjMTFormsAddInputHint("How should this Product Offering appear in the product catalog?")
  'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, session(strInput), FrameWork.GetDictionary("TEXT_COLUMN_NAME"), 25, "onChange=""javascript:PopulateDisplayName();""")
  strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, SafeForHtmlAttr(session(strInput)), FrameWork.GetDictionary("TEXT_COLUMN_NAME"), 25, "onChange=""javascript:PopulateDisplayName();""")

  strInput = strWizardName & "_displayname"
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")


    strInput            = strWizardName & "_MinUnitValue"
    strHTML = strHTML & "<tr><td></td><td>"    
    strHTML = strHTML & "<table align=""center"" valign=""center"" border=""0"">" & vbNewLine
    strHTML = strHTML   & "<tr><td>"
    'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
    'Adding HTML Encoding
    'strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, session(strInput), FrameWork.GetDictionary("TEXT_MIN_UNIT_VALUE"), 28, "maxlength='26'")
    strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, SafeForHtmlAttr(session(strInput)), FrameWork.GetDictionary("TEXT_MIN_UNIT_VALUE"), 28, "maxlength='26'")
    strHTML = strHTML   & "</td></tr>"
    strHTML = strHTML & "</table>" & vbNewLine
    strHTML = strHTML & "</td></tr>"
    
    strInput            = strWizardName & "_MaxUnitValue"
    strHTML = strHTML & "<tr><td></td><td>"
    strHTML = strHTML & "<table align=""center"" valign=""center"" border=""0"">" & vbNewLine
    strHTML = strHTML   & "<tr><td>"
    'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
    'Adding HTML Encoding
    'strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, session(strInput), FrameWork.GetDictionary("TEXT_MAX_UNIT_VALUE"), 28, "maxlength='26'")
    strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, SafeForHtmlAttr(session(strInput)), FrameWork.GetDictionary("TEXT_MAX_UNIT_VALUE"), 28, "maxlength='26'")
    strHTML = strHTML   & "</td></tr>"
    strHTML = strHTML & "</table>" & vbNewLine
    strHTML = strHTML & "</td></tr>"
    
    strInput = strWizardName & "_IntegerUnitValue"
    strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")
    strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_VALUE_TYPE"))    
    strHTML = strHTML & "<tr><td></td><td>"
    strHTML = strHTML & "<table align=""center"" valign=""center"" border=""0"">" & vbNewLine
    strHTML = strHTML & gobjMTForms.AddRadioInput(strInput,  Session(strInput), "", Array(FrameWork.GetDictionary("TEXT_INTEGER"), FrameWork.GetDictionary("TEXT_DECIMAL")), Array(TRUE,FALSE), 1, " checked") & vbNewLine
    strHTML = strHTML & "</table>" & vbNewLine    
    strHTML = strHTML & "</td></tr>"

    
    strInput = strWizardName & "_RatingType"    
    strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")
    strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_TIERED_TAPER_USER_HINT"))    
    strHTML = strHTML & "<tr><td></td><td>"
    strHTML = strHTML & "<table align=""center"" valign=""center"" border=""0"">" & vbNewLine
    strHTML = strHTML & gobjMTForms.AddRadioInput(strInput,  Session(strInput), "", Array(FrameWork.GetDictionary("TEXT_TIERED"), FrameWork.GetDictionary("TEXT_TAPERED")), Array(UDRC_RATING_TYPE_TIERED, UDRC_RATING_TYPE_TAPERED), 1, " checked") & vbNewLine
    strHTML = strHTML & "</table>" & vbNewLine    
    strHTML = strHTML & "</td></tr>"
    

    strHTML =  strHTML & gobjMTForms.CloseEditBoxTable()
    
    WriteUDRCDialog     = strHTML
End Function


Function ValidateUDRCDialog(strWizardName)

  ValidateUDRCDialog = FALSE
  
  set session(strWizardName & "__ErrorMessage") = CreateObject("Scripting.Dictionary")

  If Len(session(strWizardName & "_UnitName"))=0 Then

      Session(strWizardName & "__ErrorMessage").Add "UnitName", PreProcess(FrameWork.GetDictionary("MCM_ERROR_1001"),Array("FIELD_NAME",FrameWork.GetDictionary("TEXT_UNIT_NAME")))
      Exit Function
  End If
  ValidateUDRCDialog = TRUE
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteGeneralConfiguration                                   '
' Description : Write the general configuration page.                       '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteChargeConfiguration(strWizardName) 
  Dim strInput      'Name of the input
  Dim strHTML
  
  '// Write out the Javascript that dims/undims the ProrateBasedOn field
  strHTML = "<script language='javascript'>function updateBasedOnField(){"  & vbNewLine 
  strHTML = strHTML & "if (document.WizardForm.AddRecurring_ProrateOnDeactivation.checked || document.WizardForm.AddRecurring_ProrateOnActivation.checked){disableDiv('ProrateOn',false);  }else  {disableDiv('ProrateOn',true);}"
  strHTML = strHTML & "}"

  strHTML = strHTML & "function disableDiv(sDivName,bDisable) {" & vbNewLine
  strHTML = strHTML & "		toggleDisabled(document.getElementById(sDivName), bDisable);" & vbNewLine
  strHTML = strHTML & "	}" & vbNewLine

  strHTML = strHTML & "	function toggleDisabled(el,bDisable) {" & vbNewLine
  strHTML = strHTML & "		if (el.disabled != null){" & vbNewLine
  strHTML = strHTML & "			el.disabled = bDisable;" & vbNewLine
  strHTML = strHTML & "		}" & vbNewLine
		
  strHTML = strHTML & "		if (el.style != null){" & vbNewLine
  strHTML = strHTML & "			el.style.color =  (bDisable) ? 'gray' : 'black';" & vbNewLine
  strHTML = strHTML & "		}" & vbNewLine
		
  strHTML = strHTML & "		if (el.childNodes && el.childNodes.length > 0) {" & vbNewLine
  strHTML = strHTML & "			for (var x = 0; x < el.childNodes.length; x++) {" & vbNewLine
  strHTML = strHTML & "				toggleDisabled(el.childNodes[x],bDisable);" & vbNewLine
  strHTML = strHTML & "			}" & vbNewLine
  strHTML = strHTML & "		}" & vbNewLine
  strHTML = strHTML & "	}" & vbNewLine &"</script>" & vbNewLine

  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")

  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_Should_this_item_be_charged_in") )
 
  strInput = strWizardName & "_ChargeInAdvance"
  strHTML = strHTML & "<tr><td ><table align=""center"" valign=""center"" border=""0"">"
  strHTML = strHTML & gobjMTForms.AddSelectInput(strInput, session(strInput), FrameWork.GetDictionary("TEXT_CHARGE_IN"), array(FrameWork.GetDictionary("TEXT_ADVANCE"),FrameWork.GetDictionary("TEXT_ARREARS")), Array("TRUE","FALSE"),"")
  strHTML = strHTML & "</table></td></tr>"
 
    strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")
    
    strHTML = strHTML & "</table>"

  strHTML = strHTML & "<div id='Proration' name='Proration' style='display: block;'>"
  strHTML = strHTML & "<table class='clsWizardBody' width='100%'>"
  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_Should_this_item_be_prorated"))

  strInput = strWizardName & "_ProrateOnActivation"
  strHTML = strHTML & "<tr><td >"
  strHTML = strHTML & "<table align=""center"" valign=""center"" border=""0"">"
  strHTML = strHTML & "<tr><td>"
  if session(strInput) = "TRUE" then
 	  strHTML = strHTML & gobjMTForms.AddCheckboxInputWithoutPrompt(strInput, "TRUE", true," onClick='updateBasedOnField();' ")
  else
 	  strHTML = strHTML & gobjMTForms.AddCheckboxInputWithoutPrompt(strInput, "TRUE", false," onClick='updateBasedOnField();' ")
  end if
      strHTML = strHTML & FrameWork.GetDictionary("TEXT_PRORATE_ACTIVATION") & "<BR>"

  strInput = strWizardName & "_ProrateOnDeactivation"
  strHTML = strHTML & "<tr><td >"
  strHTML = strHTML & "<tr><td>"
  if session(strInput) = "TRUE" then
 	  strHTML = strHTML & vbNewLine & gobjMTForms.AddCheckboxInputWithoutPrompt(strInput, "TRUE", true," onClick='updateBasedOnField();' ")
  else
 	  strHTML = strHTML  & vbNewLine & gobjMTForms.AddCheckboxInputWithoutPrompt(strInput, "TRUE", false," onClick='updateBasedOnField();' ")
  end if
      strHTML = strHTML & FrameWork.GetDictionary("TEXT_PRORATE_UNSUBSCRIPTION") & "<BR>" & vbNewLine

  strInput = strWizardName & "_ProrateBasedOn"
	strHTML = strHTML & "<tr><td align='center'>"
		
	strHTML = strHTML & "<div id='ProrateOn' name='ProrateOn' style='display: block;'>"
	strHTML = strHTML & "<table><tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" & FrameWork.GetDictionary("TEXT_PRORATE_BASED_ON")
  strHTML = strHTML & gobjMTForms.AddSelectInputWithoutPrompt(strInput, session(strInput), array(FrameWork.GetDictionary("TEXT_ACTUAL"),FrameWork.GetDictionary("TEXT_FIXED")), Array("FALSE","TRUE"),"")
  strHTML = strHTML & FrameWork.GetDictionary("TEXT_number_of_days") &" </td></tr></table>"
	strHTML = strHTML & "</div>"
	
	strHTML = strHTML & "</td></tr>"

  strHTML =  strHTML & gobjMTForms.CloseEditBoxTable()
  strHTML = strHTML &  "</div>"

	
  strInput = strWizardName & "_ChargePerParticipant"
  strHTML = strHTML & "<div id='PerParticipant' name='PerParticipant' style='display: block;'>"
  strHTML = strHTML & "  <table class='clsWizardBody' width='100%'>"
  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_GROUP_SUBSCRIPTION_CHARGE_GENERATED"))
  strHTML = strHTML & "    <tr><td>"
  strHTML = strHTML & "      <table align=""center"" valign=""center"" border=""0"">"
  strHTML = strHTML & "        <tr><td>"
  strHTML = strHTML & gobjMTForms.AddRadioInput(strInput,  session(strInput), "", array(FrameWork.GetDictionary("TEXT_PER_SUBSCRIPTION"), FrameWork.GetDictionary("TEXT_PER_PARTICIPANT")), array("FALSE", "TRUE"), 1, " checked")
	strHTML = strHTML & "        </td></tr>"
  strHTML = strHTML & "      </table>"
  strHTML = strHTML & "    </td></tr>"
  strHTML = strHTML & "  </table>"
  strHTML = strHTML &  "</div>"

	
	
  'See if we should disable proration fields because the cycle is daily... thank you Travis
  dim sDisableProration
  ' ESR-2835 remove the "OR" that was checking for "_CycleOption=1 and "_CycleTypeID=3", this was disabling the "prorate on activation/deactivation"
  ' the only cycle type that cannot be prorated is daily within "Same as subscriber's payer's billing cycle"
  'if (session(strWizardName & "_CycleOption")="0" and lcase(session(strWizardName & "_ConstrainSubscriberCycle")) = "true" and session(strWizardName & "_Cycle__Relative_PeriodChoice")="3") or (session(strWizardName & "_CycleOption")="1" and session(strWizardName & "_CycleTypeID")="3") then
  if (session(strWizardName & "_CycleOption")="0" and lcase(session(strWizardName & "_ConstrainSubscriberCycle")) = "true" and session(strWizardName & "_Cycle__Relative_PeriodChoice")="3") then
    sDisableProration="true"
  else
    sDisableProration="false"
  end if
  
  strHTML = strHTML & "<script language='javascript'>disableDiv('Proration'," & sDisableProration & ");</script>"
	if sDisableProration="false" then
  	strHTML = strHTML & "<script language='javascript'>updateBasedOnField();</script>"
  end if
	
  WriteChargeConfiguration = strHTML
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteCycleConfiguration                                   '
' Description : Writes the cycle configuration of the recurring charge      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteCycleConfiguration(strWizardName) 
 Dim strInput      'Name of the input
  Dim strHTML
	dim objEnum
  dim objEnumTypeItem
	dim arrItem()
	dim arrValue()
  dim intMonth
	dim objMTProductCatalog
	dim objRecurringCharge
	intMonth= 0

	
	Set objMTProductCatalog = GetProductCatalogObject
	Set objRecurringCharge = objMTProductCatalog.getPriceableItemType(Clng(session(strWizardName & "_NewType")))
	
	if objRecurringCharge is nothing then
		response.write("Priceable Item type not found")
		response.end
	end if
	
	redim preserve arrItem(intMonth) 
  redim preserve arrValue(intMonth)

	arrItem(intMonth)  = ""
	arrValue(intMonth) = ""
	
  set objEnum = getEnumTypes("Global","MonthOfTheYear")

  For Each objEnumTypeItem In objEnum
		redim preserve arrItem(intMonth)
		redim preserve arrValue(intMonth)
		arrItem(intMonth) = objEnumTypeItem.Name
		arrValue(intMonth) = objEnumTypeItem.ElementAt(0)
		intMonth = CLNG(intMonth) + 1
  Next

	strHTML = ""
	
	strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "") ' Main table
	
	'------------ First Choice: Billing Cycle Relative ------------------'	
	
	strInput = strWizardName & "_CycleOption"
	strHTML = strHTML & "<tr>"
	strHTML = strHTML & 	"<td>"
	strHTML = strHTML & 		gobjMTForms.getRadioButtonHTML(strInput, session(strInput), 0, FrameWork.GetDictionary("TEXT_PC_CYCLE_SAME_AS_SUBSCRIBER_BILLING_CYCLE"), " onclick=""showRelative();"" checked")
	strHTML = strHTML & 	"</td>"
	strHTML = strHTML & "</tr>"

  strHTML = strHTML & "<tr>"
	strHTML = strHTML & 	"<td align=""center"">" 	
	strHTML = strHTML & 		"<div id=""Relative"" name=""Relative"" style=""display: block;"">"
	strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "") ' Options for Cycle Relative Type
  
		strInput = strWizardName & "_Cycle__Relative"
	  	
	  strHTML = strHTML & "<tr>"
		strHTML = strHTML & 	"<td align=""center"">" 
		strHTML = strHTML & 		"<table>"
		strHTML = strHTML & 			"<tr>"
		strHTML = strHTML & 				"<td>"
		
			'--------- Some logic to display options correctly -- '
			session(strWizardName & "_ConstrainSubscriberCycle") = objRecurringCharge.ConstrainSubscriberCycle
			' The CheckBox (if objRecurringCharge.ConstrainSubscriberCycle = FALSE) and Label after it
	  	if Not session(strWizardName & "_ConstrainSubscriberCycle") then
	  		strHTML = strHTML & gobjMTForms.getCheckBoxHTML(strInput, session(strInput), "", "")
			end if
		strHTML = strHTML &					"</td>"
		strHTML = strHTML & 				"<td>" 
			strHTML = strHTML & FrameWork.GetDictionary("TEXT_PC_CYCLE_REQUIRE_CYCLE_IS")
			
			'---------------------------------------------------- '
			' The select box
		strHTML = strHTML &					"</td>"
		strHTML = strHTML & 				"<td>"
	strInput = strWizardName & "_Cycle__Relative_PeriodChoice"
		strHTML = strHTML & gobjMTForms.getSelectHTML(strInput, session(strInput), array("1","3","4","5","6","7","9","8"), array( FrameWork.GetDictionary("TEXT_PC_CYCLE_MONTHLY"), FrameWork.GetDictionary("TEXT_PC_CYCLE_DAILY"),FrameWork.GetDictionary("TEXT_PC_CYCLE_WEEKLY"),FrameWork.GetDictionary("TEXT_PC_CYCLE_BIWEEKLY"),FrameWork.GetDictionary("TEXT_PC_CYCLE_SEMIMONTHLY"),FrameWork.GetDictionary("TEXT_PC_CYCLE_QUARTERLY"),FrameWork.GetDictionary("TEXT_PC_CYCLE_SEMIANNUAL"),FrameWork.GetDictionary("TEXT_PC_CYCLE_ANNUAL")), "")
									
		strHTML = strHTML &					"</td>" 
		strHTML = strHTML &				"</tr>"
		strHTML = strHTML &			"</table>"
		strHTML = strHTML &		"</td>"
		strHTML = strHTML &	"</tr>"
  
  strHTML =  strHTML & gobjMTForms.CloseEditBoxTable()
	strHTML = strHTML & 		"</div>"
	strHTML = strHTML &		"</td>"
	strHTML = strHTML &	"</tr>"

	'--------------------------------------------------------------------'
	
	'-------- Second Choice: "Extended" Billing Cycle Relative ----------'

	strInput = strWizardName & "_CycleOption"
	
	strHTML = strHTML & "<tr>"
	strHTML = strHTML & 	"<td>"
	strHTML = strHTML & 		gobjMTForms.getRadioButtonHTML(strInput, session(strInput), 1, FrameWork.GetDictionary("TEXT_PC_CYCLE_ALIGNED_TO_SUBSCRIBER_BILLING_CYCLE"), " onclick=""showExtendedRelative();"" " & IIF("" & Session(strInput)="1"," checked",""))
	strHTML = strHTML & 	"</td>"
	strHTML = strHTML & "</tr>"

  strHTML = strHTML & "<tr>"
	strHTML = strHTML & 	"<td align=""center"">" 	
	strHTML = strHTML & 		"<div id=""ExtendedRelative"" name=""ExtendedRelative"" style=""display: block;"">"
	strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "") ' Options for Cycle Relative Type
  
		strInput = strWizardName & "_Cycle__ExtendedRelative"
	  	
	  strHTML = strHTML & "<tr>"
		strHTML = strHTML & 	"<td align=""center"">" 
		strHTML = strHTML & 		"<table>"
		strHTML = strHTML & 			"<tr>"
		strHTML = strHTML & 				"<td>" 
		strHTML = strHTML & FrameWork.GetDictionary("TEXT_PC_CYCLE_ALIGNED_OCURRING")
			
		'---------------------------------------------------- '
		' The select box
		strHTML = strHTML &					"</td>"
		strHTML = strHTML & 				"<td>"
	  strInput = strWizardName & "_Cycle__ExtendedRelative_PeriodChoice"
		strHTML = strHTML & gobjMTForms.getSelectHTML(strInput, session(strInput), array("1","4","5","7","9","8"), array( FrameWork.GetDictionary("TEXT_PC_CYCLE_MONTHLY"),FrameWork.GetDictionary("TEXT_PC_CYCLE_WEEKLY"),FrameWork.GetDictionary("TEXT_PC_CYCLE_BIWEEKLY"),FrameWork.GetDictionary("TEXT_PC_CYCLE_QUARTERLY"),FrameWork.GetDictionary("TEXT_PC_CYCLE_SEMIANNUAL"),FrameWork.GetDictionary("TEXT_PC_CYCLE_ANNUAL")), "")									
		strHTML = strHTML &					"</td>" 
		strHTML = strHTML &				"</tr>"
		strHTML = strHTML &			"</table>"
		strHTML = strHTML &		"</td>"
		strHTML = strHTML &	"</tr>"
  
  strHTML =  strHTML & gobjMTForms.CloseEditBoxTable()
	strHTML = strHTML & 		"</div>"
	strHTML = strHTML &		"</td>"
	strHTML = strHTML &	"</tr>"
	
	'------------ Third Choice: Fixed Cycle ----------------------------'	
	
	strInput = strWizardName & "_CycleOption"

  strHTML = strHTML & "<tr>"
	strHTML = strHTML & 	"<td>" 
	strHTML = strHTML & 		gobjMTForms.getRadioButtonHTML(strInput, Session(strInput), 2, FrameWork.GetDictionary("TEXT_PC_CYCLE_FIXED_CYCLE"), " onclick=""showFixed();"" " & IIF("" & Session(strInput)="2"," checked",""))
  strHTML = strHTML & 	"</td>"
	strHTML = strHTML & "</tr>"

  strHTML = strHTML & "<tr>"
	strHTML = strHTML & 	"<td align=""center"">" 
	
	strHTML = strHTML & "<div id=""Fixed"" name=""Fixed"" style=""display: block;"">"
	strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "") ' Options for fixed cycle type

  	strInput = strWizardName & "_CycleTypeID" ' Name of radiobutton
  	'Set value of fixed cycle to Daily if it has not been specified
  	if Session(strInput)="" Then
  	  Session(strInput)="3"
  	end if
 		strHTML = strHTML & "<tr>"
		strHTML = strHTML & 	"<td class=""cycleTableCell"">"     
  	strHTML = strHTML & 		gobjMTForms.getRadioButtonHTML(strInput, Session(strInput), 3, FrameWork.GetDictionary("TEXT_PC_CYCLE_DAILY"), IIF("" & Session(strInput)="3"," checked",""))
		strHTML = strHTML & 	"</td>"
		strHTML = strHTML & "</tr>"

 		strHTML = strHTML & "<tr>"
		strHTML = strHTML & 	"<td class=""cycleTableCell"">"
  	strHTML = strHTML & 		gobjMTForms.getRadioButtonHTML(strInput, session(strInput), 4, FrameWork.GetDictionary("TEXT_PC_CYCLE_WEEKLY"), IIF("" & Session(strInput)="4"," checked",""))

	strInput = strWizardName & "_Cycle__EndDayOfWeek" ' Name of select
		strHTML = strHTML & "&nbsp;&nbsp;" & FrameWork.GetDictionary("TEXT_PC_CYCLE_WEEKLY_LABEL1") & "&nbsp;&nbsp;"

		strHTML = strHTML &			gobjMTForms.getSelectHTML(strInput, session(strInput), array("1","2","3","4","5","6","7"), array(FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_SUNDAY"),FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_MONDAY"),FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_TUESDAY"),FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_WEDNESDAY"),FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_THURSDAY"),FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_FRIDAY"),FrameWork.GetDictionary("TEXT_MPTE_CALENDAR_SATURDAY")), "")
		strHTML = strHTML & 	"</td>"
		strHTML = strHTML & "</tr>"

		strHTML = strHTML & "<tr>"
		strHTML = strHTML & 	"<td class=""cycleTableCell"">" 
	strInput = strWizardName & "_CycleTypeID" ' Name of radiobutton
  	strHTML = strHTML & 		gobjMTForms.getRadioButtonHTML(strInput, session(strInput), 5, FrameWork.GetDictionary("TEXT_PC_CYCLE_BIWEEKLY"), IIF("" & Session(strInput)="5"," checked",""))
		'strHTML = strHTML &		"</td>"
		
		'strHTML = strHTML &   "<td>"
	strInput = strWizardName & "_Cycle__BIWeekly" ' Name of select	
	Dim arrLabels, arrValues
  GetBillingCycleBiWeeklyComboBoxContent arrLabels, arrValues
		strHTML = strHTML &			"&nbsp;&nbsp;"
		strHTML = strHTML & 		gobjMTForms.getSelectHTML(strInput, session(strInput), arrValues, arrLabels, "")
		strHTML = strHTML & 	"</td>"
		strHTML = strHTML & "</tr>"

		strHTML = strHTML & "<tr>"
		strHTML = strHTML & 	"<td class=""cycleTableCell"">" 
	strInput = strWizardName & "_CycleTypeID" ' Name of radiobutton		
		strHTML = strHTML & 		gobjMTForms.getRadioButtonHTML(strInput, session(strInput), 6, FrameWork.GetDictionary("TEXT_PC_CYCLE_SEMIMONTHLY"), IIF("" & Session(strInput)="6"," checked","")) & "&nbsp;&nbsp;"
	strInput = strWizardName & "_Cycle@EndDayOfMonth_SemiMonthly"
			
		strHTML = strHTML & FrameWork.GetDictionary("TEXT_PC_CYCLE_SEMIMONTHLY_LABEL1") & "&nbsp;&nbsp;"
		strHTML = strHTML & 		gobjMTForms.getSelectHTML(strInput, session(strInput), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30",FrameWork.GetDictionary("TEXT_END_OF_THE_MONTH")), _
																																			"")
																																																														
		strInput = strWizardName & "_Cycle__EndDayOfMonth2"
		strHTML = strHTML & FrameWork.GetDictionary("TEXT_PC_CYCLE_SEMIMONTHLY_LABEL2") & "&nbsp;&nbsp;"
		strHTML = strHTML & 		gobjMTForms.getSelectHTML(strInput, session(strInput), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30",FrameWork.GetDictionary("TEXT_END_OF_THE_MONTH")), _
																																			 "")

 		strHTML = strHTML & 	"</td>"
		strHTML = strHTML & "</tr>"
		strHTML = strHTML & "<tr>"
		strHTML = strHTML & 	"<td class=""cycleTableCell"">"					
	strInput = strWizardName & "_CycleTypeID" ' Name of radiobutton
		strHTML = strHTML & 		gobjMTForms.getRadioButtonHTML(strInput, session(strInput), 1, FrameWork.GetDictionary("TEXT_PC_CYCLE_MONTHLY"), IIF("" & Session(strInput)="1"," checked",""))

		strHTML = strHTML & "&nbsp;&nbsp;"
	strInput = strWizardName & "_Cycle__Cycle@EndDayOfMonth_Monthly"
		
		strHTML = strHTML & FrameWork.GetDictionary("TEXT_PC_CYCLE_MONTHLY_LABEL1") & "&nbsp;&nbsp;"
		
		strHTML = strHTML & 		gobjMTForms.getSelectHTML(strInput, session(strInput), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30",FrameWork.GetDictionary("TEXT_END_OF_THE_MONTH")), _
																																			 "")
		strHTML = strHTML & 	"</td>"
		strHTML = strHTML & "</tr>"
		
		strHTML = strHTML & "<tr>"
		strHTML = strHTML & 	"<td class=""cycleTableCell"">"					
  strInput = strWizardName & "_CycleTypeID"
		strHTML = strHTML & 		gobjMTForms.getRadioButtonHTML(strInput, session(strInput), 7, FrameWork.GetDictionary("TEXT_PC_CYCLE_QUARTERLY"), IIF("" & Session(strInput)="7"," checked",""))
		strHTML = strHTML & "&nbsp;&nbsp;"
		
		strHTML = strHTML & 	FrameWork.GetDictionary("TEXT_PC_CYCLE_QUARTERLY_LABEL1") & "&nbsp;&nbsp;"
		strInput = strWizardName & "_CycleStartMonthQuarterly"
    Dim JanuaryAprilJulyOctober, FebruaryMayAugustNovember, MarchJuneSeptemberDecember
    JanuaryAprilJulyOctober = FrameWork.GetDictionary("TEXT_January") & "," & FrameWork.GetDictionary("TEXT_April") & "," &FrameWork.GetDictionary("TEXT_July") & "," &FrameWork.GetDictionary("TEXT_October")
    FebruaryMayAugustNovember = FrameWork.GetDictionary("TEXT_February") & "," & FrameWork.GetDictionary("TEXT_May") & "," &FrameWork.GetDictionary("TEXT_August") & "," &FrameWork.GetDictionary("TEXT_November")
    MarchJuneSeptemberDecember = FrameWork.GetDictionary("TEXT_March") & "," & FrameWork.GetDictionary("TEXT_June") & "," &FrameWork.GetDictionary("TEXT_September") & "," &FrameWork.GetDictionary("TEXT_December")
		strHTML = strHTML & 		gobjMTForms.getSelectHTML(strInput, session(strInput), _
																																			Array("1","2","3"), _
																																			Array(JanuaryAprilJulyOctober,FebruaryMayAugustNovember,MarchJuneSeptemberDecember), _
																																			 "")

		strHTML = strHTML & 	FrameWork.GetDictionary("TEXT_PC_CYCLE_QUARTERLY_LABEL2")
		strHTML = strHTML & "&nbsp;"	
		strInput = strWizardName & "_CycleStartDayQuarterly"
		strHTML = strHTML & 		gobjMTForms.getSelectHTML(strInput, session(strInput), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30",FrameWork.GetDictionary("TEXT_END_OF_THE_MONTH")), _
																																			 "")
		strHTML = strHTML & 	"</td>"
		strHTML = strHTML & "</tr>"

		strHTML = strHTML & "<tr>"
		strHTML = strHTML & 	"<td class=""cycleTableCell"">"						
	strInput = strWizardName & "_CycleTypeID"
		strHTML = strHTML & 		gobjMTForms.getRadioButtonHTML(strInput, session(strInput), 9, FrameWork.GetDictionary("TEXT_PC_CYCLE_SEMIANNUAL"), IIF("" & Session(strInput)="9"," checked",""))
		strHTML = strHTML & "&nbsp;&nbsp;"
		'strHTML = strHTML & 	"</td>"
		'strHTML = strHTML & 	"<td>"
		strHTML = strHTML & 	FrameWork.GetDictionary("TEXT_PC_CYCLE_SEMIANNUAL_LABEL1") & "&nbsp;&nbsp;"
  strInput = strWizardName & "_CycleStartMonthSemiAnnual"

  Dim January,April,July,October, February,May,August,November, March,June,September,December
  January = FrameWork.GetDictionary("TEXT_January")
  February = FrameWork.GetDictionary("TEXT_February")
  March = FrameWork.GetDictionary("TEXT_March")
  April = FrameWork.GetDictionary("TEXT_April")
  May = FrameWork.GetDictionary("TEXT_May")
  June = FrameWork.GetDictionary("TEXT_June")
  July = FrameWork.GetDictionary("TEXT_July")
  August = FrameWork.GetDictionary("TEXT_August")
  September = FrameWork.GetDictionary("TEXT_September")
  October = FrameWork.GetDictionary("TEXT_October")
  November = FrameWork.GetDictionary("TEXT_November")
  December = FrameWork.GetDictionary("TEXT_December")

		strHTML = strHTML & 		gobjMTForms.getSelectHTML(strInput, session(strInput), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12"), _
																																			Array(January,February,March,April,May,June,July,August,September,October,November,December), _
																																			 "")

		strHTML = strHTML & 	FrameWork.GetDictionary("TEXT_PC_CYCLE_SEMIANNUAL_LABEL2")
		strHTML = strHTML & "&nbsp;"
  strInput = strWizardName & "_CycleStartDaySemiAnnual"
		strHTML = strHTML & 		gobjMTForms.getSelectHTML(strInput, session(strInput), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"), _
																																			 "")
																																			 
		strHTML = strHTML & 	"</td>"
		strHTML = strHTML & "</tr>"
		strHTML = strHTML & "<tr>"
		strHTML = strHTML & 	"<td class=""cycleTableCell"">"						
	strInput = strWizardName & "_CycleTypeID"
		strHTML = strHTML & 		gobjMTForms.getRadioButtonHTML(strInput, session(strInput), 8, FrameWork.GetDictionary("TEXT_PC_CYCLE_ANNUAL"), IIF("" & Session(strInput)="8"," checked",""))
		strHTML = strHTML & "&nbsp;&nbsp;"
		'strHTML = strHTML & 	"</td>"
		'strHTML = strHTML & 	"<td>"
		strHTML = strHTML & 	FrameWork.GetDictionary("TEXT_PC_CYCLE_ANNUAL_LABEL1") & "&nbsp;&nbsp;"
  strInput = strWizardName & "_CycleStartMonthAnnual"
		strHTML = strHTML & 		gobjMTForms.getSelectHTML(strInput, session(strInput), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12"), _
																																			Array(January,February,March,April,May,June,July,August,September,October,November,December), _
																																			 "")

		strHTML = strHTML & 	FrameWork.GetDictionary("TEXT_PC_CYCLE_ANNUAL_LABEL2")
		strHTML = strHTML & "&nbsp;"
  strInput = strWizardName & "_CycleStartDayAnnual"
		strHTML = strHTML & 		gobjMTForms.getSelectHTML(strInput, session(strInput), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"), _
																																			Array("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30",FrameWork.GetDictionary("TEXT_END_OF_THE_MONTH")), _
																																			 "")
																																			 
		strHTML = strHTML & 	"</td>"
		strHTML = strHTML & "</tr>"

	strHTML =  strHTML & gobjMTForms.CloseEditBoxTable()
	strHTML = strHTML & 		"</div>"	
  strHTML = strHTML & 	"</td>"
	strHTML = strHTML & "</tr>"
	
	'--------------------------------------------------------------------'
	
	strHTML =  strHTML & gobjMTForms.CloseEditBoxTable() ' Main table

  'Warning: this javascript assumes that the cycle option "Aligned to subscriber's billing cycle" is present.
  'as of 3.6/3.7 this is true for recurring charges only
  strHTML = strHTML & "<script>"
  strHTML = strHTML & "if (document.WizardForm.AddRecurring_CycleOption[0].checked) "
  strHTML = strHTML &   "showRelative(); "
  strHTML = strHTML & "else if (document.WizardForm.AddRecurring_CycleOption[1].checked) "
  strHTML = strHTML &   "showExtendedRelative(); "
  strHTML = strHTML & "else "
  strHTML = strHTML &   "showFixed(); "
  strHTML = strHTML & "document.WizardForm.AddRecurring_CycleTypeID.checked = true;"
  strHTML = strHTML & "</script> "
  
	WriteCycleConfiguration = strHTML
End Function



 ' ---------------------------------------------------------------------------------------------------------------------------------------
    ' FUNCTION 		    : ComputeAndStoreBiWeeklyCycle
    ' PARAMETERS		  :
    ' DESCRIPTION 		:
    ' RETURNS		      :
    PRIVATE FUNCTION GetBillingCycleBiWeeklyComboBoxContent(arrOptions, addValues) ' As Boolean    
    
        Dim objCycle , objTimeSpan, i, objEnumType, strCurrentBiWeeklyPropertyString, strTMP
		
		arrOptions = Array(1,2,3,4,5,6,7,8,9,10,11,12,13,14)
		addValues  = Array(1,2,3,4,5,6,7,8,9,10,11,12,13,14)
          
        For i = 1 to 14
        
            Set objCycle = mdm_CreateObject(MTProductCatalogMTPCycle)      
            objCycle.CycleTypeID = BILLING_CYCLE_BI_WEEKLY
            objCycle.StartMonth  = BIWEEKLY_STARTMONTH
            objCycle.StartDay    = CLng(i)
            objCycle.StartYear   = BIWEEKLY_STARTYEAR
            objCycle.ComputeCycleIDFromProperties      
            Set objTimeSpan      = objCycle.GetTimeSpan(Date())

 			arrOptions(i-1) = "" & objTimeSpan.StartDate & " - " & objTimeSpan.EndDate
			addValues(i-1)  = i
            
            Set Session("BI-WEEKLY.CycleType" & i) = objCycle
			
        Next                     
        GetBillingCycleBiWeeklyComboBoxContent = strTMP
    END FUNCTION
	
	
	
Function getEnumTypes(strNameSpace, strEnumTypeName) ' As Object
        
    Dim objEnumTypeConfig   'As MTENUMCONFIGLib.EnumConfig
    Dim objEnumSpace        'As MTENUMCONFIGLib.MTEnumSpace
    Dim objEnumType         'As MTENUMCONFIGLib.MTEnumType
    'Dim objEnumTypeItem     'As MTENUMCONFIGLib.MTEnumerator
    
    Set objEnumTypeConfig = CreateObject("Metratech.MTEnumConfig.1")
		  
	  objEnumTypeConfig.Initialize
        
    Set objEnumSpace = objEnumTypeConfig.GetEnumSpace(strNameSpace)
    If (objEnumSpace Is Nothing) Then 
   		 response.write("Error")
			'writeSystemLog "[Asp=utilProductView.asp][Function=getEnumTypes] NameSpace not found " & strNameSpace , LOG_DEBUG ' #mark
			Exit Function
		End If
    
    Set objEnumType = objEnumSpace.GetEnumType(strEnumTypeName)
    If (objEnumType Is Nothing) Then 
			response.write("Error")
    	'writeSystemLog "[Asp=utilProductView.asp][Function=getEnumTypes] EnumTypeName not found " & strEnumTypeName , LOG_DEBUG ' #mark
			Exit Function
		End If
    
		Set getEnumTypes = objEnumType.GetEnumerators ' Return the result
    
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : WriteExtendedPropertyConfiguration()                      '
' Description   : Write the extended property configuration page.           '
' Inputs        : strWizardName -- The name of the wizard.                  '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteNewOrExisting(strWizardName)
  Dim strHTML             'HTML output
  Dim objNewProductOffering               'Priceable Item helper object
  Dim strBaseEdit         'Base string to edit data
  Dim strEdit             'Modified string
  Dim strAttributes       'Attributes in string form
  Dim objAttributeItem    'Attribute item
  Dim arrProperties()     'Array of properties
  Dim intPropertyCount    'Number of properties
  Dim bFound              'Indicates a property was found when searching
  Dim i

  
  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject

  dim objRowset
  set objRowset = objMTProductCatalog.FindPriceableItemsAsRowset

  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_EXISTING_OR_NEW_REC_CHARGE"))
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")

  'strHTML = strHTML & gobjMTForms.OpenEditBoxTable("Existing Recurring Charge", "")


  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_EXISTING_REC_CHARGE"))
   strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
   
  if true then   
 'EXISTING: Write the list of existing recurring charges
  strHTML = strHTML & gobjMTGrid.OpenGridDiv(Array(FrameWork.GetDictionary("TEXT_SELECT"), FrameWork.GetDictionary("TEXT_FIELD_NAME"), FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION")), _
                                            " id=""PropertyDiv""", _
                                            "PropertyTable", _
                                            true, _
                                            Array("10%","30%","60%"), _
                                            "", _
                                            "")

											
        
        Dim objPriceableItemTemplates
        Dim objMTFilter
        'set objPriceableItemTemplates = objMTProductCatalog.GetPriceableItemTypes()

        Set objMTFilter = mcmGetFilterForPriceableItemKind(PI_TYPE_RECURRING)
        
        Set objPriceableItemTemplates = objMTProductCatalog.FindPriceableItemsAsRowset(objMTFilter) ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset
  
										
      intPropertyCount = 0
      
      redim arrProperties(2)

  do while not cbool(objPriceableItemTemplates.EOF)

  	arrProperties(0) = "<input type='radio' name='" & strWizardName & "_SELECTTEMPLATE' value='" & objPriceableItemTemplates.value("id_prop") & "'>"
  	'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
  	'Adding HTML Encoding
  	'arrProperties(1) = objPriceableItemTemplates.value("nm_name")
  	'arrProperties(2) = objPriceableItemTemplates.value("nm_desc")
  	arrProperties(1) = SafeForHtmlAttr(objPriceableItemTemplates.value("nm_name"))
  	arrProperties(2) = SafeForHtmlAttr(objPriceableItemTemplates.value("nm_desc"))
   	strHTML = strHTML & gobjMTGrid.AddGridRow(arrProperties, "", true, Array("10%","30%","60%"), "", Array("center"))
   
    objPriceableItemTemplates.MoveNext

  loop

       
  'Close the grid
  strHTML = strHTML & gobjMTGrid.CloseGridDiv()
  'strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  end if
  
  strHTML = strHTML & gobjMTFormsAddInputHint("<input type='radio' name='" & strWizardName & "_SELECTTEMPLATE' value='-1' checked>" &  FrameWork.GetDictionary("TEXT_ADD_NEW_RECURRING_CHARGE"))

  'Set current selection
  strHTML = strHTML & "<script language=""Javascript"" src=""../../../lib/utilForm.js""></script>"
  strHTML = strHTML & "<script language=""Javascript"">setRadioSelection(document.WizardForm." & strWizardName & "_SELECTTEMPLATE, '" & session(strWizardName & "_SELECTTEMPLATE") & "');</script>"
  
  strHTML = strHTML & "<script language=""Javascript"">strOnload = 'SizeDiv(""PropertyDiv"", ""PropertyTable"", 100);';</script>" & vbNewline
  
  WriteNewOrExisting = strHTML
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : WriteTypeSelect()                                         '
' Description   :                                                           '
' Inputs        : strWizardName -- The name of the wizard.                  '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteTypeSelect(strWizardName)
  Dim strHTML             'HTML output
  Dim objNewProductOffering               'Priceable Item helper object
  Dim strBaseEdit         'Base string to edit data
  Dim strEdit             'Modified string
  Dim strAttributes       'Attributes in string form
  Dim objAttributeItem    'Attribute item
  Dim arrProperties()     'Array of properties
  Dim intPropertyCount    'Number of properties
  Dim bFound              'Indicates a property was found when searching
  Dim i

  
  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_WHAT_TYPE_REC_CHARGE"))
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()

  strHTML = strHTML & gobjMTGrid.OpenGridDiv(Array(FrameWork.GetDictionary("TEXT_SELECT"),FrameWork.GetDictionary("TEXT_FIELD_NAME"), FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION")), _
                                            " id=""PropertyDiv""", _
                                            "PropertyTable", _
                                            true, _
                                            Array("65","120","180"), _
                                            "", _
                                            "")
	
    Dim objMTProductCatalog
    Set objMTProductCatalog = GetProductCatalogObject
    
    Dim objPriceableItemTypes
    set objPriceableItemTypes = objMTProductCatalog.GetPriceableItemTypes()
  									
    intPropertyCount = 0
      
    redim arrProperties(2)
      
    // Fred
      
    Dim objType
    
    Session("AddRecurring_IsUDRC") = "TRUE"
    
    For Each objType in objPriceableItemTypes
    
          If ProductCatalogHelper.IsRecurringChargeKind(objType.Kind) then 
          
      	      arrProperties(0) = "<input type='radio' name='" & strWizardName & "_NewType' value='" & objType.ID & "'>"
          	  arrProperties(1) = objType.DisplayNames.GetMapping(Framework.GetLanguageCodeForCurrentUser())
          	  arrProperties(2) = objType.Description
        	    strHTML = strHTML & gobjMTGrid.AddGridRow(arrProperties, "", true, Array("65","120","180"), "", "")
      	  End if
    Next

    'Close the grid
    strHTML = strHTML & gobjMTGrid.CloseGridDiv()
    strHTML = strHTML & "<script language=""Javascript"">strOnload = 'SizeDiv(""PropertyDiv"", ""PropertyTable"", 200);';</script>" & vbNewline
  
  
    'Disable button on the case where start is not the first page
    If Session(strWizardName & "_CreateNew") = "1" Then
      strHTML = strHTML & "<script language=""Javascript"">strOnload += ' document.all.butBack.disabled = true;'</script>" & vbNewline      
      strHTML = strHTML & "<script language=""Javascript"">strOnload += ' document.all.butBack.style.visibility = ""hidden"";';</script>" & vbNewline      
    End If
            
    'Set current selection
    strHTML = strHTML & "<script language=""Javascript"" src=""../../../lib/utilForm.js""></script>"
    strHTML = strHTML & "<script language=""Javascript"">setRadioSelection(document.WizardForm." & strWizardName & "_NewType, '" & session(strWizardName & "_NewType") & "');</script>"

    WriteTypeSelect = strHTML
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteSummary(..)                                            '
' Description : Write a brief summary of the priceable item to be created.  '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteSummary(strWizardName)
  Dim strHTML       'HTML to output
  Dim objSW         'Service wizard object
  Dim objSWPI       'Priceable item object
  Dim strName
  Dim strText
  Dim objStage      'Stage object
  Dim StrChargeIn
	Dim StrProrateOn
	Dim StrProrateActivation
	Dim StrProrateDeActivation
  Dim StrChargePerParticipant
  Dim strTiered

   if (session(strWizardName & "_SELECTTEMPLATE") <> "-1") then
   
	     dim strPickerIDs, arrPickerIDs
	     dim objPriceableItem
   		 dim objMTProductCatalog
	     dim intPriceableItemId
			 
			 Set objMTProductCatalog 								 						= GetProductCatalogObject
       strPickerIDs 													 						= session(strWizardName & "_SELECTTEMPLATE")
       intPriceableItemId 										 						= CLng(strPickerIDs)
       set objPriceableItem										 						= objMTProductCatalog.GetPriceableItem(intPriceableItemId)
 		   session(strWizardName & "_Name")        						= objPriceableItem.Name
			 session(strWizardName & "_DisplayName") 						= objPriceableItem.DisplayName
    	 session(strWizardName & "_Description") 						= objPriceableItem.Description
		   session(strWizardName & "_ChargeInAdvance") 				= objPriceableItem.ChargeInAdvance
			 session(strWizardName & "_ProrateBasedOn")					= objPriceableItem.FixedProrationLength
			 session(strWizardName & "_ProrateOnActivation") 		= objPriceableItem.ProrateOnActivation
       session(strWizardName & "_ProrateOnDeactivation") 	= objPriceableItem.ProrateOnDeactivation
		   session(strWizardName & "_ChargePerParticipant") 	= objPriceableItem.ChargePerParticipant
			 
  	End if		

		If Ucase(session(strWizardName & "_ChargeInAdvance")) = "TRUE" Then
	 			StrChargeIn = FrameWork.GetDictionary("TEXT_ADVANCE")
	  Else
		   StrChargeIn = FrameWork.GetDictionary("TEXT_ARREARS")	   			
		End If	 
	
	  dim bDisplayProrateBasedOn
    bDisplayProrateBasedOn = false
    
	  If Ucase(session(strWizardName & "_ProrateOnActivation")) = "TRUE" Then
	 			StrProrateActivation = FrameWork.GetDictionary("TEXT_YES")
        bDisplayProrateBasedOn = true
	  Else
		   StrProrateActivation = FrameWork.GetDictionary("TEXT_NO")	   			
		End If	
    	
	  If Ucase(session(strWizardName & "_ProrateOnDeactivation")) = "TRUE" Then
	 			StrProrateDeActivation = FrameWork.GetDictionary("TEXT_YES")
        bDisplayProrateBasedOn = true
	  Else
		   StrProrateDeActivation = FrameWork.GetDictionary("TEXT_NO")	   			
		End If	
	
    If Ucase(session(strWizardName & "_ProrateBasedOn")) = "TRUE" Then
		 	StrProrateOn = FrameWork.GetDictionary("TEXT_FIXED")
	  Else
		  StrProrateOn = FrameWork.GetDictionary("TEXT_ACTUAL")	 
    End If 			

	
		If Ucase(session(strWizardName & "_ChargePerParticipant")) = "TRUE" Then
	 		 StrChargePerParticipant = FrameWork.GetDictionary("TEXT_PER_PARTICIPANT")
	  Else
		   StrChargePerParticipant = FrameWork.GetDictionary("TEXT_PER_SUBSCRIPTION")	   			
		End If	 
	
	
  strHTML = strHTML & gobjMTGrid.OpenGridDiv(Array(""), _
                                             " id=""SummaryDiv""", _
                                             "SummaryTable", _
                                             true, _
                                             Array("9%"), _
                                             "", _
                                             "")
  strHTML = strHTML & " <tr><td>" & vbNewline                                             

  strHTML = strHTML & " <table width=""100%"">" & vbNewline
  strHTML = strHTML & "   <tr>" & vbNewline
  strHTML = strHTML & "     <td valign=""top"" width=""50%"">" & vbNewline

  'Write the general configuration information  
  strHTML = strHTML & gobjMTGrid.OpenGridDiv(Array(FrameWork.GetDictionary("TEXT_WIZARD_SUMMARY_INFORMATION")), "", "", false, "", Array(2), "")
  
  'response.write("strWizardName [" & strWizardName & "]<BR>")
  'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_NAME"), session(strWizardName & "_Name")), _
  '                                          "", false, "", "", Array("right", "left"))
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"), session(strWizardName & "_DisplayName")), _
  '                                          "", false, "", "", Array("right", "left"))
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION"), session(strWizardName & "_Description")), _
  '                                          "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_NAME"), SafeForHtmlAttr(session(strWizardName & "_Name"))), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"), SafeForHtmlAttr(session(strWizardName & "_DisplayName"))), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION"), SafeForHtmlAttr(session(strWizardName & "_Description"))), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_CHARGE_IN"),StrChargeIn), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_PRORATE_ACTIVATION"),StrProrateActivation), _
                                            "", false, "", "", Array("right", "left"))
                                            
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_PRORATE_DEACTIVATION"),StrProrateDeActivation), "", false, "", "", Array("right", "left"))
                                            
  If bDisplayProrateBasedOn Then
        strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_PRORATE_ON"),StrProrateOn), "", false, "", "", Array("right", "left"))                                              
  End If																																																																		
  
  

  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_GROUP_CHARGES"),StrChargePerParticipant), "", false, "", "", Array("right", "left"))
  
  If Session("AddRecurring_IsUDRC") = "TRUE" Then
      'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
      'Adding HTML Encoding
      'strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_UNIT_NAME"), Session(strWizardName & "_UnitName")), "", false, "", "", Array("right", "left"))
      'strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_UNIT_DISPLAY_NAME"), Session(strWizardName & "_UnitDisplayName")), "", false, "", "", Array("right", "left"))
      strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_UNIT_NAME"), SafeForHtmlAttr(Session(strWizardName & "_UnitName"))), "", false, "", "", Array("right", "left"))
      strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_UNIT_DISPLAY_NAME"), SafeForHtmlAttr(Session(strWizardName & "_UnitDisplayName"))), "", false, "", "", Array("right", "left"))
      strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_TIERED_TAPER_USER_HINT"), ProductCatalogHelper.GetUDRCRatingTypeDescription(session(strWizardName & "_RatingType"))), "", false, "", "", Array("right", "left"))
      
      strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_MIN_UNIT_VALUE"), session(strWizardName & "_MinUnitValue")), "", false, "", "", Array("right", "left"))
      strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_MAX_UNIT_VALUE"), session(strWizardName & "_MaxUnitValue")), "", false, "", "", Array("right", "left"))
  End If
  
  strHTML = strHTML & gobjMTGrid.CloseGridDiv()
                                            
  'Write out debug information
  if FrameWork.DebugMode then                                            
      'Write the general configuration information  
    strHTML = strHTML & gobjMTGrid.OpenGridDiv(Array(FrameWork.GetDictionary("TEXT_WIZARD_DEBUG_INFORMATION")), "", "", false, "", Array(2), "")
    
    'response.write("strWizardName [" & strWizardName & "]<BR>")
    dim xSessionItem
    for each xSessionItem in Session.Contents
  		'response.write("Item [" & xSessionItem & "]")
      if len(xSessionItem) >= len(strWizardName) then
        if left(xSessionItem, len(strWizardName)) = strWizardName then
  		'response.write("Item from wizard")        
          if isobject(Session.Contents(xSessionItem)) then
     			strHTML = strHTML & gobjMTGrid.AddGridRow(Array(xSessionItem, "[OBJECT]"), _
                                              "", false, "", "", Array("right", "left"))
          else
     			strHTML = strHTML & gobjMTGrid.AddGridRow(Array(xSessionItem, session(xSessionItem)), _
                                              "", false, "", "", Array("right", "left"))
         end if
        
        end if
      end if
    next
  
    strHTML = strHTML & gobjMTGrid.CloseGridDiv()
  end if
      

    
  strHTML = strHTML & "     </td>" & vbNewline
  strHTML = strHTML & "   </tr>" & vbNewline
  strHTML = strHTML & " </table>" & vbNewline
  strHTML = strHTML & "</td></tr>" & vbNewline 
  strHTML = strHTML & gobjMTGrid.CloseGridDiv()
  strHTML = strHTML & "<hr size=""1"" color=""gray"">" & vbNewline
  
  strHTML = strHTML & "<br><br>" & vbNewline
  'strHTML = strHTML & "<center><button class=""clsWizardWideButton"" onClick=""javascript:window.alert('This button does not really do anything. It probably never will.');"">View Full Summary</button></center>" & vbNewline
  
    'Write javascript to resize the grid
  strHTML = strHTML & "<script language=""Javascript"">strOnload = 'SizeDiv(""SummaryDiv"", ""SummaryTable"", 200);';</script>" & vbNewline

  
  WriteSummary = strHTML
	End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteSummaryText(..)                                            '
' Description : 															'
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteSummaryText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardPrompt""><b>" & FrameWork.GetDictionary("TEXT_SUMMARY") & "</b><br><br>"
 strHTML = strHTML & FrameWork.GetDictionary("TEXT_SUMMARY_DESCRIPTION1") & "<BR><BR>"
 strHTML = strHTML & FrameWork.GetDictionary("TEXT_SUMMARY_DESCRIPTION2") & "</td></tr></table>"

 WriteSummaryText = strHTML
 
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteGeneralText(..)                                            '
' Description : 															 '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteGeneralText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardNotesTD""><b>" & FrameWork.GetDictionary("TEXT_RECURRING") & "</b></td></tr></table>"
 strHTML = strHTML & "<table><tr><td class=""clsWizardNotesTD""><b>Name</b><br>" & FrameWork.GetDictionary("TEXT_NAME_TIP") & "<br><br></td></tr>"
 strHTML = strHTML & "<tr><td class=""clsWizardNotesTD""><b>Display Name</b><br>" & FrameWork.GetDictionary("TEXT_DISPLAY_NAME_TIP") & "<br><br></td></tr>"
 strHTML = strHTML & "<tr><td class=""clsWizardNotesTD""><b>Description</b><br>"& FrameWork.GetDictionary("TEXT_DESCRIPTION_TIP")  & "<br><br></td></tr>"
 strHTML = strHTML & "<tr><td class=""clsWizardNotesTD""></td></tr></table>"
 WriteGeneralText = strHTML
 
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteRecurringText(..)                                            '
' Description : 															 '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteRecurringText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardNotesTD""><b>" & FrameWork.GetDictionary("TEXT_ADD_RECURRING") & "</b></td></tr></table>"
 WriteRecurringText = strHTML
 
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteRecurringSelectTypeText(..)                                            '
' Description : 															 '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteRecurringSelectTypeText(strWizardName)

 Dim strHTML       'HTML to output
 
 strHTML = "<table><tr><td class=""clsWizardNotesTD""><b>" & FrameWork.GetDictionary("TEXT_RECURRING_CHARGE_TYPE") & "</b></td></tr></table>"
 WriteRecurringSelectTypeText = strHTML
 
End Function
 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WritePeriodText(..)                                            '
' Description : 															 '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WritePeriodText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardNotesTD""><b>" & FrameWork.GetDictionary("TEXT_RECURRING_PERIOD") & "</b></td></tr></table>"
 WritePeriodText = strHTML
 
End Function



%>
