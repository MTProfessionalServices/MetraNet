/**************************************************************************
 * @doc SDKCON
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
 * $Header: sdkcon.cpp, 52, 11/14/2002 11:43:09 AM, Raju Matta$
 ***************************************************************************/

#include <metra.h>
#include <MTUtil.h>
// don't export anything from sdkpub
#define MTSDK_DLL_EXPORT

#include "MTDecimalVal.h"
#include "sdkcon.h"

#include "sdk_msg.h"

#include "MTUtil.h"
#include <mttime.h>

#include "mtfutil.h"    // for file I/O
#include <sys/timeb.h>  // for struct _timeb

#include <strstream>

#include <stdarg.h>
#include <stdio.h>

#include "DBMiscStlUtils.h"
#include "NTThreadLock.h"

#ifdef WIN32
template void destroyPtr(MSIXSessionStatus *);
#endif

MTDebugLogLevel gLogLevel;
FILE * gpLogStream;
NTThreadLock lock;

/*
 * NOTE: these functions are defined even if logging is disabled.
 * the function prototype needs to be there for the macros to work.
 * when SDK_LOGGING is undefined, these function bodies are empty.
 */

#ifdef SDK_LOGGING

void MtSDKLogInfo(const char * apFormat, ...)
{
	if (MT_LOG_INFO < gLogLevel)
		return;

  /*lock.Lock();
  FILE* file = fopen("C:\\sdklog.txt", "a+c");
	va_list argp;
	fprintf(file, "INFO : ");
	va_start(argp, apFormat);
	vfprintf(file, apFormat, argp);
	va_end(argp);
	fprintf(file, "\n");
	fflush(file);

	fclose(file);
  lock.Unlock();*/
}

void MtSDKLogDebug(const char * apFormat, ...)
{
	if (MT_LOG_DEBUG < gLogLevel)
		return;

  /*lock.Lock();
  FILE* file = fopen("C:\\sdklog.txt", "a+c");
	va_list argp;
  char dateTime[MAX_PATH];
  time_t mttime = GetMTTime();
  struct tm  * lTime = localtime (&mttime);
	strftime(dateTime, MAX_PATH, "MetraTime[%m/%d/%y %H:%M:%S=]", lTime);
	fprintf(file, "%s DEBUG: ", dateTime);
	va_start(argp, apFormat);
	vfprintf(file, apFormat, argp);
	va_end(argp);
	fprintf(file, "\n");
	fflush(file);
	fclose(file);
  lock.Unlock();*/
}

void MtSDKEnableLogging(MTDebugLogLevel aLevel, FILE * apLogStream)
{
	gLogLevel = aLevel;
	gpLogStream = apLogStream;
}

#endif // SDK_LOGGING


/****************************************** MeteringErrorImp ***/

MeteringErrorImp::MeteringErrorImp(const ErrorObject * apErr)
{
	mError = *apErr;
}

MeteringErrorImp::~MeteringErrorImp()
{ }

// @cmember Return the error code
unsigned long MeteringErrorImp::GetErrorCode() const
{
	return mError.GetCode();
}

time_t MeteringErrorImp::GetErrorTime() const
{
	return *(mError.GetErrorTime());
}

// @cmember Get the error message in unicode
BOOL MeteringErrorImp::GetErrorMessage(wchar_t * apBuffer, int & arBufferSize) const
{
	wstring msg;
	mError.GetErrorMessage(msg);
	if (arBufferSize == 0)
	{
		arBufferSize = msg.length() + 1;		// +1 for 0
		return TRUE;
	}
	else
	{
		if (!apBuffer)
			return FALSE;

    if (arBufferSize > (int) msg.length())
 		  wcscpy(apBuffer, msg.c_str());
    else
    {
 		  wcsncpy(apBuffer, msg.c_str(), arBufferSize - 1);
		  apBuffer[arBufferSize - 1] = L'\0';
    }
	}
	return TRUE;
}

// @cmember Get the error message in ascii
BOOL MeteringErrorImp::GetErrorMessage(char * apBuffer, int & arBufferSize) const
{
	string msg;
  mError.GetErrorMessage(msg);
	if (arBufferSize == 0)
	{
		arBufferSize = msg.length() + 1;		// +1 for \0
		return TRUE;
	}
	else
	{
		if (!apBuffer)
			return FALSE;

    if (arBufferSize > (int) msg.length())
 		  strcpy(apBuffer, msg.c_str());
    else
    {
 		  strncpy(apBuffer, msg.c_str(), arBufferSize - 1);
		  apBuffer[arBufferSize - 1] = '\0';
    }
	}
	return TRUE;
}

// @cmember Return extra info important to the programmer
BOOL MeteringErrorImp::GetErrorMessageEx(char * apBuffer, int & arBufferSize) const
{
	// NOTE: an extra copy of the string
	string msg = mError.GetProgrammerDetail();
	if (arBufferSize == 0)
	{
		arBufferSize = msg.length() + 1;		// +1 for \0
		return TRUE;
	}
	else
	{
		if (!apBuffer)
			return FALSE;

    if (arBufferSize > (int) msg.length())
 		  strcpy(apBuffer, msg.c_str());
    else
    {
 		  strncpy(apBuffer, msg.c_str(), arBufferSize - 1);
		  apBuffer[arBufferSize - 1] = '\0';
    }
	}
	return TRUE;
}

BOOL MeteringErrorImp::GetErrorMessageEx(wchar_t * apBuffer, int & arBufferSize) const
{
	wstring msg;
	ASCIIToWide (msg, mError.GetProgrammerDetail());

	if (arBufferSize == 0)
	{
		arBufferSize = msg.length() + 1;		// +1 for 0
		return TRUE;
	}
	else
	{
		if (!apBuffer)
			return FALSE;

    if (arBufferSize > (int) msg.length())
 		  wcscpy(apBuffer, msg.c_str());
    else
    {
 		  wcsncpy(apBuffer, msg.c_str(), arBufferSize - 1);
		  apBuffer[arBufferSize - 1] = L'\0';
    }
	}
	return TRUE;
}

const ErrorObject * MeteringErrorImp::GetErrorObject() const
{
	return &mError;
}

/**************************************** MeteringSessionImp ***/

MeteringSessionImp::MeteringSessionImp(NetMeterAPI * apAPI) :
	mpAPI(apAPI),
	mpErrObj(NULL),
	mpResults(NULL),
	mpBatch(NULL),
	mpParent(NULL),
   inFastMode(FALSE) // !PERF
{
	//SDK_LOG_DEBUG("MeteringSessionImp::MeteringSessionImp");
	mPartOfSessionSet = FALSE;
	SetState(BEFORE_BEGIN);
}

MeteringSessionImp::~MeteringSessionImp()
{
	ClearError();

	// detach from our parent if there is one
	if (mpParent)
		mpParent->DetachChild(this);

	// delete all of our children
	MSIXSessionRefList::iterator it;
	for (it = mChildren.begin(); it != mChildren.end(); it++)
	{
		MeteringSessionImp * child = static_cast<MeteringSessionImp *>(*it);
		// parent is set to NULL because we don't want to require the
		// child to call detatch.  We do all the detaching right here.
		child->SetParent(NULL);
		delete child;
	}

	// delete synchronous response, if any
	if (mpResults) {
		delete mpResults;
		mpResults = NULL;
	}

	std::list<MTDecimalValue *>::iterator decimalit;
	for (decimalit = mTemporaryDecimals.begin();
			 decimalit != mTemporaryDecimals.end();
			 decimalit++)
	{
		MTDecimalValue * decVal = *decimalit;
		delete decVal;
	}
	mTemporaryDecimals.clear();

   mpMeteringSessionSetImp = NULL; // PERF!

}


void MeteringSessionImp::GetSessionID(char * sessionId) const
{
	const MSIXUid & uid = MSIXSession::GetUid();
	const string & uidString = uid.GetUid();

	// TODO: what is the correct length
	ASSERT(uidString.length() <= 25 && uidString.length() > 0);
	int equals = 0;
	int i;
	for (i = uidString.length() - 1; uidString[i] == '='; i--)
		;

	strncpy(sessionId, uidString.c_str(), i + 1);
	sessionId[i + 1] = '\0';
}


// TODO: wierd interface
void MeteringSessionImp::GetReferenceID(char * referenceId) const

{
	unsigned char sessionID[16];
	if (!MSIXUidGenerator::Decode(sessionID, GetUid()))
		ASSERT(0);

	wstring wstrRef = CreatePrintableRefID_STL(sessionID);
	string cstrRef = ascii(wstrRef);

	strcpy(referenceId, cstrRef.c_str());
	//for (int i = 0; i < wstrRef.length(); i++)
	//referenceId[i] = (char) wstrRef(i);
	//referenceId[wstrRef.length()] = '\0';
}


unsigned long MeteringSessionImp::GetLastError() const
{
	if (!mpErrObj)
		return 0;
	return mpErrObj->GetCode();
}

MTMeterError * MeteringSessionImp::GetLastErrorObject() const
{
	if (!mpErrObj)
		return NULL;

	// copy it and return a new one
	MeteringErrorImp * imp = new MeteringErrorImp(mpErrObj);
	return imp;
}

// @mfunc Clear error status
// @devnote it is optional to call this function.
// objects are not required to clear errors after successful calls.
void MeteringSessionImp::ClearError()
{
	if (mpErrObj)
		delete mpErrObj;
	mpErrObj = NULL;
}


// @mfunc An error is pending with the given information
// @parm error code
// @parm module/filename
// @parm line number
// @parm procedure name
void MeteringSessionImp::SetError(
	ErrorObject::ErrorCode aCode, const char * apModule,
	int aLine, const char * apProcedure)
{
	if (!mpErrObj)
		mpErrObj = new ErrorObject(aCode, apModule, aLine, apProcedure);
	else
		mpErrObj->Init(aCode, apModule, aLine, apProcedure);
}

// @mfunc Convenience function to set the error from another error
//	object.  Also sets the error pending flag.
// @parm set from this object
void MeteringSessionImp::SetError(const ErrorObject * apError)
{
	if (!mpErrObj)
		mpErrObj = new ErrorObject(*apError);
	else
		*mpErrObj = *apError;
}

BOOL MeteringSessionImp::Save()
{
	// standalone sessions go through StandaloneMeteringSessionImp.
	// session sets are closed as a set.  Child sessions cannot be closed.
	// therefore, there is no case where this succeeds.
	SetError(MT_ERR_CANNOT_CLOSE, ERROR_MODULE, ERROR_LINE,
					 "MeteringSessionImp::Save");
	return FALSE;
}

BOOL MeteringSessionImp::Close()
{
	// standalone sessions go through StandaloneMeteringSessionImp.
	// session sets are closed as a set.  Child sessions cannot be closed.
	// therefore, there is no case where this succeeds.
	SetError(MT_ERR_CANNOT_CLOSE, ERROR_MODULE, ERROR_LINE,
					 "MeteringSessionImp::Close");
	return FALSE;
}

BOOL MeteringSessionImp::ToXML(char * buffer, int & bufferSize)
{
	SetError(MT_ERR_NOT_IMPLEMENTED, ERROR_MODULE, ERROR_LINE,
					 "MeteringSessionImp::ToXML");
	return FALSE;
}


BOOL MeteringSessionImp::DetachChild(const MTMeterSession * apChild)
{
	// NOTE: don't want to compare everything by value, so we
	// don't use removeNext here.
	MSIXSessionRefList::iterator it;
	for (it = mChildren.begin(); it != mChildren.end(); it++)
	{
		MeteringSessionImp * sess = static_cast<MeteringSessionImp *>(*it);
		if (sess == apChild)
		{
			// it will point just after the element removed from the list
			// NOTE: this routine should not delete the child!
			//it.remove();
			it = mChildren.erase(it);
			return TRUE;
		}
	}
	return FALSE;
}


// @mfunc List all sessions above or below this one that need updating.
// @parm List to add sessions to.
void MeteringSessionImp::SessionsForUpdate(
	MSIXSessionRefList & arList, SessionState aState)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::SessionsForUpdate");

	// if this session doesn't need an update
	// then nothing above it or below it will be affected
	if (!UpdateNeeded(aState))
		return;

	//
	// this calculation works for compound or atomic transactions
	//

	// add all the parents to the list of transactions to update
	for (MeteringSessionImp * parent = GetParent();
			 parent; parent = parent->GetParent())
		arList.push_back(parent);

	// this index will be the pointer to this after we're done
	// anything before it in the list is a parent.	Anything after it is
	// a child.
	//int ourIndex = arList.size();

	// collect this session and all the children that need updating
	// into the list
	Traverse(arList, aState);

	// there must be at least one in the list because we need an update
	// ourself.
	ASSERT(arList.size() > 0);

	// make sure ourIndex is correct
	//ASSERT(arList[ourIndex] == this);

	//return ourIndex;
}



BOOL MeteringSessionImp::UpdateNeeded(SessionState aState) const
{
	//SDK_LOG_DEBUG("MeteringSessionImp::UpdateNeeded");

	// NOTE: since MarkDirty marks parent sessions
	// dirty as well, we don't have to examine the state of the children
	if (aState == CLEAN)
		return (mState == BEFORE_BEGIN || mState == DIRTY);
	else if (aState == COMMITTED)
		return (mState != COMMITTED);

	// aState has to be CLEAN or COMMITTED
	ASSERT(0);
	return FALSE;
}


// @mfunc Recursively traverse the tree of sessions and add sessions
//	that need updating to the list.
// @parm List to add sessions that need updating
void MeteringSessionImp::Traverse(MSIXSessionRefList & arList,
																	SessionState aState)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::Traverse");

	if (UpdateNeeded(aState))
	{
		arList.push_back(this);

		MSIXSessionRefList::iterator it;
		for (it = mChildren.begin(); it != mChildren.end(); it++)
		{
			MeteringSessionImp * sess = static_cast<MeteringSessionImp *>(*it);
			sess->Traverse(arList, aState);
		}
	}
}


BOOL MeteringSessionImp::InitProperty(const char * apName,
																		 const wchar_t * apVal)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::InitProperty(%s)", apName);
   // !PERF
   if (SetFastModeError("MeteringSessionImp::InitProperty"))
   {
      return FALSE;
   }

	MSIXString str(apVal);
	if (!MSIXSession::AddProperty(apName, str))
	{
		SetError(MT_ERR_DUPLICATE_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::InitProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}

// ASCII helper function
BOOL MeteringSessionImp::InitProperty(const char * apName,
																		 const char * apAsciiVal)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::InitProperty(%s,%s)", apName, apAsciiVal);
   // !PERF
   if (SetFastModeError("MeteringSessionImp::InitProperty"))
   {
      return FALSE;
   }

	if (!MSIXSession::AddProperty(apName, apAsciiVal))
	{
		SetError(MT_ERR_DUPLICATE_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::InitProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}

// INT32 version
BOOL MeteringSessionImp::InitProperty(const char * apName, int aInt32, SDKPropertyTypes ptype)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::InitProperty(%s,%d)", apName, aInt32);
   // !PERF
   if (SetFastModeError("MeteringSessionImp::InitProperty"))
   {
      return FALSE;
   }

	if (((ptype == SDK_PROPTYPE_BOOLEAN) && !MSIXSession::AddBooleanProperty(apName, aInt32)) ||
			((ptype == SDK_PROPTYPE_INTEGER) && !MSIXSession::AddProperty(apName, aInt32)))
	{
		SetError(MT_ERR_DUPLICATE_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::InitProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}

// INT64 version
BOOL MeteringSessionImp::InitProperty(const char * apName, 
                                      LONGLONG aInt64)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::InitProperty(%s,%d)", apName, aInt32);
   // !PERF
   if (SetFastModeError("MeteringSessionImp::InitProperty"))
   {
      return FALSE;
   }

	if (!MSIXSession::AddInt64Property(apName, aInt64))
	{
		SetError(MT_ERR_DUPLICATE_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::InitProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}

// float version
BOOL MeteringSessionImp::InitProperty(const char * apName,
																		 float aFloat)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::InitProperty(%s,%e)", apName, (double) aFloat);
   // !PERF
   if (SetFastModeError("MeteringSessionImp::InitProperty"))
   {
      return FALSE;
   }

	if (!MSIXSession::AddProperty(apName, aFloat))
	{
		SetError(MT_ERR_DUPLICATE_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::InitProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}

// double version
BOOL MeteringSessionImp::InitProperty(const char * apName,
																		 double aDouble)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::InitProperty(%s,%e)", apName, aDouble);
   // !PERF
   if (SetFastModeError("MeteringSessionImp::InitProperty"))
   {
      return FALSE;
   }

	if (!MSIXSession::AddProperty(apName, aDouble))
	{
		SetError(MT_ERR_DUPLICATE_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::InitProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}

// timestamp version
BOOL MeteringSessionImp::InitProperty(const char * apName, time_t aTimestamp, SDKPropertyTypes ptype)
{
	// TODO: can we log the time as well?
	//SDK_LOG_DEBUG("MeteringSessionImp::InitProperty(%s)", apName);
   // !PERF
   if (SetFastModeError("MeteringSessionImp::InitProperty"))
   {
      return FALSE;
   }
	
	BOOL bResult;
	switch (ptype)
	{
	case SDK_PROPTYPE_BIGINTEGER:
		bResult = MSIXSession::AddInt64Property(apName, (__int64) aTimestamp);
		break;
	case SDK_PROPTYPE_DATETIME:
	default:
		if (aTimestamp < 0)
		{
			ErrorObject * obj = new ErrorObject (MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE,
																"MeteringSessionImp::InitProperty");
			obj->SetProgrammerDetail((const char *)"Invalid date value specified");
			SetError (obj);
			delete obj;
			return FALSE;
		}
		bResult = MSIXSession::AddTimestampProperty(apName, aTimestamp);
	}

	if (!bResult)
	{
		SetError(MT_ERR_DUPLICATE_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::InitProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}


BOOL MeteringSessionImp::InitProperty(const char * apName, 
																		const MTDecimalValue * apDecVal)
{
   // !PERF
   if (SetFastModeError("MeteringSessionImp::InitProperty"))
   {
      return FALSE;
   }

	const MTDecimalVal * pDecVal = apDecVal->mpDecimalVal;
	ASSERT(pDecVal);


	if (!MSIXSession::AddProperty(apName, *(pDecVal)))
	{
		SetError(MT_ERR_DUPLICATE_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::InitProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}


BOOL MeteringSessionImp::SetProperty(const char * apName,
																		 const wchar_t * apVal)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::SetProperty(%s)", apName);
   if (SetFastModeError("MeteringSessionImp::SetProperty"))
   {
      return FALSE;
   }

	MSIXString str(apVal);
	if (!MSIXSession::SetProperty(apName, str))
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::SetProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}

// ASCII helper function
BOOL MeteringSessionImp::SetProperty(const char * apName,
																		 const char * apAsciiVal)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::SetProperty(%s,%s)", apName, apAsciiVal);
   if (SetFastModeError("MeteringSessionImp::SetProperty"))
   {
      return FALSE;
   }

	if (!MSIXSession::SetProperty(apName, apAsciiVal))
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::SetProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}

// INT32 version
BOOL MeteringSessionImp::SetProperty(const char * apName, int aInt32, SDKPropertyTypes ptype)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::SetProperty(%s,%d)", apName, aInt32);
   if (SetFastModeError("MeteringSessionImp::SetProperty"))
   {
      return FALSE;
   }

	if (((ptype == SDK_PROPTYPE_BOOLEAN) && !MSIXSession::SetBooleanProperty(apName, aInt32)) ||
			((ptype == SDK_PROPTYPE_INTEGER) && !MSIXSession::SetProperty(apName, aInt32)))
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::SetProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}

// INT64 version
BOOL MeteringSessionImp::SetProperty(const char * apName,
																		 LONGLONG aInt64)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::SetProperty(%s,%e)", apName, (double) aFloat);
   if (SetFastModeError("MeteringSessionImp::SetProperty"))
   {
      return FALSE;
   }

	if (!MSIXSession::SetInt64Property(apName, aInt64))
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::SetProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}

// float version
BOOL MeteringSessionImp::SetProperty(const char * apName,
																		 float aFloat)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::SetProperty(%s,%e)", apName, (double) aFloat);
   if (SetFastModeError("MeteringSessionImp::SetProperty"))
   {
      return FALSE;
   }

	if (!MSIXSession::SetProperty(apName, aFloat))
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::SetProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}

// double version
BOOL MeteringSessionImp::SetProperty(const char * apName,
																		 double aDouble)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::SetProperty(%s,%e)", apName, aDouble);
   if (SetFastModeError("MeteringSessionImp::SetProperty"))
   {
      return FALSE;
   }

	if (!MSIXSession::SetProperty(apName, aDouble))
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::SetProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}

// timestamp version
BOOL MeteringSessionImp::SetProperty(const char * apName, time_t aTimestamp, SDKPropertyTypes ptype)
{
	// TODO: can we log the time as well?
	//SDK_LOG_DEBUG("MeteringSessionImp::SetProperty(%s)", apName);
   if (SetFastModeError("MeteringSessionImp::SetProperty"))
   {
      return FALSE;
   }

	BOOL bResult;
	switch (ptype)
	{
	case SDK_PROPTYPE_BIGINTEGER:
		bResult = MSIXSession::SetInt64Property(apName, (__int64)aTimestamp);
		break;
	case SDK_PROPTYPE_DATETIME:
	default:
		if (aTimestamp < 0)
		{
			ErrorObject * obj = new ErrorObject (MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE,
																"MeteringSessionImp::InitProperty");
			obj->SetProgrammerDetail((const char *)"Invalid date value specified");
			SetError (obj);
			delete obj;
			return FALSE;
		}
		bResult = MSIXSession::SetTimestampProperty(apName, aTimestamp);
	}

	if (!bResult)
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::SetProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}


// decimal version
BOOL MeteringSessionImp::SetProperty(const char * apName,
																		 const MTDecimalValue * apDecVal)
{
   if (SetFastModeError("MeteringSessionImp::SetProperty"))
   {
      return FALSE;
   }

	const MTDecimalVal * pDecVal = apDecVal->mpDecimalVal;
	ASSERT(pDecVal);

	if (!MSIXSession::SetProperty(apName, *(pDecVal)))
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::SetProperty");
		return FALSE;
	}
	MarkDirty();
	return TRUE;
}


// Unicode/direct version
BOOL MeteringSessionImp::GetProperty(const char * apName,
																		 const wchar_t * * apVal)
{
   if (SetFastModeError("MeteringSessionImp::GetProperty"))
   {
      return FALSE;
   }

	const MSIXString * str;
	if (!MSIXSession::GetProperty(apName, &str))
	{
		// TODO: set prop name as detail
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::GetProperty");
		return FALSE;
	}

	ASSERT(str);

	*apVal = str->c_str();
	return TRUE;
}

// ASCII helper function
BOOL MeteringSessionImp::GetProperty(const char * apName,
																		 const char * * apVal)
{
   if (SetFastModeError("MeteringSessionImp::GetProperty"))
   {
      return FALSE;
   }

	const string * str;
	if (!MSIXSession::GetProperty(apName, &str))
	{
		// TODO: set prop name as detail
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::GetProperty");
		return FALSE;
	}

	ASSERT(str);

	*apVal = str->c_str();
	return TRUE;
}

// INT32 and BOOL version
BOOL MeteringSessionImp::GetProperty(const char * apName, int & arInt32, SDKPropertyTypes ptype)
{
   if (SetFastModeError("MeteringSessionImp::GetProperty"))
   {
      return FALSE;
   }

	if (((ptype == SDK_PROPTYPE_BOOLEAN) && !MSIXSession::GetBooleanProperty(apName, arInt32)) ||
			((ptype == SDK_PROPTYPE_INTEGER) && !MSIXSession::GetProperty(apName, arInt32)))
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::GetProperty");
		return FALSE;
	}
	return TRUE;
}

// INT64 version
BOOL MeteringSessionImp::GetProperty(const char * apName,
																		 LONGLONG & arInt64)
{
   if (SetFastModeError("MeteringSessionImp::GetProperty"))
   {
      return FALSE;
   }

	if (!MSIXSession::GetInt64Property(apName, arInt64))
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::GetProperty");
		return FALSE;
	}
	return TRUE;
}

// float version
BOOL MeteringSessionImp::GetProperty(const char * apName,
																		 float & arFloat)
{
   if (SetFastModeError("MeteringSessionImp::GetProperty"))
   {
      return FALSE;
   }

	if (!MSIXSession::GetProperty(apName, arFloat))
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::GetProperty");
		return FALSE;
	}
	return TRUE;
}

// double version
BOOL MeteringSessionImp::GetProperty(const char * apName,
																		 double & arDouble)
{
	if (!MSIXSession::GetProperty(apName, arDouble))
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::GetProperty");
		return FALSE;
	}
	return TRUE;
}


// timestamp version
BOOL MeteringSessionImp::GetProperty(const char * apName, time_t & arTimestamp, SDKPropertyTypes ptype)
{
   if (SetFastModeError("MeteringSessionImp::GetProperty"))
   {
      return FALSE;
   }

	BOOL bResult;
	switch (ptype)
	{
	case SDK_PROPTYPE_BIGINTEGER:
		bResult = MSIXSession::GetInt64Property(apName, arTimestamp);
		break;
	case SDK_PROPTYPE_DATETIME:
	default:
		bResult = MSIXSession::GetTimestampProperty(apName, arTimestamp);
	}

	if (!bResult)
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::GetProperty");
		return FALSE;
	}
	return TRUE;
}


// decimal version
BOOL MeteringSessionImp::GetProperty(const char * apName,
																		 const MTDecimalValue * * apDecVal)
{
   if (SetFastModeError("MeteringSessionImp::GetProperty"))
   {
      return FALSE;
   }

	const MTDecimalVal * pDecVal = NULL;
	
	if (!MSIXSession::GetProperty(apName, &pDecVal))
	{
		SetError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionImp::GetProperty");
		return FALSE;
	}

	ASSERT(pDecVal);

	MTDecimalValue * decimalVal = new MTDecimalValue(pDecVal, FALSE);
	mTemporaryDecimals.push_back(decimalVal);

	*apDecVal = decimalVal;

	ASSERT(*apDecVal);

	return TRUE;
}


void MeteringSessionImp::SetName(const char * apName)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::SetName(%s)", apName);
	//	mpAPI->LocalSetName(this, apName);Not sure this is really right?	billo 31-jul-1998

	MSIXSession::SetName(apName);
}

void MeteringSessionImp::GenerateUid()
{
	//SDK_LOG_DEBUG("MeteringSessionImp::GenerateUid");

	MSIXSession::GenerateUid();
}


MTMeterSession * MeteringSessionImp::CreateChildSession(const char * apName)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::CreateChildSession(%s)", apName);

	MeteringSessionImp * sess = mpAPI->CreateSession(apName, TRUE);
	if (!sess) return NULL;

   sess->SetMeteringSessionSet(GetMeteringSessionSet()); // !PERF

	AddChild(sess);  	// FIXME: error handling
	return sess;
}

MTMeterSession * MeteringSessionImp::GetSessionResults()
{
	return mpResults;
}

void MeteringSessionImp::DetachSessionResults()
{
	mpResults = NULL;
}


////
//// WARNING: THIS IS DEPRECATED.  Use SetRequestResponseFlag instead.
////
void MeteringSessionImp::SetResultRequestFlag(BOOL aGetFeedback /* = TRUE */)
{
	MSIXSession::SetFeedbackRequested(aGetFeedback);
}

////
//// WARNING: THIS IS DEPRECATED.  Use GetRequestResponseFlag instead.
////
BOOL MeteringSessionImp::GetResultRequestFlag()
{
	return MSIXSession::GetFeedbackRequested();
}


////
//// This replaces SetResultRequestFlag()
////
void MeteringSessionImp::SetRequestResponse(BOOL aGetFeedback /* = TRUE */)
{
	MSIXSession::SetFeedbackRequested(aGetFeedback);
}

////
//// This replaces GetResultRequestFlag()
////
BOOL MeteringSessionImp::GetRequestResponse()
{
	return MSIXSession::GetFeedbackRequested();
}


// FIXME: this should not be void -- it can fail, and should return an
// error code
void MeteringSessionImp::AddChild(MTMeterSession * apChild)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::AddChild");

	MarkDirty();

	MeteringSessionImp * child = static_cast<MeteringSessionImp *>(apChild);

	mChildren.push_back(child);
	child->SetParent(this);

}

void MeteringSessionImp::SetParent(MTMeterSession * apParent)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::SetParent");

	if (apParent)
	{
		mpParent = static_cast<MeteringSessionImp *>(apParent);
		SetParentUid(mpParent->GetUid());
	}
	else
	{
		mpParent = NULL;
		ClearParentUid();
	}
}

void MeteringSessionImp::SetState(SessionState aState)
{
	//SDK_LOG_DEBUG("MeteringSessionImp::SetState");

	mState = aState;
}

MeteringSessionImp::SessionState MeteringSessionImp::GetState() const
{
	//SDK_LOG_DEBUG("MeteringSessionImp::GetState");

	return mState;
}

void MeteringSessionImp::MarkDirty()
{
	//SDK_LOG_DEBUG("MeteringSessionImp::MarkDirty");

	ASSERT(GetState() != COMMITTED);

	// recurse up the tree to mark all the parents dirty
	if (GetParent())
		GetParent()->MarkDirty();
}

void MeteringSessionImp::SetPartOfSessionSet(BOOL aIsPart)
{
	mPartOfSessionSet = aIsPart;
}

BOOL MeteringSessionImp::GetPartOfSessionSet() const
{
	return mPartOfSessionSet;
}

void MeteringSessionImp::SetBatch(MeteringBatchImp* pBatch)
{ 
	mpBatch = pBatch; 
	InitProperty("_collectionID", mpBatch->GetUID()); 
}

MeteringBatchImp* MeteringSessionImp::GetBatch() const
{ 
	return mpBatch; 
}

// ======= Begin Performance changes ============== //
void MeteringSessionImp::SetMeteringSessionSet(MeteringSessionSetImp *pMeteringSessionSetImp)
{ 
	mpMeteringSessionSetImp = pMeteringSessionSetImp; 
}

MeteringSessionSetImp* MeteringSessionImp::GetMeteringSessionSet() const
{ 
	return mpMeteringSessionSetImp; 
}

void MeteringSessionImp::CreateHeader() 
{
   // ASSERT(mpMeteringSessionSetImp);
   string beginSessionOpenTag = "<beginsession>";
   string dnOpenTag = "<dn>";
   string dnCloseTag = "</dn>";
   string uidOpenTag = "<uid>";
   string uidCloseTag = "</uid>";
   string parentIdOpenTag = "<parentid>";
   string parentIdCloseTag = "</parentid>";
   string commitTag = "<commit>Y</commit>";
   string insertTag = "<insert>Y</insert>";
   string feedbackOpenTag = "<feedback>";
   string feedbackCloseTag = "</feedback>";
   
   string beginSessionTag = "<beginsession>";

   string feedbackFlag = "Y";
   if (MSIXSession::GetFeedbackRequested() == FALSE) 
   {
      feedbackFlag = "N";
   }

   MeteringSessionImp *parent = GetParent();
   if (parent != NULL) 
   {
      mpMeteringSessionSetImp->GetSessionSetStream() << beginSessionOpenTag
                                                     << dnOpenTag 
                                                     << MSIXSession::GetName() 
                                                     << dnCloseTag
                                                     << uidOpenTag
                                                     << MSIXSession::GetUid().GetUid()
                                                     << uidCloseTag
                                                     << parentIdOpenTag
                                                     << parent->GetUid().GetUid()
                                                     << parentIdCloseTag
                                                     << commitTag
                                                     << insertTag 
                                                     // << "<feedback>Y</feedback>"
                                                     ;
   }
   else 
   {
      mpMeteringSessionSetImp->GetSessionSetStream() << beginSessionOpenTag
                                                     << dnOpenTag 
                                                     << MSIXSession::GetName() 
                                                     << dnCloseTag
                                                     << uidOpenTag
                                                     << MSIXSession::GetUid().GetUid()
                                                     << uidCloseTag
                                                     << commitTag
                                                     << insertTag 
                                                     << feedbackOpenTag
                                                     << feedbackFlag
                                                     << feedbackCloseTag
                                                     ;
   }
}

void MeteringSessionImp::CreateFooter() 
{
   // ASSERT(mpMeteringSessionSetImp);
   string beginSessionCloseTag = "</beginsession>";
   mpMeteringSessionSetImp->GetSessionSetStream() << beginSessionCloseTag;
   mpMeteringSessionSetImp->numSessions++;
}

void MeteringSessionImp::CreatePropertiesHeader() {
   // ASSERT(mpMeteringSessionSetImp);
   string propertiesOpenTag = "<properties>";
   mpMeteringSessionSetImp->GetSessionSetStream() << propertiesOpenTag;
}

void MeteringSessionImp::CreatePropertiesFooter() {
   // ASSERT(mpMeteringSessionSetImp);
   string propertiesCloseTag = "</properties>";
   mpMeteringSessionSetImp->GetSessionSetStream() << propertiesCloseTag;
}

BOOL MeteringSessionImp::IsFastMode() const 
{
   return inFastMode;
}

void MeteringSessionImp::SetFastMode(BOOL fastMode) 
{
   mpMeteringSessionSetImp->SetFastMode(fastMode);
   inFastMode = fastMode;
}

BOOL MeteringSessionImp::SetFastModeError(string methodName) 
{
   if (inFastMode == TRUE) 
   {
      SetError(MT_ERR_NOT_IMPLEMENTED, ERROR_MODULE, ERROR_LINE,
					"MeteringSessionSetImp::SetFastModeError");

      mpErrObj->SetProgrammerDetail("Cannot call " + methodName + " while in FastMode");

      return TRUE;
   }

   return FALSE;
}

// Creates the XML representation of the properties which have already
// been created on this Session.  
BOOL MeteringSessionImp::CreateExistingPropertyStream() 
{
   // Create property tags for the existing properties
   const string propertyOpenTag = "<property>";
   const string propertyCloseTag = "</property>";
   const string dnOpenTag = "<dn>";
   const string dnCloseTag = "</dn>";
   const string valueOpenTag = "<value>";
   const string valueCloseTag = "</value>";

   PropMap::const_iterator it;
	const PropMap & props = GetProperties();
   const string *propertyValue;
   
	for (it = props.begin(); it != props.end(); ++it)
	{
		const PropMapKey &name = it->first;
		const MSIXPropertyValue *value = it->second;
      value->GetValue(&propertyValue);

		mpMeteringSessionSetImp->GetSessionSetStream() << propertyOpenTag
                                                     << dnOpenTag
                                                     << name.GetBuffer() 
                                                     << dnCloseTag
                                                     << valueOpenTag
                                                     << *propertyValue
                                                     << valueCloseTag
                                                     << propertyCloseTag;
	}

   return TRUE;
}

// Creates the XML representation of the property using the 
// name and value of the properties passed into the method. 
BOOL MeteringSessionImp::CreatePropertyStream(string name, string value)
{
   const string propertyOpenTag = "<property>";
   const string propertyCloseTag = "</property>";
   const string dnOpenTag = "<dn>";
   const string dnCloseTag = "</dn>";
   const string valueOpenTag = "<value>";
   const string valueCloseTag = "</value>";

   mpMeteringSessionSetImp->GetSessionSetStream() << propertyOpenTag
                                                  << dnOpenTag
                                                  << name
                                                  << dnCloseTag
                                                  << valueOpenTag
                                                  << value
                                                  << valueCloseTag
                                                  << propertyCloseTag;
   
	MarkDirty();
	return TRUE;
}

// ======= End Performance changes ============== //

/**************************** StandaloneMeteringSessionImp ***/

StandaloneMeteringSessionImp::StandaloneMeteringSessionImp(MeteringSessionSetImp * sessionSet)
	: mpSessionSet(sessionSet),
		mpSession(NULL)
{ }

StandaloneMeteringSessionImp::~StandaloneMeteringSessionImp()
{
	delete mpSessionSet;
}

MTMeterSession * StandaloneMeteringSessionImp::CreateSession(const char * name)
{
	mSessionOp = FALSE;
	mpSession = mpSessionSet->CreateSession(name);
	return mpSession;
}

unsigned long StandaloneMeteringSessionImp::GetLastError() const
{
	if (mSessionOp)
		return mpSession->GetLastError();
	else
		return mpSessionSet->GetLastError();
}

MTMeterError * StandaloneMeteringSessionImp::GetLastErrorObject() const
{
	if (mSessionOp)
		return mpSession->GetLastErrorObject();
	else
		return mpSessionSet->GetLastErrorObject();
}

BOOL StandaloneMeteringSessionImp::Save()
{
	mSessionOp = TRUE;
	// NOTE: we call session save because we know it will fail
	return mpSession->Save();
}

BOOL StandaloneMeteringSessionImp::Close()
{
	mSessionOp = FALSE;
	return mpSessionSet->Close();
}

BOOL StandaloneMeteringSessionImp::ToXML(char * buffer, int & bufferSize)
{
	mSessionOp = FALSE;
	return mpSessionSet->ToXML(buffer, bufferSize);
}

void StandaloneMeteringSessionImp::GetSessionID(char * sessionId) const
{
	mSessionOp = TRUE;
	return mpSession->GetSessionID(sessionId);
}

void StandaloneMeteringSessionImp::GetReferenceID(char * referenceId) const
{
	mSessionOp = TRUE;
	return mpSession->GetReferenceID(referenceId);
}

// Unicode/direct version
BOOL StandaloneMeteringSessionImp::InitProperty(const char * apName,
																								const wchar_t * apVal)
{
	mSessionOp = TRUE;
	return mpSession->InitProperty(apName, apVal);
}

// ASCII helper function
BOOL StandaloneMeteringSessionImp::InitProperty(const char * apName,
																								const char * apAsciiVal)
{
	mSessionOp = TRUE;
	return mpSession->InitProperty(apName, apAsciiVal);
}

	// INT32  and BOOL version
BOOL StandaloneMeteringSessionImp::InitProperty(const char * apName,	int aInt32, 
																								SDKPropertyTypes ptype /* = SDK_PROPTYPE_INTEGER */)
{
	mSessionOp = TRUE;
	return mpSession->InitProperty(apName, aInt32, ptype);
}

	// INT64 version
BOOL StandaloneMeteringSessionImp::InitProperty(const char * apName,
																								LONGLONG aInt64)
{
	mSessionOp = TRUE;
	return mpSession->InitProperty(apName, aInt64, MTMeterSession::SDK_PROPTYPE_BIGINTEGER);
}

	// float version
BOOL StandaloneMeteringSessionImp::InitProperty(const char * apName,
																								float aFloat)
{
	mSessionOp = TRUE;
	return mpSession->InitProperty(apName, aFloat);
}

	// double version
BOOL StandaloneMeteringSessionImp::InitProperty(const char * apName,
																								double aDouble)
{
	mSessionOp = TRUE;
	return mpSession->InitProperty(apName, aDouble);
}

	// timestamp version
BOOL StandaloneMeteringSessionImp::InitProperty(const char * apName,
																								time_t aTimestamp, 
																								SDKPropertyTypes ptype /* = SDK_PROPTYPE_DATETIME */ )
{
	mSessionOp = TRUE;
	return mpSession->InitProperty(apName, aTimestamp, ptype);
}

	// decimal version
BOOL StandaloneMeteringSessionImp::InitProperty(const char * apName, 
																								const MTDecimalValue * apDecVal)
{
	mSessionOp = TRUE;
	return mpSession->InitProperty(apName, apDecVal);
}


	// Unicode/direct version
BOOL StandaloneMeteringSessionImp::SetProperty(const char * apName,
																							 const wchar_t * arVal)
{
	mSessionOp = TRUE;
	return mpSession->SetProperty(apName, arVal);
}

	// ASCII helper function
BOOL StandaloneMeteringSessionImp::SetProperty(const char * apName,
																							 const char * apAsciiVal)
{
	mSessionOp = TRUE;
	return mpSession->SetProperty(apName, apAsciiVal);
}

	// INT32 and BOOL StandaloneMeteringSessionImp::version
BOOL StandaloneMeteringSessionImp::SetProperty(const char * apName,
																							 int aInt32, 
																							 SDKPropertyTypes ptype /* = SDK_PROPTYPE_INTEGER */)
{
	mSessionOp = TRUE;
	return mpSession->SetProperty(apName, aInt32, ptype);
}

	// INT64 version
BOOL StandaloneMeteringSessionImp::SetProperty(const char * apName,
																							 LONGLONG aInt64)
{
	mSessionOp = TRUE;
	return mpSession->SetProperty(apName, aInt64, MTMeterSession::SDK_PROPTYPE_BIGINTEGER);
}

	// float version
BOOL StandaloneMeteringSessionImp::SetProperty(const char * apName,
																							 float aFloat)
{
	mSessionOp = TRUE;
	return mpSession->SetProperty(apName, aFloat);
}

// double version
BOOL StandaloneMeteringSessionImp::SetProperty(const char * apName,
																							 double aDouble)
{
	mSessionOp = TRUE;
	return mpSession->SetProperty(apName, aDouble);
}

// timestamp version
BOOL StandaloneMeteringSessionImp::SetProperty(const char * apName,
																							 time_t aTimestamp, 
																							 SDKPropertyTypes ptype /* = SDK_PROPTYPE_DATETIME */ )
{
	mSessionOp = TRUE;
	return mpSession->SetProperty(apName, aTimestamp, ptype);	
}

// decimal version
BOOL StandaloneMeteringSessionImp::SetProperty(const char * apName,
																							 const MTDecimalValue * apDecVal)
{
	mSessionOp = TRUE;
	return mpSession->SetProperty(apName, apDecVal);	
}


// Unicode/direct version
BOOL StandaloneMeteringSessionImp::GetProperty(const char * apName, const wchar_t * * apVal)
{
	mSessionOp = TRUE;
	return mpSession->GetProperty(apName, apVal);	
}

// ASCII helper function
BOOL StandaloneMeteringSessionImp::GetProperty(const char * apName, const char * * apVal)
{
	mSessionOp = TRUE;
	return mpSession->GetProperty(apName, apVal);	
}

// INT32 and BOOL StandaloneMeteringSessionImp::version
BOOL StandaloneMeteringSessionImp::GetProperty(const char * apName,
																							 int & arInt32, 
																							 SDKPropertyTypes ptype /* = SDK_PROPTYPE_INTEGER */)
{
	mSessionOp = TRUE;
	return mpSession->GetProperty(apName, arInt32, ptype);	
}

// INT64 version
BOOL StandaloneMeteringSessionImp::GetProperty(const char * apName,
																							 LONGLONG & arInt64)
{
	mSessionOp = TRUE;
	return mpSession->GetProperty(apName, arInt64, MTMeterSession::SDK_PROPTYPE_BIGINTEGER);
}

// float version
BOOL StandaloneMeteringSessionImp::GetProperty(const char * apName,
																							 float & arFloat)
{
	mSessionOp = TRUE;
	return mpSession->GetProperty(apName, arFloat);
}

	// double version
BOOL StandaloneMeteringSessionImp::GetProperty(const char * apName,
																							 double & arDouble)
{
	mSessionOp = TRUE;
	return mpSession->GetProperty(apName, arDouble);
}

	// timestamp version
BOOL StandaloneMeteringSessionImp::GetProperty(const char * apName,
																							 time_t & arTimestamp, 
																							 SDKPropertyTypes ptype /* = SDK_PROPTYPE_DATETIME */)
{
	mSessionOp = TRUE;
	return mpSession->GetProperty(apName, arTimestamp, ptype);
}

	// decimal version
BOOL StandaloneMeteringSessionImp::GetProperty(const char * apName,
																							 const MTDecimalValue * * apDecVal)
{
	mSessionOp = TRUE;
	return mpSession->GetProperty(apName, apDecVal);
}


MTMeterSession * StandaloneMeteringSessionImp::CreateChildSession(const char * apName)
{
	mSessionOp = TRUE;
	return mpSession->CreateChildSession(apName);
}

MTMeterSession * StandaloneMeteringSessionImp::GetSessionResults()
{
	mSessionOp = TRUE;
	return mpSession->GetSessionResults();
}

// Prevents session destructor from deleting results
// If you use this, you are responsible for freeing results
// MTMeterSession object.
void StandaloneMeteringSessionImp::DetachSessionResults()
{
	mSessionOp = TRUE;
	mpSession->DetachSessionResults();
}

// WARNING: These are deprecated.  They will disappear.
// Use [Get|Set]RequestResponse() below instead
void StandaloneMeteringSessionImp::SetResultRequestFlag(BOOL aGetFeedback /* = TRUE */)
{
	mSessionOp = TRUE;
	mpSession->SetResultRequestFlag(aGetFeedback);
}

BOOL StandaloneMeteringSessionImp::GetResultRequestFlag()
{
	mSessionOp = TRUE;
	return mpSession->GetResultRequestFlag();
}
// End warning

void StandaloneMeteringSessionImp::SetRequestResponse(BOOL aGetFeedback /* = TRUE */)
{
	mSessionOp = TRUE;
	mpSession->SetRequestResponse(aGetFeedback);
}

BOOL StandaloneMeteringSessionImp::GetRequestResponse()
{
	mSessionOp = TRUE;
	return mpSession->GetRequestResponse();
}

// ======= Begin Performance changes ============== //
BOOL StandaloneMeteringSessionImp::CreatePropertyStream(string name, string value) 
{
   mSessionOp = TRUE;
	return mpSession->CreatePropertyStream(name, value);
}

BOOL StandaloneMeteringSessionImp::CreateExistingPropertyStream() 
{
   mSessionOp = TRUE;
	return mpSession->CreateExistingPropertyStream();
}

void StandaloneMeteringSessionImp::CreateHeader() 
{
   mSessionOp = TRUE;
   return mpSession->CreateHeader();
}

void StandaloneMeteringSessionImp::CreateFooter() 
{
   mSessionOp = TRUE;
   return mpSession->CreateFooter();
}

void StandaloneMeteringSessionImp::CreatePropertiesHeader() {
   mSessionOp = TRUE;
   return mpSession->CreatePropertiesHeader();
}

void StandaloneMeteringSessionImp::CreatePropertiesFooter() {
   mSessionOp = TRUE;
   return mpSession->CreatePropertiesFooter();
}

BOOL StandaloneMeteringSessionImp::IsFastMode() const 
{
   mSessionOp = TRUE;
   return mpSession->IsFastMode();
}

void StandaloneMeteringSessionImp::SetFastMode(BOOL fastMode) 
{
   mSessionOp = TRUE;
   return mpSession->SetFastMode(fastMode);
}

// ======= End Performance changes ============== //

/**************************************** MeteringBatchImp ***/
MeteringBatchImp::MeteringBatchImp(NetMeterAPI * apAPI, NetMeterAPI * apMsixAPI) :
	mpAPI(apAPI),
	mpMsixAPI(apMsixAPI),
	mpErrObj(NULL)
{
	mBatchID = -1;
	mUID = "";
	mCreationDate = 0;
	mSource = "";
	mCompletedCount = 0;
	mExpectedCount = 0;
	mFailureCount = 0;
	mSequenceNumber = "";
	mComment = "";
	mSourceCreationDate = 0;
	mCompletionDate = 0;
	mMeteredCount = 0;
}

MeteringBatchImp::~MeteringBatchImp()
{

}

void MeteringBatchImp::SetBatchID(long ID)
{
	mBatchID = ID;
}

long MeteringBatchImp::GetBatchID() const
{
	return mBatchID;
}

void MeteringBatchImp::SetUID(const char * UID)
{
	mUID = (const char *) UID;
}

const char * MeteringBatchImp::GetUID() const
{
	return (const char *) mUID.c_str();
}

void MeteringBatchImp::SetNameSpace(const char * apNameSpace)
{
	mNameSpace = (const char *) apNameSpace;
}

const char * MeteringBatchImp::GetNameSpace() const
{
	return mNameSpace.c_str();
}

void MeteringBatchImp::SetName(const char * apName)
{
	mName = (const char *) apName;
}

const char * MeteringBatchImp::GetName() const
{
	return mName.c_str();
}

void MeteringBatchImp::SetExpectedCount(long expectedCount)
{
	mExpectedCount = expectedCount;
}

long MeteringBatchImp::GetExpectedCount() const
{
	return mExpectedCount;
}

void MeteringBatchImp::SetCompletedCount(long count)
{
	mCompletedCount = count;
}

long MeteringBatchImp::GetCompletedCount() const
{
	return mCompletedCount;
}

void MeteringBatchImp::SetFailureCount(long failureCount)
{
	mFailureCount = failureCount;
}

long MeteringBatchImp::GetFailureCount() const
{
	return mFailureCount;
}

//
void MeteringBatchImp::SetStatus(const char * status)
{
	mStatus = status;
}

const char * MeteringBatchImp::GetStatus() const
{
	return mStatus.c_str();
}

//	
time_t MeteringBatchImp::GetCreationDate() const
{
	return mCreationDate;
}

void MeteringBatchImp::SetCreationDate(time_t & createdate)
{
	mCreationDate = createdate;
}

//
time_t MeteringBatchImp::GetCompletionDate() const
{
	return mCompletionDate;
}

void MeteringBatchImp::SetCompletionDate(time_t & completiondate)
{
	mCompletionDate = completiondate;
}

//
time_t MeteringBatchImp::GetSourceCreationDate() const
{
	return mSourceCreationDate;
}

void MeteringBatchImp::SetSourceCreationDate(time_t & createdate)
{
	mSourceCreationDate = createdate;
}

//
void MeteringBatchImp::SetSource(const char * source)
{
	mSource = (const char *) source;
}

const char * MeteringBatchImp::GetSource() const
{
	return mSource.c_str();
}

//
void MeteringBatchImp::SetSequenceNumber(const char * sequencenumber)
{
	mSequenceNumber = sequencenumber;
}

const char * MeteringBatchImp::GetSequenceNumber() const
{
	return mSequenceNumber.c_str();
}

//
void MeteringBatchImp::SetComment(const char * comment)
{
	mComment = comment;
}

const char * MeteringBatchImp::GetComment() const
{
	return mComment.c_str();
}

//
void MeteringBatchImp::SetMeteredCount(long meteredcount)
{
	mMeteredCount = meteredcount;
}

long MeteringBatchImp::GetMeteredCount() const
{
	return mMeteredCount;
}


MTMeterSession * MeteringBatchImp::CreateSession(const char * serviceName)
{
	MeteringSessionImp * sess = mpMsixAPI->CreateSession(serviceName, FALSE);
	
	if (!sess)
		return NULL;
	
//	sess->SetBatchID(mBatchID.c_str());
	sess->SetBatch(this);

	return sess;
}

MTMeterSessionSet * MeteringBatchImp::CreateSessionSet()
{
	MeteringSessionSetImp * sess_set = mpMsixAPI->CreateSessionSet();
	
	if (!sess_set)
		return NULL;

	sess_set->SetBatch(this);

	return sess_set;
}


// SYNCHRONOUS
BOOL MeteringBatchImp::Refresh()
{
	// Call batch listener, ask for info for a batch with this ID. If we don't have an id yet,
	// we are not in the db yet so we can't be refreshed.
	if (!mpAPI->CommitBatch(*this, SOAP_CALL_LOADBYUID))
	{
		SetError(mpAPI->GetLastError());
		return FALSE;
	}
	return TRUE;
}

// SYNCHRONOUS
BOOL MeteringBatchImp::Save()
{
	// Save batch info. Make call to batch listener with batch information. If BatchID is set,
	// this will be an update. Otherwise, we are creating a brand new batch on the server.
	MSIXTimestamp timestamp;
	if (!mpAPI->CommitBatch(*this, SOAP_CALL_CREATE))
	{
		SetError(mpAPI->GetLastError());
		return FALSE;
	}

	return TRUE;
}

// SYNCHRONOUS ???
BOOL MeteringBatchImp::Close()
{
	// Mark this batch as close, causing any subsequent sessions metered as part of it to fail.
	return TRUE;
}

// SYNCHRONOUS
BOOL MeteringBatchImp::MarkAsActive()
{
	if (!mpAPI->CommitBatch(*this, SOAP_CALL_MARKASACTIVE))
	{
		SetError(mpAPI->GetLastError());
		return FALSE;
	}

	return TRUE;
}

// SYNCHRONOUS
BOOL MeteringBatchImp::MarkAsBackout()
{
	if (!mpAPI->CommitBatch(*this, SOAP_CALL_MARKASBACKOUT))
	{
		SetError(mpAPI->GetLastError());
		return FALSE;
	}

	return TRUE;
}

// SYNCHRONOUS
BOOL MeteringBatchImp::MarkAsFailed()
{
	if (!mpAPI->CommitBatch(*this, SOAP_CALL_MARKASFAILED))
	{
		SetError(mpAPI->GetLastError());
		return FALSE;
	}

	return TRUE;
}

// SYNCHRONOUS
BOOL MeteringBatchImp::MarkAsDismissed()
{
	if (!mpAPI->CommitBatch(*this, SOAP_CALL_MARKASDISMISSED))
	{
		SetError(mpAPI->GetLastError());
		return FALSE;
	}

	return TRUE;
}

// SYNCHRONOUS
BOOL MeteringBatchImp::MarkAsCompleted()
{
	if (!mpAPI->CommitBatch(*this, SOAP_CALL_MARKASCOMPLETED))
	{
		SetError(mpAPI->GetLastError());
		return FALSE;
	}

	return TRUE;
}

// SYNCHRONOUS
BOOL MeteringBatchImp::UpdateMeteredCount()
{
	if (!mpAPI->CommitBatch(*this, SOAP_CALL_UPDATEMETEREDCOUNT))
	{
		SetError(mpAPI->GetLastError());
		return FALSE;
	}

	return TRUE;
}

// @mfunc An error is pending with the given information
// @parm error code
// @parm module/filename
// @parm line number
// @parm procedure name
void MeteringBatchImp::SetError(
	ErrorObject::ErrorCode aCode, const char * apModule,
	int aLine, const char * apProcedure)
{
	if (!mpErrObj)
		mpErrObj = new ErrorObject(aCode, apModule, aLine, apProcedure);
	else
		mpErrObj->Init(aCode, apModule, aLine, apProcedure);
}

// @mfunc Convenience function to set the error from another error
//	object.  Also sets the error pending flag.
// @parm set from this object
void MeteringBatchImp::SetError(const ErrorObject * apError)
{
	if (!mpErrObj)
		mpErrObj = new ErrorObject(*apError);
	else
		*mpErrObj = *apError;
}

unsigned long MeteringBatchImp::GetLastError() const
{
	if (!mpErrObj)
		return 0;
	return mpErrObj->GetCode();
}

MTMeterError * MeteringBatchImp::GetLastErrorObject() const
{
	if (!mpErrObj)
		return NULL;

	// copy it and return a new one
	MeteringErrorImp * imp = new MeteringErrorImp(mpErrObj);
	return imp;
}

void MeteringBatchImp::UpdateMeteredCount(long meteredcount)
{
	mMeteredCount += meteredcount;
	return;
}

/**************************************** MeteringSessionImp ***/

MeteringSessionSetImp::MeteringSessionSetImp(NetMeterAPI * apAPI) :
	mpAPI(apAPI),
	mpErrObj(NULL),
	mpBatch(NULL),
   isFastMode(FALSE),  // !PERF
   isSessionSetStreamClosed(FALSE) // !PERF

{
	std::string uidString;
	MSIXUidGenerator::Generate(uidString);
	MSIXUidGenerator::Decode(mBatchHeader.mBatchUID, uidString);

	mBatchHeader.mMagic = MTMSIXBatchHeader::MAGIC;
	mBatchHeader.mHeaderSize = sizeof(mBatchHeader);
	mBatchHeader.mMessages = -1;
	mBatchHeader.mClientVersion = 0;

   // ======= Begin Performance changes ============== // 
   numSessions = 0;

   MSIXTimestamp timeStamp;
   string timeStampStr;

   timeStamp.GetStdString(timeStampStr);

   const string msixOpenTag = "<msix>";
   const string timeStampOpenTag = "<timestamp>";
   const string timeStampCloseTag = "</timestamp>";
   const string versionTag = "<version>2.0</version>";
   const string uidOpenTag = "<uid>";
   const string uidCloseTag = "</uid>";
   const string entityOpenTag = "<entity>";
   const string entityCloseTag = "</entity>";

   sessionSetStream << msixOpenTag
                    << timeStampOpenTag 
                    << timeStampStr
                    << timeStampCloseTag
                    << versionTag
                    << uidOpenTag
                    << uidString 
                    << uidCloseTag
                    << entityOpenTag
                    << MSIXUidGenerator::msipaddr
                    << entityCloseTag;
   // ======= End Performance changes ============== //
}

MeteringSessionSetImp::~MeteringSessionSetImp()
{
	if (mpErrObj)
		delete mpErrObj;
	mpErrObj = NULL;

   // !PERF
   // empty the stream
   sessionSetStream.rdbuf()->str("");

	// delete all contained sessions
	MSIXSessionRefList::iterator it;
	for (it = mSessions.begin(); it != mSessions.end(); it++)
	{
		MeteringSessionImp * sess = static_cast<MeteringSessionImp *>(*it);
		delete sess;
	}
}

MTMeterSession * MeteringSessionSetImp::CreateSession(const char * serviceName)
{
	MeteringSessionImp * sess = mpAPI->CreateSession(serviceName, FALSE);
	if (!sess)
		return NULL;

	sess->SetPartOfSessionSet(TRUE);

   sess->SetMeteringSessionSet(this); // !PERF

	if (mpBatch)
		sess->SetBatch(mpBatch);

	// add it to our list
	mSessions.push_back(sess);
	return sess;
}

void MeteringSessionSetImp::GetSessionSetID(char * batchId) const
{
	std::string uidString;
	MSIXUidGenerator::Encode(uidString, mBatchHeader.mBatchUID);

	// TODO: what is the correct length
	ASSERT(uidString.length() <= 25 && uidString.length() > 0);
	int equals = 0;
	int i;
	for (i = uidString.length() - 1; uidString[i] == '='; i--);

	strncpy(batchId, uidString.c_str(), i + 1);
	batchId[i + 1] = '\0';
}

void MeteringSessionSetImp::SetSessionSetID(const char * apUID)
{
	std::string uidString(apUID);

	MSIXUidGenerator::Decode(mBatchHeader.mBatchUID, uidString);
}


BOOL MeteringSessionSetImp::Close()
{
   if (IsFastMode()) 
   {
      if (numSessions == 0)
	   {
		   SetError(MT_ERR_SESSION_SET_FAILED, ERROR_MODULE, ERROR_LINE,
						   "MeteringSessionSetImp::Close");
		   mpErrObj->SetProgrammerDetail("Session sets must contain at least one session");
		   return FALSE;
	   }

			// since SessionSet::Close() can be called multiple times in error handling
			// scenarios (e.g. syncrhonous feedback timeout) to send the message again
			// to the listener, the closing </msix> tag should be appended to the buffer exactly once
			if (!isSessionSetStreamClosed)
			{
				sessionSetStream << "</msix>\0";
				isSessionSetStreamClosed = TRUE;
			}
   }
   else 
   {
	   if (mSessions.size() == 0)
	   {
		   SetError(MT_ERR_SESSION_SET_FAILED, ERROR_MODULE, ERROR_LINE,
						   "MeteringSessionSetImp::Close");
		   mpErrObj->SetProgrammerDetail("Session sets must contain at least one session");
		   return FALSE;
	   }
   }
	
	MSIXTimestamp timestamp;
	const char * ipaddr = MSIXUidGenerator::msipaddr;
	if (!mpAPI->CommitSessionSet(*this, timestamp, ipaddr))
	{
		SetError(mpAPI->GetLastError());
		return FALSE;
	}
	
	if (mpBatch)
		mpBatch->UpdateMeteredCount(mSessions.size());

	return TRUE;
}

BOOL MeteringSessionSetImp::ToXML(char * buffer, int & bufferSize)
{
   // !PERF
   if (isFastMode == TRUE) 
   {
      SetError(MT_ERR_NOT_IMPLEMENTED, ERROR_MODULE, ERROR_LINE,
					"MeteringSessionSetImp::ToXML");

      mpErrObj->SetProgrammerDetail("Cannot call this method while in FastMode");

      return FALSE;
   }

	if (mSessions.size() == 0)
	{
		SetError(MT_ERR_SESSION_SET_FAILED, ERROR_MODULE, ERROR_LINE,
						 "MeteringSessionSetImp::ToXML");
		mpErrObj->SetProgrammerDetail("Session sets must contain at least one session");
		return FALSE;
	}

	std::string stringBuffer;
	
	MSIXTimestamp timestamp;
	const char * ipaddr = MSIXUidGenerator::msipaddr;
	if (!mpAPI->ToXML(*this, timestamp, ipaddr, stringBuffer))
	{
		SetError(mpAPI->GetLastError());
		return FALSE;
	}

	int size = stringBuffer.length();

	if (bufferSize == 0)
	{
		bufferSize = size + 1;		// +1 for 0
		return TRUE;
	}
	else
	{
		if (!buffer)
			return FALSE;

		strncpy(buffer, stringBuffer.c_str(), size);
		if (size > bufferSize)
			buffer[bufferSize - 1] = L'\0';
		else
			buffer[size] = L'\0';
	}

	return TRUE;
}


void MeteringSessionSetImp::SetTransactionID(const char * transactionId)
{
	mTransactionID = transactionId;
   // !PERF
   sessionSetStream << "<transactionid>"
                    << mTransactionID
                    << "</transactionid>";

}

const char * MeteringSessionSetImp::GetTransactionID() const
{
	return mTransactionID.c_str();
}


void MeteringSessionSetImp::SetListenerTransactionID(const char * transactionId)
{
	mListenerTransactionID = transactionId;
   // !PERF
   sessionSetStream << "<listenertransactionid>"
                    << mListenerTransactionID
                    << "</listenertransactionid>";

}

const char * MeteringSessionSetImp::GetListenerTransactionID() const
{
	return mListenerTransactionID.c_str();
}


// ------------------------- 3.0 work -----------------------------
void MeteringSessionSetImp::SetSessionContext(const char * sessioncontext)

{
	mSessionContext = sessioncontext;
   // !PERF
   sessionSetStream << "<sessioncontext>"
                    << mSessionContext
                    << "</sessioncontext>";

}

const char * MeteringSessionSetImp::GetSessionContext() const
{
	return mSessionContext.c_str();
}

void MeteringSessionSetImp::SetSessionContextUserName(const char * username)
{
	mSessionContextUserName = username;
   // !PERF
   sessionSetStream << "<sessioncontextusername>"
                    << mSessionContextUserName
                    << "</sessioncontextusername>";

}

const char * MeteringSessionSetImp::GetSessionContextUserName() const
{
	return mSessionContextUserName.c_str();
}

void MeteringSessionSetImp::SetSessionContextPassword(const char * password)
{
	mSessionContextPassword = password;
   // !PERF
   sessionSetStream << "<sessioncontextpassword>"
                    << mSessionContextPassword
                    << "</sessioncontextpassword>";

}

const char * MeteringSessionSetImp::GetSessionContextPassword() const
{
	return mSessionContextPassword.c_str();
}

void MeteringSessionSetImp::SetSessionContextNamespace(const char * mtnamespace)
{
	mSessionContextNamespace = mtnamespace;
   // !PERF
   sessionSetStream << "<sessioncontextnamespace>"
                    << mSessionContextNamespace
                    << "</sessioncontextnamespace>";

}

const char * MeteringSessionSetImp::GetSessionContextNamespace() const
{
	return mSessionContextNamespace.c_str();
}
// ------------------------- 3.0 work -----------------------------


unsigned long MeteringSessionSetImp::GetLastError() const
{
	if (!mpErrObj)
		return 0;
	return mpErrObj->GetCode();
}

MTMeterError * MeteringSessionSetImp::GetLastErrorObject() const
{
	if (!mpErrObj)
		return NULL;

	// copy it and return a new one
	MeteringErrorImp * imp = new MeteringErrorImp(mpErrObj);
	return imp;
}


// @mfunc An error is pending with the given information
// @parm error code
// @parm module/filename
// @parm line number
// @parm procedure name
void MeteringSessionSetImp::SetError(
	ErrorObject::ErrorCode aCode, const char * apModule,
	int aLine, const char * apProcedure)
{
	if (!mpErrObj)
		mpErrObj = new ErrorObject(aCode, apModule, aLine, apProcedure);
	else
		mpErrObj->Init(aCode, apModule, aLine, apProcedure);
}

// @mfunc Convenience function to set the error from another error
//	object.  Also sets the error pending flag.
// @parm set from this object
void MeteringSessionSetImp::SetError(const ErrorObject * apError)
{
	if (!mpErrObj)
		mpErrObj = new ErrorObject(*apError);
	else
		*mpErrObj = *apError;
}

void MeteringSessionSetImp::SetBatch(MeteringBatchImp* pBatch)
{ 
	mpBatch = pBatch; 
}

MeteringBatchImp* MeteringSessionSetImp::GetBatch() const
{ 
	return mpBatch; 
}

// ======= Begin Performance changes ============== //
BOOL MeteringSessionSetImp::IsFastMode() const 
{
   return isFastMode;
}

// Return TRUE if the properties have been set.
BOOL MeteringSessionSetImp::PropertiesInitialized() const
{
  BOOL initialized = TRUE;
  
  if (mSessionContext.empty() && mSessionContextUserName.empty()) 
  {
    initialized = FALSE;
  }

  return initialized;
}

void MeteringSessionSetImp::SetFastMode(BOOL fastMode) 
{
   isFastMode = fastMode;
}

std::ostringstream& MeteringSessionSetImp::GetSessionSetStream() 
{
   return sessionSetStream;
}

std::string MeteringSessionSetImp::GetBuffer() const
{
   return sessionSetStream.rdbuf()->str();
}


// ======= End Performance changes ============== //

/******************************************* MeteringSession ***/

MTMeterSession::MTMeterSession()
{
	//SDK_LOG_DEBUG("MTMeterSession::MTMeterSession");
}

MTMeterSession::~MTMeterSession()
{
	//SDK_LOG_DEBUG("MTMeterSession::~MTMeterSession");
}


/********************* NetMeterAPI **************/

// FIXME: replace with RW dictionary.
typedef struct {
	BOOL valid;
	DWORD id;
	void *object;
} LOCAL_CRAPPY_DICT_ELEMENT;

static LOCAL_CRAPPY_DICT_ELEMENT crappy[1024];
static BOOL crappy_init = FALSE;

NetMeterAPI::NetMeterAPI(void)
{
	if (!crappy_init)
	{
		int i;
		for (i = 0; i < 1024; i++)
			crappy[i].valid = FALSE;
		crappy_init = TRUE;
	}

	InitializeCriticalSection(&mRecordGuard);
}

NetMeterAPI::~NetMeterAPI(void)
{
	DeleteCriticalSection(&mRecordGuard);
}

/**** The following functions are defined on subclasses. These are only stubs ****/
/**** A subclass will implement each of these according to need							  ****/
MeteringSessionImp * NetMeterAPI::CreateSession(const char * apName, BOOL IsChild)
{
	return NULL;
}

MeteringSessionSetImp * NetMeterAPI::CreateSessionSet()
{
	return NULL;
}

MeteringBatchImp * NetMeterAPI::CreateBatch(NetMeterAPI * apMsixAPI)
{
	return NULL;
}

MeteringBatchImp * NetMeterAPI::Refresh(const char * UID, NetMeterAPI* apMsixAPI)
{
	return NULL;
}

MeteringBatchImp * NetMeterAPI::LoadBatchByName(const char * name, const char * nmspace, const char * sequencenumber, NetMeterAPI* apMsixAPI)
{
	return NULL;
}

MeteringBatchImp * NetMeterAPI::LoadBatchByUID(const char * UID, NetMeterAPI* apMsixAPI)
{
	return NULL;
}

BOOL NetMeterAPI::MarkAsFailed(const char* UID, const char* comment, NetMeterAPI* apMsixAPI)
{
	return FALSE;
}

BOOL NetMeterAPI::MarkAsActive(const char* UID, const char* comment, NetMeterAPI* apMsixAPI)
{
	return FALSE;
}

BOOL NetMeterAPI::MarkAsBackout(const char* UID, const char* comment, NetMeterAPI* apMsixAPI)
{
	return FALSE;
}

BOOL NetMeterAPI::MarkAsDismissed(const char* UID, const char* comment, NetMeterAPI* apMsixAPI)
{
	return FALSE;
}

BOOL NetMeterAPI::MarkAsCompleted(const char* UID, const char* comment, NetMeterAPI* apMsixAPI)
{
	return FALSE;
}

BOOL NetMeterAPI::UpdateMeteredCount(const char* UID, int meteredCount, NetMeterAPI* apMsixAPI)
{
	return FALSE;
}

BOOL NetMeterAPI::MeterFile(char * FileName)
{
	return FALSE;
}

BOOL NetMeterAPI::CommitSessionSet(const MeteringSessionSetImp & arSessionSet, MSIXTimestamp aTimestamp, const char * apUpdateId)
{
	return FALSE;
}

BOOL NetMeterAPI::CommitBatch(MeteringBatchImp & arBatch, int aAction)
{
	return FALSE;
}

BOOL NetMeterAPI::ToXML(const MeteringSessionSetImp & arSessionSet, MSIXTimestamp aTimestamp, const char * apUpdateId, std::string & arBuffer)
{
	return FALSE;
}

/**********************************************************************************/


void NetMeterAPI::AddHost(MeteringServer * apServer)
{
	SDK_LOG_DEBUG("NetMeterAPI::AddHost");

	// NOTE: this isn't the most efficient, but it doesn't matter
	// since we don't insert very often
	mHosts.push_back(apServer);
	sort(mHosts.begin(), mHosts.end());
	long foo = mHosts.size();
}

void NetMeterAPI::ClearHostList()
{
	SDK_LOG_DEBUG("NetMeterAPI::ClearHostList");

	//for_each(mHosts.begin(), mHosts.end(), destroyPtr<MeteringServer>);
	//typedef vector<MeteringServer *> MeteringServerList;
	//MeteringServerList mHosts;
	for (unsigned long i = 0; i < mHosts.size(); i++)
	{
		MeteringServer * meteringServer = mHosts[i];
		delete meteringServer;
	}

	mHosts.clear();
}

MeteringServer * NetMeterAPI::CurrentMeteringServer() const
{
	// TODO: return gracefully if there are no hosts added
	if (mHosts.size() == 0)
		return NULL;

	// TODO: be careful with threading with this 
	return mHosts[mCurrentHost];
}

MeteringServer * NetMeterAPI::NextMeteringServer(const MeteringServer * apFirstServer)
{
	// TODO: be careful with threading with this
	int next = (mCurrentHost + 1) % mHosts.size();
	MeteringServer * server = mHosts[next];

	// did we get all the way around to the first server again?
	if (*apFirstServer == *server)
		return NULL;								// nothing left to try

	// start returning this one now
	mCurrentHost = next;
	return server;
}

// @mfunc
// Set the duration in milliseconds that the operation will wait
// before timing out.
// @parm maximum timeout, in milliseconds
void NetMeterAPI::SetConnectTimeout(int aTimeout) // BOTH
{
	SDK_LOG_DEBUG("NetMeterAPI::SetConnectTimeOut(%d)", aTimeout);

	mpNetStream->SetConnectTimeout(aTimeout);
}

// @mfunc
// Return the timeout in milliseconds.
// @rdesc timeout, in milliseconds
int NetMeterAPI::GetConnectTimeout() const // BOTH
{
	SDK_LOG_DEBUG("NetMeterAPI::GetConnectTimeOut");

	return mpNetStream->GetConnectTimeout();
}


// @mfunc
// Set the number of retries to make before giving up.
// @parm the max number of retries requested.
void NetMeterAPI::SetConnectRetries(int aRetries) // BOTH
{
	SDK_LOG_DEBUG("NetMeterAPI::SetConnectRetries(%d)", aRetries);

	mpNetStream->SetConnectRetries(aRetries);
}

// @mfunc
// Get the number of retries
// @rdesc the max number of retries requested
int NetMeterAPI::GetConnectRetries() const // BOTH
{
	SDK_LOG_DEBUG("NetMeterAPI::GetConnectRetries");

	return mpNetStream->GetConnectRetries();
}

void NetMeterAPI::SetProxyData(string proxyData) // BOTH
{
	mProxyName = proxyData;
}

std::string NetMeterAPI::GetProxyData() const // BOTH
{
	return mProxyName;
}

// @mfunc
// Init the API
BOOL NetMeterAPI::Init() // PROBABLY BOTH
{
	SDK_LOG_DEBUG("NetMeterAPI::Init");

#ifdef WIN32
	if (!ErrorObject::AddModule(WININET_DLL_NAME))
	{
		SetError(MT_ERR_MESSAGE_MODULE_NOT_FOUND, ERROR_MODULE, ERROR_LINE,
						 "NetMeterAPI::Init");
		return FALSE;
	}
#endif
  // FIXME: Unix has one statically linked module

	ASSERT(mpNetStream);

	const char * proxy;
	if (mProxyName.length() > 0)
		proxy = mProxyName.c_str();
	else
		proxy = NULL;
	if (!mpNetStream->Init(proxy))
	{
		SetError(mpNetStream->GetLastError());
		return FALSE;
	}

	// HACK: add an extra equal sign to be backwards compatible
	char * value = getenv("UIDCOMPATIBILITY");
	if (value && 0 == strcmp(value, "1"))
		gAddEqualSign = TRUE;

	return TRUE;
}

BOOL NetMeterAPI::SubmitNetRequest(NetStreamConnection * apConnection, string apStreamedObj, string & responseBuffer)
{
	// could happen if the server/script is down
	if (!apConnection)
	{
		return FALSE;
	}
	ASSERT(apConnection);

	// clear the sent bytes.  This is necessary for keep alive
	apConnection->ClearBytesProcessed();

	// send out the request
	if (!apConnection->SendBytes(apStreamedObj.c_str(), apStreamedObj.length()))
	{
		SetError(apConnection->GetLastError());
		return FALSE;
	}

	if (!apConnection->EndRequest())
	{
		SetError(apConnection->GetLastError());
		return FALSE;
	}

	HttpResponse response = apConnection->GetResponse();
	if ((!response.IsSuccessful()) && (!response.IsServerError())) // A server error can still contain usefull info
	{
		SetError(MT_ERR_BAD_HTTP_RESPONSE,
						 ERROR_MODULE, ERROR_LINE, "NetMeterAPI::SubmitNetRequest");
		return FALSE;
	}

	SDK_LOG_INFO("Parsing results");

	char buffer[4096];
	int size = 0;
	do
	{
		if (!apConnection->ReceiveBytes(buffer, sizeof(buffer) - 1, &size))
		{
			SetError(apConnection->GetLastError());
			return FALSE;
		}
		responseBuffer.append(buffer, size);
	} while (size > 0);

	return TRUE;
}

BOOL NetMeterAPI::Close()
{
	SDK_LOG_DEBUG("NetMeterAPI::Close");

	// only clear out the object once
	if (mpNetStream)
	{
		ClearHostList();
		if (!mpNetStream->Close())
		{
			SetError(mpNetStream->GetLastError());
			return FALSE;
		}

	}
	return TRUE;
}

/******************************************** MeteringServer ***/
MeteringServer::MeteringServer(const char * apServerName, int aPort, BOOL aSecure,
															 const char * apUsername, const char * apPassword) :
	mServerName(apServerName), mPort(aPort), mSecure(aSecure)
{
	SDK_LOG_DEBUG("MeteringServer::MeteringServer(%s, %d, %d)",
								apServerName, aPort, aSecure);

	mUsername = (apUsername == NULL) ? "" : apUsername;
	mPassword = (apPassword == NULL) ? "" : apPassword;

#ifdef WIN32
	InitializeCriticalSection(&mConnectionGuard);
#endif
}

MeteringServer::~MeteringServer()
{
	SDK_LOG_DEBUG("MeteringServer::~MeteringServer");

#ifdef WIN32
	while (!mConnections.empty())
	{
		NetStreamConnection * conn = mConnections.top();
		mConnections.pop();
		delete conn;
	}

	DeleteCriticalSection(&mConnectionGuard);
#endif
}

const char * MeteringServer::GetName() const
{
	SDK_LOG_DEBUG("MeteringServer::GetName");

	return mServerName.c_str();
}

const char * MeteringServer::GetUsername() const
{
	SDK_LOG_DEBUG("MeteringServer::GetUsername");

	return mUsername.c_str();
}

const char * MeteringServer::GetPassword() const
{
	SDK_LOG_DEBUG("MeteringServer::GetPassword");

	return mPassword.c_str();
}

int MeteringServer::GetPort() const
{
	SDK_LOG_DEBUG("MeteringServer::GetPort");

	return mPort;
}

BOOL MeteringServer::GetSecure() const
{
	SDK_LOG_DEBUG("MeteringServer::GetSecure");

	return mSecure;
}

int MeteringServer::GetPriority() const
{
	SDK_LOG_DEBUG("MeteringServer::GetPriority");

	return mPriority;
}

void MeteringServer::SetPriority(int priority) 
{
	SDK_LOG_DEBUG("MeteringServer::GetPriority");

	mPriority = priority;
}

BOOL MeteringServer::operator == (const MeteringServer & arServer) const
{
	SDK_LOG_DEBUG("MeteringServer::operator ==");

	return (GetName() == arServer.GetName()
					&& GetPort() == arServer.GetPort()
					&& GetSecure() == arServer.GetSecure()
					&& GetPriority() == arServer.GetPriority());
}


BOOL MeteringServer::operator < (const MeteringServer & arServer) const
{
	SDK_LOG_DEBUG("MeteringServer::operator < ");

	if (GetPriority() < arServer.GetPriority())
		return TRUE;
	else if (GetName() < arServer.GetName())
		return TRUE;
	else if (GetPort() < arServer.GetPort())
		return TRUE;

	return FALSE;
}


void MeteringServer::ReleaseConnection(NetStreamConnection * apConn)
{
#ifdef UNIX
  // no connection pooling in Unix
  delete apConn;
#endif

#ifdef WIN32
	// connection pool is a shared resource
	EnterCriticalSection(&mConnectionGuard);

	mConnections.push(apConn);

	// we now have control of the slot so we can leave the critical section
	LeaveCriticalSection(&mConnectionGuard);
#endif
}


NetStreamConnection * MeteringServer::GetFreeConnection(NetStream * apNetStream,
																												const char * apHeaders,
																												const char * apListenerAddress)
{
	NetStreamConnection * conn = NULL;

#ifdef WIN32
	// connection pool is a shared resource
	EnterCriticalSection(&mConnectionGuard);

	if (mConnections.size() > 0)
	{
		conn = mConnections.top();
		mConnections.pop();
	}

	LeaveCriticalSection(&mConnectionGuard);
#endif

	if (conn == NULL)
	{

		SDK_LOG_INFO("Starting new POST with keep-alive to %s", GetName());

		// start the POST
    if (GetSecure())
    {
      conn =
        apNetStream->OpenSslHttpConnection("POST",
                                           GetName(),
                                           apListenerAddress,
                                           TRUE,	// use keep alive
                                           GetUsername(),
                                           GetPassword(),
                                           apHeaders,
                                           GetPort());
    } else {
      conn =
        apNetStream->OpenHttpConnection("POST",
                                        GetName(),
                                        apListenerAddress,
#ifdef USE_KEEP_ALIVE
                                        TRUE,	// use keep alive
#else
                                        FALSE,	// don't use keep alive
#endif
                                        GetUsername(),
                                        GetPassword(),
                                        apHeaders,
                                        GetPort());
    }
		if (!conn)
		{
			SetError(apNetStream->GetLastError());
			//fprintf(stderr, "connect %d failed\n", slot);
			return NULL;
		}
	}
	else
	{
		//fprintf(stderr, "reusing %d\n", slot);

		ASSERT(conn);

		SDK_LOG_INFO("Reusing keep-alive connection to %s", GetName());

		// connection already exists - reuse it
		// NOTE: use the same params as OpenHttpConnection does above
		if (!conn->ReConnect("POST",
												 GetName(),
												 apListenerAddress,
#ifdef USE_KEEP_ALIVE
												TRUE,	// use keep alive
#else
												FALSE,	// don't use keep alive
#endif
												 GetUsername(),
												 GetPassword(),
												 apHeaders,
												 GetPort(),

GetSecure()))
		{
			//fprintf(stderr, "reconnect %d failed\n", slot);
			SetError(conn->GetLastError());

			return NULL;
		}

	}

	return conn;
}
