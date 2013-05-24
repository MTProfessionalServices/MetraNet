/**************************************************************************
 * MTWHEREABOUTSMANAGER
 *
 * Copyright 1997-2001 by MetraTech Corp.
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include "StdAfx.h"

#include <MTWhereaboutsManager.h>
#include "PipelineTransaction.h"
#include "MTWhereaboutsManagerDef.h"

#include <base64.h>

//#include <string.h>
//#include <vector>

#include <comdef.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>


_COM_SMARTPTR_TYPEDEF(ITransactionImportWhereabouts, IID_ITransactionImportWhereabouts);

#if 0


_COM_SMARTPTR_TYPEDEF(ITransactionExportFactory, IID_ITransactionExportFactory);
_COM_SMARTPTR_TYPEDEF(ITransactionExport, IID_ITransactionExport);

_COM_SMARTPTR_TYPEDEF(ITransactionImport, IID_ITransactionImport);
#endif


STDMETHODIMP CMTWhereaboutsManager::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTWhereaboutsManager
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++) {
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


CMTWhereaboutsManager::CMTWhereaboutsManager()
{
	// hold on to a CTransactionConfig object for the life time of a CMTWhereaboutsManager
	// to allow COM clients to cache the TransactionConfig by holding onto a WhereaboutsManager
	mTransactionConfig = CTransactionConfig::GetInstance();
}

CMTWhereaboutsManager::~CMTWhereaboutsManager()
{
	CTransactionConfig::ReleaseInstance();
	mTransactionConfig = NULL;
}


STDMETHODIMP
CMTWhereaboutsManager::GetWhereaboutsForServer(BSTR aServer,
																							 /*[out, retval]*/ BSTR * aWhereabouts)
{
	ASSERT(mTransactionConfig);
	
	//transactionconfig meters to server to get its whereabouts, caching the result for future requests
	_bstr_t bstrServerName = aServer;
	string serverName((const char *)bstrServerName);
	string encodedWhereAbouts;

	BOOL bRet = mTransactionConfig->GetEncodedWhereAbouts(serverName, encodedWhereAbouts);
	
	if(!bRet)
	{	string msg = "GetEncodedWhereAbouts failed for server '" + serverName + "'";
		return Error(msg.c_str());
	}

	_bstr_t bstrWhereAbouts = encodedWhereAbouts.c_str();
	*aWhereabouts = bstrWhereAbouts.copy();

	return S_OK;
}

STDMETHODIMP
CMTWhereaboutsManager::GetLocalWhereabouts(/*[out, retval]*/ BSTR * aWhereabouts)
{
	// check cached value
	if (mLocalWhereabouts.length() == 0)
	{
		BYTE * rgbWhereAbouts = NULL;
		ULONG cbWhereAbouts;
		HRESULT hr = GetLocalWhereabouts(&cbWhereAbouts, &rgbWhereAbouts);
		if (FAILED(hr))
		{
			ASSERT(rgbWhereAbouts == NULL);
			return hr;
		}

		ASSERT(rgbWhereAbouts);
		// convert cookie to ascii string
		string localStrWhereAbouts;
		BOOL ok = rfc1421encode(rgbWhereAbouts, cbWhereAbouts, localStrWhereAbouts);

		delete [] rgbWhereAbouts;

		if (!ok)
			return Error("Unable to encode whereabouts");

		mLocalWhereabouts = localStrWhereAbouts.c_str();
	}

	*aWhereabouts = mLocalWhereabouts.copy();
	return S_OK;
}

HRESULT CMTWhereaboutsManager::GetLocalWhereabouts(
	/*[out]*/ ULONG * cbWhereAbouts,
	/*[out]*/ BYTE ** rgbWhereAbouts)
{
	try
	{
		ASSERT(rgbWhereAbouts);
		ASSERT(cbWhereAbouts);

		ITransactionImportWhereaboutsPtr importWhereabouts;
    HRESULT hr = ::DtcGetTransactionManagerEx( NULL, NULL, IID_ITransactionImportWhereabouts,
																						 0, 0, (void**)&importWhereabouts);
	  if (FAILED(hr))
			return hr;

		unsigned long lWhereAboutsSize;
	  hr = importWhereabouts->GetWhereaboutsSize(&lWhereAboutsSize);
	  if (FAILED(hr))
			return hr;

		BYTE * whereAboutsBinary;
    whereAboutsBinary = new BYTE[lWhereAboutsSize];
		ASSERT(whereAboutsBinary);

		unsigned long lngUsed = 0;
	  hr = importWhereabouts->GetWhereabouts(lWhereAboutsSize, whereAboutsBinary, &lngUsed);
	  if (FAILED(hr))
		{
			delete [] whereAboutsBinary;
			*rgbWhereAbouts = NULL;
			return hr;
		}

		ASSERT(lngUsed == lWhereAboutsSize);

    *cbWhereAbouts =  lWhereAboutsSize;
    *rgbWhereAbouts  = whereAboutsBinary;

		return S_OK;
  }
	catch (_com_error & err)
	{ return ReturnComError(err); }
}
