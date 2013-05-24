// Ticket.h : Declaration of the CTicket
/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Rudi Perkins
* $Header$
* 
***************************************************************************/

#ifndef __TICKET_H_
#define __TICKET_H_

#include <comdef.h>
#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CTicket
class ATL_NO_VTABLE CTicket : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CTicket, &CLSID_Ticket>,
	public IDispatchImpl<ITicket, &IID_ITicket, &LIBID_COMTICKETAGENTLib>
{
public:
	CTicket()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_TICKET)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CTicket)
	COM_INTERFACE_ENTRY(ITicket)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// ITicket
public:
	STDMETHOD(get_AccountIdentifier)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_AccountIdentifier)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Namespace)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Namespace)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_LoggedInAs)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_LoggedInAs)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ApplicationName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ApplicationName)(/*[in]*/ BSTR newVal);

private:
  _bstr_t mNamespace;
	_bstr_t mAccountIdentifier;
	_bstr_t mLoggedInAs;
	_bstr_t mApplicationName;
};

#endif //__TICKET_H_
