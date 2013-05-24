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
#include "MTAccountTemplate.h"
#include <mtprogids.h>
#include "PCCache.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAccountTemplate

STDMETHODIMP CMTAccountTemplate::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountTemplate
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Return Value:  AccountTemplateSubscriptions object
// Description:  retrieves the list of current template subscriptions
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountTemplate::get_Subscriptions(IMTAccountTemplateSubscriptions** pVal)
{
	try {
		*pVal = reinterpret_cast<IMTAccountTemplateSubscriptions*>(mSubscriptions.GetInterfacePtr());
		(*pVal)->AddRef();
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to get account template subscription",LOG_ERROR);
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

STDMETHODIMP CMTAccountTemplate::Initialize(IMTSessionContext *pCTX, long aAccountID, long aCorporateAccountID, long aAccountTypeID, VARIANT vRefDate)
{
	HRESULT hr = S_OK;
	try {
		mCTX = pCTX;
		mAccountID = aAccountID;
    mCorporateAccountID = aCorporateAccountID;
    mAccountTypeID = aAccountTypeID;
		VARIANT_BOOL vbVal;
		
    hr = LoadMainMembers(aAccountTypeID, vRefDate, &vbVal);
		if(vbVal == VARIANT_FALSE) {
			MT_THROW_COM_ERROR("failed to load account template");
		}
		if(mID > 0) {
			hr = LoadSubscription(&vbVal);
			if(vbVal == VARIANT_FALSE) {
				MT_THROW_COM_ERROR("failed to load account template subscriptions");
			}
			hr = LoadProperties(&vbVal);
			if(vbVal == VARIANT_FALSE) {
				MT_THROW_COM_ERROR("failed to load account template properties");
			}
		}

    // check if we actually found a template that matches the account exactly; we
    // could have a found a template from an ancestor in the hierarchy
    if(aAccountID != mAccountID) {
      mID = -1;
      mAccountID = aAccountID;
    }
	}
	catch(_com_error& err) {
		return returnYAACError(err);
	}
	return hr;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountTemplate::Save(VARIANT vRefDate, VARIANT_BOOL *bRetVal)
{
	MTYAACLib::IMTAccountTemplatePtr pThis(this);
	*bRetVal = VARIANT_FALSE;
	try {
		if(pThis->SaveMainMember(vRefDate) == VARIANT_TRUE) {
			if(pThis->SaveProperties() == VARIANT_TRUE) {
				if(pThis->SaveSubscriptions() == VARIANT_TRUE) {
					*bRetVal = VARIANT_TRUE;
					return S_OK;
				}
			}
		}
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to save account template",LOG_ERROR);
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

STDMETHODIMP CMTAccountTemplate::SaveProperties(VARIANT_BOOL *bRetVal)
{
	*bRetVal = VARIANT_FALSE;
	try {
		MTYAACEXECLib::IMTAccTemplateWriterPtr writer(__uuidof(MTYAACEXECLib::MTAccTemplateWriter));
		MTYAACLib::IMTCollectionReadOnlyPtr readOnly = mProp; // QI
		writer->SaveTemplateProperties(mID,reinterpret_cast<MTYAACEXECLib::IMTCollectionReadOnly*>(readOnly.GetInterfacePtr()));
		*bRetVal = VARIANT_TRUE;
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to save template properties",LOG_ERROR);
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

STDMETHODIMP CMTAccountTemplate::SaveMainMember(VARIANT vRefDate, VARIANT_BOOL *bRetVal)
{
	try {

    // check if templates are allowed on the account (if you are creating templates at account xxxx, look at the account
    // type for xxxx.  Then check the flag b_canhavetemplates for that type.

    MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
		queryAdapter->SetQueryTag("__ARE_TEMPLATES_ALLOWED__");
		queryAdapter->AddParam("%%ACCOUNTID%%",mAccountID);
		ROWSETLib::IMTSQLRowsetPtr rs= reader->ExecuteStatement(queryAdapter->GetQuery());

    ASSERT(rs->RecordCount == 1);
  
    _bstr_t str = (_bstr_t)rs->Value["areTemplatesAllowed"];
    if (strcmp(str, "1") == 0)
    {
      QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		  queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
		  *bRetVal = VARIANT_FALSE;
		  bool bNew = false;

		  MTYAACEXECLib::IMTGenDbWriterPtr writer(__uuidof(MTYAACEXECLib::MTGenDbWriter));
		  if(mID < 0)
      {
			  // add a new template
			  queryAdapter->SetQueryTag("__ADD_NEW_TEMPLATE__");
			  queryAdapter->AddParam("%%ACCOUNTID%%",mAccountID);
        queryAdapter->AddParam("%%ACCOUNTIDTYPE%%",mAccountTypeID);
			  bNew = true;
		  }
		  else 
      {
			  // update the existing template
			  queryAdapter->SetQueryTag("__UPDATE_EXISTING_TEMPLATE__");
			  queryAdapter->AddParam("%%TEMPLATEID%%",mID);
		  }

		  queryAdapter->AddParam("%%NAME%%",mName);
		  queryAdapter->AddParam("%%DESC%%",mDesc);
		  queryAdapter->AddParam("%%APPLYPOLICY%%",bApplyDefaultPolicy ? "Y" : "N");
		  writer->ExecuteStatement(queryAdapter->GetQuery());

		  if(bNew) 
      {
			  return LoadMainMembers(mAccountTypeID, vRefDate, bRetVal);
		  }
		  else 
      {
			  *bRetVal = VARIANT_TRUE;
		  }
    }
    else
    {
        MT_THROW_COM_ERROR("Accounts of this type cannot have templates.  Saving template failed.");
    }
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to save template properties",LOG_ERROR);
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

STDMETHODIMP CMTAccountTemplate::SaveSubscriptions(VARIANT_BOOL* bRetVal)
{
	*bRetVal = VARIANT_FALSE;
	try 
  {
    // check if subscriptions are allowed on this template
    MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
		queryAdapter->SetQueryTag("__ARE_SUBSCRIPTIONS_ALLOWED__");
		queryAdapter->AddParam("%%TEMPLATEID%%",mID);
		ROWSETLib::IMTSQLRowsetPtr rs= reader->ExecuteStatement(queryAdapter->GetQuery());

    bool bsubsAllowed = false;
    bool bgsubsAllowed = false;

    ASSERT(rs->RecordCount == 1);
  
    _bstr_t str = (_bstr_t)rs->Value["areSubscriptionsAllowed"];
    if (strcmp(str, "1") == 0)
      bsubsAllowed = true;

    str = (_bstr_t)rs->Value["areGroupSubscriptionsAllowed"];
    if (strcmp(str, "1") == 0)
      bgsubsAllowed = true;

    for(int i = 1; i <= mSubscriptions->Count; i++)
    {
      MTYAACLib::IMTAccountTemplateSubscriptionPtr sub = mSubscriptions->GetItem(i);
      if(sub->GroupSubscription == VARIANT_TRUE)
      {
        if(bgsubsAllowed == false)
        {
          MT_THROW_COM_ERROR(MTPCUSER_ACCOUNT_TYPE_CANNOT_PARTICIPATE_IN_GSUB, L"Cannot add group subscriptions to this template as the account type does not allow for group subscriptions");
        }
      }
      else if(bsubsAllowed == false)
      {
        MT_THROW_COM_ERROR(MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE, L"Cannot add subscriptions to this template as the account type does not allow for subscriptions");
      }

    }
		MTYAACEXECLib::IMTAccTemplateWriterPtr writer(__uuidof(MTYAACEXECLib::MTAccTemplateWriter));
		writer->SaveSubscriptions(mID,
			reinterpret_cast<MTYAACEXECLib::IMTAccountTemplateSubscriptions*>(mSubscriptions.GetInterfacePtr()));
		*bRetVal = VARIANT_TRUE;
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to save account template subscriptions",LOG_ERROR);
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

STDMETHODIMP CMTAccountTemplate::Load(VARIANT vRefDate, VARIANT_BOOL *bRetVal)
{
	try {
		*bRetVal = VARIANT_FALSE;
		MTYAACLib::IMTAccountTemplatePtr ptemplate(this);
		if(ptemplate->LoadMainMembers(mAccountTypeID, vRefDate) == VARIANT_TRUE) {
			if(ptemplate->LoadProperties() == VARIANT_TRUE) {
				if(ptemplate->LoadSubscription() == VARIANT_TRUE) {
					*bRetVal = VARIANT_TRUE;
				}
			}
		}
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to load account template",LOG_ERROR);
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

STDMETHODIMP CMTAccountTemplate::LoadProperties(VARIANT_BOOL *bRetVal)
{
	try {
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
		queryAdapter->SetQueryTag("__LOAD_TEMPLATE_PROPERTIES_PUB__");
		queryAdapter->AddParam("%%TEMPLATEID%%",mID);
		ROWSETLib::IMTSQLRowsetPtr rs= reader->ExecuteStatement(queryAdapter->GetQuery());

		// clear the properties
		mProp->Clear();
		for(int index = 0;index < rs->GetRecordCount();index++)
    {
			mProp->Add(_bstr_t(rs->GetValue("nm_prop")),_bstr_t(rs->GetValue("nm_value")), (long)rs->GetValue("nm_prop_class"));
			rs->MoveNext();
		}
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to load account template properties",LOG_ERROR);
	}
	*bRetVal = VARIANT_TRUE;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountTemplate::LoadSubscription(VARIANT_BOOL *bRetVal)
{
	try {
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
		queryAdapter->SetQueryTag("__LOAD_TEMPLATE_SUBSCRIPTIONS__");
		queryAdapter->AddParam("%%TEMPLATEID%%",mID);
		queryAdapter->AddParam("%%ID_LANG%%", mCTX->GetLanguageID());
		ROWSETLib::IMTSQLRowsetPtr rs= reader->ExecuteStatement(queryAdapter->GetQuery());

		mSubscriptions->Clear();
		for(int index = 0;index < rs->GetRecordCount();index++) {
			MTYAACLib::IMTAccountTemplateSubscriptionPtr sub = mSubscriptions->AddSubscription();
			sub->Initialize(CTXCAST(mCTX),reinterpret_cast<MTYAACLib::IMTSQLRowset*>(rs.GetInterfacePtr()));
			rs->MoveNext();
		}
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to load account template subscription",LOG_ERROR);
	}
	*bRetVal = VARIANT_TRUE;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountTemplate::LoadMainMembers(long aAccountTypeID, VARIANT vRefDate, VARIANT_BOOL *bRetVal)
{
	try 
	{
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
		queryAdapter->SetQueryTag("__LOAD_ACC_TEMPLATE__");
		queryAdapter->AddParam("%%ACCOUNTID%%",mAccountID);
    queryAdapter->AddParam("%%ACCOUNTTYPEID%%",aAccountTypeID);

    //Check optional date.  If not specified, use MetraTime
    _variant_t vtDateVal;
    if(!OptionalVariantConversion(vRefDate, VT_DATE, vtDateVal)) {
      vtDateVal = GetMTOLETime();
    }
		wstring val;
		FormatValueForDB(vtDateVal,false,val);
		queryAdapter->AddParam("%%REFDATE%%",val.c_str(),VARIANT_TRUE);

    ROWSETLib::IMTSQLRowsetPtr rs= reader->ExecuteStatement(queryAdapter->GetQuery());

		if(rs->GetRecordCount() > 0) 
		{
			//leave as this for now, but account id of a "templated"
			//account is not necessarily the same as account id we load template from
      mAccountID = rs->GetValue("id_folder");

			mTemplateAccountID = rs->GetValue("id_folder");
			mTemplateAccountName = rs->GetValue("nm_login");
			mTemplateAccountNameSpace = rs->GetValue("nm_space");

			mID = rs->GetValue("id_acc_template");
      mAccountTypeID = aAccountTypeID;
			mDateCreated = rs->GetValue("dt_crt");
			_variant_t vtname = rs->GetValue("tx_name");
			if(vtname.vt == VT_NULL || vtname.vt == VT_EMPTY) 
			{
				mName = "";
			}
			else 
			{
				mName = vtname;
			}
			_variant_t vtdesc = rs->GetValue("tx_desc");
			if(vtdesc.vt == VT_NULL || vtdesc.vt == VT_EMPTY) 
			{
				mDesc = "";
			}
			else 
			{
				mDesc = vtdesc;
			}
			bApplyDefaultPolicy = _bstr_t(rs->GetValue("b_ApplyDefaultPolicy")) == _bstr_t("Y") ? true : false;
		}
		*bRetVal = VARIANT_TRUE;
	}
	catch(_com_error& err) {
		return returnYAACError(err,"failed to load account template",LOG_ERROR);
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

STDMETHODIMP CMTAccountTemplate::GetAvailableProductOfferingsAsRowset(VARIANT RefDate,IMTSQLRowset **ppRowset)
{
	try {
		
_bstr_t sCURRENCYFILTER1,sCURRENCYFILTER4;
				
  sCURRENCYFILTER1=" pl1.nm_currency_code = tav.c_currency ";
  sCURRENCYFILTER4=" tmp.PayerCurrency = tpl.nm_currency_code ";
    
    if (PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch) == VARIANT_TRUE)
    {
      sCURRENCYFILTER1=" 1=1 ";
      sCURRENCYFILTER4=" 1=1 ";
    }
	
    
    MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);

    _variant_t vtRefDate;
    if(!OptionalVariantConversion(RefDate,VT_DATE,vtRefDate)) {
			vtRefDate = GetMaxMTOLETime();
		}
    wstring dateStr;
    FormatValueForDB(vtRefDate,FALSE,dateStr);

    queryAdapter->SetQueryTag("__FIND_AVAILABLE_POS_FOR_TEMPLATE__");
    queryAdapter->AddParam("%%REFDATE%%",dateStr.c_str(),VARIANT_TRUE);
    queryAdapter->AddParam("%%ID_LANG%%",mCTX->GetLanguageID());
    queryAdapter->AddParam("%%ACC_TEMPLATE%%",mID);
    queryAdapter->AddParam("%%CORPORATEACCOUNT%%", mCorporateAccountID);
    queryAdapter->AddParam("%%CURRENCYFILTER1%%",sCURRENCYFILTER1);
    queryAdapter->AddParam("%%CURRENCYFILTER4%%",sCURRENCYFILTER4);

    _bstr_t additionalWhereClause;

    if(mSubscriptions->GetCount() != 0) {

      _bstr_t InMemoryInListStr;
      long count =mSubscriptions->GetCount();
      for(int i=1;i<=count;i++) {
        
        InMemoryInListStr += (_bstr_t)_variant_t(MTYAACLib::IMTAccountTemplateSubscriptionPtr(mSubscriptions->GetItem(i))->GetProductOfferingID());
        if(i != count) {
          InMemoryInListStr += ",";
        }
      }

      additionalWhereClause = "AND t_po.id_po not in (";
      additionalWhereClause += InMemoryInListStr;
      additionalWhereClause += ")";

      }
    queryAdapter->AddParam("%%ADDITIONALL_INMEM_POS%%",additionalWhereClause);

		ROWSETLib::IMTSQLRowsetPtr rs= reader->ExecuteStatement(queryAdapter->GetQuery());
		*ppRowset = reinterpret_cast<IMTSQLRowset*>(rs.Detach());
	}
	catch(_com_error& err) {
    return returnYAACError(err,"Failed to get Available Product offerings for template.",LOG_ERROR);
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

STDMETHODIMP CMTAccountTemplate::GetAvailableGroupSubscriptionsAsRowset(VARIANT RefDate,IMTSQLRowset **ppRowset)
{
	long rootCorpId;
	rootCorpId = 1;
	try {
    MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);

    _variant_t vtRefDate;

    if(!OptionalVariantConversion(RefDate, VT_DATE, vtRefDate)) {
      vtRefDate = GetMaxMTOLETime();
    }

    wstring dateStr;
    FormatValueForDB(vtRefDate, FALSE, dateStr);

    queryAdapter->SetQueryTag("__FIND_AVAILABLE_GROUPSUBS_FOR_TEMPLATE__");
		queryAdapter->AddParam("%%REFDATE%%", dateStr.c_str(), VARIANT_TRUE);
    queryAdapter->AddParam("%%ID_ACC%%", mAccountID);
    //queryAdapter->AddParam("%%ID_LANG%%", mCTX->GetLanguageID());
    queryAdapter->AddParam("%%ACC_TEMPLATE%%", mID);

		if (PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE)
				queryAdapter->AddParam("%%CORPORATEACCOUNT%%", mCorporateAccountID);
		else
				queryAdapter->AddParam("%%CORPORATEACCOUNT%%", rootCorpId);
 
		ROWSETLib::IMTSQLRowsetPtr rs= reader->ExecuteStatement(queryAdapter->GetQuery());
		*ppRowset = reinterpret_cast<IMTSQLRowset*>(rs.Detach());
    
	}
	catch(_com_error& err) {
    return returnYAACError(err,"Failed to get Available Group Product offerings for template.",LOG_ERROR);
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

STDMETHODIMP CMTAccountTemplate::GetSubscriptionsAsRowSet(IMTSQLRowset **ppRowset)
{
	try {
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
		queryAdapter->SetQueryTag("__GET_ACCTEMPLATE_SUGGESTS_SUBS__");
		queryAdapter->AddParam("%%TEMPLATEID%%",mID);
		ROWSETLib::IMTSQLRowsetPtr rs= reader->ExecuteStatement(queryAdapter->GetQuery());
		*ppRowset = reinterpret_cast<IMTSQLRowset*>(rs.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"failed to get list of available product offerings",LOG_ERROR);
	}
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::get_ID(long *pVal)
{
	*pVal = mID;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::put_ID(long newVal)
{
	mID = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::get_AccountID(long *pVal)
{
	*pVal = mAccountID;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::put_AccountID(long newVal)
{
	mAccountID = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::get_DateCrt(DATE *pVal)
{
	*pVal = mDateCreated;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::put_DateCrt(DATE newVal)
{
	mDateCreated = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::get_Name(BSTR *pVal)
{
	*pVal = mName.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::put_Name(BSTR newVal)
{
	mName = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::get_Description(BSTR *pVal)
{
	*pVal = mDesc.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::put_Description(BSTR newVal)
{
	mDesc = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::get_ApplyDefaultSecurityPolicy(VARIANT_BOOL *pVal)
{
	*pVal = bApplyDefaultPolicy ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::put_ApplyDefaultSecurityPolicy(VARIANT_BOOL newVal)
{
	bApplyDefaultPolicy = newVal == VARIANT_TRUE ? true : false;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::get_Properties(IMTAccountTemplateProperties** pVal)
{
	*pVal = reinterpret_cast<IMTAccountTemplateProperties*>(mProp.GetInterfacePtr());
	(*pVal)->AddRef();
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::put_Properties(IMTAccountTemplateProperties* newVal)
{
	mProp = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::get_TemplateAccountTypeID(long *pVal)
{
	*pVal = mAccountTypeID;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::put_TemplateAccountTypeID(long newVal)
{
	mAccountTypeID = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountTemplate::CopyTemplateFromParent(VARIANT vRefDate)
{
	try {
		MTYAACEXECLib::IMTAccTemplateWriterPtr writer(__uuidof(MTYAACEXECLib::MTAccTemplateWriter));
    writer->CopyTemplate(mAccountID, mAccountTypeID,  vtMissing);
    VARIANT_BOOL bVal;
    Load(vRefDate, &bVal);
    if(bVal == VARIANT_FALSE) {
      MT_THROW_COM_ERROR("failed to load template after copying from parent folder");
    }
	}
	catch(_com_error& err) {
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

STDMETHODIMP CMTAccountTemplate::CopyTemplateFromFolder(long aFolderID, VARIANT vRefDate)
{ 
	try {
		MTYAACEXECLib::IMTAccTemplateWriterPtr writer(__uuidof(MTYAACEXECLib::MTAccTemplateWriter));
    writer->CopyTemplate(mAccountID, mAccountTypeID, aFolderID);
    VARIANT_BOOL bVal;
    Load(vRefDate, &bVal);
    if(bVal == VARIANT_FALSE) {
      MT_THROW_COM_ERROR("failed to load template after copying from specified folder %d",aFolderID);
    }
	}
	catch(_com_error& err) {
    return returnYAACError(err);
	}
	return S_OK;
}


STDMETHODIMP CMTAccountTemplate::Clear()
{
	try {
    mName = "";
    mDesc = "";
    bApplyDefaultPolicy = false;
    mProp->Clear();
    mSubscriptions->Clear();
    mID = -1;
    // we don't need to clear the corporate account
    // because it is the same regardless if the tempalte
    // is inherited from upwards in the hierarchy
	}
	catch(_com_error& err) {
    return returnYAACError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::NearestParentInfo(VARIANT vRefDate, IMTSQLRowset** ppRowset)
{
  try {
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
		queryAdapter->SetQueryTag("__NEAREST_TEMPLATE_PARENT__");
		queryAdapter->AddParam("%%ID_ACC%%",mAccountID);

    //Check optional date.  If not specified, use MetraTime
    _variant_t vtDateVal;
    if(!OptionalVariantConversion(vRefDate, VT_DATE, vtDateVal)) {
      vtDateVal = GetMTOLETime();
    }
		wstring val;
		FormatValueForDB(vtDateVal,false,val);
		queryAdapter->AddParam("%%REFDATE%%",val.c_str(),VARIANT_TRUE);


		ROWSETLib::IMTSQLRowsetPtr rs= reader->ExecuteStatement(queryAdapter->GetQuery());
    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rs.Detach());
  }
	catch(_com_error& err) {
    return returnYAACError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::get_TemplateAccountName(BSTR *pVal)
{
	*pVal = mTemplateAccountName.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::put_TemplateAccountName(BSTR newVal)
{
	mTemplateAccountName = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::get_TemplateAccountNameSpace(BSTR *pVal)
{
	*pVal = mTemplateAccountNameSpace.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::put_TemplateAccountNameSpace(BSTR newVal)
{
	mTemplateAccountNameSpace = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::get_TemplateAccountID(long *pVal)
{
	*pVal = mTemplateAccountID;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplate::put_TemplateAccountID(long newVal)
{
	mTemplateAccountID = newVal;
	return S_OK;
}
