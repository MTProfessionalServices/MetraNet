/**************************************************************************
 * @doc RSIDLOOKUP
 *
 * @module |
 *
 *
 * Copyright 2003 by MetraTech Corporation
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
 *
 * @index | RSIDLOOKUP
 ***************************************************************************/

#ifndef _RSIDLOOKUP_H
#define _RSIDLOOKUP_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#include <RateLookup.h>

#include <OdbcException.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcResultSet.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcConnMan.h>
#include <OdbcResourceManager.h>

#include <txdtc.h>  // distributed transaction support

typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;

_COM_SMARTPTR_TYPEDEF(ITransaction, IID_ITransaction);

// this class abstracts the database details from the rating code.
class RSIDLookup
{
public:
	RSIDLookup();
	~RSIDLookup();

	void Initialize(MTPipelineLib::IMTLogPtr logger, bool resolveSub, const std::string& tagName);
	void Shutdown();

	void InsertRequest(int requestID, int accountID, int cycleID,
										 int defaultPL, time_t timestamp,
										 int piTemplateID, int subID);

	template <class T>
	void InsertRequest(T statement, int requestID, int accountID, int cycleID,
											int defaultPL, time_t timestamp,
											int piTemplateID, int subID);
	void ExecuteBatch();

	//void CommitTransaction();
	void JoinTransaction(ITransactionPtr txn);
	void LeaveTransaction();
	void ExecuteQuery();

	bool RetrieveResultRow(ScoredRateInputs & results, int & requestID);

	void ClearResults();

	void TruncateTempTable();

	bool IsOracle() const
	{ return mIsOracle; }

private:
  MTAutoSingleton<COdbcResourceManager> mOdbcManager;
  boost::shared_ptr<COdbcConnectionHandle> mConnectionHandle;
  boost::shared_ptr<COdbcConnectionHandle> mStageConnectionHandle;

	boost::shared_ptr<COdbcConnectionCommand> mConnectionCommand;
	boost::shared_ptr<COdbcConnectionCommand> mStageConnectionCommand;

	boost::shared_ptr<COdbcPreparedInsertStatementCommand> mOracleArrayInsertToTempTableCommand;
	boost::shared_ptr<COdbcPreparedArrayStatementCommand> mSqlArrayInsertToTempTableCommand;
	boost::shared_ptr<COdbcPreparedBcpStatementCommand> mBcpInsertToTempTableCommand;
	boost::shared_ptr<COdbcPreparedArrayStatementCommand> mResolveRateSchedulesCommand;
	boost::shared_ptr<COdbcPreparedArrayStatementCommand> mLookupByIdQueryCommand;
	boost::shared_ptr<COdbcPreparedArrayStatementCommand> mLookupByNameQueryCommand;
	string mTempTableName;
	int mArraySize;
	bool mResolveSub;
	bool mIsOracle;
	bool mUseBcpFlag;

	COdbcPreparedResultSetPtr mResults;

	MTPipelineLib::IMTLogPtr mLogger;
};


#endif /* _RSIDLOOKUP_H */
