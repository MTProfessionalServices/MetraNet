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
' // Created by: Dave Wood
' //
' // $Date$
' // $Author$
' // $Revision$
' //==========================================================================

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' FormsClass.asp                                                            '
'   Routines used to render forms.                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Public gobjMTForms


Class CMTFormsClass

  Dim mbUseFieldset         'Indicates whether or not to use fieldsets

  'Class strings
  Dim mstrLegendClass       'Class for fieldset legends
  Dim mstrTableClass        'Class for the table body
  Dim mstrPromptClass       'Class for the text prompts
  Dim mstrInputClass        'Class for input boxes
  Dim mstrSelectClass       'Class for select inputs
  Dim mstrMultiSelectClass  'Class for multi-select classes
  Dim mstrRadioClass        'Class for radio buttons
  Dim mstrCheckboxClass     'Class for checkbox inputs
  
  
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Sub           : Class_Initialize()                                       '
  ' Description   : Initialize the class.                                    '
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Sub Class_Initialize()
    
    mbUseFieldset = false
    
    mstrLegendClass       = "clsLegend"
    mstrTableClass        = "clsTableBody"
    mstrPromptClass       = "clsPrompt"
    mstrInputClass        = "clsInput"
    mstrSelectClass       = "clsSelect"
    mstrMultiSelectClass  = "clsMultiSelect"
    mstrRadioClass        = "clsRadio"
    mstrCheckboxClass     = "clsCheckbox"
  
  End Sub

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : OpenEditBoxTable(strFieldCaption, strOther)               '
  ' Description   : Create a table to be used as an edit box.  If a caption   '
  '               : is passed, an encompassing fieldset is created as well.   '
  ' Inputs        : strFieldCaption -- caption for the fieldset               '
  '               : strOther        -- other text for the table               '
  ' Outputs       : none                                                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function OpenEditBoxTable(strFieldCaption, strOther)
    Dim strReturn     'string to return
  
  
    'Only draw the fieldset if the caption is not empty
    if len(strFieldCaption) > 0 then
      mbUseFieldset = true
      strReturn = strReturn &  "        <fieldset>" & vbNewline
      strReturn = strReturn &  "          <legend class=""" & mstrLegendClass & """>" & strFieldCaption & "</legend>" & vbNewline
    else
      mbUseFieldset = false
    end if
    
    strReturn = strReturn &  "          <table class=""" & mstrTableClass & """ width=""100%""" & strOther & ">" & vbNewline
  
    OpenEditBoxTable = strReturn
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : CloseEditBoxTable()                                       '
  ' Description   : Close a table to be used as an edit box.                  '
  ' Inputs        : none                                                      '
  ' Outputs       : none                                                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function CloseEditBoxTable()
    Dim strReturn     'string to return
    
    
    strReturn = strReturn & "         </table>" & vbNewline
    
    if mbUseFieldset then
      strReturn = strReturn & "       </fieldset>" & vbNewline
    end if
    
    
    CloseEditBoxTable = strReturn
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : AddTextInput(...)                                         '
  ' Description   : Add an input text box.                                    '
  ' Inputs        : strName   -- name of the text box                         '
  '               : strValue  -- default value                                '
  '               : strCaption-- caption for the text box                     '
  '               : intLen    -- size of the text box                         '
  '               : strOther  -- other text for the input tag                 '
  ' Outputs       : none                                                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function AddTextInput(strName, strValue, strCaption, intLen, strOther)
    Dim strReturn     'string to return
  
    'Set a default length if none passed.
    if len(cstr(intLen)) = 0 then
      intLen = 15
    end if
  
    strReturn = strReturn &  "            <tr>" & vbNewline
    strReturn = strReturn &  "              <td align=""right"" class=""" & mstrPromptClass & """ nowrap>" & strCaption & "</td>" & vbNewline
    strReturn = strReturn &  "              <td align=""left"" nowrap><input type=""text"" class=""" & mstrInputClass & """ name=""" & strName & """ size=""" & intLen & """ value=""" & strValue & """" & strOther & "></td>" & vbNewline
    strReturn = strReturn &  "            </tr>" & vbNewline
    
    AddTextInput = strReturn
  End Function

  Public Function AddTextInputRequired(strName, strValue, strCaption, intLen, strOther)
    AddTextInputRequired = AddTextInputRequiredEx(strName, strValue, strCaption, intLen, strOther,"")
  End Function 

  Public Function AddTextInputRequiredEx(strName, strValue, strCaption, intLen, strOther,strEndingCaption)
    Dim strReturn     'string to return
  
    'Set a default length if none passed.
    if len(cstr(intLen)) = 0 then
      intLen = 15
    end if
  
    strReturn = strReturn &  "            <tr>" & vbNewline
    strReturn = strReturn &  "              <td align=""right"" class=""" & mstrPromptClass & "Required"" nowrap>" & strCaption & "</td>" & vbNewline
    strReturn = strReturn &  "              <td align=""left"" nowrap><input type=""text"" class=""" & mstrInputClass & """ name=""" & strName & """ size=""" & intLen & """ value=""" & strValue & """" & strOther & ">" & strEndingCaption & "</td>" & vbNewline
    strReturn = strReturn &  "            </tr>" & vbNewline
    
    AddTextInputRequiredEx = strReturn
  End Function 
  
        '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : AddDateInput(...)                                         '
  ' Description   : Add an input date box.                                    '
  ' Inputs        : strName   -- name of the text box                         '
  '               : strValue  -- default value                                '
  '               : strCaption-- caption for the text box                     '
  '               : intLen    -- size of the text box                         '
  '               : strOther  -- other text for the input tag                 '
  ' Outputs       : none                                                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function AddDateInput(strName, strValue, strCaption, intLen, strOther)
    Dim strReturn     'string to return
  
    'Set a default length if none passed.
    if len(cstr(intLen)) = 0 then
      intLen = 15
    end if
    strReturn = strReturn &  "            <tr>" & vbNewline
    strReturn = strReturn &  "              <td align=""right"" class=""" & mstrPromptClass & """ nowrap>" & strCaption & "</td>" & vbNewline
    strReturn = strReturn &  "              <td align='left' nowrap><input type='text' class='" &_
	                                        mstrInputClass & "' name='" & strName & "' size='" &_
											intLen & "' value='" & strValue & "'>" & strOther & "</td>"
     strReturn = strReturn &  "            </tr>" & vbNewline
  
    AddDateInput = strReturn
  End Function
  
    '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : AddTextInput(...)                                         '
  ' Description   : Add an input text box.                                    '
  ' Inputs        : strName   -- name of the text box                         '
  '               : strValue  -- default value                                '
  '               : strCaption-- caption for the text box                     '
  '               : intLen    -- size of the text box                         '
  '               : strOther  -- other text for the input tag                 '
  ' Outputs       : none                                                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function AddTextAreaInput(strName, strValue, strCaption, intWidth, intHeight, strOther)
    Dim strReturn     'string to return
  
    'Set a default size if not passed.
    if len(cstr(intWidth)) = 0 then
      intWidth = 50
    end if

    if len(cstr(intHeight)) = 0 then
      intWidth = 5
    end if
  
    strReturn = strReturn &  "            <tr>" & vbNewline
    strReturn = strReturn &  "              <td align=""right"" valign=""top"" class=""" & mstrPromptClass & """ nowrap>" & strCaption & "</td>" & vbNewline
    strReturn = strReturn &  "              <td align=""left"" nowrap><TEXTAREA cols=""" & intWidth & """ rows=""" & intHeight & """ class=""" & mstrInputClass & """ name=""" & strName & """" & strOther & ">" & strValue & "</TEXTAREA></td>" & vbNewline
    strReturn = strReturn &  "            </tr>" & vbNewline
    
    AddTextAreaInput = strReturn
  End Function

 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
 ' Function      : AddMultiSelectInput(...)                                  '
 ' Description   : Add a drop down list box that supports multi-select.      '
 ' Inputs        : strName       --  name of the select input                '
 '               : strCaption    --  caption for the select                  '
 '               : arrSelected   --  the selected inputs                     '
 '               : arrOptions    --  array of options to print               '
 '               : arrValues     --  values for the selected options         '
 '               : strOther      --  other text for the tag                  '
 ' Outputs       : none                                                      '
 '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function AddMultiSelectInput(strName, arrSelected, strCaption, arrOptions, arrValues, strOther)
    Dim strReturn     'string to return
    Dim i             'counter
    Dim j
    Dim bSelected
    
    strReturn = strReturn & "               <tr>" & vbNewline
    
    if len(strCaption) > 0 then
      strReturn = strReturn & "                 <td align=""right"" class=""" & mstrPromptClass & """ nowrap>" & strCaption & "</td>" & vbNewline
    end if
    
    strReturn = strReturn & "                 <td align=""left"" class=""" & mstrPromptClass & """ nowrap>" & vbNewline
    strReturn = strReturn & "                   <select multiple class=""" & mstrSelectClass & """ name=""" & strName & """" & strOther & ">" & vbNewline
   
    if isarray(arrOptions) then
      for i = 0 to UBound(arrOptions)
        bSelected = false
        
        if isarray(arrSelected) then
          for j = 0 to UBound(arrSelected)
            if UCase(arrSelected(j)) = UCase(arrValues(i)) then
              bSelected = true
              exit for
            end if
          next
        end if
     
    
        if bSelected then
          strReturn = strReturn &  "                <option selected value=""" & arrValues(i) & """>" & arrOptions(i) & "</option>" & vbNewline
        else
          strReturn = strReturn &  "                <option value=""" & arrValues(i) & """>" & arrOptions(i) & "</option>" & vbNewline
        end if
      next
    end if
    
    strReturn = strReturn & "                 </select>" & vbNewline
    strReturn = strReturn & "               </td>" & vbNewline
    strReturn = strReturn & "             </tr>" & vbNewline
    
    AddMultiSelectInput = strReturn
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : AddSelectInput(...)                                       '
  ' Description   : Add a drop down list box                                  '
  ' Inputs        : strName       --  name of the select input                '
  '               : strCaption    --  caption for the select                  '
  '               : strSelected   --  the selected input                      '
  '               : arrOptions    --  array of options to print               '
  '               : arrValues     --  values for the selected options         '
  '               : strOther      --  other text for the tag                  '
  ' Outputs       : none                                                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function AddSelectInput(strName, strSelected, strCaption, arrOptions, arrValues, strOther)
    Dim strReturn     'string to return
    Dim i             'counter
    
    strReturn = strReturn & "               <tr>" & vbNewline
    strReturn = strReturn & "                 <td align=""right"" class=""" & mstrPromptClass & """ nowrap>" & strCaption & "</td>" & vbNewline
    strReturn = strReturn & "                 <td align=""left"" class=""" & mstrPromptClass & """ nowrap>" & vbNewline
    strReturn = strReturn & "                   <select class=""" & mstrSelectClass & """ name=""" & strName & """" & strOther & ">" & vbNewline
   
    if isarray(arrOptions) then
      for i = 0 to UBound(arrOptions)
        if UCase(strSelected) = Ucase(arrValues(i)) then
          strReturn = strReturn &  "                <option selected value=""" & arrValues(i) & """>" & arrOptions(i) & "</option>" & vbNewline
        else
          strReturn = strReturn &  "                <option value=""" & arrValues(i) & """>" & arrOptions(i) & "</option>" & vbNewline
        end if
      next
    end if
    
    strReturn = strReturn & "                 </select>" & vbNewline
    strReturn = strReturn & "               </td>" & vbNewline
    strReturn = strReturn & "             </tr>" & vbNewline
    
    AddSelectInput = strReturn
  End Function

  Public Function AddSelectInputWithoutPrompt(strName, strSelected, arrOptions, arrValues, strOther)
    Dim strReturn     'string to return
    Dim i             'counter
    
    'strReturn = strReturn & "               <tr>" & vbNewline
    'strReturn = strReturn & "                 <td align=""right"" class=""" & mstrPromptClass & """ nowrap>" & strCaption & "</td>" & vbNewline
    'strReturn = strReturn & "                 <td align=""left"" class=""" & mstrPromptClass & """ nowrap>" & vbNewline
    strReturn = strReturn & "                   <select class=""" & mstrSelectClass & """ name=""" & strName & """" & strOther & ">" & vbNewline
   
    if isarray(arrOptions) then
      for i = 0 to UBound(arrOptions)
        if UCase(strSelected) = Ucase(arrValues(i)) then
          strReturn = strReturn &  "                <option selected value=""" & arrValues(i) & """>" & arrOptions(i) & "</option>" & vbNewline
        else
          strReturn = strReturn &  "                <option value=""" & arrValues(i) & """>" & arrOptions(i) & "</option>" & vbNewline
        end if
      next
    end if
    
    strReturn = strReturn & "                 </select>" & vbNewline
    'strReturn = strReturn & "               </td>" & vbNewline
    'strReturn = strReturn & "             </tr>" & vbNewline
    
    AddSelectInputWithoutPrompt = strReturn
  End Function
  
  Public Function AddSelectInputRequired(strName, strSelected, strCaption, arrOptions, arrValues, strOther)
    Dim strReturn     'string to return
    Dim i             'counter
    
    strReturn = strReturn & "               <tr>" & vbNewline
    strReturn = strReturn & "                 <td align=""right"" class=""" & mstrPromptClass & "Required"" nowrap>" & strCaption & "</td>" & vbNewline
    strReturn = strReturn & "                 <td align=""left"" class=""" & mstrPromptClass & """ nowrap>" & vbNewline
    strReturn = strReturn & "                   <select class=""" & mstrSelectClass & """ name=""" & strName & """" & strOther & ">" & vbNewline
    strReturn = strReturn & "                   <option selected>USD</option>" & vbNewline
   
    if isarray(arrOptions) then
      for i = 0 to UBound(arrOptions)
        if UCase(arrValues(i)) <> UCase("USD") then
           if UCase(strSelected) = Ucase(arrValues(i)) then
              strReturn = strReturn &  "                <option selected value=""" & arrValues(i) & """>" & arrOptions(i) & "</option>" & vbNewline
           else
              strReturn = strReturn &  "                <option value=""" & arrValues(i) & """>" & arrOptions(i) & "</option>" & vbNewline
           end if
        end if
      next
    end if
    
    strReturn = strReturn & "                 </select>" & vbNewline
    strReturn = strReturn & "               </td>" & vbNewline
    strReturn = strReturn & "             </tr>" & vbNewline
    
    AddSelectInputRequired = strReturn
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : AddRadioInput(...)                                          '
  ' Description : Add a group of radio inputs.                                '
  ' Inputs      : strName     --  name of the radio button                    '
  '             : strCaption  --  caption for the button                      '
  '             : arrOptions  --  options to display                          '
  '             : arrValues   --  values for the buttons                      '
  '             : strChecked  --  value that is checked                       '
  '             : intColumns  --  number of columns to use to display the     '
  '             :                 radio buttons.                              '
  '             : strOther    --  other text for tags                         '
  ' Outputs     : none                                                        '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function AddRadioInput(strName, strChecked, strCaption, arrOptions, arrValues, intColumns, strOther)
    Dim strReturn     'string to return
    Dim strValign     'vertical alignment
    Dim intWidth      'Width of rows
    Dim i             'counter
    
    'Set a default number of columns
    if len(intColumns) = 0 then
      intColumns = 1
    end if
    
    intColumns = CLng(intColumns)
    
    intWidth = CLng(100 / intColumns)
    
    'Set the vertical alignment
    if Ubound(arrOptions) > intColumns then
      strValign = "top"
    else
      strValign = "middle"
    end if
    
    strReturn = strReturn & "               <tr>" & vbNewline
  
    if len(strCaption) > 0 then
      strReturn = strReturn & "                 <td align=""right"" class=""" & mstrPromptClass & """ valign=""" & strValign & """ nowrap>" & strCaption & "</td>" & vbNewline
    end if
  
    strReturn = strReturn & "                 <td align=""left"" class=""" & mstrPromptClass & """>" & vbNewline
    strReturn = strReturn & "                   <table width=""100%"" height=""100%"" cellspacing=""0"" cellpadding=""0"">" & vbNewline
  
    for i = 0 to UBound(arrOptions)
      if i mod intColumns = 0 then
        strReturn = strReturn & "                   <tr>" & vbNewline
      end if
      
      if UCase(strChecked) = UCase(arrValues(i)) then
        strReturn = strReturn & "                     <td width=""" & intWidth & "%"" align=""left"" valign=""top"" class=""" & mstrPromptClass & """ nowrap><input class=""" & mstrRadioClass & """ type=""radio"" name=""" & strName & """ value=""" & arrValues(i) & """" & strOther & " checked>" & arrOptions(i) & "</td>" & vbNewline
      else
        strReturn = strReturn & "                     <td width=""" & intWidth & "%"" align=""left"" valign=""top"" class=""" & mstrPromptClass & """ nowrap><input class=""" & mstrRadioClass & """ type=""radio"" name=""" & strName & """ value=""" & arrValues(i) & """" & strOther & ">" & arrOptions(i) & "</td>" & vbNewline
      end if
      
      if (i + 1) mod intColumns = 0 or i = UBound(arrOptions) then
        strReturn = strReturn & "                   </tr>" & vbNewline
      end if
    next
    
    strReturn = strReturn & "                   </table>" & vbNewline
    strReturn = strReturn & "                 </td>" & vbNewline
    strReturn = strReturn & "               </tr>" & vbNewline  
  
    AddRadioInput = strReturn      
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : AddCheckboxInput(...)                                       '
  ' Description : Add a checkbox input selections                             '
  ' Inputs      : strName     --  name of the checkboxes                      '
  '             : strCaption  --  caption for the group of checkboxes         '
  '             : arrCaptions --  captions for the checkboxes                 '
  '             : arrValues   --  values for the checkboxes                   '
  '             : arrChecked  --  which checkboxes are selected               '
  '             : intColumns  --  number of columns to dislay checkboxes in   '
  '             : strOther    --  other text                                  '
  ' Outputs     : none                                                        '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function AddCheckboxInput(strName, arrChecked, strCaption, arrCaptions, arrValues, intColumns, strOther)
    Dim strReturn     'return value
    Dim strValign     'vertical alignment
    Dim i, j          'counters
    Dim bChecked      'indicates a box should be checked
    
    'Set a default number of columns
    if len(intColumns) = 0 then
      intColumns = 1
    end if
      
    intColumns = CLng(intColumns)
    
      'Set the vertical alignment
    if Ubound(arrValues) > intColumns then
      strValign = "top"
    else
      strValign = "middle"
    end if
    
    strReturn = strReturn & "               <tr>" & vbNewline
    
    if len(strCaption) > 0 then
      strReturn = strReturn & "                 <td align=""right"" class=""" & mstrPromptClass & """ valign=""" & strValign & """ nowrap>" & strCaption & "</td>" & vbNewline
    end if
    
    strReturn = strReturn & "                 <td align=""left"" class=""" & mstrPromptClass & """>" & vbNewline
    strReturn = strReturn & "                   <table width=""100%"" height=""100%"" cellspacing=""0"" cellpadding=""0"">" & vbNewline
  
    'draw the checkboxes
    for i = 0 to UBound(arrCaptions)
      if i mod intColumns = 0 then
        strReturn = strReturn & "                   <tr>" & vbNewline
      end if
      
      'Check if the current value should be checked    
      bChecked = false
      
      if isarray(arrChecked) then
        for j = 0 to UBound(arrChecked)
          if UCase(arrValues(i)) = UCase(arrChecked(j)) then
            bChecked = true
            exit for
          end if
        next
      end if
      
      if bChecked then
         strReturn = strReturn & "                     <td align=""right"" class=""" & mstrPromptClass & """ nowrap><input type=""checkbox"" class=""" & mstrCheckboxClass & """ name=""" & strName & """ value=""" & arrValues(i) & """" & strOther & " checked></td>" & vbNewline
         strReturn = strReturn & "                     <td align=""left"" class=""" & mstrPromptClass  & """ nowrap>" & arrCaptions(i) & "</td>" & vbNewline
      else
        strReturn = strReturn & "                     <td align=""right"" class=""" & mstrPromptClass & """ nowrap><input type=""checkbox""  class=""" & mstrCheckboxClass & """ name=""" & strName & """ value=""" & arrValues(i) & """" & strOther & "></td>" & vbNewline
        strReturn = strReturn & "                     <td align=""left"" class=""" & mstrPromptClass  & """ nowrap>" & arrCaptions(i) & "</td>" & vbNewline
      end if
  
      
      if (i + 1) mod intColumns = 0 or i = UBound(arrCaptions) then
        strReturn = strReturn & "                   </tr>" & vbNewline
      end if
    next
    
    strReturn = strReturn & "                   </table>" & vbNewline
    strReturn = strReturn & "                 </td>" & vbNewline
    strReturn = strReturn & "               </tr>" & vbNewline
  
    AddCheckboxInput = strReturn
  End Function

  Public Function AddCheckboxInputWithoutPrompt(strName, strValue, bChecked, strOther)
  
  dim  strReturn
  
  strReturn = ""
  
        if bChecked then
         strReturn = strReturn & "<input type=""checkbox"" class=""" & mstrCheckboxClass & """ name=""" & strName & """ value=""" & strValue & """" & strOther & " checked>" & vbNewline
      else
        strReturn = strReturn & "<input type=""checkbox""  class=""" & mstrCheckboxClass & """ name=""" & strName & """ value=""" & strValue & """" & strOther & ">" & vbNewline
      end if

    AddCheckboxInputWithoutPrompt = strReturn
  End Function

	
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : getRadioButtonHTML(...)                                     '
' Description : Add a checkbox input selections                             '
' Inputs      : strName     --  name of the radiobutton                     '
'             : strSelected  -- mark it selected or not						          '
'             : strValue  -- value of this radiobutton in the group         '
'             : strLabel  -- text that goes with the radiobutton            '
'             : strOther  -- extra args														          '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function getRadioButtonHTML(strName, strSelected, strValue, strLabel, strOther)
	dim strHTML, mstrRadioClass, strChecked
	mstrRadioClass = "clsInputText"
	if strSelected = strValue then
		strChecked = " Checked"
	else
		strChecked = ""
	end if	
	strHTML = "<input class=""" & mstrRadioClass & """ type=""radio"" id=""" & strName & """ name=""" & strName & """ value=""" & strValue & """" & strOther & strChecked & ">" & strLabel
	getRadioButtonHTML = strHTML
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : getCheckBoxHTML(...)                                        '
' Description : returns the html for one checkbox - no tables or cells      '
' Inputs      : strName     --  name of the checkbox                        '
'             : strValue  -- selected or not											          '
'             : strLabel  -- text that goes with the checkbox			          '
'             : strOther  -- extra args														          '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function getCheckBoxHTML(strName, strValue, strLabel, strOther)
	dim strHTML, mstrCheckboxClass, strChecked
	mstrCheckboxClass = "clsInputText"
	if strValue = "TRUE" then
		strChecked = " Checked"
	else
		strChecked = ""
	end if			
	strHTML = "<input type=""checkbox""  class=""" & mstrCheckboxClass & """ name=""" & strName & """" & strOther & strChecked & ">" & strLabel
	getCheckBoxHTML = strHTML
End Function

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function    : getSelectHTML(...)                                          '
' Description : Add a select input - no tables or cells around it           '
' Inputs      : strName     --  name of the select                          '
'             : strSelected  -- mark the selected item						          '
'             : strArrayValues  -- values of this select								    '
'             : strArrayLabels  -- labels for the selections above          '
'             : strOther  -- extra args														          '
' Outputs     : none                                                        '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Function getSelectHTML(strName, strSelected, strArrayValues, strArrayLabels, strOther)
	dim strHTML, mstrSelectClass, i
	mstrSelectClass = "clsInputText"
	
	strHTML = "<select class=""" & mstrSelectClass & """ name=""" & strName & """" & strOther & ">" & vbNewline

	for i = 0 to UBound(strArrayLabels)
		if UCase(strSelected) = Ucase(strArrayValues(i)) then
      strHTML = strHTML &  "<option selected value=""" & strArrayValues(i) & """>" & strArrayLabels(i) & "</option>" & vbNewline
    else
      strHTML = strHTML &  "<option value=""" & strArrayValues(i) & """>" & strArrayLabels(i) & "</option>" & vbNewline
    end if
  next  
	
	strHTML = strHTML & "</select>" & vbNewline
	getSelectHTML = strHTML
End Function
	
	
	
	
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  
  'Legend Class
  Public Property Let LegendClass(strClass)
    mstrLegendClass = strClass
  End Property

  Public Property Get LegendClass()       'As String
    LegendClass = mstrLegendClass
  End Property

  'Table Body  
  Public Property Let TableBodyClass(strClass)
    mstrTableClass = strClass
  End Property

  Public Property Get TableBodyClass()       'As String
    TableBodyClass = mstrTableClass
  End Property
  
  'Prompt
  Public Property Let PromptClass(strClass)
    mstrPromptClass = strClass
  End Property
  
  Public Property Get PromptClass()       'As String
    PromptClass = mstrPromptClass
  End Property
  
  'Input
  Public Property Let InputClass(strClass)
    mstrInputClass = strClass
  End Property

  Public Property Get InputClass()       'As String
    InputClass = mstrInputClass
  End Property

  'Select  
  Public Property Let SelectClass(strClass)
    mstrSelectClass = strClass
  End Property

  Public Property Get SelectClass()       'As String
    SelectClass = mstrSelectClass
  End Property
  
  'MultiSelect
  Public Property Let MultiSelectClass(strClass)
    mstrMultiSelectClass = strClass
  End Property

  Public Property Get MultiSelectClass()       'As String
    MultiSelectClass = mstrMultiSelectClass
  End Property
  
  'Radio
  Public Property Let RadioClass(strClass)
    mstrRadioClass = strClass
  End Property
  
  Public Property Get RadioClass()       'As String
    RadioClass = mstrRadioClass
  End Property
  
  'Checkbox
  Public Property Let CheckboxClass(strClass)
    mstrCheckboxClass = strClass
  End Property
  
  Public Property Get CheckboxClass()       'As String
    CheckboxClass = mbUseFieldset
  End Property
  
  
End Class


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Create the object                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Set gobjMTForms = new CMTFormsClass  

%>