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
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Encryptor
{
	/// <summary>
	/// Base class for key encryptor/decryptor engines
	/// </summary>
	public abstract class KeyEncryptorEngineBase : EncryptorEngineBase
	{
		#region Private fields

		private object _syncRoot = new object();
		private string _keyClassName;

		#endregion

		#region Properties

		/// <summary>
		/// Gets or internally sets a key for this engine.
		/// </summary>
		protected Key Key
		{
			get
			{
				// Retrieve the current key for this keyClass 
				Key key = SecurityKernel.Encryptor.Properties.SessionKeyConfig.GetCurrentKey(KeyClassName);
				List<string> errors = new List<string>();
				if (key == null || !key.IsValid(errors))
				{
					throw new SecurityFrameworkException(String.Format("Could not get key for key class '{0}'", KeyClassName));
				}

				return key;
			}
		}

		/// <summary>
		/// Gets or sets key name for configuration settings.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		protected virtual string KeyClassName
		{
			get
			{
				return _keyClassName;
			}
			set
			{
				if (string.IsNullOrEmpty(value))
				{
					throw new ConfigurationException("Name of key for EncryptorEngine is null or empty. Please check configuration file for Encryptor subsystem.");
				}

				_keyClassName = value;
			}
		}

		#endregion

		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="KeyEncryptorEngineBase"/> class with the specified category.
		/// </summary>
		/// <param name="category">Engine's category.</param>
		public KeyEncryptorEngineBase(EncryptorEngineCategory category) : base(category)
		{
		}

		#endregion

		#region Protected Methods

		/// <summary>
		/// Checks if the input is null or empty string. Returns null/empty string or passes real data to crypto method.
		/// </summary>
		/// <param name="input"></param>
		/// <returns></returns>
		protected override ApiOutput ExecuteInternal(ApiInput input)
		{
			string inputStr = input != null ? input.ToString() : null;

			ApiOutput result = new ApiOutput(string.IsNullOrEmpty(inputStr) ? inputStr : ProcessInternal(inputStr));

			return result;
		}

		/// <summary>
		/// Precessed input in descendant classes.
		/// </summary>
		/// <param name="input">A data to be processed.</param>
		/// <returns>A cryptography output.</returns>
		protected abstract string ProcessInternal(string input);

		/// <summary>
		/// Retrives a Key by the specified ID.
		/// </summary>
		/// <param name="keyId">An ID of the key to be retrieved.</param>
		/// <returns>A key with the specified ID if found.</returns>
		protected Key GetKey(Guid keyId)
		{
			List<string> errors = new List<string>();
			Key key = SecurityKernel.Encryptor.Properties.SessionKeyConfig.GetKey(keyId);
			if (key == null || !key.IsValid(errors))
			{
				throw new SecurityFrameworkException(String.Format("Could not get key for key class '{0}'", KeyClassName));
			}

			return key;
		}

		#endregion
	}
}
