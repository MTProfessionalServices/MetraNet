<%
' //==========================================================================
' // @doc $Workfile$
' //
' // Copyright 1998 - 2006 by MetraTech Corporation
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
' // $Notes: Modifying this for MCM
' // $Revision$
' //==========================================================================


'----------------------------------------------------------------------------
'
'DESCRIPTION:   This file is used to manipulate a tabular ruleset page.  It 
'             reads a tabular ruleset that describes the properties
'             of the ruleset.  It uses these properties to render a page for
'             editing of the ruleset.
'
'ASSUMPTIONS: The metadata and ruledata objects exist and are available.
'
'CALLS (REQUIRES): MTTabRulesetReader library
'
'----------------------------------------------------------------------------
Session.CodePage = 65001
Response.CharSet = "utf-8"

Response.Buffer = true ' In win2000 this is true by default

'----------------------------------------------------------------------------
' INCLUDES
'----------------------------------------------------------------------------
%>
  <!-- #INCLUDE VIRTUAL = "/mpte/auth.asp" -->
<%

'----------------------------------------------------------------------------
' CONSTANTS
'----------------------------------------------------------------------------
const MAX_RULES = 20

'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
dim mobjTRReader  ' as RulesetHandler
dim mobjRuleSet   ' as MTRuleSet

dim objMTRateSched ' As MTRateSchedule
dim objParamTableDef ' As MTParamTableDef
dim objMTProductCatalog   ' as MTProductCatalog

dim mbolRemove
dim mbolAdding
dim mbolFiltering
dim mbolFilterAvailable
dim mstrFilterString
dim mstrFilterImg
dim mstrErrors
dim mbolSubmitted
dim mbolIsFilterOn
dim mcolTableOutputStrings
dim mintFilteredOut
dim mintStartNum
dim mstrThisPage
dim mstrTemp
dim mbolAllConditionsOpt
dim mbolRuleNotConfigured ' Used to flag if a ruleset with 0 Conditions has the Default Actions field configured or not

dim boolmatched ' Used to flag if a property on the ruleset was matched against a property on the metadata. Otherwise we display a blank cell

'----------------------------------------------------------------------------
' METHODS
'----------------------------------------------------------------------------
'----------------------------------------------------------------------------
'   Name: determinePaging
'   Description:  Figures out how many rules are displayed and if we need to page
'               the results.  Writes out the stings for the table
'   Parameters: remove flag
'   Return Value: none
'-----------------------------------------------------------------------------
sub determinePaging(mbolRemove)
  dim intColSpan
  dim intPages
  dim intCurPage
	
  '------------------------------------------------------------
  ' First find out how many pages there are.  
  '------------------------------------------------------------
  intPages = int(mobjRuleSet.count / MAX_RULES)
  if mobjRuleSet.count mod MAX_RULES > 0 then
    intPages = intPages + 1
  end if
    
  '------------------------------------------------------------
  ' Find which page we're on
  '------------------------------------------------------------
	if mintStartNum <= MAX_RULES then
    intCurPage = 1
  else 
    intCurPage = int((mintStartNum -1) / MAX_RULES) + 1
  end if	
	
	'------------------------------------------------------------------------------------------------
	' mintStartNum
	'------------------------------------------------------------------------------------------------
	mintStartNum = (intCurPage - 1)*MAX_RULES + 1
		
  '------------------------------------------------------------
  ' Only draw the paging if there are more rules to display
  ' than the MAX RULES specified.  
  '------------------------------------------------------------
  if mobjRuleSet.count - mintFilteredOut > MAX_RULES then
  
    '------------------------------------------------------------
    ' Determine how many columns this paging row will span
    '------------------------------------------------------------
    intColSpan = 4 ' start with four columns (id, move, edit, add)
    if mobjTRReader.ConditionDatas.count > 0 then
      intColSpan = intColSpan + mobjTRReader.ConditionDatas.count + 1
    end if
    intColSpan = intColSpan + mobjTRReader.ActionDatas.count + 1
    
    call response.write("  <TR VALIGN=""absmiddle""><TD VALIGN=""absmiddle"" class=""clsTextMpteBackPane"" ALIGN=""center"" COLSPAN=""" & intColSpan & """>" & vbNewLine)
    
    ' If we're filtering, then display all rules, paging is too complicated
    if mbolFiltering then
      call response.write(FrameWork.GetDictionary("TEXT_MPTE_FILTERPAGING_ERROR"))
    
    else ' else, draw the page icons
      
      '------------------------------------------------------------
      ' If we aren't at the beginning, draw the page back icons
      '------------------------------------------------------------
      if mintStartNum >= MAX_RULES then
        call response.write("<A HREF=""" & mstrThisPage & "RemovePave=" & mbolRemove & "&page=1"  & _
                            """><img SRC=""/mpte/us/images/firstpage_enabled.gif"" BORDER=""0"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_FIRSTPAGE") & """></A>")														
        call response.write("<A HREF=""" & mstrThisPage & "RemovePage=" & mbolRemove & "&page=" &  mintStartNum - MAX_RULES & _
                            """><img SRC=""/mpte/us/images/previouspage_enabled.gif"" BORDER=""0"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_PREVIOUSPAGE") & """></A>")
      else
        call response.write("<img SRC=""/mpte/us/images/firstpage_disabled.gif"" BORDER=""0"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_FIRSTPAGE") & """>")
        call response.write("<img SRC=""/mpte/us/images/previouspage_disabled.gif"" BORDER=""0"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_PREVIOUSPAGE") & """>")
      end if
           
      '------------------------------------------------------------
      ' Tell what page we're on
      '------------------------------------------------------------
      call response.write("&nbsp;<span style='color:black; position: relative; top: -8px;'>Page " & intCurPage & " of " & intPages & "&nbsp;</span>")
      
      '------------------------------------------------------------
      ' If we're not on the last page, draw the page forward icons
      '------------------------------------------------------------
      if mintStartNum + MAX_RULES <= mobjRuleSet.count then
        call response.write("<A HREF=""" & mstrThisPage & "RemovePage=" & mbolRemove & "&page=" &  mintStartNum + MAX_RULES & _
                            """><img SRC=""/mpte/us/images/nextpage_enabled.gif"" BORDER=""0"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_NEXTPAGE") & """></A>")
        call response.write("<A HREF=""" & mstrThisPage & "RemovePage=" & mbolRemove & "&page=" &  (mobjRuleSet.count - ((mobjRuleSet.count-1) mod MAX_RULES)) & _
                            """><img SRC=""/mpte/us/images/lastpage_enabled.gif"" BORDER=""0"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_LASTPAGE") & """></A>")
      else
        call response.write("<img SRC=""/mpte/us/images/nextpage_disabled.gif"" BORDER=""0"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_NEXTPAGE") & """>")
        call response.write("<img SRC=""/mpte/us/images/lastpage_disabled.gif"" BORDER=""0"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_LASTPAGE") & """>")
      end if
      
    end if  ' end test of filtering
    
    call response.write("</TD>" & vbNewLine)
    
  end if ' end test of whether to do paging
end sub


'----------------------------------------------------------------------------
'   Name: FindFilters
'   Description:  determines if filters are available for this screen and if  so,
'                 are they on or off.  If they are on, what is being filtered?
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
sub FindFilters
  dim objConditionData
  dim objFilter
  dim bolConditionFound
  dim tmpFilterString
        
  mbolFilterAvailable = false
  
  ' Find out if any filters are available
  for each objConditionData in mobjTRReader.ConditionDatas
    if objConditionData.Filterable and not ucase(objConditionData.ColumnType) = "LABEL" then
      mbolFilterAvailable = true
      exit for
    end if
  next
  
  ' Loop through all the conditions and find whether any filter conditions
  ' are set.  Build the display string off that
  bolConditionFound = false
  if mbolFilterAvailable then
    for each objFilter in mobjTRReader.FilterConditions
      if not bolConditionFound then
        bolConditionFound = true
        mbolFiltering = true
        mintStartNum = 1
        mstrFilterString = FrameWork.GetDictionary("TEXT_MPTE_FILTERON")
        mbolIsFilterOn = true
      end if
      
      if not mstrFilterString = FrameWork.GetDictionary("TEXT_MPTE_FILTERON") then
        mstrFilterString = mstrFilterString & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_CONNECTOR_AND") & "&nbsp;"
      end if
      mstrFilterString = mstrFilterString & "(" & objFilter.DisplayName & " " & _
                        objFilter.DisplayTest & " " & objFilter.DisplayValue & ")"
                next            
  end if
  
  ' If filters are available and no filters are defined, then put the correct string
  if mbolFilterAvailable and not bolConditionFound then
    mstrFilterString  = FrameWork.GetDictionary("TEXT_MPTE_FILTEROFF")
    mbolIsFilterOn = false
  end if
end sub

'----------------------------------------------------------------------------
'   Name: MoveUpDown
'   Description:  uses the shared ruleset and moves one of the items up or down.  
'                 Updates the shared ruleset directly
'   Parameters: istrDirection - "up" or "down" to indicate direction to move a rule
'               iintID - the index into the ruleset to move
'   Return Value: none
'-----------------------------------------------------------------------------
sub MoveUpDown(istrDirection, iintID)

  dim intID
  dim intOffset
  
  dim objRSConditionSet
  dim objRSActionSet
  dim objRSConditionSet2
  dim objRSActionSet2
  
  dim objRSAction
  dim objRSCondition
  
  intID = CLng(iintID)
    
  set objRSConditionSet = CreateObject("MTConditionSet.MTConditionSet.1")
  set objRSActionSet = CreateObject("MTActionSet.MTActionSet.1")
  set objRSConditionSet2 = CreateObject("MTConditionSet.MTConditionSet.1")
  set objRSActionSet2 = CreateObject("MTActionSet.MTActionSet.1")
  
  ' if we are moving it up, then store the previous one in a temporary variable
  ' and add the next one
  if istrDirection = "U" then
    intOffset = -1
  else
    intOffset = 1
  end if
  
  for each objRSCondition in mobjRuleSet(intID + intOffset).Conditions
    call objRSConditionSet.add(objRSCondition)
  next
  for each objRSAction in mobjRuleSet(intID + intOffset).Actions
    call objRSActionSet.add(objRSAction)
  next
  
  for each objRSCondition in mobjRuleSet(intID).Conditions
    call objRSConditionSet2.add(objRSCondition)
  next
  for each objRSAction in mobjRuleSet(intID).Actions
    call objRSActionSet2.add(objRSAction)
  next
      
  mobjRuleSet(intID + intOffset).Conditions = objRSConditionSet2
  mobjRuleSet(intID + intOffset).Actions = objRSActionSet2
  
  mobjRuleSet(intID).Conditions = objRSConditionSet
  mobjRuleSet(intID).Actions = objRSActionSet
     
end sub

'----------------------------------------------------------------------------
'   Name: writeGlobalActions
'   Description:  Writes out the global actions for the page if there are any
'               Outputs the actions into a table
'   Parameters: ibolSubmitted - flag to indicate that the data was submitted and
'                       the values should be read from the request
'   Return Value: none
'-----------------------------------------------------------------------------
sub writeGlobalActions(ibolSubmitted)
  dim objActionData
  dim objRSActionSet
  dim objRSAction

  dim strValue
  dim arrstrValues
  dim arrstrText
  dim bolFirst

  dim colGlobalActions
  
  '-----------------------------------------------------------------------
  ' We need something to store the global actions so that when we are editing
  ' the rules, we can just write out the global actions.  So, when reading
  ' the global actions, save them off to a collection
  '-----------------------------------------------------------------------
  set colGlobalActions = session("TRReader").GetNewCollection
  set objRSActionSet = mobjRuleSet.DefaultActions
  
  '-----------------------------------------------------------------------
  ' We need a sample rule to see what the global actions are.  Just pick the
  ' default actions.  If there are no global actions, don't do any of this
  '-----------------------------------------------------------------------    
  if mobjTRReader.GlobalActionDatas.count > 0 then
    call response.write("<TABLE>")
                      
    '-----------------------------------------------------------------------
    ' We don't have any guarantee that the actions in the ruleset match the order
    ' of the actions diplayed.  So, for each action column, we have to
    ' loop through all the actions in the rule and try to find a match
    '-----------------------------------------------------------------------
    bolFirst = true
    
    for each objActionData in mobjTRReader.GlobalActionDatas
      ' If it is the first item, then put the editing pencil up
      if bolFirst then
        call response.write("    <TR><TD COLSPAN=""2"" ALIGN=""center"" class=""clsTableTextWhite"">") 
        call response.write("<A Name='butEdit' HREF=""javascript:OpenDialogWindow('/mpte/us/gotoPopup.asp?loadpage=GenericEditRuleset.asp&GlobalActions=T', '');""><IMG SRC=""/mpte/us/images/edit.gif"" BORDER=""0"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_EDITGLOBALSETTINGS") & """></A>")
        call response.write("&nbsp;&nbsp;Edit Global Settings<BR><HR SIZE=""1""></TD></TR>" & vbNewLine) 
        bolFirst = false
      end if
      
      call response.write("  <TR>" & vbNewLine)      
      call response.write("    <TD NOWRAP class=""clsTableTextWhite"">")
      
      ' if it's a label, then don't write the header on the left
      if ucase(objActionData.ColumnType) = "LABEL" then
        call response.write("&nbsp;")
      else
        call response.write(objActionData.DisplayName)
      end if ' end test on label
      call response.write(":</TD>"& vbNewLine)
      
      ' start the edit area
      call response.write("    <TD NOWRAP class=""clsTableTextWhite"" ALIGN=""left"">")
      
      '---------------------------------------------------------------------
      ' We're going to look for the global action in the default actions of
      ' the ruleset.  If we don't find it there, we should leave the value blank
      ' since it will be more obvious that the user has to specify the value.
      ' If we just put in the default value, then it appears that all the rules
      ' actually have that action set, which is not true.  
      '
      ' If we find the global action value in the default actions for the ruleset,
      ' store the whole assignment action into the collection.  The key for the
      ' collection value will be the property name.  This will allow us to 
      ' retrieve the value later on when editing rules.
      '---------------------------------------------------------------------
      strValue = ""    
      
      ' if it's a label, just output the label
      if ucase(objActionData.ColumnType) = "LABEL" then
        call response.write(objActionData.DisplayName)
      
      else
        ' we are just reading it in from the ruleset                                   
        for each objRSAction in objRSActionSet
          if ucase(objRSAction.PropertyName) = ucase(objActionData.PropertyName) then
            ' if the action matches, save the value          
            strValue = objRSAction.PropertyValue
            call colGlobalActions.add(objRSAction, objRSAction.PropertyName)
            exit for
          end if
        next
        
        call response.write(strValue)
        
      end if ' end test of the column type  
      
      call response.write("</TD>" & vbNewLine)                
      call response.write("  </TR>" & vbNewLine)
      
    next ' loop on GlobalActionData
    
    call response.write("</TABLE>" & vbNewLine)
    call response.write("<BR><BR>" & vbNewLine)
  end if ' end test on whether there are any actions to display
  
  '---------------------------------------------------------------------
  ' Save the collection of global action values into the session for
  ' later use when editing rules
  '---------------------------------------------------------------------
  set session("GlobalActionValues") = colGlobalActions 
end sub

'----------------------------------------------------------------------------
'   Name: writeRuleSetRows
'   Description:  writes out the rules for a ruleset using the ruleset object
'                 Assumes the table has already been started.
'   Parameters: ibolRemove - a flag to indicate that the items should be marked 
'                           for removal instead of for editing
'   Return Value: none
'-----------------------------------------------------------------------------
sub writeRuleSetRows(ibolRemove)

  dim bolOdd        ' as boolean
  dim strClassName  ' as string
  dim objRule
  dim objRSConditionSet
  dim objRSCondition
  dim objRSActionSet
  dim objRSAction
  dim objConditionData
  dim objActionData
  
  dim bolRuleFilteredOut
  dim objFilterCondition
  dim bolConditionFound
  
  dim arrstrValues
  dim arrstrText
  dim strTemp
  
  dim objTempCondition
  
  dim intDisplayedRows
  dim i
  dim j
  dim intRSCount
  
  bolOdd = false
  i = 0
  mintFilteredOut = 0
  intDisplayedRows = 0
  
  intRSCount = mobjRuleSet.count
				
  'AddDebugMessage "Writing Rules"
  
  
  ' loop through all the rules in the ruleset
  for i = mintStartNum to intRSCount ' for i = mintStartNum to intRSCount - 1
    set objRule = mobjRuleSet(i)
    
    if intDisplayedRows = MAX_RULES and not mbolFiltering then 
        exit for
    end if
    
    Set objRSConditionSet = objRule.Conditions
    Set objRSActionSet = objRule.Actions
    
    '--------------------------------------------------------------------
    ' Find out if this row needs to be filtered out
    '--------------------------------------------------------------------
    bolRuleFilteredOut = false
    if mbolFilterAvailable and mobjTRReader.FilterConditions.count > 0 then
        
        ' Start by assuming that we will not filter this row.  If we ever find a condition
        ' that does not match, then we will filter it out
        
        ' loop through each of the filters
        for each objFilterCondition in mobjTRReader.FilterConditions
            
            set objTempCondition = objFilterCondition.Condition
            'AddDebugMessage "Testing filter.  Value: " & objTempCondition.Value & " - Test: " & objTempCondition.Test
            
            bolConditionFound = false
            
            ' for each filter, loop through all the conditions in the condition set
            ' until you find the matching condition.
            ' AddDebugMessage "looping through the ruleset conditions"
            for each objRSCondition in objRSConditionSet
                
                'AddDebugMessage "looking at condition: " & objRSCondition.PropertyName
                '---------------------------------------------------------------------
                ' Find the matching condition.  Once the matching condition is found,
                ' see if the value and test operator match.  If they do not match, then
                ' this rule should be filtered out and we should exit the for loop
                '---------------------------------------------------------------------
                if objTempCondition.PropertyName = objRSCondition.PropertyName then
                    'AddDebugMessage "found condition"
                    bolConditionFound = true
                    
                    if not ConditionsAreEqual(objTempCondition, objRSCondition) then               
                        'AddDebugMessage "Rule Filtered.  Value: " & objRSCondition.Value & " - Test: " & objRSCondition.Test
                        
                        bolRuleFilteredOut = true
                        exit for
                    end if ' end test on whether the value and test match
                end if ' end test on whether the conditions have the same name
                
            next ' end loop on RS Conditions    
            
            ' If the Rule's ConditionSet does not contain the same condition, then
            ' we should filter out the rule
            if not bolConditionFound then
                'AddDebugMessage "rule filtered because a matching condition could not be found"
                bolRuleFilteredOut = true
            end if
            
        next ' end loop on FilterConditions
        
    end if ' end test of whether fiters can even apply
    
    ' Draw the row if it has not been filtered out
    if bolRuleFilteredOut then
        mintFilteredOut = mintFilteredOut + 1
    else
        intDisplayedRows = intDisplayedRows + 1
        
        'AddDebugMessage "rule has not been filtered out and will be displayed"
        
        ' do the row coloring
        bolOdd = not bolOdd
        if bolOdd then
            strClassName = "RuleEditorTableCell"
        else
            strClassName = "RuleEditorTableCellAlt"
        end if
        
        ' write the row, the move up/down buttons, edit button - if not removing
        call mcolTableOutputStrings.add("  <TR>" & vbNewLine)
        call mcolTableOutputStrings.add("    <TD WIDTH=""0"" ALIGN=""center"" class=""" & strClassName & """>" & i & "</TD>" & vbNewLine) 
        if not ibolRemove and UCase(session("RATES_EDITMODE")) = "TRUE" then
            
            if mobjTRReader.ConditionDatas.Count > 0 then       ' If we only have a single action row, no conditions, we don't need to display this
                call mcolTableOutputStrings.add("<TD WIDTH=""0"" NOWRAP ALIGN=""center"" class=""" & strClassName & """>") 
                if i > 1 then
                    call mcolTableOutputStrings.add("<A HREF=""gotoRuleEditor.asp?id=" & i & "&page=" & i & "&move=U" & """>")
                    call mcolTableOutputStrings.add("<IMG SRC=""/mpte/us/images/moveup.gif"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_MOVERULEUP") & """ BORDER=""0""></A>")
                end if
                if i < intRSCount then
                    call mcolTableOutputStrings.add("<A HREF=""gotoRuleEditor.asp?id=" & i & "&page=" & i & "&move=D" & """>")
                    call mcolTableOutputStrings.add("<IMG SRC=""/mpte/us/images/movedown.gif"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_MOVERULEDOWN") & """ BORDER=""0""></A>")
                end if
                call mcolTableOutputStrings.add("</TD>" & vbNewLine)
            end if
            
            call mcolTableOutputStrings.add("    <TD WIDTH=""0"" ALIGN=""center"" class=""" & strClassName & """>") 
            call mcolTableOutputStrings.add("<A Name='butEdit' HREF=""javascript:OpenDialogWindow('gotoPopup.asp?loadpage=GenericEditRuleset.asp&ID=" & i & "', '');""><IMG SRC=""/mpte/us/images/edit.gif"" BORDER=""0"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_EDITROW") & """></A>")
            call mcolTableOutputStrings.add("</TD>" & vbNewLine)
            
            if mobjTRReader.ConditionDatas.Count > 0 then       ' If we only have a single action row, no conditions, we don't need to display this
                call mcolTableOutputStrings.add("    <TD WIDTH=""0"" ALIGN=""center"" class=""" & strClassName & """>") 
               	call mcolTableOutputStrings.add("<A HREF=""javascript:OpenDialogWindow('gotoPopup.asp?loadpage=GenericEditRuleset.asp&new=T&ID=" & i & "', '');""><IMG SRC=""/mpte/us/images/addrows.gif"" BORDER=""0"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_ADDROW") & """></A>")
                call mcolTableOutputStrings.add("</TD>" & vbNewLine)
            end if
        end if
      
        ' write the conditions
        if mobjTRReader.ConditionDatas.count > 0 then
            'SECENG: CORE-4793 CLONE - MSOL BSS 30015 MetraOffer - Insecure XML Loading which allows for file discloure, DoS and XSS
            'Added HTML encoding
            call mcolTableOutputStrings.add("    <TD WIDTH=""5"" ALIGN=""center"" class=""" & strClassName & "Special"">" & SafeForHtml(FrameWork.GetDictionary("TEXT_MPTE_CONNECTOR_IF")) & "</TD>" & vbNewLine) 
            
            '-----------------------------------------------------------------------
            ' We don't have any guarantee that the conditions in the ruleset match the order
            ' of the conditions diplayed.  So, for each condition column, we have to
            ' loop through all the conditions in the rule and try to find a match
            '-----------------------------------------------------------------------
            'AddDebugMessage "Starting to loop through the conditions"
            
            for each objConditionData in mobjTRReader.ConditionDatas
                'AddDebugMessage "looking for condition: <B>" & objConditionData.DisplayName & "</B> - Column Type = " & objConditionData.ColumnType          
                
                ' test to see if this condition is just a label
                if ucase(objConditionData.ColumnType) = "LABEL" then
                    call mcolTableOutputStrings.add("    <TD NOWRAP ALIGN=""LEFT"" class=""" & strClassName & """>")
                    call mcolTableOutputStrings.add(objConditionData.DisplayName)
                    
                else ' not a label, so find if we have a condition in the file for it
                    call mcolTableOutputStrings.add("    <TD NOWRAP ALIGN=""" & AlignString(objConditionData.PType) & """ class=""" & strClassName & """>")
                    ' if we are to display the operator, put it here now
            
                    'AddDebugMessage "looking for the matching ruleset condition"
                    for each objRSCondition in objRSConditionSet
                        'AddDebugMessage "ruleset condition: " & objRSCondition.PropertyName
                        
                        '----------------------------------------------------------------------- 
                        ' We need to suppport having multiple conditions with the same name.
                        ' However, the name and operator pair must be unique if the operator is
                        ' specified.  If the operator is unspecified, we can only match on the name
                        '-----------------------------------------------------------------------
                           
                        if ((objConditionData.EditOperator) and (ucase(objRSCondition.PropertyName) = ucase(objConditionData.PropertyName))) or _
                           ((ucase(objRSCondition.PropertyName) = ucase(objConditionData.PropertyName)) and (Clng(objConditionData.Operator) = TestToOperatorType(objRSCondition.Test))) then
                            'AddDebugMessage "matched condition"
                            
                            if ucase(objConditionData.DisplayOperator) = "ROW" or objConditionData.EditOperator then
								'SECENG: CORE-4793 CLONE - MSOL BSS 30015 MetraOffer - Insecure XML Loading which allows for file discloure, DoS and XSS
								'Added HTML encoding
                                call mcolTableOutputStrings.add(TestToSymbolHTML(objRSCondition.Test) & "&nbsp;")
                            end if
                
                            'AddDebugMessage "condition ptype: " & objConditionData.PType
                            'AddDebugMessage "condition value: " & objRSCondition.Value
                            
                            if CLng(objConditionData.PTYPE) = PROP_TYPE_ENUM then
                                set arrstrValues = objConditionData.EnumValues
                                set arrstrText = objConditionData.EnumStrings
                                
                                j = 1
                                'AddDebugMessage "EnumType - looking for : " & objRSCondition.Value
                                
                                for each strTemp in arrstrValues
                                    'AddDebugMessage "Looking to match: " & strTemp
                                    if strTemp = objRSCondition.Value then
										'SECENG: CORE-4793 CLONE - MSOL BSS 30015 MetraOffer - Insecure XML Loading which allows for file discloure, DoS and XSS
										'Added HTML encoding
                                        call mcolTableOutputStrings.add(SafeForHtml(arrstrText(j)))
                                        exit for
                                    end if
                                    j = j + 1
                                next
                                
                                if j > arrstrValues.count then
									'SECENG: CORE-4793 CLONE - MSOL BSS 30015 MetraOffer - Insecure XML Loading which allows for file discloure, DoS and XSS
									'Added HTML encoding
                                    call mcolTableOutputStrings.add(ConvertValueToEnumerator(objConditionData.EnumSpace, objConditionData.EnumType, SafeForHtml(objRSCondition.Value)))
                                end if

                  
                            else
								' SECENG: Fix CORE-4793 CLONE - MSOL BSS 30015 MetraOffer - Insecure XML Loading which allows for file discloure, DoS and XSS
                                if IsObject(objRSCondition.Value) then
                                  Err.Raise vbObjectError,"","XML structure is wrong."
                                end if
                                call mcolTableOutputStrings.add(FormatString(objConditionData.PType, objRSCondition.Value, objRSCondition.PropertyName))
                            end if
                            
                            exit for
                        else ' If condition did not match
												end if ' End of test to see if name and operator matched
                    next
                    
                end if ' end test of the column type    
                
                call mcolTableOutputStrings.add("&nbsp;</TD>" & vbNewLine)
                
            next ' loop on ConditionData
            
        end if ' end test on whether there are any conditions to display
        
        
        ' write the actions
        if mobjTRReader.ActionDatas.count > 0 then
            if mobjTRReader.ConditionDatas.Count > 0 then       ' If we only have a single action row, no conditions, we don't need to display this
				'SECENG: CORE-4793 CLONE - MSOL BSS 30015 MetraOffer - Insecure XML Loading which allows for file discloure, DoS and XSS
				'Added HTML encoding
                call mcolTableOutputStrings.add("    <TD WIDTH=""5"" ALIGN=""center"" class=""" & strClassName & "Special"">" & SafeForHtml(FrameWork.GetDictionary("TEXT_MPTE_CONNECTOR_THEN")) & "</TD>" & vbNewLine)
            end if
            
            'AddDebugMessage "Starting to loop through the actions"
            
            '-----------------------------------------------------------------------
            ' We don't have any guarantee that the actions in the ruleset match the order
            ' of the actions diplayed.  So, for each action column, we have to
            ' loop through all the actions in the rule and try to find a match    
            '----------------------------------------------------------------------- 
            for each objActionData in mobjTRReader.ActionDatas        
                'AddDebugMessage "looking for action: <B>" & objActionData.DisplayName & "</B>"
                
                ' test to see if this condition is just a label
                if ucase(objActionData.ColumnType) = "LABEL" then
                    'AddDebugMessage "It is a label, so just output that"
                    call mcolTableOutputStrings.add("    <TD NOWRAP ALIGN=""LEFT"" class=""" & strClassName & """>")
                    call mcolTableOutputStrings.add(objActionData.DisplayName)          
                    
                else ' not a label, so find if we have an action in the file for it
                    call mcolTableOutputStrings.add("    <TD NOWRAP ALIGN=""" & AlignString(objActionData.PType) & """ class=""" & strClassName & """>")
                    'AddDebugMessage "looking for the matching ruleset action"

                    boolmatched = false ' Flag to test whether rule was matched or not
                    for each objRSAction in objRSActionSet
                        
                        'AddDebugMessage "ruleset action: " & objRSAction.PropertyName
                        
                        if ucase(objRSAction.PropertyName) = ucase(objActionData.PropertyName) then
                            'AddDebugMessage "matched condition"      
                            'AddDebugMessage "action ptype: " & objActionData.PType
                            'AddDebugMessage "action value: " & objRSAction.PropertyValue
                            
														boolmatched = true
														
                            if CLng(objActionData.PTYPE) = PROP_TYPE_ENUM then
                                set arrstrValues = objActionData.EnumValues
                                set arrstrText = objActionData.EnumStrings
                                
                                j = 1
                                for each strTemp in arrstrValues
                                    if strTemp = objRSAction.PropertyValue then
                                        call mcolTableOutputStrings.add(arrstrText(j))
                                        exit for
                                    end if
                                    j = j + 1
                                next
                                
                                if j > arrstrValues.count then
                                    call mcolTableOutputStrings.add(ConvertValueToEnumerator(objActionData.EnumSpace, objActionData.EnumType, objRSAction.PropertyValue))
                                end if
                                
                            else
                                call mcolTableOutputStrings.add(FormatString(objActionData.PType, objRSAction.PropertyValue, objRSAction.PropertyName))
                            end if
                            
                            exit for
                        end if
                    next
										
										if not boolmatched then ' If the ruleset doesn't have this property, we will add a blank space to it
											call mcolTableOutputStrings.add(FormatString(PROP_TYPE_STRING, "", objActionData.PropertyName))
										end if
										
                end if ' end test of the column type    
                
                call mcolTableOutputStrings.add("&nbsp;</TD>" & vbNewLine)
                
            next ' loop on ActionData
      
        end if ' end test on whether there are any actions to display
        
        if ibolRemove then
            call mcolTableOutputStrings.add("    <TD ALIGN=""center"" class=""" & strClassName & """>" & _
                                            "<INPUT TYPE=""Checkbox"" NAME=""RemoveID"" VALUE=""" & i &"""></TD>")
        end if
        call mcolTableOutputStrings.add("  </TR>" & vbNewLine)
        
    end if ' end test of filtered rule
  next
  
  '----------------------------------------------------------------------------------
  ' Write out the default action
  '----------------------------------------------------------------------------------

  bolOdd = not bolOdd
  if bolOdd then
      strClassName = "RuleEditorTableCell"
  else
      strClassName = "RuleEditorTableCellAlt"
  end if
  
  ' write the row, the move up/down buttons, edit button - if not removing
  call mcolTableOutputStrings.add("  <TR>" & vbNewLine)
  call mcolTableOutputStrings.add("    <TD ALIGN=""center"" class=""" & strClassName & """>&nbsp;</TD>" & vbNewLine)  
  if not ibolRemove and UCase(session("RATES_EDITMODE")) = "TRUE" then
    if mobjTRReader.ConditionDatas.Count > 0 then ' If we only have a single action row, no conditions, we don't need to display this
       call mcolTableOutputStrings.add("    <TD ALIGN=""center"" class=""" & strClassName & """>&nbsp;</TD>" & vbNewLine) 
    end if
    call mcolTableOutputStrings.add("    <TD ALIGN=""center"" class=""" & strClassName & """>")
		if not mobjRuleSet.DefaultActions is nothing then
     	call mcolTableOutputStrings.add("<A Name='butEdit' HREF=""javascript:OpenDialogWindow('gotoPopup.asp?loadpage=GenericEditRuleset.asp&ID=default&CurrPage=" & mintStartNum & "', '');""><IMG SRC=""/mpte/us/images/edit.gif"" BORDER=""0"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_EDITDEFAULTRULE") & """></A>")
		else
			call mcolTableOutputStrings.add("&nbsp;")
		end if	
    call mcolTableOutputStrings.add("</TD>" & vbNewLine)
    if mobjTRReader.ConditionDatas.Count > 0 then ' If we only have a single action row, no conditions, we don't need to display this    
		  call mcolTableOutputStrings.add("    <TD ALIGN=""center"" class=""" & strClassName & """>")
		  'call mcolTableOutputStrings.add("&nbsp;")
			call mcolTableOutputStrings.add("</TD>" & vbNewLine)
    end if
  end if
  ' no conditions for this rule, since it is the default action
  if mobjTRReader.ConditionDatas.count > 0 then
		if not mobjRuleSet.DefaultActions is nothing then
			call mcolTableOutputStrings.add("    <TD WIDTH=""5"" ALIGN=""center"" class=""" & strClassName & "Special"">if</TD>" & vbNewLine)
		else
			call mcolTableOutputStrings.add("<TD class=""" & strClassName & "Special"">&nbsp;</TD>")
		end if
    call mcolTableOutputStrings.add("    <TD COLSPAN=""" & mobjTRReader.ConditionDatas.count & """ NOWRAP ALIGN=""center"" class=""" & strClassName & """>")

		if not mobjRuleSet.DefaultActions is nothing then
			call mcolTableOutputStrings.add(FrameWork.GetDictionary("TEXT_MPTE_DEFAULTRULE") & vbNewLine)
		elseif not mbolAllConditionsOpt then
			call mcolTableOutputStrings.add(FrameWork.GetDictionary("TEXT_MPTE_DEFAULTRULE_NOT_ALLOWED") & vbNewLine)
		elseif UCase(session("RATES_EDITMODE")) = "TRUE" and not ibolRemove then
			call mcolTableOutputStrings.add("<A Name='aAddDefaultRule' HREF=""javascript:OpenDialogWindow('gotoPopup.asp?loadpage=GenericEditRuleset.asp&ID=default&new=T&currpage=" & mintStartNum & "', '');"">" & FrameWork.GetDictionary("TEXT_MPTE_ADD_DEFAULTRULE") & "</A>")
		'elseif mbolRuleNotConfigured then
			'call mcolTableOutputStrings.add("Rule not configured" & vbNewLine)
		else
			call mcolTableOutputStrings.add(FrameWork.GetDictionary("TEXT_MPTE_NO_DEFAULTRULE") & vbNewLine)
		end if
		call mcolTableOutputStrings.add("</TD>")
  end if
  
  ' write the actions
  if mobjTRReader.ActionDatas.count > 0 then 
		if not mobjRuleSet.DefaultActions is nothing and not mbolRuleNotConfigured then ' If the def action is null, and we didn't create a temp def action
																																										' for a param table with NO conditions
      if mobjTRReader.ConditionDatas.Count > 0 then ' If we only have a single action row, no conditions, we don't need to display this
        call mcolTableOutputStrings.add("    <TD WIDTH=""5"" ALIGN=""center"" class=""" & strClassName & "Special"">" & FrameWork.GetDictionary("TEXT_MPTE_CONNECTOR_THEN") & "</TD>" & vbNewLine) 
      end if 
      'AddDebugMessage "Starting to loop through the actions"
      
      set objRSActionSet = mobjRuleSet.DefaultActions
			
      '-----------------------------------------------------------------------
      ' We don't have any guarantee that the actions in the ruleset match the order
      ' of the actions diplayed.  So, for each action column, we have to
      ' loop through all the actions in the rule and try to find a match    
      '----------------------------------------------------------------------- 
      for each objActionData in mobjTRReader.ActionDatas        
        'AddDebugMessage "looking for action: <B>" & objActionData.DisplayName & "</B>"
          
        'test to see if this condition is just a label
        if ucase(objActionData.ColumnType) = "LABEL" then
          call mcolTableOutputStrings.add("    <TD NOWRAP ALIGN=""LEFT"" class=""" & strClassName & """>")
          call mcolTableOutputStrings.add(objActionData.DisplayName)          
        else ' not a label, so find if we have an action in the file for it
          call mcolTableOutputStrings.add("    <TD NOWRAP ALIGN=""" & AlignString(objActionData.PType) & """ class=""" & strClassName & """>")
          'AddDebugMessage "looking for the matching ruleset action"
              
          for each objRSAction in objRSActionSet
          'AddDebugMessage "ruleset action: " & objRSAction.PropertyName
                  
          if ucase(objRSAction.PropertyName) = ucase(objActionData.PropertyName) then
          	'AddDebugMessage "matched condition"
            'AddDebugMessage "action ptype: " & objActionData.PType
            'AddDebugMessage "action value: " & objRSAction.PropertyValue
                      
            if CLng(objActionData.PTYPE) = PROP_TYPE_ENUM then
              set arrstrValues = objActionData.EnumValues
              set arrstrText = objActionData.EnumStrings
              j = 1
            	for each strTemp in arrstrValues
              	if strTemp = objRSAction.PropertyValue then
              		call mcolTableOutputStrings.add(arrstrText(j))
              		exit for
              	end if
              j = j + 1
              next
                          
						if j > arrstrValues.count then
							call mcolTableOutputStrings.add(ConvertValueToEnumerator(objActionData.EnumSpace, objActionData.EnumType, objRSAction.PropertyValue))
						end if

					else
						call mcolTableOutputStrings.add(FormatString(objActionData.PType, objRSAction.PropertyValue, objRSAction.PropertyName))
					end if
				exit for
			end if
			next
		end if ' end test of the column type    

		call mcolTableOutputStrings.add("&nbsp;</TD>" & vbNewLine)
		next ' loop on ActionData
	elseif not mbolRuleNotConfigured then ' The def rule is null, but we didn't create a temp condition for it
		call mcolTableOutputStrings.add("    <TD NOWRAP ALIGN=""LEFT"" class=""" & strClassName & """>&nbsp;</TD>")
		for each objActionData in mobjTRReader.ActionDatas
			call mcolTableOutputStrings.add("    <TD NOWRAP ALIGN=""LEFT"" class=""" & strClassName & """>&nbsp;</TD>")
		next
	else ' We created a temp condition, but it is not configured yet. Let's display a warning message
		for each objActionData in mobjTRReader.ActionDatas
			call mcolTableOutputStrings.add("    <TD NOWRAP ALIGN=""RIGHT"" class=""" & strClassName & """>" & FrameWork.GetDictionary("TEXT_MPTE_VALUE_NOT_CONFIGURED") & "</TD>")
		next
	end if ' end test on whether there are any actions to display
end if
	
If not mobjRuleSet.DefaultActions Is Nothing and ibolRemove Then ' now we can remove default actions
  call mcolTableOutputStrings.add("    <TD ALIGN=""center"" class=""" & strClassName & """>" & "<INPUT TYPE=""Checkbox"" NAME=""RemoveID"" VALUE=""" & "default" &"""></TD>")
elseif ibolRemove then
	call mcolTableOutputStrings.add("    <TD ALIGN=""center"" class=""" & strClassName & """>&nbsp;</TD>")
End If
call mcolTableOutputStrings.add("  </TR>" & vbNewLine)

end sub


'----------------------------------------------------------------------------
'   Name: writeTableHeaderRows
'   Description:  Writes out the header rows for the ruleset table based on
'               the conditions and action properties.
'               Assumes the table has already been started
'   Parameters: ibolRemove - a flag to indicate that the items should be marked 
'                           for removal instead of for editing
'   Return Value: none
'-----------------------------------------------------------------------------
sub writeTableHeaderRows(ibolRemove)
  dim objCondition  ' as ConditionData
  dim objAction     ' as ActionData
  dim strTableHeader ' as a Stylesheet Class
  
  strTableHeader = "RuleEditorTableHeader"
  
  ' write the row, move up/down column, edit column - if not removing
  call mcolTableOutputStrings.add("  <TR>" & vbNewLine)
  call mcolTableOutputStrings.add("    <TD WIDTH=""0"" class=" & strTableHeader & " NOWRAP>#</TD>" & vbNewLine)
  if not ibolRemove and UCase(session("RATES_EDITMODE")) = "TRUE" then
    if mobjTRReader.ConditionDatas.Count > 0 then   ' If we only have a single action row, no conditions, we don't need to display this
      call mcolTableOutputStrings.add("    <TD WIDTH=""0"" class=" & strTableHeader & ">" & FrameWork.GetDictionary("TEXT_MPTE_CONNECTOR_MOVE") & "</TD>" & vbNewLine)
    end if
  	call mcolTableOutputStrings.add("    <TD WIDTH=""0"" class="& strTableHeader & ">" & FrameWork.GetDictionary("TEXT_MPTE_CONNECTOR_EDIT") & "</TD>" & vbNewLine)
    if mobjTRReader.ConditionDatas.Count > 0 then   ' If we only have a single action row, no conditions, we don't need to display this
      call mcolTableOutputStrings.add("    <TD WIDTH=""0"" class="& strTableHeader & ">" & FrameWork.GetDictionary("TEXT_MPTE_CONNECTOR_ADD") & "</TD>" & vbNewLine)
    end if
  end if
  
  ' write the conditions header - add extra column for "if"
  if mobjTRReader.ConditionDatas.count > 0 then
    call mcolTableOutputStrings.add("    <TD class="& strTableHeader &" COLSPAN=""" & _
                        mobjTRReader.ConditionDatas.count + 1 & _
                        """>" & mobjTRReader.ConditionsHeader & "</TD>" & vbNewLine)
  end if

  ' write the actions header - add extra column for "then"
  if mobjTRReader.ActionDatas.count > 0 then
    call mcolTableOutputStrings.add("    <TD class="& strTableHeader &" COLSPAN=""" & _
                        mobjTRReader.ActionDatas.count + 1 & _
                        """>" & mobjTRReader.ActionsHeader & "</TD>" & vbNewLine)
  end if
  
  ' add a column for removing if appropriate
  if ibolRemove and UCase(session("RATES_EDITMODE")) = "TRUE" then
    call mcolTableOutputStrings.add("    <TD class="& strTableHeader &">" & FrameWork.GetDictionary("TEXT_MPTE_CONNECTOR_REMOVE") & "</TD>")
  end if
  call mcolTableOutputStrings.add("  </TR>" & vbNewLine)
  
  ' write the row, move up/down column, edit column - if not removing
  call mcolTableOutputStrings.add("  <TR>" & vbNewLine)
  call mcolTableOutputStrings.add("    <TD WIDTH=""0"" class="& strTableHeader &">&nbsp;</TD>" & vbNewLine)
  if not ibolRemove and UCase(session("RATES_EDITMODE")) = "TRUE" then
  	if mobjTRReader.ConditionDatas.Count > 0 then   ' If we only have a single action row, no conditions, we don't need to display this
    	call mcolTableOutputStrings.add("    <TD WIDTH=""0"" class="& strTableHeader &">&nbsp;</TD>" & vbNewLine)
    end if
   	call mcolTableOutputStrings.add("    <TD WIDTH=""0"" class="& strTableHeader &">&nbsp;</TD>" & vbNewLine)
    if mobjTRReader.ConditionDatas.Count > 0 then   ' If we only have a single action row, no conditions, we don't need to display this
    	call mcolTableOutputStrings.add("    <TD WIDTH=""0"" class="& strTableHeader &">&nbsp;</TD>" & vbNewLine)
    end if
  end if
  
  ' write all the conditions - add extra column for "if"
  if mobjTRReader.ConditionDatas.count > 0 then
    call mcolTableOutputStrings.add("    <TD WIDTH=""5"" class="& strTableHeader &">&nbsp;</TD>" & vbNewLine)

		' We will use this variable to check whether all conditions are optional. This is needed so we know whether to allow a default rule or not
    mbolAllConditionsOpt = true
		
		for each objCondition in mobjTRReader.ConditionDatas

			if objCondition.Required then
				mbolAllConditionsOpt = false
			end if

      call mcolTableOutputStrings.add("    <TD class="& strTableHeader &">")
  
      ' Handle the case of a label first - check to see if it should be displayed
      if ucase(objCondition.ColumnType) = "LABEL" then
        call mcolTableOutputStrings.add("&nbsp;")      
      else 
        ' it is not a label - so display the name of the property
        call mcolTableOutputStrings.add(objCondition.DisplayName)
        
        ' Now handle the case of displaying the operator
        if ucase(objCondition.DisplayOperator) = "COLUMN" and not objCondition.EditOperator then
        	call mcolTableOutputStrings.add("&nbsp;(" & OperatorTranslate(objCondition.Operator) & ")")
        end if
         
      end if
      call mcolTableOutputStrings.add("</TD>" & vbNewLine)
    next
  end if
  
  ' write all the actions - add extra column for "then"
  if mobjTRReader.ActionDatas.count > 0 then
  	if mobjTRReader.ConditionDatas.Count > 0 then   ' If we only have a single action row, no conditions, we don't need to display this
      call mcolTableOutputStrings.add("    <TD WIDTH=""5"" class="& strTableHeader &">&nbsp;</TD>" & vbNewLine)
    end if
    for each objAction in mobjTRReader.ActionDatas
      call mcolTableOutputStrings.add("    <TD class="& strTableHeader &">")
    
      ' Handle the case of a label first - check to see if it should be displayed
      if ucase(objAction.ColumnType) = "LABEL" then
        call mcolTableOutputStrings.add("&nbsp;")
      else 
        call mcolTableOutputStrings.add(objAction.DisplayName)
      end if
      
      call mcolTableOutputStrings.add("</TD>" & vbNewLine)
    next
  end if
  
  ' add a column for removing if appropriate
  if ibolRemove then
    call mcolTableOutputStrings.add("    <TD class="& strTableHeader &"><A HREF=""javascript:CheckAll();""><IMG SRC=""/mpte/us/images/check.gif"" BORDER=""0"" ALT=""" & FrameWork.GetDictionary("TEXT_MPTE_ALT_REMOVEITEMSCLICK") & """></A></TD>")
  end if
  call mcolTableOutputStrings.add("  </TR>" & vbNewLine)

end sub

'----------------------------------------------------------------------------
'   Name: RemoveItems
'   Description:  Deletes the selected rules from the rule set
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
sub RemoveItems
  dim intRuleCounter
  dim strTempList
  
  if len(request.Form("RemoveID")) = 0 then
    exit sub
  end if
  
  strTempList = ", " & request.Form("RemoveID") & ","
  AddDebugMessage "strTempList: [" & strTempList & "]<BR>"
    
  '----------------------------------------------------------------------
  ' Build a string out of the list of removed items.  Then loop through
  ' The ruleset backwards to avoid index problems with removing.  Remove any
  ' rule where the ID is found in the query string
  '----------------------------------------------------------------------
  ' for intRuleCounter = mobjRuleSet.count - 1 to 0 step -1
  for intRuleCounter = mobjRuleSet.count to 1 step -1
    'AddDebugMessage "looking for rule: " & intRuleCounter & "<BR>"
    if instr(strTempList, ", " & intRuleCounter & ",") then
      'AddDebugMessage "<B>found rule - removing it!!</B><BR>"
      call mobjRuleSet.remove(intRuleCounter)
    end if
  Next
  If InStr(strTempList, "default") Then
      mobjRuleSet.DefaultActions = Nothing
  End if
    
end sub


'----------------------------------------------------------------------------
'   Name: writeNumberOutput
'   Description:  Writes out a string of how many rules there are and how many 
'                 have been filtered out.
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
function writeNumberOutput()
 ' Localize this
  writeNumberOutput = FrameWork.GetDictionary("TEXT_MPTE_TOTAL") & mobjRuleSet.count & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_RULES")
  if mbolFilterAvailable then
    writeNumberOutput = writeNumberOutput & "&nbsp;&nbsp;-&nbsp;&nbsp;" & mintFilteredOut & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_RULES") & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_FILTERED")  
	end if
end function

'----------------------------------------------------------------------------
' PAGE PROCESSING STARTS
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
' We included the page processing in a function called main, so we get specific
' error handling on some critical parts of the process
' In particular, we want to check for any problems related to Product Catalog
' objects that might not be instantiated or retrieved correctly.
'----------------------------------------------------------------------------
PUBLIC FUNCTION Main

		dim strDateWarning ' holds warning message about effective dates in the past
		
		mbolRemove 		= false
		mbolAdding 		= false
		mbolFiltering = false
		mbolSubmitted = true
		mintStartNum 	= 1
		
		'------------------------------------------------------------------------
		' If the user clicked on the paging, we save the current page to the form
		' This is different from the ruleeditor because MPTE has to use the POST
		' method in the FORM, instead of get.
		'------------------------------------------------------------------------		
		if len(request.QueryString("page")) > 0 then
			mintStartNum = CLng(request.QueryString("page"))
		elseif len(request.Form("page")) > 0 then
			mintStartNum = CLng(request.Form("page"))
		end if

		'------------------------------------------------------------
  	' Find which page we're on and fix the value of mintStartNum to
		' be that of the index of the first rule on the current page.
		' mintStartNum could have a strange value if 
  	'------------------------------------------------------------
  	Dim intTmpCurPage
		if mintStartNum <= MAX_RULES then
    	intTmpCurPage = 1
  	else 
    	intTmpCurPage = int((mintStartNum -1) / MAX_RULES) + 1
  	end if	
		mintStartNum = (intTmpCurPage - 1)*MAX_RULES + 1
		
		' Check if we should draw the page in remove mode		
		if UCase(request.queryString("RemovePage")) = "TRUE" then
			mbolRemove = true
		end if
		
		mstrThisPage = "gotoRuleEditor.asp?"
		
		call ClearDebugMessages("/mpte/us/GenericEditRuleset.asp")
		
		'----------------------------------------------------------------------------
		' RELOAD - Our first task is to find out whether we want to do a complete reload or not
		' if yes, we expect to have the complete QueryString with all the item IDs
		' Note, if we reload, we will always refresh
		'----------------------------------------------------------------------------
		if UCase(Request.QueryString("Reload")) = "TRUE" Then
		
		  Dim strTMP ' Temp var
			
		  ' We just reloaded, so there are no changes.
		  session("UnsavedChanges") = false 
		  
		  '// This method will populate the session with information passed on the querystring
		  call LoadQueryString()
		  
		  '// Now we are reloading objects.
			'// This is a critical section of the code, therefore it is in special error handling
			'//-----------------------------------------------------------------------------------------------
			'On Error resume next
		  'Set objMTProductCatalog = Server.CreateObject("MetraTech.MTProductCatalog")
		  Set objMTProductCatalog = GetProductCatalogObject
			call WriteRunTimeError("Product Catalog" & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_CANNOT_CREATE_OBJ"), false)
					  
		  Set objParamTableDef = objMTProductCatalog.GetParamTableDefinition(Clng(session("RATES_PARAMTABLE_ID")))
			call WriteRunTimeError(FrameWork.GetDictionary("TEXT_KEYTERM_PARAMETER_TABLE") & FrameWork.GetDictionary("TEXT_MPTE_ERROR_NOT_FOUND") & "&nbps;" & "ID=" & session("RATES_PARAMTABLE_ID"), false)
			
		  Set objMTRateSched = objParamTableDef.GetRateSchedule(Clng(session("RATES_RATESCHEDULE_ID")))
			call WriteRunTimeError(FrameWork.GetDictionary("TEXT_KEYTERM_RATE_SCHEDULE") & FrameWork.GetDictionary("TEXT_MPTE_ERROR_NOT_FOUND") & "&nbps;" & session("RATES_RATESCHEDULE_ID"), false)

		  ' Get the Metadata from the parameter table
		  Set mobjTRReader = Server.CreateObject("MTTabRulesetReader.RulesetHandler")
			call WriteRunTimeError("Tabular Ruleset Reader" & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_CANNOT_CREATE_OBJ"), false)
			
     Dim unitDisplayName 
     Set unitDisplayName = objMTProductCatalog.GetPriceableItem(objMTRateSched.TemplateID)

		  call mobjTRReader.InitializeFromProdCat(Clng(session("RATES_PARAMTABLE_ID")))

      'for i=1 to mobjTRReader.ConditionDatas.Count step 1
      '  mobjTRReader.ConditionDatas(i).DisplayName = unitDisplayName.UnitDisplayName
      'Next

			call WriteRunTimeError("Tabular Ruleset Reader" & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_CANNOT_INITIALIZE_OBJ"), false)

		  ' Load enum types for this parameter table 
		  call mobjTRReader.LoadEnums("US")
			'WriteRunTimeError "Tabular Ruleset Reader" & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_CANNOT_LOAD_ENUMTYPES")
			
			On Error Goto 0
		  '//-----------------------------------------------------------------------------------------------
			
		  Set mobjRuleset = objMTRateSched.RuleSet ' get the ruleset from the RateSchedule.
			  
		  ' Save these in the session      
		  Set session("TRReader") = mobjTRReader
		  Set session("RuleSet") = mobjRuleset
		  Set session("CurrMTRateSchedule") = objMTRateSched

			call DetectDecimalPrecisions(mobjTRReader, mobjRuleset)
		  
			mbolRuleNotConfigured = false
		  if mobjTRReader.ConditionDatas.Count = 0 and mobjRuleset.DefaultActions is nothing then 
			' If we got here, it means that we are editing a Ruleset with 0 Conditions
			' This means that we will use just 1 row contained in the DefaultActions
			' But that row is not initialized, so we will create a temp actionset and
			' assign to it.
				mbolRuleNotConfigured = true
			  mobjRuleset.DefaultActions = CreateActionSet(objParamTableDef)  
			  'We now have unsaved changes, so we will flag our variable
			  'session("UnsavedChanges") = true        
		  end if
		         
		  ' // helpfile call
		  ' // Note that we have to branch depending on the mode we are on.
			' // I will leave it branched now even though 3 of the options are the same
			' // Just to illustrate that they are indeed different help files depending
			' // on whether we are in MCM or MAM        
		  if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" then
		    if UCase(session("RATES_EDITMODE")) = "TRUE" then
		       session("HelpContext")  = "gotoRuleEditor.hlp.htm" ' edit mode
		    else
		       session("HelpContext")  = "View.gotoRuleEditor.hlp.htm"  ' view mode
		    end if                  
		  else
		    if UCase(session("RATES_EDITMODE")) = "TRUE" then
		       session("HelpContext")  = "gotoRuleEditor.hlp.htm" ' edit mode
		    else
		       session("HelpContext")  = "gotoRuleEditor.hlp.htm" ' edit mode - we use the same helpfile in MAM
		       'session("HelpContext")  = "View.gotoRuleEditor.hlp.htm"  ' view mode
		    end if                                  
		  end if      
		end if
		
		'----------------------------------------------------------------------------
		' AFTEREDIT - THE EDIT, ADD OR FILTER SCREEN HAS JUST FINISHED, SO JUST RELOAD FROM THE RULESET
		'----------------------------------------------------------------------------
		if len(Request.QueryString("AfterEdit")) > 0 then
		  set mobjRuleSet = session("RuleSet")
		  set mobjTRReader = session("TRReader")
		  set objMTRateSched = session("CurrMTRateSchedule")

			call DetectDecimalPrecisions(mobjTRReader, mobjRuleset)
			
		  ' We just added/edited, so there are changes.
		  session("UnsavedChanges") = true
		  
		  call response.write("<Script LANGUAGE=""JavaScript1.2"">document.location=""gotoRuleEditor.asp?page=" & request.QueryString("page") & """;</SCRIPT>")
		   
		'----------------------------------------------------------------------------
		' THE IMPORT RULES MDM DIALOG HAS JUST FINISHED.
		'----------------------------------------------------------------------------
		
		elseif Len(request.queryString("PickerIDs")) Then
		  dim importRateSched ' We will import the rules from the selected rate schedule
		  dim tmpParamTable
		  dim propset, rules, newrules
		    
		  Set objMTProductCatalog = GetProductCatalogObject
		  Set tmpParamTable = objMTProductCatalog.GetParamTableDefinition(Clng(session("RATES_PARAMTABLE_ID")))
		
		  ' We can count on the PickerIDs being on the QueryString: we just came back from the copy rules popup
		  Set importRateSched = tmpParamTable.GetRateSchedule(Clng(Request.QueryString("PickerIDs")))
		  Set objMTRateSched = session("CurrMTRateSchedule")
		  
		  ' Note that this is a workaround to copy the rules
		  ' Ideally, we would need a method on ProductCatalog or something
		  Set rules     = importRateSched.Ruleset 
		  Set propset   = rules.WriteToSet
		  Set newrules  = objMTRateSched.RuleSet
		  propset.Reset
		  newrules.ReadFromSet propset
			
		  Set session("RuleSet") = objMTRateSched.Ruleset
		  Set mobjTRReader = session("TRReader")
			
			call DetectDecimalPrecisions(mobjTRReader, objMTRateSched.Ruleset)
			
		  ' We just imported rules, so there are changes
		  session("UnsavedChanges") = true
		  
		  ' Eventually we will need to remove these JavaScript calls
		  call response.write("<Script LANGUAGE=""JavaScript1.2"">document.location=""gotoRuleEditor.asp"";</SCRIPT>")  
		  call response.end
		   
		'----------------------------------------------------------------------------
		' REFRESH - CLEAR ALL SESSION VARIABLES FOR TAB RULESET AND LOAD UP THE RULES
		' Note: if we reload, we will always refresh (avoiding code duplication)
		'----------------------------------------------------------------------------
		elseif UCase(request.queryString("Refresh")) = "TRUE" then
		  AddDebugMessage "force refresh<BR>"
		  
		  ' In any case, we will set the varibles to the saved session objects ->refresh.
		  set mobjTRReader      =       session("TRReader")
		  set mobjRuleset       =       session("RuleSet")
		  set objMTRateSched 		=			  session("CurrMTRateSchedule") 
		  
			call DetectDecimalPrecisions(mobjTRReader, mobjRuleset)
			
		  ' Reset this guy. I have to find out what it does... TODO
		  mbolSubmitted = false
		  
		  ' We just refreshed, so there are no changes.
		  session("UnsavedChanges") = false
		  
		'----------------------------------------------------------------------------
		' MOVE - MOVE AN ITEM UP OR DOWN
		'----------------------------------------------------------------------------
		elseif len(request.queryString("move")) > 0 then
		  'AddDebugMessage "move up or down using cached ruleset<BR>"  
		  
		  set mobjRuleSet = session("RuleSet")
		  session("UnsavedChanges") = true
		  call MoveUpDown(request.queryString("move"), request.queryString("id"))
		  
		'----------------------------------------------------------------------------
		' SAVE - COMMIT ALL CHANGES TO THE DATABASE
		'----------------------------------------------------------------------------
		elseif request.Form("FormAction") = "Save" then
		  AddDebugMessage "save the cached ruleset to database<BR>"
		  set mobjTRReader = session("TRReader")
		  set mobjRuleSet = session("RuleSet")  
		  set objMTRateSched = session("CurrMTRateSchedule")
			
      '//Approvals
      'dim objApprovals, bApprovalsEnabled, bAllowMoreThanOnePendingChange, bRateScheduleHasPendingChange
      bApprovalsEnabled = false
      bAllowMoreThanOnePendingChange = true
      bRateScheduleHasPendingChange = false

      set objApprovals = InitializeApprovalsClient
      bApprovalsEnabled = objApprovals.ApprovalsEnabled("RateUpdate")

      dim objChangeDetailsHelper
      set objChangeDetailsHelper = CreateObject("MetraTech.Approvals.ChangeDetailsHelper")
      
      objChangeDetailsHelper("ParameterTableId") = Clng(session("RATES_PARAMTABLE_ID"))
      objChangeDetailsHelper("RateScheduleId") = Clng(session("RATES_RATESCHEDULE_ID"))
      
      dim objConfigSet
      set objConfigSet = objMTRateSched.RuleSet.WriteToSet

      objChangeDetailsHelper("UpdatedRuleSet") = objConfigSet.WriteToBuffer

      '//dim tempDebug
      '//tempDebug = objChangeDetailsHelper("UpdatedRuleSet")
      '//tempDebug = objChangeDetailsHelper.ToBuffer

      dim displayNameForItemInApprovals
      displayNameForItemInApprovals = mobjTRReader.Caption & " - " & objMTRateSched.Description

			' We will try to save the rateschedule and the newly added rules.
			' If it fails, we will display a specific error message.
			On Error resume next
			'objMTRateSched.SaveWithRules
      dim idChange, errorsSubmit
      idChange = objApprovals.SubmitChangeForApproval("RateUpdate", session("RATES_RATESCHEDULE_ID"), displayNameForItemInApprovals, "", objChangeDetailsHelper.ToBuffer, errorsSubmit)


			call WriteRunTimeError(FrameWork.GetDictionary("TEXT_MPTE_ERROR_RATESCHEDULE_SAVE_FAILED"), true)
      
      ' We just saved everything, so there are no changes.
		  session("UnsavedChanges") = false  

			On Error goto 0
									
		'----------------------------------------------------------------------------
		' GOTOREMOVE - INDICATES THAT WE SHOULD DRAW THE REMOVE SCREEN
		'----------------------------------------------------------------------------  
		elseif request.Form("FormAction") = "GoToRemove" then 
		  mbolRemove = true
		  mstrThisPage = mstrThisPage & "&FormAction=GoToRemove&"
		
		  set mobjRuleSet = session("RuleSet")
		    		
		'----------------------------------------------------------------------------
		' REMOVE - WE NEED TO DELETE THE SELECTED RULES
		'---------------------------------------------------------------------------- 
		elseif request.Form("FormAction") = "Remove" then
		  'AddDebugMessage "removing items<BR>"
		  set mobjRuleSet = session("RuleSet")
		  set mobjTRReader = session("TRReader")
			call RemoveItems
		  set session("RuleSet") = mobjRuleSet
		  ' We just removed stuff, so there are changes.
		  session("UnsavedChanges") = true
			
			call DetectDecimalPrecisions(mobjTRReader, mobjRuleset)	
      
		'----------------------------------------------------------------------------
		' EXPORT EXCEL - 
		'---------------------------------------------------------------------------- 
		elseif request.Form("FormAction") = "ExportExcel" then
   		Server.Execute "GenericTabRulesetExportImportExcelInclude.asp" 		
      response.end
		'----------------------------------------------------------------------------
		' ELSE - JUST LOAD THE PAGE FROM THE OBJECTS
		'---------------------------------------------------------------------------- 
		else
		  ' AddDebugMessage "already exists, use existing<BR>"
		   set mobjRuleSet = session("RuleSet")
		end if
		
		' reset the flag since we are back on this page
		session("AfterEdit") = false
		set mobjRuleset = session("RuleSet")
		set mobjTRReader = session("TRReader")
		set objMTRateSched = session("CurrMTRateSchedule")
		
		' Let's see if filters work
		call FindFilters()
		
		'----------------------------------------------------------------------------
		' HTML WRITING STARTS
		'----------------------------------------------------------------------------
		%>
		
		<html>
		<HEAD>  
		  <title><%=mobjTRReader.Caption%></title>
		  <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET1")%>">
		  <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET2")%>">
		  <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET3")%>">
		  
		  <script language="JavaScript" src="/mpte/shared/browsercheck.js"></script>
		  <script language="JavaScript" src="/mpte/shared/PopupEdit.js"></script>
		  <script language="JavaScript" src="/mpte/shared/forms.js"></script>
		  <script LANGUAGE="JavaScript1.2">
		    var mbolChecked = false;
		    
		    function SubmitForm(istrAction)
		    {
		      document.main.FormAction.value = istrAction;
		      document.main.submit();
		    }
		 
		    function CheckAll()
		    {
		      mbolChecked = !mbolChecked;
		      for (var i=0;i<document.main.elements.length;i++)
		      {
		        var e = document.main.elements[i];
		        if (e.name == 'RemoveID')
		          e.checked = mbolChecked;
		      }
		    }
		    
		    function Refresh()
		    {
		       //var strMsg = 'You have unsaved changes. Are you sure you want to refresh?';
		    	var strMsg = <% Response.Write("'" & FrameWork.GetDictionary("TEXT_MPTE_UNSAVED_CHANGES") & "';")%>
		       <%
		       response.write  "var strURL  = '" & _
		                            "gotoRuleEditor.asp?Reload=TRUE&Refresh=TRUE" & _
		                                                "';" & vbNewline
		
		       %>
		       <%
		       if session("UnsavedChanges") then
		       	 Response.Write("if(confirm(strMsg))")
		         Response.Write("document.location.href = strURL;")
		       else
		         Response.Write("document.location.href = strURL;")
		       end if
		       %>
		    }
		    
		    function returnToCallerApp()
		    {       
		    	var strMsg = <% Response.Write("'" & FrameWork.GetDictionary("TEXT_MPTE_UNSAVED_CHANGES") & "';")%>
		      <%
		      	Dim strURL
		        strURL = "'" & session("ownerapp_return_page") & "';"                                    
		      %>
		      <%
		        if session("UnsavedChanges") then
		        	Response.Write("if(confirm(strMsg))")
		          Response.Write("document.location.href =" & strURL)
		        else
		          Response.Write("document.location.href =" & strURL)
		        end if
		      %>
		     }
		  </SCRIPT>
		</HEAD>
		
		<BODY onUnload="CleanUp();" onFocus="javascript:GotFocus();" onBlur="javascript:LostFocus();">

		<FORM NAME="main" ACTION="<%=mstrThisPage%>" METHOD="POST">
		<INPUT TYPE="Hidden" NAME="FormAction" VALUE="">
		<INPUT TYPE="Hidden" NAME="page" VALUE="<%=mintStartNum%>">
		
		<% call DisplayTitle(mobjTRReader.Caption, "CaptionBar", objMTRateSched, (UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM")) %>

		
		<%
		if session("UnsavedChanges") = true then
		  response.Write "<br /><div class='clsNote2'>You have unsaved changes.</div><br />"
		end if
		%>
		    
		<% call WriteError(mstrErrors)%>
		<%
      '//With explicit rate auditing, rate warning message is no longer as important
			'strDateWarning = GetDateWarning(objMTRateSched.EffectiveDate) 
			'if UCase(session("RATES_EDITMODE")) = "TRUE" and len(TRIM(strDateWarning)) then
			'	call response.write("<BR>")
			'	call response.write("<span class=""ErrorMessageCaption"" style=""padding:5px;""><img align=absmiddle src=/mpte/us/images/warningSmall.gif>&nbsp;&nbsp;" & strDateWarning & "</span>") 
			'	call response.write("<BR>")
			'end if
		%> 
    <%
      '//Approvals
      dim objApprovals, bApprovalsEnabled, bAllowMoreThanOnePendingChange, bRateScheduleHasPendingChange
      bApprovalsEnabled = false
      bAllowMoreThanOnePendingChange = true
      bRateScheduleHasPendingChange = false

      set objApprovals = InitializeApprovalsClient
      bApprovalsEnabled = objApprovals.ApprovalsEnabled("RateUpdate")

      if bApprovalsEnabled then
        bAllowMoreThanOnePendingChange = objApprovals.ApprovalAllowsMoreThanOnePendingChange("RateUpdate")
        if NOT bAllowMoreThanOnePendingChange then
          bRateScheduleHasPendingChange = objApprovals.HasPendingChange("RateUpdate", session("RATES_RATESCHEDULE_ID"))
        end if
      end if

      dim strPendingChangeWarning
      strPendingChangeWarning =  FrameWork.GetDictionary("TEXT_APPROVALS_RATESCHEDULE_ALREADY_HAS_PENDING_CHANGE")

      'Check if user has capability to view approvals
      dim strTextViewPendingChange, strLinkViewPendingChange
      strTextViewPendingChange =  FrameWork.GetDictionary("TEXT_APPROVALS_VIEW_PENDING_CHANGE")
      strLinkViewPendingChange = "&nbsp;<b><A href=""javascript:void(0)"" onClick=""javascript:window.open('/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?showchangestate=PENDING&Filter_ChangesSummary_ChangeType=RateUpdate&Filter_ChangesSummary_UniqueItemId=" & session("RATES_RATESCHEDULE_ID") & "', '_blank', 'height=800,width=1000, resizable=yes, scrollbars=yes,');"" alt=""" & strTextViewPendingChange & """>" & strTextViewPendingChange & "</A></b>"
      strPendingChangeWarning = strPendingChangeWarning & strLinkViewPendingChange

      if bRateScheduleHasPendingChange then
        session("RATES_EDITMODE") = "FALSE"
			  call response.write("<BR>")
			  call response.write("<div class=""ErrorMessageCaption"" style=""padding:5px;margin-left:20px;margin-right:20px;""><div style=""width:20px;float:left;""><img align=absmiddle src=/mpte/us/images/warningSmall.gif></div><div style=""margin-left:25px;"">" & strPendingChangeWarning & "</div></div>") 
  		  call response.write("<BR>")
			end if

		%> 
		<% 'if not mbolRemove then call writeGlobalActions(mbolSubmitted) end if%>
		
		<BR>
		<% 
			if mbolFilterAvailable then
			  if mbolIsFilterOn then 
			    mstrFilterImg =  "<img src=""/mpte/us/images/filter_on.gif""  width=""10"" height=""10"" border=""0"" alt="">&nbsp;&nbsp;"
			  else
			    mstrFilterImg =  "<img src=""/mpte/us/images/filter_off.gif"" width=""10"" height=""10"" border=""0"" alt="">&nbsp;&nbsp;"
			  end if
			  call response.write (mstrFilterImg)
			  call response.write ("<BR><BR>")
			  call response.write ("<span class=""clsTableTextWhite"">" & mstrFilterString & "</span>")
			else
			  call response.write("&nbsp;")
			end if
		%>
		<BR>
		<% if len(mobjTRReader.HelpFile) > 0 then
			response.write "<DIV class=""clsInfoURL"" title=""More information regarding this parameter table is available through a help file that has been configured explicitly for this parameter table. Click to view this help file.""><A HREF=""javascript:OpenDialogWindow('" & mobjTRReader.HelpFile & "','height=600, width=800, resizable=yes,scrollbars=yes');""><IMG border=0 align=middle SRC=""/mpte/us/images/infoSmall.gif""> " & FrameWork.GetDictionary("TEXT_MPTE_MOREINFO") & "</A></DIV>"
		end if %>
		
		<% set mcolTableOutputStrings = mobjTRReader.GetNewCollection %>
		<% call writeTableHeaderRows(mbolRemove) %>
		<% ' Let's try to load the rules %>
		<% call writeRuleSetRows(mbolRemove) %>
		<% call response.write("<span>" & writeNumberOutput()  & "</span>") %> 
		<BR>
		<BR>
		 <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" WIDTH="100%" style="border-top: 1px solid #ccc" > 
		
		  <% call determinePaging(mbolRemove)%>
		  <% 
		    for each mstrTemp in mcolTableOutputStrings 
		  		call response.write(mstrTemp)
		  	next
		  %>
		</table>
		
		<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="2" WIDTH="100%" CLASS="clsTextMpteBackPane"> 
		  <tr>
				<td class="clsTextMpteBackPane">&nbsp;</td>
		  </tr>
		  
		  <tr>
		    <td class="clsTextMpteBackPane" align="left" NOWRAP valign="center">
		      <a href="Javascript:Refresh()"><img src="/mpte/us/images/refresh.gif" border="0" align="middle" alt=""></a>&nbsp;
		    </td>
		  </tr>
		  <tr>     
		    <td class="clsTextMpteBackPane" align="center" NOWRAP>
		    <% if not mbolRemove then%>
		    	<% if mbolFilterAvailable then 'Note that filtering will never be available if there are no conditions ("mobjTRReader.ConditionDatas.Count = 0") %>
		         <input type="button" class="clsButtonBlueSmall" name="Filter" value="<%=FrameWork.GetDictionary("TEXT_MPTE_FILTER_BTN")%>" onClick="javascript:OpenDialogWindow('gotoPopup.asp?loadpage=GenericTabRulesetFilter.asp', '');">
		      <% end if %>
		      <% if UCase(session("RATES_EDITMODE")) = "TRUE" then %> 
		        <% if mobjTRReader.ConditionDatas.Count > 0 then ' We are also on edit mode %>     
              <input type="button" class="clsButtonBlueSmall" name="butAddRule" value="<%=FrameWork.GetDictionary("TEXT_MPTE_ADD_BTN")%>"" onClick="javascript:OpenDialogWindow('gotoPopup.asp?loadpage=GenericEditRuleset.asp&new=T&ID=<%=mobjRuleSet.count%>', '');">
              <input type="button" class="clsButtonBlueMedium" name="GoToRemove" value="<%=FrameWork.GetDictionary("TEXT_MPTE_REMOVE_BTN")%>" onClick="javascript:SubmitForm('GoToRemove');">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="button" class="clsButtonBlueMedium" name="CopyFrom" value="<%=FrameWork.GetDictionary("TEXT_MPTE_IMPORT_BTN")%>" title="<%=Framework.Dictionary.Item("TEXT_MPTE_IMPORT_BTN").Description%>"   onClick="javascript:OpenDialogWindow('<%=FrameWork.GetDictionary("RATESCHEDULE_IMPORT_DIALOG")%>?NextPage=gotoRuleEditor.asp&MonoSelect=TRUE&IDColumnName=id_sched&PT_ID=<%=session("RATES_PARAMTABLE_ID")%>', 'height=600, width=800,resizable=yes,scrollbars=yes');">
              
              <script>
              function ExportExcelDownload()
              {
                    var html = '';
										html += '<IFRAME';
										html += ' NAME="buffer' + '1' + '"';
										html += ' STYLE="display: none;"';
										html += ' SRC="' + 'GenericTabRulesetExportImportExcelInclude.asp?ImportExportAction=Export' + '"></IFRAME>';
										document.body.insertAdjacentHTML('beforeEnd', html);
							}
							</script>

              
              <input type="button" class="clsButtonBlueMedium" name="EditAsXML" value="<%=FrameWork.GetDictionary("TEXT_MPTE_EDIT_AS_XML_BTN")%>" title="<%=Framework.Dictionary.Item("TEXT_MPTE_EDIT_AS_XML_BTN").Description%>"   onClick="javascript:OpenDialogWindow('gotoPopup.asp?loadpage=GenericTabRuleSetExport.asp', '');">
              <input type="button" class="clsButtonBlueXLarge" name="ExportToExcel" value="<%=FrameWork.GetDictionary("TEXT_EXPORT_TO_EXCEL")%>" title="<%=FrameWork.GetDictionary("TEXT_EXPORT_TO_EXCEL")%>"   onClick="javascript:SubmitForm('ExportExcel');">
              <input type="hidden" name="ImportExportAction" value="Export">
	            <input type="button" class="clsButtonBlueXLarge" name="ImportFromExcel" value="<%=FrameWork.GetDictionary("TEXT_IMPORT_FROM_EXCEL")%>" title="<%=FrameWork.GetDictionary("TEXT_IMPORT_FROM_EXCEL")%>"   onClick="javascript:OpenDialogWindow('gotoPopup.asp?loadpage=GenericTabRuleSetExportImportExcel.asp', '');">
	        <% end if%>
		      <% else %>
		         <input type="button" class="clsButtonBlueSmall" name="Close" value="<%=FrameWork.GetDictionary("TEXT_MPTE_CLOSE_BTN")%>" onClick="javascript:returnToCallerApp();">
		      <% end if%>
		    <% else ' Removing %>
		      <input type="button" class="clsButtonBlueSmall" name="Remove" value="<%=FrameWork.GetDictionary("TEXT_MPTE_COMMITREMOVE_BTN")%>" onClick="javascript:SubmitForm('Remove');">
		      <input type="button" class="clsButtonBlueSmall" name="Cancel" value="<%=FrameWork.GetDictionary("TEXT_MPTE_CANCEL_BTN")%>" onClick="javascript:SubmitForm('Cancel');">                
		    <% end if %>
		    </td>
			</tr>
		  <tr><td class="clsTextMpteBackPane">&nbsp;</td></tr>
		</table>
		<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="2" WIDTH="100%">
		  <tr>
		    <tr><td>&nbsp;</td></tr>
		    <td align="center" NOWRAP>
		    <% if UCase(session("RATES_EDITMODE")) = "TRUE" and not mbolRemove Then %>
		    
		      <% if session("UnsavedChanges") then %>
  		      <input type="button" class="clsButtonSmall" name="Save" value="<%=FrameWork.GetDictionary("TEXT_MPTE_SAVE_BTN")%>" onClick="javascript:SubmitForm('Save');">
		      <% else %>
		        <input disabled="true" type="button" class="clsButtonSmall" name="Save" value="<%=FrameWork.GetDictionary("TEXT_MPTE_SAVE_BTN")%>" onClick="javascript:SubmitForm('Save');">
		      <% end if %>     
		      <input type="button" class="clsButtonSmall" name="Close" value="<%=FrameWork.GetDictionary("TEXT_MPTE_CLOSE_BTN")%>" onClick="javascript:returnToCallerApp();">
		    <% end if%>             
		    </td>
		  </tr>
		</table>
		
		<% if UCase(FrameWork.GetDictionary("MPTE_OWNER_APP")) = "MCM" then 'We check what application called the MPTE - if it was MCM, we will close the tabs table %>
		</tr>
		</table>
		<%end if%>
		
		</FORM>
		
		<%
		  set mcolTableOutputStrings = nothing
		  set objMTRateSched = nothing
		  set mobjTRReader = nothing
		  set mobjRuleSet = nothing
		  call WriteDebug()
		%>
		
		</body>
		</html>
		
		<% 
		
		
END FUNCTION ' End Of Function Main

		'On Error Resume next
		
		if IsEmpty(session("UnsavedChanges")) then
		  session("UnsavedChanges") = false
    end if
    
  	'// We are calling the function that processes the page.
		Main
			
		if err then 
		  call response.clear()
		  call WriteUnknownError("")
	    call response.end()
		else
		  call response.flush()
		  call response.end()
		end if
					
		On Error Goto 0	
%> 