using System;
using System.Text;
using System.Security.Cryptography;

namespace MetraTech.Security.DPAPI
{
  /// <summary>
  ///   KeyGenerator
  /// </summary>
  public class KeyGenerator
  {
    #region Public Methods
    /// <summary>
    ///   Use Rfc2898DeriveBytes to generate a key and IV for Rijndael256 using
    ///   the given password.
    /// </summary>
    /// <param name="password"></param>
    /// <param name="base64Key"></param>
    /// <param name="base64Iv"></param>
    /// <returns></returns>
    public static void CreateKey(string password, out string base64Key, out string base64Iv)
    {
      byte[] salt = new byte[] { 0, 1, 2, 3, 4, 5, 6, 7 };
      Rfc2898DeriveBytes pwdGen = new Rfc2898DeriveBytes(password, salt, 1000);

      // Generate a 32 byte (256 bit) key from the password
      byte[] bytes = pwdGen.GetBytes(32);
      base64Key = Convert.ToBase64String(bytes);

      // Generate a 32 byte (256 bit) IV from the password hash
      bytes = pwdGen.GetBytes(32);
      base64Iv = Convert.ToBase64String(bytes);
    }

    /// <summary>
    ///   Hash SHA256
    /// </summary>
    /// <param name="plainText"></param>
    /// <returns></returns>
    public static string Hash(string plainText)
    {
      string cipherText = String.Empty;

      byte[] encodedPlainText = Encoding.Unicode.GetBytes(plainText);

      using(SHA256Managed hashingObj = new SHA256Managed())
      {
          byte[] hashCode = hashingObj.ComputeHash(encodedPlainText);

          cipherText = Convert.ToBase64String(hashCode);
          hashingObj.Clear();
      }

      return cipherText;
    }
    #endregion

    #region Private Methods
    
    #endregion

    #region Data
    #endregion
  }
}
