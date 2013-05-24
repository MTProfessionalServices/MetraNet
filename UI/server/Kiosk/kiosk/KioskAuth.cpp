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
* $Header: C:\mt\development\UI\server\Kiosk\kiosk\KioskAuth.cpp, 63, 7/30/2002 9:48:57 AM, Derek Young$
* 
* 	KioskAuth.cpp : 
*	---------------
*	This is the implementation of the KioskAuth class.
*	This class expands on the functionality provided by the class 
*	CCOMKioskAuth by providing functionality to authenticate itself.
***************************************************************************/


// All the includes
// ADO includes
#include <StdAfx.h>
#include <metra.h>
#include <comdef.h>

// Local includes
#include <KioskAuth.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <stdutils.h>

#include <MTUtil.h>

// import the query adapter tlb
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace
#import <Rowset.tlb> rename ("EOF", "RowsetEOF")
#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.tlb> inject_statement("using namespace mscorlib;")

// static definition ...

// All the constants

// @mfunc CKioskAuth default constructor
// @parm 
// @rdesc This implementations is for the default constructor of the 
// Core Kiosk Auth class
DLL_EXPORT 
CKioskAuth::CKioskAuth():
mpQueryAdapter(NULL), mInitialized(FALSE)
{
}


// @mfunc CKioskAuth copy constructor
// @parm CKioskAuth& 
// @rdesc This implementations is for the copy constructor of the 
// Core Kiosk Auth class
DLL_EXPORT 
CKioskAuth::CKioskAuth(const CKioskAuth &c) 
{
  *this = c;
}

// @mfunc CKioskAuth assignment operator
// @parm 
// @rdesc This implementations is for the assignment operator of the 
// Core Kiosk Auth class
DLL_EXPORT const CKioskAuth& 
CKioskAuth::operator=(const CKioskAuth& rhs)
{
  // set the member attributes here
 	return ( *this );
}


// @mfunc CKioskAuth destructor
// @parm 
// @rdesc This implementations is for the destructor of the 
// Core Kiosk Auth class
DLL_EXPORT 
CKioskAuth::~CKioskAuth()
{
  if (mpQueryAdapter != NULL)
  {
    mpQueryAdapter->Release();
    mpQueryAdapter = NULL;
  }
}

// @mfunc Initialize
// @parm
// @rdesc This function is responsible for initializing the object
// by getting values from the database.   It creates the language
// request and does the connect to the database and executes the query.
// Returns true or false depending on whether the function succeeded
// or not.  
DLL_EXPORT BOOL 
CKioskAuth::Initialize()
{
  // local variables
  BOOL bOK = TRUE;
  _bstr_t configPath = PRES_SERVER_QUERY_PATH;
  const char* procName = "CKioskAuth::Initialize";
  
  mLock.Lock() ;
  
  // if we dont have a pointer to the query adapter 
  if (mpQueryAdapter == NULL)
  {
    // instantiate a query adapter object second
    try
    {
      // create the queryadapter ...
      IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
      
      // initialize the queryadapter ...
      queryAdapter->Init(configPath);
      
      // extract and detach the interface ptr ...
      mpQueryAdapter = queryAdapter.Detach();
    }
    catch (_com_error& e)
    {
      SetError(e.Error(), ERROR_MODULE, ERROR_LINE, procName, "Unable to initialize query adapter");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError());
      bOK = FALSE;
    }
  }
  
  if (bOK == TRUE)
  {
    mInitialized = TRUE ;
  }
  
  mLock.Unlock() ;
  
  return (bOK); 
}


//  @mfunc IsAuthentic 
//	@parm Login
//	@parm Pwd
//	@parm Name space
//	@rdesc Return a boolean value indicating whether the login/pwd
// 	combination is valid or not
DLL_EXPORT long 
CKioskAuth::IsAuthentic(const wchar_t* pLoginName, 
                        const wchar_t* pPwd,
                        const wchar_t* pName_Space)
{
  // local variables
  const char* procName = "CKioskAuth::IsAuthentic";
  
  // assert for null values
  ASSERT (pLoginName && pPwd && pName_Space);
  
  // Using the new security mechanism
  MetraTech_Security::IAuthPtr auth(__uuidof(MetraTech_Security::Auth));
  auth->Initialize(pLoginName, pName_Space);
  return auth->IsPasswordValid(pPwd) ? S_OK : E_FAIL;
}




// @mfunc AddUser
// @parm login
// @parm Pwd
// @parm name_space
// @rdesc Adds a new user to the database
DLL_EXPORT BOOL 
CKioskAuth::AddUser (const wchar_t* pLoginName,
                     const wchar_t* pPwd,
                     const wchar_t* pName_Space,
                     LPDISPATCH pRowset)
{
  const char* procName = "CKioskAuth::AddUser";
  
  // assert for null values
  ASSERT (pLoginName && pPwd && pName_Space);
  
  // lock the critical section ...
  wstring langRequest;
  BOOL bOK=TRUE ;
  
  // if we're not initialized ...
  if (mInitialized == FALSE)
  {
    mLogger->LogThis(LOG_ERROR, "Kiosk Auth object not initialized.");
    bOK = FALSE ;
  }
  else
  {
    // MD5 hash the password before inserting into the database
    // First we get the utf-8 version of the password since we cant send multi-bye to MD5 hash
    string rwPasswordToBeHashed;
    WideStringToUTF8(pPwd, rwPasswordToBeHashed);
    
    string rwHashedPassword;
    _bstr_t bstrHashedPassword;
    
    if (!rwPasswordToBeHashed.empty())
    {
      // Remove dependency on MTMiscUtil
      // FEAT-752 - Support active directory
      // Remove dependency on MetraTech_Security::PasswordManager
      MetraTech_Security::IAuthPtr auth;
      auth = new MetraTech_Security::IAuthPtr(__uuidof(MetraTech_Security::Auth));
      auth->Initialize(_bstr_t(pLoginName), _bstr_t(pName_Space));
      rwHashedPassword = auth->HashNewPassword(_bstr_t(rwPasswordToBeHashed.c_str()));

      bstrHashedPassword= rwHashedPassword.c_str();
    }
    else
    {
      bstrHashedPassword = _bstr_t();
    }

    // create and execute the query ...
    ROWSETLib::IMTSQLRowsetPtr pSQLRowset(pRowset) ;
    bOK = CreateAndExecuteQueryToAddUser(pLoginName, bstrHashedPassword, 
      pName_Space, pSQLRowset); 
    
  }
  
  return (bOK);
}

//	@mfunc CreateQueryToSetPwd
//  @parm  pwd
//  @rdesc Builds the query required for setting the pwd
void
CKioskAuth::CreateQueryToSetPwd(const wchar_t* pLoginName,
                                const wchar_t* pName_Space,
                                const wchar_t* pPwd,
                                wstring& langRequest)
{
  const char* procName = "CKioskAuth::CreateQueryToSetPwd";
  
  // assert for null values
  ASSERT (pLoginName && pPwd && pName_Space);
  
  // get the query
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  
  try
  {
    mpQueryAdapter->ClearQuery();
    queryTag = "__UPDATE_PASSWORD_PRESSERVER__";
    mpQueryAdapter->SetQueryTag(queryTag);
    
    vtParam = pLoginName;
    mpQueryAdapter->AddParam(MTPARAM_LOGINID, vtParam);
    
    vtParam = pName_Space;
    mpQueryAdapter->AddParam(MTPARAM_NAMESPACE, vtParam);
    
    vtParam = pPwd;
    mpQueryAdapter->AddParam(MTPARAM_PASSWORD, vtParam);
    
    langRequest = mpQueryAdapter->GetQuery();
  }
  catch (_com_error& e)
  {
    langRequest = L"" ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to get __UPDATE_PASSWORD_PRESSERVER__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
  
  return;
}

//	@mfunc CreateQueryToAddUser
// 	@parm  pLoginName
// 	@parm  pPwd
// 	@parm  pName_Space
//  @rdesc Builds the query required for initializing the kiosk Auth using
//	the provider ID.
void 
CKioskAuth::CreateQueryToAddUser (const wchar_t* pLoginName, 
                                  const wchar_t* pPwd, 
                                  const wchar_t* pName_Space,
                                  wstring& langRequest)
{
  const char* procName = "CKioskAuth::CreateQueryToAddUser"; 
  
  // assert for null values
  ASSERT (pLoginName && pPwd && pName_Space);
  
  // get the query
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  
  
  try
  {
    mpQueryAdapter->ClearQuery();
    queryTag = "__INSERT_USER_INFO__";
    mpQueryAdapter->SetQueryTag(queryTag);
    
    vtParam = pLoginName;
    mpQueryAdapter->AddParam(MTPARAM_LOGINID, vtParam);
    
    vtParam = pPwd;
    mpQueryAdapter->AddParam(MTPARAM_PASSWORD, vtParam);
    
    vtParam = pName_Space;
    mpQueryAdapter->AddParam(MTPARAM_NAMESPACE, vtParam);
    
    langRequest = mpQueryAdapter->GetQuery();
  }
  catch (_com_error& e)
  {
    langRequest = L"" ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to get __INSERT_USER_INFO__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
  
  return;
}

//
//
//
BOOL 
CKioskAuth::CreateAndExecuteQueryToAddUser (const wchar_t* pLoginName, 
                                            const wchar_t* pPwd, 
                                            const wchar_t* pName_Space,
                                            ROWSETLib::IMTSQLRowsetPtr &arRowset)
{
  const char* procName = "CKioskAuth::CreateAndExecuteQueryToAddUser"; 
  
  // assert for null values
  ASSERT (pLoginName && pPwd && pName_Space);
  
  // get the query
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  BOOL bRetCode=TRUE ;
  
  
  try
  {
    arRowset->ClearQuery();
    queryTag = "__INSERT_USER_INFO__";
    arRowset->SetQueryTag(queryTag);
    
    vtParam = pLoginName;
    arRowset->AddParam(MTPARAM_LOGINID, vtParam);
    
    vtParam = pPwd;
    arRowset->AddParam(MTPARAM_PASSWORD, vtParam);
    
    vtParam = pName_Space;
    arRowset->AddParam(MTPARAM_NAMESPACE, vtParam);
    
    arRowset->Execute() ;
  }
  catch (_com_error& e)
  {
    bRetCode = FALSE ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to get and execute __INSERT_USER_INFO__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
  
  return bRetCode;
}

//  @mfunc AccountExists 
//	@parm Login
//	@parm Pwd
//	@parm Name space
//	@rdesc Return a boolean value indicating whether the login/pwd
// 	combination is valid or not
DLL_EXPORT BOOL 
CKioskAuth::AccountExists(const wchar_t* pLoginName, 
													const wchar_t* pName_Space)
{
	// local variables
	BOOL bRetCode = FALSE;
	BOOL bFound = TRUE;
	const char* procName = "CKioskAuth::AccountExists";

	// assert for null values
	ASSERT (pLoginName && pName_Space);

	wstring buf;

	// instantiate a query adapter object 
	try
	{
		// if we're not initialized ...
		if (mInitialized == FALSE)
		{
			mLogger->LogThis(LOG_ERROR, "Kiosk Auth object not initialized.");
			bRetCode = FALSE ;
		}
		ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
		rs->Init(PRES_SERVER_QUERY_PATH) ;
		_variant_t vtParam;

		rs->SetQueryTag("__SELECT_ACCOUNT_EXISTS_PRESSERVER__");

		vtParam = pLoginName;
		rs->AddParam(MTPARAM_LOGINID, vtParam);

		vtParam = pName_Space;
		rs->AddParam(MTPARAM_NAMESPACE, vtParam);
		rs->Execute();
		// No rows found
		if (rs->GetRecordCount() == 0)
		{
			// exception made in this case value from this function
			buf = L"Hashed: No rows found in t_account_mapper table for login <";
			buf += pLoginName;
			buf += L"> and namespace <";
			buf += pName_Space;
			buf += L">"; 
			mLogger->LogThis (LOG_WARNING, buf.c_str());
			bRetCode = FALSE;
		}
		else
		{
			bRetCode = TRUE;
		}
	}
	catch (_com_error& e)
	{
		//MT_THROW_COM_ERROR(e);
		bRetCode = FALSE ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to execute __SELECT_ACCOUNT_EXISTS_PRESSERVER__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
	}

	return (bRetCode); 
}
