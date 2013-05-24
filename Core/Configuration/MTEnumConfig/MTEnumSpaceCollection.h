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
	
// MTEnumSpaceCollection.h : Declaration of the CMTEnumSpaceCollection

#ifndef __MTENUMSPACECOLLECTION_H_
#define __MTENUMSPACECOLLECTION_H_

#include "resource.h"       // main symbols
#include	"EnumConfig.h"
#include	"MTEnumConfig.h"

//typedef map<_bstr_t, IMTEnumSpace*> EnumSpaceColl;
typedef vector<CComVariant> EnumSpaceColl;

/////////////////////////////////////////////////////////////////////////////
// CMTEnumSpaceCollection
class ATL_NO_VTABLE CMTEnumSpaceCollection : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTEnumSpaceCollection, &CLSID_MTEnumSpaceCollection>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTEnumSpaceCollection, &IID_IMTEnumSpaceCollection, &LIBID_MTENUMCONFIGLib>
{
public:
	CMTEnumSpaceCollection()
	{
	}
	~CMTEnumSpaceCollection()
	{
		mEnumSpaceColl.clear();
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTENUMSPACECOLLECTION)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTEnumSpaceCollection)
	COM_INTERFACE_ENTRY(IMTEnumSpaceCollection)
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


// IMTEnumSpaceCollection
public:
	HRESULT FinalConstruct();
	//INTERNAL USE ONLY
	STDMETHOD(Add)(IMTEnumSpace*);
	//Returns collection size
	STDMETHOD(get_Size)(/*[out, retval]*/ long*);
	//return MTEnumSpace at a specified index
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);
	//same as size
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	//INTERNAL USE ONLY
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
private:
	EnumSpaceColl mEnumSpaceColl;
};

#endif //__MTENUMSPACECOLLECTION_H_
