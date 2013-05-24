using System;
using System.Runtime.InteropServices;
using MetraTech.Auth.Capabilities;
using MetraTech.Interop.MTAuth;
using ClassInterfaceType=System.Runtime.InteropServices.ClassInterfaceType;

namespace MetraTech.Auth.Capabilities
{
  /// <summary>
  /// This capability is required to read BillSoft exemptions and overrides.  The 
  /// BillSoft exemption and override related functionality and TaxService methods will not function
  /// unless the user has this capability
  /// </summary>
  /// 
  [Guid("e46e28a4-a21f-4b66-8cbb-866a11c8650f")]
  [ClassInterface(ClassInterfaceType.None)]
    public class BillSoftViewCapability : MTCompositeCapability, IMTCompositeCapability
  {
  }
}

