using System.Runtime.InteropServices;
using System.Xml.Serialization;

namespace MetraTech.Security.Crypto
{
	/// <summary>
	///   Password required to unlock the certificate which identifies the KMS client machine to the KMS server.
	/// </summary>
	[ComVisible(false)]
	public class CertificatePassword
	{
		#region Public properties
		/// <summary>
		///   True if KMS is being used.
		/// </summary>
		[XmlAttribute("encrypted")]
		public bool Encrypted;

		/// <summary>
		///   Password used to unlock the .pfx file used by the KMSClient.
		/// </summary>
		[XmlText]
		public string Password;
		#endregion
	}
}
