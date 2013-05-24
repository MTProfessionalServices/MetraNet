	
// SessionChildrenSlice.h : Declaration of the CSessionChildrenSlice

#ifndef __SESSIONCHILDRENSLICE_H_
#define __SESSIONCHILDRENSLICE_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CSessionChildrenSlice
class ATL_NO_VTABLE CSessionChildrenSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CSessionChildrenSlice, &CLSID_SessionChildrenSlice>,
	public ISupportErrorInfo,
	public IDispatchImpl<ISessionChildrenSlice, &IID_ISessionChildrenSlice, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CSessionChildrenSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_SESSIONCHILDRENSLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CSessionChildrenSlice)
	COM_INTERFACE_ENTRY(ISessionChildrenSlice)
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

// ISessionChildrenSlice
public:
	STDMETHOD(get_ParentID)(/*[out, retval]*/ __int64 *pVal);
	STDMETHOD(put_ParentID)(/*[in]*/ __int64 newVal);
// IViewSlice
public:
	STDMETHOD(GenerateQueryPredicate)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(ToString)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(ToStringUnencrypted)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(FromString)(/*[in]*/ ISliceLexer* apLexer);
  STDMETHOD(Equals)(/*[in]*/ IViewSlice* apSlice, /*[out,retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(Clone)(/*[out,retval]*/ IViewSlice* *pVal);
private:
	__int64 mParentID;
};

#endif //__SESSIONCHILDRENSLICE_H_
