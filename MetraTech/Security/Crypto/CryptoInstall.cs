using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using MetraTech.Security.DPAPI;


namespace MetraTech.Security.Crypto
{
  /// <summary>
  ///   CryptoInstall
  /// </summary>
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("3C449125-82EE-42ca-995A-DE58BC4C0C43")]
  public class CryptoInstall : ICryptoInstall
  {
    #region Public Methods
    /// <summary>
    ///    Constructor
    /// </summary>
    public CryptoInstall()
    {
      try
      {
        logger = new Logger("[MetraTech.Security.Crypto]");
      }
      catch (Exception e)
      {
        logger.LogException("Failed to initialize CryptoInstall", e);
      }
    }
    #endregion

    #region ICryptoInstall
    /// <summary>
    ///   Return the names of the key classes
    /// </summary>
    public object[] KeyClassNames
    {
      get
      {
        List<object> keyClassNames = new List<object>();
        foreach (string keyClassName in Enum.GetNames(typeof(CryptKeyClass)))
        {
          keyClassNames.Add(keyClassName);
        }
        foreach (string keyClassName in Enum.GetNames(typeof(HashKeyClass)))
        {
          keyClassNames.Add(keyClassName);
        }

        return keyClassNames.ToArray();
      }
    }

    /// <summary>
    ///    (1) Generate the sessionkeys.xml file in RMP\config\security based on keyClassKeys
    ///    (2) Set the contents of cryptoTypeName in RMP\config\security\mtsecurity.xml to MetraTech.Security.Crypto.MSCryptoManager
    /// </summary>
    /// <param name="mtKeyClassNames"></param>
    /// <param name="keyClassKeys"></param>
    /// <param name="setDefaultCryptoTypeName"></param>
    public void GenerateSessionKeys(object[] mtKeyClassNames, object[] keyClassKeys, bool setDefaultCryptoTypeName)
    {
      if (mtKeyClassNames == null)
      {
        var message = "The mapping of MetraTech key classes to user keys is not specified.";
        logger.LogError(message);
        throw new ApplicationException(message);
      }
      if (keyClassKeys == null)
      {
        var message = "The mapping of MetraTech key classes to user keys is not specified.";
        logger.LogError(message);
        throw new ApplicationException(message);
      }

      if (mtKeyClassNames.Length != keyClassKeys.Length)
      {
        var message = "The mapping of MetraTech key classes to user keys is not complete.";
        logger.LogError(message);
        throw new ApplicationException(message);
      }

      // Validate that all the key classes are present
      if (mtKeyClassNames.Length != KeyClassNames.Length)
      {
        var message = "Missing or extra key class items specified";
        logger.LogError(message);
        throw new ApplicationException(message);
      }

      Dictionary<string, string> keysByKeyName = new Dictionary<string, string>();
      for (int i = 0; i < mtKeyClassNames.Length; i++ )
      {
        string keyClassName = mtKeyClassNames[i] as string;
        if (String.IsNullOrEmpty(keyClassName))
        {
          var message = "A non-string or null key class name specified.";
          logger.LogError(message);
          throw new ApplicationException(message);
        }
        if (!CryptoManager.IsKeyClassNameValid(keyClassName))
        {
          var message = String.Format("The specified key class '{0}' is not valid.", keyClassName);
          logger.LogError(message);
          throw new ApplicationException(message);
        }
        keysByKeyName.Add(keyClassName, (string)keyClassKeys[i]);
      }
      try
      {
        // Create the sessionekeys.xml file
        MSCryptoManager.CreateSessionKeys(keysByKeyName);

        // Update <cryptoTypeName>
        if (setDefaultCryptoTypeName)
        {
          CryptoConfig cryptoConfig = CryptoConfig.GetInstance();
          cryptoConfig.CryptoTypeName = "MetraTech.Security.Crypto.MSCryptoManager";
          cryptoConfig.RSAConfig = null;
          cryptoConfig.Write();
        }
        
        // Encrypt passwords
        CryptoManager cryptoManager = new CryptoManager();
        cryptoManager.EncryptPasswords();
        
      }
      catch (Exception e)
      {
        logger.LogException("Error generating sessionkeys for default crypto", e);
        throw;
      }
      
    }

    /// <summary>
    ///    (1) Update RMP\config\security\mtsecurity.xml 
    ///      	Set cryptoTypeName to MetraTech.Security.Crypto.MSCryptoManager
    ///       	Set kmsIdentityGroup to the value of identityGroup
    ///      	Encrypt the clientCertPassword using DPAPI and set kmsCertificatePwd to the encrypted value.
    ///
    ///   	(2) Update RMP\config\security\key.cfg
    ///       	Set the value of kms.sslPKCS12File to clientCertPath
    ///        Set the value of kms.address to kmsServer
    ///      	Set the value of kms.logFile to the correct path for RMP\config\security
    ///      	Set the value of kms.cacheFile to the correct path for RMP\config\security
    /// </summary>
    /// <param name="kmsServer"></param>
    /// <param name="clientCertificateFile"></param>
    /// <param name="clientCertificatePwd"></param>
    /// <param name="mtKeyClassNames"></param>
    /// <param name="kmsKeyClassNames"></param>
    /// <param name="ticketingKey"></param>
    /// <param name="encryptPasswords"></param>
    public void UpdateKMSConfig(string kmsServer,
                                string clientCertificateFile,
                                string clientCertificatePwd,
                                object[] mtKeyClassNames,
                                object[] kmsKeyClassNames,
                                string ticketingKey,
                                bool encryptPasswords)
    {
      if (String.IsNullOrEmpty(kmsServer))
      {
        var message = "The KMS Server name is not specified.";
        logger.LogError(message);
        throw new ApplicationException(message);
      }

      if (String.IsNullOrEmpty(clientCertificateFile))
      {
        var message = "The client certificate is not specified.";
        logger.LogError(message);
        throw new ApplicationException(message);
      }

      if (!File.Exists(clientCertificateFile))
      {
        var message = String.Format("The client certificate file '{0}' cannot be found.", clientCertificateFile);
        logger.LogError(message);
        throw new ApplicationException(message);
      }

      if (String.IsNullOrEmpty(clientCertificatePwd))
      {
        var message = "The client certificate password is not specified.";
        logger.LogError(message);
        throw new ApplicationException(message);
      }

      if (mtKeyClassNames == null)
      {
        var message = "The mapping of MetraTech key classes to KMS Server key classes is not specified.";
        logger.LogError(message);
        throw new ApplicationException(message);
      }
      if (kmsKeyClassNames == null)
      {
        var message = "The mapping of MetraTech key classes to KMS Server key classes is not specified.";
        logger.LogError(message);
        throw new ApplicationException(message);
      }

      if (mtKeyClassNames.Length != kmsKeyClassNames.Length)
      {
        var message = "The mapping of MetraTech key classes to KMS Server key classes is not complete.";
        logger.LogError(message);
        throw new ApplicationException(message);
      }

      if (String.IsNullOrEmpty(ticketingKey))
      {
        var message = "The ticketing key is not specified.";
        logger.LogError(message);
        throw new ApplicationException(message);
      }

      // Validate that all the key classes are present
      object[] keyClassNames = KeyClassNames;
      if (keyClassNames.Length != kmsKeyClassNames.Length + 1) // Account for missing Ticketing key class
      {
        var message = "Missing or extra key class items specified";
        logger.LogError(message);
        throw new ApplicationException(message);
      }

      for (int i = 0; i < mtKeyClassNames.Length; i++)
      {
        string keyClassName = mtKeyClassNames[i] as string;
        if (String.IsNullOrEmpty(keyClassName))
        {
          var message = "A non-string or null key class name specified.";
          logger.LogError(message);
          throw new ApplicationException(message);
        }
        if (!CryptoManager.IsKeyClassNameValid(keyClassName))
        {
          var message = String.Format("The specified key class '{0}' is not valid.", keyClassName);
          logger.LogError(message);
          throw new ApplicationException(message);
        }

        if (String.IsNullOrEmpty(kmsKeyClassNames[i] as string))
        {
          var message = String.Format("No KMS key class specified for '{0}'.", keyClassName);
          logger.LogError(message);
          throw new ApplicationException(message);
        }
      }
        
      try
      {
        CryptoConfig cryptoConfig = CryptoConfig.GetInstance();
        cryptoConfig.CryptoTypeName = "MetraTech.Security.Crypto.RSACryptoManager";
        cryptoConfig.RSAConfig = new RSAConfig();
        cryptoConfig.RSAConfig.KmsClientConfigFile = Path.Combine(cryptoConfig.RCD.ConfigDir, @"security\key.cfg");
        cryptoConfig.RSAConfig.KmsCertificatePwd = new CertificatePassword();
        cryptoConfig.RSAConfig.KmsCertificatePwd.Password = DPAPIWrapper.Encrypt(clientCertificatePwd);
        cryptoConfig.RSAConfig.KmsCertificatePwd.Encrypted = true;

        cryptoConfig.RSAConfig.KMSKeyClasses = new KMSKeyClass[kmsKeyClassNames.Length];
        int i = 0;
        Dictionary<string, string> keysByKeyNameForMicrosoft = new Dictionary<string, string>();
        foreach (string keyClassName in mtKeyClassNames)
        {
          KMSKeyClass kmsKeyClass = new KMSKeyClass();
          kmsKeyClass.Id = keyClassName;
          kmsKeyClass.Name = (string)kmsKeyClassNames[i];
          cryptoConfig.RSAConfig.KMSKeyClasses[i] = kmsKeyClass;
          keysByKeyNameForMicrosoft.Add(keyClassName, keyClassName);
          i++;
        }

        cryptoConfig.Write();

        // Create key.cfg
        using (FileStream file = new FileStream(cryptoConfig.RSAConfig.KmsClientConfigFile,
                                                FileMode.Create,
                                                FileAccess.Write))
        {
          using (StreamWriter writer = new StreamWriter(file))
          {
            writer.WriteLine("kms.sslPKCS12File = " + clientCertificateFile);
            writer.WriteLine("kms.sslPKCS12Password = ");
            writer.WriteLine("kms.address = " + kmsServer);
            writer.WriteLine("kms.port = 443");
            writer.WriteLine("kms.debug = error");
            writer.WriteLine("kms.logFile = " + Path.Combine(cryptoConfig.RCD.ConfigDir, @"security\kms.log"));
            writer.WriteLine("kms.sslConnectTimeout = 2");
            writer.WriteLine("kms.retries = 2");
            writer.WriteLine("kms.retryDelay = 2");
            writer.WriteLine("kms.cacheTimeToLive = 345600");
            writer.WriteLine("kms.cacheFile = " + Path.Combine(cryptoConfig.RCD.ConfigDir, @"security\kms.cache"));
            writer.WriteLine("kms.memoryCache = false");
          }

          file.Close();
        }

        // Create sessionkeys.xml for ticketing key
        keysByKeyNameForMicrosoft.Add(CryptKeyClass.Ticketing.ToString(), ticketingKey);
        MSCryptoManager.CreateSessionKeys(keysByKeyNameForMicrosoft);


        // Encrypt passwords
        if (encryptPasswords)
        {
          CryptoManager cryptoManager = new CryptoManager();
          cryptoManager.EncryptPasswords();
        }
      }
      catch (Exception e)
      {
        logger.LogException("Error initializing KMS Crypto", e);
        throw;
      }
      
    }

    #endregion

    #region Data
    private readonly Logger logger;
    #endregion
  }
}
