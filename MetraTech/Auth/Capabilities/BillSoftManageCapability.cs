using System;
using System.Runtime.InteropServices;
using MetraTech.Auth.Capabilities;
using MetraTech.Interop.MTAuth;
using ClassInterfaceType=System.Runtime.InteropServices.ClassInterfaceType;

namespace MetraTech.Auth.Capabilities
{
  /// <summary>
  /// This capability is required to write BillSoft exemptions and overrides.  The 
  /// BillSoft exemption and override related functionality and TaxService methods will not function
  /// unless the user has this capability
  /// </summary>
  /// 
  [Guid("acc39c40-a93b-4726-8d05-f8148acdfc41")]
  [ClassInterface(ClassInterfaceType.None)]
    public class BillSoftManageCapability : MTCompositeCapability, IMTCompositeCapability
  {
  }
}

