
  Dim objLoginContext, objSessionContext
  Set objLoginContext = CreateObject("Metratech.MTLoginContext")
  Set objSessionContext = objLoginContext.Login("su", "system_user", "su123")


  set aHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")
  aHookHandler.SessionContext = objSessionContext

  wscript.echo "*** Running the audit hook..."
  Call aHookHandler.RunHookWithProgid("MetraHook.AuditHook.1", False)

  wscript.echo "*** Running MTCapabilityHook hook..."
  Call aHookHandler.RunHookWithProgid("MetraHook.MTCapabilityHook","")
  
  wscript.echo "*** Running MTSecurityPolicy hook..."
  Call aHookHandler.RunHookWithProgid("MetraHook.MTSecurityPolicyHook","")
  
  wscript.echo "Done."
  