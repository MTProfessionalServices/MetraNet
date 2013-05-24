#ifndef _INCLUDE_DATA_EXPORTER_H_
#define _INCLUDE_DATA_EXPORTER_H_

#include "ActionHandler.h"
#include "DataExporterDataStoreClient.h"
#include "RsaKeyManagerClient.h"
#include "DataMirrorManager.h"
#include "CryptoEngine.h"
#include "DataTransformTransaction.h"
#include "DataActionStateManager.h"

class CDataExporter : public CActionHandler, public CDataExporterDataStoreSubscriber
{
public:
	CDataExporter();
	virtual ~CDataExporter();

	virtual bool Execute(AutoPtr<AbstractConfiguration> spParams);

	virtual bool OnPaymentInstrumentReport(const string& inAccount,
										const string& inKey,
										string& outAccount);

	virtual bool OnPaymentInstrumentError(const string& inErrorInfo,bool& outIgnore);

private:
	bool GetParams(AutoPtr<AbstractConfiguration> spParams);
	void ClearParams();

	string m_tid;
	string m_dttPassPhrase;

	string m_serverLocation;
	string m_dbName;
	string m_uid;
	string m_password;
	string m_port;
	bool   m_doMirrorData;
	bool   m_doUpdateSource;

	string m_rsaKmcConfigFileName;
	string m_rsaKmcCertPass;
	
	string m_rsaPiNumberKeyClass;
	string m_rsaPiHashKeyClass;
	string m_rsaPassKeyClass;

	unsigned long m_piReportCount;

	SharedPtr<CDataExporterDataStoreClient> m_spDsClient;
	SharedPtr<CRsaKeyManagerClient> m_spRsaKmClient;
	SharedPtr<CCryptoEngine> m_spCryptoEngine;
	SharedPtr<CDataMirrorManager> m_spDmManager;
	SharedPtr<CDataTransformTransaction> m_spDttRecord;
	SharedPtr<CDataActionStateManager> m_spDasManager;
};

#endif

