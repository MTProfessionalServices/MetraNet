set pipeline = CreateObject("MetraPipeline.MTPipeline.1")
set filesys = CreateObject("Scripting.FileSystemObject")

Const INPROC = True
Const OUTPROC = False
  

Sub AddSite(OldInstanceName, InstanceName, port)
	'
	' read virtual directories from the default site
	'
	Set defaultServer = GetObject("IIS://LocalHost/W3SVC/1")
	Set defaultRoot = GetObject("IIS://LocalHost/W3SVC/1/ROOT")
	Set defaultMSIX = GetObject("IIS://localhost/W3SVC/1/ROOT/msix")
	Set defaultMTInclude = GetObject("IIS://localhost/W3SVC/1/ROOT/mtinclude")
	Set defaultMPS = GetObject("IIS://localhost/W3SVC/1/ROOT/mps")
	Set defaultPresServer = GetObject("IIS://localhost/W3SVC/1/ROOT/PresServer")

	'
	' make sure the default msix is isolated
	'
	if not defaultMSIX.AppIsolated then
		wscript.echo "WARNING: MSIX virtual directory is not out of process!"
	end if


	'
	' Create a new Web server object in the container. 
	'
	Set WebServiceObj = GetObject("IIS://LocalHost/W3SVC")
	Set server = GetObject("IIS://LocalHost/W3SVC")
	i = 1
	for each site in server
		if site.Class = "IIsWebServer" then
			i = i + 1
			wscript.echo "Passing " & site.ServerComment
		end if
	next
	wscript.echo "Creating site: " & i

	Set ServerObj = WebServiceObj.Create("IIsWebServer", CStr(i))

	'
	' configure the server object
	'
	ServerObj.ServerComment = InstanceName & " Site"
	ServerObj.ServerBindings = ":" & port & ":"
	ServerObj.SetInfo

	'
	' create the root virtual directory
	'
	Set rootDir = serverObj.Create("IIsWebVirtualDir", "ROOT")
	rootDir.Path = defaultRoot.Path
	rootdir.SetInfo

	'
	' create the msix virtual directory
	'
	Set msixDir = rootDir.Create("IIsWebVirtualDir", "msix")
	msixDir.AppEnable
	msixDir.AccessFlags = defaultMSIX.AccessFlags
	msixDir.Path = defaultMSIX.Path
	msixDir.KeyType = "IIsWebVirtualDir"
	msixDir.SetInfo
	msixDir.AppCreate OUTPROC

	'
	' create mtinclude virtual directory
	'
	Set mtinclude = rootDir.Create("IIsWebVirtualDir", "mtinclude")
	mtinclude.AppEnable
	mtinclude.AccessFlags = defaultMTInclude.AccessFlags
	mtinclude.Path = defaultMTInclude.Path
	mtinclude.KeyType = "IIsWebVirtualDir"
	mtinclude.SetInfo
	mtinclude.AppCreate INPROC


	'
	' create the MPS virtual directory
	'
	Set mps = rootDir.Create("IIsWebVirtualDir", "mps")
	mps.AppEnable
	mps.AccessFlags = defaultMPS.AccessFlags
	mps.Path = defaultMPS.Path
	mps.KeyType = "IIsWebVirtualDir"
	mps.SetInfo
	mps.AppCreate OUTPROC


	'
	' create the PresServer MPS virtual directory
	'
	Set PresServer = rootDir.Create("IIsWebVirtualDir", "PresServer")
	PresServer.AppEnable
	PresServer.AccessFlags = defaultPresServer.AccessFlags

	Dim PresServerDir
	wscript.echo "Changing " & OldInstanceName & " in " & _
		defaultPresServer.Path & " to " & InstanceName
	PresServerDir = Replace(defaultPresServer.Path, "config\" & OldInstanceName, _
				"config\" & InstanceName)

	PresServer.Path = PresServerDir
	PresServer.KeyType = "IIsWebVirtualDir"
	PresServer.SetInfo
	PresServer.AppCreate INPROC

	'
	' create a clone of each site virtual directory
	'
	for each dir in defaultRoot
		if dir.Class = "IIsWebVirtualDir" then
			if dir.Name <> "mtinclude" _
					and InStr(dir.Path, "sites") then

				Set clone = rootDir.Create("IIsWebVirtualDir", _
					dir.Name)
				clone.AppEnable
				clone.AccessFlags = dir.AccessFlags
				clone.Path = dir.Path
				clone.KeyType = "IIsWebVirtualDir"
				clone.SetInfo
				clone.AppCreate OUTPROC
			end if
		end if
	next

End Sub

Sub AddMapping(port, instance)
	pipeline.AddPortMapping port, instance
end sub

Sub CopyInstance(source, dest)

	config = pipeline.ConfigurationDirectory

	sourceFolder = config & source
	destFolder = config & dest

	wscript.echo "Copying " & sourceFolder & " to " & destFolder

	filesys.CopyFolder sourceFolder, destFolder
End Sub


Sub CopyInstance(source, dest)

	config = pipeline.ConfigurationDirectory

	sourceFolder = config & source
	destFolder = config & dest

	wscript.echo "Copying " & sourceFolder & " to " & destFolder

	filesys.CopyFolder sourceFolder, destFolder
End Sub


Sub PrintUsage()
	wscript.echo "usage: copyinstance sourceinstance destinstance port"
	wscript.echo " copies an instance of the system configuration"
End Sub

Sub Main()
	if wscript.arguments.length < 3 then
		PrintUsage
		Exit Sub
	End If

	source = wscript.arguments(0)
	dest = wscript.arguments(1)
	port = wscript.arguments(2)
	wscript.echo "Copying instance " & source & " to " & dest
	wscript.echo "New port " & port	

	CopyInstance source, dest
	AddSite source, dest, port
	AddMapping port, dest
End Sub

Sub PrintInstructions()

End Sub

Main

