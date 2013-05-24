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
  [Guid("97BCCD0F-C5A5-4b1a-892C-00A62323E810")]
  [ClassInterface(ClassInterfaceType.None)]

  public class ReadBusinessEntityCapability : MTCompositeCapability, IMTCompositeCapability
  {
  }
}
