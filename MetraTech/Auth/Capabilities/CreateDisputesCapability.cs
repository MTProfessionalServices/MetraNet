using System;
using MetraTech.Interop.MTAuth;
using System.Runtime.InteropServices;


namespace MetraTech.Auth.Capabilities
{
	/// <summary>
    /// This capability will govern the CSR’s ability to create disputes and 
    /// will limit the total amount of the dispute they are allowed to approve.  
    /// This mimics the behavior of the existing ApplyAdjustmentsCapability.  
    /// In fact, the CreateDisputesCapability will imply the ApplyAdjustmentsCapability 
    /// so that users won’t need both but will still be able to create disputes and 
    /// add adjustments to the dispute.
	/// </summary>
	/// 
  [Guid("1040CC4B-8C4E-4a47-B2F5-32F1999EFB2D")]
  [ClassInterface(ClassInterfaceType.None)]

	public class CreateDisputesCapability: MTCompositeCapability, IMTCompositeCapability
    {
        public override bool Implies(IMTCompositeCapability aCap, bool aCheckParams)
        {
            if (!aCheckParams && aCap is ApplyAdjustmentsCapability)
                return true;
            return mCC.Implies(this, aCap, aCheckParams);
        }
	}

  /// <summary>
  ///This capability will control the CSR’s ability to approve, reject and reverseDisputes.
  ///This mimics the behavior of the ManageAdjustmentsCapability class.
  ///
  /// This capability will imply having the CreateDisputesCapability with no limit on the amount that can be approved.
  /// It will also imply the ManageAdjustmentsCapability.  The process of approving, rejecting and reversing disputes 
  /// involves the same operations as managing adjustments, thus the manage disputes capability needs to imply that capability.
  /// </summary>
  /// 
  [Guid("C97BC971-9D51-4d0e-9F53-131ADE281ABB")]
  [ClassInterface(ClassInterfaceType.None)]

  public class ManageDisputesCapability: MTCompositeCapability, IMTCompositeCapability
  {
    public override bool Implies(IMTCompositeCapability aCap, bool aCheckParams)
    {
        bool retval = false;

        if (aCap is ApplyAdjustmentsCapability ||
           aCap is ManageAdjustmentsCapability ||
           aCap is CreateDisputesCapability)
            retval = true;

        return (retval ? retval : mCC.Implies(this, aCap, aCheckParams));
    }
  }
}
