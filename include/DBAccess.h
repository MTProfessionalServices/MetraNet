/**************************************************************************
 * @doc DBAccess
 * 
 * @module  Encapsulation for using the database context objects |
 * 
 * This class encapsulates accessing the database context.
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
 * $Header: C:\builds\v3.5\development\include\DBAccess.h, 25, 7/24/2002 7:41:51 AM, Anagha Rangarajan$
 *
 * @index | DBAccess
 ***************************************************************************/

#ifndef __DBACCESS_H
#define __DBACCESS_H

#include <comdef.h>
#include <DBSQLRowset.h>
#include <errobj.h>
#include <autologger.h>
#include <DbObjectsLogging.h>
#include <DataAccessDefs.h>
#include <RowsetDefs.h>

#import <rowsetinterfaceslib.tlb> rename("EOF", "RowsetEOF")

// forward declarations ...
class DBContext ;
class DBInitParameters;

// @class DBAccess
class DBAccess : public virtual ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBAccess() ;
  // @cmember Destructor
  DLL_EXPORT virtual ~DBAccess() ;
  // @cmember Initialize and connect to the database context
  DLL_EXPORT BOOL Init(const std::wstring &arDBName, const std::wstring  &arServerName,
    const std::wstring  &arDBUser, const std::wstring  &arDBPwd) ;
  DLL_EXPORT BOOL InitByDataSource(const std::wstring  &arDataSource, const std::wstring  &arDBUser, 
    const std::wstring  &arDBPwd, _bstr_t accessType = MTACCESSTYPE_ADO_DSN) ;
  // @cmember Initialize and connect to the database context
  DLL_EXPORT BOOL Init(const std::wstring  &arConfigPath) ;
  // @cmember Changes database name
  DLL_EXPORT BOOL ChangeDbName(const std::wstring  &newDBName) ;
  // @cmember Disconnect from the database context
  DLL_EXPORT BOOL Disconnect() ;

	// WARNING: the following two methods actually use disconnected recordsets.
	// use ExecuteConnected instead.
  // @cmember Execute a command
  DLL_EXPORT BOOL Execute(const std::wstring  &arCmd, int aTimeout=DEFAULT_TIMEOUT_VALUE) ;
  // @cmember Execute a command and get a rowset back
  DLL_EXPORT BOOL Execute(const std::wstring  &arCmd, DBSQLRowset &arRowset) ;

	// Executes a command using a connected recordset (really)
  DLL_EXPORT BOOL ExecuteConnected(const std::wstring  &arCmd, DBSQLRowset &arRowset);

  // @cmember Execute a command and get back a disconnected rowset
  DLL_EXPORT BOOL ExecuteDisconnected (const std::wstring  &arCmd, DBSQLRowset &arRowset, LockTypeEnum aLockType=adLockReadOnly) ;
  DLL_EXPORT BOOL ExecuteDisconnectedHACK (const std::wstring  &arCmd, DBSQLRowset &arRowset) ;
  // @cmember Begin a transaction
  DLL_EXPORT BOOL BeginTransaction() ;
  // @cmember Begin a transaction
  DLL_EXPORT BOOL CommitTransaction() ;
  // @cmember Begin a transaction
  DLL_EXPORT BOOL RollbackTransaction() ;

    // @cmember Initialize a command object to issue a stored procedure
  DLL_EXPORT BOOL InitializeForStoredProc (const std::wstring  &arStoredProcName) ;
  // @cmember Add parameter to the stored procedure 
    DLL_EXPORT BOOL AddParameterToStoredProc (const std::wstring  &arParamName, 
    const MTParameterType &arType, const MTParameterDirection &arDirection, 
    const _variant_t &arValue) ;
  DLL_EXPORT BOOL AddParameterToStoredProc (const std::wstring  &arParamName, 
    const MTParameterType &arType, const MTParameterDirection &arDirection) ;
  // @cmember Execute the stored procedure
  DLL_EXPORT BOOL ExecuteStoredProc() ;
  // @cmember Execute the stored procedure with a recordset
  DLL_EXPORT BOOL ExecuteStoredProc(DBSQLRowset &arRowset) ;
  // @cmember Get the specified parameter back from the stored procedure
  DLL_EXPORT BOOL GetParameterFromStoredProc (const std::wstring  &arParamName, _variant_t &arValue) ;

  // @cmember Execute a stored procedure within a Distributed Transaction
  // This method is specific to OLEDB 
  //
  // Called by the remote participant of the transaction
  // to join a transaction before executing the queries.
  // Only join if we have no already joined our session to a transaction.
  // A session can be joined to only one transaction.
  //
  DLL_EXPORT BOOL JoinDistributedTransaction(RowSetInterfacesLib::IMTTransactionPtr aTransaction);

	DLL_EXPORT RowSetInterfacesLib::IMTTransactionPtr GetDistributedTransaction();

protected:
	// @cmember initialize the database access layer with the db config
	DLL_EXPORT BOOL InitDbContext(DBInitParameters *params) ;

private:
  // @cmember the Database context 
  DBContext    *mpDBContext ;
  // @cmember the NTLogger object 
	MTAutoInstance<MTAutoLoggerImpl<szDbAccessTag,szDbObjectsDir> >	mLogger; 
  // @cmember the Database parameters 
  DBInitParameters *mpParams ;

} ;


// renable warning ...
#pragma warning( default : 4251 4275)

#endif // __DBACCESS_H

