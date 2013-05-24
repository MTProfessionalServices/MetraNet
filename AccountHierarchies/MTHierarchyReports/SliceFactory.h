	
// SliceFactory.h : Declaration of the CSliceFactory

#ifndef __SLICEFACTORY_H_
#define __SLICEFACTORY_H_

#include "resource.h"       // main symbols
#include <comutil.h>
#include <map>
#include <list>

#include <autocritical.h>

#import <MTHierarchyReports.tlb> rename ("EOF", "EOFHR")

/////////////////////////////////////////////////////////////////////////////
// CSliceFactory
class ATL_NO_VTABLE CSliceFactory : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CSliceFactory, &CLSID_SliceFactory>,
	public ISupportErrorInfo,
	public IDispatchImpl<ISliceFactory, &IID_ISliceFactory, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CSliceFactory()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_SLICEFACTORY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CSliceFactory)
	COM_INTERFACE_ENTRY(ISliceFactory)
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

// ISliceFactory
public:
	STDMETHOD(FromString)(/*[in]*/ BSTR aStr, /*[out, retval]*/ IViewSlice* *apSlice);
	STDMETHOD(GetSlice)(/*[in]*/ ISliceLexer* apLexer, /*[out, retval]*/ IViewSlice* *apSlice);
private:
	// Make this cache hooha thread safe
	NTThreadLock mCacheLock;
	// Remember the last few slice objects that have been deserialized.
	std::map<_bstr_t, MTHIERARCHYREPORTSLib::IViewSlicePtr> mCache;
	// front of the list is MRU, back is LRU
	std::list<_bstr_t> mLRU;
};

#endif //__SLICEFACTORY_H_
