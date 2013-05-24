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

#ifndef __PCCACHEIMPL_H__
#define __PCCACHEIMPL_H__

#include "MTProductCatalog.h"
#import <MTAuthLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
using MTAuthInterfacesLib::IMTSecurityPtr;

#include "PCConfig.h"
#import "PCConfig.tlb"
#import "AuditEventsLib.tlb"

#include <NTLogger.h>
#include <NTThreadLock.h>
#include <ConfigChange.h>

#include <RSCache.h>
#include <PCCache.h>
#include <lru.h>


// implementation for the product catalog cache
// clients should use class PCCache to access the cache
// implemented as singleton in PCCache.dll
// data is only loaded when needed and refreshed on ConfigChange event
class PCCacheImpl :  public ConfigChangeObserver
{
public:
  
	//refresh the cache
	static void Refresh();

	// get the logger
	static NTLogger& GetLogger();

	//get meta data
	static MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr GetMetaData(MTPCEntityType aEntityType);
	static MTPRODUCTCATALOGLib::IMTAttributeMetaDataSetPtr GetAttributeMetaData();
	static AuditEventsLib::IAuditorPtr GetAuditor();

	// get configuration
	static PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE GetPLChaining();
	static BOOL IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE aRule);
	static long GetBatchSubmitTimeout();
  static IMTSecurityPtr GetSecurityFactory();
  static void OverrideBusinessRule(MTPC_BUSINESS_RULE aBusRule,VARIANT_BOOL aVal);
  static BOOL GetDebugTempTables();
  static LRUCache<int, CachedRateSchedule*>* GetRSCache();


private:
	static PCCacheImpl* GetInstance(); 
	static void DeleteInstance();

	PCCacheImpl();
	~PCCacheImpl();

	void LoadMetaDataIfNeeded();
	void LoadPCConfigIfNeeded();
  void LoadSecurityIfNeeded();
  virtual void ConfigurationHasChanged();

	void LoadAuditorIfNeeded();

	//data
	static PCCacheImpl* mpCacheInstance;
	static NTThreadLock mCacheAccessLock;

	ConfigChangeObservable mObservable; 	//observe config change events

	NTLogger mLogger;
	PCCONFIGLib::IMTPCConfigurationPtr mPCConfig;
	MTPRODUCTCATALOGLib::IMTProductCatalogMetaDataPtr mMetaData;
	AuditEventsLib::IAuditorPtr mAuditor;
  IMTSecurityPtr mSecurity;
  LRUCache<int, CachedRateSchedule*>* mRSCache;

	//allow DllMain() call to DeleteInstance()
	friend int APIENTRY DllMain(HANDLE hModule, DWORD reasonForCall, LPVOID lpReserved); 
};

#endif
