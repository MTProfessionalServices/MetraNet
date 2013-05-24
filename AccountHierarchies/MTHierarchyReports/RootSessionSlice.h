	
// RootSessionSlice.h : Declaration of the CRootSessionSlice

#ifndef __ROOTSESSIONSLICE_H_
#define __ROOTSESSIONSLICE_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CRootSessionSlice
class ATL_NO_VTABLE CRootSessionSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CRootSessionSlice, &CLSID_RootSessionSlice>,
	public ISupportErrorInfo,
	public IDispatchImpl<IRootSessionSlice, &IID_IRootSessionSlice, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CRootSessionSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_ROOTSESSIONSLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CRootSessionSlice)
	COM_INTERFACE_ENTRY(IRootSessionSlice)
	COM_INTERFACE_ENTRY(IViewSlice)
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

// IRootSessionSlice
public:
// IViewSlice
public:
	STDMETHOD(GenerateQueryPredicate)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(ToString)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(ToStringUnencrypted)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(FromString)(/*[in]*/ ISliceLexer* apLexer);
  STDMETHOD(Equals)(/*[in]*/ IViewSlice* apSlice, /*[out,retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(Clone)(/*[out,retval]*/ IViewSlice* *pVal);
};

#endif //__ROOTSESSIONSLICE_H_
