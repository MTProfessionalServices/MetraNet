// MTSubscriptionCatalogReader.h : Declaration of the CMTSubscriptionCatalogReader

#pragma once
#include "MTSubscriptionExec.h"
#include "resource.h"       // main symbols
#include <comsvcs.h>
#include <mtxattr.h>


// CMTSubscriptionCatalogReader

class ATL_NO_VTABLE CMTSubscriptionCatalogReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTSubscriptionCatalogReader, &CLSID_MTSubscriptionCatalogReader>,
	public IDispatchImpl<IMTSubscriptionCatalogReader, &IID_IMTSubscriptionCatalogReader, &LIBID_MTSubscriptionExecLib, /*wMajor =*/ 1, /*wMinor =*/ 0>
{
public:
	CMTSubscriptionCatalogReader()
	{
	}

	DECLARE_PROTECT_FINAL_CONSTRUCT()

	HRESULT FinalConstruct()
	{
		return S_OK;
	}
	
	void FinalRelease() 
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTSUBSCRIPTIONCATALOGREADER)

DECLARE_NOT_AGGREGATABLE(CMTSubscriptionCatalogReader)

BEGIN_COM_MAP(CMTSubscriptionCatalogReader)
	COM_INTERFACE_ENTRY(IMTSubscriptionCatalogReader)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid)
	{
		static const IID* arr[] = 
		{
			&IID_IMTSubscriptionCatalogReader
		};
		for (int i = 0; i < sizeof(arr) / sizeof(arr[0]); i++)
		{
			if (InlineIsEqualGUID(*arr[i], riid))
				return S_OK;
		}
		return S_FALSE;
	}


// IMTSubscriptionCatalogReader
public:
};

OBJECT_ENTRY_AUTO(__uuidof(MTSubscriptionCatalogReader), CMTSubscriptionCatalogReader)
