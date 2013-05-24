using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Xml.Serialization;
using MetraTech.Interop.RCD;

namespace MetraTech.Security.Crypto
{
	/// <summary>
	///   Password required to unlock the certificate which identifies the KMS client machine to the KMS server.
	/// </summary>
	[ComVisible(false)]
	public class RSAConfig
	{
		#region Private fields
		private string _kmsClientConfigFile;
		private IMTRcd _rcd = new MTRcdClass();
		#endregion

		#region Public properties

		/// <summary>
		///   Name of the identity group used in KMS for this installation.
		/// </summary>
		[XmlElement(ElementName = "kmsIdentityGroup", Type = typeof(string))]
		public string KmsIdentityGroup
		{
			get;
			set;
		}

		/// <summary>
		///   Name of the config file used by the KMSClient for this machine. 
		/// </summary>
		[XmlElement(ElementName = "kmsClientConfigFile", Type = typeof(string))]
		public string KmsClientConfigFile
		{
			get
			{
				//System.Threading.Thread.Sleep(30000);
				string pathRoot = Path.GetPathRoot(_kmsClientConfigFile);
				if (String.IsNullOrEmpty(pathRoot))
				{
					return Path.Combine(_rcd.ConfigDir, _kmsClientConfigFile);
				}

				return _kmsClientConfigFile;
			}
			set
			{
				//System.Threading.Thread.Sleep(30000);
				string pathRoot = Path.GetPathRoot(value);
				if (String.IsNullOrEmpty(pathRoot))
				{
					_kmsClientConfigFile = Path.Combine(_rcd.ConfigDir, value);
				}
				else
				{
					_kmsClientConfigFile = value;
				}
			}
		}

		/// <summary>
		///   Password used to unlock the .pfx file used by the KMSClient.
		/// </summary>
		[XmlElement(ElementName = "kmsCertificatePwd", Type = typeof(CertificatePassword))]
		public CertificatePassword KmsCertificatePwd
		{
			get;
			set;
		}

		/// <summary>
		///   Mapping of internal enum key class names to KMS key class names.
		/// </summary>
		[XmlElement(ElementName = "kmsKeyClass", Type = typeof(KMSKeyClass))]
		public KMSKeyClass[] KMSKeyClasses;

		#endregion

		#region Public Methods

		/// <summary>
		///   Return true if the contents of the specified kmsClientConfigFile is valid
		/// </summary>
		/// <param name="kmsClientConfigFile"></param>
		/// <param name="validationErrors"></param>
		/// <param name="kmsClientConfig"></param>
		/// <returns></returns>
		public static bool ValidateKmsClientConfigFile(string kmsClientConfigFile,
													   out List<string> validationErrors,
													   out KmsClientConfig kmsClientConfig)
		{
			//System.Threading.Thread.Sleep(30000);

			validationErrors = new List<string>();
			kmsClientConfig = null;

			// Check that the key.cfg has been specified
			if (String.IsNullOrEmpty(kmsClientConfigFile))
			{
				validationErrors.Add(
				  String.Format("Missing value for <kmsClientConfigFile> element in RMP\\config\\security\\mtsecurity.xml."));
				return false;
			}
			// Check that key.cfg exists 
			IMTRcd rcd = new MTRcdClass();
			string kmsConfigFile = Path.Combine(rcd.ConfigDir, kmsClientConfigFile);
			if (!File.Exists(kmsConfigFile))
			{
				validationErrors.Add(
				  String.Format("Cannot find file '{0}' specified in <kmsClientConfigFile> element in RMP\\config\\security\\mtsecurity.xml.", kmsConfigFile));
				return false;
			}

			string[] configFileLines = File.ReadAllLines(kmsConfigFile);
			if (configFileLines == null || configFileLines.Length == 0)
			{
				validationErrors.Add(
				  String.Format("Empty <kmsClientConfigFile> '{0}' specified in in RMP\\config\\security\\mtsecurity.xml.", kmsConfigFile));
				return false;
			}

			Dictionary<string, string> keyValues = new Dictionary<string, string>();
			bool invalidLine = false;
			foreach (string configFileLine in configFileLines)
			{
				string[] keyValue = configFileLine.Split('=');
				if (keyValue.Length != 2)
				{
					validationErrors.Add(
					  String.Format("Invalid line '{0}' found in '{1}'", configFileLine, kmsConfigFile));
					invalidLine = true;
				}
				else
				{
					keyValues.Add(keyValue[0].Trim(), keyValue[1].Trim());
				}
			}

			if (invalidLine)
			{
				return false;
			}

			kmsClientConfig = new KmsClientConfig();
			// Initialize kmsClientConfig 
			kmsClientConfig.CertificateFile = GetKeyValue("kms.sslPKCS12File", keyValues, validationErrors, kmsConfigFile);
			if (!String.IsNullOrEmpty(kmsClientConfig.CertificateFile))
			{
				if (!File.Exists(kmsClientConfig.CertificateFile))
				{
					validationErrors.Add(
					  String.Format("Cannot find certificate file '{0}' specified in 'kms.sslPKCS12File' in file '{1}'", kmsClientConfig.CertificateFile, kmsConfigFile));
				}
			}
			kmsClientConfig.Server = GetKeyValue("kms.address", keyValues, validationErrors, kmsConfigFile);
			kmsClientConfig.ServerPort = GetKeyValue("kms.port", keyValues, validationErrors, kmsConfigFile);
			kmsClientConfig.LogLevel = GetKeyValue("kms.debug", keyValues, validationErrors, kmsConfigFile);
			kmsClientConfig.LogFile = GetKeyValue("kms.logFile", keyValues, validationErrors, kmsConfigFile);
			kmsClientConfig.ConnectTimeout = GetKeyValue("kms.sslConnectTimeout", keyValues, validationErrors, kmsConfigFile);
			kmsClientConfig.Retries = GetKeyValue("kms.retries", keyValues, validationErrors, kmsConfigFile);
			kmsClientConfig.RetryDelay = GetKeyValue("kms.retryDelay", keyValues, validationErrors, kmsConfigFile);
			kmsClientConfig.CacheTimeToLive = GetKeyValue("kms.cacheTimeToLive", keyValues, validationErrors, kmsConfigFile);
			kmsClientConfig.CacheFile = GetKeyValue("kms.cacheFile", keyValues, validationErrors, kmsConfigFile);
			kmsClientConfig.MemoryCache = GetKeyValue("kms.memoryCache", keyValues, validationErrors, kmsConfigFile);

			if (validationErrors.Count > 0)
			{
				kmsClientConfig = null;
				return false;
			}

			return true;
		}

		private static string GetKeyValue(string key,
										  IDictionary<string, string> keyValues,
										  ICollection<string> validationErrors,
										  string kmsConfigFile)
		{
			string value = String.Empty;
			if (keyValues.ContainsKey(key))
			{
				value = keyValues[key];
				if (String.IsNullOrEmpty(value))
				{
					validationErrors.Add(String.Format("Missing value for '{0}' entry in '{1}'", key, kmsConfigFile));
				}
			}
			else
			{
				validationErrors.Add(
				  String.Format("Missing '{0}' entry in '{1}'", key, kmsConfigFile));
			}
			return value;
		}
		#endregion
	}
}
