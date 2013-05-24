/**************************************************************************
* Copyright 1997-2002 by MetraTech
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

#ifndef __MTSTATE_H_
#define __MTSTATE_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <loggerconfig.h>
#include "MTAccountStatesLogging.h"
#include <autologger.h>

#include <comdef.h>
#include <map>


using namespace std;
typedef map<_bstr_t, VARIANT_BOOL> BusinessRulesMap;

/////////////////////////////////////////////////////////////////////////////
// CMTState
class ATL_NO_VTABLE CMTState : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTState, &CLSID_MTState>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTState, &IID_IMTState, &LIBID_MTACCOUNTSTATESLib>
{
public:
	CMTState()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTSTATE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTState)
	COM_INTERFACE_ENTRY(IMTState)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return S_OK;
	}

	void FinalRelease()
	{
	}

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTState
public:
	STDMETHOD(get_ProgID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ProgID)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_LongName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_LongName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(AddConfiguredBusinessRules)(/*[in]*/ BSTR rule, /*[in]*/ VARIANT_BOOL boolVal);
	STDMETHOD(GetBusinessRuleValue)(/*[in]*/ BSTR rule, /*[in]*/ VARIANT_BOOL* boolVal);

	STDMETHOD(get_ArchiveAge)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ArchiveAge)(/*[in]*/ long newVal);

private:
	MTAutoInstance<MTAutoLoggerImpl<aAccountStateLogTitle> > mLogger;
	
	_bstr_t mName;
	_bstr_t mLongName;
	_bstr_t mProgID;
	long mArchiveAge;
	BusinessRulesMap mBizRulesMap;
};

#endif //__MTSTATE_H_
