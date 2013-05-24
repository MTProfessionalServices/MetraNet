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
	/// Provades mechanisms for RSA encryption
	/// </summary>
	public class RSAEncryptEngine : RSAEngineBase
	{
		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="RSAEncryptEngine"/> class.
		/// </summary>
		public RSAEncryptEngine()
			: base(EncryptorEngineCategory.RSAEncrypt)
		{
		}
 
		#endregion

		/// <summary>
		///   Encrypt the given plainText based on the specified CryptKeyClass.
		///   The encrypted string will have the KMS key id prepended to it.
		/// </summary>
		/// <param name="input">plain text</param>
		/// <returns>cipher text</returns>
		protected override string ProcessInternal(string input)
		{
			if (String.IsNullOrEmpty(input))
			{
				return input;
			}

			int bufsize = input.Length * 200;
			int encryptedDataLen = 0;
			const int base64Flag = 1;
			byte[] cipherTextBytes = new byte[bufsize];

			try
			{
				byte[] plainTextBytes = Encoding.UTF8.GetBytes(input);

				// Initialize KMSClient
				int kmHandle = CryptoUtils.InitKMS();
				// Retrieve the KMS key class
				string kmsKeyClass = CryptoUtils.GetKMSKeyClass(KeyClassName);
				if (String.IsNullOrEmpty(kmsKeyClass))
				{
					throw new SecurityFrameworkException(String.Format("No KMS Key class name found in configuration which matches '{0}'", KeyClassName));
				}

				if ((KMClientWrapper.KMSEncryptData(kmHandle,
																						kmsKeyClass,
																						plainTextBytes,
																						plainTextBytes.Length,
																						cipherTextBytes,
																						bufsize,
																						ref encryptedDataLen,
																						base64Flag)) != KmsSuccess)
				{
					throw new EncryptorInputDataException(ExceptionId.Encryptor.General, Category, "Unable to encrypt data");
				}
			}
			catch (Exception exp)
			{
				LoggingHelper.Log(exp);
				throw;
			}

			return Encoding.UTF8.GetString(cipherTextBytes, 0, encryptedDataLen);
		}
	}
}
