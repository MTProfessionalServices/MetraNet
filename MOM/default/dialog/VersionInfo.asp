<%
' ---------------------------------------------------------------------------------------------------------------------------------------
'  @doc $Workfile: BatchManagement.ViewEdit.asp$
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
'  $Date: 11/14/2002 7:18:18 PM$
'  $Author: Rudi Perkins$
'  $Revision: 10$
' ---------------------------------------------------------------------------------------------------------------------------------------
Option Explicit
%>
<!-- #INCLUDE FILE="../../auth.asp" -->
<!-- #INCLUDE VIRTUAL="/mdm/mdm.asp" -->
<!-- #INCLUDE FILE="../../default/lib/momLibrary.asp"                   -->
<!-- #INCLUDE VIRTUAL="/mdm/FrameWork/CFrameWork.Class.asp" -->
<%

' Mandatory
Form.RouteTo			              = ""

mdm_Main ' invoke the mdm framework

' ---------------------------------------------------------------------------------------------------------------------------------------
' FUNCTION:  Form_Initialize
' PARAMETERS:  EventArg
' DESCRIPTION:
' RETURNS:  Return TRUE if ok else FALSE
FUNCTION Form_Initialize(EventArg) ' As Boolean


	  Service.Clear 	' Set all the property of the service to empty. 
		    		        ' The Product view if allocated is cleared too.
                  
  'Service.Properties.Add "ADAPTER_LIST_HTML"      , "string", 20000, FALSE, Empty, eMSIX_PROPERTY_FLAG_NONE
    Service.Properties.Add "METRANET_VERSION" , "String"     , 255 , False,   ""
    Service.Properties.Add "OS_VERSION" , "String"     , 255 , False,   ""
    Service.Properties.Add "DATABASE_VERSION" , "String"     , 255 , False,   ""
    Service.Properties.Add "DATABASE_SERVERINFO" , "String"     , 255 , False,   ""
    Service.Properties.Add "PATCH_INFORMATION_HTML" , "String"     , 0 , False,   ""

    Service.Properties("OS_VERSION").Value = "Rudi OS"
    


	Form_Initialize = form_Refresh(EventArg)
END FUNCTION

FUNCTION form_Refresh(EventArg)

    'Service.Properties("ADAPTER_LIST_HTML") = getScheduledAdapterListHTML
    '//Get OS Version Information
    dim objVersionInfo
    set objVersionInfo= CreateObject("MetraTech.Statistics.VersionInfo")

    Service.Properties("OS_VERSION").Value = objVersionInfo.GetOperatingSystemVersionInfo()

    '//sResult=objVersionInfo.GetManagementObjectInfo("Win32_Processor")

    '//Get Database Version Information
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
	rowset.Init "queries\mom"
	rowset.SetQueryTag("__GET_DATABASE_VERSION_INFORMATION__")  
    'rowset.SetQueryString("SELECT @@VERSION AS DatabaseVersionInfo")
  	rowset.Execute
    Service.Properties("DATABASE_VERSION").Value = rowset.value("DatabaseVersionInfo")
    
    'rowset.init ""
	  'rowset.InitializeForStoredProc "GetDatabaseVersionInfo"
    'rowset.AddOutputParameterToStoredProc "DatabaseVersionInfo", MTTYPE_VARCHAR, OUTPUT_PARAM
	  'rowset.ExecuteStoredProc()
	  'Service.Properties("DATABASE_VERSION").Value = rowset.GetParameterFromStoredProc ("DatabaseVersionInfo")

    Service.Properties("DATABASE_SERVERINFO").Value = getDatabaseInfo
    
    '//Get MetraNet version number
    dim strXML
    dim sPath
    '// Determine if this is developer machine or production machine
    dim objSystemInfo
    set objSystemInfo=CreateObject("MetraTech.Statistics.SystemInfo")
    sPath = objSystemInfo.GetEnviromentVariable("mtoutdir")
    if len(sPath)=0 then
      '//This is a production machine  
      sPath = session("INSTALL_DIR") & "\Bin\pipeline.exe"
    else
      '//This is a developer machine
      sPath = sPath & "\debug\bin\pipeline.exe"
    end if
          
    strXML=objVersionInfo.GetFileVersionInfoAsXML(sPath,"\.dll$|\.exe$")
    
    
	  dim objXMLDoc
	  Set objXMLDoc = server.CreateObject("Microsoft.XMLDOM")
	  objXMLDoc.async = false
	  objXMLDoc.validateOnParse = false
	  objXMLDoc.resolveExternals = false
    objXMLDoc.preserveWhitespace = true
  
	  objXMLDoc.LoadXML(strXML)

    Service.Properties("METRANET_VERSION").Value = objXMLDoc.SelectSingleNode("/Files/File/Version").Text & "<BR>" & mom_FormatDateTime(objXMLDoc.SelectSingleNode("/Files/File/LastModified").Text, mom_GetDictionary("DATE_TIME_FORMAT"))
    
    Service.Properties("PATCH_INFORMATION_HTML").Value = getPatchListHTML
    
   
  form_Refresh=true

END FUNCTION

FUNCTION getPatchListHTML
    dim sHTML

    dim objRCD, objXML
    Set objRCD = server.CreateObject("Metratech.RCD")
    Set objXML = server.CreateObject("Microsoft.XMLDOM")
    'Set objXMLHelper = server.CreateObject("MTServiceWizard.XMLHelper")
    
    dim strFile, sPatchDescription
    dim objFileList
    
    Set objFileList = objRCD.RunQueryInAlternateFolder("*.xml", true, objRCD.InstallDir & "config\patchinfo")
    
    if objFileList.count = 0 then
      getPatchListHTML = sHTML
      exit function
    else
      sHTML =  "<TABLE width='100%' BORDER='0' cellspacing='1' cellpadding='2'><tr class='TableHeader' style='BACKGROUND-COLOR: #688aba'>"
      sHTML = sHTML & "<td valign='bottom' align='left'>Patch Information</td></tr>"
    end if
    
    for each strFile in objFileList
      'sHTML = sHTML & " " & strFile
      dim objNodeList
      dim objNode
      dim objXMLDoc
      Set objXMLDoc = GetUSMConfigFileXMLDOM(strFile)
      
      sHTML = sHTML & "<tr class='TableDetailCell' title='" & strFile & "'><td style='VERTICAL-ALIGN: top'>"
      
      sHTML = sHTML & "<b>" & objXMLDoc.SelectSingleNode("//patch/patchinfo/name").text & "</b>"
      'sHTML = sHTML & " " & objXMLDoc.SelectSingleNode("//patch/patchinfo/date").text & ""
      sPatchDescription = objXMLDoc.SelectSingleNode("//patch/patchinfo/description").text
      sPatchDescription = Replace(sPatchDescription, vbLf, "<BR>")

      sHTML = sHTML & "<br>" & sPatchDescription & "<br>"
      
      '// See if there are any issues listed and if so, enumerate them
      Set objNodeList = objXMLDoc.SelectSingleNode("//patch/issues").selectNodes("//issue")         

      if objNodeList.length > 0 then
        sHTML = sHTML & "<TABLE><TR><TD width=30></TD><TD width='*'>"
        sHTML = sHTML & "<TABLE width='100%' BORDER='0' cellspacing='1' cellpadding='2'><tr>"
        'sHTML = sHTML & "<td valign='bottom' align='left' width='100%'>Issues</td></tr>"

        dim i 
        dim sRef, sSum
        dim objNodeTemp      
        sHTML = sHTML & "<tr><td style='font-weight:bold;'>Ref.</td><td style='font-weight:bold;'>Summary</td></tr><tr>"
        For i = 0 to objNodeList.length-1 
          Set objNode = objNodeList.nextNode() 
          sSum = objNode.SelectSingleNode(".//summary").text
          if len(sSum)>0 then
            sHTML = sHTML & "<td style='VERTICAL-ALIGN: top'>"
            set objNodeTemp = objNode.SelectSingleNode(".//reference")
            if not objNodeTemp is nothing then
              sRef = objNodeTemp.text
              if len(sRef)>0 then
                sHTML = sHTML & sRef

              end if
            end if
            sHTML = sHTML & "</td><td style='VERTICAL-ALIGN: top'>" & sSum & "</td></tr><tr>"
            'set objNodeTemp = objNode.SelectSingleNode(".//detail")
            'if not objNodeTemp is nothing then
            '  sTemp = objNodeTemp.text
            '  if len(ltrim(rtrim(sTemp)))>0 then
            '    sTemp = Replace(sTemp, vbLf, "<BR>")
            '    sHTML = sHTML & sTemp & "<BR>"
            '  end if
            'end if
          end if
        Next 

        sHTML = sHTML & "</TR></TABLE></TABLE>"

      end if
         'nTot = oXMLTreeList.length - 1 
                 
         'For nCnt = 0 to nTot 
                           
          '      Set oXMLNode = oXMLTreeList.nextNode() 
          '      msgbox  oXMLNode.Attributes.getNamedItem("id").Text   
       
        'Next 

      
      sHTML = sHTML & "</tr>"
      
    'if ucase(objXMLDoc.SelectSingleNode("//option[.='Close']").attributes.getNamedItem("enabled").value) = "FALSE" Then
    '	Service.Properties("CloseEnabled")=false
    'else
    '	Service.Properties("CloseEnabled")=true
    'end if
      
    next
    
    sHTML = sHTML & "</TABLE>"

    getPatchListHTML = sHTML
End Function

FUNCTION getScheduledAdapterListHTML
    dim sHTML
    dim rowset
    set rowset = server.CreateObject("MTSQLRowset.MTSQLRowset.1")
  	rowset.Init "queries\mom"
    rowset.SetQueryTag("__GET_SCHEDULED_ADAPTER_LIST_WITH_RUNTIME__")
    'rowset.SetQueryString("select evt.id_event as 'EventId', evt.tx_display_name as 'Display Name', evt.tx_name as 'Name', evt.tx_desc as 'Description', max(evi.dt_arg_end) as 'InstanceLastArgEndDate' from t_recevent evt left join t_recevent_inst evi on evt.id_event=evi.id_event where evt.tx_type = 'Scheduled' AND   evt.dt_activated <= %%%SYSTEMDATE%%% AND (evt.dt_deactivated IS NULL OR %%%SYSTEMDATE%%% < evt.dt_deactivated) group by evt.id_event, evt.tx_display_name, evt.tx_name, evt.tx_desc order by evt.tx_display_name")
  	rowset.Execute
  
    'sHTML = DumpRowsetHTML(rowset)
    'exit function
    'rowset.movefirst 
  
    sHTML = sHTML & "<TABLE width='100%' BORDER='0'  cellspacing='1' cellpadding='2'>"        
    'sHTML = sHTML & "<tr class='TableHeader' style='background-color=#688ABA'><td align='left' colspan='5'>Scheduled Adapters</td></tr>"    
    sHTML = sHTML & "<tr class='TableHeader' style='background-color=#688ABA'><td valign='bottom' align='left'><input type='checkbox' name='selectAllAdapters' value='' onClick='DoSelectAllAdapters(this);'></td><td valign='bottom' align='left'>Adapter</td><td align='left'>Start Date For<BR>New Instance</td><td valign='bottom' align='left'>Description</td></tr>"    

    if rowset.eof then
      sHTML = sHTML & "<tr class='TableDetailCell'><td colspan='4'>No scheduled adapters currently in the system.</td></tr>"
    else  
      do while not rowset.eof 
          dim sToolTip,sSelectHTML
          sSelectHTML = "<input type='checkbox' name='MDM_CB_" & rowset.value("EventID") & "' value=''>"

          'sToolTip = rowset.value("Details")
          sHTML = sHTML & "<tr class='TableDetailCell' title='" & sToolTip & "'><td style='vertical-align: top'>" & sSelectHTML & "</td>"
          sHTML = sHTML & "<td style='vertical-align: top' nowrap><strong>" & "<img alt='' border='0' src= '" & "../localized/en-us/images/adapter_scheduled.gif" & "' align='absmiddle'>&nbsp;" & rowset.value("Display Name") & "</strong></td>"  
          sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("InstanceLastArgEndDate") & "&nbsp;</td>"
          sHTML = sHTML & "<td style='vertical-align: top'>" & rowset.value("Description") & "&nbsp;</td></tr>"
          rowset.movenext
      loop 
    end if
    
    sHTML = sHTML & "</TABLE><BR>" & vbNewLine
    
    getScheduledAdapterListHTML = sHTML
END FUNCTION


FUNCTION RunAdapters_Click(EventArg) ' As Boolean

  dim sAdapterList, arrAdapterList, i
  sAdapterList = mdm_UIValue("mdmSelectedIDs")

  if sAdapterList <> "" then
    dim objUSM, idInstance
    set objUSM = mom_GetUsageServerClientObject
    arrAdapterList = split(sAdapterList, ",")
    for i = 0 to ubound(arrAdapterList)-1
      idInstance = objUSM.InstantiateScheduledEvent(arrAdapterList(i))
      objUSM.SubmitEventForExecution idInstance, ""
      'objUSM.SubmitEventForReversal_3 clng(arrAdapterList(i)), False, CDate(Service.Properties("ActionDatetime").value), ""
    next

    objUSM.NotifyServiceOfSubmittedEvents

  else
    '// No adapter selected
  end if
  
  mdm_TerminateDialogAndExecuteDialog Form.RouteTo
  
  RunAdapters_Click = true
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

function getDatabaseInfo()

  dim objServerAccessSet,objServerAccess
	set objServerAccessSet = server.createObject("MTServerAccess.MTServerAccessDataSet.1")
    
  ' Initialize the object, then search for the ServerAccess information
  ' With the information, set all the metering parameters
  objServerAccessSet.Initialize
  Set objServerAccess = objServerAccessSet.FindAndReturnObject("NetMeter")

	if err then
		exit function
	end if
   
  getDatabaseInfo = objServerAccess.ServerName
end function

%>


