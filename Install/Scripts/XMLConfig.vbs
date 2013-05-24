'******************************************************************************************
'*
'* Copyright 2000 by MetraTech Corporation
'* All rights reserved.
'*
'* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
'* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'* example, but not limitation, MetraTech Corporation MAKES NO
'* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'*
'* Title to copyright in this software and any associated
'* documentation shall at all times remain with MetraTech Corporation,
'* and USER agrees to preserve the same.
'*
'* Name:        XMLConfig.vbs
'* Created By:  Alfred Flanagan / Anagha Rangarajan / Simon Morton
'* Description: Configuration of core XML configuration files
'*
'******************************************************************************************

Option Explicit

'*******************************************************************************
'*** Include file processing (do not change)
'*******************************************************************************
Function Include(sFileName)
  Dim sCustActData
  Dim sIncludeDir
  Dim sIncludePath

  Include = False

  Dim oFso
  Set oFso  = CreateObject("Scripting.FileSystemObject")

  On Error Resume Next
  sCustActData = Session.Property("CustomActionData")

  If err.Number = 0 Then
    On Error Goto 0
    'we are being called from the installer; get install dir from CustomActionData and derive include dir
    Dim nEnd
    nEnd = InStr(sCustActData,";")
    If nEnd = 0 Then nEnd = Len(sCustActData)+1
    sIncludeDir = Left(sCustActData,nEnd-1) & "install\scripts"

  Else
    On Error Goto 0
    Dim oWsh, oEnv
    Set oWsh = CreateObject("Wscript.Shell")
    Set oEnv = oWsh.Environment("PROCESS")

    If oEnv("ROOTDIR") <> "" Then
      'ROOTDIR is defined, we are in development environment; derive include dir accordingly
      sIncludeDir = oEnv("ROOTDIR") & "\install\scripts"

    Else
      'Last chance: include file must be in my current directory
      sIncludeDir = "."
    End If

    Set oWsh = Nothing
    Set oEnv = Nothing
  End If

  sIncludePath = sIncludeDir & "\" & sFileName
  If Not oFso.FileExists(sIncludePath) Then
    wscript.echo "     Error: Include file " & sIncludePath & " does not exist"
    Set oFso = Nothing
    Exit Function
  End If

  Dim oFile
  Set oFile = oFso.OpenTextFile(sIncludePath)
  ExecuteGlobal oFile.ReadAll()
  oFile.Close
  Set oFso  = Nothing
  Set oFile = Nothing

  Include = True
End Function

If Include("Common.vbs") Then
  If Not IsISActive() Then
    'Command line invocation
    Main()
  End If
End If
'*******************************************************************************

'*** Path Constants ***
Const LOGGING_PATH      = "Config\Logging\"
Const METER_PATH        = "Config\Meter\"
Const PIPELINE_PATH     = "Config\Pipeline\"

Const PSCLIENT_SERVERACCESS_PATH = "Extensions\paymentsvrclient\Config\ServerAccess\"

'*** XML File Constants ***
Const XMLFILE_LOGGING   = "logging.xml"
Const XMLFILE_PIPELINE  = "pipeline.xml"
Const XMLFILE_LISTENER  = "listener.xml"
Const XMLFILE_ROUTE     = "route.xml"
Const XMLFILE_SERVERS   = "servers.xml"

'*** Main
Function Main
  WriteLog ">>>> Configuring MetraNet XML Files..."
  If Not SetCustomActionData ("5.0;Development;" & GetHostName() & ";;;MetraNet;MetraNet Server;2") Then Exit Function
  If ConfigureXML() <> kRetVal_SUCCESS Then Exit Function

  WriteLog ">>>> Configuring MetraPay XML Files..."
  If Not SetCustomActionData ("localhost") Then Exit Function
  If ConfigurePSClientXML() = kRetVal_SUCCESS Then Exit Function

  WriteLog "<<<< XML Files Successfully Configured!"
End Function

Function ConfigureXML()
  Dim sProductVersion
  Dim sBuildNumber
  Dim sPrimaryPipelineServer
  Dim sTitle
  Dim sServerDesc
  Dim nServerType

  Dim aServerTypes
  Dim sServerType
  Dim sMeterName

  Dim sMetraNetXml
  Dim sLoggingXml
  Dim sPipelineXml
  Dim sListenerXml
  Dim sRouteXml

  Dim sLogFilePath

  Dim aLoggingSubDirs
  Dim sLoggingSubDir

  Dim oXMLDoc

  ConfigureXML = kRetVal_ABORT
  On Error Resume Next

  EnterAction "ConfigureXML"

  If Not InitializeArguments() Then Exit Function

  If Not GetArgument (sProductVersion,        2, True) Then Exit Function
  If Not GetArgument (sBuildNumber,           3, True) Then Exit Function
  If Not GetArgument (sPrimaryPipelineServer, 4, True) Then Exit Function
  If Not GetArgument (sTitle,                 7, True) Then Exit Function
  If Not GetArgument (sServerDesc,            8, True) Then Exit Function
  If Not GetArgument (sServerType,            9, True) Then Exit Function
                    
  nServerType = CInt(sServerType)
  If nServerType < 0 Or nServerType > 3 Then
    WriteLog "***> Error: Invalid ServerType: " & nServerType
    Exit Function
  End If

  '*** Configure logging.xml files

  'First add Config/Logging...
  aLoggingSubDirs = array("")
  '...then its sub-folders
  If Not GetSubFolders(aLoggingSubDirs,MakeRMPPath(LOGGING_PATH)) Then Exit Function

  For Each sLoggingSubDir in aLoggingSubDirs 
	' CORE-3799: path to logging xml files with absolute paths filtered.
	sLoggingXml = MakeRMPPath(LOGGING_PATH & Replace(sLoggingSubDir, MakeRMPPATH(LOGGING_PATH), "") & XMLFILE_LOGGING)
	
    If Not LoadXMLDoc (oXMLDoc, sLoggingXml) Then Exit Function

    If Not GetXMLTag (oXMLDoc, "/xmlconfig/logging_config/logfilename", sLogFilePath) Then Exit Function
    sLogFilePath = MakeRMPPath(BaseName(sLogFilePath))
    If Not SetXMLTag (oXMLDoc, "/xmlconfig/logging_config/logfilename", sLogFilePath) Then Exit Function

    'Reduce log level to a maximum of 4 (INFO) on production servers
    If nServerType = 3 Then
      Dim sLogLevel
      If Not GetXMLTag (oXMLDoc, "/xmlconfig/logging_config/loglevel", sLogLevel) Then Exit Function
      If CInt(sLogLevel) > 4 Then
        If Not SetXMLTag (oXMLDoc, "/xmlconfig/logging_config/loglevel", 4) Then Exit Function
      End If
    End If

    If Not SaveXMLDoc (oXMLDoc, sLoggingXml) Then Exit Function
  Next

  '*** Configure pipeline.xml
  
  sPipelineXml = MakeRMPPath(PIPELINE_PATH & XMLFILE_PIPELINE)
  If Not LoadXMLDoc (oXMLDoc, sPipelineXml) Then Exit Function
  If Not SetXMLTag  (oXMLDoc, "/xmlconfig/sharedsessions/filename", MakeRMPPath("sessions.bin")) Then Exit Function
  If Not SaveXMLDoc (oXMLDoc, sPipelineXml) Then Exit Function

  '*** Configure listener feedback

  sMeterName = "MTMeter_" & UCase(sPrimaryPipelineServer)

  sListenerXml = MakeRMPPath(PIPELINE_PATH & XMLFILE_LISTENER)
  If Not LoadXMLDoc (oXMLDoc, sListenerXml) Then Exit Function
  If Not SetXMLTag  (oXMLDoc, "/xmlconfig/metername", sMeterName) Then Exit Function
  If Not SaveXMLDoc (oXMLDoc, sListenerXml) Then Exit Function

  sRouteXml = MakeRMPPath(METER_PATH & XMLFILE_ROUTE)
  If Not LoadXMLDoc (oXMLDoc, sRouteXml) Then Exit Function
  If Not SetXMLTag  (oXMLDoc, "/xmlconfig/responsesto/metername", sMeterName) Then Exit Function
  If Not SetXMLTag  (oXMLDoc, "/xmlconfig/responsesto/machine", UCase(sPrimaryPipelineServer)) Then Exit Function
  If Not SaveXMLDoc (oXMLDoc, sRouteXml) Then Exit Function

  '*** Configure MetraNet.xml

  aServerTypes = array("[TEST]","[DEMO]","[DEVELOPMENT]","[PRODUCTION]")
  sServerType  = aServerTypes(nServerType)

  If nServerType = 0 or nServerType = 2 then
    sTitle      = sTitle & " (" & sProductVersion & " " & sBuildNumber & ")"
    sServerDesc = sServerDesc & " (" & sProductVersion & " " & sBuildNumber & ")"
  End If

  sMetraNetXml = MakeRMPPath("extensions\SystemConfig\config\MetraNet\MetraNet.xml")

  If Not LoadXMLDoc (oXMLDoc, sMetraNetXml) Then Exit Function

  If Not SetXMLTag (oXMLDoc, "MTConfig/MetraNet/Title",                             sTitle)      Then Exit Function
  If Not SetXMLTag (oXMLDoc, "MTConfig/MetraNet/Default/MetraNetServerDescription", sServerDesc) Then Exit Function
  If Not SetXMLTag (oXMLDoc, "MTConfig/MetraNet/Default/MetraNetServerType",        sServerType) Then Exit Function

  If Not SaveXMLDoc (oXMLDoc, sMetraNetXml) Then Exit Function

  ExitAction "ConfigureXML"

  ConfigureXML = kRetVal_SUCCESS
End Function
'*****************************************************************************************


'*****************************************************************************************
Function ConfigurePSClientXML()
  Dim sPSName
  Dim sServersXml
  Dim sPSTag

  Dim oXMLDoc

  ConfigurePSCLientXML = kRetVal_ABORT
  On Error Resume Next

  EnterAction "ConfigurePSCLientXML"

  If Not InitializeArguments() Then Exit Function

  If Not GetArgument (sPSName, 2, True) Then Exit Function
                    
  '*** Configure servers.xml

  sServersXml = MakeRMPPath(MakePath(PSCLIENT_SERVERACCESS_PATH,XMLFILE_SERVERS))

  If Not LoadXMLDoc (oXMLDoc, sServersXml) Then Exit Function

  sPSTag = "/xmlconfig/server[servertype='PaymentServer']"
  If Not SetXMLTag (oXMLDoc, sPSTag & "/servername", sPSName) Then Exit Function

  If Not SaveXMLDoc (oXMLDoc, sServersXml) Then Exit Function
  
  ExitAction "ConfigurePSCLientXML"

  ConfigurePSCLientXML = kRetVal_SUCCESS
End Function
'*****************************************************************************************
