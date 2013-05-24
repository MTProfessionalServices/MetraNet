VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ExtensionBuild"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

' *************************************************************************
' Copyright 1997-2000 by MetraTech
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
' REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
' WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
' OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
' INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
' RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech, and USER
' agrees to preserve the same.
'
' Created by:
' $Header$
'
' **************************************************************************

' ----------------------------------------------------------------
' Object:     ExtensionBuild
' Prog ID: ExtensionToosls.ExtensionBuild
' Description:    Builder object for platform extensions
' ----------------------------------------------------------------

Private mInstallshieldDir, MinstallShieldBinDir As String

' error vavlues
Const mNoRegistryKeyFound As String = "Could not determine installation directory for platform extension media files.  Try reinstalling the the Platform Extension toolkit."
Const mManifestIsInvalid As String = "Manifest.xml is missing or is not valid XML."
Const mCloneError As String = "Failed to create temporary files during build."
Const mModificationError As String = "Error modifying installshield configuration files."
Const mBuildError As String = "Failure in running Installshield media builder."

' objects
Private mScriptObj As New FileSystemObject

'manifest properties

Private mExtensionName, mExtensionGuid, mExtensionPackageTargetDir, mExtensionShortName, mExtensionDescription As String

' public properties
Public mInstallShieldSrcDir As String
Public mInxFile As String
Public DebugBuild As Boolean
Public SrcDir As String
Public OutputDir As String




' ----------------------------------------------------------------
' Name:      <name of method>

' Return Value:  returns the build string.
' Errors Raised: E_FAIL with a bunch of different strings
' Description:   Build the extension specified in SrcDir and output it in OutputDir
' ----------------------------------------------------------------


Public Function BuildExtension() As String

  Dim aTempDir, aOutputBuf, aErrorMessage As String
  Dim aOutputBinaryDir As String
  Dim aFileListObj As IXMLDOMNode
  Dim aOldOutputDir As String
  
  Dim aShellObj As New IWshShell_Class
  Dim aEnvObj As IWshEnvironment_Class
  Set aEnvObj = aShellObj.Environment("PROCESS")
  
  
  On Error GoTo ErrHandler
  ' algorithm:
  ' step 1: verify that installshield is correctly installed
  If Not VerifyInstallshield() Then
    ' XXX switch to E_FAIL
    Call Err.Raise(&H80004005, "BuildExtension", "Installshield is not correctly installed")
  End If
  
  ' step : read information from manifest file
  If Not ReadManifestProperties(aFileListObj) Then
    Call Err.Raise(&H80004005, "BuildExtension", "failed to process manifest.xml")
  End If
  
  ' step : clone the source directory to a temp location
  aTempDir = CLoneISSource()
  ' step : modify the configuration files
  If Not ModifyConfigFiles((aTempDir), aErrorMessage) Then
    Call Err.Raise(&H80004005, "BuildExtension", aErrorMessage)
  End If
  
  ' step : CopyExtensionFiles
  If Not CopyExtensionFiles(aErrorMessage, aOutputBinaryDir, aOldOutputDir) Then
        aEnvObj("MTOUTDIR") = aOldOutputDir
    Call Err.Raise(&H80004005, "CopyExtensionFiles", aErrorMessage)
  End If
  
  ' step : run the media builder
  BuildExtension = RunMediaBuilder((aTempDir))
    aEnvObj("MTOUTDIR") = aOldOutputDir
  
  ' delete the temporary folder
ErrHandler:
  If aTempDir <> "" Then
    Call mScriptObj.DeleteFolder(aTempDir)
  End If
  If aOutputBinaryDir <> "" Then
    Call mScriptObj.DeleteFolder(aOutputBinaryDir)
  End If
  If Err.Number <> 0 Then
    Call Err.Raise(Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext)
  End If
  

End Function
' --------------------------------------------------------------------------
' Name:      ReadManifestProperties
' Return Value:
' Description:   reads manifest properties from manifest.xml
' --------------------------------------------------------------------------
Private Function ReadManifestProperties(ByRef aFileListObj As IXMLDOMNode) As Boolean

Dim aXmlDoc As New DOMDocument

  ' step : load the file using the MSXML DOM
  aXmlDoc.async = False
  aXmlDoc.validateOnParse = False
  aXmlDoc.preserveWhiteSpace = True
  aXmlDoc.Load (SrcDir & "\ExtensionFolder\config\manifest.xml")
  
  ' step : check for errors
  If aXmlDoc.parseError.errorCode <> 0 Then
    Call Err.Raise(&H80004005, "ReadManifestProperties", "Error reading manifest.xml: " & aXmlDoc.parseError.reason & " on line " & aXmlDoc.parseError.Line)
  End If
  
  ' step : read the properties
  'Private mExtensionName, mExtensionGuid, mExtensionPackageTargetDir, mExtensionShortName, mExtensionDescription As String
  
  mExtensionName = aXmlDoc.selectSingleNode("/xmlconfig/name").Text
  mExtensionGuid = aXmlDoc.selectSingleNode("/xmlconfig/GUID").Text
  mExtensionPackageTargetDir = aXmlDoc.selectSingleNode("/xmlconfig/PackageTargetDir").Text
  mExtensionShortName = aXmlDoc.selectSingleNode("/xmlconfig/ShortName").Text
  mExtensionDescription = aXmlDoc.selectSingleNode("/xmlconfig/FullDescription").Text
  
  Set aFileListObj = aXmlDoc.selectSingleNode("/xmlconfig/files")
  
  ReadManifestProperties = True

End Function

' --------------------------------------------------------------------------
' Name:      CopyExtensionFiles
' Effects:       <descibe the effects of the method on ASP state>
' Arguments:     <aFileListObj> - aDom Node of all files
'                <aErrorMessage> - an error buffer
' Return Value:  boolean
' Description:   Copies extension files to the output directory
' Side Effects:  puts modified files in the directory for consuming platform extension configuration
' --------------------------------------------------------------------------

Private Function CopyExtensionFiles(ByRef aErrorMessage As String, ByRef aOutputDir As String, ByRef aOldOutputDir As String) As Boolean
Dim aTempFolder As String
Dim aTempExtendedPath As String
Dim InstallTypeString As String
Dim aPackageName As String
Dim aChildNode As IXMLDOMNode

  ' step : create a temporary folder
  aTempFolder = mScriptObj.GetSpecialFolder(TemporaryFolder).Path & "\" & mScriptObj.GetTempName
  ' step : get the environement for process
  Dim aShellObj As New IWshShell_Class
  Dim aEnvObj As IWshEnvironment_Class
  Set aEnvObj = aShellObj.Environment("PROCESS")
  
    ' step : set the MTOUTDIR, INSTALLTYPE, and PACKAGENAME environment variables
    aOldOutputDir = aEnvObj("MTOUTDIR")
    aEnvObj("MTOUTDIR") = aTempFolder
  If DebugBuild Then
    InstallTypeString = "debug"
    aEnvObj("INSTALLTYPE") = "debug"
  Else
    InstallTypeString = "release"
  End If
  
  aEnvObj("INSTALLTYPE") = InstallTypeString
  aPackageName = mExtensionShortName
  aEnvObj("PACKAGENAME") = aPackageName
  
  aTempExtendedPath = aTempFolder & "\install\" & InstallTypeString & "\packages\" & aPackageName
  
  mScriptObj.CreateFolder (aTempFolder)
  mScriptObj.CreateFolder (aTempFolder & "\install\")
  mScriptObj.CreateFolder (aTempFolder & "\install\" & InstallTypeString)
  mScriptObj.CreateFolder (aTempFolder & "\install\" & InstallTypeString & "\packages\")
  
  mScriptObj.CreateFolder (aTempExtendedPath)
  ' step : create the necessary folders
  Call mScriptObj.CopyFolder(SrcDir, aTempExtendedPath)
  
  aOutputDir = aTempFolder
  CopyExtensionFiles = True


End Function



' --------------------------------------------------------------------------
' Name:      <VerifyInstallshield
' Return Value:  <return value description>
' Description:   <enter detailed description here>
' --------------------------------------------------------------------------

Public Function VerifyInstallshield() As Boolean

  mInstallshieldDir = CStr(GetRegValue(HKEY_LOCAL_MACHINE, _
                "Software\InstallShield\InstallShield Professional\6.0\Main", "PATH", _
                ""))
  If mInstallshieldDir = "" Then
    VerifyInstallshield = False
  Else
    MinstallShieldBinDir = mInstallshieldDir + "\program"
    VerifyInstallshield = True
  End If

End Function

' --------------------------------------------------------------------------
' Name:      InstallShieldSourceDir
' Return Value:  the name of the directory
' Description:   Looks up the source for platform extensions from the registry
' --------------------------------------------------------------------------

Public Function InstallShieldSourceDir() As String


  Dim SrcDir As String

  SrcDir = CStr(GetRegValue(HKEY_LOCAL_MACHINE, _
              "Software\Metratech\PlatformExtensionToolKit", "ExtensionSourceDir", _
              ""))
  If SrcDir = "" Then
    ' XXX switch to E_FAIL
    Call Err.Raise(&H80004005, "InstallShieldSourceDir", "Can't determine platform extension source directory")
    End If
  
  InstallShieldSourceDir = SrcDir
  
End Function
' --------------------------------------------------------------------------
' Name:     InxFile
' Return Value:  the location of the InxFile
' Description:   Determines the location of the InxFile from the registry
' --------------------------------------------------------------------------

Public Function InxFile() As String

  InxFile = CStr(GetRegValue(HKEY_LOCAL_MACHINE, _
              "Software\Metratech\PlatformExtensionToolKit", "InxFileLocation", _
              ""))
  If InxFile = "" Then
    Call Err.Raise(&H80004005, "InstallShieldSourceDir", "Can't determine platform extension compiled script directory")
  Else
    InxFile = InxFile & "\setup.inx"
  End If
  
End Function

' --------------------------------------------------------------------------
' Name:      CLoneISSource
' Effects:       Copies the contents of the IIS Source directory to a temporary location
' Return Value:  the temporary directory name
' Description:   Copies the source to a temp location; this is necessary so we can modify
' some of the configuration files
' Side Effects:  files are copied to a temporary directory; consumes disk space
' --------------------------------------------------------------------------
Public Function CLoneISSource() As String

  ' step : create a temporary directory
  Dim aFolderName As String
  aFolderName = mScriptObj.GetSpecialFolder(TemporaryFolder).Path & "\" & mScriptObj.GetTempName
  ' step : copy the contents of the source directory to this location
  mScriptObj.CreateFolder (aFolderName)
  
  If mInstallShieldSrcDir = "" Then
  mInstallShieldSrcDir = InstallShieldSourceDir
  End If
  Call mScriptObj.CopyFolder(mInstallShieldSrcDir, aFolderName, True)
  CLoneISSource = aFolderName

End Function

' --------------------------------------------------------------------------
' Name:      ModifyConfigFiles
' Effects:       Modifies installshiled configuration files
' Arguments:     <aSrcDir 1> - installshield source dir
'                <aErrorString> - Any errors that were encountered
' Return Value:  boolean
' Description:   Modifies 3 configuration files
' --------------------------------------------------------------------------
Public Function ModifyConfigFiles(ByRef aSrcDir As String, ByRef aErrorString As String) As Boolean
  
  ModifyConfigFiles = False
  ' step : modify the IPR
  If Not ModifyIPR(aSrcDir) Then
    aErrorString = "Failed to modify the installshield IPR file"
    Exit Function
  End If
  
  ' step : modify the MDA
  If Not ModifyMDA(aSrcDir) Then
    aErrorString = "Failed to modify the installshield MDA file"
    Exit Function
  End If
  ' step : modify string table
  If Not ModifyStringTable(aSrcDir) Then
    aErrorString = "Failed to modify the string table"
    Exit Function
  End If
  
  ModifyConfigFiles = True

End Function
' --------------------------------------------------------------------------
' Name:      ModifyIPR
' Effects:       Modifies the project IPR file
' Arguments:     <aSrcDir> - Source directory
' Return Value: boolean
' --------------------------------------------------------------------------

Private Function ModifyIPR(ByRef aSrcDir As String) As Boolean

Dim aRegExp As New RegExp
Dim aIprFile, aTempIprFile, aStreamLine, aTempStr As String
Dim aMatchCol As MatchCollection
Dim aMatch As Match
aRegExp.IgnoreCase = False

aIprFile = aSrcDir & "\PlatformExtension.ipr"
aTempIprFile = aIprFile & ".temp"

Dim aNewFileStream As TextStream
Set aNewFileStream = mScriptObj.CreateTextFile(aTempIprFile, True, False)


' step 1: load the file as a textstream
Dim aStream As TextStream
' step 2: iterate through the file line by line
Set aStream = mScriptObj.GetFile(aIprFile).OpenAsTextStream(ForReading, TristateUseDefault)
' step 3: check for the INSTALLATIONGUID
While Not aStream.AtEndOfStream
  aStreamLine = aStream.ReadLine
  aRegExp.Pattern = "INSTALLATIONGUID"
  Set aMatchCol = aRegExp.Execute(aStreamLine)
  If aMatchCol.Count > 0 Then
    aTempStr = "INSTALLATIONGUID=" & mExtensionGuid
    Call aNewFileStream.WriteLine(aTempStr)
  Else
    ' step 4: check for the PRODUCTNAME
    aRegExp.Pattern = "PRODUCTNAME"
    If aRegExp.Execute(aStreamLine).Count > 0 Then
    aTempStr = "PRODUCTNAME=" & mExtensionName
    Call aNewFileStream.WriteLine(aTempStr)
    
    Else
      ' simply copy the file
      aNewFileStream.WriteLine (aStreamLine)
    End If
  End If
  
  
Wend

aStream.Close
Call aNewFileStream.Close
Call mScriptObj.DeleteFile(aIprFile)
Call mScriptObj.MoveFile(aTempIprFile, aIprFile)
ModifyIPR = True


End Function
' --------------------------------------------------------------------------
' Name:      ModifyMDA
' Arguments:     <aSrcDir> - Source directory
' Return Value:  boolean
' Description:   Modifies the project MDA file
' --------------------------------------------------------------------------

Private Function ModifyMDA(ByRef aSrcDir As String) As Boolean
Dim aRegExp As New RegExp
aRegExp.IgnoreCase = False
Dim aMdaFile, aMdaFileTemp, aTempStr, aStreamLine As String

aMdaFile = aSrcDir & "\Media\Full\default.mda"
aMdaFileTemp = aMdaFile & ".temp"

Dim aNewFileStream As TextStream
Set aNewFileStream = mScriptObj.CreateTextFile(aMdaFileTemp, True, False)


' step 1: load the file as a textstream
Dim aStream As TextStream
' step 2: iterate through the file line by line
Set aStream = mScriptObj.GetFile(aMdaFile).OpenAsTextStream(ForReading, TristateUseDefault)
' step 3: check for the INSTALLATIONGUID
While Not aStream.AtEndOfStream
  aStreamLine = aStream.ReadLine
  aRegExp.Pattern = "APPLICATIONNAME"
  If aRegExp.Execute(aStreamLine).Count > 0 Then
    aTempStr = "APPLICATIONNAME=" & mExtensionName
    Call aNewFileStream.WriteLine(aTempStr)
  Else
    ' step 4: check for the PRODUCTNAME
    aRegExp.Pattern = "GUID"
    If aRegExp.Execute(aStreamLine).Count > 0 Then
    aTempStr = "GUID=" & mExtensionGuid
    Call aNewFileStream.WriteLine(aTempStr)
    
    Else
      ' simply copy the file
      aNewFileStream.WriteLine (aStreamLine)
    End If
  End If
  
  
Wend

aStream.Close
Call aNewFileStream.Close
Call mScriptObj.DeleteFile(aMdaFile)
Call mScriptObj.MoveFile(aMdaFileTemp, aMdaFile)
ModifyMDA = True

End Function

' --------------------------------------------------------------------------
' Name:      ModifyStringTable
' Arguments:     <aSrcDir> - Source directory
' Return Value:  boolean
' Description:   Modifies the IS source string table
' --------------------------------------------------------------------------

Private Function ModifyStringTable(ByRef aSrcDir As String) As Boolean
Dim aRegExp As New RegExp
aRegExp.IgnoreCase = False
Dim aStringTable, aStringTableTemp, aTempStr, aStreamLine As String

aStringTable = aSrcDir & "\STRING~1\0009-english\value.shl"
aStringTableTemp = aStringTable & ".temp"

Dim aNewFileStream As TextStream
Set aNewFileStream = mScriptObj.CreateTextFile(aStringTableTemp, True, False)


' step 1: load the file as a textstream
Dim aStream As TextStream
' step 2: iterate through the file line by line
Set aStream = mScriptObj.GetFile(aStringTable).OpenAsTextStream(ForReading, TristateUseDefault)
' step 3: check for the INSTALLATIONGUID
While Not aStream.AtEndOfStream
  aStreamLine = aStream.ReadLine
  aRegExp.Pattern = "TITLE_MAIN"
  If aRegExp.Execute(aStreamLine).Count > 0 Then
    aTempStr = "TITLE_MAIN=" & mExtensionName
    Call aNewFileStream.WriteLine(aTempStr)
  Else
    ' step 4: check for the PRODUCTNAME
    aRegExp.Pattern = "PRODUCT_NAME"
    If aRegExp.Execute(aStreamLine).Count > 0 Then
    aTempStr = "PRODUCT_NAME=" & mExtensionName
    Call aNewFileStream.WriteLine(aTempStr)
    
    Else
      ' simply copy the file
      aNewFileStream.WriteLine (aStreamLine)
    End If
  End If
  
  
Wend

aStream.Close
Call aNewFileStream.Close
Call mScriptObj.DeleteFile(aStringTable)
Call mScriptObj.MoveFile(aStringTableTemp, aStringTable)
ModifyStringTable = True

End Function

' --------------------------------------------------------------------------
' Name:      RunMediaBuilder
' Effects:       Generates an installshield executable
' Arguments:     <argument 1> - SrcDirectory (temp dir)
' Return Value:  the build result
' Description:   Runs the installshield media builder.  The installscript is allready compiled at this point.
' Side Effects:  Generates a setup.exe and a bunch of cab files
' --------------------------------------------------------------------------

Public Function RunMediaBuilder(ByRef aSrcDir As String) As String
Dim aExecString As String

' step : copy the compiled script to the build directory
If mInxFile = "" Then
  mInxFile = InxFile
End If


Call mScriptObj.CopyFile(mInxFile, aSrcDir & "\Script Files\setup.inx")

Dim aShellObj As New IWshShell_Class
Dim TempFile As String
TempFile = mScriptObj.GetSpecialFolder(TemporaryFolder).Path & "\" & mScriptObj.GetTempName()

aExecString = "cmd /c " & _
"""" & MinstallShieldBinDir & "\isbuild.exe" & """" & " " & _
  "-p" & aSrcDir & "\PlatformExtension.ipr" & _
" -mFull" & _
" -b" & OutputDir & _
" > " & TempFile
'Call MsgBox(aExecString, vbOKOnly, "test")
    

Call aShellObj.Run(aExecString, WshHide, True)
RunMediaBuilder = TempFile

End Function



' --------------------------------------------------------------------------
' Name:      <name of method>
' Effects:       <descibe the effects of the method on ASP state>
' Arguments:     <argument 1> - <argument 1 description>
'                <argument 2> - <argument 2 description>
'                <argument 3> - <Value returned by reference>
' Return Value:  <return value description>
' Description:   <enter detailed description here>
' Side Effects:  <Any modifications to variables in session/global objects>
' --------------------------------------------------------------------------


Private Sub Class_Initialize()
 ' intialize variables
  mInstallShieldSrcDir = ""
  mInxFile = ""
  
  Dim aDebugEnv As String
  Dim aShellObj As New IWshShell_Class
  aDebugEnv = aShellObj.Environment("PROCESS")("DEBUG")
  If aDebugEnv = "1" Then
    DebugBuild = True
  Else
    DebugBuild = False
  End If
  
  
  
End Sub
' --------------------------------------------------------------------------
' Name:      <name of method>
' Effects:       <descibe the effects of the method on ASP state>
' Arguments:     <argument 1> - <argument 1 description>
'                <argument 2> - <argument 2 description>
'                <argument 3> - <Value returned by reference>
' Return Value:  <return value description>
' Description:   <enter detailed description here>
' Side Effects:  <Any modifications to variables in session/global objects>
' --------------------------------------------------------------------------

Private Sub Class_Terminate()
  ' get rid of temporary directory
End Sub

' --------------------------------------------------------------------------
' Name:      <name of method>
' Effects:       <descibe the effects of the method on ASP state>
' Arguments:     <argument 1> - <argument 1 description>
'                <argument 2> - <argument 2 description>
'                <argument 3> - <Value returned by reference>
' Return Value:  <return value description>
' Description:   <enter detailed description here>
' Side Effects:  <Any modifications to variables in session/global objects>
' --------------------------------------------------------------------------


