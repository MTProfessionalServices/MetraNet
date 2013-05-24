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

// MTEnumTypeCollection.h : Declaration of the CMTEnumTypeCollection

#ifndef __MTENUMTYPECOLLECTION_H_
#define __MTENUMTYPECOLLECTION_H_

#include "resource.h"       // main symbols
#include "MTEnumConfig.h"
#include "EnumConfig.h"

//#import <MTEnumConfig.tlb>

using namespace std;
typedef vector<CComVariant> EnumTypeVector;


/////////////////////////////////////////////////////////////////////////////
// CMTEnumTypeCollection
class ATL_NO_VTABLE CMTEnumTypeCollection : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTEnumTypeCollection, &CLSID_MTEnumTypeCollection>,
	public IDispatchImpl<::IMTEnumTypeCollection, &IID_IMTEnumTypeCollection, &LIBID_MTENUMCONFIGLib>
{
public:
	CMTEnumTypeCollection():mEnumTypeVector(EnumTypeVector())
	{
	}
	
	~CMTEnumTypeCollection()
	{
		mEnumTypeVector.clear();
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTENUMTYPECOLLECTION)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTEnumTypeCollection)
	COM_INTERFACE_ENTRY(::IMTEnumTypeCollection)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

void FinalRelease()
{
	m_pUnkMarshaler.Release();
}

CComPtr<IUnknown> m_pUnkMarshaler;


// IMTEnumTypeCollection
public:
	HRESULT FinalConstruct();
	//adds enum type to collection
	STDMETHOD(Add)(::IMTEnumType*);
	//returns collection size
	STDMETHOD(get_Size)(/*[out, retval]*/ long*);
	//returns MTEnumType at a specified index
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);
	//same as size
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	//internal use only
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);

private:
	EnumTypeVector mEnumTypeVector;


	
};

#endif //__MTENUMTYPECOLLECTION_H_
