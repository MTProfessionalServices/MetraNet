
#include "DataActionStateManager.h"


CDataActionStateManager::CDataActionStateManager(const string& name,bool restore)
:CStateManager(name + ".Das",!restore),
 m_name(name),
 m_dataCount(0),
 m_stateId(0)
{
	if(restore)
	{
		if(!Restore())
			throw Exception("Could not restore data action state");
	}
	else
	{
		*m_spStoreSession << "CREATE TABLE ActionParam (Name TEXT, Value TEXT)", now;
		*m_spStoreSession << "CREATE TABLE KmsKeyInfo (Class TEXT, Id TEXT)", now;

		*m_spStoreSession << "CREATE TABLE State (Name TEXT, StateId INTEGER, CurrentDataIndex TEXT, DataCount INTEGER, DataHash TEXT)", now;

		Statement insert(*m_spStoreSession);
		insert << "INSERT INTO State VALUES(?, ?, ?, ?, ?)",
			use(m_name),
			use(m_stateId),
			use(m_currentDataIndex),
			use(m_dataCount),
			use(m_dataHash);
		
		insert.execute();
	}
}

CDataActionStateManager::~CDataActionStateManager()
{
}


bool 
CDataActionStateManager::Restore()
{
	bool isOk = false;
	try
	{
		string restoredName;
		string recordKey;
		Statement select(*m_spStoreSession);
		select << "SELECT Name, StateId, CurrentDataIndex, DataCount, DataHash  FROM State",
				into(restoredName),
				into(m_stateId),
				into(m_currentDataIndex),
				into(m_dataCount),
				into(m_dataHash),
				range(0, 1); 

		while (!select.done())
		{
			select.execute();
			//should have only one for now...
			break;
		}

		if(restoredName != m_name)
		{
			m_stateId = 0;
			m_currentDataIndex.clear();
			m_dataCount = 0;
			m_dataHash.clear();
		}
		else
		{
			isOk = true;
		}
	}
	catch(StatementException& x)
	{ 
		m_logger.error() << __FUNCTION__ << x.toString() << endl; 

		const StatementDiagnostics::FieldVec& fields = x.diagnostics().fields();
		StatementDiagnostics::Iterator it = fields.begin();
		for (; it != fields.end(); ++it)
		{
			if (3701 == it->_nativeError)
			{
				m_logger.error() << "Table doesnt exist" << endl;
			}
			else
			{
				m_logger.error() << __FUNCTION__ << " : Native DB Error: " << it->_nativeError << endl;
			}
		}
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}
	return isOk;
}

bool 
CDataActionStateManager::UpdateState(const string& dataIndex,const string& data)
{
	bool isOk = false;
	if(dataIndex.empty() || data.empty())
		return isOk;

	try
	{
		string tmpData = m_dataHash + data;
		SHA1Engine sha1;
		sha1.update(tmpData);
		m_dataHash = DigestEngine::digestToHex(sha1.digest());

		m_dataCount++;
		m_currentDataIndex = dataIndex;

		Statement update(*m_spStoreSession);
		update << "UPDATE State SET CurrentDataIndex=?, DataCount=?, DataHash=? WHERE Name=?",
			use(m_currentDataIndex),
			use(m_dataCount),
			use(m_dataHash),
			use(m_name);
		
		update.execute();

		isOk = true;
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}

	return isOk;
}

int 
CDataActionStateManager::DataCount() const
{
	return m_dataCount;
}

const string& 
CDataActionStateManager::DataHash() const
{
	return m_dataHash;
}

bool 
CDataActionStateManager::AddActionParam(const string& key,const string& value)
{
	bool isOk = false;
	if(key.empty() || value.empty())
	{
		m_logger.error() << __FUNCTION__ << " : invalid input = " << key << " / " << value << endl;
		return isOk;
	}

	try
	{
		Statement insert(*m_spStoreSession);
		insert << "INSERT INTO ActionParam VALUES(?, ?)",
			use(key),
			use(value);
		
		insert.execute();

		isOk = true;
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}

	return isOk;
}

bool 
CDataActionStateManager::AddActionParam(const string& key,int value)
{
	stringstream ss;
	ss << value;
	return AddActionParam(key,ss.str());
}

bool 
CDataActionStateManager::AddActionParam(const string& key,bool value)
{
	string valueStr = value ? "true" : "false";
	return AddActionParam(key,valueStr);
}

bool 
CDataActionStateManager::AddKmsKeyInfo(const string& keyClass,const string& keyId)
{
	bool isOk = false;
	if(keyClass.empty() || keyId.empty())
	{
		m_logger.error() << __FUNCTION__ << " : invalid input = " << keyClass << " / " << keyId << endl;
		return isOk;
	}

	try
	{
		Statement insert(*m_spStoreSession);
		insert << "INSERT INTO KmsKeyInfo VALUES(?, ?)",
			use(keyClass),
			use(keyId);
		
		insert.execute();

		isOk = true;
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}

	return isOk;
}

