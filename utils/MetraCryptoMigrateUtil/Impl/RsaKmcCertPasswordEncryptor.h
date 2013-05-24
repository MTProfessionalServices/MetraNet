#ifndef _INCLUDE_RSA_KMC_CERT_PASSWORD_ENCRYPTOR_H_
#define _INCLUDE_RSA_KMC_CERT_PASSWORD_ENCRYPTOR_H_

#include "ActionHandler.h"
#include "MsDataProtector.h"


class CRsaKmcCertPasswordEncryptor : public CActionHandler
{
public:
	CRsaKmcCertPasswordEncryptor();
	virtual ~CRsaKmcCertPasswordEncryptor();

	virtual bool Execute(AutoPtr<AbstractConfiguration> spParams);

private:
	bool FindFiles(const string& path,const string& name,vector<string>& files);
	bool ProcessFile(const string& fileName,const string& tagName);
	void SaveFile(const string& fileName,AutoPtr<Document>& apDoc);

	bool GetParams(AutoPtr<AbstractConfiguration> spParams);
	void ClearParams();

	string m_rsaKmcCertPass;
	string m_fileDir;
};

#endif
