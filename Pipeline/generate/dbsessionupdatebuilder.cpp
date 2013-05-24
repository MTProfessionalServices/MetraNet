/**************************************************************************
 * DBSESSIONUPDATEBUILDER
 *
 * Copyright 1997-2004 by MetraTech Corp.
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Travis Gebhardt
 *
 * $Date$
 * $Author$s
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <sessionbuilder.h>
#include <mtprogids.h>
#include <ServicesCollection.h>
#include <propids.h>
#include <DBMiscUtils.h>
#include <formatdbvalue.h>

#import <NameID.tlb>

// for feedback support
#include <routeconfig.h>
#include <ConfigDir.h>
#include <listenerconfig.h>
#include <pipelineconfig.h>
#include <msmqlib.h>
#include <makeunique.h>
#include <MSIX.h>
#import <MTConfigLib.tlb>

template <class _InsertStmt>
DBSessionUpdateBuilder<_InsertStmt>::DBSessionUpdateBuilder() 
	: mProduct(NULL), mRootServiceDef(NULL)
{ }

template <class _InsertStmt>
void DBSessionUpdateBuilder<_InsertStmt>::Initialize(const PipelineInfo& configInfo, CMTCryptoAPI* crypto)
{
	ASSERT(crypto);
	mCrypto = crypto;

	PipelinePropIDs::Init();

	//
	// builds a map of our own service def objects keyed by service ID
	//
	CServicesCollection services;
	if (!services.Initialize())
	{
		const ErrorObject* err = services.GetLastError();
		std::string msg = "Could not initialize service def collection! ";
		msg += err->GetProgrammerDetail();
		throw MTException(msg, err->GetCode());
	}

	MSIXDefCollection::MSIXDefinitionList::iterator it;
	for (it = services.GetDefList().begin(); it != services.GetDefList().end(); ++it)
	{
		DBServiceDef<_InsertStmt>* def = new DBServiceDef<_InsertStmt>(*it);
		mServiceDefs[def->GetID()] = def;
	}
	COdbcConnectionInfo aDBInfo = COdbcConnectionManager::GetConnectionInfo("NetMeter");
	mIsOracle = (aDBInfo.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);
}


template <class _InsertStmt>
DBSessionUpdateBuilder<_InsertStmt>::~DBSessionUpdateBuilder()
{
	Clear();
}

template <class _InsertStmt>
void DBSessionUpdateBuilder<_InsertStmt>::Clear()
{
	// resets property tracking
	ClearProperties();
	
	if (mProduct)
	{
		delete mProduct;
		mProduct = NULL;
	}

	mServiceDef = NULL;
}

template <class _InsertStmt>
void DBSessionUpdateBuilder<_InsertStmt>::StartProduction()
{
	Clear();
	ASSERT(!mProduct);

	mProduct = new DBSessionUpdateProduct<_InsertStmt>();
}

template <class _InsertStmt>
ISessionProduct * DBSessionUpdateBuilder<_InsertStmt>::CompleteProduction()
{
	// the client now owns the product
	// they are responsible for freeing it
	ISessionProduct * product = mProduct;
	mProduct = NULL;
	return product;
}

template <class _InsertStmt>
void DBSessionUpdateBuilder<_InsertStmt>::AbortProduction()
{
	Clear();
}

template <class _InsertStmt>
void DBSessionUpdateBuilder<_InsertStmt>::CreateSession(const unsigned char * uid, int serviceDefID)
{
	CreateChildSession(uid, serviceDefID, NULL);
}

template <class _InsertStmt>
inline void DBSessionUpdateBuilder<_InsertStmt>::CreateChildSession(const unsigned char * uid,
																											 int serviceDefID,
																											 const unsigned char * parentUID)
{
	mServiceDef = mServiceDefs[serviceDefID];
	mProduct->mUpdateQuery += L"\nUPDATE ";
	mProduct->mUpdateQuery += (wchar_t *) _bstr_t(mServiceDef->GetTableName().c_str());
	mProduct->mUpdateQuery += L" SET ";

	mHexUID = (wchar_t *) _bstr_t(ConvertBinaryUIDToHexLiteral(uid, mIsOracle).c_str());

	mFirstProperty = true;
}

template <class _InsertStmt>
inline void DBSessionUpdateBuilder<_InsertStmt>::AddProperty(long propertyID)
{
	if (!mFirstProperty)
		mProduct->mUpdateQuery += L", ";
	
	mProduct->mUpdateQuery += (wchar_t *) _bstr_t(mServiceDef->GetColumnName(propertyID).c_str());
	mProduct->mUpdateQuery += L" = ";

	mFirstProperty = false;
}

template <class _InsertStmt>
inline void DBSessionUpdateBuilder<_InsertStmt>::AddLongSessionProperty(long propertyID, long value)
{	
	AddProperty(propertyID);
	mProduct->mUpdateQuery += (wchar_t *) _bstr_t(value);
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionUpdateBuilder<_InsertStmt>::AddDoubleSessionProperty(long propertyID, double value)
{	
	AddProperty(propertyID);
	mProduct->mUpdateQuery += (wchar_t *) _bstr_t(value);
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionUpdateBuilder<_InsertStmt>::AddTimestampSessionProperty(long propertyID, time_t value)
{	
	AddProperty(propertyID);

	DATE oleDate;
	OleDateFromTimet(&oleDate, value);
	std::wstring buffer;
	if (!FormatValueForDB(_variant_t(oleDate, VT_DATE), mIsOracle, buffer))
		throw MTException("Could not convert timestamp to ODBC escape sequence!");

	mProduct->mUpdateQuery += (wchar_t *) _bstr_t(buffer.c_str());

	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionUpdateBuilder<_InsertStmt>::AddBoolSessionProperty(long propertyID, bool value)
{	
	AddProperty(propertyID);

	if (value)
		mProduct->mUpdateQuery += L"'1'";
	else
		mProduct->mUpdateQuery += L"'0'";

	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionUpdateBuilder<_InsertStmt>::AddEnumSessionProperty(long propertyID, long value)
{	
	AddProperty(propertyID);
	mProduct->mUpdateQuery += (wchar_t *) _bstr_t(value);
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionUpdateBuilder<_InsertStmt>::AddStringSessionProperty(long propertyID, const wchar_t* value)
{	
	// converts the encoded batch UID (_CollectionID special property) to binary
	if (propertyID == PipelinePropIDs::CollectionIDCode())
	{
		// TODO: this could be hashed for future lookup
		std::string batchUIDEncoded((char *) _bstr_t(value));
		unsigned char batchUID[UID_LENGTH];
		if (!MSIXUidGenerator::Decode(batchUID, batchUIDEncoded))
			throw MTException("Could not decode batch UID!");

		AddProperty(propertyID);
		// TODO: implement me!
		RecordProperty(propertyID);

		return;
	}

	AddProperty(propertyID);
	mProduct->mUpdateQuery += L"N'";
	mProduct->mUpdateQuery += EscapeSQLString(value);
	mProduct->mUpdateQuery += L"'";
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionUpdateBuilder<_InsertStmt>::AddEncryptedStringSessionProperty(long propertyID, const wchar_t* value)
{	
	// encrypts and uuencodes string
	std::string cipherText;
  if(!::WideStringToUTF8(value, cipherText))
  {
    ASSERT(0);
		throw MTException("Failed to convert wide string to UTF8!");
  }

	int result;
	result = mCrypto->Encrypt(cipherText);
	if (result != 0)
	{
		ASSERT(0);
		std::string msg = "Failed to encrypt property! propid=" + propertyID;
		throw MTException(msg.c_str());
	}

	AddProperty(propertyID);
	mProduct->mUpdateQuery += L"N'";
	mProduct->mUpdateQuery += EscapeSQLString((wchar_t*) _bstr_t(cipherText.c_str()));
	mProduct->mUpdateQuery += L"'";
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionUpdateBuilder<_InsertStmt>::AddDecimalSessionProperty(long propertyID, DECIMAL value)
{	
	AddProperty(propertyID);
	mProduct->mUpdateQuery += (wchar_t *) (_bstr_t) _variant_t(value);
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionUpdateBuilder<_InsertStmt>::AddLongLongSessionProperty(long propertyID, __int64 value)
{	
	AddProperty(propertyID);
	mProduct->mUpdateQuery += (wchar_t *) _bstr_t(value);
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline bool DBSessionUpdateBuilder<_InsertStmt>::SessionPropertyExists(long propertyID)
{
	return PropertyExists(propertyID);
}

template <class _InsertStmt>
inline void DBSessionUpdateBuilder<_InsertStmt>::CompleteSession()
{
	mProduct->mUpdateQuery += L" WHERE id_source_sess = ";
	if (mIsOracle)
	{
		//add the semicolon at the end!
		mProduct->mUpdateQuery += L" hextoraw(" + mHexUID + L"); ";
	}
	else
	{
		mProduct->mUpdateQuery += mHexUID;
	}

	// resets property tracking for the next session
	ClearProperties();
}


template <class _InsertStmt>
inline std::wstring DBSessionUpdateBuilder<_InsertStmt>::EscapeSQLString(const std::wstring & str)
{
	// only escape single quotes if necessary
  if (str.find('\'') == std::wstring::npos)
		return str;

	// double up and single quotes
  std::wstring escapedStr;
  for (unsigned int i = 0; i < str.length(); i++)
  {
    if (str[i] == '\'')
      escapedStr += L"''";
    else
      escapedStr += str[i];
  }
	
  return escapedStr;
}

// explicit instantiation - so all the impl doesn't have to be in the header
template class DBSessionUpdateBuilder<COdbcPreparedBcpStatement>;
template class DBSessionUpdateBuilder<COdbcPreparedArrayStatement>;
