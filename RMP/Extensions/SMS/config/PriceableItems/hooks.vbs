  Dim lngDummy
  Dim objHookHandler

  set objHookHandler = CreateObject("MTHookHandler.MTHookHandler.1")

  'For each hook you want to run, call:
  'call objHookHandler.RunHookWithProgid("MetraHook.ConfigRefresh.1","",CLng(lngDummy))

  
 ' call objHookHandler.RunHookWithProgid("MetraHook.DeployLocale.1","",CLng(lngDummy))
 ' call objHookHandler.RunHookWithProgid("MetraHook.DeployProductView.1","",CLng(lngDummy))

  'call objHookHandler.RunHookWithProgid("MetraHook.MTTariffDeployHook.1","",CLng(lngDummy)) 
  'call objHookHandler.RunHookWithProgid("MetraHook.ParamTableHook.1", "", CLng(lngDummy))

 ' call objHookHandler.RunHookWithProgid("MetraTech.Adjustments.Hooks.AdjustmentHook", "", CLng(lngDummy)) 

  call objHookHandler.RunHookWithProgid("PriceableItemHook.AddPitype", "", CLng(lngDummy)) 

  'call objHookHandler.RunHookWithProgid("MetraHook.MTCounterTypeHook.1", "", CLng(lngDummy)) 


