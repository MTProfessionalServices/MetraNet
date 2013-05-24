namespace MetraTech.Collections
{
	using System;
	using System.Collections;
	using System.Runtime.InteropServices;

	/// <summary>
	/// This is only partially implemented.
	/// </summary>
	[ComVisible(true)]
	[Guid("89849B6A-A35E-4af2-A457-9CA7586FB88F")]
	public interface IMTHashtable
	{
		void Add(string key, object o);
		bool CaseSensitivityOn { get; set; }
		bool Contains(string key);
		object this[string key] { get; set; }
	}

	/// <summary>
	/// Class used to expose a hashtable via COM,
	/// with added ability to enable/disable case sensitivity.
	/// Case sensitivity is off by default.
	/// </summary>
	/// 
	[ComVisible(true)]
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("5D06E86A-9BA8-4261-9DA8-3BB5B1FFF6C1")]
	public class MTHashtable : IMTHashtable
	{
		private Hashtable mCache = new Hashtable();
		private bool mCaseSensitivityOn = false;
		public IEnumerable Cache
		{
			get { return mCache.Values as IEnumerable; }
		}

		public MTHashtable()
		{
		}

		public void Add(string key, object o)
		{
			if (mCaseSensitivityOn)
				mCache.Add(key, o);
			else
				mCache.Add(key.ToLower(), o);
		}

		public bool CaseSensitivityOn
		{
			get { return mCaseSensitivityOn; }
			set { mCaseSensitivityOn = value; }
		}

		public bool Contains(string key)
		{
			if (mCaseSensitivityOn)
				return mCache.Contains(key);
			else
				return mCache.Contains(key.ToLower());
		}

		public object this[string key]
		{
			get
			{
				if (!mCaseSensitivityOn)
					key = key.ToLower();
				
				return mCache[key];
			}
			set
			{
				mCache[key] = value;
			}
		}
	}
}

// EOF