/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#include "StdAfx.h"
#include "MTYAAC.h"
#include "MTPaymentSlice.h"
#include "GenericCollectionInterfaces_i.c"


/////////////////////////////////////////////////////////////////////////////
// CMTPaymentSlice

STDMETHODIMP CMTPaymentSlice::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPaymentSlice,
    &IID_IMTCollectionReadOnly
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------


STDMETHODIMP CMTPaymentSlice::Initialize(IMTSessionContext *pCTX, IMTYAAC *pPayer, DATE RefDate)
{
	mCTX = pCTX;
	mPayerYAAC = MTYAACLib::IMTYAACPtr(pPayer)->CopyConstruct();
	mRefDate = _variant_t(RefDate,VT_DATE);
	return LoadData();
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTPaymentSlice::InitializeBitemporal(IMTSessionContext *pCTX, IMTYAAC *pPayer, DATE RefDate, DATE SystemDate)
{
	// TODO: Add your implementation code here
	mCTX = pCTX;
	mPayerYAAC = pPayer;
  mRefDate = RefDate;
  mSystemDate = SystemDate;

	return E_NOTIMPL;
}


STDMETHODIMP CMTPaymentSlice::InitializeAll(IMTSessionContext* pCTX,IMTYAAC* pPayer)
{
	mCTX = pCTX;
	mPayerYAAC = pPayer;
	return LoadDataNoTime();
}



// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------


STDMETHODIMP CMTPaymentSlice::PayeesAsRowset(IMTSQLRowset** ppRowset)
{
	try {
		*ppRowset = reinterpret_cast<IMTSQLRowset*>(mRowset.GetInterfacePtr());
		(*ppRowset)->AddRef();
	}
	catch(_com_error& err) {
		LogYAACError("Failed to read payment slice");
		return returnYAACError(err);
	}
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

HRESULT CMTPaymentSlice::LoadData()
{
	try {

		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
    queryAdapter->SetQueryTag("__FIND_PAYMENT_SLICE__");
		queryAdapter->AddParam("%%ID_PAYER%%", mPayerYAAC->GetAccountID());

		wstring DateVal;
		FormatValueForDB(mRefDate,FALSE,DateVal);
		queryAdapter->AddParam("%%REFDATE%%",DateVal.c_str(),VARIANT_TRUE);
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));

		mRowset = reader->ExecuteStatement(queryAdapter->GetQuery());
		PopulateCollection();

	}
	catch(_com_error& err) {
		LogYAACError("Failed to read payment slice");
		return returnYAACError(err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------


HRESULT CMTPaymentSlice::LoadDataNoTime()
{
	try {

		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
	queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
  queryAdapter->SetQueryTag("__FIND_PAYMENT_SLICE_NO_TIME__");
	queryAdapter->AddParam("%%ID_PAYER%%", mPayerYAAC->GetAccountID());
	MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));

	mRowset = reader->ExecuteStatement(queryAdapter->GetQuery());
	PopulateCollection();

	}
	catch(_com_error& err) {
		LogYAACError("Failed to read payment slice");
		return returnYAACError(err);
	}
	return S_OK;
}

void CMTPaymentSlice::PopulateCollection()
{
	long count;

	if(mRowset->GetRecordCount() > 0) {
		for(count = 0;count < mRowset->GetRecordCount() - 1;count++) {
			_variant_t vtDisp;

			MTYAACLib::IMTPaymentAssociationPtr assoc(__uuidof(MTYAACLib::MTPaymentAssociation));
			assoc->Initialize(CTXCAST(mCTX),
				mRowset->GetValue("id_payer"),
				mRowset->GetValue("id_payee"),
				mRowset->GetValue("vt_start"),
				mRowset->GetValue("vt_end"));
			IDispatchPtr pDisp = assoc;

			//add to collection
			InternalAdd(_variant_t(pDisp.GetInterfacePtr()));
			mRowset->MoveNext();
		}
		mRowset->MoveFirst();
	}
}
