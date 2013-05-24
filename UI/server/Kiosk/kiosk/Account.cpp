/**************************************************************************
* @doc
* 
* Copyright 1998 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Raju Matta
* $Header$
* 
* 	Account.cpp : 
*	------------------
*	This is the implementation of the Account class.
*
***************************************************************************/


// All the includes
// ADO includes
#include <StdAfx.h>
#include <metra.h>
#include <comdef.h>
#include <adoutil.h>

// Local includes
#include <Account.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <stdutils.h>

// import the query adapter tlb
#import <QueryAdapter.tlb> no_namespace rename("GetUserName", "GetUserNameQA")

// All the constants

// @mfunc CAccount default constructor
// @parm 
// @rdesc This implementations is for the default constructor of the 
// Core Kiosk Gate class
DLL_EXPORT 
CAccount::CAccount() :
  mInitialized(FALSE), 
	mbActiveAccount(FALSE)
{
}


// @mfunc CAccount copy constructor
// @parm CAccount& 
// @rdesc This implementations is for the copy constructor of the 
// Core Kiosk Gate class
DLL_EXPORT 
CAccount::CAccount(const CAccount &c) 
{
    *this = c;
}

// @mfunc CAccount assignment operator
// @parm 
// @rdesc This implementations is for the assignment operator of the 
// Core Kiosk Gate class
DLL_EXPORT const CAccount&
CAccount::operator=(const CAccount& rhs)
{
    // set the member attributes here
  	mInitialized = rhs.mInitialized;
 	return ( *this );
}


// @mfunc CAccount destructor
// @parm 
// @rdesc This implementations is for the destructor of the 
// Core Kiosk Gate class
DLL_EXPORT 
CAccount::~CAccount()
{ }


// @mfunc Init
// @parm 
// @rdesc 
DLL_EXPORT BOOL
CAccount::Initialize()
{
  const char* procName = "CAccount::Initialize";
  
	configPath = PRES_SERVER_QUERY_PATH;

	// set the initialized flag ...
	mInitialized = TRUE;
  
	return (TRUE);
}

// @mfunc Add
// @parm LoginName
// @parm name_space
// @rdesc Returns the new account ID
DLL_EXPORT BOOL 
CAccount::Add (long aAccountStatus, LPDISPATCH &arpRowset, long& arAccountID)
{
  const char* procName = "CAccount::Add";
  
  // if were not initialized dont continue ...
  if (!mInitialized)
  {
    SetError(KIOSK_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, procName,
      "Account Object not initialized");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError());
    return (FALSE);
  }
  
  // locals..
  DBSQLRowset rowset;
  wstring langRequest;
  
  // assign the language request
  ROWSETLib::IMTSQLRowsetPtr pSQLRowset (arpRowset) ;
  BOOL bRetCode = CreateAndExecuteQueryToAddAccount (aAccountStatus, pSQLRowset) ;

  // get the value from the stored procedure ...
  _variant_t vtValue = pSQLRowset->GetParameterFromStoredProc ("id_acc") ;
  arAccountID = vtValue.lVal ;
  
  mLogger->LogThis (LOG_DEBUG, "Account successfully added to the t_account table");
  
  return (TRUE);
}

// @mfunc Update
// @rdesc Updates the t_account table
DLL_EXPORT BOOL 
CAccount::Update (const wstring& arLogin, 
				  const wstring& arNamespace, 
				  const wstring& arAccountEndDate, 
				  const long& alAccountStatus)
{
  const char* procName = "CAccount::Update";
  
  // if were not initialized dont continue ...
  if (!mInitialized)
  {
    SetError(KIOSK_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, procName,
      "Account Object not initialized");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError());
    return (FALSE);
  }
  
  // locals..
  wstring langRequest;
  
  CreateQueryToUpdateAccount(arLogin, arNamespace,
							 arAccountEndDate, 
							 alAccountStatus, langRequest);
  

	DBAccess dbaccess;
	// initialize the database access layer ...
	if (!dbaccess.Init((const wchar_t *)configPath))
  {
	    SetError(dbaccess);
		mLogger->LogThis(LOG_ERROR,
						"Database initialization failed for Account object");
		return FALSE;
	}

	BOOL success = TRUE;
  // execute the language request
  if (!dbaccess.Execute(langRequest))
  {
    SetError(dbaccess);
    mLogger->LogThis(LOG_ERROR, "Database execution failed for updating account");
		success = FALSE;
  }

	// disconnect from the database
	if (!dbaccess.Disconnect())
	{
	    SetError(dbaccess);
    	mLogger->LogThis(LOG_ERROR,
						"Database disconnect failed for Account Mapper");
	}

		if (!success)
			return FALSE;

  mLogger->LogThis (LOG_DEBUG, "Account successfully updated");
  
  return (TRUE);
}



//	@mfunc CreateQueryToUpdateAccount
//  @parm
//  @rdesc 
void 
CAccount::CreateQueryToUpdateAccount(const wstring& arLogin, 
									 const wstring& arNamespace,
									 const wstring& arAccountEndDate,
									 const long& alAccountStatus,
									 wstring& langRequest)
{
    // locals
	const char* procName = "CAccount::CreateQueryToUpdateAccount";
  
  	// get the query
	_bstr_t queryTag;
  	_bstr_t queryString;
  	_variant_t vtParam;
  	
  	try
  	{
			// create the queryadapter ...
			IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
    
			// initialize the queryadapter ...
			queryAdapter->Init((const wchar_t *) configPath);

    	queryAdapter->ClearQuery();
    	queryTag = "__UPDATE_ACCOUNT__";
    	queryAdapter->SetQueryTag(queryTag);
    	
		vtParam = arLogin.c_str();
		queryAdapter->AddParam(MTPARAM_LOGINID, vtParam);

		vtParam = arNamespace.c_str();
		queryAdapter->AddParam(MTPARAM_NAMESPACE, vtParam);

        // do some special stuff here for oracle
		_bstr_t dbtype = queryAdapter->GetDBType();
		_bstr_t bstrAccountEndDate;

		// if the value is not NULL, do the following:
		// 1) if db type is ORACLE, then replace bstrAccountEndDate 
		//    with 'TO_DATE('%%ACCOUNT_END_DATE%%', 'MM/DD/YYYY')', 
		//    else replace bstrAccountEndDate with 
		//    the ' actual end date '
		// if value is NULL, then just pass the NULL string 
		if (0 != mtwcscasecmp(arAccountEndDate.c_str(), L"NULL"))
		{
            if (0 == _wcsicmp(dbtype, ORACLE_DATABASE_TYPE))
            {
                bstrAccountEndDate = L"TO_DATE('";
			    bstrAccountEndDate += arAccountEndDate.c_str();
                bstrAccountEndDate += L"', 'MM/DD/YYYY')";

            }
		    else
		    {
			    bstrAccountEndDate = L"'";
			    bstrAccountEndDate += arAccountEndDate.c_str();
			    bstrAccountEndDate += L"'";
			}
			queryAdapter->AddParam(MTPARAM_ACCOUNTENDDATE, 
			                         bstrAccountEndDate, 
			                         VARIANT_TRUE);
		}
		else
		{
			vtParam = arAccountEndDate.c_str();
			queryAdapter->AddParam(MTPARAM_ACCOUNTENDDATE, vtParam);
		}

		vtParam = alAccountStatus;
		queryAdapter->AddParam(MTPARAM_ACCOUNTSTATUS, vtParam);

    	langRequest = queryAdapter->GetQuery();
  	}
  	catch (_com_error& e)
  	{
    	langRequest = L"";
    	SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName , 
				  "Unable to get __UPDATE_ACCOUNT__ query");
    	mLogger->LogErrorObject(LOG_ERROR, GetLastError());
  	}
  
  	
  	return;
}

BOOL 
CAccount::CreateAndExecuteQueryToAddAccount(const long& arStatusID,
                                            ROWSETLib::IMTSQLRowsetPtr &arRowset)
{
  // locals
  HRESULT hOK = S_OK;
  const char* procName = "CAccount::CreateAndExecuteQueryToAddAccount";
  
  // get the query
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  BOOL bRetCode=TRUE ;
  
  try
  {
    // initialize the stored procedure ...
    arRowset->InitializeForStoredProc ("InsertAccount") ;

    // add the parameters ...
    vtParam = arStatusID;
    arRowset->AddInputParameterToStoredProc("id_status", MTTYPE_INTEGER, INPUT_PARAM, vtParam) ;
    arRowset->AddOutputParameterToStoredProc("id_acc", MTTYPE_INTEGER, OUTPUT_PARAM) ;

    // execute the stored procedure ...
    arRowset->ExecuteStoredProc() ;
  }
  catch (_com_error e)
  {
    bRetCode = FALSE;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName , 
				  "Unable to get and execute  __INSERT_ACCOUNT__ query");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError());
  }
  
  return bRetCode ;
}


// @mfunc GetAccountInfo
// @parm 
// @rdesc 
DLL_EXPORT long
CAccount::GetAccountInfo(const wstring &arLoginName, 
						 const wstring &arNameSpace)
{
  string buffer;
  long returncode = 0;

  const char* procName = "CAccount::GetAccountInfo";

  // if were not initialized dont continue ...
  if (!mInitialized)
  {
	buffer = "Account Mapper not initialized";
    SetError(KIOSK_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, procName,
			 buffer.c_str());
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return (FALSE) ;
  }

  // local variables
  wstring langRequest;
  DBSQLRowset rowset;

	CreateQueryToGetAccountInfo(arLoginName, arNameSpace, langRequest);
  
	DBAccess dbaccess;
	// initialize the database access layer ...
	if (!dbaccess.Init((const wchar_t *)configPath))
  {
	    SetError(dbaccess);
		mLogger->LogThis(LOG_ERROR,
						"Database initialization failed for Account object");
		return (FALSE);
	}

	BOOL success = TRUE;
  // execute the language request
  if (!dbaccess.Execute(langRequest, rowset))
  {
    SetError(dbaccess);
    mLogger->LogThis(LOG_ERROR, "Database execution failed");
		success = FALSE;
  }
  
 	// disconnect from the database
    if (!dbaccess.Disconnect())
  	{
	    SetError(dbaccess);
    	mLogger->LogThis(LOG_ERROR,
						"Database disconnect failed for Account Mapper");
	}

		if (!success)
    return (-1);

  // If no rows found -- return -99
  // If more than one row found -- return -100
  // If success -- return 0
  // If failure -- return -1
  if (rowset.GetRecordCount() == 0)
  {
	buffer = "Account not found in database for login <";
	buffer += (const char*) _bstr_t(arLoginName.c_str());
	buffer += "> and namespace <";
	buffer += (const char*) _bstr_t(arNameSpace.c_str());
	buffer += ">";
    SetError(KIOSK_ERR_ACCOUNT_NOT_FOUND, 
			 ERROR_MODULE, 
			 ERROR_LINE, 
			 procName,
			 buffer.c_str());
    mLogger->LogThis (LOG_WARNING, buffer.c_str()); 
    return (-99);
  }
  else if (rowset.GetRecordCount() > 1)
  {
	buffer = "More than one account was found in database for login <";
	buffer += (const char*) _bstr_t(arLoginName.c_str());
	buffer += "> and namespace <";
	buffer += (const char*) _bstr_t(arNameSpace.c_str());
	buffer += ">";
    SetError(KIOSK_ERR_MORE_THAN_ONE_ACC, 
			 ERROR_MODULE, 
			 ERROR_LINE, 
			 procName,
			 buffer.c_str());
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return (-100);
  }
  else
  {
    rowset.GetLongValue(_variant_t(ACCOUNT_ID_STR), mAccountID);
    rowset.GetValue(_variant_t(START_DATE_STR), mStartDate);
    rowset.GetValue(_variant_t(END_DATE_STR), mEndDate);
		rowset.GetWCharValue(_variant_t(CURRENCY_STR), mCurrency);
    rowset.GetLongValue(_variant_t(ACCOUNT_USAGE_CYCLE_ID_STR), mAccountCycleID);	

	//set bActiveAccountFlag flag: if mEndDate == NULL, then account is active
	//otherwise it has expired
	SetActiveFlag();
  }
  return (0); 
}


// @mfunc GetAccountInfo
// @parm account ID 
// @rdesc 
DLL_EXPORT long
CAccount::GetAccountInfo(long arAccountID)
{
  long returncode = 0;
  const char* procName = "CAccount::GetAccountInfo";

  // if were not initialized dont continue ...
  if (!mInitialized)
  {
    SetError(KIOSK_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, procName,
      "Account Mapper not initialized") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return (-1) ;
  }

  // local variables
  wstring langRequest;
  DBSQLRowset rowset;
  
  CreateQueryToGetAccountInfo(arAccountID, langRequest);
  
	// initialize the database access layer ...
	DBAccess dbaccess;
	if (!dbaccess.Init((const wchar_t *)configPath))
  {
	    SetError(dbaccess);
		mLogger->LogThis(LOG_ERROR,
						"Database initialization failed for Account object");
		return (FALSE);
	}

	BOOL success = TRUE;
  // execute the language request
  if (!dbaccess.Execute(langRequest, rowset))
  {
    SetError(dbaccess);
    mLogger->LogThis(LOG_ERROR, "Database execution failed for Account Mapper");
		success = FALSE;
  }
  
 	// disconnect from the database
    if (!dbaccess.Disconnect())
  	{
	    SetError(dbaccess);
    	mLogger->LogThis(LOG_ERROR,
						"Database disconnect failed for Account Mapper");
	}

		if (!success)
			return (-1);

  //If no rows found
  string buffer;

  // store the account ID in a buffer
  string rwAccountID;
  char accountID[10];
  ltoa(arAccountID,accountID,10);
  rwAccountID = accountID;

  // If no rows found -- return -99
  // If more than one row found -- return -100
  // If success -- return 0
  // If failure -- return -1
  if (rowset.GetRecordCount() == 0)
  {
	buffer = "Account not found in database for account ID <";
	buffer += rwAccountID;
	buffer += ">";
    SetError(KIOSK_ERR_ACCOUNT_NOT_FOUND, 
			 ERROR_MODULE, 
			 ERROR_LINE, 
			 procName, 
			 buffer.c_str()) ;
    mLogger->LogThis (LOG_WARNING, buffer.c_str());
    return (-99);
  }
  else if (rowset.GetRecordCount() > 1)
  {
	buffer = "More than one account was found for accountID <" + 
	  rwAccountID + ">";
    SetError(KIOSK_ERR_MORE_THAN_ONE_ACC, 
			 ERROR_MODULE, 
			 ERROR_LINE, 
			 procName,
			 buffer.c_str());
    mLogger->LogVarArgs (LOG_ERROR, buffer.c_str()); 
    return (-100);
  }
  else
  {
    rowset.GetLongValue(_variant_t(ACCOUNT_ID_STR), mAccountID);
    rowset.GetValue(_variant_t(START_DATE_STR), mStartDate);
    rowset.GetValue(_variant_t(END_DATE_STR), mEndDate);
		rowset.GetWCharValue(_variant_t(CURRENCY_STR), mCurrency);
    rowset.GetLongValue(_variant_t(ACCOUNT_USAGE_CYCLE_ID_STR), mAccountCycleID);

	//set bActiveAccountFlag flag: if mEndDate == NULL, then account is active
	//otherwise it has expired
	SetActiveFlag();
  }
  return (0); 
}

//	@mfunc CreateQueryToGetAccountInfo
// 	@parm  pLoginName
//  @rdesc 
void 
CAccount::CreateQueryToGetAccountInfo (const wstring &arLoginName,
									 const wstring &arNameSpace,
									 wstring& langRequest)
{
  const char* procName = "CAccount::CreateQueryToGetAccountInfo"; 
  // get the query
  _bstr_t queryTag;
  _bstr_t queryString;
  
  try
  {
    // create the queryadapter ...
    IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
    
    // initialize the queryadapter ...
    queryAdapter->Init((const wchar_t *) configPath);

    queryAdapter->ClearQuery();
    queryTag = "__SELECT_ACCOUNT_INFO__";
    queryAdapter->SetQueryTag(queryTag);
    
    // store the values as variants first
    _variant_t vtParam;
    vtParam = arLoginName.c_str() ;
    queryAdapter->AddParam(MTPARAM_LOGINID, vtParam);
    
    vtParam = arNameSpace.c_str();
    queryAdapter->AddParam(MTPARAM_NAMESPACE, vtParam);
    
    langRequest = queryAdapter->GetQuery();
  }
  catch (_com_error e)
  {
    langRequest = L"" ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
      "CAccount::CreateQueryToGetAccountID", 
      "Unable to get __SELECT_ACCOUNT_INFO__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
  
  return;
}

//	@mfunc CreateQueryToGetAccountInfo
// 	@parm  pLoginName
//  @rdesc 
void 
CAccount::CreateQueryToGetAccountInfo (long arAccountID,
									   wstring& langRequest)
{
  const char* procName = "CAccount::CreateQueryToGetAccountInfo"; 

  // get the query
  _bstr_t queryTag;
  _bstr_t queryString;
  string buffer;
  
  try
  {
    // create the queryadapter ...
    IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
    
    // initialize the queryadapter ...
    queryAdapter->Init((const wchar_t *) configPath);

    queryAdapter->ClearQuery();
    queryTag = "__SELECT_ACCOUNT_INFO_WITH_ACCOUNT_ID__";
    queryAdapter->SetQueryTag(queryTag);
    
    // store the values as variants first
    _variant_t vtParam;
    vtParam = arAccountID ;
    queryAdapter->AddParam(MTPARAM_ACCOUNTID, vtParam);
    
    langRequest = queryAdapter->GetQuery();
  }
  catch (_com_error e)
  {
	
    langRequest = L"" ;
	buffer = "Unable to get __SELECT_ACCOUNT_INFO_WITH_ACCOUNT_ID__ query";
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName, buffer.c_str());
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
  
  return;
}


DLL_EXPORT 
BOOL CAccount::IsActiveAccount()
{
	return mbActiveAccount;
}


void CAccount::SetActiveFlag()
{
	mbActiveAccount = (VT_NULL == mEndDate.vt) ? TRUE : FALSE;
}
