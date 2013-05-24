using System;
using System.Runtime.InteropServices;
using System.Xml.Serialization;

namespace MetraTech.Security.Crypto
{
	/// <summary>
	///   KeyClass specified in KMS and mapped to internal identifiers.
	/// </summary>
	[Serializable]
	[XmlRoot("kmsKeyClass")]
	[ComVisible(false)]
	public class KMSKeyClass
	{
		#region Public properties

		/// <summary>
		///   True if KMS is being used.
		/// </summary>
		[XmlAttribute("id")]
		public string Id
		{
			get;
			set;
		}

		/// <summary>
		///   Name of the key class used in KMS.
		/// </summary>
		[XmlText]
		public string Name
		{
			get;
			set;
		}

		#endregion
	}
}
