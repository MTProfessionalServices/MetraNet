/**************************************************************************
 * @doc MTNAMEID
 *
 * @module |
 *
 *
 * Copyright 1999 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | MTNAMEID
 ***************************************************************************/

#ifndef _MTNAMEID_H
#define _MTNAMEID_H

#include "resource.h"       // main symbols

#include "NameID.h"

class CCodeLookup;

/////////////////////////////////////////////////////////////////////////////
// CMTNameID
class ATL_NO_VTABLE CMTNameID :
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTNameID, &CLSID_MTNameID>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTNameID, &IID_IMTNameID, &LIBID_NAMEIDLib>
{
public:
	CMTNameID();
	~CMTNameID();

	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTNAMEID)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTNameID)
	COM_INTERFACE_ENTRY(IMTNameID)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
  COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mpUnkMarshaler.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTNameID
public:
	STDMETHOD(GetNameID)(BSTR name, long * id);
	STDMETHOD(GetName)(long id, BSTR * name);

private:
	// critical section to lock next id and name pool map
	CComAutoCriticalSection mNamePoolLock;

	CCodeLookup * mpCodeLookup;
  CComPtr<IUnknown> mpUnkMarshaler;
};

#endif //__MTNAMEID_H_
