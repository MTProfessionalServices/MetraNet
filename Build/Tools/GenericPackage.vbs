
OPTION EXPLICIT

Dim WshShell
Dim WshFileSystem
Dim IS6Dir, IS6ProgFiles, IS6CommFiles
Dim OutDir, DebugType, RootDir, TempDir, InstallType
Dim InstallSrcDir

Set WshShell = WScript.CreateObject( "WScript.Shell")
set WshFileSystem = WScript.CreateObject("Scripting.FileSystemObject")

IS6Dir       = WshShell.RegRead("HKLM\Software\InstallShield\InstallShield Professional\6.0\Main\PATH")
if IS6Dir = "" then
 return -1
end if


IS6ProgFiles = MTGetShortPath(IS6Dir)
'IS6CommFiles = Left(IS6Dir, InStrRev(IS6Dir,"\Program Files")  ) & "Program Files\Common Files\InstallShield"
IS6CommFiles = "C:\Program Files\Common Files\InstallShield"
wscript.echo "Processing " & IS6CommFiles
IS6CommFiles = MTGetShortPath(IS6CommFiles)
wscript.echo "Processing " & IS6CommFiles & "DONE"
OutDir    = MTGetEnvVar("MTOUTDIR")
DebugType = MTGetEnvVar("DEBUG")
RootDir   = MTGetEnvVar("ROOTDIR")
TempDir   = MTGetEnvVar("TEMP")
InstallType = MTGetEnvVar("INSTALLTYPE")


InstallSrcDir = RootDir & "\install\"
'PlatformIpr = "PlatformExtension.ipr"
'PlatformIprOld = "PlatformExtension.ipr.old"
'PlatformTemp = "PlatformExtension.ipr.temp"

'DefaultMda = "Media\Full\default.mda"
'DefaultMdaOld = DefaultMda & ".old"
'DefaultMdaOldTemp = DefaultMda & ".temp"


'  BEGIN

Call BuildInstall()

'  EXIT...




function BuildInstall()

	Dim manifestfile
	Dim SrcDir
	Dim szTargetPackage

	if wscript.arguments.Count = 0 then
		'  No Install selected
		wscript.echo "No Valid Arguments.  Exiting."
	else
		manifestfile = wscript.arguments(0)
		wscript.echo "Processing " & manifestfile
	    szTargetPackage = InstallSrcDir & manifestfile

		set SrcDir = WshFileSystem.GetFolder( szTargetPackage )
		call BuildPackage( manifestfile, szTargetPackage  )
	end if

end function



function BuildPackage( szPackage, PackageTargetDir )

	Dim DebugType
	Dim DebugString
	Dim BinariesDir
	Dim InstallBase
	Dim BuildString
	Dim Result
	Dim BuildStream

	wscript.echo "Starting processing of " & szPackage

	' step 1: determine the location of the output installation directory

	if OutDir = "" then
		WScript.echo "Failed to find environment variable OUTDIR"
		WScript.echo OutDir
		exit function
	end if

	if DebugType = "0" then
		DebugString = "Release"
	else
		DebugString = "Debug"
	end if

	BinariesDir = OutDir & "\" & DebugString & "\" & "bin"
	InstallBase = OutDir & "\install" & "\" & DebugString & "\"


	' step 4: build the installation kit

	BuildString = "cmd /c " & RootDir & "\build\tools\GenericBuildPackage.cmd " &_
	  szPackage & " " &_
	  IS6ProgFiles & "  " &  IS6CommFiles & " > IS6Build.txt" 

	wscript.echo BuildString

	Result = WshShell.run(BuildString,0,TRUE)

	set BuildStream = WshFileSystem.GetFile("IS6Build.txt").OpenAsTextStream

	do
		wscript.echo BuildStream.ReadLine
	loop until BuildStream.AtEndOfStream
	Call BuildStream.Close()


end function


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Generate the ODS for a platform extension
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

function GeneratePackage(Manifest)



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
  Dim UserEnvironment
  Dim SystemEnvironment
  Dim ProcessEnvironment

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



