/**************************************************************************
 * @doc DBAccess
 * 
 * @module  Encapsulation for using the database context objects|
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
 * $Header: DBAccess.cpp, 34, 7/26/2002 5:54:54 PM, Raju Matta$
 *
 * @index | DBAccess
 ***************************************************************************/

#include <metra.h>
#include <DBContext.h>
#include <ADODBContext.h>
#include <OLEDBContext.h>
#include <DBAccess.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <mtprogids.h>

#include <string.h> 
//#include <typeinfo> // run-time type info and bad_cast

// import the query adapter tlb ...
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

//
//	@mfunc
//	Initialize the data member.
//  @rdesc 
//  No return value.
//
DBAccess::DBAccess() : mpDBContext(NULL)
{
	mpParams = new DBInitParameters();
}

//
//	@mfunc
//	Destructor.
//  @rdesc 
//  No return value.
//
DBAccess::~DBAccess()
{
  // disconnect from the database context ...
  Disconnect() ;

  // if we have a dbcontext object free it ...
  if (mpDBContext != NULL)
  {
    delete mpDBContext ;
    mpDBContext = NULL ;
  }

  if (mpParams != NULL)
  {
	  delete mpParams ;
	  mpParams = NULL ;
}
}

//
//	@mfunc
//	Initialize and connect the database context object.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is stored in the mLastError data member.
//
BOOL DBAccess::Init(const std::wstring &arDBName, const std::wstring &arServerName,
    const std::wstring &arDBUser, const std::wstring &arDBPwd)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  LoggerConfigReader cfgRdr ;

  // initialize the parameters ...
  mpParams->SetAccessType (MTACCESSTYPE_ADO) ;
  mpParams->SetDBUser (arDBUser.c_str()) ;
  mpParams->SetDBPwd (arDBPwd.c_str()) ;
  mpParams->SetDBName (arDBName.c_str()) ;
  mpParams->SetServerName (arServerName.c_str()) ;

  // if we already have a dbcontext object free it ...
  if (mpDBContext != NULL)
  {
    delete mpDBContext ;
    mpDBContext = NULL ;
  }

  // allocate an ADODBContext object ...
  mpDBContext = new ADODBContext ;
  ASSERT(mpDBContext) ;
  if (mpDBContext == NULL)
  {
    SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Unable to allocate Database context object.");
    bRetCode = FALSE ;
  }
  else
  {    
    // intialize the DBContext object ...
    bRetCode = InitDbContext(mpParams);
  }

  return bRetCode ;
}

//
//	@mfunc
//	Initialize and connect the database context object.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is stored in the mLastError data member.
//
BOOL DBAccess::InitByDataSource(const std::wstring &arDataSourceName, const std::wstring &arDBUser, 
                    const std::wstring &arDBPwd, _bstr_t accessType)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  LoggerConfigReader cfgRdr ;
  BOOL bAccessADO;
  BOOL bAccessOLEDB;

  //  validate access type is DSN

  bAccessADO =    (0 == wcscmp ( (wchar_t *)accessType, MTACCESSTYPE_ADO_DSN)) ? TRUE : FALSE;
  bAccessOLEDB =  (0 == wcscmp ( (wchar_t *)accessType, MTACCESSTYPE_OLEDB_DSN)) ? TRUE : FALSE;


  // initialize the parameters ...
  mpParams->SetAccessType (accessType) ;
  mpParams->SetDBUser (arDBUser.c_str()) ;
  mpParams->SetDBPwd (arDBPwd.c_str()) ;
  mpParams->SetDataSource (arDataSourceName.c_str()) ;

  //BP: this method is only used for Oracle
  mpParams->SetDBType("{Oracle}");

  // if we are using OLEDB, set the provider to ODBC
  if ( bAccessOLEDB )
  {
    mpParams->SetProvider(DEFAULT_PROVIDER_TYPE) ;
  }

  // if we already have a dbcontext object free it ...
  if (mpDBContext != NULL)
  {
    delete mpDBContext ;
    mpDBContext = NULL ;
  }

  if (bAccessADO)
  {
    // allocate an ADODBContext object ...
    mpDBContext = new ADODBContext ;
    ASSERT(mpDBContext) ;
    if (mpDBContext == NULL)
    {
      SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
        "Unable to allocate Database context object.");
      bRetCode = FALSE ;
    }
  }
  else if (bAccessOLEDB)
  {
    // allocate an OLEDBContext object ...
    mpDBContext = new OLEDBContext ;
    ASSERT(mpDBContext) ;
    if (mpDBContext == NULL)
    {
      SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
        "Unable to allocate Database context object.");
      bRetCode = FALSE ;
    }
  }
  else
  {
    SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Unable to initialize database access layer. Incorrect DB Access Type, not DSN type.");
    mLogger->LogVarArgs (LOG_ERROR, 
      "Database access layer Init() failed. Invalid access type = %s", (char*) accessType) ;
    bRetCode = FALSE ;
  }

  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    // intialize the DBContext object ...
    bRetCode = InitDbContext(mpParams); 
  }

  return bRetCode ;
}


//
//	@mfunc
//	Initialize and connect the database context object.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is stored in the mLastError data member.
//
BOOL DBAccess::Init(const std::wstring &arConfigPath)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  _bstr_t accessType ;

  // if we already have a dbcontext object free it ...
  if (mpDBContext != NULL)
  {
    delete mpDBContext ;
    mpDBContext = NULL ;
  }

  try
  {
    // create the queryadapter ...
    IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
    
    // initialize the queryadapter ...
    queryAdapter->Init(arConfigPath.c_str()) ;
    
    // get the database access info ...
    accessType = (queryAdapter->GetAccessType()) ;
    mpParams->SetAccessType (accessType) ;
    mpParams->SetDBUser (queryAdapter->QAGetUserName()) ;
    mpParams->SetDBPwd (queryAdapter->GetPassword()) ;
    mpParams->SetProvider(queryAdapter->GetProvider()) ;
    mpParams->SetTimeout(queryAdapter->GetTimeout()) ;
    mpParams->SetDBType (queryAdapter->GetDBType()) ;
    mpParams->SetDBDriver (queryAdapter->GetDBDriver()) ;
    if (accessType == ((_bstr_t) MTACCESSTYPE_ADO))
    {
      mpParams->SetDBName (queryAdapter->GetDBName()) ;
      mpParams->SetServerName (queryAdapter->GetServerName()) ;

      // allocate an ADODBContext object ...
      mpDBContext = new ADODBContext ;
      ASSERT(mpDBContext) ;
      if (mpDBContext == NULL)
      {
        SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
          "Unable to allocate Database context object.");
        bRetCode = FALSE ;
      }
    }
    else if (accessType == ((_bstr_t) MTACCESSTYPE_ADO_DSN))
    {
      mpParams->SetDataSource (queryAdapter->GetDataSource()) ;

      // allocate an ADODBContext object ...
      mpDBContext = new ADODBContext ;
      ASSERT(mpDBContext) ;
      if (mpDBContext == NULL)
      {
        SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
          "Unable to allocate Database context object.");
        bRetCode = FALSE ;
      }
    }
    else if (accessType == ((_bstr_t) MTACCESSTYPE_OLEDB))
    {
      mpParams->SetDBName (queryAdapter->GetDBName()) ;
      mpParams->SetServerName (queryAdapter->GetServerName()) ;

      // allocate an OLEDBContext object ...
      mpDBContext = new OLEDBContext ;
      ASSERT(mpDBContext) ;
      if (mpDBContext == NULL)
      {
        SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
          "Unable to allocate Database context object.");
        bRetCode = FALSE ;
      }
    }
    else if (accessType == ((_bstr_t) MTACCESSTYPE_OLEDB_DSN))
    {
      mpParams->SetDataSource (queryAdapter->GetDataSource()) ;

      // allocate an OLEDBContext object ...
      mpDBContext = new OLEDBContext ;
      ASSERT(mpDBContext) ;
      if (mpDBContext == NULL)
      {
        SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
          "Unable to allocate Database context object.");
        bRetCode = FALSE ;
      }
    }
    else
    {
      SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
        "Unable to initialize database access layer.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Database access layer Init() failed. Invalid access type = %s", (char*) accessType) ;
      bRetCode = FALSE ;
    }
  }
  catch (_com_error e)
  {
    //SetError(e) ;
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Unable to initialize query adapter");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "Database access layer Init() failed. Error Description = %s",
      e.Description()) ;
    bRetCode = FALSE ;
  }
  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    // initialize the database access layer with the db config info read ...
    bRetCode = InitDbContext(mpParams); 
  }

  return bRetCode ;
}

//
//	@mfunc
//	Initialize the database access layer (DBContext)
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is stored in the mLastError data member.
//
DLL_EXPORT BOOL DBAccess::InitDbContext(DBInitParameters *params) 
{
	ASSERT(mpDBContext) ;
	ASSERT(params) ;
	BOOL bRetCode = mpDBContext->Init(*params) ;
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(), "Database access layer Init() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    else
    {
      // connect to the database ...
      bRetCode = mpDBContext->Connect() ;
      if (bRetCode == FALSE)
      {
        SetError(mpDBContext->GetLastError(), "Database access layer Connect() failed.");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      }
    }

  return bRetCode ;
}

//
//	@mfunc
//	Changes DBName re-initialize and connect the database context object.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is stored in the mLastError data member.
//
BOOL DBAccess::ChangeDbName(const std::wstring  &newDBName)
{
	ASSERT(mpParams) ;
	Disconnect();
	mpParams->SetDBName(newDBName.c_str());
	return InitDbContext(mpParams); 
}

//
//	@mfunc
//	Disconnect from the database context object.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is stored in the mLastError data member.
//
BOOL DBAccess::Disconnect()
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // disconnect from the database context ...
  if (mpDBContext != NULL)
  {
    bRetCode = mpDBContext->Disconnect() ;
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(), 
        "Database access layer Disconnect() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }

  return bRetCode ;
}

//
//	@mfunc
//	Execute a command 
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is stored in the mLastError data member.
//
BOOL DBAccess::Execute (const std::wstring &arCmd, int aTimeout)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  
  // execute the command ...
  if (mpDBContext != NULL)
  {
    bRetCode = mpDBContext->Execute (arCmd, aTimeout) ;
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(), 
        "Database access layer Execute() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  else
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Database access layer not initialized.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	Execute a command 
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is stored in the mLastError data member.
//
BOOL DBAccess::Execute (const std::wstring &arCmd, DBSQLRowset &arRowset)
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // execute the command ...
  if (mpDBContext != NULL)
  {
    bRetCode = mpDBContext->Execute (arCmd, arRowset) ;
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(), 
        "Database access layer Execute() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }    
  }
  else
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Database access layer not initialized.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  return bRetCode ;
}

//
// Replacement for Execute. This method correctly uses connected recordsets.
// This method should be used for large recordsets to improve performance.
//
BOOL DBAccess::ExecuteConnected(const std::wstring &arCmd, DBSQLRowset &arRowset)
{
  BOOL bRetCode = TRUE;

  // executes the command
  if (mpDBContext != NULL)
  {
    bRetCode = mpDBContext->ExecuteConnected(arCmd, arRowset);
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(), "Database access layer Execute() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError());
    }    
  }
  else
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Database access layer not initialized.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  return bRetCode;
}

//
//	@mfunc
//	Execute a command 
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is stored in the mLastError data member.
//
BOOL DBAccess::ExecuteDisconnected (const std::wstring &arCmd, DBSQLRowset &arRowset, LockTypeEnum aLockType)
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // execute the command ...
  if (mpDBContext != NULL)
  {
    bRetCode = mpDBContext->ExecuteDisconnected (arCmd, arRowset, aLockType) ;
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(), 
        "Database access layer ExecuteDisconnected() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  else
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Database access layer not initialized.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
    
  return bRetCode ;
}

BOOL DBAccess::ExecuteDisconnectedHACK (const std::wstring &arCmd, DBSQLRowset &arRowset)
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // execute the command ...
  if (mpDBContext != NULL)
  {
    bRetCode = mpDBContext->ExecuteDisconnected (arCmd, arRowset, adLockBatchOptimistic) ;
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(), 
        "Database access layer ExecuteDisconnectedHACK() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  else
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Database access layer not initialized.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  return bRetCode ;
}



//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL DBAccess::BeginTransaction()
{
  // local variables
  BOOL bRetCode=TRUE ;

  if (mpDBContext != NULL)
  {
    // call execute for stored proc ...
    bRetCode = mpDBContext->BeginTransaction() ;
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(),
        "Database access layer BeginTransaction() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  else
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Database access layer not initialized.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL DBAccess::CommitTransaction()
{
  // local variables
  BOOL bRetCode=TRUE ;

  if (mpDBContext != NULL)
  {
    // call execute for stored proc ...
    bRetCode = mpDBContext->CommitTransaction() ;
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(),
        "Database access layer CommitTransaction() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  else
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Database access layer not initialized.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL DBAccess::RollbackTransaction()
{
  // local variables
  BOOL bRetCode=TRUE ;

  if (mpDBContext != NULL)
  {
    // call execute for stored proc ...
    bRetCode = mpDBContext->RollbackTransaction() ;
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(),
        "Database access layer RollbackTransaction() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  else
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Database access layer not initialized.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL DBAccess::InitializeForStoredProc (const std::wstring &arStoredProcName)
{
  // local variables
  BOOL bRetCode=TRUE ;

  if (mpDBContext != NULL)
  {
    // calll initialize for stored proc ...
    bRetCode = mpDBContext->InitializeForStoredProc (arStoredProcName) ;
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(), 
        "Database access layer InitializeForStoredProc() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  else
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Database access layer not initialized.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
		bRetCode = FALSE ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL DBAccess::AddParameterToStoredProc (const std::wstring &arParamName, 
    const MTParameterType &arType, const MTParameterDirection &arDirection, 
    const _variant_t &arValue)
{
  // local variables
  BOOL bRetCode=TRUE ;

  if (mpDBContext != NULL)
  {
    // calll add parameter for stored proc ...
    bRetCode = mpDBContext->AddParameterToStoredProc (arParamName, arType, 
      arDirection, arValue) ;
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(), 
        "Database access layer AddParameterToStoredProc() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  else
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Database access layer not initialized.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL DBAccess::AddParameterToStoredProc (const std::wstring &arParamName, 
    const MTParameterType &arType, const MTParameterDirection &arDirection)
{
  // local variables
  BOOL bRetCode=TRUE ;

  if (mpDBContext != NULL)
  {
    // calll add parameter for stored proc ...
    bRetCode = mpDBContext->AddParameterToStoredProc (arParamName, arType, 
      arDirection) ;
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(), 
        "Database access layer AddParameterToStoredProc() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  else
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Database access layer not initialized.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  return bRetCode ;
}


//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL DBAccess::ExecuteStoredProc()
{
	DBSQLRowset rs;
	return ExecuteStoredProc(rs);
}

BOOL DBAccess::ExecuteStoredProc(DBSQLRowset &arRowset)
{
  // local variables
  BOOL bRetCode=TRUE ;

  if (mpDBContext != NULL)
  {
    // call execute for stored proc ...
    bRetCode = mpDBContext->ExecuteStoredProc(arRowset) ;
    if (bRetCode == FALSE)
    {
			SetError(mpDBContext->GetLastError());
      //SetError(mpDBContext->GetLastError(),
      //  "Database access layer ExecuteStoredProc() failed.");
      //mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  else
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Database access layer not initialized.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  return bRetCode ;
}



//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL DBAccess::JoinDistributedTransaction(RowSetInterfacesLib::IMTTransactionPtr aTransaction)
{
  BOOL bRetCode=TRUE ;

	OLEDBContext* pOLEDBContext = dynamic_cast<OLEDBContext*>(mpDBContext);

	if (pOLEDBContext != NULL)
	{
		// calll get parameter from stored proc ...
		bRetCode = pOLEDBContext->JoinDistributedTransaction (aTransaction) ;
		if (bRetCode == FALSE)
		{
			SetError(mpDBContext->GetLastError(),
							 "Database access layer JoinDistributedTransaction() failed.");
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
		}
	}
	else
	{
 	  if(mpDBContext != NULL)
		{
			SetError(DB_ERR_NO_DISTRIBUTED_TRANSACTION_SUPPORT, 
							 ERROR_MODULE, ERROR_LINE, "DBAccess::JoinDistributedTransaction", 
							 "DBContext does not cast to supporting distributed transactions (OLEDB is required)");
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			bRetCode=FALSE ;
		}
		else
		{
      SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::JoinDistributedTransaction", 
							 "Database access layer not initialized.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      bRetCode=FALSE ;
		}
	}

  return bRetCode ;
}

RowSetInterfacesLib::IMTTransactionPtr DBAccess::GetDistributedTransaction()
{
	// TODO: this method no longer makes sense - the rowset doesn't own the transaction
	SetError(DB_ERR_NO_DISTRIBUTED_TRANSACTION_SUPPORT, 
					 ERROR_MODULE, ERROR_LINE, "DBAccess::JoinDistributedTransaction", 
					 "GetDistributedTransaction no longer supported");
	return NULL;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL DBAccess::GetParameterFromStoredProc (const std::wstring &arParamName, 
                                           _variant_t &arValue)
{
  // local variables
  BOOL bRetCode=TRUE ;

  if (mpDBContext != NULL)
  {
    // calll get parameter from stored proc ...
    bRetCode = mpDBContext->GetParameterFromStoredProc (arParamName, arValue) ;
    if (bRetCode == FALSE)
    {
      SetError(mpDBContext->GetLastError(),
        "Database access layer GetParameterFromStoredProc() failed.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  else
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBAccess::Init", 
      "Database access layer not initialized.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  return bRetCode ;
}
