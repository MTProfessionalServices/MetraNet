
#include "ActionHandler.h"

CActionHandler::CActionHandler()
:m_name("<NONE>"),
 m_description("<NONE>")
{
}

CActionHandler::~CActionHandler()
{
}

const string& 
CActionHandler::Name() const
{
	return m_name;
}

const string& 
CActionHandler::Description() const
{
	return m_description;
}
