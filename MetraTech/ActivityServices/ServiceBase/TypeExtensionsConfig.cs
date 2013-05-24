#pragma warning disable 1591  // Disable XML Doc warning for now.
using System;
using System.Collections.Generic;
using System.Text;
using System.Xml.Serialization;
using MetraTech.Interop.RCD;
using System.IO;

namespace MetraTech.ActivityServices.Services.Common
{
  
  public sealed class TypeExtensionsConfig
  {
    #region Public Methods

    /// <summary>
    ///   Return the singleton RSACryptoConfig
    /// </summary>
    /// <returns></returns>
    public static TypeExtensionsConfig GetInstance()
    {
      if (TypeExtensionsConfigInstance == null)
      {
        lock (TypeExtensionsConfigSyncRoot)
        {
          if (TypeExtensionsConfigInstance == null)
          {
            TypeExtensionsConfigInstance = Initialize();
          }
        }
      }

      return TypeExtensionsConfigInstance;
    }

    public List<string> GetCustomizedTypes(Type rootType)
    {
      List<string> retval = new List<string>();

      if (m_ExtendedTypes.ContainsKey(rootType.Name))
      {
        retval = m_ExtendedTypes[rootType.Name];
      }
      else if (m_ExtendedTypes.ContainsKey(rootType.FullName))
      {
        retval = m_ExtendedTypes[rootType.FullName];
      }
      else if (m_ExtendedTypes.ContainsKey(rootType.AssemblyQualifiedName))
      {
        retval = m_ExtendedTypes[rootType.AssemblyQualifiedName];
      }
      else if (rootType.IsByRef)
      {
        if (m_ExtendedTypes.ContainsKey(rootType.Name.Substring(0, rootType.Name.Length -1)))
        {
          retval = m_ExtendedTypes[rootType.Name.Substring(0, rootType.Name.Length - 1)];
        }
        else if (m_ExtendedTypes.ContainsKey(rootType.FullName.Substring(0, rootType.FullName.Length - 1)))
        {
          retval = m_ExtendedTypes[rootType.FullName.Substring(0, rootType.FullName.Length - 1)];
        }
        else if (m_ExtendedTypes.ContainsKey(rootType.AssemblyQualifiedName.Substring(0, rootType.AssemblyQualifiedName.Length - 1)))
        {
          retval = m_ExtendedTypes[rootType.AssemblyQualifiedName.Substring(0, rootType.AssemblyQualifiedName.Length - 1)];
        }
      }

      return retval;
    }
    #endregion

    #region Private Methods

    /// <summary>
    ///  Constructor
    /// </summary>
    private TypeExtensionsConfig()
    {
    }

    private static TypeExtensionsConfig Initialize()
    {
      Logger logger = null;
      TypeExtensionsConfig config = new TypeExtensionsConfig();

      try
      {
        logger = new Logger("[TypeExtensionsConfig]");
        IMTRcd rcd = new MTRcdClass();
        string configFile = rcd.ConfigDir + @"domainmodel\typeextensions.xml";
        
        if (File.Exists(configFile))
        {
          using (FileStream fileStream = File.Open(configFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
          {
            XmlSerializer serializer = new XmlSerializer(typeof(TypeExtensions));
            TypeExtensions te = (TypeExtensions)serializer.Deserialize(fileStream);

            config.BuildDictionary(te);
          }
        }
        else
        {
          throw new FileNotFoundException("Unable to find type extensions configuration file");
        }
      }
      catch (Exception e)
      {
        if (logger != null)
        {
          logger.LogException("Unable to read type extensions configuration : ", e);
        }
        throw e;
      }

      return config;
    }

    private void BuildDictionary(TypeExtensions te)
    {
      if (te.RootTypes != null)
      {
        foreach (RootTypeElement rte in te.RootTypes)
        {
          if (rte.CustomTypes != null)
          {
            List<string> customizedTypes = new List<string>();

            foreach (CustomTypeElement cte in rte.CustomTypes)
            {
              customizedTypes.Add(cte.TypeName);
            }

            m_ExtendedTypes.Add(rte.TypeName, customizedTypes);
          }
        }
      }
    }
    #endregion

    #region Data
    private static volatile TypeExtensionsConfig TypeExtensionsConfigInstance;
    private static readonly object TypeExtensionsConfigSyncRoot = new Object();

    private Dictionary<string, List<string>> m_ExtendedTypes = new Dictionary<string, List<string>>();
    #endregion
  }

  [XmlRoot("xmlconfig")]
  public sealed class TypeExtensions
  {
    [XmlElement("RootType", typeof(RootTypeElement))]
    public RootTypeElement[] RootTypes;
  }

  public sealed class RootTypeElement
  {
    [XmlAttribute("Name")]
    public string TypeName;

    [XmlElement("CustomType", typeof(CustomTypeElement))]
    public CustomTypeElement[] CustomTypes;
  }

  public sealed class CustomTypeElement
  {
    [XmlText]
    public string TypeName;
  }

}
