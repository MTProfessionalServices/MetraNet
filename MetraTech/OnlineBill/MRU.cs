using System;
using System.Collections;
using System.Collections.Specialized;
using System.Threading;
using System.Text;
using System.Runtime.InteropServices;

namespace CodeProject.Collections
{
  /// <summary>
  /// Many times during the usage of an algorithm, a list of the last (n) most recently used 
  /// items comes to be usefull.  Sometimes this is referred to the least recently used (LRU)
  /// cache, but this simply implies which e elements that fall out of the list (i.e. the 
  /// least recently used ones).  
  /// 
  /// The usage of the class is the same of a hash table.  Keys and values are insert into
  /// the table.  If a new key is inserted into the table and the cache has exceeded the 
  /// set size, then the least recently used item is removed from the table, and an event
  /// is fired to signal that the element has fallen off the list.
  /// 
  /// Basically, as items are added to the list, they are appended
  /// to a doubly linked list.  This list is usefull in the fact that it allows deletion and
  /// insertion at O(1) time.  Since if a reference element (n) is not in the list of most
  /// recently used items, then at least one value falls out of the cache.
  /// </summary>
  /// <example>
  /// 
  ///			MostRecentlyUsed	mru	= new MostRecentlyUsed( 3 ) ;
  ///			
  ///			mru.OnPurgedFromCache	+= new PurgedFromCacheDelegate(mru_OnPurgedFromCache);
  ///
  ///			Console.WriteLine( ">> State: " + mru ) ;
  ///
  ///			for( int i = 0 ; i < 5 ; i++ ) 
  ///			{
  ///				Console.WriteLine( "Adding " + i ) ;
  ///
  ///				mru[ i ]	= i ;
  ///
  ///				Console.WriteLine( ">> State: " + mru ) ;
  ///			}
  ///
  ///			// Reference a couple of items
  ///			Console.WriteLine( "Query for " + mru[ 3 ] ) ;
  ///			Console.WriteLine( ">> State: " + mru ) ;
  ///			Console.WriteLine( "Query for " + mru[ 2 ] ) ;
  ///			Console.WriteLine( ">> State: " + mru ) ;
  ///			Console.WriteLine( "Query for " + mru[ 4 ] ) ;
  ///			Console.WriteLine( ">> State: " + mru ) ;
  ///
  ///			// Add a few more
  ///			for( int i = 5 ; i < 7 ; i++ ) 
  ///			{
  ///				Console.WriteLine( "Adding " + i ) ;
  ///				Console.WriteLine( ">> State: " + mru ) ;
  ///				mru[ i ]	= i ;
  ///			}
  ///
  ///			// Reference the tail
  ///			Console.WriteLine( "Query for " + mru[ 4 ] ) ;
  ///			Console.WriteLine( ">> State: " + mru ) ;
  ///			
  ///		------------------------------------------------------------
  ///		Output:
  ///		------------------------------------------------------------
  ///		
  ///		>> State: []
  /// 	Adding 0
  /// 	>> State: [0]
  /// 	Adding 1
  /// 	>> State: [1, 0]
  /// 	Adding 2
  /// 	>> State: [2, 1, 0]
  /// 	Adding 3
  /// 	item purged from cache: 0 , 0
  /// 	>> State: [3, 2, 1]
  /// 	Adding 4
  /// 	item purged from cache: 1 , 1
  /// 	>> State: [4, 3, 2]
  /// 	Query for 3
  /// 	>> State: [3, 4, 2]
  /// 	Query for 2
  /// 	>> State: [2, 3, 4]
  /// 	Query for 4
  /// 	>> State: [4, 2, 3]
  /// 	Adding 5
  /// 	>> State: [4, 2, 3]
  /// 	item purged from cache: 3 , 3
  /// 	Adding 6
  /// 	>> State: [5, 4, 2]
  /// 	item purged from cache: 2 , 2
  /// 	Query for 4
  /// 	>> State: [4, 6, 5]
  /// </example>
  [ComVisible(false)]
  public class MostRecentlyUsed : DictionaryBase
  {
    uint m_max = 50;
    DoubleLinkedList m_list = new DoubleLinkedList();
    HybridDictionary m_linkToKey = new HybridDictionary(); // LinkItem -> key
    object m_modLock = new object();

    /// <summary>
    /// Default constructor for the most recently used items using the default size (50)
    /// </summary>
    public MostRecentlyUsed()
    {
      //
      // TODO: Add constructor logic here
      //
    }


    /// <summary>
    /// Construct a most recently used items list with the maximum number of items
    /// allowed in the list.
    /// </summary>
    /// <param name="maxItems">Maximum number of items allowed</param>
    public MostRecentlyUsed(uint maxItems)
    {
      m_max = maxItems;
    }

    public object this[object key]
    {
      get
      {
          lock (m_modLock)
          {
              DoubleLinkedList.LinkItem item = (DoubleLinkedList.LinkItem)Dictionary[key];

              if (item == null)
                  return null;

              m_list.MoveToHead(item);

              return (item.Item);
          }
      }
      set
      {
        DoubleLinkedList.LinkItem link = null;

        lock (m_modLock)
        {
            if (Dictionary.Contains(key))
            {
                link = (DoubleLinkedList.LinkItem)Dictionary[key];
                link.Item = value;

                m_list.MoveToHead(link);

                Dictionary[key] = link;

                // Keep a reverse index from the link to the key
                m_linkToKey[link] = key;
            }
            else
            {
                Add(key, value);
            } 
        }
      }
    }

    public ICollection Keys
    {
      get
      {
        return (Dictionary.Keys);
      }
    }

    public ICollection Values
    {
      get
      {
        return (Dictionary.Values);
      }
    }

    public void Add(object key, object value)
    {
        lock (m_modLock)
        {
            DoubleLinkedList.LinkItem link = m_list.Prepend(value);

            Dictionary.Add(key, link);

            // Keep a reverse index from the link to the key
            m_linkToKey[link] = key; 
        }
    }

    public bool Contains(object key)
    {
        lock (m_modLock)
        {
            bool hasKey = Dictionary.Contains(key);

            // Update the reference for this link
            if (hasKey)
                m_list.MoveToHead((DoubleLinkedList.LinkItem)Dictionary[key]);

            return (hasKey);
        }
    }

    public void Remove(object key)
    {
        lock (m_modLock)
        {
            DoubleLinkedList.LinkItem link =
              (DoubleLinkedList.LinkItem)Dictionary[key];

            Dictionary.Remove(key);

            if (link != null)
            {
                m_list.RemoveLink(link);

                // Keep a reverse index from the link to the key
                m_linkToKey.Remove(link);
            }
        }
    }

    protected override void OnInsert(Object key, Object value)
    {
        lock (m_modLock)
        {
            if (Dictionary.Keys.Count >= m_max)
            {
                // Purge an item from the cache
                DoubleLinkedList.LinkItem tail = m_list.TailLink;

                if (tail != null)
                {
                    object purgeKey = m_linkToKey[tail];

                    // Fire the event
                    if (OnPurgedFromCache != null && OnPurgedFromCache.GetInvocationList().Length > 0)
                    {
                        OnPurgedFromCache(purgeKey, tail.Item);
                    }

                    Remove(purgeKey);
                }
            }
        }
    }

    protected override void OnRemove(Object key, Object value)
    {
      ;
    }

    protected override void OnSet(Object key, Object oldValue, Object newValue)
    {
      ;
    }

    protected override void OnValidate(Object key, Object value)
    {
      ;
    }

    /// <summary>
    /// The maximum capacity of the list
    /// </summary>
    public uint Capacity
    {
      get { return m_max; }
      set { m_max = value; }
    }
    [ComVisible(false)]
    public delegate void PurgedFromCacheDelegate(object key, object value);

    /// <summary>
    /// Event that is fired when an item falls outside of the cache
    /// </summary>
    public event PurgedFromCacheDelegate OnPurgedFromCache;

    public override string ToString()
    {
      StringBuilder buff = new StringBuilder(Convert.ToInt32(m_max));

      buff.Append("[");

      foreach (object item in m_list)
      {
        if (buff.Length > 1)
          buff.Append(", ");

        buff.Append(item.ToString());
      }

      buff.Append("]");

      return buff.ToString();
    }

    //		public bool				TestAndSetIfFirst( string key , string toAdd ) 
    //		{
    //			lock( m_refCount.SyncRoot ) 
    //			{
    //				if ( m_refCount.ContainsKey( key ) ) 
    //				{
    //					// Keep a reference count of each value
    //					m_refCount[ key ]	= Math.Min( uint.MaxValue - 1, (uint)m_refCount[ key ] + 1 ) ;
    //
    //					return false ;
    //				}
    //				else 
    //				{
    //					Add( key , toAdd ) ;
    //
    //					return true ;
    //				}
    //			}
    //		}

    public static void Main(string[] args)
    {
      MostRecentlyUsed mru = new MostRecentlyUsed(3);

      mru.OnPurgedFromCache += new PurgedFromCacheDelegate(mru_OnPurgedFromCache);

      Console.WriteLine(">> State: " + mru);

      for (int i = 0; i < 5; i++)
      {
        Console.WriteLine("Adding " + i);

        mru[i] = i;

        Console.WriteLine(">> State: " + mru);
      }

      // Reference a couple of items
      Console.WriteLine("Query for " + mru[3]);
      Console.WriteLine(">> State: " + mru);
      Console.WriteLine("Query for " + mru[2]);
      Console.WriteLine(">> State: " + mru);
      Console.WriteLine("Query for " + mru[4]);
      Console.WriteLine(">> State: " + mru);

      // Add a few more
      for (int i = 5; i < 7; i++)
      {
        Console.WriteLine("Adding " + i);
        Console.WriteLine(">> State: " + mru);
        mru[i] = i;
      }

      // Reference the tail
      Console.WriteLine("Query for " + mru[4]);
      Console.WriteLine(">> State: " + mru);

    }

    private static void mru_OnPurgedFromCache(object key, object value)
    {
      Console.WriteLine("item purged from cache: " + key.ToString() + " , " + value.ToString());
    }
  }

  /// <summary>
  /// Class that represents a doubly linked list (I can't believe that .NET didn't 
  /// have one of these).  The primary usage for this class is with the MostRecenlyUsed class,
  /// but can be used in a variety of scenarios.
  /// </summary>
  [ComVisible(false)]
  public class DoubleLinkedList : IList
  {
    /// <summary>
    /// Class that represents an element in the doubly linked list
    /// </summary>
    [ComVisible(false)]
    public class LinkItem
    {
      /// <summary>
      /// Next item in the list
      /// </summary>
      public LinkItem Next;
      /// <summary>
      /// Previous item in the list
      /// </summary>
      public LinkItem Previous;
      /// <summary>
      /// Current item that this node points to (ie the value)
      /// </summary>
      public object Item;

      /// <summary>
      /// Build a new LinkItem pointing to the next, previous and current value
      /// </summary>
      /// <param name="next">The next LinkItem in the list</param>
      /// <param name="previous">The previous LinkItem in the list</param>
      /// <param name="item">The current value that this item points to</param>
      public LinkItem(LinkItem next, LinkItem previous, object item)
      {
        Next = next;
        Previous = previous;
        Item = item;
      }

      public override string ToString()
      {
        if (Item != null)
          return Item.ToString();
        else
          return "null";
      }

    }

    /// <summary>
    /// Remove the specified link from the list
    /// </summary>
    /// <param name="item">Item to remove </param>
    public void RemoveLink(LinkItem item)
    {
      // Check the arguments
      if (item == null)
        return;

      LinkItem next = item.Next;
      LinkItem prev = item.Previous;

      if (HeadLink == item)
        HeadLink = next;
      if (TailLink == item)
        TailLink = prev;

      if (prev != null)
        prev.Next = next;
      if (next != null)
        next.Previous = prev;

      // Decrement the count
      Interlocked.Decrement(ref m_count);
    }
    /// <summary>
    /// Prepend the specified value to the head of the list
    /// </summary>
    /// <param name="value">Value to prepend to the list (not a LinkItem)</param>
    /// <returns>The LinkItem which points to this new value</returns>
    public LinkItem Prepend(object value)
    {
      LinkItem newItem = new LinkItem(HeadLink, null, value);

      if (HeadLink != null)
        HeadLink.Previous = newItem;

      if (TailLink == null)
        TailLink = newItem;

      HeadLink = newItem;

      // Increment the count
      Interlocked.Increment(ref m_count);

      return newItem;
    }
    /// <summary>
    /// Append the specified value to the tail of the list (not a LinkItem)
    /// </summary>
    /// <param name="value">The value to append to the list</param>
    /// <returns>The new LinkItem which points to the value</returns>
    public LinkItem Append(object value)
    {
      // Append this item to the tail
      if (TailLink != null)
      {
        TailLink = new LinkItem(null, TailLink, value);
        TailLink.Previous.Next = TailLink;
      }

      if (HeadLink == null)
        HeadLink = TailLink;

      // Increment the count
      Interlocked.Increment(ref m_count);

      return TailLink;
    }

    /// <summary>
    /// Move the specified LinkItem to the head of the list
    /// </summary>
    /// <param name="item">The existing LinkItem in the list</param>
    public void MoveToHead(LinkItem item)
    {
      if (item == null)
        return;

      if (item != HeadLink)
      {
        LinkItem prev = item.Previous;
        LinkItem next = item.Next;

        if (prev != null)
          prev.Next = next;
        if (next != null)
          next.Previous = prev;

        if (TailLink == item)
          TailLink = prev;

        if (HeadLink != null)
          HeadLink.Previous = item;

        item.Next = HeadLink;
        item.Previous = null;
        HeadLink = item;
      }
    }


    object m_syncRoot = new object();
    public LinkItem HeadLink = null;
    public LinkItem TailLink = null;
    int m_count = 0;

    #region IList Members


    public bool IsReadOnly
    {
      get
      {
        // TODO:  Add DoubleLinkedList.IsReadOnly getter implementation
        return false;
      }
    }

    public object this[int index]
    {
      get
      {
        int i = 0;
        LinkItem current = HeadLink;
        object item = null;

        // Skip to the index
        for (i = 0, current = HeadLink; current != null && i < index; i++, current = current.Next) ;

        if (i == index && current != null)
        {
          item = current.Item;
        }

        return item;
      }
      set
      {
        int i = 0;
        LinkItem current = HeadLink;

        // Skip past existing items
        for (i = 0, current = HeadLink; current != null && i < index; i++, current = current.Next) ;

        if (i == index && current != null)
        {
          current.Item = value;
        }
      }
    }

    public void RemoveAt(int index)
    {
      int i = 0;
      LinkItem current = HeadLink;

      // Skip past existing items
      for (i = 0, current = HeadLink; current != null && i < index; i++, current = current.Next) ;

      if (i == index && current != null)
      {
        LinkItem prev = current.Previous;
        LinkItem next = current.Next;

        if (current == HeadLink)
        {
          HeadLink = next;
        }
        else if (prev != null)
        {
          prev.Next = next;
        }

        if (TailLink == current)
        {
          TailLink = prev;
        }
        else if (next != null)
        {
          next.Previous = prev;
        }

        // Decrement the count
        Interlocked.Decrement(ref m_count);
      }
    }

    public void Insert(int index, object value)
    {
      int i = 0;
      LinkItem current = HeadLink;

      // Skip past existing items
      for (i = 0, current = HeadLink; current != null && i < index; i++, current = current.Next) ;

      if (i == index && current != null)
      {
        // Create the next link item
        LinkItem newItem = new LinkItem(current, current.Previous, value);

        current.Previous.Next = newItem;
        current.Previous = newItem;

        if (HeadLink == current)
          HeadLink = newItem;

        // Adjust the count
        Interlocked.Increment(ref m_count);
      }
      else if (current == null)
      {
        Add(value);
      }
    }

    public void Remove(object value)
    {
      LinkItem current;

      // Skip past existing items
      for (current = HeadLink; current != null && current.Item != value; current = current.Next) ;

      if (current != null)
      {
        LinkItem prev = current.Previous;
        LinkItem next = current.Next;

        if (current == HeadLink)
        {
          HeadLink = next;
        }
        else if (prev != null)
        {
          prev.Next = next;
        }

        if (current == TailLink)
        {
          TailLink = prev;
        }
        else if (next != null)
        {
          next.Previous = prev;
        }

        // Adjust the count
        Interlocked.Decrement(ref m_count);
      }
    }

    public bool Contains(object value)
    {
      LinkItem current = HeadLink;
      bool hasItem = false;

      // Skip past existing items
      for (current = HeadLink; current != null && current.Item != value; current = current.Next) ;

      if (current != null)
      {
        hasItem = true;
      }

      return hasItem;
    }

    public void Clear()
    {
      HeadLink = null;
      TailLink = null;
    }

    public int IndexOf(object value)
    {
      LinkItem current = HeadLink;
      int index = -1;

      // Skip past existing items
      for (index = 0, current = HeadLink;
        current != null && current.Item != value;
        index++, current = current.Next) ;

      if (current != null)
      {
        return index;
      }

      return -1;
    }

    public int Add(object value)
    {
      // Append this item to the tail
      TailLink = new LinkItem(null, TailLink, value);

      if (TailLink.Previous != null)
      {
        TailLink.Previous.Next = TailLink;
      }

      if (HeadLink == null)
        HeadLink = TailLink;

      // Adjust the count
      Interlocked.Increment(ref m_count);

      return m_count - 1;
    }

    public bool IsFixedSize
    {
      get
      {
        return false;
      }
    }


    #endregion

    #region ICollection Members

    public bool IsSynchronized
    {
      get
      {
        // TODO:  Add DoubleLinkedList.IsSynchronized getter implementation
        return false;
      }
    }

    public int Count
    {
      get
      {
        return m_count;
      }
    }

    public void CopyTo(Array array, int index)
    {
      int i = 0;
      LinkItem current = null;

      for (i = 0, current = HeadLink;
        current != null && (i + index) < array.Length;
        i++, current = current.Next)
      {
        array.SetValue(current.Item, index + i);
      }
    }

    public object SyncRoot
    {
      get
      {
        return m_syncRoot;
      }
    }


    #endregion

    #region IEnumerable Members

    public IEnumerator GetEnumerator()
    {
      return new EnumLinkList(this);
    }

    /// <summary>
    /// Public class to enumerate the items in the list
    /// </summary>
    [ComVisible(false)]
    public class EnumLinkList : IEnumerator
    {
      DoubleLinkedList m_list = null;
      LinkItem m_current = null;

      public EnumLinkList(DoubleLinkedList list)
      {
        m_list = list;
      }

      public object Current
      {
        get
        {
          return m_current;
        }
      }

      public bool MoveNext()
      {
        bool result = false;

        if (m_current == null)
        {
          // There are no items in the list
          if (m_list.HeadLink == null)
            return false;

          m_current = m_list.HeadLink;
          result = true;
        }
        else if (m_current.Next == null)
        {
          m_current = null;
          result = false;
        }
        else
        {
          m_current = m_current.Next;
          result = true;
        }

        return result;
      }

      public void Reset()
      {
        m_current = null;
      }
    }


    #endregion
  }



}
