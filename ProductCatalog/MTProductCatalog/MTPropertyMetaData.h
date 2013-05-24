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

#ifndef __MTPROPERTYMETADATA_H_
#define __MTPROPERTYMETADATA_H_

#include "resource.h"       // main symbols

#import <MTEnumConfigLib.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTPropertyMetaData
class ATL_NO_VTABLE CMTPropertyMetaData : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPropertyMetaData, &CLSID_MTPropertyMetaData>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPropertyMetaData, &IID_IMTPropertyMetaData, &LIBID_MTPRODUCTCATALOGLib>
{
public:
	CMTPropertyMetaData();
	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPROPERTYMETADATA)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPropertyMetaData)
	COM_INTERFACE_ENTRY(IMTPropertyMetaData)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
END_COM_MAP()


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTPropertyMetaData
public:
	STDMETHOD(InitDefault)(PropValType aDataType,/*[in]*/ VARIANT aDefault);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DisplayName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DisplayName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DataType)(/*[out, retval]*/ PropValType *pVal);
	STDMETHOD(put_DataType)(/*[in]*/ PropValType newVal);
	STDMETHOD(get_DataTypeAsString)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_Length)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Length)(/*[in]*/ long newVal);
	STDMETHOD(get_EnumType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EnumType)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_EnumSpace)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EnumSpace)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Required)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Required)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_DefaultValue)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_DefaultValue)(/*[in]*/ VARIANT newVal);
	STDMETHOD(get_Extended)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Extended)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_PropertyGroup)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_PropertyGroup)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DBColumnName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DBColumnName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DBTableName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DBTableName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DBAliasName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_DBDataType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_Attributes)(/*[out, retval]*/ IMTAttributes* *pVal);
	STDMETHOD(put_Attributes)(/*[in]*/ IMTAttributes* newVal);
	STDMETHOD(get_Overrideable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_SummaryView)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_Enumerators)(/*[out, retval]*/ IMTEnumeratorCollection * *pVal);
	STDMETHOD(put_Enumerators)(/*[in]*/ IMTEnumeratorCollection * newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);


private:
	STDMETHOD(GetAttributeValue)(const char* apAttrName, VARIANT_BOOL *apVal);
	
	//data 
	CComPtr<IUnknown> mUnkMarshalerPtr;
	CComPtr<IMTAttributes> mAttributesPtr;
	_bstr_t       mName;
	_bstr_t		  mDisplayName;
	PropValType   mDataType;
	long          mLength;
	_bstr_t       mEnumSpace;
	_bstr_t       mEnumType;
	VARIANT_BOOL  mRequired;
	_variant_t    mDefaultValue;
	VARIANT_BOOL  mExtended;	
	_bstr_t       mPropertyGroup;
	_bstr_t       mDBColumnName;
	_bstr_t       mDBTableName;
	_bstr_t       mDescription;
	CComPtr<MTENUMCONFIGLib::IMTEnumeratorCollection> mEnumeratorCollection;

  bool          mIsOracle;
};



#endif //__MTPROPERTYMETADATA_H_
