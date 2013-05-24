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
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using MetraTech.Security.Crypto;
using MetraTech.SecurityFramework.Core.Encryptor;

namespace MetraTech.SecurityFramework
{
	public static class EncryptorExtensions
	{
		/// <summary>
		/// Protects data using DPAPI.
		/// </summary>
		/// <param name="input">A data to be protected.</param>
		/// <returns>BASE 64 encoded protected data.</returns>
		public static string ProtectData(this string input)
		{
			return SecurityKernel.Encryptor.Api.ExecuteDefaultByCategory(EncryptorEngineCategory.ProtectData.ToString(), input);
		}

		/// <summary>
		/// Protects data using DPAPI.
		/// </summary>
		/// <param name="input">A data to be decrypted.</param>
		/// <returns>Decrypted data.</returns>
		public static string UnprotectData(this string input)
		{
			return SecurityKernel.Encryptor.Api.ExecuteDefaultByCategory(EncryptorEngineCategory.UnprotectData.ToString(), input);
		}

		/// <summary>
		/// Encrypts the data with AES (Rijndael) algorithm.
		/// </summary>
		/// <param name="input">Data to be encrypted.</param>
		/// <param name="keyClassName">Name of a key to encrypt the data with.</param>
		/// <returns>BASE 64 encoded encryption result.</returns>
		/// <exception cref="EncryptorInputDataException">If some environment problem happens.</exception>
		public static string EncryptAes(this string input, string keyClassName)
		{
			string engineId = CryptoUtils.GetEngineId(EncryptorEngineCategory.MSEncrypt, keyClassName);
			return SecurityKernel.Encryptor.Api.Execute(engineId, input);
		}

		/// <summary>
		/// Decrypts the data encripted with AES (Rijndael) algorithm.
		/// </summary>
		/// <param name="input">BASE 64 encoded encrypted data.</param>
		/// <param name="keyClassName">Name of a key to encrypt the data with.</param>
		/// <returns>Decryption result.</returns>
		/// <exception cref="EncryptorInputDataException">If bad data passed to the method or some environment problem happens.</exception>
		public static string DecryptAes(this string input, string keyClassName)
		{
			string engineId = CryptoUtils.GetEngineId(EncryptorEngineCategory.MSDecrypt, keyClassName);
			return SecurityKernel.Encryptor.Api.Execute(engineId, input);
		}

		/// <summary>
		/// Decrypts the data encripted with AES (Rijndael) algorithm using the key, encoded to the passed value.
		/// </summary>
		/// <param name="input">BASE 64 encoded encrypted data.</param>
		/// <returns>Decryption result.</returns>
		/// <exception cref="EncryptorInputDataException">If bad data passed to the method or some environment problem happens.</exception>
		public static string DecryptAes(this string input)
		{
			string textWithoutKey;
			Guid keyId = CryptoUtils.ParseKeyIdMicrosoft(input, out textWithoutKey);
			string keyClassName = CryptoUtils.GetKeyClassName(keyId);

			string engineId = CryptoUtils.GetEngineId(EncryptorEngineCategory.MSDecrypt, keyClassName);
			return SecurityKernel.Encryptor.Api.Execute(engineId, input);
		}

		/// <summary>
		/// Generates a SHA hash from the input data using the specified key.
		/// </summary>
		/// <param name="input">A data to be hashed.</param>
		/// <param name="keyClassName">Name of a key to hash the data with.</param>
		/// <param name="keyId">Explicitly indicates a key to be used.</param>
		/// <returns>BASE 64 encoded hash.</returns>
		/// <exception cref=""
		public static string HashSha(this string input, string keyClassName, string keyId)
		{
			return CryptoUtils.HashWithKeySha(keyClassName, keyId, input);
		}

		/// <summary>
		/// Generates a SHA hash from the input data using the default key.
		/// </summary>
		/// <param name="input">A data to be hashed.</param>
		/// <param name="keyClassName">Name of a key to hash the data with.</param>
		/// <returns>BASE 64 encoded hash.</returns>
		/// <exception cref="SubsystemInputParamException">If an engine for the specified key class not found.</exception>
		public static string HashSha(this string input, string keyClassName)
		{
			List<string> errors = new List<string>();
			
			Key key = SecurityKernel.Encryptor.Properties.SessionKeyConfig.GetCurrentKey(keyClassName);
			if (key == null || !key.IsValid(errors))
			{
				throw new SubsystemInputParamException(String.Format("Could not get key for key class '{0}'", keyClassName));
			}

			return CryptoUtils.HashWithKeySha(keyClassName, key.Id.ToString(), input);
		}

		/// <summary>
		/// Compares SHA hash from the input obtained using the specified key name with a specified hash.
		/// </summary>
		/// <param name="input">A value to be hashed.</param>
		/// <param name="keyClassName">A name of the key to be used for hashing.</param>
		/// <param name="hash">A hash to compare the value with.</param>
		/// <returns>true if the hashed values are equal and false otherwise.</returns>
		public static bool CompareWithHashSha(this string input, string keyClassName, string hash)
		{
			return CryptoUtils.CompareHashSha(keyClassName, hash, input);
		}

		/// <summary>
		/// Parse the key id out of the hashed string.
		/// </summary>
		/// <param name="hashString"></param>
		/// <returns></returns>
		public static string ParseKeyFromHashSha256(this string hashString)
		{
			return CryptoUtils.ParseKeyFromHashSha256(hashString);
		}

		#region Keys setup

		/// <summary>
		///   Create one session key for each key class. 
		///   If the given password is empty (or null), a hardcoded password is used.
		///   Existing keys, if any, are deleted. 
		///   Output is generated in RMP\config\security\sessionkeys.xml.
		/// </summary>
		/// <param name="password">A password to create keys with.</param>
		/// <param name="keyClassNames">A list of key names to be created.</param>
		/// <returns>A dictionary containing keys and passwords to them.</returns>
		public static IDictionary<string, string> CreateSessionKeys(this string password, IEnumerable<string> keyClassNames)
		{
			Dictionary<string, string> result = new Dictionary<string,string>(keyClassNames.Count());
			CryptoUtils.CreateSessionKeys(password, keyClassNames);

			return result;
		}

		/// <summary>
		///    Create a session key for the specified key class based on the specified password. 
		///    The existing keys for the specified keyclass will be deleted. 
		/// </summary>
		/// <param name="password">A password to create keys with.</param>
		/// <param name="keyClassName">A name of the key to be created.</param>
		public static void CreateCryptographicKey(this string password, string keyClassName)
		{
			CryptoUtils.CreateKey(keyClassName, password);
		}

		/// <summary>
		///   Use Rfc2898DeriveBytes to generate a key and IV for Rijndael256 using
		///   the given password.
		/// </summary>
		/// <param name="password">A password for encryption.</param>
		/// <param name="base64Key">A BASE 64 encoded generated key.</param>
		/// <param name="base64Iv">A BASE 64 encoded generated initialization vector.</param>
		/// <returns></returns>
		public static void CreateCryptographicKey(this string password, out string base64Key, out string base64Iv)
		{
			CryptoUtils.CreateKey(password, out base64Key, out base64Iv);
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
		public static void AddCryptographicKey(this string password, string keyClassName, Guid id, bool makeCurrent)
		{
			CryptoUtils.AddKey(keyClassName, password, id, makeCurrent);
		}

		/// <summary>
		///    Make the key specified by the given id to be the current key.
		/// </summary>
		/// <param name="id">An ID of the key to be made current.</param>
		public static void MakeKeyCurrent(this Guid id)
		{
			CryptoUtils.MakeKeyCurrent(id);
		}

		/// <summary>
		///   Delete the sessionkeys.xml file from RMP\config\security.
		/// </summary>
		public static void DeleteSessionKeys(this MSSessionKeyConfig sessionKeyConfig)
		{
			CryptoUtils.DeleteSessionKeys(sessionKeyConfig);
		}

		#endregion

		public static string HashWithSaltBytes(this string str, string keyClass, byte[] salt)
		{
			return string.Empty;
		}

		public static bool VerifyHash(this string str, string keyClass, string salt, string hash)
		{
			return true;
		}

		public static string CreateSignature(this string str, string keyClass)
		{
			return string.Empty;
		}

		public static bool VerifySignature(this string str, string keyClass, string sig)
		{
			return true;
		}

		public static string CreateToken(this string str, string valueId, string sessionId, long timestamp)
		{
			return string.Empty;
		}

		public static bool VerifyToken(this string str, string valueId, string sessionId)
		{
			return true;
		}

		public static string GetTokenValue(this string str, string valueId, string sessionId)
		{
			return string.Empty;
		}

		/// <summary>
		/// Decrypts the contents of the CDATA element.
		/// </summary>
		/// <param name="cdata">An element to decrypt.</param>
		/// <returns>A decryption result.</returns>
		public static byte[] Decrypt(this CDATA cdata)
		{
			string value = CryptoUtils.UnprotectData(cdata.Text);
			byte[] result = Convert.FromBase64String(value);
			return result;
		}

		/// <summary>
		/// Encrypts the data with RSA algorithm.
		/// </summary>
		/// <param name="input">Data to be encrypted.</param>
		/// <param name="keyClassName">Name of a key to encrypt the data with.</param>
		/// <returns>BASE 64 encoded encryption result.</returns>
		/// <exception cref="EncryptorInputDataException">If some environment problem happens.</exception>
		public static string EncryptRsa(this string input, string keyClassName)
		{
			string engineId = CryptoUtils.GetEngineId(EncryptorEngineCategory.RSAEncrypt, keyClassName);
			return SecurityKernel.Encryptor.Api.Execute(engineId, input);
		}

		/// <summary>
		/// Decrypts the data encripted with RSA algorithm.
		/// </summary>
		/// <param name="input">BASE 64 encoded encrypted data.</param>
		/// <param name="keyClassName">Name of a key to encrypt the data with.</param>
		/// <returns>Decryption result.</returns>
		/// <exception cref="EncryptorInputDataException">If bad data passed to the method or some environment problem happens.</exception>
		public static string DecryptRsa(this string input, string keyClassName)
		{
			string engineId = CryptoUtils.GetEngineId(EncryptorEngineCategory.RSADecrypt, keyClassName);
			return SecurityKernel.Encryptor.Api.Execute(engineId, input);
		}

		/// <summary>
		/// Generates a RSA hash from the input data using the specified key.
		/// </summary>
		/// <param name="input">A data to be hashed.</param>
		/// <param name="keyClassName">Name of a key to hash the data with.</param>
		/// <param name="keyId">Explicitly indicates a key to be used.</param>
		/// <returns>BASE 64 encoded hash.</returns>
		public static string HashRsa(this string input, string keyClassName, string keyId)
		{
			return CryptoUtils.HashRsa(keyClassName, input, keyId);
		}

		/// <summary>
		/// Generates a RSA hash from the input data using the default key.
		/// </summary>
		/// <param name="input">A data to be hashed.</param>
		/// <param name="keyClassName">Name of a key to hash the data with.</param>
		/// <returns>BASE 64 encoded hash.</returns>
		public static string HashRsa(this string input, string keyClassName)
		{
			return CryptoUtils.HashRsa(keyClassName, input);
		}

		/// <summary>
		/// Return true if the hash of the given plainText matches the specified hash.
		/// </summary>
		/// <param name="input">Plain text</param>
		/// <param name="keyClassName">Name of a key to hash the data with.</param>
		/// <param name="hash">The salted password</param>
		/// <returns>BASE 64 encoded hash.</returns>
		public static bool CompareHashRsa(this string input, string keyClassName, string hash)
		{
			return CryptoUtils.CompareHashRsa(keyClassName, hash, input);
		}

		/// <summary>
    	/// Parse the key id out of the hashed string.
    	/// </summary>
	    /// <param name="input">Hashed string</param>
	    /// <returns></returns>
	    public static string ParseKeyFromHashRsa(this string input)
		{
			return CryptoUtils.ParseKeyFromHashRsa(input);
		}

	}
}