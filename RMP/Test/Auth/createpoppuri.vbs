  Dim SECURITY_POLICY_PROGID
  Dim SECURITY_CONTEXT_PROGID
  Dim COMPOSITE_TYPE_PROGID
  Dim ATOMIC_TYPE_PROGID
  Dim COMPOSITE_PROGID
  Dim ROLE_PROGID
  Dim ACCOUNT_PROGID
  
  Dim rname
  
  rname = "Poppuri1"


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
  
  wscript.echo "-- Logging in as super user --"
  Set login = CreateObject("Metratech.MTLoginContext")
	Set ctx = login.Login("su", "system_user", "su123")

  
  wscript.echo "-- Creating Poppuri Role --"
  
  Dim r
  Set r = policy.CreateRole(ctx)
  r.Name = rname
  r.Description = "Has all possible parameterized capabiliites"
  
  wscript.echo "-- Creating cap 1 - ManageAH --"
  Dim mah
  Set mah = policy.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance()
  mah.GetAtomicEnumCapability().SetParameter "WRITE" '1= write
  mah.GetAtomicPathCapability().SetParameter "/metratech/engineering", 2'RECURSIVE
  
  wscript.echo "-- Creating cap 2 - Apply Adjustments --"
  Dim ic
  Set ic = policy.GetCapabilityTypeByName("Apply Adjustments").CreateInstance()
  ic.GetAtomicDecimalCapability().SetParameter 125.25, 7 '<
  ic.GetAtomicEnumCapability().SetParameter "USD"
  
  wscript.echo "-- Creating cap 3 - ApplicationLogOn --"
  Dim al
  Set al = policy.GetCapabilityTypeByName("Application LogOn").CreateInstance()
  al.GetAtomicEnumCapability().SetParameter "MAM"
  
  wscript.echo "-- Creating cap 4 - View Online Bill --"
  Dim vob
  Set vob = policy.GetCapabilityTypeByName("View Online Bill").CreateInstance()
  
 
  
  Dim prpol
  Set prpol = r.GetActivePolicy(ctx)
  
  wscript.echo "-- Adding cap1 to Poppuri --"
  prpol.AddCapability(mah)
  
  wscript.echo "-- Adding cap2 to Poppuri --"
  prpol.AddCapability(ic)
  
  wscript.echo "-- Adding cap3 to Poppuri --"
  prpol.AddCapability(al)
  
  wscript.echo "-- Adding cap4 to Poppuri --"
  prpol.AddCapability(vob)
  
  
  
  wscript.echo "-- Saving Poppuri --"
  r.Save()
  
  
  wscript.echo "-- Getting JCSR account --"
  Dim a
  Set a = policy.GetAccountByID(ctx, 130)
  
  Dim accpol
  Set accpol = a.GetActivePolicy(ctx)
  
  wscript.echo "-- Adding Poppuri role to JCSR account --"
  
  accpol.AddRole(r)
  
  wscript.echo "-- Saving JCSR --"
  a.Save()
  
	
  wscript.echo "-- Done --"


