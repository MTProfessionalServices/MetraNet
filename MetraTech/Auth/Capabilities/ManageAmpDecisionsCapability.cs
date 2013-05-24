using System;
using System.Runtime.InteropServices;
using MetraTech.Auth.Capabilities;
using MetraTech.Interop.MTAuth;
using ClassInterfaceType=System.Runtime.InteropServices.ClassInterfaceType;

namespace MetraTech.Auth.Capabilities
{
  /// <summary>
  /// This capability is required for managing AMP decisions.  The AMP
  /// related GUI functionality and AmpService methods will not function
  /// unless the user has this capability
  /// </summary>
  /// 
  //[Guid("247975c1-2935-4e75-808c-c8de2be3e4ef")]
  [ClassInterface(ClassInterfaceType.None)]

    public class ManageAmpDecisionsCapability : MTCompositeCapability, IMTCompositeCapability
  {
  }
}

