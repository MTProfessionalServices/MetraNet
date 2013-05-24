// MTSubscriptionCatalogWriter.cpp : Implementation of CMTSubscriptionCatalogWriter

#include "StdAfx.h"
#include "MTSubscriptionCatalogWriter.h"

#include <mtcom.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <metra.h>
#include <mtautocontext.h>
#include <mtprogids.h>
#include <MTTypeConvert.h>
#include <formatdbvalue.h>
#include <MTUtil.h>
#include <mtglobal_msg.h>
#include <MTDate.h>
#include <mttime.h>
#include <RowsetDefs.h>
#include <DataAccessDefs.h>
#include <adoutil.h>

#import <MTSubscriptionExec.tlb> rename ("EOF", "EOFX")
#import <MTProductCatalogExec.tlb>  rename ("EOF", "EOFX")
#import <QueryAdapter.tlb> rename("UserName", "QueryAdapterUserName") rename("GetUserName", "QAGetUserName")
#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.DataAccess.tlb> inject_statement("using namespace mscorlib;")


// CMTSubscriptionCatalogWriter

HRESULT CMTSubscriptionCatalogWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTSubscriptionCatalogWriter::CanBePooled()
{
	return FALSE;
} 

void CMTSubscriptionCatalogWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTSubscriptionCatalogWriter::SubscribeToGroups(IMTSessionContext*    apCtx,
                                                             IMTCollection*        pCol,  // Collection of MTSubInfo
                                                             IMTProgress*          pProgress,
                                                             VARIANT_BOOL          bUnsubscribeConflicting,
                                                             VARIANT_BOOL*         pDateModified,
                                                             IMTSQLRowset*         pErrorRs)
{
  MTAutoContext context(m_spObjectContext);
  
  try
  {
    if (VARIANT_TRUE == bUnsubscribeConflicting)
    {
      HRESULT hr = UnsubscribeFromConflictingToGroup(apCtx, pCol, pProgress, pErrorRs);
      if (FAILED(hr)) return hr;
    }
    MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr subWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
    subWriter->SubscribeToGroups(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext *>(apCtx), 
                                 reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCollection *>(pCol), 
                                 reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTProgress *>(pProgress)
                                 , pDateModified, 
                                 reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSQLRowset *>(pErrorRs));
  }
  catch(_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();

  return S_OK;
}

STDMETHODIMP CMTSubscriptionCatalogWriter::SubscribeAccounts(IMTSessionContext*    apCtx,
                                                             IMTCollection*        pCol,  // Collection of MTSubInfo
                                                             IMTProgress*          pProgress,
                                                             VARIANT_BOOL          bUnsubscribeConflicting,
                                                             VARIANT_BOOL*         pDateModified,
                                                             IMTSQLRowset*         pErrorRs)
{
  MTAutoContext context(m_spObjectContext);
  
  try
  {
    if (VARIANT_TRUE == bUnsubscribeConflicting)
    {
      HRESULT hr = UnsubscribeFromConflictingToIndividual(apCtx, pCol, pProgress, pErrorRs);
      if (FAILED(hr)) return hr;
    }
      MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr subWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
      subWriter->SubscribeAccounts(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext *>(apCtx), 
                                   reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCollection *>(pCol), 
                                   reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTProgress *>(pProgress)
                                   , pDateModified, 
                                   reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSQLRowset *>(pErrorRs));
  }
  catch(_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();

  return S_OK;
}

STDMETHODIMP CMTSubscriptionCatalogWriter::UnsubscribeFromConflictingToGroup(IMTSessionContext*    apCtx,
                                                                             IMTCollection*        pCol,  // Collection of MTSubInfo
                                                                             IMTProgress*          pProgress,
                                                                             IMTSQLRowset*         pErrorRs)
{
  bool anyErrors = false;
  try
  {
    _bstr_t sTableCreationDebugParam = "";
    _bstr_t sTableDebugParam = "";
    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init("Queries\\ProductCatalog");
    
    wstring wstrDBType = rowset->GetDBType() ;
    BOOL isOracle = (wcscmp(wstrDBType.c_str(), ORACLE_DATABASE_TYPE) == 0);
		
    if(!isOracle)
    {
      sTableCreationDebugParam = "tempdb..#";
      sTableDebugParam = "#";
    }

    MTPRODUCTCATALOGEXECLib::IMTCollectionPtr col(pCol);
    MTPRODUCTCATALOGEXECLib::IMTProgressPtr progress(pProgress);
	MTSubscriptionExecLib::IMTSessionContextPtr pContext(apCtx);

    // Create a temporary table and do a "batch" insert of args into the table.
    //
    rowset->Clear();
    rowset->SetQueryTag("__CREATE_SUBSCRIBE_TO_GROUP_BATCH_TABLE__");
    rowset->AddParamIfFound(L"%%TEMPDEBUG%%", sTableCreationDebugParam);
    rowset->AddParamIfFound(L"%%DEBUG%%", sTableDebugParam);

    rowset->Execute();
    
    // Create temporary tables that drive unsubscription
    rowset->Clear();
	rowset->SetQueryTag("__CREATE_UNSUBSCRIBE_BATCH_TABLE__");
    rowset->Execute();
    rowset->Clear();
	rowset->SetQueryTag("__CREATE_UNSUBSCRIBE_INDIVIDUAL_BATCH_TABLE__");
    rowset->Execute();

    _bstr_t query;
    DATE now = GetMTOLETime();
    long lAccountId = pContext->AccountID;
    long j = 0;
    long size = col->GetCount();

	MetraTech_DataAccess::IIdGenerator2Ptr idAuditGenerator(__uuidof(MetraTech_DataAccess::IdGenerator));
    idAuditGenerator->Initialize("id_audit", size);

    for(long i = 1; i <= size; i++) 
    {
      MTPRODUCTCATALOGLib::IMTSubInfoPtr memberPtr =  col->GetItem(i);
	
	  if (isOracle && i == 1) 
	    query = "begin\n";

      if(memberPtr->IsGroupSub)
      {
        QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
        pQueryAdapter->Init("Queries\\ProductCatalog");
        pQueryAdapter->SetQueryTag(L"__INSERT_SUBSCRIBE_TO_GROUP_BATCH_ARGS__");
        pQueryAdapter->AddParamIfFound(L"%%DEBUG%%", sTableDebugParam);
        pQueryAdapter->AddParam(L"%%ID_PO%%", _variant_t(memberPtr->ProdOfferingID));
        pQueryAdapter->AddParam(L"%%ID_GROUP%%", _variant_t(memberPtr->GroupSubID)) ;
        pQueryAdapter->AddParam(L"%%ID_ACC%%", _variant_t(memberPtr->AccountID)) ;
        pQueryAdapter->AddParam(L"%%VT_START%%", _variant_t(memberPtr->SubsStartDate, VT_DATE)) ;
        pQueryAdapter->AddParam(L"%%VT_END%%", _variant_t(memberPtr->SubsEndDate, VT_DATE)) ;
        pQueryAdapter->AddParam(L"%%TT_NOW%%", _variant_t(now, VT_DATE)) ;
        pQueryAdapter->AddParam(L"%%ID_GSUB_CORP%%", _variant_t(memberPtr->CorporateAccountID));
        pQueryAdapter->AddParam(L"%%ID_AUDIT%%", _variant_t(idAuditGenerator->NextId)) ;
        pQueryAdapter->AddParam(L"%%ID_EVENT%%", _variant_t(long(AuditEventsLib::AUDITEVENT_GSUB_MEMBER_DELETE))) ;
        pQueryAdapter->AddParam(L"%%ID_USERID%%", _variant_t(lAccountId)) ;
        pQueryAdapter->AddParam(L"%%ID_ENTITYTYPE%%", _variant_t(long(AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT))) ;
        query += pQueryAdapter->GetQuery();
        j++;
      }

      // Do our inserts in groups of 100 (seems to amortize the insert cost pretty well).
      if((j%100) == 0)
      {
        rowset->Clear();
		if (isOracle) query += "\nend;\n";
        rowset->SetQueryString(query);
        rowset->Execute();
        query = L"";
        j = 0;
        if(progress != NULL)
        {
          progress->SetProgress(i, size);
        }
      }
    }

    // Insert any stragglers
    if(query.length() > 0)
    {
      rowset->Clear();
      if (isOracle) query += "\nend;\n";
      rowset->SetQueryString(query);
      rowset->Execute();
      query = L"";
      if(progress != NULL)
      {
        progress->SetProgress(size, size);
      }
    }

    // Now execute code to identify confliciting subscriptions.
    // then execute code to unsubscribe both group and individual subscriptions that conflict.
    rowset->Clear();
    rowset->SetQueryTag(L"__IDENTIFY_CONFLICTING_SUBSCRIPTIONS__");
    rowset->AddParam(L"%%DEBUG%%", sTableDebugParam);
    rowset->AddParam(L"%%TT_NOW%%", _variant_t(now, VT_DATE)) ;
    rowset->AddParam(L"%%ID_EVENT_SUB_DELETE%%", _variant_t(long(AuditEventsLib::AUDITEVENT_SUB_DELETE))) ;
    rowset->AddParam(L"%%ID_EVENT_GSUBMEMBER_DELETE%%", _variant_t(long(AuditEventsLib::AUDITEVENT_GSUB_MEMBER_DELETE))) ;
    rowset->Execute();
    rowset->Clear();
    rowset->SetQueryTag(L"__UNSUBSCRIBE_BATCH__");
    rowset->Execute();
    rowset->Clear();
    rowset->SetQueryTag(L"__UNSUBSCRIBE_INDIVIDUAL_BATCH__");
    rowset->Execute();

    rowset->Clear();
    rowset->SetQueryTag(L"__DROP_SUBSCRIBE_TO_GROUP_BATCH_TABLE__");
    rowset->Execute();

    rowset->Clear();
    rowset->SetQueryTag(L"__DROP_UNSUBSCRIBE_BATCH_TABLE__");
    rowset->Execute();

    rowset->Clear();
    rowset->SetQueryTag(L"__DROP_UNSUBSCRIBE_INDIVIDUAL_BATCH_TABLE__");
    rowset->Execute();
  }
  catch(_com_error & err)
  {
    return ReturnComError(err);
  }

  return S_OK;
}


STDMETHODIMP CMTSubscriptionCatalogWriter::UnsubscribeFromConflictingToIndividual(IMTSessionContext*    apCtx,
                                                                                  IMTCollection*        pCol,  // Collection of MTSubInfo
                                                                                  IMTProgress*          pProgress,
                                                                                  IMTSQLRowset*         pErrorRs)
{
  bool anyErrors = false;
  try
  {
    _bstr_t sTableCreationDebugParam = "";
    _bstr_t sTableDebugParam = "";
    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init("Queries\\ProductCatalog");
    
    wstring wstrDBType = rowset->GetDBType() ;
    BOOL isOracle = (wcscmp(wstrDBType.c_str(), ORACLE_DATABASE_TYPE) == 0);
    
    if(!isOracle)
    {
      sTableCreationDebugParam = "tempdb..#";
      sTableDebugParam = "#";
    }
    
    MTPRODUCTCATALOGEXECLib::IMTCollectionPtr col(pCol);
    MTPRODUCTCATALOGEXECLib::IMTProgressPtr progress(pProgress);
		MTSubscriptionExecLib::IMTSessionContextPtr pContext(apCtx);

    // Create a temporary table and do a "batch" insert of args into the table.
    //
    rowset->Clear();
    rowset->SetQueryTag("__CREATE_SUBSCRIBE_INDIVIDUAL_BATCH_TABLE__");
    rowset->AddParamIfFound(L"%%TEMPDEBUG%%", sTableCreationDebugParam);
    rowset->AddParamIfFound(L"%%DEBUG%%", sTableDebugParam);

    rowset->Execute();
    
    // Create temporary tables that drive unsubscription
    rowset->Clear();
		rowset->SetQueryTag("__CREATE_UNSUBSCRIBE_BATCH_TABLE__");
    rowset->Execute();
    rowset->Clear();
		rowset->SetQueryTag("__CREATE_UNSUBSCRIBE_INDIVIDUAL_BATCH_TABLE__");
    rowset->Execute();

    _bstr_t query;

		_variant_t vtNULL;
		vtNULL.vt = VT_NULL;

    DATE min_time = getMinMTOLETime();
    DATE now = GetMTOLETime();

    _bstr_t bstr_Y = L"'Y'";
    _bstr_t bstr_N = L"'N'";

    long lAccountId = pContext->AccountID;

    long j = 0;
    long size = col->GetCount();

		MetraTech_DataAccess::IIdGenerator2Ptr idSubGenerator(__uuidof(MetraTech_DataAccess::IdGenerator));
		idSubGenerator->Initialize("id_subscription", size);

		MetraTech_DataAccess::IIdGenerator2Ptr idAuditGenerator(__uuidof(MetraTech_DataAccess::IdGenerator));
		idAuditGenerator->Initialize("id_audit", size);

    if (isOracle)
      query = "begin\n";
    
    for(long i = 1; i <= size; i++) 
    {
      MTPRODUCTCATALOGLib::IMTSubInfoPtr memberPtr =  col->GetItem(i);

      if(!(memberPtr->IsGroupSub))
      {
        QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
        pQueryAdapter->Init("Queries\\ProductCatalog");
        pQueryAdapter->SetQueryTag(L"__INSERT_SUBSCRIBE_INDIVIDUAL_BATCH_ARGS__");
        pQueryAdapter->AddParamIfFound(L"%%DEBUG%%", sTableDebugParam) ;
        pQueryAdapter->AddParam(L"%%ID_ACC%%", _variant_t(memberPtr->AccountID)) ;
        pQueryAdapter->AddParam(L"%%ID_SUB%%", _variant_t(idSubGenerator->NextMashedId)) ;
        pQueryAdapter->AddParam(L"%%ID_PO%%", _variant_t(memberPtr->ProdOfferingID)) ;
        pQueryAdapter->AddParam(L"%%DT_START%%", _variant_t(memberPtr->SubsStartDate, VT_DATE)) ;

        if (memberPtr->SubsEndDate == min_time)
          pQueryAdapter->AddParam(L"%%DT_END%%", vtNULL) ;
        else
          pQueryAdapter->AddParam(L"%%DT_END%%", _variant_t(memberPtr->SubsEndDate, VT_DATE)) ;

        if (memberPtr->SubsStartDateType == PCDATE_TYPE_NEXT_BILLING_PERIOD)
          pQueryAdapter->AddParam(L"%%NCA_STARTDATE%%", _variant_t(bstr_Y), VARIANT_TRUE) ;
        else
          pQueryAdapter->AddParam(L"%%NCA_STARTDATE%%", _variant_t(bstr_N), VARIANT_TRUE) ;

        if (memberPtr->SubsEndDateType == PCDATE_TYPE_NEXT_BILLING_PERIOD)
          pQueryAdapter->AddParam(L"%%NCA_ENDDATE%%", _variant_t(bstr_Y), VARIANT_TRUE) ;
        else
          pQueryAdapter->AddParam(L"%%NCA_ENDDATE%%", _variant_t(bstr_N), VARIANT_TRUE) ;

        pQueryAdapter->AddParam(L"%%SUB_GUID%%", vtNULL); // Let the database set this.
        pQueryAdapter->AddParam(L"%%ID_AUDIT%%", _variant_t(idAuditGenerator->NextId)) ;
        pQueryAdapter->AddParam(L"%%ID_EVENT%%", _variant_t(long(AuditEventsLib::AUDITEVENT_SUB_CREATE))) ;
        pQueryAdapter->AddParam(L"%%ID_USERID%%", _variant_t(lAccountId)) ;
        pQueryAdapter->AddParam(L"%%ID_ENTITYTYPE%%", _variant_t(long(AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT))) ;
        query += pQueryAdapter->GetQuery();
        j++;
      }

      // Do our inserts in groups of 100 (seems to amortize the insert cost pretty well).
      if((j%100) == 0)
      {
        rowset->Clear();
        rowset->SetQueryString(query);
        rowset->Execute();
        query = L"";
        j = 0;
        if(progress != NULL)
        {
          progress->SetProgress(i, size);
        }
      }
    }

    // Insert any stragglers
    if(query.length() > 0)
    {
      rowset->Clear();
      if (isOracle)
        query += "\nend;\n";
      rowset->SetQueryString(query);
      rowset->Execute();
      query = L"";
      if(progress != NULL)
      {
        progress->SetProgress(size, size);
      }
    }

    // Now execute code to identify confliciting subscriptions.
    // then execute code to unsubscribe both group and individual subscriptions that conflict.
    rowset->Clear();
    rowset->SetQueryTag(L"__IDENTIFY_CONFLICTING_SUBSCRIPTIONS_INDIVIDUAL__");
    rowset->AddParam(L"%%DEBUG%%", sTableDebugParam);
    rowset->AddParam(L"%%TT_NOW%%", _variant_t(now, VT_DATE)) ;
    rowset->AddParam(L"%%ID_EVENT_SUB_DELETE%%", _variant_t(long(AuditEventsLib::AUDITEVENT_SUB_DELETE))) ;
    rowset->AddParam(L"%%ID_EVENT_GSUBMEMBER_DELETE%%", _variant_t(long(AuditEventsLib::AUDITEVENT_GSUB_MEMBER_DELETE))) ;
    rowset->Execute();
    rowset->Clear();
    rowset->SetQueryTag(L"__UNSUBSCRIBE_BATCH__");
    rowset->Execute();
    rowset->Clear();
    rowset->SetQueryTag(L"__UNSUBSCRIBE_INDIVIDUAL_BATCH__");
    rowset->Execute();

    // There can be no errors during unsubscribe
    rowset->Clear();
    rowset->SetQueryTag(L"__DROP_SUBSCRIBE_INDIVIDUAL_BATCH_TABLE__");
    rowset->Execute();

    rowset->Clear();
    rowset->SetQueryTag(L"__DROP_UNSUBSCRIBE_BATCH_TABLE__");
    rowset->Execute();

    rowset->Clear();
    rowset->SetQueryTag(L"__DROP_UNSUBSCRIBE_INDIVIDUAL_BATCH_TABLE__");
    rowset->Execute();
  }
  catch(_com_error & err)
  {
    return ReturnComError(err);
  }

  return S_OK;
}


