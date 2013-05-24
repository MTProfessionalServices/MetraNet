// TicketAgent.h : Declaration of the CTicketAgent
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
* Created by: 
* $Header$
* 
***************************************************************************/

#ifndef __TICKETAGENT_H_
#define __TICKETAGENT_H_

#include <comdef.h>
#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CTicketAgent
class ATL_NO_VTABLE CTicketAgent : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CTicketAgent, &CLSID_TicketAgent>,
	public ISupportErrorInfo,
	public IDispatchImpl<ITicketAgent, &IID_ITicketAgent, &LIBID_COMTICKETAGENTLib>
{
public:
	CTicketAgent()
	{
		mDelimiter=L"~";
    mEncryptionKey=L"";
	}

DECLARE_REGISTRY_RESOURCEID(IDR_TICKETAGENT)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CTicketAgent)
	COM_INTERFACE_ENTRY(ITicketAgent)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ITicketAgent
public:
	// ----------------------------------------------------------------
  // Description:   Creates an authentication ticket
	// ----------------------------------------------------------------
	STDMETHOD(CreateTicket)(/*[in]*/ BSTR sNamespace,/*[in]*/ BSTR sAccountIdentifier,/*[in]*/ long lExpirationOffset, /*[out, retval]*/ BSTR *pTicket);
	// ----------------------------------------------------------------
	// Description:   Given a ticket, returns a component that contains the namespace and accountid from the ticket
	// ----------------------------------------------------------------
  STDMETHOD(RetrieveTicketProperties)(/*[in]*/ BSTR Ticket, /*[out, retval]*/ LPDISPATCH *pInterface);
	// ----------------------------------------------------------------
	// Description:   Sets the encryption key that the will be used to create the ticket
	// ----------------------------------------------------------------
	STDMETHOD(get_Key)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Key)(/*[in]*/ BSTR newVal);
  // ----------------------------------------------------------------
	// Description:   Sets the delimiter that the will be used to create the ticket
  // ----------------------------------------------------------------
	STDMETHOD(get_Delimiter)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Delimiter)(/*[in]*/ BSTR newVal);

	// ----------------------------------------------------------------
	// Description:   Creates an authentication ticket with additionl data
	// ----------------------------------------------------------------
	STDMETHOD(CreateTicketWithAdditionalData)(/*[in]*/ BSTR sNamespace,/*[in]*/ BSTR sAccountIdentifier,/*[in]*/ long lExpirationOffset,/*[in]*/ BSTR sLoggedInAs,/*[in]*/ BSTR sApplicationName,/*[out, retval]*/ BSTR *pTicket);

private:
	_bstr_t mDelimiter;
	_bstr_t mEncryptionKey;

};

#endif //__TICKETAGENT_H_
