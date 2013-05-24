#ifndef _INCLUDE_DATA_IMPORTER_DATA_STORE_CLIENT_H_
#define _INCLUDE_DATA_IMPORTER_DATA_STORE_CLIENT_H_

#include "DataStoreClient.h"

class CDataImporterDataStoreSubscriber 
{
public:
	virtual ~CDataImporterDataStoreSubscriber() {}

	virtual bool OnPaymentInstrumentReport(const string& inAccount,
										  const string& inKey,
										  string& outAccount,
										  string& outAccountHash) = 0;

	virtual bool OnPaymentInstrumentError(const string& inErrorInfo,bool& outIgnore) = 0;
};


class CDataImporterDataStoreClient : private CDataStoreClient
{
public:
	CDataImporterDataStoreClient(CDataImporterDataStoreSubscriber* pSubscriber,
		             const string& serverLocation,
		             const string& dbName,
					 const string& uid,
					 const string& password,
					 const string& port = "1433");

	CDataImporterDataStoreClient(CDataImporterDataStoreSubscriber* pSubscriber,
		             const string& nmServerLocation,
		             const string& nmDbName,
					 const string& nmUid,
					 const string& nmPassword,
					 const string& nmpServerLocation,
		             const string& nmpDbName,
					 const string& nmpUid,
					 const string& nmpPassword,
					 const string& nmPort = "1433",
					 const string& nmpPort = "1433");

	virtual ~CDataImporterDataStoreClient();

	bool VisitData();

	bool UpdatePaymentInstrument(const string& recordKey,const string& aNumber,const string& aNumberHash);
private:


	CDataImporterDataStoreSubscriber* m_pSubscriber;
	bool m_useNmpDsClient;
	SharedPtr<CDataStoreClient> m_spNmpDataStoreClient;
};

#endif
