set aHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")
'aHookHandler.SessionContext = objSessionContext
call aHookHandler.RunHookWithProgid("MetraTech.Product.Hooks.AccountTypeHook","")
