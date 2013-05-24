/**************************************************************************
 * @doc PIPEMESSAGES
 *
 * @module |
 *
 *
 * Copyright 1998 by MetraTech Corporation
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
 * $Header$
 *
 * @index | PIPEMESSAGES
 ***************************************************************************/

#ifndef _PIPEMESSAGES_H
#define _PIPEMESSAGES_H

#define PIPELINE_CONTROL_QUEUE L"PipelineControlQueue"

/*
 * Messages sent through the pipeline
 */

// one of these IDs is set in the app specific part of the message
// the pipeline can peek at this ID without pulling the message off the queue
// or looking at the message body

enum PipelineMessageID
{
	PIPELINE_PROCESS_SESSION = 5,	// value is arbitrary (just non-zero)
	PIPELINE_WAIT_PROCESS_SESSION,
	PIPELINE_PROCESS_SESSION_SET,
	PIPELINE_WAIT_PROCESS_SESSION_SET,
	PIPELINE_SYSTEM_COMMAND,
	PIPELINE_PROCESS_GROUP,

	// feedback
	PIPELINE_SESSION_FAILED,
	PIPELINE_SET_FAILED,
	PIPELINE_CHILDREN_COMPLETE,
	PIPELINE_GROUP_COMPLETE,

	PIPELINE_STAGE_STATUS,

	PIPELINE_SESSION_RECEIPT,
};

// priority of different messages.
// 7 is the highest priority, 0 the lowest
enum PipelineMessagePriority
{
	// system level (highest priority)
	PIPELINE_SYSTEM_PRIORITY = 5,

	// normal, asynchronous transactions
	PIPELINE_STANDARD_PRIORITY = 2,

	// transactions requiring a response (higher priority)
	PIPELINE_SYNCHRONOUS_PRIORITY = 3,

	// transactions requiring a response immediately (highest priority)
	PIPELINE_HIGH_PRIORITY = 4,
};

// higher priority system command
struct PipelineSysCommand
{
	enum Command
	{
		REFRESH_INIT,								// refresh initialization
		EXIT,												// exit server
		LOG_PERF_DATA,							// log performance data
	} mCommand;
};


// Sent to pipeline stages to tell them to process a single
// session.
// NOTE: this message is sent for PIPELINE_PROCESS_SESSION
// as well as PIPELINE_WAIT_PROCESS_SESSION.
//
// When PIPELINE_WAIT_PROCESS_SESSION is sent,
// the stage needs to wait for the session to go to a ready
// state before processing.

struct PipelineProcessSession
{
	long mSessionID;							// shared memory ID

	// TODO: don't hardcode the length of the UID
	unsigned char mUID[16];				// UID of the session (for verification only)
};

// Sent to pipeline stages to tell them to process a set
// of sessions.

struct PipelineProcessSessionSet
{
	long mSetID;									// shared memory ID

	unsigned char mSetUID[16];		// unique ID of the batch itself
};

// Sent to pipeline stages to tell them to process a set
// of sessions after a given object owner has fired a message
struct PipelineWaitProcessSessionSet
{
	long mSetID;									// shared memory ID

	unsigned char mSetUID[16];		// unique ID of the batch itself

	long mObjectOwnerID;					// object owner we're waiting for
};

// Sent to tell the pipeline that a session failed and
// must be restarted
struct PipelineSessionFailed
{
	long mSessionID;

	// TODO: don't hardcode the length of the UID
	unsigned char mUID[16];				// UID of the session (for verification only)
};

// Sent to tell the pipeline that a session failed and
// must be restarted
struct PipelineSetFailed
{
	long mSetID;
};


// Sent to tell the pipeline that a session's children are now complete
struct PipelineChildrenComplete
{
	long mSessionID;
};

// Sent to tell a stage that a group of sessions have completed
struct PipelineGroupComplete
{
	long mObjectOwnerID;
};

// Sent to tell the pipeline controller that a stage it ready/paused/quit
struct PipelineStageStatus
{
	long mStageID;
// ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1 
	enum StageStatus
	{
		PIPELINE_STAGE_STARTING,
		PIPELINE_STAGE_READY,
		PIPELINE_STAGE_PAUSED,
		PIPELINE_STAGE_QUITTING,
		PIPELINE_STAGE_QUIT,
		PIPELINE_STAGE_RESTARTING,
		PIPELINE_STAGE_FATALSTOP,
	} mStatus;
};

// Sent to the error queue when a session fails to be processed
struct SessionError
{
	// MSIX UID of the session that failed
  unsigned char mSessionID[16];

	// MSIX UID of the root of the compound the
	// session was part of.  All zeros if not part of a compound
  unsigned char mRootID[16];

	// MSIX UID of the session set containing this session
	// All zeros if not part of a session set
  unsigned char mSessionSetID[16];

	// MSIX UID of the batch this session belongs to
	// All zeros if not part of a batch
  unsigned char mBatchID[16];

	// true if this session is part of a compound
	// false if atomic
	BOOL mIsCompound;

	// error code that caused the failure
  ErrorObject::ErrorCode mErrorCode;

	// line number the error occurred on
  int mLineNumber;

	// (time_t) time session failed
	time_t mFailureTime;

	// (time_t) time session was metered
	time_t mMeteredTime;

	// IP address of failure
	unsigned char mIPAddress[4];

	// Account ID (if known), or -1
	long mAccountID;

 	// Payer ID (if known), or -1
	long mPayerID;

	// service ID
	long mServiceID;

	// NOTE: in the body of the message, this structure is followed by 6 strings,
	// separated by nulls.  the strings are:
  //  0. error message
	//  1. stage name
	//  2. plug-in name
	//  3. module-name
	//  4. procedure-name
	//  5. XML/MSIX message representation of the session


	//4.0
	long mScheduleSessionID;
	long mScheduleSessionSetID;
};

enum AUDIT_SESSION_STATE
{
	AUDIT_SESSION_CLOSED = 10,
	AUDIT_SESSION_SAVED = 20,
};

// Gives the router an idea of whether or not the session will fit in memory.
// Properties are counted in handler.cpp when the session is validated and 
// checked for overflow in route.cpp.
struct PropertyCount {
	unsigned int total;
	unsigned int smallStr;
	unsigned int mediumStr;
	unsigned int largeStr;
};

// batch of compressed MSIX messages
struct MTMSIXBatchHeader
{
	DWORD mMagic;									// = 0xABCDEFFF
	DWORD mHeaderSize;						// number of bytes in the header
	int mMessages;								// messages in the batch
	char mClientVersion;					// currently set to 0
	unsigned char mBatchUID[16];	// unique ID of the batch itself
	BOOL mValidate;								// if true, validate the batch
	char mCompression;						// 1 = zlib, 2 = lzo
	char mEncrypted;							// 1 = encrypted, 0 = cleartext
	DWORD mOriginalSize;					// original size of the data
	DWORD mCompressedSize;				// size of compressed data
	DWORD mEncryptedSize;					// size of encrypted data

	enum
	{
		MAGIC = 0xABCDEFFF,
	};
};

// an MSIX message in a batch
#define MTMSIX_COMPRESS_NONE 0
#define MTMSIX_COMPRESS_ZLIB 1
#define MTMSIX_COMPRESS_LZO 2

struct MTMSIXMessageHeader
{
	DWORD mMagic;									// = 0x00000000
	DWORD mHeaderSize;						// number of bytes in the header
	DWORD mOriginalSize;					// original size of the data
	DWORD mCompressedSize;				// size of compressed data
	DWORD mEncryptedSize;					// size of compressed data
	unsigned char mParentUID[16];	// unique ID of parent record
	char mCompression;						// 1 = zlib, 2 = lzo
	char mEncrypted;							// 1 = encrypted, 0 = cleartext

	enum
	{
		MAGIC = 0x00000000,
	};
};



#endif /* _PIPEMESSAGES_H */
