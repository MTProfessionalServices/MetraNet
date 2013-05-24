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
using System.Security.Cryptography;
using MetraTech.Security.Crypto;

namespace MetraTech.SecurityFramework.Core.Encryptor
{
	/// <summary>
	/// Represents a base class for MS crypto engines.
	/// </summary>
	public abstract class MSCryptoEngineBase : KeyEncryptorEngineBase
	{
		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="MSCryptoEngineBase"/> class with the specified category.
		/// </summary>
		/// <param name="category">Engine's category.</param>
		public MSCryptoEngineBase(EncryptorEngineCategory category)
			: base(category)
		{
		}

		#endregion

		#region Protected methods

		/// <summary>
		/// Creates and sets up an instance of the <see cref="RijndaelManaged"/> class.
		/// </summary>
		/// <returns>A configuraed instance of the <see cref="RijndaelManaged"/> class.</returns>
		protected RijndaelManaged CreateAlgorithm()
		{
			RijndaelManaged result = new RijndaelManaged();

			try
			{
				result.BlockSize = 256;
				result.Key = Key.Value.Decrypt();
				result.IV = Key.IV.Decrypt();
				result.Padding = PaddingMode.PKCS7;

				return result;
			}
			catch (Exception)
			{
				result.Dispose();
				throw;
			}
		}

		#endregion
	}
}
