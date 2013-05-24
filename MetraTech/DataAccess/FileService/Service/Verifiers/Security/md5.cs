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
  #region MD5 Verification
  /// <summary>
  /// MD5 verifier
  /// </summary>
  class MD5Verifier : SecurityVerifier
  {

    public MD5Verifier(string name, string md5)
      : base(name, md5)
    { }

    public override bool Verify()
    {
      Log.Debug(CODE.__FUNCTION__);
      if (!File.Exists(VALUE))
        return false;

      try
      {
        FileStream file = new FileStream(VALUE, FileMode.Open);
        MD5 md5chkr = new MD5CryptoServiceProvider();
        byte[] hash = md5chkr.ComputeHash(file);
        file.Close();

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < hash.Length; i++)
        {
          sb.Append(hash[i].ToString("x2"));
        }
        if (0 == string.Compare(sb.ToString(), HASH))
          return true;
        // Fall through
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
