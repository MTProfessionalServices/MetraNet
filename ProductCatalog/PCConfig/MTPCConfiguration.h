/**************************************************************************
 * @doc SIMPLE
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Boris Partensky
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#ifndef __MTPCCONFIGURATION_H_
#define __MTPCCONFIGURATION_H_

#include "resource.h"       // main symbols
#include "metra.h"
#include <PCConfig.h>
#include <ConfigDir.h>
#include <ConfigChange.h>
#include <autocritical.h>

#include <NTLogger.h>
#include <mtglobal_msg.h>
#include <mtprogids.h>
#include <mtcomerr.h>

#include <map>
#include <string>

#import <MTConfigLib.tlb>

using namespace std;

class BusinessRule
{
public:
	BusinessRule(MTPC_BUSINESS_RULE aRule, BOOL aEnabled);
	MTPC_BUSINESS_RULE GetType() {return mBusinessRule;}
	BOOL IsEnabled() {return mbEnabled;}
  void SetEnableStatus(BOOL bEnabled) { mbEnabled = bEnabled; }
private:
	MTPC_BUSINESS_RULE mBusinessRule;
	BOOL mbEnabled;
};


typedef map<MTPC_BUSINESS_RULE, BusinessRule*> BUSINESSRULES;

/////////////////////////////////////////////////////////////////////////////
// CMTPCConfiguration
class ATL_NO_VTABLE CMTPCConfiguration : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPCConfiguration, &CLSID_MTPCConfiguration>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPCConfiguration, &IID_IMTPCConfiguration, &LIBID_PCCONFIGLib>,
	public ConfigChangeObserver
{
public:
	CMTPCConfiguration();
	~CMTPCConfiguration();
	
DECLARE_REGISTRY_RESOURCEID(IDR_MTPCCONFIGURATION)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPCConfiguration)
	COM_INTERFACE_ENTRY(IMTPCConfiguration)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct();
	
	void FinalRelease()
	{
		mObserver.StopThread(INFINITE);
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTPCConfiguration
public:
	STDMETHOD(OverrideBusinessRule)(MTPC_BUSINESS_RULE aBusRule,VARIANT_BOOL aVal);
	STDMETHOD(GetBatchSubmitTimeout)(/*[out, retval]*/long* apTimeout);
	STDMETHOD(IsBusinessRuleEnabled)(/*[in]*/MTPC_BUSINESS_RULE aBusRule, /*[out, retval]*/VARIANT_BOOL* apEnabledFlag);
	STDMETHOD(GetPLChaining)(/*[out, retval]*/MTPC_PRICELIST_CHAIN_RULE* apChainRule);
  STDMETHOD(GetDebugTempTables)(/*[out, retval]*/VARIANT_BOOL* apDTT);
  STDMETHOD(GetRSCacheMaxSize)(/*[out, retval]*/long* max);
	STDMETHOD(Load)();

	virtual void ConfigurationHasChanged();

private:
	ConfigChangeObservable mObserver;
	MTConfigLib::IMTConfigPtr mConfig;
	NTThreadLock mLock;
	NTLogger mLogger;
	BUSINESSRULES* mBusinessRules;
  VARIANT_BOOL mbDebugTempTables;
	MTPC_BUSINESS_RULE ConvertBRStringToEnum(const wchar_t* aBusinessRule);
	const wchar_t* ConvertEnumToBRString(MTPC_BUSINESS_RULE aBusinessRule);
	MTPC_PRICELIST_CHAIN_RULE ConvertPLChainingStringToEnum(const wchar_t* aBusinessRule);
	std::string mConfigFile;
	long mlBatchTimeout;
  long mlRSCacheMaxSize;
	
	MTPC_PRICELIST_CHAIN_RULE mPLChainingRule;
};

#endif //__MTPCCONFIGURATION_H_
