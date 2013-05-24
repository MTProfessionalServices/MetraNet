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

#ifndef __MTPROPERTIES_H_
#define __MTPROPERTIES_H_

#include "resource.h"       // main symbols
#include <map>

namespace MTPropertiesNamespace
{
	class _CopyMapItem;
	typedef std::map<CComBSTR, CComPtr<IMTProperty> > PropMap;
	typedef CComEnumOnSTL<IEnumVARIANT, &IID_IEnumVARIANT, VARIANT, _CopyMapItem, PropMap> VarEnum;
	typedef ICollectionOnSTLImpl<IMTProperties, PropMap, VARIANT, _CopyMapItem, VarEnum> CollImpl;

	class _CopyMapItem
	{
	public:
		static HRESULT copy(VARIANT* p1, 
							const std::pair<const CComBSTR, CComPtr<IMTProperty> >* p2) 
		{
			CComPtr<IMTProperty> p = p2->second;
			CComVariant var = p;
			return VariantCopy(p1, &var);
		}
		
		static void init(VARIANT* p) {p->vt = VT_EMPTY;}
		static void destroy(VARIANT* p) {VariantClear(p);}
	};
}

/////////////////////////////////////////////////////////////////////////////
// CMTProperties
class ATL_NO_VTABLE CMTProperties : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTProperties, &CLSID_MTProperties>,
	public ISupportErrorInfo,
	public IDispatchImpl<MTPropertiesNamespace::CollImpl, &IID_IMTProperties, &LIBID_MTPRODUCTCATALOGLib>
{
public:
	CMTProperties();
	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPROPERTIES)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTProperties)
	COM_INTERFACE_ENTRY(IMTProperties)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTProperties
public:
	STDMETHOD(get_Item)(/*[in]*/ VARIANT aKey, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(Add)(/*[in]*/ IMTPropertyMetaData* aMetaData, /*[out, retval]*/ IMTProperty** aProp );
	STDMETHOD(Exist)(/*[in]*/ VARIANT aKey, /*[out, retval]*/ VARIANT_BOOL* pVal);
	STDMETHOD(ToString)(/*[out, retval]*/ BSTR* pVal);

private:
	_bstr_t PropertyToString(IMTProperty* apProp, _bstr_t aIndent);

//data
		CComPtr<IUnknown> mUnkMarshalerPtr;

};

#endif //__MTPROPERTIES_H_
