using System;
using System.Runtime.InteropServices;

namespace MetraTech.Reports
{
	/// <summary>
	/// ReportingException
	/// </summary>
	/// 
	[ComVisible(false)]
	public class ReportingException : ApplicationException
	{
		public ReportingException(string aMsg) : base(aMsg)
		{
			
		}
	}

	[ComVisible(false)]
	public class CrystalEnterpriseProviderException : ReportingException
	{
		public CrystalEnterpriseProviderException(string aMsg) : base(aMsg)
		{
			
		}
	}
}
