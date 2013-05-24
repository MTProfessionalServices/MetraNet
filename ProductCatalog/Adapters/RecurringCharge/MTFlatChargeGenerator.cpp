// MTFlatChargeGenerator.cpp : Implementation of CMTFlatChargeGenerator

#include "StdAfx.h"
#include "MTFlatChargeGenerator.h"

#include <mtprogids.h>
#include <mtparamnames.h>

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" ) 

#include <QueryBuilder.h>
#include <DataAccessDefs.h>

// CMTFlatChargeGenerator

STDMETHODIMP CMTFlatChargeGenerator::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTChargeGenerator
	};

	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTFlatChargeGenerator::InternalGetArrearsCharges(long aPITypeID, long aIntervalID, long aBillingGroupID, long aRunID, BSTR aConfigPath, IMTRecurringChargeVisitor * pExecute)
{
	HRESULT hr = S_OK;
	try
	{
		// initialize the rowset ...
		hr = pExecute->GetRowset()->Init(aConfigPath) ;
		if (FAILED(hr))
		{
			return Error("CMTFlatChargeGenerator::GetArrearsCharges - rowset initialization failed", IID_IMTChargeGenerator, hr);
		}

    bool bIsOracle = (wcsicmp((const wchar_t *)pExecute->GetRowset()->GetDBType(), ORACLE_DATABASE_TYPE) == 0);

		// arrears case
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_RECUR_CHARGES_TEMP__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_ADVANCE_RECUR_CHARGES_TEMP__");
		pExecute->Visit();

		pExecute->GetRowset()->SetQueryTag("__INSERT_RECUR_CHARGES_TEMP__");	
    pExecute->GetRowset()->AddParam ("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_rc_advance_1" : L"");
    pExecute->GetRowset()->AddParam ("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_rc_advance_1");
		pExecute->GetRowset()->AddParam ("%%RECUR_CHARGE_TYPE%%", aPITypeID);
		pExecute->GetRowset()->AddParam ("%%INTERVAL_ID%%", aIntervalID);
		pExecute->GetRowset()->AddParam ("%%BILLING_GROUP_ID%%", aBillingGroupID);
		pExecute->GetRowset()->AddParam ("%%ID_RUN%%", aRunID);
		pExecute->GetRowset()->AddParam ("%%B_ADVANCE%%", "N");
		pExecute->Visit();

		pExecute->GetRowset()->SetQueryTag("__INSERT_RECUR_CHARGES_TEMP_GROUP_SUB__");	
		pExecute->GetRowset()->AddParam ("%%RECUR_CHARGE_TYPE%%", aPITypeID);
		pExecute->GetRowset()->AddParam ("%%INTERVAL_ID%%", aIntervalID);
		pExecute->GetRowset()->AddParam ("%%BILLING_GROUP_ID%%", aBillingGroupID);
		pExecute->GetRowset()->AddParam ("%%B_ADVANCE%%", "N");
		pExecute->GetRowset()->AddParam ("%%ID_RUN%%", aRunID);
		pExecute->Visit();
		
		PerParticipantOrPerSubscriptionQueryBuilder builder;
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_CANDIDATES__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_ARREARS_CHARGE_CANDIDATES__");
    pExecute->GetRowset()->AddParam("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_recurring_charge_candidate" : L"");
    pExecute->GetRowset()->AddParam("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_recurring_charge_candidate");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_ARREARS_CHARGES__");	
		builder.BuildPerParticipantArrearsQuery(pExecute->GetRowset(), true, bIsOracle);
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_ARREARS_CHARGES__");	
		builder.BuildPerSubscriptionArrearsQuery(pExecute->GetRowset(), false, bIsOracle);
		pExecute->Visit();

		pExecute->GetRowset()->SetQueryTag("__GET_ADVANCE_RECUR_CHARGES__");	
		pExecute->VisitConnected();
	}
	catch(_com_error & err)
	{
		return err.Error();
	}

	return hr;
}

STDMETHODIMP CMTFlatChargeGenerator::InternalGetAdvanceCharges(long aPITypeID, long aIntervalID, long aBillingGroupID, long aRunID, BSTR aConfigPath, IMTRecurringChargeVisitor * pExecute)
{
	HRESULT hr = S_OK;
	try
	{
		// initialize the rowset ...
		hr = pExecute->GetRowset()->Init(aConfigPath) ;
		if (FAILED(hr))
		{
			return Error("CMTFlatChargeGenerator::GetAdvanceCharges - rowset initialization failed", IID_IMTChargeGenerator, hr);
		}

    bool bIsOracle = (wcsicmp((const wchar_t *)pExecute->GetRowset()->GetDBType(), ORACLE_DATABASE_TYPE) == 0);

		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_RECUR_CHARGES_TEMP__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_ADVANCE_RECUR_CHARGES_TEMP__");
		pExecute->Visit();

		pExecute->GetRowset()->SetQueryTag("__INSERT_RECUR_CHARGES_TEMP__");	
    pExecute->GetRowset()->AddParam ("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_rc_advance_1" : L"");
    pExecute->GetRowset()->AddParam ("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_rc_advance_1");
		pExecute->GetRowset()->AddParam ("%%RECUR_CHARGE_TYPE%%", aPITypeID);
		pExecute->GetRowset()->AddParam ("%%INTERVAL_ID%%", aIntervalID);
		pExecute->GetRowset()->AddParam ("%%BILLING_GROUP_ID%%", aBillingGroupID);
		pExecute->GetRowset()->AddParam ("%%B_ADVANCE%%", "Y");
		pExecute->GetRowset()->AddParam ("%%ID_RUN%%", aRunID);
		pExecute->Visit();
		
		pExecute->GetRowset()->SetQueryTag("__INSERT_RECUR_CHARGES_TEMP_GROUP_SUB__");	
		pExecute->GetRowset()->AddParam ("%%RECUR_CHARGE_TYPE%%", aPITypeID);
		pExecute->GetRowset()->AddParam ("%%INTERVAL_ID%%", aIntervalID);
		pExecute->GetRowset()->AddParam ("%%BILLING_GROUP_ID%%", aBillingGroupID);
		pExecute->GetRowset()->AddParam ("%%B_ADVANCE%%", "Y");
		pExecute->GetRowset()->AddParam ("%%ID_RUN%%", aRunID);
		pExecute->Visit();
		
		PerParticipantOrPerSubscriptionQueryBuilder builder;
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_CANDIDATES__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_INITIAL_CHARGE_CANDIDATES__");	
    pExecute->GetRowset()->AddParam("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_recurring_charge_candidate" : L"");
    pExecute->GetRowset()->AddParam("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_recurring_charge_candidate");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_INITIAL_CHARGES__");	
		builder.BuildPerParticipantInitialQuery(pExecute->GetRowset(), true, bIsOracle);
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_INITIAL_CHARGES__");	
		builder.BuildPerSubscriptionInitialQuery(pExecute->GetRowset(), false, bIsOracle);
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_CANDIDATES__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_ADVANCE_CHARGE_CANDIDATES__");	
    pExecute->GetRowset()->AddParam("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_recurring_charge_candidate" : L"");
    pExecute->GetRowset()->AddParam("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_recurring_charge_candidate");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_ADVANCE_CHARGES__");	
		builder.BuildPerParticipantAdvanceQuery(pExecute->GetRowset());
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_ADVANCE_CHARGES__");	
		builder.BuildPerSubscriptionAdvanceQuery(pExecute->GetRowset());
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_CANDIDATES__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_INITIAL_CREDIT_CANDIDATES__");	
    pExecute->GetRowset()->AddParam("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_recurring_charge_candidate" : L"");
    pExecute->GetRowset()->AddParam("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_recurring_charge_candidate");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_INITIAL_CREDITS__");	
		builder.BuildPerParticipantInitialCreditQuery(pExecute->GetRowset());
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_INITIAL_CREDITS__");	
		builder.BuildPerSubscriptionInitialCreditQuery(pExecute->GetRowset());
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_CANDIDATES__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_ADVANCE_CREDIT_CANDIDATES__");	
    pExecute->GetRowset()->AddParam("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_recurring_charge_candidate" : L"");
    pExecute->GetRowset()->AddParam("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_recurring_charge_candidate");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_ADVANCE_CREDITS__");	
		builder.BuildPerParticipantAdvanceCreditQuery(pExecute->GetRowset());
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_ADVANCE_CREDITS__");	
		builder.BuildPerSubscriptionAdvanceCreditQuery(pExecute->GetRowset());
		pExecute->Visit();

		pExecute->GetRowset()->SetQueryTag("__GET_ADVANCE_RECUR_CHARGES__");	
		pExecute->VisitConnected();
	}
	catch(_com_error & err)
	{
		return err.Error();
	}

	return hr;
}

STDMETHODIMP CMTFlatChargeGenerator::GetArrearsCharges(long aPITypeID, long aIntervalID, long aBillingGroupID, long aRunID, BSTR aConfigPath, IMTSQLRowset** apCharges)
{
  HRESULT hr = S_OK;
	if (apCharges == NULL) 
		return E_POINTER;
	*apCharges = NULL;

  try
  {
		// create the rowset ...
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET) ;
    CMTRecurringChargeExecuteVisitor visit(rowset);
    hr =InternalGetArrearsCharges(aPITypeID, aIntervalID, aBillingGroupID, aRunID, aConfigPath, &visit);

		*apCharges = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch(_com_error & err)
	{
		return err.Error();
	}

	return hr;
}

STDMETHODIMP CMTFlatChargeGenerator::GetAdvanceCharges(long aPITypeID, long aIntervalID, long aBillingGroupID, long aRunID, BSTR aConfigPath, IMTSQLRowset** apCharges)
{
  HRESULT hr = S_OK;
	if (apCharges == NULL) 
		return E_POINTER;
	*apCharges = NULL;

  try
  {
		// create the rowset ...
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET) ;
    CMTRecurringChargeExecuteVisitor visit(rowset);
    hr =InternalGetAdvanceCharges(aPITypeID, aIntervalID, aBillingGroupID, aRunID, aConfigPath, &visit);

		*apCharges = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch(_com_error & err)
	{
		return err.Error();
	}

	return hr;
}

STDMETHODIMP CMTFlatChargeGenerator::GetArrearsChargesScript(long aPITypeID, long aIntervalID, long aBillingGroupID, long aRunID, BSTR aConfigPath, BSTR * apScript)
{
  HRESULT hr = S_OK;
  try 
  {
		// create the rowset ...
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET) ;
    rowset->Init(L"Queries\\ProductCatalog");
    bool bIsOracle = (wcsicmp((const wchar_t *)rowset->GetDBType(), ORACLE_DATABASE_TYPE) == 0);
    std::auto_ptr<IMTRecurringChargeScriptVisitor> visit(
      bIsOracle ?
      static_cast<IMTRecurringChargeScriptVisitor*>(new CMTRecurringChargeOracleScriptVisitor(rowset)) :
      static_cast<IMTRecurringChargeScriptVisitor*>(new CMTRecurringChargeSQLServerScriptVisitor(rowset)));
    hr = InternalGetArrearsCharges(aPITypeID, aIntervalID, aBillingGroupID, aRunID, aConfigPath, visit.get());
    if(FAILED(hr)) return hr;
    *apScript = visit->GetScript().copy();
  }
  catch(_com_error & err)
	{
		return err.Error();
	}

	return hr;
}

STDMETHODIMP CMTFlatChargeGenerator::GetAdvanceChargesScript(long aPITypeID, long aIntervalID, long aBillingGroupID, long aRunID, BSTR aConfigPath, BSTR * apScript)
{
  HRESULT hr = S_OK;
  try 
  {
		// create the rowset ...
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET) ;
    rowset->Init(L"Queries\\ProductCatalog");
    bool bIsOracle = (wcsicmp((const wchar_t *)rowset->GetDBType(), ORACLE_DATABASE_TYPE) == 0);
    std::auto_ptr<IMTRecurringChargeScriptVisitor> visit(
      bIsOracle ?
      static_cast<IMTRecurringChargeScriptVisitor*>(new CMTRecurringChargeOracleScriptVisitor(rowset)) :
      static_cast<IMTRecurringChargeScriptVisitor*>(new CMTRecurringChargeSQLServerScriptVisitor(rowset)));
    hr = InternalGetAdvanceCharges(aPITypeID, aIntervalID, aBillingGroupID, aRunID, aConfigPath, visit.get());
    if(FAILED(hr)) return hr;
    *apScript = visit->GetScript().copy();
  }
  catch(_com_error & err)
	{
		return err.Error();
	}

	return hr;
}

