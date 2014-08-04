<%
' //==========================================================================
' // @doc $Workfile: D:\source\development\UI\MTAdmin\us\checkIn.asp$
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
' // $Date: 5/11/00 11:51:14 AM$
' // $Author: Noah Cushing$
' // $Revision: 6$
' //==========================================================================

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' TabsClass.asp                                                            '
'   Routines used to render tab dialogs                                    '
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Public gobjMTTabs

Const g_int_TAB_TOP      = 0
Const g_int_TAB_BOTTOM   = 1

Class CMTTabs
  'Private data members
  Private mstrLeftCap                     ' Left cap of the tabs
  Private mstrRightCap                    ' Right cap of the tabs
  Private mstrLeftCapSelected             ' Left cap for case where leftmost tab is selected
  Private mstrRightCapSelected            ' Right cap for case where rightmost tab is selected
  Private mstrMidCap                      ' Middle image, between two unselected tabs
  Private mstrMidCapRightSelected         ' Middle image, right tab is selected.
  Private mstrMidCapLeftSelected          ' Middle image, left tab is selected
  Private mstrTabLine                     ' Background for unselected items.
  Private mstrTabLineUnselected
  Private mstrTabEnd
  
  Private mintTabCount                    ' Number of tabs to render

  Private mstrImageTabClass               ' css style for the image-only tabs
  Private mstrTabClass                    ' css style for the unselected tabs
  Private mstrSelectedTabClass            ' css style for the chosen tabs
  Private mstrTabLinkUnsel                ' css style for unselected tabs
   Private mstrTabLinkSel                ' css style for Selected tabs
 
  Private mintCurTab                      ' the current tab
  
  'Data for the tabs
  Private marrLinks                       ' Variant containing an array of links.	Not defined as an array because of a VBScript 5.1 bugs. See function AddTab().
  Private marrCaptions                    ' Variant containing an array of captions.Not defined as an array because of a VBScript 5.1 bugs. See function AddTab().


  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Sub           : Class_Initialize()                                       '
  ' Description   : Initialize the class.                                    '
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Sub Class_Initialize()
    'Initialize the tab count
    mintTabCount = 0
    
    mintCurTab = 0
    
    'Set the default classes and images
    mstrLeftCap             = "" 'FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/tabs/Page/AngleTop/left_cap.gif"
    mstrRightCap            = "" 'FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/tabs/Page/AngleTop/right_cap.gif"
    mstrLeftCapSelected     =  "" 'FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/tabs/Page/AngleTop/left_cap_selected.gif"
    mstrRightCapSelected    = "" 'FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/tabs/Page/AngleTop/right_cap_selected.gif"
    mstrMidCap              = "" 'FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/tabs/Page/AngleTop/mid_cap.gif"
    mstrMidCapRightSelected = "" 'FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/tabs/Page/AngleTop/mid_cap_right_selected.gif"
    mstrMidCapLeftSelected  = "" 'FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/tabs/Page/AngleTop/mid_cap_left_selected.gif"
    mstrTabLine             = FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/tabs/Page/AngleTop/line.gif"
    mstrTabLineUnselected   = FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/tabs/Page/AngleTop/lineunselected.gif"
    mstrTabEnd              = FrameWork.GetDictionary("DEFAULT_LOCALIZED_PATH") & "/images/tabs/Page/AngleTop/end.gif"
        
    mstrImageTabClass     = "clsTabAngleTopImage"
    mstrTabClass          = "clsTabAngleTopUnselected"
    mstrSelectedTabClass  = "clsTabAngleTopSelected"
    mstrTabLinkUnsel      = "clsTabAngleTopLinkUnsel"  
	mstrTabLinkSel      = "clsTabAngleTopLinkSel"  	
  End Sub
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : AddTab(strCaption, strLink)                                 '
  ' Description : Add a tab to be rendered by the class.                      '
  ' Inputs      : strCaption  --  Caption for the tab.                        '
  ' Outputs     : strLink     --  Link for the tab.                           '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function AddTab(strCaption, strLink)
    
	'
	' Old code, this code does not work with VBScript 5.1, there is a bug with class member defined as an array
	' actually they are not, so redim preserve fail. See below for the solution
	'
    'redim preserve marrLinks(mintTabCount)
    'marrLinks(mintTabCount) = strLink
	'    
    'redim preserve marrCaptions(mintTabCount)
    'marrCaptions(mintTabCount) = strCaption
	'
	'mintTabCount = mintTabCount + 1
	

	'
	' Solution : 
	'
	'		1 - marrLinks and marrCaptions are not more array but variant containing array.
	'		2 - This function use temporary array to do the redim preserve. Of course we hae
	'			to copy the data back and forth.
	'
	Dim arrTmpLinks(), arrTmpCaptions() ' Declare my 2 temp array, here they even not allocated
	Dim i, lngArraySize

	lngArraySize = GetArraySize(marrLinks) ' Get how many item we already have. If none the function return -1, because the 0 item is a valid item i vbscript array.

	ReDim arrTmpLinks(lngArraySize)		' Allocate room in the temp array
	ReDim arrTmpCaptions(lngArraySize)

	If(lngArraySize<>-1)Then		' if we had items, copy them to the temporary array. 
									' Unfortunately VBScript does not know how to copy a Variant containing an array into an array
									' so we do it our self!
		For i=0 To lngArraySize		
			arrTmpLinks(i)		= marrLinks(i)
			arrTmpCaptions(i)	= marrCaptions(i)
		Next		
	End If
    
	redim preserve arrTmpLinks   (mintTabCount)		' Do the redim preserve
	redim preserve arrTmpCaptions(mintTabCount)
	
	arrTmpLinks	  (mintTabCount) = strLink			' Set the new link and name in the temp array
	arrTmpCaptions(mintTabCount) = strCaption

	marrLinks					 = arrTmpLinks		' Copy the data in the local array. Fortunately VBScript know how to copy am array into a Variant. 
	marrCaptions				 = arrTmpCaptions

    mintTabCount = mintTabCount + 1
  
  End Function

  Private Function GetArraySize(arrArr)
	On Error Resume Next
	GetArraySize = UBound(arrArr)
	If(Err.Number)Then
		GetArraySize=-1
		Err.Clear
	End If
  End Function
	




  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function    : DrawTabMenu()                                               '
  ' Description : Draw a tab menu based on the user's inputs.                 '
  ' Inputs      : intTabType      --  Specify the type of tab to use.         '
  ' Outputs     : HTML for the tab menu.                                      '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Function DrawTabMenu(intTabType)
    Dim strHTML           'HTML to return
    
    strHTML = strHTML & "  <table cellspacing=""0"" cellpadding=""0"">" & vbNewline
    strHTML = strHTML & "    <tr>" & vbNewline
  
    if mintTabCount > 0 then
      select case intTabType
        Case g_int_TAB_TOP
          strHTML = strHTML & DrawTopTabs()
      end select
    else
      strHTML = strHTML & " <td>An error occurred in DrawTabMenu(): No tabs to render!</td>" & vbNewline
    end if
    
    strHTML = strHTML & "    </tr>" & vbNewline
    strHTML = strHTML & "  </table>" & vbNewline
  
    DrawTabMenu = strHTML
  End Function
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  ' Function      : DrawTopTabs()                                           '
  ' Description   : Draw tabs at the top.                                   '
  ' Inputs        : none                                                    '
  ' Outputs       : none                                                    '
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Private Function DrawTopTabs()
    Dim strHTML         'HTML to return
    Dim i               'Counter
    
    ''''''''''''''''''''''''''''''''''''''''''''''
    ' Write the tabs that contain text

    ' Make a little space before the first tab starts
    strHTML = strHTML & "  <td background=""" & mstrTabEnd & """ class=""" & mstrImageTabClass & """ width=""5"" nowrap></td>" & vbNewline
    

  
    for i = 0 to mintTabCount - 1
      'If this tab is the chosen one
      if mintCurTab = i then
      strHTML = strHTML & "  <td  valign=""center"" class=""" & mstrSelectedTabClass & """ nowrap>&nbsp;<a name='aTAB" & (i+1) & "' class=""" & mstrTabLinkSel & """ href=""" & marrLinks(i) & """>" & marrCaptions(i) & "</a>&nbsp;</td>" & vbNewline
       
  
      else
        ' zizi
        strHTML = strHTML & "  <td background=""" & mstrTabLineUnselected & """ valign=""center"" class=""" & mstrTabClass & """ nowrap>&nbsp;<a name='aTAB" & (i+1) & "' class=""" & mstrTabLinkUnsel & """ href=""" & marrLinks(i) & """>" & marrCaptions(i) & "</a>&nbsp;</td>" & vbNewline
        
      
      end if
    next
    
    strHTML = strHTML & "  <td background=""" & mstrTabEnd & """ class=""" & mstrImageTabClass & """ width=""100%"" nowrap></td>" & vbNewline
    ''''''''''''''''''''''''''''''''''''''''''''''
    
    DrawTopTabs = strHTML
    
  End Function  
  
  
  
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  Public Property Get Tab()
    Tab = mintCurTab
  End Property
  
  Public Property Let Tab(intTab)
    mintCurTab = intTab
  End Property
  
  
End Class

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Create the object                                                          '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Set gobjMTTabs = new CMTTabs  

%>

