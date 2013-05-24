Dim objLoginContext, objSessionContext
Set objLoginContext = CreateObject("Metratech.MTLoginContext")
Set objSessionContext = objLoginContext.Login("su", "system_user", "su123")

'On Error Resume Next

set aHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")
aHookHandler.SessionContext = objSessionContext
'call aHookHandler.RunHookWithProgid("MetraTech.BusinessEntity.Hook.BusinessEntityHook","")

'set aHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")
call aHookHandler.RunHookWithProgid("MetraTech.Tax.Framework.Hooks.VendorParamsHook","")