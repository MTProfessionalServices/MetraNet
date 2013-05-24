// MTUDChargeGenerator.cpp : Implementation of CMTUDChargeGenerator

#include "StdAfx.h"
#include "MTUDChargeGenerator.h"

#include <mtprogids.h>
#include <mtparamnames.h>

#include <QueryBuilder.h>
#include <DataAccessDefs.h>

void PerParticipantOrPerSubscriptionQueryBuilder::BuildPerParticipantArrearsQuery(ROWSETLib::IMTSQLRowsetPtr rowset, 
                                                                                  bool createTable, bool isOracle)
{
	BuildPerParticipantAdvanceQuery(rowset);
  if (isOracle)
  {
    rowset->AddParamIfFound(L"%%INSERT_INTO_SELECT_FROM%%", L"INSERT INTO tmp_recurring_charges", VARIANT_TRUE);
    rowset->AddParamIfFound(L"%%SELECT_INTO%%", L"", VARIANT_TRUE);
  }
  else
  {
    rowset->AddParamIfFound(L"%%INSERT_INTO_SELECT_FROM%%", createTable ? L"" : L"INSERT INTO #tmp_recurring_charges", VARIANT_TRUE);
    rowset->AddParamIfFound(L"%%SELECT_INTO%%", createTable ? L"INTO #tmp_recurring_charges" : L"", VARIANT_TRUE);
  }
}

void PerParticipantOrPerSubscriptionQueryBuilder::BuildPerSubscriptionArrearsQuery(ROWSETLib::IMTSQLRowsetPtr rowset, 
                                                                                   bool createTable, bool isOracle)
{
	BuildPerSubscriptionAdvanceQuery(rowset);
  if (isOracle)
  {
    rowset->AddParamIfFound(L"%%INSERT_INTO_SELECT_FROM%%", L"INSERT INTO tmp_recurring_charges", VARIANT_TRUE);
    rowset->AddParamIfFound(L"%%SELECT_INTO%%", L"", VARIANT_TRUE);
  }
  else
  {
    rowset->AddParamIfFound(L"%%INSERT_INTO_SELECT_FROM%%", createTable ? L"" : L"INSERT INTO #tmp_recurring_charges", VARIANT_TRUE);
    rowset->AddParamIfFound(L"%%SELECT_INTO%%", createTable ? L"INTO #tmp_recurring_charges" : L"", VARIANT_TRUE);
  }
}

void PerParticipantOrPerSubscriptionQueryBuilder::BuildPerParticipantAdvanceQuery(ROWSETLib::IMTSQLRowsetPtr rowset)
{
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_TABLES%%", L"t_payment_redir_history prevpay", VARIANT_TRUE); 
	rowset->AddParam(L"%%PER_SUBSCRIPTION_QUALIFIYING_ORIGINATOR_TIME_CLAUSE%%", L"", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_SUBSCRIPTION_CANDIDATE_ORIGINATOR_TIME_CLAUSE%%", L"", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_WHERE_CLAUSE%%", L"tmp.c__AccountID=prevpay.id_payee\nAND\ntmp.b_per_subscription='N'", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_WHERE_CLAUSE2%%", L"AND\ntmp.b_per_subscription='N'", VARIANT_TRUE);
}

void PerParticipantOrPerSubscriptionQueryBuilder::BuildPerSubscriptionAdvanceQuery(ROWSETLib::IMTSQLRowsetPtr rowset)
{
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_TABLES%%", L"t_gsub_recur_map grm\nINNER JOIN t_sub s ON grm.id_group=s.id_group\nINNER JOIN t_payment_redir_history prevpay ON prevpay.id_payee=grm.id_acc", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_SUBSCRIPTION_QUALIFIYING_ORIGINATOR_TIME_CLAUSE%%", L"AND rer.run_vt_start BETWEEN grm.tt_start AND grm.tt_end", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_SUBSCRIPTION_CANDIDATE_ORIGINATOR_TIME_CLAUSE%%", L"OR\ngrm.tt_end < tmp.candidate_originator_tt_end", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_WHERE_CLAUSE%%", L"s.id_sub=tmp.c__SubscriptionID AND grm.id_prop=tmp.c__PriceableItemInstanceID\nAND\ntmp.b_per_subscription='Y'", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_WHERE_CLAUSE2%%", L"AND\ntmp.b_per_subscription='Y'", VARIANT_TRUE);
}

void PerParticipantOrPerSubscriptionQueryBuilder::BuildPerParticipantAdvanceCreditQuery(ROWSETLib::IMTSQLRowsetPtr rowset)
{
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_TABLES%%", L"t_payment_redir_history prevpay", VARIANT_TRUE); 
	rowset->AddParam(L"%%PER_SUBSCRIPTION_QUALIFIYING_ORIGINATOR_TIME_CLAUSE%%", L"", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_SUBSCRIPTION_CANDIDATE_ORIGINATOR_TIME_CLAUSE%%", L"", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_WHERE_CLAUSE%%", L"tmp.c__AccountID=prevpay.id_payee\nAND\ntmp.b_per_subscription='N'", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_WHERE_CLAUSE2%%", L"AND\ntmp.b_per_subscription='N'", VARIANT_TRUE);
}

void PerParticipantOrPerSubscriptionQueryBuilder::BuildPerSubscriptionAdvanceCreditQuery(ROWSETLib::IMTSQLRowsetPtr rowset)
{
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_TABLES%%", L"t_gsub_recur_map grm\nINNER JOIN t_sub s ON grm.id_group=s.id_group\nINNER JOIN t_payment_redir_history prevpay ON prevpay.id_payee=grm.id_acc", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_SUBSCRIPTION_QUALIFIYING_ORIGINATOR_TIME_CLAUSE%%", L"AND rer.run_vt_start BETWEEN grm.tt_start AND grm.tt_end", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_SUBSCRIPTION_CANDIDATE_ORIGINATOR_TIME_CLAUSE%%", L"OR\ngrm.tt_end < tmp.candidate_originator_tt_end", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_WHERE_CLAUSE%%", L"s.id_sub=tmp.c__SubscriptionID AND grm.id_prop=tmp.c__PriceableItemInstanceID\nAND\ntmp.b_per_subscription='Y'", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_WHERE_CLAUSE2%%", L"AND\ntmp.b_per_subscription='Y'", VARIANT_TRUE);
}

void PerParticipantOrPerSubscriptionQueryBuilder::BuildPerParticipantInitialQuery(ROWSETLib::IMTSQLRowsetPtr rowset, 
                                                                                  bool createTable, bool isOracle)
{
	BuildPerParticipantAdvanceQuery(rowset);
	rowset->AddParam(L"%%PER_SUBSCRIPTION_ORIGINATOR_CHARGE_WHERE_CLASE%%", L"", VARIANT_TRUE);
  if (isOracle)
  {
    rowset->AddParamIfFound(L"%%INSERT_INTO_SELECT_FROM%%", L"INSERT INTO tmp_recurring_charges", VARIANT_TRUE);
    rowset->AddParamIfFound(L"%%SELECT_INTO%%", L"", VARIANT_TRUE);
  }
  else
  {
    rowset->AddParamIfFound(L"%%INSERT_INTO_SELECT_FROM%%", createTable ? L"" : L"INSERT INTO #tmp_recurring_charges", VARIANT_TRUE);
    rowset->AddParamIfFound(L"%%SELECT_INTO%%", createTable ? L"INTO #tmp_recurring_charges" : L"", VARIANT_TRUE);
  }
}

void PerParticipantOrPerSubscriptionQueryBuilder::BuildPerSubscriptionInitialQuery(ROWSETLib::IMTSQLRowsetPtr rowset, 
                                                                                   bool createTable, bool isOracle)
{
	BuildPerSubscriptionAdvanceQuery(rowset);
	rowset->AddParam(L"%%PER_SUBSCRIPTION_ORIGINATOR_CHARGE_WHERE_CLASE%%", L"OR\ngrm.vt_start BETWEEN prevbinterval.dt_start AND prevbinterval.dt_end", VARIANT_TRUE);
  if (isOracle)
  {
    rowset->AddParamIfFound(L"%%INSERT_INTO_SELECT_FROM%%", L"INSERT INTO tmp_recurring_charges", VARIANT_TRUE);
    rowset->AddParamIfFound(L"%%SELECT_INTO%%", L"", VARIANT_TRUE);
  }
  else
  {
    rowset->AddParamIfFound(L"%%INSERT_INTO_SELECT_FROM%%", createTable ? L"" : L"INSERT INTO #tmp_recurring_charges", VARIANT_TRUE);
    rowset->AddParamIfFound(L"%%SELECT_INTO%%", createTable ? L"INTO #tmp_recurring_charges" : L"", VARIANT_TRUE);
  }
}

void PerParticipantOrPerSubscriptionQueryBuilder::BuildPerParticipantInitialCreditQuery(ROWSETLib::IMTSQLRowsetPtr rowset)
{
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_TABLES%%", L"t_payment_redir_history prevpay", VARIANT_TRUE); 
	rowset->AddParam(L"%%PER_SUBSCRIPTION_QUALIFIYING_ORIGINATOR_TIME_CLAUSE%%", L"", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_SUBSCRIPTION_CANDIDATE_ORIGINATOR_TIME_CLAUSE%%", L"", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_WHERE_CLAUSE%%", L"tmp.c__AccountID=prevpay.id_payee\nAND\ntmp.b_per_subscription='N'", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_WHERE_CLAUSE2%%", L"AND\ntmp.b_per_subscription='N'", VARIANT_TRUE);
}

void PerParticipantOrPerSubscriptionQueryBuilder::BuildPerSubscriptionInitialCreditQuery(ROWSETLib::IMTSQLRowsetPtr rowset)
{
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_TABLES%%", L"t_gsub_recur_map grm\nINNER JOIN t_sub s ON grm.id_group=s.id_group\nINNER JOIN t_payment_redir_history prevpay ON prevpay.id_payee=grm.id_acc", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_SUBSCRIPTION_QUALIFIYING_ORIGINATOR_TIME_CLAUSE%%", L"AND rer.run_vt_start BETWEEN grm.tt_start AND grm.tt_end", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_SUBSCRIPTION_CANDIDATE_ORIGINATOR_TIME_CLAUSE%%", L"OR\ngrm.tt_end < tmp.candidate_originator_tt_end", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_WHERE_CLAUSE%%", L"s.id_sub=tmp.c__SubscriptionID AND grm.id_prop=tmp.c__PriceableItemInstanceID\nAND\ntmp.b_per_subscription='Y'", VARIANT_TRUE);
	rowset->AddParam(L"%%PER_PARTICIPANT_OR_PER_SUBSCRIPTION_WHERE_CLAUSE2%%", L"AND\ntmp.b_per_subscription='Y'", VARIANT_TRUE);
}

// CMTUDChargeGenerator

STDMETHODIMP CMTUDChargeGenerator::InterfaceSupportsErrorInfo(REFIID riid)
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

STDMETHODIMP CMTUDChargeGenerator::InternalGetArrearsCharges(long aPITypeID, long aIntervalID, long aBillingGroupID, long aRunID, BSTR aConfigPath, IMTRecurringChargeVisitor * pExecute)
{
	HRESULT hr = S_OK;

	try
	{
		// initialize the rowset ...
		hr = pExecute->GetRowset()->Init(aConfigPath) ;
		if (FAILED(hr))
		{
			return Error("CMTUDChargeGenerator::GetArrearsCharges - rowset initialization failed", IID_IMTChargeGenerator, hr);
		}

    bool bIsOracle = (wcsicmp((const wchar_t *)pExecute->GetRowset()->GetDBType(), ORACLE_DATABASE_TYPE) == 0);

		// arrears case
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_RECUR_CHARGES_TEMP__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_ADVANCE_RECUR_CHARGES_TEMP__");
		pExecute->Visit();

		pExecute->GetRowset()->SetQueryTag("__INSERT_UDRC_RECUR_CHARGES_TEMP__");
    pExecute->GetRowset()->AddParam("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_rc_advance_1" : L"");
    pExecute->GetRowset()->AddParam("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_rc_advance_1");
		pExecute->GetRowset()->AddParam ("%%RECUR_CHARGE_TYPE%%", aPITypeID);
		pExecute->GetRowset()->AddParam ("%%INTERVAL_ID%%", aIntervalID);
		pExecute->GetRowset()->AddParam ("%%BILLING_GROUP_ID%%", aBillingGroupID);
		pExecute->GetRowset()->AddParam ("%%B_ADVANCE%%", "N");
		pExecute->GetRowset()->AddParam ("%%ID_RUN%%", aRunID);
		pExecute->Visit();

		pExecute->GetRowset()->SetQueryTag("__INSERT_UDRC_RECUR_CHARGES_GROUP_SUB_TEMP__");
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

STDMETHODIMP CMTUDChargeGenerator::InternalGetAdvanceCharges(long aPITypeID, long aIntervalID, long aBillingGroupID, long aRunID, BSTR aConfigPath, IMTRecurringChargeVisitor * pExecute)
{
	HRESULT hr = S_OK;

	try
	{
		// TODO: Add your implementation code here
		// create the rowset ...
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET) ;
		// initialize the rowset ...
		hr = pExecute->GetRowset()->Init(aConfigPath) ;
		if (FAILED(hr))
		{
			return Error("CMTUDChargeGenerator::GetAdvanceCharges - rowset initialization failed", IID_IMTChargeGenerator, hr);
		}

    bool bIsOracle = (wcsicmp((const wchar_t *)pExecute->GetRowset()->GetDBType(), ORACLE_DATABASE_TYPE) == 0);

		// advance case
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_RECUR_CHARGES_TEMP__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_ADVANCE_RECUR_CHARGES_TEMP__");
		pExecute->Visit();

		pExecute->GetRowset()->SetQueryTag("__INSERT_UDRC_RECUR_CHARGES_TEMP__");	
    pExecute->GetRowset()->AddParam("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_rc_advance_1" : L"");
    pExecute->GetRowset()->AddParam("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_rc_advance_1");
		pExecute->GetRowset()->AddParam ("%%RECUR_CHARGE_TYPE%%", aPITypeID);
		pExecute->GetRowset()->AddParam ("%%INTERVAL_ID%%", aIntervalID);
		pExecute->GetRowset()->AddParam ("%%BILLING_GROUP_ID%%", aBillingGroupID);
		pExecute->GetRowset()->AddParam ("%%B_ADVANCE%%", "Y");
		pExecute->GetRowset()->AddParam ("%%ID_RUN%%", aRunID);
		pExecute->Visit();

		pExecute->GetRowset()->SetQueryTag("__INSERT_UDRC_RECUR_CHARGES_GROUP_SUB_TEMP__");	
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

		// Handle the super-ugly case of UDRC corrections; this is 
		// when some one has changed a UDRC unit value in a way that
		// changes a previously billed charge.
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_RECUR_CHARGES_TEMP__");
		pExecute->Visit();

		pExecute->GetRowset()->SetQueryTag("__INSERT_UDRC_CORRECTION_RECUR_CHARGES_TEMP__");	
    pExecute->GetRowset()->AddParam ("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_rc_advance_1" : L"");
    pExecute->GetRowset()->AddParam ("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_rc_advance_1");
		pExecute->GetRowset()->AddParam ("%%RECUR_CHARGE_TYPE%%", aPITypeID);
		pExecute->GetRowset()->AddParam ("%%INTERVAL_ID%%", aIntervalID);
		pExecute->GetRowset()->AddParam ("%%BILLING_GROUP_ID%%", aBillingGroupID);
		pExecute->GetRowset()->AddParam ("%%B_ADVANCE%%", "Y");
		pExecute->GetRowset()->AddParam ("%%ID_RUN%%", aRunID);
		pExecute->Visit();

		pExecute->GetRowset()->SetQueryTag("__INSERT_UDRC_CORRECTION_RECUR_CHARGES_GROUP_SUB_TEMP__");	
		pExecute->GetRowset()->AddParam ("%%RECUR_CHARGE_TYPE%%", aPITypeID);
		pExecute->GetRowset()->AddParam ("%%INTERVAL_ID%%", aIntervalID);
		pExecute->GetRowset()->AddParam ("%%BILLING_GROUP_ID%%", aBillingGroupID);
		pExecute->GetRowset()->AddParam ("%%B_ADVANCE%%", "Y");
		pExecute->GetRowset()->AddParam ("%%ID_RUN%%", aRunID);
		pExecute->Visit();

		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_CANDIDATES__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_INITIAL_CORRECTION_CANDIDATES__");	
    pExecute->GetRowset()->AddParam("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_recurring_charge_candidate" : L"");
    pExecute->GetRowset()->AddParam("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_recurring_charge_candidate");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_CORRECTIONS_CANDIDATES_WITH_CHANGES__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_CORRECTIONS_CANDIDATES_WITH_CHANGES__");
    pExecute->GetRowset()->AddParam ("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_recur_charge_candidate2" : L"");
    pExecute->GetRowset()->AddParam ("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_recur_charge_candidate2");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_INITIAL_CORRECTIONS__");	
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_CANDIDATES__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_ADVANCE_CORRECTION_CANDIDATES__");	
    pExecute->GetRowset()->AddParam("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_recurring_charge_candidate" : L"");
    pExecute->GetRowset()->AddParam("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_recurring_charge_candidate");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_CORRECTIONS_CANDIDATES_WITH_CHANGES__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_CORRECTIONS_CANDIDATES_WITH_CHANGES__");
    pExecute->GetRowset()->AddParam ("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_recur_charge_candidate2" : L"");
    pExecute->GetRowset()->AddParam ("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_recur_charge_candidate2");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_ADVANCE_CORRECTIONS__");	
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_CANDIDATES__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_ADVANCE_DEBIT_CORRECTION_CANDIDATES__");	
    pExecute->GetRowset()->AddParam("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_recurring_charge_candidate" : L"");
    pExecute->GetRowset()->AddParam("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_recurring_charge_candidate");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_CORRECTIONS_CANDIDATES_WITH_CHANGES__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_DEBIT_CORRECTIONS_CANDIDATES_WITH_CHANGES__");
    pExecute->GetRowset()->AddParam ("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_recur_charge_candidate2" : L"");
    pExecute->GetRowset()->AddParam ("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_recur_charge_candidate2");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_ADVANCE_DEBIT_CORRECTIONS__");	
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_CANDIDATES__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_INITIAL_DEBIT_CORRECTION_CANDIDATES__");	
    pExecute->GetRowset()->AddParam("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_recurring_charge_candidate" : L"");
    pExecute->GetRowset()->AddParam("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_recurring_charge_candidate");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__TRUNCATE_CORRECTIONS_CANDIDATES_WITH_CHANGES__");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_DEBIT_CORRECTIONS_CANDIDATES_WITH_CHANGES__");
    pExecute->GetRowset()->AddParam ("%%INSERT_INTO_CLAUSE%%", bIsOracle ? L"INSERT INTO tmp_recur_charge_candidate2" : L"");
    pExecute->GetRowset()->AddParam ("%%INTO_CLAUSE%%", bIsOracle ? L"" : L"INTO #tmp_recur_charge_candidate2");
		pExecute->Visit();
		pExecute->GetRowset()->SetQueryTag("__GET_INITIAL_DEBIT_CORRECTIONS__");	
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

STDMETHODIMP CMTUDChargeGenerator::GetArrearsChargesScript(long aPITypeID, long aIntervalID, long aBillingGroupID, long aRunID, BSTR aConfigPath, BSTR * apScript)
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

STDMETHODIMP CMTUDChargeGenerator::GetAdvanceChargesScript(long aPITypeID, long aIntervalID, long aBillingGroupID, long aRunID, BSTR aConfigPath, BSTR * apScript)
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

STDMETHODIMP CMTUDChargeGenerator::GetArrearsCharges(long aPITypeID, long aIntervalID, long aBillingGroupID, long aRunID, BSTR aConfigPath, IMTSQLRowset** apCharges)
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

STDMETHODIMP CMTUDChargeGenerator::GetAdvanceCharges(long aPITypeID, long aIntervalID, long aBillingGroupID, long aRunID, BSTR aConfigPath, IMTSQLRowset** apCharges)
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
