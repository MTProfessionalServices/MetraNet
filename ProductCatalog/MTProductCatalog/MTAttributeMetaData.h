/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header$
* 
***************************************************************************/

#ifndef __MTATTRIBUTEMETADATA_H_
#define __MTATTRIBUTEMETADATA_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTAttributeMetaData
class ATL_NO_VTABLE CMTAttributeMetaData : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAttributeMetaData, &CLSID_MTAttributeMetaData>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAttributeMetaData, &IID_IMTAttributeMetaData, &LIBID_MTPRODUCTCATALOGLib>
{
public:
	CMTAttributeMetaData();
	HRESULT FinalConstruct();
	void FinalRelease();


DECLARE_REGISTRY_RESOURCEID(IDR_MTATTRIBUTEMETADATA)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAttributeMetaData)
	COM_INTERFACE_ENTRY(IMTAttributeMetaData)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAttributeMetaData
public:
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DefaultValue)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_DefaultValue)(/*[in]*/ VARIANT newVal);


private:
	//data 
	CComPtr<IUnknown> mUnkMarshalerPtr;
	_bstr_t       mName;
	_variant_t    mDefaultValue;
};

#endif //__MTATTRIBUTEMETADATA_H_
