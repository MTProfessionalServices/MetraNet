'*******************************************************************************
'*
'* Copyright 2000-2005 by MetraTech Corporation
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
'* Name:        Crypto.vbs
'* Created By:  Chris Messman / Alfred Flanagan / Simon Morton
'* Description: Crypto installation for MetraNet, MetraPay, and MetraView
'*
'*******************************************************************************

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
Const SERVERACCESS_PATH    = "Config\serveraccess"
Const PAYSVR_CFG_PATH      = "extensions\paymentsvr\config\paymentserver"

'*** File Name Constants ***
Const PKEY_PIPELINE        = "publickeyblob_pipeline"
Const SKEY_PIPELINE        = "sessionkeyblob_pipeline"
Const PKEY_DBACCESS        = "publickeyblob_dbaccess"
Const SKEY_DBACCESS        = "sessionkeyblob_dbaccess"
Const GENERATEKEYBLOB      = "generatekeyblob.exe"
Const SIGNIO_LOGIN         = "signiologin.xml"
Const PROTECTED_PROP_LIST  = "protectedpropertylist.xml"

Function Main()
  Dim oArgs
  
  Set oArgs = NamedArgsToHash()

  If oArgs.Count = 0 Then
	WriteLog ">>>> Uninstalling Crypto..."
    If Not SetCustomActionData("") Then Exit Function
    If UninstallCrypto() <> kRetVal_SUCCESS Then Exit Function

    WriteLog ">>>> Installing Pipeline Crypto..."
    If Not SetCustomActionData("mtkey") Then Exit Function
    If CryptoPipeline() <> kRetVal_SUCCESS Then Exit Function

    WriteLog ">>>> Installing Database Access Crypto..."
    If Not SetCustomActionData("mtkey") Then Exit Function
    If CryptoDBAccess() <> kRetVal_SUCCESS Then Exit Function

    WriteLog ">>>> Installing MetraPay credentials..."
    If Not SetCustomActionData("MetraTechCCD;mtccd1") Then Exit Function
    If CryptoMetraPay() <> kRetVal_SUCCESS Then Exit Function

    WriteLog ">>>> Installing MetraView (ticketing) Crypto..."
    If Not SetCustomActionData("mtkey") Then Exit Function
    If CryptoMetraView() <> kRetVal_SUCCESS Then Exit Function

    WriteLog ">>>> Encrypting passwords in all servers.xml files..."
    If Not SetCustomActionData("") Then Exit Function
    If EncryptPasswords() <> kRetVal_SUCCESS Then Exit Function

    WriteLog "<<<< Crypto Successfully Installed!"
    WriteLog "     Restarting IIS"

    If Not StopService("iisadmin", "/y") Then Exit Function
    If Not StartService("w3svc") Then Exit Function

  Else
    SetUtilityFunction True ' suppress warning about losing data on installed system

    If oArgs.Exists("encryptpasswords") Then
      If Not SetCustomActionData("") Then Exit Function
      If EncryptPasswords() <> kRetVal_SUCCESS Then Exit Function
    End If
  End If
End Function

'*******************************************************************************
'*** Uninstall Crypto
'*******************************************************************************
Function UninstallCrypto()
  Dim sServerAccessPath

  UninstallCrypto = kRetVal_ABORT
  On Error Resume Next

  EnterAction "UninstallCrypto"

  If Not InitializeArguments() Then Exit Function

  sServerAccessPath = MakeRMPPath(SERVERACCESS_PATH)

  WriteLog "     Deleting Pipeline key blob files"

  If Not DeleteFile(MakePath(sServerAccessPath, PKEY_PIPELINE)) Then Exit Function
  If Not DeleteFile(MakePath(sServerAccessPath, SKEY_PIPELINE)) Then Exit Function

  WriteLog "     Deleting Database Access key blob files"

  If Not DeleteFile(MakePath(sServerAccessPath, PKEY_DBACCESS)) Then Exit Function
  If Not DeleteFile(MakePath(sServerAccessPath, SKEY_DBACCESS)) Then Exit Function

  Set oCryptoManager = CreateObject("MetraTech.Security.Crypto.CryptoManager")
  oCryptoManager.FreeHandles
  
  ExitAction "UninstallCrypto"
  UninstallCrypto = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Configure Pipeline Crypto
'*******************************************************************************
Function CryptoPipeline()
  Dim sMTKey
  Dim sCmd
  Dim sPublicKeyBlob
  Dim sSessionKeyBlob

  CryptoPipeline = kRetVal_ABORT
  On Error Resume Next

  EnterAction "CryptoPipeline"

  If Not InitializeArguments() Then Exit Function

  If Not GetArgument (sMTKey, 2, True) Then Exit Function
  
  sPublicKeyBlob  = MakeRMPPath(SERVERACCESS_PATH & "\" & PKEY_PIPELINE)
  sSessionKeyBlob = MakeRMPPath(SERVERACCESS_PATH & "\" & SKEY_PIPELINE)

  'WriteLog "     Restarting IIS"

  'If Not StopService("iisadmin", "/y") Then Exit Function
  'If Not StartService("w3svc") Then Exit Function

  WriteLog "     Deleting any existing Pipeline key blob files"

  If Not DeleteFile(sPublicKeyBlob) Then Exit Function
  If Not DeleteFile(sSessionKeyBlob) Then Exit Function

  WriteLog "     Creating Pipeline key blobs"
  
  sCmd = MakeBinPath(GENERATEKEYBLOB) & _
         " -encryptionkey {0}" & _
         " -inputpublickeyblob "   & PKEY_PIPELINE & _
         " -outputsessionkeyblob " & SKEY_PIPELINE & _
         " -createkeypair"
  If Not ExecuteCommandWithPasswords(sCmd,array(sMTKey)) Then Exit Function

  If Not FileExists(sPublicKeyBlob) Then Exit Function
  If Not FileExists(sSessionKeyBlob) Then Exit Function
  
  'WriteLog "     Restarting IIS"

  'If Not StopService("iisadmin", "/y") Then Exit Function
  'If Not StartService("w3svc") Then Exit Function
  
  ExitAction "CryptoPipeline"
  CryptoPipeline = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Configure MetraPay Crypto
'*******************************************************************************
Function CryptoMetraPay()
  Dim sVerisignUser
  Dim sVerisignPwd
  Dim sSigniologinXml
  Dim oXMLDoc

  CryptoMetraPay = kRetVal_ABORT
  On Error Resume Next

  EnterAction "CryptoMetraPay"

  If Not InitializeArguments() Then Exit Function

  If Not GetArgument (sVerisignUser, 2, True) Then Exit Function
  If Not GetArgument (sVerisignPwd,  3, True) Then Exit Function

  WriteLog "     Configuring the Verisign username, password, and partner keys"
  
  sSigniologinXml = MakeRMPPath(PAYSVR_CFG_PATH & "\" & SIGNIO_LOGIN)

  If Not LoadXMLDoc(oXMLDoc, sSigniologinXml) Then Exit Function
  If Not SetProtectedProperty (oXMLDoc, "username", sVerisignUser) Then Exit Function
  If Not SetProtectedProperty (oXMLDoc, "password", sVerisignPwd) Then Exit Function
  If Not SetProtectedProperty (oXMLDoc, "partner",  "Verisign") Then Exit Function
  If Not SaveXMLDoc(oXMLDoc, sSigniologinXml) Then Exit Function
  
  'WriteLog "     Restarting IIS"

  'If Not StopService("iisadmin", "/y") Then Exit Function
  'If Not StartService("w3svc") Then Exit Function

  ExitAction "CryptoMetraPay"
  CryptoMetraPay = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Configure MetraView Crypto
'*******************************************************************************
Function CryptoMetraView()
  Dim sMVKey
  Dim sProtPropListXml
  Dim sPublicKeyBlob
  Dim sSessionKeyBlob
  Dim oXMLDoc

  CryptoMetraView = kRetVal_ABORT
  On Error Resume Next

  EnterAction "CryptoMetraView"

  If Not InitializeArguments() Then Exit Function

  If Not GetArgument (sMVKey, 2, True) Then Exit Function

  'WriteLog "     Restarting IIS"

  'If Not StopService("iisadmin", "/y") Then Exit Function
  'If Not StartService("w3svc") Then Exit Function
  
  WriteLog "     Configuring the ticketagent key"
 
  sProtPropListXml = MakeRMPPath(SERVERACCESS_PATH & "\" & PROTECTED_PROP_LIST)

  If Not LoadXMLDoc(oXMLDoc, sProtPropListXml) Then Exit Function
  If Not SetProtectedProperty (oXMLDoc, "ticketagent", sMVKey) Then Exit Function
  If Not SaveXMLDoc(oXMLDoc, sProtPropListXml) Then Exit Function

  'WriteLog "     Restarting IIS"

  'If Not StopService("iisadmin", "/y") Then Exit Function
  'If Not StartService("w3svc") Then Exit Function
 
  ExitAction "CryptoMetraView"
  CryptoMetraView = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Configure Database Access Crypto
'*******************************************************************************
Function CryptoDBAccess()  
  Dim sMTKey
  Dim sCmd
  Dim sPublicKeyBlob
  Dim sSessionKeyBlob
  Dim oInstallConfig

  CryptoDBAccess = kRetVal_ABORT
  On Error Resume Next

  EnterAction "CryptoDBAccess"

  If Not InitializeArguments() Then Exit Function

  If Not GetArgument (sMTKey, 2, True) Then Exit Function
  
  sPublicKeyBlob  = MakeRMPPath(SERVERACCESS_PATH & "\" & PKEY_DBACCESS)
  sSessionKeyBlob = MakeRMPPath(SERVERACCESS_PATH & "\" & SKEY_DBACCESS)

  WriteLog "     Deleting any existing DBAccess key blob files"

  If Not DeleteFile(sPublicKeyBlob) Then Exit Function
  If Not DeleteFile(sSessionKeyBlob) Then Exit Function

  WriteLog "     Generating DBAccess public key blob"

  Set oInstallConfig = CreateObject("InstallConfig.InstallConfigObj")
  If CheckErrors("creating InstallConfig object)") Then Exit Function
    
  oInstallConfig.EncryptDBAccessKeys()
  If CheckErrors("generating DBaccess public key blob") Then Exit Function 

  If Not FileExists(sPublicKeyBlob) Then Exit Function

  WriteLog "     Generating DBAccess session key blob"

  sCmd = MakeBinPath(GENERATEKEYBLOB) & _
         " -encryptionkey {0}" & _
         " -inputpublickeyblob "   & PKEY_DBACCESS & _
         " -outputsessionkeyblob " & SKEY_DBACCESS
  If Not ExecuteCommandWithPasswords(sCmd,array(sMTKey)) Then Exit Function

  If Not FileExists(sSessionKeyBlob) Then Exit Function
  
  ExitAction "CryptoDBAccess"

  CryptoDBAccess = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Encrypt passwords in all servers.xml files
'*******************************************************************************
Function EncryptPasswords()  
  Dim sServersXml
  Dim oRCD
  Dim oListSAFiles

  EncryptPasswords = kRetVal_ABORT
  On Error Resume Next

  EnterAction "EncryptPasswords"

  If Not InitializeArguments() Then Exit Function

  WriteLog "     Encrypting Server Access passwords"
  
  Set oRCD = CreateObject("MetraTech.RCD")
  If CheckErrors("creating RCD object") Then Exit Function 

  Set oListSAFiles = oRCD.RunQuery("Config\ServerAccess\servers.xml", False)
  If CheckErrors("getting list of server access files") Then Exit Function 

  'Add the main servers.xml file (not yet extensionalized)
  sServersXml = MakeRMPPath(SERVERACCESS_PATH & "\servers.xml")
  If FileExists(sServersXml) then
    oListSAFiles.addFile sServersXml
  End if

  ' Iterate over all servers.xml files and encrypt all passwords found
  For each sServersXml in oListSAFiles
    If Not EncryptPasswordsInServersFile(sServersXml) then Exit Function
  Next

  ExitAction "EncryptPasswords"

  EncryptPasswords = kRetVal_SUCCESS
End Function
'*******************************************************************************


'*******************************************************************************
'*** Encrypt passwords in specified servers.xml file
'*******************************************************************************
Function EncryptPasswordsInServersFile(sFileName)
  Dim oXMLDOM
  
  EncryptPasswordsInServersFile = False
  On Error Resume Next

  Set oXMLDOM = CreateObject("Microsoft.XMLDOM")
  If CheckErrors("creating XML DOM object") Then Exit Function 
  
  oXMLDOM.async = False
  oXMLDOM.validateOnParse = False
  oXMLDOM.preserveWhiteSpace = False
  oXMLDOM.resolveExternals = False

  oXMLDOM.Load(sFileName)
  If CheckErrors("loading " & sFileName & " into XML DOM") Then Exit Function 

  If oXMLDOM.parseError.errorCode <> 0 Then
    WriteLog "<*** XML Parsing Error: " & oXMLDOM.parseError.reason & " on line " & oXMLDOM.parseError.line
    Exit Function
  End If

  WriteLog "     Enabling encryption in file: " & sFileName
  If Not EncryptPasswordsInDOMObject(oXMLDOM) Then Exit Function

  '*** save the file ***
  oXMLDOM.save(sFileName)
  If CheckErrors("saving XML DOM into " & sFileName) Then Exit Function 

  EncryptPasswordsInServersFile = True
End Function
'*******************************************************************************


'*******************************************************************************
'*** Encrypt passwords in specified XML DOM object
'*******************************************************************************
Function EncryptPasswordsInDOMObject(oXMLDOMFile)
  Dim oServerList
  Dim oServer

  EncryptPasswordsInDOMObject = False

  On Error Resume Next

  Set oServerList = oXMLDOMFile.documentElement.selectNodes("/xmlconfig/server")

  For Each oServer in oServerList
    Dim oServerType
    Dim oPassword
    Set oServerType = oServer.selectSingleNode("servertype")
    Set oPassword   = oServer.selectSingleNode("password")

    If Not oServerType is Nothing and _
       Not oPassword is Nothing then
      Dim sServerDesc
      Dim oServerName

      sServerDesc = oServerType.text
      Set oServerName = oServer.selectSingleNode("servername")
      If Not oServerName is Nothing then
        sServerDesc = sServerDesc & " (" & oServerName.text & ")"
      End if

      If Len(oPassword.text) > 0 Then

        If Not IsEncrypted(oPassword) Then

          If Not EncryptNode(oXMLDOMFile,oPassword) then Exit Function
          WriteLog "     Password successfully encrypted for " & sServerDesc

        Else
          WriteLog "     Password was already encrypted for " & sServerDesc
        End if

      Else
        WriteLog "     Password is blank for " & sServerDesc
      End if
    End if
  Next
  
  EncryptPasswordsInDOMObject = True
End function
'*******************************************************************************


'*******************************************************************************
'*** Set a protected property in an XML document
'*******************************************************************************
Function SetProtectedProperty(oXMLDoc, sName, sValue)
  Dim sDataSetTag
  Dim sEncryptedValue

  SetProtectedProperty = False

  sDataSetTag = "/xmlconfig/dataset[name='" & sName & "']/"

  If Not EncryptString(sEncryptedValue, sValue) Then Exit Function
  If Not SetXMLTag (oXMLDoc, sDataSetTag & "value", sEncryptedValue) Then Exit Function
  If Not SetXMLTag (oXMLDoc, sDataSetTag & "initialized", "true") Then Exit Function

  SetProtectedProperty = True
'*******************************************************************************
End Function
