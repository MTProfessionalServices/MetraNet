/**************************************************************************
* Copyright 2002 by MetraTech
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
***************************************************************************/

#ifndef __MTGSUBMEMBER_H_
#define __MTGSUBMEMBER_H_

#include "resource.h"       // main symbols
#include "PropertiesBase.h"

/////////////////////////////////////////////////////////////////////////////
// CMTGSubMember
class ATL_NO_VTABLE CMTGSubMember : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTGSubMember, &CLSID_MTGSubMember>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTGSubMember, &IID_IMTGSubMember, &LIBID_MTPRODUCTCATALOGLib>,
	public PropertiesBase

{
public:
	CMTGSubMember()
	{
		m_pUnkMarshaler = NULL;
		mbEndDateNotSpecified = true;
		mbOldEndDateNotSpecified = true;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTGSUBMEMBER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

DEFINE_MT_PROPERTIES_BASE_METHODS


BEGIN_COM_MAP(CMTGSubMember)
	COM_INTERFACE_ENTRY(IMTGSubMember)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct();

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTGSubMember
public:
	STDMETHOD(Validate)();
	STDMETHOD(get_AccountName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_AccountName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_OldEndDateNotSpecified)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_OldStartDate)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(get_OldEndDate)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(NewDateRange)(/*[in]*/ DATE aNewStartDate,/*[in]*/ VARIANT aNewEndDate);
	STDMETHOD(get_EndDateNotSpecified)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_EndDate)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(put_EndDate)(/*[in]*/ DATE newVal);
	STDMETHOD(get_StartDate)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(put_StartDate)(/*[in]*/ DATE newVal);
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
protected:
	bool mbOldEndDateNotSpecified;
	bool mbEndDateNotSpecified;
};

#endif //__MTGSUBMEMBER_H_
