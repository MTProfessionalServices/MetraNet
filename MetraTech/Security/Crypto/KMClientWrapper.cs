/*
using System;
using System.Text;
using System.Runtime.InteropServices;

namespace MetraTech.Security.Crypto
{
  /// <summary>
  /// Summary description for KMClientWrapper.
  /// </summary>
  [ComVisible(false)]
  public class KMClientWrapper 
  {  //declare external DLL routines for KMS

    /// <summary>
    ///    KMSInit
    /// </summary>
    /// <param name="configfile"></param>
    /// <param name="certpassword"></param>
    /// <returns></returns>
    [DllImport("kmclient.dll")]
    public static extern int KMSInit(String configfile, String certpassword);

    /// <summary>
    ///    KMSGetKey
    /// </summary>
    /// <param name="handle"></param>
    /// <param name="keyclass"></param>
    /// <param name="keyid"></param>
    /// <param name="Key"></param>
    /// <param name="keysize"></param>
    /// <param name="returned_keylength"></param>
    /// <param name="returned_keyid"></param>
    /// <param name="returned_keyidsize"></param>
    /// <returns></returns>
    [DllImport("kmclient.dll")]
    public static extern int KMSGetKey(int handle, 
                                       string keyclass, 
                                       string keyid, [MarshalAs(UnmanagedType.LPArray)] byte[] Key, 
                                       int keysize, 
                                       ref int returned_keylength, 
                                       [MarshalAs(UnmanagedType.LPStr)] StringBuilder returned_keyid, 
                                       int returned_keyidsize);

    /// <summary>
    ///   KMSEncryptData
    /// </summary>
    /// <param name="handle"></param>
    /// <param name="keyclass"></param>
    /// <param name="clearText"></param>
    /// <param name="clearLen"></param>
    /// <param name="cipherText"></param>
    /// <param name="cipherSize"></param>
    /// <param name="cipherLen"></param>
    /// <param name="base64flag"></param>
    /// <returns></returns>
    [DllImport("kmclient.dll")]
    public static extern int KMSEncryptData(int handle, 
                                            [MarshalAs(UnmanagedType.LPStr)] string keyclass, 
                                            [MarshalAs(UnmanagedType.LPArray)] byte[] clearText, 
                                            int clearLen, 
                                            [MarshalAs(UnmanagedType.LPArray)] byte[] cipherText, 
                                            int cipherSize, 
                                            ref int cipherLen, 
                                            int base64flag);

    /// <summary>
    ///   KMSDecryptData
    /// </summary>
    /// <param name="handle"></param>
    /// <param name="keyclass"></param>
    /// <param name="cipherText"></param>
    /// <param name="cipherLen"></param>
    /// <param name="clearText"></param>
    /// <param name="clearSize"></param>
    /// <param name="clearLen"></param>
    /// <returns></returns>
    [DllImport("kmclient.dll")]
    public static extern int KMSDecryptData(int handle, 
                                            [MarshalAs(UnmanagedType.LPStr)] string keyclass,
																					 [MarshalAs(UnmanagedType.LPArray)] byte[] cipherText, 
                                            int cipherLen, 
                                            [MarshalAs(UnmanagedType.LPArray)] byte[] clearText, 
                                            int clearSize, 
                                            ref int clearLen);

    /// <summary>
    ///   KMSHMACData
    /// </summary>
    /// <param name="handle"></param>
    /// <param name="keyClass"></param>
    /// <param name="keyID"></param>
    /// <param name="text"></param>
    /// <param name="textLen"></param>
    /// <param name="hmac"></param>
    /// <param name="hmacSize"></param>
    /// <param name="hmacLen"></param>
    /// <returns></returns>
    [DllImport("kmclient.dll")]
    public static extern int KMSHMACData(int handle, 
                                         [MarshalAs(UnmanagedType.LPStr)] string keyClass, 
                                         [MarshalAs(UnmanagedType.LPStr)] string keyID, 
                                         [MarshalAs(UnmanagedType.LPArray)] byte[] text,
                                         int textLen, 
                                         [MarshalAs(UnmanagedType.LPArray)] byte[] hmac, 
                                         int hmacSize, 
                                         ref int hmacLen);

    /// <summary>
    ///   KMSDestroy
    /// </summary>
    /// <param name="handle"></param>
    /// <returns></returns>
    [DllImport("kmclient.dll")]
    public static extern int KMSDestroy(int handle);
  }
}
*/