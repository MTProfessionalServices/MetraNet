
#include "DataMirrorManager.h"


CDataMirrorManager::CDataMirrorManager(const string& id,
									   bool reset,
									   CDataMirrorDataSubscriber* pSubscriber)
:m_id(id),
 m_pSubscriber(pSubscriber)
{
	try
	{
		m_name = m_id + ".Dmm.Store";

		m_spStoreSession = new Session("SQLite",m_name);
		if (!(m_spStoreSession && m_spStoreSession->isConnected())) 
			throw Exception("Could not connect to data mirror store");

		if(reset)
		{
			Clear();
			Setup();
		}
	}
	catch (Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}
}

CDataMirrorManager::~CDataMirrorManager()
{
}

const string&
CDataMirrorManager::Name()
{
	return m_name;
}

void 
CDataMirrorManager::Clear()
{
	*m_spStoreSession << "DROP TABLE IF EXISTS DataMirror", now;
}

void 
CDataMirrorManager::Setup()
{
	try
	{
		*m_spStoreSession << "CREATE TABLE DataMirror (NewData TEXT, NewDataHash TEXT, OrigData TEXT, OrigDataKey TEXT)", now;
	}
	catch(ConnectionException& x)
	{ 
		m_logger.error() << __FUNCTION__ << " : " << x.toString() << endl;
	}
	catch(StatementException& x)
	{ 
		m_logger.error() << __FUNCTION__ << " : " << x.toString() << endl; 
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}
}

bool 
CDataMirrorManager::AddData(const string& newData,
							const string& newDataHash, //ok to be empty
							const string& origData, 
							const string& origDataKey)
{
	bool isOk = false;
	if(newData.empty() || origData.empty() || origDataKey.empty())
		return isOk;

	try
	{
		Statement insert(*m_spStoreSession);

		insert << "INSERT INTO DataMirror VALUES(?, ?, ?, ?)",
		use(newData),
		use(newDataHash), 
		use(origData),
		use(origDataKey);
		
		insert.execute();

		isOk = true;
	}
	catch(StatementException& x)
	{ 
		m_logger.error() << __FUNCTION__ << " : " <<  x.toString() << endl; 
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}

	return isOk;
}


bool 
CDataMirrorManager::VisitData()
{
	bool isOk = false;
	try
	{
		if(NULL != m_pSubscriber)
		{
			string newData;
			string newHash;
			string origData;
			string origDataKey;
			Statement select(*m_spStoreSession);
			select << "SELECT NewData, NewDataHash, OrigData, OrigDataKey  FROM DataMirror",
				into(newData),
				into(newHash),
				into(origData),
				into(origDataKey),
				range(0, 1); 

			m_logger.trace() << "DATA MIRROR: Start iterating through data mirror" << endl;
			while (!select.done())
			{
				select.execute();

				if(!m_pSubscriber->OnDataReport(newData,newHash,origData,origDataKey))
				{
					m_logger.warning() << __FUNCTION__ << " : Data report was not processed (key=" << origDataKey << ")" << endl;
				}
			}

			m_logger.trace() << "DATA MIRROR: Done iterating through data mirror" << endl;
		}
		isOk = true;
	}
	catch(StatementException& x)
	{ 
		m_logger.error() << __FUNCTION__ << " : " << x.toString() << endl; 

		const StatementDiagnostics::FieldVec& fields = x.diagnostics().fields();
		StatementDiagnostics::Iterator it = fields.begin();
		for (; it != fields.end(); ++it)
		{
			if (3701 == it->_nativeError)
			{
				m_logger.error() << __FUNCTION__ << " : Table doesnt exist" << endl;
			}
			else
			{
				m_logger.error() << __FUNCTION__ << " : Native DB Error: " << it->_nativeError << endl;
			}
		}

		throw;
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
		throw;
	}

	return isOk;
}
