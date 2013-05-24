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
using MetraTech.SecurityFramework.Core.Common.Logging;

namespace MetraTech.SecurityFramework.Core.Encryptor
{
	/// <summary>
	/// Provides a base class for RSA encryption engine classes.
	/// </summary>
	public abstract class RSAEngineBase : KeyEncryptorEngineBase
	{

		#region Protected Constants

		protected const char KeyIdSeparator = '|';
		protected const int KmsSuccess = 0;

		#endregion

		#region Contructor

		/// <summary>
		/// Creates an instance of the <see cref="RSAEngineBase"/> with the specified category.
		/// </summary>
		/// <param name="category">An engine's category.</param>
		public RSAEngineBase(EncryptorEngineCategory category)
			: base(category)
		{
		} 

		#endregion

		#region Protected Methods
		#endregion

	}
}
