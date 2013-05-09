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
'roles
Dim seniorcsr
Dim engcsr
Dim all
Dim defaultengineeringrole
'caps
Dim allcap
Dim mgacap
Dim id

Dim mrc 
Dim mahcap
Dim defaultmahcap
Dim rolecap

Dim atomics

Dim eng

Set loginctx = CreateObject(LOGIN_CONTEXT_PROGID)
Set policy = CreateObject(SECURITY_POLICY_PROGID)
Set seniorcsr = CreateObject(ROLE_PROGID)
Set secadmin = CreateObject(ROLE_PROGID)
Set defaultengineeringrole = CreateObject(ROLE_PROGID)
Set engcsr = CreateObject(ROLE_PROGID)
Set all = CreateObject(ROLE_PROGID)

Set scsr = CreateObject(ACCOUNT_PROGID)
Set jcsr = CreateObject(ACCOUNT_PROGID)
Set su = CreateObject(ACCOUNT_PROGID)

wscript.echo "-- Login as superuser --"
Set ctx = loginctx.Login("su", "csr", "csr123")


wscript.echo "-- configuring SeniorCSR Role --"
Set seniorcsr = policy.GetRoleByName(ctx, "SeniorCSR")
If seniorcsr is nothing Then
	Set seniorcsr = policy.CreateRole(ctx)
	seniorcsr.Name = "SeniorCSR"
End If

seniorcsr.Description = "Big cheese, can manage all Metratech hierarchy and issue unlimited credits"
' create manage AH capability and grant it to SeniorCSR
Set mahcap = policy.GetCapabilityTypeByName("MTManageAH").CreateInstance()
mahcap.GetAtomicAccessTypeCapability.AccessType = 1
mahcap.GetAtomicPathCapability.SetPathParameter "/metratech", 1

seniorcsr.GetActivePolicy().AddCapability(mahcap)

Set mahcap = nothing
Set mahcap = policy.GetCapabilityTypeByName("MTManageAH").CreateInstance()

mahcap.GetAtomicAccessTypeCapability.AccessType = 0
mahcap.GetAtomicPathCapability.SetPathParameter "/metratech/bang", 1
seniorcsr.GetActivePolicy().AddCapability(mahcap)


seniorcsr.Save()

