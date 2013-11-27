
set aRCD = CreateObject("MetraTech.Rcd.1")

call aRCD.init()

set aExtensionList = aRCD.ExtensionList

for aCount = 0 to aExtensionList.Count -1
 wscript.echo aExtensionList.item(aCount)
next


wscript.echo "Config directory is " & aRcD.ConfigDir

'wscript.echo "Extension list with full path..."
'set aExtensionListFullPath = aRCD.ExtensionListWithPath
'for aCount = 0 to aExtensionListFullPath.Count -1
'	wscript.echo aExtensionListFullPath.item(aCount)
'next


'for aCount = 0 to aNumberOfStages.Count -1
'	wscript.echo aNumberOfStages.item(aCount)
'next

set aNumberOfStages = aRCD.RunQuery("config\pipeline\stage.xml",true)
for each aFile in aNumberOfStages
	wscript.echo "file is " & aFile
next

wscript.echo "Installation directory is " & aRCD.InstallDir

'set aCallBackHook = CreateObject("MetraHook.ConfigRefresh.1")
'call aRCD.RegisterCallBack("*.xml",aCallBackHook,Arg)

'set aExtensionList =  aRCD.RunQuery("*.xml",true)
'wscript.echo "Number of files found: " & aExtensionList.count
'set aExtensionList = nothing
'set aRCD = nothing
