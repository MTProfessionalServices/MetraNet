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


// SessionSet.h : Declaration of the CSessionSet

#ifndef __SESSIONSET_H_
#define __SESSIONSET_H_

#include "resource.h"       // main symbols
#include <comdef.h>         // bstr_r, variant_t datatypes
#include <MTCollection.h>
#include <MTObjectCollection.h>

// Forward Declarations
class MTMeterSessionSet;
class CMeter;

/*
inline HRESULT WINAPI _This(void* pv, REFIID iid, void ** ppvObject, DWORD)
{
	ATLASSERT(iid == IID_NULL);
	*ppvObject = pv;
	return S_OK;
}
*/

/////////////////////////////////////////////////////////////////////////////
// CSessionSet
class ATL_NO_VTABLE CSessionSet : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CSessionSet, &CLSID_SessionSet>,
	public ISupportErrorInfo,
	public IDispatchImpl<ISessionSet, &IID_ISessionSet, &LIBID_COMMeterLib>
{
	friend CMeter;
	friend CSessionSet;
public:
	CSessionSet();
	~CSessionSet();

DECLARE_REGISTRY_RESOURCEID(IDR_SESSIONSET) // What do i have to do about this???
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CSessionSet)
	COM_INTERFACE_ENTRY(ISessionSet)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_FUNC(IID_NULL, 0, _This)
END_COM_MAP()

// ISupportsErrorInfo
  STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ISessionSet

 public:
	STDMETHOD(CreateSession)(/*[in]*/ BSTR servicename, /*[out, retval]*/ ISession** new_session);
	STDMETHOD(get_SessionSetID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(Close)();
	STDMETHOD(put_TransactionID)(/*[in]*/ BSTR TransactionID);

	STDMETHOD(put_SessionContext)(/*[in]*/ BSTR SessionContext);
	STDMETHOD(put_SessionContextUserName)(/*[in]*/ BSTR UserName);
	STDMETHOD(put_SessionContextPassword)(/*[in]*/ BSTR Password);
	STDMETHOD(put_SessionContextNamespace)(/*[in]*/ BSTR Namespace);

	STDMETHOD(ToXML)(/*[out, retval]*/ BSTR *pVal);

  STDMETHOD(put__SetID)(/*[in]*/ BSTR newVal);

	void SetSDKSessionSet(MTMeterSessionSet * set);	// Used by meter to populate session on CreateNewSession
	STDMETHOD(GetSessions)(IMTCollection** col);

	STDMETHOD(put_ListenerTransactionID)(/*[in]*/ BSTR TransactionID);

   STDMETHOD(SetProperties)(/*[in]*/ BSTR listenerTransactionID, 
                            /*[in]*/ BSTR transactionID,
                            /*[in]*/ BSTR sessionContext,
                            /*[in]*/ BSTR sessionContextUserName,
                            /*[in]*/ BSTR sessionContextPassword,
                            /*[in]*/ BSTR sessionContextNamespace);

  STDMETHOD(GetSessionSetXmlStream)(/*[out, retval]*/ BSTR * xml);

 private:
	MTMeterSessionSet * m_SessionSet;                            // Pointer To SDK Object
	
	HRESULT HandleMeterError(void);				// Deals with error on m_SessionSet object
	
	void AddSession(ISession *pSession);

	// Local Copies of variables
	bstr_t	m_SessionSetID;
	
	MTObjectCollection<ISession> mSessionsHold; //Stores the sessions for the session set
};

#endif //__SESSION_H_







