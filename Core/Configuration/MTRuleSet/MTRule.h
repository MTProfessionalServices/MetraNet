// MTRule.h : Declaration of the CMTRule

#ifndef __MTRULE_H_
#define __MTRULE_H_

#include "resource.h"       // main symbols

#import <MTRuleSet.tlb>

///#include "Rule.h"
#include "MTActionSet.h"
#include "MTConditionSet.h"

/////////////////////////////////////////////////////////////////////////////
// CMTRule
class ATL_NO_VTABLE CMTRule : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTRule, &CLSID_MTRule>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTRule, &IID_IMTRule, &LIBID_MTRULESETLib>
{
public:
	CMTRule()
	{ }

	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTRULE)

DECLARE_GET_CONTROLLING_UNKNOWN()
DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTRule)
	COM_INTERFACE_ENTRY(IMTRule)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTRule
public:
	STDMETHOD(get_Conditions)(/*[out, retval]*/ IMTConditionSet * *pVal);
	STDMETHOD(put_Conditions)(/*[in]*/ IMTConditionSet * newVal);
	STDMETHOD(get_Actions)(/*[out, retval]*/ IMTActionSet * *pVal);
	STDMETHOD(put_Actions)(/*[in]*/ IMTActionSet * newVal);


	MTRULESETLib::IMTActionSetPtr mActionSet;
	MTRULESETLib::IMTConditionSetPtr mConditionSet;

	CComPtr<IUnknown> m_pUnkMarshaler;
};

#endif //__MTRULE_H_
