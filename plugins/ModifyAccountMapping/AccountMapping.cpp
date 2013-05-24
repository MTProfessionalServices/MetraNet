/**************************************************************************
 * @doc SIMPLE
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY -- PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Raju Matta
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/
#include <mtcom.h>
#include <comdef.h>
#include <objbase.h>
#include <stdio.h>
#include <mtprogids.h>
#include <AccountMapping.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
using namespace ROWSETLib;

AccountMapping::AccountMapping() : bIsAccountMapperInitialized(FALSE),m_comaccountmapper(NULL)
{
	// initialize the logger ...
	LoggerConfigReader cfgRdr;
	mLogger.Init (cfgRdr.ReadConfiguration("AccountMapping"), "[ModifyAccountMapping]");
}
AccountMapping::~AccountMapping()
{
	m_comaccountmapper = NULL;
}


HRESULT AccountMapping::CreateRowset(LPDISPATCH& pDispatch)
{
	// extract the interface pointer ...
	HRESULT nRetVal=S_OK ;
	IMTSQLRowsetPtr pRowset ;
	// create the rowset object and begin the transaction ...
	mLogger.LogThis (LOG_DEBUG, "Creating rowset object");
	nRetVal = pRowset.CreateInstance(MTPROGID_SQLROWSET) ;
	
	// intialize rowset object
	nRetVal = pRowset->Init ("\\Queries\\PresServer") ;
	if (!SUCCEEDED(nRetVal))
	{
		mLogger.LogVarArgs (LOG_ERROR, "ERROR: unable to get initialize rowset. Error = %d",
			nRetVal);
		return nRetVal;
	}
	
	nRetVal = pRowset.QueryInterface (IID_IDispatch, &pDispatch) ;
	if (!SUCCEEDED(nRetVal))
	{
		mLogger.LogVarArgs (LOG_ERROR, "ERROR: unable to get dispatch interface of rowset. Error = %d",
			nRetVal);
		return nRetVal;
	}
	
	return nRetVal;
}

HRESULT AccountMapping::InitAccountMapperPointer()
{
	// create the vendor kiosk ...
	HRESULT hr(S_OK);
	char ErrorString[1024];
	if (bIsAccountMapperInitialized) return hr;
	hr = m_comaccountmapper.CreateInstance("COMAccountMapper.COMAccountMapper.1");
	if (!SUCCEEDED(hr))
	{
				sprintf(ErrorString,"ERROR: unable to create instance of com account mapper. Error = %X\n",hr);
				mLogger.LogThis (LOG_ERROR, ErrorString);
				return hr;
	}
	
	// initialize the account mapper object ...
	mLogger.LogThis (LOG_DEBUG, "Initializing COMAccountMapper");
	hr = m_comaccountmapper->Initialize ();
	if (!SUCCEEDED(hr))
	{
				sprintf(ErrorString,"ERROR: unable to initialize account mapper. Error = %X\n",hr);
				mLogger.LogThis (LOG_ERROR, ErrorString);
				return hr;
	} 
	bIsAccountMapperInitialized = TRUE;
	return hr;
}




HRESULT AccountMapping::ModifyAccountMapping(	int Action,
																						_bstr_t LoginName, 
																						_bstr_t NameSpace, 
																						_bstr_t NewLoginName,
																						_bstr_t NewNameSpace
																					)
{
	ComInitialize aComInit;
	HRESULT hr(S_OK);
	char ErrorString[1024];
	LPDISPATCH pDispatch = NULL;
	
	try
	{
		
		hr = CreateRowset(pDispatch);
		hr = InitAccountMapperPointer();
		// add
		mLogger.LogThis (LOG_DEBUG, " Mapping record");
		mLogger.LogVarArgs (LOG_DEBUG, "Action: %i, LoginName: %s, NameSpace: %s, NewLoginName: %s, NewNameSpace: %s",
												Action, (const char*)LoginName, (const char*)NameSpace, (const char*)NewLoginName, (const char*)NewNameSpace);
		hr = m_comaccountmapper->Modify (Action, LoginName, NameSpace, NewLoginName, NewNameSpace, pDispatch);
		if (!SUCCEEDED(hr))
		{
			sprintf(ErrorString,"ERROR: unable to update account mapper table. Error = %X\n",hr);
			mLogger.LogThis (LOG_ERROR, ErrorString);
			return hr;
		}
		hr = pDispatch->Release();
	}
	catch (_com_error e)
	{
		hr = e.Error();
		sprintf(ErrorString,"ERROR: caught _com_error. Error = %X\n",hr);
		pDispatch->Release();
		mLogger.LogThis (LOG_ERROR, ErrorString);
		return ReturnComError(e);
	}
		return hr;
}

