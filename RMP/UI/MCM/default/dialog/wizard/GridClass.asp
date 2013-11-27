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
'  GridClass.asp                                                              '
'  VBScript class to render data grids.                                       '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Public gobjMTGrid

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Class CMTGrid
  'Styles
  Private mstrDivStyle        'Grid div style
  Private mstrTableStyle      'Grid table style
  Private mstrHeaderStyle     'Style for headers
  Private mstrSubHeaderStyle  'Subheader styles
  Private mstrEvenRowStyle    'Even rows style
  Private mstrOddRowStyle     'Style for odd rows
  
  Private mbAlternate         'Indicates that row styles should alternate, if
                              ' false, only even row style is used.
  Private mbOdd               'Indicates if the current row is even or odd
  
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Sub           : Class_Initialize()                                        '
  ' Description   : Class initialization routines.                            '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Sub Class_Initialize()
    mbAlternate = true
    mbOdd       = true
    
    mstrHeaderStyle     = "clsGridHeader"
    mstrSubHeaderStyle  = "clsGridSubHeader"
    mstrEvenRowStyle    = "clsGridRowEven"
    mstrOddRowStyle     = "clsGridRowOdd"
    mstrDivStyle        = "clsGridDiv"
    mstrTableStyle      = "clsGridTableStyle"
  
  End Sub
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : OpenGridDiv()                                           '
  ' Description   : Open a div containing a grid table.                     '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function OpenGridDiv(arrHeaderData, strDivOther, strTableName, strTableOther, arrSizeData, arrColspanData, arrAlignData)
    Dim strHTML
    
    strHTML = strHTML & OpenGridTable(arrHeaderData, _
                                      strTableName &  "_Header", _
                                      strTableOther, _
                                      true, _
                                      arrSizeData, _
                                      arrColspanData, _
                                      arrAlignData)
                                      
    strHTML = strHTML & CloseGridTable()
    strHTML = strHTML & "   <div class=""" & mstrDivStyle & """" & strDivOther & ">" & vbNewline
    strHTML = strHTML & OpenGridTable("", _
                                      strTableName, _
                                      strTableOther, _
                                      false, _
                                      arrSizeData, _
                                      arrColspanData, _
                                      arrAlignData)

    OpenGridDiv = strHTML
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      :CloseGridDiv()                                           '
  ' Description   : Close the div containing a grid table.                  '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function CloseGridDiv()
    Dim strHTML
    
    strHTML = strHTML & "     </table>" & vbNewline
    strHTML = strHTML & "     </div>" & vbNewline
    
    CloseGridDiv = strHTML
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : OpenGridTable()                                         '
  ' Description   : Open a data grid table                                  '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function OpenGridTable(arrHeaderData, strName, strOther, bSpace, arrSizeData, arrColspanData, arrAlignData)
    Dim strHTML
    Dim strSize
    Dim strWidth
    Dim strSpan
    Dim strAlign
    Dim i

    strHTML = strHTML & "   <table id=""" & strName & """ class=""" & mstrTableStyle & """" & strOther & " width=""100%"">" & vbNewline


    if isarray(arrHeaderData) then
      strSize = GetSpacing(UBound(arrHeaderData))
      
      strHTML = strHTML & "     <tr>" & vbNewline
  
      for i = 0 to Ubound(arrHeaderData)
        
       
        'Check for spacing
        if bSpace then
          strWidth = " width=""" & strSize & """"
        else
          strWidth = ""
        end if
        
        'Set the cell widths
        if isarray(arrSizeData) then
          if UBound(arrSizeData) >= i then
            if len(arrSizeData(i)) > 0 then
              strWidth = " width=""" & arrSizeData(i) & """"
            end if
          end if
        end if
            
        strSpan = ""
        
        'Set the colspan
        if isarray(arrColspanData) then
          if UBound(arrColspanData) >= i then
            if len(arrColspanData(i)) > 0 then
              strSpan = " colspan=""" & arrColspanData(i) & """"
            end if
          end if
        end if
        
        'Set the Alignment
        strAlign = " align=""center"""

        if isArray(arrAlignData) then
          if UBound(arrAlignData) >= i then
            if len(arrAlignData(i)) > 0 then
              strAlign = " align=""" & arrAlignData(i) & """"
            end if
          end if
        end if
        
        
        'Render the row
        strHTML = strHTML & "       <td class=""" & mstrHeaderStyle & """" & strWidth & strAlign & strSpan & ">" & arrHeaderData(i) & "</td>" & vbNewline
        
      next
    
      strHTML = strHTML & "     </tr>" & vbNewline
    end if
  
    OpenGridTable = strHTML
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : CloseGridTable()                                        '
  ' Description   : Close the grid table.                                   '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function CloseGridTable()
    Dim strHTML
    
    strHTML = strHTML & "   </table>" & vbNewline
  
    CloseGridTable = strHTML
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : WriteSubHeaderRow(arrSubHeaderData, arrColspans)        '
  ' Description   : Write a row of subheader data.  For each element in the '
  '               : data array, the array of colpans should contain an      '
  '               : element to set the column span for the subheader        '
  '               : element.                                                '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function AddSubHeaderRow(arrSubHeaderData, arrColspans)
    Dim strHTML
    Dim i
    
    strHTML = strHTML & "      <tr>" & vbNewline
    
    for i = 0 to UBound(arrSubHeaderData)
      if isArray(arrColpans) then
        strHTML = strHTML & "       <td colspan=""" & arrColspans(i) & """ class=""" & mstrSubHeaderStyle & """>" & arrSubHeaderData(i) & "</td>" & vbNewline
      else
        strHTML = strHTML & "       <td class=""" & mstrSubHeaderStyle & """>" & arrSubHeaderData(i) & "</td>" & vbNewline    
      end if
    next
  
    strHTML = strHTML & "     </tr>" & vbNewline
  
    AddSubHeaderRow = strHTML
  End Function 
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : WriteGridRow(arrRowData)                                '
  ' Description   : Write a row of grid data. strData is a string           '
  '               : containing information about how to render the data.    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function AddGridRow(arrRowData, strData, bSpace, arrSizeData, arrColspanData, arrAlignData)
    Dim strHTML
    Dim strClass
    Dim strAlign
    Dim bAlignDecimals
    Dim bPadDecimals
    Dim bAddCommas
    Dim intNumPlaces
    Dim intTemp
    Dim strSpaceWidth     'Width of evenly-spaced columns
    Dim strWidth
    Dim strSpan
    Dim i, j
    
    'Initialize
    bAlignDecimals = false
    bPadDecimals = false
    intNumPlaces = 0
    
    
    'Add the row
    strHTML = strHTML & "       <tr>" & vbNewline
    
    if mbOdd and mbAlternate then
      strClass = mstrOddRowStyle
    else
      strClass = mstrEvenRowStyle
    end if
    
    mbOdd = not mbOdd


    'Check for input parameters
'    arrRowData = FormatData(arrRowData, strData)
	Call FormatData(arrRowData, strData)
	    
    'Get spacing
    strSpaceWidth = GetSpacing(UBound(arrRowData))

    
    'Output the data
    for i = 0 to UBound(arrRowData)

      'Set the default alignment
      if IsNumeric(arrRowData(i)) then
        strAlign = "right"
      else
        strAlign = "left"
      end if
      
      'Get any custom alignment data to override
      if isArray(arrAlignData) then
        if i <= Ubound(arrAlignData) then
          if len(arrAlignData(i)) > 0 then
            strAlign = arrAlignData(i)
          end if
        end if
      end if
      
      'Set any even space width
      if bSpace then
        strWidth = " width=""" & strSpaceWidth & """"
      else
        strWidth = ""
      end if
      
      'Get any custom size data to override
      if isArray(arrSizeData) then
        if i <= UBound(arrSizeData) then
          if len(arrSizeData(i)) > 0 then
            strWidth = " width=""" & arrSizeData(i) & """"
          end if
        end if
      end if
      
      'Get any colspan data
      strSpan = ""
      
      if isArray(arrColspanData) then
        if i <= Ubound(arrColspanData) then
          if len(arrColspanData(i)) > 0 then
            strSpan = " colspan=""" & arrColspanData(i) & """"
          end if
        end if
      end if
      

      ' write the cell
      strHTML = strHTML & "       <td class=""" & strClass & """" & strWidth & " align=""" & strAlign & """" & strSpan & ">" & arrRowData(i) & "</td>" & vbNewline      
    next
  
    strHTML = strHTML & "     </tr>" & vbNewline
  
    AddGridRow = strHTML
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function        : FormatData(...)                                       '
  ' Description     : Format the data to the given specificiations.         '
  ' Inputs          : arrData -- Data to format.                            '
  '                 : strFormat -- String to specify the format.            '
  ' Outputs         : Array of formatted data.                              '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function FormatData(arrData, strFormat)
    Dim bAlignDecimals
    Dim bPadDecimals
    Dim bAddCommas
    Dim intNumPlaces
    Dim intTemp

    strFormat = UCase(strFormat)
   
    'Check to see how decimals should be aligned    
    if instr(strFormat, "ALIGN_DECIMALS") > 0 then
      bAlignDecimals = true
      intTemp = instr(strFormat, "ALIGN_DECIMALS=") + len("ALIGN_DECIMAL=")
      intNumPlaces = CLng(mid(strFormat, intTemp, instr(strFormat, ";") - intTemp))
    end if
    
    'Check if decimals should be  padded
    if instr(strFormat, "PAD_DECIMALS") > 0 then
      bPadDecimals = true
    end if      

    'Format the data
    if bAddCommas or bPadDecimals then
      for i = 0 to UBound(arrData)
        
        'Check if decimals should be aligned
        if bAlignDecimals then
          'Aligned by padding zeros, or by spaces
          if bPadDecimals then
            arrData(i) = formatNumber(arrData(i), intNumPlaces, -1, 0, -1)
          else
            for j = 0 to intNumPlaces
              arrData(i) = arrData(i) & " "
            next
          end if
        end if
      next
    end if      
  
'    FormatData = arrData
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : GetSpacing(..)                                            '
  ' Description : Given a number of cells per row, get the width of each    '
  '             : cell (%) for even spacing.                                '
  ' Inputs      : intNumColumns -- Number of columns per row.               '
  ' Outputs     : string specifying column width.                           '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function GetSpacing(intNumColumns)
    
    'Set the sizes
    if intNumColumns > 0 then
      GetSpacing = CStr(CLng(100 / intNumColumns)) & "%"
    else
      GetSpacing = "100%"
    end if  
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  'Header Style
  Public Property Let HeaderStyle(strStyle)
    mstrHeaderStyle = strStyle
  End Property
  
  Public Property Get HeaderStyle()
    HeaderStyle = mstrHeaderStyle
  End Property  

  'SubHeader Style
  Public Property Let SubHeaderStyle(strStyle)
    mstrSubHeaderStyle = strStyle
  End Property
  
  Public Property Get SubHeaderStyle()
    SubHeaderStyle = mstrSubHeaderStyle
  End Property  

  'OddRow Style
  Public Property Let OddRowStyle(strStyle)
    mstrOddRowStyle = strStyle
  End Property
  
  Public Property Get OddRowStyle()
    OddRowStyle = mstrOddRowStyle
  End Property  

  'EvenRow Style
  Public Property Let EvenRowStyle(strStyle)
    mstrEvenRowStyle = strStyle
  End Property
  
  Public Property Get EvenRowStyle()
    EvenRowStyle = mstrEvenRowStyle
  End Property  

  'DivStyle Style
  Public Property Let DivStyle(strStyle)
    mstrDivStyle = strStyle
  End Property
  
  Public Property Get DivStyle()
    DivStyle = mstrDivStyle
  End Property  
  
  'TableStyle Style
  Public Property Let TableStyle(strStyle)
    mstrTableStyle = strStyle
  End Property
  
  Public Property Get TableStyle()
    TableStyle = mstrTableStyle
  End Property 
   
  'Alternate Styles
  Public Property Let AlternateStyles(bAlternate)
    mbAlternate = bAlternate
  End Property
  
  Public Property Get AlternateStyles()
    AlternateStyles = mbAlternate
  End Property  

End Class
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


Set gobjMTGrid = new CMTGrid


%>