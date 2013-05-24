using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Xml;
using MetraTech.Interop.RCD;
using MetraTech.Security.DPAPI;
using MetraTech.SecurityFramework;

[assembly: Guid("4F93DB2E-21AF-4979-8784-0459C9D9B95F")]
namespace MetraTech.Security.Crypto
{
	#region ICryptoManager implementation

	/// <summary>
	/// 
	/// </summary>
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("54D6180C-25D9-4c3e-B6F0-51F4775A67CD")]
	public class CryptoManager : ICryptoManager
	{
		#region Constants

		public const string SecurityFrameworkRootConfig = "MtSfConfigurationLoader.xml";

		#endregion

		#region Constructor
		/// <summary>
		///    Constructor
		/// </summary>
		public CryptoManager()
		{
			try
			{
				logger = new Logger("[MetraTech.Security.Crypto]");
				// Create the correct implementation based on configuration
				Initialize();
				// logger.LogDebug("Initialized CryptoManager");
			}
			catch (Exception e)
			{
				logger.LogException("Failed to initialize CryptoManager", e);
			}
		}
		#endregion

		#region ICryptoManager implementation

		/// <summary>
		///   The crypto provider specified in the security configuration file
		/// </summary>
		public CryptoProvider CryptoProvider
		{
			get
			{
				CryptoProvider cryptoProvider = CryptoProvider.Unknown;
				if (cryptoManager != null)
				{
					cryptoProvider = cryptoManager.CryptoProvider;
				}

				return cryptoProvider;
			}
		}

		/// <summary>
		///   Encrypt the given plainText based on the specified CryptKeyClass.
		///   The encrypted string will have the key id prepended to it.
		/// </summary>
		/// <param name="keyClass"></param>
		/// <param name="plainText"></param>
		/// <returns></returns>
		public string Encrypt(CryptKeyClass keyClass, string plainText)
		{
			if (cryptoManager == null)
			{
				logger.LogError("No 'CryptoTypeName' specified in security config. Unable to perform operation");
				return null;
			}

			string cipherText = String.Empty;

			// If this is Ticketing, use MSCryptoManager
			if (keyClass == CryptKeyClass.Ticketing)
			{
				MSCryptoManager msCryptoManager = new MSCryptoManager();
				cipherText = msCryptoManager.Encrypt(keyClass, plainText);
			}
			else
			{
				cipherText = cryptoManager.Encrypt(keyClass, plainText);
			}

			// logger.LogDebug(String.Format("Encrypted plaintext '{0}' to ciphertext '{1}'", plainText, cipherText));
			return cipherText;
		}

		/// <summary>
		///   Decrypt the given cipherText based on the specified CryptKeyClass.
		///   The cipherText string must have the key id prepended to it.
		/// </summary>
		/// <param name="keyClass"></param>
		/// <param name="cipherText"></param>
		/// <returns></returns>
		public string Decrypt(CryptKeyClass keyClass, string cipherText)
		{

			if (cryptoManager == null)
			{
				logger.LogError("No 'CryptoTypeName' specified in security config. Unable to perform operation");
				return null;
			}

			string plainText = String.Empty;

			// If this is Ticketing, use MSCryptoManager
			if (keyClass == CryptKeyClass.Ticketing)
			{
				MSCryptoManager msCryptoManager = new MSCryptoManager();
				plainText = msCryptoManager.Decrypt(keyClass, cipherText);
			}
			else
			{
				plainText = cryptoManager.Decrypt(keyClass, cipherText);
			}

			// logger.LogDebug(String.Format("Decrypted ciphertext '{0}' to plaintext '{1}'", cipherText , plainText));
			return plainText;
		}

		/// <summary>
		///   Hash the given plainText based on the specified HashKeyClass.
		///   The cipherText string will have the KMS key id prepended to it.  
		/// </summary>
		/// <param name="keyClass"></param>
		/// <param name="plainText"></param>
		/// <returns></returns>
		public string Hash(HashKeyClass keyClass, string plainText)
		{
			if (cryptoManager == null)
			{
				MSCryptoManager msCryptoManager = new MSCryptoManager();
				return msCryptoManager.Hash(keyClass, plainText);
			}

			string hash = cryptoManager.Hash(keyClass, plainText);
			// logger.LogDebug(String.Format("Hashing plainText '{0}' to cipherText '{1}'", plainText, hash));

			return hash;

		}

		/// <summary>
		///   Hash the given plainText based on the specified HashKeyClass, and key id.
		///   The cipherText string will have the KMS key id prepended to it.  
		/// </summary>
		/// <param name="keyClass"></param>
		/// <param name="keyID"></param>
		/// <param name="plainText"></param>
		/// <returns></returns>
		public string HashWithKey(HashKeyClass keyClass, string keyID, string plainText)
		{
			if (cryptoManager == null)
			{
				MSCryptoManager msCryptoManager = new MSCryptoManager();
				return msCryptoManager.HashWithKey(keyClass, keyID, plainText);
			}

			string hash = cryptoManager.HashWithKey(keyClass, keyID, plainText);
			// logger.LogDebug(String.Format("Hashing plainText '{0}' to cipherText '{1}'", plainText, hash));

			return hash;
		}

		/// <summary>
		///   Return true if the hash of the given plainText matches the specified hash.
		///   The hash string will have the KMS key id prepended to it.  
		/// </summary>
		/// <param name="keyClass"></param>
		/// <param name="hash"></param>
		/// <param name="plainText">The salted password</param>
		/// <returns></returns>
		public bool CompareHash(HashKeyClass keyClass, string hash, string plainText)
		{
			if (cryptoManager == null)
			{
				MSCryptoManager msCryptoManager = new MSCryptoManager();
				return msCryptoManager.CompareHash(keyClass, hash, plainText);
			}

			bool comparison = cryptoManager.CompareHash(keyClass, hash, plainText);

			// logger.LogDebug(String.Format("Comparing plainText '{0}' with cipherText '{1}'", plainText, hash));

			return comparison;
		}

		/// <summary>
		/// Return the key used to create the passed in hash.
		/// </summary>
		/// <param name="hashString"></param>
		/// <returns></returns>
		public string ParseKeyFromHash(string hashString)
		{
			if (cryptoManager == null)
			{
				MSCryptoManager msCryptoManager = new MSCryptoManager();
				return msCryptoManager.ParseKeyFromHash(hashString);
			}

			string key = cryptoManager.ParseKeyFromHash(hashString);

			// logger.LogDebug(String.Format("Key '{0}'", key));

			return key;
		}

		/// <summary>
		/// used from the installer to free RSA handle and unlock kms.cache file
		/// Handle was made static for performance reason
		/// </summary>
		public void FreeHandles()
		{
			if (cryptoManager != null)
			{
				cryptoManager.FreeHandles();
			}
		}

		#endregion

		#region Public Methods
		/// <summary>
		///   Encrypt items in the following files:
		///   (1) All servers.xml under RMP\config and RMP\extension
		///   (2) RMP\config\serveraccess\protectedpropertylist.xml
		///   (3) RMP\extensions\paymentsvr\config\PaymentServer\signiologin.xml
		/// </summary>
		public void EncryptPasswords()
		{
			IMTRcd rcd = new MTRcdClass();

			#region Servers.xml
			string[] configDirFiles = Directory.GetFiles(rcd.ConfigDir, "servers.xml", SearchOption.AllDirectories);
			string[] extensionDirFiles = Directory.GetFiles(rcd.ExtensionDir, "servers.xml", SearchOption.AllDirectories);

			List<string> tagNames = new List<string>();
			tagNames.Add("password");

			foreach (string file in configDirFiles)
			{
				EncryptXmlData(file, tagNames, CryptKeyClass.DatabasePassword);
			}

			foreach (string file in extensionDirFiles)
			{
				EncryptXmlData(file, tagNames, CryptKeyClass.DatabasePassword);
			}
			#endregion

			#region protectedpropertylist.xml
			// RMP\config\serveraccess\protectedpropertylist.xml
			string protectedPropertyFile =
			  Path.Combine(rcd.ConfigDir, "serveraccess" + Path.DirectorySeparatorChar + "protectedpropertylist.xml");

			if (File.Exists(protectedPropertyFile))
			{
				tagNames.Clear();
				tagNames.Add("value");

				EncryptXmlData(protectedPropertyFile, tagNames, CryptKeyClass.Ticketing);
			}
			else
			{
				logger.LogDebug(String.Format("File '{0}' does not exist.", protectedPropertyFile));
			}
			#endregion

			#region signiologin.xml
			// RMP\extensions\paymentsvr\config\PaymentServer\signiologin.xml
			string signiologinFile =
			  Path.Combine(rcd.ExtensionDir, "paymentsvr" +
											 Path.DirectorySeparatorChar +
											 "config" +
											 Path.DirectorySeparatorChar +
											 "paymentserver" +
											 Path.DirectorySeparatorChar +
											 "signiologin.xml");

			if (File.Exists(signiologinFile))
			{
				tagNames.Clear();
				tagNames.Add("value");

				EncryptXmlData(signiologinFile, tagNames, CryptKeyClass.PaymentInstrument);
			}
			else
			{
				logger.LogDebug(String.Format("File '{0}' does not exist.", signiologinFile));
			}
			#endregion

			#region WorldPayConfig.xml

			string fileName = Path.Combine(rcd.ExtensionDir, "PaymentSvr" +
															 Path.DirectorySeparatorChar +
															 "config" +
															 Path.DirectorySeparatorChar +
															 "Gateway" +
															 Path.DirectorySeparatorChar +
															 "WorldPayConfig.xml");

			string tagName = "credential";
			string attributeName = "password";
			EncryptXmlDataForAttributes(fileName, tagName, attributeName, CryptKeyClass.WorldPayPassword);

			#endregion
		}
		#endregion

		#region Public Static Methods
		/// <summary>
		///   Return true if the given keyClassName is valid.
		/// </summary>
		/// <param name="keyClassName"></param>
		/// <returns></returns>
		public static bool IsKeyClassNameValid(string keyClassName)
		{
			bool isValid = true;

			if (!IsHashKeyClassName(keyClassName) && !IsCryptKeyClassName(keyClassName))
			{
				isValid = false;
			}

			return isValid;
		}

		/// <summary>
		///   Return true if the given keyClassName is a CryptKeyClass.
		/// </summary>
		/// <param name="keyClassName"></param>
		/// <returns></returns>
		public static bool IsCryptKeyClassName(string keyClassName)
		{
			bool isValid = false;

			List<string> keyClassNames = CryptKeyClassNames;

			foreach (string name in keyClassNames)
			{
				if (name.ToLower() == keyClassName.ToLower())
				{
					isValid = true;
					break;
				}
			}
			return isValid;
		}

		/// <summary>
		///   Return true if the given keyClassName is a HashKeyClass.
		/// </summary>
		/// <param name="keyClassName"></param>
		/// <returns></returns>
		public static bool IsHashKeyClassName(string keyClassName)
		{
			bool isValid = false;

			List<string> keyClassNames = HashKeyClassNames;

			foreach (string name in keyClassNames)
			{
				if (name.ToLower() == keyClassName.ToLower())
				{
					isValid = true;
					break;
				}
			}
			return isValid;
		}

		#endregion

		#region Public Properties

		/// <summary>
		///    Key class names for CryptKeyClass
		/// </summary>
		public static List<string> CryptKeyClassNames
		{
			get
			{
				List<string> keyClassNames = new List<string>();
				foreach (string keyClassName in Enum.GetNames(typeof(CryptKeyClass)))
				{
					keyClassNames.Add(keyClassName);
				}

				return keyClassNames;
			}
		}

		/// <summary>
		///    Key class names for HashKeyClass
		/// </summary>
		public static List<string> HashKeyClassNames
		{
			get
			{
				List<string> keyClassNames = new List<string>();
				foreach (string keyClassName in Enum.GetNames(typeof(HashKeyClass)))
				{
					keyClassNames.Add(keyClassName);
				}

				return keyClassNames;
			}
		}
		#endregion

		#region Private Methods

		private void Initialize()
		{
			using (MTComSmartPtr<IMTRcd> rcd = new MTComSmartPtr<IMTRcd>())
			{
				rcd.Item = new MTRcdClass();
				rcd.Item.Init();

				string path = Path.Combine(rcd.Item.ConfigDir, @"Security\Validation", SecurityFrameworkRootConfig);
				logger.LogDebug("Security framework path: {0}", path);
				SecurityKernel.Initialize(new MetraTech.SecurityFramework.Serialization.XmlSerializer(), path); //Initialize with the Security Framework properties
				SecurityKernel.Start(); //Start the Security Kernel
			}

			CryptoConfig config = SecurityKernel.Encryptor.Properties.CryptoConfig;
			if (!String.IsNullOrEmpty(config.CryptoTypeName))
			{
				cryptoManager = Activator.CreateInstance(Type.GetType(config.CryptoTypeName, true, true)) as ICryptoManager;
				if (cryptoManager == null)
				{
					throw new ApplicationException(String.Format("Unable to create an instance of type '{0}'", config.CryptoTypeName));
				}
			}

		}

		/// <summary>
		///    Encrypt the contents of each of the xml elements specified in tagNames in the
		///    specified file based on the specified keyClass.
		///  
		///    If the element has an encrypted attribute whose value is true, it will be ignored.
		/// </summary>
		/// <param name="fileName"></param>
		/// <param name="tagNames"></param>
		/// <param name="keyClass"></param>
		private void EncryptXmlData(string fileName, List<string> tagNames, CryptKeyClass keyClass)
		{
			bool fileModified = false;
			logger.LogDebug(String.Format("Attempting to encrypt passwords in file '{0}' for key class '{1}'", fileName, keyClass));
			XmlDocument xmlDoc = new XmlDocument();
			xmlDoc.PreserveWhitespace = true;
			xmlDoc.Load(fileName);

			foreach (string tag in tagNames)
			{
				XmlNodeList nodes = xmlDoc.SelectNodes("//" + tag);
				XmlAttribute encrypted = null;

				foreach (XmlNode node in nodes)
				{
					XmlNode serverType = node.ParentNode.SelectSingleNode("servertype");

					// Skip encrypted nodes
					encrypted = node.Attributes["encrypted"];
					if (encrypted != null && encrypted.Value == "true")
					{
						if (serverType != null)
						{
							logger.LogDebug(String.Format("'{0}' is already encrypted for servertype '{1}' in file '{2}'", tag, serverType.InnerText, fileName));
						}
						else
						{
							logger.LogDebug(String.Format("'{0}' is already encrypted in file '{1}'", tag, fileName));
						}
						continue;
					}

					// Encrypt
					node.InnerText = Encrypt(keyClass, node.InnerText);
					// Add or update the attribute
					if (encrypted == null)
					{
						((XmlElement)node).SetAttribute("encrypted", "true");
					}
					else
					{
						encrypted.Value = "true";
					}

					logger.LogDebug(String.Format("Encrypted value for item '{0}' to '{1}'", node.Name, node.InnerText));
					fileModified = true;
				}
			}

			if (fileModified)
			{
				using (XmlTextWriter textWriter = new XmlTextWriter(fileName, null))
				{
					xmlDoc.Save(textWriter);
					textWriter.Close();
				}
			}
		}

		private void EncryptXmlDataForAttributes(string fileName, string tagName, string passAttrName, CryptKeyClass keyClass)
		{
			bool fileModified = false;
			logger.LogDebug(String.Format("Attempting to encrypt passwords in file '{0}' for key class '{1}'", fileName, keyClass));

			var xmlDoc = new XmlDocument();
			xmlDoc.PreserveWhitespace = true;
			xmlDoc.Load(fileName);
			var nodes = xmlDoc.SelectNodes("//" + tagName);

			foreach (XmlNode node in nodes)
			{
				XmlAttribute encrypted = node.Attributes["encrypted"];
				if (encrypted != null && encrypted.Value.Equals("true"))
				{
					logger.LogDebug(String.Format("'{0}' is already encrypted in file '{1}'", passAttrName, fileName));
					continue;
				}

				var passAttr = node.Attributes[passAttrName];
				if (passAttr == null)
				{
					throw new NullReferenceException(string.Format("Attribute {0} is missed in element {1}. Check file {2}", passAttrName, node.Name, fileName));
				}

				passAttr.Value = Encrypt(keyClass, passAttr.Value);

				if (encrypted == null)
				{
					((XmlElement)node).SetAttribute("encrypted", "true");
				}
				else
				{
					encrypted.Value = "true";
				}

				logger.LogDebug(String.Format("Encrypted value for item '{0}' to '{1}'", passAttr.Value, tagName));
				fileModified = true;
			}

			if (fileModified)
			{
				using (XmlTextWriter textWriter = new XmlTextWriter(fileName, null))
				{
					try
					{
						xmlDoc.Save(textWriter);
						textWriter.Close();
					}
					catch (Exception commonExc)
					{
						logger.LogException(string.Format("Error when saving a file {0}", fileName), commonExc);
						throw;
					}
				}
			}
		}
		#endregion

		#region Data
		private ICryptoManager cryptoManager;
		private Logger logger;
		#endregion
	}

	#endregion
}