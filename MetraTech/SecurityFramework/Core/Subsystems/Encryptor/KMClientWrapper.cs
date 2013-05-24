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
		///    Initialize the KMS client library
		/// </summary>
		/// <param name="configfile">(in) path name to configuration file</param>
		/// <param name="certpassword"></param>
		/// <returns>NULL on error|KMSHandle in success</returns>
		[DllImport("kmclient.dll", CallingConvention=CallingConvention.Cdecl)]
		public static extern int KMSInit(String configfile, String certpassword);

		/// <summary>
		///    Retrieve a key from the server or fromt the cache if available
		/// </summary>
		/// <param name="handle"> (in) KMS handle returned from KMSInit</param>
		/// <param name="keyclass">(in) Key class to retrieve the key from</param>
		/// <param name="keyid">(in) the key ID of the key to retrieve (NULL if we want the current key)</param>
		/// <param name="Key">(out) buffer to store the retrieved key</param>
		/// <param name="keysize">(in) size of buffer to store key</param>
		/// <param name="returned_keylength">(out) size of returned key in bytes</param>
		/// <param name="returned_keyid">(out) buffer to store the key ID of the retrieved key</param>
		/// <param name="returned_keyidsize">(out) size of rkid buffer</param>
		/// <returns>0 on success|error code on failure</returns>
		[DllImport("kmclient.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int KMSGetKey(int handle,
										   string keyclass,
										   string keyid, [MarshalAs(UnmanagedType.LPArray)] byte[] Key,
										   int keysize,
										   ref int returned_keylength,
										   [MarshalAs(UnmanagedType.LPStr)] StringBuilder returned_keyid,
										   int returned_keyidsize);

		/// <summary>
		/// Retrieve the current key from the server (or cache) and encrypt the
		/// supplied data with that key
		/// </summary>
		/// <param name="handle">(in) KMS handle returned from KMSInit</param>
		/// <param name="keyclass">(in) Key class to retrieve the key from</param>
		/// <param name="clearText">(in) Data to be encrypted</param>
		/// <param name="clearLen">(in) Length of data to be encrypted</param>
		/// <param name="cipherText">(out) Buffer to store cipher text</param>
		/// <param name="cipherSize">(in) Size of buffer to store cipherText</param>
		/// <param name="cipherLen">(out) Length of generated cipher text</param>
		/// <param name="base64flag">(in) boolean to base64 encode output</param>
		/// <returns>0 on success|error code on failure</returns>
		[DllImport("kmclient.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int KMSEncryptData(int handle,
												[MarshalAs(UnmanagedType.LPStr)] string keyclass,
												[MarshalAs(UnmanagedType.LPArray)] byte[] clearText,
												int clearLen,
												[MarshalAs(UnmanagedType.LPArray)] byte[] cipherText,
												int cipherSize,
												ref int cipherLen,
												int base64flag);

		/// <summary>
		/// Retrieve the key from the server (or cache) that was used to encypt
		/// the data, and decrypt the supplied data with that key
		/// </summary>
		/// <param name="handle">(in) KMS handle returned from KMSInit</param>
		/// <param name="keyclass">(in) Key class to retrieve the key from</param>
		/// <param name="cipherText">(in) Data to be decrypted</param>
		/// <param name="cipherLen">(in) Length of data to be decrypted</param>
		/// <param name="clearText">(out) Buffer to store clear text</param>
		/// <param name="clearSize">(in) Size of buffer to store cipherText</param>
		/// <param name="clearLen">(out) Length of generated cipher text</param>
		/// <returns>0 on success|error code on failure</returns>
		[DllImport("kmclient.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int KMSDecryptData(int handle,
												[MarshalAs(UnmanagedType.LPStr)] string keyclass,
																						 [MarshalAs(UnmanagedType.LPArray)] byte[] cipherText,
												int cipherLen,
												[MarshalAs(UnmanagedType.LPArray)] byte[] clearText,
												int clearSize,
												ref int clearLen);

		/// <summary>
		/// HMAC the supplied data with a key that was retrieved 
		/// from the key server.
		/// </summary>
		/// <param name="handle">(in) KMS handle returned from KMSInit</param>
		/// <param name="keyClass">(in) Key class to retrieve the key from</param>
		/// <param name="keyID">(in) KeyID to of key to HMAC with (NULL for current key)</param>
		/// <param name="text">(in) text to encrypt</param>
		/// <param name="textLen">(in) length of text</param>
		/// <param name="hmac">(in/out) Output cipher text allocated by caller</param>
		/// <param name="hmacSize">(in) number of bytes allocated to cipherText</param>
		/// <param name="hmacLen">(out) length of output cipher text</param>
		/// <returns>0 on success|error code on failure</returns>
		[DllImport("kmclient.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int KMSHMACData(int handle,
											 [MarshalAs(UnmanagedType.LPStr)] string keyClass,
											 [MarshalAs(UnmanagedType.LPStr)] string keyID,
											 [MarshalAs(UnmanagedType.LPArray)] byte[] text,
											 int textLen,
											 [MarshalAs(UnmanagedType.LPArray)] byte[] hmac,
											 int hmacSize,
											 ref int hmacLen);

		/// <summary>
		/// Destroy the KMSHandle
		/// </summary>
		/// <param name="handle">(in) KMS handle returned from KMSInit</param>
		/// <returns>None</returns>
		[DllImport("kmclient.dll", CallingConvention = CallingConvention.Cdecl)]
		public static extern int KMSDestroy(int handle);
	}
}
