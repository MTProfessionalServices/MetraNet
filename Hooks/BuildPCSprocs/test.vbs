

Set mConfig = CreateObject("MetraTech.MTConfig.1")
set aPropSet = mConfig.ReadConfigurationFromString("<xmlconfig><hook>MetraHook.BuildPCSprocs.1</hook></xmlconfig>",false)

set aHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")
call aHookHandler.Read(aPropSet)
call aHookHandler.ExecuteAllHooks("MTServiceDefChangeEvent",0)
