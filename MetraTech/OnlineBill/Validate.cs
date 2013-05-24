using System;
using System.Collections;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.IO;
using System.Xml;
using System.Xml.Serialization;
using MetraTech;

namespace MetraTech.OnlineBill
{
  [Guid("49EA03EF-52C1-4a88-A078-93774EDAA0B7")]
  public interface IValidate
  {
    void Initialize(string configFile);
    bool MatchString(string str, string regexstr);
    bool IsValid(string key, string str);
    string WhiteList { get; }
  }

  [ClassInterface(ClassInterfaceType.None)]
  [Guid("C7739045-8E7C-477f-9F50-DC5BCA27F14F")]
  public class Validate : FreeThreadedMashaler, IValidate
  {
    private Logger mLogger = new Logger("[Validate]");
    private Validation mConfig = null;

    public string WhiteList
    {
      get { return mConfig.WhiteList; }
    }

    public Validate()
    {
      // Create initial config file
      //Validation v = new Validation();
      //Item itm = new Item();
      //itm.Name = "Test";
      //itm.Expression = "reg";
      //v.AddItem(itm);
      //v.Save();
    }

    public void Initialize(string configFile)
    {
      mConfig = Validation.Load(configFile);
    }

    // Validate string against expression defined in config based on key
    public bool IsValid(string key, string str)
    {
      return MatchString(str, mConfig[key].Expression);
    }

    // Decomposed method which actually creates the pattern object and determines the match.
    public bool MatchString(string str, string regexstr)
    {
      str = str.Trim();
      Regex pattern = new System.Text.RegularExpressions.Regex(regexstr,
                                                                 RegexOptions.IgnoreCase
                                                               | RegexOptions.CultureInvariant        /* Support Unicode */
                                                               | RegexOptions.IgnorePatternWhitespace
                                                               | RegexOptions.Compiled);

      bool ret = pattern.IsMatch(str);

      if (!ret)
      {
        mLogger.LogInfo("Could not match input string to regexp: " + regexstr);
        // The next line is useful for debugging, but not safe for prooduction
        // mLogger.LogInfo("Could not match input [" + str + "] string to regexp: " + regexstr);
      }

      return ret;
    }


  }

  [ComVisible(false)]
  public class Item
  {
    public string Name;
    public string Expression;
  }

  [ComVisible(false)]
  public class Validation
  {
    public string WhiteList = "";
    private ArrayList mItems = new ArrayList();
    public Item[] Items
    {
      get
      {
        Item[] items = new Item[mItems.Count];
        mItems.CopyTo(items);
        return items;
      }
      set
      {
        if (value == null) return;
        Item[] items = (Item[])value;
        mItems.Clear();
        foreach (Item item in items)
          mItems.Add(item);
      }
    }

    public int AddItem(Item item)
    {
      return mItems.Add(item);
    }

    public Item this[string name]
    {
      get
      {
        foreach (Item itm in Items)
        {
          if (itm.Name.ToLower() == name.ToLower())
          {
            return itm;
          }
        }
        return null;
      }
    }

   /* public bool Save()
    {
      // Serialization - only used to create initial file
      XmlSerializer s = new XmlSerializer(typeof(Validation));
      string configFile = @"c:\temp\";
      configFile = configFile.Substring(0, configFile.LastIndexOf(@"\")) + @"\Validation.xml";
      TextWriter w = new StreamWriter(configFile);
      s.Serialize(w, this);
      w.Close();
      return true;
    }
    */

    public static Validation Load(string configFile)
    {
      // Deserialization
      XmlSerializer s = new XmlSerializer(typeof(Validation));
      TextReader r = new StreamReader(configFile);
      Validation opt = (Validation)s.Deserialize(r);
      r.Close();
      return opt;
    }

  }
}