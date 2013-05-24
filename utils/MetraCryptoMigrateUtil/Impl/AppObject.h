#ifndef _INCLUDE_APP_OBJECT_H_
#define _INCLUDE_APP_OBJECT_H_

#include "AppIncludes.h"

class CAppObject
{
public:
	CAppObject();
	virtual ~CAppObject();

protected:
	LogStream m_logger;
};

#endif
