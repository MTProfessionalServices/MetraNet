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

#include <metra.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <loggerconfig.h>
#include <autocritical.h>
#include <mtprogids.h>
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") rename ("IMTSecurity", "IMTSecurityPipe") no_function_mapping

#include <MTSessionBaseDef.h>
#include <PCCacheImpl.h>
#include <RSCache.h>


//static Cache members
NTThreadLock PCCacheImpl::mCacheAccessLock;
PCCacheImpl* PCCacheImpl::mpCacheInstance = NULL;


PCCacheImpl::PCCacheImpl()
{ 
  mRSCache = NULL;
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging\\ProductCatalog"), "[ProductCatalog]");
  mObservable.Init();
	mObservable.AddObserver(*this);
	if (!mObservable.StartThread())
		mLogger.LogThis (LOG_ERROR, "Unable to start Observer Thread.") ;
}

PCCacheImpl::~PCCacheImpl()
{
  if(mRSCache != NULL)
    delete mRSCache;
}

//the only way to construct the cache
PCCacheImpl* PCCacheImpl::GetInstance()
{
	if (mpCacheInstance == NULL)	
	{
		// only enter the critical section if not yet created
		// (to avoid needless locking)
		AutoCriticalSection lockCriticalSection(&mCacheAccessLock);

		if (mpCacheInstance == NULL)
		{	mpCacheInstance = new PCCacheImpl;
		}
	}

	return mpCacheInstance;
}

void PCCacheImpl::DeleteInstance()
{
  AutoCriticalSection lockCriticalSection(&mCacheAccessLock);
	delete mpCacheInstance;
	mpCacheInstance = NULL;
}

void PCCacheImpl::LoadMetaDataIfNeeded()
{
  // Note to all: Don't put back in double checked locking optmization
  // until you make it safe.  Previous attempts have been quite broken
  // because they set the mMetaData member prior to it being completely
  // initialized and this lets folks access in an unconstructed state.
  // Technically one could initialize it on a local variable and then
  // set the member, but even that can be subtle once optimizers start
  // reordering instructions (see the "Double Checked Locking is Broken"
  // article on the web before using it; note that most of this article 
  // doesn't apply to x86 but in general one should avoid a flawed technique). 

  // only enter the critical section if not yet loaded
  // (to avoid needless locking)
  AutoCriticalSection lockCriticalSection(&mCacheAccessLock);
		
  if (mMetaData == NULL) //check again in case other thread loaded it
  {
    try
    {
      mLogger.LogVarArgs(LOG_DEBUG, "loading meta data into cache" );
      HRESULT hr = mMetaData.CreateInstance(__uuidof(MTProductCatalogMetaData));
      if (FAILED(hr))
        MT_THROW_COM_ERROR(hr);
		
      mMetaData->Load( VARIANT_FALSE ); //FALSE = do not abort on errors, to allow use of certain PC object, that
    }
    catch(_com_error& err)
    {
      ErrorObject* errObj = CreateErrorFromComError(err);
      mLogger.LogErrorObject(LOG_ERROR, errObj);
      delete errObj;	
      mLogger.LogVarArgs(LOG_FATAL, "Failed to load meta data into cache" );

      mMetaData = NULL;
    }
  }
}

void PCCacheImpl::LoadAuditorIfNeeded()
{
  // See above comments about double checked locking before trying to use it!

  // only enter the critical section if not yet loaded
  // (to avoid needless locking)
  AutoCriticalSection lockCriticalSection(&mCacheAccessLock);
		
  if (mAuditor == NULL) //check again in case other thread loaded it
  {
    try
    {
      mLogger.LogVarArgs(LOG_DEBUG, "creating Auditor component" );
      //HRESULT hr = mAuditor.CreateInstance(__uuidof(AuditEventsLib::Auditor));
      HRESULT hr = mAuditor.CreateInstance(MTPROGID_AUDITOR);
      if (FAILED(hr))
        MT_THROW_COM_ERROR(hr);
		
      //mMetaData->Load();
    }
    catch(_com_error& err)
    {
      ErrorObject* errObj = CreateErrorFromComError(err);
      mLogger.LogErrorObject(LOG_ERROR, errObj);
      delete errObj;	
      mLogger.LogVarArgs(LOG_FATAL, "Failed to create auditor component" );

      mAuditor = NULL;
    }
	}
}

void PCCacheImpl::LoadPCConfigIfNeeded()
{
  // See above comments about double checked locking before trying to use it!

  // only enter the critical section if not yet loaded
  // (to avoid needless locking)
  AutoCriticalSection lockCriticalSection(&mCacheAccessLock);
		
  if (mPCConfig == NULL) //check again in case other thread loaded it
  {
    try
    {
      mLogger.LogVarArgs(LOG_DEBUG, "loading configuration into cache" );
      HRESULT hr = mPCConfig.CreateInstance(__uuidof(MTPCConfiguration));
      if (FAILED(hr))
        MT_THROW_COM_ERROR(hr);
		
      mPCConfig->Load();
    }
    catch(_com_error& err)
    {
      ErrorObject* errObj = CreateErrorFromComError(err);
      mLogger.LogErrorObject(LOG_ERROR, errObj);
      delete errObj;	
      mLogger.LogVarArgs(LOG_FATAL, "Failed to load configuration into cache" );

      mPCConfig = NULL;
    }
  }
}

void PCCacheImpl::LoadSecurityIfNeeded()
{
  // See above comments about double checked locking before trying to use it!

  AutoCriticalSection lockCriticalSection(&mCacheAccessLock);
  mSecurity.CreateInstance(MTPROGID_MTSECURITY);
}


//refresh cache
void PCCacheImpl::Refresh()
{
	PCCacheImpl* instance = GetInstance();
	
	AutoCriticalSection lockCriticalSection(&mCacheAccessLock);

	instance->mLogger.LogVarArgs(LOG_DEBUG, "Refreshing cache" );
	
	// unload all
	// cache will be loaded when needed
	instance->mMetaData = NULL;
	instance->mPCConfig = NULL;
}

void PCCacheImpl::ConfigurationHasChanged()
{
	Refresh();
}

NTLogger& PCCacheImpl::GetLogger()
{
	return GetInstance()->mLogger;
}

AuditEventsLib::IAuditorPtr PCCacheImpl::GetAuditor()
{
	
	GetInstance()->LoadAuditorIfNeeded();

	return GetInstance()->mAuditor;
}

MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr PCCacheImpl::GetMetaData(MTPCEntityType aEntityType)
{
	GetInstance()->LoadMetaDataIfNeeded();
	return GetInstance()->mMetaData->GetPropertyMetaDataSet((MTPRODUCTCATALOGLib::MTPCEntityType)aEntityType);
}

MTPRODUCTCATALOGLib::IMTAttributeMetaDataSetPtr PCCacheImpl::GetAttributeMetaData()
{
	GetInstance()->LoadMetaDataIfNeeded();
	return GetInstance()->mMetaData->GetAttributeMetaDataSet();
}

PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE PCCacheImpl::GetPLChaining()
{
	GetInstance()->LoadPCConfigIfNeeded();
	return GetInstance()->mPCConfig->GetPLChaining();
}
BOOL PCCacheImpl::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE aRule)
{
	GetInstance()->LoadPCConfigIfNeeded();
	return GetInstance()->mPCConfig->IsBusinessRuleEnabled(aRule);
}

long PCCacheImpl::GetBatchSubmitTimeout()
{
	GetInstance()->LoadPCConfigIfNeeded();
	return GetInstance()->mPCConfig->GetBatchSubmitTimeout();
}

BOOL PCCacheImpl::GetDebugTempTables()
{
  GetInstance()->LoadPCConfigIfNeeded();
  return GetInstance()->mPCConfig->GetDebugTempTables() == VARIANT_TRUE ? TRUE : FALSE;
}


MTAuthInterfacesLib::IMTSecurityPtr PCCacheImpl::GetSecurityFactory()
{
	// TODO: holding onto the MTSecurity object in PCCache
	// causes processes to hang when the DLLs are unloaded out of order.
	// for now, don't hold onto the object
	MTAuthInterfacesLib::IMTSecurityPtr security(MTPROGID_MTSECURITY);
	return security;
#if 0
  GetInstance()->LoadSecurityIfNeeded();
  return GetInstance()->mSecurity;
#endif
}

void PCCacheImpl::OverrideBusinessRule(MTPC_BUSINESS_RULE aBusRule,VARIANT_BOOL aVal)
{
  GetInstance()->LoadPCConfigIfNeeded();
  GetInstance()->mPCConfig->OverrideBusinessRule((PCCONFIGLib::MTPC_BUSINESS_RULE)aBusRule,aVal);
}

LRUCache<int, CachedRateSchedule*>* PCCacheImpl::GetRSCache()
{
  GetInstance()->LoadPCConfigIfNeeded();
  if(GetInstance()->mRSCache == NULL)
  {
    AutoCriticalSection lockCriticalSection(&mCacheAccessLock);
    if(GetInstance()->mRSCache == NULL)
    {
      GetInstance()->mRSCache = new LRUCache<int, CachedRateSchedule*>
        (GetInstance()->mPCConfig->GetRSCacheMaxSize());
    }
  }
  return GetInstance()->mRSCache;
}



