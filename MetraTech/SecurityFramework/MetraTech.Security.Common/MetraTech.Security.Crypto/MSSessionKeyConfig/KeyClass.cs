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
	public class KeyClass : IComparable<KeyClass>
	{
		private List<Key> keys;

		#region Public properties

		/// <summary>
		///   Name.
		/// </summary>
		[XmlAttribute("name")]
		public string Name
		{
			get;
			set;
		}

		/// <summary>
		///    KeyClasses
		/// </summary>
		[XmlElement(ElementName = "key", Type = typeof(Key))]
		public Key[] Keys
		{
			get
			{
				if (keys != null)
				{
					return keys.ToArray();
				}

				return null;
			}
			set
			{
				if (value != null)
				{
					keys = new List<Key>();
					foreach (Key key in value)
					{
						keys.Add(key);
					}
				}
			}
		}

		#endregion

		#region Public Methods

		/// <summary>
		///   Constructor
		/// </summary>
		public KeyClass()
		{
			keys = new List<Key>();
		}

		/// <summary>
		///   Remove the keys
		/// </summary>
		public void ClearKeys()
		{
			keys.Clear();
		}
		/// <summary>
		///   Return the current key
		/// </summary>
		/// <returns></returns>
		public Key GetCurrentKey()
		{
			Key key = null;

			foreach (Key lpKey in Keys)
			{
				if (lpKey.IsCurrent)
				{
					key = lpKey;
					break;
				}
			}

			return key;
		}

		/// <summary>
		///   Get the key for the given key id.
		/// </summary>
		/// <param name="keyId"></param>
		/// <returns></returns>
		public Key GetKey(Guid keyId)
		{
			Key key = null;

			foreach (Key lpKey in Keys)
			{
				if (lpKey.Id.Equals(keyId))
				{
					key = lpKey;
					break;
				}
			}

			return key;
		}

		/// <summary>
		///    Return true if the given key id exists
		/// </summary>
		/// <param name="keyId"></param>
		/// <returns></returns>
		public bool HasKey(Guid keyId)
		{
			bool hasKey = false;

			if (GetKey(keyId) != null)
			{
				hasKey = true;
			}
			return hasKey;
		}

		/// <summary>
		///    Make the given keyId the current key
		/// </summary>
		/// <param name="keyId"></param>
		public void MakeKeyCurrent(Guid keyId)
		{
			if (!HasKey(keyId))
			{
				throw new ApplicationException(String.Format("Key not found '{0}'", keyId));
			}

			foreach (Key lpKey in Keys)
			{
				if (lpKey.Id.Equals(keyId))
				{
					lpKey.IsCurrent = true;
				}
				else
				{
					lpKey.IsCurrent = false;
				}
			}
		}

		/// <summary>
		///   Check validity
		/// </summary>
		/// <returns></returns>
		public bool IsValid(List<string> errors)
		{
			if (String.IsNullOrEmpty(Name))
			{
				errors.Add("Missing name in key class");
				return false;
			}

			if (Keys == null)
			{
				errors.Add(String.Format("No keys specified for key class '{0}'", Name));
				return false;
			}

			foreach (Key key in Keys)
			{
				if (!key.IsValid(errors))
				{
					errors.Add(String.Format("Problem with key in key class '{0}'", Name));
					return false;
				}
			}

			return true;
		}

		/// <summary>
		///    Add a key
		/// </summary>
		/// <param name="key"></param>
		public void AddKey(Key key)
		{
			keys.Add(key);
		}

		/// <summary>
		///   Sort
		/// </summary>
		public void SortKeys()
		{
			keys.Sort();
		}

		/// <summary>
		///   ToString
		/// </summary>
		/// <returns></returns>
		public override string ToString()
		{
			return ("Name:" + Name);
		}

		/// <summary>
		///    GetHashCode
		/// </summary>
		/// <returns></returns>
		public override int GetHashCode()
		{
			return Name.GetHashCode();
		}

		/// <summary>
		///   Equals
		/// </summary>
		/// <param name="obj"></param>
		/// <returns></returns>
		public override bool Equals(object obj)
		{
			if (obj == null)
			{
				return false;
			}

			KeyClass keyClass = obj as KeyClass;
			if (keyClass != null)
			{
				return this.Name == keyClass.Name;
			}

			return false;
		}

		/// <summary>
		///   CompareTo
		/// </summary>
		/// <param name="obj"></param>
		/// <returns></returns>
		public int CompareTo(object obj)
		{
			KeyClass keyClass = obj as KeyClass;
			if (keyClass != null)
			{
				return CompareTo(keyClass);
			}
			else
			{
				throw new ArgumentException("Both objects being compared must be of type KeyClass.");
			}
		}

		/// <summary>
		///    CompareTo
		/// </summary>
		/// <param name="other"></param>
		/// <returns></returns>
		public int CompareTo(KeyClass other)
		{
			return this.Name.CompareTo(other.Name);
		}

		#endregion
	}
}
