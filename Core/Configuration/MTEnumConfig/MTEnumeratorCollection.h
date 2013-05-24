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

// MTEnumeratorCollection.h : Declaration of the CMTEnumeratorCollection

#ifndef __MTENUMERATORCOLLECTION_H_
#define __MTENUMERATORCOLLECTION_H_

#include "resource.h"       // main symbols
#include "MTEnumConfig.h"
#include "EnumConfig.h"

//#import <MTEnumConfig.tlb>

using namespace std;
typedef vector<CComVariant> EnumeratorSet;


/////////////////////////////////////////////////////////////////////////////
// CMTEnumeratorCollection
class ATL_NO_VTABLE CMTEnumeratorCollection : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTEnumeratorCollection, &CLSID_MTEnumeratorCollection>,
	public ISupportErrorInfo,
	public IDispatchImpl<::IMTEnumeratorCollection, &IID_IMTEnumeratorCollection, &LIBID_MTENUMCONFIGLib>
{
public:
	CMTEnumeratorCollection():mEnumeratorSet(EnumeratorSet())
	{
	}

	~CMTEnumeratorCollection();

DECLARE_REGISTRY_RESOURCEID(IDR_MTENUMERATORCOLLECTION)

STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);


DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTEnumeratorCollection)
	COM_INTERFACE_ENTRY(::IMTEnumeratorCollection)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

void FinalRelease()
{
	m_pUnkMarshaler.Release();
}

CComPtr<IUnknown> m_pUnkMarshaler;


// IMTEnumeratorCollection
public:
	HRESULT FinalConstruct();
	//Collection size
	STDMETHOD(get_Size)(long*);
	//INTERNAL USE ONLY
	STDMETHOD(Add)(::IMTEnumerator*);
	//MTEnumerator at a specified position
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);
	//number of elements
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	//INTERNAL USE ONLY
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);

private:
	EnumeratorSet mEnumeratorSet;
};

#endif //__MTENUMERATORCOLLECTION_H_
