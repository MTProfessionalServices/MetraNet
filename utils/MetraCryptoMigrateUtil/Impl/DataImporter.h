#ifndef _INCLUDE_DATA_IMPORTER_H_
#define _INCLUDE_DATA_IMPORTER_H_

#include "ActionHandler.h"
#include "DataImporterDataStoreClient.h"
#include "RsaKeyManagerClient.h"
#include "DataMirrorManager.h"
#include "CryptoEngine.h"
#include "DataTransformTransaction.h"
#include "DataActionStateManager.h"

//todo: need to refactor the cut and paste code from CDataExporter :-)

class CDataImporter : public CActionHandler, public CDataImporterDataStoreSubscriber, public CDataMirrorDataSubscriber
{
public:
	CDataImporter();
	virtual ~CDataImporter();

	virtual bool Execute(AutoPtr<AbstractConfiguration> spParams);

	virtual bool OnPaymentInstrumentReport(const string& inAccount,
										  const string& inKey,
										  string& outAccount,
										  string& outAccountHash);

	virtual bool OnPaymentInstrumentError(const string& inErrorInfo,bool& outIgnore);

	virtual bool OnDataReport(const string& inNewData,
							  const string& inNewDataHash,
							  const string& inOrigData,
							  const string& inOrigDataKey);

	virtual bool OnDataError(const string& inErrorInfo,bool& outIgnore);

private:
	bool GetParams(AutoPtr<AbstractConfiguration> spParams);
	void ClearParams();

	string m_tid;
	string m_dttPassPhrase;

	string m_nmServerLocation;
	string m_nmDbName;
	string m_nmUid;
	string m_nmPassword;
	string m_nmPort;

	string m_nmpServerLocation;
	string m_nmpDbName;
	string m_nmpUid;
	string m_nmpPassword;
	string m_nmpPort;

	bool   m_doMirrorData;
	bool   m_doUpdateSource;
	bool   m_importFromMirror;

	string m_rsaKmcConfigFileName;
	string m_rsaKmcCertPass;

	string m_rsaPiNumberKeyClass;
	string m_rsaPiHashKeyClass;
	string m_rsaPassKeyClass;

	unsigned long m_piReportCount;

	SharedPtr<CDataImporterDataStoreClient> m_spDsClient;
	SharedPtr<CRsaKeyManagerClient> m_spRsaKmClient;
	SharedPtr<CCryptoEngine> m_spCryptoEngine;
	SharedPtr<CDataMirrorManager> m_spDmManager;
	SharedPtr<CDataTransformTransaction> m_spDttRecord;
	SharedPtr<CDataActionStateManager> m_spDasManager;

	SharedPtr<CDataMirrorManager> m_spExportDmManager;
	SharedPtr<CDataActionStateManager> m_spExportDasManager;
};

#endif