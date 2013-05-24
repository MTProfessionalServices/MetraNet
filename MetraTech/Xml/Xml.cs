   
using System.Reflection;
using System.Runtime.InteropServices;

[assembly: GuidAttribute("1621666c-f6e3-46ea-8416-13d8ea421c1d")]

namespace MetraTech.Xml
{
  using System.Xml;
  using System;
  using MetraTech.Interop.RCD;

  /// <summary>
  /// Exception throw from the MTXmlReader class.
  /// </summary>
	[ComVisible(false)]
  public class MTXmlException : System.Xml.XmlException
  {
    //
    // no inner exception
    //
    public MTXmlException(string msg)
      : base (Format(null, msg), null)
    { }

    public MTXmlException(string format, params object[] args)
      : base (Format(null, format, args), null)
    { }

    public MTXmlException(XmlNode badNode, string msg)
      : base (Format(badNode, msg), null)
    { }

    public MTXmlException(XmlNode badNode, string format, params object[] args)
      : base (Format(badNode, format, args), null)
    { }



    //
    // inner exception supplied
    //
    public MTXmlException(System.Exception innerException,
                          string msg)
      : base (Format(null, msg), innerException)
    { }

    public MTXmlException(System.Exception innerException,
                          string format, params object[] args)
      : base (Format(null, format, args), innerException)
    { }

    public MTXmlException(System.Exception innerException,
                          XmlNode badNode, string msg)
      : base (Format(badNode, msg), innerException)
    { }

    public MTXmlException(System.Exception innerException,
                          XmlNode badNode, string format, params object[] args)
      : base (Format(badNode, format, args), innerException)
    { }


    /// <summary>
    /// Format the XPath (if available), filename (if available), and a
    /// message into a nice string.
    /// </summary>
    private static string Format(XmlNode badNode, string format, params object[] args)
    {
      if (badNode == null)
      {
        if (args.Length > 0)
          return string.Format(format, args);
        else
          return format;
      }
      else
      {
        string msg;
        if (args.Length > 0)
          msg = string.Format(format, args);
        else
          msg = format;

        return string.Format("{0}: {1}: {2}",
                             GetFilename(badNode), GetXPath(badNode), msg);
      }
    }

    /// <summary>
    /// Pull the filename out of a node
    /// </summary>
    private static string GetFilename(XmlNode node)
    {
      string uri = node.BaseURI;

      if (uri == String.Empty)
        return "unknown file";

      if (uri.StartsWith("file://"))
      {
        return uri.Substring(8).Replace("/", "\\");
      }
      return uri;
    }

    /// <summary>
    /// Pull the XPath out of a node
    /// </summary>
    private static string GetXPath(XmlNode node)
    {
      // walk the tree up, adding the names to the beginning of the
      // string as we go
      System.Text.StringBuilder path = new System.Text.StringBuilder();
      while (node != null && !(node is XmlDocument))
      {
        path.Insert(0, node.Name);
        path.Insert(0, "/");

        node = node.ParentNode;
      }

      return path.ToString();
    }

  }

  /// <summary>
  /// Helper functions beyond what XmlDocument provides
  /// </summary>

	// TODO: this really shouldn't be COM visible but the VB sample adapter uses it.
	[Guid("4ca93610-410e-4548-8db1-3a03cd6bd16a")]
  public class MTXmlDocument : System.Xml.XmlDocument
  {
    
    static MTXmlDocument()
    {
      IMTRcd rcd = (IMTRcd) new MTRcd();
      mConfigDir = rcd.ConfigDir; 
      mExtensionDir = rcd.ExtensionDir; 
    }

	/// <summary>
	/// Return the configuration path used to open configuration file.
	/// </summary>
	/// <returns></returns>
	public string GetConfigPath()
	{
		return mConfigDir;
	}

    /// <summary>
    /// read a file from the config directory (name is relative to config)
    /// </summary>
    public void LoadConfigFile(string fileName)
    {
      string fullName = mConfigDir + fileName; 
      Load(fullName);
    }

    /// <summary>
    /// read a file from the given extension
    /// </summary>
    public void LoadExtensionConfigFile(string extensionName, string fileName)
    {
      string fullName = mExtensionDir + "/" + extensionName + "/" + fileName; 
      Load(fullName);
    }

	/// <summary>
	/// Save a file to config directory (name is relative to config)
	/// </summary>
	public void SaveConfigFile(string fileName)
	{
		string fullName = mConfigDir + fileName; 
		Save(fullName);
	}

    /// <summary>
    /// returns the MetraNet configuration directory
    /// </summary>
		public static string ConfigDir
		{
			get
			{
				return mConfigDir;
			}
		}

    /// <summary>
    /// returns the MetraNet extension directory
    /// </summary>
		public static string ExtensionDir
		{
			get
			{
				return mExtensionDir;
			}
		}

    /// <summary>
    /// like SelectSingleNode, but make sure there's exactly one match
    /// </summary>
    public XmlNode SelectOnlyNode(string path)
    {
      return SelectOnlyNode(this, path);
    }

    /// <summary>
    /// if there's exactly one match, return it.
    /// if more than one match, throw.
    /// if no matches, return null.
    /// </summary>
    public XmlNode SingleNodeExists(string path)
    {
      return SingleNodeExists(this, path);
    }

    //
    // integer
    //

    /// <summary>
    /// find a single node, then return its value as an int
    /// </summary>
    public int GetNodeValueAsInt(string path)
    {
      return GetNodeValueAsInt(this, path);
    }

    /// <summary>
    /// find a single node, then return its value as an int.
    /// if the node doesn't exist, return the given default
    /// </summary>
    public int GetNodeValueAsInt(string path, int defaultVal)
    {
      return GetNodeValueAsInt(this, path, defaultVal);
    }

    //
    // long
    //

    /// <summary>
    /// find a single node, then return its value as a long.
    /// </summary>
    public long GetNodeValueAsLong(string path)
    {
      return GetNodeValueAsLong(this, path);
    }

    /// <summary>
    /// find a single node, then return its value as a long.
    /// if the node doesn't exist, return the given default
    /// </summary>
    public long GetNodeValueAsLong(string path, long defaultVal)
    {
      return GetNodeValueAsLong(this, path, defaultVal);
    }

    //
    // string
    //

    /// <summary>
    /// find a single node, then return its value as a string
    /// </summary>
    public string GetNodeValueAsString(string path)
    {
      return GetNodeValueAsString(this, path);
    }

    /// <summary>
    /// find a single node, then return its value as a string.
    /// if the node doesn't exist, return the given default
    /// </summary>
    public string GetNodeValueAsString(string path, string defaultVal)
    {
      return GetNodeValueAsString(this, path, defaultVal);
    }

    //
    // DateTime
    //

    /// <summary>
    /// find a single node, then return its value as a DateTime
    /// </summary>
    public DateTime GetNodeValueAsDateTime(string path)
    {
      return GetNodeValueAsDateTime(this, path);
    }

    /// <summary>
    /// find a single node, then return its value as a DateTime.
    /// if the node doesn't exist, return the given default.
    /// </summary>
    public DateTime GetNodeValueAsDateTime(string path,
                                           DateTime defaultVal)
    {
      return GetNodeValueAsDateTime(this, path, defaultVal);
    }

    //
    // decimal
    //

    /// <summary>
    /// find a single node, then return its value as a bool
    /// </summary>
    public decimal GetNodeValueAsDecimal(string path)
    {
      return GetNodeValueAsDecimal(this, path);
    }

    /// <summary>
    /// find a single node, then return its value as a decimal.
    /// if the node doesn't exist, return the given default.
    /// </summary>
    public decimal GetNodeValueAsDecimal(string path,
                                         decimal defaultVal)
    {
      return GetNodeValueAsDecimal(this, path, defaultVal);
    }

    //
    // bool
    //

    /// <summary>
    /// find a single node, then return its value as a bool
    /// </summary>
    public bool GetNodeValueAsBool(string path)
    {
      return GetNodeValueAsBool(this, path);
    }

    /// <summary>
    /// find a single node, then return its value as a DateTime.
    /// if the node doesn't exist, return the given default.
    /// </summary>
    public bool GetNodeValueAsBool(string path,
                                   bool defaultVal)
    {
      return GetNodeValueAsBool(this, path, defaultVal);
    }


    //
    // enum
    //

    /// <summary>
    /// find a single node, then return its value as an enum
    /// </summary>
    public object GetNodeValueAsEnum(Type enumType, string path)
    {
      return GetNodeValueAsEnum(this, enumType, path);
    }

    /// <summary>
    /// find a single node, then return its value as an enum.
    /// if the node doesn't exist, return the given default
    /// </summary>
    public object GetNodeValueAsEnum(Type enumType, string path, object defaultVal)
    {
      return GetNodeValueAsEnum(this, enumType, path, defaultVal);
    }


    /// <summary>
    /// find all filename matching the given query in all extensions
    /// </summary>
    public static System.Collections.IEnumerable FindFilesInExtensions(string path)
    {
      IMTRcd rcd = (IMTRcd) new MTRcd();
      IMTRcdFileList fileList = rcd.RunQuery(path, true);

      return fileList;
    }


    /// <summary>
    /// like SelectSingleNode, but make sure there's exactly one match
    /// </summary>
    public static XmlNode SelectOnlyNode(XmlNode parent, string path)
    {
      XmlNodeList subNodes = parent.SelectNodes(path);
      if (subNodes.Count != 1)
        throw new MTXmlException(parent, "Expected 1 node '{0}' but found {1}",
                                 path, subNodes.Count);
      return subNodes[0];
    }

    /// <summary>
    /// if there's exactly one match, return it.
    /// if more than one match, throw.
    /// if no matches, return null.
    /// </summary>
    public static XmlNode SingleNodeExists(XmlNode parent, string path)
    {
      XmlNodeList subNodes = parent.SelectNodes(path);
      if (subNodes.Count > 1)
        throw new MTXmlException(parent, "Expected 1 node '{0}' but found {1}",
                                 path, subNodes.Count);

      if (subNodes.Count == 1)
        return subNodes[0];
      else
        return null;
    }

    /// <summary>
    /// return true if the node contains only zero or more whitespace
    /// characters
    /// </summary>
    public static bool NodeIsEmpty(XmlNode node)
    {
      string text = node.InnerText;
      for (int i = 0; i < text.Length; i++)
      {
        if (text[i] != '\t'
            && text[i] != '\n'
            && text[i] != '\v'
            && text[i] != '\f'
            && text[i] != '\r')
          return false;
      }
      return true;
    }

    //
    // integer
    //

    /// <summary>
    /// parse an int out of the inner text of a node
    /// </summary>
    public static int GetNodeValueAsInt(XmlNode node)
    {
      string text = node.InnerText;
			return ToInt(text);
    }

    /// <summary>
    /// find a single node, then return its value as an int
    /// </summary>
    public static int GetNodeValueAsInt(XmlNode parent, string path)
    {
      XmlNode node = SelectOnlyNode(parent, path);
      return GetNodeValueAsInt(node);
    }

    /// <summary>
    /// find a single node, then return its value as an int.
    /// if the node doesn't exist, return the given default
    /// </summary>
    public static int GetNodeValueAsInt(XmlNode parent, string path,
                                        int defaultVal)
    {
      XmlNode node = SingleNodeExists(parent, path);
      if (node == null)
        return defaultVal;
      return GetNodeValueAsInt(node);
    }

    /// <summary>
    /// parse an int out of a string
    /// </summary>
		public static int ToInt(string text)
		{
      try
      {
        return System.Convert.ToInt32(text);
      }
      catch (System.FormatException err)
      {
        throw new MTXmlException(err, "Error converting value '{0}' to integer",
                                 text);
      }
		}

    //
    // long
    //

    /// <summary>
    /// parse a long out of the inner text of a node
    /// </summary>
    public static long GetNodeValueAsLong(XmlNode node)
    {
      string text = node.InnerText;
			return ToLong(text);
    }

    /// <summary>
    /// find a single node, then return its value as a long
    /// </summary>
    public static long GetNodeValueAsLong(XmlNode parent, string path)
    {
      XmlNode node = SelectOnlyNode(parent, path);
      return GetNodeValueAsLong(node);
    }

    /// <summary>
    /// find a single node, then return its value as a long.
    /// if the node doesn't exist, return the given default
    /// </summary>
    public static long GetNodeValueAsLong(XmlNode parent, string path,
                                          long defaultVal)
    {
      XmlNode node = SingleNodeExists(parent, path);
      if (node == null)
        return defaultVal;
      return GetNodeValueAsLong(node);
    }

    /// <summary>
    /// parse an long out of a string
    /// </summary>
		public static long ToLong(string text)
		{
      try
      {
        return System.Convert.ToInt64(text);
      }
      catch (System.FormatException err)
      {
        throw new MTXmlException(err, "Error converting value '{0}' to long",
                                 text);
      }
		}

    //
    // string
    //

    /// <summary>
    /// parse a string out of the inner text of a node
    /// </summary>
    public static string GetNodeValueAsString(XmlNode node)
    {
      // this isn't really necessary, but we'll leave it here for symmetry
      string text = node.InnerText;
      return text;
    }

    /// <summary>
    /// find a single node, then return its value as a string
    /// </summary>
    public static string GetNodeValueAsString(XmlNode parent, string path)
    {
      XmlNode node = SelectOnlyNode(parent, path);
      return GetNodeValueAsString(node);
    }

    /// <summary>
    /// find a single node, then return its value as a string.
    /// if the node doesn't exist, return the given default
    /// </summary>
    public static string GetNodeValueAsString(XmlNode parent, string path,
                                              string defaultVal)
    {
      XmlNode node = SingleNodeExists(parent, path);
      if (node == null)
        return defaultVal;
      return GetNodeValueAsString(node);
    }


    //
    // DateTime
    //


    /// <summary>
    /// parse a DateTime out of the inner text of a node
    /// </summary>
    public static DateTime GetNodeValueAsDateTime(XmlNode node)
    {
      string text = node.InnerText;

			// NOTE: we don't call ToDateTime because we want the exception
			// to have information about the node
      try
      {
        return System.Convert.ToDateTime(text);
      }
      catch (System.FormatException err)
      {
        throw new MTXmlException(err, node, "Error converting value '{0}' to DateTime",
                                 text);
      }

    }

    /// <summary>
    /// find a single node, then return its value as a DateTime
    /// </summary>
    public static DateTime GetNodeValueAsDateTime(XmlNode parent, string path)
    {
      XmlNode node = SelectOnlyNode(parent, path);
      return GetNodeValueAsDateTime(node);
    }

    /// <summary>
    /// find a single node, then return its value as a DateTime.
    /// if the node doesn't exist, return the given default.
    /// </summary>
    public static DateTime GetNodeValueAsDateTime(XmlNode parent, string path,
                                                  DateTime defaultVal)
    {
      XmlNode node = SingleNodeExists(parent, path);
      if (node == null)
        return defaultVal;
      return GetNodeValueAsDateTime(node);
    }

    /// <summary>
    /// parse a date time out of an string
    /// </summary>
		public static DateTime ToDateTime(string text)
		{
      try
      {
        return System.Convert.ToDateTime(text);
      }
      catch (System.FormatException err)
      {
        throw new MTXmlException(err, "Error converting value '{0}' to DateTime",
                                 text);
      }
		}


    //
    // decimal
    //


    /// <summary>
    /// parse a decimal out of the inner text of a node
    /// </summary>
    public static decimal GetNodeValueAsDecimal(XmlNode node)
    {
      string text = node.InnerText;
      try
      {
        return System.Convert.ToDecimal(text);
      }
      catch (System.FormatException err)
      {
        throw new MTXmlException(err, node, "Error converting value '{0}' to decimal",
                                 text);
      }
    }

    /// <summary>
    /// find a single node, then return its value as a decimal
    /// </summary>
    public static decimal GetNodeValueAsDecimal(XmlNode parent, string path)
    {
      XmlNode node = SelectOnlyNode(parent, path);
      return GetNodeValueAsDecimal(node);
    }

    /// <summary>
    /// find a single node, then return its value as a decimal.
    /// if the node doesn't exist, return the given default.
    /// </summary>
    public static decimal GetNodeValueAsDecimal(XmlNode parent, string path,
                                                decimal defaultVal)
    {
      XmlNode node = SingleNodeExists(parent, path);
      if (node == null)
        return defaultVal;
      return GetNodeValueAsDecimal(node);
    }

    /// <summary>
    /// parse a decimal out of an string
    /// </summary>
		public static decimal ToDecimal(string text)
		{
      try
      {
        return System.Convert.ToDecimal(text);
      }
      catch (System.FormatException err)
      {
        throw new MTXmlException(err, "Error converting value '{0}' to decimal",
                                 text);
      }
		}


    //
    // bool
    //
    

    /// <summary>
    /// parse a boolean out of an string
    /// </summary>
		public static bool ToBool(string text)
		{
      // System.Convert.ToBoolean only supports the values "True" and "False"
      // so we do our own conversion
      if (string.Compare(text, "true", true) == 0
          || string.Compare(text, "t", true) == 0
          || string.Compare(text, "y", true) == 0
          || string.Compare(text, "yes", true) == 0
          || string.Compare(text, "1", true) == 0)
        return true;

      if (string.Compare(text, "false", true) == 0
          || string.Compare(text, "f", true) == 0
          || string.Compare(text, "n", true) == 0
          || string.Compare(text, "no", true) == 0
          || string.Compare(text, "0", true) == 0)
        return false;

      throw new MTXmlException("Error converting value '{0}' to bool",
                               text);
		}
    /// <summary>
    /// parse a bool out of the inner text of a node
    /// </summary>
    public static bool GetNodeValueAsBool(XmlNode node)
    {
      string text = node.InnerText;
      return ToBool(text);
    }

    /// <summary>
    /// find a single node, then return its value as a bool
    /// </summary>
    public static bool GetNodeValueAsBool(XmlNode parent, string path)
    {
      XmlNode node = SelectOnlyNode(parent, path);
      return GetNodeValueAsBool(node);
    }

    /// <summary>
    /// find a single node, then return its value as a bool.
    /// if the node doesn't exist, return the given default.
    /// </summary>
    public static bool GetNodeValueAsBool(XmlNode parent, string path,
                                             bool defaultVal)
    {
      XmlNode node = SingleNodeExists(parent, path);
      if (node == null)
        return defaultVal;
      return GetNodeValueAsBool(node);
    }

    /// <summary>
    /// parse a decimal out of an string
    /// </summary>
		public static bool ToBool(object aBool)
		{
      // System.Convert.ToBoolean only supports the values "True" and "False"
      // so we do our own conversion
      if(!(aBool is string))
        return System.Convert.ToBoolean(aBool);
      string text = System.Convert.ToString(aBool);

      if (string.Compare(text, "true", true) == 0
          || string.Compare(text, "t", true) == 0
          || string.Compare(text, "y", true) == 0
          || string.Compare(text, "yes", true) == 0
          || string.Compare(text, "1", true) == 0)
        return true;

      if (string.Compare(text, "false", true) == 0
          || string.Compare(text, "f", true) == 0
          || string.Compare(text, "n", true) == 0
          || string.Compare(text, "no", true) == 0
          || string.Compare(text, "0", true) == 0)
        return false;

      throw new MTXmlException("Error converting value '{0}' to bool",
                               aBool);
		}


    //
    // enum
    //

    /// <summary>
    /// parse an enum out of the inner text of a node
    /// </summary>
    public static object GetNodeValueAsEnum(XmlNode node, Type enumType)
    {
      string text = node.InnerText;

      try
      {
        return System.Enum.Parse(enumType, text, true);
      }
      catch (System.Exception err)
      {
        throw new MTXmlException(err, node, "Error converting value '{0}' to enum type '{1}'",
                                 text, enumType.Name);
      }
    }

    /// <summary>
    /// find a single node, then return its value as an enum
    /// </summary>
    public static object GetNodeValueAsEnum(XmlNode parent, Type enumType, string path)
    {
      XmlNode node = SelectOnlyNode(parent, path);
      return GetNodeValueAsEnum(node, enumType);
    }

    /// <summary>
    /// find a single node, then return its value as an enum.
    /// if the node doesn't exist, return the given default.
    /// </summary>
    public static object GetNodeValueAsEnum(XmlNode parent, Type enumType, string path,
                                            object defaultVal)
    {
      XmlNode node = SingleNodeExists(parent, path);
      if (node == null)
        return defaultVal;
      return GetNodeValueAsEnum(node, enumType);
    }

    /// <summary>
    /// parse an enum out of an string
    /// </summary>
		public static object ToEnum(string text, Type enumType)
		{
      try
      {
        return System.Enum.Parse(enumType, text, true);
      }
      catch (System.Exception err)
      {
        throw new MTXmlException(err, "Error converting value '{0}' to enum type '{1}'",
                                 text, enumType.Name);
      }
		}


    /// <summary>
    /// find a single node, then set its value given a bool
    /// </summary>
    public void SetNodeValue(string path, bool val)
    {
      SetNodeValue(this, path, val);
    }

    /// <summary>
    /// set the value of a node given a bool
    /// </summary>
    static public void SetNodeValue(XmlNode node, bool val)
    {
      SetNodeValue(node, val ? "true" : "false");
    }

    /// <summary>
    /// find a single node, then set its value given a bool
    /// </summary>
    static public void SetNodeValue(XmlNode parent, string path, bool val)
    {
      XmlNode node = SelectOnlyNode(parent, path);
      SetNodeValue(node, val);
    }

    /// <summary>
    /// find a single node, then set its value given a DateTime (in UTC)
    /// </summary>
    public void SetNodeValue(string path, DateTime val)
    {
      SetNodeValue(this, path, val);
    }

    /// <summary>
    /// set the value of a node given a DateTime (in UTC)
    /// </summary>
    static public void SetNodeValue(XmlNode node, DateTime val)
    {
      SetNodeValue(node, val.ToString("s") + "Z");
    }

    /// <summary>
    /// find a single node, then set its value given a DateTime (in UTC) 
    /// </summary>
    static public void SetNodeValue(XmlNode parent, string path, DateTime val)
    {
      XmlNode node = SelectOnlyNode(parent, path);
      SetNodeValue(node, val);
    }

    /// <summary>
    /// find a single node, then set its value given a decimal
    /// </summary>
    public void SetNodeValue(string path, decimal val)
    {
      SetNodeValue(this, path, val);
    }

    /// <summary>
    /// set the value of a node given a decimal
    /// </summary>
    static public void SetNodeValue(XmlNode node, decimal val)
    {
      SetNodeValue(node, val.ToString());
    }

    /// <summary>
    /// find a single node, then set its value given a decimal
    /// </summary>
    static public void SetNodeValue(XmlNode parent, string path, decimal val)
    {
      XmlNode node = SelectOnlyNode(parent, path);
      SetNodeValue(node, val);
    }

    /// <summary>
    /// find a single node, then set its value given a int
    /// </summary>
    public void SetNodeValue(string path, int val)
    {
      SetNodeValue(this, path, val);
    }

    /// <summary>
    /// set the value of a node given a int
    /// </summary>
    static public void SetNodeValue(XmlNode node, int val)
    {
      SetNodeValue(node, val.ToString());
    }
    
    /// <summary>
    /// find a single node, then set its value given a int
    /// </summary>
    static public void SetNodeValue(XmlNode parent, string path, int val)
    {
      XmlNode node = SelectOnlyNode(parent, path);
      SetNodeValue(node, val);
    }

    /// <summary>
    /// find a single node, then set its value given a string
    /// </summary>
    public void SetNodeValue(string path, string val)
    {
      SetNodeValue(this, path, val);
    }

    /// <summary>
    /// set the value (inner text) of a node given a string
    /// </summary>
    static public void SetNodeValue(XmlNode node, string val)
    {
      node.InnerText = val;
    }

    /// <summary>
    /// find a single node, then set its value given a string
    /// </summary>
    static public void SetNodeValue(XmlNode parent, string path, string val)
    {
      XmlNode node = SelectOnlyNode(parent, path);
      SetNodeValue(node, val);
    }

		
    static string mConfigDir;
    static string mExtensionDir;

  }


}
