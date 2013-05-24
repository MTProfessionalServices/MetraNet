/**************************************************************************
* Copyright 1997-2010 by MetraTech.SecurityFramework
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech.SecurityFramework MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech.SecurityFramework MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech.SecurityFramework, and USER
* agrees to preserve the same.
*
* Authors: Viktor Grytsay
*
* <vgrytsay@MetraTech.SecurityFramework.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Core;
using MetraTech.Security;
using MetraTech.SecurityFramework.Serialization.Attributes;
using MetraTech.SecurityFramework.Serialization;
using MetraTech.Security.Crypto;

namespace MetraTech.SecurityFramework
{
	public class EncryptorProperties : SubsystemProperties
	{
		/// <summary>
		/// Contains configuration parameters for password encryptor
		/// </summary>
		[SerializeNested(DefaultType = typeof(PasswordConfig),  
						PathToSource=@"Security\mtpassword.xml", 
						SerializerTypeName="DotNetXmlSerializer", 
						PathType = PathType.Nested, 
						NestedPath = "ConfigurationPath")]
		public PasswordConfig PasswordConfig
		{
			get;
			set;
		}

		/// <summary>
		/// Contains configuration parameters for encryptor
		/// </summary>
		[SerializeNested(DefaultType = typeof(CryptoConfig),
						PathToSource = @"Security\mtsecurity.xml",
						SerializerTypeName = "DotNetXmlSerializer",
						PathType = PathType.Nested,
						NestedPath = "ConfigurationPath")]
		public CryptoConfig CryptoConfig
		{
			get;
			set;
		}

		/// <summary>
		/// Contains configuration parameters for RSA-encryptor
		/// </summary>
		[SerializeNested(DefaultType = typeof(RSACryptoConfig),
						PathToSource = @"Security\mtsecurity.xml",
						SerializerTypeName = "DotNetXmlSerializer",
						PathType = PathType.Nested,
						NestedPath = "ConfigurationPath")]
		public RSACryptoConfig RsaCryptoConfig
		{
			get;
			set;
		}

		/// <summary>
		/// Contains configuration parameters for MSSession-encryptor
		/// </summary>
		[SerializeNested(DefaultType = typeof(MSSessionKeyConfig),
						PathToSource = @"Security\sessionkeys.xml",
						SerializerTypeName = "DotNetXmlSerializer",
						PathType = PathType.Nested,
						NestedPath = "ConfigurationPath")]
		public MSSessionKeyConfig SessionKeyConfig
		{
			get;
			set;
		}

		/// <summary>
		/// Contains configuration parameters for MS-encryptor
		/// </summary>
		public MSCryptoConfig MSCryptoConfig
		{
			get
			{
				return MSCryptoConfig.GetInstance();
			}
		}
	}
}
