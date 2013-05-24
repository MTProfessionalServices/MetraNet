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
* 	AccountMapper.cpp : 
*	------------------
*	This is the implementation of the AccountMapper class.
*
***************************************************************************/


// All the includes
// ADO includes
#include <StdAfx.h>
#include <metra.h>
#include <comdef.h>
#include <adoutil.h>

// Local includes
#include <AccountMapper.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <stdutils.h>

// import the query adapter tlb
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

// All the constants

// @mfunc CAccountMapper default constructor
// @parm 
// @rdesc This implementations is for the default constructor of the 
// Core Kiosk Gate class
DLL_EXPORT 
CAccountMapper::CAccountMapper() :
mpQueryAdapter(NULL), mInitialized(FALSE)
{
}


// @mfunc CAccountMapper copy constructor
// @parm CAccountMapper& 
// @rdesc This implementations is for the copy constructor of the 
// Core Kiosk Gate class
DLL_EXPORT 
CAccountMapper::CAccountMapper(const CAccountMapper &c) 
{
  *this = c;
}

// @mfunc CAccountMapper assignment operator
// @parm 
// @rdesc This implementations is for the assignment operator of the 
// Core Kiosk Gate class
DLL_EXPORT const CAccountMapper&
CAccountMapper::operator=(const CAccountMapper& rhs)
{
  // set the member attributes here
  mInitialized= rhs.mInitialized;
  
 	return ( *this );
}


// @mfunc CAccountMapper destructor
// @parm 
// @rdesc This implementations is for the destructor of the 
// Core Kiosk Gate class
DLL_EXPORT 
CAccountMapper::~CAccountMapper()
{
  // tear down all the previously allocated memory ...
  TearDown();
}

void CAccountMapper::TearDown()
{
  if (mpQueryAdapter != NULL)
  {
    mpQueryAdapter->Release();
    mpQueryAdapter = NULL;
  }

  mInitialized = FALSE;
}

// @mfunc Init
// @parm 
// @rdesc 
DLL_EXPORT BOOL
CAccountMapper::Initialize()
{
  mLock.Lock();
  BOOL bOK=TRUE;
  _bstr_t configPath = PRES_SERVER_QUERY_PATH;

  // if we dont have a pointer to the query adapter 
  if (mpQueryAdapter == NULL)
  {
    // initialize query adapter object
    try
    {
      // create the queryadapter ...
      IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
      
      // initialize the queryadapter ...
      queryAdapter->Init(configPath);
      
      // extract and detach the interface ptr ...
      mpQueryAdapter = queryAdapter.Detach();
    }
    catch (_com_error e)
    {
      SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "CAccountMapper::Initialize",
        "Unable to initialize query adapter");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError());
      bOK = FALSE;
    }
  }

  mInitialized = TRUE;

  mLock.Unlock();
  
  return bOK;
}

// @mfunc Add
// @parm LoginName
// @parm name_space
// @rdesc Returns the new account ID

//Leave this one alone, because it's also used from
// an exe
DLL_EXPORT BOOL 
CAccountMapper::Add (	const wstring &arLoginName,
											const wstring &arNameSpace,
											long arAccountID, 
											LPDISPATCH pRowset,
											long& arReturnCode)
{
  BOOL bOK=TRUE;
  BOOL isModify=FALSE;

  // if were not initialized dont continue ...
  if (mInitialized == FALSE)
  {
    SetError(KIOSK_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "CAccountMapper::Add",
      "Account Mapper not initialized");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError());
    bOK = FALSE;
  }
  else
  {
    // create and execute the query ...
    ROWSETLib::IMTSQLRowsetPtr pSQLRowset (pRowset);
    bOK = CreateAndExecuteQueryToAddAccountMapper(arLoginName, 
      arNameSpace, arAccountID, isModify, pSQLRowset); 
  }

  return (bOK);
}

/*
Used to add, update, delete account mapping information
*/
DLL_EXPORT BOOL 
CAccountMapper::Modify(long& arReturnCode,
											const int ActionType, /*0 add, 1 update,2 delete*/
											BSTR LoginName,
											BSTR NameSpace,
											BSTR NewLoginName,
											BSTR NewNameSpace, 
											LPDISPATCH pRowSet)
{
	BOOL bOK=TRUE;
  BOOL isModify=TRUE;
	const char* procName = "CAccountMapper::Modify";


	_bstr_t bstrLoginName = _bstr_t(LoginName);
	_bstr_t bstrNameSpace = _bstr_t(NameSpace);
	_bstr_t bstrNewLoginName = _bstr_t(NewLoginName);
	_bstr_t bstrNewNameSpace = _bstr_t(NewNameSpace);

	wstring rwLoginName = wstring((const wchar_t*)bstrLoginName);
	wstring rwNameSpace = wstring((const wchar_t*)bstrNameSpace);
	wstring rwNewLoginName = wstring((const wchar_t*)bstrNewLoginName);
	wstring rwNewNameSpace = wstring((const wchar_t*)bstrNewNameSpace);
  wstring buffer ;

  // if were not initialized dont continue ...
  if (mInitialized == FALSE)
  {
    SetError(KIOSK_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "CAccountMapper::Modify",
      "Account Mapper not initialized");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError());
    bOK = FALSE;
  }
  else
  {
    // create and execute the query ...
    ROWSETLib::IMTSQLRowsetPtr pSQLRowset (pRowSet);
    long aAccountID = 0 ;

    try
    {
      // see if there is a mapping for the login and namespace ...
      pSQLRowset->SetQueryTag ("__SELECT_ACCOUNT_ID_PRESSERVER__") ;
      
      // add the parameters ...
      _variant_t vtParam = rwLoginName.c_str() ;
      pSQLRowset->AddParam (MTPARAM_LOGINID, vtParam) ;
      vtParam = rwNameSpace.c_str() ;
      pSQLRowset->AddParam (MTPARAM_NAMESPACE, vtParam) ;
      
      // execute the query ...
      pSQLRowset->Execute() ;
      
      // if we couldnt find the account id ...
      if (pSQLRowset->GetRecordCount() == 0)
      {
        // account not found in account tables
        buffer = L"Modify account mapping failed. Account not found for login <";
        buffer += rwLoginName;
        buffer += L"> and namespace <";
        buffer += rwNameSpace;
        buffer += L">"; 
        mLogger->LogThis (LOG_ERROR, buffer.c_str());
		SetError(ACCOUNTMAPPER_ERR_INVALID_ACCOUNTMAPPING, ERROR_MODULE, ERROR_LINE, procName, ascii(buffer).c_str());

        return FALSE ;
      }
      
      // get the account id ...
      aAccountID = pSQLRowset->GetValue ("id_acc") ;
    }
    catch (_com_error &e)
    {
      SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
        "CAccountMapper::Modify", 
        "Unable to execute __SELECT_ACCOUNT_ID_PRESSERVER__ query");
      mLogger->LogErrorObject(LOG_ERROR, GetLastError());
      mLogger->LogVarArgs (LOG_ERROR, "Modify() failed. Error Description = %s",
        (char*) e.Description());
      return FALSE ;
    }

    // switch on the case ...
    switch (ActionType)
    {
    case ADD_ACCOUNT_MAPPING:
      bOK = CreateAndExecuteQueryToAddAccountMapper(rwNewLoginName, 
        rwNewNameSpace, aAccountID, isModify, pSQLRowset); 
      break;

    case UPDATE_ACCOUNT_MAPPING:
      bOK = CreateAndExecuteQueryToUpdateAccountMapping(rwLoginName, rwNameSpace, 
        rwNewLoginName, rwNewNameSpace, pSQLRowset); 
      break;

    case DELETE_ACCOUNT_MAPPING:
      bOK = CreateAndExecuteQueryToDeleteAccountMapping(rwLoginName, 
        rwNameSpace, pSQLRowset); 
      break;

    default:
      mLogger->LogVarArgs (LOG_ERROR,
          "Invalid action type for Account Mapping. Action Type = %s", ActionType);
      bOK = FALSE ;
      break;
    }
  }

  return (bOK);
}											

BOOL 
CAccountMapper::CreateAndExecuteQueryToAddAccountMapper (const wstring &arLoginName, 
                                                         const wstring &arNameSpace,
                                                         const long &arAccountID,
                                                         BOOL isModify,
                                                         ROWSETLib::IMTSQLRowsetPtr &arRowset)
{
  // locals
  const char* procName = 
		"CAccountMapper::CreateAndExecuteQueryToAddAccountMapper";

  HRESULT hr = S_OK;

  // check if the account exists
  hr = DoesMappingExist(arLoginName, arNameSpace, arRowset);
	if (FAILED(hr))
	{
		// NEW Mapping already exists.
  	if(hr == ACCOUNTMAPPER_ERR_ALREADY_EXISTS)
		{
			SetError(ACCOUNTMAPPER_ERR_ALREADY_EXISTS, ERROR_MODULE, ERROR_LINE, 
							 procName);
			return FALSE;
		}
		// NEW Mapping does not exist.  Continue.
		else if (hr == ACCOUNTMAPPER_ERR_DOES_NOT_EXIST)
			;
		else
			return FALSE;
	}

	// check to see if namespace is valid
	hr = IsNameSpaceValid(arNameSpace, arRowset);
  if(FAILED(hr))
	{
  	// namespace does not exist
  	if(hr == ACCOUNTMAPPER_ERR_NAMESPACE_DOES_NOT_EXIST)
		{
	  	SetError(ACCOUNTMAPPER_ERR_NAMESPACE_DOES_NOT_EXIST, 
							 ERROR_MODULE, ERROR_LINE, procName);
	  	return FALSE;
  	}
		else
	  	return FALSE;
	}
  
  // get the query
  //_bstr_t queryTag;
  //_bstr_t queryString;
  _variant_t vtParam;
  BOOL bRetCode=TRUE;
  
  try
  {
    // set the query tag ...
    if (isModify)
    {
      arRowset->SetQueryTag ("__INSERT_ACCOUNT_MAPPER_INFO_PRESSERVER__");
    }
    else
    {
      arRowset->SetQueryTag ("__INSERT_ACCOUNT_MAPPER_INFO_PRESSERVER__");
    }

    // add the parameters ...
    vtParam = arLoginName.c_str();
    arRowset->AddParam(MTPARAM_LOGINID, vtParam);
    vtParam = arNameSpace.c_str();
    arRowset->AddParam(MTPARAM_NAMESPACE, vtParam);
    vtParam = arAccountID;
    arRowset->AddParam(MTPARAM_ACCOUNTID, vtParam);

    // execute the stored procedure ...
    arRowset->Execute();
  }
  catch (_com_error e)
  {
    bRetCode = FALSE;
    _bstr_t strQueryTag;
    
    if (isModify)
    {
      strQueryTag = "Unable to execute __INSERT_ACCOUNT_MAPPER_INFO_PRESSERVER__ query";
    }
    else
    {
      strQueryTag = "Unable to execute __INSERT_ACCOUNT_MAPPER_INFO_PRESSERVER__ query";
    }


    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
      "CAccountMapper::CreateAndExecuteQueryToAddAccountMapper", 
      strQueryTag);
    mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		mLogger->LogVarArgs (LOG_ERROR, "CreateAndExecuteQueryToAddAccountMapper() failed. Error Description = %s",
			(char*) e.Description());
  }
  
  return bRetCode;
}

//
//
//
BOOL 
CAccountMapper::CreateAndExecuteQueryToUpdateAccountMapping (
	const wstring &arLoginName, 
  const wstring &arNameSpace,
  const wstring &arNewLoginName, 
  const wstring &arNewNameSpace,
  ROWSETLib::IMTSQLRowsetPtr &arRowset)
{
  // locals
  const char* procName = 
		"CAccountMapper::CreateAndExecuteQueryToUpdateAccountMapping";

  HRESULT hr = S_OK;

	// check if the old mapping exists
  hr = DoesMappingExist(arLoginName, arNameSpace, arRowset);
	if (hr == ACCOUNTMAPPER_ERR_DOES_NOT_EXIST)
	{
		// old Mapping does not exist.  error
  	SetError(ACCOUNTMAPPER_ERR_DOES_NOT_EXIST, ERROR_MODULE, ERROR_LINE, 
							 procName);
		return FALSE;
	}
	else if(hr != ACCOUNTMAPPER_ERR_ALREADY_EXISTS)
		return FALSE;

	// check if the new mapping exists
  hr = DoesMappingExist(arNewLoginName, arNewNameSpace, arRowset);
  
	if(hr == ACCOUNTMAPPER_ERR_ALREADY_EXISTS)
	{
		SetError(ACCOUNTMAPPER_ERR_ALREADY_EXISTS, ERROR_MODULE, ERROR_LINE, 
						 procName);
		return FALSE;
	}
	else if(hr != ACCOUNTMAPPER_ERR_DOES_NOT_EXIST)
		return FALSE;
	
  hr = IsNameSpaceValid(arNewNameSpace, arRowset);
  if(FAILED(hr))
	{
  	// namespace does not exist
  	if(hr == ACCOUNTMAPPER_ERR_NAMESPACE_DOES_NOT_EXIST)
		{
	  	SetError(ACCOUNTMAPPER_ERR_NAMESPACE_DOES_NOT_EXIST, 
							 ERROR_MODULE, ERROR_LINE, procName);
	  	return FALSE;
  	}
		else
	  	return FALSE;
	}

  _variant_t vtParam;
  BOOL bRetCode=TRUE;
  
  
  try
  {
    // set the query tag ...
    arRowset->SetQueryTag ("__UPDATE_ACCOUNT_MAPPER_INFO__");

    // add the parameters ...
    vtParam = arLoginName.c_str();
    arRowset->AddParam(MTPARAM_LOGINID, vtParam);
    vtParam = arNameSpace.c_str();
    arRowset->AddParam(MTPARAM_NAMESPACE, vtParam);
    vtParam = arNewLoginName.c_str();
    arRowset->AddParam(MTPARAM_NEWLOGINID, vtParam);
    vtParam = arNewNameSpace.c_str();
    arRowset->AddParam(MTPARAM_NEWNAMESPACE, vtParam);

    // execute the stored procedure ...
    arRowset->Execute();
  }
  catch (_com_error e)
  {
    bRetCode = FALSE;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
      "CAccountMapper::CreateAndExecuteQueryToUpdateAccountMapping", 
      "Unable to execute __UPDATE_ACCOUNT_MAPPER_INFO__ query");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		mLogger->LogVarArgs (LOG_ERROR, "CreateAndExecuteQueryToUpdateAccountMapping() failed. Error Description = %s",
			(char*) e.Description());
  }
  
  return bRetCode;
}

BOOL 
CAccountMapper::CreateAndExecuteQueryToDeleteAccountMapping (const wstring &arLoginName, 
                                                             const wstring &arNameSpace,
                                                             ROWSETLib::IMTSQLRowsetPtr &arRowset)
{
// locals
  const char* procName = "CAccountMapper::CreateAndExecuteQueryToDeleteAccountMapping";

  HRESULT hr = S_OK;

  hr = DoesMappingExist(arLoginName, arNameSpace, arRowset);
  if(hr != ACCOUNTMAPPER_ERR_ALREADY_EXISTS)
	{
	  SetError(hr, ERROR_MODULE, ERROR_LINE, procName);
	  return FALSE;
  }

  _variant_t vtParam;
  BOOL bRetCode=TRUE;
  
  try
  {
    // set the query tag ...
    arRowset->SetQueryTag ("__DELETE_ACCOUNT_MAPPER_INFO__");

    // add the parameters ...
    vtParam = arLoginName.c_str();
    arRowset->AddParam(MTPARAM_LOGINID, vtParam);
    vtParam = arNameSpace.c_str();
    arRowset->AddParam(MTPARAM_NAMESPACE, vtParam);

    // execute the stored procedure ...
    arRowset->Execute();
  }
  catch (_com_error e)
  {
    bRetCode = FALSE;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
      "CAccountMapper::CreateAndExecuteQueryToDeleteAccountMapping", 
      "Unable to execute __DELETE_ACCOUNT_MAPPER_INFO__ query");
    mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		mLogger->LogVarArgs (LOG_ERROR, "CreateAndExecuteQueryToDeleteAccountMapping() failed. Error Description = %s",
			(char*) e.Description());
  }
  
  return bRetCode;
}


BOOL
CAccountMapper::MapAccountIdentifier(
							const wstring &arSourceName_Space,
							const wstring &arSourceIdentifier,
							const wstring &arDestinationName_Space,
							wstring &arDestinationIdentifier,
							long& arReturnCode)
{

  const char* procName = "CAccountMapper::MapAccountIdentifier";
  
  //arDestinationIdentifier=L"demo";
  //return TRUE;
  arDestinationIdentifier=L"";

  BOOL bRetCode = TRUE;
  
  // get the query
  _bstr_t queryTag = "__MAP_ACCOUNT_IDENTIFIER_TO_ALTERNATE_NAMESPACE_PRESSERVER__";
	_variant_t vtParam;
	wstring sRequest;
	DBSQLRowset rowset;

 	try
 	{
	  mpQueryAdapter->ClearQuery();
	  mpQueryAdapter->SetQueryTag(queryTag);
	  
	  // add parameters
	  vtParam = arSourceIdentifier.c_str();
	  mpQueryAdapter->AddParam(L"%%FROM_ACCOUNT_ID%%", vtParam);

 	  vtParam = arSourceName_Space.c_str();
	  mpQueryAdapter->AddParam(L"%%FROM_NAMESPACE%%", vtParam);

 	  vtParam = arDestinationName_Space.c_str();
	  mpQueryAdapter->AddParam(L"%%TO_NAMESPACE%%", vtParam);

	  // get query
	  sRequest = mpQueryAdapter->GetQuery();
 	}
  catch (_com_error& e)
  {
    	SetError(e.Error(), ERROR_MODULE, ERROR_LINE, procName,
			 	"Unable to get __MAP_ACCOUNT_IDENTIFIER_TO_ALTERNATE_NAMESPACE_PRESSERVER__ query.");
    	mLogger->LogErrorObject (LOG_ERROR, GetLastError());
    	bRetCode = FALSE;
  }

  if (!bRetCode)
  {
    return bRetCode;
  }

	DBAccess dbaccess;

	// init
	if (!dbaccess.Init((const wchar_t*)PRES_SERVER_CONFIG_PATH))
	{
		SetError(DBAccess::GetLastError());
		mLogger->LogThis(LOG_ERROR, 
										 "Database initialization failed for Account Mapper");
    return (FALSE);
	}

	// execute 
  if (!dbaccess.Execute(sRequest, rowset))
	{
    mLogger->LogThis(LOG_ERROR, "Unable to execute SQL");
		return FALSE;
	}
  
  	// If no rows found
	if (rowset.GetRecordCount() ==	0)
	{
	  mLogger->LogThis(LOG_ERROR, "No rows found for this query");
		return FALSE;
	}
	else
    rowset.GetWCharValue (_variant_t (L"nm_login"), arDestinationIdentifier);

	// disconnect 
  if (!dbaccess.Disconnect())
	{
    mLogger->LogThis(LOG_ERROR, "Unable to disconnect");
		return FALSE;
	}

  return TRUE;
}

/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: CAccountMapper::IsNameSpaceValid()
// DESCRIPTION	: returns TRUE, if namespace is present in t_namespace
// RETURN		: BOOL
// ARGUMENTS	: const wstring &arNameSpace
// 				: IMTSQLRowsetPtr &arRowset
// EXCEPTIONS	: 
// COMMENTS		: 
// CREATED		: 12/14/00, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
HRESULT CAccountMapper::IsNameSpaceValid(const wstring &arNameSpace, ROWSETLib::IMTSQLRowsetPtr &aRowset)
{
	const char* procName = "CAccountMapper::IsNameSpaceValid";

	// get the query
	_variant_t vtParam;

 	try
 	{
    aRowset->ClearQuery();
	  
		aRowset->SetQueryTag("__SELECT_NAMESPACE__");

		// add parameters
		vtParam = arNameSpace.c_str();
		aRowset->AddParam(L"%%NAME_SPACE%%", vtParam);
		
		// execute
		aRowset->Execute();

		// If no rows found
		if (aRowset->GetRecordCount() ==	0)
			return ACCOUNTMAPPER_ERR_NAMESPACE_DOES_NOT_EXIST;
 	}
	catch (_com_error& e)
	{
		SetError(e.Error(), ERROR_MODULE, ERROR_LINE, procName,
				"Unable to get __SELECT_NAMESPACE__ query.");
		mLogger->LogErrorObject (LOG_ERROR, GetLastError());
		return GetLastErrorCode();
	}

	// name space is valid
	return S_OK;
}

HRESULT CAccountMapper::DoesMappingExist(const wstring &arLoginName, 
																				 const wstring &arNameSpace,
                                         ROWSETLib::IMTSQLRowsetPtr &aRowset)
{
	// get the query
	_variant_t vtParam;
	const char* procName = "CAccountMapper::DoesMappingExists";

 	try
 	{
    // set the query tag ...
    aRowset->SetQueryTag ("__SELECT_ACCOUNT_ID_PRESSERVER__");

    // add the parameters ...
    vtParam = arLoginName.c_str();
    aRowset->AddParam(MTPARAM_LOGINID, vtParam);
    vtParam = arNameSpace.c_str();
    aRowset->AddParam(MTPARAM_NAMESPACE, vtParam);

    // execute the stored procedure ...
    aRowset->Execute();

		// if a row is not found
		if (aRowset->GetRecordCount() == 0)
			return ACCOUNTMAPPER_ERR_DOES_NOT_EXIST;

  	// If a row is found
		if (aRowset->GetRecordCount() >	0)
			return ACCOUNTMAPPER_ERR_ALREADY_EXISTS;
	}
	catch (_com_error& e)
	{
		SetError(e.Error(), ERROR_MODULE, ERROR_LINE, procName,
				"Unable to get __SELECT_ACCOUNT_ID_PRESSERVER__ query.");
		mLogger->LogErrorObject (LOG_ERROR, GetLastError());
		return GetLastErrorCode();
	}

	// mapping exists
	return S_OK;
}
