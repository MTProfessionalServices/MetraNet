/*
using System;
using System.Runtime.InteropServices;
using System.Xml.Serialization;

namespace MetraTech.Security.Crypto
{
  /// <summary>
  /// 
  /// </summary>
  [XmlRoot("xmlconfig")]
  [ComVisible(false)]
  public sealed class MSCryptoConfig
  {
    #region Public Methods

    /// <summary>
    ///   Return the singleton RSACryptoConfig
    /// </summary>
    /// <returns></returns>
    public static MSCryptoConfig GetInstance()
    {
      if (instance == null)
      {
        lock (root)
        {
          if (instance == null)
          {
            instance = new MSCryptoConfig();
            instance.Initialize();
          }
        }
      }

      return instance;
    }

    
    #endregion

    #region Public Properties
    private MSSessionKeyConfig sessionKeyConfig;
    /// <summary>
    ///    SessionKeyConfig
    /// </summary>
    public MSSessionKeyConfig SessionKeyConfig
    {
      get { return sessionKeyConfig; }
      set { sessionKeyConfig = value; }
    }
	
    #endregion

    #region Private Methods

    /// <summary>
    ///  Constructor
    /// </summary>
    private MSCryptoConfig()
    {
    }

    /// <summary>
    ///   Initialize
    /// </summary>
    private void Initialize()
    {
      try
      {
        logger = new Logger("[MetraTech.Security.CryptoConfig]");
        sessionKeyConfig = MSSessionKeyConfig.GetInstance();
        sessionKeyConfig.Initialize();
        //if (sessionKeyConfig.KeyClasses == null || sessionKeyConfig.KeyClasses.Length == 0)
        //{
        //  throw new ApplicationException(String.Format("No session keys found in '{0}'", sessionKeyConfig.KeyFile));
        //}
      }
      catch (Exception e)
      {
        logger.LogException("Unable to read security configuration : ", e);
        throw e;
      }
    }
  
    #endregion

    #region Data
    private static volatile MSCryptoConfig instance;
    private static object root = new Object();
    private Logger logger;
    #endregion

  }

  #region MSConfig Class
  /// <summary>
  ///   Microsoft specific security configuration.
  /// </summary>
  [ComVisible(false)]
  public class MSConfig
  {
    /// <summary>
    ///   Specifies the file which contains the session key information.
    /// </summary>
    [XmlElement(ElementName = "keyFile", Type = typeof(string))]
    public string KeyFile;
  }
  #endregion
}
*/