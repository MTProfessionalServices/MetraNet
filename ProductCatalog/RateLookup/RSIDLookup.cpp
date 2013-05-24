/**************************************************************************
 * RSIDLOOKUP
 *
 * Copyright 1997-2003 by MetraTech Corp.
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <MTSessionBaseDef.h>
#include <RSIDLookup.h>
#include <mtprogids.h>
#include <stdutils.h>
#include <mttime.h>
#include <math.h>
#include <formatdbvalue.h>

#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.DataAccess.tlb> inject_statement("using namespace mscorlib;")

RSIDLookup::RSIDLookup()
{

}

RSIDLookup::~RSIDLookup()
{
	Shutdown();
}

void RSIDLookup::Initialize(MTPipelineLib::IMTLogPtr logger, bool resolveSub, const std::string& tagName)
{
	mLogger = logger;

	mResolveSub = resolveSub;

	// Setup connections.
	COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
	COdbcConnectionInfo stageInfo = COdbcConnectionManager::GetConnectionInfo("NetMeterStage");
	boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(info));

	// Is this Oracle?
	mIsOracle = (info.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);

	mArraySize = 1000;
	mUseBcpFlag = IsOracle() ? FALSE : TRUE;

	// Prepare temp table name.
	string baseTempTableName = "t_arg_getrateschedules_";
  baseTempTableName += tagName;

  MetraTech_DataAccess::IDBNameHashPtr nameHash(__uuidof(MetraTech_DataAccess::DBNameHash));
  baseTempTableName = (const char *) nameHash->GetDBNameHash(_bstr_t(baseTempTableName.c_str()));

	mTempTableName = stageInfo.GetCatalog().c_str();
	mTempTableName += IsOracle() ? "." : "..";
	mTempTableName += baseTempTableName;

	// auto commit must be true to join the pipeline txn
	conn->SetAutoCommit(true);

	// Note that the argument table has a slot for id_acc and id_sub; if we are
	// resolving subscriptions, then id_acc will be used otherwise id_sub will be used.
	// Need to execute this against the Netmeter schema.
	MTPRODUCTCATALOGLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init("Queries\\ProductCatalog");
	rowset->SetQueryTag("__CREATE_TMP_GETRATESSCHEDULES_TABLE__");
	rowset->AddParam("%%TABLE_NAME%%", mTempTableName.c_str());
	if (!IsOracle())
	{
		string tempIndexName = "idx_t_arg_getrateschedules";
		rowset->AddParam("%%INDEX_NAME%%", tempIndexName.c_str());
	}
	
	string queryString = rowset->GetQueryString();
	COdbcStatementPtr createTempTable = conn->CreateStatement();
	createTempTable->ExecuteUpdate(queryString.c_str());
	conn->CommitTransaction();

  std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > bcpCommands;
  std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > arrayCommands;
  std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > insertCommands;

  std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > bcpStagingCommands;
  std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > arrayStagingCommands;
  std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > insertStagingCommands;
	// Change the schema to point to Netmeter stage.
	if (mUseBcpFlag)
	{
		COdbcBcpHints hints;
		// use minimally logged inserts.
		// TODO: this may only matter if database recovery model settings are correct.
		//       however, it won't hurt if they're not
		hints.SetMinimallyLogged(true);
		mBcpInsertToTempTableCommand = boost::shared_ptr<COdbcPreparedBcpStatementCommand>(new COdbcPreparedBcpStatementCommand(mTempTableName, hints));
    bcpCommands.push_back(mBcpInsertToTempTableCommand);
	}
	else
	{
		if (IsOracle())
    {
			mOracleArrayInsertToTempTableCommand = boost::shared_ptr<COdbcPreparedInsertStatementCommand>(
        new COdbcPreparedInsertStatementCommand(baseTempTableName, mArraySize, true));
      insertStagingCommands.push_back(mOracleArrayInsertToTempTableCommand);
    }
    else
    {
			mSqlArrayInsertToTempTableCommand = boost::shared_ptr<COdbcPreparedArrayStatementCommand>(
        new COdbcPreparedArrayStatementCommand(
          "insert into " + mTempTableName +
          " (id_request, id_acc, acc_cycle_id, default_pl, RecordDate, id_pi_template, id_sub) "
          "values (?, ?, ?, ?, ?, ?, ?)", 
          mArraySize,
          true));
      arrayCommands.push_back(mSqlArrayInsertToTempTableCommand);
    }
	}

  // pre-specify result set
  COdbcResultSetType resolveRSResults[] =
    {
      {eInteger, 256},		//rs.id_sched,  
      {eDatetime, 256}, 	//rs.dt_mod as dt_modified,  
      {eInteger, 256},		//rs.id_paramtable,  
      {eInteger, 256},		//rs.id_pricelist,  
      {eInteger, 256},		//rs.id_sub,  
      {eInteger, 256},		//rs.id_po,  
      {eInteger, 256},		//rs.id_pi_instance,  
      {eInteger, 256},		//arg.id_request, 
      {eInteger, 256},  	//rs.rs_begintype,
      {eInteger, 256},		//rs.rs_beginoffset,
      {eDatetime, 256}, 	//rs.rs_beginbase,
      {eInteger, 256},		//rs.rs_endtype,
      {eInteger, 256},		//rs.rs_endoffset,
      {eDatetime, 256},		//rs.rs_endbase,
      {eDatetime, 256},		//sub.vt_start as vt_sub_start,
      {eInteger, 256},		//arg.acc_cycle_id,
      {eDatetime, 256}		//arg.RecordDate 
    };

	// Use array size of 1 since this guy has no parameters
	// don't bind the parameters, automatically.
	if(mResolveSub)
	{
		rowset->SetQueryTag("__RESOLVE_RATE_SCHEDULES__");
		rowset->AddParam("%%TABLE_NAME%%", mTempTableName.c_str());
		_bstr_t queryString = rowset->GetQueryString();
    if (IsOracle())
    {
      mResolveRateSchedulesCommand = boost::shared_ptr<COdbcPreparedArrayStatementCommand>(
        new COdbcPreparedArrayStatementCommand((const char *) queryString, 
                                               1, 
                                               true, 
                                               resolveRSResults, 
                                               sizeof(resolveRSResults) / sizeof(resolveRSResults[0])));
    }
    else
    {
      mResolveRateSchedulesCommand = boost::shared_ptr<COdbcPreparedArrayStatementCommand>(
        new COdbcPreparedArrayStatementCommand((const char *) 
                                               queryString, 
                                               1, true));
    }
    arrayCommands.push_back(mResolveRateSchedulesCommand);
	}
	else
	{
		rowset->SetQueryTag("__RESOLVE_RATE_SCHEDULES_KNOWN_SUB__");
		rowset->AddParam("%%TABLE_NAME%%", mTempTableName.c_str());
		_bstr_t queryString = rowset->GetQueryString();
    if (IsOracle())
    {
      mResolveRateSchedulesCommand = boost::shared_ptr<COdbcPreparedArrayStatementCommand>(
        new COdbcPreparedArrayStatementCommand((const char *) queryString, 
                                               1, 
                                               true, 
                                               resolveRSResults, 
                                               sizeof(resolveRSResults) / sizeof(resolveRSResults[0])));
    }
    else
    {
      mResolveRateSchedulesCommand = boost::shared_ptr<COdbcPreparedArrayStatementCommand>(
        new COdbcPreparedArrayStatementCommand((const char *) queryString, 
                                               1, 
                                               true));
    }
    arrayCommands.push_back(mResolveRateSchedulesCommand);
	}

  mConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(
    new COdbcConnectionCommand(info,
                               COdbcConnectionCommand::TXN_AUTO,
                               true,
                               bcpCommands,
                               arrayCommands,
                               insertCommands));
  mOdbcManager->RegisterResourceTree(mConnectionCommand);

  if (IsOracle())
  {
    mStageConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(
      new COdbcConnectionCommand(stageInfo,
                                 COdbcConnectionCommand::TXN_AUTO,
                                 false,
                                 bcpStagingCommands,
                                 arrayStagingCommands,
                                 insertStagingCommands));
    mOdbcManager->RegisterResourceTree(mStageConnectionCommand);
  }
}

void RSIDLookup::JoinTransaction(ITransactionPtr txn)
{
	(*mConnectionHandle)->JoinTransaction(txn);
}

void RSIDLookup::LeaveTransaction()
{
	(*mConnectionHandle)->LeaveTransaction();
}

void RSIDLookup::InsertRequest(int requestID, int accountID, int cycleID,
															 int defaultPL, time_t timestamp,
															 int piTemplateID, int subID)
{
  if (!mConnectionHandle)
    mConnectionHandle = boost::shared_ptr<COdbcConnectionHandle>(
      new COdbcConnectionHandle(mOdbcManager, mConnectionCommand));
  if (IsOracle() && !mStageConnectionHandle)
    mStageConnectionHandle = boost::shared_ptr<COdbcConnectionHandle>(
      new COdbcConnectionHandle(mOdbcManager, mStageConnectionCommand));

	if (mUseBcpFlag)
		InsertRequest((*mConnectionHandle)[mBcpInsertToTempTableCommand], requestID, accountID, cycleID,
									defaultPL, timestamp, piTemplateID, subID);
	else
	{
    COdbcPreparedArrayStatement * stmt = 
      IsOracle() ? 
      (*mStageConnectionHandle)[mOracleArrayInsertToTempTableCommand] : 
      (*mConnectionHandle)[mSqlArrayInsertToTempTableCommand];
		// Will this batch exceed array size, if yes then execute work already done.
		if (stmt->GetCurrentArrayPos() + 1 > stmt->GetArraySize())
		{
			stmt->ExecuteBatch();
		}

		InsertRequest(stmt, requestID, accountID, cycleID,
									defaultPL, timestamp, piTemplateID, subID);
	}
}

template<class T>
void RSIDLookup::InsertRequest(T arStatement,
															 int requestID, int accountID, int cycleID,
															 int defaultPL, time_t timestamp,
															 int piTemplateID, int subID)
{
	TIMESTAMP_STRUCT odbcTimestamp;
//	::OLEDateToOdbcTimestamp(&timestamp, &odbcTimestamp);
	::TimetToOdbcTimestamp(&timestamp, &odbcTimestamp);

	arStatement->SetInteger(1, (long) requestID);
	arStatement->SetInteger(2, (long) accountID);
	arStatement->SetInteger(3, (long) cycleID);
	if (defaultPL != -1)
		arStatement->SetInteger(4, (long) defaultPL);
	arStatement->SetDatetime(5, odbcTimestamp);
	arStatement->SetInteger(6, (long) piTemplateID);
	arStatement->SetInteger(7, (long) subID);


	if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
	{
		wchar_t buffer[1024];
		const wchar_t * timeStr = _wctime(&timestamp);

		if(mResolveSub)
		{
			swprintf(buffer, L"Selecting Rate Schedule: id_acc = %d; "
							 L"id_cycle = %d; id_pricelist = %d; timestamp = %s; "
							 L"id_pi_template = %d; request_id = %d",
							 accountID, cycleID, defaultPL, timeStr, piTemplateID, requestID);
		}
		else
		{
			swprintf(buffer, L"Selecting Rate Schedule: id_sub = %d; "
							 L"id_cycle = %d; id_pricelist = %d; timestamp = %s; "
							 L"id_pi_template = %d; request_id = %d",
							 subID, cycleID, defaultPL, timeStr, piTemplateID, requestID);
		}
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
	}


	arStatement->AddBatch();
}


void RSIDLookup::ExecuteBatch()
{
	if (mUseBcpFlag)
	{
		(*mConnectionHandle)[mBcpInsertToTempTableCommand]->ExecuteBatch();
		(*mConnectionHandle)->CommitTransaction();
	}
	else if (IsOracle())
	{
		(*mStageConnectionHandle)[mOracleArrayInsertToTempTableCommand]->ExecuteBatch();
		(*mStageConnectionHandle)->CommitTransaction();
	}
  else
	{
    (*mConnectionHandle)[mSqlArrayInsertToTempTableCommand]->ExecuteBatch();
	(*mConnectionHandle)->CommitTransaction();
}
}

void RSIDLookup::ExecuteQuery()
{
	mResults = (*mConnectionHandle)[mResolveRateSchedulesCommand]->ExecuteQuery();
}

bool RSIDLookup::RetrieveResultRow(ScoredRateInputs & results, int & requestId)
{
	results.Clear();
again:
	if (!mResults->Next())
		return false;

	long sched, pt, sub, po;
	//long pl;
	__int64 score;

	pt = mResults->GetInteger(3);
	ASSERT(!mResults->WasNull());

	sub = mResults->GetInteger(5);
	if (mResults->WasNull()) sub = -1;

	po = mResults->GetInteger(6);
	if (mResults->WasNull()) po = -1;

	requestId = mResults->GetInteger(8);
	ASSERT(!mResults->WasNull());
  //BP Assert below is pretty bogus - requestID will easily be
  //greater than mArraySize, because requests also include children PIs
	//ASSERT(requestId >= 0 && requestId < mArraySize);

	//TODO: figure out how to handle 64 bit ints on SQL server (BCP)

  // Calculate the effective start and end date for the rate schedule
  DATE minDate = (DATE) ::getMinMTOLETime();
  DATE effectiveRSStart;
  DATE effectiveRSEnd;
  int beginDateType;
  beginDateType = mResults->GetInteger(9);

  switch(beginDateType)
  {
  case 1:
  {
    COdbcTimestamp beginDateBase;
    beginDateBase = mResults->GetTimestamp(11);
    if (mResults->WasNull())
    {
      effectiveRSStart = minDate;
    }
    else
    {
      ::OdbcTimestampToOLEDate(beginDateBase.GetBuffer(), &effectiveRSStart);
    }
    break;
  }
  case 2:
  {
    int beginDateOffset;
    beginDateOffset = mResults->GetInteger(10);
    COdbcTimestamp subscriptionStart;
    subscriptionStart = mResults->GetTimestamp(15);
    if (mResults->WasNull())
    {
      effectiveRSStart = minDate;
    }
    else
    {
      ::OdbcTimestampToOLEDate(subscriptionStart.GetBuffer(), &effectiveRSStart);
    }
    // Add number of days to date.  We'll be OK if we simply add numbers 
    // (the integer part of OLE is a number of days)
    effectiveRSStart += (DATE) beginDateOffset;
    break;
  }
  case 3:
  {
    int usageCycleID;
    usageCycleID = mResults->GetInteger(16);
    COdbcTimestamp beginDateBase = mResults->GetTimestamp(11);

    // Get the start of the next interval
    ROWSETLib::IMTSQLRowsetPtr pRowset(MTPROGID_SQLROWSET);
    pRowset->Init(L"\\Queries\\ProductCatalog");
    pRowset->SetQueryTag(L"__GET_NEXT_USAGE_INTERVAL_BEGIN_DATE__");
    pRowset->AddParam(L"%%ID_USAGE_CYCLE%%", usageCycleID);

    wstring datestr;
    ::OdbcTimestampToOLEDate(beginDateBase.GetBuffer(), &effectiveRSStart);
    FormatValueForDB(_variant_t(effectiveRSStart, VT_DATE), false, datestr);
    pRowset->AddParam(L"%%DT_EFF%%", datestr.c_str(), true) ;

    pRowset->Execute();
    effectiveRSStart = pRowset->GetValue("dt_start");
    break;
  }
  default:
  {
    effectiveRSStart = minDate;
  }
  }

  int endDateType;
  endDateType = mResults->GetInteger(12);

  switch(endDateType)
  {
  case 1:
  {
    COdbcTimestamp endDateBase;
    endDateBase = mResults->GetTimestamp(14);
    if (mResults->WasNull())
    {
      effectiveRSEnd = (DATE) ::GetMaxMTOLETime();
    }
    else
    {
      ::OdbcTimestampToOLEDate(endDateBase.GetBuffer(), &effectiveRSEnd);
    }
    break;
  }
  case 2:
  {
    int endDateOffset;
    endDateOffset = mResults->GetInteger(13);
    COdbcTimestamp subscriptionStart;
    subscriptionStart = mResults->GetTimestamp(15);
    if (mResults->WasNull())
    {
      effectiveRSEnd = minDate;
    }
    else
    {
      ::OdbcTimestampToOLEDate(subscriptionStart.GetBuffer(), &effectiveRSEnd);
    }
    // Add number of days to date.  We'll be OK if we simply add numbers 
    // (the integer part of OLE is a number of days).  Then take the end of the
    // day.  For floating point rounding reasons, this is computed by rounding 
    // down to current day adding one and then substracting one second.
    static const double SecondsInDay(24.0*60.0*60.0);
    effectiveRSEnd += (DATE) endDateOffset;
    effectiveRSEnd = floor(effectiveRSEnd) + 1.0 - 1.0/SecondsInDay;
    break;
  }
  case 3:
  {
    int usageCycleID;
    usageCycleID = mResults->GetInteger(16);
    COdbcTimestamp endDateBase = mResults->GetTimestamp(14);

    // Get the start of the next interval
    ROWSETLib::IMTSQLRowsetPtr pRowset(MTPROGID_SQLROWSET);
    pRowset->Init(L"\\Queries\\ProductCatalog");
    pRowset->SetQueryTag(L"__GET_CURRENT_USAGE_INTERVAL_END_DATE__");
    pRowset->AddParam(L"%%ID_USAGE_CYCLE%%", usageCycleID);

    wstring datestr;
    ::OdbcTimestampToOLEDate(endDateBase.GetBuffer(), &effectiveRSEnd);
    FormatValueForDB(_variant_t(effectiveRSEnd, VT_DATE), false, datestr);
    pRowset->AddParam(L"%%DT_EFF%%", datestr.c_str(), true);

    pRowset->Execute();
    effectiveRSEnd = pRowset->GetValue("dt_end");
    break;
  }
  default:
  {
    effectiveRSEnd = (DATE) ::GetMaxMTOLETime();
  }
  }

  // Apply the filter that requires RecordDate to be between
  // RSStart and RSEnd
  COdbcTimestamp recordDate;
  recordDate = mResults->GetTimestamp(17);
  DATE recordOLEDate;
  ::OdbcTimestampToOLEDate(recordDate.GetBuffer(), &recordOLEDate);
  if (recordOLEDate < effectiveRSStart || recordOLEDate > effectiveRSEnd) goto again;

  // Now calculate the score
  static const double secondsPerDay(60*60*24);
  int dateScore = (int) (floor((effectiveRSStart - minDate) * secondsPerDay)); 
  int typeScore = beginDateType == 2 ? 2 : (beginDateType == 4) ? 0 : 1;
  score = __int64(typeScore) << 32;
  score += dateScore;

	sched = mResults->GetInteger(1);
	ASSERT(!mResults->WasNull());

	COdbcTimestamp modified;
	time_t modifiedTimet = -1;
	modified = mResults->GetTimestamp(2);
	ASSERT(!mResults->WasNull());
	::OdbcTimestampToTimet(modified.GetBuffer(), &modifiedTimet);


	if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
	{
		wchar_t buffer[1024];
		swprintf(buffer, L"retrieved pt = %d, sub = %d, po = %d, "
						 L"request = %d, sched = %d, score = %llI64d",
						 pt, sub, po, requestId, sched, score);

		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
	}



//	pl = mResults->GetInteger(4);
//	ASSERT(!mResults->WasNull());

	// NOTE: mPI is not set here.  We assume the called will know the
	// PI 
//	results.mPI = ;
	results.mParamTableID = pt;

	if (sub == -1 && po == -1)
	{
		results.mDefaultAccountScheduleID = sched;
		results.mDefaultAccountScheduleModified = modifiedTimet;
		results.mDefaultAccountScheduleScore = score;
	}
	else if (sub == -1 && po != -1)
	{
		results.mPOScheduleID = sched;
		results.mPOScheduleModified = modifiedTimet;
		results.mPOScheduleScore = score;
	}
	else // sub != -1 && po == -1
	{
		results.mICBScheduleID = sched;
		results.mICBScheduleModified = modifiedTimet;
		results.mICBScheduleScore = score;
	}
	return true;
}

void RSIDLookup::ClearResults()
{
	mResults = 0;
  mConnectionHandle = boost::shared_ptr<COdbcConnectionHandle>();
  mStageConnectionHandle = boost::shared_ptr<COdbcConnectionHandle>();
}

void RSIDLookup::Shutdown()
{
  mOdbcManager->Reinitialize(mConnectionCommand);
  if (IsOracle())
    mOdbcManager->Reinitialize(mStageConnectionCommand);

  mConnectionHandle = boost::shared_ptr<COdbcConnectionHandle>();
  mStageConnectionHandle = boost::shared_ptr<COdbcConnectionHandle>();
}

void RSIDLookup::TruncateTempTable()
{
  if (!mConnectionHandle)
    mConnectionHandle = boost::shared_ptr<COdbcConnectionHandle>(
      new COdbcConnectionHandle(mOdbcManager, mConnectionCommand));

	MTPRODUCTCATALOGLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init("Queries\\ProductCatalog");
	rowset->SetQueryTag("__TRUNCATE_TMP_TABLE__");
	rowset->AddParam("%%TABLE_NAME%%", mTempTableName.c_str());

	string queryString = rowset->GetQueryString();
	COdbcStatementPtr truncate = (*mConnectionHandle)->CreateStatement();
	int numRows = truncate->ExecuteUpdate(queryString.c_str());
	(*mConnectionHandle)->CommitTransaction();
}
