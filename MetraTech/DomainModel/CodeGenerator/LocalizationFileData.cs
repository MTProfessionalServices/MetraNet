using System.Collections.Generic;
using System.IO;
using System.Xml;
using System;

namespace MetraTech.DomainModel.CodeGenerator
{

  public class LocalizationFileData : FileData
  {
    #region Public Methods

    /// <summary>
    ///   Return LocalizationFileData items for the given extension and localeSpace
    /// </summary>
    /// <param name="extension"></param>
    /// <param name="localeSpace"></param>
    /// <returns></returns>
    public static List<LocalizationFileData> GetLocalizationFileData(string extension, string localeSpace)
    {
      List<LocalizationFileData> localizationFiles = null;

      Dictionary<string, List<LocalizationFileData>> localizationFilesByLocaleSpace = null;
      if (localizationFilesByExtensionAndLocaleSpace.ContainsKey(extension.ToLower()))
      {
        localizationFilesByLocaleSpace =
          localizationFilesByExtensionAndLocaleSpace[extension.ToLower()];
       
        if (!localizationFilesByLocaleSpace.ContainsKey(localeSpace.ToLower()))
        {
          localizationFiles = new List<LocalizationFileData>();
          localizationFilesByLocaleSpace.Add(localeSpace.ToLower(), localizationFiles);
        }
        else
        {
          localizationFiles = localizationFilesByLocaleSpace[localeSpace.ToLower()];
          return localizationFiles;
        }
      }
      else
      {
        localizationFilesByLocaleSpace = new Dictionary<string, List<LocalizationFileData>>();
        localizationFiles = new List<LocalizationFileData>();
        localizationFilesByLocaleSpace.Add(localeSpace.ToLower(), localizationFiles);
        localizationFilesByExtensionAndLocaleSpace.Add(extension.ToLower(),
                                                       localizationFilesByLocaleSpace);
      }
      
      // Get the xml localization files under extension/.../Localization
      List<string> files = BaseCodeGenerator.GetFiles(extension, "Localization", "xml");
      XmlDocument xmlDocument = new XmlDocument();
      XmlNode node;
      foreach (string file in files)
      {
        xmlDocument.Load(file);
        node = xmlDocument.SelectSingleNode(@"//locale_space");
        if (node == null)
        {
          continue;
        }

        if (localeSpace.ToLower() != node.Attributes["name"].InnerText.Trim().ToLower()) continue;

        LocalizationFileData localizationFileData = new LocalizationFileData();
        localizationFileData.ExtensionName = extension;
        localizationFileData.FileName = Path.GetFileName(file);
        localizationFileData.FullPath = file;
        localizationFileData.LocaleSpace = localeSpace;
        localizationFileData.localeSpaceNode = node;

        // Get the language
        XmlNode language = xmlDocument.SelectSingleNode(@"//language_code");
        if (language == null || 
            String.IsNullOrEmpty(language.InnerText) || 
            String.IsNullOrEmpty(language.InnerText.Trim()))
        {
          logger.LogError(String.Format("Missing language_code element in localization file '{0}'", file));
          continue;
        }

        localizationFileData.MTLanguage = language.InnerText.Trim();
        localizationFiles.Add(localizationFileData);
        string localeSpaceKey = extension.ToLower() + "_" + localeSpace.ToLower();
        InitLocalizationEntries(localizationFileData.MTLanguage, localeSpaceKey, node);
      }

      return localizationFiles;
    }

    public static Dictionary<string, string> GetLocaleSpaceEntries(string language, string extension, string localSpace)
    {
      if (!localeSpaceEntriesByLanguage.ContainsKey(language.ToLower()))
      {
        return null;
      }

      Dictionary<string, Dictionary<string, string>> localeSpaceEntries =
        localeSpaceEntriesByLanguage[language.ToLower()];
      
      string localeSpaceKey = extension + "_" + localSpace;

      Dictionary<string, string> entries = null;

      if (localeSpaceEntries.ContainsKey(localeSpaceKey.ToLower()))
      {
        entries = localeSpaceEntries[localeSpaceKey.ToLower()];
      }

      return entries;
    }

    public static void UpdateLocaleSpaceEntries(string extension, string localeSpace)
    {
      string localeSpaceKey = extension.ToLower() + "_" + localeSpace.ToLower();

      List<string> files = BaseCodeGenerator.GetFiles(extension, "Localization", "xml");
      XmlDocument xmlDocument = new XmlDocument();
      XmlNode node;
      foreach (string file in files)
      {
        xmlDocument.Load(file);
        node = xmlDocument.SelectSingleNode(@"//locale_space");
        
        if (node == null) continue;
        if (localeSpace.ToLower() != node.Attributes["name"].InnerText.Trim().ToLower()) continue;

        XmlNode language = xmlDocument.SelectSingleNode(@"//language_code");
        if (language == null ||
            String.IsNullOrEmpty(language.InnerText) ||
            String.IsNullOrEmpty(language.InnerText.Trim()))
        {
          logger.LogError(String.Format("Missing language_code element in localization file '{0}'", file));
          continue;
        }

        InitLocalizationEntries(language.InnerText.Trim(), localeSpaceKey, node);
      }
    }

    public static void UpdateEntries(string extension, string fileName)
    {
      string dir = Path.Combine(BaseCodeGenerator.RCD.ExtensionDir, extension);
      dir = Path.Combine(dir, "config");
      dir = Path.Combine(dir, "localization");

      string[] files = Directory.GetFiles(dir, fileName, SearchOption.AllDirectories);
      if (files == null || files.Length == 0)
      {
        logger.LogError(String.Format("Unable to find localization file '{0}'", fileName));
        return;
      }

      XmlDocument xmlDocument = new XmlDocument();
      xmlDocument.Load(files[0]);

      XmlNode node = xmlDocument.SelectSingleNode(@"//locale_space");

      if (node == null || node.Attributes["name"] == null || String.IsNullOrEmpty(node.Attributes["name"].InnerText.Trim()))
      {
        logger.LogError(String.Format("Missing <locale_space> data in localization file '{0}'", files[0]));
        return;
      }

      string localeSpace = node.Attributes["name"].InnerText.Trim();
      XmlNode language = xmlDocument.SelectSingleNode(@"//language_code");
      if (language == null ||
          String.IsNullOrEmpty(language.InnerText) ||
          String.IsNullOrEmpty(language.InnerText.Trim()))
      {
        logger.LogError(String.Format("Missing language_code element in localization file '{0}'", files[0]));
        return;
      }

      string localeSpaceKey = extension.ToLower() + "_" + localeSpace.ToLower();
      InitLocalizationEntries(language.InnerText.Trim(), localeSpaceKey, node);
    }

    public static string GetLocalizedValue(string language, string extension, string localeSpace, string mtLocalizationId)
    {
      string localizedValue = null;

      Dictionary<string, string> localeSpaceEntries = GetLocaleSpaceEntries(language, extension, localeSpace);
      if (localeSpaceEntries != null)
      {
        if (localeSpaceEntries.ContainsKey(mtLocalizationId.ToLower()))
        {
          localizedValue = localeSpaceEntries[mtLocalizationId.ToLower()];
        }
      }

      return localizedValue;
    }

    public string GetLocalizedValue(string mtLocalizationId)
    {
      InitLocalizationEntries(mtLanguage, LocaleSpaceKey, localeSpaceNode);
      string localizedValue = String.Empty;

      Dictionary<string, string> localizationEntries = GetLocaleSpaceEntries(mtLanguage, ExtensionName, localeSpace);
      if (localizationEntries != null && localizationEntries.ContainsKey(mtLocalizationId))
      {
        localizedValue = localizationEntries[mtLocalizationId];
      }

      return localizedValue;
    }

    #endregion

    #region Properties
    private string localeSpace;
    public string LocaleSpace
    {
      get { return localeSpace; }
      set { localeSpace = value; }
    }

    private string mtLanguage;
    public string MTLanguage
    {
      get { return mtLanguage; }
      set { mtLanguage = value; }
    }

    public string LocaleSpaceKey
    {
      get { return ExtensionName.ToLower() + "_" + localeSpace.ToLower(); }
    }
    /// <summary>
    ///   This is used as the key for the checksum associated with this file.
    ///   The key/checksum pair is stored as a resource in the generated assemblies.
    ///   The key looks like the following:
    ///   <localizationFile ext="ExtensionName" file="fileName.xml"/>
    /// </summary>
    public override string ChecksumKey
    {
      get
      {
        StringWriter stringWriter = new StringWriter();
        XmlTextWriter xmlTextWriter = new XmlTextWriter(stringWriter);
        xmlTextWriter.WriteStartElement("localizationFile");
        xmlTextWriter.WriteAttributeString("ext", ExtensionName);
        xmlTextWriter.WriteAttributeString("file", FileName);
        xmlTextWriter.WriteEndElement();
        xmlTextWriter.Close();
        stringWriter.Close();
        return stringWriter.ToString();
      }
    }

    public static Dictionary<string, Dictionary<string, Dictionary<string, string>>> LocaleSpaceEntriesByLanguage
    {
      get
      {
        return localeSpaceEntriesByLanguage;
      }
    }

    #endregion

    #region Private Methods
    /// <summary>
    ///    langauge -> (localeSpace -> Dictionary<key, value>)
    /// </summary>
    /// <returns></returns>
    private static Dictionary<string, Dictionary<string, Dictionary<string, string>>> InitLocaleSpaceEntriesByLangauge()
    {
      Dictionary<string, Dictionary<string, Dictionary<string, string>>> entries =
        new Dictionary<string, Dictionary<string, Dictionary<string, string>>>();

      foreach(string language in BaseCodeGenerator.LanguageMappings.Keys)
      {
        Dictionary<string, Dictionary<string, string>> entry = 
          new Dictionary<string, Dictionary<string, string>>();

        entries.Add(language, entry);
      }

      return entries;
    }

    
    private static void InitLocalizationEntries(string language, string localeSpaceKey, XmlNode localeSpaceNode)
    {
      if (!localeSpaceEntriesByLanguage.ContainsKey(language.ToLower()))
      {        
       // logger.LogWarning(String.Format(@"Language '{0}' is not specified in RMP\config\domainmodel\config.xml", language));
        return;
      }

      Dictionary<string, Dictionary<string, string>> localeSpaceEntries = 
        localeSpaceEntriesByLanguage[language.ToLower()];

      if (localeSpaceEntries.ContainsKey(localeSpaceKey))
      {
        return;
      }
      
      Dictionary<string, string> localizationEntries = new Dictionary<string, string>();
      localeSpaceEntries.Add(localeSpaceKey, localizationEntries);  
      
      if (localeSpaceNode == null)
      {
        return;
      }

      XmlNodeList localizedEntriesNodeList = localeSpaceNode.SelectNodes("./locale_entry");
      if (localizedEntriesNodeList == null)
      {
        return;
      }

      XmlNode nameNode;
      XmlNode valueNode;

      foreach (XmlNode node in localizedEntriesNodeList)
      {
        nameNode = node.SelectSingleNode("Name");
        if (nameNode == null)
        {
          nameNode = node.SelectSingleNode("name");
        }

        valueNode = node.SelectSingleNode("Value");
        if (valueNode == null)
        {
          valueNode = node.SelectSingleNode("value");
        }

        if (nameNode == null || valueNode == null)
        {
          continue;
        }

        string localizedEntryName = nameNode.InnerXml.ToLower().Replace("&amp;", "&");
        string localizedEntryValue = valueNode.InnerXml.Replace("&amp;", "&");

        if (!localizationEntries.ContainsKey(localizedEntryName))
        {
          localizationEntries.Add(localizedEntryName, localizedEntryValue);
        }
      }
    }

    #endregion

    #region Data
    private XmlNode localeSpaceNode;
    private static readonly Dictionary<string, Dictionary<string, Dictionary<string, string>>> 
      localeSpaceEntriesByLanguage = InitLocaleSpaceEntriesByLangauge();

    /// <summary>
    ///   Store a mapping of extension -> (locale space -> list of files)
    /// </summary>
    private static readonly Dictionary<string, Dictionary<string, List<LocalizationFileData>>> localizationFilesByExtensionAndLocaleSpace =
      new Dictionary<string, Dictionary<string, List<LocalizationFileData>>>();
      
      
    #endregion
  }
}
