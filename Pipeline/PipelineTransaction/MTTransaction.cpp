/**************************************************************************
 * @doc MTTRANSACTION
 *
 * Copyright 2000 by MetraTech Corporation
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
 * Created by: Alan Blount
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "StdAfx.h"

#pragma warning (disable : 4192)
#if (_MSC_VER >= 1300)
#import <ComSvcs.dll> exclude("IAppDomainHelper")  rename("GetObject", "GetObjectCS")
#else
#import <ComSvcs.dll> inject_statement("typedef struct  tagBLOB { ULONG cbSize; BYTE __RPC_FAR *pBlobData;}	BLOB;") 
#endif
#pragma warning (default : 4192)



#include <MTTransaction.h>
#include "PipelineTransaction.h"
#include "MTTransactionDef.h"

#include <transactionconfig.h>
#include <base64.h>

#include <string.h>
#include <vector>

#include <mtcomerr.h>
#include <mtglobal_msg.h>



#import <com\\Comadmin.dll> no_namespace

_COM_SMARTPTR_TYPEDEF(ITransactionOptions, IID_ITransactionOptions);

_COM_SMARTPTR_TYPEDEF(ITransactionExportFactory, IID_ITransactionExportFactory);
_COM_SMARTPTR_TYPEDEF(ITransactionExport, IID_ITransactionExport);

_COM_SMARTPTR_TYPEDEF(ITransactionImport, IID_ITransactionImport);


STDMETHODIMP CMTTransaction::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTTransaction
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++) {
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


CMTTransaction::CMTTransaction()
	: mOwner(FALSE)
{ }
	
CMTTransaction::~CMTTransaction()
{
	// rollback if the transaction exists and wasn't committed.
	if (mITransaction != NULL && mOwner)
		Rollback();
}



ITransactionDispenserPtr CMTTransaction::GetFactory(HRESULT & hr)
{
	static ITransactionDispenserPtr dispenser;
	if (dispenser == NULL)
	{
		ITransactionDispenser* pTransactionDispenser = NULL;
		hr = ::DtcGetTransactionManagerEx(0, 0, IID_ITransactionDispenser, 
																		0, 0,(void **)&pTransactionDispenser);
		if (FAILED(hr))
			return NULL;
		dispenser.Attach(pTransactionDispenser, false);
	}
	return dispenser;
}


STDMETHODIMP CMTTransaction::Begin(BSTR aDescription, int aTimeout)
{
	HRESULT hr = S_OK;

  try
  {
		if (mITransaction != NULL)
			return Error("This transaction object already contains a live transaction",
									 IID_IMTTransaction, DB_ERR_TRANSACTION_STARTED);

		ITransactionDispenserPtr dispenser = CMTTransaction::GetFactory(hr);
		if (FAILED(hr))
			return hr;

		// set options
		ITransactionOptions *pTxOpts = NULL;
		hr = dispenser->GetOptionsObject(&pTxOpts);
		if (FAILED(hr))
			return hr;

		// take ownership
		ITransactionOptionsPtr txOpts(pTxOpts, false);
		pTxOpts = NULL;

		XACTOPT xaOpt;
		// The time-out limits the duration of the transaction and therefore 
		// bounds the amount of time locks are held on database records and 
		// system resources. If the time-out period expires before the transaction 
		// commits, MS DTC automatically aborts the transaction.The time-out 
		// is specified in milliseconds. 
		// A time-out value of zero indicates an infinite time-out. 
		xaOpt.ulTimeout = aTimeout;

		// The description is displayed by the MS DTC administration tool in the 
		// MS DTC Transactions window. The description is only meaningful to the 
		// MS DTC administrator and is not processed or interpreted by MS DTC itself. 
		// The string cannot be longer than MAX_TRAN_DESC bytes in length. 
		_bstr_t description(aDescription);
		if (description.length() > 0)
			strncpy(xaOpt.szDescription, description, MAX_TRAN_DESC);
		else
			strcpy(xaOpt.szDescription, "");

		// set the options
		hr = txOpts->SetOptions(&xaOpt);
		if (FAILED(hr))
			return hr;

		ITransaction * pTrans = NULL;
		hr = dispenser->BeginTransaction(NULL, ISOLATIONLEVEL_READCOMMITTED,
																		 ISOFLAG_RETAIN_DONTCARE, pTxOpts,
																		 &pTrans);
		if (FAILED(hr))
			return hr;
		// take ownership
		mITransaction.Attach(pTrans, false);

///		mLogger->LogThis (LOG_DEBUG, "OLEDBContext::BeginDistributedTransaction, ITransaction created.") ;
		mOwner = TRUE;	// we are the owner of the transaction
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

STDMETHODIMP CMTTransaction::Commit()
{
	if (mITransaction == NULL)
		return Error("No transaction to commit");

	// only close the distributed transaction if we own it
	if (!mOwner)
	{
//		mLogger->LogThis (LOG_DEBUG, "Ignoring commit of not-owned transaction");
		mITransaction = NULL;
		return S_OK;
	}

	try
	{
		ASSERT(mOwner);

		// the local commit flags are not supported HRESULT = 0x8004d00f
		HRESULT hr = mITransaction->Commit(FALSE,// "retaining" ??
																			 0,	// Values taken from the enumeration XACTTC
																			 0); // Must be zero
///			mLogger->LogThis (LOG_DEBUG, "OLEDBContext::CommitTransaction, commit remote transaction.") ;

		if (FAILED(hr))
			return hr;

		// release the transaction so we can create another one
		mITransaction = NULL;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

///	if (bRetCode)
///		mLogger->LogThis (LOG_DEBUG, "CommitTransaction succeeded") ;

	return S_OK;
}

STDMETHODIMP CMTTransaction::Rollback()
{
	if (mITransaction == NULL)
		return Error("No transaction to rollback");

	// rollback transaction regardless of ownership
	// (a failed inner transaction should abort the outer transaction)
	try
	{
    // commit the transaction ...
    HRESULT hr =
			mITransaction->Abort(
				// "A pointer to a BOID that indicates why the transaction is
				// being aborted.  If this is a null pointer, no reason is
				// provided"
				NULL,
				// retaining??
				FALSE,
				// asynchronous = no
				FALSE);

///    mLogger->LogThis (LOG_DEBUG, "OLEDBContext::RollbackTransaction, abort transaction.") ;
    if (FAILED(hr))
			return hr;

		// release the transaction so we can create another one if we want
		mITransaction = NULL;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

STDMETHODIMP CMTTransaction::SetTransaction(IUnknown * apTransaction, /*[in, optional]*/ VARIANT aOwner)
{
	try
	{
		// NOTE: SetTransaction can be passed NULL, meaning clear the object
		mITransaction = apTransaction;
		if (apTransaction != NULL && mITransaction == NULL)
			// query interface failed?
			return E_INVALIDARG;

		_variant_t owner(aOwner);
		if (V_VT(&owner) != VT_NULL)
			mOwner = (bool) owner;
		else
			mOwner = FALSE;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

STDMETHODIMP CMTTransaction::GetTransaction(/*[out, retval]*/ IUnknown * * apTransaction)
{
	try
	{
		HRESULT hr = S_OK;
		if (mITransaction == NULL)
			*apTransaction = NULL;
		else
			// have to pass it back as IUnknown unfortunately
			hr = mITransaction->QueryInterface(IID_IUnknown,
																				 (void **)apTransaction);

		return hr;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

STDMETHODIMP CMTTransaction::Export(BSTR aWhereAbouts, /*[out, retval]*/ BSTR * aEncodedCookie)
{
	ULONG cbCookie;
	BYTE *rgbCookie = NULL;

	// decode from ascii to binary
	_bstr_t strEncodedWhereAbouts(aWhereAbouts);
	int srcLen = strlen(strEncodedWhereAbouts);

	vector<unsigned char> dest;
	if (rfc1421decode(strEncodedWhereAbouts, srcLen, dest) != ERROR_NONE)
		return Error("Unable to decode whereabouts");

	rgbCookie = NULL;
	HRESULT hr = Export(
			dest.size(),
			&dest[0],	 
			&cbCookie,
			&rgbCookie);

	if (FAILED(hr))
	{
		ASSERT(rgbCookie == NULL);
		return hr;
	}

	// convert cookie to ascii string
	ASSERT(rgbCookie);
	string strEncodedTransactionCookie;
	BOOL ok = rfc1421encode(rgbCookie, cbCookie, strEncodedTransactionCookie);
	delete [] rgbCookie;

	if (!ok)
		return Error("Unable to encode transaction cookie");

	*aEncodedCookie = _bstr_t(strEncodedTransactionCookie.c_str()).copy();

	return S_OK;
}


HRESULT CMTTransaction::Export(
	/*[in]*/ ULONG cbWhereabouts,
	/*[in]*/ BYTE * rgbWhereabouts,
	/*[out]*/ ULONG * cbCookie,
	/*[out]*/ BYTE ** rgbCookie)
{
	BOOL bOK = TRUE;
	HRESULT hr = S_OK;

	ULONG ulCbCookie = 0;
	ULONG ulUsed = 0;

	try
	{
		if (mITransaction == NULL)
			return Error("Object holds no transaction", IID_IMTTransaction, DB_ERR_NO_TRANSACTION);

		ITransactionExportFactoryPtr exportFactory;

		hr = ::DtcGetTransactionManagerEx(0, 0, IID_ITransactionExportFactory, 
																		0, 0,(void **)&exportFactory);
		if (FAILED(hr))
			return hr;

		// create ITransactionExport *	from remote whereabouts 
		ITransactionExportPtr txExport = NULL;
		hr = exportFactory->Create(cbWhereabouts, rgbWhereabouts, &txExport);
		if (FAILED(hr))
			return hr ;

		hr = txExport->Export(mITransaction, &ulCbCookie);
		if (FAILED(hr))
			return hr;

		*cbCookie = ulCbCookie;
		ASSERT(rgbCookie);
		*rgbCookie = new BYTE[ulCbCookie];
		ASSERT(*rgbCookie);

		hr = txExport->GetTransactionCookie(mITransaction, ulCbCookie, *rgbCookie, &ulUsed);
		if (FAILED(hr))
			return hr;

		if (ulUsed != ulCbCookie)
			return Error("Transaction cookie size is incorrect");

		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}


STDMETHODIMP CMTTransaction::Import(BSTR aEncodedCookie)
{
  BOOL bRetCode=TRUE ;
  vector<unsigned char> dest;
  ULONG cbTransactionCookie = 0; // if zero, use current transaction
  BYTE * rgbTransactionCookie = NULL;

  // if not NULL, we want to join the transaction specified by the cookie.
	ASSERT(aEncodedCookie);

	// decode transaction cookie from ascii to binary
	_bstr_t encodedCookie(aEncodedCookie);
	int srcLen = strlen(encodedCookie);

	int err = rfc1421decode(encodedCookie, srcLen,  dest);
	if (err != ERROR_NONE)
		return Error("Unable to decode transaction cookie");

	cbTransactionCookie = dest.size();
	rgbTransactionCookie = &dest[0];

	// translate the binary transaction cookie into a transaction interface
	return Import(cbTransactionCookie, rgbTransactionCookie);
}

HRESULT CMTTransaction::Import(/*[in]*/ ULONG cbTransactionCookie,
															 /*[in]*/ BYTE * rgbTransactionCookie)
{
	if (mITransaction != NULL)
		return Error("Object already holds a transaction");

	BOOL bOK = TRUE;
	HRESULT hr = S_OK;

	try
	{
		mOwner = FALSE; // we are not the owner of this transaction

		ITransactionImportPtr txImport = NULL;
		hr = ::DtcGetTransactionManagerEx(NULL, NULL, IID_ITransactionImport, 0, NULL, (void**)&txImport);
		if(FAILED(hr))
			return hr;

		hr = txImport->Import(cbTransactionCookie, rgbTransactionCookie,
													(GUID*)&IID_ITransaction, (void**)&mITransaction);

		if (FAILED(hr))
			return hr;

		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

STDMETHODIMP CMTTransaction::IsOwner(/*[out, retval]*/ VARIANT_BOOL* aIsOwner)
{
	if (aIsOwner == NULL)
		return E_POINTER;

	if (mOwner)
		*aIsOwner = VARIANT_TRUE;
	else
		*aIsOwner = VARIANT_FALSE;

	return S_OK;
}



// returns the default transaction timeout set for COM+
STDMETHODIMP CMTTransaction::get_DefaultTimeout(/*[out, retval]*/ long *pVal)
{
	try
	{
		static long timeout = -1;
		if (timeout == -1)
		{
			// retrieve the timeout once, return it after that

			ICOMAdminCatalogPtr spCatalog("COMAdmin.COMAdminCatalog");

			ICatalogCollectionPtr oLocalComputerCol =
				spCatalog->GetCollection(L"LocalComputer"); 
			oLocalComputerCol->Populate();

			ICatalogObjectPtr oLocalComputerItem = oLocalComputerCol->GetItem(0);

			timeout = oLocalComputerItem->GetValue(L"TransactionTimeout");
		}
		ASSERT(timeout != -1);
		*pVal = timeout;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}


STDMETHODIMP CMTTransaction::CreateObjectWithTransaction(BSTR progid, IDispatch **pDisp)
{
  // step 1: lookup the CLSID from the progid
  CLSID objectCLSID;
  HRESULT hr = ::CLSIDFromProgID(progid,&objectCLSID);
  if(FAILED(hr)) {
    return hr;
  }
  // step 2: fetch the COM+ object
  return CreateObjectWithTransactionByCLSID(objectCLSID,pDisp);
}

STDMETHODIMP CMTTransaction::CreateObjectWithTransactionByCLSID(REFIID riid, IDispatch **ppDisp)
{
  GUID IDispatchGUID = __uuidof(IDispatch);
	try
	{
    // step 1: create the byot object
    COMSVCSLib::ICreateWithTransactionExPtr createWithTransaction("Byot.ByotServerEx");
    // step 2: create the object with the transaction
    void* pVoid = createWithTransaction->CreateInstance(
    reinterpret_cast<COMSVCSLib::ITransaction *>(mITransaction.GetInterfacePtr()),
    const_cast<GUID*>(&riid),&IDispatchGUID);
    *ppDisp = reinterpret_cast<IDispatch*>(pVoid);
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
	return S_OK;
}

