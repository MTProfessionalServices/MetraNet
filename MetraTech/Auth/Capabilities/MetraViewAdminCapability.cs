using System.Runtime.InteropServices;

namespace MetraTech.Auth.Capabilities
{
  /// <summary>
  /// Users must have the MetraViewAdminCapability in order to see the admin pages for a MetraView site.
  /// </summary>
  /// 
  [Guid("F2527E3F-8919-49f1-9E84-CF7C75ED37A3")]
  [ClassInterface(ClassInterfaceType.None)]
  public class MetraViewAdminCapability : MTCompositeCapability
  {
  }
}