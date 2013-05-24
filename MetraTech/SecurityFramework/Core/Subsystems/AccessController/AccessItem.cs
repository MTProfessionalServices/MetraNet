/**************************************************************************
* Copyright 1997-2011 by MetraTech.SecurityFramework
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
using System.Xml.Serialization;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Provides a base class for all controllers type for AccessController subsystem.
	/// </summary>
	public class AccessItem//AccessItemUrl
	{
		/// <summary>
		/// Gets or sets controller name.
		/// </summary>
		[SerializeProperty(IsRequired = true)]
		public string Name
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets controller description.
		/// </summary>
		[SerializeProperty(IsRequired = true)]
		public string Description
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets controller access type.
		/// </summary>
		[SerializeProperty(IsRequired = true)]
		public AccessType AccessType
		{
			get;
			set;
		}
	}
}
