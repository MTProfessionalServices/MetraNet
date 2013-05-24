#include "DatabaseSelect.h"
#include "RecordParser.h"
#include "OperatorArg.h"
#include "HashAggregate.h"
#include "SEHException.h"
#include <OdbcConnMan.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcResultSet.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcColumnMetadata.h>

#include <boost/bind.hpp>
#include <boost/regex.hpp>
#include <boost/format.hpp>
#include <boost/thread/thread.hpp>
#include <sstream>
#include <iostream>

void DesignTimeDevNull::handleArg(const OperatorArg& arg)
{
  handleCommonArg(arg);
}

DesignTimeDevNull* DesignTimeDevNull::clone(
                                        const std::wstring& name,
                                        std::vector<OperatorArg *>& args, 
                                        int nInputs, int nOutputs) const
{
  DesignTimeDevNull* result = new DesignTimeDevNull();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeDevNull::type_check()
{
}

RunTimeOperator * DesignTimeDevNull::code_generate(partition_t maxPartition)
{
  return new RunTimeDevNull(mName, *mInputPorts[0]->GetMetadata());
} 

RunTimeDevNull::RunTimeDevNull (const std::wstring& name, 
                                const RecordMetadata& metadata)
  :
  RunTimeOperator(name),
  mMetadata(metadata)
{
}

RunTimeDevNull::~RunTimeDevNull()
{
}

RunTimeOperatorActivation * RunTimeDevNull::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeDevNullActivation(reactor, partition, this);
}

RunTimeDevNullActivation::RunTimeDevNullActivation (Reactor * reactor, 
                                                    partition_t partition,
                                                    const RunTimeDevNull * runTimeDevNull)
  :
  RunTimeOperatorActivationImpl<RunTimeDevNull>(reactor, partition, runTimeDevNull),
  mNumRead(0LL)
{
}

RunTimeDevNullActivation::~RunTimeDevNullActivation()
{
}

void RunTimeDevNullActivation::Start()
{
  RequestRead(0);
}

void RunTimeDevNullActivation::HandleEvent(Endpoint * ep)
{
  ASSERT(ep == mInputs[0]);
  MessagePtr m;
  Read(m, ep);
  if(!mOperator->mMetadata.IsEOF(m))
  {
    mNumRead++;
    RequestRead(0);
  }
  // End of the road for this message.
  mOperator->mMetadata.Free(m); 
}

// Database Select importers.
class OdbcBufferCopy
{
private:
  std::size_t mSourceDataOffset;
  std::size_t mTargetDataOffset;
  std::size_t mLength;
public:
  void Init(std::size_t targetDataOffset,
            std::size_t sourceDataOffset,
            std::size_t length)
  {
    mTargetDataOffset=targetDataOffset;
    mSourceDataOffset=sourceDataOffset;
    mLength=length;
  }    
  void Copy(COdbcRowArrayResultSet * rs, record_t targetRecord)
  {
    CopyInternal(targetRecord, rs->GetDataBuffer());
  }
  void CopyInternal(record_t targetRecord, const boost::uint8_t * sourceBuffer)
  {
//     const boost::uint8_t * const sourceBuffer(rs->GetDataBuffer());
    memcpy(targetRecord + mTargetDataOffset, sourceBuffer + mSourceDataOffset, mLength);
  }
};

class OdbcNullIndicatorCopy
{
private:
  std::size_t mNumElements;
  std::size_t mTargetNullWordOffset;
  std::size_t mTargetNullFlagOffset;
  std::size_t mSourceNullOffset;
public:
  void Init(std::size_t numElements,
            std::size_t targetNullWordOffset,
            std::size_t targetNullFlagOffset,
            std::size_t sourceNullOffset)
  {
    mNumElements = numElements;
    mTargetNullWordOffset = targetNullWordOffset;
    mTargetNullFlagOffset = targetNullFlagOffset;
    mSourceNullOffset = sourceNullOffset;
  }

  void Copy(COdbcRowArrayResultSet * rs, record_t targetRecord)
//   {
//     CopyInternal(targetRecord, rs->GetDataBuffer());
//   }
//   void CopyInternal(record_t targetRecord, const boost::uint8_t * sourceBuffer)
  {
    const boost::uint8_t * const sourceBuffer(rs->GetDataBuffer());
    boost::uint32_t * const targetBitmapWordBegin = (boost::uint32_t *)(targetRecord + mTargetNullWordOffset);
    boost::uint32_t targetBitmapFlagBegin = mTargetNullFlagOffset;

    // I don't actually require this computation because I am using
    // the odbc indicator array to terminate the loop.  However it
    // is illustrative and could be turned into a bitmap iterator class I think.
      // We rely on the fact that our flag will equal 0 at the same time that we need to advance to
      // a new word.
//     boost::uint32_t rawPriority = mTargetNullFlagOffset;
//     boost::uint32_t off;
//     boost::uint8_t zf;
//     __asm { bsr eax, dword ptr [rawPriority] };
//     __asm { mov dword ptr [off], eax }; 
//     __asm { setz zf };
//     ASSERT(0x00 == zf);
//     // This is the ending bit position relative the start current word offset being at bit position 0.
//     // This may be bigger than 31 which means that we end in a new word.
//     off += mNumElements;
//     boost::uint32_t * targetBitmapWordEnd = (boost::uint32_t *)(targetRecord + mTargetNullWordOffset + (off>>5));
//     boost::uint32_t targetBitmapFlagEnd = 1 << (off - ((off>>5)<<5));

    const SQLLEN * const sourceNullBegin ((const SQLLEN *)(sourceBuffer + mSourceNullOffset));
    const SQLLEN * const sourceNullEnd (((const SQLLEN *)(sourceBuffer + mSourceNullOffset)) + mNumElements);
    boost::uint32_t * targetBitmapWordIt = targetBitmapWordBegin;
    boost::uint32_t targetBitmapFlagIt = targetBitmapFlagBegin;
    for(const SQLLEN * it = sourceNullBegin;
        it != sourceNullEnd;
        ++it)
    {
      if (*it == SQL_NULL_DATA)
      {
        *(targetBitmapWordIt) |= targetBitmapFlagIt;   
      }
      else
      {
        *(targetBitmapWordIt) &= (~targetBitmapFlagIt);
      }
      targetBitmapFlagIt <<= 1;
      if(!targetBitmapFlagIt) 
      {
        // Just ran off the end of the current word.
        // Increment word and reset flag iterator.
        targetBitmapFlagIt = 1UL;
        targetBitmapWordIt += 1;
      }
    }
  }
};

class OdbcIntegerImporter
{
private:
  RunTimeDataAccessor mAccessor;
  boost::int32_t mOdbcPosition;
public:
  void Init(const RunTimeDataAccessor& accessor, boost::int32_t odbcPosition)
  {
    mAccessor = accessor;
    mOdbcPosition = odbcPosition;
  }
  void Copy(COdbcRowArrayResultSet * rs, record_t targetRecord)
  {
    boost::int32_t val = rs->GetInteger(mOdbcPosition);
    if (rs->WasNull())
    {
      mAccessor.SetNull(targetRecord);
    }
    else
    {
      mAccessor.SetValue(targetRecord, &val);
    }
  }
};

class OdbcDoubleImporter
{
private:
  RunTimeDataAccessor mAccessor;
  boost::int32_t mOdbcPosition;
public:
  void Init(const RunTimeDataAccessor& accessor, boost::int32_t odbcPosition)
  {
    mAccessor = accessor;
    mOdbcPosition = odbcPosition;
  }
  void Copy(COdbcRowArrayResultSet * rs, record_t targetRecord)
  {
    double val = rs->GetDouble(mOdbcPosition);
    if (rs->WasNull())
    {
      mAccessor.SetNull(targetRecord);
    }
    else
    {
      mAccessor.SetValue(targetRecord, &val);
    }
  }
};

class OdbcBigIntegerImporter
{
private:
  RunTimeDataAccessor mAccessor;
  boost::int32_t mOdbcPosition;
public:
  void Init(const RunTimeDataAccessor& accessor, boost::int32_t odbcPosition)
  {
    mAccessor = accessor;
    mOdbcPosition = odbcPosition;
  }
  void Copy(COdbcRowArrayResultSet * rs, record_t targetRecord)
  {
    boost::int64_t val = rs->GetBigInteger(mOdbcPosition);
    if (rs->WasNull())
    {
      mAccessor.SetNull(targetRecord);
    }
    else
    {
      mAccessor.SetValue(targetRecord, &val);
    }
  }
};

class OdbcDecimalImporter
{
private:
  RunTimeDataAccessor mAccessor;
  boost::int32_t mOdbcPosition;
public:
  void Init(const RunTimeDataAccessor& accessor, boost::int32_t odbcPosition)
  {
    mAccessor = accessor;
    mOdbcPosition = odbcPosition;
  }
  void Copy(COdbcRowArrayResultSet * rs, record_t targetRecord)
  {
    const SQL_NUMERIC_STRUCT * val = rs->GetDecimalBuffer(mOdbcPosition);
    if (rs->WasNull())
    {
      mAccessor.SetNull(targetRecord);
    }
    else
    {
      decimal_traits::value dec;
      ::OdbcNumericToDecimal(val, &dec);
      mAccessor.SetValue(targetRecord, &dec);
    }
  }
};

class OdbcStringImporter
{
private:
  RunTimeDataAccessor mAccessor;
  boost::int32_t mOdbcPosition;
public:
  void Init(const RunTimeDataAccessor& accessor, boost::int32_t odbcPosition)
  {
    mAccessor = accessor;
    mOdbcPosition = odbcPosition;
  }
  void Copy(COdbcRowArrayResultSet * rs, record_t targetRecord)
  {
    const char * val = rs->GetStringBuffer(mOdbcPosition);
    if (rs->WasNull())
    {
      mAccessor.SetNull(targetRecord);
    }
    else
    {
      mAccessor.SetValue(targetRecord, val);
    }
  }
};

class OdbcWideStringImporter
{
private:
  RunTimeDataAccessor mAccessor;
  boost::int32_t mOdbcPosition;
public:
  void Init(const RunTimeDataAccessor& accessor, boost::int32_t odbcPosition)
  {
    mAccessor = accessor;
    mOdbcPosition = odbcPosition;
  }
  void Copy(COdbcRowArrayResultSet * rs, record_t targetRecord)
  {
    const wchar_t * val = rs->GetWideStringBuffer(mOdbcPosition);
    if (rs->WasNull())
    {
      mAccessor.SetNull(targetRecord);
    }
    else
    {
      mAccessor.SetValue(targetRecord, val);
    }
  }
};

class OdbcDatetimeImporter
{
private:
  RunTimeDataAccessor mAccessor;
  boost::int32_t mOdbcPosition;
public:
  void Init(const RunTimeDataAccessor& accessor, boost::int32_t odbcPosition)
  {
    mAccessor = accessor;
    mOdbcPosition = odbcPosition;
  }
  void Copy(COdbcRowArrayResultSet * rs, record_t targetRecord)
  {
    date_time_traits::value dt = rs->GetOLEDate(mOdbcPosition);
    if (rs->WasNull())
    {
      mAccessor.SetNull(targetRecord);
    }
    else
    {
      mAccessor.SetValue(targetRecord, &dt);
    }
  }
};

typedef boost::shared_ptr<COdbcStatement> COdbcStatementPtr;
typedef boost::shared_ptr<COdbcResultSet> COdbcResultSetPtr;

void DesignTimeDatabaseSelect::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"basequery", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetBaseQuery(arg.getNormalizedString());
  }
  else if (arg.is(L"schema", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetSchema(arg.getNormalizedString());
  }
  else if (arg.is(L"maxRecords", OPERATOR_ARG_TYPE_INTEGER, GetName()))
  {
    SetMaxRecordCount(arg.getIntValue());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeDatabaseSelect* DesignTimeDatabaseSelect::clone(
                                                      const std::wstring& name,
                                                      std::vector<OperatorArg *>& args, 
                                                      int nInputs, int nOutputs) const
{
  DesignTimeDatabaseSelect* result = new DesignTimeDatabaseSelect();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeDatabaseSelect::type_check()
{
  COdbcConnectionInfo netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter");  
  COdbcConnectionPtr conn(new COdbcConnection(netMeter));
  if (mSchema != L"NetMeter")
  {
    std::string utf8Schema;
    ::WideStringToUTF8(mSchema, utf8Schema);
    conn->SetSchema(COdbcConnectionManager::GetConnectionInfo(utf8Schema.c_str()).GetCatalog().c_str());  
  }
  conn->SetAutoCommit(true);

  std::string utf8Query;
  ::WideStringToUTF8(GetBaseQuery(), utf8Query);
  boost::regex expr1("%%PARTITION%%");
  char fmt1[255];
  sprintf(fmt1, "%d", 0);
  boost::regex expr2("%%NUMPARTITIONS%%");
  char fmt2[255];
  sprintf(fmt2, "%d", 1);
  boost::regex expr3("%%%NETMETERSTAGE_PREFIX%%%");

  std::ostringstream ostr1;
  std::ostringstream ostr2;
  std::ostringstream ostr3;
  std::ostream_iterator<char,char> oit1(ostr1);
  std::ostream_iterator<char,char> oit2(ostr2);
  std::ostream_iterator<char,char> oit3(ostr3);
  boost::regex_replace(oit1, utf8Query.begin(), utf8Query.end(), expr1, 
                       fmt1, boost::match_default | boost::format_all);
  std::string tmp(ostr1.str());
  boost::regex_replace(oit2, tmp.begin(), tmp.end(), expr2, 
                       fmt2, boost::match_default | boost::format_all); 
  tmp = ostr2.str();
  boost::regex_replace(oit3, tmp.begin(), tmp.end(), expr3, 
                       COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalogPrefix(), 
                       boost::match_default | boost::format_all); 
//   std::cout << ostr2.str() << std::endl;

  COdbcPreparedArrayStatementPtr stmt(conn->PrepareStatement(ostr3.str()));
  const COdbcColumnMetadataVector& dbMetadata(stmt->GetMetadata());
  
  // Transform record metadata from database
  LogicalRecord outputMembers;
  for(unsigned int i=0; i<dbMetadata.size(); i++)
  {
    COdbcColumnMetadata * col = dbMetadata[i];
    std::wstring wstrColName;
    ::ASCIIToWide(wstrColName, col->GetColumnName());
    outputMembers.push_back(RecordMember(wstrColName, 
                                         GetLogicalType(col)));
  }
  RecordMetadata * metadata = new RecordMetadata(outputMembers);
  mOutputPorts[0]->SetMetadata(metadata);  
}

RunTimeOperator * DesignTimeDatabaseSelect::code_generate(partition_t maxPartition)
{
  // Find a spanning tree and then propagate record types
  return new RunTimeDatabaseSelect(mName, maxPartition, mBaseQuery, mSchema, *mOutputPorts[0]->GetMetadata(), mRestrictRecordCount, mMaxRecordCount);
}

LogicalFieldType DesignTimeDatabaseSelect::GetLogicalType(COdbcColumnMetadata * col) 
{
  switch(col->GetDataType())
  {
    case eInteger:
    {
      return LogicalFieldType::Integer(col->IsNullable());
    }
    case eBigInteger: 
    {
      return LogicalFieldType::BigInteger(col->IsNullable());
    }
    case eString: 
    {
      return LogicalFieldType::UTF8String(col->IsNullable());
    }
    case eDecimal: 
    {
      return LogicalFieldType::Decimal(col->IsNullable());
    }
    case eDouble: 
    {
      return LogicalFieldType::Double(col->IsNullable());
    }
    case eDatetime: 
    {
      return LogicalFieldType::Datetime(col->IsNullable());
    }
    case eBinary: 
    {
      return LogicalFieldType::Binary(col->IsNullable());
    }
    case eWideString:
    {
      return LogicalFieldType::String(col->IsNullable());
    }
  }
  throw std::exception("Unknown database type");
}

class AsyncExecuteQueryRowBinding
{
private:
  COdbcPreparedArrayStatement& mStatement;
  COdbcRowArrayResultSet *& mResultSet;  
  boost::int32_t mExitCode;
  std::string mMessage;
public:
  AsyncExecuteQueryRowBinding(COdbcPreparedArrayStatement& stmt, COdbcRowArrayResultSet*& rs);
  ~AsyncExecuteQueryRowBinding();
  void Execute();
  boost::int32_t GetExitCode() const
  {
    return mExitCode;
  }
  const std::string& GetMessage() const
  {
    return mMessage;
  }
};

AsyncExecuteQueryRowBinding::AsyncExecuteQueryRowBinding(COdbcPreparedArrayStatement& stmt, COdbcRowArrayResultSet*& rs)
  :
  mStatement(stmt),
  mResultSet(rs),
  mExitCode(0)
{
}

AsyncExecuteQueryRowBinding::~AsyncExecuteQueryRowBinding()
{
}

void AsyncExecuteQueryRowBinding::Execute()
{
  _set_se_translator(&SEHException::TranslateStructuredExceptionHandlingException);
  try
  {
    mResultSet = mStatement.ExecuteQueryRowBinding();
    mExitCode = 0;
    mMessage = "";
  }
  catch(std::exception & e)
  {    
    mExitCode = -1;
    mMessage = e.what();
    return;
  }
  catch(SEHException & e)
  {    
    mExitCode = -1;
    mMessage = e.what();
    return;
  }
  catch(...)
  {
    mExitCode = -1;
    mMessage = "Unknown exception";
    return;
  }
 }


RunTimeDatabaseSelect::~RunTimeDatabaseSelect()
{
}

RunTimeOperatorActivation * RunTimeDatabaseSelect::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeDatabaseSelectActivation(reactor, partition, this);
}

RunTimeDatabaseSelectActivation::~RunTimeDatabaseSelectActivation()
{
  if (mExecuteThread)
  {
    mExecuteThread->join();
    delete mExecuteThread;
  }
  delete mExecuteQuery;

  delete mResultSet;
  delete mStatement;
  delete mConnection;

  delete [] mImporterData;
}

void RunTimeDatabaseSelectActivation::BuildCopyRun(COdbcRowArrayResultSet * rs,
                                                   const std::vector<RunTimeDataAccessor*>& dataflowMetadata,
                                                   boost::int32_t recordLength,
                                                   std::size_t copyStart,
                                                   std::size_t copyEnd,
                                                   std::size_t sourceCopyStart,
                                                   std::size_t sourceCopyEnd)
{
  const COdbcColumnMetadataVector& dbMetadata(rs->GetMetadata());
  // First build the memcpy for the data.  
  const std::size_t startOffset(dataflowMetadata[copyStart]->GetOffset());
  const std::size_t endOffset(copyEnd==dataflowMetadata.size() ? 
                              recordLength : 
                              dataflowMetadata[copyEnd]->GetOffset());
  const std::size_t sourceStartOffset(rs->GetDataOffset(dbMetadata[sourceCopyStart]->GetOrdinalPosition()));
  const std::size_t sourceEndOffset(sourceCopyEnd==dbMetadata.size() ? 
                                    rs->GetNullOffset() : 
                                    rs->GetDataOffset(dbMetadata[sourceCopyEnd]->GetOrdinalPosition()));
  if ((sourceEndOffset - sourceStartOffset) != (endOffset-startOffset))
  {
    throw std::exception("RunTimeDatabaseSelect::BuildCopyRun: Invalid copy run");
  }

  
  const std::size_t bytesToCopy(endOffset-startOffset);
  
  ((OdbcBufferCopy *)mImporterCurrent)->Init(startOffset,
                                             sourceStartOffset,
                                             bytesToCopy);
  
  boost::function2<void,COdbcRowArrayResultSet *,record_t> copyFunc = boost::bind(&OdbcBufferCopy::Copy, 
                                                                                  ((OdbcBufferCopy *)mImporterCurrent), 
                                                                                   _1, _2);
  mDelegates.push_back(copyFunc);
  mImporterCurrent += sizeof(OdbcBufferCopy);

  // Process Null indicators
  ((OdbcNullIndicatorCopy *)mImporterCurrent)->Init(copyEnd-copyStart,
                                                    dataflowMetadata[copyStart]->GetNullWord(),
                                                    dataflowMetadata[copyStart]->GetNullFlag(),
                                                    rs->GetNullOffset() + sizeof(SQLLEN)*sourceCopyStart);
  boost::function2<void,COdbcRowArrayResultSet*,record_t> nullFunc = boost::bind(&OdbcNullIndicatorCopy::Copy, 
                                                                                 ((OdbcNullIndicatorCopy *)mImporterCurrent),
                                                                                 _1, _2);
  mDelegates.push_back(nullFunc);
  mImporterCurrent += sizeof(OdbcNullIndicatorCopy);
}

void RunTimeDatabaseSelectActivation::Start()
{
  COdbcConnectionInfo netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter");  
  mConnection = new COdbcConnection(netMeter);
  if (mOperator->mSchema != L"NetMeter")
  {
    std::string utf8Schema;
    ::WideStringToUTF8(mOperator->mSchema, utf8Schema);
    mConnection->SetSchema(COdbcConnectionManager::GetConnectionInfo(utf8Schema.c_str()).GetCatalog().c_str());  
  }
  mConnection->SetAutoCommit(true);

  std::string utf8Query;
  ::WideStringToUTF8(mOperator->mQuery, utf8Query);
  boost::regex expr1("%%PARTITION%%");
  char fmt1[255];
  sprintf(fmt1, "%d", mPartition);
  boost::regex expr2("%%NUMPARTITIONS%%");
  char fmt2[255];
  sprintf(fmt2, "%d", mOperator->mNumPartitions);
  boost::regex expr3("%%%NETMETERSTAGE_PREFIX%%%");
  boost::regex expr4("option[[:space:]]*\\([[:space:]]*maxdop[[:space:]]+1[[:space:]]*\\)",  boost::regex::perl|boost::regex::icase);
  std::ostringstream ostr1;
  std::ostringstream ostr2;
  std::ostringstream ostr3;
  std::ostream_iterator<char,char> oit1(ostr1);
  std::ostream_iterator<char,char> oit2(ostr2);
  std::ostream_iterator<char,char> oit3(ostr3);
  boost::regex_replace(oit1, utf8Query.begin(), utf8Query.end(), expr1, 
                       fmt1, boost::match_default | boost::format_all);
  std::string tmp(ostr1.str());
  boost::regex_replace(oit2, tmp.begin(), tmp.end(), expr2, 
                       fmt2, boost::match_default | boost::format_all);  
  tmp = ostr2.str();
  boost::regex_replace(oit3, tmp.begin(), tmp.end(), expr3, 
                       COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalogPrefix(), 
                       boost::match_default | boost::format_all); 
  tmp = ostr3.str();
  // If on SQL Server, make sure that we execute with maxdop of 1.
  if (netMeter.IsSqlServer() &&
      !boost::regex_search(tmp.begin(), tmp.end(), expr4, boost::match_default))
  {
    tmp += "\noption(maxdop 1)";
  }
  // Prepare and execute the query asynchronously.
  mStatement = mConnection->PrepareStatement(tmp, 1);
  mExecuteQuery = new AsyncExecuteQueryRowBinding(*mStatement, mResultSet);
  mExecuteThread = new boost::thread(boost::bind(&AsyncExecuteQueryRowBinding::Execute, mExecuteQuery));

  mReactor->RequestWrite(this, mOutputs[0]);
}

void RunTimeDatabaseSelectActivation::SetupImport()
{
  boost::int32_t recordLength = mOperator->mMetadata.GetRecordLength();

  // We need to have the record metdata in physical order to
  // properly perform the memcpy identification.
  std::vector<RunTimeDataAccessor*> physicalOrder;
  for(boost::int32_t i=0;i<mOperator->mMetadata.GetNumColumns();i++)
  {
    physicalOrder.push_back(mOperator->mMetadata.GetColumn(i));
  }  
  std::sort(physicalOrder.begin(), physicalOrder.end(), FieldAddressOffsetOrder());

  std::map<RunTimeDataAccessor*, std::size_t> physicalOrderMap;
  for(std::size_t j=0; j<physicalOrder.size(); ++j)
  {
    physicalOrderMap[physicalOrder[j]] = j;
  }
  
  // Rip through the metdata to create the importer array.
  // Here I am trying to be cache sensitive by allocating a single
  // buffer to contain all of the data used by the HandleEvent call.
  // The delegates go into a separate memory region.
  const COdbcColumnMetadataVector& dbMetadata(mResultSet->GetMetadata());
  mImporterData = new boost::uint8_t [dbMetadata.size()*sizeof(OdbcDecimalImporter)];
  mImporterCurrent = mImporterData;
  mImporterEnd = mImporterData + dbMetadata.size()*sizeof(OdbcDecimalImporter);

  // These mark the beginning and end of a run of copyable elements. 
  // This run will be converted to a memcpy and some fancy null bitmap
  // tweaking.
  std::size_t copyStart(0);
  std::size_t copyEnd(0);
  std::size_t sourceCopyStart(0);
  std::size_t sourceCopyEnd(0);
  for(std::size_t i=0; i<dbMetadata.size(); i++)
  {
    COdbcColumnMetadata * col = dbMetadata[i];
    std::wstring wstrColumn;
    ::ASCIIToWide(wstrColumn, col->GetColumnName());
    RunTimeDataAccessor * field = mOperator->mMetadata.GetColumn(wstrColumn);
    switch(col->GetDataType())
    {
    case eInteger:
    {
      if (copyStart == copyEnd)
      {
        copyStart = physicalOrderMap[field];
        copyEnd = copyStart+1;
        sourceCopyStart = i;
        sourceCopyEnd = sourceCopyStart + 1;
      }
      else if(copyEnd != physicalOrderMap[field])
      {
        BuildCopyRun(mResultSet, physicalOrder, recordLength, copyStart, copyEnd, sourceCopyStart, sourceCopyEnd);
        copyStart = physicalOrderMap[field];
        copyEnd = copyStart+1;
        sourceCopyStart = i;
        sourceCopyEnd = sourceCopyStart + 1;
      }
      else
      {
        copyEnd += 1;
        sourceCopyEnd += 1;
      }
      break;
    }
    case eBigInteger: 
    {
      if (mConnection->GetConnectionInfo().IsOracle())
      {
        // Non-copyable on Oracle
        if (copyStart != copyEnd)
        {
          BuildCopyRun(mResultSet, physicalOrder, recordLength, copyStart, copyEnd, sourceCopyStart, sourceCopyEnd);
          copyStart = copyEnd = 0;
        }
        ((OdbcBigIntegerImporter *)mImporterCurrent)->Init(*field, i+1);
        mDelegates.push_back(boost::bind(&OdbcBigIntegerImporter::Copy, (OdbcBigIntegerImporter *)mImporterCurrent, _1, _2));
        mImporterCurrent += sizeof(OdbcBigIntegerImporter);
      }
      else
      {
        // Copyable on SQL Server
        if (copyStart == copyEnd)
        {
          copyStart = physicalOrderMap[field];
          copyEnd = copyStart+1;
          sourceCopyStart = i;
          sourceCopyEnd = sourceCopyStart + 1;
        }
        else if(copyEnd != physicalOrderMap[field])
        {
          BuildCopyRun(mResultSet, physicalOrder, recordLength, copyStart, copyEnd, sourceCopyStart, sourceCopyEnd);
          copyStart = physicalOrderMap[field];
          copyEnd = copyStart+1;
          sourceCopyStart = i;
          sourceCopyEnd = sourceCopyStart + 1;
        }
        else
        {
          copyEnd += 1;
          sourceCopyEnd += 1;
        }
      }
      break;
    }
    case eString: 
    {
      // Non-copyable 
      if (copyStart != copyEnd)
      {
        BuildCopyRun(mResultSet, physicalOrder, recordLength, copyStart, copyEnd, sourceCopyStart, sourceCopyEnd);
        copyStart = copyEnd = 0;
      }
      ((OdbcStringImporter *)mImporterCurrent)->Init(*field, i+1);
      mDelegates.push_back(boost::bind(&OdbcStringImporter::Copy, (OdbcStringImporter *)mImporterCurrent, _1, _2));
      mImporterCurrent += sizeof(OdbcStringImporter);
      break;
    }
    case eDecimal: 
    {
      // Non-copyable 
      if (copyStart != copyEnd)
      {
        BuildCopyRun(mResultSet, physicalOrder, recordLength, copyStart, copyEnd, sourceCopyStart, sourceCopyEnd);
        copyStart = copyEnd = 0;
      }
      ((OdbcDecimalImporter *)mImporterCurrent)->Init(*field, i+1);
      mDelegates.push_back(boost::bind(&OdbcDecimalImporter::Copy, (OdbcDecimalImporter *)mImporterCurrent, _1, _2));
      mImporterCurrent += sizeof(OdbcDecimalImporter);
      break;
    }
    case eDouble: 
    {
      // Copyable
      if (copyStart == copyEnd)
      {
        copyStart = physicalOrderMap[field];
        copyEnd = copyStart+1;
        sourceCopyStart = i;
        sourceCopyEnd = sourceCopyStart + 1;
      }
      else if(copyEnd != physicalOrderMap[field])
      {
        BuildCopyRun(mResultSet, physicalOrder, recordLength, copyStart, copyEnd, sourceCopyStart, sourceCopyEnd);
        copyStart = physicalOrderMap[field];
        copyEnd = copyStart+1;
        sourceCopyStart = i;
        sourceCopyEnd = sourceCopyStart + 1;
      }
      else
      {
        copyEnd += 1;
        sourceCopyEnd += 1;
      }
      break;
    }
    case eDatetime: 
    {
      // Non-copyable 
      if (copyStart != copyEnd)
      {
        BuildCopyRun(mResultSet, physicalOrder, recordLength, copyStart, copyEnd, sourceCopyStart, sourceCopyEnd);
        copyStart = copyEnd = 0;
      }
      ((OdbcDatetimeImporter *)mImporterCurrent)->Init(*field, i+1);
      mDelegates.push_back(boost::bind(&OdbcDatetimeImporter::Copy, (OdbcDatetimeImporter *)mImporterCurrent, _1, _2));
      mImporterCurrent += sizeof(OdbcDatetimeImporter);
      break;
    }
    case eBinary: 
    {
      // Copyable
      if (copyStart == copyEnd)
      {
        copyStart = physicalOrderMap[field];
        copyEnd = copyStart+1;
        sourceCopyStart = i;
        sourceCopyEnd = sourceCopyStart + 1;
      }
      else if(copyEnd != physicalOrderMap[field])
      {
        BuildCopyRun(mResultSet, physicalOrder, recordLength, copyStart, copyEnd, sourceCopyStart, sourceCopyEnd);
        copyStart = physicalOrderMap[field];
        copyEnd = copyStart+1;
        sourceCopyStart = i;
        sourceCopyEnd = sourceCopyStart + 1;
      }
      else
      {
        copyEnd += 1;
        sourceCopyEnd += 1;
      }
      break;
    }
    case eWideString:
    {
      // Non-copyable 
      if (copyStart != copyEnd)
      {
        BuildCopyRun(mResultSet, physicalOrder, recordLength, copyStart, copyEnd, sourceCopyStart, sourceCopyEnd);
        copyStart = copyEnd = 0;
      }
      ((OdbcWideStringImporter *)mImporterCurrent)->Init(*field, i+1);
      mDelegates.push_back(boost::bind(&OdbcWideStringImporter::Copy, (OdbcWideStringImporter *)mImporterCurrent, _1, _2));
      mImporterCurrent += sizeof(OdbcWideStringImporter);
      break;
    }
    }
  }
  
  // Complete a final copy run.
  if (copyStart != copyEnd)
  {
    BuildCopyRun(mResultSet, physicalOrder, recordLength, copyStart, copyEnd, sourceCopyStart, sourceCopyEnd);
    copyStart = copyEnd = 0;
  }
}

void RunTimeDatabaseSelectActivation::ImportData(COdbcRowArrayResultSet * rs, record_t buffer)
{
  for(std::vector<boost::function2<void,COdbcRowArrayResultSet *,record_t> >::iterator it=mDelegates.begin();
      it != mDelegates.end();
      ++it)
  {
    (*it)(rs,buffer);
  }
}

void RunTimeDatabaseSelectActivation::HandleEvent(Endpoint * out)
{
  if (mExecuteThread != NULL)
  {
    // Wait for execute to finish and the first record to be
    // available.  Then set up all binding information.
    mExecuteThread->join();
    delete mExecuteThread;
    mExecuteThread = NULL;
    if (mExecuteQuery->GetExitCode() != 0)
    {
      throw std::exception(mExecuteQuery->GetMessage().c_str());
    }
    SetupImport();
  }
  if(mResultSet->Next() && (!mOperator->mRestrictRecordCount || mNumWritten < mOperator->mMaxRecordCount))
  {
    record_t buffer = mOperator->mMetadata.Allocate();
    ImportData(mResultSet, buffer);
    Write(buffer, out);
    mNumWritten++;
    mReactor->RequestWrite(this, mOutputs[0]);
  }
  else
  {
    // Send EOF.
    Write(mOperator->mMetadata.AllocateEOF(), out, true);
    // Clean up resources
    delete mResultSet;
    mResultSet = NULL;
    delete mStatement;
    mStatement = NULL;
    delete mConnection;
    mConnection = NULL;
  }
}

DesignTimeHashJoinProbeSpecification::DesignTimeHashJoinProbeSpecification()
  :
  mJoinType(INNER_JOIN),
  mMerger(NULL)
{
}

DesignTimeHashJoinProbeSpecification* DesignTimeHashJoinProbeSpecification::clone() const
{
    DesignTimeHashJoinProbeSpecification* result = new DesignTimeHashJoinProbeSpecification();

    result->SetJoinType(mJoinType);
    result->SetResidual(mResidual);

    for(std::vector<std::wstring>::const_iterator it = mEquiJoinKeys.begin();
        it != mEquiJoinKeys.end();
        it++)
    {
      result->AddEquiJoinKey(*it);
    }

    return result;
}

DesignTimeHashJoinProbeSpecification::~DesignTimeHashJoinProbeSpecification()
{
  delete mMerger;
}

void DesignTimeHashJoinProbeSpecification::SetEquiJoinKeys(const std::vector<std::wstring>& equiJoinKeys)
{
  mEquiJoinKeys = equiJoinKeys;
}

void DesignTimeHashJoinProbeSpecification::AddEquiJoinKey(const std::wstring& equiJoinKey)
{
  mEquiJoinKeys.push_back(equiJoinKey);
}

const std::vector<std::wstring> & DesignTimeHashJoinProbeSpecification::GetEquiJoinKeys() const
{
  return mEquiJoinKeys;
}

void DesignTimeHashJoinProbeSpecification::SetResidual(const std::wstring& residual)
{
  mResidual = residual;
}

const std::wstring & DesignTimeHashJoinProbeSpecification::GetResidual() const
{
  return mResidual;
}

void DesignTimeHashJoinProbeSpecification::SetJoinType(JoinType joinType)
{
  mJoinType = joinType;
}

const DesignTimeHashJoinProbeSpecification::JoinType DesignTimeHashJoinProbeSpecification::GetJoinType() const
{
  return mJoinType;
}

const RecordMerge & DesignTimeHashJoinProbeSpecification::GetMerger() const
{
  return *mMerger;
}

void DesignTimeHashJoinProbeSpecification::SetInputPort(boost::shared_ptr<Port> inputPort)
{
  mInputPort = inputPort;
}

const boost::shared_ptr<Port> DesignTimeHashJoinProbeSpecification::GetInputPort() const
{
  return mInputPort;
}

void DesignTimeHashJoinProbeSpecification::SetOutputPort(boost::shared_ptr<Port> outputPort)
{
  mOutputPort = outputPort;
}

const boost::shared_ptr<Port> DesignTimeHashJoinProbeSpecification::GetOutputPort() const
{
  return mOutputPort;
}

void DesignTimeHashJoinProbeSpecification::SetOutputNonMatchPort(boost::shared_ptr<Port> outputNonMatchPort)
{
  mOutputNonMatchPort = outputNonMatchPort;
}

void DesignTimeHashJoinProbeSpecification::type_check(const DesignTimeHashJoin& op,
                                                      const Port& tablePort,
                                                      const std::vector<std::wstring>& tableEquiJoinKeys)
{
  if (tableEquiJoinKeys.size() != mEquiJoinKeys.size())
  {
    throw KeySizeMismatchException(op, tablePort, *mInputPort);
  }

  // Validate that the equijoin keys exist and have matching types.
  for(std::vector<std::wstring>::const_iterator it = mEquiJoinKeys.begin();
      it != mEquiJoinKeys.end();
      ++it)
  {
    if (!mInputPort->GetMetadata()->HasColumn(*it))
    {
      throw MissingFieldException(op, *mInputPort, *it);
    }
    ASSERT(tablePort.GetMetadata()->HasColumn(tableEquiJoinKeys[it - mEquiJoinKeys.begin()]));
    if (*mInputPort->GetMetadata()->GetColumn(*it)->GetPhysicalFieldType() !=
        *tablePort.GetMetadata()->GetColumn(tableEquiJoinKeys[it - mEquiJoinKeys.begin()])->GetPhysicalFieldType())
    {
      throw FieldTypeMismatchException(op,
                                       *mInputPort, *mInputPort->GetMetadata()->GetColumn(*it),
                                       tablePort, *tablePort.GetMetadata()->GetColumn(tableEquiJoinKeys[it - mEquiJoinKeys.begin()]));
    }
  }

  // Test compile the residual if necessary.
  if (mResidual.size())
  {
    CacheConsciousHashTablePredicateIterator::Compile(*mInputPort->GetMetadata(),
                                                      *tablePort.GetMetadata(), 
                                                      mResidual);
  }

  // Everything cool.
  if (mJoinType == RIGHT_SEMI || mJoinType == RIGHT_ANTI_SEMI)
  {
    RecordMetadata emptyMetadata;
    mMerger = new RecordMerge(&emptyMetadata, mInputPort->GetMetadata());
  }
  else
  {
    mMerger = new RecordMerge(tablePort.GetMetadata(), mInputPort->GetMetadata(),
                              tablePort.GetFullName(), mInputPort->GetFullName());
  }
  mOutputPort->SetMetadata(new RecordMetadata(*mMerger->GetRecordMetadata()));
  if (mJoinType == RIGHT_OUTER_SPLIT)
  {
    mOutputNonMatchPort->SetMetadata(new RecordMetadata(*mInputPort->GetMetadata()));
  }
}

DesignTimeHashJoin::DesignTimeHashJoin()
  :
  mTableSize(32),
  mIsMultiHashJoin(false)
{
  mInputPorts.insert(this, 0, L"table", false);
}

DesignTimeHashJoin::~DesignTimeHashJoin()
{
}

void DesignTimeHashJoin::handleArg(const OperatorArg& arg)
{
  if (mIsMultiHashJoin)
  {
    handleArgForMultiHashJoin(arg);
  }
  else
  {
    if (arg.is(L"tableKey", OPERATOR_ARG_TYPE_STRING, GetName()))
    {
      AddTableEquiJoinKey(arg.getNormalizedString());
    }
    else if (arg.is(L"probeKey", OPERATOR_ARG_TYPE_STRING, GetName()))
    {
      mProbes.back().AddEquiJoinKey(arg.getNormalizedString());
    }
    else if (arg.is(L"residual", OPERATOR_ARG_TYPE_STRING, GetName()))
    {
      mProbes.back().SetResidual(arg.getNormalizedString());
    }
    else if (arg.is(L"tableSize", OPERATOR_ARG_TYPE_INTEGER, GetName()))
    {
      SetTableSize(arg.getIntValue());
    }
    else
    {
      handleCommonArg(arg);
    }
  }
}

void DesignTimeHashJoin::handleArgForMultiHashJoin(const OperatorArg& arg)
{
  if (arg.is(L"tableKey", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddTableEquiJoinKey(arg.getNormalizedString());
  }
  else if (arg.is(L"probe", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mProbes.push_back(DesignTimeHashJoinProbeSpecification());

    if (arg.isValue(L"inner"))
    {
      mProbes.back().SetJoinType(DesignTimeHashJoinProbeSpecification::
                                 INNER_JOIN);
    }
    else if (arg.isValue(L"right") || 
             arg.isValue(L"right outer") ||
             arg.isValue(L"right_outer"))
    {
      mProbes.back().SetJoinType(DesignTimeHashJoinProbeSpecification::
                                 RIGHT_OUTER);
    }
    else if (arg.isValue(L"right split") || 
             arg.isValue(L"right outer split") ||
             arg.isValue(L"right_outer_split"))
    {
      mProbes.back().SetJoinType(DesignTimeHashJoinProbeSpecification::
                                 RIGHT_OUTER_SPLIT);
    }
    else if (arg.isValue(L"right semi") || 
             arg.isValue(L"right_semi"))
    {
      mProbes.back().SetJoinType(DesignTimeHashJoinProbeSpecification::
                                 RIGHT_SEMI);
    }
    else if (arg.isValue(L"right anti semi") || 
             arg.isValue(L"right_anti_semi"))
    {
      mProbes.back().SetJoinType(DesignTimeHashJoinProbeSpecification::
                                 RIGHT_ANTI_SEMI);
    }
    else
    {
      throw DataflowInvalidArgumentValueException(arg.getValueLine(),
                                                  arg.getValueColumn(),
                                                  arg.getFilename(),
                                                  GetName(),
                                                  arg.getName(),
                                                  arg.getStringValue(),
      L"inner,right_outer,right_outer_split,right_semi, or right_anti_semi");
    }
  }
  else if (arg.is(L"probeKey", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    if (mProbes.size() == 0)
      throw SingleOperatorException(*this, L"Must specify probe argument before setting probeKey");

    mProbes.back().AddEquiJoinKey(arg.getNormalizedString());
  }
  else if (arg.is(L"residual", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    if (mProbes.size() == 0)
      throw SingleOperatorException(*this, L"Must specify probe argument before setting residual");
    
    mProbes.back().SetResidual(arg.getNormalizedString());
  }
  else if (arg.is(L"tableSize", OPERATOR_ARG_TYPE_INTEGER, GetName()))
  {
    SetTableSize(arg.getIntValue());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeHashJoin* DesignTimeHashJoin::clone(
                                          const std::wstring& name,
                                          std::vector<OperatorArg *>& args,
                                          int extraInputs, 
                                          int extraOutputs) const
{
  DesignTimeHashJoin* result = new DesignTimeHashJoin();

  result->SetName(name);

  // Notice that this operator clone is different than most others.
  // See dataflow_generate.g references to DesignTimeHashJoin() to see why.
  // To summarize, some properties are not specified through arguments,
  // but through the uniqueness of operator type (3 operators map to
  // DesignTimeHashJoin).
  if (mIsMultiHashJoin)
  {
    result->SetIsMultiHashJoin();
  }
  else
  {
    result->SetProbeSpecificationType(mProbes.front().GetJoinType());
  }

  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  // In the multiHashJoin case, processing the arguments 
  // creates all the mProbes. For the other cases, we still
  // have a single probe.

  int nInputs;
 
  // We need to determine the number of input ports required
  // for this clone. 
  if (mIsMultiHashJoin)
  {
    // Determine how many probe inputs are expected.
    // This is at least the number of probes specified,
    // but we may increase this based on the number
    // of inputs that were connected into the composite
    // (where the composite instance was actually used).
    // This is provided by "extraInputs".  If "extraInputs"
    // is larger than the number of probe specifications,
    // this indicates a problem (missing probe specifications).
    int nProbeInputs = result->GetNumberOfProbeSpecifications();
    if (extraInputs > nProbeInputs)
    {
      nProbeInputs = extraInputs;
    }

    // The number of inputs is the number of probes + 1 (for table input).
    nInputs = nProbeInputs + 1;
  }
  else
  {
    nInputs = mInputPorts.size() + extraInputs;
  }

  result->CreatePorts(nInputs);

  for(int i=0; i<nInputs-1; i++)
  {
    result->AddProbeSpecification(i);
  }

  return result;
}

void DesignTimeHashJoin::SetTableEquiJoinKeys(const std::vector<std::wstring>& tableEquiJoinKeys)
{
  mTableEquiJoinKeys = tableEquiJoinKeys;
}

void DesignTimeHashJoin::AddTableEquiJoinKey(const std::wstring& tableEquiJoinKey)
{
  mTableEquiJoinKeys.push_back(tableEquiJoinKey);
}

const std::vector<std::wstring>& DesignTimeHashJoin::GetTableEquiJoinKeys() const
{
  return mTableEquiJoinKeys;
}

void DesignTimeHashJoin::SetTableSize(boost::int32_t tableSize)
{
  mTableSize = tableSize;
}

boost::int32_t DesignTimeHashJoin::GetTableSize() const
{
  return mTableSize;
}

void DesignTimeHashJoin::SetProbeSpecificationType(
        DesignTimeHashJoinProbeSpecification::JoinType joinType)
{
  if (mProbes.size() == 0)
    mProbes.push_back(DesignTimeHashJoinProbeSpecification());

  mProbes.back().SetJoinType(joinType);
}

void DesignTimeHashJoin::SetIsMultiHashJoin()
{
  mIsMultiHashJoin = true;
}

int DesignTimeHashJoin::GetNumberOfProbeSpecifications() const
{
  return mProbes.size();
}

void DesignTimeHashJoin::AddProbeSpecification(DesignTimeHashJoinProbeSpecification& probeSpec)
{
  std::size_t idx = mInputPorts.size()-1;
  wchar_t buf [64];
  wsprintf(buf, L"probe(%d)", idx);
  mInputPorts.push_back(this, buf, false);
  probeSpec.SetInputPort(mInputPorts.back());
  wsprintf(buf, L"output(%d)", idx);
  mOutputPorts.push_back(this, buf, false);
  probeSpec.SetOutputPort(mOutputPorts.back());
  if (probeSpec.GetJoinType() == DesignTimeHashJoinProbeSpecification::RIGHT_OUTER_SPLIT)
  {
    wsprintf(buf, L"right(%d)", idx);
    mOutputPorts.push_back(this, buf, false);
    probeSpec.SetOutputNonMatchPort(mOutputPorts.back());
  }
  mProbes.push_back(probeSpec);
}

void DesignTimeHashJoin::CreatePorts(int numberOfInputs)
{
  // If this is a multi-hash, then we've already created our
  // mProbes as part of processing the arguments.
  // Otherwise, we have to create our mProbes.
  
  if (!mIsMultiHashJoin)
  {
    // We created one mProbe by default.  Check if we need more.
    // If so, base them on the one we've already created.
    for (int i=0; i<numberOfInputs-2; i++)
    {
      mProbes.push_back(mProbes.front());
    }
  }

  for (int i=0; i<numberOfInputs-1; i++)
  {
    wchar_t buf [64];

    wsprintf(buf, L"probe(%d)", i);
    mInputPorts.push_back(this, buf, false);

    wsprintf(buf, L"output(%d)", i);
    mOutputPorts.push_back(this, buf, false);

    if (((unsigned int) i < mProbes.size()) && mProbes[i].GetJoinType() == 
                      DesignTimeHashJoinProbeSpecification::RIGHT_OUTER_SPLIT)
    {
      wsprintf(buf, L"right(%d)", i);
      mOutputPorts.push_back(this, buf, false);
    }
  }
}

void DesignTimeHashJoin::AddProbeSpecification(int probeNumber)
{
  wchar_t portName [64];

  if ((unsigned int) probeNumber >= mProbes.size())
  {
    throw DataflowInvalidArgumentsException(
                  0, 0, L"", GetName(), 
                  L"Argument 'probe' must be specified for each probe input");
    return;
  }

  wsprintf(portName, L"probe(%d)", probeNumber);
  mProbes[probeNumber].SetInputPort(mInputPorts.getPort(portName));

  wsprintf(portName, L"output(%d)", probeNumber);
  mProbes[probeNumber].SetOutputPort(mOutputPorts.getPort(portName));

  if (mProbes[probeNumber].GetJoinType() == 
              DesignTimeHashJoinProbeSpecification::RIGHT_OUTER_SPLIT)
  {
    wsprintf(portName, L"right(%d)", probeNumber);
    mProbes[probeNumber].SetOutputNonMatchPort(mOutputPorts.getPort(portName));
  }
}

void DesignTimeHashJoin::type_check()
{
  for(std::vector<std::wstring>::const_iterator it = mTableEquiJoinKeys.begin();
      it != mTableEquiJoinKeys.end();
      ++it)
  {
    if (!mInputPorts[L"table"]->GetMetadata()->HasColumn(*it))
    {
      throw MissingFieldException(*this, *mInputPorts[L"table"], *it);
    }
  }
  for(std::vector<DesignTimeHashJoinProbeSpecification>::iterator it = mProbes.begin();
      it != mProbes.end();
      it++)
  {
    it->type_check(*this, *mInputPorts[L"table"], mTableEquiJoinKeys);
  }
}

RunTimeOperator * DesignTimeHashJoin::code_generate(partition_t maxPartition)
{
  // Convert the runtime probe specs
  std::vector<RunTimeHashJoinProbeSpecification> probes;
  for(std::vector<DesignTimeHashJoinProbeSpecification>::const_iterator it = mProbes.begin();
      it != mProbes.end();
      it++)
  {
    probes.push_back(RunTimeHashJoinProbeSpecification(it->GetEquiJoinKeys(),
                                                       it->GetResidual(),
                                                       *it->GetInputPort()->GetMetadata(),
                                                       it->GetMerger(),
                                                       it->GetJoinType()));
  }

  return new RunTimeHashJoin(mName,
                             *mInputPorts[L"table"]->GetMetadata(),
                             mTableEquiJoinKeys,
                             probes,
                             mTableSize);
}

RunTimeHashJoinProbeSpecification::RunTimeHashJoinProbeSpecification()
  :
  mJoinType(DesignTimeHashJoinProbeSpecification::INNER_JOIN)
{
}

RunTimeHashJoinProbeSpecification::RunTimeHashJoinProbeSpecification(const RunTimeHashJoinProbeSpecification& rhs)
  :
  mEquiJoinKeys(rhs.mEquiJoinKeys),
  mResidual(rhs.mResidual),
  mProbeMetadata(rhs.mProbeMetadata),
  mMerger(rhs.mMerger),
  mJoinType(rhs.mJoinType)
{
}

RunTimeHashJoinProbeSpecification::RunTimeHashJoinProbeSpecification(
  const std::vector<std::wstring>& equiJoinKeys,
  const std::wstring& residual,
  const RecordMetadata& probeMetadata,
  const RecordMerge& merger,
  DesignTimeHashJoinProbeSpecification::JoinType joinType)
  :
  mEquiJoinKeys(equiJoinKeys),
  mResidual(residual),
  mProbeMetadata(probeMetadata),
  mMerger(merger),
  mJoinType(joinType)
{
}

RunTimeHashJoinProbeSpecification::~RunTimeHashJoinProbeSpecification()
{
}

const RunTimeHashJoinProbeSpecification& RunTimeHashJoinProbeSpecification::operator=(
  const RunTimeHashJoinProbeSpecification& rhs)
{
  mEquiJoinKeys = rhs.mEquiJoinKeys;
  mResidual = rhs.mResidual;
  mProbeMetadata = rhs.mProbeMetadata;
  mMerger = rhs.mMerger;
  mJoinType = rhs.mJoinType;
  return *this;
}

RunTimeHashJoinProbeSpecificationActivation::RunTimeHashJoinProbeSpecificationActivation()
  :
  mProbeSpecification(NULL),
  mPredicateIterator(NULL),
  mOutput(0),
  mOutputNonMatch(0)
{
}

RunTimeHashJoinProbeSpecificationActivation::RunTimeHashJoinProbeSpecificationActivation(const RunTimeHashJoinProbeSpecificationActivation& rhs)
  :
  mProbeSpecification(rhs.mProbeSpecification),
  mPredicateIterator(NULL),
  mOutput(0),
  mOutputNonMatch(0)
{
  ASSERT(rhs.mPredicateIterator == NULL && rhs.mOutput == 0 && rhs.mOutputNonMatch == 0);
}

RunTimeHashJoinProbeSpecificationActivation::RunTimeHashJoinProbeSpecificationActivation(const RunTimeHashJoinProbeSpecification* probeSpecification)
  :
  mProbeSpecification(probeSpecification),
  mPredicateIterator(NULL),
  mOutput(0),
  mOutputNonMatch(0)
{
}

RunTimeHashJoinProbeSpecificationActivation::~RunTimeHashJoinProbeSpecificationActivation()
{
  delete mPredicateIterator;
}

const RunTimeHashJoinProbeSpecificationActivation& RunTimeHashJoinProbeSpecificationActivation::operator=(const RunTimeHashJoinProbeSpecificationActivation& rhs)
{
  ASSERT(mPredicateIterator == NULL && mOutput == 0 && mOutputNonMatch == 0);
  ASSERT(rhs.mPredicateIterator == NULL && rhs.mOutput == 0 && rhs.mOutputNonMatch == 0);
  mProbeSpecification = rhs.mProbeSpecification;
  return *this;
}

void RunTimeHashJoinProbeSpecificationActivation::Start(CacheConsciousHashTable& table,
                                                        const RecordMetadata& tableMetadata)
{
  // set up equijoin keys
  std::vector<DataAccessor*> probeEquijoinKeys;
  
  for(std::vector<std::wstring>::const_iterator it = mProbeSpecification->mEquiJoinKeys.begin();
      it != mProbeSpecification->mEquiJoinKeys.end();
      it++)
  {
    ASSERT(mProbeSpecification->mProbeMetadata.HasColumn(*it));
    probeEquijoinKeys.push_back(mProbeSpecification->mProbeMetadata.GetColumn(*it));
  }

  if (mProbeSpecification->mResidual.size() > 0)
  {
    mPredicateIterator = new CacheConsciousHashTablePredicateIterator(table, 
                                                                      probeEquijoinKeys, 
                                                                      mProbeSpecification->mProbeMetadata, 
                                                                      tableMetadata, 
                                                                      mProbeSpecification->mResidual);
  }
  else
  {
    mPredicateIterator = new CacheConsciousHashTableIterator(table, 
                                                             probeEquijoinKeys); 
  }
}


RunTimeHashJoin::RunTimeHashJoin(const std::wstring& name, 
                                 const RecordMetadata& tableMetadata,
                                 const std::vector<std::wstring>& tableEquiJoinKeys,
                                 const std::vector<RunTimeHashJoinProbeSpecification>& probes,
                                 boost::int32_t tableSize)
  :
  RunTimeOperator(name),
  mTableEquiJoinKeys(tableEquiJoinKeys),
  mTableMetadata(tableMetadata),
  mProbes(probes),
  mTableSize(tableSize)
{
}

RunTimeHashJoin::~RunTimeHashJoin()
{
}

RunTimeOperatorActivation * RunTimeHashJoin::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeHashJoinActivation(reactor, partition, this);
}

RunTimeHashJoinActivation::RunTimeHashJoinActivation(Reactor * reactor, 
                                                     partition_t partition, 
                                                     const RunTimeHashJoin * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeHashJoin>(reactor, partition, runTimeOperator),
  mState(START),
  mActiveProbe(NULL),
  mMoreMatches(false),
  mBuffer(NULL),
  mOutputBuffer(NULL),
  mNullTableBuffer(NULL),
  mTable(NULL),
  mInsertIterator(NULL),
  mProbeActivations(NULL)
{
}

RunTimeHashJoinActivation::~RunTimeHashJoinActivation()
{
  delete mTable;
  delete mInsertIterator;
  if (mNullTableBuffer != NULL) 
    mOperator->mTableMetadata.Free(mNullTableBuffer);
  delete [] mProbeActivations;
}

void RunTimeHashJoinActivation::Start()
{
  // set up equijoin keys
  std::vector<DataAccessor*> tableEquijoinKeys;

  for(std::vector<std::wstring>::const_iterator it = mOperator->mTableEquiJoinKeys.begin();
      it != mOperator->mTableEquiJoinKeys.end();
      it++)
  {
    ASSERT(mOperator->mTableMetadata.HasColumn(*it));
    tableEquijoinKeys.push_back(mOperator->mTableMetadata.GetColumn(*it));
  }

  // Now create the hash table
  mTable = new CacheConsciousHashTable(tableEquijoinKeys, mOperator->mTableMetadata, true, mOperator->mTableSize);
  mInsertIterator = new CacheConsciousHashTableNonUniqueInsertIterator(*mTable);

  // For the case of non-split right outer joins, we need a NULL table record
  mNullTableBuffer = mOperator->mTableMetadata.Allocate();

  // For each probe, initialize
  mProbeActivations = new RunTimeHashJoinProbeSpecificationActivation[mOperator->mProbes.size()];
  for(std::size_t i = 0; i< mOperator->mProbes.size(); i++)
  {
    mProbeActivations[i] = RunTimeHashJoinProbeSpecificationActivation(&mOperator->mProbes[i]);
    mProbeActivations[i].Start(*mTable, mOperator->mTableMetadata);
  }

  // Fill in the index for each input and output
  port_t output = 0;
  for(std::size_t i = 0; i< mOperator->mProbes.size(); i++)
  {
    mProbeActivations[i].SetOutput(output++);
    if (mProbeActivations[i].GetJoinType() == DesignTimeHashJoinProbeSpecification::RIGHT_OUTER_SPLIT)
    {
      mProbeActivations[i].SetOutputNonMatch(output++);
    }
  }

  // Make sure that can figure out what type of join we are processing
  // at any given input
  ASSERT(mInputs.size() == mOperator->mProbes.size()+1);
  for(std::size_t i=0; i<mOperator->mProbes.size(); i++)
  {
    mEndpointProbeIndex[mInputs[i+1]] = &mProbeActivations[i];
  }
  
  // Initialize the the multiplexer.
  mMultiplexer.Start(mInputs.begin() + 1, mInputs.end());

  // Start by reading the table.
  RequestRead(0);
}

void RunTimeHashJoinActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
  {
    // Get and load all of the probe records
    while(true)
    {
      Read(mBuffer, ep);
      if (mOperator->mTableMetadata.IsEOF(mBuffer)) 
      {
        mOperator->mTableMetadata.Free(mBuffer);
        mBuffer = NULL;
        break;
      }
      mTable->Insert(mBuffer, *mInsertIterator);
      RequestRead(0);
      mState = READ_TABLE;
      return;
      case READ_TABLE:;
    };

    ASSERT(mBuffer == NULL);

    {
      std::string utf8Name;
      ::WideStringToUTF8(GetName(), utf8Name);
      MetraFlowLoggerManager::GetLogger("RunTimeHashJoin")->logDebug(
        (boost::format("Hash Table Loaded(%1%): %2% bytes; %3% records; %4% bytes") % 
         utf8Name % mTable->GetTotalAllocatedSize() % mTable->GetNumRecords() % (mTable->GetNumRecords()*mOperator->mTableMetadata.GetRecordLength())).str());
    }

    // Now go into a loop in which we start to read all of the probe records.
    // The subtle thing is that we are now doing a nondeterministic read of all
    // probe inputs (though we strive for round robin across inputs).
    while(true)
    {
      mMultiplexer.RequestRead(mReactor, this);
      mState = READ_PROBE;
      return;
    case READ_PROBE:;
      Read(mBuffer, ep);

      // Find the associated ProbeSpecification so we can process output
      mActiveProbe = mEndpointProbeIndex.find(ep)->second;

      if (mActiveProbe->GetProbeMetadata().IsEOF(mBuffer)) 
      {
        mActiveProbe->GetProbeMetadata().Free(mBuffer);
        mBuffer = NULL;
        mMultiplexer.OnEOF(ep);
        RequestWrite(mActiveProbe->GetOutput());
        mState = WRITE_EOF;
        return;
      case WRITE_EOF:;
        // Send EOF.
        Write(mActiveProbe->GetMerger().GetRecordMetadata()->AllocateEOF(), ep, true);
        if (mActiveProbe->GetJoinType() == DesignTimeHashJoinProbeSpecification::RIGHT_OUTER_SPLIT)
        {
          RequestWrite(mActiveProbe->GetOutputNonMatch());
          mState = WRITE_RIGHT_OUTER_EOF;
          return;
        case WRITE_RIGHT_OUTER_EOF:;
          Write(mActiveProbe->GetProbeMetadata().AllocateEOF(), ep, true);
        }

        // If all inputs are EOF then we are done.
        if (mMultiplexer.IsEOF())
        {
          delete mTable;
          mTable = NULL;
          delete mInsertIterator;
          mInsertIterator = NULL;
          if (mNullTableBuffer != NULL) 
          {
            mOperator->mTableMetadata.Free(mNullTableBuffer);
            mNullTableBuffer = NULL;
          }
          return;
        }
        // Otherwise go get more stuff.
        mMultiplexer.RequestRead(mReactor, this);
        mState = READ_PROBE;
        return;
      }

      mMultiplexer.OnRead(ep);
      mActiveProbe->GetPredicateIterator()->Find(mBuffer);
      if (mActiveProbe->GetPredicateIterator()->GetNext())
      {
        if(DesignTimeHashJoinProbeSpecification::RIGHT_SEMI == mActiveProbe->GetJoinType())
        {
          RequestWrite(mActiveProbe->GetOutput());
          mState = WRITE_SEMI_OUTPUT;
          return;
        case WRITE_SEMI_OUTPUT:
          Write(mBuffer, ep);
          mBuffer = NULL;
        }
        else if (DesignTimeHashJoinProbeSpecification::RIGHT_ANTI_SEMI != mActiveProbe->GetJoinType())
        {
          do
          {
            {
              // An important optimization is in play here.  We look ahead one position
              // in the hash table iterator to figure out whether we are processing the
              // last match for a given input.  If we are on the last match then we can
              // use transfer of ownership semantics on the probe buffer and thereby
              // save deep copy of things like nested records and strings.  In many important
              // cases in which a probe matches at most 1 record in the table, this means
              // the join never performs deep copy on the probe record.
              MessagePtr currentMatch = mActiveProbe->GetPredicateIterator()->Get();
              mMoreMatches = mActiveProbe->GetPredicateIterator()->GetNext();
              mOutputBuffer = mActiveProbe->GetMerger().GetRecordMetadata()->Allocate();
              if (!mMoreMatches)
              {
                mActiveProbe->GetMerger().Merge(currentMatch, mBuffer, mOutputBuffer, false, true);
                mActiveProbe->GetProbeMetadata().ShallowFree(mBuffer);
                mBuffer = NULL;
              }
              else
              {
                mActiveProbe->GetMerger().Merge(currentMatch, mBuffer, mOutputBuffer, false, false);
              }
            }
            RequestWrite(mActiveProbe->GetOutput());
            mState = WRITE_OUTPUT;
            return;
          case WRITE_OUTPUT:;
            Write(mOutputBuffer, ep);
            mOutputBuffer = NULL;
          } while(mMoreMatches);
        }
        else if (DesignTimeHashJoinProbeSpecification::RIGHT_ANTI_SEMI == mActiveProbe->GetJoinType())
        {
          // Found a match, don't output
          mActiveProbe->GetProbeMetadata().Free(mBuffer);
          mBuffer = NULL;
        }
        ASSERT(mBuffer == NULL);
      }
      else if(DesignTimeHashJoinProbeSpecification::RIGHT_OUTER_SPLIT == mActiveProbe->GetJoinType())
      {
        RequestWrite(mActiveProbe->GetOutputNonMatch());
        mState = WRITE_RIGHT_OUTER_OUTPUT;
        return;
      case WRITE_RIGHT_OUTER_OUTPUT:;
        Write(mBuffer, ep);
        mBuffer = NULL;
      }
      else if(DesignTimeHashJoinProbeSpecification::RIGHT_OUTER == mActiveProbe->GetJoinType())
      {
        mOutputBuffer = mActiveProbe->GetMerger().GetRecordMetadata()->Allocate();
        mActiveProbe->GetMerger().Merge(mNullTableBuffer, mBuffer, mOutputBuffer, false, true);
        mActiveProbe->GetProbeMetadata().ShallowFree(mBuffer);
        mBuffer = NULL;
        RequestWrite(mActiveProbe->GetOutput());
        mState = WRITE_OUTPUT_NONMATCH;
        return;
      case WRITE_OUTPUT_NONMATCH:
        Write(mOutputBuffer, ep);
        mOutputBuffer = NULL;
      }
      else if(DesignTimeHashJoinProbeSpecification::RIGHT_ANTI_SEMI == mActiveProbe->GetJoinType())
      {
        RequestWrite(mActiveProbe->GetOutput());
        mState = WRITE_ANTI_SEMI_OUTPUT_NONMATCH;
        return;
      case WRITE_ANTI_SEMI_OUTPUT_NONMATCH:
        Write(mBuffer, ep);
        mBuffer = NULL;
      }
      else
      {
        mActiveProbe->GetProbeMetadata().Free(mBuffer);
        mBuffer = NULL;
      }
    }
  }
  }
}

DesignTimeHashPartitioner::DesignTimeHashPartitioner()
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeHashPartitioner::~DesignTimeHashPartitioner()
{
}

void DesignTimeHashPartitioner::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"key", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddHashKey(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeHashPartitioner* DesignTimeHashPartitioner::clone(
                                  const std::wstring& name,
                                  std::vector<OperatorArg *>& args, 
                                  int nInputs, int nOutputs) const
{
  DesignTimeHashPartitioner* result = new DesignTimeHashPartitioner();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeHashPartitioner::type_check()
{
  // Get the data accessors from the input metadata.
  for(std::vector<std::wstring>::iterator it = mHashKeys.begin();
      it != mHashKeys.end();
      it++)
  {
    if (!mInputPorts[0]->GetMetadata()->HasColumn(*it))
    {
      throw MissingFieldException(*this, *mInputPorts[0], *it);
    }
    mHashAccessors.push_back(mInputPorts[0]->GetMetadata()->GetColumn(*it));
  }
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mInputPorts[0]->GetMetadata()));
}

RunTimeOperator * DesignTimeHashPartitioner::code_generate(partition_t maxPartition)
{
  return new RunTimeHashPartitioner(mName, *mInputPorts[0]->GetMetadata(), mHashAccessors);
}

void DesignTimeHashPartitioner::SetHashKeys(const std::vector<std::wstring>& hashKeys)
{
  mHashKeys = hashKeys;
}

void DesignTimeHashPartitioner::AddHashKey(const std::wstring& hashKey)
{
  mHashKeys.push_back(hashKey);
}

const std::vector<std::wstring>& DesignTimeHashPartitioner::GetHashKeys() const
{
  return mHashKeys;
}

RunTimeHashPartitioner::RunTimeHashPartitioner(const std::wstring& name, 
                                               const RecordMetadata& metadata,
                                               const std::vector<DataAccessor *>& hashKeys)
  :
  RunTimeOperator(name),
  mMetadata(metadata),
  mHashKeys(hashKeys)
{
}

RunTimeHashPartitioner::~RunTimeHashPartitioner()
{
}

RunTimeOperatorActivation * RunTimeHashPartitioner::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeHashPartitionerActivation(reactor, partition, this);
}

RunTimeHashPartitionerActivation::RunTimeHashPartitionerActivation(Reactor * reactor, 
                                                                   partition_t partition, 
                                                                   RunTimeHashPartitioner * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeHashPartitioner>(reactor, partition, runTimeOperator),
  mState(START),
  mBuffer(NULL),
  mOutputPort(0)
{
}

RunTimeHashPartitionerActivation::~RunTimeHashPartitionerActivation()
{
}

void RunTimeHashPartitionerActivation::Start()
{
  RequestRead(0);
}

void RunTimeHashPartitionerActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    Read(mBuffer, ep);
    if (mOperator->mMetadata.IsEOF(mBuffer))
    { 
      mOperator->mMetadata.Free(mBuffer);
      mOutputPort = 0;
      for(;mOutputPort<mOutputs.size();mOutputPort++)
      {
        RequestWrite(mOutputPort);
        mState = WRITE_EOF;
        return;
      case WRITE_EOF:;
        Write(mOperator->mMetadata.AllocateEOF(), ep, true);
      }
    }
    else
    {
      do 
      {
        // Scope added here to quiet compiler about uninitialized variables
        // with the case below.
        boost::uint32_t fullHashValue(0);
        for(std::vector<DataAccessor*>::const_iterator it = mOperator->mHashKeys.begin();
            it != mOperator->mHashKeys.end();
            it++)
        {
          fullHashValue = (*it)->Hash(mBuffer, fullHashValue);
        }

        std::size_t sz = mOutputs.size();
        boost::uint32_t hashValue = fullHashValue % sz;
        RequestWrite(hashValue);
        mState = WRITE_OUTPUT;
        return;
      } while(false);
    case WRITE_OUTPUT:;
      Write(mBuffer, ep); 
      mBuffer = NULL;
      RequestRead(0);
      mState = START;
      return;
    }
  }
}

DesignTimeBroadcastPartitioner::DesignTimeBroadcastPartitioner()
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeBroadcastPartitioner::~DesignTimeBroadcastPartitioner()
{
}

void DesignTimeBroadcastPartitioner::handleArg(const OperatorArg& arg)
{
  handleCommonArg(arg);
}

DesignTimeBroadcastPartitioner* DesignTimeBroadcastPartitioner::clone(
                                      const std::wstring& name,
                                      std::vector<OperatorArg *>& args, 
                                      int nInputs, int nOutputs) const
{
  DesignTimeBroadcastPartitioner* result = new DesignTimeBroadcastPartitioner();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeBroadcastPartitioner::type_check()
{
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mInputPorts[0]->GetMetadata()));
}

RunTimeOperator * DesignTimeBroadcastPartitioner::code_generate(partition_t maxPartition)
{
  return new RunTimeBroadcastPartitioner(mName, *mInputPorts[0]->GetMetadata());
}

RunTimeBroadcastPartitioner::RunTimeBroadcastPartitioner(const std::wstring& name, 
                                                         const RecordMetadata& metadata)
  :
  RunTimeOperator(name),
  mMetadata(metadata)
{
}

RunTimeBroadcastPartitioner::~RunTimeBroadcastPartitioner()
{
}

RunTimeOperatorActivation * RunTimeBroadcastPartitioner::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeBroadcastPartitionerActivation(reactor, partition, this);
}

RunTimeBroadcastPartitionerActivation::RunTimeBroadcastPartitionerActivation(Reactor * reactor, 
                                                                             partition_t partition, 
                                                                             RunTimeBroadcastPartitioner * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeBroadcastPartitioner>(reactor, partition, runTimeOperator),
  mState(START),
  mBuffer(NULL),
  mOutputPort(0)
{
}

RunTimeBroadcastPartitionerActivation::~RunTimeBroadcastPartitionerActivation()
{
}

void RunTimeBroadcastPartitionerActivation::Start()
{
  RequestRead(0);
}

void RunTimeBroadcastPartitionerActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    Read(mBuffer, ep);
    if (mOperator->mMetadata.IsEOF(mBuffer))
    { 
      mOperator->mMetadata.Free(mBuffer);
      mOutputPort = 0;
      for(;mOutputPort<mOutputs.size();mOutputPort++)
      {
        RequestWrite(mOutputPort);
        mState = WRITE_EOF;
        return;
      case WRITE_EOF:;
        Write(mOperator->mMetadata.AllocateEOF(), ep, true);
      }
    }
    else
    {
      mOutputPort = 0;
      for(;mOutputPort<mOutputs.size();mOutputPort++)
      {
        RequestWrite(mOutputPort);
        mState = WRITE_OUTPUT;
        return;
      case WRITE_OUTPUT:;
        Write(mOutputPort == mOutputs.size()-1 ? mBuffer : mOperator->mMetadata.Clone(mBuffer), ep);
      }

      mBuffer = NULL;
      RequestRead(0);
      mState = START;
      return;
    }
  }
}

DesignTimeRoundRobinPartitioner::DesignTimeRoundRobinPartitioner()
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeRoundRobinPartitioner::~DesignTimeRoundRobinPartitioner()
{
}

void DesignTimeRoundRobinPartitioner::handleArg(const OperatorArg& arg)
{
  handleCommonArg(arg);
}

DesignTimeRoundRobinPartitioner* DesignTimeRoundRobinPartitioner::clone(
                                          const std::wstring& name,
                                          std::vector<OperatorArg *>& args, 
                                          int nInputs, int nOutputs) const
{
  DesignTimeRoundRobinPartitioner* result = 
    new DesignTimeRoundRobinPartitioner();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeRoundRobinPartitioner::type_check()
{
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mInputPorts[0]->GetMetadata()));
}

RunTimeOperator * DesignTimeRoundRobinPartitioner::code_generate(partition_t maxPartition)
{
  return new RunTimeRoundRobinPartitioner(mName, *mInputPorts[0]->GetMetadata());
}

RunTimeRoundRobinPartitioner::RunTimeRoundRobinPartitioner(const std::wstring& name, 
                                                           const RecordMetadata& metadata)
  :
  RunTimeOperator(name),
  mMetadata(metadata)
{
}

RunTimeRoundRobinPartitioner::~RunTimeRoundRobinPartitioner()
{
}

RunTimeOperatorActivation * RunTimeRoundRobinPartitioner::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeRoundRobinPartitionerActivation(reactor, partition, this);
}

RunTimeRoundRobinPartitionerActivation::RunTimeRoundRobinPartitionerActivation(Reactor * reactor, 
                                                                               partition_t partition, 
                                                                               RunTimeRoundRobinPartitioner * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeRoundRobinPartitioner>(reactor, partition, runTimeOperator),
  mState(START),
  mBuffer(NULL),
  mOutputPort(0)
{
}

RunTimeRoundRobinPartitionerActivation::~RunTimeRoundRobinPartitionerActivation()
{
}

void RunTimeRoundRobinPartitionerActivation::Start()
{
  mOutputPort = 0;
  RequestRead(0);
}

void RunTimeRoundRobinPartitionerActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    Read(mBuffer, ep);
    if (mOperator->mMetadata.IsEOF(mBuffer))
    { 
      mOperator->mMetadata.Free(mBuffer);      
      for(mOutputPort = 0; mOutputPort<mOutputs.size();mOutputPort++)
      {
        RequestWrite(mOutputPort);
        mState = WRITE_EOF;
        return;
      case WRITE_EOF:;
        Write(mOperator->mMetadata.AllocateEOF(), ep, true);
      }
    }
    else
    {
      RequestWrite(mOutputPort);
      mState = WRITE_OUTPUT;
      return;
    case WRITE_OUTPUT:;
      Write(mBuffer, ep);

      mBuffer = NULL;
      mOutputPort = mOutputPort==mOutputs.size()-1 ? 0 : mOutputPort+1;
      RequestRead(0);
      mState = START;
      return;
    }
  }
}


DesignTimeNondeterministicCollector::DesignTimeNondeterministicCollector()
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", false);  
}

DesignTimeNondeterministicCollector::~DesignTimeNondeterministicCollector()
{
}

void DesignTimeNondeterministicCollector::handleArg(const OperatorArg& arg)
{
  handleCommonArg(arg);
}

DesignTimeNondeterministicCollector* DesignTimeNondeterministicCollector::clone(
                                          const std::wstring& name,
                                          std::vector<OperatorArg *>& args, 
                                          int nInputs, int nOutputs) const
{
  DesignTimeNondeterministicCollector* result = 
    new DesignTimeNondeterministicCollector();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeNondeterministicCollector::type_check()
{
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mInputPorts[0]->GetMetadata()));
}

RunTimeOperator * DesignTimeNondeterministicCollector::code_generate(partition_t maxPartition)
{
  return new RunTimeNondeterministicCollector(mName, *mInputPorts[0]->GetMetadata());
}


RunTimeNondeterministicCollector::RunTimeNondeterministicCollector(const std::wstring& name, 
                                                                   const RecordMetadata& metadata)
  :
  RunTimeOperator(name),
  mMetadata(metadata)
{
}

RunTimeNondeterministicCollector::~RunTimeNondeterministicCollector()
{
}

RunTimeOperatorActivation * RunTimeNondeterministicCollector::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeNondeterministicCollectorActivation(reactor, partition, this);
}

RunTimeNondeterministicCollectorActivation::RunTimeNondeterministicCollectorActivation(Reactor * reactor, 
                                                                                       partition_t partition, 
                                                                                       const RunTimeNondeterministicCollector * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeNondeterministicCollector>(reactor, partition, runTimeOperator),
  mState(START)
{
}

RunTimeNondeterministicCollectorActivation::~RunTimeNondeterministicCollectorActivation()
{
}

void RunTimeNondeterministicCollectorActivation::Start()
{
  mState = START;
  for(std::vector<Endpoint *>::iterator it = mInputs.begin();
      it != mInputs.end()-1;
      it++)
  {
    (*(it + 1))->LinkRequest(*it);
  }
  mNextRead = mInputs.front();
  mReactor->RequestRead(this, mNextRead);
}

void RunTimeNondeterministicCollectorActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    Read(mBuffer, ep);
    // For fairness, the highest priority read will be the next one.
    // (or will it be the previous one?)
    mNextRead = ep->NextRequest();
    if (false == mOperator->mMetadata.IsEOF(mBuffer))
    {
      RequestWrite(0);
      mState = WRITE_OUTPUT;
      return;
    case WRITE_OUTPUT:;
      Write(mBuffer, ep);
      mReactor->RequestRead(this, mNextRead);
      mState = START;
      return;
    }
    else
    {
      if (ep->UnlinkRequest() == NULL)
      {
        RequestWrite(0);
        mState = WRITE_EOF;
        return;
      case WRITE_EOF:;
        Write(mBuffer, ep, true);
        return;
      }
      else
      {
        mOperator->mMetadata.Free(mBuffer);
        mReactor->RequestRead(this, mNextRead);
        mState = START;
        return;
      }
    }
  }
}

DesignTimeUnionAll::DesignTimeUnionAll()
{
  mInputPorts.insert(this, 0, L"0", false);
  mInputPorts.insert(this, 1, L"1", false);
  mInputPorts.insert(this, 2, L"2", true);
  mInputPorts.insert(this, 3, L"3", true);
  mOutputPorts.insert(this, 0, L"output", false);  
}

DesignTimeUnionAll::DesignTimeUnionAll(boost::int32_t numInputs)
{
  for(boost::int32_t i=0; i<numInputs; i++)
  {
    mInputPorts.push_back(this, (boost::wformat(L"input(%1%)") % i).str(), false);
  }
  mOutputPorts.push_back(this, L"output", false);  
}

DesignTimeUnionAll::~DesignTimeUnionAll()
{
}

void DesignTimeUnionAll::handleArg(const OperatorArg& arg)
{
  handleCommonArg(arg);
}

DesignTimeUnionAll* DesignTimeUnionAll::clone(
                                  const std::wstring& name,
                                  std::vector<OperatorArg *>& args, 
                                  int nExtraInputs, int nExtraOutputs) const
{
  DesignTimeUnionAll* result = 
        new DesignTimeUnionAll(mInputPorts.size() + nExtraInputs);

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeUnionAll::type_check()
{
  const RecordMetadata * inputMetadata = mInputPorts[0]->GetMetadata();
  // Validate that all inputs have the same schema.
  for(PortCollection::iterator it = mInputPorts.begin() + 1;
      it != mInputPorts.end();
      it++)
  {
    CheckMetadataSameType(0, it - mInputPorts.begin());
  }

  mOutputPorts[0]->SetMetadata(new RecordMetadata(*inputMetadata));
}

RunTimeOperator * DesignTimeUnionAll::code_generate(partition_t maxPartition)
{
  return new RunTimeUnionAll(mName, *mInputPorts[0]->GetMetadata());
}

RunTimeUnionAll::RunTimeUnionAll(const std::wstring& name, 
                                 const RecordMetadata& metadata)
  :
  RunTimeOperator(name),
  mMetadata(metadata)
{
}

RunTimeUnionAll::~RunTimeUnionAll()
{
}

RunTimeOperatorActivation * RunTimeUnionAll::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeUnionAllActivation(reactor, partition, this);
}

RunTimeUnionAllActivation::RunTimeUnionAllActivation(Reactor * reactor, 
                                                     partition_t partition, 
                                                     const RunTimeUnionAll * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeUnionAll>(reactor, partition, runTimeOperator),
  mState(START)
{
}

RunTimeUnionAllActivation::~RunTimeUnionAllActivation()
{
}

void RunTimeUnionAllActivation::Start()
{
  mState = START;
  for(std::vector<Endpoint *>::iterator it = mInputs.begin();
      it != mInputs.end()-1;
      it++)
  {
    (*(it + 1))->LinkRequest(*it);
  }
  mNextRead = mInputs.front();
  mReactor->RequestRead(this, mNextRead);
}

void RunTimeUnionAllActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    Read(mBuffer, ep);
    // For fairness, the highest priority read will be the next one.
    // (or will it be the previous one)
    mNextRead = ep->NextRequest();
    if (false == mOperator->mMetadata.IsEOF(mBuffer))
    {
      RequestWrite(0);
      mState = WRITE_OUTPUT;
      return;
    case WRITE_OUTPUT:;
      Write(mBuffer, ep);
      mReactor->RequestRead(this, mNextRead);
      mState = START;
      return;
    }
    else
    {
      if (ep->UnlinkRequest() == NULL)
      {
        RequestWrite(0);
        mState = WRITE_EOF;
        return;
      case WRITE_EOF:;
        Write(mBuffer, ep, true);
        return;
      }
      else
      {
        mOperator->mMetadata.Free(mBuffer);
        mReactor->RequestRead(this, mNextRead);
        mState = START;
        return;
      }
    }
  }
}

DesignTimeRename::DesignTimeRename()
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.push_back(this, L"output", false);
}

DesignTimeRename::~DesignTimeRename()
{
}

void DesignTimeRename::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"from", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mFromArgs.push_back(arg.getNormalizedString());
  }
  else if (arg.is(L"to", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mToArgs.push_back(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

void DesignTimeRename::handleToFromArgs()
{
  if (mFromArgs.size() != mToArgs.size())
  {
    throw DataflowInvalidArgumentsException(0,0,L"",GetName(),
            L"The number of to and from arguments must be equal.");
  }

  for (std::size_t i=0; i<mFromArgs.size(); i++)
  {
    AddRename(mFromArgs[i], mToArgs[i]);
  }
}

DesignTimeRename* DesignTimeRename::clone(
                                      const std::wstring& name,
                                      std::vector<OperatorArg *>& args, 
                                      int nInputs, int nOutputs) const
{
  DesignTimeRename* result = new DesignTimeRename();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  result->handleToFromArgs();

  return result;
}

void DesignTimeRename::AddRename(const std::wstring& from, 
                                 const std::wstring& to)
{
  mRenaming[from] = to;
}

void DesignTimeRename::type_check()
{  
  LogicalRecord output;
  mInputPorts[0]->GetLogicalMetadata().Rename(mRenaming, output, mPrimitiveTypeRemapping);
  mOutputPorts[0]->SetMetadata(new RecordMetadata(output));
}

RunTimeOperator * DesignTimeRename::code_generate(partition_t maxPartition)
{
  return new RunTimeProjection(mName, 
                               *mInputPorts[0]->GetMetadata(),
                               *mOutputPorts[0]->GetMetadata(),
                               RecordProjection(*mInputPorts[0]->GetMetadata(),
                                                *mOutputPorts[0]->GetMetadata(),
                                                mPrimitiveTypeRemapping));
//  return new RunTimeCopy(mName, *mInputPorts[0]->GetMetadata());
}

DesignTimeCopy::DesignTimeCopy()
{
}

DesignTimeCopy::DesignTimeCopy(boost::int32_t numCopies)
{
  mInputPorts.insert(this, 0, L"input", false);
  for(boost::int32_t i=0; i<numCopies; i++)
  {
    wchar_t buf[64];
    wsprintf(buf, L"output(%d)", i);
    mOutputPorts.push_back(this, buf, false);  
  }
}

DesignTimeCopy::~DesignTimeCopy()
{
}

void DesignTimeCopy::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"columnList", OPERATOR_ARG_TYPE_SUBLIST, GetName()))
  {
    std::vector<std::wstring> columnList;
    const std::vector<OperatorArg> &argList = arg.getSubList();
    for (unsigned i=0; i<argList.size(); i++)
    {
      if (argList[i].is(L"column", OPERATOR_ARG_TYPE_STRING, GetName()))
      {
        columnList.push_back(argList[i].getNormalizedString());
      }
      else
      {
        throw DataflowInvalidArgumentException(argList[i].getNameLine(),
                                               argList[i].getNameColumn(),
                                               argList[i].getFilename(),
                                               GetName(),
                                               argList[i].getName());
      }
    }

    AddProjection(columnList);
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeCopy* DesignTimeCopy::clone(
                                  const std::wstring& name,
                                  std::vector<OperatorArg *>& args, 
                                  int nExtraInputs, int nExtraOutputs) const
{
  DesignTimeCopy* result = new DesignTimeCopy(mOutputPorts.size() +
                                              nExtraOutputs);
  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeCopy::type_check()
{
  if (mProjections.size() > mOutputPorts.size())
  {
    throw SingleOperatorException(
      *this, 
      (boost::wformat(L"Number of projections is %1% while number of output ports is %2%") % 
       mProjections.size() % 
       mOutputPorts.size()).str());
  }

  const LogicalRecord & inputMetadata(mInputPorts[0]->GetLogicalMetadata());

  // For backward compatibility, allow unspecified projections on the tail of the output list
  // and default these to identity projections.
  // Validate that all projections are a subset of the input (must we allow this?)
  // TODO: Share the following code with the projection operator.
  for(std::vector<std::vector<std::wstring> >::const_iterator outerIt = mProjections.begin();
      outerIt != mProjections.end();
      ++outerIt)
  {
    std::vector<std::wstring> missingColumns;
    LogicalRecord outputMembers;
    inputMetadata.Project(*outerIt, false, outputMembers, missingColumns);
    mOutputPorts[outerIt - mProjections.begin()]->SetMetadata(new RecordMetadata(outputMembers));
    if (missingColumns.size() > 0)
    {
      throw MissingFieldException(*this, *mInputPorts[0], missingColumns[0]);
    }
  }

  for(PortCollection::iterator it = mOutputPorts.begin()+mProjections.size();
      it != mOutputPorts.end();
      it++)
  {
    (*it)->SetMetadata(new RecordMetadata(*mInputPorts[0]->GetMetadata()));
  }
}

RunTimeOperator * DesignTimeCopy::code_generate(partition_t maxPartition)
{
  if (0 == mProjections.size())
  {
    return new RunTimeCopy(mName, *mInputPorts[0]->GetMetadata());
  }
  else
  {
    std::vector<RecordMetadata> outputMetadata;
    for(PortCollection::iterator it = mOutputPorts.begin();
        it != mOutputPorts.end();
        it++)
    {
      outputMetadata.push_back(*(*it)->GetMetadata());
    }
    
    return new RunTimeCopy2(mName, *mInputPorts[0]->GetMetadata(), outputMetadata);
  }
}

void DesignTimeCopy::AddProjection(const std::vector<std::wstring>& projection)
{
  mProjections.push_back(projection);
}

RunTimeCopy::RunTimeCopy(const std::wstring& name, 
                        const RecordMetadata& metadata)
  :
  RunTimeOperator(name),
  mMetadata(metadata)
{
}

RunTimeCopy::~RunTimeCopy()
{
}

RunTimeOperatorActivation * RunTimeCopy::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeCopyActivation(reactor, partition, this);
}

RunTimeCopyActivation::RunTimeCopyActivation(Reactor * reactor, 
                                             partition_t partition, 
                                             const RunTimeCopy * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeCopy>(reactor, partition, runTimeOperator),
  mState(START),
  mBuffer(NULL),
  mNextOutput(0)
{
}

RunTimeCopyActivation::~RunTimeCopyActivation()
{
}

void RunTimeCopyActivation::Start()
{
  RequestRead(0);
  mState = START;
}

void RunTimeCopyActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    Read(mBuffer, ep);
    for(mNextOutput = 0; mNextOutput < mOutputs.size(); mNextOutput++)
    {
      RequestWrite(mNextOutput);
      mState = WRITE_OUTPUT;
      return;
      case WRITE_OUTPUT:;
      Write(mNextOutput == mOutputs.size()-1 ? mBuffer : mOperator->mMetadata.Clone(mBuffer), 
            ep,
            mOperator->mMetadata.IsEOF(mBuffer));
    }
    if (!mOperator->mMetadata.IsEOF(mBuffer))
    {
      RequestRead(0);
      mState = START;
      return;
    }
  }
}

RunTimeCopy2::RunTimeCopy2(const std::wstring& name, 
                           const RecordMetadata& inputMetadata,
                           const std::vector<RecordMetadata>& outputMetadata)
  :
  RunTimeOperator(name),
  mInputMetadata(inputMetadata),
  mOutputMetadata(outputMetadata)
{
  for(std::vector<RecordMetadata>::const_iterator it = mOutputMetadata.begin();
      it != mOutputMetadata.end();
      ++it)
  {
    mProjection.push_back(RecordProjection(mInputMetadata, *it));
  }
}

RunTimeCopy2::~RunTimeCopy2()
{
}

RunTimeOperatorActivation * RunTimeCopy2::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeCopy2Activation(reactor, partition, this);
}

RunTimeCopy2Activation::RunTimeCopy2Activation(Reactor * reactor, 
                                               partition_t partition, 
                                               const RunTimeCopy2 * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeCopy2>(reactor, partition, runTimeOperator),
  mState(START),
  mBuffer(NULL),
  mNextOutput(0)
{
}

RunTimeCopy2Activation::~RunTimeCopy2Activation()
{
}

void RunTimeCopy2Activation::Start()
{
  RequestRead(0);
  mState = START;
}

void RunTimeCopy2Activation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    Read(mBuffer, ep);
    if (!mOperator->mInputMetadata.IsEOF(mBuffer))
    {
      for(mNextOutput = 0; mNextOutput < mOutputs.size(); mNextOutput++)
      {
        RequestWrite(mNextOutput);
        mState = WRITE_OUTPUT;
        return;
      case WRITE_OUTPUT:;
      {
        if (mNextOutput+1 == mOutputs.size() && mOperator->mProjection[mNextOutput].IsIdentity())
        {
          // If out last output is an identity, then we can optimize
          // by passing the buffer through unmodified.
          // TODO: If ANY of the outputs is an identity we should be able
          // to apply this optimization simply by processing the identity output last.
          Write(mBuffer, ep, mOperator->mInputMetadata.IsEOF(mBuffer));
        }
        else
        {
          // TODO: Careful analysis to allow us to apply transfer semantics if a given
          // outputs fields are disjoint from the fields of any other output.
          MessagePtr tmp = mOperator->mOutputMetadata[mNextOutput].Allocate();
          mOperator->mProjection[mNextOutput].Project(mBuffer, tmp, false);
          Write(tmp,
                ep,
                mOperator->mInputMetadata.IsEOF(mBuffer));

          if (mNextOutput + 1 == mOutputs.size())
          {
            mOperator->mInputMetadata.Free(mBuffer);
          }
        }
      }
      }
      RequestRead(0);
      mState = START;
      return;
    }
    else
    {
      mOperator->mInputMetadata.Free(mBuffer);
      for(mNextOutput = 0; mNextOutput < mOutputs.size(); mNextOutput++)
      {
        RequestWrite(mNextOutput);
        mState = WRITE_EOF;
        return;
      case WRITE_EOF:;
        Write(mOperator->mOutputMetadata[mNextOutput].AllocateEOF(), ep, true);      
      }
    }
  }
}

DesignTimeRangePartitioner::DesignTimeRangePartitioner()
{
  mInputPorts.insert(this, 0, L"input", false);
  mInputPorts.insert(this, 1, L"range", true);
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeRangePartitioner::~DesignTimeRangePartitioner()
{
}

void DesignTimeRangePartitioner::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"value", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddRangeValue(arg.getIntValue());
  }
  else if (arg.is(L"key", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddRangeKey(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeRangePartitioner* DesignTimeRangePartitioner::clone(
                                  const std::wstring& name,
                                  std::vector<OperatorArg *>& args, 
                                  int nInputs, int nOutputs) const
{
  DesignTimeRangePartitioner* result = new DesignTimeRangePartitioner();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeRangePartitioner::type_check()
{
  // Get the data accessors from the input metadata.
  for(std::vector<std::wstring>::iterator it = mRangeKeys.begin();
      it != mRangeKeys.end();
      it++)
  {
    if (!mInputPorts[0]->GetMetadata()->HasColumn(*it))
    {
      throw MissingFieldException(*this, *mInputPorts[0], *it);
    }
    mRangeAccessors.push_back(*mInputPorts[0]->GetMetadata()->GetColumn(*it));
  }

  // TEMPORARY: Only handle a single integer key
  if (mRangeKeys.size() != 1 || 
      (mInputPorts[0]->GetMetadata()->GetColumn(mRangeKeys[0])->GetColumnType() != MTPipelineLib::PROP_TYPE_INTEGER &&
       mInputPorts[0]->GetMetadata()->GetColumn(mRangeKeys[0])->GetColumnType() != MTPipelineLib::PROP_TYPE_BIGINTEGER))
  {
    throw std::logic_error("Range Partitioner only handling a single integer key");
  }

  // Check if we have an input that will feed range map or whether it is configured
  // through properties
  if (mRangeMap.size() == 0)
  {
    if (!mInputPorts[1]->GetMetadata()->HasColumn(L"value"))
    {
      throw MissingFieldException(*this, *mInputPorts[1], L"value");
    }
    if (mInputPorts[1]->GetMetadata()->GetColumn(L"value")->GetColumnType() != mInputPorts[0]->GetMetadata()->GetColumn(mRangeKeys[0])->GetColumnType())
    {
      throw std::logic_error("Range map 'value' field must be integer");
    }
  }
  else
  {
    std::sort(mRangeMap.begin(), mRangeMap.end());
  }
  

  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mInputPorts[0]->GetMetadata()));
}

RunTimeOperator * DesignTimeRangePartitioner::code_generate(partition_t maxPartition)
{
  if (mInputPorts[0]->GetMetadata()->GetColumn(mRangeKeys[0])->GetColumnType()==MTPipelineLib::PROP_TYPE_INTEGER)
  {
    return mRangeMap.size() > 0 ?
      new RunTimeRangePartitioner<boost::int32_t>(mName, *mInputPorts[0]->GetMetadata(), mRangeAccessors, mRangeMap) :
      new RunTimeRangePartitioner<boost::int32_t>(mName, *mInputPorts[0]->GetMetadata(), mRangeAccessors, *mInputPorts[1]->GetMetadata(), *mInputPorts[1]->GetMetadata()->GetColumn(L"value"));
  }
  else
  {
    // TODO: Handle configuration using bigint.
    std::vector<boost::int64_t> tmp;
    for(std::vector<boost::int32_t>::const_iterator it=mRangeMap.begin();
        it != mRangeMap.end();
        ++it)
    {
      tmp.push_back(*it);
    }
    return mRangeMap.size() > 0 ?
      new RunTimeRangePartitioner<boost::int64_t>(mName, *mInputPorts[0]->GetMetadata(), mRangeAccessors, tmp) :
      new RunTimeRangePartitioner<boost::int64_t>(mName, *mInputPorts[0]->GetMetadata(), mRangeAccessors, *mInputPorts[1]->GetMetadata(), *mInputPorts[1]->GetMetadata()->GetColumn(L"value"));
  }
}

void DesignTimeRangePartitioner::AddRangeValue(boost::int32_t rangeValue)
{
  mRangeMap.push_back(rangeValue);
}

void DesignTimeRangePartitioner::SetRangeKeys(const std::vector<std::wstring>& rangeKeys)
{
  mRangeKeys = rangeKeys;
}

void DesignTimeRangePartitioner::AddRangeKey(const std::wstring& rangeKey)
{
  mRangeKeys.push_back(rangeKey);
}

const std::vector<std::wstring>& DesignTimeRangePartitioner::GetRangeKeys() const
{
  return mRangeKeys;
}

template<class _FieldType>
RunTimeRangePartitioner<_FieldType>::RunTimeRangePartitioner(const std::wstring& name, 
                                                 const RecordMetadata& metadata,
                                                 const std::vector<RunTimeDataAccessor>& rangeKeys,
                                                 const std::vector<_FieldType>& rangeMap)
  :
  RunTimeOperator(name),
  mMetadata(metadata),
  mRangeKeys(rangeKeys),
  mRangeMap(rangeMap)
{
}

template<class _FieldType>
RunTimeRangePartitioner<_FieldType>::RunTimeRangePartitioner(const std::wstring& name, 
                                                 const RecordMetadata& metadata,
                                                 const std::vector<RunTimeDataAccessor>& rangeKeys,
                                                 const RecordMetadata& rangeMapMetadata,
                                                 const RunTimeDataAccessor& rangeMapValueAccessor)
  :
  RunTimeOperator(name),
  mMetadata(metadata),
  mRangeKeys(rangeKeys),
  mRangeMapMetadata(rangeMapMetadata),
  mRangeMapValueAccessor(rangeMapValueAccessor)
{
}

template<class _FieldType>
RunTimeRangePartitioner<_FieldType>::~RunTimeRangePartitioner()
{
}

template<class _FieldType>
RunTimeOperatorActivation * RunTimeRangePartitioner<_FieldType>::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeRangePartitionerActivation<_FieldType>(reactor, partition, this);
}

template<class _FieldType>
RunTimeRangePartitionerActivation<_FieldType>::RunTimeRangePartitionerActivation(Reactor * reactor,
                                                                     partition_t partition,
                                                                     const RunTimeRangePartitioner<_FieldType> * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeRangePartitioner<_FieldType> >(reactor, partition, runTimeOperator),
  mState(START),
  mBuffer(NULL),
  mOutputPort(0)
{
}

template<class _FieldType>
RunTimeRangePartitionerActivation<_FieldType>::~RunTimeRangePartitionerActivation()
{
}

template<class _FieldType>
void RunTimeRangePartitionerActivation<_FieldType>::Start()
{
  mState = START;
  HandleEvent(NULL);
}

template<class _FieldType>
void RunTimeRangePartitionerActivation<_FieldType>::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    // If we are configured with a range input then initialize the range map from that input
    // otherwise it is configured from the operator instance.
    if (mInputs.size() == 2)
    {
      while(true)
      {
        RequestRead(1);
        mState = READ_RANGE_MAP;
        return;
      case READ_RANGE_MAP:
        Read(mBuffer, ep);
        if (!mOperator->mRangeMapMetadata.IsEOF(mBuffer))
        {
          mActivationRangeMap.push_back(*reinterpret_cast<const _FieldType *>(mOperator->mRangeMapValueAccessor.GetValue(mBuffer)));
          mOperator->mRangeMapMetadata.Free(mBuffer);
        }
        else
        {
          mOperator->mRangeMapMetadata.Free(mBuffer);
          std::sort(mActivationRangeMap.begin(), mActivationRangeMap.end());
          break;
        }
      }
    }
    else
    {
      mActivationRangeMap = mOperator->mRangeMap;
    }

    while(true)
    {
      RequestRead(0);
      mState = READ_0;
      return;
    case READ_0:
      Read(mBuffer, ep);
      if (mOperator->mMetadata.IsEOF(mBuffer))
      { 
        mOperator->mMetadata.Free(mBuffer);
        mOutputPort = 0;
        for(;mOutputPort<mOutputs.size();mOutputPort++)
        {
          RequestWrite(mOutputPort);
          mState = WRITE_EOF;
          return;
        case WRITE_EOF:;
          Write(mOperator->mMetadata.AllocateEOF(), ep, true);
        }
        return;
      }
      else
      {
        do 
        {
          std::size_t sz = mOutputs.size();
          _FieldType val = *reinterpret_cast<const _FieldType *>(mOperator->mRangeKeys[0].GetValue(mBuffer));
          std::vector<_FieldType>::const_iterator where = std::lower_bound(mActivationRangeMap.begin(), mActivationRangeMap.end(), val);
          boost::uint32_t rangeValue = (where - mActivationRangeMap.begin()) % sz;
          RequestWrite(rangeValue);
          mState = WRITE_OUTPUT;
          return;
        } while(false);
      case WRITE_OUTPUT:;
        Write(mBuffer, ep); 
        mBuffer = NULL;
      }
    }
  }
}

// explicit instantiation - so all the impl doesn't have to be in the header
template class RunTimeRangePartitioner<boost::int32_t>;
template class RunTimeRangePartitioner<boost::int32_t>;
template class RunTimeRangePartitionerActivation<boost::int64_t>;
template class RunTimeRangePartitionerActivation<boost::int64_t>;
