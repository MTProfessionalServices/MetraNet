
#include "StateManager.h"


CStateManager::CStateManager(const string& id,bool reset)
:m_id(id)
{
	try
	{
		string name = "State.";
		name.append(id);
		name.append(".Store");

		m_spStoreSession = new Session("SQLite",name);
		if (!(m_spStoreSession && m_spStoreSession->isConnected())) 
			throw Exception("Could not connect to state store");

		if(reset)
			ResetState();
	}
	catch (Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}
}

void 
CStateManager::ResetState()
{
	*m_spStoreSession << "DROP TABLE IF EXISTS State", now;
	*m_spStoreSession << "DROP TABLE IF EXISTS ActionParam", now;
	*m_spStoreSession << "DROP TABLE IF EXISTS KmsKeyInfo", now;
}

CStateManager::~CStateManager()
{
}
