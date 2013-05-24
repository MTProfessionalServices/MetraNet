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
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.Security.Crypto;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Core.Common.Logging;

namespace MetraTech.SecurityFramework.Core.Encryptor
{

	/// <summary>
	/// Provades mechanisms for RSA decryption
	/// </summary>
	public class RSADecryptEngine : RSAEngineBase
	{
		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="RSADecryptEngine"/> class.
		/// </summary>
		public RSADecryptEngine()
			: base(EncryptorEngineCategory.RSADecrypt)
		{
		} 

		#endregion

		/// <summary>
		///   Decrypt the given cipherText based on the specified CryptKeyClass.
		///   The cipherText string must have the KMS key id prepended to it.
		/// </summary>
		/// <param name="input">cipher text</param>
		/// <returns>plain text</returns>
		protected override string ProcessInternal(string input)
		{
			if (string.IsNullOrEmpty(input))
			{
				return input;
			}
			int bufsize = input.Length;
			int plainTextDataLen = 0;
			byte[] plainTextBytes = new byte[bufsize];

			try
			{
				byte[] cipherTextBytes = Encoding.UTF8.GetBytes(input);

				// Initialize KMSClient
				int kmHandle = CryptoUtils.InitKMS();
				// Retrieve the KMS key class
				string kmsKeyClass = CryptoUtils.GetKMSKeyClass(KeyClassName);
				if (String.IsNullOrEmpty(kmsKeyClass))
				{
					throw new SecurityFrameworkException(String.Format("No KMS Key class name found in configuration which matches '{0}'", KeyClassName));
				}

				if ((KMClientWrapper.KMSDecryptData(kmHandle,
																						kmsKeyClass,
																						cipherTextBytes,
																						cipherTextBytes.Length,
																						plainTextBytes,
																						bufsize,
																						ref plainTextDataLen)) != KmsSuccess)
				{
					throw new EncryptorInputDataException(ExceptionId.Encryptor.General, Category, "Unable to decrypt data");
				}
			}
			catch (Exception exp)
			{
				LoggingHelper.Log(exp);
				throw;
			}

			return Encoding.UTF8.GetString(plainTextBytes, 0, plainTextDataLen);
		}
	}
}
