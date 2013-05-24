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
#include "MTAncestorMgr.h"

#include <autherr.h>
#include <mtbatchhelper.h>

class MTBatchStateCheck : public MTBatchHelper
{
public:
	MTBatchStateCheck()
	{
		mStateMgr.CreateInstance(__uuidof(MTACCOUNTSTATESLib::MTAccountStateManager));
	}
public:
	HRESULT PerformSingleOp(long aIndex,long &aFailedAccount);
public: // data
	ROWSETLib::IMTSQLRowsetPtr mAccountsRs;
	long mAncestor;
protected:
	MTACCOUNTSTATESLib::IMTAccountStateManagerPtr mStateMgr;

};


HRESULT MTBatchStateCheck::PerformSingleOp(long aIndex,long &aFailedAccount)
{
	HRESULT hr = S_OK;
	long targetAccount = mAccountsRs->GetValue("id_acc");
	aFailedAccount = targetAccount;


	if(targetAccount != mAncestor) {
		mStateMgr->Initialize(targetAccount,_bstr_t(mAccountsRs->GetValue("status")));
		if(mStateMgr->GetStateObject()->CanMoveAccount() == VARIANT_FALSE) {
			// move next before throwing the error
			mAccountsRs->MoveNext();
			MT_THROW_COM_ERROR(MT_MOVEACCOUNT_BAD_STATE);
		}
	}
	mAccountsRs->MoveNext();
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// CMTAncestorMgr


STDMETHODIMP CMTAncestorMgr::InterfaceSupportsErrorInfo(REFIID riid)
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

STDMETHODIMP CMTAncestorMgr::Initialize(IMTSessionContext *pCTX,IMTYAAC* pActorYAAC)
{
	try {
		mCTX = pCTX;
		MTYAACLib::IMTYAACPtr pActorYAACPtr(pActorYAAC);
		mActorYAAC = pActorYAACPtr->CopyConstruct();
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to initialize Ancestor Manager");
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

STDMETHODIMP CMTAncestorMgr::HierarchySlice(long AncestorID, DATE RefDate, IMTAccountHierarchySlice **ppSlice)
{
	try {
		MTYAACLib::IMTAccountHierarchySlicePtr slice(__uuidof(MTYAACLib::MTAccountHierarchySlice));
		slice->Initialize(mCTX,AncestorID,RefDate,mActorYAAC);
		*ppSlice = reinterpret_cast<IMTAccountHierarchySlice*>(slice.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to create hierarchy slice at date");
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

STDMETHODIMP CMTAncestorMgr::HierarchySliceNow(long AncestorID, IMTAccountHierarchySlice** ppSlice)
{
	try {
		MTYAACLib::IMTAccountHierarchySlicePtr slice(__uuidof(MTYAACLib::MTAccountHierarchySlice));
		slice->Initialize(mCTX,AncestorID,GetMTOLETime(),mActorYAAC);
		*ppSlice = reinterpret_cast<IMTAccountHierarchySlice*>(slice.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to create hierarchy slice at current system time");
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

STDMETHODIMP CMTAncestorMgr::HierarchyRoot(DATE RefDate,IMTAccountHierarchySlice** ppSlice)
{
	try {
		MTYAACLib::IMTAccountHierarchySlicePtr slice(__uuidof(MTYAACLib::MTAccountHierarchySlice));
		slice->Initialize(mCTX,HIERARCHY_ROOT,RefDate,mActorYAAC);
		*ppSlice = reinterpret_cast<IMTAccountHierarchySlice*>(slice.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to create hierarchy slice for root of hierarchy");
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

STDMETHODIMP CMTAncestorMgr::MoveAccount(long aAncestor, long aDescendent, DATE NewDate)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	long userID = -1;
	try {
		userID = mCTX->GetAccountID();
		deniedEvent = AuditEventsLib::AUDITEVENT_ACCOUNT_UPDATE_DENIED;

		// check for the manageAH capability 
		GENERICCOLLECTIONLib::IMTCollectionExPtr colPtr(__uuidof(GENERICCOLLECTIONLib::MTCollectionEx));
		//only do any checks if ancestor is not root
		//case of "promotion" of a folder to corporation.
		if(aAncestor > 1)
			colPtr->Add(aAncestor);
		colPtr->Add(aDescendent);

		// check auth
		MoveAccountAuthChecks(aAncestor,NewDate,colPtr,NULL,NULL);

		MTYAACEXECLib::IMTAncestorMgrWriterPtr writer(__uuidof(MTYAACEXECLib::MTAncestorMgrWriter));
		writer->MoveAccount(reinterpret_cast<MTYAACEXECLib::IMTSessionContext *>(mCTX.GetInterfacePtr()),
			aAncestor,aDescendent,NewDate);
	}
	catch(_com_error& err) {
		AuditAuthFailures(err, deniedEvent, userID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											aDescendent);

		return returnYAACError(err,"Failed to move account",LOG_ERROR);
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

HRESULT CMTAncestorMgr::MoveAccountAuthChecks(long aAncestor,
																					 DATE aMoveDate,
																					 GENERICCOLLECTIONLib::IMTCollectionPtr pCol,
																					 IMTProgress* pProgress,
																					 IMTRowSet** ppErrors)
{
	MTAUTHLib::IMTSecurityPtr mSecPtr(__uuidof(MTAUTHLib::MTSecurity));
	MTAUTHLib::IMTSecurityContextPtr mSecCtx = mCTX->GetSecurityContext();

	// convert the collection to a collectionEX pointer.	We need this to call ToString
	GENERICCOLLECTIONLib::IMTCollectionExPtr exColPtr = pCol; // QI
	if(exColPtr == NULL) {
		MT_THROW_COM_ERROR("Collection does not implement the IMTCollectionEx interface");
	}

	// step 1: check that all of the accounts are in a valid state
	ROWSETLib::IMTSQLRowsetPtr rs(__uuidof(ROWSETLib::MTSQLRowset));
	rs->Init(ACC_HIERARCHIES_QUERIES);
	rs->SetQueryTag("__LOOKUP_ACCOUNT_STATE_BATCH__");
	rs->AddParam("%%ACCOUNTS%%",exColPtr->ToString());
	_variant_t vtDateVal(aMoveDate,VT_DATE);
	wstring datestr;
	FormatValueForDB(vtDateVal,false,datestr);
	rs->AddParam("%%REFDATE%%",datestr.c_str(),VARIANT_TRUE);
	rs->ExecuteDisconnected();

	// this could happen if no accounts are found at the given date.
	// we return S_OK because we want the MoveAccount back end to return
	// the appropriate error that the account does not exist at the given date
	// or you can't move the account before the start date of the account.
	if(rs->GetRecordCount() == 0) {
		return S_OK;
	}

	bool bFolder = false;
	bool bAccount = true;

  /*bug -- in 5.0 t_av_internal.c_folder can be true, false or null.  The folder related capabilities
   does not determine whether an account can be created or moved underneath.  For this release the folder related 
   capabilities are not used, in future releases, we will create account type specific capabilities.*/
	
  /*for(int i=0;i<rs->GetRecordCount();i++) {
		if((long)rs->GetValue("id_acc") != aAncestor) {
			if(_bstr_t(rs->GetValue("folder")) == bstrYes) {
				bFolder = true;
			}
			else {
				bAccount = true;
			}
		}
		rs->MoveNext();
	}*/

	rs->MoveFirst();


	// step 3: check that we have the required capabilities for the accounts
	// in the batch

		// check for the move account capability
		mSecCtx->CheckAccess(mSecPtr->GetCapabilityTypeByName(MOVE_ACCOUNT_CAP)->CreateInstance());



	MTBatchStateCheck stateCheckObj;
	stateCheckObj.mAccountsRs = rs;
	stateCheckObj.mAncestor = aAncestor;
	ROWSETLib::IMTRowSetPtr errorRS =  
		stateCheckObj.PerformBatchOperation(reinterpret_cast<IMTCollection *>(pCol.GetInterfacePtr()),pProgress);
	if(errorRS->GetRecordCount() > 0) {
		if(ppErrors != NULL) {
			*ppErrors = reinterpret_cast<IMTRowSet*>(errorRS.Detach());
			return S_FALSE;
		}
		else {
			// hmm.... probably just a single move
			MT_THROW_COM_ERROR(MT_MOVEACCOUNT_BAD_STATE);
		}
	}

  // reset the progress object
  if(pProgress) {
    pProgress->Reset();
  }

	// step 2: check auth such that we can manage all of the accounts
	// check that we can manage all of the accounts (in this case, both ancestor and descendent)
	MTAUTHEXECLib::IMTBatchAuthCheckReaderPtr checkPtr(__uuidof(MTAUTHEXECLib::MTBatchAuthCheckReader));
	ROWSETLib::IMTRowSetPtr errorRs = checkPtr->BatchUmbrellaCheck(
		reinterpret_cast<MTAUTHEXECLib::IMTSessionContext *>(mCTX.GetInterfacePtr()),
		reinterpret_cast<MTAUTHEXECLib::IMTCollectionEx *>(exColPtr.GetInterfacePtr()),
		aMoveDate);
	if(errorRs->GetRecordCount() > 0) {
		MT_THROW_COM_ERROR(MTAUTH_ACCESS_DENIED, "");
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

STDMETHODIMP CMTAncestorMgr::MoveAccountBatch(long aAncestor,
																							IMTCollection* pCol,
																							IMTProgress* pProgress,
																							DATE StartDate,
																							IMTRowSet** ppErrors)
{
	try {

		HRESULT hr = MoveAccountAuthChecks(aAncestor,StartDate,pCol,pProgress,ppErrors);
		if(hr == S_FALSE) {
			// hmm.... found an auth error; return
			return S_OK;
		}

		MTYAACEXECLib::IMTAncestorMgrWriterPtr writer(__uuidof(MTYAACEXECLib::MTAncestorMgrWriter));
		_variant_t vtEndDate;
		*ppErrors = reinterpret_cast<IMTRowSet*>(writer->MoveAccountBatch(
			reinterpret_cast<MTYAACEXECLib::IMTSessionContext *>(mCTX.GetInterfacePtr()),
			aAncestor,
			reinterpret_cast<MTYAACEXECLib::IMTCollection*>(pCol),
			reinterpret_cast<MTYAACEXECLib::IMTProgress*>(pProgress),
			StartDate).Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to move account collection; check output collection for details",LOG_ERROR);
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

STDMETHODIMP CMTAncestorMgr::AddToHierarchy(long aAncestor, long aDescendent, DATE StartDate, DATE EndDate)
{
	try {
		MTYAACEXECLib::IMTAncestorMgrWriterPtr writer(__uuidof(MTYAACEXECLib::MTAncestorMgrWriter));
		writer->AddToHierarchy(reinterpret_cast<MTYAACEXECLib::IMTSessionContext *>(mCTX.GetInterfacePtr()),
			aAncestor,aDescendent,StartDate,EndDate);
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to add account to hierarchy",LOG_ERROR);
	}
	return S_OK;
}

