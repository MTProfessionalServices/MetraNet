using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;

using MetraTech.Interop.RCD;
using MetraTech.Security.DPAPI;
using MetraTech.SecurityFramework;

namespace MetraTech.Security.Crypto
{
  /// <summary>
  /// 
  /// </summary>
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("732450C1-9BAA-488f-B413-6EDBA20FDC39")]
  public class MSCryptoManager : IMSCryptoSetup, ICryptoManager
  {
	  #region Constants

	  private static string paymentInstrumentGuid = "a6e7b72c-5a68-4a0e-a581-f9555ab9fa8e";
	  private static string databasePasswordGuid = "cbb23d8d-8189-4039-a575-a7388c369d99";
	  private static string serviceDefPropGuid = "ff3cb2c7-bcaf-4653-b20b-620d8713463d";
	  private static string queryStringPropGuid = "824219bc-1ea5-49de-8318-ec8ba8de67c7";
	  private static string ticketingGuid = "db09c1ce-9969-43d3-a346-a5cb18f1d366";
	  private static string WorldPayPassword = "46073e3d-0e41-43ba-8eb1-f1c8c5acbc08";
	  //private static string userPasswordGuid = "10cdb845-bf6d-4883-beee-003368360067";
	  private static string passwordHashGuid = "1095ffa1-8cfb-46cc-b30e-2d5d32c0e848";
	  private static string paymentInstrumentHashGuid = "a2a89816-cd39-4108-9887-3a993d444e85";

	  private const string CryptographyTagName = "[MetraTech.Security.Crypto.MSCryptoManager]";

	  private const string PlainTextArgument = "plainText";
	  private const string HashArgument = "hash";

	  #endregion

	  #region Constructor

    /// <summary>
    ///    Constructor
    /// </summary>
    public MSCryptoManager():this(false)
    { }

	  /// <summary>
    ///    Constructor
    /// </summary>
    public MSCryptoManager(bool needSfInitialize)
    {
      //logger = new Logger("[MetraTech.Security.Crypto.MSCryptoManager]");
      // Initialize the configuration of SecurityFramework
      if (needSfInitialize)
      {
        Initialize();
      }

      cryptoConfig = MSCryptoConfig.GetInstance();
    }
    #endregion

    #region ICryptoManager implementation

    /// <summary>
    ///   CryptoProvider
    /// </summary>
    public CryptoProvider CryptoProvider
    {
      get
      {
        return CryptoProvider.Microsoft;
      }
    }

    /// <summary>
    ///   Encrypt the given plainText based on the specified CryptKeyClass.
    /// </summary>
    /// <param name="cryptKeyClass"></param>
    /// <param name="plainText"></param>
    /// <returns></returns>
    public string Encrypt(CryptKeyClass cryptKeyClass, string plainText)
    {
		string result = plainText != null ? plainText.EncryptAes(cryptKeyClass.ToString()) : null;
		return result;
		/*
      if (String.IsNullOrEmpty(plainText))
      {
        return plainText;
      }

      string cipherText = null;

      // Retrieve the current key for this keyClass 
      Key key = cryptoConfig.SessionKeyConfig.GetCurrentKey(cryptKeyClass.ToString());
      List<string> errors = new List<string>();
      if (key == null || !key.IsValid(errors))
      {
        throw new ApplicationException(String.Format("Could not get key for key class '{0}'", cryptKeyClass.ToString()));
      }

      MemoryStream memStream = null;
      CryptoStream cryptoStream = null;
      RijndaelManaged rijndael = null;
      ICryptoTransform rdTransform = null;

      try
      {
        // Encode data string to be stored in memory
        byte[] plainTextBytes = Encoding.UTF8.GetBytes(plainText);
        byte[] originalBytes = { };

        // Create MemoryStream to contain output
        memStream = new MemoryStream(plainTextBytes.Length);

        rijndael = new RijndaelManaged();
        rijndael.BlockSize = 256;
        rijndael.Key = key.Value.Decrypt();
        rijndael.IV = key.IV.Decrypt();
        rijndael.Padding = PaddingMode.PKCS7;

        // Create encryptor
        rdTransform = rijndael.CreateEncryptor();
        
        cryptoStream = new CryptoStream(memStream, rdTransform, CryptoStreamMode.Write);

        // Write encrypted data to the MemoryStream
        cryptoStream.Write(plainTextBytes, 0, plainTextBytes.Length);
        cryptoStream.FlushFinalBlock();
        originalBytes = memStream.ToArray();

        // Convert encrypted string
        cipherText = key.Id.ToString() + Convert.ToBase64String(originalBytes);
      }
      catch (Exception e)
      {
        logger.LogException("Unable to encrypt data", e);
        throw new ApplicationException("Unable to encrypt data");
      }
      finally
      {
        // Release all resources
        if (memStream != null)
        {
          memStream.Close();
        }
        if (cryptoStream != null)
        {
          cryptoStream.Close();
        }
        if (rdTransform != null)
        {
          rdTransform.Dispose();
        }
        if (rijndael != null)
        {
          rijndael.Clear();
        }
      }

      return cipherText;
		 */
    }

    /// <summary>
    ///   Decrypt the given cipherText. The given cryptKeyClass is ignored.
    /// </summary>
    /// <param name="cryptKeyClass"></param>
    /// <param name="cipherTextWithKey"></param>
    /// <returns></returns>
    public string Decrypt(CryptKeyClass cryptKeyClass, string cipherTextWithKey)
		{
			if (String.IsNullOrEmpty(cipherTextWithKey))
			{
				return cipherTextWithKey;
			}

			string result = cipherTextWithKey.DecryptAes();
			return result;
		/*
      if (String.IsNullOrEmpty(cipherTextWithKey))
      {
        return cipherTextWithKey;
      }

      string plainText = null;

      RijndaelManaged rijndael = null;
      ICryptoTransform decryptor = null;
      MemoryStream memoryStream = null;
      CryptoStream cryptoStream = null;
      StreamReader streamReader = null;

      try
      {
        // Retrieve the key id from the cipherText
        string cipherText;
        Guid keyId = ParseKeyId(cipherTextWithKey, out cipherText);

        // Retrieve the current key for this keyClass 
        List<string> errors = new List<string>();

        Key key = cryptoConfig.SessionKeyConfig.GetKey(keyId);
        if (key == null || !key.IsValid(errors))
        {
          throw new ApplicationException(String.Format("Could not get key for key class '{0}'", cryptKeyClass.ToString()));
        }

        byte[] cipherBytes = Convert.FromBase64String(cipherText);
        byte[] initialText = new Byte[cipherBytes.Length];

        rijndael = new RijndaelManaged();
        rijndael.BlockSize = 256;
        rijndael.Key = key.Value.Decrypt();
        rijndael.IV = key.IV.Decrypt();
        rijndael.Padding = PaddingMode.PKCS7;

        // Create a decryptor to perform the stream transform.
        decryptor = rijndael.CreateDecryptor();

        // Create the streams used for decryption.
        memoryStream = new MemoryStream(cipherBytes);
        cryptoStream = new CryptoStream(memoryStream, decryptor, CryptoStreamMode.Read);
        streamReader = new StreamReader(cryptoStream);

        // Read the decrypted bytes from the decrypting stream
        // and place them in a string.
        plainText = streamReader.ReadToEnd();
      }
      catch (Exception e)
      {
        //logger.LogException("Unable to decrypt data", e);
        throw new ApplicationException("Unable to decrypt data");
      }
      finally
      {
        // Release all resources
        if (memoryStream != null)
        {
          memoryStream.Close();
        }
        if (cryptoStream != null)
        {
          cryptoStream.Close();
        }
        if (streamReader != null)
        {
          streamReader.Close();
        }
        if (decryptor != null)
        {
          decryptor.Dispose();
        }
        if (rijndael != null)
        {
          rijndael.Clear();
        }
      }

      return plainText;
		 */
    }

    /// <summary>
    ///   Hash the given plainText based on the specified HashKeyClass.
    /// </summary>
    /// <param name="keyClass"></param>
    /// <param name="plainText"></param>
    /// <returns></returns>
    public string Hash(HashKeyClass keyClass, string plainText)
    {
		if (plainText == null)
		{
			throw new ArgumentNullException(PlainTextArgument);
		}

		string result = plainText.HashSha(keyClass.ToString());
		return result;
		/*
      string hashedString = null;
      
      // Retrieve the current key for this keyClass 
      List<string> errors = new List<string>();

      Key key = cryptoConfig.SessionKeyConfig.GetCurrentKey(keyClass.ToString());
      if (key == null || !key.IsValid(errors))
      {
        throw new ApplicationException(String.Format("Could not get key for key class '{0}'", keyClass.ToString()));
      }

      hashedString = HashWithKey(keyClass, key.Id.ToString(), plainText);
      
      return hashedString;
		 */
    }

    /// <summary>
    ///   Hash the given plainText based on the specified HashKeyClass, and key id.
    ///   The cipherText string will have the KMS key id prepended to it.  
    /// </summary>
    /// <param name="keyClass"></param>
    /// <param name="keyId">Must be a guid</param>
    /// <param name="plainText"></param>
    /// <returns></returns>
    public string HashWithKey(HashKeyClass keyClass, string keyId, string plainText)
    {
		if (plainText == null)
		{
			throw new ArgumentNullException(PlainTextArgument);
		}

		string result = plainText.HashSha(keyClass.ToString(), keyId);
		return result;
      /*
      string hashedString = null;

      Guid keyIdGuid = new Guid(keyId);

      // Retrieve the current key for this keyClass 
      List<string> errors = new List<string>();
      Key key = cryptoConfig.SessionKeyConfig.GetKey(keyIdGuid);
      if (key == null || !key.IsValid(errors))
      {
        throw new ApplicationException(String.Format("Could not get key for key class '{0}'", keyClass.ToString()));
      }

      byte[] plainTextBytes = Encoding.UTF8.GetBytes(plainText);
      HMACSHA512 hmac = new HMACSHA512(key.Value.Decrypt());
      byte[] hash = hmac.ComputeHash(plainTextBytes);
      hashedString = key.Id.ToString() + Convert.ToBase64String(hash);
      
      return hashedString;
      */
    }

    /// <summary>
    ///   Return true if the hash of the given plainText matches the specified hash.
    /// </summary>
    /// <param name="keyClass"></param>
    /// <param name="hash"></param>
    /// <param name="plainText">The salted password</param>
    /// <returns></returns>
    public bool CompareHash(HashKeyClass keyClass, string hash, string plainText)
    {
		if (hash == null)
		{
			throw new ArgumentNullException(HashArgument);
		}

		if (plainText == null)
		{
			throw new ArgumentNullException(PlainTextArgument);
		}

		return plainText.CompareWithHashSha(keyClass.ToString(), hash);

      /*string keyId = ParseKeyFromHash(hash);
      string newHash = HashWithKey(keyClass, keyId, plainText);
      return (hash == newHash);*/
    }

    /// <summary>
    /// Parse the key id out of the hashed string.
    /// </summary>
    /// <param name="hashString"></param>
    /// <returns></returns>
    public string ParseKeyFromHash(string hashString)
    {
		return hashString.ParseKeyFromHashSha256();
		/*
      string textWithoutKey = null;
      Guid keyId = ParseKeyId(hashString, out textWithoutKey);
      return keyId.ToString();
		 */
    }

    /// <summary>
    /// Default implementation. No handles opened so we do nothing.
    /// </summary>
    public void FreeHandles()
    {
    }

    #endregion

    #region ICryptoSetup implementation
    /// <summary>
    ///   Create one session key for each key class. 
    ///   If the given password is empty (or null), a hardcoded password is used.
    ///   Existing keys, if any, are deleted. 
    ///   Output is generated in RMP\config\security\sessionkeys.xml.
    /// </summary>
    public void CreateSessionKeys(string password)
    {
      //Dictionary<string, string> keyClassKeys = new Dictionary<string, string>();
      List<string> keyClassNames = new List<string>();
      foreach (string keyClassName in Enum.GetNames(typeof(CryptKeyClass)))
      {
        keyClassNames.Add(keyClassName);
      }
      foreach (string keyClassName in Enum.GetNames(typeof(HashKeyClass)))
      {
        keyClassNames.Add(keyClassName);
      }

	  Dictionary<string, string> keyClassKeys = new Dictionary<string, string>(password.CreateSessionKeys(keyClassNames));
		/*
      foreach(string keyClassName in keyClassNames)
      {
        if (String.IsNullOrEmpty(password))
        {
          keyClassKeys.Add(keyClassName, keyClassName);
        }
        else
        {
          keyClassKeys.Add(keyClassName, password);
        }
      }
      
      CreateSessionKeys(keyClassKeys);
		 */
    }
 

    /// <summary>
    ///    Create a session key for the specified key class based on the specified password. 
    ///    The existing keys for the specified keyclass will be deleted. 
    /// </summary>
    /// <param name="keyClassName"></param>
    /// <param name="password"></param>
    public void CreateKey(string keyClassName, string password)
    {
      // Check that keyClassName is valid
      if (!CryptoManager.IsKeyClassNameValid(keyClassName))
      {
        throw new ApplicationException(String.Format("The specified key class '{0}' is invalid.", keyClassName));
      }

	  password.CreateCryptographicKey(keyClassName);
		/*
      MSSessionKeyConfig sessionKeyConfig = MSSessionKeyConfig.GetInstance();
      sessionKeyConfig.Initialize();

      // Check that sessionkeys.xml is valid
      string error;
      if (!sessionKeyConfig.IsValid(out error))
      {
        //logger.LogError(String.Format("Invalid session key configuration in file '{0}' :" + error, sessionKeyConfig.KeyFile));
        throw new ApplicationException(String.Format("Invalid session key configuration in file '{0}' :" + error, sessionKeyConfig.KeyFile));
      }

      sessionKeyConfig.Machine = Environment.MachineName;
      sessionKeyConfig.CreationDate = DateTime.Now;
      sessionKeyConfig.Process = Process.GetCurrentProcess().ProcessName;

      Dictionary<string, string> keyIds = GetKeyIds();

      foreach (KeyClass keyClass in sessionKeyConfig.KeyClasses)
      {
        if (keyClass.Name.ToLower() == keyClassName.ToLower())
        {
          keyClass.ClearKeys();
          string id = keyIds[keyClass.Name];
          Key key = CreateKeyInternal(password, id, true);
          keyClass.AddKey(key);

          break;
        }
      }

      sessionKeyConfig.Write();
		 */
    }

    /// <summary>
    ///    Create a session key for the specified key class based on the specified password and identifier.
    ///    If makeCurrent is true, the key will be made the current key for the given key class.
    /// </summary>
    /// <param name="keyClassName"></param>
    /// <param name="password"></param>
    /// <param name="id"></param>
    /// <param name="makeCurrent"></param>
    public void AddKey(string keyClassName, string password, Guid id, bool makeCurrent)
    {
		// Check that keyClassName is valid
		if (!CryptoManager.IsKeyClassNameValid(keyClassName))
		{
			throw new ApplicationException(String.Format("The specified key class '{0}' is invalid.", keyClassName));
		}

		password.AddCryptographicKey(keyClassName, id, makeCurrent);
		/*
      Debug.Assert(id != Guid.Empty);

      // Check that the input id doesn't already exist
      Dictionary<string, string> keyIds = GetKeyIds();
      foreach (string keyId in keyIds.Values)
      {
        if (keyId.ToLower() == id.ToString().ToLower())
        {
          throw new ApplicationException(String.Format("The specified key id '{0}' already exists.", id.ToString()));
        }
      }

      // Check that keyClassName is valid
      if (!CryptoManager.IsKeyClassNameValid(keyClassName))
      {
        throw new ApplicationException(String.Format("The specified key class '{0}' is invalid.", keyClassName));
      }

      MSSessionKeyConfig sessionKeyConfig = MSSessionKeyConfig.GetInstance();
      sessionKeyConfig.Initialize();

      // Check that sessionkeys.xml is valid
      string error;
      if (!sessionKeyConfig.IsValid(out error))
      {
        //logger.LogError(String.Format("Invalid session key configuration in file '{0}' :" + error, sessionKeyConfig.KeyFile));
        throw new ApplicationException(String.Format("Invalid session key configuration in file '{0}' :" + error, sessionKeyConfig.KeyFile));
      }

      sessionKeyConfig.Machine = Environment.MachineName;
      sessionKeyConfig.CreationDate = DateTime.Now;
      sessionKeyConfig.Process = Process.GetCurrentProcess().ProcessName;

      foreach (KeyClass keyClass in sessionKeyConfig.KeyClasses)
      {
        if (keyClass.Name.ToLower() == keyClassName.ToLower())
        {
          Key key = CreateKeyInternal(password, id.ToString(), makeCurrent);
          keyClass.AddKey(key);
          break;
        }
      }

      sessionKeyConfig.Write();
		 */
    }

    /// <summary>
    ///    Make the key specified by the given id to be the current key.
    /// </summary>
    /// <param name="id"></param>
    public void MakeKeyCurrent(Guid id)
    {
		id.MakeKeyCurrent();
		/*
      MSSessionKeyConfig sessionKeyConfig = MSSessionKeyConfig.GetInstance();
      sessionKeyConfig.Initialize();

      // Check that sessionkeys.xml is valid
      string error;
      if (!sessionKeyConfig.IsValid(out error))
      {
        //logger.LogError(String.Format("Invalid session key configuration in file '{0}' :" + error, sessionKeyConfig.KeyFile));
        throw new ApplicationException(String.Format("Invalid session key configuration in file '{0}' :" + error, sessionKeyConfig.KeyFile));
      }

      sessionKeyConfig.Machine = Environment.MachineName;
      sessionKeyConfig.CreationDate = DateTime.Now;
      sessionKeyConfig.Process = Process.GetCurrentProcess().ProcessName;

      Key key = sessionKeyConfig.GetKey(id);
      if (key == null)
      {
        throw new ApplicationException(String.Format("Key '{0}' not found", id.ToString()));
      }

      sessionKeyConfig.MakeKeyCurrent(id);

      sessionKeyConfig.Write();
		 */
    }

    /// <summary>
    ///   Delete the sessionkeys.xml file from RMP\config\security.
    /// </summary>
    public void DeleteSessionKeys()
    {
      MSSessionKeyConfig sessionKeyConfig = MSSessionKeyConfig.GetInstance();
	  sessionKeyConfig.DeleteSessionKeys();
		/*
      try
      {
        if (File.Exists(sessionKeyConfig.KeyFile))
        {
          File.Delete(sessionKeyConfig.KeyFile);
        }
      }
      catch (Exception)
      {
        //logger.LogError(String.Format("Unable to delete the session keys file '{0}' :", sessionKeyConfig.KeyFile));
      }
		 */
    }
    #endregion

    #region Installer Helpers
    /// <summary>
    ///    
    /// </summary>
    /// <param name="keyClassKeys"></param>
    public static void CreateSessionKeys(Dictionary<string, string> keyClassKeys)
    {
      MSSessionKeyConfig sessionKeyConfig = MSSessionKeyConfig.GetInstance();

      sessionKeyConfig.Machine = Environment.MachineName;
      sessionKeyConfig.CreationDate = DateTime.Now;
      sessionKeyConfig.Process = Process.GetCurrentProcess().ProcessName;

      Dictionary<string, string> keyIds = GetKeyIds();

      foreach (string keyClassName in keyClassKeys.Keys)
      {
        KeyClass keyClass = new KeyClass();
        keyClass.Name = keyClassName;

        string userKey = keyClassKeys[keyClassName];
        string id = keyIds[keyClassName];

        if (String.IsNullOrEmpty(userKey))
        {
          throw new ApplicationException(String.Format("Missing user key for key class '{0}'", keyClassName));
        }

        if (String.IsNullOrEmpty(id))
        {
          throw new ApplicationException(String.Format("Cannot locate key id for key class '{0}'", keyClassName));
        }

        Key key = CreateKeyInternal(userKey, id, true);
        keyClass.AddKey(key);

        sessionKeyConfig.AddKeyClass(keyClass);
      }

      sessionKeyConfig.Write();
    }
    #endregion

    #region Public Methods
    /// <summary>
    ///   Return a mapping of key class enumerators
    /// </summary>
    /// <returns></returns>
    public static Dictionary<string, string> GetKeyIds()
    {
      Dictionary<string, string> keyIds = new Dictionary<string, string>();
      keyIds.Add("PaymentInstrument", paymentInstrumentGuid);
      keyIds.Add("DatabasePassword", databasePasswordGuid);
      keyIds.Add("ServiceDefProp", serviceDefPropGuid);
      keyIds.Add("QueryString", queryStringPropGuid);
	  keyIds.Add("Ticketing", ticketingGuid);
	  keyIds.Add("WorldPayPassword", WorldPayPassword);

      keyIds.Add("PasswordHash", passwordHashGuid);
      keyIds.Add("PaymentMethodHash", paymentInstrumentHashGuid);

      return keyIds;
    }
    #endregion

    #region Private Methods

    private void Initialize()
    {
      using (MTComSmartPtr<IMTRcd> rcd = new MTComSmartPtr<IMTRcd>())
      {
        rcd.Item = new MTRcdClass();
        rcd.Item.Init();

        string path = Path.Combine(rcd.Item.ConfigDir, @"Security\Validation", CryptoManager.SecurityFrameworkRootConfig);
        SecurityKernel.Initialize(new MetraTech.SecurityFramework.Serialization.XmlSerializer(), path); //Initialize with the Security Framework properties
        SecurityKernel.Start();
      }
    }
	  /*
    /// <summary>
    ///    Expect the input text to be prefixed with a key which is a Guid. 
    ///    Return the Guid and the remaining text in textWithoutKey.
    /// </summary>
    /// <param name="text"></param>
    /// <param name="textWithoutKey"></param>
    /// <returns></returns>
    private Guid ParseKeyId(string text, out string textWithoutKey)
    {
      Guid keyId = Guid.Empty;

      int length = Guid.Empty.ToString().Length;

      string guid = text.Substring(0, length);

      if (!String.IsNullOrEmpty(guid))
      {
        keyId = new Guid(guid);
      }

      textWithoutKey = text.Substring(length);

      return keyId;
    }
	  */

    /// <summary>
    ///    Create a key based on a password and id.
    /// </summary>
    /// <param name="password"></param>
    /// <param name="id">must be a Guid</param>
    /// <param name="makeCurrent">make this key current</param>
    /// <returns></returns>
    private static Key CreateKeyInternal(string password, string id, bool makeCurrent)
    {
      Key key = new Key();
      key.Id = new Guid(id);
      key.IsCurrent = makeCurrent;
      key.Secret = new CDATA(DPAPIWrapper.Encrypt(password));

      string value = null;
      string iv = null;
      KeyGenerator.CreateKey(password, out value, out iv);

      key.Value = new CDATA(DPAPIWrapper.Encrypt(value));
      key.IV = new CDATA(DPAPIWrapper.Encrypt(iv));

      return key;
    }


    #endregion

    #region Data
    // private Logger logger;
    private MSCryptoConfig cryptoConfig;

    #endregion
  }
  
}
