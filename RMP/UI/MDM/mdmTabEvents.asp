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
' NAME		        :   MetraTech Dialog Manager - Tabe  event and rendering
' VERSION	        :   2.0
' CREATION_DATE   :   03/16/2000
' AUTHOR	        :   F.Torres.
' DESCRIPTION	    :   MDM Tabs are for now in stand by
' ----------------------------------------------------------------------------------------------------------------------------------------

PRIVATE FUNCTION mdm_RenderTabs(EventArg,objMDMTabs) ' As Boolean

  Dim objTab,           strHTML,      lngCount,     strHTMLSubTemplate
  Dim objPreProcessor,  strTemplate,  strImagePath, strHTMLTemplate
  Dim objTextFile
  
  strHTMLTemplate     = mdm_GetHTMLTemplateFullName()  
  Set objPreProcessor = mdm_CreateObject(CPreProcessor)
  Set objTextFile     = mdm_CreateObject(CTextFile)
  lngCount            = 0
  
  objPreProcessor.StandardVar
  
  strHTML = "<table width='100%'  border='0' cellpadding='0' cellspacing='0'><tr>" & vbNewLine
  
  strImagePath = "/mdm/internal/images/tabs/AngleTop"
  
  For Each objTab In objMDMTabs
  
      If (objTab.Selected) Then ' Set filename for the contain of the tab
          strHTMLSubTemplate = Mid(strHTMLTemplate, 1, Len(strHTMLTemplate) - 4) & "." & objTab.Key & ".htm"
      End If
  
      objPreProcessor.Add "CAPTION"         , objTab.Caption
      objPreProcessor.Add "KEY"             , objTab.Key
      objPreProcessor.Add "INDEX"           , objTab.Index
      objPreProcessor.Add "TOOLTIP"         , objTab.ToolTipText
      objPreProcessor.Add "SELECTED_CLASS"  , IIf(objTab.Selected, "Selected" , "")
            
      strTemplate = ""
      strTemplate = strTemplate & "<td Class='TabHeader[SELECTED_CLASS]' nowrap><A Class='TabHeaderA' Name='[KEY]' HREF='#' OnClick='mdm_RefreshDialog(""Tabs([INDEX])"");' >[CAPTION]</a></td>[CRLF]"
      
      strHTML = strHTML & objPreProcessor.Process(strTemplate)
  Next
  strHTML = strHTML & "</tr>" & vbNewLine
  strHTML = strHTML & "</table>" & vbNewLine
  
  'strHTML = strHTML & "<tr><td Height=4 class='TabHeaderBar' ColSpan=" & objMDMTabs.Count & ">&nbsp;</td></tr>" & vbNewLine
  'strHTML = strHTML & "<tr><td ColSpan=" & objMDMTabs.Count & "> " & vbNewLine
  strHTML = strHTML & objTextFile.LoadFile(strHTMLSubTemplate)
  'strHTML = strHTML & "</td></tr>" & vbNewLine
  
  
  objMDMTabs.HTMLRendered = strHTML
END FUNCTION
%>