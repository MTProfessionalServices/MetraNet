	
// MTAccountPropertyCollection.h : Declaration of the CMTAccountPropertyCollection

#ifndef __MTACCOUNTPROPERTYCOLLECTION_H_
#define __MTACCOUNTPROPERTYCOLLECTION_H_

#include "resource.h"       // main symbols
#include "MTAccountProperty.h"
#include <map>
#pragma warning(disable : 4786)

class _CopyMapItem;
typedef std::map<CComBSTR, CComPtr<IMTAccountProperty> > PropMap;
typedef CComEnumOnSTL<IEnumVARIANT, &IID_IEnumVARIANT, VARIANT, _CopyMapItem, PropMap> VarEnum;
typedef ICollectionOnSTLImpl<IMTAccountPropertyCollection, PropMap, VARIANT, _CopyMapItem, VarEnum> CollImpl;

class _CopyMapItem
{
public:
	static HRESULT copy(VARIANT* p1, 
						const std::pair<const CComBSTR, CComPtr<IMTAccountProperty> >* p2) 
	{
		CComPtr<IMTAccountProperty> p = p2->second;
		CComVariant var = p;
		return VariantCopy(p1, &var);
	}
	
	static void init(VARIANT* p) {p->vt = VT_EMPTY;}
	static void destroy(VARIANT* p) {VariantClear(p);}
};


/////////////////////////////////////////////////////////////////////////////
// CMTAccountPropertyCollection
class ATL_NO_VTABLE CMTAccountPropertyCollection : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccountPropertyCollection, &CLSID_MTAccountPropertyCollection>,
	public ISupportErrorInfo,
	public IDispatchImpl<CollImpl, &IID_IMTAccountPropertyCollection, &LIBID_MTACCOUNTLib, 1, 0>
{
public:
	CMTAccountPropertyCollection() {}
	~CMTAccountPropertyCollection() {}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTPROPERTYCOLLECTION)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountPropertyCollection)
	COM_INTERFACE_ENTRY(IMTAccountPropertyCollection)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	
// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAccountPropertyCollection
public:
	STDMETHOD(get_Item)(VARIANT Index, /*[out, retval]*/ VARIANT *pVal);
    STDMETHOD(Add)(BSTR aName, VARIANT aValue, IMTAccountProperty ** apAccProp);    
};

#endif //__MTACCOUNTPROPERTYCOLLECTION_H_
