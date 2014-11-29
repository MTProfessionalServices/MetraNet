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
' // $Notes: New MPTE version
' // $Revision$
' //==========================================================================


'----------------------------------------------------------------------------
'
'DESCRIPTION:   Sets the filter in a ruleset
'
'ASSUMPTIONS:   The rate schedule ruleset and the parameter table metadata are in the session
'				In other words, GenericTabRuleset.asp loaded the objects correclty
'  
'CALLS (REQUIRES): MTTabRulesetReader library
'
'----------------------------------------------------------------------------

Response.Buffer = true
Session.CodePage = 65001
Response.CharSet = "utf-8"
'----------------------------------------------------------------------------
' INCLUDES
'----------------------------------------------------------------------------
%>
  <!-- #INCLUDE VIRTUAL = "/mpte/auth.asp" -->
  <!-- #INCLUDE VIRTUAL = "/mpte/shared/Helpers.asp" -->
  <!-- #INCLUDE VIRTUAL = "/mpte/shared/CheckConnected.asp" -->
<%

'----------------------------------------------------------------------------
' CONSTANTS
'----------------------------------------------------------------------------
' none

'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
dim mobjTRReader  ' as RulesetHandler
dim mobjRuleSet   ' as MTRuleSet
dim mdctValues
dim mstrErrors

'----------------------------------------------------------------------------
' METHODS
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
'   Name: Draw_Header
'   Description:  Draws a Header in the default style
'               
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
sub Draw_Header(strHdr)
	Dim strTitle
	strTitle = strTitle &		"<table><tr>"
    strTitle = strTitle & 		"	<td Class='CaptionBar' nowrap>"
    strTitle = strTitle & 				strHdr
	strTitle = strTitle & 		"	</td>"
	strTitle = strTitle &		"</table></tr>"
	Response.Write (strTitle)					
end sub

'----------------------------------------------------------------------------
'   Name: ClearValues
'   Description:  Clears all the submitted data.  It does not clear the session
'                 of the stored filters, just the incoming values
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
sub ClearValues()

  dim objFilterCondition
  dim objConditionData
  dim strValue
  
  dim i
  
  i = 0
  set mdctValues = Server.CreateObject("Scripting.Dictionary")
  
  for each objConditionData in mobjTRReader.ConditionDatas
    'AddDebugMessage "Condition: <B>" & objConditionData.DisplayName & "</B>"
    
    if objConditionData.Filterable and not ucase(objConditionData.ColumnType) = "LABEL" then
      'AddDebugMessage "condition is filterable"
      
      call mdctValues.add(objConditionData.PropertyName & i, "") 
      if objConditionData.EditOperator then
        'call mdctValues.add(objConditionData.PropertyName & i & "Operator", SymbolToTest(objConditionData.Operator))
				call mdctValues.add(objConditionData.PropertyName & i & "Operator", OperatorTypeToTest(objConditionData.Operator))
      end if
              
    end if ' end test to see if it is filterable
    
    i = i + 1
    
  next ' loop on condition datas
        
end sub

'----------------------------------------------------------------------------
'   Name: ReadValues
'   Description:  Reads the values from the request and populates a dictionary.
'                 If the form has not been submitted yet, it reads the values
'                 from the object.
'                 This does the type checking and creates an error message for
'                 the necessary corrections
'   Parameters: ibolSubmitting - flag to indicate that the form is being submitted
'   Return Value: none
'-----------------------------------------------------------------------------
sub ReadValues(ibolSubmitting)

  dim objFilterCondition
  dim objConditionData
  dim strValue
  
  dim i
  
  i = 0
  set mdctValues = Server.CreateObject("Scripting.Dictionary")
  
  
  for each objConditionData in mobjTRReader.ConditionDatas
    'AddDebugMessage "Condition: <B>" & objConditionData.DisplayName & "</B>"
    
    if objConditionData.Filterable and not ucase(objConditionData.ColumnType) = "LABEL" then
      'AddDebugMessage "condition is filterable"
      
      ' if we are submitting the data, then read it from the form
      if ibolSubmitting then
      
         ' test to see if the user entered a value for the condition
        strValue = request.Form(objConditionData.PropertyName & i)
        if len(strValue) > 0  then
        
         	'AddDebugMessage "found item.  value: " & strValue
            
          call mdctValues.add(objConditionData.PropertyName & i, strValue)
          mstrErrors = mstrErrors & TypeCheckCondition(objConditionData, strValue)
			
          if objConditionData.EditOperator then
            call mdctValues.Add(objConditionData.PropertyName & i & "Operator", request.Form(objConditionData.PropertyName & i & "Operator"))
          else
            'call mdctValues.add(objConditionData.PropertyName & i & "Operator", SymbolToTest(objConditionData.Operator))
			  		call mdctValues.add(objConditionData.PropertyName & i & "Operator", OperatorTypeToTest(objConditionData.Operator))
          end if
        
        end if ' end test on whether the filter condition was submitted
      
      else ' the form was not submitted and we should get the value from the current filters
      
        for each objFilterCondition in mobjTRReader.FilterConditions
          'AddDebugMessage "trying to match on: " & objFilterCondition.DisplayName
          
          if ucase(objFilterCondition.Condition.PropertyName) = ucase(objConditionData.PropertyName) then
            ' if the condition matches, save the value                      
            call mdctValues.add(objConditionData.PropertyName & i, objFilterCondition.Condition.Value)
            call mdctValues.Add(objConditionData.PropertyName & i & "Operator", objFilterCondition.Condition.Test)
            exit for
          end if
        next
        
      end if ' end test on whether the form was submitted - the source of the data
               
    end if ' end test to see if it is filterable
    
    i = i + 1
    
  next ' loop on condition datas
        
end sub


'----------------------------------------------------------------------------
'   Name: Save
'   Description:  Saves the changes made to the filters
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
sub Save()
  dim objRSCondition
  dim objConditionData
  dim objFilterCondition
  dim arrstrValues
  dim arrstrText
  dim strTemp
  
  dim i
  dim j
  
  i = 0

  'AddDebugMessage "Clear the filters"
  
  call mobjTRReader.FilterConditions.clear()
  
  ' loop through all the conditions and save them to the filters
  ' If a submitted condition has no value, then do not write the filter condition out
  ' AddDebugMessage "loop through all the conditions"
  
  for each objConditionData in mobjTRReader.ConditionDatas
    'AddDebugMessage "Condition: <B>" & objConditionData.DisplayName & "</B>"
    
    if objConditionData.Filterable and not ucase(objConditionData.ColumnType) = "LABEL" then
      'AddDebugMessage "condition is filterable"
	  
       ' test to see if the user entered a value for the condition
      if mdctValues.Exists(objConditionData.PropertyName & i) then
      
        'AddDebugMessage "user submitted a value for this condition: " & mdctValues(objConditionData.PropertyName & i)
	  
        set objRSCondition = Server.CreateObject("MTSimpleCondition.MTSimpleCondition.1")
        set objFilterCondition = Server.CreateObject("MTTabRulesetReader.FilterCondition")
        
        ' get the property names
        objRSCondition.PropertyName = objConditionData.PropertyName
        objFilterCondition.DisplayName = objConditionData.DisplayName
        
        
        ' set the SimpleCondition ValueType
        if CLng(objConditionData.PType) = PROP_TYPE_ENUM then
          objRSCondition.EnumSpace = objConditionData.EnumSpace
          objRSCondition.EnumType = objConditionData.EnumType
          objRSCondition.ValueType = objConditionData.PType
        end if
             
        objRSCondition.ValueType = objConditionData.PType
        
        'AddDebugMessage "set the valuetype: " & objRSCondition.ValueType
        
        
        ' get the property values
        ' to get the display value for an enumerated type, we need to find the 
        ' correct item from the lits of name value arrays
        call SetRSConditionValue(objRSCondition, mdctValues(objConditionData.PropertyName & i))
        
        if CLng(objConditionData.PTYPE) = PROP_TYPE_ENUM then
          set arrstrValues = objConditionData.EnumValues
          set arrstrText = objConditionData.EnumStrings
          
          j = 1
          for each strTemp in arrstrValues
          ' response.write "testing value: " & strTemp & " vs. value: " & objRSCondition.Value & "<BR>"
            if strTemp = objRSCondition.Value then
              objFilterCondition.DisplayValue = arrstrText(j)
              exit for
            end if
            j = j + 1
          next
        else
          objFilterCondition.DisplayValue = objRSCondition.Value
        end if
        
      
        ' get the test operator
        if objConditionData.EditOperator then
          'AddDebugMessage "user can edit operator.  Operator submitted: " & mdctValues(objConditionData.PropertyName & i & "Operator")
          
          objRSCondition.Test = mdctValues(objConditionData.PropertyName & i & "Operator")
          objFilterCondition.DisplayTest = TestToSymbolHTML(mdctValues(objConditionData.PropertyName & i & "Operator"))
        else
          'AddDebugMessage "user cannot edit operator - take stored operator"
          
          'objRSCondition.Test = SymbolToTest(objConditionData.Operator)
          objRSCondition.Test = OperatorTypeToTest(objConditionData.Operator)
		  		'Think about this: Related to FILTER BUG
		  		objFilterCondition.DisplayTest = OperatorTranslate(objConditionData.Operator)
        end if
        
        'AddDebugMessage "set the test: " & objRSCondition.Test
        'AddDebugMessage "set the display test: " & objFilterCondition.DisplayTest
        
        ' set the objects needed
        set objFilterCondition.Condition = objRSCondition
        mobjTRReader.FilterConditions.add(objFilterCondition)
       
      end if ' end test to see if the condition was submitted    
        
    end if ' end test to see if it is filterable
    i = i + 1
  next
    
end sub

'----------------------------------------------------------------------------
'   Name: WriteFilterRows
'   Description:  writes out the filter rows.  Assumes that a <TABLE> tag has
'                 already been started.
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
sub WriteFilterRows()

  dim objConditionData
  dim strValue
  dim strTest
  dim arrstrValues
  dim arrstrText
  dim bolNew
  
  dim i
 
  i = 0
  
  ' write the filterable conditions       
   'AddDebugMessage "Starting to loop on ConditionDatas"       
   
  for each objConditionData in mobjTRReader.ConditionDatas
    'AddDebugMessage "ConditionData: <B>" & objConditionData.DisplayName & "</B>"
    
    if objConditionData.Filterable and not ucase(objConditionData.ColumnType) = "LABEL" then
      'AddDebugMessage "Condition is filterable"
    
      call response.write("  <TR>" & vbNewLine)
      call response.write("    <TD NOWRAP ALIGN=""right"">")
    
      call response.write(objConditionData.DisplayName)
    
      if not objConditionData.EditOperator and not ucase(objConditionData.DisplayOperator) = "NONE" then
        'call response.write("&nbsp;(" & OperatorEncode(objConditionData.Operator) & ")")
		call response.write("&nbsp;(" & OperatorTranslate(objConditionData.Operator) & ")")
      end if
      call response.write(":</TD>"& vbNewLine)
    
      ' start the edit area
      call response.write("    <TD NOWRAP ALIGN=""left"">")
      
      
      strValue = mdctValues(objConditionData.PropertyName & i)
      strTest = mdctValues(objConditionData.PropertyName & i & "Operator")   
            
      ' if they can edit the operator, then write out a select
      if objConditionData.EditOperator then
        if CLng(objConditionData.PType) = PROP_TYPE_ENUM or CLng(objConditionData.PType) = PROP_TYPE_STRING or CLng(objConditionData.PType) = PROP_TYPE_BOOLEAN then
          call BuildComboBox(objConditionData.PropertyName & i & "Operator", "" & _
                  "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objConditionData.PropertyName & i & "Operator');""", _
                  mobjTRReader.TestOperatorPartialValues, mobjTRReader.TestOperatorPartialText, strTest, false)
        else
          call BuildComboBox(objConditionData.PropertyName & i & "Operator", "" & _
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
        call BuildComboBox(objConditionData.PropertyName & i, "" & _
                  "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objConditionData.PropertyName & i & "');""", _
                  arrstrValues, arrstrText, strValue, true)          
        
      elseif CLng(objConditionData.PType) = PROP_TYPE_BOOLEAN then
          call BuildBooleanComboBox(objConditionData.PropertyName & i, "" & _
                    "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objConditionData.PropertyName & i & "');""", _
                    strValue, true)
      else
        call response.write("<INPUT TYPE=""TEXT"" " & _
                  "onBlur=""javascript:LostFocus();"" onFocus=""javascript:GotFocus('" & objConditionData.PropertyName & i &"');""" & _
                  "NAME=""" & objConditionData.PropertyName & i & """ VALUE=""" & strValue & """>")
      end if
      
      call response.write("</TD>" & vbNewLine)                
      call response.write("  </TR>" & vbNewLine)

    end if ' end test of the column type                                          
    
    i = i + 1
  next ' loop on ConditionData
      
end sub



'----------------------------------------------------------------------------
' PAGE PROCESSING STARTS
'----------------------------------------------------------------------------
set mobjTRReader = session("TRReader")
set mobjRuleSet = session("RuleSet")

call ClearDebugMessages("GenericTabRulesetFilter.asp")

'----------------------------------------------------------------------------
' CLEAR - CLEAR THE VALUES FROM THE BOXES
'---------------------------------------------------------------------------- 
if request.Form("FormAction") = "Clear" then
  call ClearValues()    
    
'----------------------------------------------------------------------------
' OK - SAVE THE CHANGES TO THE RULESET, SAVE THE RULESET TO SESSION,
' AND FORCE THE CALLING SCREEN TO REFRESH.  SET A SESSION FLAG TO INDICATE THAT
' THE CALLING PAGE SHOULD REALLY JUST RELOAD FROM THE RULESET - OTHERWISE, IT
' MAY DO THE WRONG THING.
'---------------------------------------------------------------------------- 
elseif request.Form("FormAction") = "OK" then
  call ReadValues(true)
  
  if len(mstrErrors) = 0 then
    call Save()
    
    session("AfterEdit") = true
    set session("TRReader") = mobjTRReader
    
	call response.write("<script LANGUAGE=""JavaScript1.2"">window.opener.location=""gotoRuleEditor.asp?AfterFilter=TRUE""</script>")
    call response.end
  end if
  
else  
  call ReadValues(false)
end if
  


'----------------------------------------------------------------------------
' HTML WRITING STARTS
'----------------------------------------------------------------------------
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
  <head>
	  <title><%=FrameWork.GetDictionary("TEXT_TABULAR_RULESET_EDITOR")%></title>
	  <link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET1")%>">
  	<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET2")%>">
  	<link rel="STYLESHEET" type="text/css" href="<%=FrameWork.GetDictionary("MPTE_STYLESHEET3")%>">
 	  <% Response.Write (session("stylesheet1"))%>   
    <% Response.Write (session("stylesheet2"))%>
    <% Response.Write (session("stylesheet3"))%>   
	
    <script language="JavaScript1.2" src="/mpte/shared/browsercheck.js"></script>    
    <script language="JavaScript1.2" src="/mpte/shared/PopupModalDialog.js"></script>
    <script LANGUAGE="JavaScript1.2">      
      function SubmitForm(istrAction)
      {
        document.main.FormAction.value = istrAction;
        document.main.submit();
      }
    </SCRIPT>
  
  
  
  </head>

  <body onBlur="javascript:LostFocus();" onFocus="javascript:GotFocus('window');" onLoad="javascript:SizeWindow();"> 
  
  <FORM ACTION="gotoPopup.asp?loadpage=GenericTabRulesetFilter.asp" METHOD="POST" NAME="main" onFocus="javascript:InAForm(main);" onBlur="javascript:OutOfForm();">
  <INPUT TYPE="Hidden" NAME="FormAction" VALUE="OK">
  
  <% call WriteError(mstrErrors)%>
  
  <% call Draw_Header(FrameWork.GetDictionary("TEXT_MPTE_FILTERDEFINE")) %>
  
  <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="3">
  <% call WriteFilterRows() %>
  </TABLE>
  
  <BR><BR>
  <table width="100%">
  <tr>		 
    <td align="center" NOWRAP>
  	  <input type="button" class="clsButtonSmall" name="Clear" alt="Clear" value="Clear" onClick="javascript:SubmitForm('Clear');">
   	  <input type="button" class="clsButtonSmall" name="OK" alt="OK" value="OK" onClick="javascript:SubmitForm('OK');">
	  <input type="button" class="clsButtonSmall" name="Cancel" alt="Cancel" value="Cancel" onClick="javascript:window.close();">
    </td>
  </tr>
  </table>
  </FORM>
  
  <% call WriteDebug() %>

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