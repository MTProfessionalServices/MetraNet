#ifndef _INCLUDE_DATA_STORE_CLIENT_H_
#define _INCLUDE_DATA_STORE_CLIENT_H_

#include "AppObject.h"

class CDataStoreClient : public CAppObject
{
public:
	CDataStoreClient(const string& serverLocation,
		             const string& dbName,
					 const string& uid,
					 const string& password,
					 const string& port = "1433");

	virtual ~CDataStoreClient();

	SharedPtr<Session>& DataSession();

protected:
	void PrepareODBC();
	
	string m_serverLocation;
	string m_dbName;
	string m_uid;
	string m_password;
	string m_port;
	string m_dbConnectionString;

	SharedPtr<Session> m_spStoreSession;
};

#endif
