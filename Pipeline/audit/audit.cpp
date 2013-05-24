/**************************************************************************
 * @doc AUDIT
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
 ***************************************************************************/


#include <metralite.h>
#include <audit.h>

#include <pipemessages.h>
#include <batchsupport.h>
#include <MSIX.h>
#include <mtprogids.h>
#include <MTUtil.h>
#import "MTConfigLib.tlb"

#include <pipeconfigutils.h>
#include <pipelineconfig.h>
#include <queue.h>
#include <makeunique.h>
#include <perflog.h>

#include <mtglobal_msg.h>

#include <loggerconfig.h>

#import "MTPipelineLib.tlb"  rename ("EOF", "RowsetEOF") no_function_mapping
#include <pipelinehooks.h>

#include <stdutils.h>
#include <string>

using namespace std;

#include <ConfigDir.h>
#include <comutil.h>
#include <mtcomerr.h>

enum
{
	HOOK_BEFORE_AUDIT = 1,
	HOOK_AFTER_AUDIT = 2,
};


// if aDontRemove is true, don't do an audit on startup
BOOL MTAuditor::Init(BOOL aDontRemove /* = FALSE */)
{
	const char * functionName = "MTAuditor::Init";
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[Auditor]");


	//Get the machine name and routing queue

	PipelineInfoReader pipelineReader;

	PipelineInfo pipelineInfo;

	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Configuration directory not set in the registry.");
		return FALSE;
	}

	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		SetError(pipelineReader);
		return FALSE;
	}

	mUsePrivateQueues = pipelineInfo.UsePrivateQueues();
	mRoutingQueueMachine = pipelineInfo.GetOneRoutingQueueMachine();
	mRoutingQueueName = pipelineInfo.GetOneRoutingQueueName();
	
	mWanttoAudit = pipelineInfo.GetStartAuditting();
	mTime_internal = pipelineInfo.GetAuditInterval();
	mTime_back = pipelineInfo.GetAuditBacktime();
	mJournal_size = pipelineInfo.GetRoutingJournalSize();
	mTime_fre = pipelineInfo.GetAuditfrequency();
	

	//
	// initialize the perfmon integration library
	//
	if (!mPerfShare.Init())
	{
		SetError(mPerfShare);
		return FALSE;
	}
	mpStats = &mPerfShare.GetWriteableStats();


	// NOTE: we audit once during Init to make sure we have connectivity to the
	// queue and all the right permissions.
	if (!aDontRemove && mWanttoAudit)
	{
		if (!InitMutex())
			return FALSE;

		if (!AuditSessions(mTime_back))
		{
			mLogger.LogVarArgs(LOG_ERROR, "Audit Session Failed");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return FALSE;
		}
	}

	return TRUE;
}

MTAuditor::MTAuditor() :
	mLastAuditTime(0),
	mWanttoAudit(FALSE),
	mpFailureBatchLog(NULL),
	mpSuccessBatchLog(NULL),
	mpSuccessPurgedSessionLog(NULL),
	mpFailurePurgedSessionLog(NULL),
	mMutex(NULL),
	mpStats(NULL)
{ }


MTAuditor::~MTAuditor()
{
// close the query
	Cleanup();

	StopThread(INFINITE);

	if (mMutex)
	{
		CloseHandle(mMutex);
		mMutex = NULL;
	}

	ASSERT(mpSuccessBatchLog == NULL);
	ASSERT(mpFailureBatchLog == NULL);
	ASSERT(mpSuccessPurgedSessionLog == NULL);
	ASSERT(mpFailurePurgedSessionLog == NULL);
}

BOOL MTAuditor::OpenLogFiles()
{
	// we use our own locking with the log files, so don't
	// use the normal logger routines

	if (!OpenLogFile("logging\\audit\\", &mpSuccessPurgedSessionLog, FALSE))
		return FALSE;

	if (!OpenLogFile("logging\\failedaudit\\", &mpFailurePurgedSessionLog, FALSE))
		return FALSE;

	if (!OpenLogFile("logging\\batchaudit\\", &mpSuccessBatchLog, TRUE))
		return FALSE;

	if (!OpenLogFile("logging\\failedbatchaudit\\", &mpFailureBatchLog, TRUE))
		return FALSE;

	return TRUE;
}

void MTAuditor::CloseLogFiles()
{
	if (mpSuccessPurgedSessionLog)
	{
		fclose(mpSuccessPurgedSessionLog);
		mpSuccessPurgedSessionLog = NULL;
	}

	if (mpFailurePurgedSessionLog)
	{
		fclose(mpFailurePurgedSessionLog);
		mpFailurePurgedSessionLog = NULL;
	}

	if (mpSuccessBatchLog)
	{
		fclose(mpSuccessBatchLog);
		mpSuccessBatchLog = NULL;
	}

	if (mpFailureBatchLog)
	{
		fclose(mpFailureBatchLog);
		mpFailureBatchLog = NULL;
	}
}


BOOL MTAuditor::OpenLogFile(const char * apDirectory, FILE * * apFile, BOOL aBinary)
{
	const char * functionName = "MTAuditor::OpenLogFile";

	LoggerConfigReader configReader;
	// the batch log file is special - we don't use NTLogger to write to it
	// because the contents are binary.
	LoggerInfo * batchLogInfo = configReader.ReadConfiguration(apDirectory);

	MTLogLevel level = batchLogInfo->GetLogLevel();
	_bstr_t filename = batchLogInfo->GetFilename();
	delete batchLogInfo;

	// if the level is INFO or higher, log
	if ((int) level >= 4)
	{
		if (aBinary)
			// append binary
			*apFile = fopen(filename, "ab");
		else
			// append ascii
			*apFile = fopen(filename, "a");

		if (!*apFile)
		{
			std::string error;
			error = "Unable to open audit file ";
			error += filename;
			SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, error.c_str());
			return FALSE;
		}
	}

	return TRUE;
}

BOOL MTAuditor::InitMutex()
{
	if (mMutex)
		return TRUE;

	const char * functionName = "MTAuditor::InitMutex";

	SECURITY_ATTRIBUTES sa;
	SECURITY_DESCRIPTOR sd;

	/*
	 * create a NULL security descriptor
	 * TODO: create a more restricted discretionary access control list.
	 */
	sa.nLength = sizeof(SECURITY_ATTRIBUTES);
	sa.bInheritHandle = TRUE;
	sa.lpSecurityDescriptor = &sd;
	if (!::InitializeSecurityDescriptor(&sd, SECURITY_DESCRIPTOR_REVISION))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	if (!::SetSecurityDescriptorDacl(&sd, TRUE, (PACL)NULL, FALSE))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	/*
	 * create the mutex
	 */
	std::string mutexName("MTAuditLogMutex");
	MakeUnique(mutexName);
	// make this globally unique across terminal services sessions.
	mutexName.insert(0, "Global\\");

	mMutex = ::CreateMutexA(&sa,			// security
													FALSE,		// initially not owned
													mutexName.c_str()); // mutex name
	if (mMutex == NULL)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	return TRUE;
}

BOOL MTAuditor::AccessMutex()
{
	ASSERT(mMutex);
	DWORD waitResult =
		::WaitForSingleObject(mMutex,   // handle of mutex
													24000 * 60 * 60); // 24 hours

	if (waitResult == WAIT_OBJECT_0 || waitResult == WAIT_ABANDONED)
		return TRUE;
	else
		return FALSE;
}

void MTAuditor::ReleaseMutex()
{
	if (mMutex)
	{
		BOOL result = ::ReleaseMutex(mMutex);
		ASSERT(result);
	}
}


BOOL MTAuditor::AuditSessions(long aHoursAgo)
{
	MarkRegion region("AuditSessions");

	const char * functionName = "MTAuditor::AuditSessions";

	if (!ExecuteHooks("before_audit", aHoursAgo, TRUE))
		return FALSE;

	// time_t checkTime = time(NULL);
	// offset by the given number of hours
	// checkTime -= aHoursAgo * 60 * 60;


	PipelineInfoReader pipelineReader;

	PipelineInfo pipelineInfo;

	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	std::string configDir;
 
	if (!GetMTConfigDir(configDir))
	{
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Configuration directory not set in the registry.");
		return FALSE;
	}

	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		SetError(pipelineReader);
		return FALSE;
	}

	const std::wstring & auditQueueMachine = pipelineInfo.GetAuditQueueMachine();
	const std::wstring & auditQueueName = pipelineInfo.GetAuditQueueName();

	const std::wstring & failedAuditQueueMachine = pipelineInfo.GetFailedAuditQueueMachine();
	const std::wstring & failedAuditQueueName = pipelineInfo.GetFailedAuditQueueName();

	MessageQueue receiptQueue;
	MessageQueue failedReceiptQueue;

	ErrorObject * errObj = NULL;
	if (!SetupQueue(receiptQueue, auditQueueName.c_str(), auditQueueMachine.c_str(),
									L"Audit queue",
									FALSE,				// journal
									FALSE,				// send access
									pipelineInfo.UsePrivateQueues(), // private
									FALSE,				// transactional
									&errObj))
	{
		SetError(errObj);
		return FALSE;
	}

	if (!SetupQueue(failedReceiptQueue, failedAuditQueueName.c_str(), failedAuditQueueMachine.c_str(),
									L"Failed audit queue",
									FALSE,				// journal
									FALSE,				// send access
									pipelineInfo.UsePrivateQueues(), // private
									TRUE,					// transactional
									&errObj))
	{
		SetError(errObj);
		return FALSE;
	}

	// get a list of all sessions that have a receipt in the success audit queue
	if (!GetRelatedIDs(receiptQueue, NULL, TRUE))
	{
		Cleanup();
		return FALSE;
	}

	// get a list of all sessions that have a receipt in the failure audit queue
	QueueTransaction queueTran;
	if (queueTran.GetLastError() != NULL)
	{
		SetError(queueTran);
		return FALSE;
	}

	if (!GetRelatedIDs(failedReceiptQueue, &queueTran, FALSE))
	{
		Cleanup();
		return FALSE;
	}

	// remove sessions that have a receipt
	if (!AuditSweep(TRUE, TRUE))
	{
		Cleanup();
		return FALSE;
	}
	// delete receipts from success audit queue
	if (!CleanAuditQueue(receiptQueue, NULL))
	{
		Cleanup();
		return FALSE;
	}
	// delete receipts from failure audit queue
	if (!CleanAuditQueue(failedReceiptQueue, &queueTran))
	{
		Cleanup();
		return FALSE;
	}

	if (!queueTran.Commit())
	{
		SetError(queueTran);
		return FALSE;
	}
		
	if (!ExecuteHooks("after_audit", aHoursAgo, FALSE))
	{
		Cleanup();
		return FALSE;
	}
	Cleanup();
	return TRUE;
}

BOOL MTAuditor::FindLostSessions(std::list<std::string> & arUids,
																 long aHoursAgo)
{
	const char * functionName = "MTAuditor::FindLostSessions";


	// time_t checkTime = time(NULL);
	// offset by the given number of hours
	// checkTime -= aHoursAgo * 60 * 60;


	PipelineInfoReader pipelineReader;

	PipelineInfo pipelineInfo;

	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	std::string configDir;
 
	if (!GetMTConfigDir(configDir))
	{
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Configuration directory not set in the registry.");
		return FALSE;
	}

	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		SetError(pipelineReader);
		ASSERT(GetLastError());
		return FALSE;
	}

	const std::wstring & auditQueueMachine = pipelineInfo.GetAuditQueueMachine();
	const std::wstring & auditQueueName = pipelineInfo.GetAuditQueueName();

	const std::wstring & failedAuditQueueMachine = pipelineInfo.GetFailedAuditQueueMachine();
	const std::wstring & failedAuditQueueName = pipelineInfo.GetFailedAuditQueueName();

	MessageQueue receiptQueue;
	MessageQueue failedReceiptQueue;

	ErrorObject * errObj = NULL;
	if (!SetupQueue(receiptQueue, auditQueueName.c_str(), auditQueueMachine.c_str(),
									L"Audit queue",
									FALSE,				// journal
									FALSE,				// send access
									pipelineInfo.UsePrivateQueues(), // private
									FALSE,				// transactional
									&errObj))
	{
		SetError(errObj);
		ASSERT(GetLastError());
		return FALSE;
	}

	if (!SetupQueue(failedReceiptQueue, failedAuditQueueName.c_str(), failedAuditQueueMachine.c_str(),
									L"Failed audit queue",
									FALSE,				// journal
									FALSE,				// send access
									pipelineInfo.UsePrivateQueues(), // private
									TRUE,					// transactional
									&errObj))
	{
		SetError(errObj);
		ASSERT(GetLastError());
		return FALSE;
	}

	// get a list of all sessions that have a receipt in the success audit queue
	if (!GetRelatedIDs(receiptQueue, NULL, TRUE))
	{
		Cleanup();
		ASSERT(GetLastError());
		return FALSE;
	}

	// get a list of all sessions that have a receipt in the failure audit queue
	QueueTransaction queueTran;
	if (queueTran.GetLastError() != NULL)
	{
		SetError(queueTran);
		ASSERT(GetLastError());
		return FALSE;
	}

	if (!GetRelatedIDs(failedReceiptQueue, &queueTran, FALSE))
	{
		Cleanup();
		ASSERT(GetLastError());
		return FALSE;
	}

	if (!queueTran.Commit())
	{
		SetError(queueTran);
		ASSERT(GetLastError());
		return FALSE;
	}

	// check for lost messages but don't modify the queues.
	// also, don't print anything
	if (!AuditSweep(FALSE, FALSE))
	{
		Cleanup();
		ASSERT(GetLastError());
		return FALSE;
	}

	UIDList::iterator unfinishedit;
	for (unfinishedit = mUnfinished.begin();
			 unfinishedit != mUnfinished.end(); ++unfinishedit)
	{
		UIDHolder holder = *unfinishedit;

		const unsigned char * bytes = holder.GetUID();
		string encoded;
		MSIXUidGenerator::Encode(encoded, bytes);

		arUids.push_back(encoded);
	}

	Cleanup();
	return TRUE;
}




void MTAuditor::Cleanup()
{
	//Clean up the mCompleted, mUIDMap, and mUnfinished

	mCompleted.clear();
	mUIDMap.clear();
	mUnfinished.clear();

}

BOOL MTAuditor::ExecuteHooks(const char * apSection, long aHoursAgo, BOOL aBefore)
{
	// NOTE: this function can throw if there's an error

	PipelineHooks hooks;
	MTPipelineLib::IMTConfigPtr config(MTPROGID_CONFIG);

	MTPipelineLib::IMTConfigPropSetPtr propset;

	if (!hooks.ReadHookFile(config, propset)
			|| !hooks.SetupHookHandler(propset, apSection))
	{
		SetError(hooks);
		return FALSE;
	}

	_variant_t var = aHoursAgo;		// hours argument
	unsigned long arg = aBefore ? 1 : 2;	// before or after argument

	hooks.ExecuteAllHooks(var, arg);

	return TRUE;
}

BOOL MTAuditor::GetRelatedIDs(MessageQueue & arQueue,
															QueueTransaction * apTran,
															BOOL aSuccessQueue)
{
	const char * functionName = "MTAuditor::GetRelatedIDs";

	MarkRegion region("GetRelatedIDs");
	//
	// iterate through the messages in the queue, using their
	// labels as encoded UIDs
	//
	QueueCursor cursor;
	if (!cursor.Init(arQueue))
	{
		SetError(cursor.GetLastError());
		return FALSE;
	}

	QueueMessage message;
	BOOL moveNext = FALSE;
	for (int count = 0; ; count++)
	{
		message.ClearProperties();

		// get the label in order to find the UID
		// the label is only about 24 characters, so this should be plenty
		wchar_t labelBuffer[64];
		char labelbuf[64];
		message.SetLabelLen(sizeof(labelBuffer));
		message.SetLabel(labelBuffer);

		// peek at the message
		if (!arQueue.Peek(message, cursor, !moveNext, 0))
		{
			const ErrorObject * err = arQueue.GetLastError();

			// if we timed out, we're at the end of the queue
			if (!err)
				break;

			// otherwise there was a problem
			SetError(err);
			return FALSE;
		}

		moveNext = TRUE;

		// decode the UID to see if it's in the map
	    unsigned char decoded[16];
        std::string labelString;
        labelString = ascii(wstring(labelBuffer));
		
		if (!MSIXUidGenerator::Decode(decoded, labelString))
		{
			mLogger.LogVarArgs(LOG_ERROR, "Invalidate audit message label: %s",
												 std::string(labelbuf).c_str());
		}
		else
		{
			UIDHolder uid(decoded);

			uid.SetSucceeded(aSuccessQueue);

			//
			// insert the UID into the map
			//
			// TODO: for now database ID is unused
			mUIDMap[uid] = -1;
		}
	}

	return TRUE;
}

BOOL MTAuditor::AuditSweep(BOOL aVerbose, BOOL aRemove)
{
	MarkRegion region("AuditSweep");
	try
	{
		if (!InitMutex())
			return FALSE;

		if (!AccessMutex())
		{
			mLogger.LogVarArgs(LOG_ERROR, "Unable to access mutex");
			return FALSE;
		}

		if (!OpenLogFiles())
		{
			ReleaseMutex();
			return FALSE;
		}

		BOOL result = AuditSweepInternal(aVerbose, aRemove);

		CloseLogFiles();
		ReleaseMutex();

		return result;
	}
	catch (...)
	{
		ReleaseMutex();
		throw;
	}
}

BOOL MTAuditor::AuditSweepInternal(BOOL aVerbose, BOOL aRemove)
{
	const char * functionName = "MTAuditor::AuditSweep";

	if (aVerbose)
		cout << "Performing audit sweep" << endl;

	// indicate through perfmon that auditing is running
	mpStats->SetTiming(SharedStats::AUDIT_FLAG, 1);

	// this searches the audit queues (journals of the routing queues)
	mLogger.LogThis(LOG_DEBUG, "Enumerating all routing queues");
	
	// To do, because we will read the routing queue from a separete file in future. the GetAllRoutingQueue
	// will not work ----- Jiang

	ErrorObject error;
	RoutingQueueList queues;
	if (!GetAllRoutingQueues(queues, error))
	{
		// indicate through perfmon that auditing is not running
		mpStats->SetTiming(SharedStats::AUDIT_FLAG, 0);

		SetError(&error);
		return FALSE;
	}

	mLogger.LogVarArgs(LOG_DEBUG, "%d routing queues found", queues.size());


	// get config dir
	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE,
						 functionName);
		mpLastError->GetProgrammerDetail() = "Cannot read configuration directory";
		return FALSE;
	}

	// read pipeline config file
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	PipelineInfo pipeInfo;
	PipelineInfoReader reader;
	if (!reader.ReadConfiguration(config, configDir.c_str(), pipeInfo))
	{
		SetError(reader);
		return FALSE;
	}

	std::wstring resubmitQueueName = pipeInfo.GetResubmitQueueName();

	RoutingQueueList::const_iterator it;
	for (it = queues.begin(); it != queues.end(); it++)
	{
		RoutingQueueInfo info = *it;

		mLogger.LogVarArgs(LOG_DEBUG, "Searching queue: %s:%s",
											 ascii(info.GetMachineName()).c_str(),
											 ascii(info.GetQueueName()).c_str());

		MessageQueue auditQueue;

		const wchar_t * machine;
		if (info.GetMachineName().length() == 0)
			machine = NULL;
		else
			machine = info.GetMachineName().c_str();

		BOOL transactional;
		if (info.GetQueueName() == resubmitQueueName)
			transactional = TRUE;
		else
			transactional = FALSE;

		// use the journal, not the routing queue itself
		ErrorObject * errObj = NULL;
		if (!SetupJournalQueue(auditQueue, info.GetQueueName().c_str(),
													 machine,
													 L"Routing queue",
													 FALSE,				// send access
													 mUsePrivateQueues, // private
													 transactional,	// transactional
													 &errObj))
		{
			HRESULT errCode = HRESULT_FROM_WIN32(errObj->GetCode());
			mLogger.LogVarArgs(LOG_ERROR,
												 "Unable to open routing queue journal: %x", errCode);

			SetError(errObj);
			delete errObj;

			// indicate through perfmon that auditing is not running
			mpStats->SetTiming(SharedStats::AUDIT_FLAG, 0);
			return FALSE;
		}

		if (!SweepQueue(auditQueue, aVerbose, aRemove))
		{
			// indicate through perfmon that auditing is not running
			mpStats->SetTiming(SharedStats::AUDIT_FLAG, 0);

			return FALSE;
		}
	}

	if (aVerbose)
	{
		UIDList::iterator unfinishedit;
		for (unfinishedit = mUnfinished.begin();
				 unfinishedit != mUnfinished.end(); ++unfinishedit)
		{
			UIDHolder holder = *unfinishedit;

			const unsigned char * bytes = holder.GetUID();
			string encoded;
			MSIXUidGenerator::Encode(encoded, bytes);

			mLogger.LogVarArgs(LOG_DEBUG, "Session still unfinished: %s", encoded.c_str());
		}
	}

	// indicate through perfmon that auditing is not running
	mpStats->SetTiming(SharedStats::AUDIT_FLAG, 0);

	return TRUE;
}



BOOL MTAuditor::SweepQueue(MessageQueue & arQueue, BOOL aVerbose, BOOL aRemove)
{
	const char * functionName = "MTAuditor::SweepQueue";

	//
	// iterate through the messages in the queue, comparing
	// them against the list of UIDs in the database.
	//
	QueueCursor cursor;
	if (!cursor.Init(arQueue))
	{
		SetError(cursor.GetLastError());
		return FALSE;
	}

	// count of binary messages 
	int binaryMessages = 0;

	QueueMessage message;
	BOOL moveNext = FALSE;
	for (int count = 0; ; count++)
	{
		message.ClearProperties();

		// get the label in order to find the UID
		// the label is only about 24 characters, so this should be plenty
		wchar_t labelBuffer[64];
		message.SetLabelLen(sizeof(labelBuffer));
		message.SetLabel(labelBuffer);

		// peek at the message
		if (!arQueue.Peek(message, cursor, !moveNext, 0))
		{
			const ErrorObject * err = arQueue.GetLastError();

			// if we timed out, we're at the end of the queue
			if (!err)
				break;

			// otherwise there was a problem
			SetError(err);
			return FALSE;
		}

		moveNext = TRUE;
		
		// decode the UID to see if it's in the map
		unsigned char decoded[16];
		string labelString;
		labelString = ascii(wstring(labelBuffer));
		if (!MSIXUidGenerator::Decode(decoded, labelString))
		{
			// if it doesn't decode then the label is corrupt
			if (aVerbose)
				cout << "Removing corrupt message " << labelString.c_str() <<endl;			

			if (aRemove)
			{
				mLogger.LogThis(LOG_ERROR,
												"Removing corrupt message from audit queue");

				char * body;
				int bodyLen;
				if (!RemoveMessage(arQueue, cursor, &body, bodyLen, NULL))
					return FALSE;

				// throw away the message
				delete [] body;
			}
			else
			{
				// don't remove it - but log a warning
				mLogger.LogThis(LOG_WARNING,
												"Corrupt message found in audit queue");

			}
			// we're already pointing to the next message
			moveNext = FALSE;
		}
		else
		{
			UIDHolder uid(decoded);

			UIDMap::iterator findit = mUIDMap.find(uid);
			if (findit != mUIDMap.end())
			{
				const UIDHolder & uidKey = findit->first;

				if (aVerbose)
					cout << "Removing session " << labelString.c_str() <<endl;

				BOOL successMessage = uidKey.GetSucceeded();

				if (aRemove)
				{
					char * body;
					int bodyLen;
					if (!RemoveMessage(arQueue, cursor, &body, bodyLen, NULL))
						return FALSE;

					LogMessage(body, bodyLen, successMessage,
										 labelString.c_str(), binaryMessages);

					delete [] body;
				}

				//cout << "Message removed: " << endl;

				//cout << body << endl;

				mUIDMap.erase(uid);

				// keep a list of UIDs that are complete and can be removed
				mCompleted[uid] = -1;

				// we're already pointing to the next message
				moveNext = FALSE;
			}
			else
			{
				// message hasn't made it to the database
				mUnfinished.push_back(uid);
			}
		}
	}

	// flush all binary messages if there were any
	if (binaryMessages > 0)
		fflush(mpSuccessBatchLog);

	return TRUE;
}

BOOL MTAuditor::LogMessage(const char * apBody,
													 int aBodyLength, BOOL success,
													 const char * apLabel,
													 int & arBinaryMessagesLogged)
{
	const unsigned char * message = (const unsigned char *) apBody;

	if (MTMSIXBatchHelper::VerifyHeader(message) != NULL
			|| MTMSIXMessageHelper::VerifyHeader(message) != NULL)
	{
		// this message is binary - log it to the binary message log
		if (success)
		{
			if (mpSuccessBatchLog)
			{
				if (fwrite(message, aBodyLength, 1, mpSuccessBatchLog) != 1)
				{
					mLogger.LogVarArgs(LOG_ERROR, "Unable to log binary message %s",
														 apLabel);
					// NOTE: we keep going here - nothing can be done at this point
				}
				++arBinaryMessagesLogged;
			}
		}
		else
		{
			if (mpFailureBatchLog)
			{
				if (fwrite(message, aBodyLength, 1, mpFailureBatchLog) != 1)
				{
					mLogger.LogVarArgs(LOG_ERROR, "Unable to log binary message %s",
														 apLabel);
					// NOTE: we keep going here - nothing can be done at this point
				}
				++arBinaryMessagesLogged;
			}
		}
	}
	else
	{
		// TODO: this doesn't do any metratime stuff
		// log only system time
		char dateTime[256];
		time_t uTime = time(NULL);
		struct tm * lTime = localtime(&uTime);
		strftime(dateTime, 256, "%m/%d/%y %H:%M:%S ", lTime);

		strcat(dateTime, "[Auditor][INFO] ");

		if (success)
		{
			if (mpSuccessPurgedSessionLog)
			{
				if (fputs(dateTime, mpSuccessPurgedSessionLog) == EOF
						|| fputs(apBody, mpSuccessPurgedSessionLog) == EOF
						|| fputs("\n", mpSuccessPurgedSessionLog) == EOF)
				{
					mLogger.LogVarArgs(LOG_FATAL, "Unable to log audit message!");
					mLogger.LogThis(LOG_FATAL, apBody);
				}
			}
		}
		else
		{
			if (mpFailureBatchLog)
			{
				if (fputs(dateTime, mpFailurePurgedSessionLog) == EOF
						|| fputs(apBody, mpFailurePurgedSessionLog) == EOF
						|| fputs("\n", mpFailurePurgedSessionLog) == EOF)
				{
					mLogger.LogVarArgs(LOG_FATAL, "Unable to log audit message!");
					mLogger.LogThis(LOG_FATAL, apBody);
				}
			}
		}
	}
	return TRUE;
}


BOOL MTAuditor::CleanAuditQueue(MessageQueue & arQueue, QueueTransaction * apTran)
{
	const char * functionName = "MTAuditor::CleanAuditQueue";

	//
	// iterate through the messages in the queue, comparing
	// them against the list of UIDs in the database.
	//
	QueueCursor cursor;
	if (!cursor.Init(arQueue))
	{
		SetError(cursor.GetLastError());
		return FALSE;
	}

	QueueMessage message;
	BOOL moveNext = FALSE;
	for (int count = 0; ; count++)
	{
		message.ClearProperties();

		// get the label in order to find the UID
		// the label is only about 24 characters, so this should be plenty
		wchar_t labelBuffer[64];
		message.SetLabelLen(sizeof(labelBuffer));
		message.SetLabel(labelBuffer);

		// peek at the message
		if (!arQueue.Peek(message, cursor, !moveNext, 0))
		{
			const ErrorObject * err = arQueue.GetLastError();

			// if we timed out, we're at the end of the queue
			if (!err)
				break;

			// otherwise there was a problem
			SetError(err);
			return FALSE;
		}

		moveNext = TRUE;

		// decode the UID to see if it's in the map
		unsigned char decoded[16];
		string labelString;
		labelString = ascii(wstring(labelBuffer));
		if (!MSIXUidGenerator::Decode(decoded, labelString))
		{
			ASSERT(0);
		}

		UIDHolder uid(decoded);

		if (mCompleted.find(uid) != mCompleted.end())
		{
			cout << "Removing receipt " << labelString.c_str() << endl;

			if (!RemoveMessage(arQueue, cursor, apTran))
				return FALSE;

			mCompleted.erase(uid);

			if (mCompleted.size() == 0 && mUIDMap.size() == 0)
				break;									// not looking for anything else now..

			// we're already pointing to the next message
			moveNext = FALSE;
		}
		else if (mUIDMap.find(uid) != mUIDMap.end())
		{
			cout << "Extra audit message " << labelString.c_str() << endl;

			if (!RemoveMessage(arQueue, cursor, apTran))
				return FALSE;

			mUIDMap.erase(uid);

			if (mCompleted.size() == 0 && mUIDMap.size() == 0)
				break;									// not looking for anything else now..

			// we're already pointing to the next message
			moveNext = FALSE;
		}
	}

	return TRUE;
}


BOOL MTAuditor::RemoveMessage(MessageQueue & arQueue, QueueCursor & arCursor,
															QueueTransaction * apTran)
{
	const char * functionName = "MTAuditor::RemoveMessage";

	QueueMessage message;
	message.ClearProperties();

	BOOL result;
	if (apTran)
		result = arQueue.Receive(message, arCursor, *apTran, 0);
	else
		result = arQueue.Receive(message, arCursor, 0);

	if (!result)
	{
		const ErrorObject * err = arQueue.GetLastError();

		// shouldn't be possible to timeout here
		if (!err)
		{
			SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}

		// this time it's really an error
		//mLogger.LogVarArgs(LOG_ERROR, "Unexpected queue behaviour");
		//SetError(err);
		SetError(err);
		return FALSE;
	}

	return TRUE;
}


BOOL MTAuditor::RemoveMessage(MessageQueue & arQueue, QueueCursor & arCursor,
															char * * apBody, int & arBodyLen,
															QueueTransaction * apTran)
{
	const char * functionName = "MTAuditor::RemoveMessage";

	QueueMessage message;
	message.ClearProperties();

	// have to supply some sort of buffer..
	unsigned char fakeBuffer[1];
	message.SetBody(fakeBuffer, sizeof(fakeBuffer));
	message.SetBodySize(sizeof(fakeBuffer));

	// this call should fail with MQ_ERROR_BUFFER_OVERFLOW
	BOOL result;
	if (apTran)
		result = arQueue.Peek(message, arCursor, TRUE, *apTran, 0);
	else
		result = arQueue.Peek(message, arCursor, TRUE, 0);

	if (!result)
	{
		const ErrorObject * err = arQueue.GetLastError();

		// shouldn't be possible to timeout here
		if (!err)
		{
			SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}

		if (err->GetCode() != MQ_ERROR_BUFFER_OVERFLOW)
		{
			// shouldn't happen unless something's wrong with the queue
			//mLogger.LogVarArgs(LOG_ERROR, "Unexpected error returned from MSMQ peek: %x",
			//									 err->GetCode());
			SetError(err);
			return FALSE;
		}
	}
	else
	{
		// the function should have failed
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	const ULONG * size = message.GetBodySize();
	ASSERT(size);
	arBodyLen = *size;
	message.ClearProperties();

	ASSERT(apBody);
	*apBody = new char[arBodyLen + 1];

	// receive the body..
	message.SetBody((UCHAR *) *apBody, arBodyLen);

	// peek once again to get the contents of the body
	if (apTran)
		result = arQueue.Receive(message, arCursor, *apTran, 0);
	else
		result = arQueue.Receive(message, arCursor, 0);

	if (!result)
	{
		delete [] *apBody;
		*apBody = NULL;
		const ErrorObject * err = arQueue.GetLastError();

		// shouldn't be possible to timeout here
		if (!err)
		{
			SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}

		// this time it's really an error
		//mLogger.LogVarArgs(LOG_ERROR, "Unexpected queue behaviour");
		//SetError(err);
		SetError(err);
		return FALSE;
	}

	// null terminate
	(*apBody)[arBodyLen] = '\0';

	return TRUE;
}

int MTAuditor::ThreadMain()
{	
	if(mWanttoAudit) 
	{
		const char * functionName = "In the MTAuditor: ThreadMain";

		time_t StartTime = time(NULL);

		BOOL ready = FALSE;

		time_t currentTime;
		
		if(!AuditSessions(mTime_back))
		{
			mLogger.LogVarArgs(LOG_ERROR, "Audit Session Failed");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		}


		
		bool loggedPerfmonWarning = false;

		time_t LastTimeAudit  = StartTime;

		while(!StopRequested())
		{	
			currentTime = time(NULL);

			//five minutes min

#if 0
			while(!StopRequested() && (currentTime - LastTimeAudit)<5*60)
			{
				::Sleep((int) mTime_fre*1000);
				currentTime = time(NULL);
			}
#endif
				
			while (!StopRequested() && !ready)
			{
				int currentJournalSize = GetSizeofJournalQueue();
				if (currentJournalSize < 0)
				{
					// only log this warning once.  Otherwise it will fill up the log
					if (!loggedPerfmonWarning)
					{
						mLogger.LogVarArgs(LOG_WARNING, "Cannot determine size of routing queue journal");
						mLogger.LogErrorObject(LOG_ERROR, GetLastError());
						loggedPerfmonWarning = true;
					}
				}

				//cout << "Journal size = " << currentJournalSize << endl;
				if(currentJournalSize > mJournal_size * 1024 * 1024)
					ready = TRUE;
				else if((currentTime - StartTime) > mTime_internal * 60 * 60)
					ready = TRUE;
				else
				{
						::Sleep((int) mTime_fre*1000);
						currentTime = time(NULL);
				}
			}

			if (StopRequested())
				break;
			
			if(!AuditSessions(mTime_back))
			{
				mLogger.LogVarArgs(LOG_ERROR, "Audit Session Failed:");
				mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			}

			// if the journal is still bigger than the requested threshold,
			// up the threshold.  Otherwise, the auditor will just attempt to
			// run endlessly.
			int currentJournalSize = GetSizeofJournalQueue();
			if (currentJournalSize < 0)
			{
				if (!loggedPerfmonWarning)
				{
					mLogger.LogVarArgs(LOG_WARNING, "Cannot determine size of routing queue journal");
					mLogger.LogErrorObject(LOG_ERROR, GetLastError());
					loggedPerfmonWarning = true;
				}
			}

			if (currentJournalSize > mJournal_size*1024*1024)
			{
				int newSize = (currentJournalSize / (1024 * 1024)) + mJournal_size;
				mLogger.LogVarArgs(LOG_WARNING, "After audit sweep, queue size is still larger than %dMB",
													 mJournal_size);
				mLogger.LogVarArgs(LOG_WARNING, "Increasing max queue size to %dMB",
													 newSize);
				mJournal_size = newSize;
			}

			LastTimeAudit = time(NULL);
			currentTime = LastTimeAudit;

			ready = FALSE;
			StartTime = currentTime;
		}

		AuditSessions(mTime_back);

		return 1;
	}
	return 0;
}

long MTAuditor::GetSizeofJournalQueue()
{
	const char * functionName = "MTAuditor::GetSizeofJournalQueue";

	if (!mQueueSize.IsInitialized())
	{
		if (!mQueueSize.Init(mRoutingQueueMachine.c_str(),
												 mRoutingQueueName.c_str(),
												 mUsePrivateQueues,
												 TRUE))
		{
			SetError(mQueueSize);
			return -1;
		}
	}

	return mQueueSize.GetCurrentQueueSize();
}

