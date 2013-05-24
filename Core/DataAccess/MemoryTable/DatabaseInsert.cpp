#include "DatabaseInsert.h"
#include "OperatorArg.h"
#include "DatabaseCatalog.h"
#include "SEHException.h"
#include <OdbcConnMan.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcResultSet.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcMetadata.h>
#include <OdbcColumnMetadata.h>
#include "SharedDefs.h"

#ifdef WIN32
#include <process.h>
#endif

// Logging
#include "LogAdapter.h"
#include <Timer.h>

#include "asio/ip/host_name.hpp"

#include <boost/format.hpp>
#include <boost/bind.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/thread/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/condition.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/regex.hpp>
#include <memory>
#include <stdexcept>
#include <queue>

class FieldColumnMismatchException : public std::logic_error
{
private:
  std::string CreateErrorString(const DesignTimeOperator& op, const Port& port,
                                const RecordMember& field, const COdbcColumnMetadata& column);
public:
  METRAFLOW_DECL FieldColumnMismatchException(const DesignTimeOperator& op, const Port& port,
                                              const RecordMember& field, const COdbcColumnMetadata& column);
  METRAFLOW_DECL ~FieldColumnMismatchException();
};

std::string FieldColumnMismatchException::CreateErrorString(const DesignTimeOperator& op, const Port& port,
                                                            const RecordMember& field, const COdbcColumnMetadata& column)
{
  boost::wformat fmt(L"Type mismatch between field '%4%' on port %1%(%2%) of operator '%3%' and database column %%1%%.%%2%% %%3%%\n");
  fmt % port.GetName() % port.GetMetadata()->ToString() % op.GetName() % field.GetName();
  std::string msg;
  ::WideStringToUTF8(fmt.str(), msg);
  return (boost::format(msg) % column.GetTableName() % column.GetColumnName() % column.GetTypeName()).str();
}

FieldColumnMismatchException::FieldColumnMismatchException(const DesignTimeOperator& op, const Port& port,
                                                           const RecordMember& field, const COdbcColumnMetadata& column)
  :
  logic_error(CreateErrorString(op,port, field, column))
{
}

FieldColumnMismatchException::~FieldColumnMismatchException()
{
}

DesignTimeDatabaseInsert::DesignTimeDatabaseInsert()
  :
  mSchemaName(L"NetMeterStage"),
  mBatchSize(1000),
  mCreateTable(false),
  mIsOracle(false)
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", true);
}

DesignTimeDatabaseInsert::~DesignTimeDatabaseInsert()
{
}

void DesignTimeDatabaseInsert::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"table", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetTableName(arg.getNormalizedString());
  }
  else if (arg.is(L"schema", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetSchemaName(arg.getNormalizedString());
  }
  else if (arg.is(L"createTable", OPERATOR_ARG_TYPE_BOOLEAN, GetName()))
  {
    SetCreateTable(arg.getBoolValue());
  }
  else if (arg.is(L"batchSize", OPERATOR_ARG_TYPE_INTEGER, GetName()))
  {
    SetBatchSize(arg.getIntValue());
  }
  else if (arg.is(L"sortOrder", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetSortHint(arg.getNormalizedString());
  }
  else if (arg.is(L"transactionKey", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetStreamingTransactionKey(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeDatabaseInsert* DesignTimeDatabaseInsert::clone(
                                        const std::wstring& name,
                                        std::vector<OperatorArg *>& args, 
                                        int nInputs, int nOutputs) const
{
  DesignTimeDatabaseInsert* result = new DesignTimeDatabaseInsert();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeDatabaseInsert::SetSourceTargetMap(const std::map<std::wstring, std::wstring>& sourceTargetMap)  
{
  mSourceTargetMap.clear();
  for(std::map<std::wstring, std::wstring>::const_iterator it = sourceTargetMap.begin();
      it != sourceTargetMap.end();
      it++)
  {
    mSourceTargetMap[boost::to_upper_copy(it->first)] = boost::to_upper_copy(it->second);
  }
}

void DesignTimeDatabaseInsert::type_check()
{
  // Commenting out as it seems to work even if this is violated - TRW 1/6/09
  //ASSERT(mStreamingTransactionKey.size() == 0 || !mCreateTable);

  const LogicalRecord& metadata(mInputPorts[0]->GetLogicalMetadata());

  COdbcConnectionInfo netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter"); 
  mIsOracle = netMeter.IsOracle();

  // Run screaming for the hills...  Lot's of back and forth between UTF8 and UTF16.
  std::string utf8Schema;
  ::WideStringToUTF8(mSchemaName, utf8Schema);
  std::string utf8prefix = COdbcConnectionManager::GetConnectionInfo(utf8Schema.c_str()).GetCatalogPrefix();
  std::wstring prefix;
  ::ASCIIToWide(prefix, utf8prefix);
  std::wstring prefixedTable = prefix + mTableName;

  // Handle the case in which we are asked to create the target table
  // Do this in the NetMeter database because on Oracle we need to
  // use exec_ddl & table_exists and these only live in NetMeter.
  if (mCreateTable)
  {
    std::wstring ddl;
    if (mIsOracle)
    {
      ddl += L"begin\n";
      ddl += L"if table_exists('";
      ddl += prefixedTable;
      ddl += L"') then\n"
        L"exec_ddl ('drop table ";
      ddl += prefixedTable;
      ddl += L"');\n"
        L"end if;\n"
        L"exec_ddl ('";
    }
    else
    {
      ddl += L"if object_id( '";
      ddl += prefixedTable;
      ddl += L"' ) is not null\n"
        L"DROP TABLE ";
      ddl += prefixedTable;
    }
    ddl += L"\nCREATE TABLE ";
    ddl += prefixedTable;
    ddl += L"(";
    for(LogicalRecord::const_iterator it = metadata.begin();
        it != metadata.end();
        ++it)
    {
      std::wstring colName;
      if (mSourceTargetMap.size() == 0)
      {
        colName = it->GetName();
      }
      else
      {
        std::map<std::wstring,std::wstring>::const_iterator sit = mSourceTargetMap.find(boost::to_upper_copy(it->GetName()));
        if (sit == mSourceTargetMap.end()) continue;
        colName = sit->second;
      } 
      if (it != metadata.begin()) ddl += L", ";
      ddl += colName;
      ddl += L" ";
      ddl += mIsOracle ? it->GetType().GetOracleDatatype() : it->GetType().GetSQLServerDatatype();
    }    
    ddl += L")";

    if (mIsOracle)
    {
      ddl += L"');";
      ddl += L"end;";
    }

    // Create the table
    std::auto_ptr<COdbcConnection> conn (new COdbcConnection(netMeter));
    conn->SetAutoCommit(true);
    std::auto_ptr<COdbcStatement> stmt(conn->CreateStatement());
    stmt->ExecuteUpdateW(ddl);
  }

  std::auto_ptr<COdbcConnection> conn (new COdbcConnection(netMeter));
  std::auto_ptr<COdbcPreparedArrayStatement> stmt(conn->PrepareStatement(L"SELECT * FROM " + prefixedTable));
  const COdbcColumnMetadataVector& v(stmt->GetMetadata());

  if (mSourceTargetMap.size() == 0)
  {
    // OK, we've got the record metadata, bind to the table.
    for(LogicalRecord::const_iterator mit = metadata.begin();
        mit != metadata.end();
        ++mit)
    {
      std::wstring sourceName = mit->GetName();
      std::string utf8SourceName;
      ::WideStringToUTF8(sourceName, utf8SourceName);
      boost::to_upper(utf8SourceName);
      for(COdbcColumnMetadataVector::const_iterator it = v.begin();
          it != v.end();
          it++)
      {
        std::string utf8TargetName = (*it)->GetColumnName();
        boost::to_upper(utf8TargetName);
        if (utf8TargetName == utf8SourceName)
        {
          CheckTypeCompatibility(*this, *mInputPorts[0], **it, *mit);
          mBindings.push_back(Binding(mit->GetName(), (*it)->GetOrdinalPosition(),mit->GetType().GetPipelineType(), !(*it)->IsNullable()));
          break;
        }
      }
      // Don't worry if no matching field.  Just drop the column.
    }
  }
  else
  {
    for(LogicalRecord::const_iterator mit = metadata.begin();
        mit != metadata.end();
        ++mit)
    {
      std::map<std::wstring,std::wstring>::const_iterator sit = mSourceTargetMap.find(boost::to_upper_copy(mit->GetName()));
      if (sit == mSourceTargetMap.end()) continue;
      std::wstring sourceName = sit->second;
      std::string utf8SourceName;
      ::WideStringToUTF8(sourceName, utf8SourceName);
      boost::to_upper(utf8SourceName);
      COdbcColumnMetadataVector::const_iterator it = v.begin();
      for(;
          it != v.end();
          it++)
      {
        std::string utf8TargetName = (*it)->GetColumnName();
        boost::to_upper(utf8TargetName);
        if (utf8TargetName == utf8SourceName)
        {
          CheckTypeCompatibility(*this, *mInputPorts[0], **it, *mit);
          mBindings.push_back(Binding(mit->GetName(),(*it)->GetOrdinalPosition(),mit->GetType().GetPipelineType(), !(*it)->IsNullable()));
          break;
        }
      }
      if (it == v.end())
      {
        std::string utf8Msg;
        std::wstring msg((boost::wformat(L"No database column '%1%' found in table '%2%' for source column '%3%'")
                          % sit->second % mTableName % sit->first).str());
        ::WideStringToUTF8(msg, utf8Msg);
        throw std::logic_error(utf8Msg);
      }
    }
  }

  if (mStreamingTransactionKey.size() > 0)
  {
    // Make sure the key is integer and present.  This guy should be robust and be 
    // prepared to handle a NULLABLE key even though a NULL value for the streaming
    // key will result in a runtime error.  We have to be prepared for this for backward
    // compatibility reasons.
    if (!metadata.HasColumn(mStreamingTransactionKey, false) ||
        !metadata.GetColumn(mStreamingTransactionKey).GetType().CanReadAs(LogicalFieldType::Integer(true)))
    {
      throw MissingFieldException(*this, *mInputPorts[0], mStreamingTransactionKey);
    }

    // This guy will never produce nullable output.
    LogicalRecord outputMembers;
    outputMembers.push_back(mStreamingTransactionKey, 
                            LogicalFieldType::Integer(false));
    outputMembers.push_back(L"schema", 
                            LogicalFieldType::String(false));
    outputMembers.push_back(L"table", 
                            LogicalFieldType::String(false));

    mOutputPorts[0]->SetMetadata(new RecordMetadata(outputMembers));
  }
}

RunTimeOperator * DesignTimeDatabaseInsert::code_generate(partition_t maxPartition)
{
  return 
    mIsOracle 
    ?
    static_cast<RunTimeOperator*>(new RunTimeDatabaseInsert<COdbcPreparedArrayStatement>(
                                    mName, 
                                    mTableName, 
                                    mSchemaName, 
                                    mSortHint, 
                                    mBatchSize, 
                                    *mInputPorts[0]->GetMetadata(), 
                                    mStreamingTransactionKey.size() > 0 ? *mOutputPorts[0]->GetMetadata() : RecordMetadata(),
                                    mBindings,
                                    mStreamingTransactionKey))
    :
    static_cast<RunTimeOperator*>(new RunTimeDatabaseInsert<COdbcPreparedBcpStatement>(
                                    mName, 
                                    mTableName, 
                                    mSchemaName, 
                                    mSortHint, 
                                    mBatchSize, 
                                    *mInputPorts[0]->GetMetadata(), 
                                    mStreamingTransactionKey.size() > 0 ? *mOutputPorts[0]->GetMetadata() : RecordMetadata(),
                                    mBindings,
                                    mStreamingTransactionKey));
}

std::wstring DesignTimeDatabaseInsert::GetSQLServerDatatype(DataAccessor * accessor)
{
  switch(accessor->GetPhysicalFieldType()->GetPipelineType())
  {
  case MTPipelineLib::PROP_TYPE_INTEGER: return L"INTEGER";
	case MTPipelineLib::PROP_TYPE_DOUBLE: return L"DOUBLE PRECISION";
	case MTPipelineLib::PROP_TYPE_STRING: return L"NVARCHAR(255)";
	case MTPipelineLib::PROP_TYPE_DATETIME: return L"DATETIME";
	case MTPipelineLib::PROP_TYPE_TIME: return L"DATETIME";
	case MTPipelineLib::PROP_TYPE_BOOLEAN: return L"CHAR(1)";
	case MTPipelineLib::PROP_TYPE_ENUM: return L"INTEGER";
	case MTPipelineLib::PROP_TYPE_DECIMAL: return METRANET_DECIMAL_PRECISION_AND_SCALE_MAX_WSTR;
  case MTPipelineLib::PROP_TYPE_ASCII_STRING: return L"VARCHAR(255)";
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING: return L"NVARCHAR(255)";
  case MTPipelineLib::PROP_TYPE_BIGINTEGER: return L"BIGINT";
	case MTPipelineLib::PROP_TYPE_OPAQUE: return L"BINARY(16)";
	default: throw std::runtime_error("Unsupported data type");
  }
}

std::wstring DesignTimeDatabaseInsert::GetOracleDatatype(DataAccessor * accessor)
{
  switch(accessor->GetPhysicalFieldType()->GetPipelineType())
  {
  case MTPipelineLib::PROP_TYPE_INTEGER: return L"NUMBER(10)";
	case MTPipelineLib::PROP_TYPE_DOUBLE: return METRANET_NUMBER_PRECISION_AND_SCALE_MAX_WSTR;
	case MTPipelineLib::PROP_TYPE_STRING: return L"NVARCHAR2(255)";
	case MTPipelineLib::PROP_TYPE_DATETIME: return L"DATE";
	case MTPipelineLib::PROP_TYPE_TIME: return L"DATE";
	case MTPipelineLib::PROP_TYPE_BOOLEAN: return L"CHAR(1)";
	case MTPipelineLib::PROP_TYPE_ENUM: return L"NUMBER(10)";
	case MTPipelineLib::PROP_TYPE_DECIMAL: return METRANET_NUMBER_PRECISION_AND_SCALE_MAX_WSTR;
  case MTPipelineLib::PROP_TYPE_ASCII_STRING: return L"VARCHAR(255)";
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING: return L"NVARCHAR(255)";
  case MTPipelineLib::PROP_TYPE_BIGINTEGER: return L"NUMBER(20)";
	case MTPipelineLib::PROP_TYPE_OPAQUE: return L"RAW(16)";
	default: throw std::runtime_error("Unsupported data type");
  }
}

void DesignTimeDatabaseInsert::CheckTypeCompatibility(const DesignTimeOperator& op, const Port& port,
                                                      const COdbcColumnMetadata& db, const RecordMember& accessor)
{
  switch(accessor.GetType().GetPipelineType())
  {
  case MTPipelineLib::PROP_TYPE_INTEGER: 
  {
    if (db.GetDataType() != eInteger)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_DOUBLE: 
  {
    if (db.GetDataType() != eDouble)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_STRING: 
  {
    if (db.GetDataType() != eWideString)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_DATETIME: 
  {
    if (db.GetDataType() != eDatetime)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_TIME: 
  {
    if (db.GetDataType() != eInteger)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_BOOLEAN: 
  {
    if (db.GetDataType() != eString)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_ENUM: 
  {
    if (db.GetDataType() != eInteger)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_DECIMAL: 
  {
    if (db.GetDataType() != eDecimal)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
  case MTPipelineLib::PROP_TYPE_ASCII_STRING: 
  {
    if (db.GetDataType() != eString)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING: 
  {
    if (db.GetDataType() != eWideString)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER: 
  {
    if (db.GetDataType() != eBigInteger)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	case MTPipelineLib::PROP_TYPE_OPAQUE: 
  {
    if (db.GetDataType() != eBinary)
    {
      throw FieldColumnMismatchException(op, port, accessor, db);
    }
    break;
  }
	default: throw std::runtime_error("Unsupported data type");
  }
}

template <class _InsertStmt>
RunTimeDatabaseInsert<_InsertStmt>::RunTimeDatabaseInsert (const std::wstring& name, 
                                                           const std::wstring & tableName,
                                                           const std::wstring & schemaName,
                                                           const std::wstring & sortHint,
                                                           boost::int32_t batchSize,
                                                           const RecordMetadata& metadata,
                                                           const RecordMetadata& outputMetadata,
                                                           const std::vector<DesignTimeDatabaseInsert::Binding>& bindings,
                                                           const std::wstring& streamingTransactionKey)
  :
  RunTimeOperator(name),
  mTableName(tableName),
  mSchemaName(schemaName),
  mSortHint(sortHint),
  mBatchSize(batchSize),
  mMetadata(metadata),
  mOutputMetadata(outputMetadata),
  mStreamingTransactionKey(streamingTransactionKey)
{
  for(std::vector<DesignTimeDatabaseInsert::Binding>::const_iterator it=bindings.begin();
      it != bindings.end();
      ++it)
  {
    mBindings.push_back(RuntimeBinding(mMetadata.GetColumn(it->GetSourceName()), 
                                       it->GetTargetPosition(),
                                       it->GetColumnType(),
                                       it->IsRequired()));
  }
}

template <class _InsertStmt>
RunTimeDatabaseInsert<_InsertStmt>::~RunTimeDatabaseInsert()
{
}

template <class _InsertStmt>
RunTimeOperatorActivation * RunTimeDatabaseInsert<_InsertStmt>::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeDatabaseInsertActivation<_InsertStmt>(reactor, partition, this);
}

template <class _InsertStmt>
RunTimeDatabaseInsertActivation<_InsertStmt>::RunTimeDatabaseInsertActivation (Reactor * reactor, 
                                                                               partition_t partition, 
                                                                               const RunTimeDatabaseInsert<_InsertStmt> * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeDatabaseInsert<_InsertStmt> >(reactor, partition, runTimeOperator),
  mState(START),
  mInputMessage(NULL),
  mConnection(NULL),
  mBcpStatement(NULL),
  mCurrentBatchCount(0),
  mNumRead(0LL),
  mTransactionId(NULL),
  mCurrentTransaction(-1)
{
}

template <class _InsertStmt>
RunTimeDatabaseInsertActivation<_InsertStmt>::~RunTimeDatabaseInsertActivation()
{
  try
  {
    if(mBcpStatement)
    {
      mBcpStatement->ExecuteBatch();
      mBcpStatement->Finalize();
    }
  }
  catch(...)
  {
  }
  delete mBcpStatement;
  delete mConnection;
}

template <class _InsertStmt>
MessagePtr RunTimeDatabaseInsertActivation<_InsertStmt>::GetTableBuffer()
{
  MessagePtr msg = mOperator->mOutputMetadata.Allocate();
  mOperator->mOutputMetadata.GetColumn(0)->SetLongValue(msg, mCurrentTransaction);
  // Note that we are only outputting these records in the streaming case.  In this
  // case, the actual table is always in staging even if the model/eventual target is in
  // NetMeter.
  std::wstring catalog;
  ::ASCIIToWide(catalog, COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalog());
  mOperator->mOutputMetadata.GetColumn(1)->SetStringValue(msg, catalog.c_str());
  mOperator->mOutputMetadata.GetColumn(2)->SetStringValue(msg, mCurrentTableName.c_str());
  return msg;
}

template <class _InsertStmt>
void RunTimeDatabaseInsertActivation<_InsertStmt>::Start()
{
  if (mOperator->mStreamingTransactionKey.size() > 0)
  {
    mTransactionId = mOperator->mMetadata.GetColumn(mOperator->mStreamingTransactionKey);
  }

  mState = START;
  HandleEvent(NULL);
}

// template <class _InsertStmt>
// void RunTimeDatabaseInsertActivation<_InsertStmt>::HandleEvent(Endpoint * ep)
// {
//   switch(mState)
//   {
//   case START:
//     while(true)
//     {
//       RequestRead(0);
//       mState = READ_0;
//       return;
//     case READ_0:
//       ASSERT(ep == mInputs[0]);
//       Read(mInputMessage, ep);
//       if(!mOperator->mMetadata.IsEOF(mInputMessage))
//       {
//         // Initialize connection if needed.
//         if (!mConnection)
//         {
//           COdbcConnectionInfo netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter");
//           // If we are in streaming mode, always write into staging.
//           std::string utf8Schema;
//           ::WideStringToUTF8(mOperator->mSchemaName, utf8Schema);
//           netMeter.SetCatalog(COdbcConnectionManager::GetConnectionInfo(mOperator->mStreamingTransactionKey.size() > 0 ? "NetMeterStage" : utf8Schema.c_str()).GetCatalog().c_str());
//           mConnection = new COdbcConnection(netMeter);
//           mConnection->SetAutoCommit(true);

//           // Enable tracing for inserts
// //           boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET timed_statistics=true");
// //           boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET max_dump_file_size=unlimited");
// //           boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET tracefile_identifier=PERFTEST");
// //           boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET events '10046 trace name context forever, level 8'");
// //           boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET SQL_TRACE=TRUE");

//         }

//         if ((NULL == mTransactionId && mNumRead==0) ||
//             (NULL != mTransactionId && mTransactionId->GetLongValue(mInputMessage) != mCurrentTransaction))
//         {
//           if (NULL != mTransactionId)
//           {
//             // Complete BCP on current table and output completion message.
//             if(NULL != mBcpStatement)
//             {
//               mBcpStatement->ExecuteBatch();
//               mBcpStatement->Finalize();
//               delete mBcpStatement;
//               mBcpStatement = NULL;

//               RequestWrite(0);
//               mState = WRITE_0;
//               return;
//             case WRITE_0:
//               Write(GetTableBuffer(), ep);
//             }

//             // Create a copy of the table from the configured table.
//             // The copy is always in staging database.
//             DatabaseCommands cmds;
//             mCurrentTableName = cmds.GetTempTableName(L"tmp_");
//             boost::shared_ptr<COdbcStatement> stmt(mConnection->CreateStatement());
//             stmt->ExecuteUpdateW(
//               cmds.CreateTableAsSelect(L"NetMeterStage", mCurrentTableName, mOperator->mSchemaName, mOperator->mTableName));
//             // If we have a sort specification, add a clustering index to save sorting on subsequent insert
//             if (mOperator->mSortHint.size() > 0 && !COdbcConnectionManager::GetConnectionInfo("NetMeter").IsOracle())
//             {
//               std::string utf8Prefix = COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalogPrefix();
//               std::wstring prefix;
//               ::ASCIIToWide(prefix, utf8Prefix);
//               // for now just assume ascending
//               // for update joins we may want this to be a UNIQUE index if possible since that eliminates
//               // a GROUP BY inside the database while processing the update join.
//               stmt->ExecuteUpdateW((boost::wformat(L"CREATE CLUSTERED INDEX idx_%1% ON %2%%1%(%3% ASC)") % 
//                                     mCurrentTableName % prefix % mOperator->mSortHint).str());
//             }
//             mCurrentTransaction = mTransactionId->GetLongValue(mInputMessage);
//           }
//           else
//           {
//             mCurrentTableName = mOperator->mTableName;
//           }

//           ASSERT(NULL == mBcpStatement);

//           // Set up bulk loader 
//           // To improve scheduler pressure on SQL2K, recreate connection
// //           delete mConnection;
// //           mConnection = NULL;
// //           COdbcConnectionInfo netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter");
// //           // If we are in streaming mode, always write into staging.
// //           std::string utf8Schema;
// //           ::WideStringToUTF8(mOperator->mSchemaName, utf8Schema);
// //           netMeter.SetCatalog(COdbcConnectionManager::GetConnectionInfo(mOperator->mStreamingTransactionKey.size() > 0 ? "NetMeterStage" : utf8Schema.c_str()).GetCatalog().c_str());
// //           mConnection = new COdbcConnection(netMeter);
// //           mConnection->SetAutoCommit(true);

//           COdbcBcpHints hints;
//           hints.SetMinimallyLogged(true);
//           if (mOperator->mSortHint.size() > 0)
//           {
//             std::string utf8Hint;
//             ::WideStringToUTF8(mOperator->mSortHint, utf8Hint);
//             hints.AddOrder(utf8Hint);
//           }
//           std::string utf8Table;
//           ::WideStringToUTF8(mCurrentTableName, utf8Table);
//           mConnection->PrepareInsertStatement(mBcpStatement, utf8Table, hints, mOperator->mBatchSize);
//         }

//         // We've got a record to put into the table
//         // The alternative to calling API's is to expose the BCP interface
//         // as a formatted buffer and then export to that buffer.  This allows
//         // optimizations in what might not be common cases (non-nullable integral
//         // types) in which the BCP buffer can be similar to the internal buffer.
//         bool goodRecord=true;
//         for(std::vector<DesignTimeDatabaseInsert::Binding>::const_iterator it = mOperator->mBindings.begin();
//             it != mOperator->mBindings.end();
//             it++)
//         {
//           if (mOperator->mMetadata.GetNull(mInputMessage, it->GetSourcePosition()))
//           {
//             if (it->IsRequired())
//             {
//               goodRecord = false;
//               break;
//             }
//             else
//             {
//               continue;
//             }
//           }

//           switch(it->GetColumnType())
//           {
//           case MTPipelineLib::PROP_TYPE_ENUM:
//           case MTPipelineLib::PROP_TYPE_INTEGER:
//             mBcpStatement->SetInteger(it->GetTargetPosition(), mOperator->mMetadata.GetLongValue(mInputMessage, it->GetSourcePosition()));
//             break;
//           case MTPipelineLib::PROP_TYPE_BIGINTEGER:
//             mBcpStatement->SetBigInteger(it->GetTargetPosition(), mOperator->mMetadata.GetBigIntegerValue(mInputMessage, it->GetSourcePosition()));
//             break;
//           case MTPipelineLib::PROP_TYPE_DOUBLE:
//             mBcpStatement->SetDouble(it->GetTargetPosition(), mOperator->mMetadata.GetDoubleValue(mInputMessage, it->GetSourcePosition()));
//             break;
//           case MTPipelineLib::PROP_TYPE_DECIMAL:
//           {
//             mBcpStatement->SetDecimal(
//               it->GetTargetPosition(), 
//               (decimal_traits::const_pointer) mOperator->mMetadata.GetColumn(it->GetSourcePosition())->GetValue(mInputMessage));
//             break;
//           }
//           case MTPipelineLib::PROP_TYPE_DATETIME:
//           {
//             mBcpStatement->SetDatetime(
//               it->GetTargetPosition(), 
//               (date_time_traits::const_pointer) mOperator->mMetadata.GetColumn(it->GetSourcePosition())->GetValue(mInputMessage));
//             break;
//           }
//           case MTPipelineLib::PROP_TYPE_STRING:
//           case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
//           {
//             const wchar_t * str=mOperator->mMetadata.GetStringValue(mInputMessage, it->GetSourcePosition());
//             try
//             {
//               mBcpStatement->SetWideString(it->GetTargetPosition(), str, wcslen(str));
//             }
//             catch(FatalSystemErrorException & ex)
//             {
//               std::cerr << "Exception: " << ex.what() << std::endl;
//               std::cerr << "Wide String length: " << wcslen(str) << std::endl; 
//               std::cerr << "Field position: " << it->GetSourcePosition() << std::endl;
//               std::cerr << "Table position: " << it->GetTargetPosition() << std::endl;
//             }
//             break;
//           }
//           case MTPipelineLib::PROP_TYPE_ASCII_STRING:
//           {
//             const char * str=mOperator->mMetadata.GetUTF8StringValue(mInputMessage, it->GetSourcePosition());
//             mBcpStatement->SetString(it->GetTargetPosition(), str);
//             break;
//           }
//           case MTPipelineLib::PROP_TYPE_BOOLEAN:
//           {
//             bool tmp = mOperator->mMetadata.GetBooleanValue(mInputMessage, it->GetSourcePosition());
//             mBcpStatement->SetString(it->GetTargetPosition(), tmp ? "1" : "0");
//             break;
//           }
//           case MTPipelineLib::PROP_TYPE_OPAQUE:
//           {
//             const unsigned char * str=mOperator->mMetadata.GetBinaryValue(mInputMessage, it->GetSourcePosition());
//             mBcpStatement->SetBinary(it->GetTargetPosition(), str, 16);
//             break;
//           }
//           default:
//             throw std::runtime_error("Not Yet Implemented");
//           }
//         }
//         if (goodRecord)
//         {
//           mBcpStatement->AddBatch();

//           if(++mCurrentBatchCount >= mOperator->mBatchSize)
//           {
//             mCurrentBatchCount = 0;
//             mBcpStatement->ExecuteBatch();
//           }
//         }
//         else
//         {
//           // TODO: write the error to an error output.
//   std::wstring out;
//   wchar_t buf[1000];
//   // TODO: Add printing to DataAccessor.
//   for(int i=0; i<mOperator->mMetadata.GetNumColumns(); i++)
//   {
//     DataAccessor * accessor = mOperator->mMetadata.GetColumn(i);
//     if (i>0) out += L", ";
//     out += accessor->GetName();
//     out += L":";
//     if (accessor->GetNull(mInputMessage))
//     {
//       out += L"<NULL>";
//       continue;
//     }
//     switch(accessor->GetPhysicalFieldType()->GetPipelineType())
//     {
//     case MTPipelineLib::PROP_TYPE_INTEGER: 
//     {
//       swprintf(buf, L"%d", accessor->GetLongValue(mInputMessage)); 
//       out += buf;
//       break;
//     }
//     case MTPipelineLib::PROP_TYPE_DOUBLE: 
//     {
//       swprintf(buf, L"%E", accessor->GetDoubleValue(mInputMessage));      
//       out += buf;
//       break;
//     }
//     case MTPipelineLib::PROP_TYPE_DATETIME: 
//     case MTPipelineLib::PROP_TYPE_TIME: 
//     {
//       BSTR bstrVal;
//       HRESULT hr = VarBstrFromDate(accessor->GetDatetimeValue(mInputMessage), LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
//       ASSERT(!FAILED(hr));
//       // Use a _bstr_t to delete the BSTR
//       _bstr_t bstrtVal(bstrVal);
//       out += bstrVal;
//       break;
//     }
//     case MTPipelineLib::PROP_TYPE_BOOLEAN: 
//     {
//       swprintf(buf, L"%s", accessor->GetBooleanValue(mInputMessage) ? L"TRUE" : L"FALSE");      
//       out += buf;
//       break;
//     }
//     case MTPipelineLib::PROP_TYPE_ENUM: 
//     {
//       swprintf(buf, L"%d", accessor->GetEnumValue(mInputMessage));      
//       out += buf;
//       break;
//     }
//     case MTPipelineLib::PROP_TYPE_DECIMAL: 
//     {
//       BSTR bstrVal;
//       LPDECIMAL decPtr = const_cast<DECIMAL *>(accessor->GetDecimalValue(mInputMessage));
//       HRESULT hr = VarBstrFromDec(decPtr, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
//       ASSERT(!FAILED(hr));
//       // Use a _bstr_t to delete the BSTR
//       _bstr_t bstrtVal(bstrVal, false);
//       out += bstrVal;
//       break;
//     }
//     case MTPipelineLib::PROP_TYPE_ASCII_STRING: 
//     {
//       wstring tmp;
//       ::ASCIIToWide(tmp, accessor->GetUTF8StringValue(mInputMessage));
//       out += tmp;
//       break;
//     }
//     case MTPipelineLib::PROP_TYPE_STRING: 
//     case MTPipelineLib::PROP_TYPE_UNICODE_STRING: 
//     {
//       out += accessor->GetStringValue(mInputMessage);
//       break;
//     }
//     case MTPipelineLib::PROP_TYPE_BIGINTEGER: 
//     {
//       swprintf(buf, L"%I64d", accessor->GetBigIntegerValue(mInputMessage));      
//       out += buf;
//       break;
//     }
//     }
//   }

//   std::string utf8Out;
//   ::WideStringToUTF8(out, utf8Out);
//   std::cout << utf8Out.c_str() << std::endl;          
//         }
//         mNumRead++;
//         // End of the road for this message.
//         mOperator->mMetadata.Free(mInputMessage); 
//       }
//       else 
//       {
//         if (NULL != mTransactionId)
//         {
//           // Complete BCP on in progress table and output
//           if(NULL != mBcpStatement)
//           {
//             mBcpStatement->ExecuteBatch();
//             mBcpStatement->Finalize();
//             delete mBcpStatement;
//             mBcpStatement = NULL;

//             RequestWrite(0);
//             mState = WRITE_1;
//             return;
//           case WRITE_1:
//             Write(GetTableBuffer(), ep);
//           }
//           delete mConnection;
//           mConnection = NULL;

//           RequestWrite(0);
//           mState = WRITE_EOF;
//           return;
//         case WRITE_EOF:
//           Write(mOperator->mOutputMetadata.AllocateEOF(), ep, true);
//         }
//         else
//         {
//           if (mBcpStatement != NULL)
//           {
//             if (mCurrentBatchCount > 0)
//             {
//               mCurrentBatchCount = 0;
//               mBcpStatement->ExecuteBatch();
//             }
//             mBcpStatement->Finalize();
//             delete mBcpStatement;
//             mBcpStatement = NULL;
//           }
//           delete mConnection;
//           mConnection = NULL;
//         }
//         // We're all done
//         mOperator->mMetadata.Free(mInputMessage); 
//         return;
//       }
//     }
//   }
// }
template <class _InsertStmt>
void RunTimeDatabaseInsertActivation<_InsertStmt>::WriteRecord(const_record_t inputMessage)
{
  // We've got a record to put into the table
  // The alternative to calling API's is to expose the BCP interface
  // as a formatted buffer and then export to that buffer.  This allows
  // optimizations in what might not be common cases (non-nullable integral
  // types) in which the BCP buffer can be similar to the internal buffer.
  bool goodRecord=true;
  for(std::vector<RunTimeDatabaseInsert<_InsertStmt>::RuntimeBinding>::const_iterator it = mOperator->mBindings.begin();
      it != mOperator->mBindings.end();
      it++)
  {
    if (it->GetSourceAccessor()->GetNull(inputMessage))
    {
      if (it->IsRequired())
      {
        goodRecord = false;
        break;
      }
      else
      {
        continue;
      }
    }

    switch(it->GetColumnType())
    {
    case MTPipelineLib::PROP_TYPE_ENUM:
    case MTPipelineLib::PROP_TYPE_INTEGER:
      mBcpStatement->SetInteger(it->GetTargetPosition(), it->GetSourceAccessor()->GetLongValue(inputMessage));
      break;
    case MTPipelineLib::PROP_TYPE_BIGINTEGER:
      mBcpStatement->SetBigInteger(it->GetTargetPosition(), it->GetSourceAccessor()->GetBigIntegerValue(inputMessage));
      break;
    case MTPipelineLib::PROP_TYPE_DOUBLE:
      mBcpStatement->SetDouble(it->GetTargetPosition(), it->GetSourceAccessor()->GetDoubleValue(inputMessage));
      break;
    case MTPipelineLib::PROP_TYPE_DECIMAL:
    {
      mBcpStatement->SetDecimal(
        it->GetTargetPosition(), 
        (decimal_traits::const_pointer) it->GetSourceAccessor()->GetValue(inputMessage));
      break;
    }
    case MTPipelineLib::PROP_TYPE_DATETIME:
    {
      mBcpStatement->SetDatetime(
        it->GetTargetPosition(), 
        (date_time_traits::const_pointer) it->GetSourceAccessor()->GetValue(inputMessage));
      break;
    }
    case MTPipelineLib::PROP_TYPE_STRING:
    case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
    {
      const wchar_t * str=it->GetSourceAccessor()->GetStringValue(inputMessage);
      try
      {
        mBcpStatement->SetWideString(it->GetTargetPosition(), str, wcslen(str));
      }
      catch(FatalSystemErrorException & ex)
      {
        std::cerr << "Exception: " << ex.what() << std::endl;
        std::cerr << "Wide String length: " << wcslen(str) << std::endl; 
        std::cerr << "Table position: " << it->GetTargetPosition() << std::endl;
      }
      break;
    }
    case MTPipelineLib::PROP_TYPE_ASCII_STRING:
    {
      const char * str=it->GetSourceAccessor()->GetUTF8StringValue(inputMessage);
      mBcpStatement->SetString(it->GetTargetPosition(), str);
      break;
    }
    case MTPipelineLib::PROP_TYPE_BOOLEAN:
    {
      bool tmp = it->GetSourceAccessor()->GetBooleanValue(inputMessage);
      mBcpStatement->SetString(it->GetTargetPosition(), tmp ? "1" : "0");
      break;
    }
    case MTPipelineLib::PROP_TYPE_OPAQUE:
    {
      const unsigned char * str=it->GetSourceAccessor()->GetBinaryValue(inputMessage);
      mBcpStatement->SetBinary(it->GetTargetPosition(), str, 16);
      break;
    }
    default:
      throw std::runtime_error("Not Yet Implemented");
    }
  }
  if (goodRecord)
  {
    mBcpStatement->AddBatch();

    if(++mCurrentBatchCount >= mOperator->mBatchSize)
    {
      mCurrentBatchCount = 0;
      mBcpStatement->ExecuteBatch();
    }
  }
  else
  {
    // It would be good to print all the data in the batch
    // that is attempting to be inserted.  The commented
    // out lines show the printing of just a single record.
    // std::string data = mOperator->mMetadata.PrintMessage(inputMessage);
    std::string opName;
    ::WideStringToUTF8(mOperator->GetName(), opName);
    MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[DatabaseInsert]");
    logger->logError("A MetraFlow insert operation failed. This is usually due to the "
                     "data violating column constraints. "
                     "Operator: " + opName);
    // TODO: Print record to an error output.
  }
}

/**
 * Encapsulates a set of tables in a staging database that are modeled off a core table (e.g. t_acc_usage).
 * Supports methods to atomically push and pop a temporary table from the queue (safe across processes and machines
 * by using locking in the database).
 */
class TemporaryTableQueue
{
private:
  std::wstring mModelTableSchema;
  std::wstring mModelTableName;
  std::wstring mSortHint;
  std::wstring mFullyQualifiedQueueTable;

  std::wstring CreateNewTable(boost::shared_ptr<COdbcConnection> conn)
  {
    // Create a copy of the table from the configured table.
    // The copy is always in staging database.
    DatabaseCommands cmds;
    std::wstring currentTableName = cmds.GetTempTableName(L"tmp_");
    boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
    stmt->ExecuteUpdateW(
      cmds.CreateTableAsSelect(L"NetMeterStage", currentTableName, mModelTableSchema, mModelTableName));
    // If we have a sort specification, add a clustering index to save sorting on subsequent insert
    if (mSortHint.size() > 0 && !COdbcConnectionManager::GetConnectionInfo("NetMeter").IsOracle())
    {
      std::string utf8Prefix = COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalogPrefix();
      std::wstring prefix;
      ::ASCIIToWide(prefix, utf8Prefix);
      // for now just assume ascending
      // for update joins we may want this to be a UNIQUE index if possible since that eliminates
      // a GROUP BY inside the database while processing an update join (such as the Microsoft Online based benchmark).
      stmt->ExecuteUpdateW((boost::wformat(L"CREATE CLUSTERED INDEX idx_%1% ON %2%%1%(%3% ASC)") % 
                            currentTableName % prefix % mSortHint).str());
    }
    return currentTableName;
  }

public:
  TemporaryTableQueue(const std::wstring& modelTableSchema,
                      const std::wstring& modelTableName,
                      const std::wstring& sortHint)
    :
    mModelTableSchema(modelTableSchema),
    mModelTableName(modelTableName),
    mSortHint(sortHint)
  {
    std::wstring wNetMeterStagePrefix;
    ::ASCIIToWide(wNetMeterStagePrefix, COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalogPrefix().c_str());
    mFullyQualifiedQueueTable = wNetMeterStagePrefix + modelTableName + L"_queue";
    boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
    // Try to create the table but catch exception if it already exists
    boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
    try
    {
      stmt->ExecuteUpdateW(L"CREATE TABLE " + mFullyQualifiedQueueTable + L"(nm_table_name NVARCHAR(32) NOT NULL PRIMARY KEY, b_free INTEGER NOT NULL)");
    }
    catch(COdbcStatementException & ex)
    {
      // We are prepared for duplicate object errors
      if (ex.getSqlState() != "42S01")
        throw;
    }
  }

  std::wstring Pop()
  {
    boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
    conn->SetAutoCommit(false);
    boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
    boost::shared_ptr<COdbcResultSet> rs(stmt->ExecuteQueryW(L"SELECT TOP 1 nm_table_name FROM " + mFullyQualifiedQueueTable + L" WITH(UPDLOCK, READPAST) WHERE b_free=1"));
    if(rs->Next())
    {
      std::wstring tmp = rs->GetWideString(1);
      rs = boost::shared_ptr<COdbcResultSet> ();
      stmt->ExecuteUpdateW(L"UPDATE " + mFullyQualifiedQueueTable + L" SET b_free=0 WHERE nm_table_name =N'" + tmp + L"'");
      conn->CommitTransaction();
      conn->SetAutoCommit(true);
      std::wstring wNetMeterStagePrefix;
      ::ASCIIToWide(wNetMeterStagePrefix, COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalogPrefix().c_str());
      stmt = boost::shared_ptr<COdbcStatement>(conn->CreateStatement());
      stmt->ExecuteUpdateW(L"TRUNCATE TABLE " + wNetMeterStagePrefix + tmp);
      return tmp;
    }
    else
    {
      conn->CommitTransaction();
      conn->SetAutoCommit(true);
      std::wstring tmp = CreateNewTable(conn);
      // Insert a record into the queue in the allocated state
      stmt->ExecuteUpdateW(L"INSERT INTO " + mFullyQualifiedQueueTable + L" (nm_table_name, b_free) VALUES (N'" + tmp + L"', 0)");      
      return tmp;
    }
  }
};

template <class _InsertStmt>
void RunTimeDatabaseInsertActivation<_InsertStmt>::PrepareStatement()
{
  ASSERT(NULL == mBcpStatement);

  // Set up bulk loader 
  // To improve scheduler pressure on SQL2K, recreate connection
//           delete mConnection;
//           mConnection = NULL;
//           COdbcConnectionInfo netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter");
//           // If we are in streaming mode, always write into staging.
//           std::string utf8Schema;
//           ::WideStringToUTF8(mOperator->mSchemaName, utf8Schema);
//           netMeter.SetCatalog(COdbcConnectionManager::GetConnectionInfo(mOperator->mStreamingTransactionKey.size() > 0 ? "NetMeterStage" : utf8Schema.c_str()).GetCatalog().c_str());
//           mConnection = new COdbcConnection(netMeter);
//           mConnection->SetAutoCommit(true);

  COdbcBcpHints hints;
  hints.SetMinimallyLogged(true);
  if (mOperator->mSortHint.size() > 0)
  {
    std::string utf8Hint;
    ::WideStringToUTF8(mOperator->mSortHint, utf8Hint);
    hints.AddOrder(utf8Hint);
  }
  std::string utf8Table;
  ::WideStringToUTF8(mCurrentTableName, utf8Table);
  mConnection->PrepareInsertStatement(mBcpStatement, utf8Table, hints, mOperator->mBatchSize);
}

template <class _InsertStmt>
void RunTimeDatabaseInsertActivation<_InsertStmt>::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    while(true)
    {
      RequestRead(0);
      mState = READ_0;
      return;
    case READ_0:
      ASSERT(ep == mInputs[0]);
      Read(mInputMessage, ep);
      if(!mOperator->mMetadata.IsEOF(mInputMessage))
      {
        // Initialize connection if needed.
        if (!mConnection)
        {
          COdbcConnectionInfo netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter");
          // If we are in streaming mode, always write into staging.
          std::string utf8Schema;
          ::WideStringToUTF8(mOperator->mSchemaName, utf8Schema);
          netMeter.SetCatalog(COdbcConnectionManager::GetConnectionInfo(mOperator->mStreamingTransactionKey.size() > 0 ? "NetMeterStage" : utf8Schema.c_str()).GetCatalog().c_str());
          mConnection = new COdbcConnection(netMeter);
          mConnection->SetAutoCommit(true);

//           mTempTableQueue = boost::shared_ptr<TemporaryTableQueue>(new TemporaryTableQueue(mOperator->mSchemaName,
//                                                                                            mOperator->mTableName,
//                                                                                            mOperator->mSortHint));
          // Enable tracing for inserts
//           boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET timed_statistics=true");
//           boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET max_dump_file_size=unlimited");
//           boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET tracefile_identifier=PERFTEST");
//           boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET events '10046 trace name context forever, level 8'");
//           boost::shared_ptr<COdbcStatement>(mConnection->CreateStatement())->ExecuteUpdate("ALTER SESSION SET SQL_TRACE=TRUE");

        }

        if ((NULL == mTransactionId && mNumRead==0) ||
            (NULL != mTransactionId && mTransactionId->GetLongValue(mInputMessage) != mCurrentTransaction))
        {
          if (NULL != mTransactionId)
          {
            // Complete BCP on current table and output completion message.
            if(0 != mQueue.GetSize())
            {
              PrepareStatement();
              MessagePtr tmp;
              while(mQueue.GetSize())
              {
                mQueue.Pop(tmp);
                WriteRecord(tmp);
                mOperator->mMetadata.Free(tmp); 
                // TODO: add batch logic
              }

              if (mCurrentBatchCount > 0)
              {
                mCurrentBatchCount = 0;
                mBcpStatement->ExecuteBatch();
              }
              mBcpStatement->Finalize();
              delete mBcpStatement;
              mBcpStatement = NULL;

              RequestWrite(0);
              mState = WRITE_0;
              return;
            case WRITE_0:
              Write(GetTableBuffer(), ep);
            }

//             mCurrentTableName = mTempTableQueue->Pop();

            // Create a copy of the table from the configured table.
            // The copy is always in staging database.
            DatabaseCommands cmds;
            mCurrentTableName = cmds.GetTempTableName(L"tmp_");
            boost::shared_ptr<COdbcStatement> stmt(mConnection->CreateStatement());
            stmt->ExecuteUpdateW(
              cmds.CreateTableAsSelect(L"NetMeterStage", mCurrentTableName, mOperator->mSchemaName, mOperator->mTableName));
            // If we have a sort specification, add a clustering index to save sorting on subsequent insert
            if (mOperator->mSortHint.size() > 0 && !COdbcConnectionManager::GetConnectionInfo("NetMeter").IsOracle())
            {
              std::string utf8Prefix = COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalogPrefix();
              std::wstring prefix;
              ::ASCIIToWide(prefix, utf8Prefix);
              // for now just assume ascending
              // for update joins we may want this to be a UNIQUE index if possible since that eliminates
              // a GROUP BY inside the database while processing the update join.
              stmt->ExecuteUpdateW((boost::wformat(L"CREATE CLUSTERED INDEX idx_%1% ON %2%%1%(%3% ASC)") % 
                                    mCurrentTableName % prefix % mOperator->mSortHint).str());
            }
            mCurrentTransaction = mTransactionId->GetLongValue(mInputMessage);
          }
          else
          {
            mCurrentTableName = mOperator->mTableName;
            PrepareStatement();
          }
        }

        if(mTransactionId != NULL)
        {
          mQueue.Push(mInputMessage);
        }
        else
        {
          WriteRecord(mInputMessage);
          // End of the road for this message.
          mOperator->mMetadata.Free(mInputMessage); 
        }
        mNumRead++;
      }
      else 
      {
        if (NULL != mTransactionId)
        {
          // Complete BCP on in progress table and output
          if(0 != mQueue.GetSize())
          {
            PrepareStatement();
            MessagePtr tmp;
            while(mQueue.GetSize())
            {
              mQueue.Pop(tmp);
              WriteRecord(tmp);
              // TODO: add batch logic
            }

            if (mCurrentBatchCount > 0)
            {
              mCurrentBatchCount = 0;
              mBcpStatement->ExecuteBatch();
            }
            mBcpStatement->Finalize();
            delete mBcpStatement;
            mBcpStatement = NULL;

            RequestWrite(0);
            mState = WRITE_1;
            return;
          case WRITE_1:
            Write(GetTableBuffer(), ep);
          }
          delete mConnection;
          mConnection = NULL;

          RequestWrite(0);
          mState = WRITE_EOF;
          return;
        case WRITE_EOF:
          Write(mOperator->mOutputMetadata.AllocateEOF(), ep, true);
        }
        else
        {
          if (mBcpStatement != NULL)
          {
            if (mCurrentBatchCount > 0)
            {
              mCurrentBatchCount = 0;
              mBcpStatement->ExecuteBatch();
            }
            mBcpStatement->Finalize();
            delete mBcpStatement;
            mBcpStatement = NULL;
          }
          delete mConnection;
          mConnection = NULL;
        }
        // We're all done
        mOperator->mMetadata.Free(mInputMessage); 
        return;
      }
    }
  }
}
DesignTimeTransactionalInstall::DesignTimeTransactionalInstall(boost::int32_t tableInputs)
{
  ASSERT(tableInputs >= 1);
  mInputPorts.insert(this, 0, L"control", false);
  for(boost::int32_t i=0; i<tableInputs; i++)
  {
    mInputPorts.insert(this, i+1, (boost::wformat(L"input(%1%)") % i).str(), false);
  }
}

DesignTimeTransactionalInstall::~DesignTimeTransactionalInstall()
{
}

void DesignTimeTransactionalInstall::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"statementList", OPERATOR_ARG_TYPE_SUBLIST, GetName()))
  {
    std::vector<std::wstring> pre;
    std::vector<std::wstring> query;
    std::vector<std::wstring> post;

    const std::vector<OperatorArg> &argList = arg.getSubList();
    for (unsigned i=0; i<argList.size(); i++)
    {
      if (argList[i].is(L"preprocess", OPERATOR_ARG_TYPE_STRING, GetName()))
      {
        pre.push_back(argList[i].getNormalizedString());
      }
      else if (argList[i].is(L"query", OPERATOR_ARG_TYPE_STRING, GetName()))
      {
        query.push_back(argList[i].getNormalizedString());
      }
      else if (argList[i].is(L"postprocess",OPERATOR_ARG_TYPE_STRING, GetName()))
      {
        post.push_back(argList[i].getNormalizedString());
      }
      else if (argList[i].is(L"mode",OPERATOR_ARG_TYPE_STRING, GetName()))
      {
        handleModeArg(argList[i]);
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
    
    mPreTransactionQueries.push_back(pre);
    mQueries.push_back(query);
    mPostTransactionQueries.push_back(post);
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeTransactionalInstall* DesignTimeTransactionalInstall::clone(
                                              const std::wstring& name,
                                              std::vector<OperatorArg *>& args, 
                                              int nExtraInputs, 
                                              int nExtraOutputs) const
{
  DesignTimeTransactionalInstall* result = 
    new DesignTimeTransactionalInstall(mInputPorts.size() + nExtraInputs - 1);

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeTransactionalInstall::SetPreTransactionQueries(const std::vector<std::vector<std::wstring> >& preTransactionQueries)
{
  ASSERT(preTransactionQueries.size() == mInputPorts.size()-1);
  mPreTransactionQueries = preTransactionQueries;
}

void DesignTimeTransactionalInstall::SetQueries(const std::vector<std::vector<std::wstring> >& queries)
{
  ASSERT(queries.size() == mInputPorts.size()-1);
  mQueries = queries;
}

void DesignTimeTransactionalInstall::SetPostTransactionQueries(const std::vector<std::vector<std::wstring> >& postTransactionQueries)
{
  ASSERT(postTransactionQueries.size() == mInputPorts.size()-1);
  mPostTransactionQueries = postTransactionQueries;
}

void DesignTimeTransactionalInstall::type_check()
{
  // We expect a fixed record format on control input.
  const LogicalRecord& control(mInputPorts[L"control"]->GetLogicalMetadata());
  if (!control.HasColumn(L"id_commit_unit", false) ||
      !control.GetColumn(L"id_commit_unit").GetType().CanReadAs(LogicalFieldType::Integer(true)))
  {
    throw MissingFieldException(*this, *mInputPorts[L"control"], L"id_commit_unit");
  }
  
  for(std::size_t i = 1; i<mInputPorts.size(); i++)
  {
    std::wstring fieldName((boost::wformat(L"size_%1%") % (i-1)).str());
    if (!control.HasColumn(fieldName) ||
        !control.GetColumn(fieldName).GetType().CanReadAs(LogicalFieldType::Integer(true)))
    {
      throw MissingFieldException(*this, *mInputPorts[L"control"], fieldName);
    }
  }
  // We expect that there is a table name column and schema on all table inputs.
  for(PortCollection::iterator it = mInputPorts.begin()+1;
      it != mInputPorts.end();
      ++it)
  {
    if (!(*it)->GetLogicalMetadata().HasColumn(L"table", false) ||
        !(*it)->GetLogicalMetadata().GetColumn(L"table").GetType().CanReadAs(LogicalFieldType::String(false)))
    {
      throw MissingFieldException(*this, **it, L"table");
    }
    if (!(*it)->GetLogicalMetadata().HasColumn(L"schema", false) ||
        !(*it)->GetLogicalMetadata().GetColumn(L"schema").GetType().CanReadAs(LogicalFieldType::String(false)))
    {
      throw MissingFieldException(*this, **it, L"schema");
    }
  }
}

RunTimeOperator * DesignTimeTransactionalInstall::code_generate(partition_t maxPartition)
{
  std::vector<const RecordMetadata*> metadata;
  for(PortCollection::iterator it = mInputPorts.begin();
      it != mInputPorts.end();
      ++it)
  {
    metadata.push_back((*it)->GetMetadata());
  }  
  return new RunTimeTransactionalInstall(mName, 
                                         mPreTransactionQueries,
                                         mQueries,
                                         mPostTransactionQueries,
                                         metadata);
}

class RunTimeTransactionalInstaller
{
private:
  std::deque<std::wstring> mPreTransaction;
  std::deque<std::wstring> mTransaction;
  std::deque<std::wstring> mPostTransaction;
  boost::int32_t mPriority;
  std::wstring mTag;
//   MetraFlowLogPtr mLogger;
public:
  RunTimeTransactionalInstaller(boost::int32_t priority=0, const std::wstring& tag=L"");
  ~RunTimeTransactionalInstaller();
  void Run();
  void EnqueuePreTransaction(const std::wstring& query);
  void EnqueueTransaction(const std::wstring& query);
  void EnqueuePostTransaction(const std::wstring& query);
  std::wstring GetTag() const
  {
    return mTag;
  }
  boost::int32_t GetPriority() const
  {
    return mPriority;
  }
  struct Less : public std::binary_function<boost::shared_ptr<RunTimeTransactionalInstaller>, boost::shared_ptr<RunTimeTransactionalInstaller>, bool >
  {
    bool operator()(boost::shared_ptr<RunTimeTransactionalInstaller> e1, boost::shared_ptr<RunTimeTransactionalInstaller> e2) const
    {
      return e1->GetPriority() > e2->GetPriority();
    }
  };
};

typedef std::priority_queue<boost::shared_ptr<RunTimeTransactionalInstaller>, 
                            std::vector<boost::shared_ptr<RunTimeTransactionalInstaller> >, 
                            RunTimeTransactionalInstaller::Less> InstallerPriorityQueue;

RunTimeTransactionalInstaller::RunTimeTransactionalInstaller(boost::int32_t priority, const std::wstring& tag)
  :
  mPriority(priority),
  mTag(tag)
{
// 	mLogger = MetraFlowLoggerManager::GetLogger((boost::format("[RunTimeTransactionalInstaller(%1%)]") % 
//                                                std::size_t(this)).str());
}

RunTimeTransactionalInstaller::~RunTimeTransactionalInstaller()
{
}

void RunTimeTransactionalInstaller::EnqueuePreTransaction(const std::wstring& query)
{
  mPreTransaction.push_back(query);
}

void RunTimeTransactionalInstaller::EnqueueTransaction(const std::wstring& query)
{
  mTransaction.push_back(query);
}

void RunTimeTransactionalInstaller::EnqueuePostTransaction(const std::wstring& query)
{
  mPostTransaction.push_back(query);
}

void RunTimeTransactionalInstaller::Run()
{
  boost::shared_ptr<COdbcConnection> conn(
    new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));

  Timer execTimer;

  // Do pre transaction work in auto commit mode.
  conn->SetAutoCommit(true);
  while(mPreTransaction.size() > 0)
  {
    boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
    {
      ScopeTimer sc(&execTimer);
      stmt->ExecuteUpdateW(mPreTransaction.front());
    }
    mPreTransaction.pop_front();
  }

  // Do work of the transaction and commit.  Here we're going
  // to be careful to retry in face of deadlocks and connectivity failures.
  boost::int32_t numRetries = 30;
  while(--numRetries >= 0)
  {
     conn = boost::shared_ptr<COdbcConnection>(
       new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
    // Make a copy of work items so we can use the pop_front
    // code below but still have atomicity on rollback.
    std::deque<std::wstring> txn(mTransaction);
    try
    {
      conn->SetAutoCommit(false);
      while(txn.size() > 0)
      {
        boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
        {
          ScopeTimer sc(&execTimer);
          stmt->ExecuteUpdateW(txn.front());
        }
        txn.pop_front();
      }
      conn->CommitTransaction();
      break;
    }
    catch(COdbcException & )
    {
      try
      {
        conn->RollbackTransaction();
        conn = boost::shared_ptr<COdbcConnection>();
      }
      catch(...)
      {
      }
      // Enough retrying!  Consider this to be failure.
      if (numRetries == 0) throw;
    }
  }
  // All done with the transactional work.
  mTransaction.clear();

  // Do post commit work in auto commit mode.
  conn->SetAutoCommit(true);
  while(mPostTransaction.size() > 0)
  {
    boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
    {
      ScopeTimer sc(&execTimer);
      stmt->ExecuteUpdateW(mPostTransaction.front());
    }
    mPostTransaction.pop_front();
  }
//   mLogger->logDebug((boost::format("Exec time %1 ms") % execTimer.GetMilliseconds()).str());
}

class InstallerWorkQueue
{
private:
  boost::mutex mGuard;
  boost::condition mCondvar;
  bool mShutdown;
  std::size_t mMaxSize;
//   std::deque<boost::shared_ptr<RunTimeTransactionalInstaller> > mWorkQueue;
  InstallerPriorityQueue mWorkQueue;

  std::string mError;
public:

  InstallerWorkQueue()
    :
    mShutdown(false),
    mMaxSize(5)
  {
  }

  ~InstallerWorkQueue()
  {
  }

  void SetError(const std::string& errorMessage)
  {
    boost::mutex::scoped_lock lk(mGuard);
    mError = errorMessage;
    // Someone may be waiting on this queue for something
    mCondvar.notify_all();
  }

  std::string GetError()
  {
    boost::mutex::scoped_lock lk(mGuard);
    return mError;
  }

  void Enqueue(boost::shared_ptr<RunTimeTransactionalInstaller> workItem, std::size_t& sz)
  {
    boost::mutex::scoped_lock lk(mGuard);
    while (mWorkQueue.size() >= mMaxSize && mError.size() == 0)
    {
      mCondvar.wait(lk);
    }

    if (mError.size() > 0) 
      throw std::runtime_error(mError);

    mWorkQueue.push(workItem);
//     mWorkQueue.push_back(workItem);
    sz = mWorkQueue.size();
    mCondvar.notify_one();
  }
  void Shutdown()
  {
    boost::mutex::scoped_lock lk(mGuard);
    mShutdown = true;
    mCondvar.notify_all();
  }
  void Dequeue(boost::shared_ptr<RunTimeTransactionalInstaller>& installer,
               bool& shutdown)
  {
    boost::mutex::scoped_lock lk(mGuard);
    while (!mShutdown && mWorkQueue.size() == 0 && mError.size()==0)
    {
      mCondvar.wait(lk);
    }
    // If there is already an error just get out of here and don't continue processing.
    // Right now we drain our queue before truly shutting down.
    if (mWorkQueue.size() > 0 && mError.size() == 0) 
    {
      installer = mWorkQueue.top();
      mWorkQueue.pop();
//       installer = mWorkQueue.front();
//       mWorkQueue.pop_front();
      shutdown = false;
      if (mWorkQueue.size() + 1 == mMaxSize)
      {
        // If there are any blocking enqueues, wake them up.  Note
        // that since we have a single condition variable and a dequeue might
        // also be blocked, we must notify_all to make sure that the blocked
        // enqueues also wake up.  Actually, it may be the case there are no
        // blocking dequeues since the queue is non empty at this point.
        mCondvar.notify_all();
      }
    }
    else
    {
      shutdown = true;
    }
  }

  static void Run(InstallerWorkQueue& workQueue);
};

void InstallerWorkQueue::Run(InstallerWorkQueue& workQueue)
{
  try
  {
    while(true)
    {
      boost::shared_ptr<RunTimeTransactionalInstaller> installer;
      bool shutdown;
      workQueue.Dequeue(installer, shutdown);
      if (shutdown) return;
      ASSERT(installer != NULL);
      installer->Run();
    }
  }
  catch(std::exception & e)
  {   
    workQueue.SetError(e.what());
    return;
  }
  catch(SEHException & e)
  {    
    workQueue.SetError(e.what());
    return;
  }
  catch(...)
  {
    workQueue.SetError("Unknown Exception");
    return;
  }
}

RunTimeTransactionalInstall::RunTimeTransactionalInstall()
{
}

RunTimeTransactionalInstall::RunTimeTransactionalInstall(const std::wstring& name, 
                                                         const std::vector<std::vector<std::wstring> >& preTransactionQueries,
                                                         const std::vector<std::vector<std::wstring> >& queries,
                                                         const std::vector<std::vector<std::wstring> >& postTransactionQueries,
                                                         const std::vector<const RecordMetadata*>& metadata)
  :
  RunTimeOperator(name),
  mUntransformedPreTransactionQueries(preTransactionQueries),
  mUntransformedQueries(queries),
  mUntransformedPostTransactionQueries(postTransactionQueries)
{
  for(std::vector<const RecordMetadata*>::const_iterator it = metadata.begin();
      it != metadata.end();
      it++)
  {
    mMetadata.push_back(**it);
  }
}

RunTimeTransactionalInstall::~RunTimeTransactionalInstall()
{
}

RunTimeOperatorActivation * RunTimeTransactionalInstall::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeTransactionalInstallActivation(reactor, partition, this);
}

RunTimeTransactionalInstallActivation::RunTimeTransactionalInstallActivation(Reactor * reactor, 
                                                                             partition_t partition, 
                                                                             const RunTimeTransactionalInstall * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeTransactionalInstall>(reactor, partition, runTimeOperator),
  mState(START),
  mControlMessage(NULL),
  mInputMessage(NULL),
  mNextInput(0),
  mWorkQueue(NULL)
{
}

RunTimeTransactionalInstallActivation::~RunTimeTransactionalInstallActivation()
{
  // Make sure to shut down worker threads.
  if (NULL != mWorkQueue)
  {
    mWorkQueue->Shutdown();
    for(std::vector<boost::shared_ptr<boost::thread> >::iterator it = mThreadPool.begin();
        it != mThreadPool.end();
        ++it)
    {
      (*it)->join();
    }

    delete mWorkQueue;
    mWorkQueue = NULL;
  }
}

std::wstring RunTimeTransactionalInstallActivation::TransformQuery(const std::wstring& query)
{
  std::string utf8Query;
  ::WideStringToUTF8(query, utf8Query);
  boost::regex expr1("%%%NETMETERSTAGE_PREFIX%%%");

  std::ostringstream ostr1;
  std::ostream_iterator<char,char> oit1(ostr1);
  boost::regex_replace(oit1, utf8Query.begin(), utf8Query.end(), expr1, 
                       COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalogPrefix(), 
                       boost::match_default | boost::format_all);

  std::wstring ucs2Query;
  ::ASCIIToWide(ucs2Query, ostr1.str()); 
  return ucs2Query;
}

void RunTimeTransactionalInstallActivation::Start()
{
  // We now know what partition, staging database etc. we have, so we can resolve any
  // partition specific parameters at this point.
  for(std::vector<std::vector<std::wstring> >::const_iterator outerIt = mOperator->mUntransformedPreTransactionQueries.begin();
      outerIt != mOperator->mUntransformedPreTransactionQueries.end();
      ++outerIt)
  {
    mPreTransactionQueries.push_back(std::vector<std::wstring>());
    for(std::vector<std::wstring>::const_iterator innerIt = outerIt->begin();
        innerIt != outerIt->end();
        ++innerIt)
    {
      mPreTransactionQueries.back().push_back(TransformQuery(*innerIt));
    }
  }
  for(std::vector<std::vector<std::wstring> >::const_iterator outerIt = mOperator->mUntransformedQueries.begin();
      outerIt != mOperator->mUntransformedQueries.end();
      ++outerIt)
  {
    mQueries.push_back(std::vector<std::wstring>());
    for(std::vector<std::wstring>::const_iterator innerIt = outerIt->begin();
        innerIt != outerIt->end();
        ++innerIt)
    {
      mQueries.back().push_back(TransformQuery(*innerIt));
    }
  }
  for(std::vector<std::vector<std::wstring> >::const_iterator outerIt = mOperator->mUntransformedPostTransactionQueries.begin();
      outerIt != mOperator->mUntransformedPostTransactionQueries.end();
      ++outerIt)
  {
    mPostTransactionQueries.push_back(std::vector<std::wstring>());
    for(std::vector<std::wstring>::const_iterator innerIt = outerIt->begin();
        innerIt != outerIt->end();
        ++innerIt)
    {
      mPostTransactionQueries.back().push_back(TransformQuery(*innerIt));
    }
  }

  // Create accessors.
  ASSERT(mInputs.size() == mOperator->mMetadata.size());
  mControlAccessors.push_back(mOperator->mMetadata[0].GetColumn(L"id_commit_unit"));  
  for(std::size_t i = 1; i<mInputs.size(); i++)
  {
    mControlAccessors.push_back(mOperator->mMetadata[0].GetColumn((boost::wformat(L"size_%1%") % (i-1)).str()));
    mTableAccessors.push_back(mOperator->mMetadata[i].GetColumn(L"table"));
    mSchemaAccessors.push_back(mOperator->mMetadata[i].GetColumn(L"schema"));
  }

  // Create the work queue.
  mWorkQueue = new InstallerWorkQueue();
  // Spin up thread pool.
  boost::function0<void> threadFunc = boost::bind(&InstallerWorkQueue::Run, boost::ref(*mWorkQueue));
  mThreadPool.push_back(boost::shared_ptr<boost::thread>(new boost::thread(threadFunc)));
//   mThreadPool.push_back(boost::shared_ptr<boost::thread>(new boost::thread(threadFunc)));
//   mThreadPool.push_back(boost::shared_ptr<boost::thread>(new boost::thread(threadFunc)));
//   mThreadPool.push_back(boost::shared_ptr<boost::thread>(new boost::thread(threadFunc)));

//   mLogger = MetraFlowLoggerManager::GetLogger((boost::format("[RunTimeTransactionalInstaller(%1%)]") % 
//                                                std::size_t(mInstaller.get())).str());

  mState = START;
  HandleEvent(NULL);
}

void RunTimeTransactionalInstallActivation::StartTransaction(boost::int32_t txnId)
{
  mInstaller = boost::shared_ptr<RunTimeTransactionalInstaller>(new RunTimeTransactionalInstaller());  
}

void RunTimeTransactionalInstallActivation::EnqueuePreTransaction(boost::int32_t txnId, const std::wstring& query)
{
  mInstaller->EnqueuePreTransaction(query);
}

void RunTimeTransactionalInstallActivation::EnqueueTransaction(boost::int32_t txnId, const std::wstring& query)
{
  mInstaller->EnqueueTransaction(query);
}

void RunTimeTransactionalInstallActivation::EnqueuePostTransaction(boost::int32_t txnId, const std::wstring& query)
{
  mInstaller->EnqueuePostTransaction(query);
}

void RunTimeTransactionalInstallActivation::CompleteTransaction(boost::int32_t txnId)
{
  std::size_t sz;
  mWorkQueue->Enqueue(mInstaller, sz);
  mInstaller = boost::shared_ptr<RunTimeTransactionalInstaller>();

//   mLogger->logInfo((boost::format("Transaction work queue size = %1") % sz).str());
}

void RunTimeTransactionalInstallActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    while(true)
    {
      // Read the control port to see what we have to do next.
      RequestRead(0);
      mState = READ_0;
      return;
    case READ_0:
      Read(mControlMessage, ep);
      if (!mOperator->mMetadata[0].IsEOF(mControlMessage))
      {
        // This control message identifies a transaction.  Create the connection
        // for the transaction.
        StartTransaction(mControlAccessors[0]->GetLongValue(mControlMessage));

        // Look at the control input to see which inputs we should read from.
        // We guarantee that we execute in the order determined by the order of
        // the inputs and the order of the configured queries.
        // TODO: Figure out how to use the dataflow framework to avoid using
        // threads.
        for(mNextInput=1; mNextInput<mControlAccessors.size(); mNextInput++)
        {
          if (mControlAccessors[mNextInput]->GetLongValue(mControlMessage) > 0)
          {
            RequestRead(mNextInput);
            mState = READ_1;
            return;
          case READ_1:
            Read(mInputMessage, ep);
            ASSERT(!mOperator->mMetadata[mNextInput].IsEOF(mInputMessage));

            // TODO: Validate that the input is assigned the current transaction
            // Execute Queries for this input binding to the table parameter.

            for(mQueryIterator=mPreTransactionQueries[mNextInput-1].begin();
                mQueryIterator!=mPreTransactionQueries[mNextInput-1].end();
                ++mQueryIterator)
            {
              EnqueuePreTransaction(mControlAccessors[0]->GetLongValue(mControlMessage),
                                    (boost::wformat(*mQueryIterator) 
                                     % mTableAccessors[mNextInput-1]->GetStringValue(mInputMessage)).str());
            }
            for(mQueryIterator=mQueries[mNextInput-1].begin();
                mQueryIterator!=mQueries[mNextInput-1].end();
                ++mQueryIterator)
            {
              EnqueueTransaction(mControlAccessors[0]->GetLongValue(mControlMessage),
                                 (boost::wformat(*mQueryIterator) 
                                  % mTableAccessors[mNextInput-1]->GetStringValue(mInputMessage)).str());
            }
            for(mQueryIterator=mPostTransactionQueries[mNextInput-1].begin();
                mQueryIterator!=mPostTransactionQueries[mNextInput-1].end();
                ++mQueryIterator)
            {
              EnqueuePostTransaction(mControlAccessors[0]->GetLongValue(mControlMessage),
                                     (boost::wformat(*mQueryIterator) 
                                      % mTableAccessors[mNextInput-1]->GetStringValue(mInputMessage)).str());
            }
            mOperator->mMetadata[mNextInput].Free(mInputMessage);
          }
        }
        // Signal that there is no more work in the transaction.
        CompleteTransaction(mControlAccessors[0]->GetLongValue(mControlMessage));

        mOperator->mMetadata[0].Free(mControlMessage);
      }
      else
      {
        mWorkQueue->Shutdown();

        mOperator->mMetadata[0].Free(mControlMessage);
        // Read the rest of the input to EOF; should
        // be on the next input!
        for(mNextInput=1; mNextInput<mInputs.size(); mNextInput++)
        {
          RequestRead(mNextInput);
          mState = READ_EOF;
          return;
        case READ_EOF:
          Read(mInputMessage, ep);
          ASSERT(mOperator->mMetadata[mNextInput].IsEOF(mInputMessage));
          mOperator->mMetadata[mNextInput].Free(mInputMessage);
        } 
//         {
//           // Shut down worker threads.
//           for(std::vector<boost::shared_ptr<boost::thread> >::iterator it = mThreadPool.begin();
//               it != mThreadPool.end();
//               ++it)
//           {
//             (*it)->join();
//           }
//           delete mWorkQueue;
//           mWorkQueue = NULL;
//         }
        return;
      }
    }
  }
}

void RunTimeTransactionalInstallActivation::Complete()
{
  // Make sure to shut down worker threads.
  if (NULL != mWorkQueue)
  {
    mWorkQueue->Shutdown();
    for(std::vector<boost::shared_ptr<boost::thread> >::iterator it = mThreadPool.begin();
        it != mThreadPool.end();
        ++it)
    {
      (*it)->join();
    }

    // Check for any errors on the work queue
    std::string err = mWorkQueue->GetError();
    delete mWorkQueue;
    mWorkQueue = NULL;

    if (err.size() > 0)
      throw std::runtime_error(err);
  }
}

class InstallerWorkQueue2
{
private:
  boost::mutex mGuard;
  boost::condition mCondvar;
  bool mShutdown;
  std::size_t mMaxSize;
  // A set of named queues of transactions.
  // Our goal is to keep the number of transactions being executed for each name
  // about the same.  We track the number of transactions being executed separately.
  // The number is incremented whenever a transaction is dequeued for processing and it is
  // decremented when the transaction completes.
  // We leave the interpretation of the tag open but it likely some type of resource we
  // are trying to load balance over: e.g. a database table, a database schema, a physical machine.
  typedef std::map<std::wstring,
                   boost::shared_ptr<std::deque<boost::shared_ptr<RunTimeTransactionalInstaller> > > > WorkQueues;
  std::map<std::wstring,
           boost::shared_ptr<std::deque<boost::shared_ptr<RunTimeTransactionalInstaller> > > > mWorkQueues;
  
  std::map<std::wstring,
           std::size_t> mNumBeingProcessed;

  std::size_t mTotalQueueSize;

  std::string mError;
public:

  InstallerWorkQueue2()
    :
    mShutdown(false),
    mMaxSize(1000000),
    mTotalQueueSize(0)
  {
  }

  ~InstallerWorkQueue2()
  {
  }

  void SetError(const std::string& errorMessage)
  {
    boost::mutex::scoped_lock lk(mGuard);
    mError = errorMessage;
    // Someone may be waiting on this queue for something
    mCondvar.notify_all();
  }

  std::string GetError()
  {
    boost::mutex::scoped_lock lk(mGuard);
    return mError;
  }

  void Enqueue(boost::shared_ptr<RunTimeTransactionalInstaller> workItem, std::size_t& sz)
  {
    boost::mutex::scoped_lock lk(mGuard);
    while (mTotalQueueSize >= mMaxSize && mError.size() == 0)
    {
      mCondvar.wait(lk);
    }

    if (mError.size() > 0) 
      throw std::runtime_error(mError);

    // Check if we need to create a queue for the tag.  Put the item in the 
    // queue for the tag.
    if (mWorkQueues.find(workItem->GetTag()) == mWorkQueues.end())
    {
      mWorkQueues[workItem->GetTag()] = boost::shared_ptr<std::deque<boost::shared_ptr<RunTimeTransactionalInstaller> > >(
        new std::deque<boost::shared_ptr<RunTimeTransactionalInstaller> >());
      mNumBeingProcessed[workItem->GetTag()] = 0;
    }
    mWorkQueues[workItem->GetTag()]->push_back(workItem);
    mTotalQueueSize += 1;
//     mWorkQueue.push_back(workItem);
    sz = mWorkQueues[workItem->GetTag()]->size();
    mCondvar.notify_one();
  }
  void Shutdown()
  {
    boost::mutex::scoped_lock lk(mGuard);
    mShutdown = true;
    mCondvar.notify_all();
  }
  void Dequeue(boost::shared_ptr<RunTimeTransactionalInstaller>& installer,
               bool& shutdown)
  {
    boost::mutex::scoped_lock lk(mGuard);
    while (!mShutdown && mTotalQueueSize == 0 && mError.size()==0)
    {
      mCondvar.wait(lk);
    }
    // If there is already an error just get out of here and don't continue processing.
    // Right now we drain our queue before truly shutting down.
    if (mTotalQueueSize > 0 && mError.size() == 0) 
    {
      std::wstring minTag;
      std::size_t minNumBeingProcessed = std::numeric_limits<std::size_t>::max();
      // Find the non-empty queue with the smallest number of outstanding
      // requests.  Pop from that.
      for(WorkQueues::iterator it = mWorkQueues.begin();
          it != mWorkQueues.end();
          ++it)
      {
        if (it->second->size() > 0)
        {
          if (mNumBeingProcessed[it->first] < minNumBeingProcessed)
          {
            minNumBeingProcessed = mNumBeingProcessed[it->first];
            minTag = it->first;
          }
        }
      }
      installer = mWorkQueues[minTag]->front();
      mWorkQueues[minTag]->pop_front();
      mTotalQueueSize -= 1;
      mNumBeingProcessed[minTag] += 1;
      
      shutdown = false;
      if (mTotalQueueSize + 1 == mMaxSize)
      {
        // If there are any blocking enqueues, wake them up.  Note
        // that since we have a single condition variable and a dequeue might
        // also be blocked, we must notify_all to make sure that the blocked
        // enqueues also wake up.  Actually, it may be the case there are no
        // blocking dequeues since the queue is non empty at this point.
        mCondvar.notify_all();
      }
    }
    else
    {
      shutdown = true;
    }
  }

  void Complete(boost::shared_ptr<RunTimeTransactionalInstaller> installer)
  {
    boost::mutex::scoped_lock lk(mGuard);
    mNumBeingProcessed[installer->GetTag()] -= 1;
  }

  static void Run(InstallerWorkQueue2& workQueue);
};

void InstallerWorkQueue2::Run(InstallerWorkQueue2& workQueue)
{
  try
  {
    while(true)
    {
      boost::shared_ptr<RunTimeTransactionalInstaller> installer;
      bool shutdown;
      workQueue.Dequeue(installer, shutdown);
      if (shutdown) return;
      ASSERT(installer != NULL);
      installer->Run();
      workQueue.Complete(installer);
    }
  }
  catch(std::exception & e)
  {   
    workQueue.SetError(e.what());
    return;
  }
  catch(SEHException & e)
  {    
    workQueue.SetError(e.what());
    return;
  }
  catch(...)
  {
    workQueue.SetError("Unknown Exception");
    return;
  }
}

DesignTimeTransactionalInstall2::DesignTimeTransactionalInstall2(boost::int32_t tableInputs)
{
  ASSERT(tableInputs == 0);
  mInputPorts.insert(this, 0, L"input", false);
}

DesignTimeTransactionalInstall2::~DesignTimeTransactionalInstall2()
{
}

void DesignTimeTransactionalInstall2::handleArg(const OperatorArg& arg)
{
  handleCommonArg(arg);
}

DesignTimeTransactionalInstall2* DesignTimeTransactionalInstall2::clone(
                                              const std::wstring& name,
                                              std::vector<OperatorArg *>& args, 
                                              int nExtraInputs, 
                                              int nExtraOutputs) const
{
  DesignTimeTransactionalInstall2* result = 
    new DesignTimeTransactionalInstall2(mInputPorts.size() + nExtraInputs - 1);

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeTransactionalInstall2::SetPreTransactionQueries(const std::vector<std::vector<std::wstring> >& preTransactionQueries)
{
  ASSERT(preTransactionQueries.size() == 2);
  mPreTransactionQueries = preTransactionQueries;
}

void DesignTimeTransactionalInstall2::SetQueries(const std::vector<std::vector<std::wstring> >& queries)
{
  ASSERT(queries.size() == 2);
  mQueries = queries;
}

void DesignTimeTransactionalInstall2::SetPostTransactionQueries(const std::vector<std::vector<std::wstring> >& postTransactionQueries)
{
  ASSERT(postTransactionQueries.size() == 2);
  mPostTransactionQueries = postTransactionQueries;
}

void DesignTimeTransactionalInstall2::type_check()
{
  // We expect a fixed record format on control input.
//   const RecordMetadata * controlMetadata(mInputPorts[L"control"]->GetMetadata());
//   if (!controlMetadata->HasColumn(L"id_commit_unit") ||
//       PhysicalFieldType::Integer() != *controlMetadata->GetColumn(L"id_commit_unit")->GetPhysicalFieldType())
//   {
//     throw MissingFieldException(*this, *mInputPorts[L"control"], L"id_commit_unit");
//   }
  
//   for(std::size_t i = 1; i<mInputPorts.size(); i++)
//   {
//     std::wstring fieldName((boost::wformat(L"size_%1%") % (i-1)).str());
//     if (!controlMetadata->HasColumn(fieldName) ||
//         PhysicalFieldType::Integer() != *controlMetadata->GetColumn(fieldName)->GetPhysicalFieldType())
//     {
//       throw MissingFieldException(*this, *mInputPorts[L"control"], fieldName);
//     }
//   }
//   // We expect that there is a table name column and schema on all table inputs.
//   for(PortCollection::iterator it = mInputPorts.begin()+1;
  for(PortCollection::iterator it = mInputPorts.begin();
      it != mInputPorts.end();
      ++it)
  {
    if (!(*it)->GetMetadata()->HasColumn(L"id_commit_unit") ||
        PhysicalFieldType::Integer() != *(*it)->GetMetadata()->GetColumn(L"id_commit_unit")->GetPhysicalFieldType())
    {
      throw MissingFieldException(*this, **it, L"id_commit_unit");
    }
    if (!(*it)->GetMetadata()->HasColumn(L"table") ||
        PhysicalFieldType::StringDomain() != *(*it)->GetMetadata()->GetColumn(L"table")->GetPhysicalFieldType())
    {
      throw MissingFieldException(*this, **it, L"table");
    }
    if (!(*it)->GetMetadata()->HasColumn(L"schema") ||
        PhysicalFieldType::StringDomain() != *(*it)->GetMetadata()->GetColumn(L"schema")->GetPhysicalFieldType())
    {
      throw MissingFieldException(*this, **it, L"schema");
    }
    if (!(*it)->GetMetadata()->HasColumn(L"targetSchema") ||
        PhysicalFieldType::StringDomain() != *(*it)->GetMetadata()->GetColumn(L"targetSchema")->GetPhysicalFieldType())
    {
      throw MissingFieldException(*this, **it, L"targetSchema");
    }
    if (!(*it)->GetMetadata()->HasColumn(L"table1") ||
        PhysicalFieldType::StringDomain() != *(*it)->GetMetadata()->GetColumn(L"table1")->GetPhysicalFieldType())
    {
      throw MissingFieldException(*this, **it, L"table1");
    }
    if (!(*it)->GetMetadata()->HasColumn(L"schema1") ||
        PhysicalFieldType::StringDomain() != *(*it)->GetMetadata()->GetColumn(L"schema1")->GetPhysicalFieldType())
    {
      throw MissingFieldException(*this, **it, L"schema1");
    }
    if (!(*it)->GetMetadata()->HasColumn(L"targetSchema1") ||
        PhysicalFieldType::StringDomain() != *(*it)->GetMetadata()->GetColumn(L"targetSchema1")->GetPhysicalFieldType())
    {
      throw MissingFieldException(*this, **it, L"targetSchema1");
    }
  }
}

RunTimeOperator * DesignTimeTransactionalInstall2::code_generate(partition_t maxPartition)
{
  std::vector<const RecordMetadata*> metadata;
  for(PortCollection::iterator it = mInputPorts.begin();
      it != mInputPorts.end();
      ++it)
  {
    metadata.push_back((*it)->GetMetadata());
  }  
  return new RunTimeTransactionalInstall2(mName, 
                                         mPreTransactionQueries,
                                         mQueries,
                                         mPostTransactionQueries,
                                         metadata);
}

RunTimeTransactionalInstall2::RunTimeTransactionalInstall2()
{
}

RunTimeTransactionalInstall2::RunTimeTransactionalInstall2(const std::wstring& name, 
                                                         const std::vector<std::vector<std::wstring> >& preTransactionQueries,
                                                         const std::vector<std::vector<std::wstring> >& queries,
                                                         const std::vector<std::vector<std::wstring> >& postTransactionQueries,
                                                         const std::vector<const RecordMetadata*>& metadata)
  :
  RunTimeOperator(name),
  mUntransformedPreTransactionQueries(preTransactionQueries),
  mUntransformedQueries(queries),
  mUntransformedPostTransactionQueries(postTransactionQueries)
{
  for(std::vector<const RecordMetadata*>::const_iterator it = metadata.begin();
      it != metadata.end();
      it++)
  {
    mMetadata.push_back(**it);
  }
}

RunTimeTransactionalInstall2::~RunTimeTransactionalInstall2()
{
}

RunTimeOperatorActivation * RunTimeTransactionalInstall2::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeTransactionalInstall2Activation(reactor, partition, this);
}

RunTimeTransactionalInstall2Activation::RunTimeTransactionalInstall2Activation(Reactor * reactor, 
                                                                             partition_t partition, 
                                                                             const RunTimeTransactionalInstall2 * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeTransactionalInstall2>(reactor, partition, runTimeOperator),
  mState(START),
  mInputMessage(NULL),
  mPriorityAccessor(NULL),
  mWorkQueue(NULL)
{
}

RunTimeTransactionalInstall2Activation::~RunTimeTransactionalInstall2Activation()
{
  // Make sure to shut down worker threads.
  if (NULL != mWorkQueue)
  {
    mWorkQueue->Shutdown();
    for(std::vector<boost::shared_ptr<boost::thread> >::iterator it = mThreadPool.begin();
        it != mThreadPool.end();
        ++it)
    {
      (*it)->join();
    }

    delete mWorkQueue;
    mWorkQueue = NULL;
  }
}

std::wstring RunTimeTransactionalInstall2Activation::TransformQuery(const std::wstring& query)
{
  return query;
}

std::wstring RunTimeTransactionalInstall2Activation::TransformQuery(const std::wstring& query,
                                                                    const std::wstring& table,
                                                                    const std::wstring& schema,
                                                                    const std::wstring& targetSchema)
{
  std::string utf8Query;
  ::WideStringToUTF8(query, utf8Query);
  std::string utf8Table;
  ::WideStringToUTF8(table, utf8Table);
  std::string utf8Schema;
  ::WideStringToUTF8(schema, utf8Schema);
  std::string utf8TargetSchema;
  ::WideStringToUTF8(targetSchema, utf8TargetSchema);
  boost::regex expr1("%%%NETMETERSTAGE_PREFIX%%%");
  boost::regex expr2("%%%PARTITION_PREFIX%%%");
  boost::regex expr3("%1%");
  utf8Schema += "..";
  utf8TargetSchema += "..";

  std::ostringstream ostr1;
  std::ostringstream ostr2;
  std::ostringstream ostr3;
  std::ostream_iterator<char,char> oit1(ostr1);
  std::ostream_iterator<char,char> oit2(ostr2);
  std::ostream_iterator<char,char> oit3(ostr3);
  boost::regex_replace(oit1, utf8Query.begin(), utf8Query.end(), expr1, 
                       utf8Schema, 
                       boost::match_default | boost::format_all);
  std::string tmp(ostr1.str());
  boost::regex_replace(oit2, tmp.begin(), tmp.end(), expr2, 
                       utf8TargetSchema, 
                       boost::match_default | boost::format_all); 
  tmp = ostr2.str();
  boost::regex_replace(oit3, tmp.begin(), tmp.end(), expr3, 
                       utf8Table, 
                       boost::match_default | boost::format_all); 

  std::wstring ucs2Query;
  ::ASCIIToWide(ucs2Query, ostr3.str()); 
  return ucs2Query;
}

void RunTimeTransactionalInstall2Activation::Start()
{
  // We now know what partition, staging database etc. we have, so we can resolve any
  // partition specific parameters at this point.
  for(std::vector<std::vector<std::wstring> >::const_iterator outerIt = mOperator->mUntransformedPreTransactionQueries.begin();
      outerIt != mOperator->mUntransformedPreTransactionQueries.end();
      ++outerIt)
  {
    mPreTransactionQueries.push_back(std::vector<std::wstring>());
    for(std::vector<std::wstring>::const_iterator innerIt = outerIt->begin();
        innerIt != outerIt->end();
        ++innerIt)
    {
      mPreTransactionQueries.back().push_back(TransformQuery(*innerIt));
    }
  }
  for(std::vector<std::vector<std::wstring> >::const_iterator outerIt = mOperator->mUntransformedQueries.begin();
      outerIt != mOperator->mUntransformedQueries.end();
      ++outerIt)
  {
    mQueries.push_back(std::vector<std::wstring>());
    for(std::vector<std::wstring>::const_iterator innerIt = outerIt->begin();
        innerIt != outerIt->end();
        ++innerIt)
    {
      mQueries.back().push_back(TransformQuery(*innerIt));
    }
  }
  for(std::vector<std::vector<std::wstring> >::const_iterator outerIt = mOperator->mUntransformedPostTransactionQueries.begin();
      outerIt != mOperator->mUntransformedPostTransactionQueries.end();
      ++outerIt)
  {
    mPostTransactionQueries.push_back(std::vector<std::wstring>());
    for(std::vector<std::wstring>::const_iterator innerIt = outerIt->begin();
        innerIt != outerIt->end();
        ++innerIt)
    {
      mPostTransactionQueries.back().push_back(TransformQuery(*innerIt));
    }
  }

  // Create accessors.
  ASSERT(mInputs.size() == 1);
//   for(std::size_t i = 0; i<mInputs.size(); i++)
//   {
    mPriorityAccessor = mOperator->mMetadata[0].GetColumn(L"id_commit_unit");
    mTableAccessors.push_back(mOperator->mMetadata[0].GetColumn(L"table"));
    mSchemaAccessors.push_back(mOperator->mMetadata[0].GetColumn(L"schema"));
    mTargetSchemaAccessors.push_back(mOperator->mMetadata[0].GetColumn(L"targetschema"));
    mTableAccessors.push_back(mOperator->mMetadata[0].GetColumn(L"table1"));
    mSchemaAccessors.push_back(mOperator->mMetadata[0].GetColumn(L"schema1"));
    mTargetSchemaAccessors.push_back(mOperator->mMetadata[0].GetColumn(L"targetschema1"));
//   }

  // Create the work queue.
  mWorkQueue = new InstallerWorkQueue2();
  // Spin up thread pool.
  boost::function0<void> threadFunc = boost::bind(&InstallerWorkQueue2::Run, boost::ref(*mWorkQueue));

  for(int i=0; i<48*4; i++)
  {
    mThreadPool.push_back(boost::shared_ptr<boost::thread>(new boost::thread(threadFunc)));
  }
//   mThreadPool.push_back(boost::shared_ptr<boost::thread>(new boost::thread(threadFunc)));
//   mThreadPool.push_back(boost::shared_ptr<boost::thread>(new boost::thread(threadFunc)));
//   mThreadPool.push_back(boost::shared_ptr<boost::thread>(new boost::thread(threadFunc)));

//   mLogger = MetraFlowLoggerManager::GetLogger((boost::format("[RunTimeTransactionalInstaller(%1%)]") % 
//                                                std::size_t(mInstaller.get())).str());

  mState = START;
  HandleEvent(NULL);
}

void RunTimeTransactionalInstall2Activation::StartTransaction(boost::int32_t txnId, const std::wstring& tag)
{
  mInstaller = boost::shared_ptr<RunTimeTransactionalInstaller>(new RunTimeTransactionalInstaller(txnId, tag));  
}

void RunTimeTransactionalInstall2Activation::EnqueuePreTransaction(boost::int32_t txnId, const std::wstring& query)
{
  mInstaller->EnqueuePreTransaction(query);
}

void RunTimeTransactionalInstall2Activation::EnqueueTransaction(boost::int32_t txnId, const std::wstring& query)
{
  mInstaller->EnqueueTransaction(query);
}

void RunTimeTransactionalInstall2Activation::EnqueuePostTransaction(boost::int32_t txnId, const std::wstring& query)
{
  mInstaller->EnqueuePostTransaction(query);
}

void RunTimeTransactionalInstall2Activation::CompleteTransaction(boost::int32_t txnId)
{
  std::size_t sz;
  mWorkQueue->Enqueue(mInstaller, sz);
  mInstaller = boost::shared_ptr<RunTimeTransactionalInstaller>();

//   mLogger->logInfo((boost::format("Transaction work queue size = %1") % sz).str());
}

void RunTimeTransactionalInstall2Activation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    while(true)
    {
      // Read the control port to see what we have to do next.
      RequestRead(0);
      mState = READ_0;
      return;
    case READ_0:
      Read(mInputMessage, ep);
      if (!mOperator->mMetadata[0].IsEOF(mInputMessage))
      {
        // This control message identifies a transaction.  Create the connection
        // for the transaction.
        StartTransaction(mPriorityAccessor->GetLongValue(mInputMessage),
                         mTargetSchemaAccessors[0]->GetStringValue(mInputMessage));

        // Execute Queries for this input binding to the table parameter.
        {
          for(int i=0; i<2; i++)
          {
            for(mQueryIterator=mPreTransactionQueries[i].begin();
                mQueryIterator!=mPreTransactionQueries[i].end();
                ++mQueryIterator)
            {
              EnqueuePreTransaction(-1,
                                    TransformQuery(*mQueryIterator,
                                                   mTableAccessors[i]->GetStringValue(mInputMessage),
                                                   mSchemaAccessors[i]->GetStringValue(mInputMessage),
                                                   mTargetSchemaAccessors[i]->GetStringValue(mInputMessage)));
            }
            for(mQueryIterator=mQueries[i].begin();
                mQueryIterator!=mQueries[i].end();
                ++mQueryIterator)
            {
              EnqueueTransaction(-1,
                                 TransformQuery(*mQueryIterator,
                                                mTableAccessors[i]->GetStringValue(mInputMessage),
                                                mSchemaAccessors[i]->GetStringValue(mInputMessage),
                                                mTargetSchemaAccessors[i]->GetStringValue(mInputMessage)));
            }
            for(mQueryIterator=mPostTransactionQueries[i].begin();
                mQueryIterator!=mPostTransactionQueries[i].end();
                ++mQueryIterator)
            {
              EnqueuePostTransaction(-1,
                                     TransformQuery(*mQueryIterator,
                                                    mTableAccessors[i]->GetStringValue(mInputMessage),
                                                    mSchemaAccessors[i]->GetStringValue(mInputMessage),
                                                    mTargetSchemaAccessors[i]->GetStringValue(mInputMessage)));
            }
          }
        }
        // Signal that there is no more work in the transaction.
        CompleteTransaction(-1);

        mOperator->mMetadata[0].Free(mInputMessage);
      }
      else
      {
        mWorkQueue->Shutdown();

        mOperator->mMetadata[0].Free(mInputMessage);
//         {
//           // Shut down worker threads.
//           for(std::vector<boost::shared_ptr<boost::thread> >::iterator it = mThreadPool.begin();
//               it != mThreadPool.end();
//               ++it)
//           {
//             (*it)->join();
//           }
//           delete mWorkQueue;
//           mWorkQueue = NULL;
//         }
        return;
      }
    }
  }
}

void RunTimeTransactionalInstall2Activation::Complete()
{
  // Make sure to shut down worker threads.
  if (NULL != mWorkQueue)
  {
    mWorkQueue->Shutdown();
    for(std::vector<boost::shared_ptr<boost::thread> >::iterator it = mThreadPool.begin();
        it != mThreadPool.end();
        ++it)
    {
      (*it)->join();
    }

    // Check for any errors on the work queue
    std::string err = mWorkQueue->GetError();
    delete mWorkQueue;
    mWorkQueue = NULL;

    if (err.size() > 0)
      throw std::runtime_error(err);
  }
}

// explicit instantiation - so all the impl doesn't have to be in the header
template class RunTimeDatabaseInsert<COdbcPreparedArrayStatement>;
template class RunTimeDatabaseInsert<COdbcPreparedBcpStatement>;
template class RunTimeDatabaseInsertActivation<COdbcPreparedArrayStatement>;
template class RunTimeDatabaseInsertActivation<COdbcPreparedBcpStatement>;
