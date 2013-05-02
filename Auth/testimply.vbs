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
  
  Set policy = CreateObject(SECURITY_POLICY_PROGID)
  
  On Error Resume Next
  
    
	wscript.echo "-- Logging in as jcsr --"
  Set login = CreateObject("Metratech.MTLoginContext")
  Dim sessctx
	Set sessctx = login.Login("jcsr", "system_user", "csr123")
	Dim ctx
	Set ctx = sessctx.SecurityContext
	
	wscript.echo "-- Constructing MTManageAH capability to check --"
	Dim demandedmah
	Set demandedmah = policy.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance()
	demandedmah.GetAtomicEnumCapability().SetParameter "WRITE" '1= write
  demandedmah.GetAtomicPathCapability().SetParameter "/metratech/engineering/raju", 0'CURRENT
  
  wscript.echo "-- Constructing Apply Adjustments capability to check --"
  Dim demandedic
  Set demandedic = policy.GetCapabilityTypeByName("Apply Adjustments").CreateInstance()
  demandedic.GetAtomicDecimalCapability().SetParameter 130, 3 '=
  demandedic.GetAtomicEnumCapability().SetParameter "US"
  
  wscript.echo "-- Constructing Apply Adjustments capability to check --"
  Dim demandedic1
  Set demandedic1 = policy.GetCapabilityTypeByName("Apply Adjustments").CreateInstance()
  demandedic1.GetAtomicDecimalCapability().SetParameter 124, 3 '=
  demandedic1.GetAtomicEnumCapability().SetParameter "DEM"
  
  wscript.echo "-- Constructing Application LogOn capability to check --"
  Dim demandedal
  Set demandedal = policy.GetCapabilityTypeByName("Application LogOn").CreateInstance()
  demandedal.GetAtomicEnumCapability().SetParameter "MCM"
  
  wscript.echo "-- Constructing View Online Bill capability to check --"
  Dim demandedvob
  Set demandedvob = policy.GetCapabilityTypeByName("View Online Bill").CreateInstance()
  
  wscript.echo "-- Checking access on ManageAH (should succeed = /metratech/engineering/- implies /metratech/engineering/raju) --"
  ctx.CheckAccess(demandedmah)
  If err Then
    wscript.echo Err.Description
    Err = 0
  End If
  
  
  wscript.echo "-- Checking access on View Online Bill (should succeed - he has it) --"
  ctx.CheckAccess(demandedvob)
  If err Then
    wscript.echo Err.Description
    Err = 0
  End If
  
  
  wscript.echo "-- Checking access on Application LogOn (should fail - MAM does not imply MCM) --"
  ctx.CheckAccess(demandedal)
  If err Then
    wscript.echo Err.Description
    Err = 0
  End If
  
  
  wscript.echo "-- Checking access on IssueCredits (should fail - 125.25 does not imply 130) --"
  ctx.CheckAccess(demandedic)
  If err Then
    wscript.echo Err.Description
    Err = 0
  End If
  
  
  wscript.echo "-- Checking access on IssueCredits (should fail - USD does not imply DEM) --"
  ctx.CheckAccess(demandedic1)
  If err Then
    wscript.echo Err.Description
    Err = 0
  End If
  
  
  
	
	
  
  
  
  
  

  wscript.echo "-- Done --"


