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
' // Created by: Noah Cushing
' //
' // $Date$
' // $Author$
' // $Revision$
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
 
<%
'  <!-- #INCLUDE FILE="Styles.asp"-->
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Global Variables                                                         '
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
  'strHTML = strHTML & gobjMTForms.AddTextInputRequiredEx(strInput, session(strInput),  FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"), 50, "",sLanguageInfo)
  strHTML = strHTML & gobjMTForms.AddTextInputRequiredEx(strInput, SafeForHtmlAttr(session(strInput)),  FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"), 50, "",sLanguageInfo)
  
'  response.write "Name: " & session(strInput) & " :: " & strInput
  
  'Add the description
  strInput = strWizardName & "_description"
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")

  'strHTML = strHTML & gobjMTForms.AddTextInput(strInput, session(strInput), "Description", 25, "")
  'strHTML = strHTML & "<TEXTAREA class='clsInputBox' name='" & strInput & "' cols='52' rows='4'>"
  'SECENG: CORE-4862 Problems with Encoding on pressing Back in AddRecurringCharge/wizard.asp
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTForms.AddTextAreaInput(strInput, session(strInput),  FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION"), 52, 4, "")
  strHTML = strHTML & gobjMTForms.AddTextAreaInput(strInput, SafeForHtmlAttr(session(strInput)),  FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION"), 52, 4, "")
	
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  strHTML = strHTML &  "               <br><br>" & vbNewline


  WriteGeneralConfiguration = strHTML
End Function


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : ValidateGeneralConfiguration
' PARAMETERS		  : strWizardName : name of wizard, to retrieve session variables
' DESCRIPTION 		:
' RETURNS		      : Boolean stating whether generalconfig is valid or not
'-----------------------------------------------------------------------------------------------------------------------------------------
Function ValidateGeneralConfiguration(strWizardName)
  dim bValid
  bValid = true
  
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


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		    : GetBillingCycleBiWeeklyComboBoxContent
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
  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_EXISTING_OR_NEW_DISCOUNT"))
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")

  'strHTML = strHTML & gobjMTForms.OpenEditBoxTable("Existing Discount", "")

  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_EXISTING_DISCOUNT"))
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
   
  if true then   
  'EXISTING: Write the list of existing Discounts
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

  Set objMTFilter = Server.CreateObject(MTFilter)
  objMTFilter.Add "Kind", OPERATOR_TYPE_EQUAL, CLng(40)

  Set objPriceableItemTemplates = objMTProductCatalog.FindPriceableItemsAsRowset(objMTFilter) ' Load a Rowset from a SQL Queries and build the properties collection of the product view based on the columns of the rowset  
										
  intPropertyCount = 0
      
  redim arrProperties(2)

  do while not cbool(objPriceableItemTemplates.EOF)
  	arrProperties(0) = "<input type='radio' name='" & strWizardName & "_SELECTTEMPLATE' value='" & objPriceableItemTemplates.value("id_prop") & "'>"
  	'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
  	'Adding HTML Encoding
  	'arrProperties(1) = objPriceableItemTemplates.value("nm_name")
  	'arrProperties(2) = objPriceableItemTemplates.value("nm_desc")
  	arrProperties(1) = SafeForHtml(objPriceableItemTemplates.value("nm_name"))
  	arrProperties(2) = SafeForHtml(objPriceableItemTemplates.value("nm_desc"))
   	strHTML = strHTML & gobjMTGrid.AddGridRow(arrProperties, "", true, Array("10%","30%","60%"), "", Array("center"))
    objPriceableItemTemplates.MoveNext
  loop
       
  'Close the grid
  strHTML = strHTML & gobjMTGrid.CloseGridDiv()
  'strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  end if
  
  strHTML = strHTML & gobjMTFormsAddInputHint("<input type='radio' name='" & strWizardName & "_SELECTTEMPLATE' value='-1' checked>" &  FrameWork.GetDictionary("TEXT_CREATE_A_NEW_DISCOUNT"))

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
  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_WHAT_TYPE_DISCOUNT"))
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()

  strHTML = strHTML & gobjMTGrid.OpenGridDiv(Array(FrameWork.GetDictionary("TEXT_SELECT"), FrameWork.GetDictionary("TEXT_FIELD_NAME"), FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION")), _
                                            " id=""PropertyDiv""", _
                                            "PropertyTable", _
                                            true, _
                                            Array("10%","40%","50%"), _
                                            "", _
                                            "")

	
  Dim objMTProductCatalog
  Set objMTProductCatalog = GetProductCatalogObject
    
  Dim objPriceableItemTypes
  set objPriceableItemTypes = objMTProductCatalog.GetPriceableItemTypes()
  
										
  intPropertyCount = 0
      
	redim arrProperties(2)

	Dim objType
	for each objType in objPriceableItemTypes
  	if objType.Kind = PI_TYPE_DISCOUNT then
		  arrProperties(0) = "<input type='radio' name='" & strWizardName & "_NewType' value='" & objType.ID & "'>"
		  arrProperties(1) = objType.Name
		  arrProperties(2) = objType.Description
	
	    strHTML = strHTML & gobjMTGrid.AddGridRow(arrProperties, "", true, Array("10%","40%","50%"), "", "")
 		end if        
	next
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
	
	if (session(strWizardName & "_SELECTTEMPLATE") <> "-1") then
	  dim strPickerIDs, arrPickerIDs
	  dim objPriceableItem
		dim objMTProductCatalog
		dim intPriceableItemId
		
		Set objMTProductCatalog 								 						= GetProductCatalogObject
		strPickerIDs 													 						  = session(strWizardName & "_SELECTTEMPLATE")
		intPriceableItemId 										 						  = CLng(strPickerIDs)
		set objPriceableItem										 						= objMTProductCatalog.GetPriceableItem(intPriceableItemId)
		session(strWizardName & "_Name")        						= objPriceableItem.Name
		session(strWizardName & "_DisplayName") 						= objPriceableItem.DisplayName
		session(strWizardName & "_Description") 						= objPriceableItem.Description		 
 	End if	
  
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
 
  strHTML = strHTML & gobjMTGrid.CloseGridDiv()
                                            
  'Write out debug information
  if FrameWork.DebugMode then                                            
    'Write the general configuration information  
    strHTML = strHTML & gobjMTGrid.OpenGridDiv(Array("Debug Information"), "", "", false, "", Array(2), "")
    
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
' Function    : WriteDiscountText(..)                                            '
' Description : 															 '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteDiscountText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardNotesTD""><b>" & FrameWork.GetDictionary("TEXT_ADD_DISCOUNT") & "</b></td></tr></table>"
 WriteDiscountText = strHTML
 
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteDiscountSelectTypeText(..)                                            '
' Description : 															 '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteDiscountSelectTypeText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardNotesTD""><b>" & FrameWork.GetDictionary("TEXT_DISCOUNT_TYPE") & "</b></td></tr></table>"
 WriteDiscountSelectTypeText = strHTML
 
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteGeneralText(..)                                            '
' Description : 															 '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteGeneralText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardNotesTD""><b>" & FrameWork.GetDictionary("TEXT_DISCOUNT") & "</b></td></tr></table>"
 WriteGeneralText = strHTML
 
End Function

 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WritePeriodText(..)                                            '
' Description : 															 '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'FEAT-4216  Switch/Remove Legacy Discount and Aggregate Rating In Favor Of CDE
'Function WritePeriodText(strWizardName)
'
' Dim strHTML       'HTML to output
' strHTML = "<table><tr><td class=""clsWizardNotesTD""><b>" & FrameWork.GetDictionary("TEXT_DISC_PERIOD") & "</b></td></tr></table>"
' WritePeriodText = strHTML
 
'End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteSummaryText(..)                                            '
' Description : 															'
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteSummaryText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardPrompt""><b>" & FrameWork.GetDictionary("TEXT_SUMMARY") & "</b><br><br>"
 strHTML = strHTML & FrameWork.GetDictionary("TEXT_DISCOUNT_SUMMARY_DESCRIPTION1") & "<BR><BR>"
 strHTML = strHTML & FrameWork.GetDictionary("TEXT_DISCOUNT_SUMMARY_DESCRIPTION2") & "</td></tr></table>"

 WriteSummaryText = strHTML
 
End Function

%>
