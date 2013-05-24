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
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.Security;
using MetraTech.Security.Crypto;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Core;
using MetraTech.SecurityFramework.Common.Configuration.Logger;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Represents a public API for the Encryptor subsystem.
	/// </summary>
	internal sealed class Encryptor : SubsystemBase, IEncryptor
    {
		/// <summary>
		/// Gets or sets configuration for current subsystem.
		/// </summary>
		public EncryptorProperties Properties
		{
			get;
			private set;
		}

		/// <summary>
		/// Creates an instance of the <see cref="Encryptor"/> class.
		/// </summary>
		public Encryptor()
			: base()
		{

		}

		/// <summary>
		/// Initializes a list of available categories.
		/// </summary>
		public override void InitCategories()
		{
			InitCategories(typeof(EncryptorEngineCategory));
		}

		public override void Initialize(Core.SubsystemProperties props)
		{
			EncryptorProperties encProps = props as EncryptorProperties;
			if (encProps != null)
			{
				this.Properties = encProps;
			}
			else
			{
				throw new ConfigurationException("SubsystemProperties type for Encryptor subsystem is not valid. Checked configuration settings for Encryptor subsystem.");
			}

			base.Initialize(props);
		}

		/// <summary>
		/// Gets configuration for current subsystem
		/// </summary>
		public override IConfigurationLogger GetConfiguration()
		{
			SubsystemProperties baseProps = ((SubsystemProperties)base.GetConfiguration());
			EncryptorProperties result = new EncryptorProperties();
			
			result.Engines = baseProps.Engines;
			result.IsControlApiPublic = baseProps.IsControlApiPublic;
			result.IsRuntimeApiPublic = baseProps.IsRuntimeApiPublic;
			result.IsControlApiEnabled = baseProps.IsControlApiEnabled;
			result.IsRuntimeApiEnabled = baseProps.IsRuntimeApiEnabled;
			
			result.CryptoConfig = Properties.CryptoConfig;
			result.PasswordConfig = Properties.PasswordConfig;
			result.RsaCryptoConfig = Properties.RsaCryptoConfig;
			result.SessionKeyConfig = Properties.SessionKeyConfig;

			return result;
		}
	}
}
