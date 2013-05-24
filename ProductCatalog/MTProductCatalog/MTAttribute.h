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

#ifndef __MTATTRIBUTE_H_
#define __MTATTRIBUTE_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTAttribute
class ATL_NO_VTABLE CMTAttribute : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAttribute, &CLSID_MTAttribute>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAttribute, &IID_IMTAttribute, &LIBID_MTPRODUCTCATALOGLib>
{
public:
	CMTAttribute();
	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTATTRIBUTE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAttribute)
	COM_INTERFACE_ENTRY(IMTAttribute)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
END_COM_MAP()


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAttribute
	STDMETHOD(get_Value)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_Value)(/*[in]*/ VARIANT newVal);
	STDMETHOD(GetMetaData)(/*[out, retval]*/ IMTAttributeMetaData** apMetaData);
	STDMETHOD(SetMetaData)(/*[in]*/ IMTAttributeMetaData* apMetaData);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);

public:

//data
private:
	CComPtr<IUnknown> mUnkMarshalerPtr;
	CComPtr<IMTAttributeMetaData> mMetaDataPtr;
	_variant_t mValue;

};

#endif //__MTATTRIBUTE_H_
