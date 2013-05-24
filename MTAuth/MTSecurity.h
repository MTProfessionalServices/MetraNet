/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Boris Partensky
* 
***************************************************************************/
	
// MTSecurity.h : Declaration of the CMTSecurity

#ifndef __MTSECURITY_H_
#define __MTSECURITY_H_

#include "resource.h"       // main symbols
using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTSecurity
class ATL_NO_VTABLE CMTSecurity : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSecurity, &CLSID_MTSecurity>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSecurity, &IID_IMTSecurity, &LIBID_MTAUTHLib>,
  public ConfigChangeObserver
{
public:
	CMTSecurity()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_CLASSFACTORY_EX(CMTSingletonFactory<CMTSecurity>)
DECLARE_REGISTRY_RESOURCEID(IDR_MTSECURITY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTSecurity)
	COM_INTERFACE_ENTRY(IMTSecurity)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		HRESULT hr = InternalBuildCol();
    if(FAILED(hr))
      return hr;
    
    mObserver.Init();
	  mObserver.AddObserver(*this);
    
    if (!mObserver.StartThread())
	  {
		  return Error("Could not start config change thread");
	  }

    hr = mAccCatalog.CreateInstance(MTPROGID_MTACCOUNTCATALOG);
    
    if(FAILED(hr))
      return hr;

    return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		mObserver.StopThread(INFINITE);
    m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTSecurity
public:
	STDMETHOD(GetAvailableRolesAsRowset)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/IMTSecurityPrincipal* aPrincipal,
    /*[in]*/MTPrincipalPolicyType aPolicyType, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(RemoveRole)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/long aRoleID);
	STDMETHOD(GetAtomicCapabilityTypeByName)(/*[in]*/BSTR aTypeName, /*[out, retval]*/IMTAtomicCapabilityType** apCapType);
	STDMETHOD(GetCapabilityTypeByID)(/*[in]*/long aTypeID, /*[out, retval]*/IMTCompositeCapabilityType** apCapType);
	STDMETHOD(GetCapabilityTypeByNameControlLogging)(/*[in]*/BSTR aTypeName, /*[in]*/VARIANT_BOOL logErrorIfNotFound, /*[out, retval]*/IMTCompositeCapabilityType** apCapType);
	STDMETHOD(GetCapabilityTypeByName)(/*[in]*/BSTR aTypeName, /*[out, retval]*/IMTCompositeCapabilityType** apCapType);
	STDMETHOD(GetAvailableCapabilityTypesAsRowset)(IMTSessionContext *aCtx, IMTSecurityPrincipal *aPrincipal, IMTSQLRowset **apRowset);
	STDMETHOD(GetCapabilityTypesAsRowset)(/*[in]*/IMTSessionContext* aCtx, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(GetRoleByID)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/long aRoleID,  /*[out, retval]*/IMTRole** apRole);
	STDMETHOD(GetRoleByName)(/*[in]*/IMTSessionContext* aCtx, BSTR aRoleName, /*[out, retval]*/IMTRole** apRole);
	STDMETHOD(GetAllRolesAsRowset)(IMTSessionContext* aCtx, IMTSQLRowset** apRowset);
	STDMETHOD(CreateRole)(/*[in]*/IMTSessionContext* aCtx, /*[out, retval]*/IMTRole** apNewRole);
	STDMETHOD(GetCSRFolder)(/*[in]*/IMTSessionContext* aCtx, /*[out, retval]*/IMTYAAC** apFolder);
  STDMETHOD(GetMOMFolder)(/*[in]*/IMTSessionContext* aCtx, /*[out, retval]*/IMTYAAC** apFolder);
  STDMETHOD(GetMCMFolder)(/*[in]*/IMTSessionContext* aCtx, /*[out, retval]*/IMTYAAC** apFolder);
	STDMETHOD(GetAnonymousAccount)(/*[in]*/IMTSessionContext* aCtx, /*[out, retval]*/IMTYAAC** apAccount);
	STDMETHOD(GetAccountByID)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/long aAccountID,VARIANT aRefDate,  /*[out, retval]*/IMTYAAC** apAccount);
  virtual void ConfigurationHasChanged();
  	

private:
  std::map<long, MTAUTHLib::IMTCompositeCapabilityTypePtr> mCapTypeMapByID;
  std::map<_bstr_t, MTAUTHLib::IMTCompositeCapabilityTypePtr> mCapTypeMapByName;
  std::map<long, MTAUTHLib::IMTRolePtr> mRoleMapByID;
  std::map<_bstr_t, MTAUTHLib::IMTRolePtr> mRoleMapByName;
  std::map<long, MTAUTHLib::IMTCompositeCapabilityTypePtr>::const_iterator mCapTypeMapByIDIt;
  std::map<_bstr_t, MTAUTHLib::IMTCompositeCapabilityTypePtr>::const_iterator mCapTypeMapByNameIt;
  std::map<long, MTAUTHLib::IMTRolePtr>::const_iterator mRoleMapByIDIt;
  std::map<_bstr_t, MTAUTHLib::IMTRolePtr>::const_iterator mRoleMapByNameIt;

  MTYAACLib::IMTAccountCatalogPtr mAccCatalog;

  HRESULT InternalBuildCol();
 	ConfigChangeObservable mObserver;
	NTThreadLock mLock;

  MTAUTHLib::IMTRolePtr CreateRole();
  HRESULT CreateCCTCollection(const ROWSETLib::IMTSQLRowsetPtr& aRs);
};

#endif //__MTSECURITY_H_
