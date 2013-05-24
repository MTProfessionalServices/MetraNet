/**************************************************************************
 * @doc AUDIT
 *
 * @module |
 *
 *
 * Copyright 1999 by MetraTech Corporation
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
 * @index | AUDIT
 ***************************************************************************/

#ifndef _AUDIT_H
#define _AUDIT_H

#include <msmqlib.h>

#include <errobj.h>

#include <NTLogger.h>
#include <NTThreader.h>
#include <queuesize.h>
#include <perfshare.h>
#include <list>
#include <map>

using std::list;
using std::map;

/************************************************* UIDHolder ***/

class UIDHolder
{
public:
	enum
	{
		UID_SIZE = 16,
	};

	UIDHolder()
	{ }

	UIDHolder(const unsigned char * apUID)
	{ memcpy(mUID, apUID, UID_SIZE); }

	UIDHolder(const UIDHolder & arUIDHolder)
	{ *this = arUIDHolder; }

	UIDHolder & operator = (const UIDHolder & arUID)
	{
		memcpy(mUID, arUID.GetUID(), UID_SIZE);
		mSuccess = arUID.GetSucceeded();
		return *this;
	}

	void SetSucceeded(BOOL succeeded)
	{ mSuccess = succeeded; }

	BOOL GetSucceeded() const
	{ return mSuccess; }

	const unsigned char * GetUID() const
	{ return mUID; }

	BOOL operator == (const UIDHolder & arUID) const
	{
		return (0 == memcmp(arUID.GetUID(), mUID, UID_SIZE));
	}

	bool operator < (const UIDHolder & arUID) const
	{
		return memcmp(mUID, arUID.GetUID(), UID_SIZE) < 0;
	}

private:
	unsigned char mUID[UID_SIZE];

	// if true, this message succeeded
	BOOL mSuccess;
};

/************************************************* MTAuditor ***/

class MTAuditor : public virtual ObjectWithError, public NTThreader
{
public:
	MTAuditor();

	BOOL AuditSessions(long aHoursAgo);

	BOOL FindLostSessions(std::list<std::string> & arUids, long aHoursAgo);

	BOOL Init(BOOL aDontRemove = FALSE);

	int ThreadMain();

	BOOL AuditingEnabled() const
	{ return mWanttoAudit; }

	~MTAuditor();

	// only audit this many times.  If
	// max audits is -1, audit forever
	void SetMaxAudits(int aMaxAudits)
	{ mMaxAudits = aMaxAudits; }

private:
	static BOOL GetIndices();

	//BOOL GetRelatedIDs(time_t aTime);
	BOOL GetRelatedIDs(MessageQueue & arQueue,
										 QueueTransaction * apTran,
										 BOOL aSuccessQueue);

	BOOL AuditSweep(BOOL aVerbose, BOOL aRemove);
	BOOL AuditSweepInternal(BOOL aVerbose, BOOL aRemove);

	BOOL GetJournalSize(MessageQueue & arQueue);

	BOOL ExecuteHooks(const char * apSection, long aHoursAgo, BOOL aBefore);

private:
	BOOL SweepQueue(MessageQueue & arQueue, BOOL aVerbose, BOOL aRemove);

	BOOL CleanAuditQueue(MessageQueue & arQueue, QueueTransaction * apTran);

	BOOL RemoveMessage(MessageQueue & arQueue, QueueCursor & arCursor,
										 char * * apBody, int & arBodyLen,
										 QueueTransaction * apTran);

	BOOL RemoveMessage(MessageQueue & arQueue, QueueCursor & arCursor,
										 QueueTransaction * apTran);

	BOOL LogMessage(const char * apBody, int aBodyLength, BOOL success,
									const char * apLable, int & arBinaryMessagesLogged);

	long GetSizeofJournalQueue();

	void Cleanup();

	BOOL OpenLogFiles();
	void CloseLogFiles();

	BOOL OpenLogFile(const char * apDirectory, FILE * * apFile, BOOL aBinary);

	BOOL InitMutex();

	BOOL AccessMutex();
	void ReleaseMutex();

private:
	time_t mLastAuditTime;

	// Performace Monitor to get the size of the MSMQ queue.
	QueueSize mQueueSize;
	int mQueueSizeInitialized;

	typedef map<UIDHolder, long> UIDMap;
	typedef list<UIDHolder> UIDList;

	UIDMap mCompleted;

	UIDMap mUIDMap;
	UIDList mUnfinished;

	// logger interface
	NTLogger mLogger;

	FILE * mpSuccessPurgedSessionLog;
	FILE * mpFailurePurgedSessionLog;

	FILE * mpSuccessBatchLog;
	FILE * mpFailureBatchLog;

	enum
	{
		INDEX_SESSIONID = 0,
		INDEX_SERVICEID = 1,
		INDEX_UID = 2,
		INDEX_PARENTUID = 3,
		INDEX_TIMESTAMP = 4,
	};

	long mTime_back;
	double  mTime_internal ;
	long  mJournal_size ;
	long mTime_fre ;
	
	BOOL mWanttoAudit;

	int mMaxAudits;

	BOOL mUsePrivateQueues;
	std::wstring mRoutingQueueMachine;
	std::wstring mRoutingQueueName;

	HANDLE mMutex;

private:
	// perfmon instrumentation
	PerfShare mPerfShare;
	SharedStats * mpStats;
};

#endif /* _AUDIT_H */
