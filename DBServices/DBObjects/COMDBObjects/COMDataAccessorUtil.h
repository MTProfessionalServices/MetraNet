	
// CCOMDataAccessorUtil.h : Declaration of the CCCOMDataAccessorUtil

#ifndef __COMDATAACCESSORUTIL_H_
#define __COMDATAACCESSORUTIL_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CCCOMDataAccessorUtil
class ATL_NO_VTABLE CCOMDataAccessorUtil : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMDataAccessorUtil, &CLSID_COMDataAccessorUtil>,
	public IDispatchImpl<ICOMDataAccessorUtil, &IID_ICOMDataAccessorUtil, &LIBID_COMDBOBJECTSLib>
{
public:
	CCOMDataAccessorUtil()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_COMDATAACCESSORUTIL)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CCOMDataAccessorUtil)
	COM_INTERFACE_ENTRY(ICOMDataAccessorUtil)
	COM_INTERFACE_ENTRY(IDispatch)
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

// ICOMDataAccessorUtil
public:
	STDMETHOD(GetProductViewTableName)(/*[in]*/ BSTR ProductViewName, /*[out,retval]*/ BSTR *pTableName);
};

#endif //__COMDATAACCESSORUTIL_H_
