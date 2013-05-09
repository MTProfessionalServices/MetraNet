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

wscript.echo "-- Testing securable operations --"

wscript.echo "-- Login as superuser --"
Set ctx = loginctx.Login("su", "csr")


wscript.echo "-- Trying policy.CreateRole securable operation--"

Set secadmin = policy.CreateRole(ctx, "SecurityAdministrator")

wscript.echo "-- Done --"

If err Then
	Set secadmin = policy.GetRoleByName(ctx, "SecurityAdministrator")
	err.Clear
End If

wscript.echo "-- Now log in as JuniorCSR and perform same operation - should fail --"
On Error Resume Next
Set ctx = loginctx.Login("jcsr", "csr")
Set secadmin = policy.CreateRole(ctx, "SecurityAdministrator")

If err Then
	wscript.echo err.Source & err.Description
	
End If
