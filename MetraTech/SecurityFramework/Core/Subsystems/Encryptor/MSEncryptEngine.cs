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
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using MetraTech.Security.Crypto;
using MetraTech.SecurityFramework.Core.Common.Configuration;

namespace MetraTech.SecurityFramework.Core.Encryptor
{
	/// <summary>
	/// Provides data encryption using RijndaelManaged crypto algorithm.
	/// </summary>
	public class MSEncryptEngine : MSCryptoEngineBase
	{
		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="MSEncryptEngine"/> class.
		/// </summary>
		public MSEncryptEngine()
			: base(EncryptorEngineCategory.MSEncrypt)
		{
		}

		#endregion

		#region Protected methods

		/// <summary>
		/// Encrypts data from the <paramref name="input"/>.
		/// </summary>
		/// <param name="input">A data to be encrypted.</param>
		/// <returns>BASE 64 encoded encrypted data.</returns>
		protected override string ProcessInternal(string input)
		{
			string cipherText;

			try
			{
				// Encode data string to be stored in memory
				byte[] plainTextBytes = Encoding.UTF8.GetBytes(input);
				byte[] originalBytes = { };

				using (MemoryStream memStream = new MemoryStream()) // Create MemoryStream to contain output
				using (RijndaelManaged rijndael = CreateAlgorithm())
				using (ICryptoTransform transform = rijndael.CreateEncryptor()) // Create encryptor
				using (CryptoStream cryptoStream = new CryptoStream(memStream, transform, CryptoStreamMode.Write))
				{
					// Write encrypted data to the MemoryStream
					cryptoStream.Write(plainTextBytes, 0, plainTextBytes.Length);
					cryptoStream.FlushFinalBlock();
					originalBytes = memStream.ToArray();

					// Convert encrypted string
					cipherText = Key.Id.ToString() + Convert.ToBase64String(originalBytes);
				}

				return cipherText;
			}
			catch (Exception ex)
			{
				throw new EncryptorInputDataException(Common.ExceptionId.Encryptor.General, Category, "Unable to encrypt data", ex);
			}
		}

		#endregion
	}
}
