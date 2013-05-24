using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Xml.Serialization;

namespace MetraTech.Security.Crypto
{
	/// <summary>
	///   Microsoft specific security configuration.
	/// </summary>
	[ComVisible(false)]
	public class Key : IComparable<Key>
	{
		#region Public properties
		/// <summary>
		///   IsCurrent
		/// </summary>
		[XmlAttribute("current")]
		public bool IsCurrent
		{
			get;
			set;
		}

		/// <summary>
		///   Id
		/// </summary>
		[XmlElement("id", Type = typeof(Guid))]
		public Guid Id
		{
			get;
			set;
		}

		/// <summary>
		///   Id
		/// </summary>
		[XmlElement("secret", Type = typeof(CDATA))]
		public CDATA Secret
		{
			get;
			set;
		}

		/// <summary>
		///   Value
		/// </summary>
		[XmlElement("value", Type = typeof(CDATA))]
		public CDATA Value
		{
			get;
			set;
		}

		/// <summary>
		///   Initialization Vector
		/// </summary>
		[XmlElement("iv", Type = typeof(CDATA))]
		public CDATA IV
		{
			get;
			set;
		}
		#endregion

		#region Public methods

		/// <summary>
		///   Check validity
		/// </summary>
		/// <returns></returns>
		public bool IsValid(List<string> errors)
		{
			if (Id == null || Id == Guid.Empty)
			{
				errors.Add(String.Format("Missing key id"));
				return false;
			}

			if (Value == null || String.IsNullOrEmpty(Value.Text))
			{
				errors.Add(String.Format("Missing key value"));
				return false;
			}

			if (IV == null || String.IsNullOrEmpty(IV.Text))
			{
				errors.Add(String.Format("Missing iv"));
				return false;
			}

			return true;
		}

		/// <summary>
		///   CompareTo
		/// </summary>
		/// <param name="obj"></param>
		/// <returns></returns>
		public int CompareTo(object obj)
		{
			Key key = obj as Key;
			if (key != null)
			{
				return CompareTo(key);
			}
			else
			{
				throw new ArgumentException("Both objects being compared must be of type Key.");
			}
		}

		/// <summary>
		///    CompareTo
		/// </summary>
		/// <param name="other"></param>
		/// <returns></returns>
		public int CompareTo(Key other)
		{
			return this.Id.CompareTo(other.Id);
		}

		#endregion
	}
}
