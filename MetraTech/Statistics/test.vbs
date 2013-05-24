dim obj
set obj = CreateObject("MetraTech.Statistics.VersionInfo")
dim strResult
strResult = obj.GetServerDescription("")
wscript.echo strResult