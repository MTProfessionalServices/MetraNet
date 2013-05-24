
#ifndef _INCLUDE_DATA_TRANSFORM_TRANSACTION_H_
#define _INCLUDE_DATA_TRANSFORM_TRANSACTION_H_

#include "AppObject.h"

class CDataTransformTransaction : public CAppObject
{
public:
	CDataTransformTransaction(const string& id);
	~CDataTransformTransaction();

	bool SetPassPhrase(const string& passPhrase);

	bool Restore();
	bool Save();

	bool SetDataKey(const string& id, const string& value, const string& iv);
	bool GetDataKey(string& id,string& value,string& iv);
	bool GetDataKeyId(string& id);

	bool SetDataHash(const string& hash);
	bool GetDataHash(string& hash);

	bool SetDataCount(unsigned long count);
	bool GetDataCount(unsigned long& count);

	bool SetDataMirror(bool value);
	bool GetDataMirror(bool& value);

	bool SetDataMirrorFileName(const string& name);
	bool GetDataMirrorFileName(string& name);

	bool SetTransformedSource(bool value);
	bool GetTransformedSource(bool& value);

private:
	string m_id;
	string m_fileName;
	string m_passPhrase;

	string m_dataKeyId;
	string m_dataKeyValue;
	string m_dataKeyIv;
	string m_dataHash;
	unsigned long m_dataCount;
	bool m_transformedSource;
	bool m_dataMirror;
	string m_dataMirrorFileName;
};

#endif