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

#ifndef __MTPATHPARAMETER_H_
#define __MTPATHPARAMETER_H_

#include "resource.h"       // main symbols


/////////////////////////////////////////////////////////////////////////////
// CMTPathParameter
class ATL_NO_VTABLE CMTPathParameter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPathParameter, &CLSID_MTPathParameter>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPathParameter, &IID_IMTPathParameter, &LIBID_MTAUTHLib>
{
public:
	CMTPathParameter()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPATHPARAMETER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPathParameter)
	COM_INTERFACE_ENTRY(IMTPathParameter)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		//TODO: Is this correct?
		mWildCard = SINGLE;
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

// IMTPathParameter
public:
	STDMETHOD(get_WildCard)(/*[out, retval]*/ MTHierarchyPathWildCard *pVal);
	STDMETHOD(put_WildCard)(/*[in]*/ MTHierarchyPathWildCard newVal);
	STDMETHOD(get_Path)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Path)(/*[in]*/ BSTR newVal);
  STDMETHOD(get_LeafNode)(/*[out, retval]*/ BSTR *pVal);
private:
	_bstr_t mPath;
	MTHierarchyPathWildCard mWildCard;
};

#endif //__MTPATHPARAMETER_H_
