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
* Created by: Boris Partensky
* $Header$
* 
***************************************************************************/

// MTEnumerator.h : Declaration of the CMTEnumerator

#ifndef __MTENUMERATOR_H_
#define __MTENUMERATOR_H_

#include "resource.h"       // main symbols
#include "EnumConfig.h"       // main symbols
#include <autologger.h>
#include "enumtypelogging.h"


//#import <MTEnumConfigLib.tlb>



/////////////////////////////////////////////////////////////////////////////
// CMTEnumerator
class ATL_NO_VTABLE CMTEnumerator : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTEnumerator, &CLSID_MTEnumerator>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTEnumerator, &IID_IMTEnumerator, &LIBID_MTENUMCONFIGLib>
{
public:
	CMTEnumerator(): mEnumerator(CEnumerator())
	{
	}

	~CMTEnumerator()
	{
		
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTENUMERATOR)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTEnumerator)
	COM_INTERFACE_ENTRY(IMTEnumerator)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

// ISupportsErrorInfo
STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

void FinalRelease()
{
	m_pUnkMarshaler.Release();
}

CComPtr<IUnknown> m_pUnkMarshaler;



// IMTEnumerator
public:
	HRESULT FinalConstruct();
	//returns FQN for this enumerator
	STDMETHOD(get_FQN)(/*[out, retval]*/ BSTR *pVal);
	//returns value at a specified index
	STDMETHOD(ElementAt)(/*[in]*/ int, /*[out, retval]*/ BSTR*);
	//Number of values
	STDMETHOD(NumValues)(/*[out, retval]*/ int*);
	//INTERNAL USE ONLY
	STDMETHOD(WriteSet)(IMTConfigPropSet* pSet);
	//Name for enum type this enumerator belongs to
	STDMETHOD(get_EnumType)(/*[out, retval]*/ BSTR *pVal);
	//INTERNAL USE ONLY
	STDMETHOD(put_EnumType)(/*[in]*/ BSTR newVal);
	//Name for enum space this enumerator belongs to
	STDMETHOD(get_EnumSpace)(/*[out, retval]*/ BSTR *pVal);
	//INTERNAL USE ONLY
	STDMETHOD(put_EnumSpace)(/*[in]*/ BSTR newVal);
	//Adds a value to this enumerator
	STDMETHOD(AddValue)(BSTR value);
	//removes value at a specified index
	STDMETHOD(ClearValue)(BSTR value);
	//removes all values
	STDMETHOD(ClearValues)();
	//returns name for this enumerator
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	//sets name for this enumerator
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	//returns name for this enumerator
	STDMETHOD(get_DisplayName)(/*[out, retval]*/ BSTR *pVal);
	//sets name for this enumerator
	STDMETHOD(put_DisplayName)(/*[in]*/ BSTR newVal);

private:
	CEnumerator mEnumerator;
	MTAutoInstance<MTAutoLoggerImpl<LoggingMsg> >	mLogger;
};

#endif //__MTENUMERATOR_H_
