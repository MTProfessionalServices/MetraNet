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
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Common.Configuration;
using MetraTech.SecurityFramework.Serialization;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Class for deserialize special collection for case collection in SwitchRule and SwitchRuleEx classes
	/// </summary>
	public class CaseCollection : List<Case>, ISerializeEx
	{
		/// <summary>
		/// Contains name of special element in source file.
		/// </summary>
		const string Default = "Default";

		/// <summary>
		/// Gets or sets id next rule in chain of processor.
		/// </summary>
		public string DefaultIdRule
		{
			get;
			private set;
		}

		/// <summary>
		/// Deserializes special properties in extention collection.
		/// </summary>
		/// <param name="reflector">
		/// Contains values for special properties in extention collection.
		/// </param>
		public void Deserialize(ObjectReflector reflector)
		{
			if (reflector.ValueProps.ContainsKey("value"))
			{
				DefaultIdRule = reflector.ValueProps["value"];
			}
			else
			{
				throw new SerializationException(string.Format("Source file contains errors in declaring property {0}", reflector.Name));
			}
		}
	}
}
