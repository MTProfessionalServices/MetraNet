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
* Your Name <vgrytsay@MetraTech.SecurityFramework.com>
*
* 
***************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework;
using System.Reflection;

namespace MetraTech.SecurityFramework.Serialization
{
    /// <summary>
    /// This interface describes the serialization error
    /// </summary>
	public interface ISerializationError
	{
		/// <summary>
		/// Gets or sets type of deserialized object
		/// </summary>
		Type Type
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets deserialized object
		/// </summary>
		object Value
		{
			get;
			set;
		}
		
		/// <summary>
		/// Gets or sets collection properties of deserialize object
		/// </summary>
		SortedList<string, string> PropertyCollectoin
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets collection properties of deserialize object with deserialize error
		/// </summary>
		Dictionary<string, object> ErrorPropertyCollectoin
		{
			get;
			set;
		}
    }
}
