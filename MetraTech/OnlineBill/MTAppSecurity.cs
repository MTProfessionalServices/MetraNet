using System.Runtime.InteropServices;
using System.Globalization;
using System;
using System.Collections;
using System.Text;
using System.Diagnostics;
using CodeProject.Collections;

using MetraTech.Security.Crypto;

namespace MetraTech.OnlineBill
{
  using MetraTech.Interop.MTHierarchyReports;
  using MetraTech;
  using MetraTech.DataAccess;
  using MetraTech.DataAccess.MaterializedViews;
  using MetraTech.Performance;
  using System.Web;

  #region MTAppSecurity
  // QueryString encrypt provides basic encryption and URLEncoding for strings.  
  // It is used by the slice objects.
  [Guid("81BA0B8C-B47A-4d6d-8E6E-7FA9ECD73387")]
  public interface IQueryStringEncrypt
  {
    string EncryptString(string str);
    string DecryptString(string str);
     
    string Hex(string str);
    string DeHex(string str);

    string GenerateGUID();
    string GenerateToken(string guid, int acc_id);
    bool ValidateToken(string sessionToken, string pageToken, int acc_id);

    string Seed
    {
      get;
      set;
    }

  }

  [ClassInterface(ClassInterfaceType.None)]
  [Guid("51DCB281-915C-4fb4-AFFB-C38C043E3792")]
  public class QueryStringEncrypt : IQueryStringEncrypt
  {
    private Logger mLogger = new Logger("[QueryStringEncrypt]");
    private CryptoManager cryptoManager = new CryptoManager();
    private static MostRecentlyUsed mHashedStrings = new MostRecentlyUsed(1000);
    
    private string mSeed = String.Empty;
    public string Seed
    {
      get { return mSeed; }
      set { mSeed = value; }
    }

    private const char SEPARATOR_CHAR = '|';

    public QueryStringEncrypt()
    {
    }

    /// <summary>
    /// EncryptString takes in a string and encrypts it using the MT
    /// crypto api in ComSecureSore - GetProtectedProperty.  (Currently 3Des)
    /// The returned string is Hex encoded so it is safe to pass on a QueryString.
    /// </summary>
    /// <param name="str">String to encrypt</param>
    /// <returns>Encrypted string</returns>
    public string EncryptString(string str)
    {
      string encrypted = "";
      try
      {
        
        string seededStr = Seed + SEPARATOR_CHAR + str;
        
        lock(this)
        {
            if (mHashedStrings.Contains(seededStr))
            {
              encrypted = (string)mHashedStrings[seededStr];
            }
            else
            {
              // Use the new security component
              encrypted = cryptoManager.Encrypt(CryptKeyClass.QueryString, seededStr);
              mHashedStrings.Add(seededStr, encrypted);
            }
        }

        encrypted = Hex(encrypted);
      }
      catch (Exception exp)
      {
        mLogger.LogException("Exception caught while encrypting string", exp);
      }
      return encrypted;
    }

    /// <summary>
    /// DecryptString takes in a string and decrypts it using the MT
    /// crypto api in ComSecureSore - GetProtectedProperty.
    /// </summary>
    /// <param name="str">Encrypted string</param>
    /// <returns>Unencrypted string</returns>
    public string DecryptString(string str)
    {
      if (str.Length == 0)
      {
        return "";
      }

      string decrypted = "";
      try
      {
        decrypted = DeHex(str);
        decrypted = cryptoManager.Decrypt(CryptKeyClass.QueryString, decrypted);

        string[] tempSeed = decrypted.Split(new char[] { SEPARATOR_CHAR }, 2, StringSplitOptions.None);
        if (tempSeed.Length != 2)
        {
          throw new ApplicationException("Invalid seed length.");
        }

        if (tempSeed[0] != Seed)
        {
          throw new ApplicationException("Invalid seed.");
        }

        decrypted = tempSeed[1];
      }
      catch (Exception exp)
      {
        mLogger.LogError(exp.Message.ToString());
      }
      return decrypted;
    }

    /// <summary>
    /// DeHex takes in a hex String and converts to ascii
    /// </summary>
    /// <param name="str">hex string</param>
    /// <returns>converted string</returns>
    public string DeHex(string str)
    {
      if ((str.Length % 2) != 0)
      {
        throw (new System.ApplicationException("Invalid string to decode."));
      }

      StringBuilder sb = new StringBuilder();
      for (int i = 0; i < str.Length - 1; i = i + 2)
      {
        sb.Append((char)int.Parse(str.Substring(i, 2), NumberStyles.HexNumber));
      }

      return sb.ToString();
    }

    /// <summary>
    /// Hex takes in a string and converts it to hex
    /// </summary>
    /// <param name="str">string to convert</param>
    /// <returns>hex string</returns>
    public string Hex(string str)
    {
      StringBuilder sb = new StringBuilder();
      for (int i = 0; i < str.Length; i++)
      {
        sb.Append(String.Format("{0:X2}", (int)str[i]));
      }

      return sb.ToString();
    }



    public string GenerateGUID()
    {
      return System.Guid.NewGuid().ToString();
    }

    public string GenerateToken(string guid, int acc_id)
    {
      //append account id with a guid
      StringBuilder sb = new StringBuilder(acc_id.ToString());
      sb.Append(SEPARATOR_CHAR);
      sb.Append(guid);

      //encrypt the combination
      string token = EncryptString(sb.ToString());

      return token;
    }

    /// <summary>
    /// Generates an authentication token by concatenating an account ID with a generated GUID,
    /// separated by '|' and encoding the result using 3Des
    /// </summary>
    /// <param name="acc_id"></param>
    /// <returns>Encoded string</returns>
    public string GenerateToken(int acc_id)
    {
      //generate GUID
      string sGUID = GenerateGUID();

      return GenerateToken(sGUID, acc_id);
    }

    /// <summary>
    /// Perform token validation by a two-step approach:
    /// 1) compare the token received from the page against the token stored in the session
    /// 2) decrypt the token from page, parse it, and compare the first part against account ID
    /// </summary>
    /// <param name="sessionToken"></param>
    /// <param name="pageToken"></param>
    /// <param name="acc_id"></param>
    /// <returns>True if passed validation, False otherwise</returns>
    public bool ValidateToken(string sessionGuid, string pageToken, int acc_id)
    {
      //no session token provided - OK
      if (sessionGuid.Length <= 0)
      {
        return true;
      }

      //regenerate token based on session GUID and acc_id
      string generatedToken = GenerateToken(sessionGuid, acc_id);

      //compare generated token against what was shown on page
      if (generatedToken != pageToken)
      {
        return false;
      }

      return true;
    }

  }
  #endregion




}

