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
* $Header: MTRecurringCharge.h, 11, 10/17/2002 9:29:13 AM, David Blair$
* 
***************************************************************************/

#ifndef __MTRECURRINGCHARGE_H_
#define __MTRECURRINGCHARGE_H_

#include "resource.h"       // main symbols
#include "MTPriceableItem.h"

#include <set>

/////////////////////////////////////////////////////////////////////////////
// CMTRecurringCharge
class ATL_NO_VTABLE CMTRecurringCharge : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTRecurringCharge, &CLSID_MTRecurringCharge>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTRecurringCharge, &IID_IMTRecurringCharge, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPriceableItem
{
public:
	CMTRecurringCharge()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTRECURRINGCHARGE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTRecurringCharge)
	COM_INTERFACE_ENTRY(IMTRecurringCharge)
	COM_INTERFACE_ENTRY(IMTPriceableItem)
	COM_INTERFACE_ENTRY(IMTPCBase)
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

// IMTPriceableItem
public:
	DEFINE_MT_PRICABLE_ITEM_METHODS
	virtual void CopyNonBaseMembersTo(IMTPriceableItem* apTarget);

// IMTRecurringCharge
public:
	STDMETHOD(get_Cycle)(/*[out, retval]*/ IMTPCCycle* *pVal);
	STDMETHOD(get_FixedProrationLength)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_FixedProrationLength)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_ProrateOnRateChange)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_ProrateOnRateChange)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_ProrateOnDeactivation)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_ProrateOnDeactivation)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_ProrateOnActivation)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_ProrateOnActivation)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_ChargeInAdvance)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_ChargeInAdvance)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_ChargePerParticipant)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_ChargePerParticipant)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_UnitName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_UnitName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_IntegerUnitValue)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_IntegerUnitValue)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_MaxUnitValue)(/*[out, retval]*/ DECIMAL *pVal);
	STDMETHOD(put_MaxUnitValue)(/*[in]*/ DECIMAL newVal);
	STDMETHOD(get_MinUnitValue)(/*[out, retval]*/ DECIMAL *pVal);
	STDMETHOD(put_MinUnitValue)(/*[in]*/ DECIMAL newVal);
	STDMETHOD(AddUnitValueEnumeration)(/*[in]*/ DECIMAL newVal);
	STDMETHOD(RemoveUnitValueEnumeration)(/*[in]*/ DECIMAL newVal);
	STDMETHOD(GetUnitValueEnumerations)(/*[out,retval]*/ IMTCollection** apEnums);
	STDMETHOD(get_UnitValueEnumeration)(/*[out,retval]*/ IMTCollection** apEnums);
	STDMETHOD(ValidateUnitValue)(/*[in]*/ DECIMAL newVal);
	STDMETHOD(get_RatingType)(/*[out, retval]*/ MTUDRCRatingType *pVal);
	STDMETHOD(put_RatingType)(/*[in]*/ MTUDRCRatingType newVal);
  STDMETHOD(get_UnitDisplayName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_UnitDisplayName)(/*[in]*/ BSTR newVal);
  STDMETHOD(get_UnitDisplayNames)(/*[out, retval]*/ IDispatch **pVal);
	STDMETHOD(get_ProrateInstantly)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_ProrateInstantly)(/*[in]*/ VARIANT_BOOL newVal);

//CMTPCBase override
	virtual void OnSetSessionContext(IMTSessionContext* apSessionContext);

	struct DECIMAL_less : public std::binary_function<DECIMAL, DECIMAL, bool> 
	{
		bool operator()(const DECIMAL& x, const DECIMAL& y) const
		{
			
			return VARCMP_LT == VarDecCmp(const_cast<DECIMAL *> (&x), const_cast<DECIMAL *> (&y));
		}
	};

protected:

	// This predicate allows a priceable item to have configuration
	// parameters that turn various parameter tables "on" and "off".
	virtual bool IsParameterTableInUse(IMTParamTableDefinition* apParamTable);


private:
	std::set<DECIMAL, DECIMAL_less> mEnums;
};

#endif //__MTRECURRINGCHARGE_H_
