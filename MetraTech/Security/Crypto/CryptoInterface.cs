using System;
using System.Runtime.InteropServices;

namespace MetraTech.Security.Crypto
{
	#region Enums
	/// <summary>
	///   Specifies the hash key class
	/// </summary>
	[Guid("6BF6131A-FF74-45ae-BAF8-63F00F23FBED")]
	public enum CryptoProvider
	{
		/// <summary>
		///   RSA
		/// </summary>
		RSA,
		/// <summary>
		///   Microsoft
		/// </summary>
		Microsoft,
		/// <summary>
		///   Unknown
		/// </summary>
		Unknown
	}

	/// <summary>
	///   Specifies the crypto key class
	/// </summary>
	[Guid("A19AF917-398E-4e46-820D-7572DD7D76AB")]
	public enum CryptKeyClass
	{
		/// <summary>
		///   PaymentInstrument
		/// </summary>
		PaymentInstrument,
		/// <summary>
		///   DatabasePassword
		/// </summary>
		DatabasePassword,
		/// <summary>
		///   ServiceDefProp
		/// </summary>
		ServiceDefProp,
		/// <summary>
		///   Ticketing
		/// </summary>
		Ticketing,
		/// <summary>
		///   QueryString
		/// </summary>
		QueryString,
		/// <summary>
		///		WorldPay
		/// </summary>
		WorldPayPassword
	}

	/// <summary>
	///   Specifies the hash key class
	/// </summary>
	[Guid("09F8C1E0-0403-4dd1-8E09-82F1AB4A3C61")]
	public enum HashKeyClass
	{
		/// <summary>
		///   PasswordHash
		/// </summary>
		PasswordHash,
		/// <summary>
		///   PaymentMethodHash
		/// </summary>
		PaymentMethodHash
	}

	#endregion

	#region ICryptoManager Interface
	/// <summary>
	///   ICryptoManager
	/// </summary>
	[Guid("C6A3447C-6BEB-4a49-B070-E9778C4E1735")]
	public interface ICryptoManager
	{
		/// <summary>
		///   The crypto provider specified in the security configuration file
		/// </summary>
		CryptoProvider CryptoProvider { get; }

		/// <summary>
		///   Encrypt the given plainText based on the specified CryptKeyClass.
		///   The encrypted string will have the KMS key id prepended to it.
		/// </summary>
		/// <param name="keyClass"></param>
		/// <param name="plainText"></param>
		/// <returns></returns>
		string Encrypt(CryptKeyClass keyClass, string plainText);

		/// <summary>
		///   Decrypt the given cipherText based on the specified CryptKeyClass.
		///   The cipherText string must have the KMS key id prepended to it.
		/// </summary>
		/// <param name="keyClass"></param>
		/// <param name="cipherText"></param>
		/// <returns></returns>
		string Decrypt(CryptKeyClass keyClass, string cipherText);

		/// <summary>
		///   Hash the given plainText based on the specified HashKeyClass.
		///   The cipherText string will have the KMS key id prepended to it.  
		/// </summary>
		/// <param name="keyClass"></param>
		/// <param name="plainText"></param>
		/// <returns></returns>
		string Hash(HashKeyClass keyClass, string plainText);

		/// <summary>
		///   Hash the given plainText based on the specified HashKeyClass, and key ID.
		///   The cipherText string will have the KMS key id prepended to it.  
		/// </summary>
		/// <param name="keyClass"></param>
		/// <param name="keyID"></param>
		/// <param name="plainText"></param>
		/// <returns></returns>
		string HashWithKey(HashKeyClass keyClass, string keyID, string plainText);

		/// <summary>
		///   Return true if the hash of the given plainText matches the specified hash.
		///   The hash string will have the KMS key id prepended to it.  
		/// </summary>
		/// <param name="keyClass"></param>
		/// <param name="hash"></param>
		/// <param name="plainText"></param>
		/// <returns></returns>
		bool CompareHash(HashKeyClass keyClass, string hash, string plainText);

		/// <summary>
		/// Return the key used create the hash.
		/// </summary>
		/// <param name="hashString"></param>
		/// <returns></returns>
		string ParseKeyFromHash(string hashString);

		/// <summary>
		/// used from the installer to free RSA handle and unlock kms.cache file
		/// Handle was made static for performance reason
		/// </summary>
		void FreeHandles();
	}
	#endregion

	#region ICryptoSetup Interface
	/// <summary>
	///   Methods for setting up session keys and encrypting passwords for
	///   the Microsoft crypto implementation. Replaces Crypto.vbs.
	/// </summary>
	[Guid("6D66AB98-11F9-4c50-8D2A-99FD1D9E9CE9")]
	public interface IMSCryptoSetup
	{
		/// <summary>
		///   Create one session key for each key class. 
		///   If the given password is empty (or null), a hardcoded password is used. Otherwise, the specified password is used.
		///   Existing keys, if any, are deleted. 
		///   Output is generated in RMP\config\security\sessionkeys.xml.
		/// </summary>
		/// <param name="password"></param>
		void CreateSessionKeys(string password);

		/// <summary>
		///    Create a session key for the specified key class based on the specified password. 
		///    The existing keys for the specified keyclass will be deleted. 
		/// </summary>
		/// <param name="keyClassName"></param>
		/// <param name="password"></param>
		void CreateKey(string keyClassName, string password);

		/// <summary>
		///    Create a session key for the specified key class based on the specified password and identifier.
		///    If makeCurrent is true, the key will be made the current key for the given key class.
		/// </summary>
		/// <param name="keyClassName"></param>
		/// <param name="password"></param>
		/// <param name="id"></param>
		/// <param name="makeCurrent"></param>
		void AddKey(string keyClassName, string password, Guid id, bool makeCurrent);

		/// <summary>
		///    Make the key specified by the given id to be the current key.
		/// </summary>
		/// <param name="id"></param>
		void MakeKeyCurrent(Guid id);

		/// <summary>
		///   Delete the sessionkeys.xml file from RMP\config\security.
		/// </summary>
		void DeleteSessionKeys();

	}

	/// <summary>
	///   Methods for setting up session keys and encrypting passwords for
	///   the Microsoft crypto implementation. Replaces Crypto.vbs.
	/// </summary>
	[Guid("7E2175D9-C048-4f09-A7C5-CD05B104DE8A")]
	public interface ICryptoInstall
	{
		/// <summary>
		///    KeyClassNames
		/// </summary>
		object[] KeyClassNames { get; }

		/// <summary>
		///    (1) Generate the sessionkeys.xml file in RMP\config\security based on keyClassKeys
		///    (2) Set the contents of cryptoTypeName in RMP\config\security\mtsecurity.xml to MetraTech.Security.Crypto.MSCryptoManager
		/// </summary>
		/// <param name="keyClassNames"></param>
		/// <param name="keyClassKeys"></param>
		/// <param name="setDefaultCryptoTypeName"></param>
		void GenerateSessionKeys(object[] keyClassNames, object[] keyClassKeys, bool setDefaultCryptoTypeName);

		/// <summary>
		///    (1) Update RMP\config\security\mtsecurity.xml 
		///      	Set cryptoTypeName to MetraTech.Security.Crypto.RSACryptoManager
		///       	Set kmsIdentityGroup to the value of identityGroup
		///      	Encrypt the clientCertPassword using DPAPI and set kmsCertificatePwd to the encrypted value.
		///
		///    (2) Update RMP\config\security\key.cfg
		///       	Set the value of kms.sslPKCS12File to clientCertPath
		///         Set the value of kms.address to kmsServer
		///      	  Set the value of kms.logFile to the correct path for RMP\config\security
		///      	  Set the value of kms.cacheFile to the correct path for RMP\config\security
		/// 
		///    (3) Encrypt the passwords in the config files if encryptPasswords is set to true.
		/// </summary>
		/// <param name="kmsServer"></param>
		/// <param name="clientCertificateFile"></param>
		/// <param name="clientCertificatePwd"></param>
		/// <param name="mtKeyClassNames"></param>
		/// <param name="kmsKeyClassNames"></param>
		/// <param name="ticketingKey"></param>
		/// <param name="encryptPasswords"></param>
		void UpdateKMSConfig(string kmsServer,
							 string clientCertificateFile,
							 string clientCertificatePwd,
							 object[] mtKeyClassNames,
							 object[] kmsKeyClassNames,
							 string ticketingKey,
							 bool encryptPasswords);
	}
	#endregion
}
