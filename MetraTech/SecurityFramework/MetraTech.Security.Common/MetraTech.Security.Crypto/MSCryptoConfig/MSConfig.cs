using System;
using System.Runtime.InteropServices;
using System.Xml.Serialization;

namespace MetraTech.Security.Crypto
{
	/// <summary>
	///   Microsoft specific security configuration.
	/// </summary>
	[ComVisible(false)]
	public class MSConfig
	{
		/// <summary>
		///   Specifies the file which contains the session key information.
		/// </summary>
		[XmlElement(ElementName = "keyFile", Type = typeof(string))]
		public string KeyFile;
	}
}
