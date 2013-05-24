using MetraTech.Interop.MTAuth;
using System.Runtime.InteropServices;


namespace MetraTech.Auth.Capabilities
{
  /// <summary>
  /// ApplyNonStandardChargesCapability guards business operations of adjusting
  /// transactions. This capability has 1 decimal atomic capability which specifies a monetary
  /// limit of an adjustment (don we need currency as well?)
  /// </summary>
  /// 
  [Guid("8df0aa3d-5b7c-41ac-8c74-78cf22f0821e")]
  [ClassInterface(ClassInterfaceType.None)]

  public class ApplyNonStandardChargesCapability : MTCompositeCapability, IMTCompositeCapability
  {
  }

  /// <summary>
  /// ManageNonStandardChargesCapability guards business operations of managing 
  /// of previously entered adjustments (delete or approve adjustments)
  /// ManageNonStandardChargesCapability implies ApplyNonStandardChargesCapability.
  /// </summary>
  /// 
  [Guid("314d510a-1118-413e-841c-9d31ff7dbacd")]
  [ClassInterface(ClassInterfaceType.None)]

  public class ManageNonStandardChargesCapability : MTCompositeCapability, IMTCompositeCapability
  {
    public override bool Implies(IMTCompositeCapability aCap, bool aCheckParams)
    {
      if (aCap is ApplyNonStandardChargesCapability)
        return true;
      return mCC.Implies(this, aCap, aCheckParams);
    }
  }
}
