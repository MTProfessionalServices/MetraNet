/**************************************************************************
 * @doc SDKCON
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
 * $Header: sdkcon.h, 41, 11/14/2002 11:43:24 AM, Raju Matta$
 *
 * @index | SDKCON
 ***************************************************************************/

#ifndef _SDKCON_H
#define _SDKCON_H

// A couple of constants
#define METERING_SDK_SCRIPT "/msix/listener.dll" // Move this to the correct subclass
#define SOAP_SDK_SCRIPT "/Batch/Listener.asmx" // Move this to the correct subclass
#define NETMETER_PARSE_BUFFER_SIZE 4096
#define METRATECH_SDK_USER_AGENT "MetraTech Metering SDK 1.0.0a1-NT"

#define SOAP_CALL_CREATE							0
#define SOAP_CALL_LOADBYNAME					1
#define SOAP_CALL_LOADBYID						2
#define SOAP_CALL_LOADBYUID						3
#define SOAP_CALL_MARKASFAILED				4
#define SOAP_CALL_MARKASDISMISSED			5
#define SOAP_CALL_MARKASCOMPLETED			6
#define SOAP_CALL_UPDATEMETEREDCOUNT	7
#define SOAP_CALL_MARKASACTIVE			  8
#define SOAP_CALL_MARKASBACKOUT			  9


#define WININET_DLL_NAME "wininet.dll"

// don't import or export the definitions
#ifdef UNIX

#define USE_SIZE
#define USE_TIME
#include "unix_hacks.h"

//#include "metraunix.h"
#include <synch.h>
#include <wchar.h>
#endif

#include "mtsdk.h"

#include <string>

#include "MSIX.h"
//#include "mtcompress.h"
#include "errobj.h"
#include "mtsha.h"

#include <pipemessages.h>

class MTDecimalVal;

#ifdef UNIX 
#include <strstream>
#endif

#ifdef WIN32
#include <sstream>
#include <win32net.h>
#endif

#ifdef UNIX
#include <unixnet.h>
#endif

#ifdef SDK_LOGGING

void MtSDKLogDebug(const char * apFormat, ...);
void MtSDKLogInfo(const char * apFormat, ...);

#define SDK_LOG_DEBUG MtSDKLogDebug
#define SDK_LOG_INFO MtSDKLogInfo

#else // SDK_LOGGING

// this is like how MFC defines TRACE with debugging off
// NOTE: unless optimization is on, the strings will still appear
// in the EXE.  With optimization on, the compiler will
// detect that the strings are dead code and eliminate them
inline void SDKLogNullDebug(const char *, ...) { }
inline void SDKLogNullInfo(const char *, ...) { }
#define SDK_LOG_DEBUG 1 ? (void)0 : ::SDKLogNullDebug
#define SDK_LOG_INFO 1 ? (void)0 : ::SDKLogNullInfo

#endif // SDK_LOGGING

using std::sort;

// @cmember 
void EnableLogging(MTDebugLogLevel aLevel, FILE * apLogStream);

#if 0
int FillStringBuffer(const string & arStr, char * apBuffer, int aBuffSize);
int FillStringBuffer(const wstring & arStr, wchar_t * apBuffer, int aBuffSize);
#endif


class MeteringErrorImp : public MTMeterError
{
public:
	MeteringErrorImp(const ErrorObject * apErr);

	virtual ~MeteringErrorImp();

	// @cmember Return the error code
	virtual unsigned long GetErrorCode() const;

	// @cmember Return the time the error occurred.
	virtual time_t GetErrorTime() const;

	// @cmember Get the error message in unicode
	virtual BOOL GetErrorMessage(wchar_t * apBuffer, int & arBufferSize) const;

	// @cmember Get the error message in ascii
	virtual int GetErrorMessage(char * apBuffer, int & aBufferSize) const;

	// @cmember Return extra info important to the programmer
	virtual int GetErrorMessageEx(char * apBuffer, int & aBufferSize) const;
	virtual int GetErrorMessageEx(wchar_t * apBuffer, int & aBufferSize) const;

	const ErrorObject * GetErrorObject() const;
private:
	ErrorObject mError;
};

class MeteringServer;
class MeteringSessionImp;
class MeteringSessionSetImp;
class MeteringBatchImp;

typedef list<MSIXSessionReference *> MSIXSessionRefList;
typedef std::map<std::string, MSIXSessionStatus *> MSIXSessionStatusMap;

class NetMeterAPI : public ObjectWithError
{
public:
  // @cmember 
  //   Constructor
  NetMeterAPI(void);

  // @cmember 
  //   Destructor
  ~NetMeterAPI(void);

	virtual BOOL Init();
	virtual BOOL Close();

	virtual MeteringSessionImp * CreateSession(const char * apName, 
                                             BOOL IsChild = FALSE);

	virtual MeteringSessionSetImp * CreateSessionSet();

	virtual MeteringBatchImp * CreateBatch(NetMeterAPI* apMsixAPI);
	virtual MeteringBatchImp * Refresh(const char * UID, NetMeterAPI* apMsixAPI);
	virtual MeteringBatchImp * LoadBatchByName(const char * name, const char * nmspace, const char* seqnumber, NetMeterAPI* apMsixAPI);
	virtual MeteringBatchImp * LoadBatchByUID(const char * UID, NetMeterAPI* apMsixAPI);

	virtual BOOL MarkAsFailed(const char* UID, const char* comment, NetMeterAPI* apMsixAPI);
	virtual BOOL MarkAsDismissed(const char* UID, const char* comment, NetMeterAPI* apMsixAPI);
	virtual BOOL MarkAsCompleted(const char* UID, const char* comment, NetMeterAPI* apMsixAPI);
	virtual BOOL MarkAsActive(const char* UID, const char* comment, NetMeterAPI* apMsixAPI);
	virtual BOOL MarkAsBackout(const char* UID, const char* comment, NetMeterAPI* apMsixAPI);
	virtual BOOL UpdateMeteredCount(const char* UID, int meteredCount, NetMeterAPI* apMsixAPI);

	virtual BOOL MeterFile(char * FileName);

	virtual BOOL CommitSessionSet(
		const MeteringSessionSetImp & arSessionSet,
		MSIXTimestamp aTimestamp,
		const char * apUpdateId);

	virtual BOOL CommitBatch(
		MeteringBatchImp & arBatch,
		int aAction);

	virtual BOOL ToXML(
		const MeteringSessionSetImp & arSessionSet,
		MSIXTimestamp aTimestamp,
		const char * apUpdateId,
		std::string & arBuffer);

	// Methods that handle server config
	virtual void AddHost(MeteringServer * apServer);
	virtual void ClearHostList();
	virtual MeteringServer * CurrentMeteringServer() const;
	virtual MeteringServer * NextMeteringServer(const MeteringServer * apFirstServer);

	// Methods that handle connection config
	virtual void SetConnectTimeout(int aTimeout);
	virtual int GetConnectTimeout() const;
	virtual void SetConnectRetries(int aRetries);
	virtual int GetConnectRetries() const;
  virtual void SetProxyData(string proxyData);
	virtual string GetProxyData() const;


private:

  string mLocalModeDirectory;
  char mCompressionCodebook[256]; // path to codebook
  BOOL mCompression; // is compression enabled?

protected:

	virtual BOOL SubmitNetRequest(NetStreamConnection * apConnection, string apStreamedObj, string & response);

	// @cmember collections of metering servers supplied by the user
	typedef vector<MeteringServer *> MeteringServerList;
	MeteringServerList mHosts;

	// @cmember current host to send messages to
	int mCurrentHost;

	// @cmember connection to the network
	NetStream * mpNetStream;
	string mProxyName;

#ifdef WIN32
	CRITICAL_SECTION mNetworkGuard;
#endif
#ifdef UNIX
	sema_t mNetworkGuard;
#endif


#ifdef WIN32
	CRITICAL_SECTION mRecordGuard;
#endif
#ifdef UNIX
	sema_t mRecordGuard;
#endif


};


class MeteringSessionImp : public MTMeterSession, public MSIXSession
{
public:
	MeteringSessionImp(NetMeterAPI * apAPI);
	virtual ~MeteringSessionImp();

	virtual unsigned long GetLastError() const;
	virtual MTMeterError * GetLastErrorObject() const;

	virtual BOOL Save();

	virtual BOOL Close();

	virtual BOOL ToXML(char * buffer, int & bufferSize);

	virtual void GetSessionID(char * sessionId) const;

	virtual void GetReferenceID(char * referenceId) const;

	virtual BOOL DetachChild(const MTMeterSession * apChild);

	void SetParent(MTMeterSession * apParent);

	// Unicode/direct version
	virtual BOOL InitProperty(const char * apName,
														const wchar_t * apVal);

	// ASCII helper function
	virtual BOOL InitProperty(const char * apName,
														const char * apAsciiVal);

	// INT32  and BOOL version
	virtual BOOL InitProperty(const char * apName,	int aInt32, 
												SDKPropertyTypes ptype = SDK_PROPTYPE_INTEGER);

	// INT64 version
	virtual BOOL InitProperty(const char * apName,	
                            LONGLONG aInt64);

	// float version
	virtual BOOL InitProperty(const char * apName,
														float aFloat);

	// double version
	virtual BOOL InitProperty(const char * apName,
														double aDouble);

	// timestamp version
	virtual BOOL InitProperty(const char * apName,
											time_t aTimestamp, 
											SDKPropertyTypes ptype = SDK_PROPTYPE_DATETIME );

	// decimal version
	virtual BOOL InitProperty(const char * apName, 
														const MTDecimalValue * apDecVal);


	// Unicode/direct version
	virtual BOOL SetProperty(const char * apName,
													 const wchar_t * arVal);

	// ASCII helper function
	virtual BOOL SetProperty(const char * apName,
													 const char * apAsciiVal);

	// INT32 and BOOL version
	virtual BOOL SetProperty(const char * apName,
												int aInt32, 
												SDKPropertyTypes ptype = SDK_PROPTYPE_INTEGER );

	// INT64 version
	virtual BOOL SetProperty(const char * apName,
												   LONGLONG aInt64);

	// float version
	virtual BOOL SetProperty(const char * apName,
													 float aFloat);

	// double version
	virtual BOOL SetProperty(const char * apName,
													 double aDouble);

	// timestamp version
	virtual BOOL SetProperty(const char * apName,
												time_t aTimestamp, 
												SDKPropertyTypes ptype = SDK_PROPTYPE_DATETIME );

	// decimal version
	virtual BOOL SetProperty(const char * apName,
													const MTDecimalValue * apDecVal);


	// Unicode/direct version
	virtual BOOL GetProperty(const char * apName, const wchar_t * * apVal);

	// ASCII helper function
	virtual BOOL GetProperty(const char * apName, const char * * apVal);

	// INT32 and BOOL version
	virtual BOOL GetProperty(const char * apName,
									int & arInt32, 
									SDKPropertyTypes ptype = SDK_PROPTYPE_INTEGER);

	// INT64 version
	virtual BOOL GetProperty(const char * apName,
									LONGLONG & arInt64);

	// float version
	virtual BOOL GetProperty(const char * apName,
													 float & arFloat);

	// double version
	virtual BOOL GetProperty(const char * apName,
													 double & arDouble);

	// timestamp version
	virtual BOOL GetProperty(const char * apName,
									time_t & arTimestamp, 
									SDKPropertyTypes ptype = SDK_PROPTYPE_DATETIME );

	// decimal version
	virtual BOOL GetProperty(const char * apName,
													const MTDecimalValue * * apDecVal);


	virtual MTMeterSession * CreateChildSession(const char * apName);

	virtual MTMeterSession * GetSessionResults();

	// Prevents session destructor from deleting results
	// If you use this, you are responsible for freeing results
	// MTMeterSession object.
	virtual void DetachSessionResults();

	// WARNING: These are deprecated.  They will disappear.
	// Use [Get|Set]RequestResponse() below instead
	virtual void SetResultRequestFlag(BOOL aGetFeedback /* = TRUE */);
	virtual BOOL GetResultRequestFlag();
	// End warning

	virtual void SetRequestResponse(BOOL aGetFeedback /* = TRUE */);
	virtual BOOL GetRequestResponse();

	void SetName(const char * apName);

	// virtual void GetName(char *output);

	void GenerateUid();

	void MarkDirty();

	void AddChild(MTMeterSession * apChild);

	//const MSIXUid & GetUid() const;

	enum SessionState
	{
		BEFORE_BEGIN,
		CLEAN,
		DIRTY,
		COMMITTED
	};

	BOOL UpdateNeeded(SessionState aState) const;

	// @cmember List all sessions above or below this one that need updating.
	void SessionsForUpdate(
		MSIXSessionRefList & arList, SessionState aState);

	// @cmember Recursively traverse the tree of sessions and add sessions
	//  that need updating to the list.
	void Traverse(MSIXSessionRefList & arList,
								SessionState aState);

	void SetState(SessionState aState);
	SessionState GetState() const;

	void SetPartOfSessionSet(BOOL aIsPart);
	BOOL GetPartOfSessionSet() const;

	MeteringSessionImp * GetParent() const
	{ return mpParent; }

	MeteringSessionImp * GetResults() const
	{ return mpResults; }

	void SetResults(MeteringSessionImp * apResults)
	{ mpResults = apResults; }

	MeteringBatchImp* GetBatch() const;
	void SetBatch(MeteringBatchImp* pBatch);

   // BEGIN: The following methods reflect performance related changes
   MeteringSessionSetImp* GetMeteringSessionSet() const;
   void SetMeteringSessionSet(MeteringSessionSetImp *pMeteringSessionSetImp);

   // Creates the XML representation of the session using the 
   // names and values of the properties passed into the method. 
   // In addition, if any properties have been set on this session,
   // they will be added to the stream as well.
   BOOL CreatePropertyStream(string name, string value);
   BOOL CreateExistingPropertyStream();

   void CreatePropertiesHeader();
   void CreatePropertiesFooter();
   void CreateHeader();
   void CreateFooter();

   BOOL IsFastMode() const;
   void SetFastMode(BOOL fastMode);
   BOOL SetFastModeError(string methodName);
   // END:


protected:
	NetMeterAPI * mpAPI;

	// @cmember Clear error status
	// @devnote it is optional to call this function.
	// objects are not required to clear errors after successful calls.
	void ClearError();

public:
	// @cmember Convenience function to set the error from another error
	//  object.  Also sets the error pending flag.
	void SetError(const ErrorObject * apError);

	// @cmember An error is pending with the given information
	void SetError(ErrorObject::ErrorCode aCode,
				const char * apModule, int aLine, const char * apProcedure);

	const MSIXSessionRefList & GetChildSessions() const
	{ return mChildren; }


private:
	// @cmember holds pointer to error object (either mpLastError or
	// an error coming from another object).
	//MeteringErrorImp mError;
	ErrorObject * mpErrObj;
	MeteringSessionImp * mpParent;
	MSIXSessionRefList mChildren;
	MeteringSessionImp * mpResults;
	SessionState mState;
	BOOL mPartOfSessionSet;
	MeteringBatchImp* mpBatch;

	// HACK: we have to own the memory used by MTDecimalValue objects
	// so we need to store them here
	std::list<MTDecimalValue *> mTemporaryDecimals;

   // BEGIN: The following methods reflect performance related changes
   MeteringSessionSetImp *mpMeteringSessionSetImp;
   BOOL inFastMode;
   // END:

};


class StandaloneMeteringSessionImp : public MTMeterSession
{
public:
	StandaloneMeteringSessionImp(MeteringSessionSetImp * sessionSet);
	virtual ~StandaloneMeteringSessionImp();

	MTMeterSession * CreateSession(const char * name);

	virtual unsigned long GetLastError() const;
	virtual MTMeterError * GetLastErrorObject() const;

	virtual BOOL Save();

	virtual BOOL Close();

	virtual BOOL ToXML(char * buffer, int & bufferSize);

	virtual void GetSessionID(char * sessionId) const;

	virtual void GetReferenceID(char * referenceId) const;

	// Unicode/direct version
	virtual BOOL InitProperty(const char * apName,
														const wchar_t * apVal);

	// ASCII helper function
	virtual BOOL InitProperty(const char * apName,
														const char * apAsciiVal);

	// INT32  and BOOL version
	virtual BOOL InitProperty(const char * apName,	int aInt32, 
												SDKPropertyTypes ptype = SDK_PROPTYPE_INTEGER);

	// INT64 version
	virtual BOOL InitProperty(const char * apName,	
                            LONGLONG aInt64);

	// float version
	virtual BOOL InitProperty(const char * apName,
														float aFloat);

	// double version
	virtual BOOL InitProperty(const char * apName,
														double aDouble);

	// timestamp version
	virtual BOOL InitProperty(const char * apName,
											time_t aTimestamp, 
											SDKPropertyTypes ptype = SDK_PROPTYPE_DATETIME );

	// decimal version
	virtual BOOL InitProperty(const char * apName, 
														const MTDecimalValue * apDecVal);


	// Unicode/direct version
	virtual BOOL SetProperty(const char * apName,
													 const wchar_t * arVal);

	// ASCII helper function
	virtual BOOL SetProperty(const char * apName,
													 const char * apAsciiVal);

	// INT32 and BOOL version
	virtual BOOL SetProperty(const char * apName,
												int aInt32, 
												SDKPropertyTypes ptype = SDK_PROPTYPE_INTEGER );

	// INT64 version
	virtual BOOL SetProperty(const char * apName,
													 LONGLONG aInt64);

	// float version
	virtual BOOL SetProperty(const char * apName,
													 float aFloat);

	// double version
	virtual BOOL SetProperty(const char * apName,
													 double aDouble);

	// timestamp version
	virtual BOOL SetProperty(const char * apName,
												time_t aTimestamp, 
												SDKPropertyTypes ptype = SDK_PROPTYPE_DATETIME );

	// decimal version
	virtual BOOL SetProperty(const char * apName,
													const MTDecimalValue * apDecVal);


	// Unicode/direct version
	virtual BOOL GetProperty(const char * apName, const wchar_t * * apVal);

	// ASCII helper function
	virtual BOOL GetProperty(const char * apName, const char * * apVal);

	// INT32 and BOOL version
	virtual BOOL GetProperty(const char * apName,
									int & arInt32, 
									SDKPropertyTypes ptype = SDK_PROPTYPE_INTEGER);

	// INT64 version
	virtual BOOL GetProperty(const char * apName,
									         LONGLONG & arInt64);

	// float version
	virtual BOOL GetProperty(const char * apName,
													 float & arFloat);

	// double version
	virtual BOOL GetProperty(const char * apName,
													 double & arDouble);

	// timestamp version
	virtual BOOL GetProperty(const char * apName,
									time_t & arTimestamp, 
									SDKPropertyTypes ptype = SDK_PROPTYPE_DATETIME );

	// decimal version
	virtual BOOL GetProperty(const char * apName,
													const MTDecimalValue * * apDecVal);


	virtual MTMeterSession * CreateChildSession(const char * apName);

	virtual MTMeterSession * GetSessionResults();

	// Prevents session destructor from deleting results
	// If you use this, you are responsible for freeing results
	// MTMeterSession object.
	virtual void DetachSessionResults();

	// WARNING: These are deprecated.  They will disappear.
	// Use [Get|Set]RequestResponse() below instead
	virtual void SetResultRequestFlag(BOOL aGetFeedback /* = TRUE */);
	virtual BOOL GetResultRequestFlag();
	// End warning

	virtual void SetRequestResponse(BOOL aGetFeedback /* = TRUE */);
	virtual BOOL GetRequestResponse();

   // BEGIN: The following methods reflect performance related changes
   virtual BOOL CreatePropertyStream(string name, string value);
   virtual BOOL CreateExistingPropertyStream();
   virtual void CreatePropertiesHeader();
   virtual void CreatePropertiesFooter();
   virtual void CreateHeader();
   virtual void CreateFooter();

   virtual BOOL IsFastMode() const;
   virtual void SetFastMode(BOOL fastMode);
   // END:


public:
	// get the underlying session set object
	MTMeterSessionSet * GetSessionSet() const
	{ return mpSessionSet; }
	
	// get the underlying session object
	MTMeterSession * GetSession() const
	{ return mpSession; }

protected:
	NetMeterAPI * mpAPI;

private:
	// if true, last call went to the session.  this is used
	// by GetLastError
	mutable BOOL mSessionOp;
	MTMeterSessionSet * mpSessionSet;
	MTMeterSession * mpSession;
};



class MeteringSessionSetImp : public MTMeterSessionSet
{
public:
	MeteringSessionSetImp(NetMeterAPI * apAPI);
	virtual ~MeteringSessionSetImp();

	virtual MTMeterSession * CreateSession(const char * serviceName);

	virtual void GetSessionSetID(char * sessionSetID) const;
	void SetSessionSetID(const char * apUid);

	virtual BOOL Close();

	virtual BOOL ToXML(char * buffer, int & bufferSize);

	virtual void SetTransactionID(const char * transactionID);
	virtual const char * GetTransactionID() const;

	virtual void SetListenerTransactionID(const char * transactionID);
	virtual const char * GetListenerTransactionID() const;

	virtual void SetSessionContext(const char * sessioncontext);
	virtual const char * GetSessionContext() const;

	virtual void SetSessionContextUserName(const char * username);
	virtual const char * GetSessionContextUserName() const;

	virtual void SetSessionContextPassword(const char * password);
	virtual const char * GetSessionContextPassword() const;

	virtual void SetSessionContextNamespace(const char * mtnamespace);
	virtual const char * GetSessionContextNamespace() const;

	virtual unsigned long GetLastError() const;
	virtual MTMeterError * GetLastErrorObject() const;

	MeteringBatchImp* GetBatch() const;
	void SetBatch(MeteringBatchImp* pBatch);

   // BEGIN: The following methods reflect performance related changes
   BOOL IsFastMode() const;
   void SetFastMode(BOOL fastMode);
   BOOL PropertiesInitialized() const;

   std::ostringstream& GetSessionSetStream();
   virtual std::string GetBuffer() const;
   int numSessions;

   // END:


public:
	const MSIXSessionRefList & GetSessions() const
	{ return mSessions; }

private:
	// Convenience function to set the error from another error
	//  object.  Also sets the error pending flag.
	void SetError(const ErrorObject * apError);

	// An error is pending with the given information
	void SetError(ErrorObject::ErrorCode aCode,
				const char * apModule, int aLine, const char * apProcedure);

private:
	ErrorObject * mpErrObj;
	NetMeterAPI * mpAPI;
	NetMeterAPI * mpMsixAPI;
	MSIXSessionRefList mSessions;
	MTMSIXBatchHeader mBatchHeader;

	std::string mTransactionID;
	std::string mListenerTransactionID;

	// ------ 3.0 work ---------
	std::string mSessionContext;
	std::string mSessionContextUserName;
	std::string mSessionContextPassword;
	std::string mSessionContextNamespace;
	// ------ 3.0 work ---------
	std::string mUID;
	MeteringBatchImp* mpBatch;

   // BEGIN: The following methods reflect performance related changes
   BOOL isFastMode;
   BOOL isSessionSetStreamClosed;
   std::ostringstream sessionSetStream;
   // END:

};

class MeteringBatchImp : public MTMeterBatch
{
public:
	MeteringBatchImp(NetMeterAPI * apAPI, NetMeterAPI * apMsixAPI);
	virtual ~MeteringBatchImp();

	// this is the batch ID (integer format)
	virtual void SetBatchID(long ID);
	virtual long GetBatchID() const;

	virtual void SetUID(const char * UID);
	virtual const char * GetUID() const;

	virtual void SetNameSpace(const char * apNameSpace);
	virtual const char * GetNameSpace() const;

	virtual void SetName(const char * apName); 
	virtual const char * GetName() const;

	virtual void SetExpectedCount(long expectedCount);
	virtual long GetExpectedCount() const;

	virtual void SetCompletedCount(long completionCount);
	virtual long GetCompletedCount() const;

	virtual void SetFailureCount(long failureCount);
	virtual long GetFailureCount() const;

	virtual void SetStatus(const char * status);
	virtual const char * GetStatus() const;
	
	virtual time_t GetCreationDate() const;
	virtual void SetCreationDate(time_t & createdate);

	virtual time_t GetCompletionDate() const;
	virtual void SetCompletionDate(time_t & completiondate);

	virtual time_t GetSourceCreationDate() const;
	virtual void SetSourceCreationDate(time_t & sourcecreatedate);
	
	virtual void SetSource(const char * source);
	virtual const char * GetSource() const;

	virtual void SetSequenceNumber(const char * sequencenumber);
	virtual const char * GetSequenceNumber() const;
	
	virtual void SetComment(const char * comment);
	virtual const char * GetComment() const;
	
	virtual void SetMeteredCount(long meteredCount);
	virtual long GetMeteredCount() const;

	virtual MTMeterSession * CreateSession(const char * serviceName);

	virtual MTMeterSessionSet * CreateSessionSet();

  virtual BOOL Refresh();

  virtual BOOL Save();

	virtual BOOL Close();

	virtual BOOL MarkAsFailed();
	virtual BOOL MarkAsDismissed();
	virtual BOOL MarkAsCompleted();
	virtual BOOL MarkAsActive();
	virtual BOOL MarkAsBackout();
	virtual BOOL UpdateMeteredCount();

	virtual unsigned long GetLastError() const;
	virtual MTMeterError * GetLastErrorObject() const;

	//MeteringBatchImp * GetResults() const
	//{ return mpResults; }

protected:
	NetMeterAPI * mpAPI;
	NetMeterAPI * mpMsixAPI;

public:
	// @cmember Convenience function to set the error from another error
	//	object.  Also sets the error pending flag.
	void SetError(const ErrorObject * apError);

	// @cmember An error is pending with the given information
	void SetError(ErrorObject::ErrorCode aCode,
				const char * apModule, int aLine, const char * apProcedure);

	void UpdateMeteredCount(long meteredcount);

private:
	// @cmember holds pointer to error object (either mpLastError or
	// an error coming from another object).
	//MeteringErrorImp mError;
	ErrorObject * mpErrObj;

	long mBatchID;
	std::string mUID;
	std::string mNameSpace;
	std::string mName;
	std::string mSource;
	std::string mSequenceNumber;
	std::string mStatus;
	long mExpectedCount;
	long mFailureCount;
	long mCompletedCount;
	long mMeteredCount;
	time_t mSourceCreationDate;
	time_t mCreationDate;
	time_t mCompletionDate;
	std::string mComment;
	BOOL mIsClosed;
};

/********************* MeteringServer **************/

class MeteringServer : public ObjectWithError
{
public:
	MeteringServer(const char * apServerName, int aPort, BOOL aSecure,
								 const char * apUsername, const char * apPassword);
	virtual ~MeteringServer();

	const char * GetName() const;

	int GetPort() const;
	int GetPriority() const;

	void SetPriority(int Priority);

	BOOL GetSecure() const;

	const char * GetUsername() const;
	const char * GetPassword() const;

	BOOL operator == (const MeteringServer & arServer) const;
	BOOL operator < (const MeteringServer & arServer) const;

	void ReleaseConnection(NetStreamConnection * apNetStream);

	NetStreamConnection * GetFreeConnection(NetStream * conn,
																					const char * apHeaders, const char * apListenerAddress);

private:

#ifdef WIN32
	std::stack<NetStreamConnection *> mConnections;


	CRITICAL_SECTION mConnectionGuard;
#endif

#ifdef UNIX
  // no connection pooling on Unix for now
  //sema_t  mConnectionGuard;
#endif

	const string mServerName;
	string mUsername;
	string mPassword;

	const int mPort;
	const BOOL mSecure;
	int mPriority;
};


#ifdef UNIX

void InitializeCriticalSection(sema_t *s);
void DeleteCriticalSection(sema_t *s);
void EnterCriticalSection(sema_t *s);
void LeaveCriticalSection(sema_t *s);

#endif


#endif /* _SDKCON_H */
