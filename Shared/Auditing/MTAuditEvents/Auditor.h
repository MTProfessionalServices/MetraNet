	
// Auditor.h : Declaration of the CAuditor

#ifndef __AUDITOR_H_
#define __AUDITOR_H_

#include "resource.h"       // main symbols
#include "metra.h"
#include <ConfigDir.h>
#include <ConfigChange.h>
#include <autocritical.h>

#include <NTLogger.h>
#include <mtglobal_msg.h>
#include <mtprogids.h>
#include <mtcomerr.h>

#include <string>

#import <MTConfigLib.tlb>

using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CAuditor
class ATL_NO_VTABLE CAuditor : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CAuditor, &CLSID_Auditor>,
	public IDispatchImpl<IAuditor, &IID_IAuditor, &LIBID_MTAUDITEVENTSLib>,
	public ConfigChangeObserver
{
public:
	CAuditor()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_AUDITOR)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CAuditor)
	COM_INTERFACE_ENTRY(IAuditor)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	
HRESULT FinalConstruct();



	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// IAuditor
public:
	STDMETHOD(FireEvent)(/*[in]*/ long EventId, /*[in]*/ long UserId, /*[in]*/ long EntityTypeId, /*[in]*/ long EntityId, /*[in]*/ BSTR Details);
	STDMETHOD(FireFailureEvent)(/*[in]*/ long EventId, /*[in]*/ long UserId, /*[in]*/ long EntityTypeId, /*[in]*/ long EntityId, /*[in]*/ BSTR Details);

	STDMETHOD(FireEventWithAdditionalData)(/*[in]*/ long EventId, /*[in]*/ long UserId, /*[in]*/ long EntityTypeId, /*[in]*/ long EntityId, /*[in]*/ BSTR Details, /*[in]*/ BSTR LoggedInAs,/*[in]*/ BSTR ApplicationName);
	STDMETHOD(FireFailureEventWithAdditionalData)(/*[in]*/ long EventId, /*[in]*/ long UserId, /*[in]*/ long EntityTypeId, /*[in]*/ long EntityId, /*[in]*/ BSTR Details, /*[in]*/ BSTR LoggedInAs,/*[in]*/ BSTR ApplicationName);

	// this method is here only to force a dependency on MTAuditEvent.  Otherwise
	// the enum is ignored when using #import on the tlb
	STDMETHOD(dummy)(/*[in]*/ MTAuditEvent event, MTAuditEntityType entity);

  virtual void ConfigurationHasChanged();

protected:
	BOOL mAuditingEnabled;
	ConfigChangeObservable mObserver;
	MTConfigLib::IMTConfigPtr mConfig;
 	std::string mConfigFile;

  HRESULT Load();

private:
	NTThreadLock mLock;

	STDMETHOD(FireEventLocal)(/*[in]*/ long EventId, /*[in]*/ long UserId, /*[in]*/ long EntityTypeId, /*[in]*/ long EntityId, /*[in]*/ BSTR Details, /*[in]*/ BSTR LoggedInAs, /*[in]*/ BSTR ApplicationName, /*[in]*/ VARIANT_BOOL Success);
};

#endif //__AUDITOR_H_
