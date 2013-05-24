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
#include "MTYAACExec.h"
#include "MTPaymentWriter.h"
#include "PCCache.h"
#include <mtglobal_msg.h>
#include <ATLComTime.h>
#import <QueryAdapter.tlb> rename( "GetUserName", "QAGetUserName" )

/////////////////////////////////////////////////////////////////////////////

class MTBatchPaymentHelper : public MTAccountBatchHelper<MTYAACEXECLib::IMTPaymentWriterPtr>
{
public:
  HRESULT PerformSingleOp(long aIndex,long &aFailedAccount);
  long mPayer;
  DATE mStartDate;
  DATE mEndDate;
};

HRESULT MTBatchPaymentHelper::PerformSingleOp(long aIndex,long &aFailedAccount)
{
  _variant_t vtAcc = mColPtr->GetItem(aIndex);
  if(!(vtAcc.vt == VT_I4 || vtAcc.vt == VT_I2 || vtAcc.vt == VT_DECIMAL)) {
    MT_THROW_COM_ERROR("Variant is not the correct type");
  }
  long payee = vtAcc;
  aFailedAccount = payee;
  return mControllerClass->PayForAccount(
    (MTYAACEXECLib::IMTSessionContext*)(IMTSessionContext*)(mSessionContext),
    mPayer,payee,mStartDate,mEndDate);
}


/////////////////////////////////////////////////////////////////////////////
// CMTPaymentWriter

STDMETHODIMP CMTPaymentWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTPaymentWriter
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (::InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}


HRESULT CMTPaymentWriter::Activate()
{
  HRESULT hr = GetObjectContext(&m_spObjectContext);
  if (SUCCEEDED(hr))
    return S_OK;
  return hr;
} 

BOOL CMTPaymentWriter::CanBePooled()
{
  return TRUE;
} 

void CMTPaymentWriter::Deactivate()
{
  m_spObjectContext.Release();
} 

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTPaymentWriter::PayForAccount(IMTSessionContext* apCtxt, long aPayer, long aPayee, DATE aStartDate, DATE aEndDate)
{
  MTAutoContext ctx(m_spObjectContext);
  long status = 0;
  try {

    //For audit purposes, first get the current payer before you change it.
    QUERYADAPTERLib::IMTQueryAdapterPtr queryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		queryAdapter->Init(ACC_HIERARCHIES_QUERIES);
    queryAdapter->SetQueryTag("__GET_PAYMENT_HISTORY_ACC_HIERARCHIES__");
		queryAdapter->AddParam("%%ID_ACC%%", aPayee);
		MTYAACEXECLib::IMTGenDBReaderPtr reader(__uuidof(MTYAACEXECLib::MTGenDBReader));
    ROWSETLib::IMTRowSetPtr pRS = reader->ExecuteStatement(queryAdapter->GetQuery());
    pRS->MoveLast();
    long oldPayer = pRS->GetValue(L"id_payer");


		string sSameCorpEnforced = 
			(PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE) ? "1" : "0";

    ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
    rs->Init(DATABASE_CONFIGDIR);
    rs->InitializeForStoredProc("CreatePaymentRecord");
    rs->AddInputParameterToStoredProc("Payer",MTTYPE_INTEGER, INPUT_PARAM, aPayer);
    rs->AddInputParameterToStoredProc("NPA", MTTYPE_INTEGER, INPUT_PARAM, aPayee);

    rs->AddInputParameterToStoredProc("startdate", MTTYPE_DATE, INPUT_PARAM,aStartDate);
    rs->AddInputParameterToStoredProc("enddate", MTTYPE_DATE, INPUT_PARAM,aEndDate);

    _variant_t vtEmpty;
    vtEmpty.vt = VT_NULL;

    rs->AddInputParameterToStoredProc("payerbillable", MTTYPE_VARCHAR, INPUT_PARAM,vtEmpty);
    rs->AddInputParameterToStoredProc("p_systemdate", MTTYPE_DATE, INPUT_PARAM,GetMTOLETime());
    rs->AddInputParameterToStoredProc("p_fromupdate", MTTYPE_VARCHAR, INPUT_PARAM,"N");
		rs->AddInputParameterToStoredProc (	"p_enforce_same_corporation", MTTYPE_VARCHAR, INPUT_PARAM, sSameCorpEnforced.c_str());
		//dirty and ugly.... Since this stored proc call is not coming from account create/update session,
		//there is no info on account currency. Pass it as empty string and resolve in CreatePaymentRecord stored proc
		rs->AddInputParameterToStoredProc (	"p_account_currency", MTTYPE_VARCHAR, INPUT_PARAM, _bstr_t(""));
    rs->AddOutputParameterToStoredProc("status", MTTYPE_DECIMAL, OUTPUT_PARAM);
    rs->ExecuteStoredProc();
    status = rs->GetParameterFromStoredProc("status");

    if(status == 0) {
      MT_THROW_COM_ERROR(MT_UNKNOWN_PAYMENT_ERROR);
    }

    if(status != 1) {
        if (status == MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE) 
        {
         MT_THROW_COM_ERROR("Cannot update payment record, the payee is subscribed to a Billing Cycle Relative constrained product offering whose cycle type conflicts with the payer's cycle type.");           
        }
        else
      MT_THROW_COM_ERROR(status);
    }

    // audit
    char buffer[512];
    sprintf(buffer, "payer set to %d for payee %d, was %d", aPayer, aPayee, oldPayer);
    MTYAACEXECLib::IMTSessionContextPtr sessionCtxt(apCtxt);
    PCCache::GetAuditor()->FireEvent( AuditEventsLib::AUDITEVENT_ACCOUNT_UPDATE,
                                      sessionCtxt->AccountID,
                                      AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
                                      aPayee,
                                      buffer);
  }
  catch(_com_error& err) {
    return ReturnComError(err);
  }

  ctx.Complete();
  return S_OK;
}



// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------


STDMETHODIMP CMTPaymentWriter::PayForAccountBatch(IMTSessionContext* apCtxt, 
      IMTCollection* pCol,
      IMTProgress* pProgress,
      long aPayer,
      DATE StartDate,
      VARIANT aEndDate,
      IMTRowSet** ppRowset)
{
  try {
    _variant_t vtEndDate;

    if(!OptionalVariantConversion(aEndDate,VT_DATE,vtEndDate)) {
      vtEndDate = GetMaxMTOLETime();
    }
    MTBatchPaymentHelper aBatchHelper;
    aBatchHelper.Init(m_spObjectContext,MTYAACEXECLib::IMTPaymentWriterPtr(this), apCtxt);
    aBatchHelper.mPayer = aPayer;
    aBatchHelper.mStartDate = StartDate;
    aBatchHelper.mEndDate = vtEndDate;
    *ppRowset = reinterpret_cast<IMTRowSet*>(aBatchHelper.PerformBatchOperation(pCol,pProgress).Detach());

  }
  catch(_com_error& err) {
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

STDMETHODIMP CMTPaymentWriter::UpdatePaymentRecord(IMTSessionContext* apCtxt,
                                                   long aPayer, long aPayee, DATE oldStart,
                                                   DATE oldEnd, DATE aStartDate, DATE aEndDate)
{
  MTAutoContext ctx(m_spObjectContext);
  long status = 0;
  try {
    // normalize dates
    if(oldEnd == 0) {
      oldEnd = GetMaxMTOLETime();
    }
    if(aEndDate == 0) {
      aEndDate = GetMaxMTOLETime();
    }
		string sSameCorpEnforced = 
			(PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE) ? "1" : "0";

    ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
    rs->Init(DATABASE_CONFIGDIR);
    rs->InitializeForStoredProc("UpdatePaymentRecord");
    rs->AddInputParameterToStoredProc("p_payer",MTTYPE_INTEGER, INPUT_PARAM, aPayer);
    rs->AddInputParameterToStoredProc("p_payee", MTTYPE_INTEGER, INPUT_PARAM, aPayee);
    rs->AddInputParameterToStoredProc("p_oldstartdate", MTTYPE_DATE, INPUT_PARAM,oldStart);
    rs->AddInputParameterToStoredProc("p_oldenddate", MTTYPE_DATE, INPUT_PARAM,oldEnd);
    rs->AddInputParameterToStoredProc("p_startdate", MTTYPE_DATE, INPUT_PARAM,aStartDate);
    rs->AddInputParameterToStoredProc("p_enddate", MTTYPE_DATE, INPUT_PARAM,aEndDate);
    rs->AddInputParameterToStoredProc("p_systemdate", MTTYPE_DATE, INPUT_PARAM,GetMTOLETime());
		rs->AddInputParameterToStoredProc ("p_enforce_same_corporation", MTTYPE_VARCHAR, INPUT_PARAM, sSameCorpEnforced.c_str());
		//dirty and ugly.... Since this stored proc call is not coming from account update session,
		//there is way to get payee currency info. Pass it as empty string and resolve in CreatePaymentRecord
		//stored procedure
		rs->AddInputParameterToStoredProc (	"p_account_currency", MTTYPE_VARCHAR, INPUT_PARAM, _bstr_t(""));
    
    rs->AddOutputParameterToStoredProc("p_status",MTTYPE_INTEGER,OUTPUT_PARAM);
    rs->ExecuteStoredProc();
    status = rs->GetParameterFromStoredProc("p_status");
    if(status != 1) {
      MT_THROW_COM_ERROR(status);
    }

    // audit
    MTYAACEXECLib::IMTSessionContextPtr sessionCtxt(apCtxt);
    CString buffer;
    
    CString oldStartStr = COleDateTime(oldStart).Format(VAR_DATEVALUEONLY);
    CString newStartStr = COleDateTime(aStartDate).Format(VAR_DATEVALUEONLY); 
    CString oldEndStr = COleDateTime(oldEnd).Format(VAR_DATEVALUEONLY);
    CString newEndStr = COleDateTime(aEndDate).Format(VAR_DATEVALUEONLY);    

    buffer.Format(_T("payer %d date change for payee %d.  Was from %s to %s.  Now from %s to %s."),aPayer, aPayee, oldStartStr, oldEndStr, newStartStr, newEndStr);

    PCCache::GetAuditor()->FireEvent( AuditEventsLib::AUDITEVENT_ACCOUNT_UPDATE,
                                      sessionCtxt->AccountID,
                                      AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
                                      aPayee,
                                      (LPCTSTR)buffer);

  }
  catch(_com_error& err) {
    return ReturnComError(err);
  }

  ctx.Complete();
  return S_OK;
}


