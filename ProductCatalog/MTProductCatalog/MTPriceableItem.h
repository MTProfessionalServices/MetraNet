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
* $Header: c:\development35\ProductCatalog\MTProductCatalog\MTPriceableItem.h, 32, 11/13/2002 7:28:24 PM, David Blair$
* 
***************************************************************************/

#ifndef __MTPRICEABLEITEM_H_
#define __MTPRICEABLEITEM_H_

#include "resource.h"       // main symbols
#include "PropertiesBase.h"
#include <MTObjectCollection.h>
#include <map>
#import <MetraTech.Pipeline.tlb> inject_statement("using namespace mscorlib; using ROWSETLib::IMTSQLRowsetPtr; using ROWSETLib::IMTSQLRowset;") no_function_mapping
#import <MetraTech.Localization.tlb> inject_statement("using namespace mscorlib;") no_function_mapping
#import <MetraTech.Adjustments.tlb> inject_statement("using namespace mscorlib; using namespace MetraTech_Pipeline; using namespace MetraTech_Localization;")

/////////////////////////////////////////////////////////////////////////////
// CMTPriceableItem
class CMTPriceableItem :
 public CMTPCBase,
 public PropertiesBase
{
public:
	CMTPriceableItem();
	~CMTPriceableItem();

// IMTPriceableItem
public:
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_Kind)(/*[out, retval]*/ MTPCEntityType *pVal);
	STDMETHOD(put_Kind)(/*[in]*/ MTPCEntityType newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DisplayName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DisplayName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DisplayNames)(/*[out, retval]*/ IDispatch **pVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_PriceableItemType)(/*[out, retval]*/ IMTPriceableItemType* *pVal);
	STDMETHOD(put_PriceableItemType)(/*[in]*/ IMTPriceableItemType* newVal);
	STDMETHOD(get_ParentID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ParentID)(/*[in]*/ long newVal);
	STDMETHOD(get_TemplateID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_TemplateID)(/*[in]*/ long newVal);
	STDMETHOD(get_ProductOfferingID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ProductOfferingID)(/*[in]*/ long newVal);
	STDMETHOD(get_CreateChildren)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_CreateChildren)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(Save)(IMTPriceableItem* apPrcItem);
	STDMETHOD(GetParent)(/*[out, retval]*/ IMTPriceableItem** apParentPrcItem);
	STDMETHOD(GetChildren)(/*[out, retval]*/ IMTCollection** apColl);
	STDMETHOD(GetChildrenAsRowset)(/*[out, retval]*/ ::IMTRowSet** apRowset);
	STDMETHOD(GetChild)(/*[in]*/long aID, /*[out, retval]*/IMTPriceableItem** apPrcItem);
	STDMETHOD(GetPriceListMappingsAsRowset)(/*[out, retval]*/ ::IMTRowSet** apRowset);
	STDMETHOD(GetNonICBPriceListMappingsAsRowset)(/*[out, retval]*/ ::IMTRowSet **apRowset);
	STDMETHOD(GetPriceListMapping)(/*[in]*/ long aParamTblDefID, /*[out, retval]*/ IMTPriceListMapping** apPrcLstMap);
	STDMETHOD(SetPriceListMapping)(/*[in]*/ long aParamTblDefID, /*[in]*/ long aPrcLstID);
	STDMETHOD(IsTemplate)(/*[out, retval]*/ VARIANT_BOOL* apIsTemplate);
	STDMETHOD(GetTemplate)(/*[out, retval]*/ IMTPriceableItem** apPrcItemTemplate);
	STDMETHOD(SetTemplate)(/*[in]*/ IMTPriceableItem* apPrcItemTemplate);
	STDMETHOD(CreateInstance)(IMTPriceableItem* apPrcItemThis, /*[out, retval]*/ IMTPriceableItem** apPrcItemInstance);
	STDMETHOD(CopyTo)(IMTPriceableItem* apPrcItemThis, /*[in]*/IMTPriceableItem* apTarget);
	STDMETHOD(CanBeModified)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(CheckConfiguration)(IMTPriceableItem* apPrcItemThis, /*[out, retval]*/ IMTCollection** apErrors);
	STDMETHOD(GetProductOffering)(/*[out, retval]*/ IMTProductOffering** apProdOff);
	STDMETHOD(GetInstances)(/*[out, retval]*/ IMTCollection** apInstances);
	//STDMETHOD(CreateAdjustment)(IAdjustmentType** apAdjustment);
  //fix me later
	STDMETHOD(CreateAdjustment)(IMTPriceableItem* apPrcItemThis, long aAjTypeID, IDispatch** apAdjustment);
  STDMETHOD(RemoveAdjustment)(IMTPriceableItem* apPrcItemThis, long aAjID);
  STDMETHOD(RemoveAdjustmentOfType)(IMTPriceableItem* apPrcItemThis, long aAjTypeID);
	STDMETHOD(GetAdjustments)(IMTCollection** apAdjustments);
	STDMETHOD(SetAdjustments)(IMTCollection* apAdjustments);
	STDMETHOD(GetAvailableAdjustmentTypesAsRowset)(IMTPriceableItem* apPrcItemThis, /*[out, retval]*/ ::IMTRowSet **apRowset);
  STDMETHOD(get_DisplayDescriptions)(/*[out, retval]*/ IDispatch **pVal);

protected:
	// overridadable methods:
	
	// copy the members that are not in the base class
	// can throw _com_error 
	virtual void CopyNonBaseMembersTo(IMTPriceableItem* apTarget) {;}

	virtual void CheckConfigurationForDerived(IMTCollection* apErrors) {;}

	// This predicate allows a priceable item to have configuration
	// parameters that turn various parameter tables "on" and "off".
	virtual bool IsParameterTableInUse(IMTParamTableDefinition* apParamTable) { return true; }

  void CopyAdjustmentsTo(IMTPriceableItem* apPrcItemThis, IMTPriceableItem* apTarget);

private:
	STDMETHOD(DoGetPriceListMappingsAsRowset)(VARIANT_BOOL aIncludeICB, ::IMTRowSet **apRowset);
	void CheckConfigurationForBase(IMTPriceableItem* apPrcItemThis, IMTCollection* apErrors);

	HRESULT CopyPriceListMappingsTo(IMTPriceableItem* apPrcItemThis,
																	IMTPriceableItem* apTarget);
  //MTObjectCollection<IAdjustment> mAdjustments; 
  MTObjectCollection<MetraTech_Adjustments::IAdjustment> mAdjustments;
  std::map<long, MetraTech_Adjustments::IAdjustmentPtr> mAjTypeMap;

	//data
	
	// mpTemplate is the pi template used for creation of instance.
	// It is needed to store a template that has not yet been created (in DB)
	// A not yet created template will be created when the product offering
	// is saved.
	// NULL for PI templates, and for PI instances that have been created already
	CComPtr<IMTPriceableItem> mpTemplate; 

	VARIANT_BOOL mCreateChildren;
};

// macro that needs to be included in all derived classes
#define DEFINE_MT_PRICABLE_ITEM_METHODS																\
	DEFINE_MT_PCBASE_METHODS																						\
	DEFINE_MT_PROPERTIES_BASE_METHODS																		\
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal)											\
		{ return CMTPriceableItem::get_ID(pVal); }												\
	STDMETHOD(put_ID)(/*[in]*/ long newVal)															\
		{ return CMTPriceableItem::put_ID(newVal); }											\
	STDMETHOD(get_Kind)(/*[out, retval]*/ MTPCEntityType *pVal)					\
		{ return CMTPriceableItem::get_Kind(pVal); }											\
	STDMETHOD(put_Kind)(/*[in]*/ MTPCEntityType newVal)									\
		{ return CMTPriceableItem::put_Kind(newVal); }										\
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal)										\
		{ return CMTPriceableItem::get_Name(pVal); }											\
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal)														\
		{ return CMTPriceableItem::put_Name(newVal); }										\
	STDMETHOD(get_DisplayName)(/*[out, retval]*/ BSTR *pVal)						\
		{ return CMTPriceableItem::get_DisplayName(pVal); }								\
	STDMETHOD(put_DisplayName)(/*[in]*/ BSTR newVal)										\
		{ return CMTPriceableItem::put_DisplayName(newVal); }							\
	STDMETHOD(get_DisplayNames)(/*[out, retval]*/ IDispatch **pVal)     \
    { return CMTPriceableItem::get_DisplayNames(pVal); }              \
  STDMETHOD(get_DisplayDescriptions)(/*[out, retval]*/ IDispatch **pVal)     \
    { return CMTPriceableItem::get_DisplayDescriptions(pVal); }              \
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal)						\
		{ return CMTPriceableItem::get_Description(pVal); }								\
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal)										\
		{ return CMTPriceableItem::put_Description(newVal); }							\
	STDMETHOD(get_PriceableItemType)(/*[out, retval]*/ IMTPriceableItemType* *pVal) \
		{ return CMTPriceableItem::get_PriceableItemType(pVal); }					\
	STDMETHOD(put_PriceableItemType)(/*[in]*/ IMTPriceableItemType* newVal) \
		{ return CMTPriceableItem::put_PriceableItemType(newVal); }				\
	STDMETHOD(get_ParentID)(/*[out, retval]*/ long *pVal)								\
		{ return CMTPriceableItem::get_ParentID(pVal); }									\
	STDMETHOD(put_ParentID)(/*[in]*/ long newVal)												\
		{ return CMTPriceableItem::put_ParentID(newVal); }								\
	STDMETHOD(get_TemplateID)(/*[out, retval]*/ long *pVal)							\
		{ return CMTPriceableItem::get_TemplateID(pVal); }								\
	STDMETHOD(put_TemplateID)(/*[in]*/ long newVal)											\
		{ return CMTPriceableItem::put_TemplateID(newVal); }							\
	STDMETHOD(get_ProductOfferingID)(/*[out, retval]*/ long *pVal)			\
		{ return CMTPriceableItem::get_ProductOfferingID(pVal); }					\
	STDMETHOD(put_ProductOfferingID)(/*[in]*/ long newVal)							\
		{ return CMTPriceableItem::put_ProductOfferingID(newVal); }				\
	STDMETHOD(get_CreateChildren)(/*[out, retval]*/ VARIANT_BOOL *pVal)	\
		{ return CMTPriceableItem::get_CreateChildren(pVal); }						\
	STDMETHOD(put_CreateChildren)(/*[in]*/ VARIANT_BOOL newVal)					\
		{ return CMTPriceableItem::put_CreateChildren(newVal); }					\
	STDMETHOD(Save)()																										\
		{ return CMTPriceableItem::Save(this); }													\
	STDMETHOD(GetParent)(/*[out, retval]*/ IMTPriceableItem** apParentPrcItem) \
		{ return CMTPriceableItem::GetParent(apParentPrcItem); }					\
	STDMETHOD(GetChildren)(/*[out, retval]*/ IMTCollection** apColl)		\
		{ return CMTPriceableItem::GetChildren(apColl); }									\
	STDMETHOD(GetChildrenAsRowset)(/*[out, retval]*/ ::IMTRowSet** apRowset)							\
		{ return CMTPriceableItem::GetChildrenAsRowset(apRowset); }													\
	STDMETHOD(GetChild)(/*[in]*/long aID, /*[out, retval]*/IMTPriceableItem** apPrcItem)	\
		{ return CMTPriceableItem::GetChild(aID, apPrcItem); }															\
	STDMETHOD(GetPriceListMappingsAsRowset)(/*[out, retval]*/ ::IMTRowSet** apRowset)			\
		{ return CMTPriceableItem::GetPriceListMappingsAsRowset(apRowset); }								\
	STDMETHOD(GetNonICBPriceListMappingsAsRowset)(/*[out, retval]*/ ::IMTRowSet **apRowset) \
		{ return CMTPriceableItem::GetNonICBPriceListMappingsAsRowset(apRowset); }					\
	STDMETHOD(GetPriceListMapping)(/*[in]*/ long aParamTblDefID, /*[out, retval]*/ IMTPriceListMapping** apPrcLstMap) \
		{ return CMTPriceableItem::GetPriceListMapping(aParamTblDefID, apPrcLstMap); }			\
	STDMETHOD(SetPriceListMapping)(/*[in]*/ long aParamTblDefID, /*[in]*/ long aPrcLstID)	\
		{ return CMTPriceableItem::SetPriceListMapping(aParamTblDefID, aPrcLstID); }				\
	STDMETHOD(IsTemplate)(/*[out, retval]*/ VARIANT_BOOL* apIsTemplate)										\
		{ return CMTPriceableItem::IsTemplate(apIsTemplate); }															\
	STDMETHOD(GetTemplate)(/*[out, retval]*/ IMTPriceableItem** apPrcItemTemplate)				\
		{ return CMTPriceableItem::GetTemplate(apPrcItemTemplate); }												\
	STDMETHOD(SetTemplate)(/*[in]*/ IMTPriceableItem* apPrcItemTemplate)									\
		{ return CMTPriceableItem::SetTemplate(apPrcItemTemplate); }												\
	STDMETHOD(CreateInstance)(/*[out, retval]*/ IMTPriceableItem** apPrcItemInstance)			\
		{ return CMTPriceableItem::CreateInstance(this, apPrcItemInstance); }						    \
	STDMETHOD(CopyTo)(/*[out, retval]*/ IMTPriceableItem* apPrcItemInstance)							\
		{ return CMTPriceableItem::CopyTo(this, apPrcItemInstance); }												\
	STDMETHOD(CanBeModified)(/*[out, retval]*/ VARIANT_BOOL* pVal)												\
		{ return CMTPriceableItem::CanBeModified(pVal); }																		\
	STDMETHOD(CheckConfiguration)(/*[out, retval]*/ IMTCollection** apErrors)							\
		{ return CMTPriceableItem::CheckConfiguration(this, apErrors); }										\
	STDMETHOD(GetProductOffering)(/*[out, retval]*/ IMTProductOffering** apProdOff)				\
		{ return CMTPriceableItem::GetProductOffering(apProdOff); }													\
	STDMETHOD(GetInstances)(/*[out, retval]*/ IMTCollection** apPIInstances)							\
		{ return CMTPriceableItem::GetInstances(apPIInstances); }														\
  STDMETHOD(CreateAdjustment)(long aAjTypeID, /*[out, retval]*/ IDispatch** apAdjustment)				        \
		{ return CMTPriceableItem::CreateAdjustment(this, aAjTypeID, apAdjustment); }		  	\
  STDMETHOD(RemoveAdjustment)(long aAjID)				                                        \
		{ return CMTPriceableItem::RemoveAdjustment(this, aAjID); }                 		  	\
  STDMETHOD(RemoveAdjustmentOfType)(long aAdjustmentTypeID)				                                        \
		{ return CMTPriceableItem::RemoveAdjustmentOfType(this, aAdjustmentTypeID); }                 		  	\
	STDMETHOD(GetAdjustments)(/*[out, retval]*/ IMTCollection** apAdjustments)						\
	{ return CMTPriceableItem::GetAdjustments(apAdjustments); }														\
	STDMETHOD(SetAdjustments)(/*[in]*/ IMTCollection* apAdjustments)						\
		{ return CMTPriceableItem::SetAdjustments(apAdjustments); }														\
	STDMETHOD(GetAvailableAdjustmentTypesAsRowset)(/*[out, retval]*/ ::IMTRowSet** apRowset) \
		{ return CMTPriceableItem::GetAvailableAdjustmentTypesAsRowset(this, apRowset); }	 	 \


#endif //__MTPRICEABLEITEM_H_
