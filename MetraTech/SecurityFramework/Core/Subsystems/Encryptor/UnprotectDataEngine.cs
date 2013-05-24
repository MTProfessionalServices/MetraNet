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

namespace MetraTech.SecurityFramework.Core.Encryptor
{
	/// <summary>
	/// Provides data unprotection through DPAPI.
	/// </summary>
	public class UnprotectDataEngine : EncryptorEngineBase
	{
		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="UnprotectDataEngine"/> class.
		/// </summary>
		public UnprotectDataEngine()
			: base(EncryptorEngineCategory.UnprotectData)
		{
		}

		#endregion

		#region Protected methods

		/// <summary>
		/// Decrypts an input data using the DPAPI.
		/// </summary>
		/// <param name="input">A BASE 64 encoded encrypted data.</param>
		/// <returns>Decryption result.</returns>
		protected override ApiOutput ExecuteInternal(ApiInput input)
		{
			string value;
			if (input == null || (value = input.ToString()) == null)
			{
				throw new NullInputDataException(SubsystemName, CategoryName, SecurityEventType.InputDataProcessingEventType);
			}

			string plainText = CryptoUtils.UnprotectData(value);

			return new ApiOutput(plainText);
		}

		#endregion
	}
}
