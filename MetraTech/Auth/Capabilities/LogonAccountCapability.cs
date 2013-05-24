using System;
using System.Runtime.InteropServices;
using MetraTech.Auth.Capabilities;
using MetraTech.Interop.MTAuth;
using ClassInterfaceType=System.Runtime.InteropServices.ClassInterfaceType;

namespace MetraTech.Auth.Capabilities
{
  /// <summary>
  ///   LogonAccountCapability allows an account to log on other accounts and create tickets for them
  /// </summary>
  /// 
    [Guid("49C823D8-3FA9-4f5c-B10C-4D13F1508B04")]
  [ClassInterface(ClassInterfaceType.None)]

  public class LogonAccountCapability : MTCompositeCapability, IMTCompositeCapability
  {
  }
}
