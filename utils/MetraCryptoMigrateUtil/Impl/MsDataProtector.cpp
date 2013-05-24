
#include "MsDataProtector.h"
#include "CryptoEngine.h"

#include <windows.h>
#include <wincrypt.h>
#pragma comment(lib, "crypt32.lib")


static int gMagicDpApiEntropyData[] =
{
	0x31,0x34,0x37,0x30,
	0x38,0x36,0x30,0x39,
	0x35,0x32,0x37,0x33,
	0x34,0x34,0x32,0x37,
	0x36,0x38,0x35,0x31,
	0x39,0x31,0x31,0x39,
	0x33,0x34,0x34,0x30,
	0x32,0x35,0x31,0x30,
	0x36,0x32,0x37,0x32,
	0x34,0x33,0x32,0x30,
	0x35,0x31,0x34,0x30,
	0x36,0x37,0x30,0x35
};

static DATA_BLOB gMagicDpApiEntropy =
{
	48,(BYTE *)gMagicDpApiEntropyData
};


CMsDataProtector::CMsDataProtector()
{
}

CMsDataProtector::~CMsDataProtector()
{
}

string 
CMsDataProtector::Encrypt(const string& data)
{
	if(data.empty())
		return "";

	DATA_BLOB inData;
	inData.pbData = (BYTE*)data.data();   
	inData.cbData = (DWORD)data.size();

	DATA_BLOB outData;
	if(!CryptProtectData(
		&inData,
		NULL, 
		&gMagicDpApiEntropy,     
		NULL,        
		NULL, 
		CRYPTPROTECT_LOCAL_MACHINE, // | CRYPTPROTECT_UI_FORBIDDEN
		&outData))
	{
		DWORD error = GetLastError();
		return "";
	}

	if((0 == outData.cbData) || (NULL == outData.pbData))
		return "";

	string resultData;
	if(!CCryptoEngine::ToBase64((const char*)outData.pbData,outData.cbData,resultData))
	{
		resultData = "";
	}

	LocalFree(outData.pbData);
	return resultData;
}

string 
CMsDataProtector::Decrypt(const string& data)
{
	if(data.empty())
		return "";

	string inRawdata;
	if(!CCryptoEngine::FromBase64(data,inRawdata))
	{
		return "";
	}

	DATA_BLOB inData;
	inData.pbData = (BYTE*)inRawdata.data();   
	inData.cbData = (DWORD)inRawdata.size();

	DATA_BLOB outData;
	if (!CryptUnprotectData(
        &inData,
        NULL,
        &gMagicDpApiEntropy, 
        NULL,     
        NULL,
        CRYPTPROTECT_LOCAL_MACHINE, // | CRYPTPROTECT_UI_FORBIDDEN
        &outData))
	{
		DWORD error = GetLastError();
		return "";
	}

	if((0 == outData.cbData) || (NULL == outData.pbData))
		return "";

	string resultData;
	resultData.append((const char*)outData.pbData,outData.cbData);
	LocalFree(outData.pbData);
	return resultData;
}

