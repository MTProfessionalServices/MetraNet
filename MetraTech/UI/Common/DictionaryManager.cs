using System;
using System.Xml;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Runtime.InteropServices;
using System.Threading;

[assembly: GuidAttribute("74820C6F-A555-4f16-BE6B-4B75B4AE718E")]
namespace MetraTech.UI.Common
{

  [Guid("7271F644-133B-4c6d-9F24-F7143E2B19F7")]
  public interface IDictionaryManager
  {
    void LoadDirectory(string directory, string baseTag, string itemTag, string culture);
    void Render();
    string PreProcess(string str);
    object GetValue(string key, object defaultValue);
    void Add(string key, object value);
    void AddShared(string key, object value);
    bool Contains(string key);
    bool Exist(string key);
    void Clear();
    void Remove(string key);
    string ToString();
    int Count { get; } 
    object this[string Index] { get; set; }
  }

  [Guid("B30545CD-F706-469f-BCCC-BBF73D106050")]
  [ClassInterface(ClassInterfaceType.None)]
  [Serializable]
  public class DictionaryManager: /*FreeThreadedMashaler,*/ IDictionaryManager
  {
    private IDictionary<string, object> mLocalDictionary = new Dictionary<string, object>();
    private static Hashtable mSharedDictionaries = new Hashtable();
    
    /// <summary>
    /// Get the SharedDictionary for the current UI culture from the shared hashtable of dictionaries
    /// </summary>
    private IDictionary<string, object> SharedDictionary
    {
      get
      {
        IDictionary<string, object> dict = mSharedDictionaries[Thread.CurrentThread.CurrentUICulture.Name] as IDictionary<string, object>;
        if (dict != null)
        {
          return mSharedDictionaries[Thread.CurrentThread.CurrentUICulture.Name] as IDictionary<string, object>;
        }
        else
        {
          return mSharedDictionaries["en-US"] as IDictionary<string, object>;
        }
      }
    }

    public DictionaryManager() : this("en-US") 
    {
    }

    /// <summary>
    /// Create 'singleton' Hashtable keyed off culture of the shared dictionary
    /// </summary>
    public DictionaryManager(string culture)
    {
      if(!mSharedDictionaries.Contains(culture))
      {
        lock (typeof(IDictionary<string, object>))
        {
          if (!mSharedDictionaries.Contains(culture))
          {
            mSharedDictionaries.Add(culture, new Dictionary<string, object>());
          }
        }
      }
    }

    /// <summary>
    /// Gets or sets the string value associated with the given key. 
    /// Sets always go to the local dictionary, but Gets will first
    /// pull from the local and then the shared.
    /// </summary>
    /// <param name="key">
    /// The object whose value to get or set.
    /// </param>
    public object this[string key]
    {
      get
      {
        if (mLocalDictionary.ContainsKey(key))
        {
          return (object)mLocalDictionary[key];
        }
        else if (SharedDictionary.ContainsKey(key))
        {
          return (object)SharedDictionary[key];
        }
        else
        {
          //throw new ApplicationException("Could not find key [" + key + "] in dictionary.");
          return key;
        }
      }
      set
      {
        mLocalDictionary[key] = value;
      }
    }

    /// <summary>
    /// Loads dictionary files into the shared dictionary
    /// </summary>
    /// <param name="directory"></param>
    /// <param name="baseTag"></param>
    /// <param name="itemTag"></param>
    /// <param name="culture"></param>
    public void LoadDirectory(string directory, string baseTag, string itemTag, string culture)
    {
      if (Directory.Exists(directory))
      {
        if (baseTag == null)
        {
          baseTag = "dictionary";
        }
        if (itemTag == null)
        {
          itemTag = "item";
        }

        DirectoryInfo dirInfo = new DirectoryInfo(directory);
        XmlDocument xml = new XmlDocument();

        // Load all files in the directory
        foreach (FileInfo fi in dirInfo.GetFiles("*.xml"))
        {
          xml.Load(fi.FullName);
          XmlNodeList nodes = xml.SelectNodes("/" + baseTag + "/" + itemTag);
          foreach (XmlNode node in nodes)
          {
            // Use the this override notation because the add method
            // does not support replacing an existing key
            ((IDictionary<string, object>)mSharedDictionaries[culture])[node.Attributes["id"].InnerText] = node["value"].InnerText;
          }
        }

        // Recursively call LoadDirectory for each directory
        foreach (DirectoryInfo dri in dirInfo.GetDirectories())
        {
          LoadDirectory(dri.FullName, baseTag, itemTag, culture);
        }
      }
    }

    /// <summary>
    /// Replaces dictionary entries or "KeyTerms" in the shared and local dictionaries
    /// </summary>
    public void Render()
    {
      Regex regexKey = new Regex(@"\[[^\]]*\]", RegexOptions.IgnoreCase | RegexOptions.Compiled);
      Match mt;
      string replaceKey;
      string newKey;

      // Because we can not modifiy while we enumerate
      // we must *new* the Keys collection
      foreach(string key in new ArrayList(mLocalDictionary.Keys as ICollection))
      {
        // Replace each key value found in the mLocalDictionary with a dictionary value
        for(mt = regexKey.Match(mLocalDictionary[key].ToString()); mt.Success; mt = mt.NextMatch()) 
        {
          replaceKey = mt.ToString();
          newKey = replaceKey.Substring(1, replaceKey.Length -2);
          if (Contains(newKey))
          {
            mLocalDictionary[key] = mLocalDictionary[key].ToString().Replace(replaceKey, this[newKey].ToString());
          }
        }
      }
      foreach (string key in new ArrayList(SharedDictionary.Keys as ICollection))
      {
        // Replace each key value found in the SharedDictionary with a dictionary value
        for(mt = regexKey.Match(SharedDictionary[key].ToString()); mt.Success; mt = mt.NextMatch()) 
        {
          replaceKey = mt.ToString();
          newKey = replaceKey.Substring(1, replaceKey.Length -2);
          if(Contains(newKey))
          {
            SharedDictionary[key] = SharedDictionary[key].ToString().Replace(replaceKey, this[newKey].ToString());
          }
        }
      }

    }

    /// <summary>
    /// Replaces any [dictionary_entries] in a string
    /// </summary>
    /// <param name="str"></param>
    /// <returns></returns>
    public string PreProcess(string str)
    {
      Regex regexKey = new Regex(@"\[[^\]]*\]", RegexOptions.IgnoreCase | RegexOptions.Compiled);

      // Step 1:  Use a compiled Regex to pull out possible [key] values in a collection
      MatchCollection mc = regexKey.Matches(str);

      // Step 2:  Replace dictionary entries in the string
      if(mc.Count > 0) 
      {
        string replaceKey;
        string newKey;
        foreach(Match m in mc) 
        {
          replaceKey = m.ToString();
          newKey = replaceKey.Substring(1, replaceKey.Length -2);
          if (mLocalDictionary.ContainsKey(newKey))
          {
            str = str.Replace(replaceKey, this[newKey].ToString());
          }
          else if (SharedDictionary.ContainsKey(newKey))
          {
            str = str.Replace(replaceKey, this[newKey].ToString());
          }
        }
      }
      return str;
    }

    /// <summary>
    /// Returns the object associated with the given key
    /// or returns the given default value.  Looks in the local 
    /// dictionary first and then the shared one.
    /// </summary>
    /// <param name="key">
    /// The string whose value to get.
    /// </param>
    /// <param name="defaultValue">
    /// The value to return if the key does not exist.
    /// </param>
    public object GetValue(string key, object defaultValue)
    {
      if (mLocalDictionary.ContainsKey(key))
      {
        return (object)mLocalDictionary[key];
      }
      else if (SharedDictionary.ContainsKey(key))
      {
        return (object)SharedDictionary[key];
      }
      else
      {
        mLocalDictionary.Add(key, defaultValue);
        return defaultValue;
      }
    }

    /// <summary>
    /// Adds an element with the specified key to the local dictionary.
    /// </summary>
    /// <param name="key">
    /// The string key of the element to add.
    /// </param>
    /// <param name="newValue">
    /// The object value of the element to add.
    /// </param>
    public void Add(string key, object newValue)
    {
      mLocalDictionary.Add(key, newValue);
    }

    /// <summary>
    /// Adds an element with the specified key to the shared dictionary.
    /// </summary>
    /// <param name="key">
    /// The string key of the element to add.
    /// </param>
    /// <param name="newValue">
    /// The object value of the element to add.
    /// </param>
    public void AddShared(string key, object newValue)
    {
      SharedDictionary.Add(key, newValue);
    }

    /// <summary>
    /// Determines whether either the shared or local dictionary contains a specified key
    /// </summary>
    /// <param name="key">
    /// The string key to locate.
    /// </param>
    /// <returns>
    /// true if this DictionaryManager contains an element with the specified key;
    /// otherwise, false.
    /// </returns>
    public bool Contains(string key)
    {
      return(mLocalDictionary.ContainsKey(key) || SharedDictionary.ContainsKey(key));
    }

    /// <summary>
    /// Determines whether either the shared or local dictionary contains a specified key
    /// </summary>
    /// <param name="key">
    /// The string key to locate.
    /// </param>
    /// <returns>
    /// true if this DictionaryManager contains an element with the specified key;
    /// otherwise, false.
    /// </returns>
    public bool Exist(string key)
    {
      return (mLocalDictionary.ContainsKey(key) || SharedDictionary.ContainsKey(key));
    }

    /// <summary>
    /// Clears both the local and shared dictionaries.
    /// </summary>
    public void Clear()
    {
      mLocalDictionary.Clear();
      SharedDictionary.Clear();
    }

    /// <summary>
    /// ToString of name value pairs in both the local and shared dictionaries
    /// </summary>
    /// <returns></returns>
    public new string ToString()
    {
      System.Text.StringBuilder sb = new System.Text.StringBuilder();

      foreach (KeyValuePair<string, object> entry in mLocalDictionary)
      {
        sb.Append(entry.Key);
        sb.Append(" = ");
        sb.Append(entry.Value);
        sb.Append(System.Environment.NewLine);
      }
      foreach (KeyValuePair<string, object> entry in SharedDictionary)
      {
        sb.Append(entry.Key);
        sb.Append(" = ");
        sb.Append(entry.Value);
        sb.Append(System.Environment.NewLine);
      }
      return sb.ToString();
    }

    /// <summary>
    /// Total entries in both shared and local dictionaries
    /// </summary>
    public int Count
    {
      get{ return(mLocalDictionary.Count + SharedDictionary.Count); }
    }

    public void Remove(string key)
    {
      if(mLocalDictionary.ContainsKey(key))
        mLocalDictionary.Remove(key);
      else if(SharedDictionary.ContainsKey(key))
        SharedDictionary.Remove(key);
    }
  
  }

}


