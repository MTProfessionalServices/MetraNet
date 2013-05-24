
#include "RsaKeyManagerClient.h"
#include "CryptoEngine.h"

#define KMS_BUFSIZE 1024
#define MTCM_CONST_KEY_ID_SEPARATOR '|'


///////////////////////////////////////////////////////////////////////////////

static bool
ParseHashField(const string& inData,string& outKeyId,string& outHash)
{
	bool isOk = false;
	if(inData.empty())
		return isOk;

	try
	{
		StringTokenizer tokenizer(inData, "|");

		if(2 == tokenizer.count())
		{
			outKeyId = tokenizer[0];
			outHash = tokenizer[1];
			isOk = true;
		}
	}
	catch(Exception& x)
	{
		stringstream ss;
		ss << __FUNCTION__;
		ss << " : ";
		ss <<  x.displayText();
		Application::instance().logger().error(ss.str());
	}

	return isOk;
}

static bool
Base64Encode(const string& inData,string& outData)
{
	bool isOk = false;
	if(inData.empty())
		return isOk;

	try
	{
		ostringstream ostr(outData);
		Base64Encoder encoder(ostr);
		
		encoder << inData;
		encoder.close();

		if(encoder.good())
			isOk = true;
	}
	catch(Exception& x)
	{
		stringstream ss;
		ss << __FUNCTION__;
		ss << " : ";
		ss <<  x.displayText();
		Application::instance().logger().error(ss.str());
	}

	return isOk;
}

static bool
Base64Decode(const char* pInData,string& outData)
{
	bool isOk = false;
	if(NULL == pInData)
		return isOk;

	try
	{
		istringstream istr(pInData);
		Base64Decoder decoder(istr);
		
		decoder >> outData;

		if(decoder.good())
			isOk = true;
	}
	catch(Exception& x)
	{
		stringstream ss;
		ss << __FUNCTION__;
		ss << " : ";
		ss <<  x.displayText();
		Application::instance().logger().error(ss.str());
	}

	return isOk;
}

///////////////////////////////////////////////////////////////////////////////

CRsaKeyManagerClient::CRsaKeyManagerClient(const string& cfgFileName,
										   const string& clientCertPassword,
										   const string& rsaPiNumberKeyClass,
										   const string& rsaPiHashKeyClass,
										   const string& rsaPassKeyClass)
{
	if(cfgFileName.empty())
		throw Exception("Missing RSA KM Client config file");

	try
	{
		m_rsaPiNumberKeyClass = rsaPiNumberKeyClass.empty() ? "CreditCardNumber" : rsaPiNumberKeyClass;
		m_rsaPiHashKeyClass = rsaPiHashKeyClass.empty() ? "PaymentInstHash" : rsaPiHashKeyClass;
		m_rsaPassKeyClass = rsaPassKeyClass.empty() ? "PasswordHash" : rsaPassKeyClass;

		m_logger.information() << "Start initializing RSA Key Manager Client" << endl;

		int status = m_nativeClient.Initialize(cfgFileName.c_str(), 
			clientCertPassword.c_str());
		if (status  != KMS_SUCCESS) 
		{
			stringstream ss;
			ss << "Failed to initialize KM client: Error code = ";
			ss << status;
			throw Exception(ss.str());
		}

		//KCQ NOTE:
		//RSA Key Manager Client will terminate the host process if it doesn't like the configurations passed to it.
		//If this application dies and the logging message below is not shown in the log file
		//the termination was most likely caused by the RSA Key Manager Client initialization code.
		m_logger.information() << "Done initializing RSA Key Manager Client" << endl;

		//Check the key classes:
		string keyId;
		string key;
		if(GetCurrentKeyWithClass(m_rsaPiNumberKeyClass,keyId,key))
		{
			m_logger.information() << "RSA Key Manager Client: KeyClass=" << m_rsaPiNumberKeyClass << " KeyId=" << keyId  << endl;
		}
		else
		{
			m_logger.warning() << "RSA Key Manager Client: Could not find keys for KeyClass=" << m_rsaPiNumberKeyClass << endl;
		}
		keyId = "";
		if(GetCurrentKeyWithClass(m_rsaPiHashKeyClass,keyId,key))
		{
			m_logger.information() << "RSA Key Manager Client: KeyClass=" << m_rsaPiHashKeyClass << " KeyId=" << keyId  << endl;
		}
		else
		{
			m_logger.warning() << "RSA Key Manager Client: Could not find keys for KeyClass=" << m_rsaPiHashKeyClass << endl;
		}
		keyId = "";
		if(GetCurrentKeyWithClass(m_rsaPassKeyClass,keyId,key))
		{
			m_logger.information() << "RSA Key Manager Client: KeyClass=" << m_rsaPassKeyClass << " KeyId=" << keyId  << endl;
		}
		else
		{
			m_logger.warning() << "RSA Key Manager Client: Could not find keys for KeyClass=" << m_rsaPassKeyClass << endl;
		}
	}
	catch(exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " << x.what() << endl;
		throw;
	}
}

CRsaKeyManagerClient::~CRsaKeyManagerClient()
{
	m_nativeClient.Shutdown();
}

bool 
CRsaKeyManagerClient::GetCurrentKeyWithClass(const string& className,string& id,string& key)
{
	bool isOk = false;

    unsigned char keyBuf[KMS_BUFSIZE] = { NULL };
    char          rKeyID[KMS_BUFSIZE] = { NULL };

    char* keyID = NULL;
    unsigned int  keyLen = 0;

	const char* keyClass = className.c_str();
	int status = m_nativeClient.GetKey(keyClass, keyID, keyBuf, sizeof(keyBuf), &keyLen, 
                            rKeyID, sizeof(rKeyID));
	if (KMS_SUCCESS == status) 
	{
		id.append(rKeyID);
		key.append((const char*)keyBuf,keyLen);

		isOk = true;
	}
	else
	{
		m_logger.error() << __FUNCTION__ << " : KMS error status = " << status << endl;
	}

	return isOk;
}

bool 
CRsaKeyManagerClient::GetCurrentPasswordHashKey(string& id,string& key)
{
	return GetCurrentKeyWithClass(m_rsaPassKeyClass,id,key);
}

bool 
CRsaKeyManagerClient::GetCurrentCcNumberKey(string& id,string& key)
{
	return GetCurrentKeyWithClass(m_rsaPiNumberKeyClass,id,key);
}

bool 
CRsaKeyManagerClient::GetCurrentCcNumberHashKey(string& id,string& key)
{
	return GetCurrentKeyWithClass(m_rsaPiHashKeyClass,id,key);
}

bool 
CRsaKeyManagerClient::EncryptCcNumber(const string& inData,string& outData)
{
	bool isOk = false;

	if(inData.empty())
		return isOk;

	unsigned char encryptedData[KMS_BUFSIZE] = { NULL };
	unsigned int  encryptedDataLen = 0;

	const char* keyClass = m_rsaPiNumberKeyClass.c_str();
	int status = m_nativeClient.EncryptData(keyClass,
								 (unsigned char *)inData.c_str(), 
								 (unsigned int)inData.length(),
                                 encryptedData, sizeof(encryptedData), 
                                 &encryptedDataLen, 
								 TRUE);
	if (KMS_SUCCESS == status) 
	{
		outData.append((const char*)encryptedData,encryptedDataLen);
		isOk = true;
	}
	else
	{
		m_logger.error() << __FUNCTION__ << " : KMS error status = " << status << endl;
	}

	return isOk;
}

bool 
CRsaKeyManagerClient::DecryptCcNumber(const string& inData,string& outData)
{
	bool isOk = false;

	if(inData.empty())
		return isOk;

	unsigned char decryptedData[KMS_BUFSIZE] = { NULL };
	unsigned int  decryptedDataLen = 0;

	const char* keyClass = m_rsaPiNumberKeyClass.c_str();
	int status = m_nativeClient.DecryptData(keyClass,
								 (unsigned char *)inData.c_str(), 
								 (unsigned int)inData.length(),
                                 decryptedData, sizeof(decryptedData), 
                                 &decryptedDataLen);
	if (KMS_SUCCESS == status) 
	{
		outData.append((const char*)decryptedData,decryptedDataLen);
		isOk = true;
	}
	else
	{
		m_logger.error() << __FUNCTION__ << " : KMS error status = " << status << endl;
	}

	return isOk;
}


bool 
CRsaKeyManagerClient::HashCcNumber(const string& inData,string& outData)
{
	return HashCcNumberWithKey("",inData,outData);
}

bool 
CRsaKeyManagerClient::HashCcNumberWithKey(const string& id,const string& inData,string& outData)
{
	bool isOk = false;

	if(inData.empty())
		return isOk;

    unsigned char hmacBuf[KMS_BUFSIZE] = { NULL };
    unsigned int  hmacLen = 0;
	string kid;

	const char* keyId = id.empty() ? NULL : id.c_str();
	if(NULL == keyId)
	{
		string key;
		if(!GetCurrentCcNumberHashKey(kid,key))
			return isOk;

		keyId = kid.empty() ? NULL : kid.c_str();
	}
	else
	{
		//verify that the given key id is valid:
		if(!VerifyCcNumberKey(id))
			return isOk;
	}

	//Generate CC md5 and then hash it with the CC again

	//NOTE:
	//The generated hash is correct, but in some testing
	//scenarios between the generated hash and the original hash
	//when it should have been the same. It's still possible
	//that we ended up using a new hashing key though.

	MD5Engine md5;
	md5.update(inData);
	string toHash = DigestEngine::digestToHex(md5.digest());
	toHash.append(inData);

	const char* keyClass = m_rsaPiHashKeyClass.c_str();
	int status = m_nativeClient.HMACData(keyClass, keyId,
								(unsigned char *)toHash.c_str(), 
								(unsigned int)toHash.length(),
								hmacBuf, sizeof(hmacBuf),
								&hmacLen, 
								TRUE);//base64 encode result

	if (KMS_SUCCESS == status) 
	{
		//NOTE:
		//The result is already base64 encoded, but the product code we emitate
		//base64 encodes the data again
		string b64Hash;
		if(CCryptoEngine::ToBase64((const char*)hmacBuf,hmacLen,b64Hash))
		{
			if(!b64Hash.empty())
			{
				outData.append(keyId);
				outData += MTCM_CONST_KEY_ID_SEPARATOR;
				outData.append(b64Hash);
				isOk = true;
			}
		}
	}
	else
	{
		m_logger.error() << __FUNCTION__ << " : KMS error status = " << status << endl;
	}

	return isOk;
}

bool 
CRsaKeyManagerClient::VerifyCcNumberKey(const string& id)
{
	return VerifyKeyWithClass(m_rsaPiNumberKeyClass,id);
}

bool 
CRsaKeyManagerClient::VerifyKeyWithClass(const string& className,const string& id)
{
	bool isOk = false;
	if(className.empty() || id.empty())
		return isOk;

    unsigned char keyBuf[KMS_BUFSIZE] = { NULL };
    char          rKeyID[KMS_BUFSIZE] = { NULL };
    unsigned int  keyLen = 0;

	int status = m_nativeClient.GetKey(className.c_str(), id.c_str(), keyBuf, sizeof(keyBuf), &keyLen, 
                            rKeyID, sizeof(rKeyID));
	if (KMS_SUCCESS == status) 
	{
		isOk = true;
	}
	else
	{
		m_logger.error() << __FUNCTION__ << " : KMS error status = " << status << endl;
	}

	return isOk;
}

bool 
CRsaKeyManagerClient::EncryptPassword(const string& inData,string& outData)
{
	if(inData.empty())
		return false;

	return EncryptCcNumber(inData,outData);
}

bool 
CRsaKeyManagerClient::DecryptPassword(const string& inData,string& outData)
{
	if(inData.empty())
		return false;

	return DecryptCcNumber(inData,outData);
}

