

Set WshShell = WScript.CreateObject( "WScript.Shell")
set WshFileSystem = WScript.CreateObject("Scripting.FileSystemObject")


OutDir    = CStr(MTGetEnvVar("MTOUTDIR"))
DebugType = MTGetEnvVar("DEBUG")
RootDir   = MTGetEnvVar("ROOTDIR")
TempDir   = MTGetEnvVar("TEMP")
InstallType = MTGetEnvVar("INSTALLTYPE")


if DebugType = "0" then
	DebugString = "Release"
else
	DebugString = "Debug"
end if





Call BuildExtensions()

function BuildExtensions()

	' make sure the the appropriate COM objects are registered
	BaseExecuteString = "Regsvr32 /s /c " & OutDir & "\" & DebugString & "\bin"
	call WshShell.run(BaseExecuteString & "\propset.dll",0,true)
	call WshShell.run(BaseExecuteString & "\ExtensionTools.dll",0,true)

	set ExtensionsDir = WshFileSystem.GetFolder(RootDir & "\extensions")

	if wscript.arguments.Count = 0 then

		' Enumerate through all the platform extensions
		for each Folder in ExtensionsDir.SubFolders
			' generate the package
			if WshFileSystem.FileExists(Folder.path & "\config\manifest.xml") then
				GeneratePackage(Folder.path)
			end if
		next
	else
		call GeneratePackage(wscript.arguments(0))
	end if


end function




''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Generate the ODS for a platform extension
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

function GeneratePackage(aFolderPath)

	Manifest = aFolderPath & "\config\manifest.xml"

	wscript.echo "Starting processing of " & aFolderPath

	' step 1: determine the location of the output installation directory

	if OutDir = "" then
		WScript.echo "Failed to find environment variable OUTDIR"
		WScript.echo OutDir
		exit function
	end if



	BinariesDir = OutDir & "\" & DebugString & "\" & "bin"
	InstallBase = OutDir & "\install" & "\" & DebugString & "\"



	' step 3: load the manifest file
	set mConfig = CreateObject("MetraTech.MTConfig.1")
	set aPropSet = mConfig.ReadConfiguration(Manifest,false)
	aPackageName = aPropSet.NextStringWithName("ShortName")
	RelativePath = "extensions\" & aPackageName

	On Error Resume next
	Call WshFileSystem.CreateFolder(InstallBase)
	Call WshFileSystem.CreateFolder(InstallBase & "\extensions")
	Call WshFileSystem.CreateFolder(InstallBase & "\extensions\" & aPackageName)
	on error goto 0


	set aFileSet = aPropSet.NextSetWithName("Files")
	if Not aFileset is nothing then

		' loop through the file list
		do 

			set aItemSet = aFileSet.NextSetWithName("FileList")
			if Not aItemSet is nothing then
				aListType = aItemSet.AttribSet.AttrValue("type")

				wscript.echo "Copying " & aListType & " files..."

				select case aListType
				case "shared"
					Call ProcessSetAndCopyFiles(aItemSet,BinariesDir,InstallBase & RelativePath & "\bin")
				case "binaries"
					Call ProcessSetAndCopyFiles(aItemSet,BinariesDir,InstallBase & RelativePath & "\executables")
				case "ThirdParty"
					ThirdPartyRelativeDir = aItemSet.AttribSet.AttrValue("relativedir")
					wscript.echo RootDir & "\" & ThirdPartyRelativeDir
					call ProcessSetAndCopyFiles(aItemSet,RootDir & "\" & ThirdPartyRelativeDir,InstallBase & RelativePath & "\ThirdParty")
				case else
					wscript.echo "Unknown file list type"
					exit function
				end select
			end if
		loop until aItemSet is nothing
	
	else
		wscript.echo "Manifest does not contain list of files"
		Call aPropSet.Reset
	end if

	On Error Resume Next
		WshFileSystem.CreateFolder(InstallBase & RelativePath & "\executables")
		WshFileSystem.CreateFolder(InstallBase & RelativePath & "\bin")
		WshFileSystem.CreateFolder(InstallBase & RelativePath & "\ThirdParty")
		WshFileSystem.CreateFolder(InstallBase & RelativePath & "\ExtensionFolder")
	On Error goto 0
	

	' step 6: copy the extensions folder
	On Error Resume Next
	Call WshFileSystem.CreateFolder(InstallBase & RelativePath & "\ExtensionFolder")
	On Error Goto 0
	wscript.echo "Copying the extension folder " & aFolderPath & " to " & InstallBase & RelativePath & "\ExtensionFolder"
	Call WshFileSystem.CopyFolder(aFolderPath,InstallBase & RelativePath & "\ExtensionFolder")


	wscript.echo "Done with processing " & manifest

	' step 8: build the extension
	set aExtensionBuilder = CreateObject("ExtensionTools.ExtensionBuild")
	aExtensionBuilder.mInstallShieldSrcDir = RootDir & "\install\platformextension"
	aExtensionBuilder.mInxFile = OutDir & "\install\" & DebugString & "\ExtCompiledScript\setup.install"
	 
	aExtensionBuilder.SrcDir = InstallBase & RelativePath
	' create a directory in the temp folder
	aoutputTemp = WshFileSystem.GetSpecialFolder(2).Path & "\" & WshFileSystem.GetTempName()
	WshFileSystem.CreateFolder(aoutputTemp)
	aExtensionBuilder.OutputDir = aoutputTemp
	
	On error resume next
	WshFileSystem.CreateFolder( OutDir & "\install")
	WshFileSystem.CreateFolder( OutDir & "\install\" & DebugString)
	WshFileSystem.CreateFolder( OutDir & "\install\" & DebugString & "\_CD")
	WshFileSystem.CreateFolder( OutDir & "\install\" & DebugString & "\_CD\PlatformExtensions")
	WshFileSystem.CreateFolder( OutDir & "\install\" & DebugString & "\_CD\PlatformExtensions\" & aPackageName)
	aFinalBuildDir = OutDir & "\install\" & DebugString & "\_CD\PlatformExtensions\" & aPackageName
	on error goto 0

	
	' build the extension and get the temporary file
	aOutputFile =  aExtensionBuilder.BuildExtension()
	set aTextStream = WshFileSystem.GetFile(aOutputFile).OpenAsTextStream
	
	On Error resume next
	do
		wscript.echo aTextStream.ReadLine
	loop until aTextStream.AtEndOfStream
	Call aTextStream.Close()
	WshFileSystem.DeleteFile(aOutputFile)
	
	On Error goto 0
	wscript.echo "Copying files..."
	call WshFileSystem.CopyFolder(aoutputTemp & "\Disk Images\Disk1",aFinalBuildDir)
	call WshFileSystem.DeleteFolder(aoutputTemp)

end function


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ProcessSetAndCopyFiles
'
' Processes a set of items and copies them to the correct directory
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

function ProcessSetAndCopyFiles(aPropSet,aSourceDir,aCopyDir)

	On Error Resume Next
	Call WshFileSystem.CreateFolder(aCopyDir)
	On Error Goto 0

		bFlag = false

		On Error Resume next
		while(not bFlag)
			aItem = aPropSet.NextStringWithName("item")
			wscript.echo aItem
			if aItem = "" then
				bFlag = true
			else
				call WshFileSystem.CopyFile(aSourceDir & "\" & aItem,aCopyDir & "\" & aItem)
			end if
			aItem = ""

		wend
		On Error goto 0

end function

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' GetRelativePath
' 
' Finds the relative path of the package
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

function GetRelativePath(LocalRootDir,LocalPackageDir)
	RootDirArray = split(LocalRootDir,"\")
	PackageDirArray = split(LocalPackageDir,"\")

	GetRelativePath = ""

	for index = UBound(RootDirArray)+1 to UBound(PackageDirArray)
		GetRelativePath = GetRelativePath + PackageDirArray(index) + "\"
	next

end function



Function MTGetShortPath(filespec)

' Munge path to short path for 8.3 and command line compatibility.
'
' Requires:  WshFileSystem Object
' Input:     Fully qualified path of a File or Folder as variant string.
' Output:    ShortPath of File or Folder.

  Dim stmp, ftmp
  Set ftmp = WshFileSystem.GetFolder(filespec)
  stmp  = ftmp.ShortPath 

  MTGetShortPath = stmp

End Function



Function MTGetEnvVar( szEnvVar )

' Get Environment Variable from Process then User then System Area.
'
' Requires:  WshShell Object
' Input:     Environment Variable
' Output:    The first non-null environment setting.
 
  Dim stmp
  set UserEnvironment    = WshShell.Environment("USER")
  set SystemEnvironment  = WshShell.Environment("SYSTEM")
  set ProcessEnvironment = WshShell.Environment("PROCESS")

  stmp = ProcessEnvironment.Item(szEnvVar)

  if stmp = "" then
     stmp = UserEnvironment.Item(szEnvVar)
  end if

  if stmp = "" then
     stmp = SystemEnvironment.Item(szEnvVar)
  end if  

  set UserEnvironment    = Nothing
  set SystemEnvironment  = Nothing
  set ProcessEnvironment = Nothing

  MTGetEnvVar = stmp

End Function



