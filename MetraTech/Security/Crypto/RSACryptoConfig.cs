/*
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Xml.Serialization;
using System.IO;
using MetraTech.Interop.RCD;

namespace MetraTech.Security.Crypto
{
  /// <summary>
  /// 
  /// </summary>
  [XmlRoot("xmlconfig")]
  [ComVisible(false)]
  public sealed class RSACryptoConfig
  {
    #region Public Methods

    /// <summary>
    ///   Return the singleton RSACryptoConfig
    /// </summary>
    /// <returns></returns>
    public static RSACryptoConfig GetInstance()
    {
      if (rsaCryptoConfigInstance == null)
      {
        lock (rsaCryptoConfigSyncRoot)
        {
          if (rsaCryptoConfigInstance == null)
          {
            rsaCryptoConfigInstance = new RSACryptoConfig();
            rsaCryptoConfigInstance.Initialize();
          }
        }
      }

      return rsaCryptoConfigInstance;
    }

    #endregion

    #region Public Fields

    /// <summary>
    ///   Name of the identity group used in KMS for this installation.
    /// </summary>
    [XmlElement(ElementName = "rsaConfig", Type = typeof(RSAConfig))]
    public RSAConfig RSAConfig;

    #endregion

    #region Private Methods

    /// <summary>
    ///  Constructor
    /// </summary>
    private RSACryptoConfig()
    {
    }

    private void Initialize()
    {
      try
      {
        logger = new Logger("[MetraTech.Security.RSACryptoConfig]");
        IMTRcd rcd = new MTRcdClass();
        configFile = rcd.ConfigDir + @"security\mtsecurity.xml";

        RSACryptoConfig cryptoConfig = null;

        if (File.Exists(configFile))
        {
          using (FileStream fileStream = File.Open(configFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
          {
            XmlSerializer serializer = new XmlSerializer(typeof(RSACryptoConfig));
            cryptoConfig = (RSACryptoConfig)serializer.Deserialize(fileStream);
            this.RSAConfig = cryptoConfig.RSAConfig;
            fileStream.Close();
          }
        }
      }
      catch (Exception e)
      {
        logger.LogException("Unable to read security configuration : ", e);
        throw e;
      }
    }

    private bool Validate()
    {
      bool isValid = true;

      // Check that the kms client config file exists
      if (!File.Exists(RSAConfig.KmsClientConfigFile))
      {
        isValid = false;
        logger.LogError(String.Format("Unable to locate the kms client configuration file '{0}' specified in '{1}'", RSAConfig.KmsClientConfigFile, configFile));
      }

      // Check that key classes are present
      if (RSAConfig.KMSKeyClasses == null)
      {
        isValid = false;
        logger.LogError(String.Format("Missing <kmsKeyClass> elements in '{1}'", configFile));
      }
      else
      {
        // Check that each of the key classes are present
        Dictionary<string, string> keyClasses = new Dictionary<string, string>();
        foreach (KMSKeyClass keyClass in RSAConfig.KMSKeyClasses)
        {
          keyClasses.Add(keyClass.Id.ToUpper(), keyClass.Name);
        }

        foreach (string name in Enum.GetNames(typeof(CryptKeyClass)))
        {
          if (!keyClasses.ContainsKey(name.ToUpper()))
          {
            logger.LogError(String.Format("Missing <kmsKeyClass> element '{0}' in '{1}'", name, configFile));
            isValid = false;
          }
        }

        foreach (string name in Enum.GetNames(typeof(HashKeyClass)))
        {
          if (!keyClasses.ContainsKey(name.ToUpper()))
          {
            logger.LogError(String.Format("Missing <kmsKeyClass> element '{0}' in '{1}'", name, configFile));
            isValid = false;
          }
        }
      }

      return isValid;
    }
    #endregion

    #region Data
    private static volatile RSACryptoConfig rsaCryptoConfigInstance;
    private static object rsaCryptoConfigSyncRoot = new Object();
    private Logger logger;
    private string configFile;
    #endregion

  }

  #region RSAConfig Class
  /// <summary>
  ///   Password required to unlock the certificate which identifies the KMS client machine to the KMS server.
  /// </summary>
  [ComVisible(false)]
  public class RSAConfig
  {
    /// <summary>
    ///   Name of the identity group used in KMS for this installation.
    /// </summary>
    [XmlElement(ElementName = "kmsIdentityGroup", Type = typeof(string))]
    public string KmsIdentityGroup;

    /// <summary>
    ///   Name of the config file used by the KMSClient for this machine. 
    /// </summary>
    [XmlElement(ElementName = "kmsClientConfigFile", Type = typeof(string))]
    public string KmsClientConfigFile
    {
      get
      {
        string pathRoot = Path.GetPathRoot(kmsClientConfigFile);
        if (String.IsNullOrEmpty(pathRoot))
        {
          return Path.Combine(rcd.ConfigDir, kmsClientConfigFile);
        }
        
        return kmsClientConfigFile;
      }
      set
      {
        string pathRoot = Path.GetPathRoot(value);
        if (String.IsNullOrEmpty(pathRoot))
        {
          kmsClientConfigFile = Path.Combine(rcd.ConfigDir, value);
        }
        else
        {
          kmsClientConfigFile = value;
        }
      }
    }

    /// <summary>
    ///   Password used to unlock the .pfx file used by the KMSClient.
    /// </summary>
    [XmlElement(ElementName = "kmsCertificatePwd", Type = typeof(CertificatePassword))]
    public CertificatePassword KmsCertificatePwd;

    /// <summary>
    ///   Mapping of internal enum key class names to KMS key class names.
    /// </summary>
    [XmlElement(ElementName = "kmsKeyClass", Type = typeof(KMSKeyClass))]
    public KMSKeyClass[] KMSKeyClasses;

    #region Public Methods
    /// <summary>
    ///   Return true if the contents of the specified kmsClientConfigFile is valid
    /// </summary>
    /// <param name="kmsClientConfigFile"></param>
    /// <param name="validationErrors"></param>
    /// <param name="kmsClientConfig"></param>
    /// <returns></returns>
    public static bool ValidateKmsClientConfigFile(string kmsClientConfigFile, 
                                                   out List<string> validationErrors,
                                                   out KmsClientConfig kmsClientConfig)
    {
      validationErrors = new List<string>();
      kmsClientConfig = null;

      // Check that the key.cfg has been specified
      if (String.IsNullOrEmpty(kmsClientConfigFile))
      {
        validationErrors.Add(
          String.Format("Missing value for <kmsClientConfigFile> element in RMP\\config\\security\\mtsecurity.xml."));
        return false;
      }
      // Check that key.cfg exists 
      string kmsConfigFile = Path.Combine(rcd.ConfigDir, kmsClientConfigFile);
      if (!File.Exists(kmsConfigFile))
      {
        validationErrors.Add(
          String.Format("Cannot find file '{0}' specified in <kmsClientConfigFile> element in RMP\\config\\security\\mtsecurity.xml.", kmsConfigFile));
        return false;
      }

      string[] configFileLines = File.ReadAllLines(kmsConfigFile);
      if (configFileLines == null || configFileLines.Length == 0)
      {
        validationErrors.Add(
          String.Format("Empty <kmsClientConfigFile> '{0}' specified in in RMP\\config\\security\\mtsecurity.xml.", kmsConfigFile));
        return false;
      }

      Dictionary<string, string> keyValues = new Dictionary<string, string>();
      bool invalidLine = false;
      foreach(string configFileLine in configFileLines)
      {
        string[] keyValue = configFileLine.Split('=');
        if (keyValue.Length != 2)
        {
          validationErrors.Add(
            String.Format("Invalid line '{0}' found in '{1}'", configFileLine, kmsConfigFile));
          invalidLine = true;
        }
        else
        {
          keyValues.Add(keyValue[0].Trim(), keyValue[1].Trim());
        }
      }

      if (invalidLine)
      {
        return false;
      }

      kmsClientConfig = new KmsClientConfig();
      // Initialize kmsClientConfig 
      kmsClientConfig.CertificateFile = GetKeyValue("kms.sslPKCS12File", keyValues, validationErrors, kmsConfigFile);
      if (!String.IsNullOrEmpty(kmsClientConfig.CertificateFile))
      {
        if (!File.Exists(kmsClientConfig.CertificateFile))
        {
          validationErrors.Add(
            String.Format("Cannot find certificate file '{0}' specified in 'kms.sslPKCS12File' in file '{1}'", kmsClientConfig.CertificateFile, kmsConfigFile));
        }
      }
      kmsClientConfig.Server = GetKeyValue("kms.address", keyValues, validationErrors, kmsConfigFile);
      kmsClientConfig.ServerPort = GetKeyValue("kms.port", keyValues, validationErrors, kmsConfigFile);
      kmsClientConfig.LogLevel = GetKeyValue("kms.debug", keyValues, validationErrors, kmsConfigFile);
      kmsClientConfig.LogFile = GetKeyValue("kms.logFile", keyValues, validationErrors, kmsConfigFile);
      kmsClientConfig.ConnectTimeout = GetKeyValue("kms.sslConnectTimeout", keyValues, validationErrors, kmsConfigFile);
      kmsClientConfig.Retries = GetKeyValue("kms.retries", keyValues, validationErrors, kmsConfigFile);
      kmsClientConfig.RetryDelay = GetKeyValue("kms.retryDelay", keyValues, validationErrors, kmsConfigFile);
      kmsClientConfig.CacheTimeToLive = GetKeyValue("kms.cacheTimeToLive", keyValues, validationErrors, kmsConfigFile);
      kmsClientConfig.CacheFile = GetKeyValue("kms.cacheFile", keyValues, validationErrors, kmsConfigFile);
      kmsClientConfig.MemoryCache = GetKeyValue("kms.memoryCache", keyValues, validationErrors, kmsConfigFile);

      if (validationErrors.Count > 0)
      {
        kmsClientConfig = null;
        return false;
      }

      return true;
    }

    private static string GetKeyValue(string key, 
                                      IDictionary<string, string> keyValues, 
                                      ICollection<string> validationErrors, 
                                      string kmsConfigFile)
    {
      string value = String.Empty;
      if (keyValues.ContainsKey(key))
      {
        value = keyValues[key];
        if (String.IsNullOrEmpty(value))
        {
          validationErrors.Add(String.Format("Missing value for '{0}' entry in '{1}'", key, kmsConfigFile));
        }
      }
      else
      {
        validationErrors.Add(
          String.Format("Missing '{0}' entry in '{1}'", key, kmsConfigFile));
      }
      return value;
    }
    #endregion

    #region Data
    private static IMTRcd rcd = new MTRcdClass();
    private string kmsClientConfigFile;
    #endregion
  }
  #endregion

  #region CertificatePassword Class
  /// <summary>
  ///   Password required to unlock the certificate which identifies the KMS client machine to the KMS server.
  /// </summary>
  [ComVisible(false)]
  public class CertificatePassword
  {
    #region Public Fields
    /// <summary>
    ///   True if KMS is being used.
    /// </summary>
    [XmlAttribute("encrypted")]
    public bool Encrypted;

    /// <summary>
    ///   Password used to unlock the .pfx file used by the KMSClient.
    /// </summary>
    [XmlText]
    public string Password;
    #endregion
  }
  #endregion

  #region KMSKeyClass Class
  /// <summary>
  ///   KeyClass specified in KMS and mapped to internal identifiers.
  /// </summary>
  [Serializable]
  [XmlRoot("kmsKeyClass")]
  [ComVisible(false)]
  public class KMSKeyClass
  {
    #region Public Fields

    /// <summary>
    ///   True if KMS is being used.
    /// </summary>
    [XmlAttribute("id")]
    public string Id;

    /// <summary>
    ///   Name of the key class used in KMS.
    /// </summary>
    [XmlText]
    public string Name;
    #endregion
  }
  #endregion

  #region KmsClientConfig Class
  /// <summary>
  /// 
  /// </summary>
  [ComVisible(false)]
  public class KmsClientConfig
  {
    public string CertificateFile;
    public string Server;
    public string ServerPort;
    public string LogLevel;
    public string LogFile;
    public string ConnectTimeout;
    public string Retries;
    public string RetryDelay;
    public string CacheTimeToLive;
    public string CacheFile;
    public string MemoryCache;
  }
  #endregion


}
*/