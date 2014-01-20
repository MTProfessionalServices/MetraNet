'******************************************************************************************
'*
'* Copyright 2000-2005 by MetraTech Corp.
'* All rights reserved.
'*
'* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corp. MAKES
'* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
'* example, but not limitation, MetraTech Corp. MAKES NO
'* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
'* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
'* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
'* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'*
'* Title to copyright in this software and any associated
'* documentation shall at all times remain with MetraTech Corp.,
'* and USER agrees to preserve the same.
'*
'* Name:        Reporting.vbs
'* Created By:  Alfred Flanagan / Simon Morton
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

'*** Database Type Constants ***
Const DBTYPE_SQLSERVER = "{SQL Server}"
Const DBTYPE_ORACLE    = "{Oracle}"

'*** Main
Function Main
  WriteLog ">>>> Installing Reporting..."
  If Not SetCustomActionData ("1;nmdbo;nmdbo;localhost;rpt_server;rpt_user;rpt_pwd;D:\datamarts;10") Then Exit Function
  If ConfigureReporting() <> kRetVal_SUCCESS Then Exit Function

    WriteLog "<<<< Reporting Successfully Installed!"
End Function

Function ConfigureReporting()
  Dim oXMLDoc
  Dim sDBServerTag 
  Dim sAPSServerTag 
  Dim sSuffix 
  Dim sDBType
  Dim sDBUserName
  Dim sDBPassword
  Dim sDBServer
  Dim sAPSServer
  Dim sAPSLogin
  Dim sAPSPassword
  Dim sDBDataDir
  Dim sDBDataSize
  Dim sXMLFile
  Dim sDBTypeName
  Dim sReportingFolder

  ConfigureReporting = kRetVal_ABORT
  On Error Resume Next

  EnterAction "ConfigureReporting"

  If Not InitializeArguments() Then Exit Function

  If Not GetArgument (sDBType,      2, True) Then Exit Function
  If Not GetArgument (sDBUserName,  3, True) Then Exit Function
  If Not GetArgument (sDBPassword,  4, True) Then Exit Function
  If Not GetArgument (sDBServer,    5, True) Then Exit Function
  If Not GetArgument (sAPSServer,   6, True) Then Exit Function
  If Not GetArgument (sAPSLogin,    7, True) Then Exit Function
  If Not GetArgument (sAPSPassword, 8, True) Then Exit Function
  If Not GetArgument (sDBDataDir,   9, True) Then Exit Function
  If Not GetArgument (sDBDataSize, 10, True) Then Exit Function
  If Not GetArgument (sReportingFolder,      11, True) Then Exit Function

  'Validate database type

  If sDBType = kDBType_SQL Then
    sDBTypeName = DBTYPE_SQLSERVER
    sSuffix     = ".xml"

  Elseif sDBType = kDBType_Oracle Then
    sDBTypeName = DBTYPE_ORACLE
    sSuffix     = "_Oracle.xml"

  Else
    WriteLog "<*** Error: Unsupported Database Type: " & sDBType
    Exit Function
  End If
  
  sXMLFile = sReportingFolder & "Config\ServerAccess\Servers.xml"
  
  If Not LoadXMLDoc (oXMLDoc, sXMLFile) Then Exit Function
  
  sDBServerTag = "/xmlconfig/server[servertype='ReportingDBServer']"

  If Not SetXMLTag (oXMLDoc, sDBServerTag  & "/servername",   sDBServer)        Then Exit Function
  If Not SetXMLTag (oXMLDoc, sDBServerTag  & "/databasetype", sDBTypeName)      Then Exit Function
  If Not SetXMLTag (oXMLDoc, sDBServerTag  & "/username",     sDBUserName)      Then Exit Function
  If Not SetXMLTag (oXMLDoc, sDBServerTag  & "/password",     sDBPassword)      Then Exit Function

  sAPSServerTag = "/xmlconfig/server[servertype='APSServer']"

  If Not SetXMLTag (oXMLDoc, sAPSServerTag & "/servername",   sAPSServer)       Then Exit Function
  If Not SetXMLTag (oXMLDoc, sAPSServerTag & "/username",     sAPSLogin)        Then Exit Function
  If Not SetXMLTag (oXMLDoc, sAPSServerTag & "/password",     sAPSPassword)     Then Exit Function
  
  If Not SaveXMLDoc (oXMLDoc, sXMLFile) Then Exit Function

  sXMLFile = sReportingFolder & "Config\UsageServer\GenerateReportingDatamarts.xml"
  
  If Not LoadXMLDoc (oXMLDoc, sXMLFile) Then Exit Function
  
  If Not SetXMLTag (oXMLDoc, "/xmlconfig/DataMartDB/FilePath", sDBDataDir)       Then Exit Function
  If Not SetXMLTag (oXMLDoc, "/xmlconfig/DataMartDB/Size",     sDBDataSize)      Then Exit Function

  If Not SetXMLTag (oXMLDoc, "/xmlconfig/SupportedVersions/V2/GenerateSchemaQueryPath", "SqlCore\queries\GenerateSchemaQueries") Then Exit Function
  If Not SetXMLTag (oXMLDoc, "/xmlconfig/SupportedVersions/V2/PopulateQueryPath",       "SqlCore\queries\PopulateQueries") Then Exit Function
  If Not SetXMLTag (oXMLDoc, "/xmlconfig/SupportedVersions/V2/ReverseAdapterQueryPath", "SqlCore\queries\ReverseDatamartAdapter") Then Exit Function
  
  If Not SaveXMLDoc (oXMLDoc, sXMLFile) Then Exit Function

  sXMLFile = sReportingFolder & "Config\ReportListGroups.xml"
  
  If Not LoadXMLDoc (oXMLDoc, sXMLFile) Then Exit Function
  
  If Not SetXMLTag (oXMLDoc, "/xmlconfig/ReportListGroup/FileName", "config\MetraNetInvoices" & sSuffix) Then Exit Function
  
  If Not SaveXMLDoc (oXMLDoc, sXMLFile) Then Exit Function

  ExitAction "ConfigureReporting"

  ConfigureReporting = kRetVal_SUCCESS
End Function
'******************************************************************************************************************
