dim login
dim ctx
dim yaac
dim mgr

set login = CreateObject("Metratech.MTLoginContext")
set ctx = login.LOgin("su", "system_user", "su123")
set yaac = CreateObject("MetraTech.MTYAAC")
call yaac.InitAsSecuredResource(146, ctx, Now)
set mgr = yaac.GetOwnershipMgr()
set mgr = yaac.GetOwnershipMgr()