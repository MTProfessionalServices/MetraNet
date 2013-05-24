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
#include <metralite.h>
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") rename ("IMTSecurity", "IMTSecurityPipe") no_function_mapping

#include <MTSessionBaseDef.h>
#include "PCCache.h"
#include "PCCacheImpl.h"
#include <RSCache.h>



void PCCache::Refresh()
{
	PCCacheImpl::Refresh();
}

NTLogger& PCCache::GetLogger()
{
	return PCCacheImpl::GetLogger();
}

AuditEventsLib::IAuditorPtr PCCache::GetAuditor()
//MTAUDITEVENTSLib::IAuditorPtr PCCache::GetAuditor()
{
	return PCCacheImpl::GetAuditor();
}

MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr PCCache::GetMetaData(MTPCEntityType aEntityType)
{
	return PCCacheImpl::GetMetaData(aEntityType);
}

MTPRODUCTCATALOGLib::IMTAttributeMetaDataSetPtr PCCache::GetAttributeMetaData()
{
	return PCCacheImpl::GetAttributeMetaData();
}

PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE PCCache::GetPLChaining()
{
	return PCCacheImpl::GetPLChaining();
}

BOOL PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE aRule)
{
	return PCCacheImpl::IsBusinessRuleEnabled(aRule);
}

long PCCache::GetBatchSubmitTimeout()
{
	return PCCacheImpl::GetBatchSubmitTimeout();
}

MTAuthInterfacesLib::IMTSecurityPtr PCCache::GetSecurityFactory()
{
  return PCCacheImpl::GetSecurityFactory();
}

void PCCache::OverrideBusinessRule(MTPC_BUSINESS_RULE aBusRule,VARIANT_BOOL aVal)
{
  PCCacheImpl::OverrideBusinessRule(aBusRule,aVal);
}

BOOL PCCache::GetDebugTempTables()
{
  return PCCacheImpl::GetDebugTempTables();
}

LRUCache<int, CachedRateSchedule*>* PCCache::GetRSCache()
{
  return PCCacheImpl::GetRSCache();
}



