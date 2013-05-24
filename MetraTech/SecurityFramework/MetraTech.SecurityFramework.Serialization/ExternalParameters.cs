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
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework.Serialization
{
	/// <summary>
	/// This class contains external serialization parameter collection.
	/// </summary>
	public static class ExternalParameters
	{
		private static Dictionary<string, string> _keys = new Dictionary<string, string>();

		/// <summary>
		/// Adding serialization parameter in collection.
		/// </summary>
		/// <param name="key">Parameter name.</param>
		/// <param name="value">Parameter value.</param>
		public static void AddKey(string key, string value)
		{
			if (string.IsNullOrEmpty(key))
			{
				string msg = "Key parameter for external serialization parameter is null.";
				throw new SerializationException(msg);
			}

			if (string.IsNullOrEmpty(value))
			{
				string msg = "Value parameter for external serialization parameter is null.";
				throw new SerializationException(msg);
			}

			if (!_keys.ContainsKey(key))
			{
				/*string msg = string.Format("External serialization parameter collection already contains parameter with name {0}", key);
				throw new SerializationException(msg);*/
				_keys.Add(key, value);
			}
		}

		/// <summary>
		/// Gets serialization parameter value form collection.
		/// </summary>
		/// <param name="key">Parameter name.</param>
		/// <returns>Parameter value.</returns>
		public static string GetValue(string key)
		{
			if (string.IsNullOrEmpty(key))
			{
				string msg = "Key parameter for external serialization parameter is null.";
				throw new SerializationException(msg);
			}

			if (!_keys.ContainsKey(key))
			{
				string msg = string.Format("External serialization parameter {0} not found!", key);
				throw new SerializationException(msg);
			}

			return _keys[key];
		}
	}
}
