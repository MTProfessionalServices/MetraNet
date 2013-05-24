/**************************************************************************
 * RSCACHE
 *
 * Copyright 1997-2001 by MetraTech Corp.
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/
#include <metra.h>

#include <mtglobal_msg.h>
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <NameID.tlb> 
#include <PCCache.h>
#include <MTSessionServerBaseDef.h>
#include <MTSessionBaseDef.h>

#include <RSCache.h>


/**************************************** CachedRateSchedule ***/

CachedRateSchedule::CachedRateSchedule()
  : mModifiedAt(0),
    mpIndex(NULL)
{ }


/**************************************** CachedRateSchedulePropGenerator ***/

CachedRateSchedulePropGenerator::CachedRateSchedulePropGenerator(time_t modifiedAt, int parameterTable)
{ 
  mModifiedAt = modifiedAt;
  mParameterTable = parameterTable;
}

/***************************************** RateScheduleCache ***/

RateScheduleCache::RateScheduleCache()
  : mpLoader(NULL)
{ }

RateScheduleCache::~RateScheduleCache()
{
  
}

// purge a rate schedule out of the cache
BOOL RateScheduleCache::InvalidateAll()
{
  //we no longer own cache collection.
  //It will be cleaned when PCCache dll is unloaded
  ASSERT(false);
  return TRUE;
}

// look for the given rate schedule in our cache
CachedRateSchedule * RateScheduleCache::FindRateSchedule(int aScheduleID, int aParamTableID/*param table id is only needed for stats report in the cache*/)
{
  CachedRateSchedule * schedule = NULL;

  schedule = PCCache::GetRSCache()->find(aScheduleID, aParamTableID);
  return schedule;
}

// load the rate schedule with the given ID
CachedRateSchedule* RateScheduleCache::LoadRateSchedule(int    aParamTableID,
                                                        int    aScheduleID,
                                                        time_t aModifiedAt)
{
  // call out to the loader delegate to do the work
  ASSERT(mpLoader);
  CachedRateSchedule * schedule = mpLoader->LoadRateSchedule(aParamTableID,
                                                             aScheduleID, aModifiedAt);
  if (!schedule)
    SetError(*mpLoader);

  return schedule;
}

// load all rate schedule in the specified parameter table
BOOL RateScheduleCache::LoadRateSchedules(
                         int                 aParamTableID,
                         time_t              aModifiedAt,
                         RATESCHEDULEVECTOR& aRateSchedInfo)
{
  // call out to the loader delegate to do the work
  ASSERT(mpLoader);
  if (!(mpLoader->LoadRateSchedules(aParamTableID,
                                    aModifiedAt,
                                    aRateSchedInfo)))
  {
    SetError(*mpLoader);
    return FALSE;
  }

  return TRUE;
}

// purge a rate schedule out of the cache
void RateScheduleCache::InvalidateRateSchedule(int aScheduleID)
{
  PCCache::GetRSCache()->erase(aScheduleID);
}

// add a rate schedule to the cache
void RateScheduleCache::AddRateSchedule(int                 aScheduleID,
                                        CachedRateSchedule* apSchedule)
{
  PCCache::GetRSCache()->insert(aScheduleID, apSchedule);
}

// add a rate schedule if it is not in the cache, replace it if it is in the cache
void RateScheduleCache::UpdateRateSchedule(int                 aScheduleID,
                                           CachedRateSchedule* apSchedule)
{
  PCCache::GetRSCache()->insert(aScheduleID, apSchedule);
}

int RateScheduleCache::InitRateSchedules(int    aParamTableID,
                                         time_t aModifiedAt)
{
  RATESCHEDULEVECTOR           rateSchedInfo;
  RATESCHEDULEVECTOR::iterator it;

  // Get the collection of rate schedules from the loader.
  //
  // 
  if (!(LoadRateSchedules(aParamTableID, aModifiedAt, rateSchedInfo)))
  {
    for (it = rateSchedInfo.begin(); it != rateSchedInfo.end(); it++)
      delete(it->schedPtr);

    return -1;
  }

  // For each rate schedule...
  //
  // UpdateRateSchedule takes ownership of the pointer and will
  // free the allocated memory (by calling delete()) when the rate
  // schedule is no longer needed.
  for (it = rateSchedInfo.begin(); it != rateSchedInfo.end(); it++)
    UpdateRateSchedule(it->schedID, it->schedPtr);

  return rateSchedInfo.size();
}

BOOL RateScheduleCache::GetRateSchedule(int                  aParamTableID,
                                        int                  aScheduleID,
                                        time_t               aModifiedAt,
                                        CachedRateSchedule** apSchedule)
{
  CachedRateSchedule * schedule = FindRateSchedule(aScheduleID, aParamTableID);

  // if they passed in a modification time then use it.. otherwise
  // only check to see if the schedule is in the database
  if (aModifiedAt > 0 && schedule && schedule->OlderThan(aModifiedAt))
  {
    // clear it out of the cache - it's old
    InvalidateRateSchedule(aScheduleID);
    schedule = NULL;            // same as if it didn't exist
  }

  if (!schedule)
  {
    // load it
    schedule = LoadRateSchedule(aParamTableID, aScheduleID, aModifiedAt);
    if (!schedule)
      return FALSE;

    // add it to the cache
    AddRateSchedule(aScheduleID, schedule);
  }

  if (aModifiedAt > 0)
    ASSERT(!schedule->OlderThan(aModifiedAt));

  *apSchedule = schedule;

  return TRUE;
}

/*************************************************** PCRater ***/

// Rate a session given up to three rate schedules.
BOOL PCRater::Rate(CMTSessionBase* aSession,
                   const RateInputs & arInputs,
                   RateUsed & arRateUsed) // the rate used
{
  const char * functionName = "PCRater::Rate";

  CachedRateSchedule * schedule = NULL;

  int table = arInputs.mParamTableID;

  //
  // ICB/subscription rates
  // 
  BOOL chain;
  if (arInputs.mICBScheduleID != -1)
  {
    // try ICB rates
    if (!GetRateSchedule(table,
                         arInputs.mICBScheduleID, arInputs.mICBScheduleModified,
                         &schedule))
      return FALSE;

    if (schedule->IsIndexed())
    {
      SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
               functionName, "Attempt to perform a non-indexed rating on indexed (tiered) rate schedule. Either add 'WeightOnKey' property" \
               " into plugin configuration file or remove 'indexed_property' from parameter table msix definition file.");
      return FALSE;
    }
  
    BOOL matched = schedule->ProcessSession(aSession);

    if (matched == TRUE)
    {
      // match
      arRateUsed = RATE_USED_ICB;
      return TRUE;
    }

    // only go to the next level if allowed
    chain = (mChainRule == PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_ALL || mChainRule == PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_PO_ONLY);

    // there must be product offering rates if there are subscription rates
    ASSERT(arInputs.mPOScheduleID != -1);
    if (arInputs.mPOScheduleID == -1)
    {
      SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
               functionName,
               "subscription rates exist with no product offering rates");
      return FALSE;
    }
  }
  else
    chain = TRUE;         // there were no ICB rates - always go to the next level


  //
  // product offering rates
  // 
  if (chain && arInputs.mPOScheduleID != -1)
  {
    // try product offering rates
    if (!GetRateSchedule(table,
                         arInputs.mPOScheduleID, arInputs.mPOScheduleModified,
                         &schedule))
      return FALSE;

    if (schedule->IsIndexed())
    {
      SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
               functionName, "Attempt to perform a non-indexed rating on indexed (tiered) rate schedule. Either add 'WeightOnKey' property" \
               " into plugin configuration file or remove 'indexed_property' from parameter table msix definition file.");
      return FALSE;
    }

    //IMTRuleSetEvaluatorPtr evaluator = schedule->GetEvaluator();
    //VARIANT_BOOL matched =
    //  evaluator->Match(aSession);
    BOOL matched = schedule->ProcessSession(aSession);

    if (matched == TRUE)
    {
      // match
      arRateUsed = RATE_USED_PO;
      return TRUE;
    }

    // only go to the next level if allowed
    chain = (mChainRule == PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_ALL);
  }
  else
    chain = TRUE;

  //
  // default account rates
  // 
  if (chain && arInputs.mDefaultAccountScheduleID != -1)
  {
    // try default account rates
    if (!GetRateSchedule(table,
                         arInputs.mDefaultAccountScheduleID,
                         arInputs.mDefaultAccountScheduleModified,
                         &schedule))
      return FALSE;

    if (schedule->IsIndexed())
    {
      SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
               functionName, "Attempt to perform a non-indexed rating on indexed (tiered) rate schedule. Either add 'WeightOnKey' property" \
               " into plugin configuration file or remove 'indexed_property' from parameter table msix definition file.");
      return FALSE;
    }

    BOOL matched = schedule->ProcessSession(aSession);

    if (matched == TRUE)
    {
      // match
      arRateUsed = RATE_USED_DEFAULT_ACCOUNT;
      return TRUE;
    }
  }

  SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
           functionName, "no rates match");

  return FALSE;
}

PCRater::RateCode PCRater::InternalWeightedRate(CMTSessionBase* aSession,
                                                const CachedRateSchedule::IndexedRulesVector & index,
                                                long aWeightID,
                                                MTDecimal aStart, MTDecimal aEnd,
                                                CachedRateSchedule::IndexedRulesVector & arSplitResults)
{
  const char * functionName = "PCRater::InternalWeightedRate";

  arSplitResults.clear();

  if (!SplitOnIndex(index, aStart, aEnd, arSplitResults))
    return RATE_CODE_NOT_FOUND;

  //CR 5575: if aggregate rating condition does
  //not fall into any of the tiers configured on the
  //parameter table, return error
  if (arSplitResults.size() == 0)
  {
    SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
             functionName, "session submitted not in any tiers");
    return RATE_CODE_NOT_FOUND;
  }

  // rate each piece
  MTDecimal totalUnits = aEnd - aStart;

  // ESR-5943 need to find at least one rate
    BOOL matchedAtLeastOneRate = false;

  MTDecimal weightedRate(0L);
  for (int i = 0; i < (int) arSplitResults.size(); i++)
  {
    MTautoptr<IndexedRules> indexEntry = arSplitResults[i];

    // ESR-5943 dont get duration of the segment until it matches
    // duration of this segment
    //MTDecimal units = indexEntry->Units();

    BOOL matched =
      indexEntry->ProcessSession(aSession);
    
    if (matched != TRUE)
    {
      // ESR-5943 because SplitOnIndex was changed to return all the rates in "t_pt" table then not getting a match is okay
      // we just continue to process all the rates that were returned , but need to find at least one rate
      continue; 
    }

    // ESR-5943
    matchedAtLeastOneRate = TRUE;

    // ESR-5943  only get the duration of the segment when it matches
    // duration of this segment
    MTDecimal units = indexEntry->Units();

    // get the rate back that the plug-in generated
    MTDecimal rate = aSession->GetDecimalProperty(aWeightID);

    // get the percentage of this time compared to the entire time    
    MTDecimal percentage;
    if(totalUnits == 0)
      percentage = 1L;
    else
      percentage = units / totalUnits;

    // accumulate the rate
    weightedRate += rate * percentage;

  }

  // ESR-5943 after spinning through all the rates we found no matches, thats an error
  if (matchedAtLeastOneRate != TRUE)
    {      
      // no rates - error (no chaining here!)
      SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
               functionName, "no rates match on at least one range");
      return RATE_CODE_NOT_FOUND;     
  }

  // set the weighted rate of the session
  aSession->SetDecimalProperty(aWeightID, weightedRate);

  return RATE_CODE_OK;
}


BOOL PCRater::WeightedRate(CMTSessionBase* aSession,
                           const RateInputs & arInputs,
                           long aWeightID,
                           MTDecimal aStart, MTDecimal aEnd,
                           CachedRateSchedule::IndexedRulesVector & arSplitResults)
{
  const char * functionName = "PCRater::WeightedRate";

  RateUsed arRateUsed;

  int table = arInputs.mParamTableID;

  // Check all rate schedules to see if any are multitier
  CachedRateSchedule * icbRateSchedule=NULL;
  CachedRateSchedule * poRateSchedule=NULL;
  CachedRateSchedule * plRateSchedule=NULL;
  const CachedRateSchedule::IndexedRulesVector * icbIndexedRules=NULL;
  const CachedRateSchedule::IndexedRulesVector * poIndexedRules=NULL;
  const CachedRateSchedule::IndexedRulesVector * plIndexedRules=NULL;
  if (arInputs.mICBScheduleID != -1)
  {
    // get the indexed rate schedule
    if (!GetRateSchedule(table, arInputs.mICBScheduleID, arInputs.mICBScheduleModified, &icbRateSchedule))
      return FALSE;

    if (!icbRateSchedule->IsIndexed())
    {
      SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
               functionName, "rate schedule is not indexed");
      return FALSE;
    }

    // split our time range into segments that overlap the index
    icbIndexedRules = &(icbRateSchedule->GetIndex());
    if(icbIndexedRules->size() > 1)
    {
      // Mark the compound to remember our use of a multi-tier rate schedule.
      // This means that "real" aggregate rating is in effect.  Later on this
      // info will be pushed down into each session of the compound.
      long parentid = aSession->get_ParentID();
      if (parentid == -1)
      {
        aSession->SetBoolProperty(mMultiTierScheduleFlagID, true);
      }
      else
      {
        MTautoptr<CMTSessionBase> parent(mSessionServer->GetSession(parentid));
        parent->SetBoolProperty(mMultiTierScheduleFlagID, true);
      }
    }
  }
  if (arInputs.mPOScheduleID != -1)
  {
    // get the indexed rate schedule
    if (!GetRateSchedule(table, arInputs.mPOScheduleID, arInputs.mPOScheduleModified, &poRateSchedule))
      return FALSE;

    if (!poRateSchedule->IsIndexed())
    {
      SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
               functionName, "rate schedule is not indexed");
      return FALSE;
    }

    // split our time range into segments that overlap the index
    poIndexedRules = &(poRateSchedule->GetIndex());
    if(poIndexedRules->size() > 1)
    {
      // Mark the compound to remember our use of a multi-tier rate schedule.
      // This means that "real" aggregate rating is in effect.  Later on this
      // info will be pushed down into each session of the compound.
      long parentid = aSession->get_ParentID();
      if (parentid == -1)
      {
        aSession->SetBoolProperty(mMultiTierScheduleFlagID, true);
      }
      else
      {
        MTautoptr<CMTSessionBase> parent(mSessionServer->GetSession(parentid));
        parent->SetBoolProperty(mMultiTierScheduleFlagID, true);
      }
    }
  }
  if (arInputs.mDefaultAccountScheduleID != -1)
  {
    // get the indexed rate schedule
    if (!GetRateSchedule(table, arInputs.mDefaultAccountScheduleID, arInputs.mDefaultAccountScheduleModified, &plRateSchedule))
      return FALSE;

    if (!plRateSchedule->IsIndexed())
    {
      SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
               functionName, "rate schedule is not indexed");
      return FALSE;
    }

    // split our time range into segments that overlap the index
    plIndexedRules = &(plRateSchedule->GetIndex());
    if(plIndexedRules->size() > 1)
    {
      // Mark the compound to remember our use of a multi-tier rate schedule.
      // This means that "real" aggregate rating is in effect.  Later on this
      // info will be pushed down into each session of the compound.
      long parentid = aSession->get_ParentID();
      if (parentid == -1)
      {
        aSession->SetBoolProperty(mMultiTierScheduleFlagID, true);
      }
      else
      {
        MTautoptr<CMTSessionBase> parent(mSessionServer->GetSession(parentid));
        parent->SetBoolProperty(mMultiTierScheduleFlagID, true);
      }
    }
  }
  
  

  BOOL chain=FALSE;
  // ICB/subscription rates
  if (icbIndexedRules != NULL)
  {
    RateCode rc = InternalWeightedRate(aSession, *icbIndexedRules, aWeightID, aStart, aEnd, arSplitResults);
    if (rc == RATE_CODE_OK)
    {
      arRateUsed = RATE_USED_ICB;
      return TRUE;
    }
    else if (rc == RATE_CODE_NOT_FOUND)
    {
      // only go to the next level if allowed
      chain = (mChainRule == PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_ALL || mChainRule == PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_PO_ONLY);

      // there must be product offering rates if there are subscription rates
      ASSERT(poIndexedRules != NULL);
      if (poIndexedRules == NULL)
      {
        SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
                 functionName,
                 "subscription rates exist with no product offering rates");
        return FALSE;
      }
    }
    else
    {
      ASSERT(rc == RATE_CODE_ERROR);
      return FALSE;
    }
  }
  else
  {
    chain = TRUE;
  }
  
  if (chain && poRateSchedule != NULL)
  {
    RateCode rc = InternalWeightedRate(aSession, *poIndexedRules, aWeightID, aStart, aEnd, arSplitResults);
    if (rc == RATE_CODE_OK)
    {
      arRateUsed = RATE_USED_PO;
      return TRUE;
    }
    else if (rc == RATE_CODE_NOT_FOUND)
    {
      // only go to the next level if allowed
      chain = (mChainRule == PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_ALL);
    }
    else
    {
      ASSERT(rc == RATE_CODE_ERROR);
      return FALSE;
    }
  }
  else
  {
    chain = TRUE;
  }
  
  if (chain && plRateSchedule != NULL)
  {
    RateCode rc = InternalWeightedRate(aSession, *plIndexedRules, aWeightID, aStart, aEnd, arSplitResults);
    if (rc == RATE_CODE_OK)
    {
      arRateUsed = RATE_USED_DEFAULT_ACCOUNT;
      return TRUE;
    }
    else if (rc == RATE_CODE_NOT_FOUND)
    {
      SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
               functionName, "no rates match");
      return FALSE;
    }
    else
    {
      ASSERT(rc == RATE_CODE_ERROR);
      return FALSE;
    }
  }

  SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
           functionName, "no rates match");

  return FALSE;
}


BOOL PCRater::SplitOnIndex(const CachedRateSchedule::IndexedRulesVector & arIndex,
                           MTDecimal aStart, MTDecimal aEnd,
                           CachedRateSchedule::IndexedRulesVector & arSplitResults)
{
  const char * functionName = "PCRater::SplitOnIndex";

  bool foundStart = false, foundEnd = false;
  // find the first range we intersect


  // ESR-5943 return all of the rates for the "pt" table, we then will filter out the rates that dont match in "InternalWeightedRate" method
  for (int i = 0; i < (int) arIndex.size(); i++)
  {
    MTautoptr<IndexedRules> indexEntry = arIndex[i];

    // is this segment completely included in our range?
    if (indexEntry->IncludedIn(aStart, aEnd))
    {

      // ESR-5943 when the aEnd value (the value being metered) is less then the indexed value in the tier then return aEnd, otherwise return the tier entry
      // the aEnd value is used later in "InternalWeightedRate" to calculate the rate
      arSplitResults.push_back(indexEntry->Clone(indexEntry->mStart > indexEntry->mEnd ? aStart : indexEntry->mStart, indexEntry->mEnd));
      // if this is the first segment and it's completely included in the range then we found the start
      foundStart = true;
    }

    // is our starting point somewhere in between?
    else if (indexEntry->InRange(aStart))
    {
      // the end point might also be within this range
      arSplitResults.push_back(indexEntry->Clone(aStart, aEnd < indexEntry->mEnd ? aEnd : indexEntry->mEnd));

      if (aEnd < indexEntry->mEnd)
      {
        foundEnd = true;
      }
      foundStart = true;
    }

    // is our ending point somewhere in between?
    else if (indexEntry->InRange(aEnd))
    {
      // the starting point can't also be within the range or the
      // previous conditoin would have caught it
      ASSERT(!indexEntry->InRange(aStart));

      // ESR-5943 when the aEnd value (the value being metered) is less then the indexed value in the tier then return aEnd, otherwise return the tier entry
      // the aEnd value is used later in "InternalWeightedRate" to calculate the rate
      arSplitResults.push_back(indexEntry->Clone(indexEntry->mStart, aEnd < indexEntry->mEnd ? aEnd : indexEntry->mEnd));

      foundEnd = true;
    }

    /* ESR-5943 spin through all rates dont break out of loop when we "foundEnd"
    if (foundEnd)
    {
      // none of the other segments are relavent
      break;
    }
    */ 
  }

  if (!foundStart)
  {
    SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
             functionName, "no matching starting tier found for weighted aggregate rate");
    return FALSE;
  }

  if (!foundEnd)
  {
    SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
             functionName, "no matching ending tier found for weighted aggregate rate");
    return FALSE;
  }
  
  return TRUE;
}
PCRater::PCRater()
//: mChainRule(PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_ALL)
{ 
  mChainRule = PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_ALL;
  NAMEIDLib::IMTNameIDPtr nameid(__uuidof(NAMEIDLib::MTNameID));
  mMultiTierScheduleFlagID = nameid->GetNameID(L"_MultiTierScheduleFlag");
  mSessionServer = CMTSessionServerBase::CreateInstance();
}
PCRater::~PCRater()
//: mChainRule(PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE_ALL)
{ 
  mSessionServer->Release();
}
