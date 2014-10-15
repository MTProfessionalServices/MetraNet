<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: DefaultDialogUSMAutoConfig.asp$
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
'  $Date: 10/17/2002 3:44:35 PM$
'  $Author: Rudi Perkins$
'  $Revision: 2$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<%

' Mandatory
Form.RouteTo			              = mom_GetDictionary("USM_SERVICE_CONFIG_DIALOG")

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean

  Framework.AssertCourseCapability "Manage Scheduled Adapters", EventArg

  Service.Clear 	' Set all the property of the service to empty. 
					        ' The Product view if allocated is cleared too.
							
  Service.Properties.Add "CloseEnabled", MSIXDEF_TYPE_BOOLEAN, 0, FALSE, Empty
  Service.Properties.Add "BlockNewAccountsWhenCloseEnabled", MSIXDEF_TYPE_BOOLEAN, 0, FALSE, Empty

  Service.Properties.Add "RunEnabled", MSIXDEF_TYPE_BOOLEAN, 0, FALSE, Empty
  Service.Properties.Add "RunScheduledEnabled", MSIXDEF_TYPE_BOOLEAN, 0, FALSE, Empty

  Service.Properties.Add "GracePeriod_Daily", MSIXDEF_TYPE_INT32, 0, FALSE, Empty
  Service.Properties.Add "GracePeriod_Weekly", MSIXDEF_TYPE_INT32, 0, FALSE, Empty
  Service.Properties.Add "GracePeriod_Bi-weekly", MSIXDEF_TYPE_INT32, 0, FALSE, Empty
  Service.Properties.Add "GracePeriod_Semi-monthly", MSIXDEF_TYPE_INT32, 0, FALSE, Empty
  Service.Properties.Add "GracePeriod_Monthly", MSIXDEF_TYPE_INT32, 0, FALSE, Empty
  Service.Properties.Add "GracePeriod_Quarterly", MSIXDEF_TYPE_INT32, 0, FALSE, Empty
  Service.Properties.Add "GracePeriod_Annually", MSIXDEF_TYPE_INT32, 0, FALSE, Empty

  Service.Properties.Add "GracePeriod_Daily_Enabled", MSIXDEF_TYPE_BOOLEAN, 0, FALSE, Empty
  Service.Properties.Add "GracePeriod_Weekly_Enabled", MSIXDEF_TYPE_BOOLEAN, 0, FALSE, Empty
  Service.Properties.Add "GracePeriod_Bi-weekly_Enabled", MSIXDEF_TYPE_BOOLEAN, 0, FALSE, Empty
  Service.Properties.Add "GracePeriod_Semi-monthly_Enabled", MSIXDEF_TYPE_BOOLEAN, 0, FALSE, Empty
  Service.Properties.Add "GracePeriod_Monthly_Enabled", MSIXDEF_TYPE_BOOLEAN, 0, FALSE, Empty
  Service.Properties.Add "GracePeriod_Quarterly_Enabled", MSIXDEF_TYPE_BOOLEAN, 0, FALSE, Empty
  Service.Properties.Add "GracePeriod_Annually_Enabled", MSIXDEF_TYPE_BOOLEAN, 0, FALSE, Empty

  dim strConfigFile
	strConfigFile = Session("INSTALL_DIR") & "Config\UsageServer\usageserver.xml"

  dim objXMLDoc
  Set objXMLDoc = GetUSMConfigFileXMLDOM(strConfigFile)
  
'  if ucase(objXMLDoc.SelectSingleNode("//option[.='Close']").attributes.getNamedItem("enabled").value) = "FALSE" Then
  dim objNode
  set objNode=objXMLDoc.SelectSingleNode("//Service/SoftCloseIntervals")
  if ucase(objNode.nodeTypedValue) = "FALSE" Then
  	Service.Properties("CloseEnabled")=false
  else
  	Service.Properties("CloseEnabled")=true
  end if
  if ucase(objNode.attributes.getNamedItem("blockNewAccounts").value) = "FALSE" Then
  	Service.Properties("BlockNewAccountsWhenCloseEnabled")=false
  else
  	Service.Properties("BlockNewAccountsWhenCloseEnabled")=true
  end if
  
  GetConfigFileGracePeriodSetting objXMLDoc, "Daily"
  GetConfigFileGracePeriodSetting objXMLDoc, "Weekly"
  GetConfigFileGracePeriodSetting objXMLDoc, "Bi-weekly"
  GetConfigFileGracePeriodSetting objXMLDoc, "Semi-monthly"
  GetConfigFileGracePeriodSetting objXMLDoc, "Monthly"
  GetConfigFileGracePeriodSetting objXMLDoc, "Quarterly"
  GetConfigFileGracePeriodSetting objXMLDoc, "Annually"
  
 	Service.Properties("GracePeriod_Weekly")=objXMLDoc.SelectSingleNode("//Intervals/GracePeriods/Weekly").nodeTypedValue
 	Service.Properties("GracePeriod_Bi-weekly")=objXMLDoc.SelectSingleNode("//Intervals/GracePeriods/Bi-weekly").nodeTypedValue
 	Service.Properties("GracePeriod_Semi-monthly")=objXMLDoc.SelectSingleNode("//Intervals/GracePeriods/Semi-monthly").nodeTypedValue
 	Service.Properties("GracePeriod_Monthly")=objXMLDoc.SelectSingleNode("//Intervals/GracePeriods/Monthly").nodeTypedValue
 	Service.Properties("GracePeriod_Quarterly")=objXMLDoc.SelectSingleNode("//Intervals/GracePeriods/Quarterly").nodeTypedValue
 	Service.Properties("GracePeriod_Annually")=objXMLDoc.SelectSingleNode("//Intervals/GracePeriods/Annually").nodeTypedValue
  
  if ucase(objXMLDoc.SelectSingleNode("//Service/SubmitEventsForExecution").nodeTypedValue) = "FALSE" Then
  	Service.Properties("RunEnabled")=false
  else
  	Service.Properties("RunEnabled")=true
  end if

  if ucase(objXMLDoc.SelectSingleNode("//Service/InstantiateScheduledEvents").nodeTypedValue) = "FALSE" Then
  	Service.Properties("RunScheduledEnabled")=false
  else
  	Service.Properties("RunScheduledEnabled")=true
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
	strConfigFile = Session("INSTALL_DIR") & "Config\UsageServer\usageserver.xml"

  dim objXMLDoc
  Set objXMLDoc = GetUSMConfigFileXMLDOM(strConfigFile)

  dim objNode
  set objNode=objXMLDoc.SelectSingleNode("//Service/SoftCloseIntervals")
  if Service.Properties("CloseEnabled") then
    objNode.nodeTypedValue = "TRUE"
  else
    objNode.nodeTypedValue = "FALSE"
  end if
  
  if Service.Properties("BlockNewAccountsWhenCloseEnabled") then
    objNode.attributes.getNamedItem("blockNewAccounts").value = "TRUE"
  else
    objNode.attributes.getNamedItem("blockNewAccounts").value = "FALSE"
  end if
  


  SetConfigFileGracePeriodSetting objXMLDoc, "Daily"
  SetConfigFileGracePeriodSetting objXMLDoc, "Weekly"
  SetConfigFileGracePeriodSetting objXMLDoc, "Bi-weekly"
  SetConfigFileGracePeriodSetting objXMLDoc, "Semi-monthly"
  SetConfigFileGracePeriodSetting objXMLDoc, "Monthly"
  SetConfigFileGracePeriodSetting objXMLDoc, "Quarterly"
  SetConfigFileGracePeriodSetting objXMLDoc, "Annually"
  
  if Service.Properties("RunEnabled") then
    objXMLDoc.SelectSingleNode("//Service/SubmitEventsForExecution").nodeTypedValue = "TRUE"
  else
    objXMLDoc.SelectSingleNode("//Service/SubmitEventsForExecution").nodeTypedValue = "FALSE"
  end if

  if Service.Properties("RunScheduledEnabled") then
    objXMLDoc.SelectSingleNode("//Service/InstantiateScheduledEvents").nodeTypedValue = "TRUE"
  else
    objXMLDoc.SelectSingleNode("//Service/InstantiateScheduledEvents").nodeTypedValue = "FALSE"
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

Function GetConfigFileGracePeriodSetting(objXMLDoc,strName)

  dim objNode
  set objNode=objXMLDoc.SelectSingleNode("//Intervals/GracePeriods/" & strName)
 	Service.Properties("GracePeriod_" & strName)=objNode.nodeTypedValue
  if ucase(objNode.attributes.getNamedItem("enabled").value) = "FALSE" Then
  	Service.Properties("GracePeriod_" & strName & "_Enabled")=false
  else
  	Service.Properties("GracePeriod_" & strName & "_Enabled")=true
  end if
 
  GetConfigFileGracePeriodSetting = true
end function

Function SetConfigFileGracePeriodSetting(objXMLDoc,strName)

  dim objNode
  set objNode=objXMLDoc.SelectSingleNode("//Intervals/GracePeriods/" & strName)
 	objNode.nodeTypedValue   = Service.Properties("GracePeriod_" & strName).value
  if Service.Properties("GracePeriod_" & strName & "_Enabled") then
    objNode.attributes.getNamedItem("enabled").value = "TRUE"
  else
    objNode.attributes.getNamedItem("enabled").value = "FALSE"
  end if
 
  SetConfigFileGracePeriodSetting = true
end function

%>


