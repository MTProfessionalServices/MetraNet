#ifndef _INCLUDE_ACTION_HANDLER_H_
#define _INCLUDE_ACTION_HANDLER_H_

#include "AppObject.h"

class CActionHandler : public CAppObject
{
public:
	CActionHandler();
	virtual ~CActionHandler();

	virtual const string& Name() const;
	virtual const string& Description() const;
	virtual bool Execute(AutoPtr<AbstractConfiguration> spParams) = 0;

protected:
	string m_name;
	string m_description;
};

#endif