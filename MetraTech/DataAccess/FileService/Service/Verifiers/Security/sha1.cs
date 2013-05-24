namespace MetraTech.FileService
{
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Assemblies
  ////////////////////////////////////////////////////////////////////////////////////// 
  using System;
  using System.IO;
  using System.Text;
  using System.Security.Cryptography;
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Interfaces
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Delegates
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Enumerations
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Classes
  ////////////////////////////////////////////////////////////////////////////////////// 
  #region SHA1 Verification
  /// <summary>
  /// Sha1 verifier
  /// </summary>
  class SHA1Verifier : SecurityVerifier
  {
    public SHA1Verifier(string name, string sha1)
      : base(name, sha1)
    { }

    public override bool Verify()
    {
      Log.Debug(CODE.__FUNCTION__);
      if (!File.Exists(VALUE))
        return false;

      try
      {
        using (FileStream fStream = File.Open(VALUE, FileMode.Open))
        {
          byte[] hash;
          using (SHA1 sha1chkr = new SHA1CryptoServiceProvider())
          {
            hash = sha1chkr.ComputeHash(fStream);
            fStream.Close();
          }
          StringBuilder sb = new StringBuilder();
          for (int i = 0; i < hash.Length; i++)
          {
            sb.Append(hash[i].ToString("x2"));
          }
          if (0 == string.Compare(sb.ToString(), HASH))
            return true;
        }
      }
      catch (Exception e)
      {
        Log.Error(e.Message);
      }
      return false;
    }
  } 
  #endregion
  ////////////////////////////////////////////////////////////////////////////////////// 
}
