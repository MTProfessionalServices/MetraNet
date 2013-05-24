using System;
namespace MetraTech.Reports.Adapters
{
	public class UnsupportedConfigurationException : Exception
	{
		const string errorMsg = 
			"You are using an usupported configuration.";

		public UnsupportedConfigurationException():	base(errorMsg)
		{}
		public UnsupportedConfigurationException(string auxMessage):base(String.Format("{0} - {1}", errorMsg, auxMessage))
		{}


	}
}