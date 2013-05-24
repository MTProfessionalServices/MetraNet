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

#ifndef __MTATTRIBUTEMETADATASET_H_
#define __MTATTRIBUTEMETADATASET_H_

#include "resource.h"       // main symbols
#include <map>

namespace MTAttributeMetaDataSetNamespace
{
	class _CopyMapItem;
	typedef std::map<CComBSTR, CComPtr<IMTAttributeMetaData> > AttrMap;
	typedef CComEnumOnSTL<IEnumVARIANT, &IID_IEnumVARIANT, VARIANT, _CopyMapItem, AttrMap> VarEnum;
	typedef ICollectionOnSTLImpl<IMTAttributeMetaDataSet, AttrMap, VARIANT, _CopyMapItem, VarEnum> CollImpl;

	class _CopyMapItem
	{
	public:
		static HRESULT copy(VARIANT* p1, 
							const std::pair<const CComBSTR, CComPtr<IMTAttributeMetaData> >* p2) 
		{
			CComPtr<IMTAttributeMetaData> p = p2->second;
			CComVariant var = p;
			return VariantCopy(p1, &var);
		}
		
		static void init(VARIANT* p) {p->vt = VT_EMPTY;}
		static void destroy(VARIANT* p) {VariantClear(p);}
	};
}

/////////////////////////////////////////////////////////////////////////////
// CMTAttributeMetaDataSet
class ATL_NO_VTABLE CMTAttributeMetaDataSet : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAttributeMetaDataSet, &CLSID_MTAttributeMetaDataSet>,
	public ISupportErrorInfo,
	public IDispatchImpl<MTAttributeMetaDataSetNamespace::CollImpl, &IID_IMTAttributeMetaDataSet, &LIBID_MTPRODUCTCATALOGLib>
{
public:
	CMTAttributeMetaDataSet();
	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTATTRIBUTEMETADATASET)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAttributeMetaDataSet)
	COM_INTERFACE_ENTRY(IMTAttributeMetaDataSet)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAttributeMetaDataSet
public:
	STDMETHOD(get_Item)(/*[in]*/ VARIANT aKey, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(CreateMetaData)(/*[in]*/ BSTR aAttributeName, /*[out, retval]*/ IMTAttributeMetaData** apMetaData);

//data
private:
	CComPtr<IUnknown> mUnkMarshalerPtr;
};

#endif //__MTATTRIBUTEMETADATASET_H_
