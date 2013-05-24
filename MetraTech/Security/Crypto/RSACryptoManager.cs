using System;
using System.Text;
using System.Runtime.InteropServices;
using System.IO;
using MetraTech.Security.DPAPI;
using MetraTech.SecurityFramework;
using MetraTech.Interop.RCD;


namespace MetraTech.Security.Crypto
{
	/// <summary>
	/// 
	/// </summary>
	[ComVisible(false)]
	public class RSACryptoManager : ICryptoManager
	{

		#region Constructor
		/// <summary>
		///    Constructor
		/// </summary>
		public RSACryptoManager()
		{
			//System.Threading.Thread.Sleep(30000);
			try
			{
				logger = new Logger("[MetraTech.Security.Crypto.RSACryptoManager]");
				// Initialize the configuration
				Initialize();
			}
			catch (Exception e)
			{
				logger.LogException("Failed to initialize RSACryptoManager", e);
			}
		}
		#endregion

		#region ICryptoManager implementation

		/// <summary>
		///   CryptoProvider
		/// </summary>
		public CryptoProvider CryptoProvider
		{
			get
			{
				return CryptoProvider.RSA;
			}
		}

		/// <summary>
		///   Encrypt the given plainText based on the specified CryptKeyClass.
		///   The encrypted string will have the KMS key id prepended to it.
		/// </summary>
		/// <param name="keyClass"></param>
		/// <param name="plainText"></param>
		/// <returns></returns>
		public string Encrypt(CryptKeyClass keyClass, string plainText)
		{
			return String.IsNullOrEmpty(plainText) ? plainText : plainText.EncryptRsa(keyClass.ToString());

			//if (String.IsNullOrEmpty(plainText))
			//{
			//  return plainText;
			//}

			//int kmHandle = 0;
			//int BUFSIZE = plainText.Length * 200;  // make sure KMS knows our buffer will be big enough for the encrypted text
			//int encryptedDataLen = 0;
			//int status = 0;
			//int base64Flag = 1;
			//byte[] cipherTextBytes = new byte[BUFSIZE];

			//try
			//{
			//  byte[] plainTextBytes = Encoding.UTF8.GetBytes(plainText);

			//  // Initialize KMSClient
			//  kmHandle = InitKMS();
			//  // Retrieve the KMS key class
			//  string kmsKeyClass = GetKMSKeyClass(keyClass.ToString());
			//  if (String.IsNullOrEmpty(kmsKeyClass))
			//  {
			//    throw new ApplicationException(String.Format("No KMS Key class name found in configuration which matches '{0}'", keyClass.ToString()));
			//  }

			//  if ((status = KMClientWrapper.KMSEncryptData(kmHandle,
			//                                               kmsKeyClass,
			//                                               plainTextBytes,
			//                                               plainTextBytes.Length,
			//                                               cipherTextBytes,
			//                                               BUFSIZE,
			//                                               ref encryptedDataLen,
			//                                               base64Flag)) != KMS_SUCCESS)
			//  {
			//    throw new ApplicationException("Unable to encrypt data");
			//  }
			//}
			//catch (Exception exp)
			//{
			//  logger.LogException("KMSEncryptData Failed.", exp);
			//  throw;
			//}
			////finally
			////{
			////  KMClientWrapper.KMSDestroy(kmHandle);
			////}

			//return Encoding.UTF8.GetString(cipherTextBytes, 0, encryptedDataLen);
		}

		/// <summary>
		///   Decrypt the given cipherText based on the specified CryptKeyClass.
		///   The cipherText string must have the KMS key id prepended to it.
		/// </summary>
		/// <param name="keyClass"></param>
		/// <param name="cipherText"></param>
		/// <returns></returns>
		public string Decrypt(CryptKeyClass keyClass, string cipherText)
		{
			return String.IsNullOrEmpty(cipherText) ? cipherText : cipherText.DecryptRsa(keyClass.ToString());

			//if (String.IsNullOrEmpty(cipherText))
			//{
			//  return cipherText;
			//}

			//int kmHandle = 0;
			//int BUFSIZE = cipherText.Length;
			//int plainTextDataLen = 0;
			//int status = 0;
			//byte[] plainTextBytes = new byte[BUFSIZE];

			//try
			//{
			//  byte[] cipherTextBytes = Encoding.UTF8.GetBytes(cipherText);

			//  // Initialize KMSClient
			//  kmHandle = InitKMS();
			//  // Retrieve the KMS key class
			//  string kmsKeyClass = GetKMSKeyClass(keyClass.ToString());
			//  if (String.IsNullOrEmpty(kmsKeyClass))
			//  {
			//    throw new ApplicationException(String.Format("No KMS Key class name found in configuration which matches '{0}'", keyClass.ToString()));
			//  }

			//  if ((status = KMClientWrapper.KMSDecryptData(kmHandle,
			//                                               kmsKeyClass,
			//                                               cipherTextBytes,
			//                                               cipherTextBytes.Length,
			//                                               plainTextBytes,
			//                                               BUFSIZE,
			//                                               ref plainTextDataLen)) != KMS_SUCCESS)
			//  {
			//    throw new ApplicationException("Unable to decrypt data");
			//  }
			//}
			//catch (Exception exp)
			//{
			//  logger.LogException("KMSDecryptData Failed.", exp);
			//  throw;
			//}
			////finally
			////{
			////  KMClientWrapper.KMSDestroy(kmHandle);
			////}

			//return Encoding.UTF8.GetString(plainTextBytes, 0, plainTextDataLen);
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
			string keyID = null;
			return HashString(keyClass, plainText, keyID);
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
			return HashString(keyClass, plainText, keyID);
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
			return plainText.CompareHashRsa(keyClass.ToString(), hash);

			/*
						bool match = false;

						string key = ParseKeyFromHash(hash);
						string newHashedString = HashString(keyClass, plainText, key);

						if (hash == newHashedString)
						{
							match = true;
						}

						return match;
			*/
		}

		/// <summary>
		/// Parse the key id out of the hashed string.
		/// </summary>
		/// <param name="hashString"></param>
		/// <returns></returns>
		public string ParseKeyFromHash(string hashString)
		{
			return hashString.ParseKeyFromHashRsa();
			/*
						string[] splitString = hashString.Split(new char[] { CONST_KEY_ID_SEPARATOR });
						return splitString[0];
			*/
		}

		/// <summary>
		/// remove the lock on the kms.cache file
		/// </summary>
		public void FreeHandles()
		{
			lock (m_KMSHandleGuard)
			{
				if (m_KMSHandle != 0)
				{
					KMClientWrapper.KMSDestroy(m_KMSHandle);
					m_KMSHandle = 0;
				}
			}
		}

		#endregion

		#region Public Methods
		/// <summary>
		///    Create [TEMP]\key.cfg with the specified input and return the file name.
		/// </summary>
		/// <param name="pfxFile"></param>
		/// <param name="serverName"></param>
		/// <returns></returns>
		public string CreateConfigFile(string pfxFile,
																	 string serverName)
		{
			string fileName = Path.Combine(Path.GetTempPath(), "key.cfg");

			using (FileStream file = new FileStream(fileName, FileMode.Create, FileAccess.Write))
			{
				using (StreamWriter writer = new StreamWriter(file))
				{
					writer.WriteLine("kms.sslPKCS12File = " + pfxFile);
					writer.WriteLine("kms.sslPKCS12Password = ");
					writer.WriteLine("kms.address = " + serverName);
					writer.WriteLine("kms.port = 443");
					writer.WriteLine("kms.debug = true");
					writer.WriteLine("kms.logFile = " + Path.Combine(Path.GetTempPath(), "kms.log"));
					writer.WriteLine("kms.sslConnectTimeout = 10");
					writer.WriteLine("kms.retries = 2");
					writer.WriteLine("kms.retryDelay = 1");
					writer.WriteLine("kms.cacheTimeToLive = 345600");
					writer.WriteLine("kms.cacheFile = " + Path.Combine(Path.GetTempPath(), "kms.cache"));
					writer.WriteLine("kms.memoryCache = false");
				}

				file.Close();
			}

			return fileName;
		}
		#endregion

		#region Public Properties
		/// <summary>
		///   RSAConfig
		/// </summary>
		public RSAConfig RSAConfig
		{
			get { return cryptoConfig; }
		}
		#endregion

		#region Private Methods

		/// <summary>
		/// Hash the provided string and return the result.
		/// </summary>
		/// <param name="keyClass">KeyClass</param>
		/// <param name="inputData">string to hash</param>
		/// <param name="keyID">The keyID is optional. If it is null, then the current key is used.  Pass null for new hash.</param>
		/// <returns></returns>
		private string HashString(HashKeyClass keyClass, string inputData, string keyID)
		{
			return inputData.HashRsa(keyClass.ToString(), keyID);

			/*
						string b64ofEncHMACData = "";
						int status = 0;
						int kmHandle = 0;
						int KMS_BUFSIZE = 1024;
						byte[] hmacBuf = new byte[KMS_BUFSIZE];
						int hmacLen = 0;

						try
						{
							byte[] inputDataBytes = Encoding.UTF8.GetBytes(inputData);

							kmHandle = InitKMS();
							string kmsKeyClass = GetKMSKeyClass(keyClass.ToString());
							if (String.IsNullOrEmpty(kmsKeyClass))
							{
								throw new ApplicationException(String.Format("No KMS Key class name found in configuration which matches '{0}'", keyClass.ToString()));
							}

							if (keyID == null)
							{
								// Get a new key ID
								StringBuilder rKeyID = new StringBuilder(KMS_BUFSIZE);
								if ((status = KMClientWrapper.KMSGetKey(kmHandle, kmsKeyClass,
																												keyID, hmacBuf,
																												KMS_BUFSIZE, ref hmacLen,
																												rKeyID, KMS_BUFSIZE)) != KMS_SUCCESS)
								{
									throw new ApplicationException("GetKey failed: Error code = " + status);
								}
								keyID = rKeyID.ToString();
							}

							// Get hash
							if ((status = KMClientWrapper.KMSHMACData(kmHandle,
																												kmsKeyClass,
																												keyID,
																												inputDataBytes,
																												inputDataBytes.Length,
																												hmacBuf,
																												KMS_BUFSIZE,
																												ref hmacLen)) != KMS_SUCCESS)
							{
								throw new ApplicationException("HMACData failed: Error code = " + status);
							}

							// Base 64 encode and prepend the key ID to front of hash
							b64ofEncHMACData = Convert.ToBase64String(hmacBuf, 0, hmacLen);
							b64ofEncHMACData = keyID + CONST_KEY_ID_SEPARATOR + b64ofEncHMACData;
						}
						catch (Exception exp)
						{
							logger.LogException("KMSHMACData Failed.", exp);
							throw;
						}
						//finally
						//{
						//  KMClientWrapper.KMSDestroy(kmHandle);
						//}

						return b64ofEncHMACData;
			*/
		}

		private void Initialize()
		{
			using (MTComSmartPtr<IMTRcd> rcd = new MTComSmartPtr<IMTRcd>())
			{
				rcd.Item = new MTRcdClass();
				rcd.Item.Init();

				string path = Path.Combine(rcd.Item.ConfigDir, @"Security\Validation", CryptoManager.SecurityFrameworkRootConfig);
				logger.LogDebug("Security framework path: {0}", path);
				SecurityKernel.Initialize(new MetraTech.SecurityFramework.Serialization.XmlSerializer(), path); //Initialize with the Security Framework properties
				SecurityKernel.Start();

				cryptoConfig = RSACryptoConfig.GetInstance().RSAConfig;
			}
		}

/*
		private int InitKMS()
		{

			lock (m_KMSHandleGuard)
			{
				if (m_KMSHandle == 0)
				{
					// Read password from encrypted config
					string clientPwd = cryptoConfig.KmsCertificatePwd.Password;

					if (cryptoConfig.KmsCertificatePwd.Encrypted == true)
					{
						clientPwd = DPAPIWrapper.Decrypt(cryptoConfig.KmsCertificatePwd.Password);
					}

					logger.LogDebug(String.Format("Initializing KMClient using configuration file '{0}'",
																				cryptoConfig.KmsClientConfigFile));

					m_KMSHandle = KMClientWrapper.KMSInit(cryptoConfig.KmsClientConfigFile, clientPwd);
					if (m_KMSHandle == 0)
					{
						logger.LogError("Failed to initialize KM Client");
						throw new ApplicationException("Failed to initialize KM Client");
					}
				}
			}

			return m_KMSHandle;
		}
*/

/*
		/// <summary>
		///   Given a keyClass string which represents one of the enumerator values from
		///   CryptKeyClass or HashKeyClass, return the corresponding key class name for KMS
		///   based on the configuration information. 
		/// 
		///   The config file maps the enum value to a KMS key class name using an element 
		///   of the following type, where 'PasswordHash' is the value of the enum (HashKeyClass) 
		///   and MTDev_PasswordHash is the corresponding key class in KMS.
		/// 
		///   <kmsKeyClass id="PasswordHash">MTDev_PasswordHash</kmsKeyClass>
		/// </summary>
		/// <param name="keyClass"></param>
		/// <returns></returns>
		private string GetKMSKeyClass(string keyClass)
		{
			string kmsKeyClassName = null;

			foreach (KMSKeyClass kmsKeyClass in cryptoConfig.KMSKeyClasses)
			{
				if (String.Equals(kmsKeyClass.Id, keyClass.ToString(), StringComparison.InvariantCultureIgnoreCase))
				{
					kmsKeyClassName = kmsKeyClass.Name;
					break;
				}
			}
			return kmsKeyClassName;
		}
*/

		#endregion

		#region Data
/*
		private const char CONST_KEY_ID_SEPARATOR = '|';
*/
		private Logger logger;
		//private RSACryptoConfig cryptoConfig;
		private RSAConfig cryptoConfig;
/*
		private const int KMS_SUCCESS = 0;
*/

		private static object m_KMSHandleGuard = new object();
		private static int m_KMSHandle = 0;
		#endregion
	}

}
