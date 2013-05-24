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

#ifndef __MTPROPERTYMETADATASET_H_
#define __MTPROPERTYMETADATASET_H_

#include "resource.h"       // main symbols
#include <map>


namespace MTPropertyMetaDataSetNamespace
{
	class _CopyMapItem;
	typedef std::map<CComBSTR, CComPtr<IMTPropertyMetaData> > PropMap;
	typedef CComEnumOnSTL<IEnumVARIANT, &IID_IEnumVARIANT, VARIANT, _CopyMapItem, PropMap> VarEnum;
	typedef ICollectionOnSTLImpl<IMTPropertyMetaDataSet, PropMap, VARIANT, _CopyMapItem, VarEnum> CollImpl;

	class _CopyMapItem
	{
	public:
		static HRESULT copy(VARIANT* p1, 
							const std::pair<const CComBSTR, CComPtr<IMTPropertyMetaData> >* p2) 
		{
			CComPtr<IMTPropertyMetaData> p = p2->second;
			CComVariant var = p;
			return VariantCopy(p1, &var);
		}
		
		static void init(VARIANT* p) {p->vt = VT_EMPTY;}
		static void destroy(VARIANT* p) {VariantClear(p);}
	};
}

/////////////////////////////////////////////////////////////////////////////
// CMTPropertyMetaDataSet
class ATL_NO_VTABLE CMTPropertyMetaDataSet : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPropertyMetaDataSet, &CLSID_MTPropertyMetaDataSet>,
	public ISupportErrorInfo,
	public IDispatchImpl<MTPropertyMetaDataSetNamespace::CollImpl, &IID_IMTPropertyMetaDataSet, &LIBID_MTPRODUCTCATALOGLib>
{
public:
	CMTPropertyMetaDataSet();
	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPROPERTYMETADATASET)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPropertyMetaDataSet)
	COM_INTERFACE_ENTRY(IMTPropertyMetaDataSet)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTPropertyMetaDataSet
public:
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR val);
	STDMETHOD(get_TableName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_TableName)(/*[in]*/ BSTR val);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR val);
	STDMETHOD(DBAliasNameToDisplayName)(/*[in]*/ BSTR aDBAliasName, /*[out, retval]*/ BSTR* apDisplayName);
	STDMETHOD(RemoveExtendedProperties)(/*[in]*/ IMTSessionContext* apCtxt, IMTProperties* apProperties);
	STDMETHOD(UpdateProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTProperties *pProperties, /*[in]*/ VARIANT_BOOL bOverridableOnly, /*[in]*/ BSTR aTableName, /*[in]*/ BSTR aExtraUpdates);
	STDMETHOD(PropagateExtendedProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTProperties* apProperties);
	STDMETHOD(PropagateProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTProperties* apProperties, /*[in]*/ BSTR aTableName, /*[in]*/ BSTR aExtraUpdateString);
	STDMETHOD(UpsertExtendedProperties)(/*[in]*/ IMTSessionContext* apCtxt, IMTProperties* pProperties, /*[in]*/ VARIANT_BOOL aOverrideableOnly);
	STDMETHOD(GetPropertySQL)(/*[in]*/VARIANT aID, /*[in]*/ BSTR aBaseTableName, /*[in]*/ VARIANT_BOOL aSummaryViewOnly, /*[in,out]*/ BSTR* pSelectList,/*[in,out]*/ BSTR* pJoinList);
	STDMETHOD(PopulateProperties)(/*[in]*/ IMTProperties* pProperties,/*[in]*/ IMTRowSet *pRowset);

	STDMETHOD(TranslateFilter)(VARIANT aInFilter,/*[in]*/ IMTDataFilter** pFilter);
	STDMETHOD(get_Item)(/*[in]*/ VARIANT aKey, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(CreateMetaData)(/*[in]*/ BSTR aPropertyName, /*[out, retval]*/ IMTPropertyMetaData** apMetaData);
	STDMETHOD(Exist)(/*[in]*/ VARIANT aKey, /*[out, retval]*/ VARIANT_BOOL* apExist);

private:
	enum PropertySetFlags //flags to specify the set of properties
		{	PROPSET_CORE              = 1,
			PROPSET_EXTENDED          = 2,
			PROPSET_OVERRIDEABLE      = 4,
			PROPSET_NON_OVERRIDEABLE  = 8
		};

	struct MTMapItem
	{
		std::string first;
		std::string second;
		std::string third;
	};

	void LoadTableMap(std::map<string,MTMapItem>& arTableMap,
										IMTProperties *apProperties, 
										int aFlags, //of type PropertySetFlags
										BSTR* apTableName = NULL);
	
//data

	CComPtr<IUnknown> mUnkMarshalerPtr;

	_bstr_t mName;
	_bstr_t mTableName;
	_bstr_t mDescription;
};

#endif //__MTPROPERTYMETADATASET_H_
