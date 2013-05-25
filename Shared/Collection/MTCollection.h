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

#ifndef __MTCOLLECTION_H_
#define __MTCOLLECTION_H_

#include "resource.h"       // main symbols
#include <MTCollectionImpl.h>


/////////////////////////////////////////////////////////////////////////////
// CMTCollection
class ATL_NO_VTABLE CMTCollection : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCollection, &CLSID_MTCollection>,
	public ISupportErrorInfo,
	public MTCollectionImpl<IMTCollection, &IID_IMTCollection, &LIBID_GENERICCOLLECTIONLib>
{
public:
	CMTCollection()
	{
	}

	HRESULT FinalConstruct()
	{
		return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &mpUnkMarshaler.p);
	}
	void FinalRelease()
	{
		mpUnkMarshaler.Release();
	}


DECLARE_REGISTRY_RESOURCEID(IDR_MTCOLLECTION)

DECLARE_PROTECT_FINAL_CONSTRUCT()
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTCollection)
	COM_INTERFACE_ENTRY(IMTCollectionReadOnly)
	COM_INTERFACE_ENTRY(IMTCollection)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mpUnkMarshaler.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTCollection
public:


private:
	CComPtr<IUnknown> mpUnkMarshaler;
};

#endif //__MTCOLLECTION_H_







