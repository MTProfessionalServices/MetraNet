using System;
using MetraTech.Interop.MTAuth;
using System.Runtime.InteropServices;


namespace MetraTech.Auth.Capabilities
{
	/// <summary>
	/// ManualOverrideCapability checks that the user has the capability to
	/// manually override a failed transaction to move it into fixed state.
	/// </summary>
	/// 
  [Guid("9C778950-EACE-4817-A22F-5D760F14D6D8")]
  [ClassInterface(ClassInterfaceType.None)]

	public class ManualOverrideCapability : MTCompositeCapability, IMTCompositeCapability
	{
	}

}
