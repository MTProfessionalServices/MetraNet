/**************************************************************************
 * @doc SESSIONBUILDER
 *
 * @module |
 *
 *
 * Copyright 2004 by MetraTech Corporation
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | SESSIONBUILDER
 ***************************************************************************/

#ifndef _SESSIONBUILDER_H
#define _SESSIONBUILDER_H

#ifdef WIN32
#pragma once
#endif

#include <metra.h>
#include <errobj.h>
#include <set>
#include <vector>

#import <MTConfigLib.tlb>
#include <pipelineconfig.h>
#include <MTSessionServerBaseDef.h>
#include <MTSessionBaseDef.h>
#include <mtcryptoapi.h>
#include <MSIXDefinition.h>
#include <autoptr.h>

#include <OdbcConnection.h>
#include <OdbcBatchIDWriter.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcIdGenerator.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcConnMan.h>
#include <OdbcException.h>
#include <OdbcStatement.h>

typedef MTautoptr<COdbcStatement> COdbcStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcBatchIDWriter> COdbcBatchIDWriterPtr;
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;

// base class of all builders' products
// concrete products differ radically
class ISessionProduct {};


//
// abstract interface of a session builder
//

// NOTE: since builders are used as template arguments deriving
//       from this interface is not necessary, the compiler will 
//       enforce the interface
class ISessionBuilder
{
public:
	// administrative operations
	virtual void Initialize(const PipelineInfo & configInfo, CMTCryptoAPI * apCrypto) = 0;
	virtual void StartProduction() = 0;
	virtual ISessionProduct* CompleteProduction() = 0;
	virtual void AbortProduct() = 0;
	virtual void Dispose() = 0;

	// session level operations
	virtual void CreateSession(const unsigned char * uid, int serviceDefID) = 0;
	virtual void CreateChildSession(const unsigned char * uid, int serviceDefID, const unsigned char * parentUID) = 0;
	virtual void AddLongSessionProperty(long propertyID, long value) = 0;
	virtual void AddDoubleSessionProperty(long propertyID, double value) = 0;
	virtual void AddTimestampSessionProperty(long propertyID, time_t value) = 0;
	virtual void AddBoolSessionProperty(long propertyID, bool value) = 0;
	virtual void AddEnumSessionProperty(long propertyID, int value) = 0;
	virtual void AddStringSessionProperty(long propertyID, const wchar_t* value) = 0;
	virtual void AddEncryptedStringSessionProperty(long propertyID, const wchar_t* value) = 0;
	virtual void AddDecimalSessionProperty(long propertyID, DECIMAL value) = 0;
	virtual bool SessionPropertyExists(long propertyID) = 0;
	virtual void CompleteSession() = 0;
	
  // message level operations
	virtual void SetMeteredTime(time_t time) = 0;
	virtual void SetSynchronous(bool value) = 0;
	virtual void SetTransactionID(const char* transactionID) = 0;
	virtual void SetListenerTransactionID(const char* transactionID) = 0;
	virtual void SetSessionContextUsername(const char* userName) = 0;
	virtual void SetSessionContextPassword(const char* password) = 0;
	virtual void SetSessionContextNamespace(const char* name_space) = 0;
	virtual void SetSerializedSessionContext(const char* context) = 0;
	virtual void SetIPAddress(const char* address) = 0;
};



// forward declaration
class SharedMemorySessionBuilder;

//
// concrete product of the SharedMemorySessionBuilder
//
class SharedMemorySessionProduct : public ISessionProduct
{
public:

	// the current builder must be passed in because
	// access is needed to the session server
	SharedMemorySessionProduct(SharedMemorySessionBuilder * apBuilder) 
		: mHasOwnership(true), mBuilder(apBuilder)
	{ };

	~SharedMemorySessionProduct();

	// returns a vector of COM-wrapped sessions
	// ownership of the sessions is passed on to the caller at this point
	void GetSessions(std::vector<MTPipelineLib::IMTSessionPtr> & arSessions);

private:
	friend class SharedMemorySessionBuilder;

	// adds a new session to the product
	void AddSession(CMTSessionBase * apSession)
	{
		mSessions.push_back(apSession);	
	}

private:
	SharedMemorySessionBuilder * mBuilder;

	// list of all sessions found within the message
	std::vector<CMTSessionBase *> mSessions;
	
	// keeps track of whether this class has ownership of the sessions
	bool mHasOwnership;
};



//
// a shared memory session builder
//
class SharedMemorySessionBuilder
{
public:
	SharedMemorySessionBuilder();
	~SharedMemorySessionBuilder();

	// TODO: methods are virtual for now for proper linkage, they should be inlined
	virtual void Initialize(const PipelineInfo & configInfo, CMTCryptoAPI * apCrypto);
	virtual void StartProduction();
	virtual ISessionProduct * CompleteProduction();
	virtual void AbortProduction();

	virtual void CreateSession(const unsigned char * uid, int serviceDefID);
	virtual void CreateChildSession(const unsigned char * uid, int serviceDefID, const unsigned char * parentUID);
	virtual void AddLongSessionProperty(long propertyID, long value);
	virtual void AddDoubleSessionProperty(long propertyID, double value);
	virtual void AddTimestampSessionProperty(long propertyID, time_t value);
	virtual void AddBoolSessionProperty(long propertyID, bool value);
	virtual void AddEnumSessionProperty(long propertyID, long value);
	virtual void AddStringSessionProperty(long propertyID, const wchar_t* value);
	virtual void AddEncryptedStringSessionProperty(long propertyID, const wchar_t* value);
	virtual void AddDecimalSessionProperty(long propertyID, DECIMAL value);
	virtual void AddLongLongSessionProperty(long propertyID, __int64 value);
	
	virtual bool SessionPropertyExists(long propertyID);
	virtual void CompleteSession();

	virtual void SetMeteredTime(time_t time) { };
	virtual void SetSynchronous(bool value) { };
	virtual void SetTransactionID(const char* transactionID) { };
	virtual void SetListenerTransactionID(const char* transactionID) { };
	virtual void SetSessionContextUsername(const char* username) { };
	virtual void SetSessionContextPassword(const char* password) { };
	virtual void SetSessionContextNamespace(const char* name_space) { };
	virtual void SetSerializedSessionContext(const char* context) { };
	virtual void SetIPAddress(const char* address) { };

private:
	friend class  SharedMemorySessionProduct;

  // returns the COM session server
	MTPipelineLib::IMTSessionServerPtr GetCOMSessionServer()
	{ return mCOMSessionServer;	}

protected:

	//
	// methods to help keep track of properties
	//
	void RecordProperty(long propertyID)
	{	mSessionProps.insert(propertyID);	}

	bool PropertyExists(long propertyID)
	{
		std::set<int>::iterator findIt;
		findIt = mSessionProps.find(propertyID);
		return (findIt != mSessionProps.end());
	}

	void ClearProperties()
	{ mSessionProps.clear(); }


	// frees shared sessions and other memory
	void Clear();

private:

	// tracks what properties have currently been set in session
	// all Add*SessionProperty methods should insert into it on success
	// CompleteSession should clear it
	std::set<int> mSessionProps;

	// current session being operated on
	CMTSessionBase * mpSession;

	// current product being constructed
	SharedMemorySessionProduct * mpProduct;

	CMTSessionServerBase * mpSessionServer;

	// COM session server is needed to get sessions 
	// as MTPipelineLib::IMTSessionPtr objects
	MTPipelineLib::IMTSessionServerPtr mCOMSessionServer;

  CMTCryptoAPI * mpCrypto;
};



//
// a null session builder
//

// used for a parse needing only pure validation
// calls are essentially no-ops except for tracking in session properties
// NullSessionBuilder is used by the classic listener for validation
class NullSessionBuilder
{
public:
	NullSessionBuilder() {;}
	~NullSessionBuilder() {;}

	// TODO: methods are virtual for now for proper linkage, they should be inlined

	virtual void Initialize(const PipelineInfo & configInfo, CMTCryptoAPI * apCrypto) {;}
	virtual void StartProduction() {;}
	virtual ISessionProduct* CompleteProduction() { return NULL; }
	virtual void AbortProduction() {;}

	virtual void CreateSession(const unsigned char * uid, int serviceDefID) {;}
	virtual void CreateChildSession(const unsigned char * uid, int serviceDefID, const unsigned char * parentUID) {;}

	virtual void AddLongSessionProperty(long propertyID, long value)
	{ RecordProperty(propertyID); }
	virtual void AddDoubleSessionProperty(long propertyID, double value)
	{ RecordProperty(propertyID); }
	virtual void AddTimestampSessionProperty(long propertyID, time_t value)
	{ RecordProperty(propertyID); }
	virtual void AddBoolSessionProperty(long propertyID, bool value)
	{ RecordProperty(propertyID); }
	virtual void AddEnumSessionProperty(long propertyID, long value)
	{ RecordProperty(propertyID); }
	virtual void AddStringSessionProperty(long propertyID, const wchar_t* value)
	{ RecordProperty(propertyID); }
	virtual void AddEncryptedStringSessionProperty(long propertyID, const wchar_t* value)
	{ RecordProperty(propertyID); }
	virtual void AddDecimalSessionProperty(long propertyID, DECIMAL value)
	{ RecordProperty(propertyID); }
	virtual void AddLongLongSessionProperty(long propertyID, __int64 value)
	{ RecordProperty(propertyID); }
	
	virtual bool SessionPropertyExists(long propertyID)
	{ return PropertyExists(propertyID); }
	virtual void CompleteSession() 
	{ ClearProperties(); }

	virtual void SetMeteredTime(time_t time) { };
	virtual void SetSynchronous(bool value) { };
	virtual void SetTransactionID(const char* transactionID) { };
	virtual void SetListenerTransactionID(const char* transactionID) { };
	virtual void SetSessionContextUsername(const char * username) { };
	virtual void SetSessionContextPassword(const char * password) { };
	virtual void SetSessionContextNamespace(const char * name_space) { };
	virtual void SetSerializedSessionContext(const char * context) { };
	virtual void SetIPAddress(const char* address) { };

private:

	//
	// methods to help keep track of properties
	//
	void RecordProperty(long propertyID)
	{	mSessionProps.insert(propertyID);	}

	bool PropertyExists(long propertyID)
	{
		std::set<int>::iterator findIt;
		findIt = mSessionProps.find(propertyID);
		return (findIt != mSessionProps.end());
	}

	void ClearProperties()
	{ mSessionProps.clear(); }

private:

	// tracks what properties have currently been set in session
	// all Add*SessionProperty methods should insert into it on success
	// CompleteSession should clear it
	std::set<int> mSessionProps;
};



template <class _InsertStmt> 
class DBServiceDef
{
public:
	DBServiceDef(CMSIXDefinition* def);
	~DBServiceDef();
	
	const std::string& GetName() const
	{
		return mName;
	}

	int GetID() const
	{
		return mID;
	}

	const std::string& GetTableName() const
	{
		return mTableName;
	}
	
	const std::string& GetStageTableName() const
	{
		return mStageTableName;
	}
	
	int GetColumnOffset(int propertyID) const
	{
		// TODO: need a faster lookup mechanism?
		map<int, int>::const_iterator it = mPropertyToColumnOffsetMap.find(propertyID);
		if (it == mPropertyToColumnOffsetMap.end())
		{
			std::string msg = "Staging table column offset not known for property '";
			msg += propertyID;
			msg += "' in table '" + mTableName + "'! Perhaps service definitions are not synchronized?";
			throw MTException(msg);
		}
		
		return it->second;
	}

	const std::string& GetColumnName(int propertyID) const
	{
		// TODO: need a faster lookup mechanism?
		map<int, std::string>::const_iterator it = mPropertyToColumnNameMap.find(propertyID);
		if (it == mPropertyToColumnNameMap.end())
		{
			std::string msg = "Staging table column name not known for property '";
			msg += propertyID;
			msg += "' in table '" + mTableName + "'! Perhaps service definitions are not synchronized?";
			throw MTException(msg);
		}
		
		return it->second;
	}
	
	const std::string& GetColumnList() const
	{
		return mColumnList;
	}

	
	// creates a new insert statement or returns the
	// current one if one already exists
	_InsertStmt* GetStatement()
	{
		if (!mInsert)
			CreateStatement();
	
		return mInsert;
	}
	
	bool HasStatement() const
	{
			return mInsert != NULL;
	}
	
	void ClearState();
	
	void SetSessionSetID(int sessionSetID)
	{
		mSessionSetID = sessionSetID;
	}

	int GetSessionSetID()
	{
		return mSessionSetID;
	}
	
	void IncrementSessionCount()
	{
		mSessionCount++;
	}
	
	int GetSessionCount()
	{
		return mSessionCount;
	}

	void CreateStagingTable(class ServiceDefHookProxy & serviceHook);

private:
	void CreateStatement();
	
private:
	std::string mName;
	int mID;
	std::string mTableName;
	std::string mStageTableName;
	std::string mColumnList;
	
	// property ID to t_svc staging table column index map
	std::map<int, int> mPropertyToColumnOffsetMap;

	// property ID to t_svc staging table column name map
	std::map<int, std::string> mPropertyToColumnNameMap;
	
	COdbcConnectionInfo mStagingDBInfo;
	bool mIsOracle;
	
	//
	// stateful product data
	//
	_InsertStmt*   mInsert;
	int mSessionSetID;
	int mSessionCount;
};


template <class _InsertStmt>
class DBSessionBuilder;

//
// concrete product of the DBSessionBuilder
//
template <class _InsertStmt>
class DBSessionProduct : public ISessionProduct
{
public:

	DBSessionProduct(DBSessionBuilder<_InsertStmt>* builder);
	~DBSessionProduct();

	void SpoolMessage();
	
	// returns the DB-based message UID (NOTE: not the UID sent by the client)
	void GetMessageUID(std::string& encodedUid);

private:

	void SetLiveServiceDefs(std::set<DBServiceDef<_InsertStmt>*>& children)
	{
		std::set<DBServiceDef<_InsertStmt>*>::const_iterator it;
		for (it = children.begin(); it != children.end(); it++)
			mLiveServiceDefs.insert(*it);
	}

private:
	void InsertMessageData(ROWSETLib::IMTSQLRowsetPtr rowset);
	void CopySessionDataFromStaging(ROWSETLib::IMTSQLRowsetPtr rowset);
	void CopySessionSetDataFromStaging(ROWSETLib::IMTSQLRowsetPtr rowset);
	void CopySvcDataFromStaging(const DBServiceDef<_InsertStmt>* def, ROWSETLib::IMTSQLRowsetPtr rowset);

private:
	friend DBSessionBuilder<_InsertStmt>;

	DBSessionBuilder<_InsertStmt>* mBuilder;
	std::string mStagingDBName;

	std::set<DBServiceDef<_InsertStmt>*> mLiveServiceDefs;

	
	int mMessageID;

	// time the message was metered
	time_t mMeteredTime;

	// whether the message was sent synchronously or not
	bool mSynchronous;

	// base64 encoded DTC transaction cookie used to join
	// multiple session sets into one transaction
	// for pipeline processing
	std::string mTransactionID; 

	// base64 encoded DTC transaction cookie used by
	// the listener to transactional deliver a message
	// to the routing tables
	std::string mListenerTransactionID; 

	// session context message-level properties
	std::string mSessionContextUsername;
	std::string mSessionContextPassword;
	std::string mSessionContextNamespace;
	std::string mSerializedSessionContext;

	// IP address of sender
	std::string mIPAddress;
};


//
// a DB session builder that builds insert statements into t_svc tables et al
//
template <class _InsertStmt> 
class DBSessionBuilder
{
public:
	DBSessionBuilder();
	~DBSessionBuilder();

	// TODO: methods are virtual for now for proper linkage, they should be inlined
	virtual void Initialize(const PipelineInfo& configInfo, CMTCryptoAPI* crypto);
	virtual void StartProduction();
	virtual ISessionProduct * CompleteProduction();
	virtual void AbortProduction();

	virtual void CreateSession(const unsigned char * uid, int serviceDefID);
	virtual void CreateChildSession(const unsigned char * uid, int serviceDefID, const unsigned char * parentUID);
	virtual void AddLongSessionProperty(long propertyID, long value);
	virtual void AddDoubleSessionProperty(long propertyID, double value);
	virtual void AddTimestampSessionProperty(long propertyID, time_t value);
	virtual void AddBoolSessionProperty(long propertyID, bool value);
	virtual void AddEnumSessionProperty(long propertyID, long value);
	virtual void AddStringSessionProperty(long propertyID, const wchar_t* value);
	virtual void AddEncryptedStringSessionProperty(long propertyID, const wchar_t* value);
	virtual void AddDecimalSessionProperty(long propertyID, DECIMAL value);
	virtual void AddLongLongSessionProperty(long propertyID, __int64 value);
	
	virtual bool SessionPropertyExists(long propertyID);
	virtual void CompleteSession();

	virtual void SetMeteredTime(time_t time)
	{
		ASSERT(mProduct);
		mProduct->mMeteredTime = time;
	}
	
	virtual void SetSynchronous(bool value) 
	{
		ASSERT(mProduct);
		mProduct->mSynchronous = value;
	};

	virtual void SetTransactionID(const char* transactionID) 
	{ 
		ASSERT(mProduct);
		mProduct->mTransactionID = transactionID; 
	}

	virtual void SetListenerTransactionID(const char* transactionID)
	{
		ASSERT(mProduct);
		mProduct->mListenerTransactionID = transactionID; 
	}

	virtual void SetSessionContextUsername(const char* username) 
	{ 
		ASSERT(mProduct);
		mProduct->mSessionContextUsername = username; 
	}

	virtual void SetSessionContextPassword(const char* password) 
	{ 
		ASSERT(mProduct);
		mProduct->mSessionContextPassword = password;

		if (mCrypto->Encrypt(mProduct->mSessionContextPassword) != 0)
			throw MTException("Failed to encrypt session context password!");
	}

	virtual void SetSessionContextNamespace(const char* name_space) 
	{ 
		ASSERT(mProduct);
		mProduct->mSessionContextNamespace = name_space;
	};

	virtual void SetSerializedSessionContext(const char* context) 
	{
		ASSERT(mProduct);
		mProduct->mSerializedSessionContext = context;

		if (mCrypto->Encrypt(mProduct->mSerializedSessionContext) != 0)
			throw MTException("Failed to encrypt serialized session context!");
	}

	virtual void SetIPAddress(const char* address)
	{
		ASSERT(mProduct);
		mProduct->mIPAddress = address;
	}


private:
	friend class DBSessionProduct<_InsertStmt>;

	//
	// methods to help keep track of properties
	//
	void RecordProperty(long propertyID)
	{	mSessionProps.insert(propertyID);	}

	bool PropertyExists(long propertyID)
	{
		std::set<int>::iterator findIt;
		findIt = mSessionProps.find(propertyID);
		return (findIt != mSessionProps.end());
	}

	void ClearProperties()
	{ mSessionProps.clear(); }

	void ClearProductState();

	void TruncateStagingTable(const std::string& tableName);
	void CreateStagingTable(const std::string& tableName, const std::string& srcTableName);

	void AddSession(int sessionSetID, const unsigned char * sessionUID);

	// returns the ID of the listener from the t_listener table
	int GetListenerID();
	// returns the listener's feedback meter ID (configured in listener.xml)
	int GetMeterID();


	// inserts data into staging tables - performed during CompleteProduction
	void InsertSessionSetStagingData();
	void InsertSvcStagingData();
	void InsertSessionStagingData();


private:
	enum { UID_LENGTH = 16 };

	// collection of all service definitions keyed by service ID
	std::map<int, DBServiceDef<_InsertStmt> *> mServiceDefs;

	std::string mStagingDBName;

	// tracks what properties have currently been set in session
	// all Add*SessionProperty methods should insert into it on success
	// CompleteSession should clear it
	std::set<int> mSessionProps;

	// current product being constructed
	DBSessionProduct<_InsertStmt>* mProduct;

	// current root (parent or atomic) service def for the message
	DBServiceDef<_InsertStmt>* mRootServiceDef;
	unsigned char mRootSessionIDBuffer[UID_LENGTH];

	// current service def (root or child)
	DBServiceDef<_InsertStmt>* mServiceDef;
	
	// current statement to insert into t_svc table
	_InsertStmt* mSvcInsert;
		
	// insert statement for t_sessions table
	_InsertStmt* mSessionInsert;

	// insert statement for t_session_set table
	_InsertStmt* mSessionSetInsert;

  // number of session in message (all service defs)
  int mMessageSessionCount;

	// set of service defs that have been seen in the current product
	std::set<DBServiceDef<_InsertStmt>*> mLiveServiceDefs;

	// session UID of the current/last root session
	unsigned char mRootSessionUID[UID_LENGTH];

	// current session ID (root or child)
	unsigned char mSessionUID[UID_LENGTH];
	long mSessionID;

private:
  CMTCryptoAPI* mCrypto;

	COdbcIdGenerator* mIDGenerator;
	COdbcLongIdGenerator* mLongIDGenerator;
	std::string mMessageSequenceName;
	std::string mSessionSetSequenceName;
	std::string mSessionSequenceName;

	std::wstring mFeedbackQueueFormatName;

	int mListenerID; // id from t_listener
	int mMeterID;    // used for feedback (configured in listener.xml)
};



template <class _InsertStmt>
class DBSessionUpdateBuilder;

//
// concrete product of the DBSessionUpdateBuilder
//
template <class _InsertStmt>
class DBSessionUpdateProduct : public ISessionProduct
{
public:

	const std::wstring& GetUpdateQuery() const
	{ return mUpdateQuery; }

private:
	friend DBSessionUpdateBuilder<_InsertStmt>;

	DBSessionUpdateBuilder<_InsertStmt>* mBuilder;
	
	std::wstring mUpdateQuery;
};


//
// a DB session builder that builds insert statements into t_svc tables et al
//
template <class _InsertStmt>
class DBSessionUpdateBuilder
{
public:
	DBSessionUpdateBuilder();
	~DBSessionUpdateBuilder();

	// TODO: methods are virtual for now for proper linkage, they should be inlined
	virtual void Initialize(const PipelineInfo& configInfo, CMTCryptoAPI* crypto);
	virtual void StartProduction();
	virtual ISessionProduct * CompleteProduction();
	virtual void AbortProduction();

	virtual void CreateSession(const unsigned char * uid, int serviceDefID);
	virtual void CreateChildSession(const unsigned char * uid, int serviceDefID, const unsigned char * parentUID);
	virtual void AddLongSessionProperty(long propertyID, long value);
	virtual void AddDoubleSessionProperty(long propertyID, double value);
	virtual void AddTimestampSessionProperty(long propertyID, time_t value);
	virtual void AddBoolSessionProperty(long propertyID, bool value);
	virtual void AddEnumSessionProperty(long propertyID, long value);
	virtual void AddStringSessionProperty(long propertyID, const wchar_t* value);
	virtual void AddEncryptedStringSessionProperty(long propertyID, const wchar_t* value);
	virtual void AddDecimalSessionProperty(long propertyID, DECIMAL value);
	virtual void AddLongLongSessionProperty(long propertyID, __int64 value);
	
	virtual bool SessionPropertyExists(long propertyID);
	virtual void CompleteSession();

	virtual void SetMeteredTime(time_t time) { };
	virtual void SetSynchronous(bool value) { }; 
	virtual void SetTransactionID(const char* transactionID) { };
	virtual void SetListenerTransactionID(const char* transactionID) { };
	virtual void SetSessionContextUsername(const char* username) { }; 
	virtual void SetSessionContextPassword(const char* password) { };
	virtual void SetSessionContextNamespace(const char* name_space) { };
	virtual void SetSerializedSessionContext(const char* context) { }; 
	virtual void SetIPAddress(const char* address) { };

private:

	//
	// methods to help keep track of properties
	//
	void RecordProperty(long propertyID)
	{	mSessionProps.insert(propertyID);	}

	bool PropertyExists(long propertyID)
	{
		std::set<int>::iterator findIt;
		findIt = mSessionProps.find(propertyID);
		return (findIt != mSessionProps.end());
	}

	void ClearProperties()
	{ mSessionProps.clear(); }


	// frees shared sessions and other memory
	void Clear();

  // generates boiler-plate property update SQL
	void AddProperty(long propertyID);

	std::wstring EscapeSQLString(const std::wstring & str);

private:
	enum { UID_LENGTH = 16 };

	// collection of all service definitions keyed by service ID
	std::map<int, DBServiceDef<_InsertStmt>*> mServiceDefs;

	std::string mStagingDBName;

	// tracks what properties have currently been set in session
	// all Add*SessionProperty methods should insert into it on success
	// CompleteSession should clear it
	std::set<int> mSessionProps;

	// current product being constructed
	DBSessionUpdateProduct<_InsertStmt> * mProduct;

	// current root (parent or atomic) service def for the message
	DBServiceDef<_InsertStmt>* mRootServiceDef;

	// current service def (root or child)
	DBServiceDef<_InsertStmt>* mServiceDef;

	// set of service defs that have been seen in the current product
	std::set<DBServiceDef<_InsertStmt>*> mLiveServiceDefs;

	// session UID of the current/last root session
	unsigned char mRootSessionUID[UID_LENGTH];

	// current session ID (root or child)
	unsigned char mSessionUID[UID_LENGTH];
	std::wstring mHexUID;

	// indicates whether the next property to be set is the first property of that session
	// used to comma delimit the set clause in the update statement
	bool mFirstProperty;

	BOOL mIsOracle;

private:
  CMTCryptoAPI* mCrypto;
};



#endif /* _SESSIONBUILDER_H */
