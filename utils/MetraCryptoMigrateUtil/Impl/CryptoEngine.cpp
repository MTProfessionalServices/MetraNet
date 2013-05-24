
#include "CryptoEngine.h"
#include "IncludeCryptopp.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static bool 
GenerateKeyValue(string& keyValue)
{
	string part1 = IntToString(time(NULL));

	AutoSeededRandomPool rng;
	string part2 = "";
	RandomNumberSource(rng,AES::MAX_KEYLENGTH,true,new StringSink( part2 ));
	part2.append(part1);

	string part3 = UUIDGenerator::defaultGenerator().createRandom().toString();
	part3.append(part2);

	SecByteBlock result(AES::MAX_KEYLENGTH);

	SHA256 sha256;
	StringSource(part3,true,new HashFilter(sha256, new ArraySink(result.BytePtr(),result.SizeInBytes())));
	
	keyValue.append((const char*)result.BytePtr(),result.SizeInBytes());
	return true;
}

static bool 
GenerateKeyIv(string& keyIv)
{
	string part1 = IntToString(time(NULL));

	AutoSeededRandomPool rng;
	string part2 = "";
	RandomNumberSource(rng,AES::BLOCKSIZE,true,new StringSink( part2 ));
	part2.append(part1);

	string part3 = UUIDGenerator::defaultGenerator().createRandom().toString();
	part3.append(part2);

	SecByteBlock result(AES::BLOCKSIZE);

	RIPEMD128 md128;
	StringSource(part3,true,new HashFilter(md128, new ArraySink(result.BytePtr(),result.SizeInBytes())));

	keyIv.append((const char*)result.BytePtr(),result.SizeInBytes());
	return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

CCryptoEngine::CCryptoEngine()
{
}

CCryptoEngine::~CCryptoEngine()
{
	const char* pInfo = m_keyValue.data();
	size_t infoSize = m_keyValue.size();
	if((NULL != pInfo) && (0 != infoSize))
		SecureZeroMemory((void*)pInfo,infoSize);

	pInfo = m_keyIv.data();
	infoSize = m_keyIv.size();
	if((NULL != pInfo) && (0 != infoSize))
		SecureZeroMemory((void*)pInfo,infoSize);
}

bool 
CCryptoEngine::ToHexString(const string& inData,string& outData)
{
	bool isOk = false;

	StringSource(inData, true, new HexEncoder(new StringSink(outData)));
	isOk = true;

	return isOk;
}

bool 
CCryptoEngine::ToHexString(const char* inData,size_t inDataSize,string& outData)
{
	bool isOk = false;

	StringSource((const byte*)inData,inDataSize, true, new HexEncoder(new StringSink(outData)));
	isOk = true;

	return isOk;
}

bool 
CCryptoEngine::FromHexString(const string& inData,string& outData)
{
	bool isOk = false;

	StringSource(inData, true, new HexDecoder(new StringSink(outData)));
	isOk = true;

	return isOk;
}

bool 
CCryptoEngine::FromBase64(const string& inData,string& outData)
{
	bool isOk = false;

	StringSource(inData, true, new CryptoPP::Base64Decoder(new StringSink(outData)));
	isOk = true;

	return isOk;
}

bool 
CCryptoEngine::FromBase64(const char* inData,size_t inDataSize,string& outData)
{
	bool isOk = false;

	StringSource((const byte*)inData,inDataSize, true, new CryptoPP::Base64Decoder(new StringSink(outData)));
	isOk = true;

	return isOk;
}

bool 
CCryptoEngine::ToBase64(const string& inData,string& outData)
{
	bool isOk = false;

	StringSource(inData, true, new CryptoPP::Base64Encoder(new StringSink(outData),false));
	isOk = true;

	return isOk;
}

bool 
CCryptoEngine::ToBase64(const char* inData,size_t inDataSize,string& outData)
{
	bool isOk = false;

	StringSource((const byte*)inData,inDataSize, true, new CryptoPP::Base64Encoder(new StringSink(outData),false));
	isOk = true;

	return isOk;
}

bool 
CCryptoEngine::ToSha256Hash(const string& inData,string& outData)
{
	bool isOk = false;

	SHA256 hash;
	StringSource(inData, true, new HashFilter(hash,new StringSink(outData)));
	isOk = true;

	return isOk;
}

bool 
CCryptoEngine::HasKey()
{
	bool isOk = false;

	if(!m_keyValue.empty() && !m_keyIv.empty())
		isOk = true;

	return isOk;
}

bool 
CCryptoEngine::GenerateKey()
{
	bool isOk = false;

	if(GenerateKeyValue(m_keyValue) && GenerateKeyIv(m_keyIv))
		isOk = true;

	return isOk;
}

bool 
CCryptoEngine::GetKeyAsHexString(string& keyValue,string& keyIv)
{
	bool isOk = false;

	if(ToHexString(m_keyValue,keyValue) && ToHexString(m_keyIv,keyIv))
		isOk = true;

	return isOk;
}

bool 
CCryptoEngine::GetKeyRaw(string& keyValue,string& keyIv)
{
	bool isOk = false;

	keyValue = m_keyValue;
	keyIv = m_keyIv;

	isOk = true;
	return isOk;
}

bool 
CCryptoEngine::SetKeyAsHexString(const string& keyValue,const string& keyIv)
{
	bool isOk = false;

	if(FromHexString(keyValue,m_keyValue) && FromHexString(keyIv,m_keyIv))
		isOk = true;

	return isOk;
}

bool 
CCryptoEngine::SetKeyRaw(const string& keyValue,const string& keyIv)
{
	bool isOk = false;

	m_keyValue = keyValue;
	m_keyIv = keyIv;

	isOk = true;
	return isOk;
}

bool 
CCryptoEngine::Encrypt(const string& inData,string& outData,bool hexEncode)
{
	bool isOk = false;

	try
	{
		SecByteBlock key((const byte*)m_keyValue.data(),m_keyValue.size());
		SecByteBlock iv((const byte*)m_keyIv.data(),m_keyIv.size());

		CBC_Mode<AES>::Encryption aesEnc(key,key.size(),iv);

		if(hexEncode)
		{
			StringSource(inData,true,new StreamTransformationFilter(aesEnc, new HexEncoder(new StringSink(outData))));
		}
		else
		{
			StringSource(inData,true,new StreamTransformationFilter(aesEnc, new StringSink(outData)));
		}

		byte* pInfo = key.BytePtr();
		size_t infoSize = key.SizeInBytes();
		if((NULL != pInfo) && (0 != infoSize))
		 SecureZeroMemory(pInfo,infoSize);

		pInfo = iv.BytePtr();
		infoSize = iv.SizeInBytes();
		if((NULL != pInfo) && (0 != infoSize))
		 SecureZeroMemory(pInfo,infoSize);

		isOk = true;
	}
	catch(CryptoPP::Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.what() << endl;
		throw;
	}

	return isOk;
}

bool 
CCryptoEngine::Encrypt(const char* inBuf,size_t inBufSize,string& outData,bool hexEncode)
{
	bool isOk = false;

	try
	{
		SecByteBlock key((const byte*)m_keyValue.data(),m_keyValue.size());
		SecByteBlock iv((const byte*)m_keyIv.data(),m_keyIv.size());

		CBC_Mode<AES>::Encryption aesEnc(key,key.size(),iv);

		if(hexEncode)
		{
			StringSource((const byte*)inBuf,inBufSize,true,new StreamTransformationFilter(aesEnc, new HexEncoder(new StringSink(outData))));
		}
		else
		{
			StringSource((const byte*)inBuf,inBufSize,true,new StreamTransformationFilter(aesEnc, new StringSink(outData)));
		}

		byte* pInfo = key.BytePtr();
		size_t infoSize = key.SizeInBytes();
		if((NULL != pInfo) && (0 != infoSize))
		 SecureZeroMemory(pInfo,infoSize);

		pInfo = iv.BytePtr();
		infoSize = iv.SizeInBytes();
		if((NULL != pInfo) && (0 != infoSize))
		 SecureZeroMemory(pInfo,infoSize);

		isOk = true;
	}
	catch(CryptoPP::Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.what() << endl;
		throw;
	}

	return isOk;
}

bool 
CCryptoEngine::Decrypt(const string& inData,string& outData,bool hexEncoded)
{
	bool isOk = false;

	try
	{
		SecByteBlock key((const byte*)m_keyValue.data(),m_keyValue.size());
		SecByteBlock iv((const byte*)m_keyIv.data(),m_keyIv.size());

		CBC_Mode<AES>::Decryption aesDec(key,key.size(),iv);

		if(hexEncoded)
		{
			StringSource(inData,true,new HexDecoder(new StreamTransformationFilter(aesDec, new StringSink(outData))));	
		}
		else
		{
			StringSource(inData,true,new StreamTransformationFilter(aesDec, new StringSink(outData)));
		}

		byte* pInfo = key.BytePtr();
		size_t infoSize = key.SizeInBytes();
		if((NULL != pInfo) && (0 != infoSize))
		 SecureZeroMemory(pInfo,infoSize);

		pInfo = iv.BytePtr();
		infoSize = iv.SizeInBytes();
		if((NULL != pInfo) && (0 != infoSize))
		 SecureZeroMemory(pInfo,infoSize);

		isOk = true;
	}
	catch(CryptoPP::Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.what() << endl;
		throw;
	}

	return isOk;
}

bool 
CCryptoEngine::Decrypt(const char* inBuf,size_t inBufSize,string& outData,bool hexEncoded)
{
	bool isOk = false;

	try
	{
		SecByteBlock key((const byte*)m_keyValue.data(),m_keyValue.size());
		SecByteBlock iv((const byte*)m_keyIv.data(),m_keyIv.size());

		CBC_Mode<AES>::Decryption aesDec(key,key.size(),iv);

		if(hexEncoded)
		{
			StringSource((const byte*)inBuf,inBufSize,true,new HexDecoder(new StreamTransformationFilter(aesDec, new StringSink(outData))));		
		}
		else
		{
			StringSource((const byte*)inBuf,inBufSize,true,new StreamTransformationFilter(aesDec, new StringSink(outData)));
		}

		byte* pInfo = key.BytePtr();
		size_t infoSize = key.SizeInBytes();
		if((NULL != pInfo) && (0 != infoSize))
		 SecureZeroMemory(pInfo,infoSize);

		pInfo = iv.BytePtr();
		infoSize = iv.SizeInBytes();
		if((NULL != pInfo) && (0 != infoSize))
		 SecureZeroMemory(pInfo,infoSize);

		isOk = true;
	}
	catch(CryptoPP::Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.what() << endl;
		throw;
	}

	return isOk;
}


