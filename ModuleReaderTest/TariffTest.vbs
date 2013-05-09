

Set AllTariffs = CreateObject("MTModule.MTModule.1")

AllTariffs.ModuleDataFileName = "D:\Program Files\Metratech\RMP\config\test\rating\Tariff\Alltariffs.xml"
'AllTariffs.RemoteHost = "darkover"
AllTariffs.Read


wscript.echo "-- Output Tariffs"
for each item in AllTariffs
	wscript.echo "Sub Module Name " & item.Name
next


