// MTEnumExchanges.h : Declaration of the CMTEnumExchanges

#ifndef __MTENUMEXCHANGES_H_
#define __MTENUMEXCHANGES_H_

#include "resource.h"       // main symbols

#include <vector>
using std::vector;

/////////////////////////////////////////////////////////////////////////////
// CMTEnumExchanges
class ATL_NO_VTABLE CMTEnumExchanges : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTEnumExchanges, &CLSID_MTEnumExchanges>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTEnumExchanges, &IID_IMTEnumExchanges, &LIBID_PHONELOOKUPLib>
{
public:
	CMTEnumExchanges() : mCount(0)
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTENUMEXCHANGES)

BEGIN_COM_MAP(CMTEnumExchanges)
	COM_INTERFACE_ENTRY(IMTEnumExchanges)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTEnumExchanges
public:
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ LPDISPATCH *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(Add)(IMTExchange * pItem);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(InitFromPropSet )(IDispatch * pSet);
	STDMETHOD(Read )(BSTR bstrHostName, BSTR bstrFileName);

private:
  vector<CComPtr<IMTExchange> > mExchangeList;
	long	mCount;	};

#endif //__MTENUMEXCHANGES_H_
