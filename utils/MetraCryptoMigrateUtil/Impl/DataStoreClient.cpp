
#include "DataStoreClient.h"



CDataStoreClient::CDataStoreClient(const string& serverLocation,
									const string& dbName,
									const string& uid,
									const string& password,
									const string& port)
:m_serverLocation(serverLocation),
 m_dbName(dbName),
 m_uid(uid),
 m_password(password),
 m_port(port)
{
	PrepareODBC();

	if(m_dbConnectionString.empty())
		throw Exception(__FUNCTION__ ": Empty database connection string");

	try
	{
		m_spStoreSession = new Session("ODBC",m_dbConnectionString);
	}
	catch (ConnectionException& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
		throw;
	}
	catch (Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
		throw;
	}

	if (!(m_spStoreSession && m_spStoreSession->isConnected())) 
		throw Exception(string("Could not connect to ") + serverLocation);
}

CDataStoreClient::~CDataStoreClient()
{
}

SharedPtr<Session>& 
CDataStoreClient::DataSession()
{
	return m_spStoreSession;
}

void 
CDataStoreClient::PrepareODBC()
{
	static const char* sOdbcDriverNames[3] =
	{
		"SQL Native Client", 
		"SQL Server",
		NULL
	};

	m_logger.trace() << "Preparing ODBC data store driver..." << endl;

	ODBC::Utility::DriverMap odbcDrivers;
	Utility::drivers(odbcDrivers);

	bool driverFound = false;

	const char* pDriverName = NULL;
	for(int i = 0;i < 2;i++)
	{
		pDriverName = sOdbcDriverNames[i];
		if(NULL == pDriverName)
			break;

		Utility::DriverMap::iterator dir = odbcDrivers.begin();
		for (; dir != odbcDrivers.end(); ++dir)
		{
			if (((dir->first).find(pDriverName) != string::npos))
			{
				driverFound = true;
				m_logger.trace() << "Found ODBC data store driver: " << pDriverName << endl;
				break;
			}
		}

		if(driverFound)
			break;
	}

	if (!driverFound || (NULL == pDriverName)) 
	{
		throw Exception("SQL Server driver not found");
	}

	m_dbConnectionString = "DRIVER=";
	m_dbConnectionString.append(pDriverName); 
	m_dbConnectionString.append(";UID=");
	m_dbConnectionString.append(m_uid);
	m_dbConnectionString.append(";PWD=");
	m_dbConnectionString.append(m_password);
	m_dbConnectionString.append(";DATABASE=");
	m_dbConnectionString.append(m_dbName);
	m_dbConnectionString.append(";SERVER=");
	m_dbConnectionString.append(m_serverLocation);
	m_dbConnectionString.append(";PORT="); 
	m_dbConnectionString.append(m_port);
	m_dbConnectionString.append(";");
}


