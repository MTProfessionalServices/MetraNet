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

public const MAPPING_NORMAL = 0

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

  'strHTML = strHTML & "Picker returned [" & request("IDs") & "]<BR>"
  'strHTML  = strHTML & "query string [" & request.querystring & "]<BR>"
  '// See if we are returning from the select existing product offering picker
  if request("IDs")<>"" then

    Set objMTProductCatalog = GetProductCatalogObject

    dim strPickerIDs, arrPickerIDs
    strPickerIDs = request("IDs")

    'strHTML = strHTML & "Picker returned [" & strPickerIDs & "]<BR>"
   
    dim objProductOffering
    dim objMTProductCatalog
    dim intProductOfferingId

    intProductOfferingId = CLng(strPickerIDs)
    set objProductOffering = objMTProductCatalog.GetProductOffering(intProductOfferingId)
    
    session(strWizardName & "_CopyOfExistingId") = intProductOfferingId
    session(strWizardName & "_CopyName") = objProductOffering.Name
    
    if session(strWizardName & "_name") = "" then
        ' If this is a Partition admin, remove Partition Prefix before prefixing with "Copy of"
        If Session("isPartitionUser") Then
            session(strWizardName & "_name") = FrameWork.GetDictionary("TEXT_WIZARD_COPY_NAME_PREFIX") & " " & Replace(objProductOffering.Name, Session("topLevelAccountUserName") + ":", "")
        Else
            session(strWizardName & "_name") = FrameWork.GetDictionary("TEXT_WIZARD_COPY_NAME_PREFIX") & " " & objProductOffering.Name
        End If
    end if

    if session(strWizardName & "_displayname") = "" then
      session(strWizardName & "_displayname") = objProductOffering.DisplayName
    end if

    if session(strWizardName & "_description") = "" then
      session(strWizardName & "_description") = objProductOffering.Description
    end if
    
  end if  

  'Write javascript to populate Display Name with Name
  strHTML = strHTML &    "<script language=""javascript"">function PopulateDisplayName() {if (document.WizardForm.NewPO_displayname.value == """")  {document.WizardForm.NewPO_displayname.value = document.WizardForm.NewPO_name.value  }    }	</script>"


  'Write the buttons for creating copy of existing Product Offering
   strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")

  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_WIZARD_PROMPT_CREATE_COPY_OF_EXISTING"))
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable() 

  strHTML = strHTML & "<div align='center'><button class=""clsButtonBlueLarge"" style=""vertical-align: middle;"" onclick=""window.open('/mcm/default/dialog/ProductOffering.Picker.asp?NextPage=Welcome.asp&MonoSelect=TRUE&OptionalColumn=nm_name&Parameters=POMode|source','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes'); return false;"">" & FrameWork.GetDictionary("TEXT_WIZARD_BUTTON_CREATE_COPY_OF_EXISTING") & "&nbsp;<IMG align=middle border=0 src=""/mcm/default/localized/us/images/icons/arrowSelect.gif""></button></div>"
  strHTML = strHTML & "<div align='center'><button class=""clsButtonBlueLarge"" style=""vertical-align: middle;"" onclick=""window.open('/mcm/default/dialog/ProductOffering.Picker.asp?NextPage=Welcome.asp&MonoSelect=TRUE&OptionalColumn=nm_name&Master=TRUE&Parameters=POMode|source','', 'height=100,width=100, resizable=yes, scrollbars=yes, status=yes'); return false;"">" & FrameWork.GetDictionary("TEXT_WIZARD_BUTTON_CREATE_COPY_OF_MASTER") & "&nbsp;<IMG align=middle border=0 src=""/mcm/default/localized/us/images/icons/arrowSelect.gif""></button></div>"
  
  strHTML = strHTML &  "<br><br>" & vbNewline

  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_WIZARD_PROMPT_CREATE_NEW_PRODUCT_OFFERING"))
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")
  
  'Add the name field
  strInput = strWizardName & "_name"
  'SECENG: CORE-4862 Problems with Encoding on pressing Back in AddRecurringCharge/wizard.asp
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, session(strInput), FrameWork.GetDictionary("TEXT_FIELD_NAME"), 50, "onChange=""javascript:PopulateDisplayName();""")
  strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, SafeForHtmlAttr(session(strInput)), FrameWork.GetDictionary("TEXT_FIELD_NAME"), 50, "onChange=""javascript:PopulateDisplayName();""")

  strInput = strWizardName & "_displayname"
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")
  
  dim sLanguageInfo
  sLanguageInfo = Framework.GetLanguageDisplayInformation(Session("FRAMEWORK_SECURITY_SESSION_CONTEXT_SESSION_NAME").LanguageId)
  'SECENG: CORE-4862 Problems with Encoding on pressing Back in AddRecurringCharge/wizard.asp
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTForms.AddTextInputRequiredEx(strInput, session(strInput), FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"), 50, "",sLanguageInfo)
  strHTML = strHTML & gobjMTForms.AddTextInputRequiredEx(strInput, SafeForHtmlAttr(session(strInput)), FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"), 50, "",sLanguageInfo)
  
  'Add the description
  strInput = strWizardName & "_description"
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")

  'strHTML = strHTML & gobjMTForms.AddTextInput(strInput, session(strInput), "Description", 25, "")
  'strHTML = strHTML & "<TEXTAREA class='clsInputBox' name='" & strInput & "' cols='52' rows='4'>"
  'SECENG: CORE-4862 Problems with Encoding on pressing Back in AddRecurringCharge/wizard.asp
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTForms.AddTextAreaInput(strInput, session(strInput), FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION"), 50, 4, "")
  strHTML = strHTML & gobjMTForms.AddTextAreaInput(strInput, SafeForHtmlAttr(session(strInput)), FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION"), 50, 4, "")
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable() 

  WriteGeneralConfiguration = strHTML
End Function

Function ValidateGeneralConfiguration(strWizardName)

  dim bValid, v
  
  bValid = true
  
  Set session(strWizardName & "__ErrorMessage") = CreateObject("Scripting.Dictionary")
  
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

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteDateConfiguration                                   '
' Description : Write the date configuration page.                       '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteDateConfiguration(strWizardName) 

  Dim strInput      'Name of the input
  Dim strHTML

  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
  
  'Add the name field
  strInput = strWizardName & "_effectivedatestart"
  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_WIZARD_PROMPT_EFFECTIVEDATE"))
    
  'strHTML = strHTML & gobjMTForms.AddDateInput(strInput, session(strInput), FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_EFFECTIVEDATE_STARTDATE"), 25, "<a href='#' onClick=""getCalendarForStartDate(document.WizardForm.NewPO_effectivedatestart);return false;""><img localized='true' src='/mcm/default/localized/us/images/popupcalendar.gif' width='16' height='16' border='0'></a>")
strHTML = strHTML & "<tr><TD class='captionEW'><MDMLABEL Name='StartDate' type='Caption'>Effective Start Date</MDMLABEL>:&nbsp;&nbsp;</TD><TD><INPUT type='text' class='fieldRequired' size='20' id='StartDate' name='StartDate'><img style='cursor:pointer'  id='openCalendarStartDate' src='/mam/default/localized/us/images/popupcalendar.gif' width=16 height=16 border=0 alt=''/><div id='divStartDate' style='position:absolute'></div><script language='javascript' type='text/javascript'>generateDatePicker('StartDate','" & FrameWork.GetDictionary("JS_DATE_TIME_RENDERER") & "');</script></TD></tr>"

If Not(IsNull(Request.Form("StartDate"))) Then
    If mcm_IsDate(Request.Form("StartDate")) Then
       session(strInput) = CDate(Request.Form("StartDate"))        
   End If
End If

 ' strInput = strWizardName & "_availabilitydatestart"
 ' strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")
 ' strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_WIZARD_PROMPT_AVAILABILITYDATE"))
 ' strHTML = strHTML & gobjMTForms.AddDateInput(strInput, session(strInput), FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_AVAILABILITYDATE_STARTDATE"), 25, "<a href='#' onClick=""getCalendarForStartDate(document.WizardForm.NewPO_availabilitydatestart);return false""><img localized='true' src='/mcm/default/localized/us/images/popupcalendar.gif' width='16' height='16' border='0'></a>")
    
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  

  strHTML = strHTML &  "               <br><br>" & vbNewline


  WriteDateConfiguration = strHTML
End Function

Function ValidateDateConfiguration(strWizardName)

  dim effDate

  ValidateDateConfiguration = FALSE  

  set session(strWizardName & "__ErrorMessage") = CreateObject("Scripting.Dictionary")  

  If Not(IsNull(Request.Form("StartDate"))) Then       
        If Request.Form("StartDate") = "" Then
           Session(strWizardName & "_effectivedatestart")= Request.Form("StartDate")
           effDate = Session(strWizardName & "_effectivedatestart")              
        ElseIf mcm_IsDate(Request.Form("StartDate")) Then
           Session(strWizardName & "_effectivedatestart")= CDate(Request.Form("StartDate")) 
           effDate = Session(strWizardName & "_effectivedatestart") 
        Else
           Session(strWizardName & "__ErrorMessage").Add "Name", FrameWork.GetDictionary("MCM_ERROR_STARTDATE_INVALID")
           Session(strWizardName & "_effectivedatestart") = ""
           Exit Function ' Error
        End If     
  End If
 

  If Len(effDate) Then  
      If Not mcm_IsDate(effDate) Then      
          Session(strWizardName & "__ErrorMessage").Add "Name", FrameWork.GetDictionary("MCM_ERROR_STARTDATE_INVALID")
           Session(strWizardName & "_effectivedatestart") = ""
          Exit Function ' Error
      End If  
  End If   
  ValidateDateConfiguration = TRUE
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function      : WriteIncludedUsage()                                      '
' Description   :                                                           '
' Inputs        : strWizardName -- The name of the wizard.                  '
' Outputs       : none                                                      '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteIncludedUsage(strWizardName)
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


  
  
  ' Move this to a 'start' routine eventually
  dim bCreateNewPO
  
  if IsObject(session(strWizardName & "ProductOffering")) then
  	if session(strWizardName & "ProductOffering") is nothing then
		bCreateNewPO = true
	else  
		bCreateNewPO = false
	end if
  else
  	bCreateNewPO = true
  end if
  
 Dim objMTProductCatalog 
 if bCreateNewPO then
  Set objMTProductCatalog = GetProductCatalogObject
		
		  
	set session(strWizardName & "ProductOffering") = objMTProductCatalog.CreateProductOffering
 end if
  
  Set objNewProductOffering = session(strWizardName & "ProductOffering")
  'objNewProductOffering.AddPriceableItem objMTProductCatalog.GetPriceableItemByName("Conferencing").ID

  '// See if we are returning from the picker and need to add items to this product offering
  if request("PickerIDs")<>"" then

    Set objMTProductCatalog = GetProductCatalogObject

    dim strPickerIDs, arrPickerIDs
    strPickerIDs = request("PickerIDs")
    arrPickerIDs = Split(strPickerIDs, ",", -1, 1)
    
    'strHTML = strHTML & "Picker returned [" & strPickerIDs & "]<BR>"
    
    dim intPriceableItemId
    dim objPriceableItem
    for i=0 to ubound(arrPickerIDs)
      intPriceableItemId = CLng(arrPickerIDs(i))
      'response.write("Adding PI [" & intPriceableItemId & "]<BR>")
      set objPriceableItem = objMTProductCatalog.GetPriceableItem(intPriceableItemId)
      objNewProductOffering.AddPriceableItem objPriceableItem
    next
    
  end if  
  
  
  dim objPriceableItems
  set objPriceableItems = objNewProductOffering.GetPriceableItems
	
  
  if objPriceableItems.count=0 then ' is nothing then
    strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
    strHTML = strHTML & gobjMTFormsAddInputHint("Would you like to add Usage Charges to this Product Offering?")
    strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  else
      'Create the edit table
      'Create the grid
      strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
      strHTML = strHTML & gobjMTFormsAddInputHint("This Product Offering Has The Following Usage Charges")
      strHTML = strHTML & gobjMTForms.CloseEditBoxTable()

      strHTML = strHTML & gobjMTGrid.OpenGridDiv(Array("Name", "Description"), _
                                                " id=""PropertyDiv""", _
                                                "PropertyTable", _
                                                true, _
                                                Array("50%","50%"), _
                                                "", _
                                                "")
    
    											
      dim objPI
      intPropertyCount = 0
      
      redim arrProperties(1)
      
      for each objPI in objPriceableItems
         
    	
    	'arrProperties(0) = objPI.Kind
    	arrProperties(0) = objPI.Name
    	arrProperties(1) = objPI.Description
    	
    '	response.write(objPI.Kind & "<BR>")
    	
    	strHTML = strHTML & gobjMTGrid.AddGridRow(arrProperties, "", true, Array("50%","50%"), "", "")
    '	response.end
      next
      
      
      
      'Close the grid
      strHTML = strHTML & gobjMTGrid.CloseGridDiv()
      strHTML = strHTML & "<script language=""Javascript"">strOnload = 'SizeDiv(""PropertyDiv"", ""PropertyTable"", 200);';</script>" & vbNewline
  end if
  

  'Write the buttons for adding priceable items

  strHTML = strHTML & "<br><br><div align='center'><button class=""clsButtonBlueSmall""  onClick=""javascript:window.open('/mcm/default/dialog/PriceAbleItem.Picker.asp?Kind=10&Title=TEXT_SELECT_USAGE_PRICEABLE_ITEM', '_blank', 'height=400,width=600,resizable=yes,scrollbars=yes'); return false;"">Add</button></div>"
    
  WriteIncludedUsage = strHTML
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteCurrencyConfiguration                                   '
' Description : Write the currency select page                       '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteCurrencyConfiguration(strWizardName)
  Dim strInput      'Name of the input
  Dim strHTML
  Dim objEnum
  Dim objEnumTypeItem
	Dim arrItem()
	Dim arrValue()
  Dim intNumCurrency
  
	intNumCurrency = 0
	
	redim preserve arrItem(intNumCurrency) 
  redim preserve arrValue(intNumCurrency)

	arrItem(intNumCurrency)  = ""
	arrValue(intNumCurrency) = ""

  'This is the name of the property on the session
 	strInput = strWizardName & "_CurrencyCode"
  
  ' First, determine if this is a copy. If so, check business rules regarding currency conversion.
  dim prompt_text
  dim disable_txt
  prompt_text = FrameWork.GetDictionary("TEXT_WIZARD_PROMPT_CURRENCY")
  if session(strWizardName & "_CopyOfExistingId") <> "" then
    
    dim objMTProductCatalog  
    dim objProductOffering
    dim objPriceList
    
    Set objMTProductCatalog = GetProductCatalogObject
    Set objProductOffering = objMTProductCatalog.GetProductOffering(session(strWizardName & "_CopyOfExistingId"))
    Set objPriceList = objMTProductCatalog.GetPriceList(objProductOffering.NonSharedPriceListID)

    if objProductOffering.GetCountOfPriceListMappings(MAPPING_NORMAL) > 0 then
      prompt_text = FrameWork.GetDictionary("TEXT_WIZARD_PROMPT_CURRENCY_ALT1")
      disable_txt = "disabled"
      session(strWizardName & "_CurrencyCode") = objProductOffering.GetCurrencyCode()
    elseif objPriceList.GetRateScheduleCount() > 0 then
      prompt_text = FrameWork.GetDictionary("TEXT_WIZARD_PROMPT_CURRENCY_ALT2")
      disable_txt = "disabled"
      session(strWizardName & "_CurrencyCode") = objProductOffering.GetCurrencyCode()     
    end if
  end if
	
  'Load proper enum types
  set objEnum = getEnumTypes("Global/SystemCurrencies", "SystemCurrencies")
  For Each objEnumTypeItem In objEnum
      redim preserve arrItem(intNumCurrency)
			redim preserve arrValue(intNumCurrency)
			arrItem(intNumCurrency) = objEnumTypeItem.Name
	    arrValue(intNumCurrency) = objEnumTypeItem.ElementAt(0)
			intNumCurrency = CLng(intNumCurrency) + 1
  Next
  
  'Construct html
  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
  strHTML = strHTML & gobjMTFormsAddInputHint(prompt_text)
  strHTML = strHTML & "<td><tr>&nbsp;</tr></td>"
	strHTML = strHTML & gobjMTForms.AddSelectInputRequired(strInput, session(strInput), FrameWork.GetDictionary("TEXT_CURRENCY"), arrItem, arrValue, disable_txt)
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  strHTML = strHTML &  "<br><br>" & vbNewline  
  
  WriteCurrencyConfiguration = strHTML
End Function

Function ValidateCurrencyConfiguration(strWizardName)
  ValidateCurrencyConfiguration = TRUE
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
   strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_NAME"), SafeForHtmlAttr(session(strWizardName & "_Name"))), _
                                            "", false, "", "", Array("right", "left"))

  'Write copy message if we are copying an existing
  if session(strWizardName & "_CopyOfExistingId") <> "" then
      'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
      'Adding HTML Encoding
      strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_WIZARD_SUMMARY_COPY_NAME"), SafeForHtmlAttr(session(strWizardName & "_CopyName"))), _
                                            "", false, "", "", Array("right", "left"))
  end if
  'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
  'Adding HTML Encoding  
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"), SafeForHtmlAttr(session(strWizardName & "_DisplayName"))), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION"), SafeForHtmlAttr(session(strWizardName & "_Description"))), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_EFFECTIVEDATE_STARTDATE"), SafeForHtmlAttr(session(strWizardName & "_effectivedatestart"))), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_CURRENCY"), SafeForHtmlAttr(session(strWizardName & "_CurrencyCode"))), _
                                            "", false, "", "", Array("right", "left"))

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

Public Function getEnumTypes(strNameSpace, strEnumTypeName) ' As Object
      
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

%>
