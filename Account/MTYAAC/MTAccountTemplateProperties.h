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

#ifndef __MTACCOUNTTEMPLATEPROPERTIES_H_
#define __MTACCOUNTTEMPLATEPROPERTIES_H_

#include "resource.h"       // main symbols
#include <mtprogids.h>       // main symbols
#include <MTCollectionImpl.h>

/////////////////////////////////////////////////////////////////////////////
// CMTAccountTemplateProperties
class ATL_NO_VTABLE CMTAccountTemplateProperties : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccountTemplateProperties, &CLSID_MTAccountTemplateProperties>,
	public ISupportErrorInfo,
	public MTCollectionImplEx<IMTAccountTemplateProperties, &IID_IMTAccountTemplateProperties, &LIBID_MTYAACLib>
{
public:
	CMTAccountTemplateProperties()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTTEMPLATEPROPERTIES)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountTemplateProperties)
	COM_INTERFACE_ENTRY(IMTCollectionReadOnly)
	COM_INTERFACE_ENTRY(IMTCollectionEx)
	COM_INTERFACE_ENTRY(IMTAccountTemplateProperties)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
    HRESULT hr = mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);
    if(FAILED(hr))
      return hr;
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

// IMTAccountTemplateProperties
public:
	STDMETHOD(Add)(/*[in]*/ BSTR aName,/*[in]*/ BSTR aValue, /*[in, optional]*/VARIANT aType, /*[out, retval]*/ IMTAccountTemplateProperty** ppProp);
private:
  MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
};

#endif //__MTACCOUNTTEMPLATEPROPERTIES_H_
