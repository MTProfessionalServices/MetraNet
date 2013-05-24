/**************************************************************************
 * @doc RSCACHE
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 *
 * @index | RSCACHE
 ***************************************************************************/

#ifndef _RSCACHE_H
#define _RSCACHE_H

#include <errobj.h>
#include <autoptr.h>

//#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <PCConfig.tlb>
#include <MTDec.h>


//class PropGenerator;
//#include <map>
#include <vector>

//using MTPipelineLib::IMTRuleSetEvaluatorPtr;

class RateScheduleLoader;
class DBRSLoader;
class FileRSLoader;
class RateScheduleCache;
class CMTSessionBase;
class CMTSessionServerBase;


#include <PropGenerator.h>

class IndexedRules
{
public:
  MTDecimal mStart;
  MTDecimal mEnd;

public:
  IndexedRules(const MTDecimal & start, const MTDecimal & end)
    :
    mStart(start),
    mEnd(end)
  {
  }

  virtual ~IndexedRules() {}

  virtual MTautoptr<IndexedRules> Clone(const MTDecimal & start, const MTDecimal & end) =0;

  BOOL InRange(MTDecimal aValue) const
  { return (aValue >= mStart && aValue <= mEnd); }

  BOOL IncludedIn(MTDecimal aStart, MTDecimal aEnd) const
  { return (mStart >= aStart && mEnd <= aEnd); }

  MTDecimal Units() const
  { return mEnd - mStart; }

  virtual BOOL ProcessSession(CMTSessionBase * aSession) =0;
};

class IndexedRulesPropGenerator : public IndexedRules
{
private:
  IndexedRulesPropGenerator(const MTDecimal & start, const MTDecimal & end, MTautoptr<PropGenerator> propGen)
    :
    IndexedRules(start,end),
    mPropGen(propGen)
  {
  }

public:

  static MTautoptr<IndexedRules> Create(const MTDecimal & start, const MTDecimal & end, MTautoptr<PropGenerator> propGen)
  {
    return MTautoptr<IndexedRules> (new IndexedRulesPropGenerator(start, end, propGen));
  }

  ~IndexedRulesPropGenerator() {}

  MTautoptr<PropGenerator> mPropGen;

  MTautoptr<IndexedRules> Clone(const MTDecimal & start, const MTDecimal & end)
  {
    return Create(start, end, mPropGen);
  }
  //IMTRuleSetEvaluatorPtr mEvaluator;
  //CR 12855 - seems like we don't need this
  //MTPipelineLib::IMTRuleSetPtr mRules;
  BOOL ProcessSession(CMTSessionBase * aSession) 
  { return mPropGen->ProcessSession(aSession); }
};


/**************************************** CachedRateSchedule ***/
// a cached rate schedule
class CachedRateSchedule
{
  friend RateScheduleCache;
protected:
  // only friends can create
  CachedRateSchedule();

public:

  virtual ~CachedRateSchedule()
  {

    if(mpIndex != NULL)
    {
      delete mpIndex;
      mpIndex = NULL;
    }
  }
  BOOL OlderThan(time_t aTime) const
  { return mModifiedAt < aTime; }

  virtual BOOL ProcessSession(CMTSessionBase * aSession) =0;
  
public:
  BOOL IsIndexed() const
  { return mpIndex != NULL; }

  typedef std::vector<MTautoptr<IndexedRules> > IndexedRulesVector;

  const IndexedRulesVector & GetIndex() const
  { return *mpIndex; }

  void SetIndex(IndexedRulesVector * apIndex)
  { mpIndex = apIndex; }

  
 int ParameterTable() const
    { return mParameterTable; }


protected:
  // date/time this rate schedule was modified
  time_t mModifiedAt;

  // parameter table this rate schedule belongs to.
  int mParameterTable;

  //IMTRuleSetEvaluatorPtr mEvaluator;

  // optional index
  IndexedRulesVector * mpIndex;

};

class CachedRateSchedulePropGenerator : public CachedRateSchedule
{
  friend RateScheduleCache;
  friend DBRSLoader;
  friend FileRSLoader;
private:
  // only friends can create
  CachedRateSchedulePropGenerator(time_t modifiedAt, int parameterTable);

public:
  virtual ~CachedRateSchedulePropGenerator()
  {
  }

  PropGenerator* GetPropGen()
  { 
    if(mPropGen == NULL)
      mPropGen = new PropGenerator;
    return mPropGen; 
  }

  BOOL ProcessSession(CMTSessionBase * aSession)
  {
    return GetPropGen()->ProcessSession(aSession);
  }

private:
  
  MTautoptr<PropGenerator> mPropGen;   
};

/***************************************** RateScheduleInfo ***/

class RateScheduleInfo
{
public:
    int                 schedID;
    CachedRateSchedule* schedPtr;

    RateScheduleInfo() : schedID(-1), schedPtr(0) {}
    RateScheduleInfo(int NewSchedID, CachedRateSchedule* NewSchedPtr)
                    : schedID(NewSchedID), schedPtr(NewSchedPtr) {}
};

typedef std::vector<RateScheduleInfo> RATESCHEDULEVECTOR;

/**************************************** RateScheduleLoader ***/

// a class that loads rate schedules
class RateScheduleLoader : public virtual ObjectWithError
{
public:

  // load a rate schedule and return a pointer to it.
  // it's expected that this call allocates the CachedRateSchedule
  // with new.  If the schedule cannot be loaded, return NULL.
  virtual CachedRateSchedule* LoadRateSchedule(int    aParamTableID,
                                               int    aScheduleID,
                                               time_t aModifiedAt) = 0;

  // load all rate schedules in the specified parameter table.
  // it's expected that this call allocates the CachedRateSchedules
  // with new.  If the schedules cannot be loaded, return FALSE.
  virtual BOOL LoadRateSchedules(int                 aParamTableID,
                                 time_t              aModifiedAt,
                                 RATESCHEDULEVECTOR& aRateSchedInfo) = 0;
};

/***************************************** RateScheduleCache ***/

// a cache of rate schedules
class RateScheduleCache : public virtual ObjectWithError
{
public:
  RateScheduleCache();
  virtual ~RateScheduleCache();

  // Retrieves all of the rate schedules from the specified parameter
  // table and stores them in the cache.  All rate schedules in the
  // indicated parameter table are updated regardless of whether or not
  // they already exist in the cache.  If they already exist in the
  // cache they will be replaced with this latest information.
  //
  // Returns the number of rate schedules loaded if successful and -1 if
  // an error was encountered.  If an error occured it should be set on
  // the RateScheduleCache object.
  int InitRateSchedules(int    aParamTableID,
                        time_t aModifiedAt);

  // retrieve a rate schedule from the cache.
  // if the rate schedule is older than the date passed in or
  // not found in the cache, call out to the RateScheduleLoader
  // to pull it in.
  BOOL GetRateSchedule(int                  aParamTableID,
                       int                  aScheduleID,
                       time_t               aModifiedAt,
                       CachedRateSchedule** apSchedule);

  // invalidate all entries in the cache
  BOOL InvalidateAll();

  // set the object used to load rate schedules
  void SetLoader(RateScheduleLoader* apLoader)
       { mpLoader = apLoader; }

private:
  // load the rate schedule with the given ID
  CachedRateSchedule* LoadRateSchedule(int    aParamTableID,
                                       int    aScheduleID,
                                       time_t aModifiedAt);

  // load all rate schedules in the specified parameter table
  BOOL LoadRateSchedules(int                 aParamTableID,
                         time_t              aModifiedAt,
                         RATESCHEDULEVECTOR& aRateSchedInfo);

  // look for the given rate schedule in our cache
  CachedRateSchedule* FindRateSchedule(int aScheduleID, int aParamTableID/*param table id is only needed for stats report in the cache*/);

  // purge a rate schedule out of the cache
  void InvalidateRateSchedule(int aScheduleID);

  // add a rate schedule to the cache
  void AddRateSchedule(int                 aScheduleID,
                       CachedRateSchedule* apSchedule);

  // add a rate schedule if it is not in the cache, replace it if it is in the cache
  void UpdateRateSchedule(int                 aScheduleID,
                          CachedRateSchedule* apSchedule);

private:
  // class we deligate to to actually load the rate schedules
  RateScheduleLoader* mpLoader;

  //typedef std::map<int, CachedRateSchedule*> ScheduleMap;

};

/*************************************************** PCRater ***/

struct RateInputs
{
  int mPI;                      // priceable item
  int mParamTableID;            // parameter table

  int mICBScheduleID;           // ICB schedule
  time_t mICBScheduleModified;  // time it was last modified

  int mPOScheduleID;            // product offering schedule
  time_t mPOScheduleModified;   // time it was last modified

  int mDefaultAccountScheduleID; // default account schedule
  time_t mDefaultAccountScheduleModified; // time it was last modified

  RateInputs() :
    mPI(-1),
    mParamTableID(-1),
    mICBScheduleID(-1),
    mICBScheduleModified(0),
    mPOScheduleID(-1),
    mPOScheduleModified(0),
    mDefaultAccountScheduleID(-1),
    mDefaultAccountScheduleModified(0)
  { }
};


class PCRater : public RateScheduleCache
{
public:

  // return codes for internal weighted rating
  enum RateCode
  {
    RATE_CODE_ERROR = -1,
    RATE_CODE_OK = 0,
    RATE_CODE_NOT_FOUND = 1
  };

  // enum used to report the rate used
  enum RateUsed
  {
    RATE_USED_ICB,
    RATE_USED_PO,
    RATE_USED_DEFAULT_ACCOUNT,
  };

  //Use Com enumeration instead
  /*
  enum ChainRule
  {
    CHAIN_RULE_NONE,            // never chain
    CHAIN_RULE_ALL,             // chain between all levels 
    CHAIN_RULE_PO_ONLY,         // chain between subscription and product offering only 
  };
  */

public:
  PCRater();
  ~PCRater();
  // Rate a session given up to three rate schedules.
  // The rate schedule used is reported back through arRateUsed.
  // NOTE: IDs can be -1 if there is no rate schedule at the given level
  BOOL Rate(CMTSessionBase* aSession,
            const RateInputs & arInputs,
            RateUsed & arRateUsed); // the rate used

  // Rate a session given up to three rate schedules.
  // Determine the weighted average of a given property
  // when the transaction crosses over "ranges".
  BOOL WeightedRate(CMTSessionBase* aSession,
                    const RateInputs & arInputs,
                    long aWeightID,
                    MTDecimal aStart, MTDecimal aEnd,
                    CachedRateSchedule::IndexedRulesVector & arSplitResults);

  // access/set the chaining rules
  PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE GetChainRule() const
  { return mChainRule; }

  void SetChainRule(PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE aRule)
  { mChainRule = aRule; }

private:
  BOOL SplitOnIndex(const CachedRateSchedule::IndexedRulesVector & arIndex,
                    MTDecimal aStart, MTDecimal aEnd,
                    CachedRateSchedule::IndexedRulesVector & arSplitResults);

  RateCode InternalWeightedRate(CMTSessionBase* aSession,
                                const CachedRateSchedule::IndexedRulesVector & index,
                                long aWeightID,
                                MTDecimal aStart, MTDecimal aEnd,
                                CachedRateSchedule::IndexedRulesVector & arSplitResults);

private:
  PCCONFIGLib::MTPC_PRICELIST_CHAIN_RULE mChainRule;
  long mMultiTierScheduleFlagID;
  CMTSessionServerBase * mSessionServer;
};

#endif /* _RSCACHE_H */

