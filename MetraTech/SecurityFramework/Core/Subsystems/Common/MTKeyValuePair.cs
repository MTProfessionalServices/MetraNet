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
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Common
{
	/// <summary>
	/// Contains key-value pair
	/// </summary>
	public struct MetraTech_KeyValuePair<TName, TValue>
	{
		#region Private fields

		private TName _name;
		private TValue _value;

		#endregion

		#region Private properties

		[SerializePropertyAttribute]
		private TName Name
		{
			get { return _name; }
			set
			{
				_name = value;
			}
		}

		[SerializePropertyAttribute]
		private TValue Value
		{
			get { return _value; }
			set { _value = value; }
		}

		#endregion

		/// <summary>
		/// Converts and gets key and value parameters to KeyValuePair type
		/// </summary>
		public KeyValuePair<TName, TValue> Pair
		{
			get
			{
				KeyValuePair<TName, TValue> retPair = new KeyValuePair<TName, TValue>(Name, Value);
				return retPair;
			}
		}

		public MetraTech_KeyValuePair(TName name, TValue value)
		{
			_name = name;
			_value = value;
		}
		
		public override string ToString()
		{
			return Pair.ToString();
		}
	}
}
