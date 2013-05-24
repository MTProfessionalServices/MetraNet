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
#include "YAAC.h"
#include "formatdbvalue.h"
#include "optionalvariant.h"
#include "IMTAuth_i.c"
#include "MTDate.h"

/////////////////////////////////////////////////////////////////////////////
// C++ specific methods

CMTYAAC& CMTYAAC::operator = (const CMTYAAC& arVal)
{
	// only copy the properties and the session context
  mbLoaded = arVal.mbLoaded;
  mbFolder = arVal.mbFolder;
  mbBillable = arVal.mbBillable;
  mAccountID = arVal.mAccountID;
  mLoginName = arVal.mLoginName;
  mNameSpace = arVal.mNameSpace;
  mHierarchyPath = arVal.mHierarchyPath;
  mCorporateAccountID = arVal.mCorporateAccountID;
  mAccountTypeStr = arVal.mAccountTypeStr;
  mAccountTypeID = arVal.mAccountTypeID;
  mAccStatus = arVal.mAccStatus;
  mAccountName = arVal.mAccountName;
  mCurrentFolderOwner = arVal.mCurrentFolderOwner;
  mSessionContext = arVal.mSessionContext;
  mExternalIdentifier = arVal.mExternalIdentifier;
	return *this;
}

/////////////////////////////////////////////////////////////////////////////
// CMTYAAC

STDMETHODIMP CMTYAAC::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTYAAC,
    &IID_IMTSecurityPrincipal
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Description: Returns a self pointer as a smart pointer
// ----------------------------------------------------------------

MTYAACLib::IMTYAACPtr CMTYAAC::Me()
{
	MTYAACLib::IMTYAACPtr retval(this);
	return retval;
}


// ----------------------------------------------------------------
// Arguments: IMTAccountTemplate ** (the returned template)
// Description:  returns an instance of the account template object.
// THe YAAC Cached this object if the template is already loaded.
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::GetAccountTemplate(VARIANT vRefDate, VARIANT aAccountTypeID, IMTAccountTemplate **pVal)
{
	try 
  {
    GUID guid = __uuidof(MetraTech_Accounts_Type::AccountType);
    MTAccountTypeLib::IMTAccountTypePtr accTypePtr(guid);
    accTypePtr->InitializeByID(mAccountTypeID);

    // Check optional accountypeid.  If not specified, use the accounttype on the yaac.
    _variant_t vtAccountTypeVal;
    if(!OptionalVariantConversion(aAccountTypeID, VT_I4, vtAccountTypeVal))
    {
      vtAccountTypeVal = mAccountTypeID;
    }

    TemplateMap::iterator it = mTemplate.find((long)vtAccountTypeVal);
		if(it == mTemplate.end())
    {
      mTemplate[(long)vtAccountTypeVal].CreateInstance(__uuidof(MTYAACLib::MTAccountTemplate));
	    mTemplate[(long)vtAccountTypeVal]->Initialize(CTXCAST(mSessionContext),mAccountID,mCorporateAccountID, (long)vtAccountTypeVal, vRefDate);
      it = mTemplate.find((long)vtAccountTypeVal);
    }

		*pVal = reinterpret_cast<IMTAccountTemplate*>((it->second).GetInterfacePtr());
		(*pVal)->AddRef();

	}
	catch(_com_error& err)
  {
		return returnYAACError(err);
	}
	return S_OK;
}


// ----------------------------------------------------------------
// Arguments: IMTSQLRowset ** (the rowset has columns, accountTypeName, accountTypeID, templateFolderID, templateDateCreated, templateName, templateDesc )
// Description:  returns a collection of account types, for which templates exist on the account or 
// on the nearest ancestor that has templates.
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::GetTemplatesAsRowset(VARIANT vRefDate, IMTSQLRowset** ppRowset)
{
  if (!ppRowset)
    return E_POINTER;
	try 
  {
    GUID guid = __uuidof(MetraTech_Accounts_Type::AccountType);
    MTAccountTypeLib::IMTAccountTypePtr accTypePtr(guid);
    accTypePtr->InitializeByID(mAccountTypeID);
		if(accTypePtr->CanHaveTemplates == VARIANT_TRUE)
    {

		  QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		  queryAdapter->Init("queries\\accHierarchies");
      queryAdapter->SetQueryTag("__LOAD_ACC_TEMPLATES_FOR_ALL_TYPES__");

      //Check optional date.  If not specified, use MetraTime
      _variant_t vtDateVal;
      if(!OptionalVariantConversion(vRefDate, VT_DATE, vtDateVal))
      {
        vtDateVal = GetMTOLETime();
      }
		  wstring val;
		  FormatValueForDB(vtDateVal, false, val);
		  queryAdapter->AddParam("%%REFDATE%%", val.c_str(), VARIANT_TRUE);
      queryAdapter->AddParam("%%ACCOUNTID%%", mAccountID);
		  MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		  MTYAACEXECLib::IMTSQLRowsetPtr rowsetPtr = reader->ExecuteStatement(queryAdapter->GetQuery());
	    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rowsetPtr.Detach());
		}
		else
    {
			// only folders have templates
			*ppRowset = NULL;
		}

	}
	catch(_com_error& err)
  {
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

STDMETHODIMP CMTYAAC::DeleteTemplate(VARIANT aAccountTypeID, VARIANT_BOOL *bRetVal)
{

  	*bRetVal = VARIANT_FALSE;
	  try {
      GUID guid = __uuidof(MetraTech_Accounts_Type::AccountType);
      MTAccountTypeLib::IMTAccountTypePtr accTypePtr(guid);
      accTypePtr->InitializeByID(mAccountTypeID);
		  if(accTypePtr->CanHaveTemplates == VARIANT_TRUE)
			{
				_variant_t vtDateVal;
				vtDateVal = GetMTOLETime();
        MTYAACLib::IMTAccountTemplatePtr templateToDelete;

        //Check optional accountypeid.  If not specified, use the accounttype on the yaac.
        _variant_t vtAccountTypeVal;
        if(!OptionalVariantConversion(aAccountTypeID, VT_I4, vtAccountTypeVal))
        {
          vtAccountTypeVal = mAccountTypeID;
        }

				templateToDelete = Me()->GetAccountTemplate(vtDateVal, aAccountTypeID);
				if (templateToDelete != NULL)
				{
          TemplateMap::iterator it = mTemplate.find((long)vtAccountTypeVal);
          MTYAACEXECLib::IMTAccTemplateWriterPtr writer(__uuidof(MTYAACEXECLib::MTAccTemplateWriter));
					long templateID;
					templateID = templateToDelete->ID;
					writer->DeleteTemplate(templateID);
          mTemplate.erase(it);
					*bRetVal = VARIANT_TRUE;
					return S_OK;
				}
				else
				{
					//no template to delete
					MT_THROW_COM_ERROR(MT_NO_TEMPLATE_FOUND);
				}
			}
			else
			{   //TODO : create a type specific error
					//account is not a folder, so template does not exist
				MT_THROW_COM_ERROR(MT_ACCOUNT_NOT_A_FOLDER);
			}
		}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to delete account template",LOG_ERROR);
	}
	return S_OK;
}

STDMETHODIMP CMTYAAC::GetAccountTemplateType(long *pVal)
{
	*pVal = 0;
	try {
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
		queryAdapter->SetQueryTag("__LOAD_ACC_TEMPLATE_TYPE__");
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		MTYAACEXECLib::IMTSQLRowsetPtr rs = reader->ExecuteStatement(queryAdapter->GetQuery());

		// add the children to the collection
		if(rs->GetRecordCount() > 0) {
			*pVal = (long)rs->GetValue(1l);
		}
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to lookup account template type",Me());
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Description: returns the YAAC account ID
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::get_AccountID(long *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	*pVal = mAccountID;
	return S_OK;
}

// ----------------------------------------------------------------
// Arguments: SessionContext,optional data
// Description:  Initializes the YAAC as the account specified
// in the security context.  This method is usually used when you are using
// the YAAC to perform operations on behalf of the logged in user (or the 
// user from which the session context was generated)
//
// If the date is not specified, the current system time is used
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::InitAsActor(IMTSessionContext *pCTX,VARIANT RefDate)
{
	try {
    if (!pCTX)
	  	return E_POINTER;
		mSessionContext = pCTX;
		MTAUTHLib::IMTSecurityContextPtr secCtx = mSessionContext->GetSecurityContext();
		mAccountID = secCtx->GetAccountID();
    LookupAccountProperties(RefDate);
    InitPrincipalType();
    // make sure we set the account ID on the base class
    MTSecurityPrincipalImplBase<IMTYAAC, &IID_IMTYAAC, &LIBID_MTYAACLib>
    ::put_ID(mAccountID);	
	}
	catch(_com_error& err) {
		return returnYAACError(err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Arguments: AccountID, sessioncontext, optional Date
// Description: used when initializing the YAAC when performing operations
// on the passed in account ID.  The sessioncontext is used for authorization
// checks against any specific operations.  The date parameter is used
// when fetching the current account state, hierarchy, or payment information.
//
// If the date is not specified, the current system time is used
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::InitAsSecuredResource(long aAccountID, IMTSessionContext *pCTX,VARIANT RefDate)
{
	try {
    if (!pCTX)
	  	return E_POINTER;
  	mSessionContext = pCTX;
		mAccountID = aAccountID;
    LookupAccountProperties(RefDate);
    InitPrincipalType();
    // make sure we set the account ID on the base class
    MTSecurityPrincipalImplBase<IMTYAAC, &IID_IMTYAAC, &LIBID_MTYAACLib>
    ::put_ID(mAccountID);	
	}
	catch(_com_error& err) {
		return returnYAACError(err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Arguments: Name,Namespace,SessionContext, optional date
// Description:   Same as InitAsSecuredResource except that the YAAC
// looks up the account by loginname and namespace instead of account ID
//
// If the date is not specified, the current system time is used
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::InitByName(BSTR aName,
                                 BSTR aNamespace,
                                 IMTSessionContext* pCTX,
                                 VARIANT RefDate)
{
	try {
	  mSessionContext = pCTX;
    LookupAccountByName(aName,aNamespace,RefDate);
    InitPrincipalType();
		// make sure we set the account ID on the base class
    MTSecurityPrincipalImplBase<IMTYAAC, &IID_IMTYAAC, &LIBID_MTYAACLib>
    ::put_ID(mAccountID);	
    ASSERT(mAccountID > 0);
	}
	catch(_com_error& err) {
		return returnYAACError(err);
	}
	return S_OK;
}



// ----------------------------------------------------------------
// Arguments: Payment Mgr class (return)
// Description: Returns payment factory class.  Note that the YAAC
// caches the object and returns a preinitialized reference if
// it already exists.
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::GetPaymentMgr(IMTPaymentMgr **ppPaymentMgr)
{
	try {

		if(mPaymentMgr == NULL) {
			mPaymentMgr.CreateInstance(__uuidof(MTYAACLib::MTPaymentMgr));
			mPaymentMgr->Initialize(CTXCAST(mSessionContext),mbBillable ? VARIANT_TRUE : VARIANT_FALSE,
				(MTYAACLib::IMTYAAC*)this);
		}
		*ppPaymentMgr = reinterpret_cast<IMTPaymentMgr*>(mPaymentMgr.GetInterfacePtr());
		(*ppPaymentMgr)->AddRef();

	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to get payment manager",Me());
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Arguments: account state Mgr (return)
// Description: returns a reference to the account state mgr factory 
// class.  Note that this class is initialized by the current YAAC's account
// state (which is looked up based on the passed in date at initialization time)
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::GetAccountStateMgr(IMTAccountStateManager **ppMgr)
{
	try {
		if(mStateMgr == NULL) {
			mStateMgr.CreateInstance(__uuidof(MTACCOUNTSTATESLib::MTAccountStateManager));
			mStateMgr->Initialize(mAccountID,mAccStatus);
		}
		*ppMgr = reinterpret_cast<IMTAccountStateManager*>(mStateMgr.GetInterfacePtr());
		(*ppMgr)->AddRef();
	}
	catch(_com_error& err) {
		return returnYAACError(err,"failed to get account state manager",Me());
	}
	return S_OK;
}


// ----------------------------------------------------------------
// Arguments: optional system date, rowset (return)
// Return Value:  rowset of account state information
// Description:  Retreives the account state history.  If no system date
// is specified, the system retrieves the current history of account state.
// If the user specifies a system date, the method uses the bitemporal
// information to display what the state history looked like at a specific time.
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::GetStateHistory(VARIANT SystemDate, IMTSQLRowset **ppRowset)
{
	try {
		// step 1: create the query string
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);

    _variant_t systemDate;
    if(OptionalVariantConversion(SystemDate,VT_DATE,systemDate)) {
      queryAdapter->SetQueryTag("__GET_STATE_HISTORY__");
	    queryAdapter->AddParam("%%ID_ACC%%", mAccountID);
      wstring tempStr;
      FormatValueForDB(systemDate,FALSE,tempStr);
	    queryAdapter->AddParam("%%SYSTEMDATE%%", tempStr.c_str(),VARIANT_TRUE);
    }
    else {
    queryAdapter->SetQueryTag("__GET_STATE_HISTORY__");
		queryAdapter->AddParam("%%ID_ACC%%", mAccountID);
    }

		// step 2: create the reader executant
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));

		MTYAACEXECLib::IMTSQLRowsetPtr rowsetPtr = reader->ExecuteStatement(queryAdapter->GetQuery());
		*ppRowset = reinterpret_cast<IMTSQLRowset*>(rowsetPtr.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to lookup account state history",Me());
	}
	return S_OK;
}

void CMTYAAC::ManageAHAuthCheck(GENERICCOLLECTIONLib::IMTCollectionExPtr pCol)
{
  MTAUTHEXECLib::IMTBatchAuthCheckReaderPtr checkPtr(__uuidof(MTAUTHEXECLib::MTBatchAuthCheckReader));
  ROWSETLib::IMTRowSetPtr errorRs = checkPtr->BatchUmbrellaCheck(
		reinterpret_cast<MTAUTHEXECLib::IMTSessionContext *>(mSessionContext.GetInterfacePtr()),
		reinterpret_cast<MTAUTHEXECLib::IMTCollectionEx *>(pCol.GetInterfacePtr()),
		GetMTOLETime());
	if(errorRs->GetRecordCount() > 0) {
		MT_THROW_COM_ERROR(MTAUTH_ACCESS_DENIED, "");
	}

}


// ----------------------------------------------------------------
// Arguments: folder account ID
// Description:   Makes the current YAAC the owner of the folder.  Folder
// ownership simply implies that the owner also gets access to the capabilities
// that are configured on the folder.
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::AddOwnedFolderByID(long aFolderID)
{
	HRESULT hr = S_OK;
	try {
		long existingOwner = 0;

    // check auth
    GENERICCOLLECTIONLib::IMTCollectionExPtr colPtr(__uuidof(GENERICCOLLECTIONLib::MTCollectionEx));
    colPtr->Add(aFolderID);
    colPtr->Add(mAccountID);
    ManageAHAuthCheck(colPtr);

		MTYAACEXECLib::IMTFolderOwnerWriterPtr writer(__uuidof(MTYAACEXECLib::MTFolderOwnerWriter));
		existingOwner = writer->AddOwnedFolder(aFolderID,mAccountID);
    if(existingOwner != 0) {
      MT_THROW_COM_ERROR(MT_EXISTING_FOLDER_OWNER);
    }
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to add folder owner",Me());
	}
	return hr;
}

// ----------------------------------------------------------------
// Arguments: folder account ID
// Description: removes ownership relationship for the specified folder
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::RemovedOwnedFolderById(long aFolderID)
{
	try {

    // check auth
    GENERICCOLLECTIONLib::IMTCollectionExPtr colPtr(__uuidof(GENERICCOLLECTIONLib::MTCollectionEx));
    colPtr->Add(aFolderID);
    colPtr->Add(mAccountID);
    ManageAHAuthCheck(colPtr);

		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
    queryAdapter->SetQueryTag("__REMOVE_OWNED_FOLDER__");
		queryAdapter->AddParam("%%ID_ACC%%", mAccountID);
		queryAdapter->AddParam("%%FOLDER%%", aFolderID);

		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		reader->ExecuteStatement(queryAdapter->GetQuery());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to remove folder owner",Me());
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Return Value:  rowset of owned folders
// Description:   retrieves the list of folders owned by the YAAC
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::GetOwnedFolderList(IMTSQLRowset **ppRowset)
{
	try {
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
    queryAdapter->SetQueryTag("__FIND_OWNED_FOLDERS__");
		queryAdapter->AddParam("%%ID_ACC%%", mAccountID);

		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		MTYAACEXECLib::IMTSQLRowsetPtr rowsetPtr = reader->ExecuteStatement(queryAdapter->GetQuery());
		*ppRowset = reinterpret_cast<IMTSQLRowset*>(rowsetPtr.Detach());	
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to get list of owned folders",Me());
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Return Value:  Ancestor Mgr factory
// Description:   Retrieves the cached ancestor mgr factory.  If it does
// not exist, it is created.
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::GetAncestorMgr(IMTAncestorMgr **ppMgr)
{
	// TODO: Add your implementation code here
	try {
		if(mAncestorMgr == NULL) {
			mAncestorMgr.CreateInstance(__uuidof(MTYAACLib::MTAncestorMgr));
			mAncestorMgr->Initialize(CTXCAST(mSessionContext),Me());
		}
		*ppMgr = reinterpret_cast<IMTAncestorMgr*>(mAncestorMgr.GetInterfacePtr());
		(*ppMgr)->AddRef();
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to get ancestor manager",Me());
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Description:   VARIANT_BOOL that indicates the account is a folder
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::get_IsFolder(VARIANT_BOOL *pVal)
{
	*pVal = mbFolder ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}

// ----------------------------------------------------------------
// Description:   Saves the account security information.  Does
// not persist any account information specific to the YAAC.
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::Save()
{
	return MTSecurityPrincipalImplBase<IMTYAAC, &IID_IMTYAAC, &LIBID_MTYAACLib>
    ::Save(reinterpret_cast<IMTSecurityPrincipal*>(this));
}

void CMTYAAC::LookupAccountByName(BSTR aName,BSTR aNameSpace,VARIANT RefDate)
{
  MTYAACEXECLib::IMTYAACReaderPtr reader("MetraTech.MTYAACReader");

  MTYAACLib::IMTYAACPtr acc = reader->GetYAACByName
    (reinterpret_cast<MTYAACEXECLib::IMTSessionContext*>(mSessionContext.GetInterfacePtr()), aName, aNameSpace, RefDate);
  CMTYAAC* pInternalYAAC;
  HRESULT hr = acc.QueryInterface(IID_NULL,(void**)&pInternalYAAC);
  if(FAILED(hr))
    MT_THROW_COM_ERROR("Failed to query for IID_NULL");
  CMTYAAC::operator =(*pInternalYAAC);
}

// ----------------------------------------------------------------
// Description:   Internal method that looks an account by account ID.
// ----------------------------------------------------------------

void CMTYAAC::LookupAccountProperties(VARIANT RefDate)
{
  // special case for root account
  if(mAccountID != 1)
  {
    MTYAACEXECLib::IMTYAACReaderPtr reader("MetraTech.MTYAACReader");
    MTYAACLib::IMTYAACPtr acc = reader->GetYAAC
      (reinterpret_cast<MTYAACEXECLib::IMTSessionContext*>(mSessionContext.GetInterfacePtr()), mAccountID, RefDate);
    CMTYAAC* pInternalYAAC;
		HRESULT hr = acc.QueryInterface(IID_NULL,(void**)&pInternalYAAC);
    if(FAILED(hr))
      MT_THROW_COM_ERROR("Failed to query for IID_NULL");
    CMTYAAC::operator =(*pInternalYAAC);
    
  }
}

// ----------------------------------------------------------------
// Name:     
// Arguments: Query Fragment (selects account), optional date, account ID (if present),loginname
// Description:   Internal method that builds query to load account properties
// ----------------------------------------------------------------

void CMTYAAC::LookupAccountInternal(BSTR QueryFragment,VARIANT RefDate,long accountID,const char* ploginName)
{
	if(mbLoaded) return;
  ASSERT(ploginName != NULL);

	try 
{
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));

		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
    queryAdapter->SetQueryTag("__LOAD_YAAC_PROPERTIES__");
		queryAdapter->AddParam("%%NAMESPACE_CRITERIA%%",QueryFragment,VARIANT_TRUE);
	
    _variant_t vtDateVal;
    if(!OptionalVariantConversion(RefDate,VT_DATE,vtDateVal)) {
      vtDateVal = GetMTOLETime();
    }

		wstring val;
		FormatValueForDB(vtDateVal,false,val);
		queryAdapter->AddParam("%%REFDATE%%",val.c_str(),VARIANT_TRUE);
		MTYAACLib::IMTSQLRowsetPtr rowsetPtr = reader->ExecuteStatement(queryAdapter->GetQuery());
		if(rowsetPtr->GetRecordCount() == 0) {

      // note: MTDATE does not support date time; only the date.
      MTDate conversionDate((DATE)vtDateVal);
      string tempBuf;
      conversionDate.ToString("%m/%d/%Y",tempBuf);
      if(accountID < 0) {
        MT_THROW_COM_ERROR(MT_YAAC_ACCOUNT_NOT_FOUND_STR,ploginName,tempBuf.c_str());
      }
      else {
        MT_THROW_COM_ERROR(MT_YAAC_ACCOUNT_NOT_FOUND,accountID,tempBuf.c_str());
      }
		}
		else {
			mbBillable = (_bstr_t(rowsetPtr->GetValue("billable")) == bstrYes) ? true : false;
			mbFolder = (_bstr_t(rowsetPtr->GetValue("IsFolder")) == bstrYes) ? true : false;
			mLoginName = rowsetPtr->GetValue("nm_login");
			mHierarchyPath = rowsetPtr->GetValue("tx_path");
			mCorporateAccountID = rowsetPtr->GetValue("corporate_acc");
			mAccountTypeStr = rowsetPtr->GetValue("acc_type");
      mAccountTypeID = rowsetPtr->GetValue("AccountTypeID");
			mAccStatus = rowsetPtr->GetValue("status");
      // necessary if resolving by user name and namespace
      mAccountID = rowsetPtr->GetValue("id_acc");
      mNameSpace = rowsetPtr->GetValue("namespace");
      mAccountName = rowsetPtr->GetValue("accountname");
      // lookup the account external identifier and convert the value to a string
      MTMiscUtil::GuidToString(rowsetPtr->GetValue("id_acc_ext"),mExternalIdentifier);

      _variant_t vtCurrentOwner = rowsetPtr->GetValue("owner");
      if(vtCurrentOwner.vt != VT_NULL) {
        mCurrentFolderOwner = vtCurrentOwner;
      }
			mbLoaded = true;
		}
	}
	catch(_com_error& err) {
		returnYAACError(err,"Failed to load account properties", LOG_WARNING);
    throw err;
	}

}


// ----------------------------------------------------------------
// Description:   retrieves the account login name
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::get_LoginName(BSTR *pVal)
{
	*pVal = mLoginName.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Description:   retreives account namespace (is of type 'system_mps')
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::get_Namespace(BSTR* apVal)
{
  *apVal = mNameSpace.copy();
  return S_OK;
}


// ----------------------------------------------------------------
// Description:   Retrieves the hierarchy path, a string 
// that uniquely identifies the account in the hierarchy.
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::get_HierarchyPath(BSTR *pVal)
{
	*pVal = mHierarchyPath.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Description:   The corporate account ID.  This property never
// changes (it is set by account creation)
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::get_CorporateAccountID(long *pVal)
{
	*pVal = mCorporateAccountID;
	return S_OK;
}


// ----------------------------------------------------------------
// Description: Get the account type  
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::get_AccountType(BSTR *pVal)
{
	*pVal = mAccountTypeStr.copy();
	return S_OK;
}

STDMETHODIMP CMTYAAC::get_AccountTypeID(long *pVal)
{
	*pVal = mAccountTypeID;
	return S_OK;
}

// ----------------------------------------------------------------
// Description:  Internal method to specify the type of security
// principal based on the account type
// ----------------------------------------------------------------

void CMTYAAC::InitPrincipalType()
{
  MTYAACLib::IMTYAACPtr thisPtr = this;
  _bstr_t accType = thisPtr->AccountType;
	
  if( _wcsicmp((wchar_t*)accType, L"SYSTEMACCOUNT") == 0 )
    MTSecurityPrincipalImplBase<IMTYAAC, &IID_IMTYAAC, &LIBID_MTYAACLib>
    ::put_PrincipalType(CSR_ACCOUNT_PRINCIPAL);	
  else
    MTSecurityPrincipalImplBase<IMTYAAC, &IID_IMTYAAC, &LIBID_MTYAACLib>
    ::put_PrincipalType(SUBSCRIBER_ACCOUNT_PRINCIPAL);	
}



// ----------------------------------------------------------------
// Return Value:  new YAAC
// Description:   Copies all of the properties of the YAAC.  Does not
// copy any of the cached factory objects.
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::CopyConstruct(IMTYAAC** pNewYaac)
{
	try {
		MTYAACLib::IMTYAACPtr copyYAAC(__uuidof(MTYAACLib::MTYAAC));
		CMTYAAC* pInternalYAAC;
		HRESULT hr = copyYAAC.QueryInterface(IID_NULL,(void**)&pInternalYAAC);
		if(SUCCEEDED(hr)) {
			*pInternalYAAC = *this;
		}
		else {
			// hmm.. can't query for internal C++ object. perhaps we are running in
			// a different process?  We will have to do it the hard way
			LogYAACError("Failed to query for internal YAAC C++ object",LOG_WARNING);
			copyYAAC->InitAsSecuredResource(mAccountID,
				reinterpret_cast<MTYAACLib::IMTSessionContext *>(mSessionContext.GetInterfacePtr()));
		}
		*pNewYaac = reinterpret_cast<IMTYAAC*>(copyYAAC.Detach());
	}
	catch(_com_error& err) 
  {
		return returnYAACError(err);
	}
	return S_OK;
}

// method used when querying for IID_NULL
HRESULT WINAPI _This(void* pv,REFIID iid,void** ppvObject,DWORD)
{
  ATLASSERT(iid == IID_NULL);
  *ppvObject = pv;
  return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  VARIANT_BOOL indicating if account specified by 
// the security context can manage the target account
// Description:  Demands the managing account hierarchies capability
// from the security context to determine if the account can be managed.
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::CanManageAccount(VARIANT_BOOL *pRetVal)
{
	*pRetVal = VARIANT_FALSE;
	try {
		MTAUTHLib::IMTSecurityContextPtr secCtx = mSessionContext->GetSecurityContext();

    if(_wcsicmp((wchar_t*)mAccountTypeStr, L"IndependentAccount") == 0) {
      //Check manage independent accounts
      MTAUTHLib::IMTSecurityPtr secPtr(__uuidof(MTAUTHLib::MTSecurity));
	  	MTAUTHLib::IMTCompositeCapabilityPtr capPtr = secPtr->GetCapabilityTypeByName(MANAGE_NON_HIER_ACCOUNTS_CAP)->CreateInstance();
      MTAUTHLib::IMTEnumTypeCapabilityPtr enumPtr = capPtr->GetAtomicEnumCapability();
      enumPtr->SetParameter("WRITE");
      (*pRetVal) = secCtx->HasAccess(capPtr);
    } else {
      //Check hierarchical
  		MTAUTHLib::IMTSecurityPtr secPtr(__uuidof(MTAUTHLib::MTSecurity));
	  	MTAUTHLib::IMTCompositeCapabilityPtr capPtr = secPtr->GetCapabilityTypeByName(MANAGE_HIERARCHY_CAP)->CreateInstance();
		  MTAUTHLib::IMTPathCapabilityPtr pathPtr = capPtr->GetAtomicPathCapability();
		  pathPtr->SetParameter(mHierarchyPath,MTAUTHLib::SINGLE);
      MTAUTHLib::IMTEnumTypeCapabilityPtr enumPtr = capPtr->GetAtomicEnumCapability();
      enumPtr->SetParameter("WRITE");
      (*pRetVal) = secCtx->HasAccess(capPtr);
    }
	}
	catch(_com_error& err) 
  {
		return returnYAACError(err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Arguments: Target collection, optional Date (defaults to system date),
// treeHint (indicates all descendents, direct discendents, no descendents),
// include folders in query
// Description:  Fetches all accounts underneath the target folder into 
// the passed in collection.
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::GetDescendents(IMTCollection *pCol,
																		 DATE RefDate,
																		 MTHierarchyPathWildCard treeHint, 
																		 VARIANT_BOOL IncludeFolders,
                                     /*[in, optional]*/ VARIANT pAccountTypeNameList)
{
	try {
		if(!pCol) {
			return Error("GetDescendents: valid collection object required");
		}

		MTYAACLib::IMTCollectionPtr pColPtr(pCol);
    MTYAACLib::IMTCollectionPtr pAccountTypes = NULL;
    
    _variant_t vtAccountTypeVal;
    if(OptionalVariantConversion(pAccountTypeNameList, VT_DISPATCH, vtAccountTypeVal))
    {
      pAccountTypes = vtAccountTypeVal;
    }


		if(treeHint ==  MTYAACLib::SINGLE) {
			if(IncludeFolders == VARIANT_FALSE && mbFolder) {
				// nothing to do
				return S_OK;
			}
			// add ourselves to the collection
			pColPtr->Add(mAccountID);
			return S_OK;
		}

		// build the query to fetch the descendents
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
		queryAdapter->SetQueryTag("__FIND_DESCENDENTS__");
		queryAdapter->AddParam("%%ANCESTOR%%",mAccountID);

		if(IncludeFolders == VARIANT_FALSE) {
			queryAdapter->AddParam(" %%NOFOLDERS%%"," AND tav.c_folder <> '1'",VARIANT_TRUE);
		}
		else {
			queryAdapter->AddParam(" %%NOFOLDERS%%","");
		}

		wstring dateStr;
		FormatValueForDB(_variant_t(RefDate,VT_DATE),FALSE,dateStr);
		queryAdapter->AddParam("%%REFDATE%%",dateStr.c_str(),VARIANT_TRUE);

		switch(treeHint) {
		case MTYAACLib::DIRECT_DESCENDENTS:
				queryAdapter->AddParam(" %%NUMGENERATIONS%%","AND num_generations in (0,1)");
				break;
		case MTYAACLib::RECURSIVE:
				queryAdapter->AddParam(" %%NUMGENERATIONS%%","");
				break;
		default:
				MT_THROW_COM_ERROR("unknown MTHierarchyPathWildCard type");
		}

    //set %%ACCTYPE_PREDICATE%% param
    if(pAccountTypes == NULL || pAccountTypes->Count == 0)
    {
      queryAdapter->AddParam("%%ACCTYPE_PREDICATE%%", "1=1", VARIANT_TRUE);
    }
    else
    {
      _bstr_t accTypePredicate = "upper(atype.name) IN ";
      bool first = true;
      for (int i = 1; i <= pAccountTypes->Count; i++)
      {
        char buf[256];
        _bstr_t accTypeName = (_bstr_t)pAccountTypes->GetItem(i);
        if(first)
        {
          first = false;
          accTypePredicate += _bstr_t("(");
        }
        else
          accTypePredicate += _bstr_t(", ");
		accTypePredicate += _bstr_t("upper(");
        sprintf(buf, "'%s'", (const char*)accTypeName);
        accTypePredicate += _bstr_t(buf);
		accTypePredicate += _bstr_t(")");
      }
      if(first == false)
        accTypePredicate += _bstr_t(")");
      queryAdapter->AddParam("%%ACCTYPE_PREDICATE%%", accTypePredicate, VARIANT_TRUE);
    }

		MTYAACEXECLib::IMTSQLRowsetPtr rs = reader->ExecuteStatement(queryAdapter->GetQuery());

		// add the children to the collection
		for(int i=0;i<rs->GetRecordCount();i++) {
			pColPtr->Add(rs->GetValue(0l));
			rs->MoveNext();
		}

	}
	catch(_com_error& err) {
		return returnYAACError(err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: Optional date (defaults to system date)
// Return Value:  read only collection of corporate accounts
// Description: returns a list of corporate accounts that are accessible
// by the current security context
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::AccessibleCorporateAccounts(VARIANT RefDate,
                                                  IMTCollectionReadOnly** ppCol)
{
  try {
    MTYAACLib::IMTYAACPtr pThis = this;

    if(mAcessibleCol == NULL) {
      _variant_t vtRefDate;
      if(!OptionalVariantConversion(RefDate,VT_DATE,vtRefDate)) {
        vtRefDate = GetMTOLETime();
      }
      mAcessibleCol.CreateInstance(__uuidof(GENERICCOLLECTIONLib::MTCollection));


      // first, see if the user has the capability to manage all corporate accounts.


      // iterate through our security context, finding all the managable corporate accounts
      MTAUTHLib::IMTSecurityContextPtr secCtx = mSessionContext->GetSecurityContext();

      MTAUTHLib::IMTSecurityPtr secPtr(__uuidof(MTAUTHLib::MTSecurity));
      MTAUTHLib::IMTCompositeCapabilityPtr manageAHCapability = 
        secPtr->GetCapabilityTypeByName(MANAGE_HIERARCHY_CAP)->CreateInstance();
      //part of CR 8598 fix: We should really only request SINGLE, and not RECURSIVE
      //PathCapability
      //If I was given a capability to Manage Root (SINGLE) or Manage Root and It's
      //direct descendants, HIERARCHY_ROOT should still be added as my accessible corporate account 
      manageAHCapability->GetAtomicPathCapability()->SetParameter("/",MTAUTHLib::RECURSIVE);

      if(secCtx->HasAccess(manageAHCapability) == VARIANT_TRUE) 
      {
        // Great.  This wonderful person can manage all corporate accounts.
        if(mCorporateAccountID != HIERARCHY_ROOT) 
        {
          mAcessibleCol->Add(HIERARCHY_ROOT);
        }
      }
      //CR 12263: If this wonderful person has Manage SFH cap, 
      //then this wonderful person can view all subscriber corporations (because he needs to assign ownerships to these accounts)
      else if (secCtx->GetCapabilitiesOfType("Manage Sales Force Hierarchies")->GetCount() > 0)
      {
        mAcessibleCol->Add(HIERARCHY_ROOT);
      }
      else {
        // bummer.  I need to interate through the security context and build a collection of 
        // the managable corporate accounts.
        MTAUTHLib::IMTCollectionPtr colPtr = secCtx->GetCapabilitiesOfType(MANAGE_HIERARCHY_CAP);

        for(int i=1;i<=colPtr->GetCount();i++) {
          MTAUTHLib::IMTCompositeCapabilityPtr capPtr = colPtr->GetItem(i);
          _bstr_t pathstr = (const wchar_t*)capPtr->GetAtomicPathCapability()->GetParameter()->GetPath();
          //CR 8598 fix: Path could be just "/*", or "/" ('/-' case is caught by HasAccess call above). 
          //In this case _wtol(pathstr); call will fail
          //The least intrusive way (but not necessarily the right way in the long run) would be to gracefully
          //check for the value of the string and if it's one of those above, then don't add anything to a list
          //of accessible corporate accounts, just return. Since AccessibleCorporateAccounts() method is used
          //by the SQL finder object to derive the info about which accounts a user can or can not search, I don't want to
          //revisit right now the meaning of '/' or '/*' in this context.
          if( _wcsicmp((wchar_t*)pathstr, L"/") != 0 &&
            _wcsicmp((wchar_t*)pathstr, L"/*") != 0 )
          {
            pathstr = wcstok(pathstr,L"/");
            long tempCorpAccount = _wtol(pathstr);
            if(tempCorpAccount != mCorporateAccountID) 
            {
              mAcessibleCol->Add(tempCorpAccount);
            }
          }
        }
      }

      // always add the account's corporate account to the list
      //BP: Since in 5.0 Corporate account property will be -1 for system accounts,
      //try and be backward compatible - add accountid instead, so that the search worked the 
      //way it did.
      mAcessibleCol->Add(mCorporateAccountID < 0 ? mAccountID : mCorporateAccountID);

    }

    GENERICCOLLECTIONLib::IMTCollectionReadOnlyPtr pReadOnly = mAcessibleCol; // QI
    *ppCol = reinterpret_cast<IMTCollectionReadOnly*>(pReadOnly.Detach());
  }
  catch(_com_error& err) {
    return returnYAACError(err);
  }
  return S_OK;

}

// ----------------------------------------------------------------
// Description: retrieves the account name
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::get_AccountName(BSTR *pVal)
{
  *pVal = mAccountName.copy();
  return S_OK;
}

// ----------------------------------------------------------------
// Arguments: Collection of folder account Id's, progress object
// Return Value:  error rowset
// Description:  Batch interface to adding a number of owned folders
// at once to the same account.
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::SetOwnedFoldersBatch(IMTCollectionEx *pCol, IMTProgress *pProgress, IMTRowSet **ppErrors)
{
  try {
    ManageAHAuthCheck(pCol);

		MTYAACEXECLib::IMTFolderOwnerWriterPtr writer(__uuidof(MTYAACEXECLib::MTFolderOwnerWriter));
    *ppErrors = reinterpret_cast<IMTRowSet*>(writer->AddOwnedFoldersBatch(mAccountID,
      reinterpret_cast<MTYAACEXECLib::IMTCollection *>(pCol),
      reinterpret_cast<MTYAACEXECLib::IMTProgress *>(pProgress)).Detach());
  }
	catch(_com_error& err) {
		return returnYAACError(err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Arguments: SessionContext, XML String
// Description:   Initialize the YAAC from XML
// ----------------------------------------------------------------


STDMETHODIMP CMTYAAC::FromXML(IMTSessionContext* aCtx, BSTR aXmlString)
{
	try
	{
    MTYAACLib::IMTYAACPtr thisPtr = this;
    MSXML2::IXMLDOMNodePtr prNode = NULL;
    MSXML2::IXMLDOMNodePtr attribNode;
    MSXML2::IXMLDOMNamedNodeMapPtr attribs;
		MSXML2::IXMLDOMDocumentPtr domdoc("Microsoft.XMLDOM");
    domdoc->loadXML(aXmlString);
		prNode = domdoc->selectSingleNode(PRINCIPAL_TAG);
    attribs = prNode->attributes;
    attribNode = attribs->getNamedItem(TYPE_ATTRIB);
    if(attribNode == NULL)
    {
      LogYAACError("'type' attribute not found", LOG_ERROR);
      MT_THROW_COM_ERROR(MTAUTH_YAAC_DESERIALIZATION_FAILED);
    }
    _variant_t vAttribValue = attribNode->nodeValue;
    if((_bstr_t)vAttribValue != _bstr_t("account"))
    {
      LogYAACError("Principal Type not account", LOG_ERROR);
      MT_THROW_COM_ERROR(MTAUTH_YAAC_DESERIALIZATION_FAILED);
    }
    attribNode = attribs->getNamedItem(NAME_ATTRIB);
    if(attribNode == NULL)
    {
      LogYAACError("'name' attribute not found", LOG_ERROR);
      MT_THROW_COM_ERROR(MTAUTH_YAAC_DESERIALIZATION_FAILED);
    }

    vAttribValue = attribNode->nodeValue;
    _bstr_t accName = (_bstr_t)vAttribValue;
    _bstr_t accNameSpace = "auth";
    
    attribNode = attribs->getNamedItem("namespace");
    if(attribNode != NULL)
    {
      accNameSpace = (_bstr_t)attribNode->nodeValue;
    }

    thisPtr->InitByName(accName,accNameSpace, (MTYAACLib::IMTSessionContext*)aCtx);
    return MTSecurityPrincipalImplBase<IMTYAAC, &IID_IMTYAAC, &LIBID_MTYAACLib>::FromXML(aCtx, aXmlString);
	}
	catch(_com_error& e)
	{
		return returnYAACError(e);
	}

	return S_OK;
}

// ----------------------------------------------------------------
// Arguments: 
// Description:   
// ----------------------------------------------------------------


STDMETHODIMP CMTYAAC::ToXML(BSTR* apXmlString)
{
	try
	{
    return E_NOTIMPL;
	}
	catch(_com_error& e)
	{
		return returnYAACError(e);
	}

	return S_OK;
}

// ----------------------------------------------------------------
// Arguments: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::get_CurrentFolderOwner(long *pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_POINTER;
  *pVal = mCurrentFolderOwner;
	return S_OK;
}

// ----------------------------------------------------------------
// Arguments: optional date
// Description:  Reload the YAAC with the optional date
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::Refresh(VARIANT RefDate)
{
  try {
    mTemplate.clear();
    mPaymentMgr = NULL;
    mStateMgr = NULL;
    mAncestorMgr = NULL;
    mAcessibleCol = NULL;
    mbLoaded = false;
    
    MTYAACLib::IMTYAACPtr pThis = this;
    pThis->InitAsSecuredResource(mAccountID,
      reinterpret_cast<MTYAACLib::IMTSessionContext *>(mSessionContext.GetInterfacePtr()),RefDate);
  }
  catch(_com_error& err) {
		return returnYAACError(err);
  }
	return S_OK;
}

// ----------------------------------------------------------------
// return value: Account External Identifier (returned as a GUID)
// Description:  retrieves the GUID for the account
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::get_AccountExternalIdentifier(BSTR *pVal)
{
  *pVal = mExternalIdentifier.copy();
  return S_OK;
}

STDMETHODIMP CMTYAAC::UpdateOwnedFolder(long aFolderID)
{
	HRESULT hr = S_OK;
	try {
		long existingOwner = 0;

    // check auth
    GENERICCOLLECTIONLib::IMTCollectionExPtr colPtr(__uuidof(GENERICCOLLECTIONLib::MTCollectionEx));
    colPtr->Add(aFolderID);
    colPtr->Add(mAccountID);
    ManageAHAuthCheck(colPtr);

		MTYAACEXECLib::IMTFolderOwnerWriterPtr writer(__uuidof(MTYAACEXECLib::MTFolderOwnerWriter));
		writer->UpdateFolderOwner(aFolderID,mAccountID);
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to update folder owner",Me());
	}
	return hr;
}


// ----------------------------------------------------------------
// Arguments: Payment Mgr class (return)
// Description: Returns payment factory class.  Note that the YAAC
// caches the object and returns a preinitialized reference if
// it already exists.
// ----------------------------------------------------------------

STDMETHODIMP CMTYAAC::GetOwnershipMgr(IDispatch **ppOwnershipMgr)
{
  if (!ppOwnershipMgr)
		return E_POINTER;
  (*ppOwnershipMgr) = NULL;

	try 
  {
		if(mOwnershipMgr == NULL) {
			mOwnershipMgr.CreateInstance(__uuidof(MetraTech_Accounts_Ownership::OwnershipMgr));
			mOwnershipMgr->Initialize(CTXCASTTOAUTH(mSessionContext), (MTAUTHLib::IMTYAAC*)this);
		}
    IDispatchPtr disp = mOwnershipMgr;
    *ppOwnershipMgr = disp.Detach();
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to get ownership manager",Me());
	}
	return S_OK;
}

STDMETHODIMP CMTYAAC::put_Billable(VARIANT_BOOL newVal)
{
  mbBillable = (newVal == VARIANT_TRUE) ? true : false;
  return S_OK;
}

STDMETHODIMP CMTYAAC::put_Folder(VARIANT_BOOL newVal)
{
  mbFolder = (newVal == VARIANT_TRUE) ? true : false;
  return S_OK;
}

STDMETHODIMP CMTYAAC::put_LoginName(BSTR newVal)
{
  mLoginName = newVal;
  return S_OK;
}

STDMETHODIMP CMTYAAC::put_HierarchyPath(BSTR newVal)
{
  mHierarchyPath = newVal;
  return S_OK;
}

STDMETHODIMP CMTYAAC::put_CorporateAccountID(long newVal)
{
  mCorporateAccountID = newVal;
  return S_OK;
}

STDMETHODIMP CMTYAAC::put_AccountTypeID(long newVal)
{
  mAccountTypeID = newVal;
  return S_OK;
}
STDMETHODIMP CMTYAAC::put_AccountType(BSTR newVal)
{
  mAccountTypeStr = newVal;
  return S_OK;
}
STDMETHODIMP CMTYAAC::put_AccStatus(BSTR newVal)
{
  mAccStatus = newVal;
  return S_OK;
}
STDMETHODIMP CMTYAAC::put_AccountID(long newVal)
{
  mAccountID = newVal;
  MTSecurityPrincipalImplBase<IMTYAAC, &IID_IMTYAAC, &LIBID_MTYAACLib>
    ::put_ID(mAccountID);	
  return S_OK;
}
STDMETHODIMP CMTYAAC::put_NameSpace(BSTR newVal)
{
  mNameSpace = newVal;
  return S_OK;
}
STDMETHODIMP CMTYAAC::put_AccountName(BSTR newVal)
{
  mAccountName = newVal;
  return S_OK;
}

STDMETHODIMP CMTYAAC::put_CurrentFolderOwner(long newVal)
{
  mCurrentFolderOwner = newVal;
  return S_OK;
}

STDMETHODIMP CMTYAAC::put_Loaded(VARIANT_BOOL newVal)
{
  mbLoaded = (newVal == VARIANT_TRUE) ? true : false;
  return S_OK;
}
STDMETHODIMP CMTYAAC::put_AccountExternalIdentifier(BSTR newVal)
{
  mExternalIdentifier = newVal;
  return S_OK;
}
STDMETHODIMP CMTYAAC::put_SessionContext(/*[in]*/ IMTSessionContext* newVal)
{
  mSessionContext = newVal;
  return S_OK;
}
STDMETHODIMP CMTYAAC::GetAvailableGroupSubscriptionsAsRowset(DATE RefDate,VARIANT aFilter,
																															IMTSQLRowset **ppRowset)
{
	ASSERT(ppRowset);
	if(!ppRowset) return E_POINTER;
	try 
  {
    MTYAACLib::IMTYAACPtr ThisPtr = this;
    MTYAACEXECLib::IMTYAACReaderPtr 
			reader(__uuidof(MTYAACEXECLib::MTYAACReader));
		MTYAACEXECLib::IMTRowSetPtr aRowset = 
			reader->GetAvailableGroupSubscriptionsAsRowset
      ( reinterpret_cast<MTYAACEXECLib::IMTSessionContext*>(mSessionContext.GetInterfacePtr()), 
        reinterpret_cast<MTYAACEXECLib::IMTYAAC*>(ThisPtr.GetInterfacePtr()),
        RefDate, 
        aFilter);
		*ppRowset	= reinterpret_cast<IMTSQLRowset*> (aRowset.Detach());

	}
	catch(_com_error& err) 
  {
		return returnYAACError(err);
	}

	return S_OK;
}
