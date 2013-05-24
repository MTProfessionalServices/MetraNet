using System;
using System.Runtime.InteropServices;
using MetraTech.Auth.Capabilities;
using MetraTech.Interop.MTAuth;
using ClassInterfaceType = System.Runtime.InteropServices.ClassInterfaceType;

namespace MetraTech.Auth.Capabilities
{
  /// <summary>
  /// This capability allows a user to view FLS file processing errors
  /// </summary>
  [Guid("938cb725-120e-44df-97ac-1d096ec8bd7c")]
  [ClassInterface(ClassInterfaceType.None)]
  public class ViewFLSFiles : MTCompositeCapability, IMTCompositeCapability
  {
  }
}
