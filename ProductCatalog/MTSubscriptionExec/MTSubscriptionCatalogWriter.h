// MTSubscriptionCatalogWriter.h : Declaration of the CMTSubscriptionCatalogWriter

#pragma once
#include "MTSubscriptionExec.h"
#include "resource.h"       // main symbols
#include <comsvcs.h>
#include <mtxattr.h>


// CMTSubscriptionCatalogWriter

class ATL_NO_VTABLE CMTSubscriptionCatalogWriter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public IObjectControl,
	public CComCoClass<CMTSubscriptionCatalogWriter, &CLSID_MTSubscriptionCatalogWriter>,
	public IDispatchImpl<IMTSubscriptionCatalogWriter, &IID_IMTSubscriptionCatalogWriter, &LIBID_MTSubscriptionExecLib, /*wMajor =*/ 1, /*wMinor =*/ 0>
{
public:
	CMTSubscriptionCatalogWriter()
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

DECLARE_REGISTRY_RESOURCEID(IDR_MTSUBSCRIPTIONCATALOGWRITER)

BEGIN_COM_MAP(CMTSubscriptionCatalogWriter)
	COM_INTERFACE_ENTRY(IMTSubscriptionCatalogWriter)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid)
	{
		static const IID* arr[] = 
		{
			&IID_IMTSubscriptionCatalogWriter
		};
		for (int i = 0; i < sizeof(arr) / sizeof(arr[0]); i++)
		{
			if (InlineIsEqualGUID(*arr[i], riid))
				return S_OK;
		}
		return S_FALSE;
	}


// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTSubscriptionCatalogWriter
public:
	STDMETHOD(SubscribeToGroups)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress,/*[in]*/ VARIANT_BOOL bUnsubscribeConflicting, /*[out]*/ VARIANT_BOOL* pDateModified,/*[in]*/ IMTSQLRowset* errorRs);
	STDMETHOD(SubscribeAccounts)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress,/*[in]*/ VARIANT_BOOL bUnsubscribeConflicting, /*[out]*/ VARIANT_BOOL* pDateModified,/*[in]*/ IMTSQLRowset* errorRs);
  // WARNING:  The following are internal methods only and do not manage session context!!!!!!!!!!  Do not call as COM methods.
	STDMETHOD(UnsubscribeFromConflictingToGroup)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress,/*[in]*/ IMTSQLRowset* errorRs);
	STDMETHOD(UnsubscribeFromConflictingToIndividual)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress,/*[in]*/ IMTSQLRowset* errorRs);
};

OBJECT_ENTRY_AUTO(__uuidof(MTSubscriptionCatalogWriter), CMTSubscriptionCatalogWriter)
