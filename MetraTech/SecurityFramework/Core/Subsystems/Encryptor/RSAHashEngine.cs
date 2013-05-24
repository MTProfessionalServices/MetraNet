/**************************************************************************
* Copyright 1997-2011 by MetraTech
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
* Borys Sokolov <bsokolov@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Text;
using MetraTech.Security.Crypto;
using MetraTech.SecurityFramework.Core.Common.Logging;

namespace MetraTech.SecurityFramework.Core.Encryptor
{
	/// <summary>
	/// Provades mechanisms for RSA hashing
	/// </summary>
	public class RSAHashEngine : RSAEngineBase
	{
		/// <summary>
		///  Creates an instance of the <see cref="RSAHashEngine"/> class.
		/// </summary>
		public RSAHashEngine()
			: base(EncryptorEngineCategory.RSAHash)
		{
		}

		/// <summary>
		/// Hashes the provided string and return the result.
		/// </summary>
		/// <param name="input">String to hash</param>
		/// <returns></returns>
		protected override string ProcessInternal(string input)
		{
			return new ApiOutput(HashRsa(KeyClassName, input, Key.Id.ToString()));
		}

		/// <summary>
		/// Hashes the provided string and return the result.
		/// </summary>
		/// <param name="keyClassName">Name of a key to encrypt the data with.</param>
		/// <param name="inputData">string to hash</param>
		/// <param name="keyId">The keyID is optional. If it is null, then the current key is used.  Pass null for new hash.</param>
		/// <returns></returns>
		public string HashRsa(string keyClassName, string inputData, string keyId)
		{
			LoggingHelper.LogDebug("SequrityFramework.RSAHashEngine.HashRsa", string.Format("keyClassName = {0}, inputData = {1}, keyID = {2}", keyClassName, inputData, keyId));
			//System.Threading.Thread.Sleep(90000);
			string b64OfEncHmacData = "";
			const int kmsBufsSize = 1024;
			byte[] hmacBuf = new byte[kmsBufsSize];
			int hmacLen = 0;

			try
			{
				byte[] inputDataBytes = Encoding.UTF8.GetBytes(inputData);

				int kmHandle = CryptoUtils.InitKMS();
				string kmsKeyClass = CryptoUtils.GetKMSKeyClass(keyClassName); //GetKey(new Guid(keyID)).ToString();
				if (String.IsNullOrEmpty(kmsKeyClass))
				{
					throw new SecurityFrameworkException(String.Format("No KMS Key class name found in configuration which matches '{0}'", kmsKeyClass));
				}

				int status;
				if (keyId == null)
				{
					// Get a new key ID
					StringBuilder rKeyID = new StringBuilder(kmsBufsSize);
					if ((status = KMClientWrapper.KMSGetKey(kmHandle, kmsKeyClass,
																									keyId, hmacBuf,
																									kmsBufsSize, ref hmacLen,
																									rKeyID, kmsBufsSize)) != KmsSuccess)
					{
						throw new SecurityFrameworkException("GetKey failed: Error code = " + status);
					}
					keyId = rKeyID.ToString();
				}

				// Get hash
				if ((status = KMClientWrapper.KMSHMACData(kmHandle,
																									kmsKeyClass,
																									keyId,
																									inputDataBytes,
																									inputDataBytes.Length,
																									hmacBuf,
																									kmsBufsSize,
																									ref hmacLen)) != KmsSuccess)
				{
					throw new SecurityFrameworkException("HMACData failed: Error code = " + status);
				}

				// Base 64 encode and prepend the key ID to front of hash
				b64OfEncHmacData = Convert.ToBase64String(hmacBuf, 0, hmacLen);
				b64OfEncHmacData = keyId + KeyIdSeparator + b64OfEncHmacData;
			}
			catch (Exception ex)
			{
				LoggingHelper.LogError("KMSHMACData Failed.", ex.Message);
				throw;
			}

			return b64OfEncHmacData;
		}

	}
}
