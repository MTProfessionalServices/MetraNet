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
* $Header: MTSubscriptionWriter.h, 19, 10/31/2002 12:28:58 PM, David Blair$
* 
***************************************************************************/

#ifndef __MTSUBSCRIPTIONWRITER_H_
#define __MTSUBSCRIPTIONWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTSubscriptionWriter
class ATL_NO_VTABLE CMTSubscriptionWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTSubscriptionWriter, &CLSID_MTSubscriptionWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTSubscriptionWriter, &IID_IMTSubscriptionWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTSubscriptionWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTSUBSCRIPTIONWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTSubscriptionWriter)

BEGIN_COM_MAP(CMTSubscriptionWriter)
	COM_INTERFACE_ENTRY(IMTSubscriptionWriter)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTSubscriptionWriter
public:
  STDMETHOD(SubscribeBatch)(IMTSessionContext* apCtx,long aProductID,IMTPCTimeSpan* pTimeSpan,IMTCollection* pCol,IMTProgress* pProgress,VARIANT_BOOL* pDateModified,IMTSQLRowset* errorRs);
	STDMETHOD(DeleteSubscription)(/*[in]*/ IMTSessionContext* apCTX, /*[in]*/ IMTSubscriptionBase* pSubBase);
	STDMETHOD(AddAccountToGroupSubBatch)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTGroupSubscription* pGroupSub,/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress,VARIANT_BOOL* pDateModified,IMTSQLRowset* errorRs);
	STDMETHOD(DeleteMemberBatch)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTGroupSubscription* pGroupSub,/*[in]*/ IMTCollection* pCol,IMTProgress* pProgress,/*[out,retval]*/ IMTRowSet** ppRowset);
	STDMETHOD(DeleteMember)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTGroupSubscription* pGroupSub,/*[in]*/ long aAccountID, /*[in]*/ VARIANT subStartDate);
	STDMETHOD(ModifyMembershipBatch)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTGroupSubscription* pGroupSub,/*[in]*/ IMTCollection* pCol,IMTProgress* pProgress,VARIANT_BOOL* pDateModified,/*[out,retval]*/ IMTRowSet** ppRowset);
	STDMETHOD(ModifyMembership)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTGroupSubscription* pGroupSub,/*[in]*/ IMTGSubMember* pSubMember,VARIANT_BOOL* pDateModified);
	STDMETHOD(UpdateGroupSub)(IMTSessionContext* apCtx,IMTGroupSubscription* pGroupSub,VARIANT_BOOL* pDateModified);
	STDMETHOD(AddAccountToGroupSub)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTGroupSubscription* pGroupSub,/*[in]*/ IMTGSubMember* pGsubMember,VARIANT_BOOL* pDateModified);
	STDMETHOD(SaveNewGroupSub)(/*[in]*/ IMTSessionContext* apCtx, /*[in]*/ IMTGroupSubscription* pGroupSub,VARIANT_BOOL* pDateModified);
	STDMETHOD(BulkSubscriptionChange)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aOldPO_id,/*[in]*/ long aNewPO_id,/*[in]*/ VARIANT vtDate,VARIANT_BOOL bNextBillingCycle);
	STDMETHOD(SaveNew)(/*[in]*/ IMTSessionContext* apCtxt, IMTSubscription *pSub, VARIANT_BOOL* pDateModified);
	STDMETHOD(UpdateExisting)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTSubscription* pSub,VARIANT_BOOL* pDateModified);
	STDMETHOD(RemoveICBMapping)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPI_ID, /*[in]*/ long aPtdID,/*[in]*/ IMTSubscriptionBase* pSub);
	STDMETHOD(AddICBPriceListMapping)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemID,/*[in]*/ long aParamTblID,/*[in]*/ IMTSubscriptionBase* pSub);
	STDMETHOD(SetChargeAccount)(/*[in]*/ IMTSessionContext* apCtx, /*[in]*/ IMTGroupSubscription* pGroupSub, /*[in]*/ long aPrcItemInstanceID, /*[in]*/ long aAccountID, /*[in]*/ DATE aStartDate, /*[in]*/ DATE aEndDate);
	STDMETHOD(SetRecurringChargeAccounts)(/*[in]*/ IMTSessionContext* apCtx, /*[in]*/ IMTGroupSubscription* pGroupSub, /*[in]*/ long aAccountID, /*[in]*/ DATE aStartDate, /*[in]*/ DATE aEndDate);
	STDMETHOD(SetUnitValue)(/*[in]*/ IMTSessionContext* apCtx, /*[in]*/ IMTSubscriptionBase* pSub, /*[in]*/ long aPrcItemInstanceID, /*[in]*/ DECIMAL aUnitValue, /*[in]*/ DATE aStartDate, /*[in]*/ DATE aEndDate);
	STDMETHOD(UpdateUnitValue)(/*[in]*/ IMTSessionContext* apCtx, /*[in]*/ IMTSubscriptionBase* pSub, /*[in]*/ long aPrcItemInstanceID, /*[in]*/ DECIMAL aUnitValue, /*[in]*/ DATE aStartDate, /*[in]*/ DATE aEndDate);
	STDMETHOD(DeleteUnitValue)(/*[in]*/ IMTSessionContext* apCtx, /*[in]*/ IMTSubscriptionBase* pSub, /*[in]*/ long aPrcItemInstanceID, /*[in]*/ DATE aStartDate, /*[in]*/ DATE aEndDate);
  STDMETHOD(DeleteGroupSubscription)(/*[in]*/ IMTSessionContext *apCTX, /*[in]*/ IMTSubscriptionBase *pSubBase);
	STDMETHOD(UnsubscribeMemberBatch)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTGroupSubscription* pGroupSub,/*[in]*/ IMTCollection* pCol,IMTProgress* pProgress,/*[in]*/ IMTSQLRowset* errorRs);
	STDMETHOD(AddAccountToGroupSubBatch2)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTGroupSubscription* pGroupSub,/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress,/*[out]*/ VARIANT_BOOL* pDateModified,/*[in]*/ IMTSQLRowset* errorRs);
	STDMETHOD(SubscribeToGroups)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress,/*[out]*/ VARIANT_BOOL* pDateModified,/*[in]*/ IMTSQLRowset* errorRs);
	STDMETHOD(SubscribeAccounts)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress,/*[out]*/ VARIANT_BOOL* pDateModified,/*[in]*/ IMTSQLRowset* errorRs);
  STDMETHOD(FinalizeUnitValue)(/*[in]*/ IMTSessionContext* apCtx, /*[in]*/ IMTSubscriptionBase* pSub);
protected:
	void CheckAccountState(IMTSessionContext *apCtx,
																							long accountID,DATE aStartDate);
  void ResolveGenericSubError(HRESULT hr,MTPRODUCTCATALOGLib::IMTSubscriptionBasePtr subBasePtr);

	void EnforceDayGranularity(DATE& aStartDate, DATE& aEndDate);

	bool ValidateUDRCUnitValues(long groupID);
	bool ValidatePerSubscriptionChargeAccounts(long groupID);

};

#endif //__MTSUBSCRIPTIONWRITER_H_
