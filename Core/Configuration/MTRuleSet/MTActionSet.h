// MTActionSet.h : Declaration of the CMTActionSet

#ifndef __MTACTIONSET_H_
#define __MTACTIONSET_H_

#include "resource.h"       // main symbols

///#include "ActionSet.h"
#include "MTAssignmentAction.h"

#import <GenericCollection.tlb>
using GENERICCOLLECTIONLib::IMTCollection;

#include <MTObjectCollection.h>

#include <map>

/////////////////////////////////////////////////////////////////////////////
// CMTActionSet
class ATL_NO_VTABLE CMTActionSet : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTActionSet, &CLSID_MTActionSet>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTActionSet, &IID_IMTActionSet, &LIBID_MTRULESETLib>
{
public:
	CMTActionSet()
	{ }

	HRESULT FinalConstruct();

	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTACTIONSET)

DECLARE_GET_CONTROLLING_UNKNOWN()
DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTActionSet)
	COM_INTERFACE_ENTRY(IMTActionSet)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTActionSet
public:

	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(get_Item)(/*[in]*/ VARIANT Index, /*[out,retval]*/ LPVARIANT pItem);
	STDMETHOD(get_NthItem)(/*[in]*/ VARIANT Index, long aN, /*[out,retval]*/ LPVARIANT pItem);
	STDMETHOD(Add)(/*[in]*/ IMTAssignmentAction * pMyObj );
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal );

private:
	MTObjectCollection<IMTAssignmentAction> mActions;

	// map used to lookup objects by name
	typedef std::map<std::wstring, long> NameIndexMap;
	NameIndexMap mIndexMap;

	CComPtr<IUnknown> m_pUnkMarshaler;
};

#endif //__MTACTIONSET_H_
