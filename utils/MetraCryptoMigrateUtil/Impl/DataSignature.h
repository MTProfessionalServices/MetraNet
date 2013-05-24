#ifndef _INCLUDE_DATA_SIGNATURE_H_
#define _INCLUDE_DATA_SIGNATURE_H_

#include "ActionHandler.h"
#include "DataExporterDataStoreClient.h"
#include "RsaKeyManagerClient.h"
#include "DataMirrorManager.h"
#include "CryptoEngine.h"
#include "DataTransformTransaction.h"
#include "DataActionStateManager.h"


class CDataSignature : public CActionHandler, public CDataExporterDataStoreSubscriber, public CDataMirrorDataSubscriber
{
public:
	CDataSignature(bool isGenerator);
	virtual ~CDataSignature();

	virtual bool Execute(AutoPtr<AbstractConfiguration> spParams);

	virtual bool OnPaymentInstrumentReport(const string& inAccount,
										   const string& inKey,
										   string& outAccount);

	virtual bool OnPaymentInstrumentError(const string& inErrorInfo,bool& outIgnore);

	virtual bool OnDataReport(const string& inNewData,
							  const string& inNewDataHash,
							  const string& inOrigData,
							  const string& inOrigDataKey);

	virtual bool OnDataError(const string& inErrorInfo,bool& outIgnore);

private:
	typedef enum
	{
		E_DS_NONE,
		E_DS_SERVER,
		E_DS_EXPORT_DATA_MIRROR,
		E_DS_IMPORT_DATA_MIRROR
	} TDataSource;

	TDataSource GetDataSource(const string& dataSourceStr);

	bool GetParams(AutoPtr<AbstractConfiguration> spParams);

	void GetServerDataSourceParams(AutoPtr<AbstractConfiguration> spParams);
	void GetExportDataMirrorDataSourceParams(AutoPtr<AbstractConfiguration> spParams);
	void GetImportDataMirrorDataSourceParams(AutoPtr<AbstractConfiguration> spParams);

	void ClearParams();

	bool m_isGenerator;

	string m_tid;
	TDataSource m_dataSource;

	string m_exportDataTid;
	string m_dttPassPhrase;

	bool   exportedServerData;
	string m_serverLocation;
	string m_dbName;
	string m_uid;
	string m_password;
	string m_port;

	string m_rsaKmcConfigFileName;
	string m_rsaKmcCertPass;
	string m_rsaPiNumberKeyClass;
	string m_rsaPiHashKeyClass;
	string m_rsaPassKeyClass;

	unsigned long m_piReportCount;

	SharedPtr<CDataMirrorManager> m_spSourceDmManager;

	SharedPtr<CDataExporterDataStoreClient> m_spDsClient;
	SharedPtr<CRsaKeyManagerClient> m_spRsaKmClient;
	SharedPtr<CCryptoEngine> m_spCryptoEngine;
	SharedPtr<CDataTransformTransaction> m_spDttRecord;

	SharedPtr<CDataActionStateManager> m_spDasManager;
	SharedPtr<CDataActionStateManager> m_spSourceDataMirrorDasManager;
	SharedPtr<CDataActionStateManager> m_spCompareDasManager;
};

#endif
