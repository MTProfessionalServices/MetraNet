/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Travis Gebhardt
* $Header$
* 
***************************************************************************/


// MTBillingCycleConfig.h : Declaration of the CMTBillingCycleConfig

#ifndef __MTBILLINGCYCLECONFIG_H_
#define __MTBILLINGCYCLECONFIG_H_

#include "resource.h"       // main symbols
#include <metra.h>
#include <mtcom.h>
#include <mtprogids.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <ConfigDir.h>
#include <MTBillingCycle.h>
#include <MTTimePoint.h>

#import "MTEnumConfigLib.tlb"
#import "MTConfigLib.tlb"


//STL includes
#include <vector>
#include <string>

typedef std::vector<CComVariant> BillingCycleColl;


#define BILLCONFIG_CONFIG_SUBDIR  "UsageServer"
#define BILLCONFIG_XMLCONFIG_FILE "billingcycles.xml"

#define BILLCONFIG_LOGGER_TAG     "[BillingCycleConfig]"

//tags used in the billingcycle.xml file
#define BILLCONFIG_VERSION_TAG        "version"
#define BILLCONFIG_BILLINGCYCLES_TAG  "billingcycles"
#define BILLCONFIG_BILLINGCYCLE_TAG   "billingcycle"
#define BILLCONFIG_CYCLETYPE_TAG      "cycletype"
#define BILLCONFIG_CLOSINGPOINTS_TAG  "closingpoints"
#define BILLCONFIG_CLOSINGPOINT_TAG   "closingpoint"
#define BILLCONFIG_STARTINGPOINTS_TAG "startingpoints"
#define BILLCONFIG_STARTINGPOINT_TAG  "startingpoint"
#define BILLCONFIG_NAMEDDAY_TAG       "namedday"
#define BILLCONFIG_MONTH_TAG          "month"
#define BILLCONFIG_DAY_TAG            "day"
#define BILLCONFIG_YEAR_TAG           "year"
#define BILLCONFIG_LABEL_TAG          "label"

//recognized cycle types (given from enumerator)
#define BILLCONFIG_CYCLE_ONDEMAND     "on-demand"
#define BILLCONFIG_CYCLE_DAILY        "daily"
#define BILLCONFIG_CYCLE_WEEKLY       "weekly"
#define BILLCONFIG_CYCLE_BIWEEKLY     "bi-weekly"
#define BILLCONFIG_CYCLE_MONTHLY      "monthly"
#define BILLCONFIG_CYCLE_SEMIMONTHLY  "semi-monthly"
#define BILLCONFIG_CYCLE_QUARTERLY    "quarterly"    
#define BILLCONFIG_CYCLE_SEMIANNUALLY "semiannually" 
#define BILLCONFIG_CYCLE_ANNUALLY     "annually"



/////////////////////////////////////////////////////////////////////////////
// CMTBillingCycleConfig
class ATL_NO_VTABLE CMTBillingCycleConfig : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTBillingCycleConfig, &CLSID_MTBillingCycleConfig>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTBillingCycleConfig, &IID_IMTBillingCycleConfig, &LIBID_BILLINGCYCLECONFIGLib>
{
public:
	CMTBillingCycleConfig();
	~CMTBillingCycleConfig()
	{
		mCollection.clear();
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTBILLINGCYCLECONFIG)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTBillingCycleConfig)
	COM_INTERFACE_ENTRY(IMTBillingCycleConfig)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTBillingCycleConfig
public:
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(Add)(/*[in]*/ IMTBillingCycle* apBillingCycle);	

	STDMETHOD(Init)();

 private:
	NTLogger mLogger;

	BillingCycleColl mCollection;
};

#endif //__MTBILLINGCYCLECONFIG_H_
