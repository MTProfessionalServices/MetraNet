#ifndef _INCLUDE_SERVER_PASSWORD_TRANSFORMER_H_
#define _INCLUDE_SERVER_PASSWORD_TRANSFORMER_H_

#include "ActionHandler.h"
#include "CryptoEngine.h"
#include "RsaKeyManagerClient.h"
#include "DataTransformTransaction.h"

class CServerPasswordTransformer : public CActionHandler
{
public:
	CServerPasswordTransformer(bool isExporter);
	virtual ~CServerPasswordTransformer();

	virtual bool Execute(AutoPtr<AbstractConfiguration> spParams);

private:
	bool FindFiles(const string& path,const string& name,vector<string>& files);
	bool ProcessFile(const string& fileName,const string& tagName);
	void SaveFile(const string& fileName,AutoPtr<Document>& apDoc);

	bool GetParams(AutoPtr<AbstractConfiguration> spParams);
	void ClearParams();

	string m_tid;
	string m_dttPassPhrase;
	string m_rsaKmcConfigFileName;
	string m_rsaKmcCertPass;
	string m_rsaPiNumberKeyClass;
	string m_rsaPiHashKeyClass;
	string m_rsaPassKeyClass;

	bool m_doServersFiles;
	bool m_doProtectedPropertyListFile;
	bool m_doSignIoLoginFile;
	bool m_doMirrorData;
	bool m_doUpdateSource;
	bool m_fromMirror;
	string m_configDir;
	string m_extensionDir;

	bool m_isExporter;
	unsigned long m_transformCount;

	SharedPtr<CRsaKeyManagerClient> m_spRsaKmClient;
	SharedPtr<CCryptoEngine> m_spCryptoEngine;
	SharedPtr<CDataTransformTransaction> m_spDttRecord;
};

#endif
