using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Represents a validation pattern.
	/// </summary>
	public class StringPattern
	{
		/// <summary>
		/// Gets or sets a pattern value.
		/// </summary>
		[SerializeProperty(IsRequired = true)]
		public string Pattern
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a value indicating the pattern match is used to block.
		/// </summary>
		[SerializeProperty(IsRequired = true)]
		public bool Exclude
		{
			get;
			set;
		}
	}
}
