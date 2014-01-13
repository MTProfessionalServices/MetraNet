<% 
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998 - 2002 by MetraTech Corporation
'  All rights reserved.
' 
'  THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'  NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'  example, but not limitation, MetraTech Corporation MAKES NO
'  REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'  PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'  DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'  COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' 
'  Title to copyright in this software and any associated
'  documentation shall at all times remain with MetraTech Corporation,
'  and USER agrees to preserve the same.
'
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
' DIALOG	    : WizardInclude.asp
' DESCRIPTION	: 
' AUTHOR	    : K. Boucher
' VERSION	    : V3.5
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%>
  <!-- #INCLUDE FILE="../../../../mcmIncludes.asp" -->
  <!-- #INCLUDE FILE="../FormsClass.asp" -->
  <!-- #INCLUDE FILE="../GridClass.asp" -->
  <!-- #INCLUDE FILE="../Styles.asp"-->
<%

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Global Variables                                                         '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteCounterParameterText(..)                               '
' Description : 															                              '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteCounterParameterText(strWizardName)

  Dim strHTML       'HTML to output
  strHTML = "<table><tr><td class=""clsWizardNotesTD""><br>"
  strHTML = strHTML & "<b>" & "Name"        & "</b><br>Each Counter Parameter has a unique name.<br><br>"
  strHTML = strHTML & "<b>" & "Display Name"& "</b><br>Name displayed to users.<br><br>"
  strHTML = strHTML & "<b>" & "Group"       & "</b><br>Optional group to be associated with such as ""Charge"".<br><br>" 
  strHTML = strHTML & "<b>" & "Description" & "</b><br>The description of the Counter Parameter used only for reference.<br><br>" 
  strHTML = strHTML & "</td></tr></table>"
  
  WriteCounterParameterText = strHTML

End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteCounterParameterConfiguration(..)                      '
' Description :                                                             '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteCounterParameterConfiguration(strWizardName)
  Dim strHTML       'HTML to output
  Dim strInput
  
  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
  
  'Add name 
  strInput = strWizardName & "_name"
  strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, session(strInput), "Name:", 20, "")

  'Add display name 
  strInput = strWizardName & "_displayname"
  strHTML = strHTML & gobjMTForms.AddTextInputRequired(strInput, session(strInput), "Display Name:", 20, "")

  'Add group
  strInput = strWizardName & "_group"
  strHTML = strHTML & gobjMTForms.AddTextInput(strInput, session(strInput), "Group:", 20, "")

  'Add description
  strInput = strWizardName & "_description"
  strHTML = strHTML & gobjMTForms.AddTextAreaInput(strInput, session(strInput), "Description:", 50, 4, "")
  
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
    
  WriteCounterParameterConfiguration = strHTML
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : ValidateCounterParameterConfiguration(..)                   '
' Description :                                                             '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ValidateCounterParameterConfiguration(strWizardName)
  dim bValid
  bValid = true
  
  set session(strWizardName & "__ErrorMessage") = CreateObject("Scripting.Dictionary")
  session(strWizardName & "__ErrorMessage").Add "X",FrameWork.GetDictionary("ERROR_WIZARD_NOTIFICATION")

  if session(strWizardName & "_Name") = "" then
    bValid = false
    session(strWizardName & "__ErrorMessage").Add "Name", replace(FrameWork.GetDictionary("MCM_ERROR_1001"),"[FIELD_NAME]",FrameWork.GetDictionary("TEXT_FIELD_NAME"))
  elseif session(strWizardName & "_displayname") = "" then
    bValid = false
    session(strWizardName & "__ErrorMessage").Add "Display Name",replace(FrameWork.GetDictionary("MCM_ERROR_1001"),"[FIELD_NAME]", "Display Name")
  else
    session(strWizardName & "_MTCounterParameter").Name        = session(strWizardName & "_Name") 
    session(strWizardName & "_MTCounterParameter").DisplayName = session(strWizardName & "_DisplayName") 
    session(strWizardName & "_MTCounterParameter").Description = session(strWizardName & "_Description") 
  end if
 
  ValidateCounterParameterConfiguration = bValid
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WritePITypeText(..)                                         '
' Description : 															                              '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WritePITypeText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardPrompt""><b><br>" & "Priceable Item Type" & "</b><br>"
 strHTML = strHTML & "Select the Priceable Item Type you want to choose the Counter Parameter property from.<br><br>"
 strHTML = strHTML & "</td></tr></table>"

 WritePITypeText = strHTML
 
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WritePITypeConfiguration(..)                                '
' Description : 															                              '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WritePITypeConfiguration(strWizardName)

  Dim strHTML       'HTML to output
  Dim strInput
  Dim objProductCatalog 
  Dim colPriceableItemTypes
  Dim PIType
  Dim i
  Dim arrPITypes()
  
  Set objProductCatalog = GetProductCatalogObject
  Set colPriceableItemTypes = objProductCatalog.GetPriceableItemTypes()

  i = 0
  For Each PIType in colPriceableItemTypes
    ReDim Preserve arrPITypes(i)   
    arrPITypes(i) = PIType.name
    i = i + 1
  Next
      
  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
  
  'Add PIType
  strInput = strWizardName & "_PIType"
  strHTML = strHTML & gobjMTForms.AddSelectInputRequired(strInput, session(strInput), "Pricable Item Type:", arrPITypes, arrPITypes, "")
  
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  
  WritePITypeConfiguration = strHTML
 
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WritePropertyText(..)                                       '
' Description : 															                              '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WritePropertyText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardPrompt""><b><br>" & "Property" & "</b><br>"
 strHTML = strHTML & "Here you specify the property to be associated with this Counter Parameter.<br><br>"
 strHTML = strHTML & "</td></tr></table>"

 WritePropertyText = strHTML
 
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WritePropertyConfiguration(..)                              '
' Description : 															                              '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WritePropertyConfiguration(strWizardName)

  Dim strHTML       'HTML to output
  Dim strInput
  Dim objProductCatalog 
  Dim colPriceableItemTypes
  Dim colProperties
  Dim PIType
  Dim i
  Dim prop
  Dim arrProperties()
  
  Set objProductCatalog = GetProductCatalogObject
  Set PIType = objProductCatalog.GetPriceableItemTypeByName(Session(strWizardName & "_PIType"))
  Set colProperties = PIType.GetProductViewObject().GetProperties()
 
  i = 0 
  For Each prop in colProperties
    ReDim Preserve arrProperties(i) 
    arrProperties(i) = prop.DN  
    i = i + 1
  Next
      
  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
  
  'Add Property 
  strInput = strWizardName & "_property"
  strHTML = strHTML & gobjMTForms.AddSelectInputRequired(strInput, session(strInput), "Property:", arrProperties, arrProperties, "")
  
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  
  WritePropertyConfiguration = strHTML
 
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : ValidatePropertyConfiguration(..)                           '
' Description :                                                             '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function ValidatePropertyConfiguration(strWizardName)
  dim bValid
  bValid = true
  
  set session(strWizardName & "__ErrorMessage") = CreateObject("Scripting.Dictionary")
  session(strWizardName & "__ErrorMessage").Add "X",FrameWork.GetDictionary("ERROR_WIZARD_NOTIFICATION")

  session(strWizardName & "_MTCounterParameter").Value = "metratech.com/" & session(strWizardName & "_PIType") & "/" & session(strWizardName & "_Property")
 
  ValidatePropertyConfiguration = bValid
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WritePredicateText(..)                                      '
' Description : 															                              '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WritePredicateText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardPrompt""><b><br>" & "Predicate" & "</b><br>"
 strHTML = strHTML & "You may choose to configure an optional predicate which will determine when to count this parameter.<br><br>"
 strHTML = strHTML & "</td></tr></table>"

 WritePredicateText = strHTML
 
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WritePredicateConfiguration(..)                             '
' Description : 															                              '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WritePredicateConfiguration(strWizardName)

  Dim strHTML       'HTML to output
  Dim objPredicate
  Dim objEnumTypeconfig ' As Object    

  Set objEnumTypeconfig   = server.CreateObject("Metratech.MTEnumConfig.1")
  
  strHTML = strHTML & gobjMTForms.OpenEditBoxTable("", "")
  
  ' List predicates
  If session(strWizardName & "_MTCounterParameter").Predicates.Count = 0 Then
    strHTML = strHTML & "<tr><td class=""clsWizardPrompt"">There is currently no predicate configured.<br><br></td></tr>"
  Else
      strHTML = strHTML & "<tr><td class=""clsWizardPrompt"">Predicate:<br></td></tr>"
      For Each objPredicate in session(strWizardName & "_MTCounterParameter").Predicates
        strHTML = strHTML & "<tr><td class ='clsWizardPromptOdd'>" & objPredicate.ProductViewProperty.DN 
  			Select Case objPredicate.Operator
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_EQUAL
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>=" 
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_NOT_EQUAL
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&lt;&gt;"  
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&gt;" 
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER_EQUAL
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&gt;=" 
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&lt;" 
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS_EQUAL
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&lt;=" 
          End Select          
        If objPredicate.ProductViewProperty.PropertyType = 8 Then
          strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>" & objEnumTypeconfig.GetEnumWithValue(objPredicate.ProductViewProperty.EnumNamespace, objPredicate.ProductViewProperty.EnumEnumeration, objPredicate.value) & "</td></tr>"    
        Else
          strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>" & objPredicate.value & "</td></tr>"            
        End If
      Next
  End If  
    
  'Configure button
  strHTML = strHTML & "<tr><td align='center'><br><button class='clsButtonBlueXLarge' name='configurePredicate' onClick=""javascript:OpenDialogWindow('ConfigurePredicate.asp', 'height=400,width=600,resizable=yes,scrollbars=yes');"">Configure Predicate</button></td></tr>"
  strHTML = strHTML & gobjMTForms.CloseEditBoxTable()
  
  WritePredicateConfiguration = strHTML
 
End Function
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteSummaryText(..)                                        '
' Description : 															                              '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteSummaryText(strWizardName)

 Dim strHTML       'HTML to output
 strHTML = "<table><tr><td class=""clsWizardPrompt""><b>" & "Counter Parameter Summary" & "</b><br><br>"
 strHTML = strHTML & "Here is a summary of the Counter Parameter you are about to create.<br><br>"
 strHTML = strHTML & "Click 'Finish' to create this Counter Parameter.<br><br>"
 strHTML = strHTML & "</td></tr></table>"

 WriteSummaryText = strHTML
 
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : WriteSummary(..)                                            '
' Description : 															                              '
' Inputs      : strWizardName -- Name of the wizard                         '
' Outputs     : HTML                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function WriteSummary(strWizardName)

  Dim strHTML       'HTML to output
  Dim objEnumTypeconfig ' As Object    

  Set objEnumTypeconfig   = server.CreateObject("Metratech.MTEnumConfig.1")
  
  strHTML = strHTML & gobjMTGrid.OpenGridDiv(Array("Counter Parameter Summary"), "", "", false, "", Array(2), "")
  'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
  'Adding HTML Encoding
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_NAME"), session(strWizardName & "_Name")), _
  '                                          "", false, "", "", Array("right", "left"))
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array("Display Name", session(strWizardName & "_DisplayName")), _
  '                                          "", false, "", "", Array("right", "left"))
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array("Group", session(strWizardName & "_Group")), _
  '                                          "", false, "", "", Array("right", "left"))
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION"), session(strWizardName & "_Description")), _
  '                                          "", false, "", "", Array("right", "left"))
  'strHTML = strHTML & gobjMTGrid.AddGridRow(Array("Property", session(strWizardName & "_PIType") & "/" & session(strWizardName & "_Property")), _
  '                                          "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_NAME"), SafeForHtmlAttr(session(strWizardName & "_Name"))), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array("Display Name", SafeForHtmlAttr(session(strWizardName & "_DisplayName"))), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array("Group", session(strWizardName & "_Group")), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array(FrameWork.GetDictionary("TEXT_FIELD_DESCRIPTION"), SafeForHtmlAttr(session(strWizardName & "_Description"))), _
                                            "", false, "", "", Array("right", "left"))
  strHTML = strHTML & gobjMTGrid.AddGridRow(Array("Property", session(strWizardName & "_PIType") & "/" & SafeForHtmlAttr(session(strWizardName & "_Property"))), _
                                            "", false, "", "", Array("right", "left"))

  Dim objPredicate
  ' List predicates
  If session(strWizardName & "_MTCounterParameter").Predicates.Count = 0 Then
    strHTML = strHTML & "<tr><td class=""clsWizardPrompt"">No predicate configured.</td></tr>"
  Else
      strHTML = strHTML & "<tr><td class=""clsWizardPrompt"">Predicate:<br></td></tr>"
      For Each objPredicate in session(strWizardName & "_MTCounterParameter").Predicates
        strHTML = strHTML & "<tr><td class ='clsWizardPromptOdd'>" & objPredicate.ProductViewProperty.DN 
  			Select Case objPredicate.Operator
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_EQUAL
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>=" 
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_NOT_EQUAL
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&lt;&gt;"  
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&gt;" 
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_GREATER_EQUAL
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&gt;=" 
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&lt;" 
          	Case MTDECIMALCAPABILITY_OPERATOR_TYPE_LESS_EQUAL
					  strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>&lt;=" 
        End Select                              

        If objPredicate.ProductViewProperty.PropertyType = 8 Then
          strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>" & objEnumTypeconfig.GetEnumWithValue(objPredicate.ProductViewProperty.EnumNamespace, objPredicate.ProductViewProperty.EnumEnumeration, objPredicate.value) & "</td></tr>"    
        Else
          strHTML = strHTML & "</td><td class ='clsWizardPromptOdd'>" & objPredicate.value & "</td></tr>"            
        End If

      Next
  End If 
  strHTML = strHTML & gobjMTGrid.CloseGridDiv()
  WriteSummary = strHTML
 
End Function

%>