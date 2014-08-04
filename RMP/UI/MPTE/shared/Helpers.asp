<%

' //==========================================================================
' // @doc $Workfile: Helpers.asp$
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
' // $Date: 11/9/2002 10:21:03 AM$
' // $Author: Kevin Boucher$
' // $Revision: 27$
' //==========================================================================


'----------------------------------------------------------------------------
'
'DESCRIPTION:   This file is used to assist in general stuff editing.
'               It contains useful functions and constants that can be called
'               by the other pages when processing and redering
'
'ASSUMPTIONS: none
'
'CALLS (REQUIRES): none
'
'----------------------------------------------------------------------------

PUBLIC CONST PROP_TYPE_UNKNOWN = 0
PUBLIC CONST PROP_TYPE_DEFAULT = 1
PUBLIC CONST PROP_TYPE_INTEGER = 2
PUBLIC CONST PROP_TYPE_DOUBLE = 3
PUBLIC CONST PROP_TYPE_STRING = 4
PUBLIC CONST PROP_TYPE_DATETIME = 5
PUBLIC CONST PROP_TYPE_TIME = 6
PUBLIC CONST PROP_TYPE_BOOLEAN = 7
PUBLIC CONST PROP_TYPE_SET = 8
PUBLIC CONST PROP_TYPE_OPAQUE = 9
PUBLIC CONST PROP_TYPE_ENUM = 10
PUBLIC CONST PROP_TYPE_DECIMAL = 11

' Constants for type checking
' Ideally, we should get these from the backend
' "Precision" is number of significant digits;
' "Scale" is number of digits to right of decimal point.
CONST MAX_DECIMAL_SCALE				=	10
CONST MAX_DECIMAL_PRECISION						= 22
CONST MAX_INTEGER									= 2147483647
CONST MAX_STRING_SIZE							= 255
CONST MAX_DATE_SIZE				  			= 22
CONST MAX_BOOLEAN_SIZE						= 6


CONST DEBUG_ON = false

'Idealy we should get these from VB or some place that has localized settings according to the user's computer
dim DECIMALSEPARATOR
dim THOUSANDSEPARATOR

FUNCTION GetDecimalSeparator()

  if IsEmpty(DECIMALSEPARATOR) then
    DECIMALSEPARATOR = FrameWork.GetDictionary("DECIMAL_SEPARATOR")
  end if
  
  GetDecimalSeparator = DECIMALSEPARATOR
  
END FUNCTION

FUNCTION GetThousandSeparator()

  if IsEmpty(THOUSANDSEPARATOR) then
    THOUSANDSEPARATOR = FrameWork.GetDictionary("THOUSAND_SEPARATOR")
  end if
  
  GetThousandSeparator = THOUSANDSEPARATOR
  
END FUNCTION

CONST DEFAULTDECIMALSCALEFORDISPLAY = 2	' By default, decimal types are displayed with two decimal places

' Default Type Values - Used in SetRSAction and SetRSCondition
' Since the default action is now optional, we will need, sometimes,
' to instantiate the values of it's actions to something. If there is
' no default value configured on the metadata, we are forced to use these:

'----------------------------------------------------------------------------
' VARIABLES
'----------------------------------------------------------------------------
dim garrstrDebugMessages

'----------------------------------------------------------------------------
' METHODS
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
'   Name: Tab_Initialize
'   Description: Figures out under which tab we are in (if any) and draws them
'   Parameters: none
'   Return Value: none
'   TODO: Detect whether we need tabs or not
'-----------------------------------------------------------------------------

FUNCTION Tab_Initialize()
	' Dynamically Add Tabs to template
	Dim strTabs
	gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_RATES_PRODUCT_OFFERING_LIST"), FrameWork.GetDictionary("RATES_PRODUCT_OFFERING_LIST_DIALOG")
	gObjMTTabs.AddTab FrameWork.GetDictionary("TEXT_RATES_PRICELIST_LIST"), FrameWork.GetDictionary("RATES_PRICE_LIST_LIST_DIALOG")
	
	If UCase(session("RATES_POBASED")) = "TRUE" Then
		gObjMTTabs.Tab = 0
	Else
		gObjMTTabs.Tab = 1
	end If
	
	strTabs = gObjMTTabs.DrawTabMenu(g_int_TAB_TOP)    
	strTabs = strTabs & "<table class=""clsTabAngleTopSelected"" cellspacing=""0"" cellpadding=""5"" width=""100%"" height=""90%""><tr valign=""top""><td>"
	strTabs = "<BR>" & strTabs
	Response.Write(strTabs)
	' Note that the table close is the last thing that happens in this page.
	Tab_Initialize = TRUE
END FUNCTION

'----------------------------------------------------------------------------
'   Name: ConvertValueToEnumerator
'   Description:  Given an enumspace, enumtype, and enumerator value, return
'                 the name of the associated enumerator.
'   Parameters: strEnumspace  -- Enumspace
'               strEnumtype   -- Enumtype
'               strValue      -- Value of the enumerator
'   Return Value: The name of the enumerator
'-----------------------------------------------------------------------------
Function ConvertValueToEnumerator(strEnumspace, strEnumtype, strValue)
  Dim objEnumConfig   'EnumConfig object
  Dim strEnumerator

  'Check for an error, since it will be cleared
  if err then 
    exit function
  end if

  'Create the object
  Set objEnumConfig = Server.CreateObject("Metratech.MTEnumConfig")

  'strEnumerator = objEnumConfig.GetEnumWithValue(strEnumspace, strEnumtype, strValue)
	if IsNumeric(strValue) then
		' Seems like the value being passed in to this function is the enumid.
		' Therefore we will try to retrieve the enum by ID, and not by value...
		strEnumerator = objEnumConfig.GetEnumeratorByID(Clng(strValue))
	else
		strEnumerator = ""
	end if
  
  'If no value was found then display a message, clear any errors that may have occurred
  if len(strEnumerator) = 0 or err then
    ' We can have null enum in the case that the property is not required.  (so just set the value to empty string)
		ConvertValueToEnumerator = ""
		Call err.Clear
    exit function
  end if

  'Found the enumerator, no errors, so return the value
  ConvertValueToEnumerator = strEnumerator  

End Function


'----------------------------------------------------------------------------
'   Name: AddDebugMessage
'   Description:  Adds a message to the debugging list
'   Parameters: istrMessage - The message to add
'   Return Value: none
'-----------------------------------------------------------------------------
sub AddDebugMessage(istrMessage)
  if DEBUG_ON then
    redim preserve garrstrDebugMessages(ubound(garrstrDebugMessages)+1)
    garrstrDebugMessages(ubound(garrstrDebugMessages)) = istrMessage
  end if
end sub

'----------------------------------------------------------------------------
'   Name: AlignString
'   Description:  Returns an HTML ALIGN format depending on the ptype passed in
'   Parameters: iintPType - the ptype to check for
'   Return Value: String - "RIGHT" or "LEFT", depending on the type
'-----------------------------------------------------------------------------
function AlignString(iintPType)
  select case CLng(iintPType)
    case PROP_TYPE_INTEGER, PROP_TYPE_DOUBLE, PROP_TYPE_DECIMAL
      'AddDebugMessage "aligning right for ptype: " & iintPType
      AlignString = "RIGHT"
    case else
      'AddDebugMessage "aligning left for ptype: " & iintPType
      AlignString = "LEFT"
  end select
end function

'----------------------------------------------------------------------------
'   Name: BuildComboBox
'   Description:  Builds a Combo box given a name for the box, any additional
'                 attributes for the box, a collection of values, a collection of text,
'                 and a selected item (by value)
'   Parameters: istrName - name to use for the select
'               istrAttributes - any additional attributes to add to the select
'               icolstrValues - a collection of string values
'               icolstrText - a collection of display names
'               istrSelected - the value of the selected item
'               ibolCreateBlank - flag to indicate that a blank should be created
'   Return Value: none
'-----------------------------------------------------------------------------
sub BuildComboBox(istrName, istrAttributes, icolstrValues, icolstrText, istrSelected, ibolCreateBlank)
  dim strValue
  dim i
  
  if not isObject(icolstrText) or not isObject(icolstrValues) then
    exit sub
  end if
  
  if icolstrValues.count <> icolstrText.count then
    exit sub
  end if
  
  i = 1
  
  call response.write("<SELECT NAME=""" & istrName & """ " & istrAttributes & " >" & vbNewLine)
  if ibolCreateBlank then
    call response.write("  <OPTION")
    if len(strValue) = 0 then
      call response.write(" SELECTED")
    end if
    call response.write(" VALUE=""""></OPTION>" & vbNewLine)
  end if
  
  for each strValue in icolstrValues
    call response.write("  <OPTION")
    if UCase(strValue) = UCase(istrSelected) then
      call response.write(" SELECTED")
    end if
    call response.write(" VALUE=""" & Server.HTMLEncode(strValue) & """>")
    call response.write(icolstrText(i) & "</OPTION>" & vbNewLine)
    i = i + 1
  next
  
  call response.write("</SELECT>" & vbNewLine)

end sub


'----------------------------------------------------------------------------
'   Name: BuildBooleanComboBox
'   Description:  Builds a Combo box for boolean values given a name for the box, 
'                 any additional attributes for the box, 
'                 and a selected item (by value)
'   Parameters: istrName - name to use for the select
'               istrAttributes - any additional attributes to add to the select
'               istrSelected - the value of the selected item
'               ibolCreateBlank - flag to indicate that a blank should be created
'   Return Value: none
'-----------------------------------------------------------------------------
sub BuildBooleanComboBox(istrName, istrAttributes, istrSelected, ibolCreateBlank)

  call response.write("<SELECT NAME=""" & istrName & """ " & istrAttributes & " >" & vbNewLine)
  if ibolCreateBlank then
    call response.write("  <OPTION")
    if len(istrSelected) = 0 then
      call response.write(" SELECTED")
    end if
    call response.write(" VALUE=""""></OPTION>" & vbNewLine)
  end if
  
  call response.write("  <OPTION")
  if ucase(istrSelected) = "TRUE" or ucase(istrSelected) = "T" or ucase(istrSelected) = "YES" or ucase(istrSelected) = "Y" then
    call response.write(" SELECTED")
  end if
  call response.write(" value=""TRUE"">True</OPTION>" & vbNewLine)
  
  call response.write("  <OPTION")
  if ucase(istrSelected) = "FALSE" or ucase(istrSelected) = "F" or ucase(istrSelected) = "NO" or ucase(istrSelected) = "N" then
    call response.write(" SELECTED")
  end if
  call response.write(" value=""FALSE"">False</OPTION>" & vbNewLine) 
  call response.write("</SELECT>" & vbNewLine)
end sub


'----------------------------------------------------------------------------
'   Name: buildDateString
'   Description:  Parses the query string params to create a date string from
'                 the data entered.
'   Parameters: none
'   Return Value: The date string constructed from the inputs
'-----------------------------------------------------------------------------
function buildDateString
  buildDateString = request.queryString("cmbMon") & "/" & _
                    request.queryString("cmbDay") & "/" & _
                    request.queryString("cmbYear") & " " 
  
  if request.queryString("cmbAMPM") = "AM" then
    if CLng(request.queryString("cmbHour")) = 12 then
      buildDateString = buildDateString & "00:" 
    else  
      buildDateString = buildDateString & request.queryString("cmbHour") & ":" 
    end if
  else
    if CLng(request.queryString("cmbHour")) = 12 then
      buildDateString = buildDateString & "12:" 
    else  
      buildDateString = buildDateString & cstr(CLng(request.queryString("cmbHour")) + 12) & ":" 
    end if
  end if
  
  buildDateString = buildDateString & _
                    request.queryString("cmbMinute") & ":" & _
                    request.queryString("cmbSeconds")
                    
   
  ' AddDebugMessage "Date created: " & buildDateString & "<BR>"                 

end function

'----------------------------------------------------------------------------
'   Name: buildDateStringFromPost
'   Description:  Parses the query string params to create a date string from
'                 the data entered.
'   Parameters: none
'   Return Value: The date string constructed from the inputs
'-----------------------------------------------------------------------------
function buildDateStringFromPost
  buildDateStringFromPost = request.Form("cmbMon") & "/" & _
                    request.Form("cmbDay") & "/" & _
                    request.Form("cmbYear") & " " 
  
  if request.Form("cmbAMPM") = "AM" then
    if CLng(request.Form("cmbHour")) = 12 then
      buildDateStringFromPost = buildDateStringFromPost & "00:" 
    else  
      buildDateStringFromPost = buildDateStringFromPost & request.Form("cmbHour") & ":" 
    end if
  else
    if CLng(request.Form("cmbHour")) = 12 then
      buildDateStringFromPost = buildDateStringFromPost & "12:" 
    else  
      buildDateStringFromPost = buildDateStringFromPost & cstr(CLng(request.Form("cmbHour")) + 12) & ":" 
    end if
  end if
  
  buildDateStringFromPost = buildDateStringFromPost & _
                    request.Form("cmbMinute") & ":" & _
                    request.Form("cmbSeconds")
                    
   
  'AddDebugMessage "Date created: " & buildDateStringFromPost & "<BR>"                 

end function

'----------------------------------------------------------------------------
'   Name: ClearDebugMessages
'   Description:  Prepares the debugging information by clearing the array
'   Parameters: istrPageName - The name of the ASP Page debugging
'   Return Value: none
'-----------------------------------------------------------------------------
sub ClearDebugMessages(istrPageName)
  if DEBUG_ON then
    redim garrstrDebugMessages(0)
    garrstrDebugMessages(0) = "Debugging On for page: " & istrPageName
  end if
end sub

'----------------------------------------------------------------------------
'   Name: ConditionsAreEqual
'   Description:  Tests to see if 2 MTSimpleConditions are equal.  Tests the 
'                 PropertyNames, PType, Test and value.  Tests the value after
'                 doing the appropriate conversion for the given PType
'   Parameters: iobjCondition1 - the first condition to test
'               iobjCondition2 - the second condition to test
'   Return Value: True if the conditions match.  False otherwise
'-----------------------------------------------------------------------------
function ConditionsAreEqual(iobjCondition1, iobjCondition2)
  
  if not iobjCondition1.PropertyName = iobjCondition2.PropertyName then
    ConditionsAreEqual = false
    exit function
  end if
  
  if not CLng(iobjCondition1.ValueType) = CLng(iobjCondition2.ValueType) then
    ConditionsAreEqual = false
    exit function
  end if
  
  if not TestToOperatorType(iobjCondition1.Test) = TestToOperatorType(iobjCondition2.Test) then 
    ConditionsAreEqual = false
    exit function
  end if
  
  select case CLng(iobjCondition1.ValueType)
    case PROP_TYPE_INTEGER
      if not clng(iobjCondition1.Value) = clng(iobjCondition2.Value) then 
        ConditionsAreEqual = false
        exit function
      end if 
    case PROP_TYPE_DOUBLE
      if not cdbl(iobjCondition1.Value) = cdbl(iobjCondition2.Value) then 
        ConditionsAreEqual = false
        exit function
      end if 
    case PROP_TYPE_DECIMAL
      if VarType(iobjCondition1.Value) = 14 AND VarType(iobjCondition2.Value) = 14 then 
          if not cdbl(iobjCondition1.Value) = cdbl(iobjCondition2.Value) then  
             ConditionsAreEqual = false 
          exit function 
          end if  
              else 
                  if not CDec(iobjCondition1.Value) = CDec(iobjCondition2.Value) then  
          ConditionsAreEqual = false 
          exit function 
          end if  
      end if  
    case PROP_TYPE_STRING
      if not iobjCondition1.Value = iobjCondition2.Value then 
        ConditionsAreEqual = false
        exit function
      end if
		case PROP_TYPE_ENUM
			set objEnumConfig = Server.CreateObject("Metratech.MTEnumConfig")
			if not objEnumConfig.GetID(iobjCondition1.EnumSpace, iobjCondition1.EnumType, iobjCondition1.Value) = objEnumConfig.GetID(iobjCondition2.EnumSpace, iobjCondition2.EnumType, iobjCondition2.Value) then
				ConditionsAreEqual = false
				exit function
			end if	 
    case PROP_TYPE_DATETIME
      if not cdate(iobjCondition1.Value) = cdate(iobjCondition2.Value) then 
        ConditionsAreEqual = false
        exit function
      end if 
 '   case PROP_TYPE_TIME
 '     if not ctime(iobjCondition1.Value) = ctime(iobjCondition2.Value) then 
  '      ConditionsAreEqual = false
  '      exit function
  '    end if 
    case PROP_TYPE_BOOLEAN
      if not cbool(iobjCondition1.Value) = cbool(iobjCondition2.Value) then 
        ConditionsAreEqual = false
        exit function
      end if 
      
    case else
      ConditionsAreEqual = false
      exit function
  end select
  
  ConditionsAreEqual = true

end function

'----------------------------------------------------------------------------
'   Name: LoadDOMFile
'   Description:  This function takes in an xml file to load and attempts
'                   to load it using the XMLDOM.  Checks to see if the file exists.
'                   an can be parsed.  If not, returns an error
'   Parameters: icstrXMLFile - the name of the xml file to read
'               ostrErrMessage - string the will capture any errors
'   Return Value: the loaded DOM object
'-----------------------------------------------------------------------------
Function LoadDOMFile(istrXMLFile, ostrErrMessage) 'As DOMDocument
On Error Resume Next

    Dim objFSO          'As New FileSystemObject
    Dim objXMLDOM       'As New DOMDocument
    
    set LoadDOMFile = Nothing
    
    set objFSO = CreateObject("Scripting.FileSystemObject")
    set objXMLDOM = CreateObject("MSXML.DOMDocument")
    
    objXMLDOM.async = false
    '---------------------------------------------------------
    ' Now try to find the xml file.
    ' If we can't find or parse the file, raise an error
    '---------------------------------------------------------
    If Not objFSO.FileExists(istrXMLFile) Then
      ostrErrMessage = FrameWork.GetDictionary("TEXT_MPTE_ERROR_FILE_NOT_LOCATED") & "nbsp;" & istrXMLFile
      Exit Function
    End If
        
    If Not objXMLDOM.Load(istrXMLFile) Then
        ostrErrMessage = FrameWork.GetDictionary("TEXT_MPTE_ERROR_FILE_NOT_READABLE") & "nbsp;" & istrXMLFile & vbNewLine & objXMLDOM.parseError
        Exit Function
    End If
        
    If objXMLDOM.parseError.ErrorCode <> 0 Then
        ostrErrMessage =  FrameWork.GetDictionary("TEXT_MPTE_ERROR_FILE_NOT_READABLE") & "nbsp;" & istrXMLFile & vbNewLine & objXMLDOM.parseError
        Exit Function
    End If
    
    Set LoadDOMFile = objXMLDOM

End Function


'----------------------------------------------------------------------------
'   Name: OperatorEncode
'   Description:  Converts the the < and > to HTML valid stuff
'   Parameters: istrOperator - the operator to convert
'   Return Value: the new value
'-----------------------------------------------------------------------------
function OperatorEncode(istrOperator) ' as string
  select case istrOperator
    case "<"
      OperatorEncode = "&lt;"
    case "<="
      OperatorEncode = "&lt;="
    case ">"
      OperatorEncode = "&gt;"
    case ">="
      OperatorEncode = "&gt;="
		case "<>"
	  	OperatorEncode = "&lt;&gt;"
		case "="
	 		OperatorEncode = "="
    case else
      OperatorEncode = istrOperator
  end select
  
end function

'----------------------------------------------------------------------------
'   Name: OperatorTranslate
'   Description:  Converts the the enumerated operator type into HTML
'   Parameters: istrOperator - the operator number, maybe a constant
'   Return Value: the corresponding html string
'-----------------------------------------------------------------------------
function OperatorTranslate(istrOperator) ' as string
 select case Clng(istrOperator)
   case OPERATOR_TYPE_LESS
     OperatorTranslate = "&lt;"
   case OPERATOR_TYPE_LESS_EQUAL
     OperatorTranslate = "&lt;="
   case OPERATOR_TYPE_GREATER
     OperatorTranslate = "&gt;"
   case OPERATOR_TYPE_GREATER_EQUAL
     OperatorTranslate = "&gt;="
	 case OPERATOR_TYPE_NOT_EQUAL
  	 OperatorTranslate = "&lt;&gt;"
	 case OPERATOR_TYPE_EQUAL
  	 OperatorTranslate = "="
	 case OPERATOR_TYPE_NONE
  	 OperatorTranslate = ""
	 case OPERATOR_TYPE_LIKE
  	 OperatorTranslate = "&nbsp;is like&nbsp;"
	 case OPERATOR_TYPE_LIKE_W
  	 OperatorTranslate = "&nbsp;LIKE W (What this means?)&nbsp;"	  
   case else
     OperatorTranslate = istrOperator
 end select
end function

'----------------------------------------------------------------------------
'   Name: RequiredConditionMessage
'   Description:  Returns a string declaring that a condition is required
'   Parameters: iobjConditionData - the conditiondata to use to get some information
'   Return Value: String - the message to display
'-----------------------------------------------------------------------------
function RequiredConditionMessage(iobjConditionData)
  RequiredConditionMessage = "&middot; " & iobjConditionData.DisplayName  & " is required.<BR>"
end function

'----------------------------------------------------------------------------
'   Name: SetRSDefaultActionValue
'   Description:  Sets the value of a MTAssignmentAction - It needs to cast the
'                 value based on the PType of the action passed in.
'   Parameters: iobjAction - the condition to set the value to
'               istrDefaultValue - the default value present in the metadata
'								   if it is none, then we use the default type values
'   Return Value: none
'-----------------------------------------------------------------------------

sub SetRSDefaultActionValue(iobjAction, istrDefaultValue)
 select case CLng(iobjAction.PropertyType)
    case PROP_TYPE_INTEGER
	  	if IsNumeric(istrDefaultValue) then	
				iobjAction.PropertyValue = clng(istrDefaultValue)
			else
				iobjAction.PropertyValue = 0
			end if
    case PROP_TYPE_DOUBLE
			if IsNumeric(istrDefaultValue) then
				iobjAction.PropertyValue = CDbl(istrDefaultValue)
			else
				iobjAction.PropertyValue = 0.0
			end if
    case PROP_TYPE_DECIMAL
			if IsObject(istrDefaultValue) AND IsNumeric(istrDefaultValue) then
				iobjAction.PropertyValue = CDec(istrDefaultValue)
			else
				iobjAction.PropertyValue = 0.0
			end if
    case PROP_TYPE_STRING, PROP_TYPE_ENUM
			' In this case, cstr will at most return "" so we don't need to test it
      iobjAction.PropertyValue = cstr(istrDefaultValue)
    case PROP_TYPE_DATETIME
			if IsDate(istrDefaultValue) then
      	iobjAction.PropertyValue = cdate(istrDefaultValue)
			else
				iobjAction.PropertyValue = Now()
			end if
'   case PROP_TYPE_TIME
    case PROP_TYPE_BOOLEAN
			' In this case, cbool always returns true or false, so there is no need to test the input
      iobjAction.PropertyValue = cbool(istrDefaultValue)      
  end select
end sub


'----------------------------------------------------------------------------
'   Name: SetRSActionValue
'   Description:  Sets the value of a MTAssignmentAction - It needs to cast the
'                 value based on the PType of the action passed in.
'   Parameters: iobjAction - the condition to set the value to
'               istrValue - the value to set for the condition
'   Return Value: none
'-----------------------------------------------------------------------------
sub SetRSActionValue(iobjAction, istrValue)
 select case CLng(iobjAction.PropertyType)
    case PROP_TYPE_INTEGER
      iobjAction.PropertyValue = clng(istrValue)
    case PROP_TYPE_DOUBLE
       iobjAction.PropertyValue = Cdbl(istrValue)
    case PROP_TYPE_DECIMAL
       iobjAction.PropertyValue = CDec(istrValue)
    case PROP_TYPE_STRING, PROP_TYPE_ENUM
      iobjAction.PropertyValue = cstr(istrValue)
    case PROP_TYPE_DATETIME
      iobjAction.PropertyValue = cdate(istrValue)
'   case PROP_TYPE_TIME
    case PROP_TYPE_BOOLEAN
      iobjAction.PropertyValue = cbool(istrValue)      
  end select
end sub

'----------------------------------------------------------------------------
'   Name: SetRSConditionValue
'   Description:  Sets the value of a MTSimpleCondition - It needs to cast the
'                 value based on the PType of the condition passed in.
'   Parameters: iobjCondition - the condition to set the value to
'               istrValue - the value to set for the condition
'   Return Value: none
'-----------------------------------------------------------------------------
sub SetRSConditionValue(iobjCondition, istrValue)
 select case CLng(iobjCondition.ValueType)
    case PROP_TYPE_INTEGER
      iobjCondition.Value = clng(istrValue)
    case PROP_TYPE_DOUBLE
      iobjCondition.Value = Cdbl(istrValue)
    case PROP_TYPE_DECIMAL
      iobjCondition.Value = CDec(istrValue)
    case PROP_TYPE_STRING, PROP_TYPE_ENUM
      iobjCondition.Value = cstr(istrValue)
    case PROP_TYPE_DATETIME
      iobjCondition.Value = cdate(istrValue)
'   case PROP_TYPE_TIME
    case PROP_TYPE_BOOLEAN
      iobjCondition.Value = cbool(istrValue)
  end select
end sub

'----------------------------------------------------------------------------
'   Name: SymbolToTest
'   Description:  Converts the cleaner displays to RuleSet test strings
'   Parameters: istrTest - the string to change
'   Return Value: the new value
'-----------------------------------------------------------------------------
function SymbolToTest(istrTest) ' as string
  select case cstr(istrTest)
    case "=", "=="
      SymbolToTest = "equals"
    case "<>", "!="
      SymbolToTest = "not_equal"
    case "<"
      SymbolToTest = "less_than"
    case "<="
      SymbolToTest = "less_equal"
    case ">"
      SymbolToTest = "greater_than"
    case ">="
      SymbolToTest = "greater_equal"
    case else
      SymbolToTest = ""
  end select
  
end function

'----------------------------------------------------------------------------
'   Name: OperatorTypeToTest
'   Description:  Converts the Operator Type to RuleSet test strings
'   Parameters: istrTest - the Operator Type
'   Return Value: the new value
'-----------------------------------------------------------------------------
function OperatorTypeToTest(istrTest) ' as string
  select case Clng(istrTest)
    case OPERATOR_TYPE_EQUAL
     OperatorTypeToTest = "equals"
    case OPERATOR_TYPE_NOT_EQUAL
      OperatorTypeToTest = "not_equal"
    case OPERATOR_TYPE_LESS
      OperatorTypeToTest = "less_than"
    case OPERATOR_TYPE_LESS_EQUAL
      OperatorTypeToTest = "less_equal"
    case OPERATOR_TYPE_GREATER
      OperatorTypeToTest = "greater_than"
    case OPERATOR_TYPE_GREATER_EQUAL
      OperatorTypeToTest = "greater_equal"
    case else
      OperatorTypeToTest = ""
  end select
  
'  TODO: DO I HAVE TO WORRY ABOUT THESE GUYS HERE?
'  const OPERATOR_TYPE_NONE 			= 0
'  const OPERATOR_TYPE_LIKE 			= 1
'  const OPERATOR_TYPE_LIKE_W 			= 2 
  
end function

'----------------------------------------------------------------------------
'   Name: TestToSymbolHTML
'   Description:  Converts the RuleSet tests to cleaner displays
'   Parameters: istrTest - the string to change
'   Return Value: the new value
'-----------------------------------------------------------------------------
function TestToSymbolHTML(istrTest) ' as string
  select case cstr(istrTest)
    case "equals", "equal"
      TestToSymbolHTML = "="
    case "not_equal", "not_equals"
      TestToSymbolHTML = "&lt;&gt;"
    case "less_than"
      TestToSymbolHTML = "&lt;"
    case "less_equal"
      TestToSymbolHTML = "&lt;="
    case "greater_than", "great_than"
      TestToSymbolHTML = "&gt;"
    case "greater_equal", "great_equal"
      TestToSymbolHTML = "&gt;="
    case else
      TestToSymbolHTML = ""
  end select
end function

'----------------------------------------------------------------------------
'   Name: TestToSymbol
'   Description:  Converts the RuleSet tests to cleaner displays
'   Parameters: istrTest - the string to change
'   Return Value: the new value
'-----------------------------------------------------------------------------
function TestToSymbol(istrTest) ' as string
  select case cstr(istrTest)
    case "equals", "equal"
      TestToSymbol = "="
    case "not_equal", "not_equals"
      TestToSymbol = "!="
    case "less_than"
      TestToSymbol = "<"
    case "less_equal"
      TestToSymbol = "<="
    case "greater_than", "great_than"
      TestToSymbol = ">"
    case "greater_equal", "great_equal"
      TestToSymbol = ">="
    case else
      TestToSymbol = ""
  end select
  
end function

'----------------------------------------------------------------------------
'   Name: TestToOperatorType
'   Description:  Converts the RuleSet tests to the enumerated type used in the core components
'   Parameters: istrTest - the string to convert 
'   Return Value: the number corresponding to the enumerated type
'-----------------------------------------------------------------------------
function TestToOperatorType(istrTest) ' as string
  select case cstr(istrTest)
    case "equals", "equal"
      TestToOperatorType = OPERATOR_TYPE_EQUAL
    case "not_equal", "not_equals"
      TestToOperatorType = OPERATOR_TYPE_NOT_EQUAL
    case "less_than"
      TestToOperatorType = OPERATOR_TYPE_LESS
    case "less_equal"
      TestToOperatorType = OPERATOR_TYPE_LESS_EQUAL
    case "greater_than", "great_than"
      TestToOperatorType = OPERATOR_TYPE_GREATER
    case "greater_equal", "great_equal"
      TestToOperatorType = OPERATOR_TYPE_GREATER_EQUAL 
	'TODO: COMPLETE WITH OTHER TYPES:
	'OPERATOR_TYPE_NONE 
	'OPERATOR_TYPE_LIKE
	'OPERATOR_TYPE_LIKE_W
    case else
      TestToOperatorType = ""
  end select  
end function


'----------------------------------------------------------------------------
'   Name: TypeCheckAction
'   Description:  Checks the type for the given action and value.  If the 
'               value cannot be cast, then the function returns an error string
'   Parameters: iobjActionData - the condition to type check
'               istrValue - the value to convert
'   Return Value: String - empty if the type converts successfully
'-----------------------------------------------------------------------------
function TypeCheckAction(iobjActionData, istrValue)
on error resume next
dim varTemp

  TypeCheckAction = "" 
  
  select case CLng(iobjActionData.PType)
    case PROP_TYPE_INTEGER
      if not isnumeric(cstr(istrValue)) then
        TypeCheckAction = "&middot; " & iobjActionData.DisplayName  & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_MUSTBE_INTEGER")
      else 
        varTemp = clng(istrValue)
        if err then
          err.clear
          TypeCheckAction = "&middot; " & iobjActionData.DisplayName   & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_LONG_OVERFLOW")
        end if          
      end if  
    case PROP_TYPE_DOUBLE,PROP_TYPE_DECIMAL 
      if (not IsNumeric(istrValue)) or (InStr(istrValue, GetDecimalSeparator()) <> InStrRev(istrValue, GetDecimalSeparator())) then
			  TypeCheckAction = "&middot; " & iobjActionData.DisplayName & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_MUSTBE_NUMBER")
      end if
    case PROP_TYPE_DATETIME
      if not isdate(istrValue) then
        TypeCheckAction = "&middot; " & iobjActionData.DisplayName  &  "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_MUSTBE_DATE")
      end if
    'case PROP_TYPE_BOOLEAN
     '   TypeCheckAction = "&middot; " & iobjActionData.DisplayName  & " must be a boolean"
  end select
  
  if len(TypeCheckAction) > 0 then
    TypeCheckAction = TypeCheckAction + "<BR>"
  end if

end function


'----------------------------------------------------------------------------
'   Name: TypeCheckCondition
'   Description:  Checks the type for the given condition and value.  If the 
'               value cannot be cast, then the function returns an error string
'   Parameters: iobjConditionData - the condition to type check
'               istrValue - the value to convert
'   Return Value: String - empty if the type converts successfully
'-----------------------------------------------------------------------------
function TypeCheckCondition(iobjConditionData, istrValue)
on error resume next
  dim varTemp
  
  TypeCheckCondition = "" 
  
  select case CLng(iobjConditionData.PType)
    case PROP_TYPE_INTEGER
      if not isnumeric(cstr(istrValue)) then
        TypeCheckCondition = "&middot; " & iobjConditionData.DisplayName  & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_MUSTBE_INTEGER")
      else 
        varTemp = clng(istrValue)
        if err then
          err.clear
          TypeCheckCondition = "&middot; " & iobjConditionData.DisplayName  & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_LONG_OVERFLOW") 
        end if          
      end if
    case PROP_TYPE_DOUBLE, PROP_TYPE_DECIMAL
      if (not IsNumeric(istrValue)) or (InStr(istrValue, GetDecimalSeparator()) <> InStrRev(istrValue, GetDecimalSeparator())) then
        TypeCheckCondition = "&middot; " & iobjConditionData.DisplayName  & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_MUSTBE_NUMBER")
      end if
    case PROP_TYPE_DATETIME
      if not isdate(istrValue) then
        TypeCheckCondition = "&middot; " & iobjConditionData.DisplayName  &  "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_MUSTBE_DATE")
      end if
    'case PROP_TYPE_BOOLEAN
     '   TypeCheckCondition = "&middot; " & iobjConditionData.DisplayName  & " must be a boolean"
  end select
  
  if len(TypeCheckCondition) > 0 then
    TypeCheckCondition = TypeCheckCondition + "<BR>"
  end if

end function




'----------------------------------------------------------------------------
'   Name: UseDefaultActionMessage
'   Description:  Returns a string declaring that an action cannot be blank.
'   Parameters: iobjActionData - the action data to use to get some information
'   Return Value: String - the message to display
'-----------------------------------------------------------------------------
function UseDefaultActionMessage(iobjActionData)
  UseDefaultActionMessage = "&middot; " & iobjActionData.DisplayName & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_NOT_BLANK1")
	if len(iobjActionData.DefaultValue) > 0 then
		UseDefaultActionMessage = UseDefaultActionMessage & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_NOT_BLANK2") & "&nbsp;" & iobjActionData.DefaultValue & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_NOT_BLANK3") & "<BR>"
	end if
end function

'----------------------------------------------------------------------------
'   Name: UseOverflowMessage
'   Description:  Returns a string declaring that the value is too large.
'   Parameters: iobjActionData - the action data to use to get some information
'   Return Value: String - the message to display
'-----------------------------------------------------------------------------
function UseOverflowMessage(iobjActionData)
  UseOverflowMessage = "&middot; " & iobjActionData.DisplayName & "&nbsp;" & FrameWork.GetDictionary("TEXT_MPTE_ERROR_OVERFLOW")
end function

'----------------------------------------------------------------------------
'   Name: ValidateLength
'   Description:  Tests maximum size of data entered, depending on type
'   Parameters: strValue - the candidate metadataType - the type of string
'								to test against
'   Return Value: boolean
'-----------------------------------------------------------------------------
function ValidateLength(strValue, metadataType, metadataLength)
	Dim numDecimalPlaces
	
	ValidateLength = false
	Select Case metadataType
		Case PROP_TYPE_INTEGER
			if len(Replace(strValue, "-", "")) > len(CStr(MAX_INTEGER)) then
				ValidateLength = false
		  else
				On Error Resume Next
				ValidateLength = ((Clng(strValue) <= MAX_INTEGER) and (CLng(strValue) >= (-MAX_INTEGER - 1)))
				if err then
					On Error goto 0
					ValidateLength = false
				end if
			end if 
		Case PROP_TYPE_DOUBLE
			ValidateLength = true
		Case PROP_TYPE_STRING
			if metadataLength > 0 then
				ValidateLength = (len(strValue) <= metadataLength) and (len(strValue) <= MAX_STRING_SIZE) 
			else
				ValidateLength = len(strValue) <= MAX_STRING_SIZE
			end if
		Case PROP_TYPE_DATETIME
			ValidateLength = true ' I only care if IsDate is true or not
		Case PROP_TYPE_BOOLEAN
			ValidateLength = (len(strValue) < MAX_BOOLEAN_SIZE)
		Case PROP_TYPE_DECIMAL
			numDecimalPlaces = FindDecimalOffset(strValue)
			if numDecimalPlaces > MAX_DECIMAL_SCALE then
			  ' Too many decimal places
				ValidateLength = false
			else
			  ' The number of decimal places is known to be valid.
			  ' Thousand separators have already been stripped out of strValue at this point.

			  ' Since precision is defined as the total number of digits
			  ' (left and right of the decimal point),
			  ' we SHOULD just check that the total number of digits
			  ' does not exceed the maximum precision.
				'ValidateLength = ( len(Replace(strValue, GetDecimalSeparator(), "")) <= MAX_DECIMAL_PRECISION )

			  ' HOWEVER, SQL Server interprets (22,10) as a max of 10 digits
			  ' to the right of the decimal point and a max of 12 digits
			  ' to the left, so we do a different check:
			  if numDecimalPlaces = 0 then
			    ' No decimal places, but there might be a decimal point.
			  	ValidateLength = (len(Replace(strValue, GetDecimalSeparator(), "")) <= (MAX_DECIMAL_PRECISION - MAX_DECIMAL_SCALE))
				else
					ValidateLength = ((len(strValue) - numDecimalPlaces - 1) <= (MAX_DECIMAL_PRECISION - MAX_DECIMAL_SCALE))
			  end if
			end if
		Case else
			ValidateLength = true
	end Select
end function

'----------------------------------------------------------------------------
'   Name: WriteDebug
'   Description:  Writes out a table of debug messages from an array of strings
'   Parameters: none
'   Return Value: none
'-----------------------------------------------------------------------------
sub WriteDebug()
  dim i
  
  if DEBUG_ON then
    if not isArray(garrstrDebugMessages) then
      exit sub
    end if
  
    call response.write("<TABLE BORDER=1 WIDTH='100%' BGCOLOR='white' CELLPADDING='0' CELLSPACING='0'>" & vbNewLine)
    
    call response.write("  <TR>" & vbNewLine)
    call response.write("    <TD Class='mdmDebuggerCaption'>" & garrstrDebugMessages(i) & "</TD>" & vbNewLine)
    call response.write("  </TR>" & vbNewLine)
      
    for i = 1 to ubound(garrstrDebugMessages)
      call response.write("  <TR>" & vbNewLine)
      call response.write("    <TD Class='mdmDebuggerCell'>" & garrstrDebugMessages(i) & "</TD>" & vbNewLine)
      call response.write("  </TR>" & vbNewLine)  
    next
    call response.write("</TABLE>" & vbNewLine)

  end if
end sub


'----------------------------------------------------------------------------
'   Name: WriteError
'   Description:  Writes a 100% table with an error message that is passed in
'   Parameters: istrMessage - the message to display
'   Return Value: none
'-----------------------------------------------------------------------------
sub WriteError(istrMessage)

if len(istrMessage) > 0 then
  call response.write("<TABLE WIDTH=""100%"" BORDER=""1"" CELLSPACING=""0"" CELLPADDING=""0"" BORDERCOLOR=""black"" BGCOLOR=""black"">" & vbCrLf)
  call response.write(" <TR><TD>" & vbCrLf)
  call response.write("	  <TABLE WIDTH=""100%"" BORDER=""0"" CELLSPACING=""0"" CELLPADDING=""0"" BGCOLOR=""#FFCC00"">" & vbCrLf)
  call response.write("	    <TR>" & vbCrLf)
  call response.write("			  <TD WIDTH=10 HEIGHT=16>&nbsp;</TD>" & vbCrLf)
  call response.write("				<TD VALIGN=""top"" WIDTH=""37""><IMG SRC=""/mpte/us/images/error.gif"" WIDTH=38 HEIGHT=37 BORDER=0 ALT=""""></TD>" & vbCrLf)
  call response.write("				<TD><BR>" & vbCrLf)
  call response.write("				  <FONT FACE=""Verdana"" SIZE=""1"" COLOR=""Black"">")
  call response.write(					istrMessage )
  call response.write("					</FONT><BR><BR>" & vbCrLf)
  call response.write("				</TD>" & vbCrLf)
  call response.write("				<TD WIDTH=10 HEIGHT=16>&nbsp;</TD>" & vbCrLf)
  call response.write("			</TR>" & vbCrLf)
  call response.write("		</TABLE>" & vbCrLf)
  call response.write(" </TD></TR>" & vbCrLf)
  call response.write("</TABLE>" & vbCrLf)
	call response.write("<BR><BR>" & vbCrLf)
end if
end sub



'----------------------------------------------------------------------------
'   Name: writeTab
'   Description:  A utility function that writes out a specified number of vbtabs
'               Used for pretty print of ASP
'   Parameters: iintNumberTabs - the number of tabs to write out
'   Return Value: The string containing all the VBTabs
'-----------------------------------------------------------------------------
function writeTab(iintNumberTabs) ' as string
  dim i       ' as long
  dim intNum  ' as long
  
  if isNumeric(cstr(iintNumberTabs)) then
    intNum = clng(iintNumberTabs)
  else
    intNum = 0
  end if
  
  for i = 0 to intNum
    writeTab = writeTab & vbtab
  next
end function

'----------------------------------------------------------------------------
'   Name: writeDateTimeBoxes
'   Description:  Writes out a series of combo boxes for creating a date and
'               time.  Takes a date/time in as a parameter and marks the appropriate
'               items as selected.
'   Parameters: idtmDateTime - the date to use when selecting items
'               istrStyle - the style to use
'   Return Value: none
'-----------------------------------------------------------------------------
sub writeDateTimeBoxes(idtmDateTime, istrStyle)
  dim i
  dim intLowYear
  
  ' Write Month
  call response.write("  <td nowrap CLASS=""" & istrStyle & """>" & vbNewLine)
  call response.write("     <select name=""cmbMon"" class=""clsInputBox"">" & vbNewLine)
  for i = 1 to 12
    call response.write("       <option")
    if CLng(month(idtmDateTime)) = CLng(i) then
      call response.write(" SELECTED")
    end if
    call response.write(" VALUE=""" & i & """>")
    if i < 10 then
      call response.write("0")
    end if
    call response.write( i & "</OPTION>" & vbNewLine) 
  next
  call response.write("</select>" & vbnewLine & "&nbsp;/&nbsp;</td>" & vbNewLine)
  
  
  ' Write Day
  call response.write("  <td nowrap CLASS=""" & istrStyle & """>" & vbNewLine)
  call response.write("     <select name=""cmbDay"" class=""clsInputBox"">" & vbNewLine)
  for i = 1 to 31
    call response.write("       <option")
    if CLng(day(idtmDateTime)) = CLng(i) then
      call response.write(" SELECTED")
    end if
    call response.write(" VALUE=""" & i & """>")
    if i < 10 then
      call response.write("0")
    end if
    call response.write( i & "</OPTION>" & vbNewLine) 
  next
  call response.write("</select>" & vbnewLine & "&nbsp;/&nbsp;</td>" & vbNewLine)
  
  
  ' Write Year
  call response.write("  <td nowrap CLASS=""" & istrStyle & """>" & vbNewLine)
  call response.write("     <select name=""cmbYear"" class=""clsInputBox"">" & vbNewLine)
  if year(idtmDateTime) < year(now) then
    intLowYear = year(idtmDateTime) - 10
  else
    intLowYear = year(now) - 10
  end if
  for i = intLowYear to year(now) + 10
    call response.write("       <option")
    if CLng(year(idtmDateTime)) = CLng(i) then
      call response.write(" SELECTED")
    end if
    call response.write(" VALUE=""" & i & """>" & i & "</OPTION>" & vbNewLine) 
  next
  call response.write("</select>" & vbnewLine & "&nbsp;&nbsp;&nbsp;at&nbsp;&nbsp;&nbsp;</td>" & vbNewLine)
  
  
  ' Write Hour - do special work here since hours START AT 12
  call response.write("  <td nowrap CLASS=""" & istrStyle & """>" & vbNewLine)
  call response.write("     <select name=""cmbHour"" class=""clsInputBox"">" & vbNewLine)
  
  call response.write("       <option")
  if CLng(hour(idtmDateTime)) mod 12 = 0 then
    call response.write(" SELECTED")
  end if
  call response.write(" VALUE=""12"">12</OPTION>" & vbNewLine) 
  
  for i = 1 to 11
    call response.write("       <option")
    if CLng(hour(idtmDateTime)) mod 12 = CLng(i) then
      call response.write(" SELECTED")
    end if
    call response.write(" VALUE=""" & i & """>")
    if i < 10 then
      call response.write("0")
    end if
    call response.write( i & "</OPTION>" & vbNewLine) 
  next
  call response.write("</select>" & vbnewLine & "&nbsp;:&nbsp;</td>" & vbNewLine)
  
  
  ' Write Minute
  call response.write("  <td nowrap CLASS=""" & istrStyle & """>" & vbNewLine)
  call response.write("     <select name=""cmbMinute"" class=""clsInputBox"">" & vbNewLine)
  for i = 0 to 59
    call response.write("       <option")
    if CLng(minute(idtmDateTime)) = CLng(i) then
      call response.write(" SELECTED")
    end if
    call response.write(" VALUE=""" & i & """>")
    if i < 10 then
      call response.write("0")
    end if
    call response.write( i & "</OPTION>" & vbNewLine) 
  next
  call response.write("</select>" & vbnewLine & "&nbsp;:&nbsp;</td>" & vbNewLine)
    
  ' Write Seconds
  call response.write("  <td nowrap CLASS=""" & istrStyle & """>" & vbNewLine)
  call response.write("     <select name=""cmbSeconds"" class=""clsInputBox"">" & vbNewLine)
  for i = 0 to 59
    call response.write("       <option")
    if CLng(second(idtmDateTime)) = CLng(i) then
      call response.write(" SELECTED")
    end if
    call response.write(" VALUE=""" & i & """>")
    if i < 10 then
      call response.write("0")
    end if
    call response.write( i & "</OPTION>" & vbNewLine) 
  next
  call response.write("</select>" & vbnewLine & "&nbsp;:&nbsp;</td>" & vbNewLine)
  
  
  ' Write AM/PM
  call response.write("  <td nowrap CLASS=""" & istrStyle & """>" & vbNewLine)
  call response.write("     <select name=""cmbAMPM"" class=""clsInputBox"">" & vbNewLine)
  
  call response.write("       <option")
  if CLng(hour(idtmDateTime)) < 12 then
    call response.write(" SELECTED")
  end if
  call response.write(" VALUE=""AM"">AM</OPTION>" & vbNewLine) 
  
  call response.write("       <option")
  if CLng(hour(idtmDateTime)) >= 12 then
    call response.write(" SELECTED")
  end if
  call response.write(" VALUE=""PM"">PM</OPTION>" & vbNewLine) 
  call response.write("</select>" & vbnewLine & "&nbsp;&nbsp;(GMT)</td>" & vbNewLine)
  
end sub


'----------------------------------------------------------------------------
'   Name: WriteUnknownError
'   Description:  Writes an unknown error message to the user
'   Parameters: istrOptionalMessage - if not empty, then use that string
'   Return Value: none
'-----------------------------------------------------------------------------
sub WriteUnknownError(istrOptionalMessage)
  dim strErr, strRunTimeError
	
	If(err.Number)Then
			strRunTimeError = Cstr(Err.Number) & " " & Err.Description & " " & Err.source
	End If
	
  if len(istrOptionalMessage) > 0 then
    strErr = istrOptionalMessage
  else
    strErr = FrameWork.GetDictionary("TEXT_MPTE_ERROR_UNKNOWN")
  end if
  
  call response.write("<HTML><link rel=""stylesheet"" href=""styles/styles.css"">" & vbCrLf)
  call WriteError(strErr &  "<BR>" & strRunTimeError)
  call response.write("</HTML>" & vbCrLf)
end sub

sub WriteRunTimeError(istrOptionalMessage, bContinueHTMLWriting)
  dim strErr, strRunTimeError
	
	If(err.Number)Then
	
			strRunTimeError = Cstr(Err.Number) & " " & Err.Description & " " & Err.source
			
		  if len(istrOptionalMessage) > 0 then
		    	strErr = istrOptionalMessage
		  else
		    	strErr = FrameWork.GetDictionary("TEXT_MPTE_ERROR_UNKNOWN")
		  end if		  
		  call response.write("<HTML><link rel=""stylesheet"" href=""styles/styles.css"">" & vbCrLf)
		  call WriteError(strErr &  "<BR>" & strRunTimeError)
		  call response.write("</HTML>" & vbCrLf)
			if not bContinueHTMLWriting then
				response.End
			end if
	End If
end sub


FUNCTION FormatDecimalNumber(mDecimalValue, minDecimalScale)
  Dim strDecimalValue, strZeros, i, intseparatorindex, strtemp, strintegerpart, strdecimalpart
        
  strDecimalValue = CStr(mDecimalValue)
	
	'We will assume that the 
	intseparatorindex = InStr(strDecimalValue, GetDecimalSeparator())
	if intseparatorindex = 0 then
		intseparatorindex = len(strDecimalValue)
	end if
	      
  if not minDecimalScale = 0 then
    
		intseparatorindex = InStr(strDecimalValue, GetDecimalSeparator())
		
		if FindDecimalOffset(mDecimalValue) = 0 then
      strDecimalValue = strDecimalValue & GetDecimalSeparator()
		elseif intseparatorindex = 1 then
			strDecimalValue = "0" & strDecimalValue
    end if
		
    for i = 1 to (minDecimalScale - FindDecimalOffset(mDecimalValue))
      strDecimalValue = strDecimalValue & "0"
    next
								
  end if
  
	intseparatorindex = InStr(strDecimalValue, GetDecimalSeparator())
	     
	' Here we will strip the integer part from the decimal and add commas to it		 
	if intseparatorindex > 0 then
		strintegerpart = Left(strDecimalValue, intseparatorindex)
		strdecimalpart = Right(strDecimalValue, len(strDecimalValue) - intseparatorindex)
	else
		strintegerpart = strDecimalValue
		strdecimalpart = ""
	end if
	
	dim strFormattedIntegerPart
	strFormattedIntegerPart = CStr(FormatNumber(CDec(strintegerpart), 0))
	if Mid(strintegerpart,1,1) = "-" then
	  if Mid(strFormattedIntegerPart,1,1) <> "-" then
		strFormattedIntegerPart = "-" & strFormattedIntegerPart
	  end if
	end if
	
	strDecimalValue = strFormattedIntegerPart & GetDecimalSeparator() & strdecimalpart		   
	
	FormatDecimalNumber = strDecimalValue
	
END FUNCTION

Function AddChar(strvalue, intindex, strchar)
	AddChar = Left(strvalue, intindex) & strchar & Right(strvalue, (len(strvalue) - intindex))
End Function

Function AddThousandSeparator(strDecimalValue)

  Dim strtemp, inttemp2, strstore

  inttemp2 = Int((Len(strDecimalValue)-1) / 3)
    
  for i = 1 to inttemp2
		strtemp = strDecimalValue
		strDecimalValue = AddChar(strtemp, Len(strtemp) - (4*i -1)   , GetThousandSeparator())
  Next

  AddThousandSeparator = strDecimalValue
	  
End Function


'// SET OF FUNCTIONS TO DETECT AND DISPLAY DECIMAL TYPES WITH THE CORRECT SCALE
'// (NUMBER OF DIGITS RIGHT OF DECIMAL POINT).
'// WE WILL SWEEP THE RULESET AND FIGURE OUT WHICH DECIMAL VALUE HAS THE LARGEST
'// NUMBER OF DECIMAL PLACES.  AFTER THAT, WE WILL DISPLAY DECIMAL VALUES RIGHT-JUSTIFIED
'// AND CORRECTLY ALIGNED, WITH A MINIMUM SCALE OF 2.

'// Function FindDecimalOffset
'// in: the decimal value to test
'// out: how many decimal places it has 
FUNCTION FindDecimalOffset(decimalValue) 

	Dim strDecVal, intDecPointPlace
	
	strDecVal = CStr(decimalValue)
	
	intDecPointPlace = InStrRev(strDecVal, GetDecimalSeparator())
	
	if intDecPointPlace = 0 then
		FindDecimalOffset = 0
	else
		FindDecimalOffset = len(strDecVal) - intDecPointPlace
	end if
	
END FUNCTION
 
'// Function FindRulesetOffset
'// in: mstrPropertyName - the name of the property on the set
'//			mobjRuleset: the current ruleset
'//			boolIsAction:	is it an Action or Condition? Some function calls are different 

FUNCTION FindRulesetOffset(mstrPropertyName, mobjRuleset, boolIsAction)

	Dim objRule, objAction, objCondition, intTmpOffset
	intMaxOffset = DEFAULTDECIMALSCALEFORDISPLAY
	
	for each objRule in mobjRuleset
		intTmpOffset = 0
		if boolIsAction then
			for each objAction in objRule.Actions
				if (mstrPropertyName = objAction.PropertyName) then
					intTmpOffset = FindDecimalOffset(objAction.PropertyValue)
				end if
			next
		else
			for each objCondition in objRule.Conditions
				if (mstrPropertyName = objCondition.PropertyName) then
					intTmpOffset = FindDecimalOffset(objCondition.Value)
				end if
			next	
		end if
		if intTmpOffset > intMaxOffset then
			intMaxOffset = intTmpOffset
		end if
	next
	
	FindRulesetOffset = intMaxOffset
END FUNCTION

'// Function DetectDecimalPrecisions
'// Sweeps the ruleset (only decimals) and detects the largest precision for each decimal metadata
'// in: objTabRulesetReader : the TabRulesetReader object
'// 		objRuleset : the Ruleset
'// out: nothing
FUNCTION DetectDecimalPrecisions(objTabRulesetReader, objRuleset)
	dim mDicValues, objMetaData
	
	for each objMetaData in objTabRulesetReader.ActionDatas
		if objMetaData.PTYPE = PROP_TYPE_DECIMAL then
			session("DecimalPrecision_" & objMetaData.PropertyName) = FindRulesetOffset(objMetaData.PropertyName, objRuleset, true)
		end if
	next

	for each objMetaData in objTabRulesetReader.ConditionDatas
		if objMetaData.PTYPE = PROP_TYPE_DECIMAL then
			session("DecimalPrecision_" & objMetaData.PropertyName) = FindRulesetOffset(objMetaData.PropertyName, objRuleset, false)
		end if
	next

END FUNCTION

'----------------------------------------------------------------------------
'   Name: FormatString
'   Description:  Formats the value to the desired format.
'   Parameters: iintPType - the ptype to test for formatting
'               istrValue - the value to format
'               istrName  - the name, for decimal precision detection purposes
'   Return Value: String - the formatted value
'-----------------------------------------------------------------------------
function FormatString(iintPType, istrValue, istrName)

  FormatString = "" 
  if len(istrValue) = 0 then
    exit function
  end if
  
  select case CLng(iintPType)
    case PROP_TYPE_DOUBLE
      FormatString = istrValue
  
	 	case PROP_TYPE_DECIMAL
			if len(session("DecimalPrecision_" & istrName)) then
				'SECENG: CORE-4793 CLONE - MSOL BSS 30015 MetraOffer - Insecure XML Loading which allows for file discloure, DoS and XSS
				'Added HTML encoding
				FormatString = SafeForHtml(FormatDecimalNumber(istrValue, session("DecimalPrecision_" & istrName)))
				'response.write(">>>" & session("DecimalPrecision_" & istrName))
				'FormatString = FormatCurrency(istrValue, session("DecimalPrecision_" & istrName), -1, 0, -1)
			else
				'SECENG: CORE-4793 CLONE - MSOL BSS 30015 MetraOffer - Insecure XML Loading which allows for file discloure, DoS and XSS
				'Added HTML encoding
				FormatString = SafeForHtml(istrValue)
			end if
	  
	  case PROP_TYPE_DATETIME
	  	If CStr(CDate(istrValue)) <> "" then
				FormatString = CStr(CDate(istrValue))
			else
				FormatString = ""
			end if
			
    case PROP_TYPE_BOOLEAN
      if ucase(istrValue) = "TRUE" or ucase(istrValue) = "T" or ucase(istrValue) = "YES" or ucase(istrValue) = "Y" then
        FormatString = "True"
      elseif ucase(istrValue) = "FALSE" or ucase(istrValue) = "F" or ucase(istrValue) = "NO" or ucase(istrValue) = "N" then
        FormatString = "False"      
      
      elseif isNumeric(cstr(istrValue)) then  
        if CLng(istrValue) = -1 then
          FormatString = "True"
        elseif CLng(istrValue) = 0 then
          FormatString = "False"
        else 
          'SECENG: CORE-4793 CLONE - MSOL BSS 30015 MetraOffer - Insecure XML Loading which allows for file discloure, DoS and XSS
		  'Added HTML encoding
          FormatString = SafeForHtml(istrValue)
        end if
      else
		'SECENG: CORE-4793 CLONE - MSOL BSS 30015 MetraOffer - Insecure XML Loading which allows for file discloure, DoS and XSS
		'Added HTML encoding
        FormatString = SafeForHtml(istrValue)
      end if
      
    case else
	  'SECENG: CORE-4793 CLONE - MSOL BSS 30015 MetraOffer - Insecure XML Loading which allows for file discloure, DoS and XSS
	  'Added HTML encoding
      FormatString = SafeForHtml(istrValue)
  end select
  
end function

function PreProcessValue(strPropertyValue, mPropertyType)
	select case CLng(mPropertyType)
		case PROP_TYPE_DECIMAL, PROP_TYPE_DOUBLE
			PreProcessValue = Replace(strPropertyValue, GetThousandSeparator(), "")
		case else
			PreProcessValue = strPropertyValue
	end select
end function

%>