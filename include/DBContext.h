/**************************************************************************
 * @doc DBContext
 *
 * @module  Encapsulation for ADO Database Context |
 *
 * This class encapsulates the ADO database connection.
 *
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header: DBContext.h, 8, 9/11/2002 9:28:43 AM, Alon Becker$
 *
 * @index | DBContext
 ***************************************************************************/

#ifndef __DBContext_H
#define __DBContext_H

//#define NAME_BINDING

#include <comdef.h>
#include <NTLogger.h>
#include <DBSQLRowset.h>
#include <DataAccessDefs.h>
#include <RowsetDefs.h>
#include <autologger.h>
#include <DbObjectsLogging.h>

class DBInitParameters
{
public:
  DBInitParameters() :
    mDBType (DEFAULT_DATABASE_TYPE), mProvider(DEFAULT_PROVIDER_TYPE),
      mTimeout (DEFAULT_TIMEOUT_VALUE) {}
  ~DBInitParameters() {} ;

  void SetDBName (const _bstr_t &arDBName)
  { mDBName = arDBName ; }
  void SetServerName (const _bstr_t &arServerName)
  { mServerName = arServerName ; }
  void SetDBUser (const _bstr_t &arDBUser)
  { mDBUser = arDBUser ; }
  void SetDBPwd (const _bstr_t &arDBPwd)
  { mDBPwd = arDBPwd ; }
  void SetDBType (const _bstr_t &arDBType)
  { mDBType = arDBType ; }
  void SetProvider (const _bstr_t &arProvider)
  { mProvider = arProvider ; }
  void SetTimeout (const long &arTimeout)
  { mTimeout = arTimeout ; }
  void SetDataSource (const _bstr_t &arDataSource)
  { mDataSource = arDataSource ; }
  void SetDBDriver (const _bstr_t &arDBDriver)
  { mDBDriver = arDBDriver ; }
  void SetAccessType (const _bstr_t &arAccessType)
  { mAccessType = arAccessType ; }

  const _bstr_t GetDBName () const
  { return mDBName ; }
  const _bstr_t GetServerName () const
  { return mServerName ; }
  const _bstr_t GetDBUser () const
  { return mDBUser ; }
  const _bstr_t GetDBPwd () const
  { return mDBPwd ; }
  const _bstr_t GetDBType () const
  { return mDBType ; }
  const _bstr_t GetProvider () const
  { return mProvider ; }
  const long GetTimeout () const
  { return mTimeout ; }
  const _bstr_t GetDataSource () const
  { return mDataSource ; }
  const _bstr_t GetDBDriver () const
  { return mDBDriver ; }
  const _bstr_t GetAccessType () const
  { return mAccessType ; }
private:
  _bstr_t     mDBName  ;
  _bstr_t     mDBUser ;
  _bstr_t     mDBPwd ;
  _bstr_t     mServerName ;
  _bstr_t     mDBType ;
  _bstr_t     mProvider ;
  long        mTimeout ;
  _bstr_t     mDataSource ;
  _bstr_t     mDBDriver ;
  _bstr_t     mAccessType ;
} ;


// @class DBContext
class DBContext : public virtual ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
	DLL_EXPORT DBContext() :mUserName(L""), mPassword(L""), 
							mDBName(L""), mDBType(L""), mProvider(L""), 
							mDataSource(L""),  mDBDriver(L""), mAccessType(L"")
  {};
  // @cmember Destructor
  DLL_EXPORT virtual ~DBContext() {};

  // @cmember Initialize the Database Context
  DLL_EXPORT virtual BOOL Init (const DBInitParameters &arParams) = 0;

  // @cmember Connect to the Database
  DLL_EXPORT virtual BOOL Connect() = 0;
  // @cmember Disconnect from the Database
  DLL_EXPORT virtual BOOL Disconnect() = 0;
  // @cmember Execute the SQL command
  DLL_EXPORT virtual BOOL Execute (const std::wstring &arCmd, int aTimeout=DEFAULT_TIMEOUT_VALUE) = 0;
  // @cmember Execute the SQL command
  DLL_EXPORT virtual BOOL Execute (const std::wstring &arCmd, DBSQLRowset &arRowset) = 0;
  DLL_EXPORT virtual BOOL ExecuteConnected(const std::wstring &arCmd, DBSQLRowset &arRowset) 
	{
		ASSERT(!"ExecuteConnected not implemented for this DBContext");
		return FALSE;
	};
  // @cmember Execute the SQL command with a disconnected Recordset
  DLL_EXPORT virtual BOOL ExecuteDisconnected (const std::wstring &arCmd,
    DBSQLRowset &arRowset, LockTypeEnum lockType=adLockReadOnly) = 0;
  // @cmember Begin a transaction
  DLL_EXPORT virtual BOOL BeginTransaction() = 0;
  // @cmember Begin a transaction
  DLL_EXPORT virtual BOOL CommitTransaction() = 0;
  // @cmember Begin a transaction
  DLL_EXPORT virtual BOOL RollbackTransaction() = 0;

  // @cmember Initialize a command object to issue a stored procedure
  DLL_EXPORT BOOL virtual InitializeForStoredProc (const std::wstring &arStoredProcName) = 0;
  // @cmember Add parameter to the stored procedure
  DLL_EXPORT BOOL virtual AddParameterToStoredProc (const std::wstring &arParamName,
    const MTParameterType &arType, const MTParameterDirection &arDirection,
    const _variant_t &arValue) = 0;
  DLL_EXPORT BOOL virtual AddParameterToStoredProc (const std::wstring &arParamName,
    const MTParameterType &arType, const MTParameterDirection &arDirection) = 0;
  // @cmember Execute the stored procedure
  DLL_EXPORT BOOL virtual ExecuteStoredProc() = 0;
  // @cmember Execute the stored procedure
  DLL_EXPORT BOOL virtual ExecuteStoredProc(DBSQLRowset &arRowset) = 0;
  // @cmember Get the specified parameter back from the stored procedure
  DLL_EXPORT BOOL virtual GetParameterFromStoredProc (const std::wstring &arParamName,
    _variant_t &arValue) = 0;
// @access Protected:
protected:

	DLL_EXPORT virtual std::wstring GetTransactionContext();

  // @cmember the logging object
  // @cmember the UserName
  _bstr_t					mUserName ;
  // @cmember the Password
  _bstr_t		      mPassword ;
  // @cmember the Database name
  _bstr_t				  mDBName ;
  // @cmember the ODBC data source
  _bstr_t					mServerName ;
  _bstr_t         mDBType ;
  _bstr_t         mProvider ;
  _bstr_t         mDataSource ;
  _bstr_t         mDBDriver ;
  _bstr_t         mAccessType ;
  long            mTimeout ;
} ;

#endif // __DBContext_H
