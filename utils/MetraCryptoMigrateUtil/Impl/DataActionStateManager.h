#ifndef _INCLUDE_DATA_ACTION_STATE_MANAGER_H_
#define _INCLUDE_DATA_ACTION_STATE_MANAGER_H_

#include "StateManager.h"

class CDataActionStateManager : public CStateManager
{
public:
	CDataActionStateManager(const string& name = "",bool restore = false);
	virtual ~CDataActionStateManager();

	bool UpdateState(const string& dataIndex,const string& data);

	int DataCount() const;
	const string& DataHash() const;

	virtual bool Restore();

	bool AddActionParam(const string& key,const string& value);
	bool AddActionParam(const string& key,int value);
	bool AddActionParam(const string& key,bool value);

	bool AddKmsKeyInfo(const string& keyClass,const string& keyId);

private:
	string m_name;
	int m_stateId;
	string m_currentDataIndex;
	int m_dataCount;
	string m_dataHash;
	SHA1Engine m_dataHashEngine;
};

#endif
