
Dim loginctx
Dim ctx
Dim id

Dim SECURITY_POLICY_PROGID
Dim SECURITY_CONTEXT_PROGID
Dim COMPOSITE_TYPE_PROGID
Dim ATOMIC_TYPE_PROGID
Dim COMPOSITE_PROGID
Dim ROLE_PROGID
Dim ACCOUNT_PROGID


SECURITY_POLICY_PROGID = "Metratech.MTSecurity"
ACCOUNT_PROGID = "Metratech.MTAuthAccount"
ROLE_PROGID = "Metratech.MTRole"
SECURITY_CONTEXT_PROGID = "Metratech.MTSecurityContext"
COMPOSITE_TYPE_PROGID = "Metratech.MTCompositeCapabilityType"
ATOMIC_TYPE_PROGID = "Metratech.MTAtomicCapabilityType"
COMPOSITE_PROGID = "Metratech.MTCompositeCapability"
PATH_CAP_PROGID = "Metratech.MTPathCapability"
ACCESSTYPE_CAP_PROGID = "Metratech.MTAccessTypeCapability"
SESSION_CONTEXT_PROGID = "Metratech.MTSessionContext"

Dim login

wscript.echo "-- Logging in as super user --"
Set login = CreateObject("Metratech.MTLoginContext")
Set ctx = login.Login("su", "csr", "su123")
Set policy = CreateObject(SECURITY_POLICY_PROGID)


Set demo = policy.GetAccountByID(ctx, 123) ' 130 == su
Dim cap
Dim cap1
Set cap = policy.GetCapabilityTypeByName("Application LogOn").CreateInstance()
Set cap1 = policy.GetCapabilityTypeByName("Manage System Wide Authorization Policies").CreateInstance()
cap.GetAtomicEnumCapability().SetParameter "MPS"
demo.GetActivePolicy(ctx).AddCapability(cap)
demo.GetActivePolicy(ctx).AddCapability(cap1)
demo.Save()
wscript.echo "-- Done --"
			
			
