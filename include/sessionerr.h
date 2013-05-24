/**************************************************************************
 * @doc SESSIONERR
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
 * @index | SESSIONERR
 ***************************************************************************/

#ifndef _SESSIONERR_H
#define _SESSIONERR_H

#include <pipemessages.h>

class SessionErrorObject
	: private SessionError,
		public ObjectWithError			// used for encode/decode problems
{
public:
	SessionErrorObject();
	~SessionErrorObject();

	// initialize this object from a buffer of bytes (normally an error message)
	BOOL Decode(const unsigned char * apBytes, int aBufferLen);

	// get the size of the buffer required to hold an encoded version of
	// this object
	int GetEncodeBufferSize() const;

	// encode this object into the buffer.  buffer size must be large enough
	// to hold the byte stream or the method will fail
	BOOL Encode(unsigned char * apBytes, int aBufferSize);

	// line number error occurred on
	int GetLineNumber() const
	{ return mLineNumber; }

	void SetLineNumber(int aLine)
	{ mLineNumber = aLine; }


	// time of failure
	time_t GetFailureTime() const
	{ return (time_t) mFailureTime; }

	void SetFailureTime(time_t aFailureTime)
	{ mFailureTime = aFailureTime; }


	// time of metered
	time_t GetMeteredTime() const
	{ return (time_t) mMeteredTime; }

	void SetMeteredTime(time_t aMeteredTime)
	{ mMeteredTime = aMeteredTime; }


	// IP address as four bytes
	const unsigned char * GetIPAddress() const
	{ return mIPAddress; }

	void SetIPAddress(const unsigned char * apAddress);

	// takes a IP address as a string in the following format: %d.%d.%d.%d
	void SetIPAddressAsString(const char * apAddress);

	// IP address as a string
	void GetIPAddressAsString(std::string & arIP);


	// code of error
	ErrorObject::ErrorCode GetErrorCode() const
	{ return mErrorCode; }

	void SetErrorCode(ErrorObject::ErrorCode aCode)
	{ mErrorCode = aCode; }

	BOOL GetIsCompound() const
	{ return mIsCompound; }

	void SetIsCompound(BOOL val)
	{ mIsCompound = val; }


	// MSIX UID of session that failed
	const unsigned char * GetSessionID() const
	{ return mSessionID; }

	void SetSessionID(const unsigned char aUID[])
	{ memcpy(mSessionID, aUID, sizeof(mSessionID)); }


	// MSIX UID of the root of the compound the
	// session was part of.  All zeros if not part of a compound
	const unsigned char * GetRootID() const;

	void SetRootID(const unsigned char aUID[]);


	// MSIX UID of session set containing the failed session
	const unsigned char * GetSessionSetID() const;
	void SetSessionSetID(const unsigned char aUID[]);

	// MSIX UID of session that failed
	const unsigned char * GetBatchID() const;
	void SetBatchID(const unsigned char aUID[]);


	// error message
	const std::string & GetErrorMessage() const
	{ return mErrorMessage; }

	void SetErrorMessage(const char * apMessage)
	{ mErrorMessage = apMessage; }


	// stage name error occurred in
	const std::string & GetStageName() const
	{ return mStageName; }

	void SetStageName(const char * apStageName)
	{ mStageName = apStageName; }


	// plug-in name where error occurred
	const std::string & GetPlugInName() const
	{ return mPlugInName; }

	void SetPlugInName(const char * apPlugInName)
	{ mPlugInName = apPlugInName; }


	// module name where error occurred
	const std::string & GetModuleName() const
	{ return mModuleName; }

	void SetModuleName(const char * apModuleName)
	{ mModuleName = apModuleName; }


	// procedure name where error occurred
	const std::string & GetProcedureName() const
	{ return mProcedureName; }

	void SetProcedureName(const char * apProcedureName)
	{ mProcedureName = apProcedureName; }


	// MSIX message
	void GetMessage(const char * * apMessage, int & aMessageLength);
	void SetMessage(const char * apMessage, int aMessageLength);


	// account id for Payee (if known) or -1
	long GetPayeeID() const
	{ return mAccountID; }

	void SetPayeeID(long aPayeeID)
	{ mAccountID = aPayeeID; }

 	// account ID for Payer (if known) or -1
	long GetPayerID() const
	{ return mPayerID; }

	void SetPayerID(long aPayerID)
	{ mPayerID = aPayerID; }

	// service ID
	long GetServiceID() const
	{ return mServiceID; }

	void SetServiceID(long aServiceID)
	{ mServiceID = aServiceID; }


	//4.0
	long GetScheduleSessionID() const
	{ return mScheduleSessionID; }

	void SetScheduleSessionID(long aScheduleSessionID)
	{ mScheduleSessionID = aScheduleSessionID; }

	long GetScheduleSessionSetID() const
	{ return mScheduleSessionSetID; }

	void SetScheduleSessionSetID(long aScheduleSessionSetID)
	{ mScheduleSessionSetID = aScheduleSessionSetID; }



public:
	bool operator ==(const SessionErrorObject & arObj) const
	{ ASSERT(0); return FALSE; }

private:
	std::string mErrorMessage;
	std::string mStageName;
	std::string mPlugInName;
	std::string mModuleName;
	std::string mProcedureName;

	// the message itself might be binary so we don't use a string
	char * mpMessage;
	int mMessageLength;
};


class BatchErrorObject
	: private SessionError,
		public ObjectWithError			// used for encode/decode problems
{
public:
	// initialize this object from a buffer of bytes (normally an error message)
	BOOL Decode(const unsigned char * apBytes, int aBufferLen);

	// get the size of the buffer required to hold an encoded version of
	// this object
	int GetEncodeBufferSize() const;

	// encode this object into the buffer.  buffer size must be large enough
	// to hold the byte stream or the method will fail
	BOOL Encode(unsigned char * apBytes, int aBufferSize);

	// line number error occurred on
	int GetLineNumber() const
	{ return mLineNumber; }

	void SetLineNumber(int aLine)
	{ mLineNumber = aLine; }


	// time of failure
	time_t GetFailureTime() const
	{ return (time_t) mFailureTime; }

	void SetFailureTime(time_t aFailureTime)
	{ mFailureTime = aFailureTime; }


	// time of metered
	time_t GetMeteredTime() const
	{ return (time_t) mMeteredTime; }

	void SetMeteredTime(time_t aMeteredTime)
	{ mMeteredTime = aMeteredTime; }


	// IP address as four bytes
	const unsigned char * GetIPAddress() const
	{ return mIPAddress; }

	void SetIPAddress(const unsigned char * apAddress);


	// IP address as a string
	void GetIPAddressAsString(std::string & arIP);


	// code of error
	ErrorObject::ErrorCode GetErrorCode()
	{ return mErrorCode; }

	void SetErrorCode(ErrorObject::ErrorCode aCode)
	{ mErrorCode = aCode; }


	// MSIX UID of session that failed
	const unsigned char * GetSessionID() const
	{ return mSessionID; }

	void SetSessionID(const unsigned char aUID[])
	{ memcpy(mSessionID, aUID, sizeof(mSessionID)); }


	// MSIX UID of the root of the compound the
	// session was part of.  All zeros if not part of a compound
	const unsigned char * GetRootID() const;
	void SetRootID(const unsigned char aUID[]);


	// MSIX UID of batch containing the failed session
	const unsigned char * GetSessionSetID() const;
	void SetSessionSetID(const unsigned char aUID[]);


	// error message
	const std::string & GetErrorMessage() const
	{ return mErrorMessage; }

	void SetErrorMessage(const char * apMessage)
	{ mErrorMessage = apMessage; }


	// stage name error occurred in
	const std::string & GetStageName() const
	{ return mStageName; }

	void SetStageName(const char * apStageName)
	{ mStageName = apStageName; }


	// plug-in name where error occurred
	const std::string & GetPlugInName() const
	{ return mPlugInName; }

	void SetPlugInName(const char * apPlugInName)
	{ mPlugInName = apPlugInName; }


	// module name where error occurred
	const std::string & GetModuleName() const
	{ return mModuleName; }

	void SetModuleName(const char * apModuleName)
	{ mModuleName = apModuleName; }


	// procedure name where error occurred
	const std::string & GetProcedureName() const
	{ return mProcedureName; }

	void SetProcedureName(const char * apProcedureName)
	{ mProcedureName = apProcedureName; }


	// account ID for Payee (if known) or -1
	long GetPayeeID() const
	{ return mAccountID; }

	void SetPayeeID(long aPayeeID)
	{ mAccountID = aPayeeID; }

 	// account ID for Payer (if known) or -1
	long GetPayerID() const
	{ return mPayerID; }

	void SetPayerID(long aPayerID)
	{ mPayerID = aPayerID; }

	// MSIX message
	const std::string & GetMessage() const
	{ return mMessage; }

	void SetMessage(const char * apMessage)
	{ mMessage = apMessage; }


	// service ID
	long GetServiceID() const
	{ return mServiceID; }

	void SetServiceID(long aServiceID)
	{ mServiceID = aServiceID; }

public:
	bool operator ==(const SessionErrorObject & arObj) const
	{ ASSERT(0); return FALSE; }

private:
	std::string mErrorMessage;
	std::string mStageName;
	std::string mPlugInName;
	std::string mModuleName;
	std::string mProcedureName;
	std::string mMessage;
};



#endif /* _SESSIONERR_H */
