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

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  WizardClass.asp                                                            '
'  Contains VBScript to control dynamic wizards.                              '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


Public gobjMTWizard   'Create an instance of the Wizard for pages that include this



'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Class         : CMTWizard                                                   '
' Description   : Class containing data and methods to drive operation of the '
'               : dynamic wizard.                                             '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Class CMTWizard
  'Pages
  Private mstrCurPage       'Current page description
  Private mstrNextPage      'The next page in the wizard
  Private mstrPrevPage      'The previous page in the wizard

  Private mstrCurrentPageVerificationRoutine
  
  'Objects
  Private mobjXML           'Wizard.xml for the current wizard
  Private mobjPageNode      'Node for the current page
 
  'Data
  Private mstrWizardDir     'URL path for the wizard's files
  Private mstrWizardTemplateHTML  'HTML template for the wizard
  Private mstrTitle         'The title of the wizard
  Private mstrName          'The name of the wizard
  
  Private mstrPageTitle     'Title of the page
  
  Private marrInputs        'Array of inputs
  Private marrInputTypes    'Array of input types
  Private mintNumInputs     'Number of inputs
  
  Private marrNextConditions    'Conditions
  Private mintNumNextConditions 'Number of conditions
  Private marrPrevConditions    'Conditions
  Private mintNumPrevConditions 'Number of conditions

  
  Private mstrLeftFrame
  Private mstrRightFrame
  Private mstrButtonFrame
  
  'Buttons
  Private mstrNextButton
  Private mstrBackButton
  Private mstrFinishButton
  Private mstrCancelButton
  
  
  
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : Class_Initialize                                            '
  ' Description : Initialize variables and the XML dom object.                '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Sub Class_Initialize()
    Dim arrInputs()
    Dim arrInputTypes()
    Dim arrNextConditions()
    Dim arrPrevConditions()
    
    Dim objNode
    
    
    marrInputs          = arrInputs
    marrInputTypes      = arrInputTypes
    marrNextConditions  = arrNextConditions
    marrPrevConditions  = arrPrevConditions
    ''''''''''''''''''''''''''''''''''''''
    'Create the XML object
    Set mobjXML = Server.CreateObject("Microsoft.XMLDOM")
    
    'Load the wizard.xml
    mstrWizardDir = request.QueryString("Path")
    ''''''''''''''''''''''''''''''''''''''
    
    ''''''''''''''''''''''''''''''''''''''
    'Check if the path was passed in
    if len(mstrWizardDir) = 0 then
      err.description = "Wizard Path Not Passed."
      err.raise(-1)
    else
      ''''''''''''''''''''''''''''''''''''
      'Attempt to load the XML and check for parse error
      Call mobjXML.Load(server.MapPath(mstrWizardDir & "/wizard.xml"))
      
      if mobjXML.ParseError then
      err.description = "Parse Error in wizard.xml: " & mobjXML.ParseError.Reason
      err.raise(-1)
      end if
    end if
    
    ''''''''''''''''''''''''''''''''''''''
    'Get the current page id
    mstrCurPage = request.QueryString("PageID")
    
    if len(mstrCurPage) = 0 then
      err.description = "Current Page Not Passed."
      err.raise(-1)
    end if
    
    
    ''''''''''''''''''''''''''''''''''''''
    'Get the title
    mstrTitle = mobjXML.SelectSingleNode("/MTWizard/title").text
    
    
    ''''''''''''''''''''''''''''''''''''''
    'Get the template
    mstrWizardTemplateHTML = mobjXML.SelectSingleNode("/MTWizard/template").text
    
    ''''''''''''''''''''''''''''''''''''''
    'Get the name
    mstrName = mobjXML.SelectSingleNode("/MTWizard/name").text
    
    'If we are finished, then there is no page node
    if mstrCurPage = "_FINISHED" then
      exit sub
    end if
    
    ''''''''''''''''''''''''''''''''''''''
    'Get the current page node
    Set mobjPageNode = mobjXML.selectSingleNode("/MTWizard/page[@id='" & mstrCurPage & "']")
    
    if mobjPageNode is nothing then
      err.description = "Unable to get page node."
      err.raise(-1)
    end if
    
    ''''''''''''''''''''''''''''''''''''''
    'Get the page title
    Set objNode = mobjPageNode.selectSingleNode("title")
    
    if not objNode is nothing then
      mstrPageTitle = objNode.text
    end if
    
    ''''''''''''''''''''''''''''''''''''''    
    'Load the frame templates
    Call LoadFrameTemplates()

    mstrCurrentPageVerificationRoutine = GetNodeText("update_verification_eval", mobjPageNode)
       
    ''''''''''''''''''''''''''''''''''''''    
    'Get the next & previous page Ids
    mstrPrevPage = GetNodeText("previous_page", mobjPageNode)
    mstrNextPage = GetNodeText("next_page", mobjPageNode)

    
    ''''''''''''''''''''''''''''''''''''''    
    'Get the buttons
    mstrNextButton    = GetNodeText("buttons/next", mobjXML.documentElement)
    mstrBackButton    = GetNodeText("buttons/back", mobjXML.documentElement)
    mstrFinishButton  = GetNodeText("buttons/finish", mobjXML.documentElement)
    mstrCancelButton  = GetNodeText("buttons/cancel", mobjXML.documentElement)
    
    ''''''''''''''''''''''''''''''''''''''    
    'Load the inputs
    Call LoadInputs()
    
  End Sub
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : LoadInputs()                                              '
  ' Description : Load the inputs section of the page.                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function LoadInputs()
    Dim objNodeList     'List of input nodes
    Dim objNode         'Each input node
        
    Set objNodeList = mobjPageNode.selectNodes("inputs/input")
    
    mintNumInputs = 0
    
    for each objNode in objNodeList
      redim preserve marrInputs(mintNumInputs)
      redim preserve marrInputTypes(mintNumInputs)      
      
      marrInputs(mintNumInputs) = objNode.text
      marrInputTypes(mintNumInputs) = objNode.attributes.getNamedItem("type").value      
      
      mintNumInputs = mintNumInputs + 1
    next      
    
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : GetPageHTML()                                             '
  ' Description : Get the HTML to render the page.                          '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function GetPageHTML()                                             
    Dim strHTML       'HTML output
    Dim objFSO        'Filesystem object
    Dim objTxtStream  'Textstream object
    Dim strPath       'Path to the template

    'Get the template
    strPath = server.MapPath(mstrWizardDir & "/" & mstrWizardTemplateHTML)
    
    Set objFSO = server.CreateObject("Scripting.FileSystemObject")
    
    Set objTxtStream = objFSO.OpenTextFile(strPath)
    
    strHTML = objTxtStream.ReadAll
    
    strHTML = DoPageSubs(strHTML)
    
    GetPageHTML = strHTML
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : GetNodeText(strSearch, strSearcNode)                      '
  ' Description : Get the text for the child node of the page. If the node  '
  '             : does not exist, an empty string is returned.              '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function GetNodeText(strSearch, strSearchNode)
    Dim objNode
'    response.write "<br>Search: " & strSearch    
    Set objNode = strSearchNode.selectSingleNode(strSearch)
    
    if not objNode is nothing then
      GetNodeText = objNode.text
'     response.write " -- > Found."
    else
      GetNodeText = ""
'      response.write " -- > Not Found."
    end if
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : LoadFrameTemplates                                        '
  ' Description : Load the templates for the individual frames.             '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function LoadFrameTemplates()
    mstrLeftFrame   = GetHTML("left", mobjXML.documentElement)
    mstrRightFrame  = GetHTML("right", mobjXML.documentElement)
    mstrButtonFrame = GetHTML("button", mobjXML.documentElement)        
  End Function  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : DeterminePage(strPage)                                    '
  ' Description : Load the conditions for page transfer.                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function DeterminePage(strPage)
    Dim objNodeList
    Dim objNode
    Dim strProperty
    Dim strOperation
    Dim strValue
    Dim strNext
    Dim strSessVal
    
    Set objNodeList = mobjPageNode.selectNodes(strPage & "_page_condition")
    
    for each objNode in objNodeList
      strProperty   = GetNodeText("property", objNode)
      strOperation  = GetNodeText("operation", objNode)
      strValue      = GetNodeText("value", objNode)
      strNext       = GetNodeText("next_page", objNode)
      
      strSessVal = session(mstrName & "_" & strProperty)

      if eval("""" & strSessVal & """" & strOperation & """" & strValue & """") then
        if UCase(strPage) = "NEXT" then
          mstrNextPage = strNext
        else
          mstrPrevPage = strNext
        end if
        exit for
      end if
    next
    
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : GetHTML                                                   '
  ' Description : Load the HTML from the wizard.xml file or from a template '
  '             :  file.                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function GetHTML(strFrame, objSearchNode)
    Dim objFSO        'File system object
    Dim objTxtStream  'Text stream object
    Dim objNode
    Dim strHTML       'HTML string
    
    'Try to get the HTML from the wizard.xml, searches for the following, in order:
    '     _frame_html
    '     _frame_template
    '     _frame_eval
    
'    response.write "<br>Frame: " & strFrame & " ... Looking for: " & strFrame & "_frame_html"
    Set objNode = objSearchNode.selectSingleNode(strFrame & "_frame_html")
    
    if not objNode is nothing then
'      response.write "--->Found!"
      strHTML = objNode.text
      
      'Perform any substitutions
      
      'Return the HTML
      GetHTML = strHTML
    else
'      response.write "--->Not Found!"    
      'Check for a file
      Set objNode = objSearchNode.selectSingleNode(strFrame & "_frame_file")
      
      'If the file exists, load it and get the data
      dim strLinkName
      dim strFileName
      if not objNode is nothing then
        Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
        'Determine if this an explicit file name or a MDM dictionary link
        if instr(objNode.text,"[") = 0 then
          'This is an explicit file, open it and get its contents
          on error resume next
          strFileName = server.MapPath(mstrWizardDir & "/" & objNode.text)
          Set objTxtStream = objFSO.OpenTextFile(strFileName)
          strHTML = objTxtStream.ReadAll
          if (err.number) then
            strHTML = "Error opening file [" & strFileName & "]"
          end if
        else
          'This is a link reference, look it up in the dictionary and then also do the key term replacements
          strLinkName = replace(objNode.text,"[","")
          strLinkName = replace(strLinkName,"]","")
          strFileName = server.MapPath(session("mdm_LOCALIZATION_DICTIONARY").Item(strLinkName).value)
          on error resume next
          Set objTxtStream = objFSO.OpenTextFile(strFileName)
          strHTML = session("mdm_LOCALIZATION_DICTIONARY").Preprocess(objTxtStream.ReadAll)
          if (err.number) then
            strHTML = "Error opening file [" & strFileName & "]"
          end if

        end if
        
        'Return the HTML
        GetHTML = strHTML
      else
        Set objNode = objSearchNode.selectSingleNode(strFrame & "_frame_eval")
        
        if not objNode is nothing then
          strHTML = eval(replace(objNode.text, "[WIZARD_NAME]", mstrName))
          GetHTML = strHTML
        end if      
      end if
    end if
  End Function 
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : DoPageSubs(strHTML)                                       '
  ' Description : Perform all the substitutions on the page.                '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Function DoPageSubs(strHTML)

    'Place the individual Frames
    strHTML = replace(strHTML, "[WIZARD_TITLE]", mstrTitle)
    strHTML = replace(strHTML, "[LEFT_FRAME]", mstrLeftFrame)
    strHTML = replace(strHTML, "[RIGHT_FRAME]", mstrRightFrame)
    strHTML = replace(strHTML, "[BUTTON_FRAME]", DoButtonSubs(mstrButtonFrame))
    
    'Place the content of the individual frames
    strHTML = replace(strHTML, "[LEFT_FRAME_HTML]", GetHTML("left", mobjPageNode))
    strHTML = replace(strHTML, "[RIGHT_FRAME_HTML]", GetHTML("right", mobjPageNode))
    strHTML = replace(strHTML, "[PAGE_ID]", mstrCurPage)
    strHTML = replace(strHTML, "[PAGE_TITLE]", mstrPageTitle)
	  strHTML = replace(strHTML, "[TEXT_KEYTERM_RECURRING_CHARGE]",FrameWork.GetDictionary("TEXT_KEYTERM_RECURRING_CHARGE"))
		strHTML = replace(strHTML, "[TEXT_ADD_RECURRING]",FrameWork.GetDictionary("TEXT_ADD_RECURRING"))
		strHTML = replace(strHTML, "[TEXT_NEW]",FrameWork.GetDictionary("TEXT_NEW"))
		strHTML = replace(strHTML, "[TEXT_WIZARD]",FrameWork.GetDictionary("TEXT_WIZARD"))
		strHTML = replace(strHTML, "[TEXT_SELECT_TYPE]",FrameWork.GetDictionary("TEXT_SELECT_TYPE"))
  	strHTML = replace(strHTML, "[TEXT_SELECT_PERIOD]",FrameWork.GetDictionary("TEXT_SELECT_PERIOD"))
  	strHTML = replace(strHTML, "[TEXT_CONFIGURE_CHARGE]",FrameWork.GetDictionary("TEXT_CONFIGURE_CHARGE"))
		
	' Non Recurring charge	
    strHTML = replace(strHTML, "[TEXT_KEYTERM_NON_RECURRING_CHARGE]",FrameWork.GetDictionary("TEXT_KEYTERM_NON_RECURRING_CHARGE"))
   	strHTML = replace(strHTML, "[TEXT_ADD_NON_RECURRING]",FrameWork.GetDictionary("TEXT_ADD_NON_RECURRING"))
   	strHTML = replace(strHTML, "[TEXT_CONFIGURE_EVENT]",FrameWork.GetDictionary("TEXT_CONFIGURE_EVENT"))

	' Discounts	
   	strHTML = replace(strHTML, "[TEXT_KEYTERM_DISCOUNT]",FrameWork.GetDictionary("TEXT_KEYTERM_DISCOUNT"))
  	strHTML = replace(strHTML, "[TEXT_ADD_DISCOUNT]",FrameWork.GetDictionary("TEXT_ADD_DISCOUNT"))
  	strHTML = replace(strHTML, "[TEXT_SELECT_PERIOD]",FrameWork.GetDictionary("TEXT_SELECT_PERIOD"))
  	strHTML = replace(strHTML, "[TEXT_CONFIGURE_CHARGE]",FrameWork.GetDictionary("TEXT_CONFIGURE_CHARGE"))
  	strHTML = replace(strHTML, "[TEXT_SUMMARY]",FrameWork.GetDictionary("TEXT_SUMMARY"))

	' Product offering		
  	strHTML = replace(strHTML, "[TEXT_KEYTERM_PRODUCT_OFFERING]",FrameWork.GetDictionary("TEXT_KEYTERM_PRODUCT_OFFERING"))
  	strHTML = replace(strHTML, "[TEXT_EFFECTIVE_DATES]",FrameWork.GetDictionary("TEXT_EFFECTIVE_DATES"))
	
	' Price List	
  	strHTML = replace(strHTML, "[TEXT_KEYTERM_PRICE_LIST]",FrameWork.GetDictionary("TEXT_KEYTERM_PRICE_LIST"))
	
	
    strHTML = DoErrorMessageSub(strHTML)
    
    'Form Action
    strHTML = DoFormSubs(strHTML)
   
    DoPageSubs = strHTML
  End Function
  
  Private Function DoErrorMessageSub(strHTML)
  
    if len(request.QueryString("Error")) then
      strHTML = replace(strHTML, "[ERROR_MESSAGE]", RenderErrorMessage(session(mstrName & "__ErrorMessage")))
    else
      strHTML = replace(strHTML, "[ERROR_MESSAGE]", "")
    end if
    
    DoErrorMessageSub = strHTML
  End Function
  
  Private Function RenderErrorMessage(varErrorMessage)
    dim strErrorHTML
    
    strErrorHTML = strErrorHTML & "<TABLE class=""clsWizardError"" width=""100%"" BORDER=""1"" BORDERCOLOR=""Black"" CELLSPACING=""0"" CELLPADDING=""0"">" & vbNewline
    strErrorHTML = strErrorHTML & "  <TR>" & vbNewline
    strErrorHTML = strErrorHTML & "    <TD>" & vbNewline
    strErrorHTML = strErrorHTML & "      <TABLE class=""clsWizardError"" BORDER=""0"">" & vbNewline
    strErrorHTML = strErrorHTML & "        <TR>" & vbNewline
    strErrorHTML = strErrorHTML & "          <TD WIDTH=10 HEIGHT=16><IMG SRC=""" & "/mcm/default/localized/en-us" & "/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
    strErrorHTML = strErrorHTML & "          <TD VALIGN=""top""><IMG SRC=""" & "/mcm/default/localized/en-us" &  "/images/icons/warningSmall.gif"" align=""center"" BORDER=""0"" >&nbsp;</TD>" & vbNewline
    strErrorHTML = strErrorHTML & "          <TD class=""clsWizardErrorText"">"
    
    'What kind of error message was passed to us
    if isObject(varErrorMessage) then
      'assume this is a dictionary
      dim i 'objItem
      dim objItems
      objItems = varErrorMessage.Items
      for i = 0 to varErrorMessage.count-1    
        strErrorHTML = strErrorHTML & objItems(i) & "<BR>"
      next
    else
      'assume it is a string
      strErrorHTML = strErrorHTML & varErrorMessage
    end if
    
    'Substitute any key terms in the error message
    strErrorHTML = Framework.Dictionary.PreProcess(strErrorHTML) 

    strErrorHTML = strErrorHTML & "</TD>" & vbNewline
    strErrorHTML = strErrorHTML & "          <TD WIDTH=10 HEIGHT=16><IMG SRC=""" & "/mcm/default/localized/en-us" & "/images/spacer.gif"" WIDTH=""10"" HEIGHT=""16"" BORDER=""0""></TD>" & vbNewline
    strErrorHTML = strErrorHTML & "        </TR>" & vbNewline
    'strErrorHTML = strErrorHTML & "        <TR>" & vbNewline
    'strErrorHTML = strErrorHTML & "          <TD>&nbsp</TD>" & vbNewline
    
    'strErrorHTML = strErrorHTML & "        </TR>" & vbNewline
    strErrorHTML = strErrorHTML & "      </TABLE>" & vbNewline
    strErrorHTML = strErrorHTML & "    </TD>" & vbNewline
    strErrorHTML = strErrorHTML & "  </TR>" & vbNewline
    strErrorHTML = strErrorHTML & "</TABLE>"

    RenderErrorMessage = strErrorHTML
  End Function
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : DoFrameSubs(strHTML)                                      '
  ' Description : Perform the substitutions for the frames.                 '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function DoButtonSubs(strHTML)
    Dim strState
    Const DISABLED = "disabled"
  
    'Back button
    strHTML = replace(strHTML, "[BACK_BUTTON]", mstrBackButton)
    strHTML = replace(strHTML, "[TEXT_BACK]", FrameWork.GetDictionary("TEXT_BACK"))

    'Set the state
    if len(mstrPrevPage) = 0 then
      strState = DISABLED
    else
      strState = ""
    end if
    
    strHTML = replace(strHTML, "[BACK_BUTTON_STATE]", strState)
    
    'Next/Finish Button
    if len(mstrNextPage) = 0 then
      strHTML = replace(strHTML, "[NEXT_BUTTON]", mstrFinishButton)
      strHTML = replace(strHTML, "[TEXT_FINISH]", FrameWork.GetDictionary("TEXT_FINISH"))
    else
      strHTML = replace(strHTML, "[NEXT_BUTTON]", mstrNextButton)
      strHTML = replace(strHTML, "[TEXT_NEXT]", FrameWork.GetDictionary("TEXT_NEXT"))
    end if
    
    'Cancel Button
    strHTML = replace(strHTML, "[CANCEL_BUTTON]", mstrCancelButton)
    strHTML = replace(strHTML, "[TEXT_CANCEL]", FrameWork.GetDictionary("TEXT_CANCEL"))

 
    DoButtonSubs = strHTML  
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : DoFormSubs()                                              '
  ' Description : Replace values in forms.                                  '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function DoFormSubs(strHTML)
  
    strHTML = replace(strHTML, "[FORM_ACTION]", "wizard.asp?PageID=" & mstrCurPage & "&Path=" & mstrWizardDir & "&Update=True")
  
    DoFormSubs = strHTML
  End Function
  
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : CheckInputs                                               '
  ' Description : Parse all the expected inputs from the form.              '
  ' Inputs      : none                                                      '
  ' Outputs     : none                                                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function CheckInputs()
    Dim i                   'Counter
    
    for i = 0 to mintNumInputs - 1
      session(marrInputs(i)) = request.form(marrInputs(i))       
    next

    ''''''''''''''''''''''''''''''''''''''
    'Determine the Next/Previous Pages
    Call DeterminePage("next")
    Call DeterminePage("previous")    
  
  End Function

  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Properties                                                              '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Property Get Path()
    Path = mstrWizardDir
  End Property
  
  Public Property Get Name()
    Name = mstrName
  End Property
  
  Public Property Get NextPage()
    NextPage = mstrNextPage
  End Property
  
  Public Property Get PreviousPage()
    PreviousPage = mstrPrevPage
  End Property 
  
  Public Property Get CurrentPage()
    CurrentPage = mstrCurPage
  End Property
  
  Public Property Get UpdateVerificationRoutine()
    
    UpdateVerificationRoutine = replace(mstrCurrentPageVerificationRoutine, "[WIZARD_NAME]", mstrName)
    
  End Property

End Class



'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Create the object for the pages that include this file.                   '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Set gobjMTWizard = New CMTWizard

%>
