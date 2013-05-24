#include <metra.h>
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") \
  no_function_mapping
#import <MTProductCatalog.tlb> rename("EOF", "EOFX")

#include <mtglobal_msg.h>
#include <RSCache.h>
#include <MTSessionBaseDef.h>
#include <RateInterpreter.h>
#include <autoptr.h>
#include <autocritical.h>
#include <OdbcConnMan.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcResultSet.h>
#include <OdbcSessionTypeConversion.h>
#include <errutils.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#import <NameID.tlb> rename("EOF", "EOFX")

// Wrapper to access decimal constant pool with COdbcDecimal
static decimal_traits::pointer GetDecimalConstant(ConstantPoolFactory * cp, const COdbcDecimal & dec)
{
  decimal_traits::value decVal;
  OdbcDecimalToDecimal(dec, &decVal);
  return cp->GetDecimalConstant(&decVal);
}


// For the moment this just passes through to the underlying session object.
// We can add memoization to it if we think it will improve performance.
class MemoizedSession
{
private:
  CMTSessionBase * mSession;
public:
  MemoizedSession(CMTSessionBase * session)
    :
    mSession(session)
  {
  }

  long GetLongProperty(long propid)
  {
    return mSession->GetLongProperty(propid);
  }
  DECIMAL GetDecimalProperty(long propid)
  {
    return mSession->GetDecimalProperty(propid);
  }
  long GetEnumProperty(long propid)
  {
    return mSession->GetEnumProperty(propid);
  }
  long GetTimeProperty(long propid)
  {
    return mSession->GetTimeProperty(propid);
  }
  __int64 GetLongLongProperty(long propid)
  {
    return mSession->GetLongLongProperty(propid);
  }
  BSTR GetStringProperty(long propid)
  {
    return mSession->GetStringProperty(propid);
  }
  bool GetBoolProperty(long propid)
  {
    return mSession->GetBoolProperty(propid);
  }
  double GetDoubleProperty(long propid)
  {
    return mSession->GetDoubleProperty(propid);
  }
  DATE GetDatetimeProperty(long propid)
  {
    return mSession->GetOLEDateProperty(propid);
  }

  void SetLongProperty(long propid, long value)
  {
    mSession->SetLongProperty(propid, value);
  }
  void SetDecimalProperty(long propid, DECIMAL value)
  {
    mSession->SetDecimalProperty(propid, value);
  }
  void SetEnumProperty(long propid, long value)
  {
    mSession->SetEnumProperty(propid, value);
  }
  void SetTimeProperty(long propid, long value)
  {
    mSession->SetTimeProperty(propid, value);
  }
  void SetLongLongProperty(long propid, __int64 value)
  {
    mSession->SetLongLongProperty(propid, value);
  }
  void SetStringProperty(long propid, const wchar_t * value)
  {
    mSession->SetStringProperty(propid, value);
  }
  void SetBoolProperty(long propid, bool value)
  {
    mSession->SetBoolProperty(propid, value);
  }
  void SetDoubleProperty(long propid, double value)
  {
    mSession->SetDoubleProperty(propid, value);
  }
  void SetDatetimeProperty(long propid, DATE value)
  {
    mSession->SetOLEDateProperty(propid, value);
  }
};

struct Record
{
  struct Record * mNext;
  unsigned char * GetBuffer()
  {
    return (unsigned char *) (this + 1);
  }
};

class BufferList
{
private:
  friend class BufferListIterator;
  struct Record * mHead;
  struct Record * mTail;
public:
  BufferList()
    :
    mHead(NULL),
    mTail(NULL)
  {
  }

  unsigned char * AllocateBuffer(size_t sz)
  {
    struct Record * r = (struct Record *) RuleSetStaticExecution::malloc(sz + sizeof(struct Record));
    memset(r, 0, sz + sizeof(struct Record));
    r->mNext = NULL;
    if(mTail != NULL)
    {
      mTail->mNext = r;
    }
    mTail = r;
    if(mHead == NULL)
    {
      mHead = mTail;
    }
    return mTail->GetBuffer();
  }  
};

class BufferListIterator
{
private:
  Record * mCurrent;
  bool mWait;
public:
  BufferListIterator (const BufferList * rs)
    :
    mCurrent(rs->mHead),
    mWait(true)
  {
  }
  bool Next()
  {
    if (!mWait) mCurrent = mCurrent->mNext;
    else mWait = false;
    return mCurrent != NULL;
  }
  unsigned char * GetRateBuffer()
  {
    return mCurrent->GetBuffer();
  }
};



// In this implementation, a rate schedule is just an ordered list of records from the database.
// Records are implemented as singly linked list; there is no need to access them in any way
// other than forward iteration.
// Each record is stored with a null bitmap in front and then a series of 32-bit fields.  Values
// larger than 32-bits are stored in a constant pool and the record contains a pointer to the value.

class CachedRateScheduleOptimized : public CachedRateSchedule, public BufferList
{
private:
  RuleSetStaticExecution * mRuleSet;
public:
//   static void * operator new (size_t sz)
//   {
//     return RuleSetStaticExecution::malloc(sz);
//   }
//   static void operator delete (void * p)
//   {
//     RuleSetStaticExecution::free(p);
//   }

  CachedRateScheduleOptimized(RuleSetStaticExecution * ruleSet, int paramTableID, time_t modifiedAt)
    :
    mRuleSet(ruleSet)
  {
    ASSERT(mRuleSet != NULL);
    mParameterTable = paramTableID;
    mModifiedAt = modifiedAt;
  }


  BOOL ProcessSession(CMTSessionBase * sess)
  {
    return mRuleSet->Evaluate(sess, this);
  }
};

class IndexedRulesOptimized : public IndexedRules
{
private:
  RuleSetStaticExecution * mRuleSet;
  MTautoptr<BufferList> mBufferList;
  IndexedRulesOptimized(RuleSetStaticExecution * ruleSet, const MTDecimal& start, const MTDecimal& end, MTautoptr<BufferList> bufferList)
    :
    IndexedRules(start, end),
    mRuleSet(ruleSet),
    mBufferList(bufferList)
  {
  }
public:

  IndexedRulesOptimized(RuleSetStaticExecution * ruleSet, const MTDecimal& start, const MTDecimal& end)
    :
    IndexedRules(start, end),
    mRuleSet(ruleSet)
  {
    mBufferList = MTautoptr<BufferList> (new BufferList);
  }

  

  MTautoptr<IndexedRules> Clone(const MTDecimal& start, const MTDecimal& end)
  {
    return MTautoptr<IndexedRules>(new IndexedRulesOptimized(mRuleSet, start, end, mBufferList));
  }

  unsigned char * AllocateBuffer(size_t sz)
  {
    return mBufferList->AllocateBuffer(sz);
  }

  BOOL ProcessSession(CMTSessionBase * sess)
  {
    return mRuleSet->Evaluate(sess, &mBufferList);
  }  
};


// There are 3 interesting scopes for rulesets.  Things that are defined at the
// level of the table; things that are defined at each row and things that are
// defined at the level of each evaluation of the ruleset.
class ConditionBase : public DatabaseColumn
{
protected:
  static PhysicalFieldType Convert(MTPipelineLib::PropValType ty);

  // Session id of the session property we reference.
  long mSessionProperty;

  // Rule set that the condition specification belongs to.
  RuleSetStaticExecution * mRuleSet;
  bool Evaluate(RuleSetStaticExecution::OpCode op, const unsigned char * recordBuffer, MemoizedSession * session);

public:
  ConditionBase(RuleSetStaticExecution * ruleSet, 
                long sessionProperty, MTPipelineLib::PropValType sessionType, 
                bool isRequired, long position, long columnPosition, long offset, const std::wstring& name);
  virtual ~ConditionBase() {}
  virtual bool Evaluate(const unsigned char * recordBuffer, MemoizedSession * session) =0;
  virtual void Load(record_t recordBuffer, COdbcPreparedResultSet * rs);
  virtual void Print(const_record_t recordBuffer, NTLogger& logger);
};

void ConditionBase::Print(const_record_t recordBuffer, NTLogger& logger)
{
  if(GetNull(recordBuffer)) 
  {
    logger.LogVarArgs(LOG_DEBUG, "Column Position=%d; Value=NULL", mColumnPosition+1);
    return ;
  }
  switch(GetColumnType())
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    MTDecimal dec(**((decimal_traits::pointer*)(recordBuffer + mOffset)));
    logger.LogVarArgs(LOG_DEBUG, "Column Position=%d; Decimal Value=%s", mColumnPosition+1, dec.Format().c_str());
    return;
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    logger.LogVarArgs(LOG_DEBUG, "Column Position=%d; Enum Value=%d", mColumnPosition+1, *((long *)(recordBuffer+mOffset)));
    return;
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    logger.LogVarArgs(LOG_DEBUG, "Column Position=%d; Integer Value=%d", mColumnPosition+1, *((long *)(recordBuffer+mOffset)));
    return;
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    logger.LogVarArgs(LOG_DEBUG, "Column Position=%d; Boolean Value=%s", mColumnPosition+1, 
                                      *((bool *)(recordBuffer+mOffset)) ? "true" : "false");
    return;
  }
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  case MTPipelineLib::PROP_TYPE_STRING:
  {
    std::wstring wstr(*((wchar_t **)(recordBuffer+mOffset)));
    std::string utf8Str;
    ::WideStringToUTF8(wstr, utf8Str);
    logger.LogVarArgs(LOG_DEBUG, "Column Position=%d; Wide String Value=%s", mColumnPosition+1, 
                                      utf8Str.c_str());
    return;
  }
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
  {
    logger.LogVarArgs(LOG_DEBUG, "Column Position=%d; UTF8 String Value=%s", mColumnPosition+1, 
                                           *((char **)(recordBuffer+mOffset)));
    return;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    logger.LogVarArgs(LOG_DEBUG, "Column Position=%d; Big Integer Value=%I64d", mColumnPosition+1, **((_int64 **)(recordBuffer+mOffset)));
    return;
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    logger.LogVarArgs(LOG_DEBUG, "Column Position=%d; Double Value=%E", mColumnPosition+1, **((double **)(recordBuffer+mOffset)));
    return;
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    logger.LogVarArgs(LOG_DEBUG, "Column Position=%d; Datetime Value=%E", mColumnPosition+1, **((date_time_traits::pointer*)(recordBuffer+mOffset)));
    return;
  }
  }
}

void ConditionBase::Load(record_t recordBuffer, COdbcPreparedResultSet * rs)
{
  switch(GetColumnType())
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    COdbcDecimal odbcDec = rs->GetDecimal(mColumnPosition+1);
    *((decimal_traits::pointer*)(recordBuffer + mOffset)) = GetDecimalConstant(mConstantPool, odbcDec);
    break;
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    *((long *)(recordBuffer + mOffset)) = (long) rs->GetInteger(mColumnPosition+1);
    break;
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    *((long *)(recordBuffer + mOffset)) = (long) rs->GetInteger(mColumnPosition+1);
    break;
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    *((bool *)(recordBuffer + mOffset)) = 0==strcmp("1", rs->GetString(mColumnPosition+1).c_str()) ? true : false;
    break;
  }
  case MTPipelineLib::PROP_TYPE_STRING:
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  {
    *((wchar_t **)(recordBuffer + mOffset)) = mConstantPool->GetWideStringConstant(rs->GetWideString(mColumnPosition+1).c_str());
    break;
  }
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
  {
    *((char **)(recordBuffer + mOffset)) = mConstantPool->GetUTF8StringConstant(rs->GetString(mColumnPosition+1).c_str());
    break;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    *((boost::int64_t **)(recordBuffer + mOffset)) =  mConstantPool->GetBigIntegerConstant(rs->GetBigInteger(mColumnPosition+1));
    break;
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    *((double **)(recordBuffer + mOffset)) =  mConstantPool->GetDoubleConstant(rs->GetDouble(mColumnPosition+1));
    break;
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    COdbcTimestamp ts = rs->GetTimestamp(mColumnPosition+1);
    date_time_traits::value dt;
    ::OdbcTimestampToOLEDate(ts.GetBuffer(), &dt);
    *((date_time_traits::pointer*)(recordBuffer + mOffset)) =  mConstantPool->GetDoubleConstant(dt);
    break;
  }
  }
  if (rs->WasNull())
  {
    if(mIsRequired)
    {
      std::string buffer("The condition property ");
      buffer += rs->GetMetadata()[mColumnPosition+1]->GetColumnName();
      buffer += " is required but NULL in the database";
      throw MTErrorObjectException(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE,
                                   "FixedOperatorCondition::Load", buffer.c_str());
    }
    else
    {
      // Set the null bit
      SetNull(recordBuffer);
    }
  }
}

PhysicalFieldType ConditionBase::Convert(MTPipelineLib::PropValType ty)
{
  switch(ty)
	{
	case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
	case MTPipelineLib::PROP_TYPE_STRING:
		return PhysicalFieldType::StringDomain();
	case MTPipelineLib::PROP_TYPE_ASCII_STRING:
		return PhysicalFieldType::UTF8StringDomain();
	case MTPipelineLib::PROP_TYPE_INTEGER:
		return PhysicalFieldType::Integer();
	case MTPipelineLib::PROP_TYPE_BIGINTEGER:
		return PhysicalFieldType::BigIntegerDomain();
	case MTPipelineLib::PROP_TYPE_DATETIME:
		return PhysicalFieldType::DatetimeDomain();
	case MTPipelineLib::PROP_TYPE_DOUBLE:
	case MTPipelineLib::PROP_TYPE_DECIMAL:
		return PhysicalFieldType::DecimalDomain();
	case MTPipelineLib::PROP_TYPE_ENUM:
		return PhysicalFieldType::Enum();
	case MTPipelineLib::PROP_TYPE_BOOLEAN:
		return PhysicalFieldType::Boolean();
	case MTPipelineLib::PROP_TYPE_TIME:
		return PhysicalFieldType::Datetime();
	case MTPipelineLib::PROP_TYPE_OPAQUE:
		return PhysicalFieldType::Binary();
	default:
	{
    ASSERT(FALSE);
		return PhysicalFieldType::StringDomain();
  }
	}
}

class FixedOperatorCondition : public ConditionBase
{
private:
  RuleSetStaticExecution::OpCode mOperator;
public:
  FixedOperatorCondition(RuleSetStaticExecution * ruleSet, long sessionProperty, MTPipelineLib::PropValType sessionType, 
                         bool isRequired, long position, long columnPosition, long offset, const std::wstring& name, RuleSetStaticExecution::OpCode opCode);
  bool Evaluate(const unsigned char * recordBuffer, MemoizedSession * session);
  void Load(unsigned char * recordBuffer, COdbcPreparedResultSet * rs);
};

class OperatorPerRowCondition : public ConditionBase
{
public:
  OperatorPerRowCondition(RuleSetStaticExecution * ruleSet, long sessionProperty, MTPipelineLib::PropValType sessionType, 
                          bool isRequired, long position, long columnPosition, long offset, const std::wstring& name);
  bool Evaluate(const unsigned char * recordBuffer, MemoizedSession * session);
  void Load(unsigned char * recordBuffer, COdbcPreparedResultSet * rs);
};

class Action : public ConditionBase
{
public:
  Action(RuleSetStaticExecution * ruleSet, long sessionProperty, MTPipelineLib::PropValType sessionType, 
         bool isRequired, long position, long columnPosition, long offset, const std::wstring& name);
  ~Action() {}
  bool Evaluate(const unsigned char * recordBuffer, MemoizedSession * session);
  void Load(unsigned char * recordBuffer, COdbcPreparedResultSet * rs);
};

///////////////////////////////////////////////////////////////
// Implementation

void * RuleSetStaticExecution::malloc(size_t sz)
{
  return ::malloc(sz);
}

void RuleSetStaticExecution::free(void * p)
{
  return ::free(p);
}

RuleSetStaticExecution::RuleSetStaticExecution(OptimizedRateScheduleLoader * loader)
  :
  mLoader(loader),
  mIndexedPropertyPosition(-1)
{
}

RuleSetStaticExecution::~RuleSetStaticExecution()
{
  for(std::vector<ConditionBase *>::iterator it = mConditions.begin(); it != mConditions.end(); it++)
  {
    delete (*it);
  }
  for(std::vector<Action *>::iterator it = mActions.begin(); it != mActions.end(); it++)
  {
    delete (*it);
  }
}


void RuleSetStaticExecution::Init(MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr aParamTableDef)
{
	LoggerConfigReader configReader;
  mLogger.Init(configReader.ReadConfiguration("logging"), "[RuleSetStaticExcution]");
  
  NAMEIDLib::IMTNameIDPtr nameid(__uuidof(NAMEIDLib::MTNameID));

  mTableName = (const wchar_t *)aParamTableDef->DBTableName;
  mParameterTable = aParamTableDef->ID;

  // We need to know the size of the bitmap first. Then we create conditions and actions.
  MTPRODUCTCATALOGLib::IMTCollectionPtr conditions = aParamTableDef->ConditionMetaData;
  MTPRODUCTCATALOGLib::IMTCollectionPtr actions = aParamTableDef->ActionMetaData;

  long conditionCount = conditions->Count;
  long actionCount = actions->Count;

  // Go get database metadata so that we can bind to the appropriate ordinal position.
  MTautoptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  MTautoptr<COdbcStatement> stmt = conn->CreateStatement();
  MTautoptr<COdbcResultSet> rs = stmt->ExecuteQueryW(std::wstring(L"SELECT * FROM ") + mTableName + std::wstring(L" WHERE 0=1"));

  _bstr_t indexedPropertyName = aParamTableDef->GetIndexedProperty();

  // Find the size of the null bitmap (must be a multiple of 4bytes = 32bits).
  long nullBitmapSize = (conditionCount + actionCount + 31)/32;
  // The current offset of the buffer.  The buffer starts with a linked list pointer and the null bitmap.
  // In our buffers, fields will be in the order of the metadata not the database.
  long bufferOffset = nullBitmapSize*sizeof(long)+sizeof(void*);
  for(long i=1; i<=conditionCount; i++)
  {
    MTPRODUCTCATALOGLib::IMTConditionMetaDataPtr condition = conditions->Item[i];

    // Skip the indexed property; it is not handled as part of the 
    // rate schedule proper, but rather by the indexed rate schedule
    // PCRater::WeightedRate method.
    if (indexedPropertyName == condition->PropertyName) 
    {
      _bstr_t tmpColumnName = condition->ColumnName;
      const char * asciiColumnName = (const char *) tmpColumnName;
      for(unsigned int j=0; j<rs->GetMetadata().size(); j++)
      {
        if(0==stricmp(asciiColumnName, rs->GetMetadata()[j]->GetColumnName().c_str()))
        {
          mIndexedPropertyPosition = (long) j;
          break;
        }
      }

      if (mIndexedPropertyPosition == -1)
      {
        throw MTErrorObjectException(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
                                     "RuleSetStaticExecution::Init", 
                                     "IndexedProperty column not found in table");
      }

      // Don't process this as a regular condition.
      continue;
    }

    // Session property name
    long sessionProperty = nameid->GetNameID(condition->PropertyName);

    // Database column position
    long columnPosition = -1;
    _bstr_t bstrColName = condition->ColumnName;
    const char * colName = (const char *)bstrColName;
    // Find the appropriate column position in the table.
    for(unsigned int j=0; j<rs->GetMetadata().size(); j++)
    {
      if(0==stricmp(colName, rs->GetMetadata()[j]->GetColumnName().c_str()))
      {
        columnPosition = (long) j;
        break;
      }
    }
    if (columnPosition == -1)
    {
      ASSERT(FALSE);
    }
    
    
    if (VARIANT_TRUE == condition->OperatorPerRule)
    {
      // Must correct for presence of per rule column; it occurs before the position 
      // we matched.
      mConditions.push_back(new OperatorPerRowCondition(this, sessionProperty, (MTPipelineLib::PropValType) condition->DataType, 
                                                        condition->Required == VARIANT_TRUE, i-1, 
                                                        columnPosition-1, bufferOffset, (const wchar_t *)bstrColName));
      // Buffer will use one slot for operator and one for data
      bufferOffset += 8;
    }
    else
    {
      mConditions.push_back(new FixedOperatorCondition(this, sessionProperty, (MTPipelineLib::PropValType) condition->DataType, 
                                                        condition->Required == VARIANT_TRUE, i-1, 
                                                        columnPosition, bufferOffset, (const wchar_t *)bstrColName, 
                                                       GetOpCode(condition->Operator, (MTPipelineLib::PropValType) condition->DataType)));
      bufferOffset += 4;
    }
  }

  // Move on to the actions
  for(long i=1; i<=actionCount; i++)
  {
    MTPRODUCTCATALOGLib::IMTActionMetaDataPtr action = actions->Item[i];

    // Session property name
    long sessionProperty = nameid->GetNameID(action->PropertyName);

    // Database column position
    long columnPosition = -1;
    _bstr_t bstrColName = action->ColumnName;
    const char * colName = (const char *)bstrColName;
    // Find the appropriate column position in the table.
    for(unsigned int j=0; j<rs->GetMetadata().size(); j++)
    {
      if(0==stricmp(colName, rs->GetMetadata()[j]->GetColumnName().c_str()))
      {
        columnPosition = (long) j;
        break;
      }
    }
    if (columnPosition == -1)
    {
      ASSERT(FALSE);
    }
    
    
    mActions.push_back(new Action(this, sessionProperty, (MTPipelineLib::PropValType) action->DataType, 
                                  action->Required == VARIANT_TRUE, i+conditionCount-1, 
                                  columnPosition, bufferOffset, (const wchar_t *)bstrColName));
    bufferOffset += 4;
  }

  // We have the final length of the buffer we need.
  mRecordLength=bufferOffset;
}

void RuleSetStaticExecution::LoadFromDatabase(MTautoptr<COdbcPreparedResultSet> rs, time_t aModifiedAt)
{
  int id_sched=-1;
  CachedRateScheduleOptimized * rateSched = NULL;
  while(rs->Next())
  {
    // Check to see if we have a new rate schedule.
    if (id_sched != rs->GetInteger(1))
    {
      id_sched = rs->GetInteger(1);
      rateSched = mLoader->CreateRateScheduleOptimized(this, mParameterTable, aModifiedAt);
      mSchedules[id_sched] = rateSched;
    }
    unsigned char * buf = rateSched->AllocateBuffer(mRecordLength);
    for(std::vector<ConditionBase *>::iterator it = mConditions.begin();
        it != mConditions.end();
        it++)
    {
      (*it)->Load(buf, rs);
    }
    for(std::vector<Action *>::iterator it = mActions.begin();
        it != mActions.end();
        it++)
    {
      (*it)->Load(buf, rs);
    }
  }
}

void RuleSetStaticExecution::LoadIndexedFromDatabase(MTautoptr<COdbcPreparedResultSet> rs, time_t aModifiedAt)
{
  int id_sched=-1;
  DECIMAL * indexValue = NULL;
  DECIMAL * zeroDecimalValue = NULL;
  DECIMAL * maxDecimalValue = NULL;
  CachedRateScheduleOptimized * rateSched = NULL;
  IndexedRulesOptimized * rules = NULL;
  CachedRateSchedule::IndexedRulesVector * rulesVector = NULL;

  // Initialize zero and max decimal values.
  // Initialize current index value to 0.
  zeroDecimalValue = ::GetDecimalConstant(this, COdbcDecimal());
  indexValue = zeroDecimalValue;

  while(rs->Next())
  {
    DECIMAL * currentIndexValue = NULL;
    COdbcDecimal odbcIndexValue = rs->GetDecimal(mIndexedPropertyPosition+1);
    if (rs->WasNull())
    {
      // Interpret database NULL as max decimal.
      if (maxDecimalValue == NULL)
      {
        MTDecimal maxMTDecimal(METRANET_DECIMAL_MAX_VALUE_STR);
        COdbcDecimal odbcDecimal;
        ::DecimalToOdbcNumeric(&maxMTDecimal, (SQL_NUMERIC_STRUCT *) odbcDecimal.GetBuffer());
        maxDecimalValue = ::GetDecimalConstant(this, odbcDecimal);
      }
      currentIndexValue = maxDecimalValue;
    }
    else
    {
      currentIndexValue = ::GetDecimalConstant(this, odbcIndexValue);
    }
    // Check to see if we have a new rate schedule or if we have new indexed property value.
    if (id_sched != rs->GetInteger(1))
    {
      id_sched = rs->GetInteger(1);
      rateSched = mLoader->CreateRateScheduleOptimized(this, mParameterTable, aModifiedAt);
      rulesVector = new CachedRateSchedule::IndexedRulesVector();
      rateSched->SetIndex(rulesVector);
      mSchedules[id_sched] = rateSched;
      rules = new IndexedRulesOptimized(this, *zeroDecimalValue, *currentIndexValue);
      rulesVector->push_back(MTautoptr<IndexedRules>(rules));
      indexValue = currentIndexValue;
    }
    else if (indexValue != currentIndexValue)
    {
      rules = new IndexedRulesOptimized(this, *indexValue, *currentIndexValue);
      rulesVector->push_back(MTautoptr<IndexedRules>(rules));
      indexValue = currentIndexValue;
    }

    unsigned char * buf = rules->AllocateBuffer(mRecordLength);
    for(std::vector<ConditionBase *>::iterator it = mConditions.begin();
        it != mConditions.end();
        it++)
    {
      (*it)->Load(buf, rs);
    }
    for(std::vector<Action *>::iterator it = mActions.begin();
        it != mActions.end();
        it++)
    {
      (*it)->Load(buf, rs);
    }
  }
}

CachedRateScheduleOptimized * RuleSetStaticExecution::LoadFromDatabase(int aSchedID, time_t aModifiedAt)
{
  MTautoptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  wchar_t buf[256];
  wsprintf(buf, L"SELECT * FROM %s WHERE id_sched = %d AND tt_end = dbo.mtmaxdate() ORDER BY id_sched asc, n_order asc", mTableName.c_str(), aSchedID);
  MTautoptr<COdbcPreparedArrayStatement> stmt = conn->PrepareStatement(buf);
  MTautoptr<COdbcPreparedResultSet> rs = stmt->ExecuteQuery();

  if (mIndexedPropertyPosition != -1)
  {
    LoadIndexedFromDatabase(rs, aModifiedAt);
  }
  else
  {
    LoadFromDatabase(rs, aModifiedAt);
  }
  //CR 13593: handle rate schedules with no rules
  // (merged in lost Rev 3 from V4.0-Rel)
  std::map<int, CachedRateScheduleOptimized *>::iterator it = mSchedules.find(aSchedID);
  if(it == mSchedules.end())
  {
    //make things compatible with the past
    //create empty rs object
    CachedRateScheduleOptimized* rateSched = mLoader->CreateRateScheduleOptimized(this, mParameterTable, aModifiedAt);
    pair<map<int, CachedRateScheduleOptimized*>::iterator, bool> findit = 
      mSchedules.insert(make_pair(aSchedID, rateSched));
    ASSERT(findit.second == true);
    return findit.first->second;
  }
  else
    return it->second;
}


void RuleSetStaticExecution::LoadFromDatabase(RATESCHEDULEVECTOR & aRateSchedInfo, time_t aModifiedAt)
{
  LoadFromDatabase(aModifiedAt);
  // Walk the list of rate schedules.
  for(std::map<int, CachedRateScheduleOptimized *>::const_iterator mapIt = mSchedules.begin();
      mapIt != mSchedules.end();
      mapIt++)
  {
    aRateSchedInfo.push_back(RateScheduleInfo(mapIt->first, mapIt->second));
  }
  return;
}

void RuleSetStaticExecution::LoadFromDatabase(time_t aModifiedAt)
{
  MTautoptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  MTautoptr<COdbcPreparedArrayStatement> stmt = conn->PrepareStatement(std::wstring(L"SELECT * FROM ") + mTableName + std::wstring(L" WHERE tt_end = dbo.mtmaxdate() ORDER BY id_sched asc, n_order asc"));
  MTautoptr<COdbcPreparedResultSet> rs = stmt->ExecuteQuery();
  if (mIndexedPropertyPosition != -1)
  {
    LoadIndexedFromDatabase(rs, aModifiedAt);
  }
  else
  {
    LoadFromDatabase(rs, aModifiedAt);
  }
}

bool RuleSetStaticExecution::Evaluate(CMTSessionBase * sess, BufferList * sched)
{
  BufferListIterator rsIt(sched);
  MemoizedSession msess(sess);
  while(rsIt.Next())
  {
    unsigned char * buf = rsIt.GetRateBuffer();
    bool result = true;
    for(std::vector<ConditionBase *>::iterator it = mConditions.begin();
        it != mConditions.end() && result;
        it++)
    {
      result = (*it)->Evaluate(buf, &msess);
    }
    
    if (!result) continue;
    for(std::vector<Action *>::iterator it = mActions.begin();
        it != mActions.end();
        it++)
    {
      (*it)->Evaluate(buf, &msess);
    }    
    return true;
  }
  return false;
}

RuleSetStaticExecution::OpCode RuleSetStaticExecution::GetOpCodeFromOffset(int opCodeOffset, MTPipelineLib::PropValType sessionType)
{
  if ((sessionType == MTPipelineLib::PROP_TYPE_BOOLEAN || sessionType == MTPipelineLib::PROP_TYPE_STRING ||
       sessionType == MTPipelineLib::PROP_TYPE_UNICODE_STRING) && opCodeOffset > 1)
    throw MTErrorObjectException(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
                                 "RuleSetStaticExecution::GetOpCodeFromOffset", 
                                 "Boolean and String ruleset conditions only support equals and not_equals operators");

  switch(sessionType)
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
    return (OpCode) (DECIMAL_EQUALS + opCodeOffset);
  case MTPipelineLib::PROP_TYPE_ENUM:
    return (OpCode) (ENUM_EQUALS + opCodeOffset);
  case MTPipelineLib::PROP_TYPE_INTEGER:
    return (OpCode) (INTEGER_EQUALS + opCodeOffset);
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
    return (OpCode) (BIGINTEGER_EQUALS + opCodeOffset);
  case MTPipelineLib::PROP_TYPE_DOUBLE:
    return (OpCode) (DOUBLE_EQUALS + opCodeOffset);
  case MTPipelineLib::PROP_TYPE_DATETIME:
    return (OpCode) (DATETIME_EQUALS + opCodeOffset);
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  case MTPipelineLib::PROP_TYPE_STRING:
    return (OpCode) (WIDESTRING_EQUALS + opCodeOffset);
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
    return (OpCode) (BOOLEAN_EQUALS + opCodeOffset);
  default:
    ASSERT(FALSE);
    return DECIMAL_EQUALS;
  }
}

RuleSetStaticExecution::OpCode RuleSetStaticExecution::GetOpCode(long op, MTPipelineLib::PropValType sessionType)
{
  int opCodeOffset=-1;

  // The order here matters and must be the same as the order of the
  // op codes in the enumerator.
  switch(op)
  {
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_EQUAL: opCodeOffset = 0; break;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_NOT_EQUAL: opCodeOffset = 1; break;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_GREATER: opCodeOffset = 2; break;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_GREATER_EQUAL: opCodeOffset = 3; break;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_LESS: opCodeOffset = 4; break;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_LESS_EQUAL: opCodeOffset = 5; break;
  default: ASSERT(FALSE); break;
  }

  return GetOpCodeFromOffset(opCodeOffset, sessionType);
}

RuleSetStaticExecution::OpCode RuleSetStaticExecution::GetOpCode(const wchar_t * opStr, MTPipelineLib::PropValType sessionType)
{
  int opCodeOffset=-1;
  // First decode the string.

  // The order here matters and must be the same as the order of the
  // op codes in the enumerator.
  if (0==wcscmp(L"=", opStr))
  {
    opCodeOffset = 0;
  }
  else if (0==wcscmp(L"!=", opStr))
  {
    opCodeOffset = 1;
  }
  else if (0==wcscmp(L">", opStr))
  {
    opCodeOffset = 2;
  }
  else if (0==wcscmp(L">=", opStr))
  {
    opCodeOffset = 3;
  }
  else if (0==wcscmp(L"<", opStr))
  {
    opCodeOffset = 4;
  }
  else if (0==wcscmp(L"<=", opStr))
  {
    opCodeOffset = 5;
  }
  else
  {
    std::wstring buffer(L"The operator ");
    buffer += opStr;
    buffer += L" is invalid";
    std::string utf8Buffer;
    WideStringToUTF8(buffer, utf8Buffer);
    throw MTErrorObjectException(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
                                 "RuleSetStaticExecution::GetOpCode", utf8Buffer.c_str());
  }
  return GetOpCodeFromOffset(opCodeOffset, sessionType);
}

void RuleSetStaticExecution::Print()
{
  for(std::map<int, CachedRateScheduleOptimized *>::const_iterator mapit=mSchedules.begin();
      mapit != mSchedules.end();
      mapit++)
  {
    LoggerConfigReader configReader;
    NTLogger logger;
    logger.Init(configReader.ReadConfiguration("logging"), "[RateInterpreter]");
    
    BufferListIterator rsit(mapit->second);
    while(rsit.Next())
    {
      unsigned char * buf = rsit.GetRateBuffer();

      for(std::vector<ConditionBase *>::iterator it = mConditions.begin(); it != mConditions.end(); it++)
      {
        (*it)->Print(buf, logger);
      }
      for(std::vector<Action *>::iterator it = mActions.begin(); it != mActions.end(); it++)
      {
        (*it)->Print(buf, logger);
      }
    }
  }
}

ConditionBase::ConditionBase(RuleSetStaticExecution * ruleSet, long sessionProperty, MTPipelineLib::PropValType sessionType, bool isRequired, 
                             long position, long columnPosition, long offset, const std::wstring& name)
  :
  DatabaseColumn(ruleSet, Convert(sessionType), isRequired, position, columnPosition, offset, name),
  mRuleSet(ruleSet),
  mSessionProperty(sessionProperty)
{
}

FixedOperatorCondition::FixedOperatorCondition(RuleSetStaticExecution * ruleSet, long sessionProperty, 
                                               MTPipelineLib::PropValType sessionType, bool isRequired, 
                                               long position, long columnPosition, long offset, const std::wstring& name, RuleSetStaticExecution::OpCode opCode)
  :
  ConditionBase(ruleSet, sessionProperty, sessionType, isRequired, position, columnPosition, offset, name),
  mOperator(opCode)
{
}

OperatorPerRowCondition::OperatorPerRowCondition(RuleSetStaticExecution * ruleSet, long sessionProperty, 
                                                  MTPipelineLib::PropValType sessionType, bool isRequired, 
                                                  long position, long columnPosition, long offset, const std::wstring& name)
  :
  ConditionBase(ruleSet, sessionProperty, sessionType, isRequired, position, columnPosition, offset, name)
{
}

Action::Action(RuleSetStaticExecution * ruleSet, long sessionProperty, 
               MTPipelineLib::PropValType sessionType, bool isRequired, 
               long position, long columnPosition, long offset, const std::wstring& name)
  :
  ConditionBase(ruleSet, sessionProperty, sessionType, isRequired, position, columnPosition, offset, name)
{
}

bool ConditionBase::Evaluate(RuleSetStaticExecution::OpCode op, const unsigned char * recordBuffer, MemoizedSession * session)
{
  switch(op)
  {
  case RuleSetStaticExecution::DECIMAL_EQUALS:
  {
    DECIMAL dec = session->GetDecimalProperty(mSessionProperty);
    DECIMAL * cstDec = *((DECIMAL **)(recordBuffer + mOffset));
    HRESULT hr = ::VarDecCmp(&dec, cstDec);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    return hr == VARCMP_EQ;
  }
  case RuleSetStaticExecution::DECIMAL_GT:
  {
    DECIMAL dec = session->GetDecimalProperty(mSessionProperty);
    DECIMAL * cstDec = *((DECIMAL **)(recordBuffer + mOffset));
    HRESULT hr = ::VarDecCmp(&dec, cstDec);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    return hr == VARCMP_GT;
  }
  case RuleSetStaticExecution::DECIMAL_GTEQ:
  {
    DECIMAL dec = session->GetDecimalProperty(mSessionProperty);
    DECIMAL * cstDec = *((DECIMAL **)(recordBuffer + mOffset));
    HRESULT hr = ::VarDecCmp(&dec, cstDec);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    return hr == VARCMP_GT || hr == VARCMP_EQ;
  }
  case RuleSetStaticExecution::DECIMAL_LT:
  {
    DECIMAL dec = session->GetDecimalProperty(mSessionProperty);
    DECIMAL * cstDec = *((DECIMAL **)(recordBuffer + mOffset));
    HRESULT hr = ::VarDecCmp(&dec, cstDec);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    return hr == VARCMP_LT;
  }
  case RuleSetStaticExecution::DECIMAL_LTEQ:
  {
    DECIMAL dec = session->GetDecimalProperty(mSessionProperty);
    DECIMAL * cstDec = *((DECIMAL **)(recordBuffer + mOffset));
    HRESULT hr = ::VarDecCmp(&dec, cstDec);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    return hr == VARCMP_LT || hr == VARCMP_EQ;
  }
  case RuleSetStaticExecution::DECIMAL_NOTEQUALS:
  {
    DECIMAL dec = session->GetDecimalProperty(mSessionProperty);
    DECIMAL * cstDec = *((DECIMAL **)(recordBuffer + mOffset));
    HRESULT hr = ::VarDecCmp(&dec, cstDec);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    return hr == VARCMP_LT || hr == VARCMP_GT;
  }
  case RuleSetStaticExecution::ENUM_EQUALS:
  {
    return session->GetEnumProperty(mSessionProperty) == *((long *)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::ENUM_GT:
  {
    return session->GetEnumProperty(mSessionProperty) > *((long *)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::ENUM_GTEQ:
  {
    return session->GetEnumProperty(mSessionProperty) >= *((long *)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::ENUM_LT:
  {
    return session->GetEnumProperty(mSessionProperty) < *((long *)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::ENUM_LTEQ:
  {
    return session->GetEnumProperty(mSessionProperty) <= *((long *)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::ENUM_NOTEQUALS:
  {
    return session->GetEnumProperty(mSessionProperty) != *((long *)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::INTEGER_EQUALS:
  {
    return session->GetLongProperty(mSessionProperty) == *((long *)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::INTEGER_GT:
  {
    return session->GetLongProperty(mSessionProperty) > *((long *)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::INTEGER_GTEQ:
  {
    return session->GetLongProperty(mSessionProperty) >= *((long *)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::INTEGER_LT:
  {
    return session->GetLongProperty(mSessionProperty) < *((long *)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::INTEGER_LTEQ:
  {
    return session->GetLongProperty(mSessionProperty) <= *((long *)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::INTEGER_NOTEQUALS:
  {
    return session->GetLongProperty(mSessionProperty) != *((long *)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::BIGINTEGER_EQUALS:
  {
    return session->GetLongLongProperty(mSessionProperty) == **((__int64 **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::BIGINTEGER_GT:
  {
    return session->GetLongLongProperty(mSessionProperty) > **((__int64 **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::BIGINTEGER_GTEQ:
  {
    return session->GetLongLongProperty(mSessionProperty) >= **((__int64 **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::BIGINTEGER_LT:
  {
    return session->GetLongLongProperty(mSessionProperty) < **((__int64 **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::BIGINTEGER_LTEQ:
  {
    return session->GetLongLongProperty(mSessionProperty) <= **((__int64 **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::BIGINTEGER_NOTEQUALS:
  {
    return session->GetLongLongProperty(mSessionProperty) != **((__int64 **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::DOUBLE_EQUALS:
  {
    return session->GetDoubleProperty(mSessionProperty) == **((double **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::DOUBLE_GT:
  {
    return session->GetDoubleProperty(mSessionProperty) > **((double **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::DOUBLE_GTEQ:
  {
    return session->GetDoubleProperty(mSessionProperty) >= **((double **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::DOUBLE_LT:
  {
    return session->GetDoubleProperty(mSessionProperty) < **((double **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::DOUBLE_LTEQ:
  {
    return session->GetDoubleProperty(mSessionProperty) <= **((double **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::DOUBLE_NOTEQUALS:
  {
    return session->GetDoubleProperty(mSessionProperty) != **((double **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::DATETIME_EQUALS:
  {
    return session->GetDatetimeProperty(mSessionProperty) == **((DATE **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::DATETIME_GT:
  {
    return session->GetDatetimeProperty(mSessionProperty) > **((DATE **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::DATETIME_GTEQ:
  {
    return session->GetDatetimeProperty(mSessionProperty) >= **((DATE **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::DATETIME_LT:
  {
    return session->GetDatetimeProperty(mSessionProperty) < **((DATE **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::DATETIME_LTEQ:
  {
    return session->GetDatetimeProperty(mSessionProperty) <= **((DATE **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::DATETIME_NOTEQUALS:
  {
    return session->GetDatetimeProperty(mSessionProperty) != **((DATE **)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::WIDESTRING_EQUALS:
  {
    _bstr_t tmp(session->GetStringProperty(mSessionProperty), false);
    return 0 ==wcscmp(tmp, *((wchar_t **)(recordBuffer + mOffset)));
  }
  case RuleSetStaticExecution::WIDESTRING_NOTEQUALS:
  {
    _bstr_t tmp(session->GetStringProperty(mSessionProperty), false);
    return 0 != wcscmp(tmp, *((wchar_t **)(recordBuffer + mOffset)));
  }
  case RuleSetStaticExecution::BOOLEAN_EQUALS:
  {
    return session->GetBoolProperty(mSessionProperty) == *((bool *)(recordBuffer + mOffset));
  }
  case RuleSetStaticExecution::BOOLEAN_NOTEQUALS:
  {
    return session->GetBoolProperty(mSessionProperty) != *((bool *)(recordBuffer + mOffset));
  }
  default:
  {
    ASSERT(FALSE);
    return false;
  }
  }
}

bool FixedOperatorCondition::Evaluate(const unsigned char * recordBuffer, MemoizedSession * session)
{
  // Check if NULL, if so the we always match.  Otherwise we must check the operator.
  if (GetNull(recordBuffer)) return true;
  return ConditionBase::Evaluate((RuleSetStaticExecution::OpCode) mOperator, recordBuffer, session);
}

void FixedOperatorCondition::Load(unsigned char * recordBuffer, COdbcPreparedResultSet * rs)
{
  switch(GetColumnType())
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    COdbcDecimal odbcDec = rs->GetDecimal(mColumnPosition+1);
    *((DECIMAL **)(recordBuffer + mOffset)) = GetDecimalConstant(mRuleSet, odbcDec);
    break;
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    *((long *)(recordBuffer + mOffset)) = (long) rs->GetInteger(mColumnPosition+1);
    break;
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    *((long *)(recordBuffer + mOffset)) = (long) rs->GetInteger(mColumnPosition+1);
    break;
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    *((bool *)(recordBuffer + mOffset)) = 0==strcmp("1", rs->GetString(mColumnPosition+1).c_str()) ? true : false;
    break;
  }
  case MTPipelineLib::PROP_TYPE_STRING:
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  {
    *((wchar_t **)(recordBuffer + mOffset)) = mRuleSet->GetWideStringConstant(rs->GetWideString(mColumnPosition+1).c_str());
    break;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    *((__int64 **)(recordBuffer + mOffset)) =  mRuleSet->GetBigIntegerConstant(rs->GetBigInteger(mColumnPosition+1));
    break;
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    *((double **)(recordBuffer + mOffset)) =  mRuleSet->GetDoubleConstant(rs->GetDouble(mColumnPosition+1));
    break;
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    COdbcTimestamp ts = rs->GetTimestamp(mColumnPosition+1);
    DATE dt;
    ::OdbcTimestampToOLEDate(ts.GetBuffer(), &dt);
    *((DATE **)(recordBuffer + mOffset)) =  mRuleSet->GetDoubleConstant(dt);
    break;
  }
  }
  if (rs->WasNull())
  {
    if(mIsRequired)
    {
      std::string buffer("The condition property ");
      buffer += rs->GetMetadata()[mColumnPosition+1]->GetColumnName();
      buffer += " is required but NULL in the database";
      throw MTErrorObjectException(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE,
                                   "FixedOperatorCondition::Load", buffer.c_str());
    }
    else
    {
      // Set the null bit
      SetNull(recordBuffer);
    }
  }
}

bool OperatorPerRowCondition::Evaluate(const unsigned char * recordBuffer, MemoizedSession * session)
{
  // Check if NULL, if so the we always match.  Otherwise we must check the operator.
  if (GetNull(recordBuffer)) return true;

  RuleSetStaticExecution::OpCode op = *((RuleSetStaticExecution::OpCode *) (recordBuffer + mOffset));
  // Increment the buffer pointer so we can get the value.
  recordBuffer += sizeof(long);

  return ConditionBase::Evaluate(op, recordBuffer, session);
}

void OperatorPerRowCondition::Load(unsigned char * recordBuffer, COdbcPreparedResultSet * rs)
{
  // First snarf the operator 
  long position = mColumnPosition+1;
  std::wstring opStr = rs->GetWideString(position);
  if (rs->WasNull())
  { 
    if(mIsRequired)
    {
      std::string buffer("The condition property ");
      buffer += rs->GetMetadata()[position]->GetColumnName();
      buffer += " is required but NULL in the database";
      throw MTErrorObjectException(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE,
                                   "OperatorPerRowCondition::Load", buffer.c_str());
    }
    else
    {
      // Set the null bit
      SetNull(recordBuffer);
      return;
    }
  }

  // Use the type of the property and the database operator to get the 
  // OpCode to use at runtime.
  *((long *)(recordBuffer + mOffset)) = mRuleSet->GetOpCode(opStr.c_str(), (MTPipelineLib::PropValType) GetColumnType());

  // Now go after the value, increment recordBuffer and position appropriately.
  position = mColumnPosition+2;
  recordBuffer += sizeof(long);
  switch(GetColumnType())
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    COdbcDecimal odbcDec = rs->GetDecimal(position);
    *((DECIMAL **)(recordBuffer + mOffset)) = GetDecimalConstant(mRuleSet, odbcDec);
    break;
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    *((long *)(recordBuffer + mOffset)) = (long) rs->GetInteger(position);
    break;
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    *((bool *)(recordBuffer + mOffset)) = 0==strcmp("1", rs->GetString(position).c_str()) ? true : false;
    break;
  }
  case MTPipelineLib::PROP_TYPE_STRING:
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  {
    *((wchar_t **)(recordBuffer + mOffset)) = mRuleSet->GetWideStringConstant(rs->GetWideString(position).c_str());
    break;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    *((__int64 **)(recordBuffer + mOffset)) = mRuleSet->GetBigIntegerConstant(rs->GetBigInteger(position));
    break;
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    *((double **)(recordBuffer + mOffset)) = mRuleSet->GetDoubleConstant(rs->GetDouble(position));
    break;
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    COdbcTimestamp ts = rs->GetTimestamp(position);
    DATE dt;
    ::OdbcTimestampToOLEDate(ts.GetBuffer(), &dt);
    *((DATE **)(recordBuffer + mOffset)) =  mRuleSet->GetDoubleConstant(dt);
    break;
  }
  }
  if (rs->WasNull())
  {
    // This cannot be null if we got here.
    std::string buffer("The condition property ");
    buffer += rs->GetMetadata()[position]->GetColumnName();
    buffer += " is NULL but it's corresponding operator is not";
    throw MTErrorObjectException(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE,
                                 "OperatorPerRowCondition::Load", buffer.c_str());
  }
}


bool Action::Evaluate(const unsigned char * recordBuffer, MemoizedSession * session)
{
  // Check if NULL, if so then don't set anything.
  if (GetNull(recordBuffer)) return true;

  switch(GetColumnType())
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    DECIMAL * decVal = *((DECIMAL **)(recordBuffer + mOffset));
    session->SetDecimalProperty(mSessionProperty, *decVal);
    break;
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    session->SetLongProperty(mSessionProperty, *((long *)(recordBuffer + mOffset)));
    break;
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    session->SetEnumProperty(mSessionProperty, *((long *)(recordBuffer + mOffset)));
    break;
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    session->SetBoolProperty(mSessionProperty, *((bool *)(recordBuffer + mOffset)));
    break;
  }
  case MTPipelineLib::PROP_TYPE_STRING:
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  {
    session->SetStringProperty(mSessionProperty, *((wchar_t **)(recordBuffer + mOffset)));
    break;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    session->SetLongLongProperty(mSessionProperty, **((__int64 **)(recordBuffer + mOffset)));
    break;
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    session->SetDoubleProperty(mSessionProperty, **((double **)(recordBuffer + mOffset)));
    break;
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    session->SetDatetimeProperty(mSessionProperty, **((DATE **)(recordBuffer + mOffset)));
    break;
  }
  default:
    throw MTErrorObjectException(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE,
                                   "Action::Evaluate", "Unimplemented PropValType");
  }

  return true;
}

void Action::Load(unsigned char * recordBuffer, COdbcPreparedResultSet * rs)
{
  switch(GetColumnType())
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    COdbcDecimal odbcDec = rs->GetDecimal(mColumnPosition+1);
    *((DECIMAL **)(recordBuffer + mOffset)) = GetDecimalConstant(mRuleSet, odbcDec);
    break;
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    *((long *)(recordBuffer + mOffset)) = (long) rs->GetInteger(mColumnPosition+1);
    break;
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    *((bool *)(recordBuffer + mOffset)) = 0==strcmp("1", rs->GetString(mColumnPosition+1).c_str()) ? true : false;
    break;
  }
  case MTPipelineLib::PROP_TYPE_STRING:
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  {
    *((wchar_t **)(recordBuffer + mOffset)) = mRuleSet->GetWideStringConstant(rs->GetWideString(mColumnPosition+1).c_str());
    break;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    *((__int64 **)(recordBuffer + mOffset)) = mRuleSet->GetBigIntegerConstant(rs->GetBigInteger(mColumnPosition+1));
    break;
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    *((double **)(recordBuffer + mOffset)) = mRuleSet->GetDoubleConstant(rs->GetDouble(mColumnPosition+1));
    break;
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    COdbcTimestamp ts = rs->GetTimestamp(mColumnPosition+1);
    DATE dt;
    ::OdbcTimestampToOLEDate(ts.GetBuffer(), &dt);
    *((DATE **)(recordBuffer + mOffset)) =  mRuleSet->GetDoubleConstant(dt);
    break;
  }
  }
  if (rs->WasNull())
  {
    if(mIsRequired)
    {
      std::string buffer("The action property ");
      buffer += rs->GetMetadata()[mColumnPosition+1]->GetColumnName();
      buffer += " is required but NULL in the database";
      throw MTErrorObjectException(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE,
                                   "Action::Load", buffer.c_str());
    }
    else
    {
      // Set the null bit
      SetNull(recordBuffer);
    }
  }
}

OptimizedRateScheduleLoader::~OptimizedRateScheduleLoader()
{
  for(std::map<int, RuleSetStaticExecution *>::iterator it = mRuleSets.begin();
      it != mRuleSets.end();
      it++)
  {
    delete it->second;
  }
}

CachedRateScheduleOptimized* OptimizedRateScheduleLoader::CreateRateScheduleOptimized(RuleSetStaticExecution * rsse, int aParameterTable, time_t aModifiedAt)
{
  CachedRateScheduleOptimized * rs = new CachedRateScheduleOptimized(rsse, aParameterTable, aModifiedAt);
  return rs;
}

CachedRateSchedule* OptimizedRateScheduleLoader::CreateRateSchedule(int aParameterTable, time_t aModifiedAt)
{
  ASSERT(FALSE);
  return CreateRateScheduleOptimized(NULL, aParameterTable, aModifiedAt);
}

CachedRateSchedule* OptimizedRateScheduleLoader::LoadRateSchedule(int aParamTableID,
                                                                  int aScheduleID,
                                                                  time_t aModifiedAt)
{
  try
  {
    std::map<int, RuleSetStaticExecution *>::iterator it = mRuleSets.find(aParamTableID);
    if (it == mRuleSets.end())
    {
      RuleSetStaticExecution * tmp = new RuleSetStaticExecution(this);
      MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc (__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
      MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr pt = pc->GetParamTableDefinition(aParamTableID);
      tmp->Init(pt);
      mRuleSets[aParamTableID] = tmp;
    }
    RuleSetStaticExecution * rsse = mRuleSets.find(aParamTableID)->second;

    return rsse->LoadFromDatabase(aScheduleID, aModifiedAt);
  }
  catch(_com_error & err)
  {
    // TODO:
    ErrorObject * errobj = CreateErrorFromComError(err);
    SetError(errobj, "Unable to load rate schedule");
    return NULL;
  }
  catch(MTErrorObjectException & errObj)
  {
    SetError(errObj.GetErrorObject(), "Unable to load rate schedule");
    return NULL;
  }
}

BOOL OptimizedRateScheduleLoader::LoadRateSchedules(int                 aParamTableID,
                                                    time_t              aModifiedAt,
                                                    RATESCHEDULEVECTOR& aRateSchedInfo)
{
  try
  {
    std::map<int, RuleSetStaticExecution *>::iterator it = mRuleSets.find(aParamTableID);
    if (it == mRuleSets.end())
    {
      RuleSetStaticExecution * tmp = new RuleSetStaticExecution(this);
      MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc (__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
      MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr pt = pc->GetParamTableDefinition(aParamTableID);
      tmp->Init(pt);
      mRuleSets[aParamTableID] = tmp;
    }
    RuleSetStaticExecution * rsse = mRuleSets.find(aParamTableID)->second;

    rsse->LoadFromDatabase(aRateSchedInfo, aModifiedAt);
  }
  catch(_com_error & err)
  {
    // TODO:
    ErrorObject * errobj = CreateErrorFromComError(err);
    SetError(errobj, "Unable to load rate schedule");
    return FALSE;
  }
  catch(MTErrorObjectException & errObj)
  {
    SetError(errObj.GetErrorObject(), "Unable to load rate schedule");
    return FALSE;
  }
  return TRUE;
}

