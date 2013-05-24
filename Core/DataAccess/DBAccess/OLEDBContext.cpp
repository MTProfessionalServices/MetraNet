/**************************************************************************
 * @doc OLEDBContext
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
 * $Header: OLEDBContext.cpp, 49, 9/11/2002 9:40:11 AM, Alon Becker$
 *
 * @index | OLEDBContext
 ***************************************************************************/

#define MT_TRACE_CONNECTIONS

#include <metra.h>
#include <mtcom.h>
#include <mtglobal_msg.h>
#include <comdef.h>
#include <comsvcs.h>
#include <string>
#include <OLEDBContext.h>
#include <mtprogids.h>
#include <iostream>
#include <base64.h> // encode/decode
#include <atlconv.h> // for char conversion
#include <SharedDefs.h>

#include <txdtc.h>  // distributed transaction support
#include <xolehlp.h>  // distributed transaction support

#ifndef _ATLBASE_H
#include <atlbase.h>
#endif

#ifndef __oledb_h__
#include <oledb.h>
#endif // __oledb_h__

#include <msdaguid.h>
#include <msdasc.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent")
#import <MetraTech.Debug.Transaction.tlb> inject_statement("using namespace mscorlib;") no_function_mapping

using namespace std;


_COM_SMARTPTR_TYPEDEF(ITransactionJoin, IID_ITransactionJoin);
_COM_SMARTPTR_TYPEDEF(ITransactionObject, IID_ITransactionObject);
_COM_SMARTPTR_TYPEDEF(ITransaction, IID_ITransaction);

static std::wstring GuidToString(const GUID& guid)
{
	wchar_t buf1[64];
	std::wstring result;

	wsprintf(buf1, L"%.8x", (int)guid.Data1);
	result = buf1;
	result += L"-";
	wsprintf(buf1, L"%.4x", (int)guid.Data2);
	result += buf1;
	result += L"-";
	wsprintf(buf1, L"%.4x", (int)guid.Data3);
	result += buf1;
	result += L"-";
	wsprintf(buf1, L"%.2x", (int)guid.Data4[0]);
	result += buf1;
	wsprintf(buf1, L"%.2x", (int)guid.Data4[1]);
	result += buf1;

	result += L"-";
	wsprintf(buf1, L"%.2x", (int)guid.Data4[2]);
	result += buf1;
	wsprintf(buf1, L"%.2x", (int)guid.Data4[3]);
	result += buf1;
	wsprintf(buf1, L"%.2x", (int)guid.Data4[4]);
	result += buf1;
	wsprintf(buf1, L"%.2x", (int)guid.Data4[5]);
	result += buf1;
	wsprintf(buf1, L"%.2x", (int)guid.Data4[6]);
	result += buf1;
	wsprintf(buf1, L"%.2x", (int)guid.Data4[7]);
	result += buf1;

	return result;
}

std::wstring DBContext::GetTransactionContext()
{
	IObjectContextInfo* pCtxt;
	GUID txn;
	BOOL bDtc=FALSE;
  HRESULT hr = S_OK;
  hr = ::CoGetObjectContext(IID_IObjectContextInfo, (LPVOID *) &pCtxt);
	if(!FAILED(hr))
	{
		if(TRUE == pCtxt->IsInTransaction())
		{
			if(!FAILED(pCtxt->GetTransactionId(&txn)))
			{
				bDtc = TRUE;
			}
		}
		pCtxt->Release();
		pCtxt = NULL;
	}
	if (bDtc)
	{
		return std::wstring(L"DTC<") + ::GuidToString(txn) + std::wstring(L">: ");
	}
	else
	{
		return L"LocalTransaction: ";
	}
}

std::wstring OLEDBContext::GetTransactionContext()
{
	if(mJoinedDistributed)
	{
		// This is a major hack.  This object will create a serviced component using
		// BYOT and the transaction passed in.  Then the object will get the TRID from
		// its context.  I do not know how to get a TRID directly from an ITransaction!
    MetraTech_Debug_Transaction::ITransactionDebugPtr info(__uuidof(MetraTech_Debug_Transaction::TransactionDebug));
		return std::wstring(L"DTC<") + std::wstring((const wchar_t *) info->GetTransactionID(reinterpret_cast<MetraTech_Debug_Transaction::IMTTransaction*>(mDistributedTransaction.GetInterfacePtr()))) + std::wstring(L">: ");
	}
	else
	{
		return DBContext::GetTransactionContext();
	}
}

//
//  This is a static function so that I can easily share error-processing
//  code between two classes.
//
////////////////////////////////////////////////////////////////////////////

void GetOLEDBError (HRESULT aError, const char *pString, ErrorList &arErrorList);



//
//	@mfunc
//	Constructor. Initialize the appropriate data members
//  @rdesc 
//  No return value
//
////////////////////////////////////////////////////////////////////////////

OLEDBContext::OLEDBContext()
: mInitialized(FALSE), mProcInitialized(FALSE), mpIDBInit(NULL), 
mpIDBCreateSession(NULL), mpICreateCmd(NULL),
	mpITransaction(NULL),
	mJoinedDistributed(FALSE)
{  
}

//
//	@mfunc
//	Destructor
//  @rdesc 
//  No return value
//
////////////////////////////////////////////////////////////////////////////

OLEDBContext::~OLEDBContext()
{
  Disconnect() ;
}

//
//  init connection parameters
//  does not connect or anything else
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::Init(const DBInitParameters &arParams)
{
  // local variables 
  BOOL bRetCode=TRUE ;
  DWORD nError=NO_ERROR ;

  try 
  {
		mJoinedDistributed = FALSE;

    // copy the parameters to the data members ...
    mAccessType = arParams.GetAccessType() ;
		if (arParams.GetDataSource().length() > 0)
			mAccessType = (_bstr_t) MTACCESSTYPE_OLEDB_DSN;
    mDBType = arParams.GetDBType() ;
    if (mAccessType == ((_bstr_t) MTACCESSTYPE_OLEDB))
    {
      mDBName = arParams.GetDBName() ;
      mServerName = arParams.GetServerName() ;
    }
    else if (mAccessType == ((_bstr_t) MTACCESSTYPE_OLEDB_DSN))
    {
      mDataSource = arParams.GetDataSource() ;
    }
    else
    {
      nError = DB_ERR_INVALID_PARAMETER ;
      SetError (nError, ERROR_MODULE, ERROR_LINE,
        "OLEDBContext::Init", "Invalid access type specified.") ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Invalid access type specified. Access Type = %s", (char*)mAccessType) ;
      throw nError ;
    }
    mUserName = arParams.GetDBUser() ;
    mPassword = arParams.GetDBPwd() ;
    mTimeout = arParams.GetTimeout() ;
    mProvider = arParams.GetProvider() ;    
    mDBDriver = arParams.GetDBDriver() ;
    // set the initialized data member ...
    mInitialized = TRUE ;
  }
  catch (DWORD nResult)
  {
    SetError (nResult, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Init") ;
    mLogger->LogThis (LOG_ERROR, "Initialization of database context failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    nResult = 0 ;
    bRetCode = FALSE ;
  }
  catch (_com_error e)
  {
    // SetError (e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "OLEDBContext::Init") ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Initialization of database context failed. Error Description = %s",
      (char*)e.Description()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Init") ;
    mLogger->LogThis (LOG_ERROR, "Initialization of database context failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }
#endif
  
  return bRetCode ;
}

//
//	@mfunc
//	Connect to the database using the configuration information.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
//  Creates : mpIDBInit (IDBInitialize*), 
//            mpIDBCreateSession (IDBCreateSession*)
//            mpICreateCmd (IDBCreateCommand *)
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::Connect()
{
  #define MAX_PROP_INDEX 7
	BOOL bRetCode = TRUE;
  IDBProperties*	pIDBProperties = NULL;
  CLSID clsid ;
  DBPROP rgProps[MAX_PROP_INDEX+1];
  DBPROPSET dbPropSet;
  HRESULT nRetVal=S_OK ;
  ErrorList errorList ;

	try
	{
    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect",
        "Database context not initialized") ;
      throw nRetVal ;
    }

		//NOTE!!!!!!!!!! For Oracle always set provider to OraOledb (no ODBC)
		if (mDBType == (_bstr_t) ORACLE_DATABASE_TYPE)
		{
			mProvider  = "OraOLEDB.Oracle";
		}

    nRetVal = ::CLSIDFromProgID (mProvider, &clsid) ;
    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect", 
        "cannot get progID of the provider.") ;
      GetOLEDBError( nRetVal, "CLSIDFromProgID", errorList);
      throw nRetVal ;
    }
    
    // connect to the database ...

		// follow the MSDN to enable the connection pool.


		IDataInitialize *  pIDataInitialize = NULL;

		nRetVal = CoCreateInstance
				(
				 CLSID_MSDAINITIALIZE,
				 NULL,
				 CLSCTX_INPROC_SERVER,
				 IID_IDataInitialize,
				 (void**)&pIDataInitialize
				 );
		
		if(!(SUCCEEDED(nRetVal))){
				SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect",
								 "CoCreateInstance of DataInitialize failed.");
				GetOLEDBError(nRetVal, "CoCreateInstance of DataInitialize", errorList);
				throw nRetVal;
		}

		ASSERT(mpIDBInit == 0);
		nRetVal = pIDataInitialize->CreateDBInstance
				(
				 clsid,
				 NULL,
				 CLSCTX_INPROC_SERVER,
				 NULL,
				 IID_IDBInitialize,
				 (IUnknown**)&mpIDBInit
				 );

		pIDataInitialize->Release();
		pIDataInitialize = NULL;

#if 0
    nRetVal = CoCreateInstance(clsid, NULL, CLSCTX_INPROC_SERVER, 
      IID_IDBInitialize, (void **)&mpIDBInit ); 
#endif
    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect", 
        "CreateDBInstance of provider failed.") ;
      GetOLEDBError( nRetVal, "CreateDBInstance of provider", errorList );
      throw nRetVal ;
    }
    
    // initialize this provider with the initialization properties ...

    // Set the initialization properties.   
      for (ULONG i = 0; i <= MAX_PROP_INDEX; i++)  // WARNING <-- check that we don't exceed 5 connect params
      {
        VariantInit(&rgProps[i].vValue);
        rgProps[i].dwOptions = DBPROPOPTIONS_REQUIRED;
      };

      unsigned long prop_index=0 ;
      
      if (mProvider != _bstr_t("MSDASQL"))
			{
				//
				// MSDAORA or SQLOLEDB provider - native interface
				//

				V_VT(&(rgProps[prop_index].vValue)) = VT_BSTR;
				if (mAccessType == ((_bstr_t) MTACCESSTYPE_OLEDB_DSN))
				{
					rgProps[prop_index].dwPropertyID = DBPROP_INIT_DATASOURCE; // The SQL Server to connect to
					V_BSTR(&(rgProps[prop_index].vValue)) = mDataSource ;
				}
				else
				{
					rgProps[prop_index].dwPropertyID = DBPROP_INIT_DATASOURCE; // The SQL Server to connect to
					V_BSTR(&(rgProps[prop_index].vValue)) = mServerName ;
				}
				++prop_index;
				if ( prop_index > MAX_PROP_INDEX)
				{
					nRetVal = E_FAIL;
					SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect", "Database context not initialized") ;
					mLogger->LogThis (LOG_ERROR, "Too many initialization properties.  Array overflow.") ;
					throw nRetVal ;
				}
      
				rgProps[prop_index].dwPropertyID = DBPROP_AUTH_PASSWORD;  // password
      
				V_VT(&(rgProps[prop_index].vValue)) = VT_BSTR;
				V_BSTR(&(rgProps[prop_index].vValue)) = mPassword ;
				++prop_index;
				if ( prop_index > MAX_PROP_INDEX)
				{
					nRetVal = E_FAIL;
					SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect", "Database context not initialized") ;
					mLogger->LogThis (LOG_ERROR, "Too many initialization properties.  Array overflow.") ;
					throw nRetVal ;
				}
      
				rgProps[prop_index].dwPropertyID = DBPROP_AUTH_USERID;  // user name
      
				V_VT(&(rgProps[prop_index].vValue)) = VT_BSTR;
				V_BSTR(&(rgProps[prop_index].vValue)) = mUserName ;
				++prop_index;
				if ( prop_index > MAX_PROP_INDEX)
				{
					nRetVal = E_FAIL;
					SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect", "Database context not initialized") ;
					mLogger->LogThis (LOG_ERROR, "Too many initialization properties.  Array overflow.") ;
					throw nRetVal ;
				}
      
				// don't need database name if we are using a datasource
				if (mAccessType == ((_bstr_t) MTACCESSTYPE_OLEDB))
				{
					rgProps[prop_index].dwPropertyID = DBPROP_INIT_CATALOG;  // The SQL Server database.
      
					V_VT(&(rgProps[prop_index].vValue)) = VT_BSTR;
					V_BSTR(&(rgProps[prop_index].vValue)) = mDBName ;
					++prop_index;
					if ( prop_index > MAX_PROP_INDEX)
					{
						nRetVal = E_FAIL;
						SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect", "Database context not initialized") ;
						mLogger->LogThis (LOG_ERROR, "Too many initialization properties.  Array overflow.") ;
						throw nRetVal ;
					}
				}

#ifdef MT_TRACE_CONNECTIONS
				mLogger->LogVarArgs(LOG_TRACE, "[CnxTrace] >>> opening OLEDB [%x]: %s", this,
														(const char*)mProvider);
#endif
			}
      else
			{
				//
				// MSDASQL provider - OLEDB over ODBC
				//

				// construct a connection string directly
				_bstr_t connectionString;
				if (mDataSource.length() > 0)
				{
					// DSN specified
					connectionString = L"DSN=";
					connectionString = mDataSource;
				}
				else
				{
					// DSN-less connection
					if (mDBType == (_bstr_t) ORACLE_DATABASE_TYPE)
					{
						connectionString =
							L"DRIVER={Microsoft ODBC for Oracle};"
							L"SERVER=";
					}
					else
					{
						connectionString =
							L"DRIVER={SQL Server};"
							L"SERVER=";
					}

					connectionString += mServerName;
				}

				// always specify username/password
				connectionString += L";UID=";
				connectionString += mUserName;
				connectionString += L";PWD=";
				connectionString += mPassword;

				rgProps[prop_index].dwPropertyID = DBPROP_INIT_PROVIDERSTRING;
      
				V_VT(&(rgProps[prop_index].vValue)) = VT_BSTR;
				V_BSTR(&(rgProps[prop_index].vValue)) = connectionString;
				++prop_index;
				if ( prop_index > MAX_PROP_INDEX)
				{ 
					nRetVal = E_FAIL;
					SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect", "Database context not initialized") ;
					mLogger->LogThis (LOG_ERROR, "Too many initialization properties.  Array overflow.") ;
					throw nRetVal ;
				}

#ifdef MT_TRACE_CONNECTIONS
				mLogger->LogVarArgs(LOG_TRACE, "[CnxTrace] >>> opening OLEDB [%x]: %s", this, (const char*)connectionString);
#endif
			}


      // Create the structure containing the properties.   
      
      dbPropSet.rgProperties      = rgProps;
      dbPropSet.cProperties       = prop_index;
      dbPropSet.guidPropertySet   = DBPROPSET_DBINIT;

    // Get an IDBProperties pointer and set the initialization properties.

    nRetVal = mpIDBInit->QueryInterface( IID_IDBProperties, (void**)&pIDBProperties);
    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect", 
        "IDBInitialize::QI for IDBProperties") ;
      GetOLEDBError( nRetVal, "IDBInitialize::QI for IDBProperties", errorList);
      throw nRetVal ;
    }
    nRetVal = pIDBProperties->SetProperties( 1, &dbPropSet);
    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect", 
        "IDBProperties::SetProperties") ;
      GetOLEDBError( nRetVal, "IDBProperties::SetProperties", errorList);
      throw nRetVal ;
    }

    // intialize the data source with the properties that we just set

    nRetVal = mpIDBInit->Initialize();
    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect", 
        "IDBInitialize::Initialize") ;
      GetOLEDBError( nRetVal, "IDBInitialize::Initialize", errorList);
      throw nRetVal ;
    }

    // get the create session interface ....

		ASSERT(mpIDBCreateSession == 0);
    nRetVal = mpIDBInit->QueryInterface(IID_IDBCreateSession,(void**) &mpIDBCreateSession);
    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect", 
        "IDBInitialize::QI for IDBCreateSession") ;
      GetOLEDBError( nRetVal, "IDBInitialize::QI for IDBCreateSession", errorList);
      throw nRetVal ;
    }

    // Create the session 

		ASSERT(mpICreateCmd == 0);
    nRetVal = mpIDBCreateSession->CreateSession(NULL, IID_IDBCreateCommand, (IUnknown**) &mpICreateCmd);
    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect", 
        "ISession::QI for IDBCreateCommand") ;
      GetOLEDBError( nRetVal, "ISession::QI for IDBCreateCommand", errorList);
      throw nRetVal ;
    }

	}
	catch (HRESULT nResult)
	{
    nResult =0;
		bRetCode = FALSE;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Database connect failed. DBName = <%s> ServerName = <%s> User = <%s>. DSN = <%s>. Provider = <%s>",
      (char*)mDBName, (char*)mServerName, (char*)mUserName, (char*) mDataSource, (char*) mProvider) ;
    mLogger->LogThis (LOG_ERROR, "Database context not initialized") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
	}
  catch (_com_error e)
  {
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect") ;
    bRetCode = FALSE ;
    
    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, 
      "Database connect failed. Error Description = %s",
      (char*)e.Description()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Database connect failed. DBName = <%s> ServerName = <%s> User = <%s>. DSN = <%s>. Provider = <%s>",
      (char*)mDBName, (char*)mServerName, (char*)mUserName, (char*) mDataSource, (char*) mProvider) ;

    nRetVal = e.Error() ;
    GetOLEDBError( nRetVal, "Database connect failed", errorList);
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#ifndef _DEBUG
  catch (...)
  {
    nRetVal = E_FAIL;
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Connect") ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Database connect failed. DBName = <%s> ServerName = <%s> User = <%s>. DSN = <%s>. Provider = <%s>",
      (char*)mDBName, (char*)mServerName, (char*)mUserName, (char*) mDataSource, (char*) mProvider) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }
#endif

  LogErrorList (nRetVal, "OLEDBContext::Connect", errorList);

  if (pIDBProperties != NULL)
  {
    pIDBProperties->Release() ;
  }

  return bRetCode;
}

//
//	@mfunc
//	Disconnect from the database.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::Disconnect()
{
  // local variables 
  BOOL bRetCode=TRUE ;
  DWORD nError=NO_ERROR ;
  HRESULT nRetVal=S_OK ;
  ErrorList errorList ;
  
  // start the try ...
  try
  {
#ifdef MT_TRACE_CONNECTIONS
			mLogger->LogVarArgs(LOG_TRACE, "[CnxTrace] <<< closing OLEDB [%x]", this);
#endif
		
			nRetVal = FreeStoredProcParamList();
			if (FAILED(nRetVal))
					{
							SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
												"OLEDBContext::Disconnect") ;
							mLogger->LogThis (LOG_ERROR, "Unable to Free StoredProcParamList.") ;
							mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
							bRetCode = FALSE ;
					}

      // Always leave a distributed transaction since we use connection pooling and 
      // putting an OLEDB connection back into the pool while still joined to a DTC
      // transaction will cause problems if someone gets it and tries to use it with a
      // local transaction.
      if (mJoinedDistributed == TRUE)
      {
        JoinDistributedTransaction(NULL);
      }

			if (mpITransaction != NULL)
					{
							// mpITransaction should be cleaned up in the commit or rollback methods
							// if it is non-null at this point, we goofed.
      //
							mLogger->LogThis (LOG_WARNING, "OLEDBContext::Disconnect, ITransaction not cleaned. call RollbackTransaction.") ;
							RollbackTransaction();
					}


			if (mpICreateCmd != NULL)
					{
							mpICreateCmd->Release();
							mpICreateCmd = NULL;
					}
			if (mpIDBCreateSession != NULL)
					{
							mpIDBCreateSession->Release();
							mpIDBCreateSession = NULL;
					}
			if (mpIDBInit != NULL)
					{
							mpIDBInit->Release();
							mpIDBInit = NULL;
					}
  }
  catch (_com_error e)
			{
					//SetError(e) ;
					SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "OLEDBContext::Disconnect") ;
					mLogger->LogVarArgs (LOG_ERROR, "Database disconnect failed. Error Description = %s",
															(char*)e.Description()) ;
					mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
					bRetCode = FALSE ;

					nRetVal = e.Error() ;
					GetOLEDBError( nRetVal, "Database connect failed", errorList);
			}
#ifndef _DEBUG
  catch (...)
			{
					SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Disconnect") ;
					bRetCode = FALSE ;
					mLogger->LogThis (LOG_ERROR, "Database disconnect failed.") ;
					mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			}
#endif

  LogErrorList (nRetVal, "OLEDBContext::Disconnect", errorList);

  return bRetCode ;
}

//
//	@mfunc
//	Execute the SQL command.
//  @parm The SQL command to execute.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::Execute (const std::wstring &arCmd, int aTimeout)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  ICommandText *	pICommandText = NULL;
  DBSQLRowset arRowset;
  _RecordsetPtr &arRecordset = arRowset.GetRecordsetPtr() ;
  
  bRetCode = InitializeCommand (arCmd, &pICommandText);

//  if (bRetCode)
    //bRetCode = InternalExecute (arCmd, aTimeout, pICommandText, arRecordset);

  if ( pICommandText )
  {
		pICommandText->Release ();
    pICommandText = NULL;
  }

  return bRetCode ;
}

//
//	@mfunc
//	Execute the SQL command.
//  @parm The SQL command to execute.
//  @parm The recordset to fill in ...
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::Execute (const std::wstring &arCmd, DBSQLRowset &arRowset)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  ICommandText *	pICommandText = NULL;
  _RecordsetPtr &arRecordset = arRowset.GetRecordsetPtr() ;
  int aTimeout=DEFAULT_TIMEOUT_VALUE;

	// log the query string.  Only really useful on Oracle
	// Include helpful Debugging of transactions
	if(mQueryLog->IsOkToLog(LOG_DEBUG))
	{
		mQueryLog->LogThis(LOG_DEBUG, (GetTransactionContext() + arCmd).c_str());
	}

  bRetCode = InitializeCommand (arCmd, &pICommandText);

  if (bRetCode)
    bRetCode = InternalExecute (arCmd, aTimeout, pICommandText, arRecordset);


  if ( pICommandText )
  {
		pICommandText->Release ();
    pICommandText = NULL;
  }
 
  return bRetCode ;
}



//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::JoinDistributedTransaction(
	RowSetInterfacesLib::IMTTransactionPtr aTransaction)
{
	const char * functionName = "OLEDBContext::JoinDistributedTransaction";

	BOOL bOK = TRUE;
	HRESULT hr = S_OK;

	ErrorList errorList ;

	try
	{
		if (mpICreateCmd == NULL)
		{
			SetError (DB_ERR_NOT_CONNECTED, ERROR_MODULE, ERROR_LINE, "OLEDBContext::JoinDistributedTransaction",
								"Database context not connected") ;
			return FALSE;
		}
    // If we've already joined a distributed transaction, then it is OK to call with a NULL
    // argument as this means that we are leaving the transaction.  Otherwise its an error.
		if (mJoinedDistributed && aTransaction.GetInterfacePtr() != NULL)
		{
			SetError(DB_ERR_TRANSACTION_STARTED, ERROR_MODULE, ERROR_LINE, functionName,
							 "Already part of a distributed transaction");
			return FALSE;
		}

		if (mpITransaction)
		{
			SetError(DB_ERR_TRANSACTION_STARTED, ERROR_MODULE, ERROR_LINE, functionName,
							 "Already part of a local transaction");
			return FALSE;
		}

		ITransactionJoinPtr transactionJoin;
		hr =
			mpICreateCmd->QueryInterface(IID_ITransactionJoin, (void**) &transactionJoin);

		if (FAILED(hr))
		{
			SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::JoinDistributedTransaction",
								"mpICreateCmd->QueryInterface(IID_ITransactionJoin failed.");

			GetOLEDBError( hr, "mpICreateCmd->QueryInterface(IID_ITransactionJoin failed.", errorList);

			mLogger->LogThis (LOG_ERROR, "JoinDistributedTransaction failed.") ;
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			LogErrorList (hr, "OLEDBContext::JoinDistributedTransaction", errorList);

			return FALSE;
		}
	  
#if 1
		hr = transactionJoin->JoinTransaction(aTransaction.GetInterfacePtr() != NULL ? aTransaction->GetTransaction() : NULL,
																						 ISOLATIONLEVEL_UNSPECIFIED, 0, NULL);
#endif
#if 0
		hr = mpITransactionJoin->JoinTransaction(NULL, ISOLATIONLEVEL_READUNCOMMITTED, 0, NULL);
#endif
		if (FAILED(hr))
		{
			bOK = FALSE;
			SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::JoinDistributedTransaction",
								"ITransactionJoin->JoinTransaction failed.");
			GetOLEDBError( hr, "ITransactionJoin->JoinTransaction failed.", errorList);
			mLogger->LogThis (LOG_ERROR, "JoinDistributedTransaction failed.") ;
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
		}
		else
		{
			// remember we're part of a distributed transaction
			mJoinedDistributed = aTransaction.GetInterfacePtr() != NULL ? TRUE : FALSE;
			mDistributedTransaction = aTransaction; 
		}
	}
	catch (_com_error e)
  {
    //SetError (e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "OLEDBContext::JoinDistributedTransaction") ;
    bOK = FALSE ;

    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, "JoinDistributedTransaction failed. Error Description = %s",
      (char*)e.Description()) ;

    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    HRESULT hr = e.Error() ;
    GetOLEDBError( hr, "JoinDistributedTransaction failed", errorList);
  }

  LogErrorList (hr, "OLEDBContext::JoinDistributedTransaction", errorList);

  if (bOK)
    mLogger->LogThis (LOG_DEBUG, "JoinDistributedTransaction succeeded") ;

  return bOK;
}


//
//	@mfunc
//	Initialize the SQL command.
//  @parm The SQL command to execute.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::InitializeCommand (/*[in]*/ const std::wstring &arCmd, 
                                      /*[out]*/ ICommandText **  ppICommandText )
{
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  ErrorList errorList ;

  // start the try 
  try
  {
    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::InitializeCommand",
        "Database context not initialized") ;
      throw nRetVal ;
    }
  
    // Create the command object.
    nRetVal = mpICreateCmd->CreateCommand(NULL, IID_ICommandText, (IUnknown**) ppICommandText);
    if (FAILED(nRetVal))
    {
      GetOLEDBError( nRetVal, "Database execute failed. Unable to create command.", errorList);
      throw nRetVal ;
    }
	
    // The command requires the actual text as well as an indicator of its language and dialect.
    nRetVal = (*ppICommandText)->SetCommandText(DBGUID_DBSQL, arCmd.c_str());
    if (FAILED(nRetVal))
    {
      GetOLEDBError( nRetVal, "Database execute failed. Unable to set command text.", errorList);
      throw nRetVal ;
    }
#if 0
		
		ICommandProperties * pICommandProperties;
		DBPROP CmdProperties[2];
		DBPROPSET rgCmdPropSet;
		
		CmdProperties[0].dwPropertyID = DBPROP_SERVERCURSOR;
		CmdProperties[0].dwOptions = DBPROPOPTIONS_REQUIRED;
		CmdProperties[0].dwStatus = DBPROPSTATUS_OK;
		CmdProperties[0].colid = DB_NULLID;
		CmdProperties[0].vValue.vt = VT_BOOL;
		CmdProperties[0].vValue.iVal = VARIANT_FALSE;

		CmdProperties[1].dwPropertyID = DBPROP_CLIENTCURSOR;
		CmdProperties[1].dwOptions = DBPROPOPTIONS_REQUIRED;
		CmdProperties[1].dwStatus = DBPROPSTATUS_OK;
		CmdProperties[1].colid = DB_NULLID;
		CmdProperties[1].vValue.vt = VT_BOOL;
		CmdProperties[1].vValue.iVal = VARIANT_TRUE;

		rgCmdPropSet.guidPropertySet = DBPROPSET_ROWSET;
		rgCmdPropSet.cProperties = 2;
		rgCmdPropSet.rgProperties = CmdProperties;

		nRetVal = (*ppICommandText)->QueryInterface(IID_ICommandProperties, (void **) & pICommandProperties);
		if(FAILED(nRetVal))
    {
      GetOLEDBError( nRetVal, "Database execute failed. Unable to set command text.", errorList);
      throw nRetVal ;
    }
			
		nRetVal = pICommandProperties->SetProperties(1, & rgCmdPropSet);
		if(FAILED(nRetVal))
    {
      GetOLEDBError( nRetVal, "Database execute failed. Unable to set command text.", errorList);
      throw nRetVal ;
    }
			
#endif

  }
  catch (HRESULT nResult)
  {
    nResult = 0 ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database Execute() failed.") ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str()) ;
  }
  catch (_com_error e)
  {
    //SetError (e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "OLEDBContext::Execute") ;
    bRetCode = FALSE ;

    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, "Database Execute() failed. Error Description = %s",
      (char*)e.Description()) ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str()) ;

    nRetVal = e.Error() ;
    GetOLEDBError( nRetVal, "Database connect failed", errorList);
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Execute") ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database Execute() failed.") ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif

  LogErrorList (nRetVal, "OLEDBContext::Execute", errorList);

  return bRetCode ;
}
    

//
//	@mfunc
//	Execute the SQL command.
//  @parm The SQL command to execute.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::InternalExecute (/*[in]*/ const std::wstring &arCmd, 
                                    /*[in]*/ int aTimeout,
                                    /*[in]*/ ICommandText *  pICommandText,
                                    /*[in]*/ _RecordsetPtr & arRecordset)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  ErrorList errorList ;
  long cRowsAffected;
	IRowset *  pIRowset = NULL;
  _RecordsetPtr convRecordset;

  
  // start the try 
  try
  {
    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::InternalExecute",
        "Database context not initialized") ;
      throw nRetVal ;
    }
    // check to make sure the command isnt null ...
    if (arCmd.empty())
    {
      nRetVal = DB_ERR_NO_QUERY ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::InternalExecute",
        "No query specified.") ;
      throw nRetVal ;
    }

    // command is not initialized
    if (pICommandText == NULL)
    {
      nRetVal = DB_ERR_NOT_CONNECTED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::InternalExecute",
        "Database SQL command not initialized") ;
      throw nRetVal ;
    }

    // set the timeout ...
    if (aTimeout > mTimeout)
    {
      ;
    }
    
#if 0
    // log the time before the call ...
    nStart = ::GetTickCount() ;
#endif
    // Execute command with no parameters
		ICommandProperties * pICommandProperties = NULL;
		DBPROP CmdProperties[2];
		DBPROPSET rgCmdPropSet;
		
		CmdProperties[0].dwPropertyID = DBPROP_SERVERCURSOR;
		CmdProperties[0].dwOptions = DBPROPOPTIONS_REQUIRED;
		CmdProperties[0].dwStatus = DBPROPSTATUS_OK;
		CmdProperties[0].colid = DB_NULLID;
		CmdProperties[0].vValue.vt = VT_BOOL;
		CmdProperties[0].vValue.iVal = VARIANT_FALSE;

		CmdProperties[1].dwPropertyID = DBPROP_CLIENTCURSOR;
		CmdProperties[1].dwOptions = DBPROPOPTIONS_REQUIRED;
		CmdProperties[1].dwStatus = DBPROPSTATUS_OK;
		CmdProperties[1].colid = DB_NULLID;
		CmdProperties[1].vValue.vt = VT_BOOL;
		CmdProperties[1].vValue.iVal = VARIANT_TRUE;

		rgCmdPropSet.guidPropertySet = DBPROPSET_ROWSET;
		rgCmdPropSet.cProperties = 2;
		rgCmdPropSet.rgProperties = CmdProperties;

		nRetVal = pICommandText->QueryInterface(IID_ICommandProperties, (void **) & pICommandProperties);
		if(FAILED(nRetVal))
		{
			GetOLEDBError( nRetVal, "Database execute failed. Unable to set command text.", errorList);
			throw nRetVal ;
		}
			
		nRetVal = pICommandProperties->SetProperties(1, & rgCmdPropSet);
		pICommandProperties->Release();
		if(FAILED(nRetVal))
		{
			GetOLEDBError( nRetVal, "Database execute failed. Unable to set command text.", errorList);
			throw nRetVal ;
		}
			
  	// log the query string.  Only really useful on Oracle
		if(mQueryLog->IsOkToLog(LOG_DEBUG))		
		{
			mQueryLog->LogThis(LOG_DEBUG, (GetTransactionContext() + arCmd).c_str());
		}

    nRetVal = pICommandText->Execute(NULL, IID_IRowset, NULL, &cRowsAffected, (IUnknown**)&pIRowset);
    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::InternalExecute",
        "pICommandText->Execute failed") ;
      GetOLEDBError( nRetVal, "Database execute failed. Unable to execute command.", errorList);
      throw nRetVal ;
    }

    if (pIRowset)
    {
			//do this if there is no record in the Rowset, create an empty the _Recordset with property EOF is on

#if 0
			if(nRetVal == DBSTATUS_S_ISNULL)
			{
				arRecordset = convRecordset;
			}
			else
#endif
			{
				// return the results in an ADO recordset
				nRetVal = Rowset2Recordset(pIRowset,  convRecordset);
				if (FAILED(nRetVal))
				{
					SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::InternalExecute",
										"Rowset2Recordset failed") ;
					throw nRetVal ;
				}
			}
      arRecordset = convRecordset;
			pIRowset->Release();	// rowset has been copied, release this pointer
    }

#if 0
    // log the time after the call ...
    nEnd = ::GetTickCount() ;

    // calculate the difference ...
    nDiff = nEnd - nStart ;

    // log the perf time ...
    mLogger->LogVarArgs (LOG_DEBUG, "The database query took %d milliseconds", nDiff) ;
#endif
    // reset the timeout value ...
    if (aTimeout > mTimeout)
    {
      ;
    }
  }
  catch (HRESULT nResult)
  {
    nResult = 0 ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database Execute() failed.") ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  catch (_com_error e)
  {
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "OLEDBContext::InternalExecute") ;
    bRetCode = FALSE ;

    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, "Database Execute() failed. Error Description = %s",
      (char*)e.Description()) ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;

    nRetVal = e.Error() ;
    GetOLEDBError( nRetVal, "Database connect failed", errorList);
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Execute") ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database Execute() failed.") ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif

  LogErrorList (nRetVal, "OLEDBContext::InternalExecute", errorList);

  return bRetCode ;
}


//
//	@mfunc
//	Execute the SQL command with a disconnected Recordset.
//  @parm The SQL command to execute.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::ExecuteDisconnected (const std::wstring &arCmd, DBSQLRowset &arRowset,
                                        LockTypeEnum lockType)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  ErrorList errorList ;
  ICommandText *	pICommandText = NULL;
  _RecordsetPtr &arRecordset = arRowset.GetRecordsetPtr() ;

  int aTimeout= DEFAULT_TIMEOUT_VALUE;
  
  bRetCode = InitializeCommand (arCmd, &pICommandText);

#if 0
	ICommandProperties * pICommandProperties = NULL;
	DBPROP CmdProperties[2];
	DBPROPSET rgCmdPropSet;
		
	CmdProperties[0].dwPropertyID = DBPROP_SERVERCURSOR;
	CmdProperties[0].dwOptions = DBPROPOPTIONS_REQUIRED;
	CmdProperties[0].dwStatus = DBPROPSTATUS_OK;
	CmdProperties[0].colid = DB_NULLID;
	CmdProperties[0].vValue.vt = VT_BOOL;
	CmdProperties[0].vValue.iVal = VARIANT_FALSE;

	CmdProperties[1].dwPropertyID = DBPROP_CLIENTCURSOR;
	CmdProperties[1].dwOptions = DBPROPOPTIONS_REQUIRED;
	CmdProperties[1].dwStatus = DBPROPSTATUS_OK;
	CmdProperties[1].colid = DB_NULLID;
	CmdProperties[1].vValue.vt = VT_BOOL;
	CmdProperties[1].vValue.iVal = VARIANT_TRUE;

	rgCmdPropSet.guidPropertySet = DBPROPSET_ROWSET;
	rgCmdPropSet.cProperties = 2;
	rgCmdPropSet.rgProperties = CmdProperties;

	nRetVal = pICommandText->QueryInterface(IID_ICommandProperties, (void **) & pICommandProperties);
	if(FAILED(nRetVal))
	{
		GetOLEDBError( nRetVal, "Database execute failed. Unable to set command text.", errorList);
		pICommandText->Release();
		throw nRetVal ;
	}
			
	nRetVal = pICommandProperties->SetProperties(1, & rgCmdPropSet);
	if(FAILED(nRetVal))
	{
		GetOLEDBError( nRetVal, "Database execute failed. Unable to set command text.", errorList);
		pICommandProperties->Release();
    pICommandText->Release();
		throw nRetVal ;
	}
			
  if (pICommandProperties)
  {
		pICommandProperties->Release();
    pICommandProperties = NULL;
  }
#endif 

  if (bRetCode)
    bRetCode = InternalExecute (arCmd, aTimeout, pICommandText, arRecordset);

  if (pICommandText )
  {
		pICommandText->Release();
    pICommandText = NULL;
  }

  return bRetCode ;
}

//
//	@mfunc
//	Begin an ADO transaction.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
////////////////////////////////////////////////////////////////////////////


BOOL OLEDBContext::BeginTransaction()
{
		//	ASSERT(0);	
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  ErrorList errorList ;
  unsigned long ulLevel ;
  ITransactionLocal *pITransactionLocal=NULL ;
 
  // start the try 
  try
  {
    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::BeginTransaction", "Database context not initialized") ;
      throw nRetVal ;
    }
    // if we already are in a transaction ... return error 
    if (mpITransaction != NULL || mJoinedDistributed)
    {
      nRetVal = DB_ERR_TRANSACTION_STARTED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::BeginTransaction", "A transaction has already been started.") ;
      throw nRetVal ;
    }
    // get the ITransactionLocal interface ...
    nRetVal = mpICreateCmd->QueryInterface(IID_ITransactionLocal,(void**) &pITransactionLocal);
    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::BeginTransaction", "Unable to get ITransactionLocal interface.") ;
      GetOLEDBError (nRetVal, 
        "Database begin transaction failed. Unable to get ITransactionLocal interface.", errorList);
      throw nRetVal ;
    }
    
    // begin the transaction ...
    nRetVal = pITransactionLocal->StartTransaction(ISOLATIONLEVEL_READCOMMITTED, 0, NULL, &ulLevel) ;
    pITransactionLocal->Release();
    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::BeginTransaction", "Unable to start transaction.") ;
      GetOLEDBError (nRetVal, 
        "Database begin transaction failed. Unable to start transaction.", errorList);
      throw nRetVal ;
    }
    
    // get the ITransaction interface ...
    nRetVal = mpICreateCmd->QueryInterface(IID_ITransaction,(void**) &mpITransaction);
    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::BeginTransaction", "Unable to get ITransaction interface.") ;
      GetOLEDBError (nRetVal, 
        "Database begin transaction failed. Unable to get ITransaction interface.", errorList);
      throw nRetVal ;
    }

    mLogger->LogThis (LOG_DEBUG, "OLEDBContext::BeginTransaction, ITransaction created.") ;
  }
  catch (HRESULT nResult)
  {
    nResult = 0 ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database BeginTransaction() failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  catch (_com_error e)
  {
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "OLEDBContext::BeginTransaction") ;
    bRetCode = FALSE ;
    
    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, "Database BeginTransaction() failed. Error Description = %s",
      (char*)e.Description()) ;

    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;

    nRetVal = e.Error() ;
    GetOLEDBError( nRetVal, "Database connect failed", errorList);
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "OLEDBContext::BeginTransaction") ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database BeginTransaction() failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif

  LogErrorList (nRetVal, "OLEDBContext::Connect", errorList);

  if (bRetCode)
    mLogger->LogThis (LOG_DEBUG, "local BeginTransaction succeeded") ;

  return bRetCode ;
}

//
//	@mfunc
//	Commit an ADO transaction.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::CommitTransaction()
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  ErrorList errorList ;


  // start the try 
  try
  {
		if (mJoinedDistributed)
		{
      SetError (DB_ERR_NO_TRANSACTION, ERROR_MODULE, ERROR_LINE,
								"OLEDBContext::CommitTransaction",
								"Part of a distributed (not local) transaction");
			return FALSE;
		}

    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::CommitTransaction", "Database context not initialized") ;
      throw nRetVal ;
    }
    // if we are not in a transaction ... return error 
    if (mpITransaction == NULL)
    {
      nRetVal = DB_ERR_NO_TRANSACTION ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::CommitTransaction", "A transaction has not been started.") ;
      throw nRetVal ;
    }

    // commit the transaction ...

		// in a local transaction
		nRetVal = mpITransaction->Commit(FALSE, XACTTC_SYNC, 0) ;
		mLogger->LogThis (LOG_DEBUG, "OLEDBContext::CommitTransaction, commit local transaction.") ;

    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::CommitTransaction", "Unable to commit transaction.") ;
      GetOLEDBError (nRetVal, 
        "Database commit transaction failed. Unable to commit transaction.", errorList);
      throw nRetVal ;
    }
  }
  catch (HRESULT nResult)
  {
    nResult = 0 ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database CommitTransaction() failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  catch (_com_error e)
  {
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "OLEDBContext::CommitTransaction") ;
    bRetCode = FALSE ;

    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, "Database CommitTransaction() failed. Error Description = %s",
      (char*)e.Description()) ;

    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;

    nRetVal = e.Error() ;
    GetOLEDBError( nRetVal, "Database connect failed", errorList);
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "OLEDBContext::CommitTransaction") ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database CommitTransaction() failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif

  LogErrorList (nRetVal, "OLEDBContext::Connect", errorList);

  // release the transaction so we can create another one if we want
  if( NULL != mpITransaction )
  {
    mpITransaction->Release();
    mpITransaction = NULL;
    mLogger->LogThis (LOG_DEBUG, "OLEDBContext::CommitTransaction, release transaction.") ;
  }


  if (bRetCode)
    mLogger->LogThis (LOG_DEBUG, "CommitTransaction succeeded") ;

  return bRetCode ;
}

//
//	@mfunc
//	Rollback a transaction.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::RollbackTransaction()
{
	const char * functionName = "OLEDBContext::RollbackTransaction";

  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  ErrorList errorList ;

  // start the try 
  try
  {
    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::RollbackTransaction", "Database context not initialized") ;
      throw nRetVal ;
    }

		if (mJoinedDistributed)
		{
			SetError(DB_ERR_NO_TRANSACTION, ERROR_MODULE, ERROR_LINE, functionName,
							 "Part of a distributed (not local) transaction");
			return FALSE;
		}

    // if we are not in a transaction ... return error 
    if (mpITransaction == NULL)
    {
      nRetVal = DB_ERR_NO_TRANSACTION ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::RollbackTransaction", "A transaction has not been started.") ;
      throw nRetVal ;
    }
    // commit the transaction ...
    nRetVal = mpITransaction->Abort(NULL, FALSE, FALSE) ;
    mLogger->LogThis (LOG_DEBUG, "OLEDBContext::RollbackTransaction, abort transaction.") ;
    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::RollbackTransaction", "Unable to abort transaction.") ;
      GetOLEDBError (nRetVal, 
        "Database rollback transaction failed. Unable to abort transaction.", errorList);
      throw nRetVal ;
    }
  }
  catch (HRESULT nResult)
  {
    nResult = 0 ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database RollbackTransaction() failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  catch (_com_error e)
  {
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "OLEDBContext::RollbackTransaction") ;
    bRetCode = FALSE ;

    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, "Database RollbackTransaction() failed. Error Description = %s",
      (char*)e.Description()) ;

    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;

    nRetVal = e.Error() ;
    GetOLEDBError( nRetVal, "Database connect failed", errorList);
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "OLEDBContext::RollbackTransaction") ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database RollbackTransaction() failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif

  LogErrorList (nRetVal, "OLEDBContext::RollbackTransaction", errorList);

  // release the transaction so we can create another one if we want
  if( NULL != mpITransaction )
  {
    mpITransaction->Release();
    mpITransaction = NULL;
    mLogger->LogThis (LOG_DEBUG, "OLEDBContext::RollbackTransaction, release transaction.") ;
  }

  if (bRetCode)
    mLogger->LogThis (LOG_DEBUG, "RollbackTransaction succeeded") ;

  return bRetCode ;
}


//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::InitializeForStoredProc (const std::wstring &arStoredProcName)
{
  // local variables
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  ErrorList errorList ;

  try
  {
    // copy the stored proc name ...

//    if (mStoredProcName.length() > 0)
//    {
//      mLogger->LogThis (LOG_DEBUG, "OLEDBContext::InitializeForStoredProc: Overwriting previous stored proc name.") ;
//    }

    mStoredProcName = arStoredProcName;

    // free any parameter info from previous stored procedure calls

    nRetVal = FreeStoredProcParamList();
    if (FAILED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::InitializeForStoredProc") ;
      mLogger->LogThis (LOG_ERROR, "Unable to Free StoredProcParamList.") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      bRetCode = FALSE ;
    }
  }
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::InitializeForStoredProc") ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Unable to create command for stored procedure %s. Error Description = %s",
      mStoredProcName.c_str(), (char*)e.Description()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;

    GetOLEDBError( nRetVal, "Database connect failed", errorList);
  }

  LogErrorList (nRetVal, "OLEDBContext::InitializeForStoredProc", errorList);
  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::AddParameterToStoredProc (const std::wstring &arParamName, 
    const MTParameterType &arType, const MTParameterDirection &arDirection)
{
  // if the parameter direction is input or input/output then this cannot be used...
  if ((arDirection == INPUT_PARAM) || (arDirection == IN_OUT_PARAM))
  {
    HRESULT nRetVal = ERROR_INVALID_FUNCTION ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
      "OLEDBContext::AddParameterToStoredProc") ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Unable to add input parameter to stored procedure %s with input value. Direction = %x.", 
      mStoredProcName.c_str(), arDirection) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

  // call add parameter to stored procedure ...
  _variant_t vtValue ;
  BOOL bRetCode ;
  bRetCode = AddParameterToStoredProc (arParamName, arType, arDirection, vtValue) ;

  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::AddParameterToStoredProc (const std::wstring &arParamName, 
    const MTParameterType &arType, const MTParameterDirection &arDirection, 
    const _variant_t &arValue)
{
  // local variables
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  ErrorList errorList ;
  CParameterToStoredProc *pNewParam;

  // if we're not initialized for a stored procedure ...

  if (mStoredProcName.length() == 0)
  {
    nRetVal = DB_ERR_NOT_INITIALIZED ;
    bRetCode = FALSE ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
      "OLEDBContext::AddParameterToStoredProc") ;
    mLogger->LogThis (LOG_ERROR, "Unable to add paramter for stored procedure. Not initialized.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  else
  {
    try
    {
      // save parameter info until we execure the stored procedure

      pNewParam = new CParameterToStoredProc(arParamName, arType, arDirection, arValue, mDBType);
      m_StoredProcParamList.push_back(pNewParam);
    }
    catch (_com_error e)
    {
      nRetVal = e.Error() ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::AddParameterToStoredProc") ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to add parameter for stored procedure %s. Error Description = %s",
        mStoredProcName.c_str(), (char*)e.Description()) ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      bRetCode = FALSE ;

      nRetVal = e.Error() ;
      GetOLEDBError( nRetVal, "Database connect failed", errorList);
    }
    catch (HRESULT nStatus)
    {
      nRetVal = nStatus ;
      bRetCode = FALSE ;
    }
  }

  LogErrorList (nRetVal, "OLEDBContext::InitializeForStoredProc", errorList);

  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////
BOOL OLEDBContext::ExecuteStoredProc()
{
	DBSQLRowset rs;
	return ExecuteStoredProc(rs);
}

BOOL OLEDBContext::ExecuteStoredProc(DBSQLRowset &arRowset)
{
  // local variables ...
	_RecordsetPtr &arRecordset = arRowset.GetRecordsetPtr();
	IRowset*  pIRowset = NULL;

  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  ErrorList errorList ;
  // local variables ...
  ICommandText *	pICommandText=NULL;
  ICommandWithParameters *pCmdParam=NULL ;
  IAccessor *pAccessor=NULL ;
 	long cRowsAffected;
  std::wstring StoredProcCommand;  // must build command string, i.e. L"exec MySprocOut ?, ? OUTPUT"
  long ParameterCount;
  DBPARAMBINDINFO * pParamInfo = NULL;
  unsigned long *pOrdinals = NULL;
  STORED_PROC_PARAM_LIST::iterator iter;
  DBBINDING * pDBBinding = NULL;
  DBBINDSTATUS * pDBBindStatus = NULL;
  HACCESSOR paramAccessor;
  unsigned long ParamMemSize = 0;
  unsigned char *pBuffer = NULL;
  DBPARAMS dbParams;
  
  // if we're not initialized for a stored procedure ...

  if (mStoredProcName.length() == 0)
  {
    nRetVal = DB_ERR_NOT_INITIALIZED ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
      "OLEDBContext::ExecuteStoredProc") ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Unable to execute stored procedure. Not initialized.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }
  else
  {
    try
    {
      // get the command interface

      nRetVal = mpICreateCmd->CreateCommand(NULL, IID_ICommandText,(IUnknown**) &pICommandText);

      if (FAILED(nRetVal))
      {
        SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
          "OLEDBContext::ExecuteStoredProc", "Unable to create command.") ;
        GetOLEDBError (nRetVal, 
          "Execute Stored Procedure failed. Unable to abort transaction.", errorList);
        throw nRetVal ;
			}

			// set client cursor props
			ICommandProperties * pICommandProperties = NULL;
			DBPROP CmdProperties[2];
			DBPROPSET rgCmdPropSet;

			CmdProperties[0].dwPropertyID = DBPROP_SERVERCURSOR;
			CmdProperties[0].dwOptions = DBPROPOPTIONS_REQUIRED;
			CmdProperties[0].dwStatus = DBPROPSTATUS_OK;
			CmdProperties[0].colid = DB_NULLID;
			CmdProperties[0].vValue.vt = VT_BOOL;
			CmdProperties[0].vValue.iVal = VARIANT_FALSE;

			CmdProperties[1].dwPropertyID = DBPROP_CLIENTCURSOR;
			CmdProperties[1].dwOptions = DBPROPOPTIONS_REQUIRED;
			CmdProperties[1].dwStatus = DBPROPSTATUS_OK;
			CmdProperties[1].colid = DB_NULLID;
			CmdProperties[1].vValue.vt = VT_BOOL;
			CmdProperties[1].vValue.iVal = VARIANT_TRUE;

			rgCmdPropSet.guidPropertySet = DBPROPSET_ROWSET;
			rgCmdPropSet.cProperties = 2;
			rgCmdPropSet.rgProperties = CmdProperties;

			nRetVal = pICommandText->QueryInterface(IID_ICommandProperties, (void **) & pICommandProperties);
			if(FAILED(nRetVal))
			{
				GetOLEDBError( nRetVal, "Database execute failed. Unable to get command properties.", errorList);
				pICommandText->Release();
				throw nRetVal ;
			}

			nRetVal = pICommandProperties->SetProperties(1, &rgCmdPropSet);
			if(FAILED(nRetVal))
			{
				GetOLEDBError( nRetVal, "Database execute failed. Unable to set command properties.", errorList);
				pICommandProperties->Release();
        pICommandText->Release();
				throw nRetVal ;
			}

			// If this is an Oracle stored procedure, get the IID_ICommandProperties 
			// interface so we can tell the driver to expect one or more refcursors.
			if (mDBType == (_bstr_t) ORACLE_DATABASE_TYPE)
			{
				DBPROP oraCmdProperties[1];
				DBPROPSET oraCmdPropSet;

				// these two are from OraOLEDB.h.  should've included the 3d party header.
				const GUID ORAPROPSET_COMMANDS = 
				{0x8B92E3F1,0x4C70,0x11D4,{0x91,0x1B,0x00,0xC0,0x4F,0x4C,0x7E,0x26}};
				const int ORAPROP_PLSQLRSet = 1;

				oraCmdProperties[0].dwPropertyID = ORAPROP_PLSQLRSet;
				oraCmdProperties[0].dwOptions = DBPROPOPTIONS_REQUIRED;
				oraCmdProperties[0].dwStatus = DBPROPSTATUS_OK;
				oraCmdProperties[0].colid = DB_NULLID;
				oraCmdProperties[0].vValue.vt = VT_BOOL;
				oraCmdProperties[0].vValue.iVal = VARIANT_TRUE;

				oraCmdPropSet.guidPropertySet = ORAPROPSET_COMMANDS;
				oraCmdPropSet.cProperties = 1;
				oraCmdPropSet.rgProperties = oraCmdProperties;

				nRetVal = pICommandProperties->SetProperties(1, &oraCmdPropSet);
				if(FAILED(nRetVal))
				{
					GetOLEDBError( nRetVal, "Database execute failed. Unable to set command properties.", errorList);
					pICommandProperties->Release();
					throw nRetVal ;
				}
			}

			//Release the interface pointer
			pICommandProperties->Release();

			// get the command with parameters interface
      nRetVal = pICommandText->QueryInterface (IID_ICommandWithParameters, (void**)&pCmdParam);

      if (FAILED(nRetVal))
      {
        SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
          "OLEDBContext::ExecuteStoredProc", "Unable to QueryInterface ICommandWithParameters.") ;
        GetOLEDBError (nRetVal, 
          "Execute Stored Procedure failed. Unable to  QueryInterface ICommandWithParameters.", errorList);
        throw nRetVal ;
      }

      // initialize the start of the command string
#ifdef NAME_BINDING      
      if (mDBType == (_bstr_t) ORACLE_DATABASE_TYPE)
      {
        StoredProcCommand = L"\nbegin\n";
        StoredProcCommand += mStoredProcName;
        StoredProcCommand += L" (";
      }
      else
      {
        StoredProcCommand = L"rpc ";
        StoredProcCommand += mStoredProcName;
      }
#else
      if (mDBType == (_bstr_t) ORACLE_DATABASE_TYPE)
      {
        StoredProcCommand = L"call ";
        StoredProcCommand += mStoredProcName;
        StoredProcCommand += L" (";
      }
      else
      {
        StoredProcCommand = L"exec ";
        StoredProcCommand += mStoredProcName;
      }
#endif
			if(mQueryLog->IsOkToLog(LOG_DEBUG))
			{
				mQueryLog->LogThis(LOG_DEBUG, (GetTransactionContext() + mStoredProcName).c_str());
			}

      // initialize the parameter info ...
#ifdef NAME_BINDING 
      //push one more parameter - reserved ReturnValue for PRC command
      if (mDBType != (_bstr_t) ORACLE_DATABASE_TYPE)
      {
        _variant_t vtNull;
        vtNull = 0L;
        std::vector<CParameterToStoredProc*>::iterator it = m_StoredProcParamList.begin();
        m_StoredProcParamList.insert
          (it, new CParameterToStoredProc(std::wstring(L"ReturnVal"), MTTYPE_INTEGER, OUTPUT_PARAM, vtNull, mDBType));
      }
#endif
      ParameterCount = m_StoredProcParamList.size();

      pParamInfo = new DBPARAMBINDINFO[ ParameterCount];
      pOrdinals = new unsigned long[ ParameterCount ];

      memset (pParamInfo, 0, sizeof (DBPARAMBINDINFO)*(ParameterCount));

      // initialize the binding info

      pDBBinding = new DBBINDING[ ParameterCount];
      pDBBindStatus = new DBBINDSTATUS[ ParameterCount];

      memset (pDBBinding, 0, sizeof (DBBINDING)*(ParameterCount));

      // set the parameter info

      DBPARAMBINDINFO * pParamInfoIndex = pParamInfo;
      unsigned long *pOrdinalIndex = pOrdinals;
      DBBINDING * pDBBindingIndex = pDBBinding;
      unsigned long ordinal = 1;
      BOOL bOK = TRUE;

	    for (iter = m_StoredProcParamList.begin(); bOK == TRUE && iter != m_StoredProcParamList.end(); iter++)
	    {
		    CParameterToStoredProc* param = (*iter);
        bOK = param->InitParamInfo( pParamInfoIndex );

        *pOrdinalIndex = ordinal;
        ++pParamInfoIndex;
        ++pOrdinalIndex;

        if (bOK)
#ifdef NAME_BINDING 
          if (mDBType == (_bstr_t) ORACLE_DATABASE_TYPE)
			  bOK = param->AppendParamToCommand( StoredProcCommand , ordinal, (std::wstring)((wchar_t*)mDBType));
#else
          bOK = param->AppendParamToCommand( StoredProcCommand , ordinal, (std::wstring)((wchar_t*)mDBType));
#endif
        if (bOK)
		      bOK = param->InitBindingInfo( pDBBindingIndex , ordinal, &ParamMemSize);
        ++pDBBindingIndex;

        ++ordinal;
        ////
       	if (mQueryLog->IsOkToLog(LOG_DEBUG))
        {
          MTParameterType type = param->GetType();
          
          long size = param->GetSize();
          
          _bstr_t name = param->GetName();
          _variant_t value = param->GetValue();
          _bstr_t bstrValue = "NULL";
          
          if(V_VT(&value) != VT_NULL)
            bstrValue = (_bstr_t)value;
          
          MTParameterDirection direction = param->GetDirection();
          
          const char * directionString;
          switch (direction)
          {
          case INPUT_PARAM:
            directionString = "input"; break;
          case OUTPUT_PARAM:
            directionString = "output"; break;
          case IN_OUT_PARAM:
            directionString = "input/output"; break;
          case RETVAL_PARAM:
            directionString = "return"; break;
          default:
            directionString = "unknown"; break;
          }
          
          mQueryLog->LogVarArgs(LOG_DEBUG,
            " %s param: %s, type=%d, size=%d",
            directionString,
            (const char *) name, (int) type, size);
          if (direction == INPUT_PARAM || direction == OUTPUT_PARAM)
          {
            mQueryLog->LogVarArgs(LOG_DEBUG,
              "  value: <%s>", (const char *)bstrValue);
          }
        }
        /////
	    }


      // allocate the buffer to hold the data ...

      pBuffer = new unsigned char[ParamMemSize] ;
      if (pBuffer == NULL)
      {
        nRetVal = E_FAIL;
        SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
          "OLEDBContext::ExecuteStoredProc", "Unable to allocate memory.") ;
        throw nRetVal ;
      }
      memset(pBuffer, 0, ParamMemSize) ;


      // fill in data values

      unsigned char * pBufferPointer = pBuffer;
	    for (iter = m_StoredProcParamList.begin(); iter != m_StoredProcParamList.end(); iter++)
	    {
		    (*iter)->InitData( &pBufferPointer, DBSTATUS_S_OK);
	    }

#ifdef NAME_BINDING
      // set the command string
      if (mDBType == (_bstr_t) ORACLE_DATABASE_TYPE)
        StoredProcCommand += L");\n end;";
      else
      {
        StoredProcCommand.insert(0, L"{") ;
        StoredProcCommand += L"}";
      }
#else
      if (mDBType == (_bstr_t) ORACLE_DATABASE_TYPE)
      {
        StoredProcCommand.insert(0, L"{ ") ;
        StoredProcCommand += L" ) }";
      }
#endif

			nRetVal = pICommandText->SetCommandText(DBGUID_DBSQL, StoredProcCommand.c_str());

      if (FAILED(nRetVal))
      {
        SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
          "OLEDBContext::ExecuteStoredProc", "Unable to set command text.") ;
        GetOLEDBError (nRetVal, 
          "Execute Stored Procedure failed. Unable to set command text.", errorList);
        throw nRetVal ;
      }

      if ( ParameterCount > 0 )
      {
        // set the command param info

        nRetVal = pCmdParam->SetParameterInfo (ParameterCount, pOrdinals, pParamInfo);

        if (FAILED(nRetVal))
        {
          char buf[1024];
          _snprintf(buf, 1024, "Unable to SetParameterInfo for %s", StoredProcCommand);
          SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "OLEDBContext::ExecuteStoredProc", buf);
          GetOLEDBError (nRetVal, "Execute Stored Procedure failed. Unable to SetParameterInfo.", errorList);
          throw nRetVal ;
        }

        // get the IAccessor interface ...

        nRetVal = pICommandText->QueryInterface (IID_IAccessor, (void**)&pAccessor);

        if (FAILED(nRetVal))
        {
          SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
            "OLEDBContext::ExecuteStoredProc", "Unable to QueryInterface IAccessor.") ;
          GetOLEDBError (nRetVal, 
            "Execute Stored Procedure failed. Unable to QueryInterface IAccessor.", errorList);
          throw nRetVal ;
        }

        // create the accessor ...

        nRetVal = pAccessor->CreateAccessor (DBACCESSOR_PARAMETERDATA, ParameterCount, pDBBinding, ParamMemSize, 
          &paramAccessor, pDBBindStatus);

        if (FAILED(nRetVal))
        {
          SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
            "OLEDBContext::ExecuteStoredProc", "Unable to Create IAccessor .") ;
          GetOLEDBError (nRetVal, 
            "Execute Stored Procedure failed. Unable to Create IAccessor.", errorList);
          throw nRetVal ;
        }

        // set up the DBPARAMS structure ...

        dbParams.pData = pBuffer ;
        dbParams.cParamSets = 1;
        dbParams.hAccessor = paramAccessor;

        if(mQueryLog->IsOkToLog(LOG_DEBUG))
				{
					mQueryLog->LogThis(LOG_DEBUG, (GetTransactionContext() + StoredProcCommand).c_str());
				}

#if 0
    // log the time before the call ...
    __int64 nStart = ::GetTickCount() ;
#endif
		
		// execute the stored proc.  provide a pointer for a possible rowset result
    nRetVal = pICommandText->Execute(NULL, IID_IRowset, &dbParams, &cRowsAffected, (IUnknown**)&pIRowset);

#if 0
    // log the time after the call ...
    __int64 nEnd = ::GetTickCount() ;

    // calculate the difference ...
    __int64 nDiff = nEnd - nStart ;

    // log the perf time ...
    mLogger->LogVarArgs (LOG_DEBUG, "The stored procedure took %d milliseconds to execute", (long)nDiff) ;
#endif

      }
      else // ( ParameterCount == 0 )
      {
        nRetVal = pICommandText->Execute(NULL, IID_NULL, NULL, &cRowsAffected, (IUnknown**)NULL);
      }

      if (FAILED(nRetVal))
      {
        SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
          "OLEDBContext::ExecuteStoredProc", "Unable to Execute stored procedure.") ;
        GetOLEDBError (nRetVal, 
          "Execute Stored Procedure failed. Unable to Execute stored procedure.", errorList);
        mLogger->LogVarArgs (LOG_ERROR, 
          L"Unable to execute stored procedure. Command = %s", StoredProcCommand.c_str());
        throw nRetVal ;
      }

      // get return data values
      pBufferPointer = pBuffer;
			for (iter = m_StoredProcParamList.begin(); iter != m_StoredProcParamList.end(); iter++)
			{
				(*iter)->UpdateData(&pBufferPointer, mDBType);
			}

			// if there a rowset result, return it in an ADO recordset
			if (pIRowset != NULL)
			{
				_RecordsetPtr convRecordset;

				HRESULT hrR2R = Rowset2Recordset(pIRowset, convRecordset);
				if (FAILED(hrR2R))
				{
					SetError (hrR2R, ERROR_MODULE, ERROR_LINE, "OLEDBContext::ExecuteStoredProc",
						"Rowset2Recordset failed") ;
					throw hrR2R ;
				}
				arRecordset = convRecordset;

				// Release rowset interface pointer
				pIRowset->Release();
			}

      if (mQueryLog->IsOkToLog(LOG_DEBUG))
      {
        //log parameters after procedure execution
        mQueryLog->LogVarArgs(LOG_DEBUG,
          "Logging output parameters after %s stored procedure executed", mStoredProcName.c_str());
        for (iter = m_StoredProcParamList.begin(); bOK == TRUE && iter != m_StoredProcParamList.end(); iter++)
        {
          CParameterToStoredProc* param = (*iter);
          
          MTParameterType type = param->GetType();
          
          long size = param->GetSize();
          
          _bstr_t name = param->GetName();
          _variant_t value = param->GetValue();
          _bstr_t bstrValue = "NULL";
          
          if(V_VT(&value) != VT_NULL)
            bstrValue = (_bstr_t)value;
          
          MTParameterDirection direction = param->GetDirection();
          
          const char * directionString;
          switch (direction)
          {
          case INPUT_PARAM:
            //don't log input parameters
            directionString = "input"; continue;
          case OUTPUT_PARAM:
            directionString = "output"; break;
          case IN_OUT_PARAM:
            directionString = "input/output"; break;
          case RETVAL_PARAM:
            directionString = "return"; break;
          default:
            directionString = "unknown"; break;
          }
          
          mQueryLog->LogVarArgs(LOG_DEBUG,
            " %s param: %s, type=%d, size=%d",
            directionString,
            (const char *) name, (int) type, size);
          if (direction == INPUT_PARAM || direction == OUTPUT_PARAM)
          {
            mQueryLog->LogVarArgs(LOG_DEBUG,
              "  value: <%s>", (const char *)bstrValue);
          }
        }
        /////
      }
    }
    catch (HRESULT nResult)
    {
      nResult = 0 ;
      bRetCode = FALSE ;
      mLogger->LogVarArgs (LOG_ERROR, L"Database ExecuteStoredProc() failed. Name = %s", mStoredProcName.c_str()) ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    catch (_com_error e)
    {
      nRetVal = e.Error() ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::ExecuteStoredProc") ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to execute stored procedure %s. Error Description = %s",
        mStoredProcName.c_str(), (char*)e.Description()) ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      bRetCode = FALSE ;

      nRetVal = e.Error() ;
      GetOLEDBError( nRetVal, "Database ExecuteStoredProc failed", errorList);
    }
  }

  LogErrorList (nRetVal, "OLEDBContext::ExecuteStoredProc", errorList);

  // release the objects ...
  if (pAccessor != NULL)
  {
    pAccessor->Release() ;
  }
  if (pCmdParam != NULL)
  {
    pCmdParam->Release() ;
  }
  if (pICommandText != NULL)
  {
    pICommandText->Release() ;
  }
  if (pParamInfo != NULL)
  {
    delete[] pParamInfo;
  }
  if (pOrdinals != NULL)
  {
    delete[] pOrdinals;
  }
  if (pDBBinding != NULL)
  {
    delete[] pDBBinding;
  }
  if (pDBBindStatus != NULL)
  {
    delete[] pDBBindStatus;
  }
  if (pBuffer != NULL)
  {
    delete[] pBuffer;
  }

  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////

BOOL OLEDBContext::GetParameterFromStoredProc (const std::wstring &arParamName, 
                                               _variant_t &arValue)
{
  // local variables
  BOOL bRetCode=TRUE ;
  _variant_t vtIndex ;
  HRESULT nRetVal=S_OK ;
  ErrorList errorList ;

  // if we're not initialized for a stored procedure ...
  if (mStoredProcName.length() == 0)
  {
    nRetVal = DB_ERR_NOT_INITIALIZED ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
      "OLEDBContext::GetParameterFromStoredProc") ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Unable to get parameter from stored procedure. No results available.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }
  else
  {
    try
    {
      STORED_PROC_PARAM_LIST::iterator iter;
      BOOL bFound = FALSE;
      _bstr_t name = arParamName.c_str();
	    for (iter = m_StoredProcParamList.begin(); !bFound && iter != m_StoredProcParamList.end(); iter++)
	    {
		    bFound = (*iter)->GetParamByName(name, arValue, mDBType);
	    }
    }
    catch (_com_error e)
    {
      nRetVal = e.Error() ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "OLEDBContext::GetParameterFromStoredProc") ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to get parameter from stored procedure %s. Error Description = %s",
        mStoredProcName.c_str(), (char*)e.Description()) ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      bRetCode = FALSE ;
      
      nRetVal = e.Error() ;
      GetOLEDBError( nRetVal, "Database GetParameterFromStoredProc", errorList);
    }
  }

  LogErrorList (nRetVal, "OLEDBContext::GetParameterFromStoredProc", errorList);

  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////

void OLEDBContext::LogErrorList (HRESULT aError, const char *pString, ErrorList &arErrorList)
{
  if (FAILED(aError))
  {
    std::wstring wstr;
    ErrorListIter iter ;

	  for (iter = arErrorList.begin(); iter != arErrorList.end(); iter++)
	  {
      wstr = (*iter);
#ifdef _DEBUG
      _tprintf(_T("%s\n"), wstr.c_str());
#endif
      // log the message ...
      mLogger->LogThis (LOG_ERROR, wstr.c_str()) ;
		}
  }
}

//
//	@mfunc
//	
//  @rdesc 
//  
//typedef RWTValSlist<RWWString> ErrorList;
//
////////////////////////////////////////////////////////////////////////////

void GetOLEDBError (HRESULT aError, const char *pString, ErrorList &arErrorList)
{
  // get the error info ...
  IErrorInfo *pError = NULL ;
  IErrorInfo *pErrorInfo = NULL ;
  IErrorRecords *pErrorRecords=NULL ;
  ISQLErrorInfo *pSQLErrorInfo=NULL ;
  ERRORINFO ErrorInfo ;
  BSTR bstrDesc=NULL ;
  BSTR bstrSource=NULL ;
  BSTR bstrSQLInfo=NULL ;
  unsigned long nNumRecds=0;
  HRESULT nRetVal=S_OK;
  wchar_t formaterror[1024];
  std::wstring errorstring;

  wsprintf (formaterror, L"\nERROR occurred. Hresult: %0x08x \n",
    aError) ;
  errorstring = formaterror;
  arErrorList.push_front(errorstring);

  // get the error info ...
  static LCID lcid = GetUserDefaultLCID();
  nRetVal = GetErrorInfo (0, &pError) ;
  if (FAILED(nRetVal) || NULL == pError)
  {
    wsprintf (formaterror, L"\nERROR: unable to get extended error information. Hresult: %0x08x \n",
      aError) ;
    errorstring = formaterror;
    arErrorList.push_front(errorstring);
    return ;
  }
  // get the extended error information ...
  nRetVal = pError->QueryInterface( IID_IErrorRecords, (void**)&pErrorRecords);
  if (FAILED(nRetVal))
  {
    // single error ... get the description ...
    nRetVal = pError->GetDescription (&bstrDesc) ;
    if (FAILED(nRetVal))
    {
      cout << "ERROR: unable to get error description for error. Error = " <<
        hex << nRetVal << dec << endl ;
    }
    else
    {
      wsprintf (formaterror, L"\nERROR occurred. Hresult: %0x08x  Description: %s\n",
        aError, bstrDesc) ;
      errorstring = formaterror;
      arErrorList.push_front(errorstring);

      // get the source ...
      nRetVal = pError->GetSource(&bstrSource) ;
      if (FAILED(nRetVal))
      {
        cout << "ERROR: unable to get error source for error. Error = " <<
          hex << nRetVal << dec << endl ;
      }
      else
      {
        // output the info ...
        wsprintf (formaterror, L"\nErrorRecord: Hresult: %0x08x Source %s\n",
          aError, bstrSource) ;
        errorstring = formaterror;
        arErrorList.push_front(errorstring);
      }
    }
    if (pError)
    {
      pError->Release() ;
    }
    if (bstrDesc)
    {
      ::SysFreeString (bstrDesc) ;
    }
    if (bstrSource)
    {
      ::SysFreeString (bstrSource) ;
    }
  }
  else
  {
    // get the number of error records ...
    nRetVal = pErrorRecords->GetRecordCount(&nNumRecds) ;
    if (FAILED(nRetVal))
    {
      cout << "ERROR: unable to get number of error records. Error = " <<
        hex << nRetVal << dec << endl ;
      return ;
    }

    // output the info ...
    wsprintf (formaterror, L"\nErrorRecord: Hresult: %0x08x RecordCount=  %d \n",
      aError, nNumRecds) ;
    errorstring = formaterror;
    arErrorList.push_front(errorstring);
    
    // for all the errors ...
    for (unsigned long i=0; i<nNumRecds;i++)
    {
      // get the error info ...
      nRetVal = pErrorRecords->GetErrorInfo (i, lcid, &pErrorInfo) ;
      if (FAILED(nRetVal))
      {
        cout << "ERROR: unable to get error info from record #" << i << ". Error = " <<
          hex << nRetVal << dec << endl ;
        continue ;
      }
      // get the description ...
      nRetVal = pErrorInfo->GetDescription (&bstrDesc) ;
      if (FAILED(nRetVal))
      {
        cout << "ERROR: unable to get error description for record #" << i << ". Error = " <<
          hex << nRetVal << dec << endl ;
        continue ;
      }

      // output the info ...
      wsprintf (formaterror, L"\nErrorRecord: Hresult: %0x08x RecordNumber =  %d Description = %s\n",
        aError, nNumRecds, bstrDesc) ;
      errorstring = formaterror;
      arErrorList.push_front(errorstring);

      // get the source ...
      nRetVal = pErrorInfo->GetSource(&bstrSource) ;
      if (FAILED(nRetVal))
      {
        cout << "ERROR: unable to get error source for record #" << i << ". Error = " <<
          hex << nRetVal << dec << endl ;
        continue ;
      }

      // output the info ...
      wsprintf (formaterror, L"\nErrorRecord: Hresult: %0x08x RecordNumber =  %d Source = %s\n",
        aError, nNumRecds, bstrSource) ;
      errorstring = formaterror;
      arErrorList.push_front(errorstring);

      // get the ErrorInfo ...
      nRetVal = pErrorRecords->GetBasicErrorInfo (i, &ErrorInfo) ;
      if (FAILED(nRetVal))
      {
        cout << "ERROR: unable to get basic error info for record #" << i << ". Error = " <<
          hex << nRetVal << dec << endl ;
        continue ;
      }

      // output the info ...
      wsprintf (formaterror, L"\nErrorRecord: Hresult: %0x08x RecordNumber =  %d  BasicErrorInfo = %0x08x \n",
        aError, nNumRecds, ErrorInfo.hrError) ;
      errorstring = formaterror;
      arErrorList.push_front(errorstring);

        // attempt to get the SQL error info ...
      nRetVal = pErrorRecords->GetCustomErrorObject (i, IID_ISQLErrorInfo, (IUnknown**)&pSQLErrorInfo) ;
      if (FAILED(nRetVal))
      {
        cout << "ERROR: unable to get sql error info from record #" << i << ". Error = " <<
          hex << nRetVal << dec << endl ;
        continue ;
      }
      // if we have SQL error info ...
      if (pSQLErrorInfo)
      {
        long lNativeError ;

        nRetVal = pSQLErrorInfo->GetSQLInfo (&bstrSQLInfo, &lNativeError) ;
        if (FAILED(nRetVal))
        {
          cout << "ERROR: unable to get sql error description for record #" << i << ". Error = " <<
            hex << nRetVal << dec << endl ;
          continue ;
        }
        // output the info ...
        wsprintf (formaterror, L"SQLErrorInfo: %s NativeError: %d\n", bstrSQLInfo, lNativeError) ;
        errorstring = formaterror;
        arErrorList.push_front(errorstring);
      }
    }
  }

  cout << "ERROR: " << pString << " failed. Error = " <<
    hex << aError << dec << endl ;
}


//
//    Convert a OLEDB Rowset into a ADO Recordset using IRecordsetConstruction
//
// This method is specific to OLEDB 
//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////

HRESULT OLEDBContext::Rowset2Recordset(IRowset *pRowset,  _RecordsetPtr & pRs)
{
  ADORecordsetConstructionPtr pADORsCt;
  HRESULT hr = S_OK;

  try 
  {
    // Get an ADO recordset and ask for the recordset construction  interface

    if ( pRs != NULL)
    {
      // free the previous recordset
      pRs.Release();
    }

    // initialize the recordset
    hr = pRs.CreateInstance ("ADODB.Recordset") ;
    if (FAILED(hr))
    {
      SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Rowset2Recordset, CreateInstance (ADODB.Recordset)") ;
      throw hr;
    }

		// using client cursor
		pRs->CursorLocation = adUseClient;
		pRs->LockType = adLockBatchOptimistic;

    // query interface for IRecordsetConstruction
    pADORsCt = pRs;

    // Give the rowset to ADO
    hr= pADORsCt->put_Rowset(pRowset);

		// disconnect recordset
		//_ConnectionPtr cp5 = pRs->GetActiveConnection();
		//pRs->PutRefActiveConnection(NULL);  // this doesn't seem to be necessary
		//_ConnectionPtr cp6 = pRs->GetActiveConnection();

    if (FAILED(hr))
    {
      SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Rowset2Recordset, pADORsCt->put_Rowset(pRowset)") ;
      throw hr;
    }

  }
  catch (HRESULT hResult)
  {
    hResult =0;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  catch (_com_error e)
  {
    hr = e.Error();
    SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Rowset2Recordset") ;
    mLogger->LogVarArgs (LOG_ERROR, "Error Description = %s", (char*)e.Description()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#ifndef _DEBUG
  catch (...)
  {
    hr = E_FAIL ;
    SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Rowset2Recordset") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif

  return hr;
}

//
//    Convert a ADO Recordset into a OLEDB Rowset using IRecordsetConstruction
//
// This method is specific to OLEDB 
//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////

HRESULT OLEDBContext::Recordset2Rowset( _RecordsetPtr & pRs, IRowset **ppRowset)
{
  ADORecordsetConstructionPtr pADORsCt;
  HRESULT hr = S_OK;

  // Get an ADO recordset and ask for the recordset construction  interface

  if ( NULL == pRs )
  {
// If  no input, return NULL IRowset pointer - don't create one
//    hr = pRs.CreateInstance ("ADODB.Recordset") ;
//    if (FAILED(hr))  
      return hr;
  }

  // query interface for IADORecordsetConstruction

  try 
  {
    pADORsCt = pRs;

    // get the rowset from ADO

		hr = pADORsCt->get_Rowset((IUnknown **)ppRowset);

    if (FAILED(hr))
    {
      SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Recordset2Rowset", "Cannot transalate from ADO to OLEDB") ;
      throw hr;
    }
  }
  catch (HRESULT hResult)
  {
    hResult =0;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  catch (_com_error e)
  {
    hr = e.Error();
    SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Recordset2Rowset") ;
    mLogger->LogVarArgs (LOG_ERROR, "Error Description = %s", (char*)e.Description()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#ifndef _DEBUG
  catch (...)
  {
    hr = E_FAIL ;
    SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::Recordset2Rowset") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif
  return hr;

}

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//   CGetWhereAboutsOLE DB rowset to ADO rowset
///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

//
//	@mfunc
//	Constructor. Initialize the appropriate data members
//  @rdesc 
//  No return value
//
CGetWhereAbouts::CGetWhereAbouts() :
  m_lWhereAboutsSize(0),
  m_pWhereAboutsBinary(NULL)
{
}

//
//	@mfunc
//	Destructor
//  @rdesc 
//  No return value
//
CGetWhereAbouts::~CGetWhereAbouts()
{
    if ( NULL != m_pWhereAboutsBinary )
      delete[] m_pWhereAboutsBinary;
}


// @cmember Get the WhereAbouts info needed to call
// This gets the whereabouts and then 
// encodes the WhereAbouts binary cookie into a string.
// This method is specific to OLEDB 
BOOL CGetWhereAbouts::GetEncodedWhereAboutsDistributedTransaction(
                 /*[out]*/  _bstr_t * strWhereAbouts )
{
  BOOL              bOK = TRUE;
  ULONG             cbWhereAbouts;
  BYTE *            rgbWhereAbouts;
  string						localStrWhereAbouts;

  // check cached value

  if ( m_strCookie.length() > 0 )
  {
    *strWhereAbouts = m_strCookie;
    return bOK;
  }

  bOK =  GetWhereAboutsDistributedTransaction( &cbWhereAbouts, &rgbWhereAbouts );


  // convert cookie to ascii string

  if (bOK)
    bOK = rfc1421encode(rgbWhereAbouts, cbWhereAbouts, localStrWhereAbouts);

  if (bOK)
  {
    m_strCookie = localStrWhereAbouts.c_str();
    *strWhereAbouts = m_strCookie;
  }

  return bOK;
}

// @cmember Get the WhereAbouts info needed to call
// ExportDistributedTransaction.
// This method is specific to OLEDB 
//////////////////////////////////////////////
BOOL CGetWhereAbouts::GetWhereAboutsDistributedTransaction(
                 /*[out]*/ ULONG * cbWhereAbouts,
                 /*[out]*/ BYTE ** rgbWhereAbouts  )
{
  BOOL              bOK = TRUE;
	HRESULT						hr = S_OK;
	ITransactionImportWhereabouts*	pITransactionImportWhereabouts = NULL;
	unsigned long			lngUsed = 0;
  ErrorList errorList ;


	try
	{
    // check pointers 

	  if( (NULL == rgbWhereAbouts) || (NULL == cbWhereAbouts) )
    {
      hr = DB_ERR_INVALID_PARAMETER ;
      SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::GetWhereAboutsDistributedTransaction") ;
      mLogger->LogThis (LOG_ERROR, "NULL Pointer invalid argument.") ;
      throw hr;
    }

     // check for cached results
    if ( m_lWhereAboutsSize && NULL != m_pWhereAboutsBinary)
    {
      // return a copy of the cached data
      *cbWhereAbouts =  m_lWhereAboutsSize;
      *rgbWhereAbouts  = m_pWhereAboutsBinary;
      return hr;
    }

    hr = DtcGetTransactionManagerEx( NULL, NULL, IID_ITransactionImportWhereabouts, 0, 0, (void**)&pITransactionImportWhereabouts );
	  if( FAILED( hr ) )
    {
      SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::GetWhereAboutsDistributedTransaction",
        "cannot query ITransactionImportWhereabouts");
      GetOLEDBError( hr, "DtcGetTransactionManagerEx", errorList);
      throw hr;
    }

	  hr = pITransactionImportWhereabouts->GetWhereaboutsSize( &m_lWhereAboutsSize );
	  if( FAILED( hr ) )
    {
      SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::GetWhereAboutsDistributedTransaction",
        "ITransactionImportWhereabouts->GetWhereaboutsSize failed");
      GetOLEDBError( hr, "GetWhereaboutsSize", errorList);
      throw hr;
    }

    m_pWhereAboutsBinary = new BYTE[m_lWhereAboutsSize];
	  if( NULL == m_pWhereAboutsBinary )
    {
		  hr = E_OUTOFMEMORY;
      SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::GetWhereAboutsDistributedTransaction",
        "cannot allocate memory.");
      throw hr;
	  }

	  hr = pITransactionImportWhereabouts->GetWhereabouts( m_lWhereAboutsSize, m_pWhereAboutsBinary, &lngUsed );
	  if( FAILED( hr ) )
    {
      SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::GetWhereAboutsDistributedTransaction",
        "ITransactionImportWhereabouts->GetWhereabouts failed.");
      GetOLEDBError( hr, "GetWhereabouts", errorList);
      throw hr;
    }

    if( lngUsed != m_lWhereAboutsSize )
    {
		  hr = E_FAIL;
      SetError (hr, ERROR_MODULE, ERROR_LINE, "OLEDBContext::GetWhereAboutsDistributedTransaction",
        "WhereAboutsSize is incorrect") ;
      throw hr;
	  }
  }
	catch (HRESULT nResult)
	{
		bOK = FALSE;
    nResult = 0;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
	}
  catch (_com_error e)
  {
    bOK = FALSE ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "OLEDBContext::GetWhereAboutsDistributedTransaction") ;
    
    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, "Error Description = %s", (char*)e.Description()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    hr = e.Error() ;
    GetOLEDBError( hr, "GetWhereAboutsDistributedTransaction failed", errorList);
  }
#ifndef _DEBUG
  catch (...)
  {
    bOK = FALSE ;
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "OLEDBContext::GetWhereAboutsDistributedTransaction") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif
  
  ////////// clean up

  if ( bOK )
  {
    *cbWhereAbouts =  m_lWhereAboutsSize;
    *rgbWhereAbouts  = m_pWhereAboutsBinary;
  }
  else
  {
    *cbWhereAbouts =  0;
    *rgbWhereAbouts  = NULL;
    if ( NULL != m_pWhereAboutsBinary)
    {
      delete[] m_pWhereAboutsBinary;
    }
	}

	if( NULL != pITransactionImportWhereabouts )
  {
		pITransactionImportWhereabouts->Release();
  }

  return bOK;
}


///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//   CParameterToStoredProc
///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////
CParameterToStoredProc::CParameterToStoredProc()
{
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////
CParameterToStoredProc::CParameterToStoredProc(const std::wstring &arParamName, 
    const MTParameterType &arType, const MTParameterDirection &arDirection, 
    const _variant_t &arValue, _bstr_t& aDBType)
{
  if((_wcsicmp(arParamName.c_str(), L"ReturnVal") != 0 &&
    aDBType != (_bstr_t) ORACLE_DATABASE_TYPE))
    m_arParamName = L"@" ;

  // Oracle converts "" to NULL, so we replace them here with our own values.
  if(aDBType == (_bstr_t) ORACLE_DATABASE_TYPE && 
	 (arType == MTTYPE_W_VARCHAR || arType == MTTYPE_VARCHAR) &&
	 arValue == _variant_t(L""))
	 m_arValue = MTEmptyString;
  else
	 m_arValue = arValue;

  m_arParamName += arParamName.c_str();
  m_arType = arType;
  m_arDirection = arDirection;
  m_stringlength = 0;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////
CParameterToStoredProc::~CParameterToStoredProc()
{
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////

BOOL CParameterToStoredProc::InitParamInfo( DBPARAMBINDINFO * pParamInfo )
{
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;

    // switch on the variant type ...
    switch (m_arType)
    {
      case MTTYPE_SMALL_INT:
        pParamInfo->pwszDataSourceType = L"DBTYPE_I2";
        pParamInfo->ulParamSize = sizeof(short);
        break ;
      case MTTYPE_INTEGER:
        pParamInfo->pwszDataSourceType = L"DBTYPE_I4";
        pParamInfo->ulParamSize = sizeof(int);
        break ;
      case MTTYPE_BIGINT:
        pParamInfo->pwszDataSourceType = L"DBTYPE_I8";
        pParamInfo->ulParamSize = sizeof(long long);
        break ;
      case MTTYPE_FLOAT:
        pParamInfo->pwszDataSourceType = L"DBTYPE_R4";
        pParamInfo->ulParamSize = sizeof(float);
        break ;
      case MTTYPE_DOUBLE:
        pParamInfo->pwszDataSourceType = L"DBTYPE_R8";
        pParamInfo->ulParamSize = sizeof(double);
        break ;
      case MTTYPE_DECIMAL:
        pParamInfo->pwszDataSourceType = L"DBTYPE_NUMERIC";
        pParamInfo->ulParamSize = sizeof(DECIMAL);
				pParamInfo->bPrecision = METRANET_PRECISION_MAX;
				pParamInfo->bScale = METRANET_SCALE_MAX;
        break ;
      case MTTYPE_VARCHAR:
        pParamInfo->pwszDataSourceType = L"DBTYPE_VARCHAR";
        m_stringlength = GetSize(); // save the string length in case we need it for output
        pParamInfo->ulParamSize = m_stringlength;
        break ;
      case MTTYPE_W_VARCHAR:
        pParamInfo->pwszDataSourceType = L"DBTYPE_WVARCHAR";
        m_stringlength = GetSize(); // save the string length in case we need it for output
        pParamInfo->ulParamSize = m_stringlength;
        break ;
      case MTTYPE_VARBINARY:
        pParamInfo->pwszDataSourceType = L"DBTYPE_VARBINARY";
				m_stringlength = GetSize();
        pParamInfo->ulParamSize = m_stringlength;
        break ;
///////////////  other types not implemented
      case MTTYPE_DATE:
        pParamInfo->pwszDataSourceType = L"DBTYPE_DATE";
				pParamInfo->ulParamSize = sizeof(DATE);
				// hmm... maybe this is enough?
				break;

      case MTTYPE_NULL:
      default:
        bRetCode = FALSE ;
    }
      
      
    if (bRetCode)
    {
      switch (m_arDirection)
      {
      case INPUT_PARAM:
        pParamInfo->dwFlags = DBPARAMFLAGS_ISINPUT | DBPARAMFLAGS_ISNULLABLE ;
        break ;
      case OUTPUT_PARAM:
        pParamInfo->dwFlags = DBPARAMFLAGS_ISOUTPUT;
        break ;
      case IN_OUT_PARAM:
        pParamInfo->dwFlags = DBPARAMFLAGS_ISINPUT | DBPARAMFLAGS_ISOUTPUT;
        break ;
      case RETVAL_PARAM:
        pParamInfo->dwFlags = DBPARAMFLAGS_ISOUTPUT;
        break ;
      default:
        bRetCode = FALSE ;
      }
    }

    if (bRetCode)
    {
      pParamInfo->pwszName = (wchar_t *)m_arParamName;
    }

  return bRetCode;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////
BOOL CParameterToStoredProc::AppendParamToCommand( std::wstring &arCmd , unsigned long index,
                                                   const std::wstring &arDBType)
{
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;

  if (index > 1)
  {
    // append a separating comma
    arCmd += L", ";
  }
  else
  {
    // append a separating space
    arCmd += L" ";
  }
#ifdef NAME_BINDING

  if (arDBType.compare(ORACLE_DATABASE_TYPE) == 0)
  {
    arCmd += (wchar_t *)m_arParamName;
    arCmd += L" => ";
  }

#endif
  
  arCmd += L"?";

  if (arDBType.compare(DEFAULT_DATABASE_TYPE) == 0)
  {
    if ( m_arDirection ==  OUTPUT_PARAM  ||
      m_arDirection ==  IN_OUT_PARAM  )
    {
      arCmd += L" OUTPUT";
    }
  }

  return bRetCode;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////
BOOL CParameterToStoredProc::InitBindingInfo( DBBINDING * pBinding , unsigned long index,
                                             unsigned long * pOffsetBytesValue)
{
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;

  pBinding->iOrdinal = index ;
  pBinding->obValue = *pOffsetBytesValue ; // The offset in bytes in the consumer's buffer to the value part
  *pOffsetBytesValue += GetByteAlignedSize();
  pBinding->obLength = 0 ;
  pBinding->obStatus = *pOffsetBytesValue;
  *pOffsetBytesValue += sizeof(unsigned long) ;
  pBinding->pTypeInfo = NULL ;
  pBinding->pObject = NULL ;
  pBinding->pBindExt = NULL ;
  pBinding->dwPart = DBPART_VALUE | DBPART_STATUS ;
  pBinding->dwMemOwner = DBMEMOWNER_CLIENTOWNED;
  pBinding->eParamIO = GetParamIO() ;
  pBinding->dwFlags = 0 ;

  pBinding->wType = GetDBType() ;

	//BP: temporarily set string length
	//to string without multiplying by 2.
	//Seems like OraOLEDB wants a different thing from MSDAORA
	//
	/*
	if (pBinding->wType == DBTYPE_BYTES)
		// byte count for byte arrays
		pBinding->cbMaxLen = m_stringlength ;
	else
		// char count for strings - 2 bytes per char
		pBinding->cbMaxLen = 2*m_stringlength ;
		*/

	pBinding->cbMaxLen = m_stringlength ;


  pBinding->bPrecision = 10;
  pBinding->bScale = 10;

  return bRetCode;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////
unsigned long CParameterToStoredProc::GetByteAlignedSize( )
{
  unsigned long ByteAlignedSize = GetSize( );
  ByteAlignedSize = ((ByteAlignedSize +3) / 4 ) * 4;

  return ByteAlignedSize;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////
unsigned long CParameterToStoredProc::GetSize( )
{
  unsigned long Size = 0;
  _bstr_t val;

  try
  {
    // switch on the variant type ...
    switch (m_arType)
    {
      case MTTYPE_SMALL_INT:
        Size = sizeof(short);
        break ;
      case MTTYPE_INTEGER:
        Size = sizeof(int);
        break ;
      case MTTYPE_BIGINT:
        Size = sizeof(long long);
        break ;	
      case MTTYPE_FLOAT:
        Size = sizeof(float);
        break ;
      case MTTYPE_DOUBLE:
        Size = sizeof(double);
        break ;
      case MTTYPE_DECIMAL:
        Size = sizeof(DECIMAL);
        break ;
      case MTTYPE_VARCHAR:
				if(V_VT(&m_arValue) == VT_NULL)
					Size = 0;
				else
				{
					val = (_bstr_t)m_arValue;
					if(val.length() == 0 && m_arDirection == OUTPUT_PARAM) {
						Size = 0x1000;
					}
					else {
						Size = __max(1 + val.length(),m_stringlength);
					}
				}
        break ;
      case MTTYPE_W_VARCHAR:
				if(V_VT(&m_arValue) == VT_NULL)
					Size = 0;
				else
				{
					val = (_bstr_t)m_arValue;
					if(val.length() == 0 && m_arDirection == OUTPUT_PARAM) {
						Size = 0x1000;
					}
					else {
						Size = __max((1 + val.length()) * sizeof(wchar_t),m_stringlength);
					}
				}
        break ;
      case MTTYPE_VARBINARY:
				long temp;
				if(V_VT(&m_arValue) != VT_NULL)
				{
					SafeArrayGetUBound(m_arValue.parray, 1, &temp);
					Size = temp + 1;
				}
				else
					Size = 16;
				break;
      case MTTYPE_DATE:
				Size = 8;
        break;
///////////////  other types not implemented
      case MTTYPE_NULL:
      default:
        ASSERT(0);
        Size = 0;
        break;
    }

  }
  catch (_com_error e)
  {
    Size =0;
  }

  return Size;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////
DBTYPE CParameterToStoredProc::GetDBType( )
{
  DBTYPE wType;

    // switch on the variant type ...
    switch (m_arType)
    {
      case MTTYPE_SMALL_INT:
        wType = DBTYPE_I2;
        break ;
      case MTTYPE_INTEGER:
        wType = DBTYPE_I4;
        break ;
      case MTTYPE_BIGINT:
        wType = DBTYPE_I8;
        break ;
      case MTTYPE_FLOAT:
        wType = DBTYPE_R4;
        break ;
      case MTTYPE_DOUBLE:
        wType = DBTYPE_R8;
        break ;
      case MTTYPE_DECIMAL:
        wType = DBTYPE_DECIMAL;
        break ;
      case MTTYPE_W_VARCHAR:
        wType = DBTYPE_WSTR;
        break ;
      case MTTYPE_VARCHAR:
        wType = DBTYPE_STR;
        break ;
      case MTTYPE_VARBINARY:
				wType = DBTYPE_BYTES;
				break;
///////////////  other types not implemented
      case MTTYPE_DATE:
				wType = DBTYPE_DATE;
				break;
      case MTTYPE_NULL:
      default:
        wType = DBTYPE_EMPTY;
        break;
    }

  return wType;
}

//
//	@mfunc
//	
//  @rdesc 
//  
// write INPUT values into param buffer
//
////////////////////////////////////////////////////////////////////////////
BOOL CParameterToStoredProc::InitData(unsigned char ** ppBuffer, unsigned long status)
{
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  unsigned long datasize;
	
  
	// switch on the variant type ...
		if(V_VT(&m_arValue) != VT_NULL)
		{
			try
			{
				switch (m_arType)
				{
				case MTTYPE_SMALL_INT:
					{
						short val = (short)m_arValue;
						memcpy (*ppBuffer, &val , sizeof(short)) ;
					}
					break ;
				case MTTYPE_INTEGER:
					{
						long val = (long)m_arValue;
						memcpy (*ppBuffer, &val , sizeof(int)) ;
					}
					break ;
				case MTTYPE_BIGINT:
					{
						long long val = (long long)m_arValue;
						memcpy (*ppBuffer, &val , sizeof(long long)) ;
					}
					break ;	
				case MTTYPE_FLOAT:
					{
						float val = (float)m_arValue;
						memcpy (*ppBuffer, &val , sizeof(float)) ;
					}
					break ;
				case MTTYPE_DOUBLE:
					{
						double val = (double)m_arValue;
						memcpy (*ppBuffer, &val , sizeof(double)) ;
					}
					break ;
				case MTTYPE_DECIMAL:
					{
						DECIMAL val = (DECIMAL)m_arValue;
						memcpy (*ppBuffer, &val , sizeof(DECIMAL)) ;
					}
					break ;
				case MTTYPE_W_VARCHAR:
					{
						_bstr_t val = (_bstr_t)m_arValue;
						wmemcpy((wchar_t*)*ppBuffer, (wchar_t *)val , 1 + val.length()) ;
					}
					break ;
				case MTTYPE_VARCHAR:
					{
						_bstr_t	val = (_bstr_t)m_arValue;
						memcpy(*ppBuffer, (char *)val , 1 + val.length()) ;
					}
					break ;
				case MTTYPE_VARBINARY:
					{
						unsigned char * temp;
						::SafeArrayAccessData(m_arValue.parray, (void **) & temp);
						memcpy (*ppBuffer, temp , 16) ;
						::SafeArrayUnaccessData(m_arValue.parray);
					}
					break;
				case MTTYPE_DATE:
					{
						DATE val = (DATE)m_arValue;
						memcpy(*ppBuffer,&val,sizeof(DATE));
					}
          break;
				case MTTYPE_NULL:
					mLogger->LogThis(LOG_ERROR,"MTTYPE_NULL not supported in OLEDBContext");
					break;
				default:
					mLogger->LogThis(LOG_ERROR,"CParameterToStoredProc::InitData: unknown type");
					bRetCode = FALSE ;
					break;
				}
			}
			catch (_com_error e)
			{
				bRetCode = FALSE ;
			}
		}
		
		// round up to nearest 4 byte aligned
		
		(*ppBuffer) += GetByteAlignedSize();
		
		datasize = sizeof(unsigned long);  // this is 4 bytes
		
		// CS 1-29-2002: support for NULL values.  if the passed im variant is VT_NULL, 
		// then we use a status  code of DBSTATUS_S_ISNULL
		if(V_VT(&m_arValue) == VT_NULL) {
			status = DBSTATUS_S_ISNULL;
		}

		memcpy (*ppBuffer, &status, datasize) ;
		
		// round up to nearest 4 byte aligned
		
		(*ppBuffer) += datasize;
		
		return bRetCode;
}

//
//	@mfunc
//	
//  @rdesc 
//  
// read OUTPUT values from param buffer
//
////////////////////////////////////////////////////////////////////////////
BOOL CParameterToStoredProc::UpdateData(unsigned char ** ppBuffer, _bstr_t& aDBType)
{
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;

  try
  {
    if ( m_arDirection ==  OUTPUT_PARAM  ||
         m_arDirection ==  IN_OUT_PARAM  )
    {
      // switch on the variant type ...
      switch (m_arType)
      {
        case MTTYPE_SMALL_INT:
          {
          short val;
          memcpy (&val, *ppBuffer, sizeof(short)) ;
          m_arValue = val;
          }
          break ;
        case MTTYPE_INTEGER:
          {
          long val;
          memcpy (&val, *ppBuffer , sizeof(int)) ;
          m_arValue = val;
          }
          break ;
	case MTTYPE_BIGINT:
          {
          long long val;
          memcpy (&val, *ppBuffer , sizeof(long long)) ;
          m_arValue = val;
          }
          break ;  
        case MTTYPE_FLOAT:
          {
          float val;
          memcpy (&val, *ppBuffer , sizeof(float)) ;
          m_arValue = val;
          }
          break ;
        case MTTYPE_DOUBLE:
          {
          double val;
          memcpy (&val, *ppBuffer , sizeof(double)) ;
          m_arValue = val;
          }
          break ;
        case MTTYPE_DECIMAL:
          {
          DECIMAL val;
          memcpy (&val, *ppBuffer , sizeof(DECIMAL)) ;
          m_arValue = val;
          }
          break ;
        case MTTYPE_W_VARCHAR:
          {
			_bstr_t bstrparam;
			bstrparam = (const wchar_t *) *ppBuffer;

			// For oracle "" is mapped to MTEmptyString to avoid being interpreted as NULL.
			// We need to strip this character if we see it.
			if (aDBType == (_bstr_t) ORACLE_DATABASE_TYPE && MTEmptyString == bstrparam)
			{
				m_arValue = L"";
			}
			else
				m_arValue = bstrparam;
            break;
          }
		case MTTYPE_VARCHAR:
          {
			_bstr_t bstrparam;
			bstrparam = (const char *) *ppBuffer;

			// For orace "" is mapped to MTEmptyString to avoid being interpreted as NULL.
			// We need to strip this character if we see it.
			if (aDBType == (_bstr_t) ORACLE_DATABASE_TYPE && 
				MTEmptyString == bstrparam)
			{
				m_arValue = "";
			}
			else
				m_arValue = bstrparam;
            break;
          }
					// other types not implemented for return values
        case MTTYPE_VARBINARY:
					{
						ASSERT(!"Not implemented");
						mLogger->LogThis(LOG_FATAL,"CParameterToStoredProc::UpdateData not implemented for MTTYPE_VARBINARY");
						bRetCode = FALSE;
            break;
					}
        case MTTYPE_DATE:
					{
						DATE val;
						memcpy(&val,*ppBuffer,sizeof(DATE));
						m_arValue = val;
            break;
					}
        case MTTYPE_NULL:
        default:
          bRetCode = FALSE ;
          break;
      }
    }
  }
  catch (_com_error e)
  {
      bRetCode = FALSE ;
  }


  // round up to nearest 4 byte aligned

  (*ppBuffer) += GetByteAlignedSize();

	// store status for debugging
	long status;
	memcpy (&status, *ppBuffer , sizeof(long)) ;

  (*ppBuffer) += sizeof(unsigned long);  // this is 4 bytes for status

  return bRetCode;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////
DBPARAMIO CParameterToStoredProc::GetParamIO( )
{
  DBPARAMIO io =DBPARAMIO_NOTPARAM;

      switch (m_arDirection)
      {
      case INPUT_PARAM:
        io = DBPARAMIO_INPUT;
        break ;
      case OUTPUT_PARAM:
        io = DBPARAMIO_OUTPUT;
        break ;
      case IN_OUT_PARAM:
        io = DBPARAMIO_INPUT | DBPARAMIO_OUTPUT;
        break ;
      case RETVAL_PARAM:
      default:
        break;
      }

  return io;
}


//
//	@mfunc
//	
//  @rdesc 
//  
//
////////////////////////////////////////////////////////////////////////////
BOOL CParameterToStoredProc::GetParamByName(_bstr_t & arParamName, _variant_t &arValue, _bstr_t& aDBType)
{
  bstr_t tempName;
  if((_wcsicmp((wchar_t*)arParamName, L"ReturnVal") != 0 &&
    aDBType != (_bstr_t) ORACLE_DATABASE_TYPE))
    tempName = L"@" ;
  
  tempName += arParamName;
  
  if (tempName == m_arParamName)
  {
    // For oracle string parameters may be empty strings represented by our internal empty string.
	// We need to convert back to normal empty string before returning param.
	if (aDBType == (_bstr_t) ORACLE_DATABASE_TYPE &&
		(m_arType == MTTYPE_W_VARCHAR || m_arType == MTTYPE_VARCHAR) &&
		MTEmptyString == (_bstr_t) m_arValue)
		arValue = "";
	else
		arValue = m_arValue;
    return TRUE;
  }
  
  return FALSE;
}
