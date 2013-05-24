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
 * $Header: ADODBContext.cpp, 56, 9/11/2002 9:25:02 AM, Alon Becker$
 *
 * @index | ADODBContext
 ***************************************************************************/

#define MT_TRACE_CONNECTIONS

#include <metra.h>
#include <mtcom.h>
#include <mtglobal_msg.h>
#include <comdef.h>
#include <ADODBContext.h>
#include <adoutil.h>
#include <cpool.h>
#include <mtprogids.h>
#include <SharedDefs.h>
#ifdef _DEBUG
#include <iostream>
#include <string>
#endif

#include <mtcomerr.h>


static int oc = 0;
//
//	@mfunc
//	Constructor. Initialize the appropriate data members
//  @rdesc 
//  No return value
//
ADODBContext::ADODBContext()
: mConnection(NULL), mInitialized(FALSE), mCommand(NULL),
mProcInitialized(FALSE)
{  
}

//
//	@mfunc
//	Destructor
//  @rdesc 
//  No return value
//
ADODBContext::~ADODBContext()
{
  Disconnect() ;
}

BOOL ADODBContext::Init(const DBInitParameters &arParams)
{
  // local variables 
  BOOL bRetCode=TRUE ;
  DWORD nError=NO_ERROR ;
  long nState ;

  try 
  {
#if 0
    // verify the version of ADO ... must be 1.50.2404 or greater ...
    bRetCode = VerifyADOVersion() ;
    if (bRetCode == FALSE)
    {
      throw nError ;
    }
#endif

    // if the command has already been initialized ... free it 
    if (mCommand != NULL)
    {
      // release the command ...
      mCommand.Release() ;
      mCommand = NULL ;
    }
    // if the connection has already been initialized ... free it 
    if (mConnection != NULL)
    {
      // check the state of the object
      nState = mConnection->State ;
      if (nState == adStateOpen)
      {
        mConnection->Close() ;
      }
    }

		// Enable connection pooling
		EnableConnectionPooling(TRUE);

    // create the instance of the connection ...
    nError = mConnection.CreateInstance("ADODB.Connection");
    if (!SUCCEEDED(nError))
    {
      SetError (nError, ERROR_MODULE, ERROR_LINE, "Init",
        "Unable to create instance of Connection object") ;
      throw nError ;
    }
    // copy the parameters to the data members ...
    mAccessType = arParams.GetAccessType() ;
    if (mAccessType == ((_bstr_t) MTACCESSTYPE_ADO))
    {
      mDBName = arParams.GetDBName() ;
      mServerName = arParams.GetServerName() ;
      mDBType = arParams.GetDBType() ;
    }
    else if (mAccessType == ((_bstr_t) MTACCESSTYPE_ADO_DSN))
    {
      mDataSource = arParams.GetDataSource() ;
      mDBType = arParams.GetDBType() ;
    }
    else
    {
      nError = DB_ERR_INVALID_PARAMETER ;
      SetError (nError, ERROR_MODULE, ERROR_LINE,
        "Init", "Invalid access type specified.") ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Invalid access type specified. Access Type = %s", (char*)mAccessType) ;
      throw nError ;
    }
    mUserName = arParams.GetDBUser() ;
    mPassword = arParams.GetDBPwd() ;
    mProvider = arParams.GetProvider() ;
    mTimeout = arParams.GetTimeout() ;
    mDBDriver = arParams.GetDBDriver() ;
    
    // set the initialized data member ...
    mInitialized = TRUE ;
  }
  catch (DWORD nResult)
  {
    SetError (nResult, ERROR_MODULE, ERROR_LINE, "Init") ;
    mLogger->LogThis (LOG_ERROR, "Initialization of database context failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    nResult = 0 ;
    bRetCode = FALSE ;
  }
  catch (_com_error e)
  {
    // SetError (e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "Init") ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Initialization of database context failed. Error Description = %s",
      (char*)e.Description()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "Init") ;
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
BOOL ADODBContext::Connect()
{
	BOOL bRetCode = TRUE;
    std::wstring sourceName ;
  HRESULT nRetVal=S_OK ;
  long nState ;
  DWORD nRetries=0 ;
  bool bOracle = (0 == wcscmp(mDBType, L"{Oracle}"));
	std::wstring provider=mProvider ;

    try
    {
    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "Connect",
        "Database context not initialized") ;
      throw nRetVal ;
    }
    // check the state of the object
    nState = mConnection->State ;

    // if the object is closed ... open a connection ... otherwise just return
    if (nState == adStateClosed)
    {
			sourceName = L"Provider=";
			sourceName += mProvider;

			if (mDataSource.length() > 0)
			{
				sourceName += L";DSN=";
				sourceName += mDataSource;
			}
      else
      {
        sourceName += L";DRIVER=";
        sourceName += mDBType;
        // provide the SQL server database name, although it's not necessarily required
        sourceName += L";Server=";
        sourceName += mServerName ;
        sourceName += L";database=" ;
        sourceName += mDBName ;
      }

      // while we aren't connected ...
      while ((nState == adStateClosed) && (nRetries < 3))
		{
			// start the try ...
			try
			{
					// the -1 below is for undocumented options on ADO 1.5

				if (!bOracle)
				{
            mConnection->Open(sourceName.c_str(), mUserName, mPassword, -1); 

#ifdef MT_TRACE_CONNECTIONS
					mLogger->LogVarArgs(LOG_TRACE, "[CnxTrace] >>> opened ADO [%x] '%S'", this, sourceName.c_str());
#endif
				}
				else
				{
					char connstr[1024];
					if(mServerName.length() < 1)
						mServerName = mDataSource;
					sprintf(connstr, "Provider=OraOLEDB.Oracle;Data Source=%s;", (char*)mServerName);
					mConnection->Open(connstr, mUserName, mPassword, -1); 

#ifdef MT_TRACE_CONNECTIONS
					mLogger->LogVarArgs(LOG_TRACE, "[CnxTrace] >>> opened ADO %i [%x] '%s'", ++oc, this, connstr);
#endif
				}
					
				nState = mConnection->State ;
													
        }
        catch (_com_error e)
        {
#ifdef MT_TRACE_CONNECTIONS
					mLogger->LogVarArgs(LOG_ERROR, "[CnxTrace] *** error opening '%S'\nError %x: %S",
															sourceName.c_str(), e.Error(), e.ErrorMessage());
#endif          
					//SetError (e) ;
          nRetVal = e.Error() ;
          nRetries++ ;
          Sleep (100 * nRetries) ;
          if (nRetries >= 3)
          {
            throw e ;
          }
        }
      }
      // if the connection is still closed ...
      if (nState == adStateClosed)
      {
        SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "Connect",
          "Unable to connect to database") ;
        throw nRetVal ;
      }
      // otherwise ... set the timeout value ...
      else 
      {
        // set the timeout on the command ...
        mConnection->CommandTimeout = mTimeout;
      }
    }
	}
	catch (HRESULT nResult)
	{
    nResult = 0 ;
		bRetCode = FALSE;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Database connect failed. DBName = <%s> ServerName = <%s> User = <%s>. DSN = <%s>. Provider = <%s>",
      (char*)mDBName, (char*)mServerName, (char*)mUserName, (char*) mDataSource, (char*) mProvider) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
	}
  catch (_com_error e)
  {
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "Connect") ;
    bRetCode = FALSE ;
    
    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, 
      "Database connect failed. Error Description = %s",
      (char*)e.Description()) ;
        mLogger->LogVarArgs (LOG_ERROR, 
      "DBName = <%s> ServerName = <%s> User = <%s>. DSN = <%s>. Provider = <%s>",
      (char*)mDBName, (char*)mServerName, (char*)mUserName, (char*) mDataSource, (char*) mProvider) ;

    std::wstring wstr;
    LISTADOERROR adoErrorList;
    LISTADOERROR::iterator iter;
    GetCOMError( e, adoErrorList, mConnection );
		for (iter = adoErrorList.begin(); iter != adoErrorList.end(); iter++) 
    {
			wstr = *iter;
#ifdef _DEBUG
      _tprintf(_T("%s\n"), wstr.c_str());
#endif
      // log the message ...
      mLogger->LogThis (LOG_ERROR, wstr.c_str()) ;
		}
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "Connect") ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Database connect failed. DBName = <%s> ServerName = <%s> User = <%s>",
      (char*)mDBName, (char*)mServerName, (char*)mUserName) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }
#endif

	return bRetCode;
}

//
//	@mfunc
//	Disconnect from the database.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
BOOL ADODBContext::Disconnect()
{
  // local variables 
  BOOL bRetCode=TRUE ;
  DWORD nError=NO_ERROR ;
  long nState ;
  
  // start the try ...
  try
  {
    // disconnect the connection ...
    if (mConnection != NULL)
    {
			// check the state of the object
      nState = mConnection->State ;
      if (nState == adStateOpen)
      {
#ifdef MT_TRACE_CONNECTIONS
				mLogger->LogVarArgs(LOG_TRACE, "[CnxTrace] <<< closing ADO %i [%x]",	oc--, this);
#endif 
        mConnection->Close() ;
        mConnection = NULL ;
      }
    }
    // disconnect the command ...
    if (mCommand != NULL)
    {
      mCommand.Release() ;
      mCommand = NULL ;
    }
  }
  catch (_com_error e)
  {
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "Disconnect") ;
    mLogger->LogVarArgs (LOG_ERROR, "Database disconnect failed. Error Description = %s",
      (char*)e.Description()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "Disconnect") ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database disconnect failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif

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
BOOL ADODBContext::Execute (const std::wstring & arCmd, int aTimeout)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal ;
  
  // start the try 
  try
  {
    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "Execute",
        "Database context not initialized") ;
      throw nRetVal ;
    }
    // check to make sure the command isnt null ...
    if (arCmd.empty())
    {
      nRetVal = DB_ERR_NO_QUERY ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "Execute",
        "No query specified.") ;
      throw nRetVal ;
    }

    // set the timeout ...
    if (aTimeout > mTimeout)
    {
      mConnection->CommandTimeout = aTimeout;
    }
#if 0
    // log the time before the call ...
    nStart = ::GetTickCount() ;
#endif

		if (mQueryLog->IsOkToLog(LOG_DEBUG))
		{
			mQueryLog->LogThis(LOG_DEBUG, (GetTransactionContext() + arCmd).c_str());
		}

    // execute the command
	 //wprintf(L"####### sqlcmd:\n%s\n#######\n", arCmd.c_str());
    mConnection->Execute (arCmd.c_str(), NULL, 
      (adCmdText | adExecuteNoRecords)) ;
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
      mConnection->CommandTimeout = mTimeout ;
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
    //SetError (e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "Execute") ;
    bRetCode = FALSE ;

    // log the message ...
	 //printf("error:\n%s\n######\n", (char*)e.Description());
    mLogger->LogVarArgs (LOG_ERROR, "Database Execute() failed. Error Description = %s",
      (char*)e.Description()) ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str());

    std::wstring wstr;
    LISTADOERROR adoErrorList;
    LISTADOERROR::iterator iter;
    GetCOMError( e, adoErrorList, mConnection );
		for (iter = adoErrorList.begin(); iter != adoErrorList.end(); iter++) 
    {
			wstr = *iter;
#ifdef _DEBUG
      _tprintf(_T("%s\n"), wstr.c_str());
#endif
      // log the message ...
      mLogger->LogThis (LOG_ERROR, wstr.c_str()) ;
		}
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "Execute") ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database Execute() failed.") ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif

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
BOOL ADODBContext::Execute (const std::wstring &arCmd, DBSQLRowset &arRowset)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal ;
  _RecordsetPtr &arRecordset = arRowset.GetRecordsetPtr() ;

  // start the try 
  try
  {
    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "Execute",
        "Database context not initialized") ;
      throw nRetVal ;
    }
    // check to make sure the command isnt null ...
    if (arCmd.empty())
    {
      nRetVal = DB_ERR_NO_QUERY ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "Execute",
        "No query specified.") ;
      throw nRetVal ;
    }
#if 0
    // log the time before the call ...
    nStart = ::GetTickCount() ;
#endif
    // set the cursor location ...
    mConnection->CursorLocation = adUseClient;

		if(mQueryLog->IsOkToLog(LOG_DEBUG))
		{
			mQueryLog->LogThis(LOG_DEBUG, (GetTransactionContext() + arCmd).c_str());
		}

    // execute the command ...
    arRecordset = mConnection->Execute (arCmd.c_str(), NULL, adCmdText) ;

    // disconnect the record set
		arRecordset->PutRefActiveConnection(NULL);
#if 0
    // log the time after the call ...
    nEnd = ::GetTickCount() ;

    // calculate the difference ...
    nDiff = nEnd - nStart ;

    // log the perf time ...
    mLogger->LogVarArgs (LOG_DEBUG, "The database query took %d milliseconds", nDiff) ;
#endif
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
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "Execute") ;
    bRetCode = FALSE ;

    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, "Database Execute() failed. Error Description = %s",
      (char*)e.Description()) ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str()) ;

    std::wstring wstr;
    LISTADOERROR adoErrorList;
    LISTADOERROR::iterator iter;
    GetCOMError( e, adoErrorList, mConnection );
		for (iter = adoErrorList.begin(); iter != adoErrorList.end(); iter++) 
    {
			wstr = *iter;
#ifdef _DEBUG
      _tprintf(_T("%s\n"), wstr.c_str());
#endif
      // log the message ...
      mLogger->LogThis (LOG_ERROR, wstr.c_str()) ;
		}
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "Execute") ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database Execute() failed.") ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif

  return bRetCode ;
}


//
// Replacement for Execute. This method correctly uses connected recordsets.
// This method should be used for large recordsets to improve performance.
//
BOOL ADODBContext::ExecuteConnected(const std::wstring &arCmd, DBSQLRowset &arRowset)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal ;
  _RecordsetPtr &arRecordset = arRowset.GetRecordsetPtr() ;

  // start the try 
  try
  {
    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "Execute",
        "Database context not initialized") ;
      throw nRetVal ;
    }
    // check to make sure the command isnt null ...
    if (arCmd.empty())
    {
      nRetVal = DB_ERR_NO_QUERY ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, "Execute",
        "No query specified.") ;
      throw nRetVal ;
    }

    // set the cursor location ...
    mConnection->CursorLocation = adUseNone;

		if(mQueryLog->IsOkToLog(LOG_DEBUG))
		{
			mQueryLog->LogThis(LOG_DEBUG, (GetTransactionContext() + arCmd).c_str());
		}

    // execute the command ...
    arRecordset = mConnection->Execute (arCmd.c_str(), NULL, adCmdText) ;

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
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "Execute") ;
    bRetCode = FALSE ;

    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, "Database Execute() failed. Error Description = %s",
      (char*)e.Description()) ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str()) ;

    std::wstring wstr;
    LISTADOERROR adoErrorList;
    LISTADOERROR::iterator iter;
    GetCOMError( e, adoErrorList, mConnection );
		for (iter = adoErrorList.begin(); iter != adoErrorList.end(); iter++) 
    {
			wstr = *iter;
#ifdef _DEBUG
      _tprintf(_T("%s\n"), wstr.c_str());
#endif
      // log the message ...
      mLogger->LogThis (LOG_ERROR, wstr.c_str()) ;
		}
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "Execute") ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database Execute() failed.") ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif

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
BOOL ADODBContext::ExecuteDisconnected (const std::wstring &arCmd, DBSQLRowset &arRowset,
                                        LockTypeEnum lockType)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  _RecordsetPtr &arRecordset = arRowset.GetRecordsetPtr() ;
 
  // start the try 
  try
  {
    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "ExecuteDisconnected", "Database context not initialized") ;
      throw nRetVal ;
    }
    // check to make sure the command isnt null ...
    if (arCmd.empty())
    {
      nRetVal = DB_ERR_NO_QUERY ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "ExecuteDisconnected", "No query specified.") ;
      throw nRetVal ;
    }
    // create an instance of the Recordset COM object ...
    nRetVal = arRecordset.CreateInstance ("ADODB.Recordset") ;
    if (!SUCCEEDED(nRetVal))
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "ExecuteDisconnected", 
        "Unable to create instance of Recordset object") ;
      throw nRetVal ;
    }
    
    // prepare the return result set to be disconnected
		arRecordset->CursorLocation = adUseClient;
#if 0
    // log the time before the call ...
    nStart = ::GetTickCount() ;
#endif

		if(mQueryLog->IsOkToLog(LOG_DEBUG))
		{
			mQueryLog->LogThis(LOG_DEBUG, (GetTransactionContext() + arCmd).c_str());
		}

    // execute the query ... 
    arRecordset->Open(arCmd.c_str(), mConnection.GetInterfacePtr(), 
											adOpenForwardOnly, lockType, -1);
		
		// disconnect the record set
		arRecordset->PutRefActiveConnection(NULL);
#if 0
    // log the time after the call ...
    nEnd = ::GetTickCount() ;

    // calculate the difference ...
    nDiff = nEnd - nStart ;

    // log the perf time ...
    mLogger->LogVarArgs (LOG_DEBUG, "The database query took %d milliseconds", nDiff) ;
#endif
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
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "ExecuteDisconnected") ;
    bRetCode = FALSE ;

    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, "Database Execute() failed. Error Description = %s",
      (char*)e.Description()) ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str()) ;

    std::wstring wstr;
    LISTADOERROR adoErrorList;
    LISTADOERROR::iterator iter;
    GetCOMError( e, adoErrorList, mConnection );
		for (iter = adoErrorList.begin(); iter != adoErrorList.end(); iter++) 
    {
			wstr = *iter;
#ifdef _DEBUG
      _tprintf(_T("%s\n"), wstr.c_str());
#endif
      // log the message ...
      mLogger->LogThis (LOG_ERROR, wstr.c_str()) ;
		}
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "ExecuteDisconnected") ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database Execute() failed.") ;
    mLogger->LogThis (LOG_ERROR, arCmd.c_str()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif

  return bRetCode ;
}

//
//	@mfunc
//	Begin an ADO transaction.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
BOOL ADODBContext::BeginTransaction()
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  long nState ;
 
  // start the try 
  try
  {
    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "BeginTransaction", "Database context not initialized") ;
      throw nRetVal ;
    }
    // check the state of the connection ...
    if (mConnection != NULL)
    {
      // check the state of the object
      nState = mConnection->State ;
      if (nState == adStateOpen)
      {
        mConnection->BeginTrans() ;
      }
      else
      {
        nRetVal = ADOERROR_OBJECT_CLOSED ;
        SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
          "BeginTransaction", "Unable to begin transaction") ;
        throw nRetVal ;
      }
    }
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
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "BeginTransaction") ;
    bRetCode = FALSE ;
    
    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, "Database BeginTransaction() failed. Error Description = %s",
      (char*)e.Description()) ;

    std::wstring wstr;
    LISTADOERROR adoErrorList;
    LISTADOERROR::iterator iter;
    GetCOMError( e, adoErrorList, mConnection );
		for (iter = adoErrorList.begin(); iter != adoErrorList.end(); iter++) {
			wstr = *iter;
#ifdef _DEBUG
      _tprintf(_T("%s\n"), wstr.c_str());
#endif
      // log the message ...
      mLogger->LogThis (LOG_ERROR, wstr.c_str()) ;
		}
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "BeginTransaction") ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database BeginTransaction() failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif

  return bRetCode ;
}

//
//	@mfunc
//	Commit an ADO transaction.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
BOOL ADODBContext::CommitTransaction()
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  long nState ;

  // start the try 
  try
  {
    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "CommitTransaction", "Database context not initialized") ;
      throw nRetVal ;
    }
    // check the state of the connection ...
    if (mConnection != NULL)
    {
      // check the state of the object
      nState = mConnection->State ;
      if (nState == adStateOpen)
      {
        mConnection->CommitTrans() ;
      }
      else
      {
        nRetVal = ADOERROR_OBJECT_CLOSED ;
        SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
          "CommitTransaction", "Unable to cimmit transaction") ;
        throw nRetVal ;
      }
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
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "CommitTransaction") ;
    bRetCode = FALSE ;

    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, "Database CommitTransaction() failed. Error Description = %s",
      (char*)e.Description()) ;

    std::wstring wstr;
    LISTADOERROR adoErrorList;
    LISTADOERROR::iterator iter;
    GetCOMError( e, adoErrorList, mConnection );
		for (iter = adoErrorList.begin(); iter != adoErrorList.end(); iter++) 
    {
			wstr = *iter;
#ifdef _DEBUG
      _tprintf(_T("%s\n"), wstr.c_str());
#endif
      // log the message ...
      mLogger->LogThis (LOG_ERROR, wstr.c_str()) ;
		}
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "CommitTransaction") ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database CommitTransaction() failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif

  return bRetCode ;
}

//
//	@mfunc
//	Rollback an ADO transaction.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error is
//  saved in mLastError.
//
BOOL ADODBContext::RollbackTransaction()
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  long nState ;

  // start the try 
  try
  {
    // check to make sure we're initialized ...
    if (mInitialized == FALSE)
    {
      nRetVal = DB_ERR_NOT_INITIALIZED ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "RollbackTransaction", "Database context not initialized") ;
      throw nRetVal ;
    }
    // check the state of the connection ...
    if (mConnection != NULL)
    {
      // check the state of the object
      nState = mConnection->State ;
      if (nState == adStateOpen)
      {
        mConnection->RollbackTrans() ;
      }
      else
      {
        nRetVal = ADOERROR_OBJECT_CLOSED ;
        SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
          "RollbackTransaction", "Unable to rollback transaction") ;
        throw nRetVal ;
      }
    }
  }
  catch (_com_error e)
  {
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "RollbackTransaction") ;
    bRetCode = FALSE ;

    // log the message ...
    mLogger->LogVarArgs (LOG_ERROR, "Database RollbackTransaction() failed. Error Description = %s",
      (char*)e.Description()) ;

    std::wstring wstr;
    LISTADOERROR adoErrorList;
    LISTADOERROR::iterator iter;
    GetCOMError( e, adoErrorList, mConnection );
		for (iter = adoErrorList.begin(); iter != adoErrorList.end(); iter++) 
    {
			wstr = *iter;
#ifdef _DEBUG
      _tprintf(_T("%s\n"), wstr.c_str());
#endif
      // log the message ...
      mLogger->LogThis (LOG_ERROR, wstr.c_str()) ;
		}
  }
  catch (HRESULT nResult)
  {
    nResult = 0 ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database RollbackTransaction() failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#ifndef _DEBUG
  catch (...)
  {
    SetError (DB_ERR_UNHANDLED_EXCEPTION, ERROR_MODULE, ERROR_LINE, "RollbackTransaction") ;
    bRetCode = FALSE ;
    mLogger->LogThis (LOG_ERROR, "Database RollbackTransaction() failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
#endif
  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL ADODBContext::VerifyADOVersion()
{
  // local variables ...
  DWORD nSize, nDummy ;
  DWORD nError=NO_ERROR ;
  void *pData=NULL, *pBuffer ;
  UINT nBufLen ;
  BOOL bRetCode ;
  std::wstring wstrFileVersion ;
  wchar_t wstrDirPath[MAX_PATH] ;

  // get the system directory ...
  nBufLen = ::GetSystemDirectory (wstrDirPath, MAX_PATH) ;
  if (nBufLen == 0)
  {
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "VerifyADOVersion") ;
    mLogger->LogThis (LOG_ERROR, "Call to GetSystemDirectory() failed.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }
  else
  {
    // get the directory out of the system directory ...
    wstrDirPath[2] = '\0' ;
    wcscat (wstrDirPath, ADO_FILE_DIRECTORY) ;
    
    // get the file version size ...
    nSize = ::GetFileVersionInfoSize (wstrDirPath, &nDummy) ;
    if (nSize == 0)
    {
      SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "VerifyADOVersion") ;
      mLogger->LogThis (LOG_ERROR, "Call to GetFileVersionInfoSize() failed.") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      bRetCode = FALSE ;
    }
    else
    {
      // allocate memory for the file version info ...
      pData = new BYTE[nSize] ;
      ASSERT (pData) ;
      if (pData == NULL)
      {
        SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "VerifyADOVersion") ;
        mLogger->LogThis (LOG_ERROR, "Call to allocate memory failed.") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        bRetCode = FALSE ;
      }
      else
      {
        // get the file version info ...
        bRetCode = ::GetFileVersionInfo (wstrDirPath, nDummy, 
          nSize, pData) ;
        if (bRetCode == 0)
        {
          SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "VerifyADOVersion") ;
          mLogger->LogThis (LOG_ERROR, "Call to GetFileVersionInfo() failed.") ;
          mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
          bRetCode = FALSE ;
        }
        else
        {
          // get out the file version info ...
          bRetCode = ::VerQueryValue (pData, L"\\StringFileInfo\\040904b0\\FileVersion",
            &pBuffer, &nBufLen) ;
          if (bRetCode == 0)
          {
            bRetCode = ::VerQueryValue (pData, L"\\StringFileInfo\\040904E4\\FileVersion",
              &pBuffer, &nBufLen) ;
            if (bRetCode == 0)
            {
              bRetCode = ::VerQueryValue (pData, L"\\StringFileInfo\\000004E4\\FileVersion",
                &pBuffer, &nBufLen) ;
              if (bRetCode == 0)
              {
                SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "VerifyADOVersion") ;
                mLogger->LogThis (LOG_ERROR, "Call to GetFileVersionInfo() failed.") ;
                mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
                bRetCode = FALSE ;
              }
              else
              {
                // copy the file version string out ...
                wstrFileVersion = (wchar_t*) pBuffer ;
              }
            }
            else
            {
              // copy the file version string out ...
              wstrFileVersion = (wchar_t*) pBuffer ;        
            }
          }
          else
          {
            // copy the file version string out ...
            wstrFileVersion = (wchar_t*) pBuffer ;
          }
        }
      }
    }
  }
  // if we read the file version successfully ...
  if (bRetCode == TRUE)
  {
    // the file version will look like one of two things 1.50.2404 or 2.0.3002.11
    // for some reason version 1.5 and version 2.0 have different version levels ...
    int nDiff = wstrFileVersion.compare (EARLIEST_SUPPORTED_ADO_VERSION) ;
    if (nDiff < 0)
    {
      SetError (DB_ERR_UNSUPPORTED_VERSION, ERROR_MODULE, ERROR_LINE, 
        "VerifyADOVersion") ;
      mLogger->LogThis (LOG_ERROR, "Unsupported version of ADO installed.") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      bRetCode = FALSE ;
    }
  }
  // delete the allocated memory ...
  if (pData != NULL)
  {
    delete [] pData ;
  }
    
  return bRetCode ;
}
//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL ADODBContext::InitializeForStoredProc (const std::wstring &arStoredProcName)
{
  // local variables
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;

  try
  {
    // if the command has already been initialized ... free it 
    if (mCommand != NULL)
    {
      // release the command ...
      mCommand.Release() ;
      mCommand = NULL ;
    }
    
    // create a command object ...
    nRetVal = mCommand.CreateInstance("ADODB.Command");
    if (SUCCEEDED(nRetVal))
    {
      // set the command text ...
      mSprocName = arStoredProcName.c_str() ;

      //BP: Associate command with active connection
      //here instead of doing it in ExecuteStoredProc
      mCommand->ActiveConnection = mConnection;
      mCommand->CommandText = mSprocName ;
      
      // set the command type ...
      mCommand->CommandType = adCmdStoredProc ;
#ifdef NAME_BINDING
      //mCommand->GetParameters();
      mCommand->NamedParameters = VARIANT_TRUE;
#endif

      // set the mProcInitialized flag
      mProcInitialized = TRUE ;
    }
    else
    {
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "InitializeForStoredProc") ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to create command for stored procedure. Name = %s", (char*)mSprocName) ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      bRetCode = FALSE ;
    }
  }
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "InitializeForStoredProc") ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Unable to create command for stored procedure. Name = %s. Error Description = %s",
      (char*) mSprocName, (char*)e.Description()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
    
    std::wstring wstr;
    LISTADOERROR adoErrorList;
    LISTADOERROR::iterator iter;
    GetCOMError( e, adoErrorList, mConnection );
    for (iter = adoErrorList.begin(); iter != adoErrorList.end(); iter++) 
    {
      wstr = *iter;
#ifdef _DEBUG
      _tprintf(_T("%s\n"), wstr.c_str());
#endif
      // log the message ...
      mLogger->LogThis (LOG_ERROR, wstr.c_str()) ;
    }
  }

  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL ADODBContext::AddParameterToStoredProc (const std::wstring &arParamName, 
    const MTParameterType &arType, const MTParameterDirection &arDirection)
{
  // if the parameter direction is input or input/output then this cannot be used...
  if ((arDirection == INPUT_PARAM) || (arDirection == IN_OUT_PARAM))
  {
    HRESULT nRetVal = ERROR_INVALID_FUNCTION ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
      "AddParameterToStoredProc") ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Unable to add input parameter to stored procedure without input value. Direction = %x. Name = %s", 
      arDirection, (char*) mSprocName) ;
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
//#ifndef NAME_BINDING
BOOL ADODBContext::AddParameterToStoredProc (const std::wstring &arParamName, 
    const MTParameterType &arType, const MTParameterDirection &arDirection, 
    const _variant_t &arValue)
{
  // local variables
  BOOL bRetCode=TRUE ;
  _ParameterPtr pParam ;
  long nDirection ;
  HRESULT nRetVal=S_OK ;
  std::wstring param;

  // if we're not initialized for a stored procedure ...
  if (mProcInitialized == FALSE)
  {
    nRetVal = DB_ERR_NOT_INITIALIZED ;
    bRetCode = FALSE ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
      "AddParameterToStoredProc") ;
    mLogger->LogThis (LOG_ERROR, "Unable to add paramter for stored procedure. Not initialized.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  else
  {
    try
    {
      //since we do support name binding,
      //append @ to parameter in case of SQL server
      param = arParamName;
	  if (0 == wcscmp(mDBType, L"{SQL Server}"))
        param.insert(0, L"@");
      //
      // convert the direction into ado enum ...
      switch (arDirection)
      {
      case INPUT_PARAM:
        nDirection = adParamInput ;
        break ;
      case OUTPUT_PARAM:
        nDirection = adParamOutput ;
        break ;
      case IN_OUT_PARAM:
        nDirection = adParamInputOutput ;
        break ;
      case RETVAL_PARAM:
        nDirection = adParamReturnValue ;
        break ;
      default:
        nRetVal = ERROR_INVALID_PARAMETER ;
        SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
          "AddParameterToStoredProc") ;
        mLogger->LogVarArgs (LOG_ERROR, 
          "Invalid direction for parameter specified. Param = %s. Name = %s. Direction = %x.", 
          param.c_str(), mSprocName, arDirection) ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        throw nRetVal ;
      }
      
      // switch on the variant type ...
      switch (arType)
      {
      case MTTYPE_SMALL_INT:
        if ((nDirection == adParamInput) || (nDirection == adParamInputOutput))
        {
          pParam = mCommand->CreateParameter (param.c_str(), adSmallInt, 
            (ParameterDirectionEnum) nDirection, 2, arValue) ; 
        }
        else
        {
          pParam = mCommand->CreateParameter (param.c_str(), adSmallInt, 
            (ParameterDirectionEnum) nDirection, 2) ; 
        }
        mCommand->Parameters->Append(pParam) ;
      case MTTYPE_INTEGER:
        if ((nDirection == adParamInput) || (nDirection == adParamInputOutput))
        {
          pParam = mCommand->CreateParameter (param.c_str(), adInteger, 
            (ParameterDirectionEnum) nDirection, 4, arValue) ; 
        }
        else
        {
          pParam = mCommand->CreateParameter (param.c_str(), adInteger, 
            (ParameterDirectionEnum) nDirection, 4) ; 
        }
        mCommand->Parameters->Append(pParam) ;
        break ;
      case MTTYPE_BIGINT:
        if ((nDirection == adParamInput) || (nDirection == adParamInputOutput))
        {
          pParam = mCommand->CreateParameter (param.c_str(), adBigInt, 
            (ParameterDirectionEnum) nDirection, 8, arValue) ; 
        }
        else
        {
          pParam = mCommand->CreateParameter (param.c_str(), adBigInt, 
            (ParameterDirectionEnum) nDirection, 8) ; 
        }
        mCommand->Parameters->Append(pParam) ;
        break ;
      case MTTYPE_FLOAT:
        if ((nDirection == adParamInput) || (nDirection == adParamInputOutput))
        {
          pParam = mCommand->CreateParameter (param.c_str(), adSingle, 
            (ParameterDirectionEnum) nDirection, 4, arValue) ; 
        }
        else
        {
          pParam = mCommand->CreateParameter (param.c_str(), adSingle, 
            (ParameterDirectionEnum) nDirection, 4) ; 
        }
        mCommand->Parameters->Append(pParam) ;
        break ;
      case MTTYPE_DOUBLE:
        if ((nDirection == adParamInput) || (nDirection == adParamInputOutput))
        {
          pParam = mCommand->CreateParameter (param.c_str(), adDouble, 
            (ParameterDirectionEnum) nDirection, 8, arValue) ; 
        }
        else
        {
          pParam = mCommand->CreateParameter (param.c_str(), adDouble, 
            (ParameterDirectionEnum) nDirection, 8) ; 
        }
        mCommand->Parameters->Append(pParam) ;
        break ;
      case MTTYPE_DECIMAL:
        if ((nDirection == adParamInput) || (nDirection == adParamInputOutput))
        {
          pParam = mCommand->CreateParameter (param.c_str(), adNumeric, 
            (ParameterDirectionEnum) nDirection, 14, arValue) ; 
		      pParam->PutNumericScale(METRANET_SCALE_MAX);
		      pParam->PutPrecision(METRANET_PRECISION_MAX);
		}
        else
        {
          pParam = mCommand->CreateParameter (param.c_str(), adNumeric, 
            (ParameterDirectionEnum) nDirection, 14) ; 
					// TODO: necessary for outputs?
		      pParam->PutNumericScale(METRANET_SCALE_MAX);
		      pParam->PutPrecision(METRANET_PRECISION_MAX);
        }
        mCommand->Parameters->Append(pParam) ;
        break ;
      case MTTYPE_VARCHAR:
      {
          if ((nDirection == adParamInput) || (nDirection == adParamInputOutput))
          {
			bool isOracleEmptyString = (mDBType == (_bstr_t) ORACLE_DATABASE_TYPE && arValue == _variant_t(""))
									 ? true : false;
			long size;
			if (V_VT(&arValue) == VT_NULL)
				size = 0;
			else if (isOracleEmptyString)
				size = MTEmptyString.length();
			else
				size = _bstr_t(arValue).length();

            // size can not be 0 
            // If size is 0 on a variable-length data type we'll get the follwing error when calling Append(pParam):
            //  0x800a0e7c: Parameter object is improperly defined. Inconsistent or incomplete information was provided
            // To allow passing empty strings "" make sure size it at least 1 (size specifies the MAXIMUM length)
			if (size == 0)
				size = 1;

			pParam = mCommand->CreateParameter (param.c_str(), adVarChar, 
												(ParameterDirectionEnum) nDirection,
												size, isOracleEmptyString ? MTEmptyString : arValue) ; 
          }
          else
          {
			// TODO: the length in characters of this output parameter is
			// fixed at 4000. Ideally it would be nice to pass this information in
            pParam = mCommand->CreateParameter (param.c_str(), adVarChar,
												(ParameterDirectionEnum) nDirection,
												MAX_VARCHAR_OUTPUT_SIZE) ; 
          }
          mCommand->Parameters->Append(pParam) ;
        }
        break ;
      case MTTYPE_W_VARCHAR:
        {
          if ((nDirection == adParamInput) || (nDirection == adParamInputOutput))
          {
	  			bool isOracleEmptyString = (mDBType == (_bstr_t) ORACLE_DATABASE_TYPE && arValue == _variant_t(L""))
										 ? true : false;

	            // convert the variant to a std string so we can get the length ...
		        long size;
				if (V_VT(&arValue) == VT_NULL)
					size = 1;
				else if (isOracleEmptyString)
					size = MTEmptyString.length();
				else
				{
					size = _bstr_t(arValue).length();
		        }

				if(size == 0)
					size = 1;

			    pParam = mCommand->CreateParameter (param.c_str(), adWChar, 
													(ParameterDirectionEnum) nDirection, size,
													isOracleEmptyString ? MTEmptyString : arValue); // 2?
          }
          else
          {
            pParam = mCommand->CreateParameter (param.c_str(), adWChar, 
              (ParameterDirectionEnum) nDirection, 20) ; 
          }
          mCommand->Parameters->Append(pParam) ;
        }
        break ;
      case MTTYPE_VARBINARY:
        {
          if ((nDirection == adParamInput) || (nDirection == adParamInputOutput))
          {
				if (V_VT(&arValue) == VT_NULL)
				{
					pParam = mCommand->CreateParameter (param.c_str(), adVarBinary, 
														(ParameterDirectionEnum) nDirection, 1, arValue) ; 
				}
				else
				{
					// get the size of the varbinary ...
					long nSize=0 ;
					nRetVal = SafeArrayGetUBound (arValue.parray, 1, &nSize) ;
					if (FAILED(nRetVal))
					{
						SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
											"AddParameterToStoredProc") ;
						mLogger->LogVarArgs (LOG_ERROR, 
											 "Unable to get upper bound for parameter = %s.", 
											 param.c_str()) ;
						mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
					}
					pParam = mCommand->CreateParameter (param.c_str(), adVarBinary, 
														(ParameterDirectionEnum) nDirection, nSize+1, arValue) ; 
				}
          }
          else
          {
            pParam = mCommand->CreateParameter (param.c_str(), adVarBinary, 
              (ParameterDirectionEnum) nDirection, 20) ; 
          }
          mCommand->Parameters->Append(pParam) ;
        }
        break ;
      case MTTYPE_DATE:
        if ((nDirection == adParamInput) || (nDirection == adParamInputOutput))
        {
          pParam = mCommand->CreateParameter (param.c_str(), adDBTimeStamp, 
            (ParameterDirectionEnum) nDirection, 8, arValue) ; 
        }
        else
        {
          pParam = mCommand->CreateParameter (param.c_str(), adDBTimeStamp, 
            (ParameterDirectionEnum) nDirection, 8) ; 
        }
        mCommand->Parameters->Append(pParam) ;
        break ;
      case MTTYPE_NULL:
        {
          if ((nDirection == adParamInput) || (nDirection == adParamInputOutput))
          {
            pParam = mCommand->CreateParameter (param.c_str(), adEmpty, 
              (ParameterDirectionEnum) nDirection, 0, arValue) ; 
						pParam->PutAttributes(adParamNullable);
          }
          else
          {
            pParam = mCommand->CreateParameter (param.c_str(), adEmpty, 
              (ParameterDirectionEnum) nDirection, 20) ; 
          }
          mCommand->Parameters->Append(pParam) ;
        }
        break ;
      default:
        nRetVal = ERROR_INVALID_PARAMETER ;
        SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
          "AddParameterToStoredProc") ;
        mLogger->LogVarArgs (LOG_ERROR, 
          "Invalid type for parameter specified. Param = %s. Type = %x. Name = %s.", 
          param.c_str(), arValue.vt, (char*) mSprocName) ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        throw nRetVal ;
      }
    }
    catch (_com_error e)
    {
      nRetVal = e.Error() ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "AddParameterToStoredProc") ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to add parameter for stored procedure. Name = %s. Error Description = %s",
      (char*)mSprocName, (char*)e.Description()) ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Parameter Name = %s. Type = %x", param.c_str(), arValue.vt) ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      bRetCode = FALSE ;

      std::wstring wstr;
      LISTADOERROR adoErrorList;
      LISTADOERROR::iterator iter;
      GetCOMError( e, adoErrorList, mConnection );
      for (iter = adoErrorList.begin(); iter != adoErrorList.end(); iter++) 
      {
        wstr = *iter;
#ifdef _DEBUG
        _tprintf(_T("%s\n"), wstr.c_str());
#endif
        // log the message ...
        mLogger->LogThis (LOG_ERROR, wstr.c_str()) ;
      }
    }
    catch (HRESULT nStatus)
    {
      nRetVal = nStatus ;
      bRetCode = FALSE ;
    }
  }
  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL ADODBContext::ExecuteStoredProc()
{
  DBSQLRowset rs;
	return ExecuteStoredProc(rs);
}

BOOL ADODBContext::ExecuteStoredProc(DBSQLRowset &arRowset)
{
  // local variables ...
  BOOL bRetCode=TRUE;
  HRESULT nRetVal=S_OK;

  // if we're not initialized for a stored procedure ...
  if (mProcInitialized == FALSE)
  {
    nRetVal = DB_ERR_NOT_INITIALIZED ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
      "ExecuteStoredProc") ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Unable to execute stored procedure. Not initialized.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }
  else
  {
    try
    {
      //fix to the fix of CR 6412
			mCommand->CommandTimeout = mTimeout;

			// associate the command with the connection ...
      //BP: put connection in initialize for stored procedure

      //mCommand->PutRefActiveConnection(mConnection);

			if (mQueryLog->IsOkToLog(LOG_DEBUG))
			{
				mQueryLog->LogThis(LOG_DEBUG, (GetTransactionContext() + std::wstring((const wchar_t *)mSprocName)).c_str());

				// current setting of parameters
				ParametersPtr params = mCommand->GetParameters();
				//OraOLEDB throws DB_E_PARAMUNAVAIABLE in GetCount method for stored procedures
				//that have 0 parameters (Parameters collection was never initialized). call raw method
				//instead not to have to catch an error
				long count = 0;
				params->get_Count(&count);
				
				for (int paramnum = 0; paramnum < count; paramnum++)
				{
					_ParameterPtr param = params->GetItem((long) paramnum);
					DataTypeEnum type = param->GetType();
					long size = param->GetSize();
					long numericScale = param->GetNumericScale();
					long precision = param->GetPrecision();
					_bstr_t name = param->GetName();
					_variant_t value = param->GetValue();
					ParameterDirectionEnum direction = param->GetDirection();
					const char * directionString;
					switch (direction)
					{
					case adParamInput:
						directionString = "input"; break;
					case adParamOutput:
						directionString = "output"; break;
					case adParamInputOutput:
						directionString = "input/output"; break;
					case adParamReturnValue:
						directionString = "return"; break;
					default:
						directionString = "unknown"; break;
					}

					mQueryLog->LogVarArgs(LOG_DEBUG,
									" %s param: %s, type=%d, size=%d, scale=%d, precision=%d",
									directionString,
									(const char *) name, (int) type, size, numericScale,
									precision);
					if (direction == adParamInput || direction == adParamInputOutput)
					{
						if (V_VT(&value) == VT_NULL)
							mQueryLog->LogVarArgs(LOG_DEBUG, "  value: NULL");
						else
							mQueryLog->LogVarArgs(LOG_DEBUG, "  value: %s", (const char *) _bstr_t(value));
					}
				}
			}

      // execute the stored procedure ...

      // execute the stored proc.  
      // support provided for:
      // 1. a stored proc that returns a result set
      // 2. a proc with output params
      // but not both

      // find out if there are any output params
      ParametersPtr params = mCommand->GetParameters();
      long count = 0;
      params->get_Count(&count);

      bool bOutParams = false;

      for (long paramnum = 0; paramnum < count; paramnum++)
      {
        ParameterDirectionEnum dir = params->GetItem(paramnum)->GetDirection();
        if (dir == adParamOutput || dir == adParamInputOutput)
        {
          bOutParams = true;
          break;
        }
      }

      // if any out params specified then no result set
      if (bOutParams)
      {
        // don't ask for a rowset if you don't want one
        mCommand->Execute(NULL, NULL, adCmdStoredProc|adExecuteNoRecords);
      }
      else
      {
        // if oracle, tell the command that a rowset is expected
        if (mDBType == (_bstr_t) ORACLE_DATABASE_TYPE)
          mCommand->Properties->GetItem("PLSQLRSet")->PutValue(true);

        _RecordsetPtr &arRecordset = arRowset.GetRecordsetPtr();
        arRecordset = mCommand->Execute(NULL, NULL, adCmdStoredProc);
      }

      // remove association with the connection ...
      mCommand->PutRefActiveConnection(NULL);

			if (mQueryLog->IsOkToLog(LOG_DEBUG))
			{
				// output parameters
				ParametersPtr params = mCommand->GetParameters();
				for (int paramnum = 0; paramnum < params->GetCount(); paramnum++)
				{
					_ParameterPtr param = params->GetItem((long) paramnum);
					ParameterDirectionEnum direction = param->GetDirection();
					if (direction == adParamOutput || direction == adParamInputOutput)
					{
						DataTypeEnum type = param->GetType();
						long size = param->GetSize();
						long numericScale = param->GetNumericScale();
						long precision = param->GetPrecision();
						_bstr_t name = param->GetName();
						_variant_t value = param->GetValue();

						const char * directionString;
						switch (direction)
						{
						case adParamInput:
							directionString = "input"; break;
						case adParamOutput:
							directionString = "output"; break;
						case adParamInputOutput:
							directionString = "input/output"; break;
						case adParamReturnValue:
							directionString = "return"; break;
						default:
							directionString = "unknown"; break;
						}

						mQueryLog->LogVarArgs(LOG_DEBUG,
																	" %s param: %s, type=%d, size=%d, scale=%d, precision=%d",
																	directionString,
																	(const char *) name, (int) type, size, numericScale,
																	precision);
						if (V_VT(&value) == VT_NULL)
							mQueryLog->LogVarArgs(LOG_DEBUG,
																		"  value: NULL");
						else
							mQueryLog->LogVarArgs(LOG_DEBUG,
																		"  value: %s", (const char *) _bstr_t(value));
					}
				}
			}



    }
    catch (_com_error& e)
    {
      nRetVal = e.Error() ;

			char* buff;
			buff = new char[1024];
		  sprintf(buff, 
							"Unable to execute stored procedure <%s> with error description <%s>",
							(char*)mSprocName, 
							(char*)e.Description());
			SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "ExecuteStoredProc", buff);
      //mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      delete[] buff;
			bRetCode = FALSE ;

      std::wstring wstr;
      LISTADOERROR adoErrorList;
      LISTADOERROR::iterator iter;
      GetCOMError( e, adoErrorList, mConnection );
      for (iter = adoErrorList.begin(); iter != adoErrorList.end(); iter++) 
      {
        wstr = *iter;
#ifdef _DEBUG
        _tprintf(_T("%s\n"), wstr.c_str());
#endif
        // log the message ...
        mLogger->LogThis (LOG_ERROR, wstr.c_str()) ;
      }

			try
			{
				// current setting of parameters
				mLogger->LogThis(LOG_ERROR, "Current settings of parameters:");
				ParametersPtr params = mCommand->GetParameters();
				for (int paramnum = 0; paramnum < params->GetCount(); paramnum++)
				{
					_ParameterPtr param = params->GetItem((long) paramnum);
					DataTypeEnum type = param->GetType();
					long size = param->GetSize();
					long numericScale = param->GetNumericScale();
					long precision = param->GetPrecision();
					_bstr_t name = param->GetName();
					_variant_t value = param->GetValue();
					if (value.vt == VT_NULL)
						value = "NULL";

					mLogger->LogVarArgs(LOG_ERROR,
															" param: %s, type=%d, size=%d, scale=%d, precision=%d",
															(const char *) name, (int) type, size, numericScale,
															precision);
					mLogger->LogVarArgs(LOG_ERROR,
															"  value: %s", (const char *) _bstr_t(value));
				}

#if 0
				// refresh to get what the server thinks
				mCommand->GetParameters()->Refresh();

				mLogger->LogThis(LOG_ERROR, "Server's settings of parameters:");
				// dump the updated version
				params = mCommand->GetParameters();
				for (paramnum = 0; paramnum < params->GetCount(); paramnum++)
				{
					_ParameterPtr param = params->GetItem((long) paramnum);
					DataTypeEnum type = param->GetType();
					long size = param->GetSize();
					long numericScale = param->GetNumericScale();
					long precision = param->GetPrecision();
					_bstr_t name = param->GetName();
					mLogger->LogVarArgs(LOG_ERROR,
															" param: %s, type=%d, size=%d, scale=%d, precision=%d",
															(const char *) name, (int) type, size, numericScale,
															precision);
				}
#endif
			}
			catch (_com_error & err)
			{
				std::string buffer;
				StringFromComError(buffer, "Unable to log parameters", err);
				mLogger->LogThis(LOG_ERROR, buffer.c_str());
			}
    }
  }

  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL ADODBContext::GetParameterFromStoredProc (const std::wstring &arParamName, 
                                               _variant_t &arValue)
{
  // local variables
  BOOL bRetCode=TRUE ;
  _variant_t vtIndex ;
  _ParameterPtr pParam ;
  HRESULT nRetVal=S_OK ;

  // if we're not initialized for a stored procedure ...
  if (mProcInitialized == FALSE)
  {
    nRetVal = DB_ERR_NOT_INITIALIZED ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
      "GetParameterFromStoredProc") ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Unable to get parameter from stored procedure. Not initialized.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }
  else
  {
    try
    {
      // get the specified parameter from the command ...
      std::wstring param = arParamName;
	  if (0 == wcscmp(mDBType, L"{SQL Server}"))
        param.insert(0, L"@");
      
      vtIndex = param.c_str() ;
      pParam = mCommand->Parameters->GetItem(vtIndex) ;
      arValue = pParam->GetValue() ;

	  // If we get a MTEmptyString from Oracle then convert to true empty string.
	  if (arValue.vt != VT_NULL && mDBType == (_bstr_t) ORACLE_DATABASE_TYPE && MTEmptyString == (_bstr_t) arValue)
		arValue = _variant_t("");
    }
    catch (_com_error e)
    {
      nRetVal = e.Error() ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE, 
        "GetParameterFromStoredProc") ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to get parameter from stored procedure. Param = %s. Name = %s. Error Description = %s",
        arParamName.c_str(), (char*)mSprocName, (char*)e.Description()) ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      bRetCode = FALSE ;
      
      std::wstring wstr;
      LISTADOERROR adoErrorList;
      LISTADOERROR::iterator iter;
      GetCOMError( e, adoErrorList, mConnection );
      for (iter = adoErrorList.begin(); iter != adoErrorList.end(); iter++) 
      {
        wstr = *iter;
#ifdef _DEBUG
        _tprintf(_T("%s\n"), wstr.c_str());
#endif
        // log the message ...
        mLogger->LogThis (LOG_ERROR, wstr.c_str()) ;
      }
    }
  }

  return bRetCode ;
}

