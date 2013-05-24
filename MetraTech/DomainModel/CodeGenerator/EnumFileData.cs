using System.Collections.Generic;
using System.IO;
using System.Xml;

namespace MetraTech.DomainModel.CodeGenerator
{
  public class EnumFileData : FileData
  {
    #region Public Methods

    public EnumFileData()
    {
      enumSpaces = new List<EnumSpace>();
    }

    /// <summary>
    ///    Return EnumFileData for each enum file in RMP\Extensions. 
    /// </summary>
    /// <returns></returns>
    public static List<EnumFileData> GetEnumFileData()
    {
      List<EnumFileData> enumFiles = new List<EnumFileData>();

      foreach(string extension in BaseCodeGenerator.RCD.ExtensionList)
      {
        enumFiles.AddRange(GetEnumFileData(extension));
      }
      return enumFiles;
    }
    /// <summary>
    ///   Return EnumFileData items for the given extension
    /// </summary>
    /// <param name="extension"></param>
    /// <returns></returns>
    public static List<EnumFileData> GetEnumFileData(string extension)
    {
      List<EnumFileData> enumFiles = new List<EnumFileData>();

      // Get the xml enum files under extension/.../EnumType
      List<string> files = BaseCodeGenerator.GetFiles(extension, "EnumType", "xml");
      XmlDocument xmlDocument = new XmlDocument();
      foreach (string file in files)
      {
        xmlDocument.Load(file);
        XmlNodeList nodeList = xmlDocument.SelectNodes("//enum_space");
        if (nodeList == null)
        {
          continue;
        }

        EnumFileData enumFileData = new EnumFileData();
        enumFileData.ExtensionName = BaseCodeGenerator.RCD.GetExtensionFromPath(file);
        enumFileData.FileName = Path.GetFileName(file);
        enumFileData.FullPath = file;

        foreach(XmlNode node in nodeList)
        {
          EnumSpace enumSpace = CreateEnumSpace(node);
          enumSpace.FileData = enumFileData;
          enumFileData.enumSpaces.Add(enumSpace);

          // Get the localization files
          enumFileData.LocalizationFiles.AddRange(LocalizationFileData.GetLocalizationFileData(extension, enumSpace.Name));
        }

        enumFiles.Add(enumFileData);
      }

      return enumFiles;
    }
    #endregion

    #region Properties
    private readonly List<EnumSpace> enumSpaces;
    public List<EnumSpace> EnumSpaces
    {
      get { return enumSpaces; }
    }

    /// <summary>
    ///   This is used as the key for the checksum associated with this file.
    ///   The key/checksum pair is stored as a resource in the generated assembly.
    ///   The key looks like the following:
    ///   <enumFile ext="ExtensionName" file="fileName.xml"/>
    /// </summary>
    public override string ChecksumKey
    {
      get
      {
        StringWriter stringWriter = new StringWriter();
        XmlTextWriter xmlTextWriter = new XmlTextWriter(stringWriter);
        xmlTextWriter.WriteStartElement("enumFile");
        xmlTextWriter.WriteAttributeString("ext", ExtensionName);
        xmlTextWriter.WriteAttributeString("file", FileName);
        xmlTextWriter.WriteEndElement();
        xmlTextWriter.Close();
        stringWriter.Close();
        return stringWriter.ToString();
      }
    }
    #endregion

    #region Protected Methods
    
    #endregion

    #region Private Methods
    private static EnumSpace CreateEnumSpace(XmlNode enumSpaceNode)
    {
      EnumSpace enumSpace = new EnumSpace();

      // Get the name attribute 
      enumSpace.Name = enumSpaceNode.Attributes["name"].InnerText.Trim();

      XmlNodeList enumSpaceNodes = enumSpaceNode.SelectNodes("./enums");

      if (enumSpaceNodes != null)
      {
        foreach (XmlNode node in enumSpaceNodes)
        {
          XmlNodeList enumTypeNodes = node.SelectNodes("./enum");
          if (enumTypeNodes == null) continue;
          foreach (XmlNode enumTypeNode in enumTypeNodes)
          {
            EnumType enumType = CreateEnumType(enumTypeNode);
            enumType.EnumSpace = enumSpace;
            enumSpace.EnumTypes.Add(enumType);
          }
        }
      }

      return enumSpace;
    }

    private static EnumType CreateEnumType(XmlNode enumTypeNode)
    {
      EnumType enumType = new EnumType();

      // Get the name attribute 
      enumType.Name = enumTypeNode.Attributes["name"].InnerText.Trim();

      XmlNodeList entries = enumTypeNode.SelectNodes("./entries");

      if (entries != null)
      {
        foreach(XmlNode node in entries)
        {
          XmlNodeList nodes = node.SelectNodes("./entry");
          if (nodes == null) continue;

          foreach (XmlNode entryNode in nodes)
          {
            List<string> values = new List<string>();

            XmlNodeList valueNodes = entryNode.SelectNodes("./value");

            if (valueNodes == null) continue;

            foreach (XmlNode valueNode in valueNodes)
            {
              values.Add(valueNode.InnerText.Trim());
            }

            enumType.EntryValues.Add(entryNode.Attributes["name"].InnerText.Trim(), values);
          }
        }
      }

      return enumType;
    }
    #endregion
  }

  #region EnumSpace class
  public class EnumSpace
  {
    private string name;
    public string Name
    {
      get { return name; }
      set { name = value; }
    }

    private List<EnumType> enumTypes = new List<EnumType>();
    public List<EnumType> EnumTypes
    {
      get { return enumTypes; }
      set { enumTypes = value; }
    }

    private FileData fileData;
    public FileData FileData
    {
      get { return fileData; }
      set { fileData = value; }
    }
  }
  #endregion

  #region EnumType class
  public class EnumType
  {
    public string FQN
    {
      get
      {
        return EnumSpace.Name + "/" + name;
      }
    }

    private EnumSpace enumSpace;
    public EnumSpace EnumSpace
    {
      get { return enumSpace; }
      set { enumSpace = value; }
    }

    private string name;
    public string Name
    {
      get { return name; }
      set { name = value; }
    }

    // Given the following enum definition, store a mapping of the following type:
    //    Account <--> List<> (containts "0")
    //    Contact <--> List<> (contains "1")
    //    Both <--> List<> (contains "2")
    //    
    //<enum name="ActionType">
    //      <description>What do I want to create?</description>
    //      <entries>
    //        <entry name="Account">
    //          <value>0</value>
    //        </entry>
    //        <entry name="Contact">
    //          <value>1</value>
    //        </entry>
    //        <entry name="Both">
    //          <value>2</value>
    //        </entry>
    //      </entries>
    //    </enum>
    private Dictionary<string, List<string>> entryValues = new Dictionary<string, List<string>>();
    public Dictionary<string, List<string>> EntryValues
    {
      get { return entryValues; }
      set { entryValues = value; }
    }

  }
  #endregion

}
