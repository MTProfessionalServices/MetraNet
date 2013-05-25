	
// AuditEvent.h : Declaration of the CAuditEvent

#ifndef __AUDITEVENT_H_
#define __AUDITEVENT_H_

#include <comdef.h>
#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CAuditEvent
class ATL_NO_VTABLE CAuditEvent : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CAuditEvent, &CLSID_AuditEvent>,
	public IDispatchImpl<IAuditEvent, &IID_IAuditEvent, &LIBID_MTAUDITEVENTSLib>
{
public:
	CAuditEvent()
	{
		m_pUnkMarshaler = NULL;

		mUserId = 0;
		mEventId = 0;
		mEntityTypeId = 0;
		mEntityId = 0;
		mDetails = _bstr_t("");	
	}

DECLARE_REGISTRY_RESOURCEID(IDR_AUDITEVENT)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CAuditEvent)
	COM_INTERFACE_ENTRY(IAuditEvent)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct();

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// IAuditEvent
public:
	STDMETHOD(get_Details)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Details)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_EntityId)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_EntityId)(/*[in]*/ long newVal);
	STDMETHOD(get_EntityTypeId)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_EntityTypeId)(/*[in]*/ long newVal);
	STDMETHOD(get_EventId)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_EventId)(/*[in]*/ long newVal);
	STDMETHOD(get_UserId)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_UserId)(/*[in]*/ long newVal);
	STDMETHOD(get_Success)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Success)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_AuditId)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AuditId)(/*[in]*/ long newVal);
	//Additional information
	STDMETHOD(get_LoggedInAs)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_LoggedInAs)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ApplicationName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ApplicationName)(/*[in]*/ BSTR newVal);

protected:
	long mEventId;
	long mUserId;
	long mAuditId;
	long mEntityTypeId;
	long mEntityId;
	_bstr_t mDetails;
	_bstr_t mLoggedInAs;
	_bstr_t mApplicationName;

	VARIANT_BOOL mSuccess;
};

#endif //__AUDITEVENT_H_
