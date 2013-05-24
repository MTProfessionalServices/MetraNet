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
* Maksym Sukhovarov <msukhovarov@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Uses for output engine param.
	/// </summary>
	/// <see cref="IEngine"/>
	public class ApiOutput
	{

		private ICollection<Exception> _exceptions;

		public ApiOutput(object value)
			: this(value, string.Empty)
		{ }

		public ApiOutput(object value, string format)
		{
			Value = value;
			Format = format;
			if (value is ApiInput)
			{
				this._exceptions = ((ApiInput)value).Exceptions;
			}
		}

		public ApiOutput(object value, ICollection<Exception> exceptions)
			: this(value)
		{
			this._exceptions = exceptions;
		}

		public ApiOutput(object value, ICollection<Exception> exceptions, string format)
			: this(value, format)
		{
			this._exceptions = exceptions;
		}

		public ICollection<Exception> Exceptions
		{
			get
			{
				if (_exceptions == null)
				{
					_exceptions = new List<Exception>();
				}
				return _exceptions;
			}
		}

		/// <summary>
		/// Replaces the format item in a specified string with the string representation of a corresponding object in a specified array. 
		/// A specified parameter supplies culture-specific formatting information.
		/// </summary>
		public string Format { get; private set; }

		/// <summary>
		/// Gets or internally sets the value.
		/// </summary>
		public object Value { get; private set; }

		/// <summary>
		/// Return System.String
		/// </summary>
		/// <returns></returns>
		public override string ToString()
		{
			return String.IsNullOrEmpty(Format) ?
				(Value != null ? Value.ToString() : null) : String.Format(Format, Value);
		}

		/// <summary>
		/// Convert to type
		/// </summary>
		/// <typeparam name="T"></typeparam>
		/// <returns></returns>
		public T OfType<T>()
		{
			// TODO: add the code to convert to the resulting  type.
			return (T)Value;
		}

		/// <summary>
		/// Converts an instance of the <see cref="ApiOutput"/> class to a string.
		/// </summary>
		/// <param name="value">A value to be converted.</param>
		/// <returns>A string object.</returns>
		/// <remarks>Returns null is a value argument is null.</remarks>
		public static implicit operator string(ApiOutput value)
		{
			return value != null ? value.ToString() : null;
		}

	}
}
