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


'----------------------------------------------------------------------------
'
'DESCRIPTION:   This file is used to manipulate a tabular ruleset rule.  It is
'               called from the GenericTabRuleset.asp page and is used to edit
'               rules
'
'ASSUMPTIONS: The metafile and ruleset file already exist.
'
'CALLS (REQUIRES): MTTabRulesetReader library
'
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
' INCLUDES
'----------------------------------------------------------------------------
%>
  <!-- #INCLUDE VIRTUAL = "/mpte/auth.asp" -->
  <!-- #INCLUDE VIRTUAL = "/mpte/shared/Helpers.asp" -->
  <!-- #INCLUDE VIRTUAL = "/mpte/shared/CheckConnected.asp" -->
<%

Response.Buffer = True
Session.CodePage = 65001
Response.CharSet = "utf-8"

'----------------------------------------------------------------------------
' CONSTANTS
'----------------------------------------------------------------------------
' none

'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
dim mobjTRReader  ' as RulesetHandler
dim mobjRuleSet   ' as MTRuleSet
dim mstrID
dim mstrCurrPage
dim mbolNewRow
dim mdctValues
dim mstrErrors
dim mbolIsDefaultRule
dim mbolIsGlobalActions
dim intBlankConditionCount
dim intRequiredConditionCount

'----------------------------------------------------------------------------
' METHODS
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
'   Name: ReadValues
'   Description:  Reads the values from the request and populates a dictionary.
'                 If the form has not been submitted yet, it reads the values
'                 from the object.
'                 This does the type checking and creates an error message for
'                 the necessary corrections
'   Parameters: istrIndex - the index of the rule to use.  
'               ibolSubmitting - flag to indicate that the form is being submitted
'   Return Value: none
'-----------------------------------------------------------------------------
sub ReadValues(istrIndex, ibolSubmitting)

  dim objRule
  dim objRSConditionSet
  dim objRSCondition
  dim objRSActionSet
  dim objRSAction
  dim objConditionData
  dim objActionData
  dim objActionDatas
  dim strValue
  dim objFilter
  dim bolConditionFound
	dim bolConditionsAllBlank
  
  dim i
  
  i = 0
	bolConditionsAllBlank = true
		
  set mdctValues = Server.CreateObject("Scripting.Dictionary")
  
  if not mbolNewRow then 
    if not ibolSubmitting then
      if mbolIsDefaultRule or mbolIsGlobalActions then 
        set objRSActionSet = mobjRuleSet.DefaultActions
      else
        'AddDebugMessage "Reading the values from the ruleset"
        set objRule = mobjRuleSet(CLng(istrIndex))
        Set objRSConditionSet = objRule.Conditions
        Set objRSActionSet = objRule.Actions
      end if
    end if
  else
     'AddDebugMessage "Reading the values from the form"
  end if
  
 ' write the conditions
  if mobjTRReader.ConditionDatas.count > 0 and not mbolIsDefaultRule and not mbolIsGlobalActions then
    '----------------------------------------------------------------------- 
    ' We don't have any guarantee that the conditions in the ruleset match the order
    ' of the conditions diplayed.  So, for each condition column, we have to
    ' loop through all the conditions in the rule and try to find a match
    '-----------------------------------------------------------------------
    'AddDebugMessage "Start loop through conditiondatas"
    for each objConditionData in mobjTRReader.ConditionDatas
    
      'AddDebugMessage "looking for condition: <B>" & objConditionData.DisplayName & "</B>"
      'AddDebugMessage "request as: <B>" & objConditionData.PropertyName & i & "</B>"
      
      '-----------------------------------------------------------------------
      ' If it is a new rule that is being loaded for the first time, check to
      ' see if we should default values to what is being filtered.  To do this
      ' loop through all the filters (there may be none).  If you find a matching
      ' filter, then stick that value into the dictionary.  Otherwise, just
      ' put a blank entry into the dictionary of values
      '-----------------------------------------------------------------------
      if mbolNewRow and not ibolSubmitting then          
  
      	bolConditionFound = false

        ' Find out if any filters are available
        for each objFilter in mobjTRReader.FilterConditions
            
        '---------------------------------------------------------------
        ' For filtering, do a test first to see if the user can edit the
        ' operator.  If the user cannot edit the operator, then make sure
        ' you match on both the property name and on the test operator.
        ' If they match, add the entry to the dictionary.
        '---------------------------------------------------------------

        if not objConditionData.EditOperator then
          'if (objFilter.Condition.PropertyName = objConditionData.PropertyName) and (TestToSymbol(objFilter.Condition.Test) = objConditionData.Operator) then
			  	if (objFilter.Condition.PropertyName = objConditionData.PropertyName) and (TestToOperatorType(objFilter.Condition.Test) = Clng(objConditionData.Operator)) then
          	bolConditionFound = true
            'call mdctValues.add(objConditionData.PropertyName & i, FormatString(objConditionData.PType, objFilter.DisplayValue, objConditionData.PropertyName))
						call mdctValues.add(objConditionData.PropertyName & i, objFilter.DisplayValue)
            'call mdctValues.add(objConditionData.PropertyName & i & "Operator", SymbolToTest(objConditionData.Operator))              
						call mdctValues.add(objConditionData.PropertyName & i & "Operator", OperatorTypeToTest(objConditionData.Operator))              
          end if
              
            '---------------------------------------------------------------
            ' If the operator is editable, look for a match on the property
            ' name.  This stuff may not work correctly in cases where there
            ' are two conditions with the same name and one of them has an
            ' editable operator.  However, in that case, it would be a really
            ' confusing ruleset anyway and that condition should be filterable
            '---------------------------------------------------------------
            else
              if (objFilter.Condition.PropertyName = objConditionData.PropertyName) then
                bolConditionFound = true
                call mdctValues.add(objConditionData.PropertyName & i, objFilter.DisplayValue)
                call mdctValues.add(objConditionData.PropertyName & i & "Operator", objFilter.Condition.Test)  
              end if
            end if
          next

          if not bolConditionFound then
           'response.write "Found condition[" & objConditionData.PropertyName & "]: Type[" & objConditionData.PType & "] DefaultValue[" & objConditionData.DefaultValue & "]<BR>"
           'CR# - Quickest way to resolve issue with default boolean condition values not being set correctly.
            call mdctValues.add(objConditionData.PropertyName & i, ConvertValueToDictionaryFormat(objConditionData.PType, objConditionData.DefaultValue))
            'call mdctValues.add(objConditionData.PropertyName & i & "Operator", SymbolToTest(objConditionData.Operator))
						call mdctValues.add(objConditionData.PropertyName & i & "Operator", OperatorTypeToTest(objConditionData.Operator))              
          end if

          
          
      '-----------------------------------------------------------------------
      ' If they are just submitting the form, get all the values from the 
      ' query string.  Check for required fields, type-checking, etc...
      ' Place the value into the dictionary of values.
      '-----------------------------------------------------------------------
      elseif ibolSubmitting then
        strValue = PreProcessValue(request.Form(objConditionData.PropertyName & i), objConditionData.PType)
        if not ucase(objConditionData.ColumnType) = "LABEL" then
          if len(strValue) > 0 then
            'AddDebugMessage "found item.  value: " & strValue
						bolConditionsAllBlank = false ' At least on condition is not blank
            
            'call mdctValues.add(objConditionData.PropertyName & i, FormatString(objConditionData.PType, strValue, objConditionData.PropertyName))
						call mdctValues.add(objConditionData.PropertyName & i, strValue)
						mstrErrors = mstrErrors & TypeCheckCondition(objConditionData, strValue)                
							
						if len(mstrErrors) = 0 and not ValidateLength(strValue, objConditionData.PType, objConditionData.Length) then            	
							mstrErrors = mstrErrors & UseOverflowMessage(objConditionData)
						end if
							
            if objConditionData.EditOperator then
             	call mdctValues.Add(objConditionData.PropertyName & i & "Operator", request.Form(objConditionData.PropertyName & i & "Operator"))
            else
							call mdctValues.add(objConditionData.PropertyName & i & "Operator", OperatorTypeToTest(objConditionData.Operator))
             	' call mdctValues.add(objConditionData.PropertyName & i & "Operator", SymbolToTest(objConditionData.Operator))
            end if
          	' else there was no value.  We need to check to see if it is required
          elseif objConditionData.required and ibolSubmitting then
            mstrErrors = mstrErrors & RequiredConditionMessage(objConditionData)          
					end if ' end test of wheter a value is blank
        end if ' end test of whether this is a label
             
      '-----------------------------------------------------------------------
      ' Otherwise they are not sumitting the form, and it is not new.  This
      ' means that they are editing an existing rule.  Get the values for the
      ' rule from the condition set
      '-----------------------------------------------------------------------       
      else 
        'AddDebugMessage "could not find value in query string - get it from ruleset"
         
        if not ucase(objConditionData.ColumnType) = "LABEL" then        
          for each objRSCondition in objRSConditionSet                        
            'AddDebugMessage " -- Look for match on : " & objRSCondition.PropertyName
            '----------------------------------------------------------------------- 
            ' We need to suppport having multiple conditions with the same name.
            ' However, the name and operator pair must be unique if the operator is
            ' specified.  If the operator is unspecified, we can only match on the name
            '----------------------------------------------------------------------- 
							if ((objConditionData.EditOperator) and (ucase(objRSCondition.PropertyName) = ucase(objConditionData.PropertyName))) or _
                ((ucase(objRSCondition.PropertyName) = ucase(objConditionData.PropertyName)) and (Clng(objConditionData.Operator) = TestToOperatorType(objRSCondition.Test))) then
						
            'if ((objConditionData.EditOperator) and (ucase(objRSCondition.PropertyName) = ucase(objConditionData.PropertyName))) or _
            '    ((ucase(objRSCondition.PropertyName) = ucase(objConditionData.PropertyName)) and (objConditionData.Operator = TestToSymbol(objRSCondition.Test))) then
            
              'call mdctValues.add(objConditionData.PropertyName & i, FormatString(objConditionData.PType, objRSCondition.Value, objRSCondition.PropertyName))
							call mdctValues.add(objConditionData.PropertyName & i, objRSCondition.Value)
              call mdctValues.Add(objConditionData.PropertyName & i & "Operator", objRSCondition.Test)
              
              'AddDebugMessage " Found matching value of: " & mdctValues(objConditionData.PropertyName & i)
              
              exit for
            end if
          next
          
        end if ' end test of column type
        
      end if ' end test of the where data comes from                        
                          
      i = i + 1
    next ' loop on ConditionData
  	
		'--------------------------------------------------------------------
		' Let's see if all the conditions are optional and set to "blank"
		' if so, we throw an error because this is not supposed to happen,
		' unless it is the default rule
		'--------------------------------------------------------------------
		if ibolSubmitting and mobjTRReader.ConditionDatas.Count > 0 and bolConditionsAllBlank then
 			mstrErrors = mstrErrors & FrameWork.GetDictionary("TEXT_MPTE_ERROR_ALLCONDITIONSBLANK")
		end if

  end if ' end test on whether there are any conditions to display
  
  

	' TODO: Fix this so we have global actions  
  ' write the Actions
	'  if (mobjTRReader.ActionDatas.count > 0 and not mbolIsGlobalActions) or _
	'      (mobjTRReader.GlobalActionDatas.count > 0 and mbolIsGlobalActions) then

  if (mobjTRReader.ActionDatas.count > 0 and not mbolIsGlobalActions) Then
                      
    '-----------------------------------------------------------------------
    ' We don't have any guarantee that the actions in the ruleset match the order
    ' of the actions diplayed.  So, for each action column, we have to
    ' loop through all the actions in the rule and try to find a match
    '-----------------------------------------------------------------------
    	
		if mbolIsGlobalActions then
      set objActionDatas = mobjTRReader.GlobalActionDatas
    else
      set objActionDatas = mobjTRReader.ActionDatas
    end if
    
    'AddDebugMessage "Start loop through actiondatas"
    for each objActionData in objActionDatas
      'AddDebugMessage "working with action: <B>" & objActionData.DisplayName & "</B>"
      'AddDebugMessage "request as: <B>" & objActionData.PropertyName & i & "</B>"
      
      ' if we are submitting a form, get the values from the request       
      if ibolSubmitting or mbolNewRow then      
      
        if not ucase(objActionData.ColumnType) = "LABEL" then
         	strValue = PreProcessValue(Request.Form(objActionData.PropertyName & i), objActionData.PType) 
         	'AddDebugMessage "found item.  value: " & strValue & objActionData.DefaultValue
              
          if len(strValue) > 0 then
						'call mdctValues.add(objActionData.PropertyName & i, FormatString(objActionData.PType, strValue, objActionData.PropertyName))
						call mdctValues.add(objActionData.PropertyName & i, strValue)
            'AddDebugMessage "typechecking action"

						if ibolSubmitting then
            	mstrErrors = mstrErrors & TypeCheckAction(objActionData, strValue)
							if len(mstrErrors) = 0 and not ValidateLength(strValue, objActionData.PType, objActionData.Length) then
            		mstrErrors = mstrErrors & UseOverflowMessage(objActionData)
							end if
						end if
					elseif objActionData.required and ibolSubmitting then
            if ibolSubmitting then
              mstrErrors = mstrErrors & UseDefaultActionMessage(objActionData)
            end if
            'call mdctValues.add(objActionData.PropertyName & i, FormatString(objActionData.PType, objActionData.DefaultValue, objActionData.PropertyName))
            call mdctValues.add(objActionData.PropertyName & i, ConvertValueToDictionaryFormat(objActionData.PType, objActionData.DefaultValue))
					else
					  ' Set the default value for required actions (CR12890) 'Always set the default, even if not required (CR13172)
            if not ibolSubmitting and mbolNewRow then
              'This action is blank, is a new row and we are not submitting so set the default value if there is one
						  call mdctValues.add(objActionData.PropertyName & i, ConvertValueToDictionaryFormat(objActionData.PType, objActionData.DefaultValue))
            end if
          end if
        
        end if ' end test on whether it is a label
              
      else ' else we are loading the data from the RS source        
        
        if mbolIsGlobalActions then
          set objRSActionSet = mobjRuleSet.DefaultActions
        end if
        
        if not ucase(objActionData.ColumnType) = "LABEL" then
          for each objRSAction in objRSActionSet
            if ucase(objRSAction.PropertyName) = ucase(objActionData.PropertyName) then
              ' if the condition matches, save the value          
              'call mdctValues.add(objActionData.PropertyName & i, FormatString(objActionData.PType, objRSAction.PropertyValue, objActionData.PropertyName))
							call mdctValues.add(objActionData.PropertyName & i, objRSAction.PropertyValue)
              exit for
            end if
          next
        end if ' end test on column type
        
      end if ' end test on source of data
         
      i = i + 1
    next ' loop on ActionData
      
  end if ' end test on whether there are any actions to display
    
end sub

function ConvertValueToDictionaryFormat(ptype,value)
           'CR# 12960 & 13172- Quickest way to resolve issue with default boolean condition values not being set correctly.
           if ptype = 7 then					
 	           if Cstr(value) = "1" OR Cstr(value) = "T" Then
               ConvertValueToDictionaryFormat = "TRUE"
	           else
               if Cstr(value) = "0" OR Cstr(value) = "F" Then
                 ConvertValueToDictionaryFormat = "FALSE"
               end if
             end if
           else 
             ConvertValueToDictionaryFormat = value
           end if
end function

'----------------------------------------------------------------------------
'   Name: Save
'   Description:  Saves the changes made to the rule into the ruleset
'   Parameters: istrIndex - the index of the rule to use or add to
'   Return Value: none
'-----------------------------------------------------------------------------
sub Save(istrIndex)
  dim objRule
  dim objRSConditionSet
  dim objRSCondition
  dim objRSActionSet
  dim objRSAction
  dim objConditionData
  dim objActionData
  dim i
  
  i = 0
 
  '------------------------------------------------------------------
  ' The easiest way to update a rule from an existing ruleset is to 
  ' create a new rule with new conditions and actions, then set the
  ' new rule in the right spot.  If it is really supposed to be a new rule,
  ' just add the rule to the end of the ruleset.
  '------------------------------------------------------------------
  set objRule = Server.CreateObject("MTRule.MTRule.1")
  set objRSConditionSet = Server.CreateObject("MTConditionSet.MTConditionSet.1")
  set objRSActionSet = Server.CreateObject("MTActionSet.MTActionSet.1")
	
  '------------------------------------------------------------------
  ' loop through all the conditions and write them out.
  ' If a submitted condition has no value or is a label, then do not 
  ' write the condition out to the ruleset
  '------------------------------------------------------------------
  if not mbolIsDefaultRule then
    for each objConditionData in mobjTRReader.ConditionDatas

      if (mdctValues.exists(objConditionData.PropertyName & i)) and (not ucase(objConditionData.ColumnType) = "LABEL") then
      
        set objRSCondition = Server.CreateObject("MTSimpleCondition.MTSimpleCondition.1")
        
        if CLng(objConditionData.PType) = PROP_TYPE_ENUM then
          objRSCondition.EnumSpace = objConditionData.EnumSpace
          objRSCondition.EnumType = objConditionData.EnumType
          objRSCondition.ValueType = objConditionData.PType
        else     
          objRSCondition.ValueType = objConditionData.PType
        end if
        
        objRSCondition.PropertyName = objConditionData.PropertyName
        
        call SetRSConditionValue(objRSCondition, mdctValues(objConditionData.PropertyName & i))
              
        if objConditionData.EditOperator then
          objRSCondition.Test = mdctValues(objConditionData.PropertyName & i & "Operator")
        else
          'objRSCondition.Test = SymbolToTest(objConditionData.Operator)
		  		objRSCondition.Test = OperatorTypeToTest(objConditionData.Operator)
        end if
        
        call objRSConditionSet.Add(objRSCondition)
        
      end if ' end test of whether this is a valid condition
      
      i = i + 1
      
    next ' loop on the condition datas
		
  end if
  
  '------------------------------------------------------------------
  ' loop through all the actions and write them out.  Actions are required and
  ' cannot be empty, so write all of them.  If one is empty, use the default value.
  ' ESR-6319 Don't write an empty, non-required enum action (because the
  ' default value of -1 will cause an error when the user clicks on Save).
  '------------------------------------------------------------------
  for each objActionData in mobjTRReader.ActionDatas

    if (mdctValues.exists(objActionData.PropertyName & i) or objActionData.Required) _
        and (not ucase(objActionData.ColumnType) = "LABEL") then
    
     set objRSAction = Server.CreateObject("MTAssignmentAction.MTAssignmentAction.1")
     objRSAction.PropertyName = objActionData.PropertyName  

     if CLng(objActionData.PType) = PROP_TYPE_ENUM then
        objRSAction.EnumSpace = objActionData.EnumSpace
        objRSAction.EnumType = objActionData.EnumType
        objRSAction.PropertyType = objActionData.PType
      else     
        objRSAction.PropertyType = objActionData.PType
      end if
	  
      if mdctValues.exists(objActionData.PropertyName & i) then
        call SetRSActionValue(objRSAction, mdctValues(objActionData.PropertyName & i))
      end if
      
      call objRSActionSet.Add(objRSAction)
      
    end if
    i = i + 1
  next
  
  ' TODO : FIX THIS
  ' Add the default actions to the action set
  ' call SaveGlobalActionsToActionSet(objRSActionSet)
  
  objRule.Conditions = objRSConditionSet
  objRule.Actions = objRSActionSet
  
  '--------------------------------------------------------------
  ' Save the new rule by placing it in the correct position.  If
  ' it is a ne rule, just add it to the end.  Otherwise, replace the
  ' rule that is at the given index.
  '---------------------------------------------------------------  
  if mbolIsDefaultRule then
    'AddDebugMessage "setting default actions"
    mobjRuleSet.DefaultActions = objRSActionSet
  else
    'AddDebugMessage "setting a normal rule"
    
    '---------------------------------------------------------------  
    ' If it is a new rule, then the add can be complicated.  If we
    ' are adding a new rule to the end of the ruleset, the just
    ' add the rule.  If we are adding a rule in the middle, then
    ' we need to create a new ruleset and copy everything over and 
    ' put the new rule in the correct place.  
    '---------------------------------------------------------------  
    if mbolNewRow then
      if CLng(istrIndex) = mobjRuleSet.count then
        call mobjRuleSet.Add(objRule) 
      else
        call mobjRuleSet.Insert(objRule, istrIndex)
               
      end if ' end test on whether the rule should be added to the end
      
    else ' else, the rule is just being updated
      mobjRuleSet(CLng(istrIndex)).Conditions = objRSConditionSet
      mobjRuleSet(CLng(istrIndex)).Actions = objRSActionSet
      
    end if ' end test on whether it is a new row or not
    
  end if ' end test on whether it is the default rule
  
  set session("RuleSet") = mobjRuleSet
  
  set objRule = Nothing
  set objRSConditionSet = Nothing
  set objRSActionSet = Nothing

end sub

'----------------------------------------------------------------------------
'   Name: writeEditTableRows
'   Description:  writes out the edit table.  Assumes that a <TABLE> tag has
'                 already been started.
'   Parameters: ibolIsDefault - flag to indicate that these are default actions
'   Return Value: none
'-----------------------------------------------------------------------------
sub writeEditTableRows(ibolIsDefault)

  dim objConditionData
  dim objActionData
  dim objActionDatas
  dim strValue
  dim strTest
  dim arrstrValues
  dim arrstrText
  dim strTemp
  dim strEnumerator
	dim strClass
  
  dim i
  
  i = 0
 ' write the conditions
  if mobjTRReader.ConditionDatas.count > 0 and not ibolIsDefault and not mbolIsGlobalActions then
    call response.write("  <TR>" & vbNewLine)
    'call response.write("    <TD NOWRAP colspan=""2"" class=""clsTableText""><B><BR>" & _
    '                  mobjTRReader.ConditionsHeader & "</B><HR SIZE=""1""></TD>" & vbNewLine)
    call Draw_Header(mobjTRReader.ConditionsHeader & vbNewLine, 2, "CaptionBar")
		call response.write("  </TR>" & vbNewLine)
                     
    '----------------------------------------------------------------------- 
    ' loop through the conditions and get the data from the dictionary
    '-----------------------------------------------------------------------
    for each objConditionData in mobjTRReader.ConditionDatas
			if objConditionData.Required then
				strClass = "captionEWRequired"
			else
				strClass = "captionEW"
			end if
			
      call response.write("  <TR>" & vbNewLine)
      call response.write("    <TD NOWRAP class=" & strClass & " ALIGN=""right"">")
      
      ' if it's a label, then don't write the header on the left
      if ucase(objConditionData.ColumnType) = "LABEL" then
        call response.write("&nbsp;")
      else
        call response.write(objConditionData.DisplayName)
        if not objConditionData.EditOperator and not ucase(objConditionData.DisplayOperator) = "NONE" then
		  		'call response.write("&nbsp;(" & OperatorEncode(objConditionData.Operator) & ")")
          call response.write("&nbsp;(" & OperatorTranslate(objConditionData.Operator) & ")")
        end if
      end if ' end test on label
      call response.write(":</TD>"& vbNewLine)
      
      ' start the edit area
      call response.write("    <TD NOWRAP ALIGN=""left"">")
            
     ' if it's a label, just output the label
     'AddDebugMessage "Condition: " & objConditionData.DisplayName & " - Type: " & objConditionData.Columntype
      if ucase(objConditionData.ColumnType) = "LABEL" then
        call response.write(objConditionData.DisplayName)
        
      else ' not a label, so find if we have a condition in the file for it
        strValue = mdctValues(objConditionData.PropertyName & i)
        strTest = mdctValues(objConditionData.PropertyName & i & "Operator")
  
        
        ' if they can edit the operator, then write out a select
        if objConditionData.EditOperator then
          if CLng(objConditionData.PType) = PROP_TYPE_ENUM or CLng(objConditionData.PType) = PROP_TYPE_STRING  or CLng(objConditionData.PType) = PROP_TYPE_BOOLEAN then
            call BuildComboBox(objConditionData.PropertyName & i & "Operator", _
                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objConditionData.PropertyName & i & "Operator');""", _
                    mobjTRReader.TestOperatorPartialValues, mobjTRReader.TestOperatorPartialText, strTest, false)
          else
            call BuildComboBox(objConditionData.PropertyName & i & "Operator", _
                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objConditionData.PropertyName & i & "Operator');""", _
                    mobjTRReader.TestOperatorFullValues, mobjTRReader.TestOperatorFullText, strTest, false)
          end if
        end if
        
        '-----------------------------------------------------------------------
        ' if it is an enum, write up a combo box, otherwise, use a text box
        ' set the name of the input to the property name and the i variable 
        ' This will allow us to keep meaningful names and avoid the conflicts
        ' if two or more items share the PropertyName
        '-----------------------------------------------------------------------
        if CLng(objConditionData.PType) = PROP_TYPE_ENUM then
          set arrstrValues = objConditionData.EnumValues
          set arrstrText = objConditionData.EnumStrings
          
          'Check for the enum type to exist
          strEnumerator = ""
    
          'AddDebugMessage("LOOKING FOR : " & strValue)
          
          for each strTemp in arrstrValues
            if UCase(strTemp) = Ucase(strValue) then
              strEnumerator = strTemp
               'AddDebugMessage("Found : " & strTemp)
             	exit for
            end if
          next
                   
          if len(strEnumerator) = 0 then
            strEnumerator = ConvertValueToEnumerator(objConditionData.Enumspace, objConditionData.Enumtype, strValue)
            'AddDebugMessage("Got Enumerator : " & strEnumerator)
          end if
           
'          call BuildComboBox(objConditionData.PropertyName & i, "CLASS=""clsInputBox"" " & _
'                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objConditionData.PropertyName & i & "');""", _
'                    arrstrValues, arrstrText, strValue, true)
          call BuildComboBox(objConditionData.PropertyName & i, _
                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objConditionData.PropertyName & i & "');""", _
                    arrstrValues, arrstrText, strEnumerator, not objConditionData.Required)

                    
        elseif CLng(objConditionData.PType) = PROP_TYPE_BOOLEAN then
          call BuildBooleanComboBox(objConditionData.PropertyName & i, _
                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objConditionData.PropertyName & i & "');""", _
                    strValue, not objConditionData.Required)
        elseif CLng(objConditionData.PType) = PROP_TYPE_DATETIME then
          If Len(CStr(strValue)) = 0 Then
            call response.write("<INPUT TYPE=""TEXT"" " & _
                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objConditionData.PropertyName & i &"');""" & _
                    "NAME=""" & objConditionData.PropertyName & i & """ VALUE=""" & "" & """>")          
          Else
            call response.write("<INPUT TYPE=""TEXT"" " & _
                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objConditionData.PropertyName & i &"');""" & _
                    "NAME=""" & objConditionData.PropertyName & i & """ VALUE=""" & CStr(CDate(strValue)) & """>")
          End If          
        else
        'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
        'Adding HTML Encoding
          call response.write("<INPUT TYPE=""TEXT"" " & _
                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objConditionData.PropertyName & i &"');""" & _
                    "NAME=""" & objConditionData.PropertyName & i & """ size=""25"" VALUE=""" &  SafeForHtmlAttr(strValue) & """>")
        end if
        
      end if ' end test of the column type                        
                          
      call response.write("</TD>" & vbNewLine)                
      call response.write("  </TR>" & vbNewLine)
      
      i = i + 1
    next ' loop on ConditionData
      
  end if ' end test on whether there are any conditions to display
    
  ' write the Actions
  if (mobjTRReader.ActionDatas.count > 0 and not mbolIsGlobalActions) or _
      (mobjTRReader.GlobalActionDatas.count > 0 and mbolIsGlobalActions) then
      
    if mbolIsGlobalActions then
      set objActionDatas = mobjTRReader.GlobalActionDatas
    else
      set objActionDatas = mobjTRReader.ActionDatas
    end if
    
	call response.write("<TR><TD>&nbsp;</td></tr>")
    call response.write("  <TR>" & vbNewLine)
    if mbolIsGlobalActions then
	  	call 	Draw_Header(FrameWork.GetDictionary("TEXT_MPTE_GLOBALACTIONS") & vbNewLine, 2, "CaptionBar")
    else
	  	call Draw_Header(mobjTRReader.ActionsHeader & vbNewLine, 2, "CaptionBar")
    end if
    call response.write("  </TR>" & vbNewLine)
                      
    '-----------------------------------------------------------------------
    ' We don't have any guarantee that the actions in the ruleset match the order
    ' of the actions diplayed.  So, for each action column, we have to
    ' loop through all the actions in the rule and try to find a match
    '-----------------------------------------------------------------------
    for each objActionData in objActionDatas

			if objActionData.Required then
				strClass = "captionEWRequired"
			else
				strClass = "captionEW"
			end if
			
      call response.write("  <TR>" & vbNewLine)
      call response.write("    <TD NOWRAP class=" & strClass & " ALIGN=""right"">")
						
      ' if it's a label, then don't write the header on the left
      if ucase(objActionData.ColumnType) = "LABEL" then
        call response.write("&nbsp;")
      else
        call response.write(objActionData.DisplayName)
      end if ' end test on label
      call response.write(":</TD>"& vbNewLine)
      
      ' start the edit area
      call response.write("    <TD NOWRAP ALIGN=""left"">")
      
      ' if it's a label, just output the label
      if ucase(objActionData.ColumnType) = "LABEL" then
        call response.write(objActionData.DisplayName)
      
      elseif (mbolIsGlobalActions) and (not objActionData.Editable) then
        call response.write(objActionData.DefaultValue)
        call response.write("<INPUT TYPE=""HIDDEN"" NAME=""" & _
                    objActionData.PropertyName & i & """ VALUE=""" & objActionData.DefaultValue & """>")  
                    
      else ' not a label, so find if we have an action in the file for it

        strValue = mdctValues(objActionData.PropertyName & i)
        
        '-----------------------------------------------------------------------
        ' if it is an enum, write up a combo box, otherwise, use a text box
        ' set the name of the input to the property name and the i variable 
        ' This will allow us to keep meaningful names and avoid the conflicts
        ' if two or more items share the PropertyName
        '-----------------------------------------------------------------------
        if CLng(objActionData.PType) = PROP_TYPE_ENUM then
          set arrstrValues = objActionData.EnumValues
          set arrstrText = objActionData.EnumStrings
          
          strEnumerator = ""
    
          'AddDebugMessage("LOOKING FOR : " & strValue)
          
          for each strTemp in arrstrValues
            if UCase(strTemp) = Ucase(strValue) then
              strEnumerator = strTemp
               'AddDebugMessage("Found : " & strTemp)
              exit for
            end if
          next
          
                   
          if len(strEnumerator) = 0 then
            strEnumerator = ConvertValueToEnumerator(objActionData.Enumspace, objActionData.Enumtype, strValue)
            'AddDebugMessage("Got Enumerator : " & strEnumerator)
          end if

'          call BuildComboBox(objActionData.PropertyName & i, "CLASS=""clsInputBox"" " & _
'                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objActionData.PropertyName & i &"');""", _
'                    arrstrValues, arrstrText, strValue, false)

          call BuildComboBox(objActionData.PropertyName & i, _
                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objActionData.PropertyName & i &"');""", _
                    arrstrValues, arrstrText, strEnumerator, not objActionData.Required)
 
                              
        elseif CLng(objActionData.PType) = PROP_TYPE_BOOLEAN then
          call BuildBooleanComboBox(objActionData.PropertyName & i, _
                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objActionData.PropertyName & i & "');""", _
                    strValue, not objActionData.Required)
        elseif CLng(objActionData.PType) = PROP_TYPE_DATETIME then
          If Len(CStr(strValue)) = 0 Then
            call response.write("<INPUT TYPE=""TEXT"" " & _
                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objActionData.PropertyName & i &"');""" & _
                    "NAME=""" & objActionData.PropertyName & i & """ VALUE=""" & "" & """>")
          Else
            call response.write("<INPUT TYPE=""TEXT"" " & _
                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objActionData.PropertyName & i &"');""" & _
                    "NAME=""" & objActionData.PropertyName & i & """ VALUE=""" & CStr(CDate(strValue)) & """>")
          End If          
        else
        
          call response.write("<INPUT TYPE=""TEXT"" " & _
                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objActionData.PropertyName & i &"');""" & _
                    "NAME=""" & objActionData.PropertyName & i & """ size=""25"" VALUE=""" & strValue & """>")
        end if
        
      end if ' end test of the column type  
      
      call response.write("</TD>" & vbNewLine)                
      call response.write("  </TR>" & vbNewLine)
      
      i = i + 1
    next ' loop on ActionData
      
  end if ' end test on whether there are any actions to display
    
end sub



'----------------------------------------------------------------------------
' PAGE PROCESSING STARTS
'----------------------------------------------------------------------------

set mobjTRReader = session("TRReader")
set mobjRuleSet = session("RuleSet")
mbolIsDefaultRule = false

mstrID = request.QueryString("ID")

if mstrID = "default" then
  mbolIsDefaultRule = true
	' If the value above is 'default', then the first rule to be displayed (determining paging) will be in the QueryString as 'CurrPage'
	mstrCurrPage = request.QueryString("CurrPage")
end if

mbolIsGlobalActions = False ' cbool(request.queryString("GlobalActions") = "T")
mbolNewRow = cbool(request.QueryString("new") = "T")

call ClearDebugMessages("GenericEditRuleset.asp")
mstrErrors = ""
  
'----------------------------------------------------------------------------
' OK - SAVE THE CHANGES TO THE RULESET, SAVE THE RULESET TO SESSION,
' AND FORCE THE CALLING SCREEN TO REFRESH.  SET A SESSION FLAG TO INDICATE THAT
' THE CALLING PAGE SHOULD REALLY JUST RELOAD FROM THE RULESET - OTHERWISE, IT
' MAY DO THE WRONG THING.
'---------------------------------------------------------------------------- 
if request.Form("FormAction") = "OK" then
	Dim strURL
	Dim strPage
  ' Reload important variables, this time from the Form, since the method we have now is POST
  mstrID = request.Form("ID")
  if mstrID = "default" then
  	mbolIsDefaultRule = true
			' If the user is adding the default rule, we will override the value of mstrID (now is "default") to the value of Request.Form("currpage"),
			' which is the index of the first rule on the page that the user was before, when he/she added the default rule.
		strPage = Request.Form("currpage")
	else
		strPage = mstrID
  end if

  mbolNewRow = cbool(request.Form("new") = "T")
  
  ' Do what we have to do to add a new/modify an existing objects
  call ReadValues(mstrID, true)
  if len(mstrErrors) = 0 then
    if mbolIsGlobalActions then
    	' For the future
		else
      call Save(mstrID)
    end if
  
  session("AfterEdit") = true
	strURL = "<script LANGUAGE=""JavaScript1.2"">window.opener.location=""gotoRuleEditor.asp?AfterEdit=TRUE&page=" & strPage & """</script>"  
	call response.write(strURL)

	call response.write("")
  call response.end
  end if
  
else
  call ReadValues(mstrID, false)
end if

'----------------------------------------------------------------------------
' HTML WRITING STARTS
'----------------------------------------------------------------------------
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
  <head>
	 <title><%=FrameWork.GetDictionary("TEXT_RULESET_EDITOR")%></title>

	<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET1")%>">
  	<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET2")%>">
  	<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET3")%>">
	
     <script language="JavaScript1.2" src="/mpte/shared/browsercheck.js"></script>    
     <script language="JavaScript1.2" src="/mpte/shared/PopupModalDialog.js"></script>
     <script LANGUAGE="JavaScript1.2">
     
     function handleEnter()
      {
        //alert('Key pressed');
        if (window.event.keyCode==13)
        {
            //alert('You hit enter');
            SubmitForm('OK');
            return false;
        }
        if (window.event.keyCode==27)
        {
            //alert('You hit ESC');
            javascript:window.close();
            return false;
        }
        return true;
      }
           
     function SubmitForm(istrAction)
     {
        document.main.FormAction.value = istrAction;
        document.main.submit();
     }
     </script>
  </head>

  <body onKeyPress="return handleEnter();" onBlur="javascript:LostFocus();" onFocus="javascript:GotFocus('window');" onLoad="javascript:SizeWindow();"> 
  <table>
    <tr>
      <td>
        <FORM ACTION="gotoPopup.asp?loadpage=GenericEditRuleset.asp" METHOD="POST" NAME="main" onFocus="javascript:InAForm(main);" onBlur="javascript:OutOfForm();">
        <INPUT TYPE="Hidden" NAME="FormAction" VALUE="OK">
        <INPUT TYPE="HIDDEN" NAME="ID" VALUE="<%=mstrID%>">
				<INPUT TYPE="HIDDEN" NAME="CurrPage" VALUE="<%=mstrCurrPage%>">
        <INPUT TYPE="HIDDEN" NAME="GlobalActions" VALUE="<% if mbolIsGlobalActions then response.write("T") end if%>">  
        <INPUT TYPE="HIDDEN" NAME="new" VALUE="<% if mbolNewRow then response.write("T") end if%>">
  
  		<% call WriteError(mstrErrors)%>
        <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="3">
  		<% call writeEditTableRows(mbolIsDefaultRule) %>
        </TABLE>
        <BR><BR>
        <table width="100%">
        <tr>
          <td align="center" NOWRAP>
     	  	  <input type="button" class="clsButtonSmall" name="OK" alt="<%=FrameWork.GetDictionary("TEXT_MPTE_ALT_OK")%>" value="<%=FrameWork.GetDictionary("TEXT_MPTE_OK_BTN")%>" onClick="javascript:SubmitForm('OK');">
    	  	  <input type="button" class="clsButtonSmall" name="Cancel" alt="<%=FrameWork.GetDictionary("TEXT_MPTE_ALT_CANCEL")%>" value="<%=FrameWork.GetDictionary("TEXT_MPTE_CANCEL_BTN")%>" onClick="javascript:window.close();">
          </td>
        </tr>
        </table>
        </FORM>
      </td>
    </tr>
  </table>

  <% call writeDebug() %>
  </body>
</html>

<%
   
  if err then 
    call response.clear()
    call WriteUnknownError("")
    call response.end()
  else
    call response.flush()
    call response.end()
  end if

%> 