

set object = CreateObject("VersionReporting.VersionTool.1")
version = object.GetVersion()
wscript.echo "version = " & version
