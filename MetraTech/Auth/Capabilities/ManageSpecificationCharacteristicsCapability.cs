using System;
using System.Runtime.InteropServices;
using MetraTech.Auth.Capabilities;
using MetraTech.Interop.MTAuth;
using ClassInterfaceType = System.Runtime.InteropServices.ClassInterfaceType;

namespace MetraTech.Auth.Capabilities
{
  /// <summary>
  /// This capability is required to Manage Specification Characteristics.
  /// </summary>
  [Guid("fa71e07e-a852-4cb1-9a35-5d4552ce44b9")]
  [ClassInterface(ClassInterfaceType.None)]
  public class ManageSpecificationCharacteristicsCapability : MTCompositeCapability, IMTCompositeCapability
  {
  }
}
