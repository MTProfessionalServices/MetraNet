using System;
using MetraTech.Interop.MTAuth;
using System.Runtime.InteropServices;


namespace MetraTech.Auth.Capabilities
{
	/// <summary>
	/// ApplyAdjustmentsCapability guards business operations of adjusting
	/// transactions. This capability has 1 decimal atomic capability which specifies a monetary
	/// limit of an adjustment (don we need currency as well?)
	/// </summary>
	/// 
  [Guid("f2cf5abe-cf95-4078-9260-6e9748b23169")]
  [ClassInterface(ClassInterfaceType.None)]

	public class ApplyAdjustmentsCapability : MTCompositeCapability, IMTCompositeCapability
	{
	}

  /// <summary>
  /// ManageAdjustmentsCapability guards business operations of managing 
  /// of previously entered adjustments (delete or approve adjustments)
  /// ManageAdjustmentsCapability implies ApplyAdjustmentsCapability.
  /// </summary>
  /// 
  [Guid("c0d10411-46fd-4826-a24e-1e3645e3f127")]
  [ClassInterface(ClassInterfaceType.None)]

  public class ManageAdjustmentsCapability : MTCompositeCapability, IMTCompositeCapability
  {
    public override bool Implies(IMTCompositeCapability aCap, bool aCheckParams)
    {
      if (aCap is ApplyAdjustmentsCapability)
        return true;
      return mCC.Implies(this, aCap, aCheckParams);
    }
  }
}
