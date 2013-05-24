#ifndef _INCLUDE_DATA_EXPORTER_DATA_STORE_CLIENT_H_
#define _INCLUDE_DATA_EXPORTER_DATA_STORE_CLIENT_H_

#include "DataStoreClient.h"

class CDataExporterDataStoreSubscriber  
{
public:
	virtual ~CDataExporterDataStoreSubscriber() {}

	virtual bool OnPaymentInstrumentReport(const string& inAccount,
										const string& inKey,
										string& outAccount) = 0;

	virtual bool OnPaymentInstrumentError(const string& inErrorInfo,bool& outIgnore) = 0;
};


class CDataExporterDataStoreClient : private CDataStoreClient
{
public:
	CDataExporterDataStoreClient(CDataExporterDataStoreSubscriber* pSubscriber,
		             const string& serverLocation,
		             const string& dbName,
					 const string& uid,
					 const string& password,
					 const string& port = "1433");

	virtual ~CDataExporterDataStoreClient();

	bool VisitPaymentInstruments();

private:
	bool UpdatePaymentInstrument(const string& recordKey,const string& aNumber);

	CDataExporterDataStoreSubscriber* m_pSubscriber;
};

#endif
