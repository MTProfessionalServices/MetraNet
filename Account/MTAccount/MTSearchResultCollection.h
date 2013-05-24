// MTSearchResultCollection.h : Declaration of the CMTSearchResultCollection

#ifndef __MTSEARCHRESULTCOLLECTION_H_
#define __MTSEARCHRESULTCOLLECTION_H_

#include "resource.h"       // main symbols
#include <vector>
#include "MTAccountPropertyCollection.h"
#include <MTAccountFinder.h>
#pragma warning(disable : 4786)

class _CopyVectorItem;
typedef std::vector<CAdapt<CComPtr<IMTAccountPropertyCollection> > > PropCollMap;
typedef CComEnumOnSTL<IEnumVARIANT, &IID_IEnumVARIANT, VARIANT, _CopyVectorItem, PropCollMap> CVarEnum;
typedef ICollectionOnSTLImpl<IMTSearchResultCollection, PropCollMap, VARIANT, _CopyVectorItem, CVarEnum> ICollImpl;

class _CopyVectorItem
{
public:
	static HRESULT copy(VARIANT* p1, const CAdapt<CComPtr<IMTAccountPropertyCollection> >* p2) 
	{
		CComPtr<IMTAccountPropertyCollection>  p = *p2;
		CComVariant var = p;

		return VariantCopy(p1, &var);
	}
	
	static void init(VARIANT* p) {p->vt = VT_EMPTY;}
	static void destroy(VARIANT* p) {VariantClear(p);}
};



/////////////////////////////////////////////////////////////////////////////
// CMTSearchResultCollection
class ATL_NO_VTABLE CMTSearchResultCollection : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSearchResultCollection, &CLSID_MTSearchResultCollection>,
	public ISupportErrorInfo,
	public IDispatchImpl<ICollImpl, &IID_IMTSearchResultCollection, &LIBID_MTACCOUNTLib, 1, 0>
	//public IDispatchImpl<IMTSearchResultCollection, &IID_IMTSearchResultCollection, &LIBID_MTACCOUNTLib>
{
public:
	CMTSearchResultCollection() {}

DECLARE_REGISTRY_RESOURCEID(IDR_MTSEARCHRESULTCOLLECTION)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTSearchResultCollection)
	COM_INTERFACE_ENTRY(IMTSearchResultCollection)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTSearchResultCollection
public:

	STDMETHOD(Add)(/*[in]*/ IMTAccountPropertyCollection* pAccPropColl);
	STDMETHOD(Append)(/*[in]*/ IMTSearchResultCollection* apSRC);
	STDMETHOD(Count)(/*[out]*/ long* aSize);
	STDMETHOD(Clear)();
};

#endif //__MTSEARCHRESULTCOLLECTION_H_
