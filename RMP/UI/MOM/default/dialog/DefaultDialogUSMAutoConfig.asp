<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile$
' 
'  Copyright 1998-2003 by MetraTech Corporation
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
'  Created by: Rudi
' 
'  $Date$
'  $Author$
'  $Revision$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<%

' Mandatory
Form.RouteTo			              = mom_GetDictionary("USM_AUTO_CONFIG_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

  Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
							
  Service.Properties.Add "CloseEnabled", MSIXDEF_TYPE_BOOLEAN, 0, FALSE, Empty
  Service.Properties.Add "RunEnabled", MSIXDEF_TYPE_BOOLEAN, 0, FALSE, Empty

  dim strConfigFile
	strConfigFile = Session("INSTALL_DIR") & "Config\UsageServer\usm_daily.xml"

  dim objXMLDoc
  Set objXMLDoc = GetUSMConfigFileXMLDOM(strConfigFile)
  
  if ucase(objXMLDoc.SelectSingleNode("//option[.='Close']").attributes.getNamedItem("enabled").value) = "FALSE" Then
  	Service.Properties("CloseEnabled")=false
  else
  	Service.Properties("CloseEnabled")=true
  end if

  if ucase(objXMLDoc.SelectSingleNode("//option[.='Run']").attributes.getNamedItem("enabled").value) = "FALSE" Then
  	Service.Properties("RunEnabled")=false
  else
  	Service.Properties("RunEnabled")=true
  end if
           
  ' We only accept the following chars
  Service.LoadJavaScriptCode  
  
  Form_Initialize = TRUE
END FUNCTION

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  OK_Click
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION OK_Click(EventArg) ' As Boolean

  On Error Resume Next
 
  dim strConfigFile
	strConfigFile = Session("INSTALL_DIR") & "Config\UsageServer\usm_daily.xml"

  dim objXMLDoc
  Set objXMLDoc = GetUSMConfigFileXMLDOM(strConfigFile)
  
  if Service.Properties("CloseEnabled") then
    objXMLDoc.SelectSingleNode("//option[.='Close']").attributes.getNamedItem("enabled").value = "TRUE"
  else
    objXMLDoc.SelectSingleNode("//option[.='Close']").attributes.getNamedItem("enabled").value = "FALSE"
  end if

  if Service.Properties("RunEnabled") then
    objXMLDoc.SelectSingleNode("//option[.='Run']").attributes.getNamedItem("enabled").value = "TRUE"
  else
    objXMLDoc.SelectSingleNode("//option[.='Run']").attributes.getNamedItem("enabled").value = "FALSE"
  end if
  
  objXMLDoc.Save(strConfigFile)

  If(Err.Number)Then
    
      EventArg.Error.Save Err
      OK_Click = FALSE
      Err.Clear
  Else
        OK_Click = TRUE        
  End If
END FUNCTION


Function GetUSMConfigFileXMLDOM(strFilePath)

	dim objXMLDoc
	Set objXMLDoc = server.CreateObject("Microsoft.XMLDOM")
	
	'Helpful things to do
	'Turn of asynchronous operation
	objXMLDoc.async = false
	
	'Turn of DTD validation
	objXMLDoc.validateOnParse = false
	
	'Don't resolve external DTD's, etc.
	objXMLDoc.resolveExternals = false
	
  objXMLDoc.preserveWhitespace = true
  
	objXMLDoc.Load(strFilePath)

	set GetUSMConfigFileXMLDOM = objXMLDoc
end function

%>


