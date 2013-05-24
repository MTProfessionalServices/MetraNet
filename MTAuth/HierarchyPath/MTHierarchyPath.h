/**************************************************************************
 *
 * Copyright 2001 by MetraTech Corporation
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
 * Created by: Boris Partensky
 * $Author$
 * $Header$
 *
 ***************************************************************************/


#ifndef __MTHIERARCHYPATH_H_
#define __MTHIERARCHYPATH_H_

#include "resource.h"       // main symbols

//#include <metra.h>
#include <mtcom.h>
#include <comdef.h>
#include <PathRegEx.h>


class ATL_NO_VTABLE CMTHierarchyPath : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTHierarchyPath, &CLSID_MTHierarchyPath>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTHierarchyPath, &IID_IMTHierarchyPath, &LIBID_HIERARCHYPATHLib>
{
public:
	CMTHierarchyPath() : msPattern(_bstr_t()), msRequestedPath(_bstr_t()), mbCs(false), mpPattern(NULL)
	{
		m_pUnkMarshaler = NULL;
	}
	virtual ~CMTHierarchyPath()
	{
		if (mpPattern)
		{
			delete mpPattern;
			mpPattern = NULL;
		}
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTHIERARCHYPATH)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTHierarchyPath)
	COM_INTERFACE_ENTRY(IMTHierarchyPath)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTHierarchyPath
public:
	STDMETHOD(Implies)(/*[in]*/BSTR aPath, /*[out, retval]*/VARIANT_BOOL* aMatch);
	STDMETHOD(get_CaseSensitive)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_CaseSensitive)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_Pattern)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Pattern)(/*[in]*/ BSTR newVal);
private:
	_bstr_t msPattern;
	_bstr_t msRequestedPath;
	bool mbCs;
	CMTPathRegEx* mpPattern;
};

#endif //__MTHIERARCHYPATH_H_
