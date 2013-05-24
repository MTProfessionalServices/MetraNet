using System;
using System.Runtime.InteropServices;
using MetraTech.Auth.Capabilities;
using MetraTech.Interop.MTAuth;
using ClassInterfaceType=System.Runtime.InteropServices.ClassInterfaceType;

namespace MetraTech.Auth.Capabilities
{
  /// <summary>
  ///   ReadBusinessEntityCapability allows for the reading of BE's for a given extension.
  /// </summary>
  /// 
  //[Guid("5F9AF694-6E7B-4946-BBAD-B07B1ADDE554")]
  [ClassInterface(ClassInterfaceType.None)]

    public class ApproveAccountChangesCapability : MTCompositeCapability, IMTCompositeCapability
  {
  }
}
