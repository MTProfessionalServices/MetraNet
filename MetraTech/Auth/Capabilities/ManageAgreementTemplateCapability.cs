//using System;
//using System.Runtime.InteropServices;
//using MetraTech.Auth.Capabilities;
//using MetraTech.Interop.MTAuth;
//using ClassInterfaceType=System.Runtime.InteropServices.ClassInterfaceType;
using MetraTech.Interop.MTAuth;
using System.Runtime.InteropServices;

namespace MetraTech.Auth.Capabilities
{
  /// <summary>
  ///   ReadAgreementTemplateCapability allows system user to view the agreement templates.
  /// </summary>
  /// 
  [Guid("9f7584ca-006f-4cb9-b07f-58988183efd9")]
  [ClassInterface(ClassInterfaceType.None)]

    public class ReadAgreementTemplateCapability : MTCompositeCapability, IMTCompositeCapability
  {
  }

  /// <summary>
  ///   ManageAgreementTemplateCapability allows the system user to create or update agreement templates.
  ///   ManageAgreementTemplateCapability implies the ReadAgreementTemplateCapability
  /// </summary>
  /// 
  [Guid("9368ee14-119a-4bf4-8bda-18dc698f51f0")]
  [ClassInterface(ClassInterfaceType.None)]

  public class ManageAgreementTemplateCapability : MTCompositeCapability, IMTCompositeCapability
  {
    public override bool Implies(IMTCompositeCapability aCap, bool aCheckParams)
    {
      if (aCap is ReadAgreementTemplateCapability)
        return true;
      return mCC.Implies(this, aCap, aCheckParams);
    }

  }





}
