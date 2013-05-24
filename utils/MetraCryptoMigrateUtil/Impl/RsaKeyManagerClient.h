#ifndef _INCLUDE_RSA_KEY_MANAGER_CLIENT_H_
#define _INCLUDE_RSA_KEY_MANAGER_CLIENT_H_

#include "AppObject.h"
#include "KMClient.h"      
#include "KMSError.h"

class CRsaKeyManagerClient : public CAppObject
{
public:
	CRsaKeyManagerClient(const string& cfgFileName,
		                 const string& clientCertPassword,
						 const string& rsaPiNumberKeyClass = "CreditCardNumber",
						 const string& rsaPiHashKeyClass = "PaymentInstHash",
						 const string& rsaPassKeyClass = "PasswordHash");

	~CRsaKeyManagerClient();

	bool GetCurrentPasswordHashKey(string& id,string& key);
	bool GetCurrentCcNumberKey(string& id,string& key);
	bool GetCurrentCcNumberHashKey(string& id,string& key);
	bool GetCurrentKeyWithClass(const string& className,string& id,string& key);

	bool EncryptCcNumber(const string& inData,string& outData);
	bool DecryptCcNumber(const string& inData,string& outData);

	bool HashCcNumber(const string& inData,string& outData);
	bool HashCcNumberWithKey(const string& id,const string& inData,string& outData);

	bool VerifyKeyWithClass(const string& className,const string& id);
	bool VerifyCcNumberKey(const string& id);

	bool EncryptPassword(const string& inData,string& outData);
	bool DecryptPassword(const string& inData,string& outData);

private:
	KMClient m_nativeClient;

	string m_rsaPiNumberKeyClass;
	string m_rsaPiHashKeyClass;
	string m_rsaPassKeyClass;
};

#endif

