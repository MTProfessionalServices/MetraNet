#ifndef _INCLUDE_DATA_MIRROR_MANAGER_H_
#define _INCLUDE_DATA_MIRROR_MANAGER_H_

#include "AppObject.h"

class CDataMirrorDataSubscriber 
{
public:
	virtual ~CDataMirrorDataSubscriber() {}

	virtual bool OnDataReport(const string& inNewData,
							  const string& inNewDataHash,
							  const string& inOrigData,
							  const string& inOrigDataKey) = 0;

	virtual bool OnDataError(const string& inErrorInfo,bool& outIgnore) = 0;
};


class CDataMirrorManager : public CAppObject
{
public:
	CDataMirrorManager(const string& id,
					   bool reset = true,
					   CDataMirrorDataSubscriber* pSubscriber = NULL);
	virtual ~CDataMirrorManager();

	bool AddData(const string& newData,
				 const string& newDataHash, 
				 const string& origData, 
				 const string& origDataKey);

	const string& Name();

	bool VisitData();

protected:
	void Clear();
	void Setup();
	SharedPtr<Session> m_spStoreSession;

	string m_id;
	string m_name;

	CDataMirrorDataSubscriber* m_pSubscriber;
};

#endif
