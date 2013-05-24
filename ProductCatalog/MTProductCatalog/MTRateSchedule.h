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

#ifndef __MTRATESCHEDULE_H_
#define __MTRATESCHEDULE_H_

#include "resource.h"       // main symbols

#include <comdef.h>
#include <PCConfig.h>
#include <ConfigDir.h>
#include <ConfigChange.h>

#include "PropertiesBase.h"

#import <MTConfigLib.tlb>

using MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr;
using MTPRODUCTCATALOGLib::IMTRuleSetPtr;
using MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr;
using MTPRODUCTCATALOGLib::IMTPriceListPtr;
using MTPRODUCTCATALOGLib::IMTProductCatalogPtr;
using MTPRODUCTCATALOGLib::IMTRateSchedulePtr;

/////////////////////////////////////////////////////////////////////////////
// CMTRateSchedule
class ATL_NO_VTABLE CMTRateSchedule : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTRateSchedule, &CLSID_MTRateSchedule>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTRateSchedule, &IID_IMTRateSchedule, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase
{
public:
	CMTRateSchedule();

DEFINE_MT_PCBASE_METHODS
DEFINE_MT_PROPERTIES_BASE_METHODS

DECLARE_REGISTRY_RESOURCEID(IDR_MTRATESCHEDULE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTRateSchedule)
	COM_INTERFACE_ENTRY(IMTRateSchedule)
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

// IMTRateSchedule
public:
	STDMETHOD(get_ScheduleType)(MTPriceListMappingType *pVal);
	STDMETHOD(put_ScheduleType)(MTPriceListMappingType newVal);
	STDMETHOD(GetPriceList)(/*[out, retval]*/ IMTPriceList * *pVal);
	STDMETHOD(GetParameterTable)(/*[out, retval]*/ IMTParamTableDefinition * *pVal);
	STDMETHOD(get_RuleSet)(/*[out, retval]*/ IMTRuleSet * *pVal);
	STDMETHOD(get_EffectiveDate)(/*[out, retval]*/ IMTPCTimeSpan * *pVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_PriceListID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_PriceListID)(/*[in]*/ long newVal);
	STDMETHOD(get_ParameterTableID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ParameterTableID)(/*[in]*/ long newVal);
	STDMETHOD(get_TemplateID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_TemplateID)(/*[in]*/ long newVal);
	STDMETHOD(Save)();
	STDMETHOD(SaveRules)();
	STDMETHOD(SaveWithRules)();
	STDMETHOD(CreateCopy)(/*[out, retval]*/ IMTRateSchedule * *pVal);
  STDMETHOD(GetDatedRuleSet)(/*[in, optional]*/ VARIANT aRefDate, /*[out, retval]*/ IMTRuleSet * *pVal);

//CMTPCBase override
	virtual void OnSetSessionContext(IMTSessionContext* apSessionContext);

public:
#if 0
	// used by the factory

	void Setup(long rsID,
						 long effectiveDateID,
						 long paramTableID,
						 long priceListID);
#endif
private:
	HRESULT DoSave(VARIANT_BOOL aSaveRateSchedule, VARIANT_BOOL aSaveRules );

	//long mID;
	_bstr_t mDescription;

	IMTPCTimeSpanPtr mEffectiveDate;
	IMTRuleSetPtr mRuleSet;
	//IMTParamTableDefinitionPtr mParamTable;
	//IMTPriceListPtr mPriceList;

	//long mEffectiveDateID;
	//long mParamTableID;
	//long mPriceListID;
	// if true, rules exist but they haven't been read yet
	BOOL mRuleSetAvailable;
};

#endif //__MTRATESCHEDULE_H_
