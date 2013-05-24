set pipeline = CreateObject("MetraPipeline.MTPipeline.1")
set filesys = CreateObject("Scripting.FileSystemObject")
Set wshshell = WScript.CreateObject("WScript.Shell")

Const INPROC = True
Const OUTPROC = False

Sub InstanceDirectories(InstanceName)

	config = pipeline.ConfigurationDirectory
	wscript.echo "Configuration dir: " & config
	MakeInstance(config, InstanceName)

	repository = "f:\repository"
	wscript.echo "Repository: " & repository
	MakeInstance(repository, InstanceName)
end sub

Sub MakeInstance(FolderName, InstanceName)

	wscript.echo "Folder name: " & FolderName

	config = pipeline.ConfigurationDirectory

	parent = filesys.GetParentFolderName(FolderName)

	if right(FolderName, 1) = "\" then
		base = Left(FolderName, Len(FolderName) - 1)
	else
		base = FolderName
	end if

	new = base & "\" & InstanceName
	temp = parent & "\temp"

	wscript.echo "Moving " & base & " to " & temp
	filesys.MoveFolder base, temp

	wscript.echo "Creating folder " & FolderName
	filesys.CreateFolder FolderName

	wscript.echo "Moving " & temp & " to " & new
	filesys.MoveFolder temp, new
end sub


Sub MakeSiteIsolated(InstanceName)
	Set defaultMSIX = GetObject("IIS://localhost/W3SVC/1/ROOT/msix")
	if not defaultMSIX.AppIsolated then
		wscript.echo "Moving " & defaultMSIX.Name & " out of process"
		defaultMSIX.AppCreate OUTPROC
	end if

	Set defaultMPS = GetObject("IIS://localhost/W3SVC/1/ROOT/mps")
	if not defaultMPS.AppIsolated then
		wscript.echo "Moving " & defaultMPS.Name & " out of process"
		defaultMPS.AppCreate OUTPROC
	end if

	Set defaultMT = GetObject("IIS://localhost/W3SVC/1/ROOT/mt")
	if not defaultMT.AppIsolated then
		wscript.echo "Moving " & defaultMT.Name & " out of process"
		defaultMT.AppCreate OUTPROC
	end if

	Set defaultPresServer = GetObject("IIS://localhost/W3SVC/1/ROOT/PresServer")
	Dim PresServerDir
	PresServerDir = Replace(defaultPresServer.Path, "config\", _
				"config\" & InstanceName & "\")

	defaultPresServer.Path = PresServerDir
	defaultPresServer.SetInfo

	Set defaultValidation = GetObject("IIS://localhost/W3SVC/1/ROOT/validation")
	Dim validationDir
	validationDir = Replace(defaultValidation.Path, "config\", _
				"config\" & InstanceName & "\")

	defaultValidation.Path = validationDir
	defaultValidation.SetInfo

	'
	' mark the MPS sites as out of proc.
	'
	Set defaultRoot = GetObject("IIS://LocalHost/W3SVC/1/ROOT")
	for each dir in defaultRoot
		if dir.Class = "IIsWebVirtualDir" then
			if dir.Name <> "mtinclude" _
					and InStr(dir.Path, "sites") then

				if not dir.AppIsolated then
					wscript.echo "Moving " & dir.Name & _
							" out of process"
					dir.AppCreate OUTPROC
				end if
			end if
		end if
	next

end sub


Sub MakeInstanced()
	wshshell.RegWrite "HKLM\Software\MetraTech\NetMeter\MultiInstance", 1, "REG_DWORD"
end sub

Sub AddMapping(port, instance)
	pipeline.AddPortMapping port, instance
end sub

Sub PrintUsage()
	wscript.echo "usage: makemulti instancename"
	wscript.echo " helps setup the system into a multi-instance state"
End Sub

Sub Main()
	if wscript.arguments.length < 1 then
		PrintUsage
		Exit Sub
	End If

	if pipeline.IsMultiInstance then
		wscript.echo "Already multi-instance"
		exit sub
	else
		wscript.echo "Currently single-instance"
	end if

	instance = wscript.arguments(0)
	wscript.echo "Creating instance " & instance

	InstanceDirectories(instance)

	MakeSiteIsolated(instance)

	MakeInstanced
	AddMapping 80, instance
End Sub


Main
