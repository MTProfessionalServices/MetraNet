using System;
using System.Collections.Generic;
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
	public sealed class RSACryptoConfig
	{
		#region Private fields
		private static volatile RSACryptoConfig rsaCryptoConfigInstance;
		private static object rsaCryptoConfigSyncRoot = new Object();
		private string configFile;
		#endregion

		#region Public properties

		/// <summary>
		///   Name of the identity group used in KMS for this installation.
		/// </summary>
		[XmlElement(ElementName = "rsaConfig", Type = typeof(RSAConfig))]
		public RSAConfig RSAConfig
		{
			get;
			set;
		}

		#endregion

		#region Public Methods

		/// <summary>
		///   Return the singleton RSACryptoConfig
		/// </summary>
		/// <returns></returns>
		public static RSACryptoConfig GetInstance()
		{
			if (rsaCryptoConfigInstance == null)
			{
				lock (rsaCryptoConfigSyncRoot)
				{
					if (rsaCryptoConfigInstance == null)
					{
						rsaCryptoConfigInstance = new RSACryptoConfig();
						rsaCryptoConfigInstance.Initialize();
					}
				}
			}

			return rsaCryptoConfigInstance;
		}

		#endregion

		#region Private Methods

		/// <summary>
		///  Constructor
		/// </summary>
		private RSACryptoConfig()
		{
		}

		private void Initialize()
		{
			try
			{
				IMTRcd rcd = new MTRcdClass();
				configFile = rcd.ConfigDir + @"security\mtsecurity.xml";

				RSACryptoConfig cryptoConfig = null;

				if (File.Exists(configFile))
				{
					using (FileStream fileStream = File.Open(configFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
					{
						XmlSerializer serializer = new XmlSerializer(typeof(RSACryptoConfig));
						cryptoConfig = (RSACryptoConfig)serializer.Deserialize(fileStream);
						this.RSAConfig = cryptoConfig.RSAConfig;
						fileStream.Close();
					}
				}
			}
			catch (Exception e)
			{
				LoggingHelper.Log(e);
				throw;
			}

			LoggingHelper.LogDebug("[MetraTech.Security.RSACryptoConfig]", "Finished initializing RSACryptoConfig");
		}

		#endregion
	}
}
