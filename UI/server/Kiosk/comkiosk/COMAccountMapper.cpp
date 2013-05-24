/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
***************************************************************************/
// ---------------------------------------------------------------------------
// COMAccountMapper.cpp : Implementation of CCOMAccountMapper
// ---------------------------------------------------------------------------
#include "StdAfx.h"
#include "COMKiosk.h"
#include "COMAccountMapper.h"
#include <mtglobal_msg.h>

#include <loggerconfig.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMAccountMapper

// ---------------------------------------------------------------------------
// Description:   This is the default constructor for this object
// ---------------------------------------------------------------------------
CCOMAccountMapper::CCOMAccountMapper()
{	
	mIsInitialized = FALSE;
}

// ---------------------------------------------------------------------------
// Description:   This is the default destructor for this object. It set the 
//                local flag to false. 
// ---------------------------------------------------------------------------
CCOMAccountMapper::~CCOMAccountMapper() 
{
	mIsInitialized = FALSE;
}

STDMETHODIMP CCOMAccountMapper::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMAccountMapper,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ---------------------------------------------------------------------------
// Description:	This method initializes the underlying C++ account mapper object
// Errors Raised: 0xE140002F - ACCOUNT_MAPPER_INITIALIZATION_FAILED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccountMapper::Initialize()
{
	// local variables ...
	HRESULT hr = S_OK;  
	string buffer;

  // initialize the account mapper object...
  if (!mAccountMapper.Initialize ())
  {
    // null the pointer 
    mIsInitialized = FALSE;
    hr = ACCOUNT_MAPPER_INITIALIZATION_FAILED;
	buffer = "Account Mapper object cannot be initialized";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMAccountMapper, hr);
  }
  else
  {
    mIsInitialized = TRUE;
  }

	return (hr);	
}

// ---------------------------------------------------------------------------
// Description:   This method will add an entry to the t_account_mapper table.  It 
//                does that through the C++ account mapper object. 
// Arguments:     Login - login or username
//                name_space - name_space that uniquely identifies the
//                account
//                accountID - uniquely generated MT account ID
//                pRowset - A rowset object that manages transactions
// Return Value:  Uniquely generated account ID
// Errors Raised: 0xE14000C - KIOSK_ERR_ADD_FAILED 
//                0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
//                0xE140018 - KIOSK_ERR_ACCOUNT_ALREADY_EXISTS 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccountMapper::Add(BSTR login, BSTR name_space, long lAcctID, LPDISPATCH pRowset)
{
	// local variables ...
	HRESULT hr(S_OK);  
	long lReturnCode;
	string buffer;

  	// check for mIsInitialized flag or the existence of the pointer
	if (mIsInitialized == TRUE)
	{
		// make sure you evaluate the return codes from executing the stored procs
		// evaluate return code provided as an output parameter of the stored proc.
		if (!mAccountMapper.Add (login, name_space, lAcctID, pRowset, lReturnCode))
		{
			hr = mAccountMapper.GetLastErrorCode();

			switch(hr)
			{
				case ACCOUNTMAPPER_ERR_INVALID_ACCOUNTMAPPING:
					buffer = "Invalid account mapping";
					break;
				case ACCOUNTMAPPER_ERR_ALREADY_EXISTS:
					buffer = "Account mapping already exists";
					break;
				case ACCOUNTMAPPER_ERR_NAMESPACE_INVALID:
					buffer = "Invalid name space";
					break;
				case ACCOUNTMAPPER_ERR_NOCHANGESMADE_ACCOUNTMAPPING:
					buffer = "No changes where made to account mapping";
					break;
				case ACCOUNTMAPPER_ERR_DBERROR:
					buffer = "Database has detected an error";
					break;
				case KIOSK_ERR_ADD_FAILED:
					buffer = "Unable to add account";
					break;
				default:
					buffer = "Database has detected an error";
			}

			mLogger->LogThis (LOG_ERROR, buffer.c_str());

			return Error (buffer.c_str(), IID_ICOMAccountMapper, hr);
		}
	}
	else
	{
		hr = KIOSK_ERR_NOT_INITIALIZED;
		buffer = "Account Mapper object not initialized";
		mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMAccountMapper, hr);
	}

	return (hr);	
}

STDMETHODIMP CCOMAccountMapper::MapAccountIdentifier(BSTR fromAccountIdentifier, BSTR fromName_space, BSTR toName_space, BSTR *pAccountIdentifier)
{
	HRESULT hr = S_OK;  
	wstring sAccountIdentifier;
  long lReturnCode;
	string buffer;

  // check for mIsInitialized flag or the existence of the pointer
  if (mIsInitialized == TRUE)
  {
    if (!mAccountMapper.MapAccountIdentifier(fromName_space, fromAccountIdentifier, toName_space, sAccountIdentifier,lReturnCode))
    {
		  buffer = "Account Mapper unable to map account <";
      buffer += _bstr_t(fromAccountIdentifier,true);
      buffer += "> in namespace <";
      buffer += _bstr_t(fromName_space,true);
      buffer += "> to namespace <";
      buffer += _bstr_t(toName_space,true);
      buffer += ">";
		  mLogger->LogThis (LOG_ERROR, buffer.c_str());
      return Error (buffer.c_str(), IID_ICOMAccountMapper, hr);
    }
    else
    {
      //Successfully retrieved the account id for the desired namespace
      *pAccountIdentifier = SysAllocString(sAccountIdentifier.c_str());
      buffer = "Account Mapper mapped account <";
      buffer += _bstr_t(fromAccountIdentifier,true);
      buffer += "> in namespace <";
      buffer += _bstr_t(fromName_space,true);
      buffer += "> to account <";
      buffer += (char*)_bstr_t(sAccountIdentifier.c_str());
      buffer += "> in namespace <";
      buffer += _bstr_t(toName_space,true);
      buffer += ">";
		  mLogger->LogThis (LOG_DEBUG, buffer.c_str());
    }
  }
	else
	{
		hr = KIOSK_ERR_NOT_INITIALIZED;
		buffer = "Account Mapper object not initialized";
		mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMAccountMapper, hr);
	}

	return (hr);	
}

STDMETHODIMP CCOMAccountMapper::Modify(int ActionType, BSTR LoginName, BSTR NameSpace, BSTR NewLoginName, BSTR NewNameSpace, LPDISPATCH pRowset)
{
	
	// local variables ...
	HRESULT hr(S_OK);
	long lReturnCode;
	string buffer;

  	// check for mIsInitialized flag or the existence of the pointer
	if (mIsInitialized == TRUE)
	{
  		if(!mAccountMapper.Modify (lReturnCode, ActionType, LoginName,
						NameSpace, NewLoginName, NewNameSpace, pRowset))
		{
			hr = mAccountMapper.GetLastErrorCode();

			switch(hr)
			{
				case ACCOUNTMAPPER_ERR_INVALID_ACCOUNTMAPPING:
					buffer = "Invalid account mapping";
					break;
				case ACCOUNTMAPPER_ERR_ALREADY_EXISTS:
					buffer = "Account mapping already exists";
					break;
				case ACCOUNTMAPPER_ERR_NAMESPACE_INVALID:
					buffer = "Invalid name space";
					break;
				case ACCOUNTMAPPER_ERR_NOCHANGESMADE_ACCOUNTMAPPING:
					buffer = "No changes where made to account mapping";
					break;
				case ACCOUNTMAPPER_ERR_DBERROR:
					buffer = "Database has detected an error";
					break;
				case KIOSK_ERR_ADD_FAILED:
					buffer = "Unable to add account";
					break;
				default:
					buffer = "Database has detected an error";
			}

			mLogger->LogThis (LOG_ERROR, buffer.c_str());

			return Error (buffer.c_str(), IID_ICOMAccountMapper, hr);
		}
	}
	else
	{
		hr = KIOSK_ERR_NOT_INITIALIZED;
		buffer = "Account Mapper object not initialized";
		mLogger->LogThis (LOG_ERROR, buffer.c_str());
   	return Error (buffer.c_str(), IID_ICOMAccountMapper, hr);
	}

	return (hr);	
}
