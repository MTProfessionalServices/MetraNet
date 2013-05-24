#ifndef _INCLUDE_STATE_MANAGER_H_
#define _INCLUDE_STATE_MANAGER_H_

#include "AppObject.h"

class CStateManager : public CAppObject
{
public:
	CStateManager(const string& id,bool reset = true);
	virtual ~CStateManager();

	virtual void ResetState();
	virtual bool Restore() = 0;

protected:
	string m_id;
	SharedPtr<Session> m_spStoreSession;
};

#endif
