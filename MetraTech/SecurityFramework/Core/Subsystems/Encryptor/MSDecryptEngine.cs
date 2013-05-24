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
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using MetraTech.SecurityFramework.Core.Common;
using System.IO;

namespace MetraTech.SecurityFramework.Core.Encryptor
{
	/// <summary>
	/// Provides data encryption using RijndaelManaged crypto algorithm.
	/// </summary>
	public class MSDecryptEngine : MSCryptoEngineBase
	{
		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="MSDecryptEngine"/> class.
		/// </summary>
		public MSDecryptEngine()
			: base(EncryptorEngineCategory.MSDecrypt)
		{
		}

		#endregion

		#region Protected methods

		/// <summary>
		/// Decrypts data from the <paramref name="input"/>.
		/// </summary>
		/// <param name="input">A BASE 64 encoded encrypted data.</param>
		/// <returns>A decryption result.</returns>
		protected override string ProcessInternal(string input)
		{
			string plainText;

			try
			{
				// Retrieve the key id from the cipherText
				string cipherText;
				Guid keyId = CryptoUtils.ParseKeyIdMicrosoft(input, out cipherText);

				byte[] cipherBytes = Convert.FromBase64String(cipherText);
				
				// Create a decryptor to perform the stream transform.
				using (RijndaelManaged rijndael = CreateAlgorithm())
				using (ICryptoTransform transform = rijndael.CreateDecryptor())
				// Create the streams used for decryption.
				using (MemoryStream memStream = new MemoryStream(cipherBytes))
				using (CryptoStream cryptoStream = new CryptoStream(memStream, transform, CryptoStreamMode.Read))
				using (StreamReader streamReader = new StreamReader(cryptoStream))
				{
					// Read the decrypted bytes from the decrypting stream
					// and place them in a string.
					plainText = streamReader.ReadToEnd();
				}
			}
			catch (CryptographicException ex)
			{
				throw new EncryptorInputDataException(ExceptionId.Encryptor.BadEncryptedData, Category, ex.Message, ex);
			}
			catch (FormatException ex)
			{
				throw new EncryptorInputDataException(ExceptionId.Encryptor.BadEncodedData, Category, ex.Message, ex);
			}
			catch (Exception ex)
			{
				throw new EncryptorInputDataException(Common.ExceptionId.Encryptor.General, Category, "Unable to decrypt data", ex);
			}

			return plainText;
		}

		#endregion
	}
}
