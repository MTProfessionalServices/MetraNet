<!-- #INCLUDE VIRTUAL="/mdm/SecurityFramework.asp" -->
<%
' --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'  Copyright 1998,2000 by MetraTech Corporation
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
'  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
' NAME		        :   MetraTech Dialog Manager - Product View Browser Event
' VERSION	        :   1.0
' CREATION_DATE   :   08/xx/2000
' AUTHOR	        :   F.Torres.
' DESCRIPTION	    :   This file contains the default implementation of the MDM ProductView Browser Events.
'                     For each event I define 2 functions, For instance :
'                     Form_DisplayBeginOfPage
'                     inheritedForm_DisplayBeginOfPage
'
'                     Form_DisplayBeginOfPage just calls inheritedForm_DisplayBeginOfPage, and nothing must be implemented
'                     in Form_DisplayBeginOfPage but every thing in inheritedForm_Initialize!
'                     WHY?
'                     This events are part of the MDM Product View Browser Form class. If you do not define
'                     an event the default one is executed. Now If you define your own event
'                     in the ASP Form file; your event is executed instead. A good Object Oriented question
'                     that comes then is How can I call the default implementation
'                     (the inherited event). 
'                     I want the programmer to be able to call the Default Super/Inherited Event from its own event
'                     this way inherited("Form_Initialize(EventArg)"). 
'                     In the case of Product View Browser Form; it is very use full to be able to call the inherited event.
'                     In the case of a Dialog Form only the event Form_Click contains code.
'                     Since it is use full in the PV and may become usefull in the next future for a dialog.
'                     F.TORRES 9/2/2000!
'
' ----------------------------------------------------------------------------------------------------------------------------------------


' -----------------------------------------------------------------------------
' FUNCTION 		: Form_Export_Transform
' PARAMETERS	: EventArg
' DESCRIPTION : Gets the rowset XML and transforms it to CSV.
'               No localization, or enum lookup (faster than inheritedForm_Export)
' RETURNS			: TRUE / FALSE
' USAGE       : Add the following to your page:            
'                 PRIVATE FUNCTION Form_Export(EventArg) ' As Boolean
'                   Form_Export = Form_Export_Transform(EventArg)
'                 END FUNCTION
' -----------------------------------------------------------------------------
PRIVATE FUNCTION Form_Export_Transform(EventArg) ' As Boolean

  CONST DELIMITER = "<xsl:value-of select=""$delimiter"" />"
  CONST QUOTE = "<xsl:value-of select=""$quote"" />"
  
  Dim TimeOut

  Form_Export_Transform = FALSE
  Response.Buffer = TRUE
   Response.Clear
  ' Save timeout value and increase it for this page
  TimeOut = Server.ScriptTimeout 
  Server.ScriptTimeout = 60 * 60    ' set timeout to 1 hour
  
  Response.ContentType = "application/csv"
  Response.AddHeader "Content-Disposition", "attachment; filename=export.csv"
  Response.Write "sep=,"
  Response.Write vbNewLine

  ' Load XSL template
  Dim fso, fs, strXSL, templateXSLFile
  templateXSLFile = Server.MapPath("/MDM/internal") & "\RowsetToCSV.xsl"
  Set fso = Server.CreateObject("Scripting.FileSystemObject")

  'Make sure the text file exists
  If Not fso.FileExists(templateXSLFile) then
    ' Tell the user we can't find the XSL transform...
	  Response.Write "Transform file can not be located at: " & templateXSLFile
	  Response.end
  Else
    Set fs = fso.OpenTextFile(templateXSLFile, 1) ' open for reading
	  While Not fs.AtEndOfStream
  	  strXSL = fs.ReadAll
	  Wend
	  fs.Close
  End If

  ' Replace the dynamic header and attributes
  Dim i, dynProps, dynHeader
  dynProps = ""
  dynHeader = ""
  
  For i = 1 To ProductView.Properties.Count
    If ProductView.Properties(i).ExportAble And (ProductView.Properties(i).Flags And eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET)=0 Then
      Dim nm, name
      name = ProductView.Properties(i).Name
      
      ' If there is a space in the column name, 
      ' then we use a synthetic column name defined by Microsoft
      If Instr(1, name, " ") > 0 Then
        nm = "c" & i-1
      Else
        nm = name
      End If
      
      dynHeader = dynHeader & QUOTE & "<xsl:text>" & name & "</xsl:text>" & QUOTE  ' write header name
      
      If UCase(ProductView.Properties(i).PropertyType) = UCase(MSIXDEF_TYPE_STRING) Then
        dynProps = dynprops & QUOTE & "<xsl:value-of select=""@" & nm & """ />" & QUOTE 
      Else
        dynProps = dynprops & "<xsl:value-of select=""@" & nm & """ />"
      End If
      
      dynHeader = dynHeader & DELIMITER
      dynProps = dynprops & DELIMITER
    End If      
  Next
  
  ' remove trailing delimiter
  dynHeader = Mid(dynHeader, 1, Len(dynHeader) - Len(DELIMITER))
  dynProps = Mid(dynProps, 1, Len(dynProps) - Len(DELIMITER))
  
  dynHeader = dynHeader & "<xsl:value-of	select=""$newline"" />"
  dynProps = dynprops & "<xsl:value-of	select=""$newline"" />"
                
  strXSL = Replace(strXSL, "<!--##DYNAMIC_HEADER##-->", dynHeader)    
  strXSL = Replace(strXSL, "<!--##DYNAMIC_ATTRIBUTES##-->", dynProps)

  ' Load XML to CSV transform
  Dim objXSL, csvString
  Set objXSL = server.CreateObject("MSXML2.DOMDocument.4.0")
  objXSL.async = false
  objXSL.validateOnParse = false
  objXSL.resolveExternals = false
  Call objXSL.LoadXML(strXSL)

  ' Get the rowset as XML and run the transform
  Dim strCSV
  strCSV = ProductView.Properties.Rowset.SaveToXml(objXSL)

  ' Stream out CSV export
  Dim outStream
	Set outStream = Server.CreateObject("ADODB.Stream")
	outStream.Open
	outStream.Type = 2 'adTypeText
	outStream.WriteText strCSV
	outStream.Position = 0
	While Not outStream.EOS
	  Response.Write outStream.ReadText(1024)
	wend
	outStream.Close

  ' Set timeout back  
  Server.ScriptTimeout = TimeOut   
  
  Form_Export_Transform = TRUE
END FUNCTION
    
' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 		: inheritedForm_Export
' PARAMETERS	: EventArg
' DESCRIPTION : Loops around the rowset and dumps exportable properties to
'               the response object with buffering.
' RETURNS			: TRUE / FALSE
PRIVATE FUNCTION inheritedForm_Export(EventArg) ' As Boolean

    Dim i, j, strValue, TimeOut, start, duration

    inheritedForm_Export  = FALSE
    
    ' Save timeout value and increase it for this page
    TimeOut = Server.ScriptTimeout 
    Server.ScriptTimeout = 60 * 5    ' Start at 5 min.
    start = now
    
    Response.Clear()
    Response.Buffer = TRUE
    Response.ContentType = "application/csv"
    Response.AddHeader "Content-Disposition", "attachment; filename=export.csv"
    Response.Write "sep=,"
    Response.Write vbNewLine
    ' Generate the column caption
    For i = 1 To ProductView.Properties.Count

      ' Remove static updatable property from the export
      If ProductView.Properties(i).ExportAble And (ProductView.Properties(i).Flags And eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET)=0 Then
         Response.Write """"
         Response.Write ProductView.Properties(i).Caption
         Response.Write ""","
      End If      
    Next
    Response.Write vbNewLine

    ' Generate the data
    if ProductView.Properties.Rowset.RecordCount > 0 then
      ProductView.Properties.Rowset.MoveFirst
      j = 1
      Do While Not ProductView.Properties.Rowset.EOF    
          
          For i = 1 To ProductView.Properties.Count
          
            If ProductView.Properties(i).ExportAble And (ProductView.Properties(i).Flags And eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET)=0 Then
                
                strValue = ProductView.Properties(i).Value
                If IsArray(strValue) Then
                    strValue = ""
                End If
                Response.Write """"
                Response.Write strValue 
                Response.Write ""","
            End If
          Next
          Response.Write vbNewLine
          ProductView.Properties.Rowset.MoveNext
          
          ' Make sure we have enough time every thousand rows
		  ' and flush the buffer
          If j Mod 1000 = 0 Then
            duration = DateDiff("n", start, now)          
            If duration > 4 Then ' if we are getting close to server timeout add 5 more minutes
              Server.ScriptTimeout = Server.ScriptTimeout + (60 * 5)
              start = now
            End If
			' AspBufferingLimit defaults to 4 MB. Assumption is that 1000 rows
			' will not come close to this limit.
            Response.Flush
          End If
          
          j = j + 1
      Loop
    end if

    ' Set timeout back  
    Server.ScriptTimeout = TimeOut   

    inheritedForm_Export = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION inheritedForm_DisplayBeginOfPage(EventArg) ' As Boolean

    EventArg.HTMLRendered =   "<table border='0' cellpadding='3' cellspacing='0' width='100%' >" ' bgcolor='#FFFFFF'
    inheritedForm_DisplayBeginOfPage = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: inheritedForm_DisplayEndOfPage 
' PARAMETERS		:
' DESCRIPTION 		: The event Close the TABLE and the FORM
' RETURNS			:
PRIVATE FUNCTION inheritedForm_DisplayEndOfPage(EventArg) ' As Boolean

    EventArg.HTMLRendered =   "</TABLE></FORM>"
    Dim objWidget
    For Each objWidget in Form.Widgets
      EventArg.HTMLRendered = EventArg.HTMLRendered & vbNewLine & objWidget.GetFooter() & vbNewline
    Next
    
    inheritedOnDisplayEndOfPageJavaScript EventArg

    EventArg.HTMLRendered = EventArg.HTMLRendered &   "</BODY></HTML>"
    inheritedForm_DisplayEndOfPage = TRUE
END FUNCTION


PRIVATE FUNCTION inheritedOnDisplayEndOfPageJavaScript(EventArg)

    If Len(Form.OnDisplayEndOfPageJavaScript) Then
        EventArg.HTMLRendered = EventArg.HTMLRendered & "<SCRIPT>" & vbNewLine & Form.OnDisplayEndOfPageJavaScript & vbNewline & "</SCRIPT>"
        Form.JavaScriptInitialize = ""
    End If
    inheritedOnDisplayEndOfPageJavaScript = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION inheritedForm_DisplayBeginHeader(EventArg) ' As Boolean
    EventArg.HTMLRendered =   "<tr>"
    inheritedForm_DisplayBeginHeader = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION inheritedForm_DisplayEndHeader(EventArg) ' As Boolean
    EventArg.HTMLRendered =   "</tr>"
    inheritedForm_DisplayEndHeader = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION inheritedForm_DisplayBeginRow(EventArg) ' As Boolean
    
    If(IsValidObject(Form.Grid.PropertyID))Then
        EventArg.HTMLRendered =   "<tr id='" & Form.Grid.PropertyID.Value & "'>"            
    Else
        EventArg.HTMLRendered =   "<tr>"            
    End If
    
    inheritedForm_DisplayBeginRow = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION inheritedForm_DisplayEndRow(EventArg) ' As Boolean
    
    EventArg.HTMLRendered =   "</tr>"
    inheritedForm_DisplayEndRow = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION inheritedForm_DisplayBeginDetailRow(EventArg) ' As Boolean
    EventArg.HTMLRendered =   "<tr>"
    inheritedForm_DisplayBeginDetailRow = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION inheritedForm_DisplayEndDetailRow(EventArg) ' As Boolean
    EventArg.HTMLRendered =   "</tr>"
    inheritedForm_DisplayEndDetailRow = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION inheritedForm_DisplayHeaderCell(EventArg) ' As Boolean

    Dim strAspPage, strSortedImage, objPreProcessor, strHTMLTemplate
     
    Select Case Form.Grid.Col
        Case 1
            EventArg.HTMLRendered = "<td nowrap class='TableHeader'>&nbsp;</td>"
        Case 2
            EventArg.HTMLRendered = "<td nowrap class='TableHeader' width='1'>&nbsp;</td>"
            
        Case Else
            Set objPreProcessor =   mdm_CreateObject(CPreProcessor)
                            
            EventArg.HTMLRendered =  EventArg.HTMLRendered & "<td nowrap Class='TableHeader'>"
            
            ' Select the image for the sort
            Select Case Form.Grid.SelectedProperty.Sorted
            
                Case MTSORT_ORDER_NONE      :   strSortedImage  = Empty
                Case MTSORT_ORDER_ASCENDING :   strSortedImage  = MDM_PRODUCT_VIEW_TOOL_BAR_SORT_ASC_HTTP_FILE_NAME
                Case MTSORT_ORDER_DECENDING :   strSortedImage  = MDM_PRODUCT_VIEW_TOOL_BAR_SORT_DEC_HTTP_FILE_NAME
            End Select
                        
            objPreProcessor.Add "ASP_PAGE"          ,   request.serverVariables("URL") ' Populate the PreProcessor
            objPreProcessor.Add "IMAGE"             ,   strSortedImage
            objPreProcessor.Add "PROPERTY_NAME"     ,   Server.URLEncode(Form.Grid.SelectedProperty.Name)
            'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
            'Updated HTML encoding.            
            objPreProcessor.Add "PROPERTY_CAPTION"  ,   SafeForHtml(Form.Grid.SelectedProperty.Caption)
            objPreProcessor.Add "PAGE_INDEX"        ,   SafeForHtml(Form.Page.Index)
            
            If(ProductView.Properties.RowsetSupportSort())Then
            
              strHTMLTemplate = "<A Class='TableHeaderA' HREF='[ASP_PAGE]?mdmPageAction=" & MDM_ACTION_SORT & "&mdmSortColumn=[PROPERTY_NAME]'>&nbsp;[PROPERTY_CAPTION]&nbsp;</A>"
              If(Len(strSortedImage))Then ' If we are dealing with the sorted column, we know it because the image was set strSortedImage
                strHTMLTemplate = strHTMLTemplate & "<A HREF='[ASP_PAGE]?mdmPageAction=" & MDM_ACTION_REVERSESORT & "&mdmPageIndex=[PAGE_INDEX]'><IMG Border=0 Src=[IMAGE]></A>"
              End If
            
            Else                                
                strHTMLTemplate =  strHTMLTemplate & "&nbsp;[PROPERTY_CAPTION]&nbsp;" ' Sort not supported
            End If            
            EventArg.HTMLRendered =  EventArg.HTMLRendered & objPreProcessor.Process(strHTMLTemplate)
            EventArg.HTMLRendered =  EventArg.HTMLRendered & "</td>"
    End Select
    inheritedForm_DisplayHeaderCell = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION inheritedForm_DisplayCell(EventArg) ' As Boolean
    
    Dim strSelectorHTMLCode
    Dim strValue, strTDHTMLAttributeName, strImageHTMLAttributeName
    Dim strCurrency    
    Dim strImage, strPageAction    
    Dim strFormat
    
    ' Get the MSIXProperty object
    
    strTDHTMLAttributeName     = "Reserved(" & Form.Grid.Row & "," & Form.Grid.Col & ")"
    strImageHTMLAttributeName  = "TurnDown(" & Form.Grid.Row & ")"
    EventArg.HTMLRendered      = ""
    
    Select Case Form.Grid.Col
        Case 1
            
            EventArg.HTMLRendered = EventArg.HTMLRendered & "<td name='" & strTDHTMLAttributeName & "' nowrap class='" & Form.Grid.CellClass & "' width=20>&nbsp;</td>"
        
        Case 2
            If(Form.Grid.TurnDowns.Exist("R" & Form.Grid.Row))Then
            
                strImage            = MDM_PRODUCT_VIEW_TOOL_BAR_TURN_DOWN_HTTP_FILE_NAME
                strPageAction       = MDM_ACTION_TURN_RIGHT
            Else
                strImage            = MDM_PRODUCT_VIEW_TOOL_BAR_TURN_RIGHT_HTTP_FILE_NAME
                strPageAction       = MDM_ACTION_TURN_DOWN
            End If
            
            EventArg.HTMLRendered = EventArg.HTMLRendered  & "<td name='" & strTDHTMLAttributeName & "' nowrap class='" & Form.Grid.CellClass & "' width=10><A href='" & request.serverVariables("URL")  & "?mdmPageAction=" & strPageAction & "&mdmRowIndex=" & Form.Grid.Row & "&mdmFormUniqueKey=" & mdm_GetDictionary().Item("MDM_FORM_UNIQUE_KEY").Value & "'><img alt='" & MDM_PRODUCT_VIEW_TOOL_BAR_TURN_DOWN_TOOL_TIP & "' name='" & strImageHTMLAttributeName &  "' src='" & strImage & "' Border='0'></a></td>"
                        
        Case Else
                
            strTDHTMLAttributeName = Form.Grid.SelectedProperty.Name  & "(" & Form.Grid.Row & ")"
            

            If(Form.Grid.SelectRowMode)Then ' User can select a row
        
                EventArg.HTMLRendered =  EventArg.HTMLRendered  & "<td name='" & strTDHTMLAttributeName & "' class='" & Form.Grid.CellClass & "' align='" & Form.Grid.SelectedProperty.Alignment & "' OnClick='mdm_TDOnClick(this.parentNode,""[IDROW]"",""[LABELID]"");' OnMouseOver='mdm_TDMouseOver(this);' OnMouseOut='mdm_TDMouseOut(this,""[CLASS]"")'; >"
                EventArg.HTMLRendered =  PreProcess(EventArg.HTMLRendered,Array("LABELID",Form.Grid.LabelID,"IDROW",Form.Grid.PropertyID.Value,"CLASS",Form.Grid.CellClass,"CLASS_SELECTED",Form.Grid.CellClass & "Selected"))

            Else            
                EventArg.HTMLRendered =  EventArg.HTMLRendered  & "<td name='" & strTDHTMLAttributeName & "' class='" & Form.Grid.CellClass & "' align='" & Form.Grid.SelectedProperty.Alignment & "' >"
            End If
            
            If(Form.Grid.SelectedProperty.IsEnumType())Then            
                strValue = Form.Grid.SelectedProperty.LocalizedValue
            Else
				strValue = Form.Grid.SelectedProperty.Value
            End If
            
            ' Test if the property has a format assigned, if yes format the value
            strFormat = Form.Grid.SelectedProperty.Format
            If(Len(strFormat))Then            
                strValue = ProductView.Tools.Format(strValue,strFormat) 'CORE-7367
                ' 3.6 - support decimal localization
                'strValue = Service.Tools.Format(strValue, FrameWork.Dictionary())        
            End If
            
            If (Len(strValue)=0) Then strValue = " "
            
            
            If(IsArray(strValue))Then
                strValue=REPLACE(mdm_GetMDMLocalizedError("MDM_ERROR_1017"),"COLUMNS",Form.Grid.SelectedProperty.Name)
            End If
            'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
            'Added HTML encoding.
            EventArg.HTMLRendered =  EventArg.HTMLRendered  &  SafeForHtml(strValue) & "</td>"
    End Select
    inheritedForm_DisplayCell = TRUE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION inheritedForm_DisplayDetailRow(EventArg) ' As Boolean

    Dim objProperty
    Dim strSelectorHTMLCode
    Dim strValue
    Dim strCurrency
    Dim strHTMLAttributeName

    'Set objProperty = ProductView.Properties.Item(Form.Grid.PropertyName)
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td></td><td></td>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<td ColSpan=" & (ProductView.Properties.Count+2) & " width=20>" & vbNewLine
    
    EventArg.HTMLRendered = EventArg.HTMLRendered & "<TABLE  width='100%' border=0 cellpadding=1 cellspacing=0>" & vbNewLine
    
    For Each objProperty In ProductView.Properties
        
        If(UCase(objProperty.Name)<>"MDMINTERVALID") And ((objProperty.Flags And eMSIX_PROPERTY_FLAG_NOT_STORED_IN_ROWSET)=0) Then
        
          If(objProperty.UserVisible)Then
          
              strHTMLAttributeName  = "TurnDown." & objProperty.Name & "(" & Form.Grid.Row & ")"
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<tr>" & vbNewLine
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Class='TableDetailCell' nowrap>" & objProperty.Caption & "</td>" & vbNewLine
              
              'strValue = TRIM("" & objProperty.NonLocalizedValue)
              
              If IsArray(objProperty.Value) Then
                  strValue = MDM_ERROR_1026
              Else
                  'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
                  'Adding HTML Encoding
                  'strValue = TRIM("" & objProperty.Value)
                  strValue = SafeForHtml(TRIM("" & objProperty.Value))
              End If
              If(Len(strValue)=0)Then
                  strValue  = "&nbsp;"
              End If
              EventArg.HTMLRendered = EventArg.HTMLRendered & "<td Name='" & strHTMLAttributeName & "' Class='TableDetailCell' nowrap>" & strValue & " </td>" & vbNewLine
              EventArg.HTMLRendered = EventArg.HTMLRendered & "</tr>" & vbNewLine
          End If
        End If        
    Next
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</TABLE>" & vbNewLine
    EventArg.HTMLRendered = EventArg.HTMLRendered & "</td>" & vbNewLine
    
    inheritedForm_DisplayDetailRow = TRUE
END FUNCTION

PRIVATE FUNCTION inheritedForm_ChangePage(EventArg,lngPreviousPage,lngNewPage) ' As Boolean

    Dim selectIdString

    If Len(ProductView.Properties.Selector.ColumnID) Then
    
        selectIdString = mdm_UIValue("mdmSelectedIDs")
        If(Len(selectIdString)<>0)Then
        'SECENG: CORE-4797 CLONE - MSOL 30262 MetraOffer: Stored cross-site scripting - All output should be properly encoded
        'Adding HTML Encoding
         Dim retVal
		 retVal = Validate(selectIdString, "PatternString.AlphaNumericCommaDelimited")
    
        If(retVal = false) then
           Err.number = 1006
           Err.Description = "An unknown error has occurred. Please have your administrator check the system log, and try again later."
           response.write err.description
           response.end
        End If
      End If

        ProductView.Properties.Selector.SelecteItemsFromCSVString(mdm_UIValue("mdmSelectedIDs"))
        ProductView.Properties.Selector.UnSelecteItemsFromCSVString(mdm_UIValue("mdmUnSelectedIDs"))
    End If
    inheritedForm_ChangePage = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' PUBLIC DEFINITION OF THE EVENTS
' ---------------------------------------------------------------------------------------------------------------------------------------

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 	:
' RETURNS			  :
PRIVATE FUNCTION Form_ChangePage(EventArg,lngPreviousPage,lngNewPage) ' As Boolean
  Form_ChangePage =  inheritedForm_ChangePage(EventArg,lngPreviousPage,lngNewPage)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_DisplayBeginOfPage(EventArg) ' As Boolean
    Form_DisplayBeginOfPage = inheritedForm_DisplayBeginOfPage(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: Form_DisplayEndOfPage 
' PARAMETERS		:
' DESCRIPTION 		: The event Close the TABLE and the FORM
' RETURNS			:
PRIVATE FUNCTION Form_DisplayEndOfPage(EventArg) ' As Boolean
   Form_DisplayEndOfPage = inheritedForm_DisplayEndOfPage(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_DisplayBeginHeader(EventArg) ' As Boolean    
    Form_DisplayBeginHeader = inheritedForm_DisplayBeginHeader(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_DisplayEndHeader(EventArg) ' As Boolean
    Form_DisplayEndHeader = inheritedForm_DisplayEndHeader(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_DisplayBeginRow(EventArg) ' As Boolean
    Form_DisplayBeginRow = inheritedForm_DisplayBeginRow(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_DisplayEndRow(EventArg) ' As Boolean
    Form_DisplayEndRow = inheritedForm_DisplayEndRow(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_DisplayBeginDetailRow(EventArg) ' As Boolean
    Form_DisplayBeginDetailRow = inheritedForm_DisplayBeginDetailRow(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_DisplayEndDetailRow(EventArg) ' As Boolean
    Form_DisplayEndDetailRow = inheritedForm_DisplayEndDetailRow(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_DisplayDetailRow(EventArg) ' As Boolean
    Form_DisplayDetailRow = inheritedForm_DisplayDetailRow(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_DisplayHeaderCell(EventArg) ' As Boolean
    Form_DisplayHeaderCell = inheritedForm_DisplayHeaderCell(EventArg)
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_DisplayCell(EventArg) ' As Boolean
    Form_DisplayCell = inheritedForm_DisplayCell(EventArg)
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_Export(EventArg) ' As Boolean
    Form_Export = inheritedForm_Export(EventArg)
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			:
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Form_LoadProductView(EventArg) ' As Boolean
    Err.Raise 1014,mdm_GetMDMLocalizedError("MDM_ERROR_1014"),mdm_GetMDMLocalizedError("MDM_ERROR_1014")
    Form_LoadProductView = FALSE
END FUNCTION


' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: Filter_Click
' PARAMETERS		:
' DESCRIPTION 		:
' RETURNS			:
PRIVATE FUNCTION Filter_Click(EventArg) ' As Boolean
    Filter_Click = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION 			: Form_DisplayEndOfPageAddSelectButtons
' PARAMETERS		:
' DESCRIPTION 	: Generate the HTML source code for the button Select Page, UnSelect Page, Select All, UnSelect All
'                 MDM 3.5
' RETURNS			  :
PUBLIC FUNCTION Form_DisplayEndOfPageAddSelectButtons(EventArg, strJavaScript, booCloseFormTag) ' As Boolean

    Dim strEndOfPageHTMLCode, strTmp
    
    
    ' -- Add some code at the end of the product view UI
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</TABLE><br>" & vbNewLine

    strTmp = "<br><button name='butSelectPage' Class='clsButtonBlueXLarge' OnClick='mdm_PVBPickerSelectPage(true);return false;'>" & FrameWork.Dictionary.Item("MDM_SELECT_PAGE") & "</button>" & vbNewLine
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp

    ' -- The button Select Page and UnSelect Page trigger a javascript client side event
    strTmp = "<button name='butUnSelectPage' Class='clsButtonBlueXLarge' OnClick='mdm_PVBPickerSelectPage(false);return false;'>" & FrameWork.Dictionary.Item("MDM_UNSELECT_PAGE") & "</button>" & vbNewLine
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
    
    ' -- The button Select All And UnSelect All Trigger a server side event --
    strTmp = "<button name='butMDMSelectAll' Class='clsButtonBlueXLarge' OnClick='mdm_UpdateSelectedIDsAndReDrawDialog(this);return false;'>" & FrameWork.Dictionary.Item("MDM_SELECT_ALL") & "</button>" & vbNewLine
    strEndOfPageHTMLCode = strEndOfPageHTMLCode & strTmp
    
    strTmp = "<button name='butMDMUnSelectAll' Class='clsButtonBlueXLarge' OnClick='mdm_RefreshDialogUserCustom(this,""dummy"");return false;'>" & FrameWork.Dictionary.Item("MDM_UNSELECT_ALL") & "</button><br>" & vbNewLine
    strEndOfPageHTMLCode  = strEndOfPageHTMLCode & strTmp
    
    If(booCloseFormTag)Then

        strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</FORM></BODY>" & vbNewLine
    End If
    
    If(Len(strJavaScript))Then

        strEndOfPageHTMLCode = strEndOfPageHTMLCode & "<SCRIPT>"    & vbNewLine
        strEndOfPageHTMLCode = strEndOfPageHTMLCode & strJavaScript & vbNewLine
        strEndOfPageHTMLCode = strEndOfPageHTMLCode & "</SCRIPT>"   & vbNewLine
    End If
    'strHTML = strHTML & "</body></html>" & vbNewLine
    EventArg.HTMLRendered = strEndOfPageHTMLCode
    
    Form_DisplayEndOfPageAddSelectButtons = TRUE
END FUNCTION

PRIVATE FUNCTION butMDMSelectAll_Click(EventArg)


    If IsValidObject(ProductView.Properties.Rowset) Then 
      If ProductView.Properties.Rowset.RecordCount Then 
          ProductView.Properties.Selector.SelectAllFromRowSet ProductView.Properties.Rowset , ProductView.Properties.Selector.ColumnID    ' Select all item in the rowset
      End If
    End If
    butMDMSelectAll_Click = TRUE
END FUNCTION

PRIVATE FUNCTION butMDMUnSelectAll_Click(EventArg)

    ProductView.Properties.Selector.Clear
    butMDMUnSelectAll_Click = TRUE
END FUNCTION  

%>
