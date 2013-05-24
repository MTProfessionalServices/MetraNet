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

#ifndef __PCCACHE_H__
#define __PCCACHE_H__

#include "MTProductCatalog.h"
#import "MTProductCatalog.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTAuthLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
using MTAuthInterfacesLib::IMTSecurityPtr;


#include "PCConfig.h"
#import "PCConfig.tlb"

#import "AuditEventsLib.tlb"

#include <NTLogger.h>

#ifdef PCCACHE_EXPORTS
#define PCCACHE_API __declspec(dllexport)
#else
#define PCCACHE_API __declspec(dllimport)
#endif

#include <lru.h>

class CachedRateSchedule;

// public interface to PCCache
// cache itself is implemented in PCCacheImpl
class PCCACHE_API PCCache
{
public:
	
	//refresh the cache
	static void Refresh();

	// get the logger
	static NTLogger& GetLogger();

	// get the auditor
	static AuditEventsLib::IAuditorPtr GetAuditor();
  static MTAuthInterfacesLib::IMTSecurityPtr GetSecurityFactory();


	//get meta data
	static MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr GetMetaData(MTPCEntityType aEntityType);
	static MTPRODUCTCATALOGLib::IMTAttributeMetaDataSetPtr GetAttributeMetaData();

	// get configuration
	static PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE GetPLChaining();
	static BOOL IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE aRule);
	static long GetBatchSubmitTimeout();
  static void OverrideBusinessRule(MTPC_BUSINESS_RULE aBusRule,VARIANT_BOOL aVal);
  static BOOL GetDebugTempTables();
  static LRUCache<int, CachedRateSchedule*>* GetRSCache();
};

#endif
