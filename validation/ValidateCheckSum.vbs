


wscript.echo "-- creating mtconfig object --"

Set MtconfigObj = CreateObject("MetraTech.MTConfig.1")
Set aPropSet = MtconfigObj.ReadConfiguration("bingbar.xml",true)
