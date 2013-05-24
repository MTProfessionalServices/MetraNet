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
#include "MTPaymentMgr.h"
#include <mttime.h>
#include <autherr.h>

/////////////////////////////////////////////////////////////////////////////
// CMTPaymentMgr

STDMETHODIMP CMTPaymentMgr::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPaymentMgr
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

STDMETHODIMP CMTPaymentMgr::Initialize(IMTSessionContext *pCTX, VARIANT_BOOL aBillable, IMTYAAC *pPayer)
{
	mCTX = pCTX;
	mbBillable = (aBillable == VARIANT_TRUE) ? true : false;
	mPayerYAAC = MTYAACLib::IMTYAACPtr(pPayer)->CopyConstruct();
	return S_OK;
}

void CMTPaymentMgr::PaymentAuthChecks(DATE PaymentStartDate,
                                         GENERICCOLLECTIONLib::IMTCollectionExPtr pCol)
{
  if(mSecPtr == NULL) {
    mSecPtr.CreateInstance(__uuidof(MTAUTHLib::MTSecurity));
  }

  // check the manage payment capability
  mCTX->GetSecurityContext()->CheckAccess(mSecPtr->GetCapabilityTypeByName(MANAGE_PAYMENT_CAP)->CreateInstance());

  // check that the account's can be managed.
    
  MTAUTHEXECLib::IMTBatchAuthCheckReaderPtr checkPtr(__uuidof(MTAUTHEXECLib::MTBatchAuthCheckReader));
  ROWSETLib::IMTRowSetPtr errorRs = checkPtr->BatchUmbrellaCheck(
		reinterpret_cast<MTAUTHEXECLib::IMTSessionContext *>(mCTX.GetInterfacePtr()),
		reinterpret_cast<MTAUTHEXECLib::IMTCollectionEx *>(pCol.GetInterfacePtr()),
		PaymentStartDate);
	if(errorRs->GetRecordCount() > 0) {
		MT_THROW_COM_ERROR(MTAUTH_ACCESS_DENIED, "");
	}
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTPaymentMgr::PayForAccount(long aAccount, DATE StartDate, VARIANT EndDate)
{
	try {
		_variant_t realEndDate;

		// if the enddate was not specified, enter the maximum date
		if(!OptionalVariantConversion(EndDate,VT_DATE,realEndDate)) {
			realEndDate = GetMaxMTOLETime();
		}

    // check Auth
    GENERICCOLLECTIONLib::IMTCollectionExPtr colPtr(__uuidof(GENERICCOLLECTIONLib::MTCollectionEx));
		colPtr->Add(aAccount);
    PaymentAuthChecks(StartDate,colPtr);


		MTYAACEXECLib::IMTPaymentWriterPtr writer(__uuidof(MTYAACEXECLib::MTPaymentWriter));
		writer->PayForAccount(reinterpret_cast<MTYAACEXECLib::IMTSessionContext *>(mCTX.GetInterfacePtr()),
      mPayerYAAC->GetAccountID(),aAccount,StartDate,realEndDate);
	}
	catch(_com_error& err) {
		char buff[100];
		sprintf(buff,"Failed to pay for account %d",aAccount);
		return returnYAACError(err,buff,mPayerYAAC);
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

STDMETHODIMP CMTPaymentMgr::ChangePaymentEffectiveDate(long aAccount, DATE OldStartDate, DATE OldEndDate, DATE StartDate, DATE EndDate)
{
	try {

    // check Auth
    GENERICCOLLECTIONLib::IMTCollectionExPtr colPtr(__uuidof(GENERICCOLLECTIONLib::MTCollectionEx));
		colPtr->Add(aAccount);
    PaymentAuthChecks(StartDate,colPtr);
    
    MTYAACEXECLib::IMTPaymentWriterPtr writer(__uuidof(MTYAACEXECLib::MTPaymentWriter));
		writer->UpdatePaymentRecord(reinterpret_cast<MTYAACEXECLib::IMTSessionContext *>(mCTX.GetInterfacePtr()),
      mPayerYAAC->GetAccountID(),aAccount,OldStartDate,OldEndDate,
			StartDate,EndDate);
	}
	catch(_com_error& err) {
		char buff[100];
		sprintf(buff,"Failed to change payment effective date for target account %d",aAccount);
		return returnYAACError(err,buff,mPayerYAAC);
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

STDMETHODIMP CMTPaymentMgr::PayForAccountBatch(IMTCollectionEx *pCol,
																							 IMTProgress* pProgress,
																							 DATE StartDate,
																							 VARIANT EndDate,
																							 IMTRowSet** ppRowset)
{
	try {
    PaymentAuthChecks(StartDate,pCol);

		MTYAACEXECLib::IMTPaymentWriterPtr writer(__uuidof(MTYAACEXECLib::MTPaymentWriter));
		ROWSETLib::IMTRowSetPtr rs = writer->PayForAccountBatch(
			reinterpret_cast<MTYAACEXECLib::IMTSessionContext *>(mCTX.GetInterfacePtr()),
      reinterpret_cast<MTYAACEXECLib::IMTCollection *>(pCol),
			reinterpret_cast<MTYAACEXECLib::IMTProgress *>(pProgress),
			mPayerYAAC->GetAccountID(),
			StartDate,EndDate);
		*ppRowset = reinterpret_cast<IMTRowSet*>(rs.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Error attempting to pay for multiple accounts, check the return collection for details",mPayerYAAC);
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

STDMETHODIMP CMTPaymentMgr::PaymentSliceNow(IMTPaymentSlice **ppSlice)
{
	try {
		MTYAACLib::IMTPaymentSlicePtr slice(__uuidof(MTYAACLib::MTPaymentSlice));
		slice->Initialize(CTXCAST(mCTX),mPayerYAAC,GetMTOLETime());
		*ppSlice = reinterpret_cast<IMTPaymentSlice*>(slice.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to create a payment slice based on the current system time",mPayerYAAC);
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

STDMETHODIMP CMTPaymentMgr::PaymentSlice(DATE RefDate, IMTPaymentSlice **ppSlice)
{
	try {
		MTYAACLib::IMTPaymentSlicePtr slice(__uuidof(MTYAACLib::MTPaymentSlice));
		slice->Initialize(CTXCAST(mCTX),mPayerYAAC,RefDate);
		*ppSlice = reinterpret_cast<IMTPaymentSlice*>(slice.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to create a payment slice",mPayerYAAC);
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

STDMETHODIMP CMTPaymentMgr::AllPayees(IMTPaymentSlice **ppSlice)
{
	try {
		MTYAACLib::IMTPaymentSlicePtr slice(__uuidof(MTYAACLib::MTPaymentSlice));
		slice->InitializeAll(CTXCAST(mCTX),mPayerYAAC);
		*ppSlice = reinterpret_cast<IMTPaymentSlice*>(slice.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to find all payees for payer ",mPayerYAAC);
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

STDMETHODIMP CMTPaymentMgr::PaymentSliceAtSystemDate(DATE RefDate, DATE SystemDate, IMTPaymentSlice **ppSlice)
{
	try {
		MTYAACLib::IMTPaymentSlicePtr slice(__uuidof(MTYAACLib::MTPaymentSlice));
		slice->InitializeBitemporal(CTXCAST(mCTX),mPayerYAAC,RefDate,SystemDate);
		*ppSlice = reinterpret_cast<IMTPaymentSlice*>(slice.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to create bitemporal payment slice",mPayerYAAC);
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

STDMETHODIMP CMTPaymentMgr::get_AccountIsBillable(VARIANT_BOOL *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	*pVal = mbBillable ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTPaymentMgr::SetAccountAsBillable()
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	long userID = -1;
	long accountID = -1;

	try {

		deniedEvent = AuditEventsLib::AUDITEVENT_ACCOUNT_UPDATE_DENIED;
		userID = mCTX->GetAccountID();
		accountID = mPayerYAAC->GetAccountID();

		// check required capabilities
		CheckBillableAuth();

		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
    queryAdapter->SetQueryTag("__SET_ACCOUNT_AS_BILLABLE");
		queryAdapter->AddParam("%%ID_ACC%%", accountID);
		MTYAACEXECLib::IMTGenDbWriterPtr writer(__uuidof(MTYAACEXECLib::MTGenDbWriter));
		writer->ExecuteStatement(queryAdapter->GetQuery());
	}
	catch(_com_error& err) {
		AuditAuthFailures(err, deniedEvent, userID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											accountID);

		return returnYAACError(err,"Failed to set account as billable",mPayerYAAC);
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

STDMETHODIMP CMTPaymentMgr::SetAccountAsNonBillable()
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	long accountID = -1;
	long userID = -1;
	try {

		deniedEvent = AuditEventsLib::AUDITEVENT_ACCOUNT_UPDATE_DENIED;
		userID = mCTX->GetAccountID();

		// check required capabilities
		CheckBillableAuth();
		
		accountID = mPayerYAAC->GetAccountID();
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
    queryAdapter->SetQueryTag("__SET_ACCOUNT_AS_NON_BILLABLE");
		queryAdapter->AddParam("%%ID_ACC%%", accountID);
		MTYAACEXECLib::IMTGenDbWriterPtr writer(__uuidof(MTYAACEXECLib::MTGenDbWriter));
		writer->ExecuteStatement(queryAdapter->GetQuery());
	}
	catch(_com_error& err) {
		AuditAuthFailures(err, deniedEvent, userID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											accountID);

		return returnYAACError(err,"Failed to set account as non-billable",mPayerYAAC);
	}
	return S_OK;
}


void CMTPaymentMgr::CheckBillableAuth()
{
	// check umbrella capability
	if(mPayerYAAC->CanManageAccount() == VARIANT_FALSE) {
		MT_THROW_COM_ERROR(MTAUTH_ACCESS_DENIED, "");
	}

	// check for the Manage billable accounts capability
	MTAUTHLib::IMTSecurityPtr secPtr(__uuidof(MTAUTHLib::MTSecurity));
	MTAUTHLib::IMTSecurityContextPtr secCtx = mCTX->GetSecurityContext();
	secCtx->CheckAccess(secPtr->GetCapabilityTypeByName("Manage billable accounts")->CreateInstance());
}

STDMETHODIMP CMTPaymentMgr::PaymentHistory(IMTRowSet **ppRowset)
{
	try {
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
    queryAdapter->SetQueryTag("__GET_PAYMENT_HISTORY_ACC_HIERARCHIES__");
		queryAdapter->AddParam("%%ID_ACC%%", mPayerYAAC->GetAccountID());
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
    ROWSETLib::IMTRowSetPtr pRS = reader->ExecuteStatement(queryAdapter->GetQuery());
    *ppRowset = reinterpret_cast<IMTRowSet*>(pRS.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to create bitemporal payment slice",mPayerYAAC);
	}
	return S_OK;}

STDMETHODIMP CMTPaymentMgr::BitemporalPaymentHistory(IMTRowSet **ppRowset)
{
  try {
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
    queryAdapter->SetQueryTag("__GET_BITEMPORAL_PAYMENT_HISTORY__");
		queryAdapter->AddParam("%%ID_ACC%%", mPayerYAAC->GetAccountID());
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
    ROWSETLib::IMTRowSetPtr pRS = reader->ExecuteStatement(queryAdapter->GetQuery());
    *ppRowset = reinterpret_cast<IMTRowSet*>(pRS.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to create bitemporal payment slice",mPayerYAAC);
	}
	return S_OK;}
