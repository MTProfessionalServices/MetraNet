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
using System.Text;
using System.Security.Cryptography;

namespace MetraTech.SecurityFramework.Core.Encryptor
{
	/// <summary>
	/// Provides data encryption using HMACSHA512 crypto algorithm.
	/// </summary>
	public class MSHashEngine : KeyEncryptorEngineBase
	{
		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="MSHashEngine"/> engine.
		/// </summary>
		public MSHashEngine()
			: base(EncryptorEngineCategory.MSHash)
		{
		}

		#endregion

		#region Protected methods

		/// <summary>
		/// Hashes the specified input with the currently configured key.
		/// </summary>
		/// <param name="input">A data to be hashed.</param>
		/// <returns>A hashed data.</returns>
		protected override string ProcessInternal(string input)
		{
			return new ApiOutput(HashWithKey(Key.Id.ToString(), input.ToString()));
		}

		/// <summary>
		///   Hash the given plainText based on the specified HashKeyClass, and key id.
		///   The cipherText string will have the KMS key id prepended to it.  
		/// </summary>
		/// <param name="keyClassName"></param>
		/// <param name="keyId">Must be a guid</param>
		/// <param name="plainText"></param>
		/// <returns></returns>
		public string HashWithKey(string keyId, string plainText)
		{
			try
			{
				Guid keyIdGuid = new Guid(keyId);

				// Retrieve the current key for this keyClass 
				MetraTech.Security.Crypto.Key key = GetKey(keyIdGuid);

				byte[] plainTextBytes = Encoding.UTF8.GetBytes(plainText);
			    string hashedString = null;
				using(HMACSHA512 hmac = new HMACSHA512(key.Value.Decrypt()))
				{
                    byte[] hash = hmac.ComputeHash(plainTextBytes);
                    hashedString = key.Id.ToString() + Convert.ToBase64String(hash);
                }

				return hashedString;
			}
			catch (FormatException ex)
			{
				throw new EncryptorInputDataException(Common.ExceptionId.Encryptor.BadEncodedData, Category, "Unable to hash data", ex);
			}
			catch (Exception ex)
			{
				throw new EncryptorInputDataException(Common.ExceptionId.Encryptor.General, Category, "Unable to hash data", ex);
			}
		}

		#endregion
	}
}
