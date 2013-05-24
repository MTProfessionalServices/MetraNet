#pragma warning( disable : 4786 ) 
#include "MTSQLSelectCommand.h"
#include "mtprogids.h"
#include <formatdbvalue.h>
#include <comdef.h>
#include <string>

MTSQLSelectCommand::MTSQLSelectCommand(MTPipelineLib::IMTSQLRowsetPtr rowset)
	:
	mpRowset(rowset)
{
}

void MTSQLSelectCommand::setQueryString(const std::wstring& query)
{
	mpRowset->Clear();
	mpRowset->SetQueryString(_bstr_t(query.c_str()));
}

void MTSQLSelectCommand::execute()
{
	mpRowset->Execute();
}

long MTSQLSelectCommand::getRecordCount()
{
	return mpRowset->GetRecordCount();
}

void MTSQLSelectCommand::setParam(long pos, RuntimeValue val)
{
	char buf [32];
	sprintf(buf, "%%%%%d%%%%", pos);
	if(val.getType() == RuntimeValue::eDate)
	{
		std::wstring buffer;
		BOOL bSuccess = FormatValueForDB(val.getVariant(), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Error converting DATETIME value to database parameter");
		}
		HRESULT hr = mpRowset->AddParam(_bstr_t(buf), buffer.c_str(), VARIANT_TRUE);
		if (FAILED(hr))
		{
			throw MTSQLComException(hr);
		}
	}
	else if(val.getType() == RuntimeValue::eBool)
	{
		HRESULT hr = mpRowset->AddParam(_bstr_t(buf), val.castToLong().getVariant(), VARIANT_TRUE);
		if(FAILED(hr))
		{
			throw MTSQLComException(hr);
		}		
	}
	else
	{
		HRESULT hr = mpRowset->AddParam(_bstr_t(buf), val.getVariant(), VARIANT_TRUE);
		if(FAILED(hr))
		{
			throw MTSQLComException(hr);
		}
	}
}

RuntimeValue MTSQLSelectCommand::getLong(long pos)
{
	try {
		_variant_t vtPos(pos);
		_variant_t val = mpRowset->GetValue(vtPos);
		return V_VT(&val) == VT_NULL ? RuntimeValue::createNull() : RuntimeValue::createLong(long(val));
	} catch (_com_error e) {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Type conversion in query");
	}
}

RuntimeValue MTSQLSelectCommand::getLongLong(long pos)
{
	try {
		_variant_t vtPos(pos);
		_variant_t val = mpRowset->GetValue(vtPos);
		return V_VT(&val) == VT_NULL ? RuntimeValue::createNull() : RuntimeValue::createLongLong(__int64(val));
	} catch (_com_error e) {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Type conversion in query");
	}
}

RuntimeValue MTSQLSelectCommand::getDec(long pos)
{
	try {
		_variant_t vtPos(pos);
		_variant_t val = mpRowset->GetValue(vtPos);
		return V_VT(&val) == VT_NULL ? RuntimeValue::createNull() : RuntimeValue::createDec(DECIMAL(val));
	} catch (_com_error e) {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Type conversion in query");
	}
}

RuntimeValue MTSQLSelectCommand::getDouble(long pos)
{
	try {
		_variant_t vtPos(pos);
		_variant_t val = mpRowset->GetValue(vtPos);
		return V_VT(&val) == VT_NULL ? RuntimeValue::createNull() : RuntimeValue::createDouble((double)val);
	} catch (_com_error e) {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Type conversion in query");
	}
}

RuntimeValue MTSQLSelectCommand::getBool(long pos)
{
	try {
		_variant_t vtPos(pos);
		_variant_t val = mpRowset->GetValue(vtPos);
		return V_VT(&val) == VT_NULL ? RuntimeValue::createNull() : RuntimeValue::createBool((bool)val);
	} catch (_com_error e) {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Type conversion in query");
	}
}

RuntimeValue MTSQLSelectCommand::getString(long pos)
{
	try {
		_variant_t vtPos(pos);
		_variant_t val = mpRowset->GetValue(vtPos);
		return V_VT(&val) == VT_NULL ? RuntimeValue::createNull() : RuntimeValue::createString(std::string((const char *)((_bstr_t)val)));
	} catch (_com_error e) {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Type conversion in query");
	}
}

RuntimeValue MTSQLSelectCommand::getWString(long pos)
{
	try {
		_variant_t vtPos(pos);
		_variant_t val = mpRowset->GetValue(vtPos);
		return V_VT(&val) == VT_NULL ? RuntimeValue::createNull() : RuntimeValue::createWString((const wchar_t *)((_bstr_t)val));
	} catch (_com_error e) {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Type conversion in query");
	}
}

RuntimeValue MTSQLSelectCommand::getDatetime(long pos)
{
	try {
		_variant_t vtPos(pos);
		_variant_t val = mpRowset->GetValue(vtPos);
		// Since DATE is just a typedef of double, tell RuntimeValue that this is not a double
		return V_VT(&val) == VT_NULL ? RuntimeValue::createNull() : RuntimeValue::createDatetime((DATE)val);
	} catch (_com_error e) {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Type conversion in query");
	}
}

RuntimeValue MTSQLSelectCommand::getTime(long pos)
{
	try {
		_variant_t vtPos(pos);
		_variant_t val = mpRowset->GetValue(vtPos);
		// Since TIME is just a long in the database, pull it out as such
		return V_VT(&val) == VT_NULL ? RuntimeValue::createNull() : RuntimeValue::createTime((long)val);
	} catch (_com_error e) {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Type conversion in query");
	}
}

RuntimeValue MTSQLSelectCommand::getEnum(long pos)
{
	try {
		_variant_t vtPos(pos);
		_variant_t val = mpRowset->GetValue(vtPos);
		// Since ENUM is just a long in the database, pull it out as such
		return V_VT(&val) == VT_NULL ? RuntimeValue::createNull() : RuntimeValue::createEnum((long)val);
	} catch (_com_error e) {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Type conversion in query");
	}
}

RuntimeValue MTSQLSelectCommand::getBinary(long pos)
{
  throw MTSQLInternalErrorException(__FILE__, __LINE__, "BINARY unsupported in MTSQL SELECT statements");
}

