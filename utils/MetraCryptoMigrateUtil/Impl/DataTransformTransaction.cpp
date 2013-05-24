
#include "DataTransformTransaction.h"
#include "IncludeCryptopp.h"

#define DTT_MAGIC_NUMBER 0x7812a49f

CDataTransformTransaction::~CDataTransformTransaction()
{
}

CDataTransformTransaction::CDataTransformTransaction(const string& id)
:m_id(id),
 m_fileName(id + ".dtt"),
 m_dataCount(0),
 m_dataMirror(false),
 m_transformedSource(false)
{
}

bool 
CDataTransformTransaction::Restore()
{
	bool isOk = false;

	if(m_passPhrase.empty())
		return isOk;

	if(m_fileName.empty())
		return isOk;

	File f(m_fileName.c_str());
	if(!f.exists() || !f.isFile())
		return isOk;

	try
	{
		string inData;
		FileSource f(m_fileName.c_str(), true, new DefaultDecryptorWithMAC(m_passPhrase.c_str(), new StringSink(inData)));

		if(inData.empty())
			throw Poco::Exception("missing DTT data");

		stringstream ss(inData);
		UInt32 magic = 0;
		BinaryReader reader(ss);

		reader >> magic;
		if(DTT_MAGIC_NUMBER != magic)
			throw Poco::Exception("invalid DTT data format");

	    reader >> m_id
			   >> m_dataKeyId
			   >> m_dataKeyValue
			   >> m_dataKeyIv
			   >> m_dataHash
			   >> m_dataCount
			   >> m_transformedSource
			   >> m_dataMirror
			   >> m_dataMirrorFileName;

		isOk = true;
	}
	catch(Poco::Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}
	catch(exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.what() << endl;
	}

	return isOk;
}

bool 
CDataTransformTransaction::Save()
{
	bool isOk = false;

	if(!m_passPhrase.empty())
	{
		try
		{
			stringstream ss;
			BinaryWriter writer(ss);

			writer << DTT_MAGIC_NUMBER
				   << m_id
				   << m_dataKeyId
				   << m_dataKeyValue
				   << m_dataKeyIv
				   << m_dataHash
				   << m_dataCount
				   << m_transformedSource
				   << m_dataMirror
				   << m_dataMirrorFileName;

			StringSource f(ss.str(), true, new DefaultEncryptorWithMAC(m_passPhrase.c_str(), new FileSink(m_fileName.c_str())));
			isOk = true;
		}
		catch(Poco::Exception& x)
		{
			m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
		}
		catch(exception& x)
		{
			m_logger.error() << __FUNCTION__ << " : " <<  x.what() << endl;
		}
	}

	return isOk;
}

bool 
CDataTransformTransaction::SetPassPhrase(const string& passPhrase)
{
	bool isOk = false;

	if(passPhrase.empty() || passPhrase.length() < 12)
		return isOk;

	m_passPhrase = passPhrase;
	isOk = true;

	return isOk;
}

bool 
CDataTransformTransaction::SetDataKey(const string& id, const string& value, const string& iv)
{
	bool isOk = false;
	if(id.empty() || value.empty() || iv.empty())
		return isOk;

	m_dataKeyId = id;
	m_dataKeyValue = value;
	m_dataKeyIv = iv;
	isOk = true;

	return isOk;
}

bool 
CDataTransformTransaction::GetDataKey(string& id,string& value,string& iv)
{
	bool isOk = false;
	if(m_dataKeyId.empty() || m_dataKeyValue.empty() || m_dataKeyIv.empty())
		return isOk;

	id = m_dataKeyId;
	value = m_dataKeyValue;
	iv = m_dataKeyIv;
	isOk = true;

	return isOk;
}

bool 
CDataTransformTransaction::GetDataKeyId(string& id)
{
	bool isOk = false;
	if(m_dataKeyId.empty())
		return isOk;

	id = m_dataKeyId;
	isOk = true;
	return isOk;
}

bool 
CDataTransformTransaction::SetDataHash(const string& hash)
{
	bool isOk = false;
	if(hash.empty())
		return isOk;

	m_dataHash = hash;
	isOk = true;
	return isOk;
}

bool 
CDataTransformTransaction::GetDataHash(string& hash)
{
	bool isOk = false;
	if(m_dataHash.empty())
		return isOk;

	hash = m_dataHash;
	isOk = true;
	return isOk;
}

bool 
CDataTransformTransaction::SetDataCount(unsigned long count)
{
	bool isOk = false;
	if(0 == count)
		return isOk;

	m_dataCount = count;
	isOk = true;
	return isOk;
}

bool 
CDataTransformTransaction::GetDataCount(unsigned long& count)
{
	bool isOk = false;
	if(0 == m_dataCount)
		return isOk;

	count = m_dataCount;
	isOk = true;
	return isOk;
}

bool 
CDataTransformTransaction::SetTransformedSource(bool value)
{
	bool isOk = false;
	m_transformedSource = value;
	isOk = true;
	return isOk;
}

bool 
CDataTransformTransaction::GetTransformedSource(bool& value)
{
	bool isOk = false;
	value = m_transformedSource;
	isOk = true;
	return isOk;
}

bool 
CDataTransformTransaction::SetDataMirror(bool value)
{
	bool isOk = false;
	m_dataMirror = value;
	isOk = true;
	return isOk;
}

bool 
CDataTransformTransaction::GetDataMirror(bool& value)
{
	bool isOk = false;
	value = m_dataMirror;
	isOk = true;
	return isOk;
}

bool 
CDataTransformTransaction::SetDataMirrorFileName(const string& name)
{
	bool isOk = false;
	if(name.empty())
		return isOk;

	m_dataMirrorFileName = name;
	isOk = true;
	return isOk;
}

bool 
CDataTransformTransaction::GetDataMirrorFileName(string& name)
{
	bool isOk = false;
	if(m_dataMirrorFileName.empty())
		return isOk;

	name = m_dataMirrorFileName;
	isOk = true;

	return isOk;
}



