/**************************************************************************
 * @doc 
 *
 * @module |
 *
 * The MetraTech Metering Software Development Kit.
 *
 * Copyright 1998 by MetraTech Corporation
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
// MTCreditCard.h : Declaration of the CMTCreditCard

#ifndef __MTCREDITCARD_H_
#define __MTCREDITCARD_H_

#include "resource.h"       // main symbols
#include <comdef.h>			// bstr_t definition
#include "MTCCdefs.h"		

// Structure to hold server list for HTTPConfig
typedef struct _metratech_server_entry {
    long	Priority;
	_variant_t	serverName;
	long	PortNumber;
	BOOL	Secure;
	_variant_t	UserName;
	_variant_t	Password;
} MT_SERVER_ENTRY;

/////////////////////////////////////////////////////////////////////////////
// CMTCreditCard
class ATL_NO_VTABLE CMTCreditCard : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCreditCard, &CLSID_MTCreditCard>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCreditCard, &IID_IMTCreditCard, &LIBID_CREDITCARDLib>
{
public:

	CMTCreditCard();
DECLARE_REGISTRY_RESOURCEID(IDR_MTCREDITCARD)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCreditCard)
	COM_INTERFACE_ENTRY(IMTCreditCard)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTCreditCard
public:
	STDMETHOD(get_ExpDateFormat)(/*[out, retval]*/ MTExpDateFormat *pVal);
	STDMETHOD(put_ExpDateFormat)(/*[in]*/ MTExpDateFormat newVal);
	STDMETHOD(get_HTTPProxyHostname)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_HTTPProxyHostname)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_HTTPRetries)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_HTTPRetries)(/*[in]*/ long newVal);
	STDMETHOD(get_HTTPTimeout)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_HTTPTimeout)(/*[in]*/ long newVal);
	STDMETHOD(AddServer)(/*[in]*/ long priority, /*[in]*/ BSTR serverName, /*[in]*/ long Port, /*[in]*/ BOOL Secure, /*[in, optional, defaultvalue(NULL)]*/ VARIANT username, /*[in, optional, defaultvalue(NULL)]*/ VARIANT password);
	STDMETHOD(get_ZipCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ZipCode)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_UseAVS)(/*[out, retval]*/ BOOL *pVal);
	STDMETHOD(put_UseAVS)(/*[in]*/ BOOL newVal);
	STDMETHOD(get_ServiceName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ServiceName)(/*[in]*/ BSTR newVal);
	STDMETHOD(AddUserProperty)(/*[in]*/ BSTR Name, /*[in]*/ VARIANT Value);
	STDMETHOD(Execute)(/*[in, defaultvalue(0)]*/ BOOL wait, MTCreditCardErrorMsg * successCode);
	STDMETHOD(Validate)(/*[out, retval]*/ MTCreditCardErrorMsg * success);
	STDMETHOD(ValidateTypeAndNumber)(/*[out, retval]*/ MTCreditCardErrorMsg * success);
	STDMETHOD(get_Phone)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Phone)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Country)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Country)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_State)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_State)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_City)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_City)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Address3)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Address3)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Address2)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Address2)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Address1)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Address1)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Company)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Company)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_LastName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_LastName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_FirstName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_FirstName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_CardType)(/*[out, retval]*/ MTCreditCardType *pVal);
	STDMETHOD(put_CardType)(/*[in]*/ MTCreditCardType newVal);
	STDMETHOD(get_ExpirationDateYear)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ExpirationDateYear)(/*[in]*/ long newVal);
	STDMETHOD(get_ExpirationDateMonth)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ExpirationDateMonth)(/*[in]*/ long newVal);
	STDMETHOD(get_CardNumber)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_CardNumber)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_NameOnCard)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_NameOnCard)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_CurrencyCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_CurrencyCode)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Amount)(/*[out, retval]*/ double *pVal);
	STDMETHOD(put_Amount)(/*[in]*/ double newVal);
	STDMETHOD(get_Action)(/*[out, retval]*/ MTCreditCardAction *pVal);
	STDMETHOD(put_Action)(/*[in]*/ MTCreditCardAction newVal);
	STDMETHOD(get_MapNamespace)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_MapNamespace)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_MapName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_MapName)(/*[in]*/ BSTR newVal);
private:
	MTCreditCardErrorMsg CheckCCChecksum(const char * number, int numlength);
	MTCreditCardErrorMsg CheckCCFormat(const char * number, int type);

	// Service Name to Use
	bstr_t m_ServiceName;

	// HTTP Info
	MT_SERVER_ENTRY m_Servers[MT_MAX_SERVERS];
	long m_NumServers;
	long m_Timeout;
	long m_Retries;
	bstr_t m_ProxyHost;

	// Local Copies of Service Properties
	bstr_t	m_MapName;
	bstr_t	m_MapNamespace;
	long	m_Action;
	double	m_Amount;
	bstr_t	m_CurrencyCode;
	bstr_t	m_NameOnCard;
	bstr_t	m_CardNumber;
	long	m_ExpirationDateMonth;
	long	m_ExpirationDateYear;
	long	m_CardType;
	bstr_t	m_FirstName;
	bstr_t	m_LastName;
	bstr_t	m_Company;
	bstr_t	m_Address1;
	bstr_t	m_Address2;
	bstr_t	m_Address3;
	bstr_t	m_City;
	bstr_t	m_State;
	bstr_t	m_ZipCode;
	bstr_t	m_Country;
	bstr_t	m_Phone;
	BOOL	m_UseAVS;
};

#endif //__MTCREDITCARD_H_
