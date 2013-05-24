/**************************************************************************
* Copyright 1998, 1999 by MetraTech Corporation
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech Corporation MAKES NO
* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech Corporation,
* and USER agrees to preserve the same.
*
***************************************************************************/


// Session.h : Declaration of the CSession

#ifndef __SESSION_H_
#define __SESSION_H_

#include "resource.h"       // main symbols
#include <comdef.h>         // bstr_r, variant_t datatypes

#include <vector>
#include <MTObjectCollection.h>
using std::vector;

// Forward Declarations
class MTMeterSession;
class CMeter;

inline HRESULT WINAPI _This(void* pv, REFIID iid, void ** ppvObject, DWORD)
{
	ATLASSERT(iid == IID_NULL);
	*ppvObject = pv;
	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// CSession
class ATL_NO_VTABLE CSession : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CSession, &CLSID_Session>,
	public ISupportErrorInfo,
	public IDispatchImpl<ISession, &IID_ISession, &LIBID_COMMeterLib>
{
	friend CMeter;
	friend CSession;	// Other Sessions and Meter will have to set SDK object
public:
	CSession();
	~CSession();

DECLARE_REGISTRY_RESOURCEID(IDR_SESSION)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CSession)
	COM_INTERFACE_ENTRY(ISession)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_FUNC(IID_NULL, 0, _This)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ISession
public:
	STDMETHOD(get_ResultSession)(/*[out, retval]*/ ISession **pVal);
	STDMETHOD(put_RequestResponse)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_RequestResponse)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_ReferenceID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_SessionID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(GetProperty)(/*[in]*/ BSTR name, /*[in, optional, defaultvalue(1)]*/ DataType Type, /*[out, retval]*/ VARIANT * value);
	STDMETHOD(SetProperty)(/*[in]*/ BSTR Name, /*[in]*/ VARIANT Value);
	STDMETHOD(InitProperty)(/*[in]*/ BSTR Name, /*[in]*/ VARIANT Value);
	STDMETHOD(CreateChildSession)(BSTR ServiceName, /*[out, retval]*/ ISession** chldSess);
  STDMETHOD(put__ID)(/*[in]*/ BSTR newVal);
  STDMETHOD(put__SetID)(/*[in]*/ BSTR newVal);

	STDMETHOD(Close)();
	STDMETHOD(Save)();
	STDMETHOD(ToXML)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_ErrorCode)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_ErrorMessage)(/*[out, retval]*/ BSTR *pVal);
	
	void SetSDKSession(MTMeterSession * session);	// Used by meter to populate session on CreateNewSession
	void SetSessionName(BSTR theName);

	STDMETHOD(GetChildSessions)(IMTCollection** col);
   STDMETHOD(CreateSessionStream)(/*[in]*/ SAFEARRAY* propertyDataArray);

private:
	void AddChild (ISession * pSession);
	MTMeterSession * m_Session;						// Pointer To SDK Object

	HRESULT HandleMeterError(void);				// Deals with error on m_Session object

	// Local Copies of variables
	bstr_t	m_ReferenceID;
	bstr_t	m_Name;
	bstr_t	m_SessionID;
	MTObjectCollection<ISession> mChildSessions;

};

#endif //__SESSION_H_
