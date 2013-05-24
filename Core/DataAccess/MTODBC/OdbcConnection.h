// OdbcConnection.h: interface for the COdbcConnection class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ODBCCONNECTION_H__384B3FD9_16BA_48E4_A254_DB5182A94710__INCLUDED_)
#define AFX_ODBCCONNECTION_H__384B3FD9_16BA_48E4_A254_DB5182A94710__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000


#include <sql.h>
#include <sqlext.h>
#include <sqltypes.h>
#include <odbcss.h>

#include <transact.h>
#include <xoleHlp.h>
#include <autologger.h>
#include <ntthreadlock.h>
#include "OdbcColumnMetadata.h"	// Added by ClassView
#include <mtprogids.h>	// Added by ClassView
#include <OdbcException.h>

// TODO: remove undefs
#if defined(MTODBC_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

#pragma warning( disable : 4251 )

class COdbcEnvironment;
class COdbcMetadata;
class COdbcPreparedArrayStatement;
class COdbcTableInsertStatement;
class COdbcStatement;
class COdbcPreparedBcpStatement;
class COdbcBcpHints;

class COdbcEnvironment
{
private:
	HENV mEnv;

	void AllocateEnvironment();

	COdbcEnvironment();

	~COdbcEnvironment();

  static NTThreadLock msLock;
  static DWORD msNumRefs;
  static COdbcEnvironment * mpsInstance;

public:

  DllExport static COdbcEnvironment* GetInstance();

  DllExport static void ReleaseInstance();

	DllExport HENV GetHandle();
};


class DllExport COdbcConnectionInfo
{
public:
	DllExport enum DBType
	{
		DBTYPE_SQL_SERVER,
		DBTYPE_ORACLE
	};

private:
	string mServer;
	string mCatalog;
	string mUserName;
	string mPassword;
	int mTimeout;									// timeout in seconds
	DBType mDBType;
	string mDataSource;
	string mDBDriver;

public:
	// default constructor needed for many STL objects.  not useful otherwise
	COdbcConnectionInfo()
		: mDBType(DBTYPE_SQL_SERVER)
	{	}

	COdbcConnectionInfo(const string& aLogicalServerName)
	{	
		Load(aLogicalServerName);
	}

	void Load(const string& aLogicalServerName);

	COdbcConnectionInfo(const string& aServer, 
											const string& aCatalog, 
											const string& aUserName, 
											const string& aPassword) 
		: mServer(aServer), mCatalog(aCatalog), mUserName(aUserName), mPassword(aPassword),
			mDBType(DBTYPE_SQL_SERVER), mTimeout(30)
	{ }

	COdbcConnectionInfo(const string& aDataSource, 
											const string& aUserName, 
											const string& aPassword) 
		: mDataSource(aDataSource), mUserName(aUserName), mPassword(aPassword),
			mDBType(DBTYPE_SQL_SERVER), mTimeout(30)
	{ }

	COdbcConnectionInfo(const COdbcConnectionInfo& aInfo) 
	{
		*this = aInfo;
	}

	COdbcConnectionInfo & operator = (const COdbcConnectionInfo & arInfo)
	{
		mServer = arInfo.GetServer();
		mCatalog = arInfo.GetCatalog();
		mUserName = arInfo.GetUserName();
		mPassword = arInfo.GetPassword();
		mTimeout = arInfo.GetTimeout();
		mDBType = arInfo.GetDatabaseType();
		mDataSource = arInfo.GetDataSource();
		mDBDriver = arInfo.GetDatabaseDriver();
		return *this;
	}

	bool operator == (const COdbcConnectionInfo & arInfo)
	{
		return (mServer == arInfo.mServer &&
						mCatalog == arInfo.mCatalog &&
						mUserName == arInfo.mUserName &&
						mPassword == arInfo.mPassword &&
						mTimeout == arInfo.mTimeout &&
						mDBType == arInfo.mDBType &&
						mDataSource == arInfo.mDataSource &&
						mDBDriver  == arInfo.mDBDriver );
	}
	
	bool operator != (const COdbcConnectionInfo & arInfo)
	{
		return !(operator == (arInfo));
	}

	const string& GetUserName() const { return mUserName; }
	const string& GetPassword() const { return mPassword; }
	const string& GetCatalog() const { return mCatalog; }
   const string GetCatalogPrefix() const
   { 
      return mCatalog + (IsOracle() ? "." : "..");
   }
	const string& GetServer() const { return mServer; }
	int GetTimeout() const { return mTimeout; }
	DBType GetDatabaseType() const { return mDBType; }
   bool IsOracle() const { return mDBType == COdbcConnectionInfo::DBTYPE_ORACLE; }
   bool IsSqlServer() const { return mDBType == COdbcConnectionInfo::DBTYPE_SQL_SERVER; }
	const string& GetDataSource() const { return mDataSource; }
	const string& GetDatabaseDriver() const { return mDBDriver; }

	void SetUserName(const char * apUsername) { mUserName = apUsername; }
	void SetPassword(const char * apPassword) { mPassword = apPassword; }
	void SetCatalog(const char * apCatalog) { mCatalog = apCatalog; }
	void SetServer(const char * apServer) { mServer = apServer; }
	void SetTimeout(int aTimeout) { mTimeout = aTimeout; }
	void SetDatabaseType(DBType aDBType) { mDBType = aDBType; }
	void SetDataSource(const char * apDataSource) { mDataSource = apDataSource; }
	void SetDatabaseDriver(const char * apDatabaseDriver) { mDBDriver = apDatabaseDriver; }
};

class COdbcConnection  
{
protected:

	class OdbcConnectionAttribute
	{
	public:
		SQLINTEGER attribute;
		SQLPOINTER valuePtr;
		SQLINTEGER stringLength;
	};

private:
	bool mUsedBcp;
	HDBC m_hConnection;

	COdbcConnectionInfo mInfo;

	COdbcMetadata* mMetadata;

	NTLogger mLogger;

	// SQL server specific pre connection attributes
	static OdbcConnectionAttribute sSQLServerAttr[];

	ITransactionDispenser* m_pTransactionDispenser;
	bool Initialize(const OdbcConnectionAttribute* preConnectionAttributes,
									int numAttributes);

  COdbcEnvironment * mEnvironment;
protected:

public:
	
	DllExport COdbcConnection(const COdbcConnectionInfo& aInfo, 
									const OdbcConnectionAttribute* preConnectionAttributes,
									int numAttributes);

	// Isolation Levels
	enum TransactionIsolation {READ_UNCOMMITTED, READ_COMMITTED, REPEATABLE_READ, SERIALIZABLE};
	DllExport void SetTransactionIsolation(TransactionIsolation aTxnIso);
	DllExport TransactionIsolation GetTransactionIsolation();


	DllExport void SetSchema(const string& schema);
	DllExport void RollbackTransaction();
	DllExport void CommitTransaction();
	DllExport void SetAutoCommit(bool aAutoCommit);
	DllExport bool LeaveTransaction();
	DllExport bool JoinTransaction(ITransaction* pTransaction);

	DllExport const COdbcConnectionInfo& GetConnectionInfo() const
	{
		return mInfo;
	}

	DllExport HENV GetEnvHandle();

	DllExport HDBC GetHandle() const;
	// Right now the infrastructure only supports inserts into tables.  The reason is that
	// the classes use metadata about the target table metadata to set up the query.  For
	// general insert queries, parameter metadata is harder to come by.  Nonetheless, I think
	// SQL server has enough support to be able to eliminate the special case...
	DllExport COdbcTableInsertStatement* PrepareInsertStatement(const string& aTableName, int aMaxArraySize = 1, bool aBind = true);
	DllExport COdbcPreparedArrayStatement* PrepareStatement(const string& aQueryString, int aMaxArraySize = 1, bool aBind = true);
	DllExport COdbcPreparedArrayStatement* PrepareStatement(const wstring& aQueryString, int aMaxArraySize = 1, bool aBind = true);
	DllExport COdbcPreparedArrayStatement* PrepareStatementFromFile(const string & aQueryDirectory, const string & aQueryTag,
																												int aMaxArraySize = 1, bool aBind = true);
	DllExport COdbcStatement* CreateStatement();
	DllExport COdbcMetadata* GetMetadata();

	NTLogger* GetLogger() { return &mLogger; }

	//
	// SQL Server specific calls
	//
	DllExport COdbcPreparedBcpStatement* PrepareBcpInsertStatement(const string& aTableName,
                                                                 const COdbcBcpHints& aHints);


	// next to methods provide a little type dispacthing
	DllExport void PrepareInsertStatement(
		COdbcPreparedBcpStatement*& stmt,
		const string& aTableName, 
		const COdbcBcpHints& aHints,
		const int aMaxArraySize = 1000,
		bool aBind = true);

	DllExport void PrepareInsertStatement(
		COdbcPreparedArrayStatement*& stmt,
		const string& aTableName, 
		const COdbcBcpHints& aHints,
		const int aMaxArraySize = 1000,
		bool aBind = true);

	DllExport COdbcConnection(const COdbcConnectionInfo& aInfo);
	DllExport virtual ~COdbcConnection();

};

#pragma warning( default : 4251 )

#endif // !defined(AFX_ODBCCONNECTION_H__384B3FD9_16BA_48E4_A254_DB5182A94710__INCLUDED_)
