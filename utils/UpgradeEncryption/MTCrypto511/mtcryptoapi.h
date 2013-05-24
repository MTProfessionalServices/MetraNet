
#ifndef _MTCRYPTOAPI_H
#define _MTCRYPTOAPI_H

#ifdef WIN32
// only want this header brought in one time
#pragma once
#endif

#include <WTypes.h>
#include <wincrypt.h>
#include <stdio.h>
#include <string>
#include <vector>

#include <NTLogger.h>

#define MT_128_BIT_KEY 0x00800000

class CMTCryptoProvider;
class CMTCryptoSessionKey;
class CMTCryptoPublicKey;

/**
 * An object with memory of a single error.
 */

class CMTCryptoObjectWithError
{
public:
	/**
	 * Create an object with an empty error string.
	 */
	CMTCryptoObjectWithError();

	/**
	 * Returns the error string associated with the last error to occur in
	 * the object.  The caller is not to free the returned pointer.
	 * @return The error string 
	 */
	const char * GetCryptoApiErrorString();

protected:
	virtual ~CMTCryptoObjectWithError();
	/**
	 * Sets and logs the error string and returns the value of GetLastError().
	 */
	int SetCryptoApiErrorString(const char * chrErrorString);

	void CopyError(CMTCryptoObjectWithError * other);
	NTLogger mLogger;
private:
	void MTGetLastErrorString(TCHAR * atchBuf, int aintError, int aintLen);
	char m_chrErrorString[2048];
 
};

/**
 * Represents either a public key and cipher or a private/public key pair and
 * cipher.  A public/private key cipher can be used to encrypt and decrypt
 * a session key.  A public key cipher can only be used to encrypt a session
 * key.  The public or private/public key cannot be used to encrypt and decrypt
 * arbitrary data.  
 */
class CMTCryptoPublicKey : public CMTCryptoObjectWithError
{
public:

  /**
	 * Create a public key object
	 * @param pProv Cryptography provider in whose context the key lives.
	 */
	CMTCryptoPublicKey(CMTCryptoProvider * pProv) : m_pProv(pProv), m_hKey(NULL) {}
	~CMTCryptoPublicKey();

	int Initialize(HCRYPTKEY hKey);

  /**
	 * Decrypt a session key object that was encrypted with this public key.
	 * @param blob The buffer containing the encrypted data.
	 * @param pSessionKey A reference to a session key object into which to store
	 * the decrypted session key data.  This must be a non-null reference.
	 * @return 0 if sucessful.  Non-zero if not successful.
	 */
	int Unwrap(const std::string& blob, CMTCryptoSessionKey* pSessionKey);
	
  /**
	 * Encrypt a session key object with this public key.
	 * @param pSessionKey A reference to a session key object which to encrypt.
	 * This must be a non-null reference.
	 * @param blob The buffer in which to place the encrypted data.
	 * @return 0 if sucessful.  Non-zero if not successful.
	 */
	int Wrap(CMTCryptoSessionKey* pSessionKey, std::string& blob);
	
  /**
	 * Get the strength of the public key in bits.
	 * @param keylen Output parameter into which the keylen is placed.
	 * @return 0 if sucessful.  Non-zero if not successful.
	 */
	int GetKeyLength(unsigned long& keylen);

  /**
	 * Serialize the public key into a buffer.
	 * @param keylen Output buffer into which the exported key is placed.
	 * @return 0 if sucessful.  Non-zero if not successful.
	 */
	int ExportKey(std::string& blob);

 private:

	CMTCryptoProvider * m_pProv;

	HCRYPTKEY m_hKey;

	// Make this a friend function of CMTCryptoProvider.
	// We need the HCRYPTPROV to implement the Unwrap method
	HCRYPTPROV GetHandle(CMTCryptoProvider * pProv);
	// Make this a friend function of CMTCryptoSessionKey.
	// We need the HCRYPTKEY of the CMTCryptoSessionKey to 
	// implement the Wrap() method.
	HCRYPTKEY GetHandle(CMTCryptoSessionKey * pSessionKey);
};

/**
 * Represents a symmetric key and cipher.  Can be created
 * in two different ways.  Either the sesssion key can
 * be created by unwrapping an public key encrypted session
 * key buffer or the session key can be created from key
 * material (i.e. a password).
 *
 * In either case, the resulting initialized session key
 * object can be used to encrypt or decrypt arbitrary blocks of data.
 */
class CMTCryptoSessionKey : public CMTCryptoObjectWithError
{
public:
	CMTCryptoSessionKey(CMTCryptoProvider * pProv) : m_pProv(pProv), m_hSessionKey(NULL) {}
	virtual ~CMTCryptoSessionKey();

	/**
	 * Initialize the session key from an algorithm descriptor and key material (password)
	 * @param algId The algorithm descriptor string. 
	 * Valid algorithm descriptors are "RC2", "RC4", "DES", "3DES".
	 * @param asKeyMaterial The password from which the session key is generated.
	 * @param bGenerateIV If this is true then a random initialization vector is generated.  The
	 * default for this parameter is false.  This parameter is only relevant if the algorithm is
	 * a block cipher.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int Initialize(const std::string& algId, const std::string& asKeyMaterial, bool bGenerateIV=FALSE);

	/**
	 * Initialize the session key from a Win32 Session key handle.  The session key
	 * takes ownership of the handle.
	 * @param hSessionKey The Win32 session key with which to initialize the object.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int Initialize(HCRYPTKEY hSessionKey);
	/**
	 * Get the block length in bytes of session key.  For stream ciphers, the block
	 * length is 0.
	 * @param keylen Output parameter into which the block length is stored.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int GetBlockLength(unsigned long& keylen);
	
	/**
	 * Get the key length in bits of session key.  
	 * @param keylen Output parameter into which the key length is stored.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int GetKeyLength(unsigned long& keylen);

	/**
	 * This method encrypts data using the session key object and
	 * then uuencodes the resulting ciphertext
	 * @param plaintext On input this contains the plaintext to be
	 * encrypted.  On output it is overwritten with the uuencoded ciphertext.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int Encrypt(std::string& plaintext);
	/**
	 * This method encrypts data using the session key object 
	 * @param plaintext The plaintext to be
	 * encrypted.  
	 * @param ciphertext The output ciphertext.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int Encrypt(const std::string& plaintext, std::vector<unsigned char>& ciphertext);

	/**
	 * This method uudecodes and decrypts data using the session key object.  
	 * @param ciphertext On input this contains the ciphertext to be
	 * uudecoded and decrypted.  On output it is overwritten with the plaintext.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int Decrypt(std::string& ciphertext);
	/**
	 * This method encrypts data using the session key object 
	 * @param plaintext The plaintext to be
	 * encrypted.  
	 * @param ciphertext The output ciphertext.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int Decrypt(const std::vector<unsigned char>& ciphertext, std::string& plaintext);

private:
	// This is owned and managed by the session key instance
	HCRYPTKEY m_hSessionKey;

	// This is not owned by the session key instance; don't free it
	CMTCryptoProvider * m_pProv;

	// Call this method to validate that the algorithm is supported by the provider
	int CheckAlgorithmSupport(ALG_ID aiAlgId);

	// Map string parameter to Win32 ALG_ID
	int MapAlgorithm(const std::string& rwcEncryptionType, ALG_ID& aiAlgId);

public:
	/**
	 * This method encrypts data using the session key object.  
	 * @param pData On input, this is the plaintext data.  On output, this is the
	 * ciphertext data.  The ciphertext data is guaranteed to be as long as the plaintext
	 * and may be longer in the case that the underlying cipher is a block cipher.  If pData
	 * is NULL, then the method returns the length of the output buffer required to encrypt
	 * data of length *pDataLen.
	 * @param pDataLen On input, this is the length of the plaintext data in pData.  On
	 * output this is set to the length of the ciphertext data. If pData is NULL, then on
	 * output this contains the buffer length required to encrypt plaintext of length *pDataLen.
	 * @param lBufLen This is the length of the underlying buffer for pData.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int Encrypt(char * pData, long * pDataLen, long lBufLen);

  int Decrypt(char * pData, long * pDataLen);

private:
	// Make this a friend of CMTCryptoProvider.
	// We need the HCRYPTPROV handle to create a hash to build
	// the HCRYPTKEY from raw key material.
	HCRYPTPROV GetHandle(CMTCryptoProvider * pProv);

	// Break the encapsulation of the Win32 handle; CMTCryptoPublicKey can grab
	// my Win32 crypto handle (used to export or import a session key).  This
	// should only be called by CMTCryptoPublicKey::GetHandle
	HCRYPTKEY GetHandle();

	// CMTCryptoPublicKey needs to be able call CMTCryptoSessionKey::GetHandle
	// in order to perform implement its Wrap method.  
	friend CMTCryptoPublicKey;
};

/**
 * Provider of cryptographic services.  The cryptography provider is associated
 * which a key container which holds a two disinguished public/private key pairs.
 * The provider also supports the ability to create and manage additional public keys that
 * are deserialized from external representations.
 */
class CMTCryptoProvider : public CMTCryptoObjectWithError
{
public:
	CMTCryptoProvider();
	virtual ~CMTCryptoProvider();

	/**
	 * Bind the provider to a key container object.  The container for keys may
	 * either exist or not.  The method optionally creates the container if it
	 * does not exist.  If the object creates a key container on initialization,
	 * the container is treated as temporary and will be deleted when the object is destroyed.
	 * The underlying Win32 CryptoAPI provider is determined by reading the mtcrypto.xml
	 * configuration file.
	 * @param szContainerName The container of public keys. 
	 * @param bMachineKey ???
	 * @param bCreateKeyContainer Flag indicating whether the provider should create
	 * a temporary container if the named container doesn't exist. 
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int Initialize(const std::string& szContainerName, bool bMachineKey = false, bool bCreateKeyContainer = false);

	/**
	 * Delete the key container.  This method destroys the key container and all
	 * of the keys in it (including their image on disk).  It is not valid to call
	 * any methods on the object after it is Deleted.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int Delete();

	/**
	 * Get the version of the provider.  For the current implementation,
	 * this value should always be 0x0200.
	 * @param aulngVersion Output parameter into which the version is placed.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int GetProviderVersion(unsigned long& aulngVersion);

	/**
	 * Get the name of the key container the provider is associated with.
	 * This method returns the same name as the szContainerName parameter
	 * the provider was initialized with.
	 * @param aName Output parameter into which the name is placed.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int GetContainerName(std::string& aName);

	/**
	 * Get the signature public key in the container that
	 * the provider was initialized with.  The method fails if
	 * the key does not exist.
	 * @param pKey public key object which is initialized with the retrieved key.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int GetSignatureKey(CMTCryptoPublicKey * pKey);
	/**
	 * Get the exchange public key in the container that
	 * the provider was initialized with.  The method fails if
	 * the key does not exist.
	 * @param pKey public key object which is initialized with the retrieved key.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int GetExchangeKey(CMTCryptoPublicKey * pKey);

	/**
	 * Deserialize an external representation of a public key.
	 * @param blob Input buffer containing the serialized representation of the key.
	 * @param pKey public key object which is initialized with the retrieved key.  Must be
	 * non-null.
	 * @return 0 if successful.  Non-zero if not successful.
	 */
	int ImportKey(const std::string& blob, CMTCryptoPublicKey * pKey);

  /**
	 * Grant a user full access to the provider (container).
	 * @param username The NT user to whom we are granting access.  username can be
	 * a domain name ("domain\user") or a built-in group ("EVERYONE" or "GUEST").
	 * @return 0 if sucessful.  Non-zero if not successful.
	 */
	int GrantAccess(const std::string& username);

	static const char * GetProviderName();

private:
	// This is owned by the crypto provider class instance
	HCRYPTPROV m_hProv;

	// Break the encapsulation of the Win32 handle; the public and session keys can grab
	// my Win32 crypto handle
	HCRYPTPROV GetHandle();

	// Is this a machine key or not?
	bool m_bMachineKey;

	// Allow access to my Win32 handle to both the CMTCryptoPublicKey and
	// CMTCryptoSessionKey objects.  Many of the MS CryptoAPI functions
	// require an HCRYPTPROV in addition to a HCRYPTKEY.
  friend class CMTCryptoPublicKey; 
  friend class CMTCryptoSessionKey; 
};

class CMTCryptoAPI : public CMTCryptoObjectWithError
{
public:
  CMTCryptoAPI();
  virtual ~CMTCryptoAPI();

  // Null for default container, Machine wide or user based keys
  int Initialize(const std::string& szContainerName, bool bMachineKey, const std::string& szSource);

	/**
	 * Encrypt a string and then uuencode the resulting
	 * ciphertext.
	 * CMTCryptoAPI container and source.
	 * @param text On input, the text to be encrypted on output the encrypted/encoded text.
	 * @return 0 if successful, non-zero if not.
	 */
	int Encrypt(std::string& text);

	/*
	 * directly encrypt the buffer.  see CMTCryptoSessionKey::Encrypt for more details
	 */
	int Encrypt(char * pData, long * pDataLen, long lBufLen);

	/**
	 * Uudecode and decrypt a string 
	 * CMTCryptoAPI container and source.
	 * @param text On input, the uuencoded and encrypted ciphertext.  On output the uudecoded and decrypted
	 * plaintext.
	 * @return 0 if successful, non-zero if not.
	 */
	int Decrypt(std::string& plaintext);

	/*
	 * directly decrypt the buffer.  see CMTCryptoSessionKey::Decrypt for more details
	 */
  int Decrypt(char * pData, long * pDataLen);


  // Null for default container, Machine wide or user based keys
  int CreateKeys(
		const std::string& szContainerName,
		bool bMachineKey,
		const std::string& chrSource);
  int DeleteKeys(char * szContainerName, bool bMachineKey = false);

  /**
	 * This is used to upgrade a pre 3.5 crypto configuration to a 3.5 crypto configuration.
	 * Prior to 3.5, we had a separate container for each user that accessed the primary
	 * encryption keys (e.g. "listener" and "pipeline").  That really was unecessary because
	 * we are using machine keys.  Therefore in 3.5 we moved to having a single machine key
	 * for each function (e.g. the main "pipeline" key used for encrypting pipeline properties
	 * or the "dbaccess" key for encrypting passwords).  This function will initialize a 3.5
	 * container and will optionally "upgrade" it from 3.0 by moving any sessionkeys into the new
	 * RSA envelopes.  This method also creates a new set of RSA keys if needed and grants "EVERYONE" 
	 * access to the newly created container.
	 * @param container The container name of the new container (this will also be the "source" for the new container).
	 * @param oldcontainer The name of the container to upgrade.
	 * @param blobsuffix The suffix of the keyblob files (or "source") to upgrade.
	 * @return 0 if sucessful.  Non-zero if not successful.
	 */
	int CreateKeysAndUpgrade(const std::string& container, const std::string& oldcontainername, const std::string& blobsuffix);

	BOOL GrantKeyAccessRights(std::vector<std::string>& aUserList);
	void SetSource(const char* aSrc) { mSource = aSrc; }

private:
	void DumpExistingSecurityInfo(HCRYPTPROV hProv);

private:
	CMTCryptoProvider m_cpProvider;
	CMTCryptoPublicKey m_pkExchangeKey;
	CMTCryptoSessionKey m_skSessionKey;

  BOOL mblnSessionKeyInitialized;

	std::string mSource;
	std::string mContainerName;
	int InitializeSessionKey();

};

#endif // _MTCRYPTOAPI_H
