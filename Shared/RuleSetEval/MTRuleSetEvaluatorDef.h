	
// MTRuleSetEvaluator.h : Declaration of the CMTRuleSetEvaluator

#ifndef __MTRULESETEVALUATOR_H_
#define __MTRULESETEVALUATOR_H_

#include "resource.h"       // main symbols

#include <PropGenerator.h>

class IMTQueryAdapter;

/////////////////////////////////////////////////////////////////////////////
// CMTRuleSetEvaluator
class ATL_NO_VTABLE CMTRuleSetEvaluator : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTRuleSetEvaluator, &CLSID_MTRuleSetEvaluator>,
	public ISupportErrorInfo,
  public IDispatchImpl<::IMTRuleSetEvaluator, &IID_IMTRuleSetEvaluator, &LIBID_RULESETEVALLib>
{
public:
	CMTRuleSetEvaluator()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTRULESETEVALUATOR)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTRuleSetEvaluator)
	COM_INTERFACE_ENTRY(IMTRuleSetEvaluator)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTRuleSetEvaluator
public:
  STDMETHOD(Match)(::IMTSession * session, /*[out, retval]*/ VARIANT_BOOL * matched);
  STDMETHOD(Configure)(::IMTRuleSet * ruleset);

private:
	// engine to evaluate the rules
	PropGenerator mPropGen;

//	IMTQueryAdapter* mpQueryAdapter;
};

#endif //__MTRULESETEVALUATOR_H_
