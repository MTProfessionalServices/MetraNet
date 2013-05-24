using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Xml.Serialization;
using System.IO;
using MetraTech.Basic;

namespace MetraTech.DomainModel.CodeGenerator
{
  /// <summary>
  /// 
  /// </summary>
  [XmlRoot("xmlconfig")]
  [ComVisible(false)]
  public sealed class DomainModelConfig
  {
    #region Public Methods

    /// <summary>
    ///   Return the singleton RSACryptoConfig
    /// </summary>
    /// <returns></returns>
    public static DomainModelConfig GetInstance()
    {
      if (domainModelConfigInstance == null)
      {
        lock (domainModelConfigSyncRoot)
        {
          if (domainModelConfigInstance == null)
          {
            domainModelConfigInstance = Initialize();
          }
        }
      }

      return domainModelConfigInstance;
    }

    /// <summary>
    ///    Return the standard language code for the specified mtLanguage based on the
    ///    configuration file.
    /// </summary>
    /// <param name="mtLanguage"></param>
    /// <returns></returns>
    public string GetStandardLanguageCode(string mtLanguage)
    {
      string languageCode = String.Empty;

      foreach(Language language in Languages)
      {
        if (language.MetraTech.ToLower() != mtLanguage.ToLower()) continue;
        languageCode = language.Standard;
        break;
      }

      return languageCode;
    }

    public IList<string> GetAssemblyCopyDirectories()
    {
      if (AssemblyCopyDirectories != null)
      {
        return AssemblyCopyDirectories.AsReadOnly();
      }

      AssemblyCopyDirectories = new List<string>();

      if (AssemblyCopyDirConfigs == null)
      {
        return AssemblyCopyDirectories.AsReadOnly();
      }

      foreach (AssemblyCopyDirConfig assemblyCopyDirConfig in AssemblyCopyDirConfigs)
      {
        if (String.IsNullOrEmpty(assemblyCopyDirConfig.VirtualDirectoryName))
        {
          continue;
        }

        string dir = DirectoryUtil.ResolveVirtualDirectory(assemblyCopyDirConfig.VirtualDirectoryName);
        if (String.IsNullOrEmpty(dir))
        {
          logger.LogWarning(String.Format("Cannot resolve virtual directory '{0}'",
                            assemblyCopyDirConfig.VirtualDirectoryName));
          continue;
        }

        dir = Path.Combine(dir, "bin");
        if (!Directory.Exists(dir))
        {
          logger.LogWarning(String.Format("Cannot find bin path '{0}' for virtual directory '{1}'",
                                           dir, assemblyCopyDirConfig.VirtualDirectoryName));
          continue;
        }

        AssemblyCopyDirectories.Add(dir);
      }

      return AssemblyCopyDirectories.AsReadOnly();
    }
    
    #endregion

    #region Public Fields

    /// <summary>
    ///   LocalizableAssemblies
    /// </summary>
    [XmlElement(ElementName = "localizableAssembly", Type = typeof(LocalizableAssembly))]
    public LocalizableAssembly[] LocalizableAssemblies;

    /// <summary>
    ///   DtoAssemblies
    /// </summary>
    [XmlElement(ElementName = "dto-assembly", Type = typeof(DtoAssembly))]
    public DtoAssembly[] DtoAssemblies;

    /// <summary>
    ///   Version.
    /// </summary>
    [XmlElement(ElementName = "version")]
    public string Version;

    /// <summary>
    ///   Language
    /// </summary>
    [XmlElement(ElementName = "language", Type = typeof(Language))]
    public Language[] Languages;

    /// <summary>
    ///   Language
    /// </summary>
    [XmlElement(ElementName = "customResxFile", Type = typeof(CustomResxFile))]
    public CustomResxFile[] CustomResxFiles;

    [XmlElement(ElementName = "copy-generated-assemblies-to", Type = typeof(AssemblyCopyDirConfig))]
    public AssemblyCopyDirConfig[] AssemblyCopyDirConfigs { get; set; }

    #endregion

    #region Private Methods

    /// <summary>
    ///  Constructor
    /// </summary>
    private DomainModelConfig()
    {
    }

    private static DomainModelConfig Initialize()
    {
      Logger logger = null;
      try
      {
        logger = new Logger("[MetraTech.DomainModel.CodeGenerator.DomainModelConfig]");
        string configFile = BaseCodeGenerator.RCD.ConfigDir + @"domainmodel\config.xml";

        DomainModelConfig config;

        if (File.Exists(configFile))
        {
          using (FileStream fileStream = File.Open(configFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
          {
            XmlSerializer serializer = new XmlSerializer(typeof(DomainModelConfig));
            config = (DomainModelConfig)serializer.Deserialize(fileStream);
          }
        }
        else
        {
          throw new FileNotFoundException("Unable to find domain model configuration file");
        }

        return config;
      }
      catch (Exception e)
      {
        if (logger != null)
        {
          logger.LogException("Unable to read domain model configuration : ", e);
        }
        throw;
      }
    }

    
    #endregion

    #region Private Properties
    private static List<string> AssemblyCopyDirectories { get; set; }
    #endregion

    #region Data
    private static volatile DomainModelConfig domainModelConfigInstance;
    private static readonly object domainModelConfigSyncRoot = new Object();
    private static Logger logger = new Logger("Logging\\DomainModel\\CodeGenerator", "[DomainModelConfig]");
    #endregion

  }

  #region CustomResxFile Class
  /// <summary>
  ///   Language
  /// </summary>
  [ComVisible(false)]
  public class CustomResxFile
  {
    #region Public Fields
    /// <summary>
    ///   Override
    /// </summary>
    [XmlAttribute("override")]
    public bool Override;

    /// <summary>
    ///   Language.
    /// </summary>
    [XmlAttribute("language")]
    public string Language;

    /// <summary>
    ///   FileName.
    /// </summary>
    [XmlAttribute("file")]
    public string FileName;

    #endregion
  }
  #endregion

  #region Language Class
  /// <summary>
  ///   Language
  /// </summary>
  [ComVisible(false)]
  public class Language
  {
    #region Public Fields
    /// <summary>
    ///   MetraTech.
    /// </summary>
    [XmlAttribute("metratech")]
    public string MetraTech;

    /// <summary>
    ///   Standard.
    /// </summary>
    [XmlAttribute("standard")]
    public string Standard;
    #endregion
  }
  #endregion

  #region LocalizableAssembly Class
  /// <summary>
  ///   KeyClass specified in KMS and mapped to internal identifiers.
  /// </summary>
  [Serializable]
  [XmlRoot("localizableAssembly")]
  [ComVisible(false)]
  public class LocalizableAssembly
  {
    #region Public Fields

    /// <summary>
    ///   Name of the key class used in KMS.
    /// </summary>
    [XmlText]
    public string Name;
    #endregion
  }
  #endregion

  #region DtoAssembly Class
  /// <summary>
  ///   KeyClass specified in KMS and mapped to internal identifiers.
  /// </summary>
  [Serializable]
  [XmlRoot("dto-assembly")]
  [ComVisible(false)]
  public class DtoAssembly
  {
    #region Public Fields

    /// <summary>
    ///   Name of assembly.
    /// </summary>
    [XmlText]
    public string Name;
    #endregion
  }
  #endregion

  [Serializable]
  public sealed class AssemblyCopyDirConfig
  {
    [XmlAttribute("virtual-dir")]
    public string VirtualDirectoryName { get; set; }
  }
}
