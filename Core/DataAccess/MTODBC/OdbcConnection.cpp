// OdbcConnection.cpp: implementation of the COdbcConnection class.
//
//////////////////////////////////////////////////////////////////////
#pragma warning( disable : 4786 ) 

#define MT_TRACE_CONNECTIONS

#include <metra.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <autocritical.h>
#include "OdbcConnection.h"
#include "OdbcException.h"
#include "OdbcPreparedArrayStatement.h"
#include "OdbcMetadata.h"
#include "OdbcStatement.h"
#include "OdbcPreparedBcpStatement.h"

#import <MTServerAccess.tlb>

DWORD COdbcEnvironment::msNumRefs = 0;
COdbcEnvironment* COdbcEnvironment::mpsInstance = 0;
NTThreadLock COdbcEnvironment::msLock;

void COdbcEnvironment::AllocateEnvironment()
{
  if(mEnv == SQL_NULL_HANDLE)
  {
    SQLRETURN sqlReturn;

    // pooling first
    sqlReturn = ::SQLSetEnvAttr(mEnv, SQL_ATTR_CONNECTION_POOLING, (SQLPOINTER)SQL_CP_ONE_PER_DRIVER, 0);
//     sqlReturn = ::SQLSetEnvAttr(NULL, SQL_ATTR_CONNECTION_POOLING, (SQLPOINTER)SQL_CP_OFF, 0);
    if(sqlReturn == SQL_ERROR) throw COdbcException("Failed to enable per-driver pooling");

    // environment next
    sqlReturn = ::SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &mEnv);
    if(sqlReturn == SQL_ERROR) throw COdbcException("Failed to allocate ODBC Environment");

    // force version to 3.x
    sqlReturn = ::SQLSetEnvAttr(mEnv, SQL_ATTR_ODBC_VERSION, (SQLPOINTER) SQL_OV_ODBC3, SQL_IS_INTEGER);
    if(sqlReturn == SQL_ERROR) throw COdbcException("Failed to set ODBC version");

  }
}

COdbcEnvironment::COdbcEnvironment()
{
  mEnv = SQL_NULL_HANDLE;
}

COdbcEnvironment::~COdbcEnvironment()
{
  if (mEnv != SQL_NULL_HANDLE) 
  {
    ::SQLFreeHandle(SQL_HANDLE_ENV, mEnv);
  }
}

COdbcEnvironment* COdbcEnvironment::GetInstance() 
{
  AutoCriticalSection lock(&msLock);
  // if the object does not exist..., create a new one
  if (mpsInstance == 0)
  {
    mpsInstance = new COdbcEnvironment();
  }
  // if we got a valid pointer.. increment...
  if (mpsInstance != 0)
  {
    msNumRefs++;
  }
  return (mpsInstance);
}

void COdbcEnvironment::ReleaseInstance()
{
  AutoCriticalSection lock(&msLock);

  // decrement the reference counter
  if (mpsInstance != 0)
  {
    msNumRefs--;
  }

  // if the number of references is 0, delete the pointer
  if (msNumRefs == 0)
  {
    delete mpsInstance;
    mpsInstance = 0;
  }
}

HENV COdbcEnvironment::GetHandle() 
{
  AutoCriticalSection lock(&msLock);
  AllocateEnvironment();
  return mEnv;
}


void COdbcConnectionInfo::Load(const string& aLogicalServerName)
{
  MTSERVERACCESSLib::IMTServerAccessDataSetPtr serverAccessCol(MTPROGID_SERVERACCESS);
  ASSERT(serverAccessCol != NULL);
  serverAccessCol->Initialize();
		
  // talk to the server access object... find the information about the server we
  // are trying to use
  MTSERVERACCESSLib::IMTServerAccessDataPtr accessData;
  accessData = serverAccessCol->FindAndReturnObject(aLogicalServerName.c_str());
  mServer = accessData->GetServerName();
  mCatalog = accessData->GetDatabaseName();
  mDBDriver = accessData->GetDatabaseDriver();
  mUserName = accessData->GetUserName();
  mPassword = accessData->GetPassword();
  mTimeout = accessData->GetTimeout();
  _bstr_t dbtype = accessData->GetDatabaseType();

  COdbcConnectionInfo::DBType type;
  if (dbtype.length() == 0)
    type = COdbcConnectionInfo::DBTYPE_SQL_SERVER; // default type is SQL server
  else if (0 == wcsicmp(dbtype, L"{Oracle}"))
    type = COdbcConnectionInfo::DBTYPE_ORACLE;
  else if (0 == wcsicmp(dbtype, L"{SQL Server}"))
    type = COdbcConnectionInfo::DBTYPE_SQL_SERVER;
  else
  {
    std::string buffer("Unknown database type ");
    buffer += dbtype;
    throw COdbcException(buffer);
  }
  mDBType = type;
}

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

COdbcConnection::OdbcConnectionAttribute COdbcConnection::sSQLServerAttr[] = 
{{SQL_COPT_SS_BCP, (SQLPOINTER) SQL_BCP_ON, SQL_IS_INTEGER}};


COdbcConnection::COdbcConnection(const COdbcConnectionInfo& aInfo) : mInfo(aInfo)
{
	m_pTransactionDispenser = NULL;
	m_hConnection = NULL;
  mEnvironment = COdbcEnvironment::GetInstance();
	mUsedBcp = false;
	if (aInfo.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_SQL_SERVER)
		// SQL server attributes
		Initialize(sSQLServerAttr, sizeof(sSQLServerAttr) / sizeof(sSQLServerAttr[0]));
	else
		// otherwise no special attributes
		Initialize(NULL, 0);
}

COdbcConnection::COdbcConnection(const COdbcConnectionInfo& aInfo, 
																 const OdbcConnectionAttribute* preConnectionAttributes,
																 int numAttributes) 
	: 
	mInfo(aInfo)
{
	m_pTransactionDispenser = NULL;
	m_hConnection = NULL;
  mEnvironment = COdbcEnvironment::GetInstance();
	mUsedBcp = false;
	Initialize(preConnectionAttributes, numAttributes);
}

COdbcConnection::~COdbcConnection()
{
#ifdef MT_TRACE_CONNECTIONS
	mLogger.LogVarArgs(LOG_TRACE, "[CnxTrace] <<< closing ODBC [%x]", this);
#endif
	
	// attempt to make sure any BCP activity is cleaned up.
	if (mUsedBcp)
		bcp_done(m_hConnection);

	if(m_pTransactionDispenser) m_pTransactionDispenser->Release();
	if(m_hConnection != NULL) ::SQLDisconnect(m_hConnection);
	if(m_hConnection != NULL) ::SQLFreeHandle(SQL_HANDLE_DBC, m_hConnection);
	delete mMetadata;

  // Release reference on odbc environment.
  if (mEnvironment != NULL) COdbcEnvironment::ReleaseInstance();
}

HDBC COdbcConnection::GetHandle() const
{
	return m_hConnection;
}

HENV COdbcConnection::GetEnvHandle()
{
	return mEnvironment->GetHandle();
}

class BadConnections
{
private:
  std::vector<HDBC> mBadConnections;
public:
  BadConnections()
  {
  }
  ~BadConnections()
  {
    for(std::vector<HDBC>::iterator it = mBadConnections.begin();
        it != mBadConnections.end();
        ++it)
    {
      ::SQLDisconnect(*it);
      ::SQLFreeHandle(SQL_HANDLE_DBC, *it);      
    }
  }
  void push_back(HDBC conn)
  {
    mBadConnections.push_back(conn);
  }
};

bool COdbcConnection::Initialize(const OdbcConnectionAttribute* preConnectionAttributes,
																 int numAttributes)
{
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging\\mtodbc\\"), "[MTODBC]");

	std::string connStr;

	BOOL isOracle = (mInfo.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);
	if (isOracle)
	{
		connStr = "DRIVER=";
		connStr += mInfo.GetDatabaseDriver();
		connStr += ";SERVER=";
		connStr += mInfo.GetServer();
		connStr += ";DBQ=";
		connStr += mInfo.GetServer();
		connStr += ";DATABASE=";
		connStr += mInfo.GetCatalog();
		//BP: Add support for DTC
		//By default Oracle ODBC driver doesn't support MTS(DTC)
		//Need to pass MTS=F, which is very misleading, because it actually
		//diables "Do not support MTS" option rather then disabling MTS.
		connStr += ";MTS=F";
		//GDE Allows to call SQLGetData in any order.
		connStr += ";GDE=T";
	}
	else
	{
		connStr = "DRIVER=";
		connStr += mInfo.GetDatabaseDriver();
		connStr += ";SERVER=";
		connStr += mInfo.GetServer();
	}

	connStr += ";UID=";
	connStr += mInfo.GetUserName();
	if (mInfo.GetPassword().length() > 0)
	{
		connStr += ";PWD=";
		connStr += mInfo.GetPassword();
	}

	const int MAXBUFLEN = 1024;
	SQLCHAR ConnStrOut[MAXBUFLEN];
	SQLSMALLINT cbConnStrOut = 0;

  // This is a workaround to a nasty issue.  SQL Server connection pooling does not seem to honor
  // request for BCP.  To get around this we pull as many connections out of the pool
  // as we have to until we get one with BCP enabled.  We must keep the "bad" connections
  // around to avoid putting them back into the pool only to retrieve them again.
  BadConnections badBoys;
  while(m_hConnection == NULL)
  {
    SQLRETURN sqlReturn = ::SQLAllocHandle(SQL_HANDLE_DBC, GetEnvHandle(), &m_hConnection);
    if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcException("Failed to allocate connection handle");

    sqlReturn = ::SQLSetConnectAttrA(m_hConnection, SQL_ATTR_CURRENT_CATALOG, 
                                     (SQLPOINTER) mInfo.GetCatalog().c_str(), SQL_NTS);
    if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcConnectionException(m_hConnection);

    for (int i=0; i<numAttributes; i++)
    {
      sqlReturn = ::SQLSetConnectAttrA(m_hConnection, 
                                       preConnectionAttributes[i].attribute, 
                                       preConnectionAttributes[i].valuePtr, 
                                       preConnectionAttributes[i].stringLength);
      if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcConnectionException(m_hConnection);
    }

    // Make connection without data source. Ask that driver not
    // prompt if insufficient information. Driver returns
    // SQL_ERROR and application prompts user
    // for missing information. Window handle not needed for
    // SQL_DRIVER_NOPROMPT.
    sqlReturn = ::SQLDriverConnectA(m_hConnection,// Connection handle
                                    NULL, // Window handle
                                    (unsigned char *) connStr.c_str(), // Input connect string
                                    SQL_NTS, // Null-terminated string
                                    ConnStrOut,	// Address of output buffer
                                    MAXBUFLEN, // Size of output buffer
                                    &cbConnStrOut, // Address of output length
                                    SQL_DRIVER_NOPROMPT);
    if (sqlReturn != SQL_SUCCESS)
    {	
      if(sqlReturn != SQL_SUCCESS_WITH_INFO)
      {
        //mLogger.LogVarArgs(LOG_ERROR, Database connect failed for '%s'", connStr.c_str());
        mLogger.LogVarArgs(LOG_ERROR, "Database connect failed");
        throw COdbcConnectionException(m_hConnection);
      }
      else
      {
        /*
          SQL State IM006: During SQLConnect, the Driver Manager called the driver's 
          SQLSetConnectAttr function and the driver returned an error. 
          (Function returns SQL_SUCCESS_WITH_INFO.)
        */
        SQLCHAR sqlstate[6];
        SQLINTEGER nativeErrorPtr;
        SQLCHAR messageText[1024];
        SQLSMALLINT messageLength;
        SQLRETURN sqlReturn = ::SQLGetDiagRecA(SQL_HANDLE_DBC, m_hConnection, 1, &sqlstate[0], &nativeErrorPtr, &messageText[0], 1024, &messageLength);
        if (sqlReturn == SQL_SUCCESS && stricmp((const char *) sqlstate, "IM006") == 0)
        {
          /* It appears that there is a 28 character limit for default odbc driver. To minimize the 
             the scope of this error check we'll restrict the size here.
          */
          std::string strCatalog = mInfo.GetCatalog();
          if (strCatalog.length() > 28)
          {
            mLogger.LogVarArgs(LOG_ERROR, "ODBC driver may not support long database names. Database name '%s' may be too long.", strCatalog.c_str());
            throw COdbcConnectionException(m_hConnection);
          }
          else // just log the condition
            mLogger.LogVarArgs(LOG_DEBUG, "OBDC connect with info: '%s'.", messageText);
        }
      }
    }

#ifdef MT_TRACE_CONNECTIONS
    mLogger.LogVarArgs(LOG_TRACE, "[CnxTrace] >>> opened ODBC [%x] '%s'", this, connStr.c_str());
#endif

    if (numAttributes > 0)
    {
      // Double check that we got the BCP attribute.
      SQLINTEGER bcpOnFlag;
      sqlReturn = ::SQLGetConnectAttrA(m_hConnection, SQL_COPT_SS_BCP, &bcpOnFlag, SQL_IS_INTEGER, NULL);
      if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) 
        throw COdbcConnectionException(m_hConnection);
      if (bcpOnFlag != SQL_BCP_ON)
      {
        mLogger.LogVarArgs(LOG_WARNING, "Database connect returned connection without BCP enabled.  Retrying connection...");
        badBoys.push_back(m_hConnection);
        m_hConnection = NULL;
      }
    }
  }

	mMetadata = new COdbcMetadata(this);

	// NOTE: this is called to be sure the BCP state of the connection is
	// clear.  Otherwise failures can cause a connection to go back
	// to the connection pool with a BCP half done.  This causes an error like
	// this "Connection is busy with results for another hstmt"
	if (!isOracle)
		bcp_done(m_hConnection);

	return true;
}

bool COdbcConnection::JoinTransaction(ITransaction *pTransaction)
{
	SQLRETURN sqlReturn = ::SQLSetConnectAttrA(m_hConnection, SQL_COPT_SS_ENLIST_IN_DTC,
                                             (SQLPOINTER)pTransaction, 0);
	if (sqlReturn == SQL_ERROR || sqlReturn == SQL_SUCCESS_WITH_INFO)
	{
		throw COdbcConnectionException(m_hConnection);
	}
	return true;
}

bool COdbcConnection::LeaveTransaction()
{
	SQLRETURN sqlReturn = ::SQLSetConnectAttrA(m_hConnection, SQL_COPT_SS_ENLIST_IN_DTC,
                                             (SQLPOINTER)SQL_DTC_DONE, 0);
	if (sqlReturn == SQL_ERROR || sqlReturn == SQL_SUCCESS_WITH_INFO)
	{
		throw COdbcConnectionException(m_hConnection);
	}
	return true;
}

void COdbcConnection::SetTransactionIsolation(COdbcConnection::TransactionIsolation aTxnIso)
{
	SQLRETURN sqlReturn = SQL_ERROR;
	switch(aTxnIso)
	{
	case READ_UNCOMMITTED:
		sqlReturn = ::SQLSetConnectAttrA(m_hConnection, SQL_ATTR_TXN_ISOLATION, (SQLPOINTER) SQL_TXN_READ_UNCOMMITTED, SQL_IS_INTEGER);
		break;
	case READ_COMMITTED:
		sqlReturn = ::SQLSetConnectAttrA(m_hConnection, SQL_ATTR_TXN_ISOLATION, (SQLPOINTER) SQL_TXN_READ_COMMITTED, SQL_IS_INTEGER);
		break;
	case REPEATABLE_READ:
		sqlReturn = ::SQLSetConnectAttrA(m_hConnection, SQL_ATTR_TXN_ISOLATION, (SQLPOINTER) SQL_TXN_REPEATABLE_READ, SQL_IS_INTEGER);
		break;
	case SERIALIZABLE:
		sqlReturn = ::SQLSetConnectAttrA(m_hConnection, SQL_ATTR_TXN_ISOLATION, (SQLPOINTER) SQL_TXN_SERIALIZABLE, SQL_IS_INTEGER);
		break;
	default:
		ASSERT(0);
		break;
	}
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcConnectionException(m_hConnection);
}

COdbcConnection::TransactionIsolation COdbcConnection::GetTransactionIsolation()
{
	TransactionIsolation txnIso;
	SQLRETURN sqlReturn = SQL_ERROR;

	SQLINTEGER sqlTxnIso = 0;
	sqlReturn = SQLGetConnectAttr(m_hConnection, SQL_ATTR_TXN_ISOLATION, &sqlTxnIso, SQL_IS_INTEGER, NULL);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcConnectionException(m_hConnection);
	
	switch(sqlTxnIso)
	{
		case SQL_TXN_READ_UNCOMMITTED:
			txnIso = READ_UNCOMMITTED;
			break;
		case SQL_TXN_READ_COMMITTED:
			txnIso = READ_COMMITTED;
			break;
		case SQL_TXN_REPEATABLE_READ:
			txnIso = REPEATABLE_READ;
			break;
		case SQL_TXN_SERIALIZABLE:
			txnIso = SERIALIZABLE;
			break;
		default:
			ASSERT(0);
			break;
	}

	return txnIso;
}

void COdbcConnection::SetSchema(const string &schema)
{
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLSetConnectAttrA(m_hConnection, SQL_ATTR_CURRENT_CATALOG, (SQLPOINTER) schema.c_str(), SQL_NTS);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcConnectionException(m_hConnection);
}

void COdbcConnection::CommitTransaction()
{
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLEndTran(SQL_HANDLE_DBC, m_hConnection, SQL_COMMIT);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcConnectionException(m_hConnection);
}

void COdbcConnection::RollbackTransaction()
{
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLEndTran(SQL_HANDLE_DBC, m_hConnection, SQL_ROLLBACK);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcConnectionException(m_hConnection);
}

void COdbcConnection::SetAutoCommit(bool aAutoCommit)
{
  	SQLRETURN sqlReturn;
	if(FALSE == aAutoCommit)
	{
		sqlReturn = ::SQLSetConnectAttrA(m_hConnection, SQL_ATTR_AUTOCOMMIT, (SQLPOINTER) SQL_AUTOCOMMIT_OFF, SQL_IS_INTEGER);
	} else {
		sqlReturn = ::SQLSetConnectAttrA(m_hConnection, SQL_ATTR_AUTOCOMMIT, (SQLPOINTER) SQL_AUTOCOMMIT_ON, SQL_IS_INTEGER);
	}
	if (sqlReturn == SQL_ERROR) throw COdbcConnectionException(m_hConnection);
}

COdbcTableInsertStatement* COdbcConnection::PrepareInsertStatement(const string& aTableName, int aMaxArraySize, bool aBind)
{
	return COdbcTableInsertStatement::CreateTableInsertStatement(this, aMaxArraySize, aTableName, aBind);
}

COdbcPreparedArrayStatement* COdbcConnection::PrepareStatement(const string& aQueryString, int aMaxArraySize, bool aBind)
{
	return COdbcPreparedArrayStatement::CreateStatement(this, aMaxArraySize, aQueryString, aBind);
}

//overloaded for wide strings
COdbcPreparedArrayStatement* COdbcConnection::PrepareStatement(const wstring& aQueryString, int aMaxArraySize, bool aBind)
{
	return COdbcPreparedArrayStatement::CreateStatement(this, aMaxArraySize, aQueryString, aBind);
}

COdbcPreparedArrayStatement* COdbcConnection::PrepareStatementFromFile(const string & aQueryDirectory,
																																			 const string & aQueryTag,
																																			 int aMaxArraySize, bool aBind)
{
	return COdbcPreparedArrayStatement::CreateStatementFromFile(this, aMaxArraySize, aQueryDirectory.c_str(), aQueryTag.c_str(), aBind);
}


COdbcStatement* COdbcConnection::CreateStatement()
{
	return new COdbcStatement(this);
}


COdbcMetadata* COdbcConnection::GetMetadata()
{
	return mMetadata;
}

// SQL server specific!
COdbcPreparedBcpStatement* COdbcConnection::PrepareBcpInsertStatement(const string& aTableName, 
																																			const COdbcBcpHints& aHints)
{
	if (mInfo.GetDatabaseType() != COdbcConnectionInfo::DBTYPE_SQL_SERVER)
	{
		ASSERT(0);
		throw COdbcException("PrepareBcpInsertStatement can only be called with SQL Server connections");
	}
	mUsedBcp = true;
	return new COdbcPreparedBcpStatement(this, aTableName, aHints);
}

// these two methods are siginature equivalent
void COdbcConnection::PrepareInsertStatement(
	COdbcPreparedBcpStatement*& stmt,
	const string& aTableName, 
	const COdbcBcpHints& aHints,
	const int aMaxArraySize,
	bool aBind)
{
	mUsedBcp = true;
	stmt = new COdbcPreparedBcpStatement(this, aTableName, aHints);
}

void COdbcConnection::PrepareInsertStatement(
	COdbcPreparedArrayStatement*& stmt,
	const string& aTableName, 
	const COdbcBcpHints& aHints,
	const int aMaxArraySize,
	bool aBind)
{
	stmt = COdbcTableInsertStatement::CreateTableInsertStatement(this, aMaxArraySize, aTableName, aBind);
}
