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
#include "MTAncestorMgrWriter.h"
#include "PCCache.h"
#include <OdbcConnMan.h>
#include <OdbcConnection.h>

/////////////////////////////////////////////////////////////////////////////
class MTBatchMoveHelper : public MTAccountBatchHelper<MTYAACEXECLib::IMTAncestorMgrWriterPtr>
{
public:
  HRESULT PerformSingleOp(long aIndex,long &aFailedAccount);
  long mAncestor;
  DATE mStartDate;
};

HRESULT MTBatchMoveHelper::PerformSingleOp(long aIndex,long &aFailedAccount)
{
  // get the descendent
  long mDescendent = mColPtr->GetItem(aIndex);
  aFailedAccount = mDescendent;
  return mControllerClass->MoveAccount((MTYAACEXECLib::IMTSessionContext*)(IMTSessionContext*)(mSessionContext),
     mAncestor,mDescendent,mStartDate);
}


/////////////////////////////////////////////////////////////////////////////
// CMTAncestorMgrWriter

STDMETHODIMP CMTAncestorMgrWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAncestorMgrWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTAncestorMgrWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTAncestorMgrWriter::CanBePooled()
{
	return TRUE;
} 

void CMTAncestorMgrWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTAncestorMgrWriter::MoveAccount(IMTSessionContext* apCtxt, long aAncestor, long aDescendent, DATE StartDate)
{
	MTAutoContext ctx(m_spObjectContext);

  // Create an instance of the stage table binding.
	ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
	rs->Init("queries\\AccountCreation");

 	long status = 0;
	try
  {
     // Initialize materialized view manager on first use.
    if (mMVMPtr == NULL)
    {
      mMVMPtr = new MetraTech_DataAccess_MaterializedViews::IManagerPtr(__uuidof(MetraTech_DataAccess_MaterializedViews::Manager));
      mMVMPtr->Initialize();

      // Cache this result so that we don't need to do a COM interop each time.
      mIsMVSupportEnabled = mMVMPtr->GetIsMetraViewSupportEnabled() == VARIANT_TRUE ? true : false;

      // Prepare the base table bindings.
      if (mIsMVSupportEnabled)
      {
        mInsertDeltaTableName = mMVMPtr->GenerateDeltaInsertTableName(mBaseTableName.c_str());
        mDeleteDeltaTableName = mMVMPtr->GenerateDeltaDeleteTableName(mBaseTableName.c_str());
        mMVMPtr->AddInsertBinding(mBaseTableName.c_str(), mInsertDeltaTableName.c_str());
        mMVMPtr->AddDeleteBinding(mBaseTableName.c_str(), mDeleteDeltaTableName.c_str());

        // Create the temp delta tables.
        rs->ClearQuery();
        rs->SetQueryTag("__CREATE_ACCOUNT_DELTA_TABLE__");
        rs->AddParam("%%TABLE_NAME%%", mDeleteDeltaTableName.c_str());
        rs->Execute();

        rs->ClearQuery();
        rs->SetQueryTag("__CREATE_ACCOUNT_DELTA_TABLE__");
        rs->AddParam("%%TABLE_NAME%%", mInsertDeltaTableName.c_str());
        rs->Execute();
      }
    }

    // Do some materialized view preprocessing.
    if (mIsMVSupportEnabled)
    {
      // Prepare the delta delete table for materialized view update.
      rs->SetQueryTag("__UPDATE_ACCOUNT_DELTA_TABLE__");
      rs->AddParam("%%TABLE_NAME%%", mBaseTableName.c_str());
      rs->AddParam("%%DELTA_TABLE_NAME%%", mDeleteDeltaTableName.c_str());
      rs->AddParam("%%ID_ACC_LIST%%", aDescendent);
      rs->Execute();
    }

		string bRestictedToSameCorporation = 
			PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE ? "1" : "0";
    rs->ClearQuery();
		rs->InitializeForStoredProc("MoveAccount");
		rs->AddInputParameterToStoredProc("p_id_ancestor", MTTYPE_INTEGER, INPUT_PARAM, aAncestor);
		rs->AddInputParameterToStoredProc("p_id_descendent", MTTYPE_INTEGER, INPUT_PARAM, aDescendent);
		rs->AddInputParameterToStoredProc("p_dt_start", MTTYPE_DATE, INPUT_PARAM, StartDate);
		rs->AddInputParameterToStoredProc("p_enforce_same_corporation", MTTYPE_VARCHAR, INPUT_PARAM, bRestictedToSameCorporation.c_str());

		//_variant_t vtDateVal;
		//vtDateVal = GetMTOLETime();
		//wstring val;
		//FormatValueForDB(vtDateVal,false,val);

		rs->AddInputParameterToStoredProc("p_system_time", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime());

		rs->AddOutputParameterToStoredProc("status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rs->AddOutputParameterToStoredProc("p_id_ancestor_out",MTTYPE_INTEGER,OUTPUT_PARAM);
    rs->AddOutputParameterToStoredProc("p_ancestor_type", MTTYPE_VARCHAR, OUTPUT_PARAM);
    rs->AddOutputParameterToStoredProc("p_acc_type", MTTYPE_VARCHAR, OUTPUT_PARAM);
		rs->ExecuteStoredProc();
		status = rs->GetParameterFromStoredProc("status");

		if(status != 1)
    {
      if (status == MT_ANCESTOR_OF_INCORRECT_TYPE)
      {
         _bstr_t ancestor_type = rs->GetParameterFromStoredProc("p_ancestor_type");
         _bstr_t acc_type = rs->GetParameterFromStoredProc("p_acc_type");
         MT_THROW_COM_ERROR(MT_ANCESTOR_OF_INCORRECT_TYPE, (char *)acc_type, (char *)ancestor_type);
      }
      else
			  MT_THROW_COM_ERROR(status);
		}

    // audit
    char buffer[512];
    long origAnc =  rs->GetParameterFromStoredProc("p_id_ancestor_out");
    sprintf(buffer,"moved account %ld from %ld to %ld", aDescendent, origAnc, aAncestor);
    MTYAACEXECLib::IMTSessionContextPtr sessionCtxt(apCtxt);
    PCCache::GetAuditor()->FireEvent( AuditEventsLib::AUDITEVENT_ACCOUNT_UPDATE,
                                      sessionCtxt->AccountID,
                                      AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
                                      aDescendent,
                                      buffer);

    // 
    if (mIsMVSupportEnabled)
    {
      // Prepare the delta insert table for materialized view update.
      rs->ClearQuery();
      rs->SetQueryTag("__UPDATE_ACCOUNT_DELTA_TABLE__");
      rs->AddParam("%%TABLE_NAME%%", mBaseTableName.c_str());
      rs->AddParam("%%DELTA_TABLE_NAME%%", mInsertDeltaTableName.c_str());
      rs->AddParam("%%ID_ACC_LIST%%", aDescendent);
      rs->Execute();

      // Execute the matrerialized wiew update.
      // Create safe array of product view tables that were metered.
      SAFEARRAYBOUND sabound[1];
      sabound[0].lLbound = 0;
      sabound[0].cElements = 1;
      SAFEARRAY* pSA = SafeArrayCreate(VT_BSTR, 1, sabound);
      if (pSA == NULL)
        MT_THROW_COM_ERROR(L"Unable to create safe arrary for materialized view update trigger list.");

      // Try - Catch, to make sure safe arrays are cleaned up.
      bool bSALocked = false;
      try
      {
        // Set data to the contents of the safe array.
        BSTR HUGEP *pbstrNames;
        if (!::SafeArrayAccessData(pSA, (void**)&pbstrNames))
        {
          // All account moves affect t_dm_account.
          bSALocked = true;
          _bstr_t _bstrName(mBaseTableName.c_str());
          pbstrNames[0] = ::SysAllocString(_bstrName);
          ::SafeArrayUnaccessData(pSA);
          bSALocked = false;
        }
        else
           MT_THROW_COM_ERROR(L"Unable to access safe array trigger data.");

        // Get the update query to execute for all materialized views that changed.
        _bstr_t _bstrQueriesToExecute(mMVMPtr->GetMaterializedViewUpdateQuery(pSA));

        // Free safe array.
        ::SafeArrayDestroy(pSA);
        pSA = NULL;

        // Execute the queries.
        if (!!_bstrQueriesToExecute)
        {
          rs->ClearQuery();
          HRESULT hr = rs->SetQueryString(_bstrQueriesToExecute);
          if (FAILED(hr))
          {
            _com_error err(hr);
      			throw err;
          }

          rs->Execute();
        }

        // Truncate transactional delta tables.
        rs->ClearQuery();
        rs->SetQueryTag("__TRUNCATE_ACCOUNT_DELTA_TABLE__");
        rs->AddParam("%%TABLE_NAME%%", mInsertDeltaTableName.c_str());
        rs->Execute();

        rs->ClearQuery();
        rs->SetQueryTag("__TRUNCATE_ACCOUNT_DELTA_TABLE__");
        rs->AddParam("%%TABLE_NAME%%", mDeleteDeltaTableName.c_str());
        rs->Execute();
      }
      catch(...)
      {
        if (pSA)
        {
          if (bSALocked)
            ::SafeArrayUnaccessData(pSA);

          ::SafeArrayDestroy(pSA);
        }
        throw;
      }
    } // if (mIsMVSupportEnabled)
	}
	catch(_com_error& err)
  {
		return ReturnComError(err);
	}

	ctx.Complete();
	return S_OK;
}

STDMETHODIMP CMTAncestorMgrWriter::AddToHierarchy(IMTSessionContext* apCtxt,
                                                  long aAncestor, 
																									long aDescendent,
																									DATE aStartDate, DATE aEndDate)
{
	MTAutoContext ctx(m_spObjectContext);

	long status = 0;
	try {

		ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
		rs->Init("queries\\AccountCreation");
		rs->InitializeForStoredProc("AddAccToHierarchy");
		rs->AddInputParameterToStoredProc("p_id_ancestor", MTTYPE_INTEGER, INPUT_PARAM, aAncestor);
		rs->AddInputParameterToStoredProc("p_id_descendent", MTTYPE_INTEGER, INPUT_PARAM, aDescendent);
		rs->AddInputParameterToStoredProc("p_dt_start", MTTYPE_DATE, INPUT_PARAM, aStartDate);
		rs->AddInputParameterToStoredProc("p_dt_end", MTTYPE_DATE, INPUT_PARAM, aEndDate);

    _variant_t vtNULL;
    vtNULL.vt = VT_NULL;

		rs->AddInputParameterToStoredProc("p_acc_startdate", MTTYPE_DATE, INPUT_PARAM, vtNULL);
    rs->AddOutputParameterToStoredProc("ancestor_type", MTTYPE_VARCHAR, OUTPUT_PARAM);
    rs->AddOutputParameterToStoredProc("acc_type", MTTYPE_VARCHAR, OUTPUT_PARAM);
		rs->AddOutputParameterToStoredProc("status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rs->ExecuteStoredProc();

    _bstr_t ancestor_type, acc_type;
    ancestor_type = rs->GetParameterFromStoredProc("ancestor_type");
    acc_type = rs->GetParameterFromStoredProc("acc_type");
		status = rs->GetParameterFromStoredProc("status");

		if(status != 1) {
      switch (status)
      {
        case MT_ANCESTOR_OF_INCORRECT_TYPE :
          MT_THROW_COM_ERROR(MT_ANCESTOR_OF_INCORRECT_TYPE, (char *)acc_type, (char *)ancestor_type);

        default:MT_THROW_COM_ERROR(status);

      }
		}
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}

	ctx.Complete();
	return S_OK;
}

STDMETHODIMP CMTAncestorMgrWriter::MoveAccountBatch(IMTSessionContext* apCtxt,
                                                    long aAncestor,
                                                    IMTCollection *pCol,
                                                    IMTProgress *pProgress, 
                                                    DATE aStartDate,
                                                    IMTRowSet **ppErrors)
{
	try {
    MTBatchMoveHelper aBatchHelper;
    aBatchHelper.Init(m_spObjectContext,MTYAACEXECLib::IMTAncestorMgrWriterPtr(this),apCtxt);
    aBatchHelper.mAncestor = aAncestor;
    aBatchHelper.mStartDate = aStartDate;
    *ppErrors = reinterpret_cast<IMTRowSet*>(aBatchHelper.PerformBatchOperation(pCol,pProgress).Detach());
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
  return S_OK;
}
