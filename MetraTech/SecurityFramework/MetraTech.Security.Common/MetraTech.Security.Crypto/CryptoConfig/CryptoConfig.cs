using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Xml.Serialization;
using MetraTech.Interop.RCD;
using MetraTech.SecurityFramework.Core.Common.Logging;

namespace MetraTech.Security.Crypto
{
	/// <summary>
	/// 
	/// </summary>
	[XmlRoot("xmlconfig")]
	[ComVisible(false)]
	public sealed class CryptoConfig
	{
		#region Private fields

		private static volatile CryptoConfig cryptoConfigInstance;
		private static readonly object cryptoConfigSyncRoot = new Object();
		private readonly IMTRcd rcd;
		private readonly string configFile;

		#endregion

		#region Public Properties

		/// <summary>
		///   CryptoTypeName
		/// </summary>
		[XmlElement(ElementName = "cryptoTypeName", Type = typeof(string))]
		public string CryptoTypeName
		{
			get;
			set;
		}

		/// <summary>
		///   RSAConfig
		/// </summary>
		[XmlElement(ElementName = "rsaConfig", Type = typeof(RSAConfig))]
		public RSAConfig RSAConfig
		{
			get;
			set;
		}

		/// <summary>
		///   RCD
		/// </summary>
		public IMTRcd RCD
		{
			get { return rcd; }
		}

		#endregion

		#region Public Methods

		/// <summary>
		///   Return the singleton CryptoConfig
		/// </summary>
		/// <returns></returns>
		public static CryptoConfig GetInstance()
		{
			if (cryptoConfigInstance == null)
			{
				lock (cryptoConfigSyncRoot)
				{
					if (cryptoConfigInstance == null)
					{
						cryptoConfigInstance = new CryptoConfig();
						cryptoConfigInstance.Initialize();
					}

				}
			}

			return cryptoConfigInstance;
		}

		/// <summary>
		///   Write the contents to disk.
		/// </summary>
		public void Write()
		{
			if (!File.Exists(configFile))
			{
				throw new ApplicationException(String.Format("Unable to locate security configuration file '{0}'", configFile));
			}

			XmlSerializerNamespaces nameSpaces = new XmlSerializerNamespaces();
			nameSpaces.Add(String.Empty, String.Empty);
			XmlSerializer serializer = new XmlSerializer(typeof(CryptoConfig));
			using (FileStream fileStream = File.Open(configFile, FileMode.Create, FileAccess.Write, FileShare.None))
			{
				serializer.Serialize(fileStream, this, nameSpaces);
				fileStream.Close();
			}
		}

		#endregion

		#region Private Methods
		/// <summary>
		///   If init is true, then initialize the data in this class based on the config file.
		/// </summary>
		private CryptoConfig()
		{
			rcd = new MTRcdClass();
			configFile = rcd.ConfigDir + @"security\mtsecurity.xml";
		}

		private void Initialize()
		{
			CryptoConfig cryptoConfig = null;
			if (File.Exists(configFile))
			{
				using (FileStream fileStream = File.Open(configFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
				{
					XmlSerializer serializer = new XmlSerializer(typeof(CryptoConfig));
					cryptoConfig = (CryptoConfig)serializer.Deserialize(fileStream);

					this.CryptoTypeName = cryptoConfig.CryptoTypeName;
					this.RSAConfig = cryptoConfig.RSAConfig;
				}
			}
			else
			{
				LoggingHelper.LogError(String.Format("Could not locate security configuration file '{0}'", configFile), "TODO: add new parameter");
				throw new ApplicationException(String.Format("Could not locate security configuration file '{0}'", configFile));
			}

			LoggingHelper.LogDebug("[MetraTech.Security.CryptoConfig]", "Finished initializing CryptoConfig");
		}

		#endregion
	}
}
