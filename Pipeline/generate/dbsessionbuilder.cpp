/**************************************************************************
 * DBSESSIONBUILDER
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
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <sessionbuilder.h>
#include <mtprogids.h>
#include <ServicesCollection.h>
#include <propids.h>
#include <DBMiscUtils.h>
#include <reservedproperties.h>
#include <hostname.h>

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
#import <MetraTech.Product.Hooks.tlb>

class ServiceDefHookProxy
{
public:
	MetraTech_Product_Hooks::IServiceDefHookPtr ServiceDefHook;

  ServiceDefHookProxy()
    :
    ServiceDefHook(__uuidof(MetraTech_Product_Hooks::ServiceDefHook))
  {
  }
  ~ServiceDefHookProxy()
  {
  }
};

template <class _InsertStmt>
DBSessionBuilder<_InsertStmt>::DBSessionBuilder() 
	: mProduct(NULL), mRootServiceDef(NULL), mIDGenerator(NULL),mLongIDGenerator(NULL),
		mSessionSetInsert(NULL), mSessionInsert(NULL), mMessageSessionCount(0),
		mMessageSequenceName("id_dbqueuesch"),
		mSessionSetSequenceName("id_dbqueuess"),
		mSessionSequenceName("id_dbqueue")
{ }

template <class _InsertStmt>
void DBSessionBuilder<_InsertStmt>::Initialize(const PipelineInfo& configInfo, CMTCryptoAPI* crypto)
{
	ASSERT(crypto);
	mCrypto = crypto;

	PipelinePropIDs::Init();

	mListenerID = GetListenerID();
	mMeterID = GetMeterID();

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

  ServiceDefHookProxy serviceDefHook;
	MSIXDefCollection::MSIXDefinitionList::iterator it;
	for (it = services.GetDefList().begin(); it != services.GetDefList().end(); ++it)
	{
		DBServiceDef<_InsertStmt>* def = new DBServiceDef<_InsertStmt>(*it);
		mServiceDefs[def->GetID()] = def;
		def->CreateStagingTable(serviceDefHook);
	}

	mIDGenerator = COdbcIdGenerator::GetInstance(COdbcConnectionManager::GetConnectionInfo("NetMeter"));
	mLongIDGenerator = COdbcLongIdGenerator::GetInstance(COdbcConnectionManager::GetConnectionInfo("NetMeter"));

	// creates staging tables if they don't yet exist
  // create t_message (staging) even though it isn't used here because
  // other metering clients may want it.
	CreateStagingTable("t_session_set", "t_session_set");
	CreateStagingTable("t_session", "t_session");
	CreateStagingTable("t_message", "t_message");

	// prepares the t_session_set staging insert statement
	ASSERT(!mSessionSetInsert);
	COdbcConnection* sessionSetConn = new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeterStage"));
	sessionSetConn->SetAutoCommit(true);
	COdbcBcpHints hints;
	hints.SetMinimallyLogged(true);
	sessionSetConn->PrepareInsertStatement(mSessionSetInsert, "t_session_set", hints);

	// prepares the t_session staging insert statement
	ASSERT(!mSessionInsert);
	COdbcConnection* sessionsConn = new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeterStage"));
	sessionsConn->SetAutoCommit(true);
	sessionsConn->PrepareInsertStatement(mSessionInsert, "t_session", hints);
}

template <class _InsertStmt>
DBSessionBuilder<_InsertStmt>::~DBSessionBuilder()
{
	ClearProductState();

	map<int, DBServiceDef<_InsertStmt>*>::const_iterator it;
	for (it = mServiceDefs.begin(); it != mServiceDefs.end(); it++)
		delete it->second;
	mServiceDefs.clear();

  if (mIDGenerator)
  {
    COdbcIdGenerator::ReleaseInstance();
    mIDGenerator = NULL;
  }

  if (mLongIDGenerator)
  {
    COdbcLongIdGenerator::ReleaseInstance();
    mLongIDGenerator = NULL;
  }

	if (mSessionSetInsert)
	{
		// flushes any pending AddBatches
		mSessionSetInsert->ExecuteBatch();

		COdbcConnection* conn =  mSessionSetInsert->GetConnection();
		delete mSessionSetInsert;
		mSessionSetInsert = NULL;
		delete conn;
	}

	if (mSessionInsert)
	{
		// flushes any pending AddBatches
		mSessionInsert->ExecuteBatch();

		COdbcConnection* conn =  mSessionInsert->GetConnection();
		delete mSessionInsert;
		mSessionInsert = NULL;
		delete conn;
	}
}

// clears any product state that the builder maintained
template <class _InsertStmt>
void DBSessionBuilder<_InsertStmt>::ClearProductState()
{
	// resets property tracking
	ClearProperties();

	// clears any product state kept in service defs (session set id, session counts, etc.)
	std::set<DBServiceDef<_InsertStmt>*>::const_iterator it;
	for (it = mLiveServiceDefs.begin(); it != mLiveServiceDefs.end(); it++)
		(*it)->ClearState();
	mLiveServiceDefs.clear();

	if (mProduct)
	{
		delete mProduct;
		mProduct = NULL;
	}

	// flushes any pending AddBatches on the BCP statements
	if (mSessionSetInsert)
		mSessionSetInsert->ExecuteBatch();
	if (mSessionInsert)
		mSessionInsert->ExecuteBatch();

	mRootServiceDef = NULL;
	mServiceDef = NULL;
	mSvcInsert = NULL;
  mMessageSessionCount = 0;
}

template <class _InsertStmt>
void DBSessionBuilder<_InsertStmt>::StartProduction()
{
	ASSERT(!mProduct);

	mProduct = new DBSessionProduct<_InsertStmt>(this);

	TruncateStagingTable("t_session_set");
	TruncateStagingTable("t_session");

	mProduct->mMessageID = mIDGenerator->GetNext(mMessageSequenceName);
}

template <class _InsertStmt>
ISessionProduct * DBSessionBuilder<_InsertStmt>::CompleteProduction()
{
	mProduct->SetLiveServiceDefs(mLiveServiceDefs);

	// inserts all staging data before any DTC work starts
	InsertSessionSetStagingData();
	InsertSvcStagingData();
	InsertSessionStagingData();

	// the client now owns the product
	// they are responsible for freeing it
	ISessionProduct * product = mProduct;
	mProduct = NULL;

	ClearProductState();

	return product;
}

// inserts session set data into t_session_set staging table
template <class _InsertStmt>
void DBSessionBuilder<_InsertStmt>::InsertSessionSetStagingData()
{
	std::set<DBServiceDef<_InsertStmt>*>::const_iterator it;
	for (it = mLiveServiceDefs.begin(); it != mLiveServiceDefs.end(); it++)
	{
		DBServiceDef<_InsertStmt>* serviceDef = *it;

		//mSessionSetInsert->BeginBatch();

		mSessionSetInsert->SetInteger(1, mProduct->mMessageID);          // id_message
		mSessionSetInsert->SetInteger(2, serviceDef->GetSessionSetID()); // id_ss
		mSessionSetInsert->SetInteger(3, serviceDef->GetID());           // id_svc

		if (serviceDef == mRootServiceDef)                               // b_root
			mSessionSetInsert->SetString(4, "1");              
		else
			mSessionSetInsert->SetString(4, "0");

		mSessionSetInsert->SetInteger(5, serviceDef->GetSessionCount()); // session_count

		mSessionSetInsert->AddBatch();
	}

	mSessionSetInsert->ExecuteBatch();
}

// inserts root and children data into t_svc staging tables
template <class _InsertStmt>
void DBSessionBuilder<_InsertStmt>::InsertSvcStagingData()
{
	std::set<DBServiceDef<_InsertStmt>*>::const_iterator it;
	for (it = mLiveServiceDefs.begin(); it != mLiveServiceDefs.end(); it++)
	{
		DBServiceDef<_InsertStmt>* serviceDef = *it;
		_InsertStmt* svcInsert = serviceDef->GetStatement();
		svcInsert->ExecuteBatch();
	}
}

// inserts session data into t_session staging table
template <class _InsertStmt>
void DBSessionBuilder<_InsertStmt>::InsertSessionStagingData()
{
	mSessionInsert->ExecuteBatch();
}


template <class _InsertStmt>
void DBSessionBuilder<_InsertStmt>::AbortProduction()
{
	// rolls back the listener transaction if it is set (CR13891)
	if (mProduct && !mProduct->mListenerTransactionID.empty())
	{
		MTPipelineLib::IMTTransactionPtr tran(MTPROGID_MTTRANSACTION);
		tran->Import(mProduct->mListenerTransactionID.c_str());

		// rollback needs to occur even if no database work has
		// been done by the listener. this lets parsing validation errors
		// rollback other work in the external DTC transaction
		tran->Rollback();
	}

	ClearProductState();
}

template <class _InsertStmt>
void DBSessionBuilder<_InsertStmt>::CreateSession(const unsigned char * uid, int serviceDefID)
{
	// caches root service def for fast lookup for the remainder of this product
	if (!mRootServiceDef)
	{
		mRootServiceDef = mServiceDefs[serviceDefID];

		// adds the service def to the live set
		mLiveServiceDefs.insert(mRootServiceDef);

		int sessionSetID = mIDGenerator->GetNext(mSessionSetSequenceName);
		mRootServiceDef->SetSessionSetID(sessionSetID);

		TruncateStagingTable(mRootServiceDef->GetStageTableName());
	}
	mServiceDef = mRootServiceDef;

	// parser now enforces all root sessions are of the same type
	ASSERT(mRootServiceDef->GetID() == serviceDefID);

	// generates a new session ID from the database (this will be the UID from now on)
	__int64 sessionID = mLongIDGenerator->GetNext(mSessionSequenceName);
	memset(mRootSessionIDBuffer, 0, UID_LENGTH);
	mRootSessionIDBuffer[UID_LENGTH - 8] = ((unsigned char *) &sessionID)[7];
	mRootSessionIDBuffer[UID_LENGTH - 7] = ((unsigned char *) &sessionID)[6];
	mRootSessionIDBuffer[UID_LENGTH - 6] = ((unsigned char *) &sessionID)[5];
	mRootSessionIDBuffer[UID_LENGTH - 5] = ((unsigned char *) &sessionID)[4];
	mRootSessionIDBuffer[UID_LENGTH - 4] = ((unsigned char *) &sessionID)[3];
	mRootSessionIDBuffer[UID_LENGTH - 3] = ((unsigned char *) &sessionID)[2];
	mRootSessionIDBuffer[UID_LENGTH - 2] = ((unsigned char *) &sessionID)[1];
	mRootSessionIDBuffer[UID_LENGTH - 1] = ((unsigned char *) &sessionID)[0];
	
	// inserts into t_svc table
	mSvcInsert = mServiceDef->GetStatement();
	//mSvcInsert->BeginBatch();
	mSvcInsert->SetBinary(1, mRootSessionIDBuffer, UID_LENGTH); // id_source_sess

	// The pipeline must generate feedback with these original client UIDs.
	// This is important so that the SDK can correctly match up responses with requests.
	// The rest of the product could care less about these UIDs. We always insert them
	// though because it is easier to do (<feedback> tag comes after the 
	// <beginsession> tag) and doesn't cost much.
	mSvcInsert->SetBinary(3, uid, UID_LENGTH); // id_external

	// inserts into t_session table
	AddSession(mServiceDef->GetSessionSetID(), mRootSessionIDBuffer);
	
}

template <class _InsertStmt>
inline void DBSessionBuilder<_InsertStmt>::CreateChildSession(const unsigned char * uid,
																								 int serviceDefID,
																								 const unsigned char * parentUID)
{
	// TODO: recursive compound check should be in genparser
	ASSERT(mRootServiceDef->GetID() != serviceDefID);

	mServiceDef = mServiceDefs[serviceDefID];

	// have we seen this child type before?
	std::set<DBServiceDef<_InsertStmt>*>::const_iterator it;
	it = mLiveServiceDefs.find(mServiceDef);
	if (it == mLiveServiceDefs.end())
	{
		// not yet seen, adds it to the live set
		mLiveServiceDefs.insert(mServiceDef);

		int sessionSetID = mIDGenerator->GetNext(mSessionSetSequenceName);
		mServiceDef->SetSessionSetID(sessionSetID);

		TruncateStagingTable(mServiceDef->GetStageTableName());
	}

	// generates a new session ID from the database (this will be the UID from now on)
	__int64 sessionID = mLongIDGenerator->GetNext(mSessionSequenceName);
	unsigned char sessionIDBuffer[UID_LENGTH];
	memset(sessionIDBuffer, 0, UID_LENGTH);
	sessionIDBuffer[UID_LENGTH - 8] = ((unsigned char *) &sessionID)[7];
	sessionIDBuffer[UID_LENGTH - 7] = ((unsigned char *) &sessionID)[6];
	sessionIDBuffer[UID_LENGTH - 6] = ((unsigned char *) &sessionID)[5];
	sessionIDBuffer[UID_LENGTH - 5] = ((unsigned char *) &sessionID)[4];
	sessionIDBuffer[UID_LENGTH - 4] = ((unsigned char *) &sessionID)[3];
	sessionIDBuffer[UID_LENGTH - 3] = ((unsigned char *) &sessionID)[2];
	sessionIDBuffer[UID_LENGTH - 2] = ((unsigned char *) &sessionID)[1];
	sessionIDBuffer[UID_LENGTH - 1] = ((unsigned char *) &sessionID)[0];

	// inserts into t_svc table
	mSvcInsert = mServiceDef->GetStatement();
	//mSvcInsert->BeginBatch();
	mSvcInsert->SetBinary(1, sessionIDBuffer, UID_LENGTH);       // id_source_sess
	mSvcInsert->SetBinary(2, mRootSessionIDBuffer, UID_LENGTH);  // id_parent_source_sess
	mSvcInsert->SetBinary(3, uid, UID_LENGTH); // tx_external

	// inserts into t_session table
	AddSession(mServiceDef->GetSessionSetID(), sessionIDBuffer);
}

template <class _InsertStmt>
inline void DBSessionBuilder<_InsertStmt>::AddLongSessionProperty(long propertyID, long value)
{	
	// TODO: why is there no SetLong?? precission is being lost
  mSvcInsert->SetInteger(mServiceDef->GetColumnOffset(propertyID), value);	
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionBuilder<_InsertStmt>::AddDoubleSessionProperty(long propertyID, double value)
{	
	// converts double to decimal
	_variant_t variant(value);
	DECIMAL decVal = (DECIMAL) variant;
	SQL_NUMERIC_STRUCT numeric;

	// stores double as decimal in the database
	DecimalToOdbcNumeric(&decVal, &numeric);
  mSvcInsert->SetDecimal(mServiceDef->GetColumnOffset(propertyID), numeric);	
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionBuilder<_InsertStmt>::AddTimestampSessionProperty(long propertyID, time_t value)
{	
	TIMESTAMP_STRUCT timestamp;
	TimetToOdbcTimestamp(&value, &timestamp);
  mSvcInsert->SetDatetime(mServiceDef->GetColumnOffset(propertyID), timestamp);	
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionBuilder<_InsertStmt>::AddBoolSessionProperty(long propertyID, bool value)
{	
  mSvcInsert->SetString(mServiceDef->GetColumnOffset(propertyID), value ? "1" : "0");	
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionBuilder<_InsertStmt>::AddEnumSessionProperty(long propertyID, long value)
{	
	// TODO: precision? 
  mSvcInsert->SetInteger(mServiceDef->GetColumnOffset(propertyID), value);	
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionBuilder<_InsertStmt>::AddStringSessionProperty(long propertyID, const wchar_t* value)
{	

	// converts the encoded batch UID (_CollectionID special property) to binary
	if (propertyID == PipelinePropIDs::CollectionIDCode())
	{
		// TODO: this could be hashed for future lookup
		std::string batchUIDEncoded((char *) _bstr_t(value));
		unsigned char batchUID[UID_LENGTH];
		if (!MSIXUidGenerator::Decode(batchUID, batchUIDEncoded))
			throw MTException("Could not decode batch UID!");

		mSvcInsert->SetBinary(mServiceDef->GetColumnOffset(propertyID), batchUID, UID_LENGTH);	
		RecordProperty(propertyID);
		return;
	}

	// TODO: length of string should be passed in from parser
  mSvcInsert->SetWideString(mServiceDef->GetColumnOffset(propertyID), std::wstring(value));	
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionBuilder<_InsertStmt>::AddEncryptedStringSessionProperty(long propertyID, const wchar_t* value)
{	
	std::string cipherText;
  if(!::WideStringToUTF8(value, cipherText))
		throw MTException("Failed to convert wide string to UTF8!");

	// encrypts and uuencodes string
	int result;
	result = mCrypto->Encrypt(cipherText);
	if (result != 0)
	{
		std::string msg = "Failed to encrypt property! propid=" + propertyID;
		throw MTException(msg.c_str());
	}

	_bstr_t wideCipherText(cipherText.c_str());
  mSvcInsert->SetWideString(mServiceDef->GetColumnOffset(propertyID),
														(wchar_t*) wideCipherText,
														wideCipherText.length());	
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionBuilder<_InsertStmt>::AddDecimalSessionProperty(long propertyID, DECIMAL value)
{	
	SQL_NUMERIC_STRUCT numeric;
	DecimalToOdbcNumeric(&value, &numeric);
  mSvcInsert->SetDecimal(mServiceDef->GetColumnOffset(propertyID), numeric);	
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline void DBSessionBuilder<_InsertStmt>::AddLongLongSessionProperty(long propertyID, __int64 value)
{	
  mSvcInsert->SetBigInteger(mServiceDef->GetColumnOffset(propertyID), value);	
	RecordProperty(propertyID);
}

template <class _InsertStmt>
inline bool DBSessionBuilder<_InsertStmt>::SessionPropertyExists(long propertyID)
{
	return PropertyExists(propertyID);
}

template <class _InsertStmt>
inline void DBSessionBuilder<_InsertStmt>::CompleteSession()
{
	mSvcInsert->AddBatch();
	
  // If we have filled up the client buffer for the service def, flush it.
  if (mServiceDef->GetSessionCount() % 1000 == 0)
  {
    mSvcInsert->ExecuteBatch();
  }

	// resets property tracking for the next session
	ClearProperties();
}

// creates a staging table if it doesn't exist
template <class _InsertStmt>
void DBSessionBuilder<_InsertStmt>::CreateStagingTable(const std::string& tableName, const std::string& srcTableName)
{
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(L"Queries\\Pipeline");
    rowset->SetQueryTag("__CREATE_STAGING_TABLE__");
		rowset->AddParam("%%TABLE%%", _bstr_t(tableName.c_str()));
		rowset->AddParam("%%SOURCETABLE%%", _bstr_t(srcTableName.c_str()));
    rowset->Execute();
}

// truncates a staging table
template <class _InsertStmt>
void DBSessionBuilder<_InsertStmt>::TruncateStagingTable(const std::string& tableName)
{
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init(L"Queries\\Pipeline");
	rowset->SetQueryTag("__TRUNCATE_STAGING_TABLE__");
	rowset->AddParam("%%TABLE%%", _bstr_t(tableName.c_str()));
	rowset->Execute();
}

// adds a batch to be inserted into t_session
template <class _InsertStmt>
void DBSessionBuilder<_InsertStmt>::AddSession(int sessionSetID, const unsigned char * sessionUID)
{
	ASSERT(sessionSetID != -1);

	//mSessionInsert->BeginBatch();

	mSessionInsert->SetInteger(1, sessionSetID);           // id_ss
	mSessionInsert->SetBinary(2, sessionUID, UID_LENGTH);  // id_source_ss

	mSessionInsert->AddBatch();

  // If we have filled up the session client buffer, flush it.
  if (0 == (++mMessageSessionCount) % 1000)
  {
    mSessionInsert->ExecuteBatch();
  }

	mServiceDef->IncrementSessionCount();
}

template <class _InsertStmt>
int DBSessionBuilder<_InsertStmt>::GetListenerID()
{
  ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
  rowset->Init(L"Queries\\Pipeline");
  rowset->SetQueryTag(L"__GET_LISTENER_ID__");
  rowset->AddParam(L"%%TX_MACHINE%%", ::GetNTHostName());
  rowset->Execute();

	if(rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
		throw MTException("Could not retrieve listener ID!");

	int listenerID = (long) _variant_t(rowset->GetValue("id_listener"));
	return listenerID;
}

template <class _InsertStmt>
int DBSessionBuilder<_InsertStmt>::GetMeterID()
{
	std::string configDir;
	if (!GetMTConfigDir(configDir))
		throw MTException("Couldn't read config dir!");

	// reads the listener configuration file
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	ListenerInfoReader listenerReader;
	ListenerInfo info;
	if (!listenerReader.ReadConfiguration(config, configDir.c_str(), info))
		throw listenerReader.GetLastError();

	MTPipelineLib::IMTNameIDPtr nameID(MTPROGID_NAMEID);
	return nameID->GetNameID(info.GetMeterName().c_str());
}



//
// DBServiceDef
//

template <class _InsertStmt>
DBServiceDef<_InsertStmt>::DBServiceDef(CMSIXDefinition* def) :
	mInsert(NULL), mSessionSetID(-1), mSessionCount(0)
{
	mName = (const char *) _bstr_t(def->GetName().c_str());

  NAMEIDLib::IMTNameIDPtr nameID(MTPROGID_NAMEID);
	mID = nameID->GetNameID(mName.c_str());

	mTableName = ascii(def->GenerateTableName(L"t_svc_"));
	mStageTableName = ascii(def->GenerateTableName(L"t_svc_"));

	// creates a map between prop IDs and column indices
	MSIXPropertiesList & props = def->GetMSIXPropertiesList();
	MSIXPropertiesList::iterator it;

	// first user-defined data column starts at index 4
	// 1 id_source_sess
	// 2 id_parent_source_sess
	// 3 id_external
	mColumnList = "id_source_sess, id_parent_source_sess, id_external, ";

	int i = 4; 
	for (it = props.begin(); it != props.end(); ++it, i++)
	{
		CMSIXProperties* serviceProp = *it;

		int propID = nameID->GetNameID(serviceProp->GetDN().c_str());
		mPropertyToColumnOffsetMap[propID] = i;

		string columnName = ascii(serviceProp->GetColumnName());
		mPropertyToColumnNameMap[propID] = columnName;
		mColumnList += columnName + ", ";
	}

	//
	// remaining columns are special properties included in all t_svc tables
	//
	std::string intervalColumnName;
	intervalColumnName = "c_";
	intervalColumnName += MT_INTERVALID_PROP_A;
	mPropertyToColumnOffsetMap[PipelinePropIDs::IntervalIdCode()] = i++;
	mPropertyToColumnNameMap[PipelinePropIDs::IntervalIdCode()] = intervalColumnName;
	mColumnList += "c_";
	mColumnList += MT_INTERVALID_PROP_A;
	mColumnList += ", ";

	std::string cookieColumnName;
	cookieColumnName = "c_" ;
	cookieColumnName += MT_TRANSACTIONCOOKIE_PROP_A;
	mPropertyToColumnOffsetMap[PipelinePropIDs::TransactionCookieCode()] = i++;
	mPropertyToColumnNameMap[PipelinePropIDs::TransactionCookieCode()] = cookieColumnName;
	mColumnList += "c_";
	mColumnList += MT_TRANSACTIONCOOKIE_PROP_A;
	mColumnList += ", ";

	std::string resubmitColumnName;
	resubmitColumnName = "c_" ;
	resubmitColumnName += MT_RESUBMIT_PROP_A;
	mPropertyToColumnOffsetMap[PipelinePropIDs::ResubmitCode()] = i++;
	mPropertyToColumnNameMap[PipelinePropIDs::ResubmitCode()] = resubmitColumnName;
	mColumnList += "c_";
	mColumnList += MT_RESUBMIT_PROP_A;
	mColumnList += ", ";

	std::string collectionColumnName;
	collectionColumnName = "c_";
	collectionColumnName += MT_COLLECTIONID_PROP_A;
	mPropertyToColumnOffsetMap[PipelinePropIDs::CollectionIDCode()] = i++;
	mPropertyToColumnNameMap[PipelinePropIDs::CollectionIDCode()] = collectionColumnName;
	mColumnList += "c_";
	mColumnList += MT_COLLECTIONID_PROP_A;
	
	// retrieves staging database settings
	mStagingDBInfo = COdbcConnectionManager::GetConnectionInfo("NetMeterStage");
	mIsOracle = (mStagingDBInfo.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);
}


// creates the statement to insert into the appropriate t_svc table
// NOTE: statements now live for the duration of the builder (not the product)
template <class _InsertStmt>
void DBServiceDef<_InsertStmt>::CreateStatement()
{
	COdbcConnection* connection = new COdbcConnection(mStagingDBInfo);

	// use BCP inserts for SQL Server and Array Inserts for Oracle
	connection->SetAutoCommit(true);
	COdbcBcpHints hints;
	hints.SetMinimallyLogged(true);
	connection->PrepareInsertStatement(mInsert, mStageTableName, hints, 1000);
}

// clears stateful information having to do with the current product
template <class _InsertStmt>
void DBServiceDef<_InsertStmt>::ClearState()
{
	if (mInsert)
	{
		// flushes any pending AddBatches
		mInsert->ExecuteBatch();
	}

	mSessionSetID = -1;
	mSessionCount = 0;
}

// creates the t_svc staging table if it is missing
// NOTE: the only difference between the staging table and the non-staging table is that
// the staging table has no non-null constraints. this is important for dealing with
// non-required properties.
template <class _InsertStmt>
void DBServiceDef<_InsertStmt>::CreateStagingTable(ServiceDefHookProxy & serviceDefHook)
{
	// TODO: this functionallity should be broken out of the hook
	BSTR bname;
	_bstr_t createQuery = serviceDefHook.ServiceDefHook->GenerateStagingCreateTableStatement(mName.c_str(), &bname);
	_bstr_t name(bname);
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init(L"Queries\\Pipeline");
	rowset->ChangeDbName(mStagingDBInfo.GetCatalog().c_str());
	rowset->SetQueryTag("__CREATE_SVC_STAGING_TABLE__");
	rowset->AddParam("%%TABLE%%", name);
	rowset->AddParam("%%CREATE_STATEMENT%%", createQuery, true);	
	rowset->Execute();
}

template <class _InsertStmt>
DBServiceDef<_InsertStmt>::~DBServiceDef()
{
	// performs a final flush on the BCP connection
	ClearState();

	if (mInsert)
	{
		COdbcConnection* connection = mInsert->GetConnection();

		// statements must be destroyed before the connection
		delete mInsert;
		mInsert = NULL;

		delete connection;
		connection = NULL;
	}

	ASSERT(!mInsert);
}




//
// DBSessionProduct
//

template <class _InsertStmt>
DBSessionProduct<_InsertStmt>::DBSessionProduct(DBSessionBuilder<_InsertStmt>* builder) 
	: mBuilder(builder), mMessageID(-1),
		mSynchronous(false) // messages are asynchronous by default
{ }

template <class _InsertStmt>
DBSessionProduct<_InsertStmt>::~DBSessionProduct()
{ }

template <class _InsertStmt>
void DBSessionProduct<_InsertStmt>::SpoolMessage()
{
	ASSERT(mMessageID != -1);

	MTPipelineLib::IMTTransactionPtr tran(MTPROGID_MTTRANSACTION);
	try
	{
		// imports an external DTC transaction if the ListenerTransactionID property on
		// the session set was sent, otherwise creates a new DTC transaction.
		if (!mListenerTransactionID.empty())
			tran->Import(mListenerTransactionID.c_str());
		else
			tran->Begin("MetraTech Listener TXN", tran->GetDefaultTimeout());

		// joins in the rowset
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(L"Queries\\Pipeline");
		rowset->JoinDistributedTransaction((ROWSETLib::IMTTransaction *) tran.GetInterfacePtr());
		
		//
		// inserts data into final routing tables
		//

		std::set<DBServiceDef<_InsertStmt>*>::const_iterator it;
		for (it = mLiveServiceDefs.begin(); it != mLiveServiceDefs.end(); it++)
			CopySvcDataFromStaging(*it, rowset); 

		CopySessionDataFromStaging(rowset);

		CopySessionSetDataFromStaging(rowset);

		InsertMessageData(rowset);


		// only commits the transaction if we started it
		if (mListenerTransactionID.size() == 0)
			tran->Commit();
	}
	catch(...)
	{
		tran->Rollback();
		throw;
	}
}

template <class _InsertStmt>
void DBSessionProduct<_InsertStmt>::GetMessageUID(std::string& encodedUID)
{
	unsigned char uidBuffer[16];
	memset(uidBuffer, 0, 16);
	memcpy(uidBuffer, &mMessageID, 4);
	
	MSIXUidGenerator::Encode(encodedUID, uidBuffer);
};

template <class _InsertStmt>
void DBSessionProduct<_InsertStmt>::InsertMessageData(ROWSETLib::IMTSQLRowsetPtr rowset)
{
	rowset->SetQueryTag("__INSERT_MESSAGE_VIA_LISTENER__");
	rowset->AddParam("%%ID_MESSAGE%%", mMessageID);
	rowset->AddParam("%%ID_LISTENER%%", mBuilder->mListenerID);
	rowset->AddParam("%%TX_IP_ADDRESS%%", mIPAddress.c_str());

	DATE vtDate;
	OleDateFromTimet(&vtDate, mMeteredTime);
	rowset->AddParam("%%DT_METERED%%", _variant_t(vtDate, VT_DATE));
	
	// only inserts feedback ID if  message was sent synchronously
	if (mSynchronous)
		rowset->AddParam("%%ID_FEEDBACK%%", mBuilder->mMeterID);
	else
		rowset->AddParam("%%ID_FEEDBACK%%", "NULL");


	// adds the transaction ID if one was sent
	if (mTransactionID.length() > 0)
	{
		std::wstring value = ValidateString((const wchar_t*) _bstr_t(mTransactionID.c_str()));
		value = L"'" + value + L"'";
		rowset->AddParam("%%TX_TRANSACTIONID%%", value.c_str(), VARIANT_TRUE);
	}
	else
		rowset->AddParam("%%TX_TRANSACTIONID%%", "NULL");


	//
	// adds the session context parameters, if any
	//
	if (mSessionContextUsername.length() > 0)
	{
		std::wstring value = ValidateString((const wchar_t*) _bstr_t(mSessionContextUsername.c_str()));
		value = L"'" + value + L"'";
		rowset->AddParam("%%TX_SC_USERNAME%%", value.c_str(), VARIANT_TRUE);
	}
	else
		rowset->AddParam("%%TX_SC_USERNAME%%", "NULL");

	if (mSessionContextPassword.length() > 0)
	{
		std::wstring value = ValidateString((const wchar_t*) _bstr_t(mSessionContextPassword.c_str()));
		value = L"'" + value + L"'";
		rowset->AddParam("%%TX_SC_PASSWORD%%", value.c_str(), VARIANT_TRUE);
	}
	else
		rowset->AddParam("%%TX_SC_PASSWORD%%", "NULL");

	if (mSessionContextNamespace.length() > 0)
	{
		std::wstring value = ValidateString((const wchar_t*) _bstr_t(mSessionContextNamespace.c_str()));
		value = L"'" + value + L"'";
		rowset->AddParam("%%TX_SC_NAMESPACE%%", value.c_str(), VARIANT_TRUE);
	}
	else
		rowset->AddParam("%%TX_SC_NAMESPACE%%", "NULL");

	if (mSerializedSessionContext.length() > 0)
	{
		std::wstring value = ValidateString((const wchar_t*) _bstr_t(mSerializedSessionContext.c_str()));
		value = L"'" + value + L"'";
		rowset->AddParam("%%TX_SC_SERIALIZED%%", value.c_str(), VARIANT_TRUE);
	}
	else
		rowset->AddParam("%%TX_SC_SERIALIZED%%", "NULL");

	rowset->Execute();
}

template <class _InsertStmt>
void DBSessionProduct<_InsertStmt>::CopySessionSetDataFromStaging(ROWSETLib::IMTSQLRowsetPtr rowset)
{
	rowset->SetQueryTag("__COPY_SESSION_SET_DATA_FROM_STAGING__");
	rowset->Execute();
}

template <class _InsertStmt>
void DBSessionProduct<_InsertStmt>::CopySvcDataFromStaging(const DBServiceDef<_InsertStmt>* def, ROWSETLib::IMTSQLRowsetPtr rowset)
{
	rowset->SetQueryTag("__COPY_SVC_DATA_FROM_STAGING__");
	rowset->AddParam("%%TABLE%%", def->GetTableName().c_str());
	rowset->AddParam("%%STAGETABLE%%", def->GetStageTableName().c_str());
	rowset->AddParam("%%COLUMNS%%", def->GetColumnList().c_str());
	rowset->Execute();
}

template <class _InsertStmt>
void DBSessionProduct<_InsertStmt>::CopySessionDataFromStaging(ROWSETLib::IMTSQLRowsetPtr rowset)
{
	rowset->SetQueryTag("__COPY_SESSION_DATA_FROM_STAGING__");
	rowset->Execute();
}

// explicit instantiation - so all the impl doesn't have to be in the header
template class DBServiceDef<COdbcPreparedArrayStatement>;
template class DBServiceDef<COdbcPreparedBcpStatement>;

template class DBSessionBuilder<COdbcPreparedArrayStatement>;
template class DBSessionBuilder<COdbcPreparedBcpStatement>;

template class DBSessionProduct<COdbcPreparedArrayStatement>;
template class DBSessionProduct<COdbcPreparedBcpStatement>;

