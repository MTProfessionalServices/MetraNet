using System;
using System.Runtime.InteropServices;
using MetraTech.Auth.Capabilities;
using MetraTech.Interop.MTAuth;
using ClassInterfaceType=System.Runtime.InteropServices.ClassInterfaceType;

namespace MetraTech.Auth.Capabilities
{
  /// <summary>
  ///   WriteBusinessEntityCapability allows for the writing of BE's for a given extension.
  /// </summary>
  /// 
  [Guid("28CA6D07-AA1C-4995-AABA-F1F3C5F1ADD7")]
  [ClassInterface(ClassInterfaceType.None)]
  public class WriteBusinessEntityCapability : MTCompositeCapability, IMTCompositeCapability
  {
  }
}
