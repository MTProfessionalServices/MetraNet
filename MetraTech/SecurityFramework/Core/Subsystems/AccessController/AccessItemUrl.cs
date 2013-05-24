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
using MetraTech.SecurityFramework.Serialization.Attributes;
using System.Xml.Serialization;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Provides a class for checking access to external url.
	/// </summary>
	public class AccessItemUrl : AccessItem
	{	
		/// <summary>
		/// Gets or sets checking url.
		/// </summary>
		[SerializeProperty(IsRequired = true)]
		public string Url
		{
			get;
			private set;
		}
	}
}
