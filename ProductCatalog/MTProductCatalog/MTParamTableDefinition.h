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

#ifndef __MTPARAMTABLEDEFINITION_H_
#define __MTPARAMTABLEDEFINITION_H_

#include "resource.h"       // main symbols

#include <MTObjectCollection.h>
#include "PropertiesBase.h"

/////////////////////////////////////////////////////////////////////////////
// CMTParamTableDefinition
class ATL_NO_VTABLE CMTParamTableDefinition : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTParamTableDefinition, &CLSID_MTParamTableDefinition>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTParamTableDefinition, &IID_IMTParamTableDefinition, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase
{
public:
	DEFINE_MT_PCBASE_METHODS
	DEFINE_MT_PROPERTIES_BASE_METHODS

	CMTParamTableDefinition();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPARAMTABLEDEFINITION)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTParamTableDefinition)
	COM_INTERFACE_ENTRY(IMTParamTableDefinition)
	COM_INTERFACE_ENTRY(IMTPCBase)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct();

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTParamTableDefinition
public:
	STDMETHOD(GetNonICBRateSchedulesByPriceableItemTypeAsRowset)(/*[in]*/ long aPriceableItemTypeID, /*[out, retval]*/ IMTRowSet **apRowset);
	STDMETHOD(GetRateSchedulesByPriceableItemTypeAsRowset)(/*[in]*/ long idPriceableItemTypeID, /*[out, retval]*/ IMTRowSet **apRowset);
	STDMETHOD(GetRateSchedulesByPriceListAsRowset)(long aPricelistID, long aPITemplate, /*[out, retval]*/IMTRowSet** apRowset);
	STDMETHOD(GetNonICBRateSchedulesAsRowset)(/*[in, optional]*/ VARIANT aFilter, /*[out, retval]*/IMTRowSet** apRowset);
	STDMETHOD(GetRateSchedulesAsRowset)(/*[in, optional]*/ VARIANT aFilter, /*[in, optional]*/ VARIANT aIncludeHidden, /*[out, retval]*/IMTRowSet** apRowset);
	STDMETHOD(GetRateSchedule)(long aScheduleID, /*[out, retval]*/ IMTRateSchedule * * apSchedule);
	STDMETHOD(CreateRateSchedule)(/*[in]*/ long aPriceListID, /*[in]*/ long aPrcItemTmplID, /*[out, retva]*/ IMTRateSchedule * * apSchedule);
	STDMETHOD(get_DBTableName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DBTableName)(/*[in]*/ BSTR newVal);
	STDMETHOD(AddActionMetaData)(/*[out, retval]*/ IMTActionMetaData * * pVal);
	STDMETHOD(AddConditionMetaData)(/*[out, retval]*/ IMTConditionMetaData * * pVal);
	STDMETHOD(Save)();
	STDMETHOD(get_ActionMetaData)(/*[out, retval]*/ IMTCollection * *pVal);
	STDMETHOD(get_ConditionMetaData)(/*[out, retval]*/ IMTCollection * *pVal);
	STDMETHOD(get_HelpURL)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_HelpURL)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ActionHeader)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ActionHeader)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ConditionHeader)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ConditionHeader)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_IndexedProperty)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_IndexedProperty)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DisplayName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DisplayName)(/*[in]*/ BSTR newVal);
	STDMETHOD(RemoveRateSchedule)(/*[in]*/ long aRateScheduleID);


private:
	//overridden PropertiesBase methods
	HRESULT OnGetProperties();

	STDMETHOD(DoGetRateSchedulesAsRowset)(VARIANT_BOOL aIncludeICB, VARIANT aIncludeHidden, VARIANT aFilter, IMTRowSet **apRowset);
	STDMETHOD(DoGetRateSchedulesByPriceableItemAsRowset)(long aPriceableItemID, VARIANT_BOOL aIncludeICB, IMTRowSet **apRowset);

	HRESULT LoadSecondaryDataIfNeeded();

	bool mSecondaryDataHasBeenLoaded;
	bool mSecondaryDataLoading;
	MTObjectCollection<IMTConditionMetaData> mConditions;
	MTObjectCollection<IMTActionMetaData> mActions;
};


#endif //__MTPARAMTABLEDEFINITION_H_
