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
using System.Reflection;

namespace MetraTech.SecurityFramework.Serialization.Attributes
{
	/// <summary>
	/// Contains parameters of serialize attribute, if serialize member is collection
	/// </summary>
	public class SerializeCollectionParams:SerializeParams
	{
		/// <summary>
		/// Gets or sets default type of collection elements in xml document
		/// </summary>
		public Type ElementType
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets name of collection elements in xml document
		/// </summary>
		public string ElementName
		{
			get;
			set;
		}
	}
}
