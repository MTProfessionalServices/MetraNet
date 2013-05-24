using System;
using System.Text;
using System.Security.Cryptography;

namespace MetraTech.Security.DPAPI
{
  /// <summary>
  ///   DPAPI Wrapper
  /// </summary>
  public class DPAPIWrapper
  {
    #region Public Methods
    /// <summary>
    ///   Use DPAPI to encrypt the given plainText.
    /// </summary>
    /// <param name="plainText"></param>
    /// <returns></returns>
    public static string Encrypt(string plainText)
    {
      string cipherText = null;

      string entropy = GetEntropy();

      byte[] encodedPlaintext = Encoding.UTF8.GetBytes(plainText);
      byte[] encodedEntropy = Encoding.UTF8.GetBytes(entropy);

      byte[] ciphertext =
        ProtectedData.Protect(encodedPlaintext, encodedEntropy, DataProtectionScope.LocalMachine);

      cipherText = Convert.ToBase64String(ciphertext);

      return cipherText;
    }

    /// <summary>
    ///   Use DPAPI to decrypt the given cipherText.
    /// </summary>
    /// <param name="base64Ciphertext"></param>
    /// <returns></returns>
    public static string Decrypt(string base64Ciphertext)
    {
      string plainText = null;

      string entropy = GetEntropy();

      byte[] ciphertext = Convert.FromBase64String(base64Ciphertext);
      byte[] encodedEntropy = Encoding.UTF8.GetBytes(entropy);

      byte[] encodedPlaintext =
        ProtectedData.Unprotect(ciphertext, encodedEntropy, DataProtectionScope.LocalMachine);

      plainText = Encoding.UTF8.GetString(encodedPlaintext);

      return plainText;
    }
    #endregion

    #region Private Methods
    private static string GetEntropy()
    {
      Random random = new Random(987654321);

      StringBuilder entropy = new StringBuilder();
      for (int i = 0; i < 5; i++)
      {
        entropy.Append(random.Next());
      }

      return entropy.ToString();
    }
    #endregion

    #region Data
    #endregion
  }
}
