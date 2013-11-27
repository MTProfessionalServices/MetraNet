


wscript.echo "-- creating mtconfig object --"

Set MtconfigObj = CreateObject("MetraTech.MTConfig.1")
Set aPropSet = MtconfigObj.ReadConfiguration(wscript.arguments(0),false)
aPropSet =  aPropSet.WriteWithChecksum(wscript.arguments(0))
