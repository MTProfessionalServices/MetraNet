
Dim SECURITY_POLICY_PROGID
Dim SECURITY_CONTEXT_PROGID
Dim COMPOSITE_TYPE_PROGID
Dim ATOMIC_TYPE_PROGID
Dim COMPOSITE_PROGID
Dim ROLE_PROGID
Dim ACCOUNT_PROGID
Dim dsp


SECURITY_POLICY_PROGID = "MTAuthProto.MTSecurityPolicy"
ACCOUNT_PROGID = "MTAuthProto.MTAuthAccount"
ROLE_PROGID = "MTAuthProto.MTRole"
SECURITY_CONTEXT_PROGID = "MTAuthProto.MTSecurityContext"
LOGIN_CONTEXT_PROGID = "MTAuthProto.MTLoginContext"
COMPOSITE_TYPE_PROGID = "MTAuthProto.MTCompositeCapabilityType"
ATOMIC_TYPE_PROGID = "MTAuthProto.MTAtomicCapabilityType"
COMPOSITE_PROGID = "MTAuthProto.MTCompositeCapability"
PATH_CAP_PROGID = "MTAuthProto.MTPathCapability"
ACCESSTYPE_CAP_PROGID = "MTAuthProto.MTAccessTypeCapability"




Dim allcaps
Dim cap
Dim loginctx
Dim ctx
Dim policy
'accounts
Dim scsr
Dim jcsr
Dim su

Set loginctx = CreateObject(LOGIN_CONTEXT_PROGID)
Set policy = CreateObject(SECURITY_POLICY_PROGID)
Set scsr = CreateObject(ACCOUNT_PROGID)
Set jcsr = CreateObject(ACCOUNT_PROGID)
Set su = CreateObject(ACCOUNT_PROGID)


wscript.echo "-- Bypass Security  to configure super user account --"
wscript.echo "-- Unless this is done = can't do anything --"
wscript.echo "-- GetRoleByName is also a securable operation --"
wscript.echo "-- the hook would need to run in system context --"

wscript.echo "-- Configuring su account (126) --"

Set ctx = CreateObject(SECURITY_CONTEXT_PROGID)
su.ID = 126
su.GetActivePolicy().AddRole(policy.GetAllRoles(ctx).Item("SuperUser"))
' su.GetActivePolicy().AddRole(policy.GetRoleByName(ctx, "SuperUser"))
su.Save()
wscript.echo "-- Done --"

wscript.echo "-- Login as superuser --"
Set ctx = loginctx.Login("su", "csr", "csr123")


wscript.echo "-- Configuring su account (126) --"
su.ID = 126
su.GetActivePolicy().AddRole(policy.GetRoleByName(ctx, "SuperUser"))
su.Save()
wscript.echo "-- Done --"

wscript.echo "-- Configuring scsr account (128) --"
scsr.ID = 128
wscript.echo "-- Adding SeniorCSR Role to 128 --"
scsr.GetActivePolicy().AddRole(policy.GetRoleByName(ctx, "SeniorCSR"))
scsr.Save()

wscript.echo "-- Configuring jcsr account (127) --"
jcsr.ID = 127
jcsr.GetActivePolicy().AddRole(policy.GetRoleByName(ctx, "EngineeringCSR"))
jcsr.Save()


wscript.echo "-- Creating Default Security Policy on Engineering folder (134) --"
Set eng = policy.GetAccountByID(134)
Dim eng
Set dsp = eng.GetDefaultPolicy(ctx)
dsp.AddRole(policy.GetRoleByName(ctx, "EgineeringFolderRole"))
eng.Save
'DefaultEngineeringRole



' wscript.echo "-- Performing runtime access check --"









		




