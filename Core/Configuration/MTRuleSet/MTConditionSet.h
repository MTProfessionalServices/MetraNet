// MTConditionSet.h : Declaration of the CMTConditionSet

#ifndef __MTCONDITIONSET_H_
#define __MTCONDITIONSET_H_

#include "resource.h"       // main symbols

///#include <ConditionSet.h>

#import <GenericCollection.tlb>
using GENERICCOLLECTIONLib::IMTCollection;

#include <MTObjectCollection.h>

#include <map>

/////////////////////////////////////////////////////////////////////////////
// CMTConditionSet
class ATL_NO_VTABLE CMTConditionSet : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTConditionSet, &CLSID_MTConditionSet>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTConditionSet, &IID_IMTConditionSet, &LIBID_MTRULESETLib>
{
public:
	CMTConditionSet()
	{ }

	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTCONDITIONSET)

DECLARE_GET_CONTROLLING_UNKNOWN()
DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTConditionSet)
	COM_INTERFACE_ENTRY(IMTConditionSet)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTConditionSet
public:

	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(get_Item)(/*[in]*/ VARIANT Index, /*[out,retval]*/ LPVARIANT pItem);
	STDMETHOD(get_NthItem)(/*[in]*/ VARIANT Index, long aN, /*[out,retval]*/ LPVARIANT pItem);
	//STDMETHOD(Add)(/*[in]*/ IMTAssignmentAction * pMyObj );
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal );

	STDMETHOD(Add)(/*[in]*/ IMTSimpleCondition * action);

private:
	MTObjectCollection<IMTSimpleCondition> mConditions;

	// map used to lookup objects by name
	typedef std::map<std::wstring, long> NameIndexMap;
	NameIndexMap mIndexMap;

	CComPtr<IUnknown> m_pUnkMarshaler;
};

#endif //__MTCONDITIONSET_H_
