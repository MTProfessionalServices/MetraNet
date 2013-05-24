

#include <metra.h>
#include <mtcom.h>
#include <mtprogids.h>
#include <base64.h>
#include <vector>
#include <ConfigDir.h>
#include <ACLAPI.H>
#include <mtglobal_msg.h>
#include <loggerconfig.h>

#import "MTConfigLib.tlb"

//static ComInitialize sComInitialize;

#include "mtcryptoapi.h"


CMTCryptoObjectWithError::CMTCryptoObjectWithError()
{
	m_chrErrorString[0] = '\0';
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[MTCrypto]");
}

CMTCryptoObjectWithError::~CMTCryptoObjectWithError()
{
}

const char *
CMTCryptoObjectWithError::GetCryptoApiErrorString()
{
  return m_chrErrorString;
}

int 
CMTCryptoObjectWithError::SetCryptoApiErrorString(const char * chrErrorString)
{
  char  chrBuf[512];
  TCHAR tchErrBuf[256];
  tchErrBuf[0] = '\0';
	DWORD dwLastError = GetLastError();
  sprintf(chrBuf, chrErrorString);
  MTGetLastErrorString(tchErrBuf, dwLastError, 256);
  sprintf((char *)m_chrErrorString, "Error message: %s: %s\n", chrErrorString, tchErrBuf);

	mLogger.LogThis(LOG_ERROR, m_chrErrorString);

  return (int) dwLastError;
}

void
CMTCryptoObjectWithError::MTGetLastErrorString(TCHAR * atchBuf, int aintError, int aintLen)
{

  FormatMessage(
    FORMAT_MESSAGE_FROM_SYSTEM,
    NULL,
    aintError,
    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
    (LPTSTR) atchBuf,
    aintLen,
    0);

  return;
}

void
CMTCryptoObjectWithError::CopyError(CMTCryptoObjectWithError * other)
{
	const char * err = other->GetCryptoApiErrorString();
	strcpy(m_chrErrorString, err);
}


CMTCryptoAPI::CMTCryptoAPI() : 
	m_cpProvider(), m_pkExchangeKey(&m_cpProvider), m_skSessionKey(&m_cpProvider),
	mblnSessionKeyInitialized(FALSE)
//, mbIsErrorMessageSet(false)
{
}

CMTCryptoAPI::~CMTCryptoAPI()
{
}

int CMTCryptoAPI::Initialize(const std::string& szContainerName, bool bMachineKey, const std::string& szSource)
{
	mContainerName = szContainerName;
	mSource = szSource;
	int result=0;
	result = m_cpProvider.Initialize(szContainerName, bMachineKey, false);
	result = m_cpProvider.GetExchangeKey(&m_pkExchangeKey);
	return 0;
}

int CMTCryptoAPI::Decrypt(std::string& ciphertext)
{
	int result;
	
	if (0 != (result=InitializeSessionKey())) return result;

	result = m_skSessionKey.Decrypt(ciphertext);
	if (result != 0)
		CopyError(&m_skSessionKey);
	return result;
}

int CMTCryptoAPI::Decrypt(char * pData, long * pDataLen)
{
	int result;
	
	if (0 != (result=InitializeSessionKey())) return result;

	result = m_skSessionKey.Decrypt(pData, pDataLen);
	if (result != 0)
		CopyError(&m_skSessionKey);
	return result;
}

int CMTCryptoAPI::Encrypt(std::string& plaintext)
{
	int result;
	
	if (0 != (result=InitializeSessionKey())) return result;
	
	result = m_skSessionKey.Encrypt(plaintext);
	if (result != 0)
		CopyError(&m_skSessionKey);
	return result;
}

int CMTCryptoAPI::Encrypt(char * pData, long * pDataLen, long lBufLen)
{
	int result;
	
	if (0 != (result=InitializeSessionKey())) return result;

	result = m_skSessionKey.Encrypt(pData, pDataLen, lBufLen);
	if (result != 0)
		CopyError(&m_skSessionKey);
	return result;
}

class KeyBlobFile : public CMTCryptoObjectWithError
{
protected:
	virtual const char * GetFilePrefix() const = 0;
public:
	int GetFileName(const std::string& mSource, std::string& filename);
	int Read(const std::string& mSource, std::string& sBlob);
	int Write(const std::string& mSource, const std::string& sBlob);
	int Exists(const std::string& mSource, bool& bExists);
};

int KeyBlobFile::GetFileName(const std::string& mSource, std::string& filename)
{
	if (!GetMTConfigDir(filename))
	{
		return SetCryptoApiErrorString("Unable to get MetraTech configuration directory");
	}

	filename += "ServerAccess\\";
	filename += GetFilePrefix();

	if(mSource.size() > 0) {
		filename +=  "_";
		filename +=  mSource.c_str();
	}

	return 0;
}

int KeyBlobFile::Read(const std::string& mSource, std::string& sBlob) 
{
	  FILE * hBlob;
	  DWORD  dwKeyBlobLen;
	  BYTE * pbKeyBlob;

	  std::string rwcConfigDir;

		int result;
		if((result = GetFileName(mSource, rwcConfigDir)) != 0) return result;

		mLogger.LogVarArgs(LOG_DEBUG, "Opening keyblob file %s for reading", rwcConfigDir.c_str());

	  // Open source file.
	  if(!(hBlob = fopen((char *)rwcConfigDir.c_str(), "rb"))) 
    {
      // file not in use
      // return 0;
 
      char chrBuf[256];
      sprintf(chrBuf, "Unable to open file: %s", (char *)rwcConfigDir.c_str());
    
		  SetLastError(MT_ERR_BAD_CONFIG);
      return SetCryptoApiErrorString(chrBuf);
    }

	  fread(&dwKeyBlobLen, sizeof(DWORD), 1, hBlob); 
	  if(ferror(hBlob) || feof(hBlob))
    {
      return SetCryptoApiErrorString("Unable to read session key blob length");
    }

    if(!(pbKeyBlob = (BYTE *)malloc(dwKeyBlobLen)))
    {
      return SetCryptoApiErrorString("Unable to allocate memory for session key blob");
    }

    fread(pbKeyBlob, 1, dwKeyBlobLen, hBlob); 
    if(ferror(hBlob) || feof(hBlob))
    {  
      free(pbKeyBlob);
      return SetCryptoApiErrorString("Unable to read session key blob");
    }

	  fclose(hBlob);

		sBlob= std::string((char *)pbKeyBlob, dwKeyBlobLen);

    free(pbKeyBlob);

		return 0;
}

int KeyBlobFile::Write(const std::string& mSource, const std::string& sBlob) 
{
	FILE * hPublicKeyBlobFile = 0;
	int intReturnCode = 0;
	std::string rwcConfigDir;

	int result;
	if((result = GetFileName(mSource, rwcConfigDir)) != 0) return result;

  //
  // now, write it to file
  //

	mLogger.LogVarArgs(LOG_DEBUG, "Opening keyblob file %s for writing", rwcConfigDir.c_str());

	if(!(hPublicKeyBlobFile = fopen((char *)rwcConfigDir.c_str(), "wb+"))) 
  { 
    char chrBuf[1024];

    sprintf(
      chrBuf,
      "Unable to open public key blob file: %s",
      (const char *)rwcConfigDir.c_str());

    intReturnCode = SetCryptoApiErrorString(chrBuf);
    goto Done;
  } 
  
	DWORD dwPublicKeyBlobLen = sBlob.size();
	DWORD dwNumWritten = 0;
  dwNumWritten = fwrite((const void *)&dwPublicKeyBlobLen, sizeof(DWORD), 1, hPublicKeyBlobFile); 

  if (dwNumWritten < 1)
  { 
    char chrBuf[1024];

    sprintf(
      chrBuf,
      "Unable to write length of public key blob to file: %s",
      (const char *)rwcConfigDir.c_str());

    intReturnCode = SetCryptoApiErrorString(chrBuf);
    goto Done;
  } 

  dwNumWritten = 0;
  dwNumWritten = fwrite(sBlob.c_str(), 1, dwPublicKeyBlobLen, hPublicKeyBlobFile); 

  if (dwNumWritten < dwPublicKeyBlobLen)
  { 
    char chrBuf[1024];

    sprintf(
      chrBuf,
      "Unable to write public key blob to file: %s",
      (const char *)rwcConfigDir.c_str());

    intReturnCode = SetCryptoApiErrorString(chrBuf);
  } 

Done:

	if(hPublicKeyBlobFile) fclose(hPublicKeyBlobFile);
	return intReturnCode;
}

int KeyBlobFile::Exists(const std::string& mSource, bool& bExists)
{
	FILE * hBlob;
	std::string rwcConfigDir;
	
	int result;
	if((result = GetFileName(mSource, rwcConfigDir)) != 0) return result;

	// Open source file.
	if(!(hBlob = fopen((char *)rwcConfigDir.c_str(), "rb"))) 
	{
		bExists = false;
	}
	else
	{
		fclose(hBlob);
		bExists = true;
	}

	return 0;
}

class SessionKeyBlobFile : public KeyBlobFile
{
protected:
	const char * GetFilePrefix() const
	{
		return "sessionkeyblob";
	}
};

class PublicKeyBlobFile : public KeyBlobFile
{
protected:
	const char * GetFilePrefix() const
	{
		return "publickeyblob";
	}
};

int CMTCryptoAPI::InitializeSessionKey()
{
  if (!mblnSessionKeyInitialized)
  {
	  //
    // Import the session key
	  //
		SessionKeyBlobFile file;
		std::string sBlob;
		int result;
		if((result = file.Read(mSource, sBlob)) != 0) return result;
		if((result = m_pkExchangeKey.Unwrap(sBlob, &m_skSessionKey)) != 0) return result;
 
    mblnSessionKeyInitialized = TRUE;
  }
	return 0;
}

int CMTCryptoAPI::CreateKeys(const std::string& szContainerName, bool bMachineKey, const std::string& chrSource)
{
	PublicKeyBlobFile pfile;
	bool bExists;
	int intReturnCode;

	mSource = chrSource;
	std::string container(szContainerName);

	if((intReturnCode = pfile.Exists(mSource, bExists)) != 0) return intReturnCode;

	// If the file exists, we do nothing
	if (bExists)
	{
		CMTCryptoProvider p;
		if(p.Initialize(container, true, false) != 0)
		{
			std::string filename;
			pfile.GetFileName(container, filename);
			std::string error;
			error += "Failed to open the key container named '";
			error += container.c_str();
			error += "', when there is a public key file '";
			error += filename.c_str();
			error += "'.  This may indicate that the keys exist but have been corrupted or that permissions are improperly set.  ";
			error += "Check the keys in your Cryptographic Service Provider.";
			SetLastError(CORE_ERR_CRYPTO_FAILURE);
			return SetCryptoApiErrorString(error.c_str());
		}
		return 0;
	}

	// The file didn't exist so let's create a new container and RSA keys.  Be
	// generous and give everyone access; the customer will need to
	// lock this down prior to deployment.
	CMTCryptoProvider provider;
	if((intReturnCode = provider.Initialize(container, true, true)) != 0) return intReturnCode;
	if((intReturnCode = provider.GrantAccess("EVERYONE")) != 0) return intReturnCode;

	// Just for kicks log a warning that the container was created with EVERYONE
	// permissions
	mLogger.LogVarArgs(LOG_WARNING, "Cryptographic key container '%s' was created with EVERYONE access.  "
										 "Before putting a system into production, set proper permissions on the container", container.c_str());

	CMTCryptoPublicKey exchange (&provider);
	if((intReturnCode = provider.GetExchangeKey(&exchange)) != 0) return intReturnCode;
	CMTCryptoPublicKey signature (&provider);
	if((intReturnCode = provider.GetSignatureKey(&signature)) != 0) return intReturnCode;

	// Write the public key to disk.
	std::string publickeyblob;
	if((intReturnCode = exchange.ExportKey(publickeyblob)) != 0) return intReturnCode;
	if((intReturnCode = pfile.Write(mSource, publickeyblob)) != 0) return intReturnCode;

  return intReturnCode;
}

int CMTCryptoAPI::DeleteKeys(char * szContainerName, bool bMachineKey)
{
	ASSERT(szContainerName);
	CMTCryptoProvider provider;
	int result;
	if((result = provider.Initialize(szContainerName, bMachineKey, false)) != 0) return result;
	if((result = provider.Delete()) != 0) return result;
	
  return 0;
}

int CMTCryptoAPI::CreateKeysAndUpgrade(const std::string& container, 
																			 const std::string& oldcontainername, 
																			 const std::string& blobsuffix)
{
	int result;
	if((result = CreateKeys(container, true, container)) != 0) return result;

	// Onto the upgrade part of our story.  First check to see if a session key
	// exists for the new container.  If so, skip the whole upgrade process.
	SessionKeyBlobFile sfile;
	bool bExists;
	if((result = sfile.Exists(container, bExists)) != 0) return result;
	if(bExists)
	{
		std::string sessionblobfilename;
		sfile.GetFileName(container, sessionblobfilename);
		mLogger.LogVarArgs(LOG_INFO, "Container '%s' already has session key file '%s'; upgrade skipped",
											 container.c_str(),
											 sessionblobfilename.c_str());
		return 0;
	}

	// Open up the new container and get its exchange key.
	// Let's open up the old container and its session key blob file,
	// so that we may convert it to the new container.
	CMTCryptoProvider provider;
	if((result = provider.Initialize(container, true, false)) != 0) return result;
	CMTCryptoPublicKey exchange (&provider);
	if((result = provider.GetExchangeKey(&exchange)) != 0) return result;

	std::string sessionblob;
	if((result = sfile.Read(blobsuffix, sessionblob)) != 0) 
	{
		std::string sessionblobfilename;
		sfile.GetFileName(blobsuffix, sessionblobfilename);
		mLogger.LogVarArgs(LOG_INFO, "No session key blob file '%s' found; upgrade skipped.  "
											 "You must create new session keys for the container '%s'.", 
											 sessionblobfilename.c_str(),
											 container.c_str());
		return 0;
	}

	CMTCryptoProvider old;
	if((result = old.Initialize(oldcontainername, true, false)) != 0) return result;
	CMTCryptoPublicKey oldexchange(&old);
	if((result = old.GetExchangeKey(&oldexchange)) != 0) return result;
	CMTCryptoSessionKey oldsession(&old);
	if((result = oldexchange.Unwrap(sessionblob, &oldsession)) != 0) return result;

	// Write out the session key wrapped in the new container's key.
	// The algorithm for this is a little complicated since MS doesn't
	// directly support exporting a plaintext session key.  What we do
	// is take the public key blob of the new container and import it into
	// the old one.  Then we export the session key using the imported copy
	// of the new container's public key.  This exported session key can then
	// be imported into the new container!
	// Step1: Import the "new" container's exchange RSA key into the "old" container.
	PublicKeyBlobFile pfile;
	std::string publickeyblob;
	if((result = pfile.Read(container, publickeyblob)) != 0) return result;
	CMTCryptoPublicKey exchangecopy(&old);
	if((result = old.ImportKey(publickeyblob, &exchangecopy)) != 0) return result;

	// Step 2: Export(wrap) the session key from the old container using the new container's key
	if((result = exchangecopy.Wrap(&oldsession, sessionblob)) != 0) return result;

	// Step 3: Import(unwrap) the session key into the new container.
	// To be honest, these last steps are unnecessary.  The result of unwrap/wrap
	// should be an identity transformation!  Maybe it is a good idea to go through
	// the motions just to make sure everything is cool.
	if((result = exchange.Unwrap(sessionblob, &oldsession)) != 0) return result;
	CMTCryptoSessionKey session(&provider);
	if((result = exchange.Wrap(&oldsession, sessionblob)) != 0) return result;
		
	// Step 4: Finally write out the converted session blob. And there was much rejoicing...
	if((result = sfile.Write(container, sessionblob)) != 0) return result;

	return result;
}

BOOL CMTCryptoAPI::GrantKeyAccessRights(std::vector<std::string>& aUserList)
{
	CMTCryptoProvider provider;
	int result;
	// Assume machine key; this is ugly but harmless, cause we won't work any other way!!!
	if((result = provider.Initialize(mContainerName, true, false)) != 0) return result;
	for(std::vector<std::string>::iterator it = aUserList.begin();it != aUserList.end();it++) 
	{
		if((result = provider.GrantAccess(*it)) != 0) return FALSE;
	}
	return TRUE;
}



int CMTCryptoSessionKey::MapAlgorithm(const std::string& sEncryptionType, ALG_ID& aiAlgId)
{
	//
	// Convert the encryption type to a Win32 ALG_ID
	//
	//rwcEncryptionType.toUpper();
	if (sEncryptionType == "RC2")
	{
		aiAlgId = CALG_RC2;
	}
	else if (sEncryptionType == "RC4")
	{
		aiAlgId = CALG_RC4;
	}
	else if (sEncryptionType == "RC5")
	{
		aiAlgId = CALG_RC5;
	}
	else if (sEncryptionType == "DES")
	{
		aiAlgId = CALG_DES;
	}
	else if (sEncryptionType == "3DES")
	{
		aiAlgId = CALG_3DES;
	} 
	else
	{
		// TODO: how to make this a valid error code
		SetLastError(CORE_ERR_CRYPTO_FAILURE);
		return SetCryptoApiErrorString("Unknown encryption type string");
	}
	return 0;
}

CMTCryptoSessionKey::~CMTCryptoSessionKey()
{
	if (m_hSessionKey != NULL) CryptDestroyKey(m_hSessionKey);
}

int CMTCryptoSessionKey::CheckAlgorithmSupport(ALG_ID aiAlgId)
{
	DWORD rc = 0;
	int result = 0;
	DWORD dwEnumAlgsLen = 0;
	BYTE *pbEnumAlgs = NULL;

	DWORD dwFlags = CRYPT_FIRST;
	
	// This grabs the maximum algorithm descriptor size from CryptoAPI.
	// Use the return value to allocate the descriptor buffer for entire
	// iteration.
	if(!CryptGetProvParam(GetHandle(m_pProv), PP_ENUMALGS, NULL, &dwEnumAlgsLen, dwFlags))
	{
		rc = SetCryptoApiErrorString("Win32 Error getting algorithm descriptor size from Cryptography Provider");
		goto Done;
	}
	pbEnumAlgs = new BYTE [dwEnumAlgsLen];

	// Win32 crypto enumeration initialization setting
	dwFlags = CRYPT_FIRST;
	do
	{
		if(CryptGetProvParam(GetHandle(m_pProv), PP_ENUMALGS, pbEnumAlgs, &dwEnumAlgsLen, dwFlags))
		{
			// No longer the first iteration
			dwFlags = 0;
			if (((PROV_ENUMALGS *)pbEnumAlgs)->aiAlgid == aiAlgId)
			{
				// Found the algorithm; bail out.
				break;
			}
		}
		else
		{
			if (ERROR_NO_MORE_ITEMS == GetLastError())
			{
				rc = SetCryptoApiErrorString("Chosen encryption algorithm not supported by encryption provider");
				goto Done;
			}
			else
			{
				rc = SetCryptoApiErrorString("Win32 Error Listing Cryptography Provider algorithms");
				goto Done;
			}
		}
	} while (1);
 Done:

	delete [] pbEnumAlgs;

	return rc;
}

int CMTCryptoSessionKey::Initialize(HCRYPTKEY hSessionKey)
{
	ASSERT(hSessionKey != NULL);
	m_hSessionKey = hSessionKey;
	return 0;
}

int CMTCryptoSessionKey::Initialize(const std::string& algId,
																		const std::string& asKeyMaterial, 
																		bool bGenerateIV)
{
	HCRYPTHASH hHash = NULL;
	BYTE * pbRandomData = NULL;
	DWORD rc = 0;
	unsigned long keylen = 0;

	// Map into Win32 algorithm
	ALG_ID aiAlgId;
	int result;
	if (0 != (result=MapAlgorithm(algId, aiAlgId)))
	{
		return result;
	}

	// Check that this algorithm is supported by the crypto provider
	if (0 != (result=CheckAlgorithmSupport(aiAlgId)))
	{
		return result;
	}


	// For backward compatibility, we use MD5 for RC4 and
	// SHA for others;  note that SHA is a 20 byte hash, thus
	// is more appropriate for 3DES in particular.

	// Create a hash
	if(!CryptCreateHash(GetHandle(m_pProv), aiAlgId == CALG_RC4 ? CALG_MD5 : CALG_SHA, 0, 0, &hHash)) 
  {
		rc = SetCryptoApiErrorString("Failed to allocate hash function");
		goto Done;
  }

	// Hash the passord
	if(!CryptHashData(hHash, (BYTE *)asKeyMaterial.data(), asKeyMaterial.length(), 0))
  {
		rc = SetCryptoApiErrorString("Failed to hash the password");
		goto Done;
  }

	// Create a session key based on the hash of the password.
	
	if(!CryptDeriveKey(GetHandle(m_pProv), aiAlgId, hHash, CRYPT_EXPORTABLE, &m_hSessionKey)) 
  {
		rc = SetCryptoApiErrorString("Failed to create the session key from hashed password");
		goto Done;
  }

  //
  // If we are using a block cipher, then we hard code CBC mode and generate
	// an initialization vector from random 
	keylen=0;
	if (0 != (rc=GetBlockLength(keylen)))
	{
		goto Done;
	}

	// Crypto API says that stream ciphers will return 0 block length
	if (keylen > 0 && TRUE == bGenerateIV)
	{
		// Generate one block worth of random stuff for initialization
		// Convert keylen from bits to bytes.
		DWORD dwRandomDataLen = keylen/8;
		pbRandomData = new BYTE [dwRandomDataLen];
		if(!CryptGenRandom(GetHandle(m_pProv), dwRandomDataLen, pbRandomData))
		{
			rc = SetCryptoApiErrorString("Unable to generate random initialization vector");
			goto Done;
		}
	
		if(!CryptSetKeyParam(m_hSessionKey, KP_IV, (BYTE *)&pbRandomData, 0))
		{
			rc = SetCryptoApiErrorString("Unable to set initialization vector of session key");
			goto Done;
		}

		DWORD dwMode = CRYPT_MODE_CBC;
		if(!CryptSetKeyParam(m_hSessionKey, KP_MODE, (BYTE *)&dwMode, 0))
		{
			rc = SetCryptoApiErrorString("Unable to set chaining mode of session key");
			goto Done;
		}
	}

 Done:

	CryptDestroyHash(hHash);

	return (int) rc;
}

int CMTCryptoSessionKey::GetKeyLength(unsigned long& keylen)
{
  DWORD dwBufLen = sizeof(keylen);

  if(!CryptGetKeyParam(m_hSessionKey, KP_KEYLEN, (BYTE *)&keylen, &dwBufLen, 0))
  {
		return SetCryptoApiErrorString("Failed to get key length of session key");
  }
	return 0;
}

int CMTCryptoSessionKey::GetBlockLength(unsigned long& keylen)
{
  DWORD dwBufLen = sizeof(keylen);

  if(!CryptGetKeyParam(m_hSessionKey, KP_BLOCKLEN, (BYTE *)&keylen, &dwBufLen, 0))
  {
		return SetCryptoApiErrorString("Failed to get block length of session key");
  }
	return 0;
}

HCRYPTKEY CMTCryptoSessionKey::GetHandle() 
{
	return m_hSessionKey;
}

HCRYPTPROV CMTCryptoSessionKey::GetHandle(CMTCryptoProvider * pProv)
{
	ASSERT(pProv);
	return pProv->GetHandle();
}


int CMTCryptoSessionKey::Encrypt(char * pData, long * pDataLen, long lBufLen)
{
  if (!CryptEncrypt(m_hSessionKey, NULL, TRUE, 0, 
	                (BYTE *)pData, (unsigned long *)pDataLen, lBufLen))
  {
    return SetCryptoApiErrorString("Unable to encrypt using the session key");
  }

  return 0;
}

int CMTCryptoSessionKey::Encrypt(const std::string& plaintext, std::vector<unsigned char>& ciphertext)
{
	// Find the size of the buffer required to encode
	int result = 0;
	long lBufLen = plaintext.size();
	if (0 != (result=Encrypt(NULL, &lBufLen, lBufLen)))
	{
		return result;
	}	
	
	// Create the encode buffer and initialize with the plaintext
	unsigned char * pData = new unsigned char [lBufLen];
	long lDataLen = plaintext.size();
	memcpy(pData, plaintext.data(), lDataLen);

	if (0 != (result=Encrypt((char *)pData, &lDataLen, lBufLen)))
	{
		delete [] pData;
		return result;
	}

	// If this isn't true, then Win32 lies...
	ASSERT(lDataLen = lBufLen);

	// Stuff the encoded data into the ciphertext
	ciphertext.clear();
	ciphertext.reserve(lBufLen);
	for(int i=0; i<lBufLen; i++)
	{
		ciphertext.push_back(pData[i]);
	}

	delete [] pData;

  return result;
}

int CMTCryptoSessionKey::Encrypt(std::string& plaintext)
{
	// Find the size of the buffer required to encode
	int result = 0;
	long lBufLen = plaintext.size();
	if (0 != (result=Encrypt(NULL, &lBufLen, lBufLen)))
	{
		return result;
	}	
	
	// Create the encode buffer and initialize with the plaintext
	unsigned char * pData = new unsigned char [lBufLen];
	long lDataLen = plaintext.size();
	memcpy(pData, plaintext.data(), lDataLen);

	if (0 != (result=Encrypt((char *)pData, &lDataLen, lBufLen)))
	{
		delete [] pData;
		return result;
	}

	ASSERT(lDataLen == lBufLen);

	if (FALSE == rfc1421encode(pData, lDataLen, plaintext))
	{
		// This really is an unknown error, since the current rfc1421encode
		// cannot fail.
		SetLastError(CORE_ERR_CRYPTO_FAILURE);
		result = SetCryptoApiErrorString("Unable to uuencode encrypted text");
	}

	delete [] pData;

  return result;
}

int CMTCryptoSessionKey::Decrypt(char * pData, long * pDataLen)
{
	ASSERT(pData != NULL && pDataLen != NULL);

  if (!CryptDecrypt(m_hSessionKey, NULL, TRUE, 0, 
	                  (BYTE *)pData, (unsigned long *)pDataLen))
  {
    return SetCryptoApiErrorString("Unable to decrypt using the session key");
  }

  return 0;
}

int CMTCryptoSessionKey::Decrypt(const std::vector<unsigned char>& ciphertext, std::string& plaintext)
{
	// Move data into a non-const buffer that we can modify
	int result = 0;
	long lCipherTextLen = 0;
	unsigned char * pData = NULL;

	lCipherTextLen = ciphertext.size();
	pData = new unsigned char [lCipherTextLen];
	std::vector<unsigned char>::const_iterator it = ciphertext.begin();
	unsigned char * pTemp = pData;
	while (it != ciphertext.end())
	{
		*pTemp++ = *it++;
	}
	pTemp = 0;

	if (0 != (result=Decrypt((char *)pData, &lCipherTextLen))) 
	{
		delete [] pData;
		return result;
	}

	// Move the buffer into the string; this is one more copy than I'd
	// like to see but I don't want to side-effect the string buffer!
	plaintext.assign((char *)pData, lCipherTextLen);

	delete [] pData;

  return result;
}

int CMTCryptoSessionKey::Decrypt(std::string& ciphertext)
{
	// Move data into a non-const buffer that we can modify
	int result = 0;
	std::vector<unsigned char> dest;

	if(ERROR_NONE != rfc1421decode(ciphertext.data(), ciphertext.size(), dest))
	{
		SetLastError(CORE_ERR_CRYPTO_FAILURE);
		return SetCryptoApiErrorString("Unable to uudecode encrypted text");
	}

	if (0 != (result=Decrypt(dest, ciphertext)))
	{
		return result;
	}

  return result;
}

CMTCryptoProvider::CMTCryptoProvider() : m_hProv(NULL)
{
}

CMTCryptoProvider::~CMTCryptoProvider()
{
	// Release the context
	if (m_hProv)
	{
		CryptReleaseContext(m_hProv, 0);
	}
}

int CMTCryptoProvider::Delete()
{
	if (m_hProv == NULL)
	{
		SetLastError(CORE_ERR_CRYPTO_FAILURE);
		return SetCryptoApiErrorString("Cannot call CMTCryptoProvider::Delete on incorrectly initialized instance");
	}

	const char * chrProvider = GetProviderName();

	if (NULL == chrProvider)
	{
		SetLastError(MT_ERR_BAD_CONFIG);
		return SetCryptoApiErrorString("Unable to open file: mtcrypto.xml");
	}
	else
	{
		std::string containerName;
		if (0 == GetContainerName(containerName))
		{
			// value returned by CryptAcquireContext when passing in CRYPT_DELETEKEYSET
			// is undefined.
			DWORD dwFlags = CRYPT_DELETEKEYSET;
			if (m_bMachineKey)
			{
				dwFlags |= CRYPT_MACHINE_KEYSET;
			}

			HCRYPTPROV tempProvider;
			if(!CryptAcquireContext(&tempProvider,
															containerName.c_str(),
															chrProvider,
															PROV_RSA_FULL,
															dwFlags))
			{
				return SetCryptoApiErrorString("Failed to delete container");
			}

			CryptReleaseContext(m_hProv, 0);
			m_hProv = NULL;
		}
	}
	return 0;
}

int CMTCryptoProvider::Initialize(const std::string& szContainerName, bool bMachineKey, bool bAllocateContainer)
{
  const char * chrProvider = GetProviderName();

  if (NULL == chrProvider)
  {
    SetLastError(MT_ERR_BAD_CONFIG);
    return SetCryptoApiErrorString("Unable to open file: mtcrypto.xml");
  }

	m_bMachineKey = bMachineKey;

	DWORD dwFlags = m_bMachineKey ? CRYPT_MACHINE_KEYSET : 0;
  // Attempt to acquire a handle to the key container.
  if(!CryptAcquireContext(&m_hProv,
                          szContainerName.c_str(),
                          chrProvider,
                          PROV_RSA_FULL,
                          dwFlags))
	{
		if (bAllocateContainer)
		{
			dwFlags |= CRYPT_NEWKEYSET;
			if(!CryptAcquireContext(&m_hProv,
															szContainerName.c_str(),
															chrProvider,
															PROV_RSA_FULL,
															dwFlags))
			{
				return SetCryptoApiErrorString("Unable to allocate context");
			}
		}
		else
		{
			return SetCryptoApiErrorString("Unable to acquire context");
		}
	}
	return 0;
}

HCRYPTPROV CMTCryptoProvider::GetHandle()
{
	return m_hProv;
}

int CMTCryptoProvider::GetProviderVersion(unsigned long& aulngVersion)
{
	if (m_hProv == NULL)
	{
		SetLastError(CORE_ERR_CRYPTO_FAILURE);
		return SetCryptoApiErrorString("Cannot call CMTCryptoProvider::GetProviderVersion on incorrectly initialized instance");
	}

  DWORD dwBufLen = sizeof(aulngVersion);

  if(!CryptGetProvParam(m_hProv, PP_VERSION, (BYTE *)&aulngVersion, &dwBufLen, 0)) 
  {
		return SetCryptoApiErrorString("Failed to get version of CSP");
  }
	return 0;
}

int CMTCryptoProvider::GetContainerName(std::string& aName)
{
	if (m_hProv == NULL)
	{
		SetLastError(CORE_ERR_CRYPTO_FAILURE);
		return SetCryptoApiErrorString("Cannot call CMTCryptoProvider::GetContainerName on incorrectly initialized instance");
	}

	DWORD cbData=0;
	DWORD rc=0;
	TCHAR * chrBuf = NULL;

  // Get the buffer size for the name
  if(!CryptGetProvParam(m_hProv, PP_CONTAINER, NULL, &cbData, 0)) 
  {
		rc = SetCryptoApiErrorString("Failed to get container name length");
    goto Done;
  }

	chrBuf = new TCHAR [cbData];

	// Get the name and copy into the argument
  if(!CryptGetProvParam(m_hProv, PP_CONTAINER, (BYTE *)chrBuf, &cbData, 0)) 
  {
		rc = SetCryptoApiErrorString("Failed to get container name");
    goto Done;
  }

	aName.assign(chrBuf);

Done:

	delete [] chrBuf;

	return rc;
}

int CMTCryptoProvider::GetSignatureKey(CMTCryptoPublicKey* pKey)
{
	if (m_hProv == NULL)
	{
		SetLastError(CORE_ERR_CRYPTO_FAILURE);
		return SetCryptoApiErrorString("Cannot call CMTCryptoProvider::GetSignatureKey on incorrectly initialized instance");
	}

	ASSERT(pKey);
	HCRYPTKEY hPrivateKey=NULL;

	// Get the private key
  if(!CryptGetUserKey(m_hProv, AT_SIGNATURE, &hPrivateKey)) 
	{
    if(GetLastError()==NTE_NO_KEY) 
    {
      //
      // The key does not exist, so create the pair.
      //
      if(!CryptGenKey(m_hProv, AT_SIGNATURE, 0 /*MT_128_BIT_KEY*/, &hPrivateKey)) 
      {
        return SetCryptoApiErrorString("Unable to generate signature key pair");
      } 
    } 
		else
		{
			return SetCryptoApiErrorString("Unable to get signature key");
		}
	}

	pKey->Initialize(hPrivateKey);

	return 0;
}

int CMTCryptoProvider::GetExchangeKey(CMTCryptoPublicKey* pKey)
{
	if (m_hProv == NULL)
	{
		SetLastError(CORE_ERR_CRYPTO_FAILURE);
		return SetCryptoApiErrorString("Cannot call CMTCryptoProvider::GetExchangeKey on incorrectly initialized instance");
	}

	ASSERT(pKey);
	HCRYPTKEY hPrivateKey=NULL;

	// Get the private key
  if(!CryptGetUserKey(m_hProv, AT_KEYEXCHANGE, &hPrivateKey)) 
	{
    if(GetLastError()==NTE_NO_KEY) 
    {
      //
      // The key does not exist, so create the pair.
      //
      if(!CryptGenKey(m_hProv, AT_KEYEXCHANGE, 0 /*MT_128_BIT_KEY*/, &hPrivateKey)) 
      {
        return SetCryptoApiErrorString("Unable to generate exchange key pair");
      } 
    } 
		else
		{
			return SetCryptoApiErrorString("Unable to get exchange key");
		}
	}

	pKey->Initialize(hPrivateKey);

	return 0;
}

int CMTCryptoProvider::ImportKey(const std::string& blob, CMTCryptoPublicKey * pKey)
{
	if (m_hProv == NULL)
	{
		SetLastError(CORE_ERR_CRYPTO_FAILURE);
		return SetCryptoApiErrorString("Cannot call CMTCryptoProvider::ImportKey on incorrectly initialized instance");
	}

	ASSERT(pKey);
	HCRYPTKEY hKey;
	if (!CryptImportKey(m_hProv, (BYTE *)blob.data(), blob.size(), NULL, 0, &hKey))
	{
		return SetCryptoApiErrorString("Unable to import public key");
	}
	return pKey->Initialize(hKey);
}
	
int CMTCryptoProvider::GrantAccess(const std::string& aUser)
{
	BOOL bResult;
	PACL pNewDACL = NULL;
	PSECURITY_DESCRIPTOR pSec = NULL;
	int result = CORE_ERR_CRYPTO_FAILURE;

	do {
		// step 1: create a SECURITY_DESCRIPTOR
		SECURITY_DESCRIPTOR aSecDesc;
		InitializeSecurityDescriptor(&aSecDesc,SECURITY_DESCRIPTOR_REVISION);

		unsigned long aLen = 1024;
		BOOL aDaclPresent,aDaclDefaulted;
		PACL pAcl;
		
		// step 2: get the length of the security descriptor.
		bResult = CryptGetProvParam(m_hProv,PP_KEYSET_SEC_DESCR,NULL,&aLen,
																DACL_SECURITY_INFORMATION);
		
		if(!bResult) {
			SetCryptoApiErrorString("CryptGetProvParam failed to get DACL length:"); break;
		}

		pSec = (PSECURITY_DESCRIPTOR)new char[aLen];

		// step 3: get the current security descriptor for the key store.  This usually has a bunch
		// of existing permissions set by the crypto API.  We are only requisting the DACL

		bResult = CryptGetProvParam(m_hProv,PP_KEYSET_SEC_DESCR,(unsigned char*)pSec,&aLen,
																DACL_SECURITY_INFORMATION);

		if(!bResult) {
			SetCryptoApiErrorString("CryptGetProvParam failed to get DACL:"); break;
		}

		// step 4: get the DACL from the security descriptor.  WooHoo!! aren't we having fun.
		bResult = GetSecurityDescriptorDacl(pSec,&aDaclPresent,&pAcl,&aDaclDefaulted);
		if(!aDaclPresent) {
			SetCryptoApiErrorString("DACL not present in SECURITY_DESCRIPTOR: "); break;
		}

		// step 4.5: get the SID for "Everyone"
		// Specify the DACL to use.
		// Create a SID for the Everyone group.
		PSID pSIDEveryone = NULL;
		SID_IDENTIFIER_AUTHORITY SIDAuthWorld = SECURITY_WORLD_SID_AUTHORITY;
		if (!AllocateAndInitializeSid(&SIDAuthWorld,			// Top-level SID authority
																	1,									// Number of subauthorities
																	SECURITY_WORLD_RID,	// Subauthority value
																	0,
																	0, 
																	0, 
																	0, 
																	0, 
																	0, 
																	0,
																	&pSIDEveryone // SID returned as OUT parameter
																	)) 
		{
			SetCryptoApiErrorString("AllocateAndInitializeSid (Everyone) error:"); 
			printf("AllocateAndInitializeSid (Everyone) error %u\n", GetLastError());
			break;
    }

		// step 5: add the user to add to the DACL granting full control.
		EXPLICIT_ACCESS eaList;
		ZeroMemory(&eaList, sizeof(EXPLICIT_ACCESS));
		eaList.grfAccessPermissions = 0x10000000; // this corresponds to FULL_CONTROL
		eaList.grfAccessMode = GRANT_ACCESS;
		eaList.grfInheritance= CONTAINER_INHERIT_ACE;
		eaList.Trustee.TrusteeForm = TRUSTEE_IS_SID;
		eaList.Trustee.ptstrName = (LPTSTR) pSIDEveryone;
		
		// step 6: add the new entries and get back a new ACL.  This ACL must be freed by LocalFree
		DWORD dwRes = SetEntriesInAcl(1 ,&eaList, pAcl, &pNewDACL);
		if(ERROR_SUCCESS != dwRes)  {
			SetCryptoApiErrorString("SetEntriesInAcl error: "); break;
		}

		// step 7: set the new ACL in the security descriptor.
		bResult = SetSecurityDescriptorDacl(&aSecDesc,TRUE,pNewDACL,FALSE);
		if(!bResult) {
			SetCryptoApiErrorString("SetSecurityDescriptorDacl failed: "); break;
		}
		// step 8: put Humpty Dumpty back together.  I think this essentially corresponds to RegSetKeySecurity.
		bResult = CryptSetProvParam(m_hProv,PP_KEYSET_SEC_DESCR,(unsigned char*)&aSecDesc,DACL_SECURITY_INFORMATION);
		if(!bResult) {
			SetCryptoApiErrorString("CryptSetProvParam failed:"); break;
		}

		// step 9: Success!
		result = 0;

	} while(false);

	// step 10: clean up our mess.
	if(pNewDACL) {
		::LocalFree(pNewDACL);
	}
	if(pSec) {
		delete [] ((char *) pSec);
	}

	return result;
}

const char *
CMTCryptoProvider::GetProviderName()
{
  static char chrProvider[512];
  // Hardcoding the provider for legacy 5.1.1 value as mtcrypto.xml has a new value in 6.0.1
  sprintf(chrProvider, "Microsoft Enhanced Cryptographic Provider v1.0");
	return chrProvider;
  
  /*static BOOL blnInitialized = FALSE;

  if (!blnInitialized)
  {
    //
    // get the provider name
    //

    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

    _bstr_t bstrConfigFile;

    std::string rwcConfigDir;
    if (!GetMTConfigDir(rwcConfigDir))
    {
			// TODO: this never seems to get used
///      SetCryptoApiErrorString("Unable to read config directory from the registry");
      return NULL;
    }

    bstrConfigFile = rwcConfigDir.c_str();
    bstrConfigFile += "\\ServerAccess";
    bstrConfigFile += "\\mtcrypto.xml";

    VARIANT_BOOL flag;

    MTConfigLib::IMTConfigPropSetPtr propset = config->ReadConfiguration(bstrConfigFile, &flag);

    // get the config data ...
    MTConfigLib::IMTConfigPropSetPtr cpsConfigData;

    try
    {
      _bstr_t bstrProvider = propset->NextStringWithName("provider");
      sprintf(chrProvider, (const char *)bstrProvider);
	  }
	  catch (_com_error)
	  {
			/// TODO: this never seems to get used
///      CMTCryptoAPI::SetCryptoApiErrorString("Unable to read provider name from config file"); 
      return NULL;
	  }

    blnInitialized = TRUE;
  }

  return (const char *)chrProvider;
  */
}


CMTCryptoPublicKey::~CMTCryptoPublicKey()
{
	if (m_hKey != NULL)
	{
		CryptDestroyKey(m_hKey);
		m_hKey = NULL;
	}
}

int CMTCryptoPublicKey::Initialize(HCRYPTKEY hKey)
{
	m_hKey = hKey;
	return 0;
}

int CMTCryptoPublicKey::Unwrap(const std::string& blob, CMTCryptoSessionKey* pSessionKey)
{
	ASSERT(pSessionKey != NULL);

	HCRYPTKEY hSessionKey = NULL;

	BLOBHEADER * pBlobHeader = (BLOBHEADER *)blob.data();
	if (pBlobHeader->bType != SIMPLEBLOB) 
	{
		SetLastError(CORE_ERR_CRYPTO_FAILURE);
		return SetCryptoApiErrorString("Invalid session key blob");
	}
	ASSERT(pBlobHeader->bVersion == 0x02);
	ASSERT(pBlobHeader->reserved == 0x0000);
	
	if (!CryptImportKey(GetHandle(m_pProv), (BYTE *)blob.data(), blob.size(), m_hKey, CRYPT_EXPORTABLE, &hSessionKey))
	{
		return SetCryptoApiErrorString("Unable to import session key. Make sure your crypto settings are correct.");
	}

	pSessionKey->Initialize(hSessionKey);
	return 0;
}
 
int CMTCryptoPublicKey::Wrap(CMTCryptoSessionKey* pSessionKey, std::string& blob)
{
	ASSERT(pSessionKey != NULL);

	DWORD dwSessionBlobLen;
	BYTE * pbSessionKeyBlob=NULL;
	DWORD rc = 0;
  // Determine the size of the public key BLOB and allocate memory.
  if(!CryptExportKey(GetHandle(pSessionKey), m_hKey, SIMPLEBLOB, 0, NULL, &dwSessionBlobLen))
  {
    rc = SetCryptoApiErrorString("Unable to get blob length for session key");
    goto Done;
  }

  if((pbSessionKeyBlob = (BYTE *)malloc(dwSessionBlobLen)) == NULL)
  { 
    rc = SetCryptoApiErrorString("Cannot allocate memory for session key blob");
    goto Done;
  }

  // Export the key into a public key BLOB.
  if(!CryptExportKey(GetHandle(pSessionKey), m_hKey, SIMPLEBLOB, 0, pbSessionKeyBlob, &dwSessionBlobLen))
  {
    rc = SetCryptoApiErrorString("Cannot export session key blob");
    goto Done;
  }

	blob.assign((char *) pbSessionKeyBlob, dwSessionBlobLen);

 Done:
	if(pbSessionKeyBlob != NULL) free(pbSessionKeyBlob);

	return rc;
}
 
int CMTCryptoPublicKey::GetKeyLength(unsigned long& aKeylen)
{
  DWORD dwBufLen = sizeof(aKeylen);
	
  if(!CryptGetKeyParam(m_hKey, KP_BLOCKLEN, (BYTE *)&aKeylen, &dwBufLen, 0))
  {
		return SetCryptoApiErrorString("Unable to get public key length");
  }

	return 0;
}

int CMTCryptoPublicKey::ExportKey(std::string& asBlob)
{
	BYTE * pbPublicKeyBlob=NULL;
	DWORD dwPublicKeyBlobLen=0;

  // Determine the size of the public key BLOB and allocate memory.
  if(!CryptExportKey(m_hKey, NULL, PUBLICKEYBLOB, 0, NULL, &dwPublicKeyBlobLen))
  {
    return SetCryptoApiErrorString("Unable to get blob length for public key");
  }

  if((pbPublicKeyBlob = (BYTE *)malloc(dwPublicKeyBlobLen)) == NULL)
  { 
    return SetCryptoApiErrorString("Unable to get memory for public key blob");
  }

  // Export the key into a public key BLOB.
  if(!CryptExportKey(m_hKey, NULL, PUBLICKEYBLOB, 0, pbPublicKeyBlob, &dwPublicKeyBlobLen))
  {
    int err = SetCryptoApiErrorString("Unable to export public key blob");
		if (pbPublicKeyBlob) free(pbPublicKeyBlob);
    return err;
  }
	
	asBlob.assign((char *)pbPublicKeyBlob, dwPublicKeyBlobLen);

	return 0;
}

HCRYPTPROV CMTCryptoPublicKey::GetHandle(CMTCryptoProvider * apProv)
{
	ASSERT(apProv);
	return apProv->GetHandle();
}


HCRYPTKEY CMTCryptoPublicKey::GetHandle(CMTCryptoSessionKey * apSessionKey)
{
	ASSERT(apSessionKey);
	return apSessionKey->GetHandle();
}
