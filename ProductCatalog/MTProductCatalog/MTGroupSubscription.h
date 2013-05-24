	
// MTGroupSubscription.h : Declaration of the CMTGroupSubscription

#ifndef __MTGROUPSUBSCRIPTION_H_
#define __MTGROUPSUBSCRIPTION_H_

#include "resource.h"       // main symbols
#include "MTSubscriptionBase.h"

/////////////////////////////////////////////////////////////////////////////
// CMTGroupSubscription
class ATL_NO_VTABLE CMTGroupSubscription : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTGroupSubscription, &CLSID_MTGroupSubscription>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTGroupSubscription, &IID_IMTGroupSubscription, &LIBID_MTPRODUCTCATALOGLib>,
	public MTSubscriptionBase
{
public:
	CMTGroupSubscription()
	{
		SetSubscriptionKind();
		m_pUnkMarshaler = NULL;
	}

	~CMTGroupSubscription();

DECLARE_REGISTRY_RESOURCEID(IDR_MTGROUPSUBSCRIPTION)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

DEFINE_MT_PCBASE_METHODS
DEFINE_MT_PROPERTIES_BASE_METHODS
DEFINE_SUBSCRIPTION_BASE_METHODS


BEGIN_COM_MAP(CMTGroupSubscription)
	COM_INTERFACE_ENTRY(IMTPCBase)
	COM_INTERFACE_ENTRY(IMTSubscriptionBase)
	COM_INTERFACE_ENTRY(IMTGroupSubscription)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct();

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTGroupSubscription
public:
  STDMETHOD(put_SupportGroupOps)(VARIANT_BOOL newVal);
  STDMETHOD(get_SupportGroupOps)(VARIANT_BOOL* pVal);
	STDMETHOD(FindMember)(long aAccountID,DATE RefDate,IMTGSubMember** ppMember);
	STDMETHOD(DeleteMemberBatch)(/*[in]*/ IMTCollection* pCol,IMTProgress* pProgress,/*[out,retval]*/ ::IMTRowSet** ppRowset);
	STDMETHOD(DeleteMember)(/*[in]*/ long aAccountID, VARIANT subStartDate);
	STDMETHOD(ModifyMembershipBatch)(/*[in]*/ IMTCollection* pCol,IMTProgress* pProgress,VARIANT_BOOL* pDateModified,/*[out,retval]*/ ::IMTRowSet** ppRowset);
	STDMETHOD(ModifyMembership)(/*[in]*/ IMTGSubMember* pSubMember,VARIANT_BOOL* pDateModified);
	STDMETHOD(Membership)(/*[out, retval]*/ IMTGroupSubSlice** ppSlice);
	STDMETHOD(get_GroupID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_GroupID)(/*[in]*/ long newVal);
	STDMETHOD(AddAccountBatch)(/*[in]*/ IMTCollection* pCol,IMTProgress* pProgress,VARIANT_BOOL* pDateModified,VARIANT pTransaction,/*[out,retval]*/ ::IMTRowSet** ppRowset);
	STDMETHOD(AddAccount)(IMTGSubMember* pSubMember,VARIANT_BOOL* pDateModified);
	STDMETHOD(MembershipAtSystemDate)(/*[in]*/ DATE RefDate,/*[in]*/ DATE SystemDate,/*[out, reval]*/ IMTGroupSubSlice** ppSlice);
	STDMETHOD(MembershipNow)(/*[out, retval]*/ IMTGroupSubSlice** ppSlice);
	STDMETHOD(MemberShipAtDate)(/*[in]*/ DATE RefDate,IMTGroupSubSlice** ppSlice);
	STDMETHOD(get_DistributionAccount)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_DistributionAccount)(/*[in]*/ long newVal);
	STDMETHOD(get_ProportionalDistribution)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_ProportionalDistribution)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_CorporateAccount)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_CorporateAccount)(/*[in]*/ long newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
  STDMETHOD(put_HasRecurringCharges)(VARIANT_BOOL newVal);
  STDMETHOD(get_HasRecurringCharges)(VARIANT_BOOL* pVal);
  STDMETHOD(put_HasDiscounts)(VARIANT_BOOL newVal);
  STDMETHOD(get_HasDiscounts)(VARIANT_BOOL* pVal);
  STDMETHOD(put_HasPersonalRates)(VARIANT_BOOL newVal);
  STDMETHOD(get_HasPersonalRates)(VARIANT_BOOL* pVal);
	STDMETHOD(Save)(VARIANT_BOOL* pDateModified);
	// Get the account paying for a per-subscription recurring charge
	STDMETHOD(GetChargeAccount)(/*[in]*/ long aPrcItemInstanceID, /*[in]*/ DATE aEffDate, /*[out, retval]*/ long *apAccountID);
	// Set the account paying for a per-subscription recurring charge
	STDMETHOD(SetChargeAccount)(/*[in]*/ long aPrcItemInstanceID, /*[in]*/ long aAccountID, /*[in]*/ DATE aStartDate, /*[in]*/ DATE aEndDate);
	// Get the list of per-subscription recurring charges with the charged account
	STDMETHOD(GetRecurringChargeAccounts)(/*[in]*/ DATE aEffDate, /*[out, retval]*/ ::IMTSQLRowset **apAccounts);
	// Set the account paying for all per-subscription recurring charges
	STDMETHOD(SetRecurringChargeAccounts)(/*[in]*/ long aAccountID, /*[in]*/ DATE aStartDate, /*[in]*/ DATE aEndDate);
	// Get the list of per-subscription recurring charges with the charged account
	STDMETHOD(GetRecurringChargeAccountsFromMemory)(/*[out, retval]*/ ::IMTRowSet **apAccounts);
	STDMETHOD(UnsubscribeMemberBatch)(/*[in]*/ IMTCollection* pCol,IMTProgress* pProgress,/*[out,retval]*/ ::IMTRowSet** ppRowset);
	STDMETHOD(UnsubscribeMember)(/*[in]*/ IMTGSubMember* pSubMember);

	// Returns true if altering the member's start date
	// could affect the derived EBCR cycle
	STDMETHOD(WarnOnEBCRMemberStartDateChange)(/*[in]*/ IMTGSubMember* pSubMember, /*[out, retval]*/ VARIANT_BOOL *pVal);

	virtual void SetSubscriptionKind() { mSubKind = GroupSubscription; }

protected:
  void CheckAddToGroupSub();
  void CheckUpdateGroupSubMembership();

	// Only used before the object is persisted.
	std::map<long, TemporalProperty*> mRecurringChargeAccount;	
};

#endif //__MTGROUPSUBSCRIPTION_H_
