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
#include "MTAccountCatalog.h"
#include "SQLAccountFinder.h"
#include <mtprogids.h>



/////////////////////////////////////////////////////////////////////////////
// CMTAccountCatalog

STDMETHODIMP CMTAccountCatalog::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTAccountCatalog
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

CMTAccountCatalog::CMTAccountCatalog()
{
  m_pUnkMarshaler = NULL;
  mInitialized = false;
}

HRESULT CMTAccountCatalog::FinalConstruct()
{
  return CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &m_pUnkMarshaler.p);
}

void CMTAccountCatalog::FinalRelease()
{
  m_pUnkMarshaler.Release();

  mActorAccount = NULL;
  mEnumConfig = NULL;
}


// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountCatalog::Init(IMTSessionContext *apCTX)
{
  if (!apCTX)
    return E_POINTER;

  try
  {
    //reinitialize 
    mInitialized = false;
    mSessionContext = NULL;
    mActorAccount = NULL;

    //save session context
    mSessionContext = apCTX;

    mInitialized = true;
  }
  catch (_com_error & err)
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

STDMETHODIMP CMTAccountCatalog::FindAccountsAsRowset(DATE aRefDate,
                                                     IMTCollection *apColumns,
                                                     IMTDataFilter *apFilter,
                                                     IMTDataFilter *apJoinFilter,
                                                     IMTCollection *apOrder,
                                                     long aMaxRows,
                                                     VARIANT *apMoreRows,
                                                     VARIANT transaction,
                                                     IMTSQLRowset **apRowset
                                                     )
{
  if (!apRowset)
    return E_POINTER;


  try
  {
    //init out vars
    *apRowset = NULL;

    bool bMoreRows = false;

    if (!mInitialized)
      MT_THROW_COM_ERROR("Object not initialized");

    
  
    // get CorporateAccounts that the ActorYAAC has access to
    GENERICCOLLECTIONLib::IMTCollectionPtr corporateAccounts;
    MTYAACLib::IMTYAACPtr actor = InternalGetActorAccount(vtMissing);
    corporateAccounts = actor->AccessibleCorporateAccounts(vtMissing);

    // see if ActorYAAC has access to NonHierarchical accounts
    // check for read MANAGE_NON_HIER_ACCOUNTS_CAP capability
    
    MTAUTHLib::IMTCompositeCapabilityPtr manageNHAccountsCap;
    MTAUTHLib::IMTSecurityPtr secPtr(__uuidof(MTAUTHLib::MTSecurity));
    manageNHAccountsCap = secPtr->GetCapabilityTypeByName(MANAGE_NON_HIER_ACCOUNTS_CAP)->CreateInstance();
    MTAUTHLib::IMTEnumTypeCapabilityPtr enumPtr = manageNHAccountsCap->GetAtomicEnumCapability();
    enumPtr->SetParameter("READ");

    MTAUTHLib::IMTSecurityContextPtr secCTX = mSessionContext->GetSecurityContext();
    VARIANT_BOOL hasAccess = secCTX->HasAccess(manageNHAccountsCap);
    
    bool canReadNonHierachicalAccounts = (hasAccess == VARIANT_TRUE);

    

    // create a finder object
    CSQLAccountFinder finder(CAccountMetaData::GetInstance(),
                             InternalGetEnumConfig(),
                             mSessionContext);

    // search
    finder.Search((IMTCollection*)corporateAccounts.GetInterfacePtr(),
                  canReadNonHierachicalAccounts,
                  aRefDate,
                  apColumns,
                  apFilter,
                  apJoinFilter,
                  apOrder,
                  aMaxRows,
                  bMoreRows,
                  transaction,
                  apRowset);

    // set outgoing apMoreRows
    if(apMoreRows)
    { 
      if(apMoreRows)
      { _variant_t vt = bMoreRows;
        *apMoreRows = vt;
      }
    }
  }
  catch (_com_error & err)
  {
    if(apMoreRows)
    { _variant_t vt = false;
      *apMoreRows = vt;
    }
    
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

STDMETHODIMP CMTAccountCatalog::GenerateAccountSearchQuery(DATE aRefDate,
																													 IMTCollection *apColumns,
																													 IMTDataFilter *apFilter,
																													 IMTDataFilter *apJoinFilter,
																													 IMTCollection *apOrder,
																													 long aMaxRows,
																													 BSTR * apQuery)
{
  try
  {
    if (!mInitialized)
      MT_THROW_COM_ERROR("Object not initialized");
  
    // get CorporateAccounts that the ActorYAAC has access to
    GENERICCOLLECTIONLib::IMTCollectionPtr corporateAccounts;
    MTYAACLib::IMTYAACPtr actor = InternalGetActorAccount(vtMissing);
    corporateAccounts = actor->AccessibleCorporateAccounts(vtMissing);

    // see if ActorYAAC has access to NonHierarchical accounts
    // check for read MANAGE_NON_HIER_ACCOUNTS_CAP capability
    
    MTAUTHLib::IMTCompositeCapabilityPtr manageNHAccountsCap;
    MTAUTHLib::IMTSecurityPtr secPtr(__uuidof(MTAUTHLib::MTSecurity));
    manageNHAccountsCap = secPtr->GetCapabilityTypeByName(MANAGE_NON_HIER_ACCOUNTS_CAP)->CreateInstance();
    MTAUTHLib::IMTEnumTypeCapabilityPtr enumPtr = manageNHAccountsCap->GetAtomicEnumCapability();
    enumPtr->SetParameter("READ");

    MTAUTHLib::IMTSecurityContextPtr secCTX = mSessionContext->GetSecurityContext();
    VARIANT_BOOL hasAccess = secCTX->HasAccess(manageNHAccountsCap);
    
    bool canReadNonHierachicalAccounts = (hasAccess == VARIANT_TRUE);


    // create a finder object
    CSQLAccountFinder finder(CAccountMetaData::GetInstance(),
                             InternalGetEnumConfig(),
                             mSessionContext);

		// TODO: this is a lot of overhead to find out if we're oracle or SQL
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(ACC_HIERARCHIES_QUERIES);

		_bstr_t dbType = rowset->GetDBType();
		bool isOracle = (mtwcscasecmp(dbType, ORACLE_DATABASE_TYPE) == 0);

    // search
    _bstr_t query = finder.GenerateQuery((IMTCollection*)corporateAccounts.GetInterfacePtr(),
																				 canReadNonHierachicalAccounts,
																				 aRefDate,
																				 apColumns,
																				 apFilter,
																				 apJoinFilter,
																				 apOrder,
																				 aMaxRows,
																				 isOracle,
                                         false).c_str();

		*apQuery = query.copy();
  }
  catch (_com_error & err)
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

STDMETHODIMP CMTAccountCatalog::GenerateParameterizedAccountSearchQuery(DATE aRefDate,
																													 IMTCollection *apColumns,
																													 IMTDataFilter *apFilter,
																													 IMTDataFilter *apJoinFilter,
																													 IMTCollection *apOrder,
																													 long aMaxRows,
																													 BSTR * apQuery)
{
  try
  {
    if (!mInitialized)
      MT_THROW_COM_ERROR("Object not initialized");
  
    // get CorporateAccounts that the ActorYAAC has access to
    GENERICCOLLECTIONLib::IMTCollectionPtr corporateAccounts;
    MTYAACLib::IMTYAACPtr actor = InternalGetActorAccount(vtMissing);
    corporateAccounts = actor->AccessibleCorporateAccounts(vtMissing);

    // see if ActorYAAC has access to NonHierarchical accounts
    // check for read MANAGE_NON_HIER_ACCOUNTS_CAP capability
    
    MTAUTHLib::IMTCompositeCapabilityPtr manageNHAccountsCap;
    MTAUTHLib::IMTSecurityPtr secPtr(__uuidof(MTAUTHLib::MTSecurity));
    manageNHAccountsCap = secPtr->GetCapabilityTypeByName(MANAGE_NON_HIER_ACCOUNTS_CAP)->CreateInstance();
    MTAUTHLib::IMTEnumTypeCapabilityPtr enumPtr = manageNHAccountsCap->GetAtomicEnumCapability();
    enumPtr->SetParameter("READ");

    MTAUTHLib::IMTSecurityContextPtr secCTX = mSessionContext->GetSecurityContext();
    VARIANT_BOOL hasAccess = secCTX->HasAccess(manageNHAccountsCap);
    
    bool canReadNonHierachicalAccounts = (hasAccess == VARIANT_TRUE);


    // create a finder object
    CSQLAccountFinder finder(CAccountMetaData::GetInstance(),
                             InternalGetEnumConfig(),
                             mSessionContext);

		// TODO: this is a lot of overhead to find out if we're oracle or SQL
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(ACC_HIERARCHIES_QUERIES);

		_bstr_t dbType = rowset->GetDBType();
		bool isOracle = (mtwcscasecmp(dbType, ORACLE_DATABASE_TYPE) == 0);

    // search
    _bstr_t query = finder.GenerateQuery((IMTCollection*)corporateAccounts.GetInterfacePtr(),
																				 canReadNonHierachicalAccounts,
																				 aRefDate,
																				 apColumns,
																				 apFilter,
																				 apJoinFilter,
																				 apOrder,
																				 aMaxRows,
																				 isOracle,
                                         true).c_str();

		*apQuery = query.copy();
  }
  catch (_com_error & err)
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

STDMETHODIMP CMTAccountCatalog::FindAccountByIDAsRowset(DATE refdate, long aAccountID,  VARIANT transaction, IMTSQLRowset **apRowset)
{
  if (!apRowset)
    return E_POINTER;

	_variant_t vRefDate(refdate, VT_DATE);

  try
  {

    if(!mInitialized)
      return Error("Object not initialized");

    //init out vars
    *apRowset = NULL;

    MTYAACEXECLib::IMTYAACReaderPtr yaacreader = NULL;

    _variant_t trans;
    
    if(V_VT(&transaction) != VT_NULL && OptionalVariantConversion(transaction,VT_UNKNOWN,trans))
    {
      PIPELINETRANSACTIONLib::IMTTransactionPtr pTrans(__uuidof(PIPELINETRANSACTIONLib::CMTTransaction));
      pTrans->SetTransaction(trans,VARIANT_FALSE);
      IDispatchPtr pDisp = pTrans->CreateObjectWithTransaction("MetraTech.MTYAACReader");
      yaacreader = pDisp; // QI
    }
    else
    {
      yaacreader.CreateInstance("MetraTech.MTYAACReader");
    }

    //load yaac, get account type
    MTYAACLib::IMTYAACPtr yaac =  
      yaacreader->GetYAAC(reinterpret_cast<MTYAACEXECLib::IMTSessionContext*>(mSessionContext.GetInterfacePtr()), aAccountID, vRefDate);
    _bstr_t acctype = yaac->AccountType;


    //call FindAccountsAsRowset with all columns and filter AccountID
    MTYAACLib::IMTDataFilterPtr filter(MTPROGID_FILTER);
    filter->Add("_AccountID", variant_t((long)MTYAACLib::OPERATOR_TYPE_EQUAL, VT_I4), aAccountID);
    filter->Add("AccountTypeName", variant_t((long)MTYAACLib::OPERATOR_TYPE_EQUAL, VT_I4), acctype);
    // Grotesque but "correct" to pass multiple parameters with a 
//     SAFEARRAYBOUND saBound[1];
//     SAFEARRAY * psa;
//     saBound[0].lLbound = 0;
//     saBound[0].cElements = 2;
//     psa = SafeArrayCreate(VT_BSTR, 1, saBound);
		filter->Add("_NameSpaceType", variant_t((long)MTYAACLib::OPERATOR_TYPE_IN, VT_I4), "'system_mps', 'system_user'");

    MTYAACLib::IMTAccountCatalogPtr thisPtr = this;
    MTYAACLib::IMTSQLRowsetPtr rowset;

    rowset = thisPtr->FindAccountsAsRowset( vRefDate,
      NULL,   //apColumns,
      filter, //apFilter,
      NULL,   //aoJoinFilter,
      NULL,   //apOrder,
      0,      //aMaxRows,
      NULL);  //apMoreRows

    *apRowset = reinterpret_cast<IMTSQLRowset*> (rowset.Detach());
  }
  catch (_com_error & err)
  {
    return returnYAACError(err);
  }

  return S_OK;
}

STDMETHODIMP CMTAccountCatalog::FindAccountByNameAsRowset(DATE refdate, BSTR aName, BSTR aNamespace,  VARIANT transaction, IMTSQLRowset **apRowset)
{
  if (!apRowset)
    return E_POINTER;
	_variant_t vRefDate(refdate, VT_DATE);

  try
  {

    if(!mInitialized)
      return Error("Object not initialized");

    //init out vars
    *apRowset = NULL;

    //load yaac, get account type
    MTYAACLib::IMTYAACPtr yaac(__uuidof(MTYAACLib::MTYAAC));
    yaac->InitByName(aName, aNamespace, mSessionContext, vRefDate);
    _bstr_t acctype = yaac->AccountType;
    

    //call FindAccountsAsRowset with all columns and filter AccountID
    MTYAACLib::IMTDataFilterPtr filter(MTPROGID_FILTER);
    filter->Add("UserName", variant_t((long)MTYAACLib::OPERATOR_TYPE_EQUAL, VT_I4), aName);
    filter->Add("name_space", variant_t((long)MTYAACLib::OPERATOR_TYPE_EQUAL, VT_I4), aNamespace);
    
    filter->Add("AccountTypeName", variant_t((long)MTYAACLib::OPERATOR_TYPE_EQUAL, VT_I4), acctype);

    MTYAACLib::IMTAccountCatalogPtr thisPtr = this;
    MTYAACLib::IMTSQLRowsetPtr rowset;

    rowset = thisPtr->FindAccountsAsRowset( vRefDate,
                                            NULL,   //apColumns,
                                            filter, //apFilter,
                                            NULL,   //aoJoinFilter,
                                            NULL,   //apOrder,
                                            0,      //aMaxRows,
                                            NULL);  //apMoreRows

    *apRowset = reinterpret_cast<IMTSQLRowset*> (rowset.Detach());
  }
  catch (_com_error & err)
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

STDMETHODIMP CMTAccountCatalog::GetActorAccount(VARIANT RefDate,IMTYAAC **apYAAC)
{
  ASSERT(apYAAC);
  if(!apYAAC)
    return E_POINTER;

  try
  {
    if(!mInitialized)
      return Error("Object not initialized");

    MTYAACLib::IMTYAACPtr actorCopy = InternalGetActorAccount(RefDate);

    *apYAAC = reinterpret_cast<IMTYAAC*>(actorCopy.Detach());
  }
  catch(_com_error& err)
  {
    mActorAccount = NULL;
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

STDMETHODIMP CMTAccountCatalog::GetAccount(long aAccountID,VARIANT RefDate,IMTYAAC **apYAAC)
{
  ASSERT(apYAAC);
  if(!apYAAC)
    return E_POINTER;

  try
  {
    if(!mInitialized)
      return Error("Object not initialized");

    MTYAACLib::IMTYAACPtr newYAAC(__uuidof(MTYAACLib::MTYAAC));
    newYAAC->InitAsSecuredResource(aAccountID, mSessionContext,RefDate);
    *apYAAC = reinterpret_cast<IMTYAAC*>(newYAAC.Detach());
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

STDMETHODIMP CMTAccountCatalog::GetAccountByName(BSTR aName,
                                                 BSTR aNamespace,
                                                 VARIANT RefDate,
                                                 IMTYAAC **apYAAC)
{
  try {
    if(!mInitialized)
      return Error("Object not initialized");
    MTYAACLib::IMTYAACPtr newYAAC(__uuidof(MTYAACLib::MTYAAC));
    newYAAC->InitByName(aName,aNamespace, mSessionContext,RefDate);
    *apYAAC = reinterpret_cast<IMTYAAC*>(newYAAC.Detach());
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


STDMETHODIMP CMTAccountCatalog::GetAccountMetaData(/*[out,retval]*/ IMTPropertyMetaDataSet** apMetaDataSet)
{
  if (!apMetaDataSet)
    return E_POINTER;

  *apMetaDataSet = NULL;

  try
  {
    CAccountMetaData* metaData = CAccountMetaData::GetInstance();

    *apMetaDataSet = reinterpret_cast<IMTPropertyMetaDataSet*>(metaData->GetPropertyMetaDataSet().Detach());
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
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

STDMETHODIMP CMTAccountCatalog::GetMAMFilter(IMTDataFilter** apFilter)
{
  if (!apFilter)
    return E_POINTER;

  *apFilter = NULL;

  try
  {
    //create a new filter and add a where clause with all the states    
    ROWSETLib::IMTDataFilterPtr mamFilter(MTPROGID_FILTER);
    wstring stateFilterClause = GetMAMStateFilterClause();

    mamFilter->Add( "AccountStatus",
                     variant_t((long)ROWSETLib::OPERATOR_TYPE_IN, VT_I4),
                     stateFilterClause.c_str());
    
    *apFilter = reinterpret_cast<IMTDataFilter*>(mamFilter.Detach());
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
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


MTYAACLib::IMTYAACPtr CMTAccountCatalog::InternalGetActorAccount(VARIANT RefDate)
{
  ASSERT(mSessionContext != NULL);
    
  //construct ActorAccount first time asked for
  if (mActorAccount == NULL)
  {
    // create an initialize before assigning to mActorAccount
    // to have NULL mActorAccount in case of thrown exceptions
    MTYAACLib::IMTYAACPtr actor(CLSID_MTYAAC);  
    actor->InitAsActor(mSessionContext,RefDate);
    
    mActorAccount = actor;
  }

  return mActorAccount;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

MTENUMCONFIGLib::IEnumConfigPtr CMTAccountCatalog::InternalGetEnumConfig()
{
  //construct EnumConfig first time asked for
  if (mEnumConfig == NULL)
  {
    HRESULT hr = mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);  
    if(FAILED(hr))
      MT_THROW_COM_ERROR(hr);
  }

  return mEnumConfig;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

wstring CMTAccountCatalog::GetMAMStateFilterClause()
{
  //read clause once and then cache it
  if (mMAMStateFilterClause.empty())
  {
    CAccountMetaData* metaData = CAccountMetaData::GetInstance();
    mMAMStateFilterClause = metaData->GetMAMStateFilterClause();
  }

  return mMAMStateFilterClause;
}

// ----------------------------------------------------------------
// Name:     Refresh
// Description: Drop references to all cached objects.  This is useful
// when we are doing an operation that will invalidate the actor YAAC's
// cache.  NOTE: This does not refresh the security context!
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountCatalog::Refresh()
{
  try {
    mActorAccount = NULL;
    mEnumConfig = NULL;
    GetMAMStateFilterClause();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  return S_OK;
}

STDMETHODIMP CMTAccountCatalog::BatchCreateOrUpdateOwnerhip(IMTCollection* pCol,
                                                    IMTProgress* pProgress, 
                                                    VARIANT transaction,
                                                    IMTRowSet** ppRowset)
{
  try 
  {
    GUID writerGuid = __uuidof(MetraTech_Accounts_Ownership::OwnershipWriter);
    MetraTech_Accounts_Ownership::IOwnershipWriterPtr writer;

    _variant_t trans;
    if(OptionalVariantConversion(transaction,VT_UNKNOWN,trans))
    {
      PIPELINETRANSACTIONLib::IMTTransactionPtr pTrans(__uuidof(PIPELINETRANSACTIONLib::CMTTransaction));
      pTrans->SetTransaction(trans,VARIANT_FALSE);
      IDispatchPtr pDisp = pTrans->CreateObjectWithTransactionByCLSID(&writerGuid);
      writer = pDisp; // QI
    }
    else
    {
      writer.CreateInstance(writerGuid);
    }
    ROWSETLib::IMTSQLRowsetPtr errorRs = writer->AddOwnershipBatch(  
                                reinterpret_cast<MTAUTHLib::IMTSessionContext *>(mSessionContext.GetInterfacePtr()),
                                  reinterpret_cast<MTAUTHLib::IMTCollection *>(pCol),
                                  reinterpret_cast<MTAUTHLib::IMTProgress *>(pProgress)
                                 );
    *ppRowset = reinterpret_cast<IMTRowSet*>(errorRs.Detach());

  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  return S_OK;
}


STDMETHODIMP CMTAccountCatalog::BatchDeleteOwnerhip(IMTCollection* pCol,
                                                    IMTProgress* pProgress, 
                                                    VARIANT transaction,
                                                    IMTRowSet** ppRowset)
{
  try 
  {
    GUID writerGuid = __uuidof(MetraTech_Accounts_Ownership::OwnershipWriter);
    MetraTech_Accounts_Ownership::IOwnershipWriterPtr writer;

    _variant_t trans;
    if(OptionalVariantConversion(transaction,VT_UNKNOWN,trans))
    {
      PIPELINETRANSACTIONLib::IMTTransactionPtr pTrans(__uuidof(PIPELINETRANSACTIONLib::CMTTransaction));
      pTrans->SetTransaction(trans,VARIANT_FALSE);
      IDispatchPtr pDisp = pTrans->CreateObjectWithTransactionByCLSID(&writerGuid);
      writer = pDisp; // QI
    }
    else
    {
      writer.CreateInstance(writerGuid);
    }
    ROWSETLib::IMTSQLRowsetPtr errorRs = writer->RemoveOwnershipBatch(  
                                  reinterpret_cast<MTAUTHLib::IMTSessionContext *>(mSessionContext.GetInterfacePtr()),
                                  reinterpret_cast<MTAUTHLib::IMTCollection *>(pCol),
                                  reinterpret_cast<MTAUTHLib::IMTProgress *>(pProgress)
                                 );
    *ppRowset = reinterpret_cast<IMTRowSet*>(errorRs.Detach());

  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  return S_OK;
}

/* the following two functions return ALL account types.. I don't expect there to be more than double digit account types
and so have not provided finer grain functions. */

 STDMETHODIMP CMTAccountCatalog::GetAllAccountTypes(IMTCollection** apTypes)
 {
                                                    
  if (!apTypes)
    return E_POINTER;

  try
  {
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init("queries\\account");
    queryAdapter->SetQueryTag("__FIND_ACCOUNT_TYPES__");

		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		MTYAACEXECLib::IMTSQLRowsetPtr rowsetPtr = reader->ExecuteStatement(queryAdapter->GetQuery());

    GENERICCOLLECTIONLib::IMTCollectionPtr accountTypes(__uuidof(GENERICCOLLECTIONLib::MTCollectionEx));
    if (rowsetPtr->RecordCount > 0)
    {
      rowsetPtr->MoveFirst();
      while(!(bool)rowsetPtr->GetRowsetEOF())
      {
        accountTypes->Add(rowsetPtr->Value["name"]);
        rowsetPtr->MoveNext();
      }
    }
    *apTypes = reinterpret_cast<IMTCollection*>(accountTypes.Detach());	
  }
   catch (_com_error & err)
  {
    return returnYAACError(err);
  }

  return S_OK;
 }

 STDMETHODIMP CMTAccountCatalog::GetAllAccountTypesAsRowset(IMTSQLRowset** apRowset)
 {
    if (!apRowset)
    return E_POINTER;


  try
  {
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init("queries\account");
    queryAdapter->SetQueryTag("__FIND_ACCOUNT_TYPES__");

		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		MTYAACEXECLib::IMTSQLRowsetPtr rowsetPtr = reader->ExecuteStatement(queryAdapter->GetQuery());
		*apRowset = reinterpret_cast<IMTSQLRowset*>(rowsetPtr.Detach());	
  }
  catch (_com_error & err)
  {
    return returnYAACError(err);
  }

  return S_OK;
 }


 STDMETHODIMP CMTAccountCatalog::GetAccountTypeByName(BSTR aName, IMTAccountType** apAccType)
 {
   if (!apAccType)
    return E_POINTER;


   try
    {
      GUID guid = __uuidof(MetraTech_Accounts_Type::AccountType);
      MTAccountTypeLib::IMTAccountTypePtr accTypePtr(guid);
      accTypePtr->InitializeByName(aName);

      *apAccType = reinterpret_cast<IMTAccountType*>(accTypePtr.Detach());	
    }
   catch (_com_error & err)
    {
      return returnYAACError(err);
    }

   return S_OK;
 }


 STDMETHODIMP CMTAccountCatalog::GetAccountTypeByID(long aType, IMTAccountType** apAccType)
 {
   if (!apAccType)
    return E_POINTER;


   try
    {
      GUID guid = __uuidof(MetraTech_Accounts_Type::AccountType);
      MTAccountTypeLib::IMTAccountTypePtr accTypePtr(guid);
      accTypePtr->InitializeByID(aType);

      *apAccType = reinterpret_cast<IMTAccountType*>(accTypePtr.Detach());	
    }
   catch (_com_error & err)
    {
      return returnYAACError(err);
    }

   return S_OK;
 }

STDMETHODIMP CMTAccountCatalog::FindAllAccountTypesWithOperation(BSTR operation, IMTCollectionReadOnly** apTypes)
 {
                                                    
  if (!apTypes)
    return E_POINTER;

  try
  {
		QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init("queries\\account");
    queryAdapter->SetQueryTag("__FIND_ACCOUNT_TYPES_WITH_OP_");
	  queryAdapter->AddParam("%%OPERATION%%", operation);

		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
		MTYAACEXECLib::IMTSQLRowsetPtr rowsetPtr = reader->ExecuteStatement(queryAdapter->GetQuery());

    GENERICCOLLECTIONLib::IMTCollectionPtr accountTypeNames(__uuidof(GENERICCOLLECTIONLib::MTCollectionEx));
    if (rowsetPtr->RecordCount > 0)
    {
      rowsetPtr->MoveFirst();
      while(!(bool)rowsetPtr->GetRowsetEOF())
      {
        _bstr_t name = rowsetPtr->Value["AccountTypeName"];
        accountTypeNames->Add(name);
        rowsetPtr->MoveNext();
      }
    }
    *apTypes = reinterpret_cast<IMTCollectionReadOnly*>(accountTypeNames.Detach());	
  }
   catch (_com_error & err)
  {
    return returnYAACError(err);
  }

  return S_OK;
 }

