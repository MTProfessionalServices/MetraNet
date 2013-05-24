#ifndef _INCLUDE_CRYPTO_ENGINE_H_
#define _INCLUDE_CRYPTO_ENGINE_H_

#include "AppObject.h"

class CCryptoEngine : public CAppObject
{
public:
	CCryptoEngine();
	virtual ~CCryptoEngine();

	static bool FromHexString(const string& inData,string& outData);
	static bool ToHexString(const string& inData,string& outData);
	static bool ToHexString(const char* inData,size_t inDataSize,string& outData);

	static bool FromBase64(const char* inData,size_t inDataSize,string& outData);
	static bool FromBase64(const string& inData,string& outData);
	static bool ToBase64(const string& inData,string& outData);
	static bool ToBase64(const char* inData,size_t inDataSize,string& outData);

	static bool ToSha256Hash(const string& inData,string& outData);

	bool HasKey();
	bool GenerateKey();

	bool GetKeyAsHexString(string& keyValue,string& keyIv);
	bool GetKeyRaw(string& keyValue,string& keyIv);

	bool SetKeyAsHexString(const string& keyValue,const string& keyIv);
	bool SetKeyRaw(const string& keyValue,const string& keyIv);

	bool Encrypt(const string& inData,string& outData,bool hexEncode = false);
	bool Encrypt(const char* inBuf,size_t inBufSize,string& outData,bool hexEncode = false);

	bool Decrypt(const string& inData,string& outData,bool hexEncoded = false);
	bool Decrypt(const char* inBuf,size_t inBufSize,string& outData,bool hexEncoded = false);
private:
	string m_keyValue;
	string m_keyIv;
};

#endif


