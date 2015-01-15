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
  'strHTML = strHTML & gobjMTForms.AddTextInputRequiredEx(strInput, session(strInput),FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"), 50, "",sLanguageInfo)
  strHTML = strHTML & gobjMTForms.AddTextInputRequiredEx(strInput, SafeForHtmlAttr(session(strInput)),FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"), 50, "",sLanguageInfo)
  
'  response.write "Name: " & session(strInput) & " :: " & strInput
  
  'Add the description
  strInput = strWizardName & "_description"
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")

  'strHTML = strHTML & gobjMTForms.AddTextInput(strInput, session(strInput), "Description", 25, "")
  'strHTML = strHTML & "<TEXTAREA class='clsInputBox' name='" & strInput & "' cols='52' rows='4'>"
  'SECENG: CORE-4862 Problems with Encoding on pressing Back in AddRecurringCharge/wizard.asp
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTForms.AddTextAreaInput(strInput, session(strInput), FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION"), 52, 4, "")
  strHTML = strHTML & gobjMTForms.AddTextAreaInput(strInput, SafeForHtmlAttr(session(strInput)), FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION"), 52, 4, "")
  
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  

  strHTML = strHTML &  "               <br><br>" & vbNewline


  WriteGeneralConfiguration = strHTML
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteEventConfiguration                                   '
' Description : Write the general configuration page.                       '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteEventConfiguration(strWizardName) 
  Dim strInput      'Name of the input
  Dim strHTML

  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
  
  strHTML = strHTML & "<center><B>" & FrameWork.GetDictionary("TEXT_WHAT_EVENT") & "<B></center>"
  strHTML = strHTML &  "               <br><br>" & vbNewline

  strInput = strWizardName & "_NewEvent"
  strHTML = strHTML & "<tr><td colspan=""15""></td><td align=""Left""><table>"
  strHTML = strHTML & gobjMTForms. AddRadioInput(strInput,  session(strInput), "", array(FrameWork.GetDictionary("TEXT_SUBSCRIPTION")), array("1"), 1, " checked")
  strHTML = strHTML & "</table></td></tr>"
  
  strInput = strWizardName & "_NewEvent"
  strHTML = strHTML & "<tr><td colspan=""15""></td><td align=""Left""><table>"
  strHTML = strHTML & gobjMTForms. AddRadioInput(strInput,  session(strInput), "", array(FrameWork.GetDictionary("TEXT_UNSUBSCRIPTION")), array("2"), 1, "")
  strHTML = strHTML & "</table></td></tr>"
	
  'strInput = strWizardName & "_NewEvent"
  'strHTML = strHTML & "<tr><td colspan=""15""></td><td align=""Left""><table>"
  'strHTML = strHTML & gobjMTForms. AddRadioInput(strInput,  session(strInput), "",array(FrameWork.GetDictionary("TEXT_SUBSCRIPTION_CHANGE")), array("3"), 1, "")
  'strHTML = strHTML & "</table></td></tr>"
 
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  strHTML = strHTML &  "               <br><br>" & vbNewline

  WriteEventConfiguration= strHTML
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
  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_EXISTING_OR_NEW_NON_REC_CHARGE"))
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")

  'strHTML = strHTML & gobjMTForms.OpenEditBoxTable("Existing Recurring Charge", "")


  strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_EXISTING_NON_REC_CHARGE"))
   strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
   
  if true then   
 'EXISTING: Write the list of existing recurring charges
  strHTML = strHTML & gobjMTGrid.OpenGridDiv(Array(FrameWork.GetDictionary("TEXT_SELECT"), FrameWork.GetDictionary("TEXT_FIELD_NAME"), FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION")), _
                                            " id=""PropertyDiv""", _
                                            "PropertyTable", _
                                            true, _
                                            Array("65","120","180"), _
                                            "", _
                                            "")

											
        
        Dim objPriceableItemTemplates
        Dim objMTFilter
        'set objPriceableItemTemplates = objMTProductCatalog.GetPriceableItemTypes()

        Set objMTFilter = Server.CreateObject(MTFilter)
        objMTFilter.Add "Kind", OPERATOR_TYPE_EQUAL, CLng(30)
  
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
   	strHTML = strHTML & gobjMTGrid.AddGridRow(arrProperties, "", true, Array("65","120","180"), "", Array("center"))
   
    objPriceableItemTemplates.MoveNext

  loop

       
  'Close the grid
  strHTML = strHTML & gobjMTGrid.CloseGridDiv()
  'strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  end if
 
  strHTML = strHTML & gobjMTFormsAddInputHint("<input type='radio' name='" & strWizardName & "_SELECTTEMPLATE' value='-1' checked>" &  FrameWork.GetDictionary("TEXT_ADD_NEW_NON_RECURRING_CHARGE"))

  'Set current selection
  strHTML = strHTML & "<script language=""Javascript"" src=""../../../lib/utilForm.js""></script>"
  strHTML = strHTML & "<script language=""Javascript"">setRadioSelection(document.WizardForm." & strWizardName & "_SELECTTEMPLATE, '" & session(strWizardName & "_SELECTTEMPLATE") & "');</script>"
 
  strHTML = strHTML & "<script language=""Javascript"">strOnload = 'SizeDiv(""PropertyDiv"", ""PropertyTable"", 100);';</script>" & vbNewline
  
  WriteNewOrExisting = strHTML
End Function


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
      strHTML = strHTML & gobjMTFormsAddInputHint(FrameWork.GetDictionary("TEXT_WHAT_TYPE_NON_REC_CHARGE"))
      strHTML = strHTML & gobjMTForms.CloseEditBoxTable()

      strHTML = strHTML & gobjMTGrid.OpenGridDiv(Array(FrameWork.GetDictionary("TEXT_SELECT"), FrameWork.GetDictionary("TEXT_FIELD_NAME"), FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION")), _
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
  
  'response.write("There are [" & objPriceableItemTypes.count & "] priceable item types.<BR>")
  
										
      intPropertyCount = 0
      
      redim arrProperties(2)
      
		  Dim objType
		  for each objType in objPriceableItemTypes
    		if objType.Kind = PI_TYPE_NON_RECURRING then
			  	arrProperties(0) = "<input type='radio' name='" & strWizardName & "_NewType' value='" & objType.ID & "'>"
	    	  arrProperties(1) = objType.DisplayNames.GetMapping(Framework.GetLanguageCodeForCurrentUser()) 
  	  	  arrProperties(2) = objType.Description
    		  strHTML = strHTML & gobjMTGrid.AddGridRow(arrProperties, "", true, Array("65","120","180"), "", "")
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
  dim strEvent 
  
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
		   session(strWizardName & "_NewEvent")	 							= objPriceableItem.NonRecurringChargeEvent
  	End if	
	
	
  ' See if we are adding an existing
'  if session(strWizardName & "_SELECTTEMPLATE") =  "-1" then
  	' In General Information if i put _new event,it is displaying event 1 or 2.for displaying equivalent text 1 - subscription 2-unsubscription.
  	If clng(session(strWizardName & "_NewEvent")) = 1 then
  			 strEvent = FrameWork.GetDictionary("TEXT_SUBSCRIPTION")
  	Else
  		   strEvent = FrameWork.GetDictionary("TEXT_UNSUBSCRIPTION")		 
    End if		 
	'end if
  
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
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_EVENT"),strEvent), _
  '                                          "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_NAME"), SafeForHtmlAttr(session(strWizardName & "_Name"))), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"), SafeForHtmlAttr(session(strWizardName & "_DisplayName"))), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION"), SafeForHtmlAttr(session(strWizardName & "_Description"))), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_EVENT"),strEvent), _
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


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteNonRecurringText(..)                                            '
' Description : 															 '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteNonRecurringText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardNotesTD""><b>" & FrameWork.GetDictionary("TEXT_ADD_NON_RECURRING") & "</b></td></tr></table>"
 WriteNonRecurringText = strHTML
 
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteNonRecurringSelectTypeText(..)                                            '
' Description : 															 '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteNonRecurringSelectTypeText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardNotesTD""><b>" & FrameWork.GetDictionary("TEXT_NON_RECURRING_CHARGE_TYPE") & "</b></td></tr></table>"
 WriteNonRecurringSelectTypeText = strHTML
 
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteGeneralText(..)                                            '
' Description : 															 '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteGeneralText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardNotesTD""><b>" & FrameWork.GetDictionary("TEXT_NON_RECURRING") & "</b></td></tr></table>"
 strHTML = strHTML & "<table><tr><td class=""clsWizardNotesTD""><b>Name</b><br>" & FrameWork.GetDictionary("TEXT_NON_REC_NAME_TIP") & "<br><br></td></tr>"
 strHTML = strHTML & "<tr><td class=""clsWizardNotesTD""><b>Display Name</b><br>" & FrameWork.GetDictionary("TEXT_NON_REC_DISPLAY_NAME_TIP") & "<br><br></td></tr>"
 strHTML = strHTML & "<tr><td class=""clsWizardNotesTD""><b>Description</b><br>"& FrameWork.GetDictionary("TEXT_NON_REC_DESCRIPTION_TIP")  & "<br><br></td></tr>"
 strHTML = strHTML & "<tr><td class=""clsWizardNotesTD""></td></tr></table>"

 WriteGeneralText = strHTML
 
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteGeneralText(..)                                            '
' Description : 															 '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteEventText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardNotesTD""><b>" & FrameWork.GetDictionary("TEXT_EVENT") & "</b></td></tr></table>"
 WriteEventText = strHTML
 
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
 strHTML = strHTML & FrameWork.GetDictionary("TEXT_NON_REC_SUMMARY_DESCRIPTION1") & "<BR><BR>"
 strHTML = strHTML & FrameWork.GetDictionary("TEXT_NON_REC_SUMMARY_DESCRIPTION2") & "</td></tr></table>"

 WriteSummaryText = strHTML
 
End Function


%>
