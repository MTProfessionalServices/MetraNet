#ifndef __RATE_INTERPRETER__
#define __RATE_INTERPRETER__

#import <MTPipelineLib.tlb> rename("EOF", "EOFX")
#import <MTProductCatalog.tlb> rename("EOF", "EOFX")
#include <RSCache.h>
#include <vector>
#include <autoptr.h>
#include <NTLogger.h>
#include <NTThreadLock.h>
#include <RecordModel.h>

#include <map>

class ConditionBase;
class Action;
class COdbcDecimal;
class MTDecimal;
class COdbcPreparedResultSet;
class CachedRateScheduleOptimized;
class OptimizedRateScheduleLoader;
class BufferList;
class HashTableIterator;
class HashTablePredicateIterator;

// Represents the static/metadata portion of the ruleset.  Specific bindings to sessions and rate schedules
// are made later.
class RuleSetStaticExecution : public ConstantPoolFactoryBase
{
public:
  enum OpCode { DECIMAL_EQUALS, DECIMAL_NOTEQUALS, DECIMAL_GT, DECIMAL_GTEQ, DECIMAL_LT, DECIMAL_LTEQ, 
         ENUM_EQUALS, ENUM_NOTEQUALS, ENUM_GT, ENUM_GTEQ, ENUM_LT, ENUM_LTEQ,
         INTEGER_EQUALS, INTEGER_NOTEQUALS, INTEGER_GT, INTEGER_GTEQ, INTEGER_LT, INTEGER_LTEQ,
         BIGINTEGER_EQUALS, BIGINTEGER_NOTEQUALS, BIGINTEGER_GT, BIGINTEGER_GTEQ, BIGINTEGER_LT, BIGINTEGER_LTEQ,
         DOUBLE_EQUALS, DOUBLE_NOTEQUALS, DOUBLE_GT, DOUBLE_GTEQ, DOUBLE_LT, DOUBLE_LTEQ,
         DATETIME_EQUALS, DATETIME_NOTEQUALS, DATETIME_GT, DATETIME_GTEQ, DATETIME_LT, DATETIME_LTEQ,
         WIDESTRING_EQUALS, WIDESTRING_NOTEQUALS,
         BOOLEAN_EQUALS, BOOLEAN_NOTEQUALS,
  };

private:
  OptimizedRateScheduleLoader * mLoader;
  std::wstring mTableName;
  int mIndexedPropertyPosition;
  int mParameterTable;
  std::vector<ConditionBase *> mConditions;
  std::vector<Action *> mActions;

  // All rules are fixed length, because variable length things will be stored
  // via an indirection (as well as big objects in general).  In general, the
  // record length is (#fields + 31)/32 bits + 32bits * #fields.
  long mRecordLength;

  // We store wchar_t strings as null terminated strings in an intrusive list.
  // Here is our constant pool for big objects.  Constant pool is shared over all
  // rate schedules within a single rate table.
// 	struct StringNode*		mStrPool;
// 	double	*			mDoublePool;
// 	DECIMAL *			mDecimalPool;
// 	__int64	*		  mLongLongPool;
  // No pools for 32 bit quantities.
// 	long					mLongValue;
// 	float					mFloatValue;
// 	bool	        mBoolValue;

  OpCode GetOpCodeFromOffset(int offset, MTPipelineLib::PropValType sessionType);
  NTLogger mLogger;

  std::map<int, CachedRateScheduleOptimized *> mSchedules;
  void LoadFromDatabase(MTautoptr<COdbcPreparedResultSet> rs, time_t aModifiedAt);
  void LoadIndexedFromDatabase(MTautoptr<COdbcPreparedResultSet> rs, time_t aModifiedAt);

public:

  RuleSetStaticExecution(OptimizedRateScheduleLoader * loader);
  ~RuleSetStaticExecution();

  NTLogger * GetLogger () { return &mLogger; }

  OpCode GetOpCode(long op, MTPipelineLib::PropValType sessionType);
  OpCode GetOpCode(const wchar_t * opStr, MTPipelineLib::PropValType sessionType);

  long GetRecordLength() const { return mRecordLength; }

  void Init(MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr aParamTableDef);
  // Load all of the rate schedules from the database.
  void LoadFromDatabase(time_t aModifiedAt);
  void LoadFromDatabase(RATESCHEDULEVECTOR & rateSchedInfo, time_t aModifiedAt);
  CachedRateScheduleOptimized * LoadFromDatabase(int aSchedID, time_t aModifiedAt);
  // Print all rate schedules to log for debugging purposes
  void Print();
  // Evaluate a session against a rate schedule
  bool Evaluate(CMTSessionBase * sess, BufferList * sched);

  // Fast Region based allocator.
  static void * malloc(size_t sz);
  static void free(void * ptr);
};


class OptimizedRateScheduleLoader : public RateScheduleLoader
{

  std::map<int, RuleSetStaticExecution *> mRuleSets;

public:

  ~OptimizedRateScheduleLoader();

  CachedRateScheduleOptimized * CreateRateScheduleOptimized(RuleSetStaticExecution * rsee, int aParameterTable, time_t aModifiedAt);

  // create a rate schedule with the ruleset evaluator created
  // and modification date initialized.
  CachedRateSchedule* CreateRateSchedule(int aParameterTable, time_t aModifiedAt);

  // load a rate schedule and return a pointer to it.
  // it's expected that this call allocates the CachedRateSchedule
  // with new.  If the schedule cannot be loaded, return NULL.
  CachedRateSchedule* LoadRateSchedule(int    aParamTableID,
                                       int    aScheduleID,
                                       time_t aModifiedAt);

  // load all rate schedules in the specified parameter table.
  // it's expected that this call allocates the CachedRateSchedules
  // with new.  If the schedules cannot be loaded, return FALSE.
  BOOL LoadRateSchedules(int                 aParamTableID,
                         time_t              aModifiedAt,
                         RATESCHEDULEVECTOR& aRateSchedInfo);
};





#endif
