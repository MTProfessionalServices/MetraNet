/**************************************************************************
 * @doc ADODBContext
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
 * $Header: C:\builds\v3.5\development\include\ADODBContext.h, 25, 7/24/2002 7:37:38 AM, Anagha Rangarajan$
 *
 * @index | ADODBContext
 ***************************************************************************/

#ifndef __ADODBCONTEXT_H
#define __ADODBCONTEXT_H

#include <DBContext.h>
#include <autologger.h>
#include <DbObjectsLogging.h>

const long MAX_VARCHAR_OUTPUT_SIZE = 4000;

// @class ADODBContext
class ADODBContext : public DBContext
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT ADODBContext() ;
  // @cmember Destructor
  DLL_EXPORT virtual ~ADODBContext() ;

  // @cmember Initialize the Database Context
  DLL_EXPORT virtual BOOL Init (const DBInitParameters &arParams) ;

  // @cmember Connect to the Database
  DLL_EXPORT virtual BOOL Connect() ;
  // @cmember Disconnect from the Database
  DLL_EXPORT virtual BOOL Disconnect() ;
  // @cmember Execute the SQL command

	// WARNING: the following two methods actually use disconnected recordsets.
	// use ExecuteConnected instead.
  DLL_EXPORT virtual BOOL Execute (const std::wstring &arCmd, int aTimeout=DEFAULT_TIMEOUT_VALUE) ;
  // @cmember Execute the SQL command
  DLL_EXPORT virtual BOOL Execute (const std::wstring &arCmd, DBSQLRowset &arRowset) ;

	// Executes a command using a connected recordset (really)
  DLL_EXPORT virtual BOOL ExecuteConnected(const std::wstring &arCmd, DBSQLRowset &arRowset);

  // @cmember Execute the SQL command with a disconnected Recordset
  DLL_EXPORT virtual BOOL ExecuteDisconnected (const std::wstring &arCmd,
    DBSQLRowset &arRowset, LockTypeEnum lockType=adLockReadOnly) ;
  // @cmember Begin a transaction
  DLL_EXPORT virtual BOOL BeginTransaction() ;
  // @cmember Begin a transaction
  DLL_EXPORT virtual BOOL CommitTransaction() ;
  // @cmember Begin a transaction
  DLL_EXPORT virtual BOOL RollbackTransaction() ;

  // @cmember Initialize a command object to issue a stored procedure
  DLL_EXPORT virtual BOOL InitializeForStoredProc (const std::wstring &arStoredProcName) ;
  // @cmember Add parameter to the stored procedure
  DLL_EXPORT virtual BOOL AddParameterToStoredProc (const std::wstring &arParamName,
    const MTParameterType &arType, const MTParameterDirection &arDirection,
    const _variant_t &arValue) ;
  DLL_EXPORT virtual BOOL AddParameterToStoredProc (const std::wstring &arParamName,
    const MTParameterType &arType, const MTParameterDirection &arDirection) ;
  // @cmember Execute the stored procedure
  DLL_EXPORT virtual BOOL ExecuteStoredProc() ;
  DLL_EXPORT virtual BOOL ExecuteStoredProc(DBSQLRowset &arRowset) ;
  // @cmember Get the specified parameter back from the stored procedure
  DLL_EXPORT virtual BOOL GetParameterFromStoredProc (const std::wstring &arParamName,
    _variant_t &arValue) ;

// @access Private:
private:
  // @cmember Verify the ado version
  BOOL VerifyADOVersion() ;

	MTAutoInstance<MTAutoLoggerImpl<szDbAccessTag,szDbObjectsDir> >	mLogger;
	MTAutoInstance<MTAutoLoggerImpl<szQueryLogTag,szQueryLogDir> >	mQueryLog;


  // @cmember the initialized flag
  BOOL            mInitialized ;
  // @cmember the stored procedure initialized flag
  BOOL            mProcInitialized ;
  // @cmember the ADO connection
  _ConnectionPtr  mConnection ;
  // @cmember the command used for stored procedures
  _CommandPtr     mCommand ;
  _bstr_t         mSprocName ;
} ;

#endif // __ADODBCONTEXT_H
