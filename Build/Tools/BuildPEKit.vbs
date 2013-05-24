Set WshShell = WScript.CreateObject( "WScript.Shell")
set WshFileSystem = WScript.CreateObject("Scripting.FileSystemObject")


IS6Dir       = WshShell.RegRead("HKLM\Software\InstallShield\InstallShield Professional\6.0\Main\PATH")
if IS6Dir = "" then
 return -1
end if

IS6ProgFiles = MTGetShortPath(IS6Dir)
IS6CommFiles = "C:\Program Files\Common Files\InstallShield"
IS6CommFiles = MTGetShortPath(IS6CommFiles)


' step 1: copy the source files
	szRootDir = MTGetEnvVar("ROOTDIR")
	szOutDir = MTGetEnvVar("MTOUTDIR")
	DebugType = MTGetEnvVar("DEBUG")

	if DebugType = "0" then
		DebugString = "Release"
	else
		DebugString = "Debug"
	end if

	szOutDir = szOutDir & "\install\" & DebugString & "\ExtProjSrc"
	szInxDir =  MTGetEnvVar("MTOUTDIR") & "\install\" & DebugString & "\ExtCompiledScript"

	On Error resume next
	call WshFileSystem.CreateFolder(szOutDir)
	call WshFileSystem.CreateFolder(szInxDir)
	On Error goto 0
	call WshFileSystem.CopyFolder(szRootDir & "\install\platformextension",szOutDir)


' step 2: remove the scripts and compiled inx files
	call WshFileSystem.DeleteFile(szOutDir & "\Script Files\*.*")
' step 3: compile the inx file to the output directory
	szExecutionString = BuildExecuteString("\build\tools\GenericCompile.cmd","platformextension","",szInxDir)
	Call WshShell.run(szExecutionString,0,TRUE)
	call DumpLogFile()
	call DeleteLogFile()
	On Error resume next
	call WshFileSystem.DeleteFile(szInxDir & "\setup.install")
	On Error goto 0
	call WshFileSystem.MoveFile(szInxDir & "\setup.inx",szInxDir & "\setup.install")

' step 4: build the Platform Extension toolkit object
	szExecutionString = BuildExecuteString("\build\tools\GenericBuildObject.cmd","ExtToolKitObj","default","")
	wscript.echo szExecutionString
	Call WshShell.run(szExecutionString,0,TRUE)
	call DumpLogFile()
	call DeleteLogFile()

' step 5: build the installer for the extension toolkit object
	szExecutionString = BuildExecuteString("\build\tools\GenericBuildPackage.cmd","ExtToolKitInst","default","")
	wscript.echo szExecutionString
	Call WshShell.run(szExecutionString,0,TRUE)
	call DumpLogFile()
	'wscript.echo "done!"
	call DeleteLogFile()
	

Function BuildExecuteString(szScript,szArg1,szMedia,szOutDir)
	if szMedia = "" then
		szMedia = "Full"
	end if
BuildExecuteString = szRootDir & szScript & " " & szArg1 & _
	" " & IS6ProgFiles & " " & IS6CommFiles & " " & szMedia & " " & szOutDir & " > build.log 2>&1"
end function

function DumpLogFile

	set BuildStream = WshFileSystem.GetFile("build.log").OpenAsTextStream

	do
	On error Resume Next
	wscript.echo BuildStream.ReadLine
	On Error goto 0
	loop until BuildStream.AtEndOfStream
	Call BuildStream.Close()

end function


Function DeleteLogFile()
	'WshFileSystem.DeleteFile("build.log")
end function


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
