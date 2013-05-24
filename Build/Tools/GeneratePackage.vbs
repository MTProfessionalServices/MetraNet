
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' This script generates the disk layout for a platform extension.
' It reads the manifest.xml to decide what files must be copied 
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' This script expects that it will be passed to location of a manifest file

' step : create required objects
Set WshShell = WScript.CreateObject( "WScript.Shell")
set WshFileSystem = WScript.CreateObject("Scripting.FileSystemObject")
Call GeneratePackage()

function GeneratePackage()

	Manifest = wscript.arguments(0)
	wscript.echo "Starting processing of " & Manifest




	' step 1: determine the location of the output installation directory
	set UserEnvironment = WshShell.Environment("USER")
	Outdir = UserEnvironment.Item("MTOUTDIR")
	DebugType = UserEnvironment.Item("DEBUG")
	RootDir = UserEnvironment.Item("ROOTDIR")

	if Outdir = "" then
		WScript.echo "Failed to find environment variable OUTDIR"
		WScript.echo Outdir
		exit function
	end if

	if DebugType = "" then
		DebugType = "Release"
	else
		DebugType = "Debug"
	end if

	BinariesDir = Outdir & "\" & DebugType & "\" & "bin"
	InstallBase = Outdir & "\install" & "\" & DebugType & "\"

	' step 2: get the parent folder of the manifest file
	RelativePath = GetRelativePath(RootDir,WshFileSystem.GetParentFolderName(Manifest))

	On Error Resume next
	Call WshFileSystem.CreateFolder(InstallBase)
	Call WshFileSystem.CreateFolder(InstallBase & "\packages")
	Call WshFileSystem.CreateFolder(InstallBase & RelativePath)
	on error goto 0


	' step 3: load the manifest file
	set mConfig = CreateObject("MetraTech.MTConfig.1")
	set aPropSet = mConfig.ReadConfiguration(Manifest,false)


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
					Call ProcessSetAndCopyFiles(aItemSet,BinariesDir,InstallBase & RelativePath & "\shared")
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
	

	' step 6: copy the configuration directory
	On Error Resume Next
	Call WshFileSystem.CreateFolder(InstallBase & RelativePath & "\config")
	wscript.echo "Copying the package configuration tree..."
	Call WshFileSystem.CopyFolder(WshFileSystem.GetParentFolderName(Manifest) & "\config",InstallBase & RelativePath & "\config")
	On Error Goto 0

	' step 7: copy the manifest file itself
	On Error Resume Next
	Call WshFileSystem.CreateFolder(InstallBase & RelativePath & "\manifest")
	On Error Goto 0
	wscript.echo "Copying the manifest file..."
	call WshFileSystem.CopyFile(Manifest,InstallBase & RelativePath & "\manifest\manifest.xml")

	wscript.echo "Done with processing " & manifest

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

function GetRelativePath(RootDir,PackageDir)
	RootDirArray = split(RootDir,"\")
	PackageDirArray = split(PackageDir,"\")

	GetRelativePath = ""

	for index = UBound(RootDirArray)+1 to UBound(PackageDirArray)
		GetRelativePath = GetRelativePath + PackageDirArray(index) + "\"
	next

end function