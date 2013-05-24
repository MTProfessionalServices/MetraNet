/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Anatoliy Lokshin <alokshin@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using MetraTech.Security.Crypto;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Core.Common.Logging;

namespace MetraTech.SecurityFramework.Core.Encryptor
{
	/// <summary>
	/// Provides cryptographic utility methods: random keys generation and so on.
	/// </summary>
	internal static class CryptoUtils
	{
		#region Constants

		private static string PaymentInstrumentGuid = "a6e7b72c-5a68-4a0e-a581-f9555ab9fa8e";
		private static string DatabasePasswordGuid = "cbb23d8d-8189-4039-a575-a7388c369d99";
		private static string ServiceDefPropGuid = "ff3cb2c7-bcaf-4653-b20b-620d8713463d";
		private static string QueryStringPropGuid = "824219bc-1ea5-49de-8318-ec8ba8de67c7";
		private static string TicketingGuid = "db09c1ce-9969-43d3-a346-a5cb18f1d366";
		//private static string userPasswordGuid = "10cdb845-bf6d-4883-beee-003368360067";
		private static string PasswordHashGuid = "1095ffa1-8cfb-46cc-b30e-2d5d32c0e848";
		private static string PaymentInstrumentHashGuid = "a2a89816-cd39-4108-9887-3a993d444e85";
		private static string WorldPayPassword = "46073E3D-0E41-43BA-8EB1-F1C8C5ACBC08";

		private const string CryptoSetupTag = "[MetraTech.Security.Crypto.MSCryptoManager]";

		//constants for RSA
		private static readonly object SyncRoot = new object();
		//private const int KmsSuccess = 0;
		private const char KeyIdSeparator = '|';

		#endregion

		#region Private Fields

		private static int _kmsHandle = 0;

		#endregion

		/// <summary>
		/// Makes an ID for the engine by the specified category and key class name.
		/// </summary>
		/// <param name="category"></param>
		/// <param name="keyClassName"></param>
		/// <returns></returns>
		internal static string GetEngineId(EncryptorEngineCategory category, string keyClassName)
		{
			return string.Format("{0}.{1}", category, keyClassName);
		}

		/// <summary>
		///   Use Rfc2898DeriveBytes to generate a key and IV for Rijndael256 using
		///   the given password.
		/// </summary>
		/// <param name="password">A password for encryption.</param>
		/// <param name="base64Key">A BASE 64 encoded generated key.</param>
		/// <param name="base64Iv">A BASE 64 encoded generated initialization vector.</param>
		/// <returns></returns>
		internal static void CreateKey(string password, out string base64Key, out string base64Iv)
		{
			byte[] salt = new byte[] { 0, 1, 2, 3, 4, 5, 6, 7 };
			Rfc2898DeriveBytes pwdGen = new Rfc2898DeriveBytes(password, salt, 1000);

			// Generate a 32 byte (256 bit) key from the password
			byte[] bytes = pwdGen.GetBytes(32);
			base64Key = Convert.ToBase64String(bytes);

			// Generate a 32 byte (256 bit) IV from the password hash
			bytes = pwdGen.GetBytes(32);
			base64Iv = Convert.ToBase64String(bytes);
		}

		#region SHA

		/// <summary>
		///   Hash SHA256
		/// </summary>
		/// <param name="plainText">A data to be hashed.</param>
		/// <returns>A BASE 64 encoded hash of an input data.</returns>
		internal static string HashSha256(string plainText)
		{
			string cipherText = String.Empty;

			byte[] encodedPlainText = Encoding.Unicode.GetBytes(plainText);

			using(SHA256Managed hashingObj = new SHA256Managed())
			{
                byte[] hashCode = hashingObj.ComputeHash(encodedPlainText);

                cipherText = Convert.ToBase64String(hashCode);
                hashingObj.Clear();
            }

            return cipherText;
		}

		/// <summary>
		/// Parse the key id out of the hashed string.
		/// </summary>
		/// <param name="hashString"></param>
		/// <returns></returns>
		internal static string ParseKeyFromHashSha256(string hashString)
		{
			string textWithoutKey = null;
			Guid keyId = ParseKeyIdMicrosoft(hashString, out textWithoutKey);
			return keyId.ToString();
		}

		/// <summary>
		///   Return true if the hash of the given plainText matches the specified hash.
		/// </summary>
		/// <param name="keyClassName"></param>
		/// <param name="hash"></param>
		/// <param name="plainText">The salted password</param>
		/// <returns></returns>
		internal static bool CompareHashSha(string keyClassName, string hash, string plainText)
		{
			string keyId = ParseKeyFromHashSha256(hash);
			string newHash = HashWithKeySha(keyClassName, keyId, plainText);
			return (hash == newHash);
		}

		/// <summary>
		///   Hash the given plainText based on the specified KeyClassName, and key id.
		///   The cipherText string will have the KMS key id prepended to it.  
		/// </summary>
		/// <param name="keyClassName">A key name to hash an input with.</param>
		/// <param name="keyId">Must be a guid.</param>
		/// <param name="plainText">A value to be hashed.</param>
		/// <returns>A hash from <paramref name="plainText"/> prepended with the key ID.</returns>
		/// <exception cref="EncryptorInputDataException">When either an engine or the key ID not found.</exception>
		internal static string HashWithKeySha(string keyClassName, string keyId, string plainText)
		{
			string engineId = GetEngineId(EncryptorEngineCategory.MSHash, keyClassName);
			MSHashEngine engine = SecurityKernel.Encryptor.Api.GetEngine(engineId) as MSHashEngine;
			if (engine == null)
			{
				throw new EncryptorInputDataException(
					ExceptionId.Encryptor.General,
					EncryptorEngineCategory.MSHash,
					string.Format("Engine with ID \"{0}\" not found", engineId));
			}

			return engine.HashWithKey(keyId, plainText);
		}

		/// <summary>
		///    Expect the input text to be prefixed with a key which is a Guid. 
		///    Return the Guid and the remaining text in textWithoutKey.
		/// </summary>
		/// <param name="text"></param>
		/// <param name="textWithoutKey"></param>
		/// <returns></returns>
		internal static Guid ParseKeyIdMicrosoft(string text, out string textWithoutKey)
		{
			Guid keyId = Guid.Empty;
			int length = Guid.Empty.ToString().Length;
			string guid = text.Substring(0, length);

			if (!String.IsNullOrEmpty(guid))
			{
				keyId = new Guid(guid);
			}

			textWithoutKey = text.Substring(length);

			return keyId;
		}

		#endregion

		#region DPAPI methods

		/// <summary>
		/// Generates an entropy for DPAPI encryption.
		/// </summary>
		/// <returns></returns>
		internal static string GetEntropy()
		{
			Random random = new Random(987654321);

			StringBuilder entropy = new StringBuilder();
			for (int i = 0; i < 5; i++)
			{
				entropy.Append(random.Next());
			}

			return entropy.ToString();
		}

		/// <summary>
		/// Encrypts an input data using the DPAPI.
		/// </summary>
		/// <param name="value">A data to be encrypted.</param>
		/// <returns>BASE 64 encoded encryption result.</returns>
		internal static string ProtectData(string value)
		{
			string cipherText;
			try
			{
				string entropy = CryptoUtils.GetEntropy();

				byte[] encodedPlaintext = Encoding.UTF8.GetBytes(value);
				byte[] encodedEntropy = Encoding.UTF8.GetBytes(entropy);

				byte[] ciphertext = ProtectedData.Protect(encodedPlaintext, encodedEntropy, DataProtectionScope.LocalMachine);

				cipherText = Convert.ToBase64String(ciphertext);
			}
			catch (Exception ex)
			{
				throw new EncryptorInputDataException(ExceptionId.Encryptor.General, EncryptorEngineCategory.ProtectData, ex.Message, ex);
			}

			return cipherText;
		}

		/// <summary>
		/// Decrypts an input data using the DPAPI.
		/// </summary>
		/// <param name="value">A BASE 64 encoded encrypted data.</param>
		/// <returns>Decryption result.</returns>
		internal static string UnprotectData(string value)
		{
			string plainText;
			try
			{
				string entropy = CryptoUtils.GetEntropy();

				byte[] ciphertext = Convert.FromBase64String(value);
				byte[] encodedEntropy = Encoding.UTF8.GetBytes(entropy);

				byte[] encodedPlaintext = ProtectedData.Unprotect(ciphertext, encodedEntropy, DataProtectionScope.LocalMachine);

				plainText = Encoding.UTF8.GetString(encodedPlaintext);
			}
			catch (CryptographicException ex)
			{
				throw new EncryptorInputDataException(ExceptionId.Encryptor.BadEncryptedData, EncryptorEngineCategory.UnprotectData, ex.Message, ex);
			}
			catch (FormatException ex)
			{
				throw new EncryptorInputDataException(ExceptionId.Encryptor.BadEncodedData, EncryptorEngineCategory.UnprotectData, ex.Message, ex);
			}
			catch (Exception ex)
			{
				throw new EncryptorInputDataException(ExceptionId.Encryptor.General, EncryptorEngineCategory.UnprotectData, ex.Message, ex);
			}
			return plainText;
		}

		#endregion

		#region RSA

		/// <summary>
		/// Initializes KMS Client
		/// </summary>
		/// <returns>KMS Handle</returns>
		internal static int InitKMS()
		{

			lock (SyncRoot)
			{
				if (_kmsHandle == 0)
				{
					// Read password from encrypted config
					string clientPwd = SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig.KmsCertificatePwd.Password;

					if (SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig.KmsCertificatePwd.Encrypted)
					{
						clientPwd = SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig.KmsCertificatePwd.Password.UnprotectData();
					}

					LoggingHelper.LogDebug("SecurityFramework.RSAEncryptorEngine.InitKMS",
						String.Format("Initializing KMClient using configuration file '{0}'",
						SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig.KmsClientConfigFile));
					
					_kmsHandle = KMClientWrapper.KMSInit(SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig.KmsClientConfigFile, clientPwd);
					if (_kmsHandle == 0)
					{
						//LoggingHelper.Log("Failed to initialize KM Client");
						throw new SecurityFrameworkException("Failed to initialize KM Client");
					}
				}
			}

			return _kmsHandle;
		}


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
		internal static string GetKMSKeyClass(string keyClass)
		{
			return (from kmsKeyClass in SecurityKernel.Encryptor.Properties.CryptoConfig.RSAConfig.KMSKeyClasses
							where String.Equals(kmsKeyClass.Id, keyClass, StringComparison.InvariantCultureIgnoreCase)
							select kmsKeyClass.Name).FirstOrDefault();
		}

		/// <summary>
		/// remove the lock on the kms.cache file
		/// </summary>
		internal static void FreeHandles()
		{
			lock (SyncRoot)
			{
				if (_kmsHandle == 0) return;
				KMClientWrapper.KMSDestroy(_kmsHandle);
				_kmsHandle = 0;
			}
		}

		/// <summary>
		/// Retrives a Key by the specified ID.
		/// </summary>
		/// <param name="keyId">An ID of the key to be retrieved.</param>
		/// <returns>A key with the specified ID if found.</returns>
		internal static Key GetKey(Guid keyId)
		{
			List<string> errors = new List<string>();
			Key key = SecurityKernel.Encryptor.Properties.SessionKeyConfig.GetKey(keyId);
			if (key == null || !key.IsValid(errors))
			{
				throw new SecurityFrameworkException(String.Format("Could not get key for key class '{0}'", keyId));
			}

			return key;
		}

		/// <summary>
		/// Retrives a Key class name by the specified ID.
		/// </summary>
		/// <param name="keyId">An ID of the key to be retrieved.</param>
		/// <returns>A key class name for the key with the specified ID if found.</returns>
		internal static string GetKeyClassName(Guid keyId)
		{
			KeyClass keyClass = SecurityKernel.Encryptor.Properties.SessionKeyConfig.KeyClasses.FirstOrDefault(p => p.Keys.FirstOrDefault(k => k.Id == keyId) != null);
			if (keyClass == null)
			{
				throw new SecurityFrameworkException(String.Format("Could not get key class for key '{0}'", keyId));
			}

			return keyClass.Name;
		}

		/// <summary>
		///   Hash the given plainText based on the specified string.
		///   The cipherText string will have the KMS key id prepended to it.  
		/// </summary>
		/// <param name="keyClassName">Name of a key to encrypt the data with.</param>
		/// <param name="plainText"></param>
		/// <returns></returns>
		internal static string HashRsa(string keyClassName, string plainText)
		{
			string keyId = null;
			return HashRsa(keyClassName, plainText, keyId);
		}

		/// <summary>
		///   Return true if the hash of the given plainText matches the specified hash.
		///   The hash string will have the KMS key id prepended to it.  
		/// </summary>	
		/// <param name="keyClassName">Name of a key to encrypt the data with.</param>
		/// <param name="hash"></param>
		/// <param name="plainText">The salted password</param>
		/// <returns></returns>
		internal static bool CompareHashRsa(string keyClassName, string hash, string plainText)
		{
			bool match = false;

			string key = ParseKeyFromHashRsa(hash);
			string newHashedString = HashRsa(keyClassName, plainText, key);

			if (hash == newHashedString)
			{
				match = true;
			}

			return match;
		}

		/// <summary>
		/// Parse the key id out of the hashed string.
		/// </summary>
		/// <param name="hashString"></param>
		/// <returns></returns>
		internal static string ParseKeyFromHashRsa(string hashString)
		{
			string[] splitString = hashString.Split(new char[] { KeyIdSeparator });
			return splitString[0];
		}

		/// <summary>
		///    Create [TEMP]\key.cfg with the specified input and return the file name.
		/// </summary>
		/// <param name="pfxFile"></param>
		/// <param name="serverName"></param>
		/// <returns></returns>
		internal static string CreateRsaConfigFile(string pfxFile, string serverName)
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

		/// <summary>
		/// Hash the provided string and return the result.
		/// </summary>
		/// <param name="keyClassName">Name of a key to encrypt the data with.</param>
		/// <param name="inputData">string to hash</param>
		/// <param name="keyId">The keyID is optional. If it is null, then the current key is used.  Pass null for new hash.</param>
		/// <returns></returns>
		internal static string HashRsa(string keyClassName, string inputData, string keyId)
		{
		string engineId = GetEngineId(EncryptorEngineCategory.RSAHash, keyClassName);
			RSAHashEngine engine = SecurityKernel.Encryptor.Api.GetEngine(engineId) as RSAHashEngine;
			if (engine == null)
			{
				throw new EncryptorInputDataException(
					ExceptionId.Encryptor.General,
					EncryptorEngineCategory.MSHash,
					string.Format("Engine with ID \"{0}\" not found", engineId));
			}

			return engine.HashRsa(keyClassName: keyClassName, inputData: inputData, keyId: keyId);
		}

		#endregion

		#region Setup cryptography

		/// <summary>
		///   Create one session key for each key class. 
		///   If the given password is empty (or null), a hardcoded password is used.
		///   Existing keys, if any, are deleted. 
		///   Output is generated in RMP\config\security\sessionkeys.xml.
		/// </summary>
		internal static void CreateSessionKeys(string password, IEnumerable<string> keyClassNames)
		{
			Dictionary<string, string> keyClassKeys = new Dictionary<string, string>();

			//List<string> keyClassNames = new List<string>();
			//foreach (string keyClassName in Enum.GetNames(typeof(CryptKeyClass)))
			//{
			//    keyClassNames.Add(keyClassName);
			//}
			//foreach (string keyClassName in Enum.GetNames(typeof(HashKeyClass)))
			//{
			//    keyClassNames.Add(keyClassName);
			//}

			foreach (string keyClassName in keyClassNames)
			{
				if (String.IsNullOrEmpty(password))
				{
					keyClassKeys.Add(keyClassName, keyClassName);
				}
				else
				{
					keyClassKeys.Add(keyClassName, password);
				}
			}

			CreateSessionKeys(keyClassKeys);
		}

		/// <summary>
		///    Creates keys with the specified names.
		/// </summary>
		/// <param name="keyClassKeys"></param>
		internal static void CreateSessionKeys(Dictionary<string, string> keyClassKeys)
		{
			MSSessionKeyConfig sessionKeyConfig = MSSessionKeyConfig.GetInstance();

			sessionKeyConfig.Machine = Environment.MachineName;
			sessionKeyConfig.CreationDate = DateTime.Now;
			sessionKeyConfig.Process = Process.GetCurrentProcess().ProcessName;

			Dictionary<string, string> keyIds = GetKeyIds();

			foreach (string keyClassName in keyClassKeys.Keys)
			{
				KeyClass keyClass = new KeyClass();
				keyClass.Name = keyClassName;

				string userKey = keyClassKeys[keyClassName];
				string id = keyIds[keyClassName];

				if (String.IsNullOrEmpty(userKey))
				{
					throw new SecurityFrameworkException(String.Format("Missing user key for key class '{0}'", keyClassName));
				}

				if (String.IsNullOrEmpty(id))
				{
					throw new SecurityFrameworkException(String.Format("Cannot locate key id for key class '{0}'", keyClassName));
				}

				Key key = CreateKeyInternal(userKey, id, true);
				keyClass.AddKey(key);

				sessionKeyConfig.AddKeyClass(keyClass);
			}

			sessionKeyConfig.Write();
		}

		/// <summary>
		///   Return a mapping of key class enumerators
		/// </summary>
		/// <returns></returns>
		internal static Dictionary<string, string> GetKeyIds()
		{
			Dictionary<string, string> keyIds = new Dictionary<string, string>();
			keyIds.Add("PaymentInstrument", PaymentInstrumentGuid);
			keyIds.Add("DatabasePassword", DatabasePasswordGuid);
			keyIds.Add("ServiceDefProp", ServiceDefPropGuid);
			keyIds.Add("QueryString", QueryStringPropGuid);
			keyIds.Add("Ticketing", TicketingGuid);
			keyIds.Add("WorldPayPassword", WorldPayPassword);

			keyIds.Add("PasswordHash", PasswordHashGuid);
			keyIds.Add("PaymentMethodHash", PaymentInstrumentHashGuid);

			return keyIds;
		}


		/// <summary>
		///    Create a session key for the specified key class based on the specified password. 
		///    The existing keys for the specified keyclass will be deleted. 
		/// </summary>
		/// <param name="keyClassName"></param>
		/// <param name="password"></param>
		/// <remarks>It's recommended to call CryptoManager.IsKeyClassNameValid(keyClassName) before this method to check if the specified key name is valid.</remarks>
		internal static void CreateKey(string keyClassName, string password)
		{
			MSSessionKeyConfig sessionKeyConfig = MSSessionKeyConfig.GetInstance();
			sessionKeyConfig.Initialize();

			// Check that sessionkeys.xml is valid
			string error;
			if (!sessionKeyConfig.IsValid(out error))
			{
				LoggingHelper.LogError(
					CryptoSetupTag,
					String.Format("Invalid session key configuration in file '{0}' :" + error, sessionKeyConfig.KeyFile));
				throw new EncryptorInputDataException(
					ExceptionId.Encryptor.General,
					EncryptorEngineCategory.KeySetup,
					String.Format("Invalid session key configuration in file '{0}' :" + error, sessionKeyConfig.KeyFile));
			}

			sessionKeyConfig.Machine = Environment.MachineName;
			sessionKeyConfig.CreationDate = DateTime.Now;
			sessionKeyConfig.Process = Process.GetCurrentProcess().ProcessName;

			Dictionary<string, string> keyIds = GetKeyIds();

			KeyClass keyClass = sessionKeyConfig.GetKeyClass(keyClassName);
			if (keyClass == null)
			{
				keyClass = new KeyClass() { Name = keyClassName };
				sessionKeyConfig.AddKeyClass(keyClass);
			}

			keyClass.ClearKeys();
			string id = keyIds[keyClass.Name];
			Key key = CreateKeyInternal(password, id, true);
			keyClass.AddKey(key);

			sessionKeyConfig.Write();
		}

		/// <summary>
		///    Create a session key for the specified key class based on the specified password and identifier.
		///    If makeCurrent is true, the key will be made the current key for the given key class.
		/// </summary>
		/// <param name="keyClassName"></param>
		/// <param name="password"></param>
		/// <param name="id"></param>
		/// <param name="makeCurrent"></param>
		/// <remarks>It's recommended to call CryptoManager.IsKeyClassNameValid(keyClassName) before this method to check if the specified key name is valid.</remarks>
		internal static void AddKey(string keyClassName, string password, Guid id, bool makeCurrent)
		{
			Debug.Assert(id != Guid.Empty);

			// Check that the input id doesn't already exist
			Dictionary<string, string> keyIds = GetKeyIds();
			foreach (string keyId in keyIds.Values)
			{
				if (string.Compare(keyId, id.ToString(), StringComparison.InvariantCultureIgnoreCase) == 0)
				{
					throw new EncryptorInputDataException(
						ExceptionId.Encryptor.General,
						EncryptorEngineCategory.KeySetup,
						String.Format("The specified key id '{0}' already exists.", id.ToString()));
				}
			}

			//// Check that keyClassName is valid
			//if (!CryptoManager.IsKeyClassNameValid(keyClassName))
			//{
			//    throw new ApplicationException(String.Format("The specified key class '{0}' is invalid.", keyClassName));
			//}

			MSSessionKeyConfig sessionKeyConfig = MSSessionKeyConfig.GetInstance();
			sessionKeyConfig.Initialize();

			// Check that sessionkeys.xml is valid
			string error;
			if (!sessionKeyConfig.IsValid(out error))
			{
				LoggingHelper.LogError(CryptoSetupTag, String.Format("Invalid session key configuration in file '{0}' :" + error, sessionKeyConfig.KeyFile));
				throw new EncryptorInputDataException(
					ExceptionId.Encryptor.General,
					EncryptorEngineCategory.KeySetup,
					String.Format("Invalid session key configuration in file '{0}' :" + error, sessionKeyConfig.KeyFile));
			}

			sessionKeyConfig.Machine = Environment.MachineName;
			sessionKeyConfig.CreationDate = DateTime.Now;
			sessionKeyConfig.Process = Process.GetCurrentProcess().ProcessName;

			foreach (KeyClass keyClass in sessionKeyConfig.KeyClasses)
			{
				if (string.Compare(keyClass.Name, keyClassName, StringComparison.InvariantCultureIgnoreCase) == 0)
				{
					Key key = CreateKeyInternal(password, id.ToString(), makeCurrent);
					keyClass.AddKey(key);
					break;
				}
			}

			sessionKeyConfig.Write();
		}

		/// <summary>
		///    Make the key specified by the given id to be the current key.
		/// </summary>
		/// <param name="id"></param>
		internal static void MakeKeyCurrent(Guid id)
		{
			MSSessionKeyConfig sessionKeyConfig = MSSessionKeyConfig.GetInstance();
			sessionKeyConfig.Initialize();

			// Check that sessionkeys.xml is valid
			string error;
			if (!sessionKeyConfig.IsValid(out error))
			{
				LoggingHelper.LogError(CryptoSetupTag, String.Format("Invalid session key configuration in file '{0}' :" + error, sessionKeyConfig.KeyFile));
				throw new EncryptorInputDataException(
					ExceptionId.Encryptor.General,
					EncryptorEngineCategory.KeySetup,
					String.Format("Invalid session key configuration in file '{0}' :" + error, sessionKeyConfig.KeyFile));
			}

			sessionKeyConfig.Machine = Environment.MachineName;
			sessionKeyConfig.CreationDate = DateTime.Now;
			sessionKeyConfig.Process = Process.GetCurrentProcess().ProcessName;

			Key key = sessionKeyConfig.GetKey(id);
			if (key == null)
			{
				throw new SecurityFrameworkException(String.Format("Key '{0}' not found", id.ToString()));
			}

			sessionKeyConfig.MakeKeyCurrent(id);

			sessionKeyConfig.Write();
		}

		/// <summary>
		///   Delete the sessionkeys.xml file from RMP\config\security.
		/// </summary>
		internal static void DeleteSessionKeys(MSSessionKeyConfig sessionKeyConfig)
		{
			try
			{
				if (File.Exists(sessionKeyConfig.KeyFile))
				{
					File.Delete(sessionKeyConfig.KeyFile);
				}
			}
			catch (Exception)
			{
				LoggingHelper.LogError(CryptoSetupTag, String.Format("Unable to delete the session keys file '{0}' :", sessionKeyConfig.KeyFile));
			}
		}

		#endregion

		#region Private methods

		/// <summary>
		///    Create a key based on a password and id.
		/// </summary>
		/// <param name="password"></param>
		/// <param name="id">must be a Guid</param>
		/// <param name="makeCurrent">make this key current</param>
		/// <returns></returns>
		private static Key CreateKeyInternal(string password, string id, bool makeCurrent)
		{
			Key key = new Key();
			key.Id = new Guid(id);
			key.IsCurrent = makeCurrent;
			key.Secret = new CDATA(ProtectData(password));

			string value = null;
			string iv = null;
			CreateKey(password, out value, out iv);

			key.Value = new CDATA(ProtectData(value));
			key.IV = new CDATA(ProtectData(iv));

			return key;
		}
		#endregion
	}
}
