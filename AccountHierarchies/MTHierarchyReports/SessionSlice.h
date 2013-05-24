	
// SessionSlice.h : Declaration of the CSessionSlice

#ifndef __SESSIONSLICE_H_
#define __SESSIONSLICE_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CSessionSlice
class ATL_NO_VTABLE CSessionSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CSessionSlice, &CLSID_SessionSlice>,
	public ISupportErrorInfo,
	public IDispatchImpl<ISessionSlice, &IID_ISessionSlice, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CSessionSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_SESSIONSLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CSessionSlice)
	COM_INTERFACE_ENTRY(ISessionSlice)
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

// ISessionSlice
public:
	STDMETHOD(get_SessionID)(/*[out, retval]*/ __int64 *pVal);
	STDMETHOD(put_SessionID)(/*[in]*/ __int64 newVal);
  STDMETHOD(CreateChildSlice)(/*[out, retval]*/ IViewSlice* *pVal);
// IViewSlice
public:
	STDMETHOD(GenerateQueryPredicate)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(ToString)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(ToStringUnencrypted)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(FromString)(/*[in]*/ ISliceLexer* apLexer);
  STDMETHOD(Equals)(/*[in]*/ IViewSlice* apSlice, /*[out,retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(Clone)(/*[out,retval]*/ IViewSlice* *pVal);
private:
	__int64 mSessionID;
};

#endif //__SESSIONSLICE_H_
