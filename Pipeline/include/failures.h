/**************************************************************************
 * @doc FAILURES
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
 * @index | FAILURES
 ***************************************************************************/

#ifndef _FAILURES_H
#define _FAILURES_H

#include <metra.h>
#include <autoptr.h>
#include <NTLogger.h>
#include <NTThreadLock.h>
#include <sessionerr.h>
#include <OdbcConnection.h>
#include <OdbcBatchIDWriter.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcIdGenerator.h>

#include <map>
#include <string>

#import <MTPipelineLib.tlb> rename("EOF", "PipelineEOF")
_COM_SMARTPTR_TYPEDEF(ITransaction, __uuidof(ITransaction));
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcBatchIDWriter> COdbcBatchIDWriterPtr;
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;

#define MAX_FAILURE_ERROR_MESSAGE_SIZE 1024

class PipelineFailureWriter : public virtual ObjectWithError
{
private:
	// message logger
	NTLogger mLogger;
  BOOL mWriteErrorInitialized;
	COdbcIdGenerator* mGenerator;

  bool mIsDatabaseQueue;

  //Used to write errors to failed transaction table
	COdbcConnectionPtr  mConnection;
  
  //Used to write errors to the failed session state table.  Do I need another dedicated connection here?
  COdbcConnectionPtr mStateConnection;

  //controls whether we use bcp or not (so can be set to TRUE even if SQL Server :-)
  BOOL mIsOracle;

  COdbcBatchIDWriterPtr mBatchIDWriter;
	COdbcPreparedArrayStatementPtr mArrayInsertToFailureTable;
	COdbcPreparedBcpStatementPtr   mBcpInsertToFailureTable;

  COdbcPreparedArrayStatementPtr mArrayInsertToFailureSessionStateTable;
  COdbcPreparedBcpStatementPtr   mBcpInsertToFailureSessionStateTable;

	//COdbcIdGeneratorPtr mIdGenerator;
	string mStagingDBName;

  MTPipelineLib::IMTNameIDPtr mNameID;
	MTPipelineLib::IMTNameIDPtr GetNameID() const
	{ return mNameID; }

	MTPipelineLib::IMTSessionServerPtr mSessionServer;
  MTPipelineLib::IMTSessionServerPtr GetSessionServer() const
	{ return mSessionServer; }

protected:
	enum { UID_LENGTH = 16 };

	template <class T>
  BOOL WriteErrorEx(MTPipelineLib::IMTSessionPtr aSession,
										SessionErrorObject & arErrObject,
                    T & arStatement);

  
  template<class T>
  BOOL WriteErrorStateEx(
    MTPipelineLib::IMTSessionPtr aSession,
    SessionErrorObject & arErrObject,
    T & stateStatement);
  BOOL PrepareWriteError();

public:
  PipelineFailureWriter(MTPipelineLib::IMTNameIDPtr aNameID,
                        MTPipelineLib::IMTSessionServerPtr aSessionServer,
                        bool aIsDatabaseQueue);
  void Clear();
  BOOL BeginWriteError();
  BOOL FinalizeWriteError(MTPipelineLib::IMTTransactionPtr apTran, std::map<std::wstring, int>& arBatchCounts);
  BOOL WriteError(
    MTPipelineLib::IMTSessionPtr aSession,
    SessionErrorObject & arErrObject);
};

class PipelineResubmitDatabase : public virtual ObjectWithError
{
public:
  struct ServiceStats
  {
    long SessionSetID ;
    long NumSessions;
  };

private:
	enum { UID_LENGTH = 16 };

  //Used to success id's to staging table
	NTLogger mLogger;
	COdbcConnectionPtr  mConnection;
	COdbcPreparedArrayStatementPtr mArrayInsertToSuccessTable;
	COdbcPreparedBcpStatementPtr   mBcpInsertToSuccessTable;
  BOOL mWriteErrorInitialized;
  BOOL mIsOracle;
	string mStagingDBName;
  MTPipelineLib::IMTSessionServerPtr mSessionServer;

  bool Prepare();
  void WriteResubmitSession(MTPipelineLib::IMTSessionPtr aSession, map<long, ServiceStats> & serviceToSessionSet);

 	// Used to guard a in a multithreaded case.
	NTThreadLock mThreadLock;

public:
  PipelineResubmitDatabase(MTPipelineLib::IMTSessionServerPtr aSessionServer);
  bool AutoResubmit(MTPipelineLib::IMTTransactionPtr apTran, 
                    std::vector<MTPipelineLib::IMTSessionPtr> & arErrorsNotMarked, 
                    int originalMessageID);
  bool MarkAsSucceeded(MTPipelineLib::IMTTransactionPtr apTran,
                       MTPipelineLib::IMTSessionSetPtr aSet,
                       long aMessageID);
  void Clear();
};

#endif /* _FAILURES_H */

