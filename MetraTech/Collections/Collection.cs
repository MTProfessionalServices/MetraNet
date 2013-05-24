using System.Runtime.InteropServices;

[assembly: GuidAttribute("4D14D0A4-307D-43d3-BC7E-0AE198DDF8B8")]

namespace MetraTech.Collections
{
  using System.Collections;
  using System.Collections.Specialized;
	using System;
	using System.Xml.Serialization;
	using System.Runtime.Serialization;
	using System.Runtime.Serialization.Formatters.Soap;
	using System.Runtime.InteropServices;

	//	using MetraTech.Interop.MetraTechInterfacesLib;
	//using MetraTech.Interop.GenericCollection;
	using MetraTech.Interop.MTBillingReRun;

	//
	// MetraTech.Collection is similar to the classes in GenericCollection
	// but it's 100% .NET and is serializable.
	//
	[Serializable]
	public class Collection : IMTCollection, IEnumerable
	{
		public IEnumerator GetEnumerator()
		{
			return new CollectionEnumerator(this);
		}

		// NOTE: the collection is 1 based!
		public object this[int index]
		{
			get
			{ return mValues[index - 1]; }
			set
			{ mValues[index - 1] = value; }
		}

		public int Count
		{
			get
			{
				return mValues.Count;
			}
		}

		public void Sort()
		{
			System.Diagnostics.Debug.Assert(false, "Sort not implemented");
			throw new ApplicationException("Sort not implemented");
		}

		public void Add(object item)
		{
			mValues.Add(item);
		}

		public void Insert(object item, int index)
		{
			mValues.Insert(index, item);
		}
												 
		public void Remove(int index)
		{
			mValues.Remove(index);
		}

		private ArrayList mValues = new ArrayList();
	}

	public class CollectionEnumerator : IEnumerator
	{
		internal CollectionEnumerator(Collection collection)
		{
			mCollection = collection;
			// NOTE: the collection is 1 based!
			mItem = 0;
		}

		public object Current
		{
			get
			{
				return mCollection[mItem];
			}
		}

		public bool MoveNext()
		{
			if (mItem >= mCollection.Count)
				return false;
			mItem++;
			return true;
		}

		public void Reset()
		{
			mItem = 0;
		}

		private Collection mCollection;
		private int mItem;
	}

  /// <summary>
  /// Derived from .Net StringCollection with added case-insensitive lookup.  
  /// </summary>
  [ComVisible(false)]
  public class MTStringCollection : StringCollection 
  {
    public bool ContainsCaseInsensitive(string target) 
    { 
      foreach (string s in this)
        if (0 == string.Compare(s, target, true))
          return true;
      return false; 
    }
  }

}


// EOF