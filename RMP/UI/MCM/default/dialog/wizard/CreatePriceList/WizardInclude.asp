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

Function gobjMTFormsAddInputHint(strInput)
gobjMTFormsAddInputHint = "<tr><td colspan=""2"" align=""center"" class=""clsWizardPrompt""><b>" & strInput & "</b></td></tr>"
End Function
%>

<%
'Function Save_RateSchedule()
'End Function

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
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_NAME"), session(strWizardName & "_Name")), _
  '                                          "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_NAME"), SafeForHtmlAttr(session(strWizardName & "_Name"))), _
                                            "", false, "", "", Array("right", "left"))
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_DISPLAY_NAME"), session(strWizardName & "_DisplayName")), _
  '                                          "", false, "", "", Array("right", "left"))
  'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION"), session(strWizardName & "_Description")), _
  '                                          "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION"), SafeForHtmlAttr(session(strWizardName & "_Description"))), _
                                            "", false, "", "", Array("right", "left"))
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_EFFECTIVEDATE_STARTDATE"), session(strWizardName & "_effectivedatestart")), _
  '                                          "", false, "", "", Array("right", "left"))
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_PRODUCT_OFFERING_AVAILABILITYDATE_STARTDATE"), session(strWizardName & "_availabilitydatestart")), _
  '                                          "", false, "", "", Array("right", "left"))

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
' Function    : WriteGeneralConfiguration                                   '
' Description : Write the general configuration page.                       '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteGeneralConfiguration(strWizardName) 
  Dim strInput      'Name of the input
  Dim strHTML

  
  strHTML = gobjMTForms.OpenEditBoxTable("", "")
  
  'Add the name field
  strInput = strWizardName & "_name"
  'SECENG: CORE-4862 Problems with Encoding on pressing Back in AddRecurringCharge/wizard.asp
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, session(strInput), FrameWork.GetDictionary("TEXT_COLUMN_NAME"), 25, "")
  strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, SafeForHtmlAttr(session(strInput)), FrameWork.GetDictionary("TEXT_COLUMN_NAME"), 25, "")

  'Add the description
  strInput = strWizardName & "_description"
  'strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")
  'SECENG: CORE-4862 Problems with Encoding on pressing Back in AddRecurringCharge/wizard.asp
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTForms.AddTextAreaInput(strInput, session(strInput),FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION"), 52, 4, "")
  strHTML = strHTML & gobjMTForms.AddTextAreaInput(strInput, SafeForHtmlAttr(session(strInput)),FrameWork.GetDictionary("TEXT_COLUMN_DESCRIPTION"), 52, 4, "")

  dim objEnum
  dim objEnumTypeItem
	dim arrItem()
	dim arrValue()
  dim intNumCurrency 
	intNumCurrency = 0
	
	redim preserve arrItem(intNumCurrency) 
  redim preserve arrValue(intNumCurrency)

	arrItem(intNumCurrency)  = ""
	arrValue(intNumCurrency) = ""
	
  set objEnum = getEnumTypes("Global/SystemCurrencies","SystemCurrencies")
  For Each objEnumTypeItem In objEnum
      redim preserve arrItem(intNumCurrency)
			redim preserve arrValue(intNumCurrency)
			arrItem(intNumCurrency) = objEnumTypeItem.Name
	    arrValue(intNumCurrency) = objEnumTypeItem.ElementAt(0)
			intNumCurrency = CLng(intNumCurrency) + 1
  Next
  
	strInput = strWizardName & "_CurrencyCode"
  strHTML = strHTML & gobjMTFormsAddInputHint("&nbsp;")
	strHTML = strHTML & gobjMTForms.AddSelectInputRequired(strInput, session(strInput), FrameWork.GetDictionary("TEXT_CURRENCY"), arrItem, arrValue,"")

  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  strHTML = strHTML &  "               <br><br>" & vbNewline
  WriteGeneralConfiguration = strHTML
End Function


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

Function ValidateGeneralConfiguration(strWizardName)
  dim bValid
  bValid = true
  
  set session(strWizardName & "__ErrorMessage") = CreateObject("Scripting.Dictionary")
  session(strWizardName & "__ErrorMessage").Add "X",FrameWork.GetDictionary("ERROR_WIZARD_NOTIFICATION")

  if session(strWizardName & "_Name") = "" then
    bValid = false
    session(strWizardName & "__ErrorMessage").Add "Name",replace(FrameWork.GetDictionary("MCM_ERROR_1001"),"[FIELD_NAME]",FrameWork.GetDictionary("TEXT_FIELD_NAME"))
  end if
 
  ValidateGeneralConfiguration = bValid
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WritePriceListText(..)                                            '
' Description : 															 '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WritePriceListText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardNotesTD""><b>" & FrameWork.GetDictionary("TEXT_NEW_PRICELIST") & "</b><br><br>"
 strHTML = strHTML & FrameWork.GetDictionary("TEXT_NEW_PRICELIST_DESCRIPTION") & "<BR><BR></td></tr></table>"

 WritePriceListText = strHTML

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
 strHTML = strHTML & FrameWork.GetDictionary("TEXT_PRICELIST_SUMMARY_DESCRIPTION1") & "<BR><BR>"
 strHTML = strHTML & FrameWork.GetDictionary("TEXT_PRICELIST_SUMMARY_DESCRIPTION2") & "</td></tr></table>"

 WriteSummaryText = strHTML
 
End Function


%>