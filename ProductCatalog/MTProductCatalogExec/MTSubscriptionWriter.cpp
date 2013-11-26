/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header: c:\mainline\development\ProductCatalog\MTProductCatalogExec\MTSubscriptionWriter.cpp, 46, 11/13/2002 6:09:28 PM, Fabricio Pettena$
* 
***************************************************************************/

#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTSubscriptionWriter.h"
#include <mtcom.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <metra.h>
#include <mtautocontext.h>
#include <mtprogids.h>
#include <MTTypeConvert.h>
#include <formatdbvalue.h>
#include <RowsetDefs.h>
#include <DataAccessDefs.h>
#include <mtglobal_msg.h>
#include <MTUtil.h>
#include <MTDate.h>
#include "accountbatchhelper.h"
#include <mttime.h>
#include <ATLComTime.h>

#pragma warning(disable: 4297)  // disable warning "function assumed not to throw an exception but does"

#import <QueryAdapter.tlb> rename("UserName", "QueryAdapterUserName") rename("GetUserName", "QAGetUserName")
#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.DataAccess.tlb> inject_statement("using namespace mscorlib;")

#import <MTAccountStates.tlb> rename("EOF", "RowsetEOF")

#include <string>
using namespace std;

#include <NTThreadLock.h>
#include <autocritical.h>

class SubscriptionIdGenerator
{
private:
  static NTThreadLock mThreadLock;
  static MetraTech_DataAccess::IIdGenerator2Ptr mIdGenerator;
  static MetraTech_DataAccess::IIdGenerator2Ptr mAuditIdGenerator;
public:
  static MetraTech_DataAccess::IIdGenerator2Ptr Get();
  static MetraTech_DataAccess::IIdGenerator2Ptr GetAuditIdGenerator();
};

NTThreadLock SubscriptionIdGenerator::mThreadLock;
MetraTech_DataAccess::IIdGenerator2Ptr SubscriptionIdGenerator::mIdGenerator;
MetraTech_DataAccess::IIdGenerator2Ptr SubscriptionIdGenerator::mAuditIdGenerator;

MetraTech_DataAccess::IIdGenerator2Ptr SubscriptionIdGenerator::Get()
{
  AutoCriticalSection acs(&mThreadLock);

  if (mIdGenerator.GetInterfacePtr() == NULL)
  {
		MetraTech_DataAccess::IIdGenerator2Ptr idGen(__uuidof(MetraTech_DataAccess::IdGenerator));
    idGen->Initialize("id_subscription", 100);
    mIdGenerator = idGen;
  }

  return mIdGenerator;
}

MetraTech_DataAccess::IIdGenerator2Ptr SubscriptionIdGenerator::GetAuditIdGenerator()
{
  AutoCriticalSection acs(&mThreadLock);

  if (mAuditIdGenerator.GetInterfacePtr() == NULL)
  {
		MetraTech_DataAccess::IIdGenerator2Ptr idGen(__uuidof(MetraTech_DataAccess::IdGenerator));
    idGen->Initialize("id_audit", 100);
    mAuditIdGenerator = idGen;
  }

  return mAuditIdGenerator;
}

///////////////////////////////////////////////////////////////////////
// Status response codes from the AddNewSub stored procedure

const int CONFLICTING_SUBSCRIPTION = 1;
const int CONFLICTING_PRICEABLEITEM = 2;
const int SUBSCRIPTION_START_DATE_BEFORE_ACCOUNT_START_DATE = 3;

  // Set ProdOff Allow Account PO Currency Mismatch business rule, 
//bool bAllowAccountPOCurrencyMismatch = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch) == VARIANT_TRUE;

  // Set ProdOff Allow Multiple PI SubscriptionRCNRC business rule, ProdOff_AllowMultiplePISubscriptionRCNRC
//bool bAllowMultiplePISubscriptionRCNRC = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowMultiplePISubscriptionRCNRC) == VARIANT_TRUE;

///////////////////////////////////////////////////////////////////////
// helper classes for batch operation

class MTGroupSubBatchBase : public MTAccountBatchHelper<MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr>
{
public:
  MTGroupSubBatchBase() : bDateModified(VARIANT_FALSE) {}
  virtual HRESULT PerformSingleOp(long aIndex,long &aFailedAccount) = 0;
  MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr mCTX;
  MTPRODUCTCATALOGEXECLib::IMTGroupSubscriptionPtr mGroupSub;

  VARIANT_BOOL bDateModified;

};

class AddAccountToGroupSubBatchHelper : public MTGroupSubBatchBase
{
public:
  HRESULT PerformSingleOp(long aIndex,long &aFailedAccount)
  {
    MTPRODUCTCATALOGEXECLib::IMTGSubMemberPtr memberPtr =  mColPtr->GetItem(aIndex);
    aFailedAccount = memberPtr->GetAccountID();
    memberPtr->Validate();
    VARIANT_BOOL vbVal =  mControllerClass->AddAccountToGroupSub(
      mCTX,
      mGroupSub,
			memberPtr.GetInterfacePtr());
    if(vbVal == VARIANT_TRUE) {
      bDateModified = vbVal;
    }
    return S_OK;
  }

};

class ModifyMembershipBatchHelper : public MTGroupSubBatchBase
{
public:
  HRESULT PerformSingleOp(long aIndex,long &aFailedAccount)
  {
    MTPRODUCTCATALOGEXECLib::IMTGSubMemberPtr memberPtr =  mColPtr->GetItem(aIndex);
    aFailedAccount = memberPtr->GetAccountID();
    memberPtr->Validate();
    VARIANT_BOOL vbVal = mControllerClass->ModifyMembership(mCTX,mGroupSub,
				memberPtr);
    if(vbVal == VARIANT_TRUE) {
      bDateModified = vbVal;
    }
    return S_OK;
  }
};

class DeleteMemberBatchHelper : public MTGroupSubBatchBase
{
public:
  HRESULT PerformSingleOp(long aIndex,long &aFailedAccount)
  {
		_variant_t vtVal = mColPtr->GetItem(aIndex);
		long accountID;
		switch(vtVal.vt) 
    {
			case VT_DISPATCH:
			{
		 		accountID = MTPRODUCTCATALOGEXECLib::IMTGSubMemberPtr(vtVal)->GetAccountID();
				break;
			}
			case VT_I4:
			case VT_DECIMAL:
			case VT_I2:
				accountID = vtVal;
			default:
				MT_THROW_COM_ERROR("DeleteMemberBatch: Unknown type in collection");
		}

    aFailedAccount = accountID;
    return mControllerClass->DeleteMember(mCTX, mGroupSub, accountID);
  }
};


///////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////////
// CMTSubscriptionWriter

/******************************************* error interface ***/
STDMETHODIMP CMTSubscriptionWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSubscriptionWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTSubscriptionWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTSubscriptionWriter::CanBePooled()
{
	return TRUE;
} 

void CMTSubscriptionWriter::Deactivate()
{
	m_spObjectContext.Release();
} 

// ----------------------------------------------------------------
// Name:  AddICBPriceListMapping   	
// Arguments:     priceable item instance ID,paramtable ID, and pricelist
//                
// Return Value:  S_OK,E_FAIL
// Errors Raised: 
// Description:   Adds an ICB Pricelist mapping for the priceable instance ID
// ----------------------------------------------------------------


STDMETHODIMP CMTSubscriptionWriter::AddICBPriceListMapping(IMTSessionContext* apCtxt, 
																													 long aPrcItemID, 
																													 long aParamTblID,
																													 IMTSubscriptionBase *pSub)
{
	ASSERT(pSub);
	if(!pSub) return E_POINTER;
	MTAutoContext context(m_spObjectContext);
	MTPRODUCTCATALOGLib::IMTSubscriptionBasePtr aSubPtr(pSub);

	try {

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->InitializeForStoredProc("AddICBMapping");
		rowset->AddInputParameterToStoredProc (	"id_paramtable", MTTYPE_INTEGER, INPUT_PARAM, aParamTblID);
		rowset->AddInputParameterToStoredProc (	"id_pi_instance", MTTYPE_INTEGER, INPUT_PARAM, aPrcItemID);
		rowset->AddInputParameterToStoredProc (	"id_sub", MTTYPE_INTEGER, INPUT_PARAM,aSubPtr->GetID());

		//lets play a fun games of downcasting.
		MTPRODUCTCATALOGLib::IMTSubscriptionPtr pSingleSub = pSub;
		MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr pGroupSub = pSub;

		long RefAccountID;
		if(pSingleSub) {
			RefAccountID = pSingleSub->GetAccountID();
		}
		else if(pGroupSub) {
			RefAccountID = pGroupSub->GetCorporateAccount();
		}
		else {
			PCCache::GetLogger().LogThis(LOG_ERROR,"Unknown subscription type; I have no mouth and I can not scream!");
			MT_THROW_COM_ERROR("Unknown subscription type");
		}

		rowset->AddInputParameterToStoredProc (	"id_acc", MTTYPE_INTEGER, INPUT_PARAM,RefAccountID);
		rowset->AddInputParameterToStoredProc (	"id_po", MTTYPE_INTEGER, INPUT_PARAM, aSubPtr->ProductOfferingID);
		rowset->AddInputParameterToStoredProc (	"p_systemdate", MTTYPE_DATE, INPUT_PARAM,GetMTOLETime());
		rowset->ExecuteStoredProc();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:   RemoveICBMapping  	
// Arguments:  priceable instance ID, parametertable ID, subscription interface pointer   
//                
// Return Value:  S_OK,E_FAIL
// Errors Raised: 
// Description:   Removes an existing ICB mapping by parameter table ID
// and priceable item instance ID
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionWriter::RemoveICBMapping(IMTSessionContext* apCtxt,
																										 long aPI_ID, 
																										 long aPtdID, 
																										 IMTSubscriptionBase *pSub)
{
	ASSERT(pSub);
	if(!pSub) return E_POINTER;
	MTAutoContext context(m_spObjectContext);
	MTPRODUCTCATALOGLib::IMTSubscriptionBasePtr aSubPtr(pSub);

	try {
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->SetQueryTag("_REMOVE_ICB_MAPPING__");
		rowset->AddParam("%%ID_SUB%%",aSubPtr->GetID());
		rowset->AddParam("%%ID_PI_INSTANCE%%",aPI_ID);
		rowset->AddParam("%%ID_PARAMTABLE%%",aPtdID);
		rowset->Execute();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}


// ----------------------------------------------------------------
// Name:   SaveNew  	
// Arguments:  IMTSubscription  
//                
// Return Value:  S_OK,E_FAIL
// Errors Raised: 
// Description:   Saves a new subscription
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionWriter::SaveNew(IMTSessionContext* apCtxt,
																						IMTSubscription *pSub,
																						VARIANT_BOOL* pDateModified)
{
	ASSERT(pSub);
	if(!pSub) return E_POINTER;
	MTAutoContext context(m_spObjectContext);

	MTPRODUCTCATALOGLib::IMTSubscriptionPtr aSubPtr(pSub);

	try {

		// check whether the account can subscribe.  Note: this method
		// creates a YAAC and may be a performance bottleneck if we have a large
		// number of accounts
		CheckAccountState(apCtxt,aSubPtr->GetAccountID(),aSubPtr->GetEffectiveDate()->GetStartDate());



		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->InitializeForStoredProc("AddNewSub");

		rowset->AddInputParameterToStoredProc (	"p_id_acc", MTTYPE_INTEGER, INPUT_PARAM, aSubPtr->GetAccountID());
		rowset->AddInputParameterToStoredProc (	"p_dt_start", MTTYPE_DATE, INPUT_PARAM, 
			aSubPtr->GetEffectiveDate()->GetStartDate());
		if(aSubPtr->GetEffectiveDate()->IsEndDateNull() == VARIANT_TRUE)	 {
			_variant_t empty;
			empty.vt = VT_NULL;
			rowset->AddInputParameterToStoredProc (	"p_dt_end", MTTYPE_DATE, INPUT_PARAM, empty);
		}
		else {
			rowset->AddInputParameterToStoredProc (	"p_dt_end", MTTYPE_DATE, INPUT_PARAM, aSubPtr->GetEffectiveDate()->GetEndDate());
		}
		rowset->AddInputParameterToStoredProc (	"p_NextCycleAfterStartDate",MTTYPE_VARCHAR,INPUT_PARAM,
			aSubPtr->GetEffectiveDate()->GetStartDateType() == PCDATE_TYPE_NEXT_BILLING_PERIOD ? "Y" : "N");
		rowset->AddInputParameterToStoredProc (	"p_NextCycleAfterEndDate",MTTYPE_VARCHAR,INPUT_PARAM,
			aSubPtr->GetEffectiveDate()->GetEndDateType() == PCDATE_TYPE_NEXT_BILLING_PERIOD ? "Y" : "N");
		// product offering ID
		rowset->AddInputParameterToStoredProc (	"p_id_po", MTTYPE_INTEGER, INPUT_PARAM,aSubPtr->GetProductOfferingID());

    _variant_t subGUID;
		if(!MTMiscUtil::CreateGuidAsVariant(subGUID)) {
			return Error("Failed to create GUID values for new subscription");
		}

    rowset->AddInputParameterToStoredProc (	"p_GUID", MTTYPE_VARBINARY, INPUT_PARAM, subGUID);
    rowset->AddInputParameterToStoredProc (	"p_systemdate", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime());

    MetraTech_DataAccess::IIdGenerator2Ptr idGenerator = SubscriptionIdGenerator::Get();
	long nextSubID = idGenerator->NextMashedId;

	bool bAllowAccountPOCurrencyMismatch = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch) == VARIANT_TRUE;
	bool bAllowMultiplePISubscriptionRCNRC = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowMultiplePISubscriptionRCNRC) == VARIANT_TRUE;

		rowset->AddInputParameterToStoredProc("p_id_sub", MTTYPE_INTEGER, INPUT_PARAM, nextSubID);

		// output parameters
		rowset->AddOutputParameterToStoredProc("p_status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->AddOutputParameterToStoredProc("p_datemodified", MTTYPE_VARCHAR, OUTPUT_PARAM);
		rowset->AddInputParameterToStoredProc (	"p_allow_acc_po_curr_mismatch", MTTYPE_INTEGER, INPUT_PARAM, _variant_t((long)bAllowAccountPOCurrencyMismatch));
	    rowset->AddInputParameterToStoredProc (	"p_allow_multiple_pi_sub_rcnrc", MTTYPE_INTEGER, INPUT_PARAM, _variant_t((long)bAllowMultiplePISubscriptionRCNRC));

		rowset->ExecuteStoredProc();

		// check the status of the stored procedure
		long status = rowset->GetParameterFromStoredProc("p_status");
		if(status != 1) {
      // this method throws an error
      ResolveGenericSubError(status,aSubPtr);
		}
		else {
			// get the result back and stuff it in the subscription object
			aSubPtr->PutID(nextSubID);
		}

		_bstr_t bstrDateModified = rowset->GetParameterFromStoredProc("p_datemodified");
		(*pDateModified) = (wcsicmp((wchar_t*)bstrDateModified, L"Y") == 0) ? VARIANT_TRUE : VARIANT_FALSE;

		MTPRODUCTCATALOGLib::IMTSessionContextPtr pContext(apCtxt);

		// Now write out the UDRC unit values configured prior to saving
		ROWSETLib::IMTRowSetPtr unitValues = aSubPtr->GetRecurringChargeUnitValuesFromMemoryAsRowset();

		MTPRODUCTCATALOGEXECLib::IMTSubscriptionBasePtr base = dynamic_cast<IMTSubscriptionBase*>(pSub);
		
    MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr subWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
		for(int i=0; i<unitValues->GetRecordCount(); i++)
		{
			// Set the unit value
			subWriter->SetUnitValue(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
															base, 
															(long)unitValues->GetValue(L"id_prop"), 
															(DECIMAL)unitValues->GetValue(L"n_value"), 
															(DATE)unitValues->GetValue(L"vt_start"), 
															(DATE)unitValues->GetValue(L"vt_end"));			
			unitValues->MoveNext();
		}
		if((unitValues->GetRecordCount()) > 0)
		{
    subWriter->FinalizeUnitValue(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), base); 
	}
    PCCache::GetAuditor()->FireEventWithAdditionalData(AuditEventsLib::AUDITEVENT_SUB_CREATE,
                                                          pContext->AccountID,
                                                          1,
                                                          aSubPtr->GetAccountID(),
                                                          aSubPtr->GetProductOffering()->GetName(),
                                                          pContext->LoggedInAs,
                                                          pContext->ApplicationName);

	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:    UpdateExisting 	
// Arguments:  IMTSubscription*   
//                
// Return Value:  
// Errors Raised: 
// Description:   Updates an existing subscription
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionWriter::UpdateExisting(IMTSessionContext* apCtxt,
                                                   IMTSubscription *pSub,
                                                   VARIANT_BOOL* pDateModified)
{
	ASSERT(pSub);
	if(!pSub) return E_POINTER;
	MTAutoContext context(m_spObjectContext);


  try {
    MTPRODUCTCATALOGLib::IMTSubscriptionPtr aSubPtr(pSub);
    MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr effDatePtr(aSubPtr->GetEffectiveDate());
    bool bAllowAccountPOCurrencyMismatch2 = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch) == VARIANT_TRUE;
    bool bAllowMultiplePISubscriptionRCNRC2 = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowMultiplePISubscriptionRCNRC) == VARIANT_TRUE;

    ROWSETLib::IMTSQLRowsetPtr oldDataRowset(MTPROGID_SQLROWSET);
    oldDataRowset->Init(CONFIG_DIR);

    //First get old dates for audit purposes
    oldDataRowset->SetQueryTag("__GET_SUBSCRIPTION_START_END_DATES__");
		oldDataRowset->AddParam(L"%%ID_SUB%%", aSubPtr->GetID());
		oldDataRowset->Execute();
    _variant_t oldStartDate = oldDataRowset->GetValue("vt_start");
    _variant_t oldEndDate = oldDataRowset->GetValue("vt_end");

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
 
    rowset->InitializeForStoredProc("UpdateSub");

    rowset->AddInputParameterToStoredProc (	"p_id_sub", MTTYPE_INTEGER, INPUT_PARAM, aSubPtr->GetID());

    rowset->AddInputParameterToStoredProc (	"p_dt_start", MTTYPE_DATE, INPUT_PARAM, 
      effDatePtr->GetStartDate());

		if(effDatePtr->IsEndDateNull() == VARIANT_TRUE) {
			_variant_t vtNull;
			vtNull.vt = VT_NULL;
			rowset->AddInputParameterToStoredProc (	"p_dt_end", MTTYPE_DATE, INPUT_PARAM,vtNull);
		}
		else {
		rowset->AddInputParameterToStoredProc (	"p_dt_end", MTTYPE_DATE, INPUT_PARAM, 
			aSubPtr->GetEffectiveDate()->GetEndDate());
		}

		rowset->AddInputParameterToStoredProc (	"p_nextcycleafterstartdate", MTTYPE_VARCHAR,INPUT_PARAM,
			aSubPtr->GetEffectiveDate()->GetStartDateType() == PCDATE_TYPE_NEXT_BILLING_PERIOD ? "Y" : "N");
		rowset->AddInputParameterToStoredProc (	"p_nextcycleafterenddate", MTTYPE_VARCHAR,INPUT_PARAM,
			aSubPtr->GetEffectiveDate()->GetEndDateType() == PCDATE_TYPE_NEXT_BILLING_PERIOD ? "Y" : "N");
		rowset->AddInputParameterToStoredProc (	"p_id_po", MTTYPE_INTEGER, INPUT_PARAM,
			aSubPtr->GetProductOffering()->GetID());
    rowset->AddInputParameterToStoredProc (	"p_id_acc", MTTYPE_INTEGER, INPUT_PARAM,
			aSubPtr->GetAccountID());
    rowset->AddInputParameterToStoredProc (	"p_systemdate", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime());
		rowset->AddOutputParameterToStoredProc ("p_status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->AddOutputParameterToStoredProc ("p_datemodified", MTTYPE_VARCHAR, OUTPUT_PARAM);
		rowset->AddInputParameterToStoredProc (	"p_allow_acc_po_curr_mismatch", MTTYPE_INTEGER, INPUT_PARAM, _variant_t((long)bAllowAccountPOCurrencyMismatch2));
	    rowset->AddInputParameterToStoredProc (	"p_allow_multiple_pi_sub_rcnrc", MTTYPE_INTEGER, INPUT_PARAM, _variant_t((long)bAllowMultiplePISubscriptionRCNRC2));

		rowset->ExecuteStoredProc();

		long status = rowset->GetParameterFromStoredProc("p_status");
		if(status != 1) {
      MT_THROW_COM_ERROR(status); // throws an exception
		}
    _bstr_t dateModified = rowset->GetParameterFromStoredProc("p_datemodified");
    *pDateModified = dateModified == _bstr_t("Y") ? VARIANT_TRUE : VARIANT_FALSE;

    // Now write out the UDRC unit values configured prior to saving
		ROWSETLib::IMTRowSetPtr unitValues = aSubPtr->GetRecurringChargeUnitValuesFromMemoryAsRowset();
    MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr innerSubWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
			  
    if(unitValues->GetRecordCount() > 0)
    {
      long oldId = -1;

      MTPRODUCTCATALOGEXECLib::IMTSubscriptionBasePtr base = dynamic_cast<IMTSubscriptionBase*>(pSub);
      
      for(int i=0; i<unitValues->GetRecordCount(); i++)
		  {
        long newId = (long)unitValues->GetValue(L"id_prop");

        if(newId != oldId)
        {
          MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr subWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));

          // Since we're doing a batch update of values...
          // delete all records from min to max dates, then insert each
          subWriter->DeleteUnitValue(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
															    base, 
                                  newId,
                                  (DATE)getMinMTOLETime(),
                                  (DATE)GetMaxMTOLETime());

          oldId = newId;
        }

			  // Set the unit value
			  innerSubWriter->SetUnitValue(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
															  base, 
															  newId, 
															  (DECIMAL)unitValues->GetValue(L"n_value"), 
															  (DATE)unitValues->GetValue(L"vt_start"), 
															  (DATE)unitValues->GetValue(L"vt_end"));			

			  unitValues->MoveNext();
		  }
      innerSubWriter->FinalizeUnitValue(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), base);
    }

    oldDataRowset->SetQueryTag("__GET_SUBSCRIPTION_START_END_DATES__");
    //Find the new start/end dates.  We can't just use the values that were passed in, because the DB 
    //  sometimes makes a new date range using the overlap of the new dates and the old dates.
    //  We have chosen (for now) not to fix that behavior, but the audit logging must still be
    //  consistent with what's actually in the DB.
		oldDataRowset->AddParam(L"%%ID_SUB%%", aSubPtr->GetID());
		oldDataRowset->Execute();
    _variant_t newStartDate = oldDataRowset->GetValue("vt_start");
    _variant_t newEndDate = oldDataRowset->GetValue("vt_end");

    MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
    CString auditInfo = "Changed product offering " + CString((char *)(aSubPtr->GetProductOffering()->GetName()));
    CString dateInfo = "";
    CString oldStartStr = COleDateTime(oldStartDate).Format(VAR_DATEVALUEONLY);
    CString newStartStr = COleDateTime(newStartDate).Format(VAR_DATEVALUEONLY);
    CString oldEndStr = COleDateTime(oldEndDate).Format(VAR_DATEVALUEONLY);
    CString newEndStr = COleDateTime(newEndDate).Format(VAR_DATEVALUEONLY);
    dateInfo.Format(_T(".  Was from %s to %s.  Now from %s to %s."),oldStartStr, oldEndStr, newStartStr, newEndStr);

    PCCache::GetAuditor()->FireEventWithAdditionalData(AuditEventsLib::AUDITEVENT_SUB_UPDATE,
                                                        pContext->AccountID,
                                                        1,
                                                        aSubPtr->GetAccountID(),
                                                        (LPCTSTR)(auditInfo + dateInfo),
                                                        pContext->LoggedInAs,
                                                        pContext->ApplicationName); 

  }
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}


STDMETHODIMP CMTSubscriptionWriter::BulkSubscriptionChange(IMTSessionContext* apCtxt, long aOldPO_id, long aNewPO_id, VARIANT vtDate,VARIANT_BOOL bNextBillingCycle)
{
	MTAutoContext context(m_spObjectContext);
	try {

    // Make sure vtDate is really a date.
    _variant_t variantDate(vtDate);
    variantDate.ChangeType(VT_DATE);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		
		// step 1: verify we can sucessfully bulk subscribe between the source and destination product offerings
		if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_Account_NoDuplicateProdOff )||
				PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_Account_NoConflictingProdOff ))
		{
			rowset->InitializeForStoredProc("CanBulkSubscribe");
			rowset->AddInputParameterToStoredProc (	"id_old_po", MTTYPE_INTEGER, INPUT_PARAM, aOldPO_id);
			rowset->AddInputParameterToStoredProc (	"id_new_po", MTTYPE_INTEGER, INPUT_PARAM, aNewPO_id);
			rowset->AddInputParameterToStoredProc (	"subdate", MTTYPE_DATE, INPUT_PARAM, variantDate);
			rowset->AddOutputParameterToStoredProc ("status", MTTYPE_INTEGER, OUTPUT_PARAM);
			rowset->ExecuteStoredProc();
			long statuscode = rowset->GetParameterFromStoredProc("status");
			switch(statuscode) {
			case 1:
					if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_Account_NoDuplicateProdOff ))
						MT_THROW_COM_ERROR(IID_IMTSubscriptionWriter,MTPCUSER_BULKSUB_ACCS_ALREADY_SUBS_TO_NEW_PO);
					break;
			case 2:
					if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_Account_NoConflictingProdOff ))
						MT_THROW_COM_ERROR(IID_IMTSubscriptionWriter,MTPCUSER_BULKSUB_CONFLICTING_PO);
					break;
			}
		}

    // step 1.5: allocate the subscription ids we need...

    rowset->Clear();
    rowset->SetQueryTag("__GET_BULKSUBCHANGE_COUNT__");
  	rowset->AddParam("%%ID_OLD_PO%%", aOldPO_id);
  	rowset->AddParam("%%DATE%%", variantDate);
    rowset->Execute();

	  long count = rowset->GetValue(0L);
	  if (count > 0)
    {
      // Use a new instance of the IdGenerator since we are using the Initialize method to increment
      // the value in t_current_id by count+1.
		  MetraTech_DataAccess::IIdGenerator2Ptr idGenerator(__uuidof(MetraTech_DataAccess::IdGenerator));
		  idGenerator->Initialize("id_subscription", count+1);

        rowset->Clear();

		// step 2: make the change
		rowset->InitializeForStoredProc("BulkSubscriptionChange");
		rowset->AddInputParameterToStoredProc (	"id_old_po", MTTYPE_INTEGER, INPUT_PARAM, aOldPO_id);
		rowset->AddInputParameterToStoredProc (	"id_new_po", MTTYPE_INTEGER, INPUT_PARAM, aNewPO_id);

		rowset->AddInputParameterToStoredProc (	"date", MTTYPE_DATE, INPUT_PARAM, variantDate);
		rowset->AddInputParameterToStoredProc (	"nextbillingcycle", MTTYPE_W_VARCHAR, INPUT_PARAM, 
			MTTypeConvert::BoolToString(bNextBillingCycle));
    rowset->AddInputParameterToStoredProc (	"p_systemdate", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime());
		rowset->AddInputParameterToStoredProc (	"new_sub", MTTYPE_INTEGER, INPUT_PARAM, idGenerator->NextId);
		rowset->AddOutputParameterToStoredProc ("p_status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->ExecuteStoredProc();
		// check the status of the stored procedure
		long status = rowset->GetParameterFromStoredProc("p_status");
		if(status != 1) 
    {
        switch(status)
		    {
        case 0:
          MT_THROW_COM_ERROR("Unknown Failure during bulk subscription change");
          break;
			  case MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE: 
				  {
				  // we need to lookup the cycle for the product offering.
          MTPRODUCTCATALOGLib::IMTProductOfferingPtr prodOff;
          MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog(__uuidof(MTProductCatalog));
          productCatalog->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));
          prodOff = productCatalog ->GetProductOffering(aNewPO_id);
				  MTPRODUCTCATALOGLib::MTUsageCycleType cycle = prodOff->GetConstrainedCycleType();
				  MTPRODUCTCATALOGLib::IMTPCCyclePtr pcCyclePtr(__uuidof(MTPRODUCTCATALOGLib::MTPCCycle));
				  MT_THROW_COM_ERROR(MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE,
					  (const char*)pcCyclePtr->GetDescriptionFromCycleType(cycle));
				  break;
				  }
			  default:
				  MT_THROW_COM_ERROR(status);
		    }
		}
	}
    else
    {
      MT_THROW_COM_ERROR(MTPC_BULKSUBCHANGE_NO_SOURCEPO_SUBSCRIBERS_FOUND);
    }
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionWriter::SaveNewGroupSub(IMTSessionContext *apCtx,
                                                    IMTGroupSubscription *pGroupSub,
                                                    VARIANT_BOOL* pDateModified)
{
	ASSERT(apCtx && pGroupSub);
	if(!(apCtx && pGroupSub)) return E_POINTER;
	MTAutoContext context(m_spObjectContext);

	try {
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->InitializeForStoredProc("CreateGroupSubscription");

		MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr aGroupSubPtr(pGroupSub);

		_variant_t subGUID,groupGUID;
		if(!MTMiscUtil::CreateGuidAsVariant(subGUID) || !MTMiscUtil::CreateGuidAsVariant(groupGUID)) {
			return Error("Failed to create GUID values for new group subscription");
		}
		
		string sSameCorpEnforced = 
			(PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE) ? "1" : "0";

		rowset->AddInputParameterToStoredProc (	"p_sub_GUID", MTTYPE_VARBINARY, INPUT_PARAM, subGUID);
		rowset->AddInputParameterToStoredProc (	"p_group_GUID", MTTYPE_VARBINARY, INPUT_PARAM, groupGUID);
		rowset->AddInputParameterToStoredProc (	"p_name", MTTYPE_VARCHAR, INPUT_PARAM, aGroupSubPtr->GetName());
		rowset->AddInputParameterToStoredProc (	"p_desc", MTTYPE_VARCHAR, INPUT_PARAM, aGroupSubPtr->GetDescription());

		MTPRODUCTCATALOGLib::IMTPCCyclePtr cyclePtr = aGroupSubPtr->GetCycle();
		// compute the cycle ID.
		cyclePtr->ComputeCycleIDFromProperties();
		long cycleID = cyclePtr->GetCycleID();

		rowset->AddInputParameterToStoredProc (	"p_usage_cycle", MTTYPE_INTEGER, INPUT_PARAM, cycleID);
		rowset->AddInputParameterToStoredProc (	"p_startdate", MTTYPE_DATE, INPUT_PARAM, 
			aGroupSubPtr->GetEffectiveDate()->GetStartDate());

		if(aGroupSubPtr->GetEffectiveDate()->IsEndDateNull() == VARIANT_TRUE) {
			_variant_t empty;
			empty.vt = VT_NULL;
			rowset->AddInputParameterToStoredProc (	"p_enddate", MTTYPE_DATE, INPUT_PARAM,empty);
		}
		else {
			rowset->AddInputParameterToStoredProc (	"p_enddate", MTTYPE_DATE, INPUT_PARAM,
				aGroupSubPtr->GetEffectiveDate()->GetEndDate());
		}

		rowset->AddInputParameterToStoredProc (	"p_id_po", MTTYPE_INTEGER, INPUT_PARAM, 
			aGroupSubPtr->GetProductOfferingID());


		_variant_t bProportional = aGroupSubPtr->GetProportionalDistribution();
		rowset->AddInputParameterToStoredProc (	"p_proportional", MTTYPE_VARCHAR, INPUT_PARAM,
			 (bool)bProportional == true ? "Y" : "N");

    _variant_t bSupportGroupOps = aGroupSubPtr->GetSupportGroupOps();
		rowset->AddInputParameterToStoredProc (	"p_supportgroupops", MTTYPE_VARCHAR, INPUT_PARAM,
			 (bool)bSupportGroupOps == true ? "Y" : "N");


		variant_t empty;
		empty.vt = VT_NULL;

		rowset->AddInputParameterToStoredProc (	"p_discountaccount", MTTYPE_INTEGER, INPUT_PARAM,
			(bool)bProportional == true ? empty : aGroupSubPtr->GetDistributionAccount());

		// if allowing corporate account moves then the group subscriptions are global, so set the corp. account id to 1
		if (PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE)
		   rowset->AddInputParameterToStoredProc (	"p_CorporateAccount", MTTYPE_INTEGER, INPUT_PARAM,
			    aGroupSubPtr->GetCorporateAccount());
		else
			rowset->AddInputParameterToStoredProc (	"p_CorporateAccount", MTTYPE_INTEGER, INPUT_PARAM, 1);

    
    rowset->AddInputParameterToStoredProc (	"p_systemdate", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime());

		// business rule hint. Needed in CheckGroupSubBusinessRules stored proc 
		rowset->AddInputParameterToStoredProc (	"p_enforce_same_corporation", MTTYPE_VARCHAR, INPUT_PARAM, sSameCorpEnforced.c_str());

                //CORE-4245 Fix
                if (PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch) == VARIANT_TRUE)
		   rowset->AddInputParameterToStoredProc ("p_allow_acc_po_curr_mismatch", MTTYPE_INTEGER, INPUT_PARAM, 1);
		else
			rowset->AddInputParameterToStoredProc (	"p_allow_acc_po_curr_mismatch", MTTYPE_INTEGER, INPUT_PARAM, 0);


    MetraTech_DataAccess::IIdGenerator2Ptr idGenerator = SubscriptionIdGenerator::Get();
	long nextSubID = idGenerator->NextMashedId;

		rowset->AddInputParameterToStoredProc("p_id_sub", MTTYPE_INTEGER, INPUT_PARAM, nextSubID);

		// output parameters
		rowset->AddOutputParameterToStoredProc("p_id_group", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->AddOutputParameterToStoredProc("p_status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->AddOutputParameterToStoredProc("p_datemodified", MTTYPE_VARCHAR, OUTPUT_PARAM);
		rowset->ExecuteStoredProc();

		// get the status value
		long status = rowset->GetParameterFromStoredProc("p_status");
		if(status != 1) {
      // this method throws an error
      ResolveGenericSubError(status,aGroupSubPtr);
		}
    _bstr_t dateModified = rowset->GetParameterFromStoredProc("p_datemodified");
    *pDateModified = dateModified == _bstr_t("Y") ? VARIANT_TRUE : VARIANT_FALSE;

		// subscription ID
		aGroupSubPtr->PutID(nextSubID);
		// group ID
		aGroupSubPtr->PutGroupID(rowset->GetParameterFromStoredProc("p_id_group"));


		// writes out the UDRC unit values
		ROWSETLib::IMTRowSetPtr unitValues = aGroupSubPtr->GetRecurringChargeUnitValuesFromMemoryAsRowset();
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionBasePtr base = dynamic_cast<IMTSubscriptionBase*>(pGroupSub);
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr subWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
	
    for(int i=0; i<unitValues->GetRecordCount(); i++)
		{
			// Set the unit value
			subWriter->SetUnitValue(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtx), 
															base, 
															(long)unitValues->GetValue(L"id_prop"), 
															(DECIMAL)unitValues->GetValue(L"n_value"), 
															(DATE)unitValues->GetValue(L"vt_start"), 
															(DATE)unitValues->GetValue(L"vt_end"));			
			unitValues->MoveNext();
		}
		if((unitValues->GetRecordCount()) > 0)
		{
    subWriter->FinalizeUnitValue(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtx), base);
	}

		if (!ValidateUDRCUnitValues(aGroupSubPtr->GroupID))
			MT_THROW_COM_ERROR(MTPCUSER_MISSING_UDRC_UNIT_VALUE);

		// writes out the charge accounts for Per Subscription RCs
		ROWSETLib::IMTRowSetPtr recurringChargeAccounts = aGroupSubPtr->GetRecurringChargeAccountsFromMemory();
		for(int i=0; i<recurringChargeAccounts->GetRecordCount(); i++)
		{
			MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr subWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
			// Set the recurring charge account
			subWriter->SetChargeAccount(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtx), 
																	reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTGroupSubscription*>(pGroupSub), 
																	(long)recurringChargeAccounts->GetValue(L"id_prop"), 
																	(long)recurringChargeAccounts->GetValue(L"id_acc"), 
																	(DATE)recurringChargeAccounts->GetValue(L"vt_start"), 
																	(DATE)recurringChargeAccounts->GetValue(L"vt_end"));			
			recurringChargeAccounts->MoveNext();
		}

		if (!ValidatePerSubscriptionChargeAccounts(aGroupSubPtr->GroupID))
			MT_THROW_COM_ERROR(MTPCUSER_MISSING_RC_CHARGE_ACCOUNT);


    // audit
    MTPRODUCTCATALOGLib::IMTSessionContextPtr sessionCtxt(apCtx);
    PCCache::GetAuditor()->FireEventWithAdditionalData( AuditEventsLib::AUDITEVENT_GSUB_CREATE,
                                      sessionCtxt->AccountID,
                                      AuditEventsLib::AUDITENTITY_TYPE_GROUPSUB,
                                      aGroupSubPtr->GetGroupID(),
                                      "",
                                      sessionCtxt->LoggedInAs,
                                      sessionCtxt->ApplicationName);

	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

bool CMTSubscriptionWriter::ValidateUDRCUnitValues(long groupID)
{
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init(CONFIG_DIR);

	rowset->SetQueryTag("__GET_COUNT_OF_MISSING_UDRC_UNIT_VALUES__");
	rowset->AddParam("%%ID_GROUP%%", groupID);
	rowset->Execute();

	if((bool) rowset->GetRowsetEOF())
		MT_THROW_COM_ERROR("No rows returned from __GET_COUNT_OF_MISSING_UDRC_UNIT_VALUES__ query!");

	long count = rowset->GetValue(0L);
	if (count > 0)
		return false;

	return true;
}


bool CMTSubscriptionWriter::ValidatePerSubscriptionChargeAccounts(long groupID)
{
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init(CONFIG_DIR);

	rowset->SetQueryTag("__GET_COUNT_OF_MISSING_PER_SUB_RC_CHARGE_ACCOUNTS__");
	rowset->AddParam("%%ID_GROUP%%", groupID);
	rowset->Execute();

	if((bool) rowset->GetRowsetEOF())
		MT_THROW_COM_ERROR("No rows returned from __GET_COUNT_OF_MISSING_PER_SUB_RC_CHARGE_ACCOUNTS__!");

	long count = rowset->GetValue(0L);
	if (count > 0)
		return false;

	return true;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionWriter::UpdateGroupSub(IMTSessionContext* apCtx,
																									 IMTGroupSubscription* pGroupSub,
                                                   VARIANT_BOOL* pDateModified)
{
	MTAutoContext context(m_spObjectContext);
	try {
		string sSameCorpEnforced = 
			(PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE) ? "1" : "0";

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->InitializeForStoredProc("UpdateGroupSubscription");
		MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr aGroupSubPtr(pGroupSub);
		rowset->AddInputParameterToStoredProc (	"p_id_group", MTTYPE_INTEGER, INPUT_PARAM, aGroupSubPtr->GetGroupID());
		rowset->AddInputParameterToStoredProc (	"p_name", MTTYPE_VARCHAR, INPUT_PARAM, aGroupSubPtr->GetName());
		rowset->AddInputParameterToStoredProc (	"p_desc", MTTYPE_VARCHAR, INPUT_PARAM, aGroupSubPtr->GetDescription());
		rowset->AddInputParameterToStoredProc (	"p_startdate", MTTYPE_DATE, INPUT_PARAM, 
			aGroupSubPtr->GetEffectiveDate()->GetStartDate());
		if(aGroupSubPtr->GetEffectiveDate()->IsEndDateNull() == VARIANT_TRUE) {
			_variant_t empty;
			empty.vt = VT_NULL;
			rowset->AddInputParameterToStoredProc (	"p_enddate", MTTYPE_DATE, INPUT_PARAM,empty);
		}
		else {
			rowset->AddInputParameterToStoredProc (	"p_enddate", MTTYPE_DATE, INPUT_PARAM,
				aGroupSubPtr->GetEffectiveDate()->GetEndDate());
		}
		_variant_t bProportional = aGroupSubPtr->GetProportionalDistribution();
		rowset->AddInputParameterToStoredProc (	"p_proportional", MTTYPE_VARCHAR, INPUT_PARAM,
			 (bool)bProportional == true ? "Y" : "N");

    _variant_t bSupportGroupOps = aGroupSubPtr->GetSupportGroupOps();
		rowset->AddInputParameterToStoredProc (	"p_supportgroupops", MTTYPE_VARCHAR, INPUT_PARAM,
			 (bool)bSupportGroupOps == true ? "Y" : "N");

		variant_t empty;
		empty.vt = VT_NULL;

		rowset->AddInputParameterToStoredProc (	"p_discountaccount", MTTYPE_INTEGER, INPUT_PARAM,
			(bool)bProportional == true ? empty : aGroupSubPtr->GetDistributionAccount());

		// if allowing corporate account moves then the group subscriptions are global, so set the corp. account id to 1
		if (PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE)
		   rowset->AddInputParameterToStoredProc (	"p_CorporateAccount", MTTYPE_INTEGER, INPUT_PARAM,
			    aGroupSubPtr->GetCorporateAccount());
		else
			rowset->AddInputParameterToStoredProc (	"p_CorporateAccount", MTTYPE_INTEGER, INPUT_PARAM, 1);

		rowset->AddInputParameterToStoredProc (	"p_systemdate", MTTYPE_DATE, INPUT_PARAM,GetMTOLETime());

		//business rule hint. Needed in CheckGroupSubBusinessRules stored proc 
		rowset->AddInputParameterToStoredProc (	"p_enforce_same_corporation", MTTYPE_VARCHAR, INPUT_PARAM, sSameCorpEnforced.c_str());

                //CORE-4245 Fix
                if (PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch) == VARIANT_TRUE)
		   rowset->AddInputParameterToStoredProc ("p_allow_acc_po_curr_mismatch", MTTYPE_INTEGER, INPUT_PARAM, 1);
		else
		   rowset->AddInputParameterToStoredProc (	"p_allow_acc_po_curr_mismatch", MTTYPE_INTEGER, INPUT_PARAM, 0);


		rowset->AddOutputParameterToStoredProc("p_status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->AddOutputParameterToStoredProc("p_datemodified", MTTYPE_VARCHAR, OUTPUT_PARAM);
		rowset->ExecuteStoredProc();

		// get the status value
		long status = rowset->GetParameterFromStoredProc("p_status");
		if(status != 1) {
			MT_THROW_COM_ERROR(status);
		}
    _bstr_t dateModified = rowset->GetParameterFromStoredProc("p_datemodified");
    *pDateModified = dateModified == _bstr_t("Y") ? VARIANT_TRUE : VARIANT_FALSE;

    // audit
    MTPRODUCTCATALOGLib::IMTSessionContextPtr sessionCtxt(apCtx);
    PCCache::GetAuditor()->FireEventWithAdditionalData( AuditEventsLib::AUDITEVENT_GSUB_UPDATE,
                                      sessionCtxt->AccountID,
                                      AuditEventsLib::AUDITENTITY_TYPE_GROUPSUB,
                                      aGroupSubPtr->GetGroupID(),
                                      "",
                                      sessionCtxt->LoggedInAs,
                                      sessionCtxt->ApplicationName);

	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;

}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionWriter::AddAccountToGroupSub(IMTSessionContext *apCtx,
																												 IMTGroupSubscription *pGroupSub,
																												 IMTGSubMember *pGsubMember,
                                                         VARIANT_BOOL* pDateModified)
{
	ASSERT(apCtx && pGroupSub && pGsubMember);
	if(!(apCtx && pGroupSub && pGsubMember)) return E_POINTER;
	MTAutoContext context(m_spObjectContext);

	try {
		MTPRODUCTCATALOGLib::IMTGSubMemberPtr submemberPtr(pGsubMember);
	
		// check whether the account can subscribe.  Note: this method
		// creates a YAAC and may be a performance bottleneck if we have a large
		// number of accounts
		CheckAccountState(apCtx,submemberPtr->GetAccountID(),submemberPtr->GetStartDate());

		string sSameCorpEnforced = 
			(PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE) ? "1" : "0";

		bool bAllowAccountPOCurrencyMismatch3 = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch) == VARIANT_TRUE;
		bool bAllowMultiplePISubscriptionRCNRC3 = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowMultiplePISubscriptionRCNRC) == VARIANT_TRUE;


		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->InitializeForStoredProc("AddAccountToGroupSub");

		MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr aGroupSubPtr(pGroupSub);


		rowset->AddInputParameterToStoredProc ("p_id_sub", MTTYPE_INTEGER, INPUT_PARAM, aGroupSubPtr->GetID());
		rowset->AddInputParameterToStoredProc ("p_id_group", MTTYPE_INTEGER, INPUT_PARAM, aGroupSubPtr->GetGroupID());
		rowset->AddInputParameterToStoredProc ("p_id_po", MTTYPE_INTEGER, INPUT_PARAM, aGroupSubPtr->GetProductOfferingID());
		rowset->AddInputParameterToStoredProc ("p_id_acc", MTTYPE_INTEGER, INPUT_PARAM, submemberPtr->GetAccountID());
		rowset->AddInputParameterToStoredProc ("p_startdate", MTTYPE_DATE, INPUT_PARAM, submemberPtr->GetStartDate());

		_variant_t empty;
		empty.vt = VT_NULL;

		if(submemberPtr->GetEndDateNotSpecified() == VARIANT_TRUE) {
			rowset->AddInputParameterToStoredProc (	"p_enddate", MTTYPE_DATE, INPUT_PARAM, empty);
		}
		else {
			rowset->AddInputParameterToStoredProc (	"p_enddate", MTTYPE_DATE, INPUT_PARAM, submemberPtr->GetEndDate());
		}
    rowset->AddInputParameterToStoredProc (	"p_systemdate", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime());

		rowset->AddInputParameterToStoredProc (	"p_enforce_same_corporation", MTTYPE_VARCHAR, INPUT_PARAM, sSameCorpEnforced.c_str());

		rowset->AddOutputParameterToStoredProc("p_status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->AddOutputParameterToStoredProc("p_datemodified", MTTYPE_VARCHAR, OUTPUT_PARAM);
 		rowset->AddInputParameterToStoredProc (	"p_allow_acc_po_curr_mismatch", MTTYPE_INTEGER, INPUT_PARAM, _variant_t((long)bAllowAccountPOCurrencyMismatch3));
	  rowset->AddInputParameterToStoredProc (	"p_allow_multiple_pi_sub_rcnrc", MTTYPE_INTEGER, INPUT_PARAM, _variant_t((long)bAllowMultiplePISubscriptionRCNRC3));

    rowset->ExecuteStoredProc();

		// get the status value
		long status = rowset->GetParameterFromStoredProc("p_status");
		if(status != 1) {
			MT_THROW_COM_ERROR(status);
		}
    _bstr_t dateModified = rowset->GetParameterFromStoredProc("p_datemodified");
    *pDateModified = dateModified == _bstr_t("Y") ? VARIANT_TRUE : VARIANT_FALSE;

    // audit
    MTPRODUCTCATALOGLib::IMTSessionContextPtr sessionCtxt(apCtx);
    PCCache::GetAuditor()->FireEventWithAdditionalData( AuditEventsLib::AUDITEVENT_GSUB_MEMBER_ADD,
                                      sessionCtxt->AccountID,
                                      AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
                                      submemberPtr->GetAccountID(),
                                      aGroupSubPtr->GetName(),
                                      sessionCtxt->LoggedInAs,
                                      sessionCtxt->ApplicationName);
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	context.Complete();
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionWriter::AddAccountToGroupSubBatch(IMTSessionContext *apCtx,
																															IMTGroupSubscription *pGroupSub,
																															IMTCollection *pCol,
																															IMTProgress *pProgress,
                                                              VARIANT_BOOL* pDateModified,
																															IMTSQLRowset* errorRs)
{
	try {
    AddAccountToGroupSubBatchHelper aBatchHelper;
    aBatchHelper.Init(m_spObjectContext,MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr(this));
    aBatchHelper.errorRs = ROWSETLib::IMTSQLRowsetPtr(errorRs);
    aBatchHelper.mCTX = apCtx;
    aBatchHelper.mGroupSub = pGroupSub;
    aBatchHelper.PerformBatchOperation(pCol,pProgress);
    *pDateModified = aBatchHelper.bDateModified;
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:  CheckGroupSubAccountState  
// Arguments: collection of gsubmember pointers, error rowset
// Description: 
// ----------------------------------------------------------------

void CMTSubscriptionWriter::CheckAccountState(IMTSessionContext *apCtx,
																							long accountID,
                                              DATE aStartDate)
{

	MTYAACLib::IMTYAACPtr tempYAAC(__uuidof(MTYAACLib::MTYAAC));
	tempYAAC->InitAsSecuredResource(accountID,
		reinterpret_cast<MTYAACLib::IMTSessionContext *>(apCtx),_variant_t(aStartDate,VT_DATE));

	// check that we can create a subscription
	if(tempYAAC->GetAccountStateMgr()->GetStateObject()->CanSubscribe() == VARIANT_FALSE) {
		MT_THROW_COM_ERROR(MT_ADD_TO_GROUP_SUB_BAD_STATE);
	}

}


// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionWriter::ModifyMembership(IMTSessionContext *apCtx,
                                                     IMTGroupSubscription *pGroupSub,
                                                     IMTGSubMember *pSubMember,
                                                     VARIANT_BOOL* pDateModified)
{
	MTAutoContext context(m_spObjectContext);

	try {
		MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr groupSubPtr(pGroupSub);
		MTPRODUCTCATALOGLib::IMTGSubMemberPtr submemberPtr(pSubMember);

		bool bAllowAccountPOCurrencyMismatch4 = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch) == VARIANT_TRUE;
		bool bAllowMultiplePISubscriptionRCNRC4 = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowMultiplePISubscriptionRCNRC) == VARIANT_TRUE;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->InitializeForStoredProc("UpdateGroupSubMembership");
		rowset->AddInputParameterToStoredProc (	"p_id_acc", MTTYPE_INTEGER, INPUT_PARAM,submemberPtr->GetAccountID()); 
		rowset->AddInputParameterToStoredProc (	"p_id_sub", MTTYPE_INTEGER, INPUT_PARAM,groupSubPtr->GetID());
		rowset->AddInputParameterToStoredProc (	"p_id_po", MTTYPE_INTEGER, INPUT_PARAM, groupSubPtr->GetProductOfferingID());
		rowset->AddInputParameterToStoredProc (	"p_id_group", MTTYPE_INTEGER, INPUT_PARAM, groupSubPtr->GetGroupID());

		_variant_t empty;
		empty.vt = VT_NULL;
		
		rowset->AddInputParameterToStoredProc (	"p_startdate", MTTYPE_DATE, INPUT_PARAM, submemberPtr->GetStartDate());
		
		if(submemberPtr->GetEndDateNotSpecified() == VARIANT_TRUE) {
			rowset->AddInputParameterToStoredProc (	"p_enddate", MTTYPE_DATE, INPUT_PARAM, empty);
		}
		else {
			rowset->AddInputParameterToStoredProc (	"p_enddate", MTTYPE_DATE, INPUT_PARAM, submemberPtr->GetEndDate());
		}

    rowset->AddInputParameterToStoredProc (	"p_systemdate", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime());
		rowset->AddOutputParameterToStoredProc("p_status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->AddOutputParameterToStoredProc("p_datemodified", MTTYPE_VARCHAR, OUTPUT_PARAM);
		rowset->AddInputParameterToStoredProc (	"p_allow_acc_po_curr_mismatch", MTTYPE_INTEGER, INPUT_PARAM, _variant_t((long)bAllowAccountPOCurrencyMismatch4));
	    rowset->AddInputParameterToStoredProc (	"p_allow_multiple_pi_sub_rcnrc", MTTYPE_INTEGER, INPUT_PARAM, _variant_t((long)bAllowMultiplePISubscriptionRCNRC4));

		rowset->ExecuteStoredProc();
		long status = rowset->GetParameterFromStoredProc("p_status");
		if(status != 1) {
			MT_THROW_COM_ERROR(status);
		}
    _bstr_t dateModified = rowset->GetParameterFromStoredProc("p_datemodified");
    *pDateModified = dateModified == _bstr_t("Y") ? VARIANT_TRUE : VARIANT_FALSE;

    // audit
    MTPRODUCTCATALOGLib::IMTSessionContextPtr sessionCtxt(apCtx);
    PCCache::GetAuditor()->FireEvent( AuditEventsLib::AUDITEVENT_GSUB_MEMBER_UPDATE,
                                      sessionCtxt->AccountID,
                                      AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
                                      submemberPtr->GetAccountID(),
                                      groupSubPtr->GetName());
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	context.Complete();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionWriter::ModifyMembershipBatch(IMTSessionContext *apCtx,
																													IMTGroupSubscription *pGroupSub,
																													IMTCollection *pCol,
																													IMTProgress* pProgress,
                                                          VARIANT_BOOL* pDateModified,
																													IMTRowSet **ppRowset)
{
	try {
    ModifyMembershipBatchHelper aBatchHelper;
    aBatchHelper.Init(m_spObjectContext,MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr(this));
    aBatchHelper.mCTX = apCtx;
    aBatchHelper.mGroupSub = pGroupSub;
    *ppRowset = reinterpret_cast<IMTRowSet*>(aBatchHelper.PerformBatchOperation(pCol,pProgress).Detach());
    *pDateModified = aBatchHelper.bDateModified;
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

STDMETHODIMP CMTSubscriptionWriter::DeleteMember(IMTSessionContext *apCtx, IMTGroupSubscription *pGroupSub, long aAccountID, VARIANT aSubStartDate)
{
	MTAutoContext context(m_spObjectContext);

	try {
		MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr groupSubPtr(pGroupSub);

    // Determine if a date was passed in
    _variant_t vtStartDate;
    wstring strStartDate;
    if(!OptionalVariantConversion(aSubStartDate,VT_DATE,vtStartDate))
    {
      // If the date was not specified, we will set it to the max date
      // Then the stored proce
      vtStartDate = GetMaxMTOLETime();
    }

    FormatValueForDB(vtStartDate, FALSE, strStartDate);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->InitializeForStoredProc("RemoveGroupSubMember");
		rowset->AddInputParameterToStoredProc("p_id_acc", MTTYPE_INTEGER, INPUT_PARAM, aAccountID);
    // New parameter - start date - to uniquely identify the record to be deleted, since we allow an account to
    // participate in a group sub for 2 different time spans.
    rowset->AddInputParameterToStoredProc("p_startdate", MTTYPE_DATE, INPUT_PARAM, vtStartDate);
		rowset->AddInputParameterToStoredProc("p_id_group", MTTYPE_INTEGER, INPUT_PARAM, groupSubPtr->GetGroupID());

		if(PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_IgnoreDateCheckOnGroupSubDelete)) 
    {
			rowset->AddInputParameterToStoredProc("p_b_overrideDateCheck", MTTYPE_VARCHAR, INPUT_PARAM, "Y");
		}
		else 
    {
			rowset->AddInputParameterToStoredProc("p_b_overrideDateCheck", MTTYPE_VARCHAR, INPUT_PARAM, "N");
		}

    rowset->AddInputParameterToStoredProc("p_systemdate", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime());
		rowset->AddOutputParameterToStoredProc("p_status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->ExecuteStoredProc();
		long status = rowset->GetParameterFromStoredProc("p_status");
		if(status != 1) {
			MT_THROW_COM_ERROR(status);
		}

    // audit
    MTPRODUCTCATALOGLib::IMTSessionContextPtr sessionCtxt(apCtx);
    PCCache::GetAuditor()->FireEvent( AuditEventsLib::AUDITEVENT_GSUB_MEMBER_DELETE,
                                      sessionCtxt->AccountID,
                                      AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
                                      aAccountID,
                                      groupSubPtr->GetName());
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	context.Complete();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionWriter::DeleteMemberBatch(IMTSessionContext *apCtx,
																											IMTGroupSubscription *pGroupSub,
																											IMTCollection *pCol,
																											IMTProgress* pProgress,
																											IMTRowSet **ppRowset)
{
	try {
    DeleteMemberBatchHelper aBatchHelper;
    aBatchHelper.Init(m_spObjectContext,MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr(this));
    aBatchHelper.mCTX = apCtx;
    aBatchHelper.mGroupSub = pGroupSub;
    *ppRowset = reinterpret_cast<IMTRowSet*>(aBatchHelper.PerformBatchOperation(pCol,pProgress).Detach());
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	return S_OK;
}


STDMETHODIMP CMTSubscriptionWriter::DeleteSubscription(IMTSessionContext *apCTX, IMTSubscriptionBase *pSubBase)
{
	MTAutoContext context(m_spObjectContext);
	try {
    MTPRODUCTCATALOGLib::IMTSubscriptionBasePtr subBasePtr(pSubBase);
    MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr timeSpanPtr = subBasePtr->GetEffectiveDate();
    
    if(!PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_IgnoreDateCheckOnSubscriptionDelete)) {
      MTDate currentTime((DATE)GetMTOLETime());
      MTDate subscriptionStart = (DATE)timeSpanPtr->GetStartDate();
    
      if(subscriptionStart < currentTime) {
        MT_THROW_COM_ERROR(MTPCUSER_FAILED_TO_DELETE_SUBSCRIPTION);
      }
    }

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->InitializeForStoredProc("RemoveSubscription");
		rowset->AddInputParameterToStoredProc (	"p_id_sub", MTTYPE_INTEGER, INPUT_PARAM,subBasePtr->GetID()); 
		rowset->AddInputParameterToStoredProc (	"p_systemdate", MTTYPE_DATE, INPUT_PARAM,GetMTOLETime()); 
		rowset->ExecuteStoredProc();

    //audit 
    //use QueryInterface to determine type
    MTPRODUCTCATALOGLib::IMTSubscriptionPtr subPtr;
    HRESULT hr = subBasePtr.QueryInterface(__uuidof(IMTSubscription), (void**)&subPtr);
    if(SUCCEEDED(hr))
    {
      //audit a normal subscription (entity is accountID)
      MTPRODUCTCATALOGLib::IMTSessionContextPtr sessionCtxt(apCTX);
      PCCache::GetAuditor()->FireEventWithAdditionalData(AuditEventsLib::AUDITEVENT_SUB_DELETE,
                                       sessionCtxt->AccountID,
                                       AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
                                       subPtr->GetAccountID(),
                                       subPtr->GetProductOffering()->GetName(),
                                       sessionCtxt->LoggedInAs,
                                       sessionCtxt->ApplicationName);
    }
    else
    {
      //audit group subscription  (entity is groupSubID)
      MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr groupSubPtr = subBasePtr;

      MTPRODUCTCATALOGLib::IMTSessionContextPtr sessionCtxt(apCTX);
      PCCache::GetAuditor()->FireEventWithAdditionalData( AuditEventsLib::AUDITEVENT_SUB_DELETE,
                                        sessionCtxt->AccountID,
                                        AuditEventsLib::AUDITENTITY_TYPE_GROUPSUB,
                                        groupSubPtr->GetGroupID(),
                                        groupSubPtr->GetName(),
                                        sessionCtxt->LoggedInAs,
                                        sessionCtxt->ApplicationName);
      
      
    }
  }
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTSubscriptionWriter::DeleteGroupSubscription(IMTSessionContext *apCTX, IMTSubscriptionBase *pSubBase)
{
	MTAutoContext context(m_spObjectContext);
	try 
  {
    MTPRODUCTCATALOGLib::IMTSubscriptionBasePtr subBasePtr(pSubBase);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->InitializeForStoredProc("RemoveGroupSubscription");
		rowset->AddInputParameterToStoredProc("p_id_sub", MTTYPE_INTEGER, INPUT_PARAM, subBasePtr->GetID()); 
		rowset->AddInputParameterToStoredProc("p_systemdate", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime());
		rowset->AddOutputParameterToStoredProc ("p_status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->ExecuteStoredProc();

		// Treat possible errors
		long statuscode = rowset->GetParameterFromStoredProc("p_status");
		if (statuscode == 1) // Meaning the group sub is not empty, or more technically: there was, at some point, at least one member participating in this group
    {
      MT_THROW_COM_ERROR(IID_IMTSubscriptionWriter, MTPCUSER_CANNOT_DELETE_GROUPSUB_HASMEMBERS);
    }
    else
    {
      // It succeeded and we are going to log this audit event
      MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr groupSubPtr = subBasePtr;
      MTPRODUCTCATALOGLib::IMTSessionContextPtr sessionCtxt(apCTX);
      PCCache::GetAuditor()->FireEventWithAdditionalData( AuditEventsLib::AUDITEVENT_GSUB_DELETE,
                                        sessionCtxt->AccountID,
                                        AuditEventsLib::AUDITENTITY_TYPE_GROUPSUB,
                                        groupSubPtr->GetGroupID(),
                                        "Successfully deleted the group subscription: " + groupSubPtr->GetName(),
                                        sessionCtxt->LoggedInAs,
                                        sessionCtxt->ApplicationName);
    }
  }
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	context.Complete();
	return S_OK;
}


class MTSubscribeBatchHelper : public MTAccountBatchHelper<MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr>
{
public:
  HRESULT PerformSingleOp(long aIndex,long &aFailedAccount);
public:
  IMTPCTimeSpan* timeSpan;
  long mProductofferingID;
  MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr mCTX;
};

HRESULT MTSubscribeBatchHelper::PerformSingleOp(long aIndex,long &aFailedAccount)
{
  // get the descendent
  long account = mColPtr->GetItem(aIndex);
  aFailedAccount = account;

  MTPRODUCTCATALOGLib::IMTSubscriptionPtr subPtr(__uuidof(MTPRODUCTCATALOGLib::MTSubscription));
  subPtr->PutAccountID(account);
  subPtr->PutEffectiveDate((MTPRODUCTCATALOGLib::IMTPCTimeSpan *)timeSpan);
  subPtr->SetProductOffering(mProductofferingID);
  subPtr->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext *>(mCTX.GetInterfacePtr()));

	//BP: how do we deal if date was modified in bulk subscription? Return it as warning in Errors rowset?
  return mControllerClass->SaveNew(mCTX,reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSubscription*>(subPtr.GetInterfacePtr()));
}


STDMETHODIMP CMTSubscriptionWriter::SubscribeBatch(IMTSessionContext* apCtx,
                                                   long aProductID,
                                                   IMTPCTimeSpan* pTimeSpan,
                                                   IMTCollection* pCol,
                                                   IMTProgress* pProgress,
                                                   VARIANT_BOOL* pDateModified,
                                                   IMTSQLRowset* errorRs)
{
	try {
    MTSubscribeBatchHelper aBatchHelper;
    aBatchHelper.Init(m_spObjectContext,MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr(this));
    aBatchHelper.mCTX = apCtx;
    aBatchHelper.errorRs = ROWSETLib::IMTSQLRowsetPtr(errorRs);
    aBatchHelper.timeSpan = pTimeSpan;
    aBatchHelper.mProductofferingID = aProductID;
    aBatchHelper.PerformBatchOperation(pCol,pProgress);
    *pDateModified = VARIANT_FALSE;
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	return S_OK;
}

void CMTSubscriptionWriter::ResolveGenericSubError(HRESULT hr,MTPRODUCTCATALOGLib::IMTSubscriptionBasePtr subBasePtr)
{
  switch(hr) {
  case MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE: 
    {
      // we need to lookup the cycle of the account for the product offering.
      MTPRODUCTCATALOGLib::MTUsageCycleType cycle = subBasePtr->GetProductOffering()->GetConstrainedCycleType();
      MTPRODUCTCATALOGLib::IMTPCCyclePtr pcCyclePtr(__uuidof(MTPRODUCTCATALOGLib::MTPCCycle));
      MT_THROW_COM_ERROR(MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE,
        (const char*)pcCyclePtr->GetDescriptionFromCycleType(cycle));
      break;
    }
  default:
    MT_THROW_COM_ERROR(hr);
  }
}

STDMETHODIMP CMTSubscriptionWriter::SetChargeAccount(IMTSessionContext* apCtx,
																										 IMTGroupSubscription* pGroupSub,
																										 long aPrcItemInstanceID,
																										 long aAccountID,
																								     DATE aStartDate,
																										 DATE aEndDate)
{
	MTAutoContext context(m_spObjectContext);

	try {
		MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr groupSubPtr(pGroupSub);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
    rowset->InitializeForStoredProc("SequencedUpsertGsubRecur");
		rowset->AddInputParameterToStoredProc (	"p_id_group_sub", MTTYPE_INTEGER, INPUT_PARAM, groupSubPtr->GetGroupID()); 
		rowset->AddInputParameterToStoredProc (	"p_id_prop", MTTYPE_INTEGER, INPUT_PARAM,aPrcItemInstanceID); 
		rowset->AddInputParameterToStoredProc (	"p_id_acc", MTTYPE_INTEGER, INPUT_PARAM,aAccountID); 
		if(aStartDate == 0.0 && aEndDate == 0.0)
		{
			// This should be true only when the subscription is being created.
      // We have charge accounts valid for "all time".  This is necessary for a variety
			// of subtle reasons having to do with advance and initial charges.  Suffice
			// it to say, that charge accounts are needed for dates that extend beyond the subscription
			// interval.
			rowset->AddInputParameterToStoredProc("p_vt_start", MTTYPE_DATE, INPUT_PARAM, GetMinDatabaseTime());
			rowset->AddInputParameterToStoredProc("p_vt_end", MTTYPE_DATE, INPUT_PARAM, GetMaxMTOLETime());
		}
    else
		{
			rowset->AddInputParameterToStoredProc (	"p_vt_start", MTTYPE_DATE, INPUT_PARAM, aStartDate); 
			rowset->AddInputParameterToStoredProc (	"p_vt_end", MTTYPE_DATE, INPUT_PARAM, aEndDate); 
		}
		rowset->AddInputParameterToStoredProc (	"p_tt_current", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime()); 
		rowset->AddInputParameterToStoredProc (	"p_tt_max", MTTYPE_DATE, INPUT_PARAM, GetMaxMTOLETime());

    //CORE-4245 Fix
    if (PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch) == VARIANT_TRUE)
		   rowset->AddInputParameterToStoredProc ("p_allow_acc_po_curr_mismatch", MTTYPE_INTEGER, INPUT_PARAM, 1);
		else
			rowset->AddInputParameterToStoredProc (	"p_allow_acc_po_curr_mismatch", MTTYPE_INTEGER, INPUT_PARAM, 0);

		rowset->AddOutputParameterToStoredProc( "p_status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->ExecuteStoredProc();

		// check the status of the stored procedure
		long status = rowset->GetParameterFromStoredProc("p_status");
		if(status != 0) {
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG,
																			"Failed to set charge account on group id = %d, instance id = %d, account id = %d, status = %d", 
																			groupSubPtr->GetGroupID(), 
																			aPrcItemInstanceID, 
																			aAccountID,
																			status);

			if (status == -289472440) // MTPCUSER_EBCR_RECEIVERS_CONFLICT_WITH_EACH_OTHER) 
			{
				MT_THROW_COM_ERROR("EBCR Receivers conflicts with each other..");           
			}
			if (status == -289472441) // MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_RECEIVER) 
			{
				MT_THROW_COM_ERROR("EBCR Cycle conflicts with payer of receiver.");           
			}


			MT_THROW_COM_ERROR(status);
		}
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTSubscriptionWriter::SetRecurringChargeAccounts(IMTSessionContext* apCtx,
																															 IMTGroupSubscription* pGroupSub,
																															 long aAccountID, 
																															 DATE aStartDate, 
																															 DATE aEndDate)
{
	try {
		MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr groupSubPtr(pGroupSub);
		// TODO: Implement this
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTSubscriptionWriter::SetUnitValue(IMTSessionContext* apCtx,
																								 IMTSubscriptionBase* pSub,
																								 long aPrcItemInstanceID,
																								 DECIMAL aUnitValue,
																								 DATE aStartDate,
																								 DATE aEndDate)
{
	MTAutoContext context(m_spObjectContext);

	try {
		MTPRODUCTCATALOGLib::IMTSubscriptionBasePtr subPtr(pSub);
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		std::wstring buffer;
		rowset->SetQueryTag("__SEQUENCED_INSERT_RECUR_VALUE__");
		if(aStartDate == 0.0 && aEndDate == 0.0)
		{
			// We have unit values go for "all time".  This is necessary for a variety
			// of subtle reasons having to do with advance and initial charges.  Suffice
			// it to say, that unit values are needed for dates that extend beyond the subscription
			// interval.
			rowset->AddParam(L"%%VT_START%%", GetMinDatabaseTime());
			rowset->AddParam(L"%%VT_END%%", GetMaxMTOLETime());
		}
		else
		{
			EnforceDayGranularity(aStartDate, aEndDate);
			// Make sure that start date is at midnight, and end date is at 11:59:59 PM
			rowset->AddParam(L"%%VT_START%%", _variant_t(aStartDate, VT_DATE));
			rowset->AddParam(L"%%VT_END%%", _variant_t(aEndDate, VT_DATE));
		}
		rowset->AddParam("%%ID_PROP%%", aPrcItemInstanceID);
		rowset->AddParam("%%ID_SUB%%", subPtr->ID);
		rowset->AddParam("%%N_VALUE%%", aUnitValue);
		BOOL bSuccess = FormatValueForDB(GetMaxMTOLETime(), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%DT_MAX_VALUE%%", buffer.c_str(), VARIANT_TRUE);

		bSuccess = FormatValueForDB(GetMTOLETime(), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%DT_CURRENT_VALUE%%", buffer.c_str(), VARIANT_TRUE);

		rowset->Execute();
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTSubscriptionWriter::FinalizeUnitValue(IMTSessionContext* apCtx,
																								 IMTSubscriptionBase* pSub)
{
	MTAutoContext context(m_spObjectContext);

	try {
		MTPRODUCTCATALOGLib::IMTSubscriptionBasePtr subPtr(pSub);
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		std::wstring buffer;
		rowset->SetQueryTag("__FINALIZE_RECUR_VALUE__");
		rowset->AddParam("%%ID_SUB%%", subPtr->ID);
		rowset->Execute();
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTSubscriptionWriter::UpdateUnitValue(IMTSessionContext* apCtx,
																										IMTSubscriptionBase* pSub,
																										long aPrcItemInstanceID,
																										DECIMAL aUnitValue,
																										DATE aStartDate,
																										DATE aEndDate)
{
	MTAutoContext context(m_spObjectContext);
	try {
		MTPRODUCTCATALOGLib::IMTSubscriptionBasePtr subPtr(pSub);
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->SetQueryTag("__SEQUENCED_UPDATE_RECUR_VALUE__");
		rowset->AddParam("%%ID_PROP%%", aPrcItemInstanceID);
		rowset->AddParam("%%ID_SUB%%", subPtr->ID);
		rowset->AddParam("%%N_VALUE%%", aUnitValue);

		// Only allow changes on day granularity
		EnforceDayGranularity(aStartDate, aEndDate);

		std::wstring buffer;
		BOOL bSuccess = FormatValueForDB(_variant_t(aStartDate, VT_DATE), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%VT_START%%", buffer.c_str(), VARIANT_TRUE);

		bSuccess = FormatValueForDB(_variant_t(aEndDate, VT_DATE), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%VT_END%%", buffer.c_str(), VARIANT_TRUE);

		rowset->Execute();
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTSubscriptionWriter::DeleteUnitValue(IMTSessionContext* apCtx,
																										IMTSubscriptionBase* pSub,
																										long aPrcItemInstanceID,
																										DATE aStartDate,
																										DATE aEndDate)
 {
	MTAutoContext context(m_spObjectContext);
	try {
		MTPRODUCTCATALOGLib::IMTSubscriptionBasePtr subPtr(pSub);
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->SetQueryTag("__SEQUENCED_DELETE_RECUR_VALUE__");
		rowset->AddParam("%%ID_PROP%%", aPrcItemInstanceID);
		rowset->AddParam("%%ID_SUB%%", subPtr->ID);

		// Only allow changes on day granularity
		EnforceDayGranularity(aStartDate, aEndDate);

		std::wstring buffer;
		BOOL bSuccess = FormatValueForDB(_variant_t(aStartDate, VT_DATE), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%VT_START%%", buffer.c_str(), VARIANT_TRUE);

		bSuccess = FormatValueForDB(_variant_t(aEndDate, VT_DATE), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%VT_END%%", buffer.c_str(), VARIANT_TRUE);

		bSuccess = FormatValueForDB(GetMaxMTOLETime(), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%DT_MAX_VALUE%%", buffer.c_str(), VARIANT_TRUE);

		bSuccess = FormatValueForDB(GetMTOLETime(), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%DT_CURRENT_VALUE%%", buffer.c_str(), VARIANT_TRUE);

		rowset->Execute();
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	context.Complete();
	return S_OK;
}

void CMTSubscriptionWriter::EnforceDayGranularity(DATE& aStartDate, DATE& aEndDate)
{
	SYSTEMTIME startDate;
	SYSTEMTIME endDate;

	::VariantTimeToSystemTime(aStartDate, &startDate);
	::VariantTimeToSystemTime(aEndDate, &endDate);

	if(startDate.wHour != 0 || startDate.wMinute != 0 || startDate.wSecond != 0 || startDate.wMilliseconds != 0)
	{
		startDate.wHour = 0;
		startDate.wMinute = 0;
		startDate.wSecond = 0;
		startDate.wMilliseconds = 0;
		::SystemTimeToVariantTime(&startDate, &aStartDate);
	}
	if(aEndDate != (DATE) GetMaxMTOLETime() &&
		 (endDate.wHour != 23 || endDate.wMinute != 59 || endDate.wSecond != 59 || endDate.wMilliseconds != 0))
	{
		endDate.wHour = 23;
		endDate.wMinute = 59;
		endDate.wSecond = 59;
		endDate.wMilliseconds = 0;
		::SystemTimeToVariantTime(&endDate, &aEndDate);
	}
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionWriter::UnsubscribeMemberBatch(IMTSessionContext *apCtx,
                                                           IMTGroupSubscription *pGroupSub,
                                                           IMTCollection *pCol,
                                                           IMTProgress* pProgress,
                                                           IMTSQLRowset *pErrorRs)
{
	MTAutoContext context(m_spObjectContext);
  bool anyErrors=false;
	try {
    // Create a temporary table and do a "batch" insert of args into the table.
    // 
    MTPRODUCTCATALOGEXECLib::IMTCollectionPtr col(pCol);
    MTPRODUCTCATALOGEXECLib::IMTGroupSubscriptionPtr gsub(pGroupSub);
    MTPRODUCTCATALOGEXECLib::IMTProgressPtr progress(pProgress);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
    wstring wstrDBType = rowset->GetDBType() ;
    BOOL isOracle = (wcscmp(wstrDBType.c_str(), ORACLE_DATABASE_TYPE) == 0);

		rowset->SetQueryTag("__CREATE_UNSUBSCRIBE_BATCH_TABLE__");
    rowset->Execute();

    _bstr_t query;
    
    DATE now = GetMTOLETime();

    // Number of group subscriptions
    long size = col->GetCount();

    // Reserve audit id batch and get the next audit id.
 		MetraTech_DataAccess::IIdGenerator2Ptr idAuditGenerator = SubscriptionIdGenerator::GetAuditIdGenerator();

    MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtx);
    long lAccountId = pContext->AccountID;

    // Do our inserts in groups of 100 (seems to amortize the insert cost pretty well).
    for(int i=1;i<=size;i++) 
    {

      if (isOracle && (i%100) == 1) query = "begin\n";
      MTPRODUCTCATALOGEXECLib::IMTGSubMemberPtr memberPtr =  col->GetItem(i);
      QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
      pQueryAdapter->Init(CONFIG_DIR);
      pQueryAdapter->SetQueryTag(L"__INSERT_UNSUBSCRIBE_BATCH_ARGS__");
			pQueryAdapter->AddParam(L"%%ID_ACC%%", _variant_t(memberPtr->GetAccountID())) ;
			pQueryAdapter->AddParam(L"%%ID_PO%%", _variant_t(gsub->ProductOfferingID)) ;
			pQueryAdapter->AddParam(L"%%ID_GROUP%%", _variant_t(gsub->GetGroupID())) ;
      pQueryAdapter->AddParam(L"%%VT_START%%", _variant_t(memberPtr->GetStartDate(), VT_DATE)) ;
      pQueryAdapter->AddParam(L"%%VT_END%%", _variant_t(memberPtr->GetEndDate(), VT_DATE)) ;
      pQueryAdapter->AddParam(L"%%TT_NOW%%", _variant_t(now, VT_DATE)) ;
			pQueryAdapter->AddParam(L"%%ID_GSUB_CORP%%", _variant_t(gsub->CorporateAccount));

      // Add audit events
      pQueryAdapter->AddParam(L"%%ID_AUDIT%%", _variant_t(idAuditGenerator->NextId)) ;
      pQueryAdapter->AddParam(L"%%ID_EVENT%%", _variant_t(long(AuditEventsLib::AUDITEVENT_GSUB_MEMBER_UNSUBSCRIBE))) ;
      pQueryAdapter->AddParam(L"%%ID_USERID%%", _variant_t(lAccountId)) ;
      pQueryAdapter->AddParam(L"%%ID_ENTITYTYPE%%", _variant_t(long(AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT))) ;

      query += pQueryAdapter->GetQuery();

      if((i%100) == 0)
      {
        rowset->Clear();
        if (isOracle) query += "\nend;\n";
        rowset->SetQueryString(query);
        rowset->Execute();
        query = L"";
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

    // Now execute batch unsubscribe stuff itself
    rowset->Clear();
    rowset->SetQueryTag(L"__UNSUBSCRIBE_BATCH__");
    rowset->Execute();

    rowset->Clear();
    rowset->SetQueryTag(L"__GET_UNSUBSCRIBE_BATCH_ERRORS__");
    rowset->Execute();
    
    // We get back HRESULTs from the query, resolve them to a description
    ROWSETLib::IMTSQLRowsetPtr errorRs(pErrorRs);
    errorRs->InitDisconnected();
    errorRs->AddColumnDefinition("id_acc","int32",4);
    errorRs->AddColumnDefinitionByType("accountname",adBSTR,256);
    errorRs->AddColumnDefinitionByType("description",adVarChar,256);
    errorRs->OpenDisconnected();

    while(!bool(rowset->RowsetEOF))
		{
      anyErrors=true;
      _com_error e = MTSourceInfo(__FILE__, __LINE__).CreateComError(IID_IMTSubscriptionWriter, (HRESULT) rowset->GetValue("status"));
      errorRs->AddRow();
			errorRs->AddColumnData("id_acc",rowset->GetValue("id_acc"));
			errorRs->AddColumnData("accountname",rowset->GetValue("accountname"));
			errorRs->AddColumnData("description",(_variant_t)e.Description());
			rowset->MoveNext();
    }

    rowset->Clear();
    rowset->SetQueryTag(L"__DROP_UNSUBSCRIBE_BATCH_TABLE__");
    rowset->Execute();
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
  if(!anyErrors)
  {
    context.Complete();
  }
	return S_OK;
}

static void InsertAccountState(ROWSETLib::IMTSQLRowsetPtr rowset, MTACCOUNTSTATESLib::IMTStatePtr state, _bstr_t debugparam)
{
  rowset->Clear();
  rowset->SetQueryTag("__INSERT_ACCOUNT_STATE_SUBSCRIPTION_RULE__");
  rowset->AddParamIfFound(L"%%DEBUG%%", debugparam);
  rowset->AddParam(L"%%ACCOUNT_STATE%%", _variant_t(state->Name));
  rowset->AddParam(L"%%CAN_SUBSCRIBE%%", _variant_t(VARIANT_TRUE == state->GetBusinessRuleValue("subscribe") ? 1L : 0L));
  if(debugparam.length() == 0)
  {
    MTPRODUCTCATALOGEXECLib::IMTDDLWriterPtr ddlwriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTDDLWriter));
    ASSERT(ddlwriter != NULL);
    ddlwriter->ExecuteStatement(rowset->GetQueryString());
  }
  else
  {
   rowset->Execute();
  }
}

static void InsertAccountStates(ROWSETLib::IMTSQLRowsetPtr rowset, _bstr_t debug)
{
  MTACCOUNTSTATESLib::IMTAccountStateMetaDataPtr states(__uuidof(MTACCOUNTSTATESLib::MTAccountStateMetaData));
  states->Initialize();
  InsertAccountState(rowset, states->PendingActiveApproval, debug);
  InsertAccountState(rowset, states->Active, debug);
  InsertAccountState(rowset, states->Suspended, debug);
  InsertAccountState(rowset, states->PendingFinalBill, debug);
  InsertAccountState(rowset, states->Closed, debug);
  InsertAccountState(rowset, states->Archived, debug);
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionWriter::AddAccountToGroupSubBatch2(IMTSessionContext*    apCtx,
                                                               IMTGroupSubscription* pGroupSub,
                                                               IMTCollection*        pCol,  // Collection of MTGSubMembers
                                                               IMTProgress*          pProgress,
                                                               VARIANT_BOOL*         pDateModified,
                                                               IMTSQLRowset*         pErrorRs)
{
  MTPRODUCTCATALOGEXECLib::IMTGroupSubscriptionPtr gsub(pGroupSub);
  MTPRODUCTCATALOGEXECLib::IMTCollectionPtr        col(pCol);

  MTObjectCollection<MTPRODUCTCATALOGLib::IMTSubInfo> grpSubs;

  HRESULT hr   = S_OK;
  int     size = col->GetCount();
  for(int i = 1; i <= size; i++) 
  {
    MTPRODUCTCATALOGEXECLib::IMTGSubMemberPtr memberPtr = col->GetItem(i);
    MTPRODUCTCATALOGLib::IMTSubInfoPtr        subInfo;

    hr = subInfo.CreateInstance("MTProductCatalog.MTSubInfo");
    if (FAILED(hr))
      throw _com_error(hr);

    subInfo->PutAll(memberPtr->GetAccountID(),
                    gsub->CorporateAccount,
                    gsub->ID,
                    memberPtr->GetStartDate(),
                    MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE,
                    memberPtr->GetEndDate(),
                    MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE,
                    gsub->ProductOfferingID,
                    VARIANT_TRUE,
                    gsub->GroupID);

    grpSubs.Add(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSubInfo*>(subInfo.GetInterfacePtr()));
  }

  MTPRODUCTCATALOGEXECLib::IMTCollectionPtr pGrpSubs = grpSubs.Detach();

  hr = SubscribeToGroups(apCtx,
                         reinterpret_cast<IMTCollection*>(pGrpSubs.GetInterfacePtr()),
                         pProgress,
                         pDateModified,
                         pErrorRs);

  return hr;
}

STDMETHODIMP CMTSubscriptionWriter::SubscribeToGroups(IMTSessionContext*    apCtx,
                                                      IMTCollection*        pCol,  // Collection of MTSubInfo
                                                      IMTProgress*          pProgress,
                                                      VARIANT_BOOL*         pDateModified,
                                                      IMTSQLRowset*         pErrorRs)
{
  MTAutoContext context(m_spObjectContext);
  bool          anyErrors = false;

  BOOL bDebug = PCCache::GetDebugTempTables();

  try
  {
    _bstr_t sTableCreationDebugParam = "";
    _bstr_t sTableDebugParam = "";
    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    wstring wstrDBType = rowset->GetDBType() ;
    BOOL isOracle = (wcscmp(wstrDBType.c_str(), ORACLE_DATABASE_TYPE) == 0);

    if(!bDebug && !isOracle)
    {
      sTableCreationDebugParam = "tempdb..#";
      sTableDebugParam = "#";

    }

	// Put info about account states into the database so we can check
    // business rules around this.
    rowset->SetQueryTag(L"__CREATE_ACCOUNT_STATE_SUBSCRIPTION_RULE_TABLE__");
    rowset->AddParamIfFound(L"%%TEMPDEBUG%%", sTableCreationDebugParam);
    rowset->AddParamIfFound(L"%%DEBUG%%", sTableDebugParam);

    if(bDebug)
    {
      //if we are in debug mode, we don't want to roll back
      //table creations, hence we use DDLWriter to execute those queries outside of DTC
      MTPRODUCTCATALOGEXECLib::IMTDDLWriterPtr ddlwriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTDDLWriter));
      ASSERT(ddlwriter != NULL);
      ddlwriter->ExecuteStatement(rowset->GetQueryString());
    }
    else
    {
      rowset->Execute();
    }
    
    InsertAccountStates(rowset, sTableDebugParam);

    MTPRODUCTCATALOGEXECLib::IMTCollectionPtr col(pCol);
    MTPRODUCTCATALOGEXECLib::IMTProgressPtr progress(pProgress);
		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtx);

    // Create a temporary table and do a "batch" insert of args into the table.
    //
    rowset->Clear();
    rowset->SetQueryTag("__CREATE_SUBSCRIBE_TO_GROUP_BATCH_TABLE__");
    rowset->AddParamIfFound(L"%%TEMPDEBUG%%", sTableCreationDebugParam);
    rowset->AddParamIfFound(L"%%DEBUG%%", sTableDebugParam);

    if(bDebug)
    {
      MTPRODUCTCATALOGEXECLib::IMTDDLWriterPtr ddlwriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTDDLWriter));
      ASSERT(ddlwriter != NULL);
      ddlwriter->ExecuteStatement(rowset->GetQueryString());
    }
    else
    {
      rowset->Execute();
    }
    

    _bstr_t query;
    DATE now = GetMTOLETime();
    long lAccountId = pContext->AccountID;
    long j = 0;
    long size = col->GetCount();


    MetraTech_DataAccess::IIdGenerator2Ptr idAuditGenerator = SubscriptionIdGenerator::GetAuditIdGenerator();

	for(long i = 1; i <= size; i++) 
    {
	  MTPRODUCTCATALOGLib::IMTSubInfoPtr memberPtr =  col->GetItem(i);

	  if (isOracle && j == 0) 
		query = "begin\n";

      if(memberPtr->IsGroupSub)
      {
        QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
        pQueryAdapter->Init(CONFIG_DIR);
        pQueryAdapter->SetQueryTag(L"__INSERT_SUBSCRIBE_TO_GROUP_BATCH_ARGS__");
        pQueryAdapter->AddParamIfFound(L"%%DEBUG%%", sTableDebugParam);
        pQueryAdapter->AddParam(L"%%ID_PO%%", _variant_t(memberPtr->ProdOfferingID));
        pQueryAdapter->AddParam(L"%%ID_GROUP%%", _variant_t(memberPtr->GroupSubID)) ;
        pQueryAdapter->AddParam(L"%%ID_ACC%%", _variant_t(memberPtr->AccountID)) ;
        pQueryAdapter->AddParam(L"%%VT_START%%", _variant_t(memberPtr->SubsStartDate, VT_DATE)) ;
        pQueryAdapter->AddParam(L"%%VT_END%%", _variant_t(memberPtr->SubsEndDate, VT_DATE)) ;
        pQueryAdapter->AddParam(L"%%TT_NOW%%", _variant_t(now, VT_DATE)) ;
        pQueryAdapter->AddParam(L"%%ID_GSUB_CORP%%", _variant_t(memberPtr->CorporateAccountID));
        pQueryAdapter->AddParam(L"%%ID_AUDIT%%", _variant_t(idAuditGenerator->NextIdForImportExport)) ;
        pQueryAdapter->AddParam(L"%%ID_EVENT%%", _variant_t(long(AuditEventsLib::AUDITEVENT_GSUB_MEMBER_ADD))) ;
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
        if(bDebug)
        {
          MTPRODUCTCATALOGEXECLib::IMTDDLWriterPtr ddlwriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTDDLWriter));
          ASSERT(ddlwriter != NULL);
          ddlwriter->ExecuteStatement(rowset->GetQueryString());
        }
        else
        {
          rowset->Execute();
        }
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
      if(bDebug)
      {
        MTPRODUCTCATALOGEXECLib::IMTDDLWriterPtr ddlwriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTDDLWriter));
        ASSERT(ddlwriter != NULL);
        ddlwriter->ExecuteStatement(rowset->GetQueryString());
      }
      else
      {
        rowset->Execute();
      }
      query = L"";
      if(progress != NULL)
      {
        progress->SetProgress(size, size);
      }
    }

    // Now execute batch subscribe stuff
//     rowset->Clear();
//     rowset->SetQueryTag(L"__EXECUTE_SUBSCRIBE_TO_GROUP_BATCH__");
//     rowset->AddParam(L"%%DEBUG%%", sTableDebugParam);

//     //Set corporate account business rule
    bool bSameCorpEnforced = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE;

	  // Set ProdOff Allow Account PO Currency Mismatch business rule, 
    bool bAllowAccountPOCurrencyMismatch1 = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch) == VARIANT_TRUE;

  // Set ProdOff Allow Multiple PI SubscriptionRCNRC business rule, ProdOff_AllowMultiplePISubscriptionRCNRC
    bool bAllowMultiplePISubscriptionRCNRC1 = PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowMultiplePISubscriptionRCNRC) == VARIANT_TRUE;

//     rowset->AddParam(L"%%CORP_BUSINESS_RULE_ENFORCED%%", _variant_t((long)bSameCorpEnforced));
//     rowset->Execute();
    rowset->Clear();
		rowset->InitializeForStoredProc("SubscribeBatchGroupSub");
		rowset->AddInputParameterToStoredProc (	"tmp_subscribe_batch", MTTYPE_W_VARCHAR, INPUT_PARAM, _bstr_t(sTableDebugParam) + _bstr_t(L"tmp_subscribe_batch"));
		rowset->AddInputParameterToStoredProc (	"tmp_account_state_rules", MTTYPE_W_VARCHAR, INPUT_PARAM, _bstr_t(sTableDebugParam) + _bstr_t(L"tmp_account_state_rules"));
		rowset->AddInputParameterToStoredProc (	"corp_business_rules_enforced", MTTYPE_INTEGER, INPUT_PARAM, _variant_t((long)bSameCorpEnforced));
		rowset->AddInputParameterToStoredProc (	"dt_now", MTTYPE_DATE, INPUT_PARAM, ::GetMTOLETime());  
		rowset->AddInputParameterToStoredProc (	"allow_acc_po_curr_mismatch", MTTYPE_INTEGER, INPUT_PARAM, _variant_t((long)bAllowAccountPOCurrencyMismatch1));
        rowset->AddInputParameterToStoredProc (	"allow_multiple_pi_sub_rcnrc", MTTYPE_INTEGER, INPUT_PARAM, _variant_t((long)bAllowMultiplePISubscriptionRCNRC1));

		rowset->ExecuteStoredProc();

    rowset->Clear();
    rowset->SetQueryTag(L"__GET_SUBSCRIBE_TO_GROUP_BATCH_ERRORS__");
    rowset->AddParamIfFound(L"%%DEBUG%%", sTableDebugParam);
    rowset->Execute();

    // We get back HRESULTs from the query, resolve them to a description
    ROWSETLib::IMTSQLRowsetPtr errorRs(pErrorRs);
    errorRs->InitDisconnected();
    errorRs->AddColumnDefinition("id_acc","int32",4);
    errorRs->AddColumnDefinitionByType("accountname",adBSTR, 256);
    errorRs->AddColumnDefinitionByType("description",adVarChar,256);
    errorRs->OpenDisconnected();

    while(!bool(rowset->RowsetEOF))
    {
      anyErrors = true;
      _com_error e = MTSourceInfo(__FILE__, __LINE__).CreateComError(IID_IMTSubscriptionWriter, (HRESULT) rowset->GetValue("status"));
      errorRs->AddRow();
      errorRs->AddColumnData("id_acc",rowset->GetValue("id_acc"));
      errorRs->AddColumnData("accountname",rowset->GetValue("accountname"));
      errorRs->AddColumnData("description",(_variant_t)e.Description());
      rowset->MoveNext();
    }
    //move it back to beginning so that a client doesn't have to
    if(anyErrors == true)
      errorRs->MoveFirst();


    if(bDebug	== false)
    {
      rowset->Clear();
      rowset->SetQueryTag(L"__DROP_SUBSCRIBE_TO_GROUP_BATCH_TABLE__");
      rowset->Execute();

      rowset->Clear();
      rowset->SetQueryTag(L"__DROP_ACCOUNT_STATE_SUBSCRIPTION_RULE_TABLE__");
      rowset->Execute();
    }
  }
  catch(_com_error& err)
  {
    return ReturnComError(err);
  }
  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTSubscriptionWriter::SubscribeAccounts(IMTSessionContext*    apCtx,
                                                      IMTCollection*        pCol,  // Collection of MTSubInfo
                                                      IMTProgress*          pProgress,
                                                      VARIANT_BOOL*         pDateModified,
                                                      IMTSQLRowset*         pErrorRs)
{
  MTAutoContext context(m_spObjectContext);
  bool anyErrors = false;
  BOOL bDebug = PCCache::GetDebugTempTables();
  
  try
  {
    _bstr_t sTableCreationDebugParam = "";
    _bstr_t sTableDebugParam = "";
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    
    wstring wstrDBType = rowset->GetDBType() ;
    BOOL isOracle = (wcscmp(wstrDBType.c_str(), ORACLE_DATABASE_TYPE) == 0);
    
    if(!bDebug && !isOracle)
    {
      sTableCreationDebugParam = "tempdb..#";
      sTableDebugParam = "#";
    }

    // Put info about account states into the database so we can check
    // business rules around this.
    rowset->SetQueryTag(L"__CREATE_ACCOUNT_STATE_SUBSCRIPTION_RULE_TABLE__");
    rowset->AddParamIfFound(L"%%TEMPDEBUG%%", sTableCreationDebugParam);
    rowset->AddParamIfFound(L"%%DEBUG%%", sTableDebugParam);

    if(bDebug)
    {
      //if we are in debug mode, we don't want to roll back
      //table creations, hence we use DDLWriter to execute those queries outside of DTC
      MTPRODUCTCATALOGEXECLib::IMTDDLWriterPtr ddlwriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTDDLWriter));
      ASSERT(ddlwriter != NULL);
      ddlwriter->ExecuteStatement(rowset->GetQueryString());
    }
    else
    {
      rowset->Execute();
    }
    InsertAccountStates(rowset, sTableDebugParam);

    MTPRODUCTCATALOGEXECLib::IMTCollectionPtr col(pCol);
    MTPRODUCTCATALOGEXECLib::IMTProgressPtr progress(pProgress);
		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtx);

    // Create a temporary table and do a "batch" insert of args into the table.
    // 
    rowset->Clear();
    rowset->SetQueryTag("__CREATE_SUBSCRIBE_INDIVIDUAL_BATCH_TABLE__");
    rowset->AddParamIfFound(L"%%TEMPDEBUG%%", sTableCreationDebugParam);
    rowset->AddParamIfFound(L"%%DEBUG%%", sTableDebugParam);
    if(bDebug)
    {
      MTPRODUCTCATALOGEXECLib::IMTDDLWriterPtr ddlwriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTDDLWriter));
      ASSERT(ddlwriter != NULL);
      ddlwriter->ExecuteStatement(rowset->GetQueryString());
    }
    else
    {
      rowset->Execute();
    }
    
    _bstr_t query;

	_variant_t vtNULL;
	vtNULL.vt = VT_NULL;

    DATE min_time = getMinMTOLETime();

    _bstr_t bstr_Y = L"'Y'";
    _bstr_t bstr_N = L"'N'";
    long lAccountId = pContext->AccountID;

    if (isOracle)
      query = "begin\n";

    long j = 0;
    long size = col->GetCount();

		MetraTech_DataAccess::IIdGenerator2Ptr idSubGenerator = SubscriptionIdGenerator::Get();

		MetraTech_DataAccess::IIdGenerator2Ptr idAuditGenerator = SubscriptionIdGenerator::GetAuditIdGenerator();

    for(long i = 1; i <= size; i++) 
    {
      MTPRODUCTCATALOGLib::IMTSubInfoPtr memberPtr =  col->GetItem(i);

      if(!(memberPtr->IsGroupSub))
      {
        QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
        pQueryAdapter->Init(CONFIG_DIR);
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
      if((j % 100) == 0)
      {
        rowset->Clear();
        if (isOracle)
          query += "\nend;\n";
        rowset->SetQueryString(query);
        if(bDebug)
        {
          MTPRODUCTCATALOGEXECLib::IMTDDLWriterPtr ddlwriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTDDLWriter));
          ASSERT(ddlwriter != NULL);
          ddlwriter->ExecuteStatement(rowset->GetQueryString());
        }
        else
        {
          rowset->Execute();
        }
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
      if(bDebug)
      {
        MTPRODUCTCATALOGEXECLib::IMTDDLWriterPtr ddlwriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTDDLWriter));
        ASSERT(ddlwriter != NULL);
        ddlwriter->ExecuteStatement(rowset->GetQueryString());
      }
      else
      {
        rowset->Execute();
      }
      query = L"";
      if(progress != NULL)
      {
        progress->SetProgress(size, size);
      }
    }

    long languageID;
    HRESULT hr = pContext->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

_bstr_t sCURRENCYUPDATESTATUS = "";
sCURRENCYUPDATESTATUS=" 1=1 ";

		// Check whether ProdOff_AllowAccountPOCurrencyMismatch is enabled, if yes then don't update the status 
    if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch ))
		{
			sCURRENCYUPDATESTATUS=" 1=0 "; 
		}

_bstr_t sCONFLICTINGPINOTALLOWED = "";
sCONFLICTINGPINOTALLOWED=" 1=1 ";

   // Check whether ProdOff_AllowMultiplePISubscriptionRCNRC is enabled, if yes then don't update the status   
    if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowMultiplePISubscriptionRCNRC ))
		{
			sCONFLICTINGPINOTALLOWED=" 1=0 "; 
		}

    
    // Now execute batch subscribe stuff
    rowset->Clear();
    rowset->SetQueryTag(L"__EXECUTE_SUBSCRIBE_INDIVIDUAL_ACCOUNTS__");
    rowset->AddParamIfFound(L"%%DEBUG%%", sTableDebugParam) ;
    rowset->AddParam(L"%%ID_LANG%%", _variant_t(languageID));
    rowset->AddParam(L"%%CURRENCYUPDATESTATUS%%", sCURRENCYUPDATESTATUS);
    rowset->AddParam(L"%%CONFLICTINGPINOTALLOWED%%", sCONFLICTINGPINOTALLOWED);

	rowset->Execute();

    rowset->Clear();
    rowset->SetQueryTag(L"__GET_SUBSCRIBE_INDIVIDUAL_BATCH_ERRORS__");
    rowset->AddParamIfFound(L"%%DEBUG%%", sTableDebugParam) ;
    rowset->Execute();

    // We get back HRESULTs from the query, resolve them to a description
    ROWSETLib::IMTSQLRowsetPtr errorRs(pErrorRs);
    errorRs->InitDisconnected();
    errorRs->AddColumnDefinition("id_acc","int32",4);
    errorRs->AddColumnDefinitionByType("accountname",adBSTR,256);
    errorRs->AddColumnDefinitionByType("description",adVarChar,256);
    errorRs->OpenDisconnected();

    while(!bool(rowset->RowsetEOF))
    {
      anyErrors = true;
      errorRs->AddRow();
      errorRs->AddColumnData("id_acc",rowset->GetValue("id_acc"));
      errorRs->AddColumnData("accountname",rowset->GetValue("accountname"));
      _com_error e = MTSourceInfo(__FILE__, __LINE__).CreateComError(IID_IMTSubscriptionWriter, (HRESULT) rowset->GetValue("status"));
      errorRs->AddColumnData("description",(_variant_t)e.Description());
      rowset->MoveNext();
    }
	
    if(bDebug	== false)
    {
      rowset->Clear();
      rowset->SetQueryTag(L"__DROP_SUBSCRIBE_INDIVIDUAL_BATCH_TABLE__");
      rowset->Execute();

      rowset->Clear();
      rowset->SetQueryTag(L"__DROP_ACCOUNT_STATE_SUBSCRIPTION_RULE_TABLE__");
      rowset->Execute();
    }
  }
  catch(_com_error& err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}
