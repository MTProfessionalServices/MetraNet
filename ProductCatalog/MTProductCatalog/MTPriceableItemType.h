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
* $Header: c:\development35\ProductCatalog\MTProductCatalog\MTPriceableItemType.h, 22, 11/13/2002 6:09:19 PM, Fabricio Pettena$
* 
***************************************************************************/

#ifndef __MTPRICEABLEITEMTYPE_H_
#define __MTPRICEABLEITEMTYPE_H_

#include "resource.h"       // main symbols
#include "PropertiesBase.h"
#include "mtglobal_msg.h"
#include <MTObjectCollection.h>
#import <MetraTech.Pipeline.tlb> inject_statement("using namespace mscorlib; using ROWSETLib::IMTSQLRowsetPtr; using ROWSETLib::IMTSQLRowset;") no_function_mapping
#import <MetraTech.Localization.tlb> inject_statement("using namespace mscorlib;") no_function_mapping
#import <MetraTech.Adjustments.tlb> inject_statement("using namespace mscorlib; using namespace MetraTech_Pipeline; using namespace MetraTech_Localization;")//rename ("EOF", "RowsetEOF") no_function_mapping


/////////////////////////////////////////////////////////////////////////////
// CMTPriceableItemType
class ATL_NO_VTABLE CMTPriceableItemType : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPriceableItemType, &CLSID_MTPriceableItemType>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPriceableItemType, &IID_IMTPriceableItemType, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase
{
	DEFINE_MT_PCBASE_METHODS
	DEFINE_MT_PROPERTIES_BASE_METHODS

public:
	CMTPriceableItemType();
	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRICEABLEITEMTYPE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPriceableItemType)
	COM_INTERFACE_ENTRY(IMTPriceableItemType)
	COM_INTERFACE_ENTRY(IMTPCBase)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
END_COM_MAP()


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTPriceableItemType
public:
	STDMETHOD(get_AdjustmentTypes)(/*[out, retval]*/ IMTCollection* *pVal);
	STDMETHOD(put_AdjustmentTypes)(/*[in]*/ IMTCollection* newVal);
	STDMETHOD(GetParamTableDefinitionsAsRowset)(/*[out, retval]*/IMTRowSet** apRowset);
	STDMETHOD(FindCounterPropertyDefinitionsAsRowset)(/*in*/VARIANT aFilter, /*[out, retval]*/IMTRowSet** apRowset);
	STDMETHOD(RemoveCounterPropertyDefinition)(/*[in]*/long aID);
	STDMETHOD(GetCounterPropertyDefinitions)(/*[out, retval]*/IMTCollection** apColl);
	STDMETHOD(CreateCounterPropertyDefinition)(/*[out,retval]*/IMTCounterPropertyDefinition** apCPD);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_Kind)(/*[out, retval]*/ MTPCEntityType *pVal);
	STDMETHOD(put_Kind)(/*[in]*/ MTPCEntityType newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ServiceDefinition)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ServiceDefinition)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ProductView)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ProductView)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ParentID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ParentID)(/*[in]*/ long newVal);
	STDMETHOD(get_ConstrainSubscriberCycle)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_ConstrainSubscriberCycle)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(Save)();
	STDMETHOD(GetParent)(/*[out, retval]*/ IMTPriceableItemType** apType);
	STDMETHOD(CreateChild)(/*[out, retval]*/ IMTPriceableItemType** apChildType);
	STDMETHOD(RemoveChild)(/*[in]*/ long aID);
	STDMETHOD(GetChildren)(/*[out, retval]*/ IMTCollection** apColl);
	STDMETHOD(GetChild)(/*[in]*/long aID, /*[out, retval]*/IMTPriceableItemType** apType);
	STDMETHOD(AddParamTableDefinition)(/*[in]*/ long aParamTblDefID);
	STDMETHOD(RemoveParamTableDefinition)(/*[in]*/ long aParamTblDefID);
	STDMETHOD(GetParamTableDefinitions)(/*[out, retval]*/ IMTCollection** apColl);
	STDMETHOD(CreateTemplate)(/*[in, optional]*/ VARIANT aCreateChildren, /*[out, retval]*/ IMTPriceableItem** apPrcItemTmpl);
	STDMETHOD(RemoveTemplate)(/*[in]*/ long aID);
	STDMETHOD(GetTemplates)(/*[out, retval]*/ IMTCollection** apColl);
	STDMETHOD(GetProductOfferings)(/*[out, retval]*/ IMTCollection** apProdOffs);
	STDMETHOD(CreateCharge)(/*[out, retval]*/ IMTCharge** apCharge);
	STDMETHOD(RemoveCharge)(/*[in]*/ long aChargeID);
	STDMETHOD(GetCharges)(/*[out, retval]*/ IMTCollection** apColl);
	STDMETHOD(GetProductViewObject)(/*[out, retval]*/ IProductView** apPV);
  //STDMETHOD(CreateAdjustmentType)(IAdjustmentType** apAdjustmentType);
  //fix me later
  STDMETHOD(CreateAdjustmentType)(IDispatch** apAdjustmentType);



	//data
private:
	CComPtr<IUnknown> mUnkMarshalerPtr;
protected:
  MTObjectCollection<MetraTech_Adjustments::IAdjustmentType> mAdjustmentTypeCol;

};

#endif //__MTPRICEABLEITEMTYPE_H_
