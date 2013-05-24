#include <BatchQuery.h>

#include <RuntimeValue.h>

BatchQuery::BatchQuery(const string& create, const string& insert, const wstring& dml, const string& table, const vector<VarEntryPtr>& access, const vector<VarEntryPtr> & outputs)
{
  // Here we have the create table for the temp params and the query itself
  mDdl = create;
  mDml = dml;
  mInsert = insert;
  mTable = table;
  mParameterBindings = access;
  mResultBindings = outputs;
  //BP TODO:
  mArraySize = 1000;
    
  COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(info));
  mIsOracle = (info.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);

  // Using BCP so use auto commit
  conn->SetAutoCommit(true);

  COdbcStatementPtr createTempTable(conn->CreateStatement());
  createTempTable->ExecuteUpdate(mDdl);

  // Prepare the batch version of the query and validate the datatypes of the
  // columns in the result set.  Note that we do not do conversions.
  COdbcPreparedArrayStatementPtr query(conn->PrepareStatement(mDml));
  COdbcPreparedResultSetPtr rs(query->ExecuteQuery());
  if (rs->GetMetadata().size() != mResultBindings.size()+1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Size mismatch between SELECT list of batch query and number of variables in INTO list");
  for(unsigned int i=0; i<mResultBindings.size(); i++)
  {
    if(!Match(rs->GetMetadata()[i], mResultBindings[i]->getType())) 
    {
      rs->Close();
      throw MTSQLRuntimeErrorException("Type mismatch between MTSQL variable of type " + ToString(mResultBindings[i]->getType()) + " and resultset column '" + rs->GetMetadata()[i]->GetColumnName() + "' of type " + rs->GetMetadata()[i]->GetTypeName());
    }
  }
  rs->Close();


  std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > bcpCommands;
  std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > arrayCommands;
  std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > insertCommands;
  if(mIsOracle == false)
  {
    COdbcBcpHints hints;
    // use minimally logged inserts.
    // TODO: this may only matter if database recovery model settings are correct.
    //       however, it won't hurt if they're not
    hints.SetMinimallyLogged(true);
    mInsertStatementCommand = boost::shared_ptr<COdbcPreparedBcpStatementCommand>(new COdbcPreparedBcpStatementCommand(mTable, hints));
    bcpCommands.push_back(mInsertStatementCommand);
  }
  else
  {
    mOracleInsertStatementCommand = boost::shared_ptr<COdbcPreparedInsertStatementCommand>(new COdbcPreparedInsertStatementCommand(mTable, mArraySize, true));
    insertCommands.push_back(mOracleInsertStatementCommand);

    COdbcConnectionInfo stageinfo  = info;
    string stagecat = COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalog();
    stageinfo.SetCatalog(stagecat.c_str());
    stageinfo.SetUserName(stagecat.c_str());
    mStageConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(new COdbcConnectionCommand(stageinfo, 
                                                                                                   COdbcConnectionCommand::TXN_AUTO, 
                                                                                                   false,
                                                                                                   bcpCommands, 
                                                                                                   arrayCommands,
                                                                                                   insertCommands));
    insertCommands.clear();

    mOdbcManager->RegisterResourceTree(mStageConnectionCommand);
  }
  mConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(new COdbcConnectionCommand(COdbcConnectionManager::GetConnectionInfo("NetMeter"),
                                                                                            COdbcConnectionCommand::TXN_AUTO,
                                                                                            true,
                                                                                            bcpCommands,
                                                                                            arrayCommands,
                                                                                            insertCommands));

  mOdbcManager->RegisterResourceTree(mConnectionCommand);
}

BatchQuery::~BatchQuery()
{
}

bool BatchQuery::Match(const COdbcColumnMetadata * metadata, int mtsqlType)
{
  switch(mtsqlType)
  {
    case RuntimeValue::TYPE_INTEGER:
    {
      return metadata->GetDataType() == eInteger || 
        metadata->GetDataType() == eDecimal || 
        metadata->GetDataType() == eDouble;
    }
    case RuntimeValue::TYPE_DOUBLE:
    {
      return metadata->GetDataType() == eDouble || 
        metadata->GetDataType() == eDecimal;
    }
    case RuntimeValue::TYPE_STRING:
    {
      return metadata->GetDataType() == eString;
    }
    case RuntimeValue::TYPE_WSTRING:
    {
      return metadata->GetDataType() == eWideString;
    }
    case RuntimeValue::TYPE_DATETIME:
    {
      return metadata->GetDataType() == eDatetime;
    }
    case RuntimeValue::TYPE_DECIMAL:
    {
      return metadata->GetDataType() == eDecimal || 
        metadata->GetDataType() == eDouble;
    }
    case RuntimeValue::TYPE_BOOLEAN:
    {
      return metadata->GetDataType() == eString;
    }
    case RuntimeValue::TYPE_ENUM:
    {
      return metadata->GetDataType() == eInteger;
    }
    case RuntimeValue::TYPE_TIME:
    {
      return metadata->GetDataType() == eInteger;
    }
    default:
      throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type");
  }  
}

std::string BatchQuery::ToString(const COdbcColumnMetadata * metadata)
{
  return metadata->GetTypeName();
}

std::string BatchQuery::ToString(int mtsqlType)
{
  switch(mtsqlType)
  {
    case RuntimeValue::TYPE_INTEGER:
    {
      return "INTEGER";
      break;
    }
    case RuntimeValue::TYPE_DOUBLE:
    {
      return "DOUBLE PRECISION";
      break;
    }
    case RuntimeValue::TYPE_STRING:
    {
      return "VARCHAR";
      break;
    }
    case RuntimeValue::TYPE_WSTRING:
    {
      return "NVARCHAR";
      break;
    }
    case RuntimeValue::TYPE_DATETIME:
    {
      return "DATETIME";
      break;
    }
    case RuntimeValue::TYPE_DECIMAL:
    {
      return "DECIMAL";
      break;
    }
    case RuntimeValue::TYPE_BOOLEAN:
    {
      return "BOOLEAN";
      break;
    }
    case RuntimeValue::TYPE_ENUM:
    {
      return "ENUM";
      break;
    }
    case RuntimeValue::TYPE_TIME:
    {
      return "TIME";
      break;
    }
    default:
      throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type");
  }
}
template <class T>
void BatchQuery::BindParameters(T stmt, ActivationRecord * record, int requestid)
{
  for(int i=0; i<(int)mParameterBindings.size(); i++)
  {
    // TODO: Handle nulls
    // TODO: Handle all datatypes
    switch(mParameterBindings[i]->getType())
    {
    case RuntimeValue::TYPE_INTEGER:
    {
      RuntimeValue val;
      record->getLongValue(mParameterBindings[i]->getAccess().get(), &val);
      if(!val.isNullRaw())
      {
        stmt->SetInteger(i+1, val.getLong());
      }
      break;
    }
    case RuntimeValue::TYPE_DOUBLE:
    {
      RuntimeValue val;
      record->getDoubleValue(mParameterBindings[i]->getAccess().get(), &val);
      if(!val.isNullRaw())
      {
        stmt->SetDouble(i+1, val.getDouble());
      }
      break;
    }
    case RuntimeValue::TYPE_STRING:
    {
      RuntimeValue val;
      record->getStringValue(mParameterBindings[i]->getAccess().get(), &val);
      if(!val.isNullRaw())
      {
        stmt->SetString(i+1, val.getStringPtr());
      }
      break;
    }
    case RuntimeValue::TYPE_WSTRING:
    {
      RuntimeValue val;
      record->getWStringValue(mParameterBindings[i]->getAccess().get(), &val);
      if(!val.isNullRaw())
      {
        stmt->SetWideString(i+1, val.getWStringPtr());
      }
      break;
    }
    case RuntimeValue::TYPE_DATETIME:
    {
      RuntimeValue val;
      record->getDatetimeValue(mParameterBindings[i]->getAccess().get(), &val);
      if(!val.isNullRaw())
      {
        TIMESTAMP_STRUCT refTimeStamp;
        DATE pDate = val.getDatetime();
        OLEDateToOdbcTimestamp(&pDate,&refTimeStamp);      
        stmt->SetDatetime(i+1, refTimeStamp);
      }
      break;
    }
    case RuntimeValue::TYPE_DECIMAL:
    {
      RuntimeValue val;
      record->getDecimalValue(mParameterBindings[i]->getAccess().get(), &val);
      if(!val.isNullRaw())
      {
        SQL_NUMERIC_STRUCT refNumeric;
        DecimalToOdbcNumeric(val.getDecPtr(),&refNumeric);      
        stmt->SetDecimal(i+1, refNumeric);
      }
      break;
    }
    case RuntimeValue::TYPE_BOOLEAN:
    {
      RuntimeValue val;
      record->getBooleanValue(mParameterBindings[i]->getAccess().get(), &val);
      if(!val.isNullRaw())
      {
        // Convert BOOLEAN value to "1" or "0" when going to DB.
        stmt->SetString(i+1, val.getBool() ? "1" : "0");
      }
      break;
    }
    case RuntimeValue::TYPE_ENUM:
    {
      RuntimeValue val;
      record->getEnumValue(mParameterBindings[i]->getAccess().get(), &val);
      if(!val.isNullRaw())
      {
        // Convert ENUM value to long when going to DB.
        stmt->SetInteger(i+1, val.getLong());
      }
      break;
    }
    case RuntimeValue::TYPE_TIME:
    {
      RuntimeValue val;
      record->getTimeValue(mParameterBindings[i]->getAccess().get(), &val);
      if(!val.isNullRaw())
      {
        // Convert TIME value to long when going to DB.
        stmt->SetInteger(i+1, val.getLong());
      }
      break;
    }
    default:
      throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type");
    }
  }
  stmt->SetInteger(mParameterBindings.size()+1, requestid);

  stmt->AddBatch();
}

/*
COdbcResultSet * BatchQuery::ExecuteQueryInternal()
{
  mInsertStatement->ExecuteBatch();
    
  COdbcStatementPtr query = mConnection->CreateStatement();
  return query->ExecuteQueryW(mDml);
}
*/

void BatchQuery::ExecuteQuery(std::vector<ActivationRecord *>& activations, ITransaction * pTrans)
{
  COdbcConnectionHandle connection(mOdbcManager, mConnectionCommand);

  // First truncate the table of arguments.
  if(mIsOracle == false)
  {
    COdbcStatementPtr truncate(connection->CreateStatement());
    truncate->ExecuteUpdate(std::string("TRUNCATE TABLE ") + mTable);

    for(int i=0; i<(int)activations.size(); i++)
    {
      BindParameters(connection[mInsertStatementCommand], activations[i], i);
    }
     connection[mInsertStatementCommand]->ExecuteBatch();
  }
  else
  {
    COdbcConnectionHandle stageConnection(mOdbcManager, mStageConnectionCommand);
    COdbcStatementPtr truncate(stageConnection->CreateStatement());
    truncate->ExecuteUpdate(std::string("TRUNCATE TABLE ") + mTable);

    int numInBatch=0;
    for(int i=0; i<(int)activations.size(); i++)
    {
      BindParameters(stageConnection[mOracleInsertStatementCommand], activations[i], i);
      if (++numInBatch == mArraySize)
      {
        stageConnection[mOracleInsertStatementCommand]->ExecuteBatch();
        numInBatch = 0;
      }
    }
    if(numInBatch > 0)
    {
      stageConnection[mOracleInsertStatementCommand]->ExecuteBatch();
    }
  }

  // This is unnecessary when doing BCP (since we use AutoCommit) but it won't hurt.
  connection->CommitTransaction();

  // Now we are ready to execute the query, read the resultset and place session
  // properties into the activation record (i.e. sessions).
  // This activity should happen on the DTC transaction that was passed in.
  if(pTrans != NULL)
    connection->JoinTransaction(pTrans);

  COdbcPreparedArrayStatementPtr query(connection->PrepareStatement(mDml));
  COdbcPreparedResultSetPtr resultSet(query->ExecuteQuery());
  int count=0;
  while(resultSet->Next())
  {
    count++;
    int requestid = resultSet->GetInteger(mResultBindings.size()+1);
    for(int i=0; i<(int)mResultBindings.size(); i++)
    {
      switch(mResultBindings[i]->getType())
      {
      case RuntimeValue::TYPE_INTEGER:
      {
        int result = resultSet->GetInteger(i+1);
        if(!resultSet->WasNull())
        {
          activations[requestid]->setLongValue(mResultBindings[i]->getAccess().get(), &RuntimeValue::createLong(result));
        }
        break;
      }
      case RuntimeValue::TYPE_DOUBLE:
      {
        double result = resultSet->GetDouble(i+1);
        if(!resultSet->WasNull())
        {
          activations[requestid]->setDoubleValue(mResultBindings[i]->getAccess().get(), &RuntimeValue::createDouble(result));
        }
        break;
      }
      case RuntimeValue::TYPE_STRING:
      {
        std::string result = resultSet->GetString(i+1);
        if(!resultSet->WasNull())
        {
          activations[requestid]->setStringValue(mResultBindings[i]->getAccess().get(), &RuntimeValue::createString(result));
        }
        break;
      }
      case RuntimeValue::TYPE_WSTRING:
      {
        std::wstring result = resultSet->GetWideString(i+1);
        if(!resultSet->WasNull())
        {
          activations[requestid]->setWStringValue(mResultBindings[i]->getAccess().get(), &RuntimeValue::createWString(result));
        }
        break;
      }
      case RuntimeValue::TYPE_DATETIME:
      {
        COdbcTimestamp time = resultSet->GetTimestamp(i+1);
        if(!resultSet->WasNull())
        {
          DATE date;
          OdbcTimestampToOLEDate(time.GetBuffer(), &date);
          activations[requestid]->setDatetimeValue(mResultBindings[i]->getAccess().get(), &RuntimeValue::createDatetime(date));
        }
        break;
      }
      case RuntimeValue::TYPE_DECIMAL:
      {
        COdbcDecimal result = resultSet->GetDecimal(i+1);
        if(!resultSet->WasNull())
        {
          DECIMAL decimal;
          OdbcDecimalToDecimal(result, &decimal);
          activations[requestid]->setDecimalValue(mResultBindings[i]->getAccess().get(), &RuntimeValue::createDec(decimal));
        }
        break;
      }
      case RuntimeValue::TYPE_BOOLEAN:
      {
        std::string result = resultSet->GetString(i+1);
        if(!resultSet->WasNull())
        {
          activations[requestid]->setBooleanValue(mResultBindings[i]->getAccess().get(), &RuntimeValue::createBool(result==std::string("1") ? true : false));
        }
        break;
      }
      case RuntimeValue::TYPE_ENUM:
      {
        int result = resultSet->GetInteger(i+1);
        if(!resultSet->WasNull())
        {
          activations[requestid]->setEnumValue(mResultBindings[i]->getAccess().get(), &RuntimeValue::createEnum(result));
        }
        break;
      }
      case RuntimeValue::TYPE_TIME:
      {
        int result = resultSet->GetInteger(i+1);
        if(!resultSet->WasNull())
        {
          activations[requestid]->setTimeValue(mResultBindings[i]->getAccess().get(), &RuntimeValue::createTime(result));
        }
        break;
      }
      default:
        throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type");
      }
    }
  }

  // All cleaned up, leave the transaction.
  if(pTrans != NULL)
    connection->LeaveTransaction();
}


