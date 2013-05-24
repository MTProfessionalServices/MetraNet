using System;
using System.Runtime.InteropServices;
using MetraTech.Auth.Capabilities;
using MetraTech.Interop.MTAuth;
using ClassInterfaceType = System.Runtime.InteropServices.ClassInterfaceType;

namespace MetraTech.Auth.Capabilities
{
  /// <summary>
  /// This capability allows a user to view and reprocess files related to FLS
  /// </summary>
  [Guid("636d9cf9-8987-4fd2-8c4a-f66c4618d183")]
  [ClassInterface(ClassInterfaceType.None)]
  public class ManageFLSFiles : MTCompositeCapability, IMTCompositeCapability
  {
  }
}
