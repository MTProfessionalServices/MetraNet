/**************************************************************************
 * @doc MSIX
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
 * $Header: C:\mt\development\Core\msix\msix.cpp, 46, 9/30/2002 4:49:47 PM, Derek Young$
 *
 * MSIX functions unrelated to parsing/writing
 ***************************************************************************/

#include "metra.h"
#include "MSIX.h"

#ifdef UNIX
#include <wchar.h>
#endif
#include <sys/timeb.h>					// for struct _timeb

// this is to get the local IP address (for UIDs)
#include <mtsock.h>
#include <base64.h>

#include <time.h>								// time
#include <stdlib.h>							// rand, srand

#include <MTUtil.h>
#include <MTTypeConvert.h>

#include <algorithm>
#include <stdutils.h>
#include <MTDecimalVal.h>
#include <mttime.h>

// hack used temporarily to add an extra = to UIDs
#ifdef ADD_EQUAL_SIGN
BOOL gAddEqualSign = FALSE;
#endif // ADD_EQUAL_SIGN

#ifdef WIN32
template void destroyPtr(MSIXObject *);
#endif

/*************************************************** MSIXUid ***/

BOOL MSIXUid::Init(const XMLString & arUid)
{
	// TODO: this should further massage the UID.
	// it could check the length at least.
	return XMLStringToUtf8(mUid, arUid);
}

BOOL MSIXUid::Init(const char * apUid)
{
	// TODO: this should further massage the UID.
	// it could check the length at least.
	mUid = apUid;
	return TRUE;
}

void MSIXUid::Clear()
{
	mUid.resize(0);
}

void MSIXUid::Generate()
{
	Clear();
	MSIXUidGenerator::Generate(mUid);
}


/********************************************* MSIXTimestamp ***/

MSIXTimestamp::MSIXTimestamp()
{
	SetCurrentTime();
}

MSIXTimestamp::MSIXTimestamp(time_t arTime)
{
	// NOTE: Setting the current time can be expensive.
	// allowing the user to pass in -1 can avoid this overhead
	if (arTime != -1)
		SetTime(arTime);
}


BOOL MSIXTimestamp::Parse(const char * aTimeString)
{
	return MTParseISOTime(aTimeString, &mTime);
}

void MSIXTimestamp::GetStdString(string & arBuffer) const
{
	MTFormatISOTime(mTime, arBuffer);
}

void MSIXTimestamp::SetCurrentTime()
{
	mTime = GetMTTime();
}

void MSIXTimestamp::SetTime(time_t arTime)
{
	mTime = arTime;
}

time_t MSIXTimestamp::GetTime() const
{
	return mTime;
}


/************************************************ MSIXStatus ***/

MSIXStatus::MSIXStatus()
{
	// the OK status
	mCode = 0;
}


MSIXStatus::MSIXStatus(const MSIXStatus & arStatus)
{
	*this = arStatus;
}

MSIXStatus & MSIXStatus::operator =(const MSIXStatus & arStatus)
{
	mCode = arStatus.GetCode();
	return *this;
}

ErrorObject::ErrorCode MSIXStatus::GetCode() const
{
	return mCode;
}

void MSIXStatus::SetCode(ErrorObject::ErrorCode aCode)
{
	mCode = aCode;
}

void MSIXStatus::SetMessage(const wchar_t * apMessage)
{
	mMessage = apMessage;
}

const MSIXString & MSIXStatus::GetMessage() const
{
	return mMessage;
}

/***************************************** MSIXSessionStatus ***/

MSIXSessionStatus::MSIXSessionStatus()
	: mCode(0),										// the OK status
		mpSession(NULL)
{ }

MSIXSessionStatus::~MSIXSessionStatus()
{
	delete mpSession;
	mpSession = NULL;
}

ErrorObject::ErrorCode MSIXSessionStatus::GetCode() const
{
	return mCode;
}

void MSIXSessionStatus::SetCode(ErrorObject::ErrorCode aCode)
{
	mCode = aCode;
}

void MSIXSessionStatus::SetUid(const MSIXUid & arUid)
{
	mUid = arUid;
}

const MSIXUid & MSIXSessionStatus::GetUid() const
{
	return mUid;
}


void MSIXSessionStatus::SetStatusMessage(MSIXString & arMessage)
{
	mMessage = arMessage;
}

const MSIXString & MSIXSessionStatus::GetStatusMessage() const
{
	return mMessage;
}

void MSIXSessionStatus::AttachSession(MSIXSession * apSession)
{
	// NOTE: the session is deleted in the destructor
	mpSession = apSession;
}

MSIXSession * MSIXSessionStatus::DetachSession()
{
	// NOTE: caller is now responsible for deleting
	MSIXSession * sess = mpSession;
	mpSession = NULL;
	return sess;
}

MSIXSession * MSIXSessionStatus::GetSession()
{
	return  mpSession;
}

/****************************************** MSIXUidAggregate ***/

void MSIXUidAggregateBase::SetUid(const MSIXUid & arUid)
{
	mUid = arUid;
}

const MSIXUid & MSIXUidAggregateBase::GetUid()
{
	return mUid;
}

/****************************************** MSIXUidGenerator ***/

// only need to construct one so the constructor and destructor are called
MSIXUidGenerator gGenerator;

char MSIXUidGenerator::msipaddr[20];

unsigned int MSIXUidGenerator::msCounter = 0;
unsigned char MSIXUidGenerator::msIPBytes[4];


MSIXUidGenerator::MSIXUidGenerator()
{
	// TODO: is this big enough
	char hostname[512];
#ifdef WIN32
	WSADATA data;
	::WSAStartup(MAKEWORD(1, 0), &data);
	::gethostname(hostname, sizeof(hostname));
#endif
#ifdef UNIX
  gethostname(hostname, sizeof(hostname));
#endif
	struct hostent * hent = ::gethostbyname(hostname);

	const unsigned char * src = (const unsigned char *) hent->h_addr_list[0];
	int len = hent->h_length;
	// TODO: I'm not sure what we'll do if IP addresses aren't four bytes
	ASSERT(len == 4);

	// copy IP address into first four bytes
	int i;
	for (i = 0; i < 4; i++)
		msIPBytes[i] = src[i];

	// convert IP address into string form for reference
	char buf[20];
	sprintf(buf, "%d.%d.%d.%d", (int) src[0], (int) src[1], (int) src[2], (int) src[3]);

	// TODO: why does this definition disappear!?
	//msIpAddress = buf;

	//string * ptr = &msIpAddress;

	strcpy(msipaddr, buf);

#ifdef WIN32
	// also initialize the random number generator
	// TODO: this isn't ANSI
	srand(::GetTickCount());
#endif
#ifdef UNIX
  struct timeb now;

  ftime(&now);

  srand(now.millitm + 1000 * now.time);

#endif

	// start the counter at a random value - no reason to start at 0
	// randomize all four bytes of it
	msCounter = rand();
	for (i = 0; i < 4; i++)
		msCounter = (msCounter << 8) | rand();
}

MSIXUidGenerator::~MSIXUidGenerator()
{
#ifdef WIN32
	::WSACleanup();
#endif
}


void MSIXUidGenerator::Generate(string & arUid)
{
  //4 byte entity IP address + 
	//4 byte current Unixtime value +
  //4 byte arbitrary random number +
  //4 byte counter, incrementing in each message sent by entity.

	unsigned char uid[16];

	enum
	{
		IP_OFFSET = 0,
		TIMER_OFFSET = 4,
		RAND_OFFSET = 8,
		COUNTER_OFFSET = 12,

		SEGMENT_LENGTH = 4,					// number of bytes in each "chunk"
	};

	//
	// IP address
	//
	memcpy(uid + IP_OFFSET, msIPBytes, SEGMENT_LENGTH);

	//
	// timer
	//
	// NOTE: instead of using unix time, we use low word
	// of the win32 filetime (which is in nanoseconds).
	// it's more likely to be different for transactions sent around the
	// same time.
	// this isn't ANSI however.
	//

#ifdef WIN32
	FILETIME fileTime;
	::GetSystemTimeAsFileTime(&fileTime);
	long t = fileTime.dwLowDateTime;
#endif
#ifdef UNIX
	long t = time(NULL);
#endif

	ASSERT(sizeof(t) == SEGMENT_LENGTH);
	memcpy(uid + TIMER_OFFSET, (unsigned char *) &t, SEGMENT_LENGTH);

	//
	// set the random section
	// we want a fairly random 4 byte value but RAND_MAX is
	// only 0x7FFFF.  To ensure randomness we use the low byte of 4 rand calls
	//
	for (int i = 0; i < 4; i++)
		uid[RAND_OFFSET + i] = rand() & 0xFF;

	//
	// next count
	//
#ifdef WIN32
	long val = ::InterlockedIncrement((long *) &msCounter);
#else
	long val = ++msCounter;
#endif

	ASSERT(sizeof(val) == SEGMENT_LENGTH);
	memcpy(uid + COUNTER_OFFSET, (unsigned char *) &val, SEGMENT_LENGTH);

	//
	// base 64 encode
	//
	Encode(arUid, uid);
}

BOOL MSIXUidGenerator::Decode(unsigned char * apID, const MSIXUid & arUid)
{
	const string & encodedUid = arUid.GetUid();

	return Decode(apID, encodedUid);
}

BOOL MSIXUidGenerator::Decode(unsigned char * apID, const string & arUid)
{
	vector<unsigned char> dest;
	if (rfc1421decode(arUid.c_str(), arUid.length(), dest) != ERROR_NONE)
		return FALSE;

	// UID didn't decode to the correct size
	if (dest.size() != 16)
		return FALSE;

	// vector type guarantees elements are next to each other
	memcpy(apID, &dest[0], dest.size());
	return TRUE;
}		

void MSIXUidGenerator::Encode(string & arUid, const unsigned char * apID)
{
	// base 64 encode
	rfc1421encode(apID, 16, arUid);

#ifdef ADD_EQUAL_SIGN

	if (gAddEqualSign)
		arUid += '=';

#endif // ADD_EQUAL_SIGN
}

/************************************** MSIXSessionReference ***/

MSIXSessionReference::MSIXSessionReference()
{ }

void MSIXSessionReference::SetName(const char * apName)
{
	mDn = apName;
}

const string & MSIXSessionReference::GetName() const
{
	return mDn;
}


void MSIXSessionReference::GenerateUid()
{
	mUid.Generate();
}

void MSIXSessionReference::SetUid(const MSIXUid & arUid)
{
	mUid = arUid;
}

const MSIXUid & MSIXSessionReference::GetUid() const
{
	return mUid;
}

/*********************************************** MSIXSession ***/


MSIXSession::MSIXSession()
	: mCommit(FALSE),
		mInsertHint(Unknown),
		mFeedback(FALSE)
{ }


MSIXSession::MSIXSession(MSIXSession & arSession)
{
	*this = arSession;
}

MSIXSession::~MSIXSession()
{
	PropMap::iterator it;
	for (it = mProperties.begin(); it != mProperties.end(); it++)
		delete it->second;
}

MSIXSession & MSIXSession::operator =(const MSIXSession & arSess)
{
	Copy(&arSess);
	return *this;
}

void MSIXSession::Copy(const MSIXSession * apSession)
{
	// Copy the session reference properties
	SetName(apSession->GetName().c_str());
	SetUid(apSession->GetUid());

	// copy the map of properties (deep copy)
	PropMap::const_iterator it;
	const PropMap & props = apSession->GetProperties();
	for (it = props.begin(); it != props.end(); it++)
	{
		const PropMapKey & name = it->first;
		const MSIXPropertyValue * value = it->second;

		MSIXPropertyValue * propCopy = new MSIXPropertyValue(*value);
		mProperties[name] = propCopy;
	}

	// copy other fields
	mParentUid = apSession->GetParentUid();
	mCommit = apSession->GetCommit();
	mInsertHint = apSession->GetInsertHint();
	mFeedback = apSession->GetFeedbackRequested();
}


void MSIXSession::ClearParentUid()
{
	mParentUid.Clear();
}

BOOL MSIXSession::SetParentUid(const XMLString & arUid)
{
	return mParentUid.Init(arUid);
}

BOOL MSIXSession::SetParentUid(const MSIXUid & arUid)
{
	mParentUid = arUid;
	// TODO: could this ever return FALSE?
	return TRUE;
}

const MSIXUid & MSIXSession::GetParentUid() const
{
	return mParentUid;
}

template<class T> BOOL SetNewPropertyValue(MSIXSession::PropMap & arMap,
																					 const char * apName, const T & arVal)
{
	PropMapKey key(apName);
	
	MSIXPropertyValue * val = new MSIXPropertyValue;
	std::pair<MSIXSession::PropMap::iterator, bool> insertResults =
		arMap.insert(MSIXSession::PropMap::value_type(key, val));

	if (!insertResults.second)
	{
		// not inserted - duplicate
		delete val;
		return FALSE;								// already exists
	}

	*val = arVal;

	return TRUE;
}

//very similar to SetNewPropertyValue above except this function is used
//when the value's type is still undetermined (i.e., when setting a 
//default value). also note that this is not a template function.
BOOL SetNewUnknownPropertyValue(MSIXSession::PropMap & arMap,
																const char * apName, const MSIXString & arVal)
{
	PropMapKey key(apName);
	MSIXPropertyValue * val;

	MSIXSession::PropMap::iterator it = arMap.find(key);
	if (it != arMap.end())
	{
		return FALSE;								// already exists
	}

	// create a new prop value object and assign the property value to it
	val = new MSIXPropertyValue;
	val->SetUnknownValue(arVal);
//	*val = apVal;

	arMap[key] = val;

	return TRUE;
}

template<class T> BOOL SetExistingPropertyValue(MSIXSession::PropMap & arMap,
																								const char * apName, const T & arVal)
{
	PropMapKey key(apName);
	MSIXPropertyValue * val;
	MSIXSession::PropMap::iterator it = arMap.find(key);
	if (it == arMap.end())
 		return FALSE;								// doesn't exist

	val = it->second;
	*val = arVal;

	return TRUE;
}



// Unicode
template<class T>
BOOL GetPropertyValue(const MSIXSession::PropMap & arMap, const char * apName, T & arVal)
{
	// too bad we have to construct a string just to look up the value
	PropMapKey key(apName);

	MSIXPropertyValue * val;
	MSIXSession::PropMap::const_iterator it = arMap.find(key);
	if (it == arMap.end())
 		return FALSE;								// doesn't exist

	val = it->second;
	return val->GetValue(arVal);
}


// Unknown version
BOOL MSIXSession::AddUnknownProperty(const char * apName,
																		 const MSIXString & arVal)
{
	return SetNewUnknownPropertyValue(mProperties, apName, arVal);
}

// @rdesc FALSE if the property already exists
BOOL MSIXSession::AddProperty(const char * apName,
															const MSIXString & arVal)
{
	return SetNewPropertyValue(mProperties, apName, arVal);
}


// ASCII helper function
BOOL MSIXSession::AddProperty(const char * apName,
															const char * apAsciiVal)
{
	return SetNewPropertyValue(mProperties, apName, apAsciiVal);
}

// TODO: these could be more efficient
// INT32 version
BOOL MSIXSession::AddProperty(const char * apName,
															int aInt32)
{
	return SetNewPropertyValue(mProperties, apName, aInt32);
}

// INT64 version
BOOL MSIXSession::AddInt64Property(const char * apName,
															__int64 aInt64)
{
	//can't use the following because it uses the operator =
	//so instead we'll subsitute the code in and use AssignBoolean
	//	return SetNewPropertyValue(mProperties, apName, aBool);
	PropMapKey key(apName);
	MSIXPropertyValue * val;

	MSIXSession::PropMap::iterator it = mProperties.find(key);
	if (it != mProperties.end())
	{
		return FALSE;								// already exists
	}

	// create a new prop value object and assign the property value to it
	val = new MSIXPropertyValue;
	val->AssignInt64(aInt64);   // instead of *val = aBool;

	mProperties[key] = val;

	return TRUE;
}

// float version
BOOL MSIXSession::AddProperty(const char * apName,
															float aFloat)
{
	return SetNewPropertyValue(mProperties, apName, aFloat);
}

// double version
BOOL MSIXSession::AddProperty(const char * apName,
															double aDouble)
{
	return SetNewPropertyValue(mProperties, apName, aDouble);
}

// timestamp version
BOOL MSIXSession::AddTimestampProperty(const char * apName,
                                       time_t aTimestamp)
{
	//can't use the following because it uses the operator =
	//so instead we'll subsitute the code in and use AssignBoolean
	//	return SetNewPropertyValue(mProperties, apName, aBool);
	PropMapKey key(apName);
	MSIXPropertyValue * val;

	MSIXSession::PropMap::iterator it = mProperties.find(key);
	if (it != mProperties.end())
	{
		return FALSE;								// already exists
	}

	// create a new prop value object and assign the property value to it
	val = new MSIXPropertyValue;
	val->AssignTimestamp(aTimestamp);   // instead of *val = aBool;

	mProperties[key] = val;

	return TRUE;
}

// decimal version
BOOL MSIXSession::AddProperty(const char * apName, 
															const MTDecimalVal & arVal)
{
	return SetNewPropertyValue(mProperties, apName, arVal);
}

// boolean version
//special case for BOOL since it is really an int
//and would have the same signature as AddProperty(int)
BOOL MSIXSession::AddBooleanProperty(const char * apName,
																		 BOOL aBool) {
	//can't use the following because it uses the operator =
	//so instead we'll subsitute the code in and use AssignBoolean
	//	return SetNewPropertyValue(mProperties, apName, aBool);
	PropMapKey key(apName);
	MSIXPropertyValue * val;

	MSIXSession::PropMap::iterator it = mProperties.find(key);
	if (it != mProperties.end())
	{
		return FALSE;								// already exists
	}

	// create a new prop value object and assign the property value to it
	val = new MSIXPropertyValue;
	val->AssignBoolean(aBool);   // instead of *val = aBool;

	mProperties[key] = val;

	return TRUE;
}




// @rdesc FALSE if the property doesn't exist
BOOL MSIXSession::SetProperty(const char * apName,
															const MSIXString & arVal)
{
	return SetExistingPropertyValue(mProperties, apName, arVal);
}

// ASCII helper function
BOOL MSIXSession::SetProperty(const char * apName,
															const char * apAsciiVal)
{
	return SetExistingPropertyValue(mProperties, apName, apAsciiVal);
}

// TODO: these could be more efficient
// INT32 version
BOOL MSIXSession::SetProperty(const char * apName,
															int aInt32)
{
	return SetExistingPropertyValue(mProperties, apName, aInt32);
}

// INT64 version
BOOL MSIXSession::SetInt64Property(const char * apName,
                                   __int64 aInt64)
{
	PropMapKey key(apName);
	MSIXPropertyValue * val;
	
	MSIXSession::PropMap::iterator it = mProperties.find(key);
	if (it == mProperties.end())
		return FALSE;								// doesn't exist

	val = it->second;
	val->AssignInt64(aInt64);

	return TRUE;
}

// float version
BOOL MSIXSession::SetProperty(const char * apName,
															float aFloat)
{
	return SetExistingPropertyValue(mProperties, apName, aFloat);
}

// double version
BOOL MSIXSession::SetProperty(const char * apName,
															double aDouble)
{
	return SetExistingPropertyValue(mProperties, apName, aDouble);
}


// timestamp version
BOOL MSIXSession::SetTimestampProperty(const char * apName,
                                       time_t aTimestamp)
{
	PropMapKey key(apName);
	MSIXPropertyValue * val;
	
	MSIXSession::PropMap::iterator it = mProperties.find(key);
	if (it == mProperties.end())
		return FALSE;								// doesn't exist

	val = it->second;
	val->AssignTimestamp(aTimestamp);

	return TRUE;
}

BOOL MSIXSession::SetProperty(const char * apName, 
														const MTDecimalVal & arVal)
{
	return SetExistingPropertyValue(mProperties, apName, arVal);
}


// boolean version
//special case for BOOL since it is really an int
//and would have the same signature as SetProperty(int)
BOOL MSIXSession::SetBooleanProperty(const char * apName,
																		 BOOL aBool)
{
//	return SetExistingPropertyValue(mProperties, apName, aBool);
	PropMapKey key(apName);
	MSIXPropertyValue * val;
	
	MSIXSession::PropMap::iterator it = mProperties.find(key);
	if (it == mProperties.end())
		return FALSE;								// doesn't exist

	val = it->second;
	val->AssignBoolean(aBool);

	return TRUE;
}

// Unicode
BOOL MSIXSession::GetProperty(const char * apName, const MSIXString * * apVal) const
{
	return GetPropertyValue(mProperties, apName, apVal);
}

// ASCII helper function
BOOL MSIXSession::GetProperty(const char * apName, const string * * apVal) const
{
	return GetPropertyValue(mProperties, apName, apVal);
}

// INT32 version
BOOL MSIXSession::GetProperty(const char * apName, int & arInt32) const
{
	return GetPropertyValue(mProperties, apName, arInt32);
}

// INT64 version
BOOL MSIXSession::GetInt64Property(const char * apName, __int64 & arInt64) const
{
//	return GetPropertyValue(mProperties, apName, arBool);
	// too bad we have to construct a string just to look up the value
	PropMapKey key(apName);
	MSIXPropertyValue * val;
	
	MSIXSession::PropMap::const_iterator it = mProperties.find(key);
	if (it == mProperties.end())
		return FALSE;								// doesn't exist

	val = it->second;
	return val->GetInt64Value(arInt64);
}

// float version
BOOL MSIXSession::GetProperty(const char * apName, float & arFloat) const
{
	return GetPropertyValue(mProperties, apName, arFloat);
}

// double version
BOOL MSIXSession::GetProperty(const char * apName, double & arDouble) const
{
	return GetPropertyValue(mProperties, apName, arDouble);
}

// timestamp version
BOOL MSIXSession::GetTimestampProperty(const char * apName, time_t & arTimestamp) const
{
//	return GetPropertyValue(mProperties, apName, arBool);
	// too bad we have to construct a string just to look up the value
	PropMapKey key(apName);
	MSIXPropertyValue * val;
	
	MSIXSession::PropMap::const_iterator it = mProperties.find(key);
	if (it == mProperties.end())
		return FALSE;								// doesn't exist

	val = it->second;
	return val->GetTimestampValue(arTimestamp);
}

// decimal version
BOOL MSIXSession::GetProperty(const char * apName, const MTDecimalVal * * apVal) const
{
	return GetPropertyValue(mProperties, apName, apVal);
}

//boolean version
//special case for BOOL since it is really an int
//and would have the same signature as GetProperty(int)
BOOL MSIXSession::GetBooleanProperty(const char * apName, BOOL & arBool) const
{
//	return GetPropertyValue(mProperties, apName, arBool);
	// too bad we have to construct a string just to look up the value
	PropMapKey key(apName);
	MSIXPropertyValue * val;
	
	MSIXSession::PropMap::const_iterator it = mProperties.find(key);
	if (it == mProperties.end())
		return FALSE;								// doesn't exist

	val = it->second;
	return val->GetBooleanValue(arBool);
}

/*********************************************** MSIXMessage ***/

MSIXMessage::MSIXMessage()
	// pass in -1 to avoid the call to get the current time.
	: mTimestamp(-1)
{
	mDeleteBody = TRUE;
	mTransactionID.SetBuffer(L"");
	mListenerTransactionID.SetBuffer(L"");
}

MSIXMessage::~MSIXMessage()
{
	if (mDeleteBody)
	{
		// delete the body of the message
		//for_each(mBody.begin(), mBody.end(), destroyPtr<XMLObject>);
		for (unsigned long i = 0; i < mBody.size(); i++)
		{
			MSIXObject* msixObject = mBody[i];
			delete msixObject;
		}

		mBody.clear();
	}
}

void MSIXMessage::DeleteBody(BOOL aDeleteFlag /* = TRUE */)
{
	mDeleteBody = aDeleteFlag;
}

void MSIXMessage::SetCurrentTimestamp()
{
	mTimestamp.SetCurrentTime();
}

void MSIXMessage::SetVersion(const wchar_t * apVersion)
{
	mVersion = apVersion;
}

void MSIXMessage::GenerateUid()
{
	mUid.Generate();
}

void MSIXMessage::SetUid(const char * apUid)
{
	mUid.Init(apUid);
}

void MSIXMessage::SetEntity(const wchar_t * apEntity)
{
	mEntity = apEntity;
}

void MSIXMessage::SetTransactionID(const wchar_t * apTransactionID)
{
	mTransactionID = apTransactionID;
}

void MSIXMessage::SetListenerTransactionID(const wchar_t * apTransactionID)
{
	mListenerTransactionID = apTransactionID;
}

void MSIXMessage::SetSessionContext(const wchar_t * apSessionContext)
{
	mSessionContext = apSessionContext;
}

void MSIXMessage::SetSessionContextUserName(const wchar_t * apUserName)
{
	mSessionContextUserName = apUserName;
}

void MSIXMessage::SetSessionContextPassword(const wchar_t * apPassword)
{
	mSessionContextPassword = apPassword;
}

void MSIXMessage::SetSessionContextNamespace(const wchar_t * apNamespace)
{
	mSessionContextNamespace = apNamespace;
}

void MSIXMessage::AddToBody(MSIXObject * apObject)
{
	mBody.push_back(apObject);
}

/***************************************** MSIXPropertyValue ***/

MSIXPropertyValue::MSIXPropertyValue()
{
	mPropType = INVALID;
}

MSIXPropertyValue::MSIXPropertyValue(const MSIXPropertyValue & arProp)
{
	mPropType = INVALID;
	*this = arProp;
}

MSIXPropertyValue & MSIXPropertyValue::operator =(const MSIXPropertyValue & arProp)
{
	switch (arProp.mPropType)
	{
	case UNKNOWN_AS_UNISTRING:
		operator =(*(arProp.mpWString));
	  mPropType = UNKNOWN_AS_UNISTRING;
	  return *this;
	case UNISTRING:
		return operator =(*(arProp.mpWString));
	case STRING:
		return operator =(*(arProp.mpAString));
	case INT32:
		return operator =(arProp.mInt);
	case INT64:
		AssignInt64(arProp.mBigInt);
    break;
	case FLOAT:
		return operator =(arProp.mFloat);
	case DOUBLE:
		return operator =(arProp.mFloat);
	case TIMESTAMP:
		AssignTimestamp(arProp.mTimestamp);
    break;
	case DECIMAL:
		return operator =(*(arProp.mpDecimal));
	case BOOLEAN:
	  AssignBoolean(arProp.mBoolean);
	  break;
	case INVALID:
		mPropType = INVALID;
    break;
	default:
		ASSERT(0);
	}

	return *this;
}


MSIXPropertyValue::~MSIXPropertyValue()
{
	ClearValue();
}

MSIXPropertyValue::PropType MSIXPropertyValue::GetType() const
{
	return mPropType;
}

void MSIXPropertyValue::GetValueAsString(MSIXString & arString) const
{
	char buffer[40];
	BOOL res;
	string asc;
	switch (mPropType)
	{
	case UNKNOWN_AS_UNISTRING:
	case UNISTRING:
		arString = *mpWString;
		break;
	case STRING:
		// TODO: don't use Utf8 version
		res = Utf8ToXMLString(arString, mpAString->c_str());
		ASSERT(res);
		break;
	case INT32:
		sprintf(buffer, "%d", mInt);
		// TODO: don't use Utf8 version
		res = Utf8ToXMLString(arString, buffer);
		ASSERT(res);
		break;
	case INT64:
		sprintf(buffer, "%I64d", mBigInt);
		// TODO: don't use Utf8 version
		res = Utf8ToXMLString(arString, buffer);
		ASSERT(res);
		break;
	case FLOAT:
		sprintf(buffer, "%.15e", (double) mFloat);
		// TODO: don't use Utf8 version
		res = Utf8ToXMLString(arString, buffer);
		ASSERT(res);
		break;
	case DOUBLE:
		sprintf(buffer, "%.15e", mDouble);
		// TODO: don't use Utf8 version
		res = Utf8ToXMLString(arString, buffer);
		ASSERT(res);
		break;
	case BOOLEAN:
		if (mBoolean)
			sprintf(buffer, "T");
		else
			sprintf(buffer, "F");
		// TODO: don't use Utf8 version
		res = Utf8ToXMLString(arString, buffer);
		ASSERT(res);
		break;
	case DECIMAL:
	{
		wchar_t wbuffer[100];
		int wbufferLen = sizeof(wbuffer);
		res = mpDecimal->Format(wbuffer, wbufferLen);
		ASSERT(res);
		arString = wbuffer;
		break;
	}
	case TIMESTAMP:
	{
		// TODO: the timestamp constructor call SetCurrentTime which can
		// be expensive.
		MSIXTimestamp msixTime;
		msixTime.SetTime(mTimestamp);
		// make the string printable
		msixTime.GetStdString(asc);
		// TODO: don't use Utf8 version
		res = Utf8ToXMLString(arString, asc.c_str());
		ASSERT(res);
		break;
	}
		// should never happen
	default:
	case INVALID:
		ASSERT(0);
	}
}

void MSIXPropertyValue::Output(char * apWorkArea, int workAreaSize,
															 XMLWriter & arWriter) const
{
	char buffer[40];
	BOOL res;
	switch (mPropType)
	{
	case UNKNOWN_AS_UNISTRING:
	case UNISTRING:
		arWriter.OutputCharacterData(*mpWString, apWorkArea, workAreaSize);
		break;
	case STRING:
		arWriter.OutputCharacterData(mpAString->c_str());
		break;
	case INT32:
		sprintf(buffer, "%d", mInt);
		arWriter.OutputRawCharacters(buffer);
		break;
	case INT64:
		sprintf(buffer, "%I64d", mBigInt);
		arWriter.OutputRawCharacters(buffer);
		break;
	case FLOAT:
		sprintf(buffer, "%.15e", (double) mFloat);
		arWriter.OutputRawCharacters(buffer);
		break;
	case DOUBLE:
		sprintf(buffer, "%.15e", mDouble);
		arWriter.OutputRawCharacters(buffer);
		break;
	case BOOLEAN:
		if (mBoolean)
			arWriter.OutputRawCharacters("T");
		else
			arWriter.OutputRawCharacters("F");
		break;
	case DECIMAL:
	{
		int bufferSize = sizeof(buffer);
		res = mpDecimal->Format(buffer, bufferSize);
		arWriter.OutputRawCharacters(buffer);
		break;
	}
	case TIMESTAMP:
	{
		string asc;

		// TODO: the timestamp constructor call SetCurrentTime which can
		// be expensive.
		MSIXTimestamp msixTime;
		msixTime.SetTime(mTimestamp);
		// make the string printable
		msixTime.GetStdString(asc);

		arWriter.OutputRawCharacters(asc.c_str());
		break;
	}
		// should never happen
	default:
	case INVALID:
		ASSERT(0);
	}
}


void MSIXPropertyValue::ClearValue() const
{
	MSIXPropertyValue * thisPtr = const_cast<MSIXPropertyValue *>(this);

	if (mPropType == UNISTRING || mPropType == UNKNOWN_AS_UNISTRING)
	{
		ASSERT(mpWString);
		delete thisPtr->mpWString;
		thisPtr->mpWString = NULL;
	}
	else if (mPropType == STRING)
	{
		ASSERT(mpAString);
		delete thisPtr->mpAString;
		thisPtr->mpAString = NULL;
	}
	else if (mPropType == DECIMAL)
	{
		ASSERT(mpDecimal);
		delete thisPtr->mpDecimal;
		thisPtr->mpDecimal = NULL;
	}

	thisPtr->mPropType = INVALID;
}

MSIXPropertyValue & MSIXPropertyValue::operator =(const char * apAscii)
{
	if (mPropType == STRING)
	{
		// already a string - use it
		ASSERT(mpAString);
		*mpAString = apAscii;
	}
	else
	{
		// clear what was there if there was anything
		ClearValue();
		mpAString = new string(apAscii);
	}

	mPropType = STRING;
	return *this;
}

MSIXPropertyValue & MSIXPropertyValue::operator =(const string & arAscii)
{
	if (mPropType == STRING)
	{
		// already a string - use it
		ASSERT(mpAString);
		*mpAString = arAscii;
	}
	else
	{
		// clear what was there if there was anything
		ClearValue();
		mpAString = new string(arAscii);
	}

	mPropType = STRING;
	return *this;
}

MSIXPropertyValue & MSIXPropertyValue::operator =(const wchar_t * apUnicode)
{
	if (mPropType == UNISTRING)
	{
		// already a string - use it
		ASSERT(mpWString);
		*mpWString = apUnicode;
	}
	else
	{
		// clear what was there if there was anything
		ClearValue();
		mpWString = new MSIXString(apUnicode);
	}

	mPropType = UNISTRING;
	return *this;
}

MSIXPropertyValue & MSIXPropertyValue::operator =(const MSIXString & arUnicode)
{
	if (mPropType == UNISTRING)
	{
		// already a string - use it
		ASSERT(mpWString);
		*mpWString = arUnicode;
	}
	else
	{
		// clear what was there if there was anything
		ClearValue();
		mpWString = new MSIXString(arUnicode);
	}

	mPropType = UNISTRING;
	return *this;
}

MSIXPropertyValue & MSIXPropertyValue::operator =(int aInteger)
{
	ClearValue();

	mInt = aInteger;

	mPropType = INT32;
	return *this;
}

void MSIXPropertyValue::AssignInt64(__int64 aBigInteger)
{
	ClearValue();

	mBigInt = aBigInteger;

	mPropType = INT64;
}

MSIXPropertyValue & MSIXPropertyValue::operator =(float aFloat)
{
	ClearValue();

	mFloat = aFloat;

	mPropType = FLOAT;
	return *this;
}

MSIXPropertyValue & MSIXPropertyValue::operator =(double aDouble)
{
	ClearValue();

	mDouble = aDouble;

	mPropType = DOUBLE;
	return *this;
}

void MSIXPropertyValue::AssignTimestamp(time_t aTimestamp)
{
	ClearValue();

	mTimestamp = aTimestamp;

	mPropType = TIMESTAMP;
}

MSIXPropertyValue & MSIXPropertyValue::operator =(const MTDecimalVal & apDecimal)
{
	if (mPropType == DECIMAL)
	{
		// already a decimal - use it 
		ASSERT(mpDecimal);
		*mpDecimal = apDecimal;
	}	
	else
	{
		// clear what was there if there was anything
		ClearValue();
		mpDecimal = new MTDecimalVal(apDecimal);
	}

	mPropType = DECIMAL;
	return *this;
}

//the assignment method for type boolean
//can't use operator = since type BOOL is really
//type int in disguise. can't use C++ bool
//primitive because Solaris's compiler does
//not yet support it (although GCC does) 
void MSIXPropertyValue::AssignBoolean(BOOL aBool)
{
	ClearValue();

	mBoolean = aBool;

	mPropType = BOOLEAN;
}

void MSIXPropertyValue::SetUnknownValue(const MSIXString & arUnicode)
{
	ClearValue();

	// store in the same way as a unicode string
	operator = (arUnicode);

	// the property type is not yet known (castable to other types)
	mPropType = UNKNOWN_AS_UNISTRING;
}

void MSIXPropertyValue::SetUnknownValue(const wchar_t * apUnicode)
{
	ClearValue();

	// store in the same way as a unicode string
	operator = (apUnicode);

	// the property type is not yet known (castable to other types)
	mPropType = UNKNOWN_AS_UNISTRING;
}



BOOL MSIXPropertyValue::GetValue(const string * * apAscii) const
{
	if (mPropType == UNKNOWN_AS_UNISTRING)
	{
		if (!ConvertToAscii())
			return FALSE;
	}
	else if (mPropType != STRING)
		return FALSE;

	*apAscii = mpAString;
	return TRUE;
}

BOOL MSIXPropertyValue::GetValue(const MSIXString * * apUnicode) const
{
	if (mPropType == UNKNOWN_AS_UNISTRING)
	{
		if (!ConvertToUnistring())
			return FALSE;
	}
	else if (mPropType != UNISTRING)
		return FALSE;

	*apUnicode = mpWString;
	return TRUE;
}

BOOL MSIXPropertyValue::GetValue(int & arInt) const
{
	if (mPropType == UNKNOWN_AS_UNISTRING)
	{
		if (!ConvertToInt())
			return FALSE;
	}
	else if (mPropType != INT32)
		return FALSE;

	arInt = mInt;
	return TRUE;
}

BOOL MSIXPropertyValue::GetInt64Value(__int64 & arBigInt) const
{
	if (mPropType == UNKNOWN_AS_UNISTRING)
	{
		if (!ConvertToBigInt())
			return FALSE;
	}
	else if (mPropType != INT64)
		return FALSE;

	arBigInt = mBigInt;
	return TRUE;
}

BOOL MSIXPropertyValue::GetValue(float & arFloat) const
{
	if (mPropType == UNKNOWN_AS_UNISTRING)
	{
		if (!ConvertToFloat())
			return FALSE;
	}
	else if (mPropType != FLOAT)
		return FALSE;

	arFloat = mFloat;
	return TRUE;
}

BOOL MSIXPropertyValue::GetValue(double & arDouble) const
{
	if (mPropType == UNKNOWN_AS_UNISTRING)
	{
		if (!ConvertToDouble())
			return FALSE;
	}
	else if (mPropType != DOUBLE)
		return FALSE;

	arDouble = mDouble;
	return TRUE;
}

BOOL MSIXPropertyValue::GetTimestampValue(time_t & arTime) const
{
	if (mPropType == UNKNOWN_AS_UNISTRING)
	{
		if (!ConvertToTimestamp())
			return FALSE;
	}
	else if (mPropType != TIMESTAMP)
		return FALSE;

	arTime = mTimestamp;
	return TRUE;
}

BOOL MSIXPropertyValue::GetValue(const MTDecimalVal * * apDecimal) const
{
	if (mPropType == UNKNOWN_AS_UNISTRING)
	{
		if (!ConvertToDecimal())
			return FALSE;
	}
	else if (mPropType != DECIMAL)
		return FALSE;

	*apDecimal = mpDecimal;
	return TRUE;
}


//special case for BOOL since it is really an int
//and would have the same signature as GetValue(int)
BOOL MSIXPropertyValue::GetBooleanValue(BOOL & arBool) const
{
	if (mPropType == UNKNOWN_AS_UNISTRING)
	{
		if (!ConvertToBoolean())
			return FALSE;
	}
	else if (mPropType != BOOLEAN)
		return FALSE;

	arBool = mBoolean;
	return TRUE;
}


//TODO: use the standard XMLConfigNameVal::ConvertTo*** routine
BOOL MSIXPropertyValue::ConvertToInt() const
{
	MSIXPropertyValue * thisPtr = const_cast<MSIXPropertyValue *>(this);

	ASSERT(mPropType == UNKNOWN_AS_UNISTRING);

	const wchar_t * begin = mpWString->c_str();
	wchar_t * end;
	int intVal = (int) wcstol(begin, &end, 10);	// base 10
	if (end != (begin + wcslen(begin)))
		return FALSE;

	ClearValue();

	thisPtr->mInt = intVal;
	thisPtr->mPropType = INT32;

	return TRUE;
}

//TODO: use the standard XMLConfigNameVal::ConvertTo*** routine
BOOL MSIXPropertyValue::ConvertToBigInt() const
{
	MSIXPropertyValue * thisPtr = const_cast<MSIXPropertyValue *>(this);

	ASSERT(mPropType == UNKNOWN_AS_UNISTRING);

	const wchar_t * begin = mpWString->c_str();
	wchar_t * end;
	__int64 int64Val = _wcstoi64(begin, &end, 10);	// base 10
	if (end != (begin + wcslen(begin)))
		return FALSE;

	ClearValue();

	thisPtr->mBigInt = int64Val;
	thisPtr->mPropType = INT64;

	return TRUE;
}

//TODO: use the standard XMLConfigNameVal::ConvertTo*** routine
BOOL MSIXPropertyValue::ConvertToFloat() const
{
	MSIXPropertyValue * thisPtr = const_cast<MSIXPropertyValue *>(this);

	ASSERT(mPropType == UNKNOWN_AS_UNISTRING);

	const wchar_t * begin = mpWString->c_str();
	wchar_t * end;
	float floatVal = (float) wcstod(begin, &end);
	if (end != (begin + wcslen(begin)))
		return FALSE;

	ClearValue();

	thisPtr->mFloat = floatVal;
	thisPtr->mPropType = FLOAT;

	return TRUE;
}

//TODO: use the standard XMLConfigNameVal::ConvertTo*** routine
BOOL MSIXPropertyValue::ConvertToDouble() const
{
	MSIXPropertyValue * thisPtr = const_cast<MSIXPropertyValue *>(this);

	ASSERT(mPropType == UNKNOWN_AS_UNISTRING);

	const wchar_t * begin = mpWString->c_str();
	wchar_t * end;
	double doubleVal = wcstod(begin, &end);
	if (end != (begin + wcslen(begin)))
		return FALSE;

	ClearValue();

	thisPtr->mDouble = doubleVal;
	thisPtr->mPropType = DOUBLE;

	return TRUE;
}

BOOL MSIXPropertyValue::ConvertToBoolean() const
{
	MSIXPropertyValue * thisPtr = const_cast<MSIXPropertyValue *>(this);

	ASSERT(mPropType == UNKNOWN_AS_UNISTRING);

	BOOL boolVal;
	if (!MTTypeConvert::ConvertToBoolean(*mpWString, &boolVal))
		return FALSE;
	
	ClearValue();
	
	thisPtr->mBoolean = boolVal;
	thisPtr->mPropType = BOOLEAN;

	return TRUE;
}

//TODO: use the standard XMLConfigNameVal::ConvertTo*** routine
BOOL MSIXPropertyValue::ConvertToTimestamp() const
{
	MSIXPropertyValue * thisPtr = const_cast<MSIXPropertyValue *>(this);

	ASSERT(mPropType == UNKNOWN_AS_UNISTRING);

	string cstr = ascii(*mpWString);

	time_t timeVal;
	if (!MTParseISOTime(cstr.c_str(), &timeVal))
		return FALSE;

	ClearValue();

	thisPtr->mTimestamp = timeVal;
	thisPtr->mPropType = TIMESTAMP;

	return TRUE;
}

BOOL MSIXPropertyValue::ConvertToUnistring() const
{
	MSIXPropertyValue * thisPtr = const_cast<MSIXPropertyValue *>(this);

	ASSERT(mPropType == UNKNOWN_AS_UNISTRING);

	thisPtr->mPropType = UNISTRING;
	return TRUE;
}

BOOL MSIXPropertyValue::ConvertToAscii() const
{
	MSIXPropertyValue * thisPtr = const_cast<MSIXPropertyValue *>(this);

	ASSERT(mPropType == UNKNOWN_AS_UNISTRING);

	string * asciiStr = new string(ascii(*mpWString));

	ClearValue();

	thisPtr->mpAString = asciiStr;
	thisPtr->mPropType = STRING;

	return TRUE;
}

BOOL MSIXPropertyValue::ConvertToDecimal() const
{
	MSIXPropertyValue * thisPtr = const_cast<MSIXPropertyValue *>(this);

	ASSERT(mPropType == UNKNOWN_AS_UNISTRING);
	
	MTDecimalVal * decimalVal = new MTDecimalVal();
	
	if (!decimalVal->SetValue(mpWString->c_str()))
		return FALSE;
	
	ClearValue();

	thisPtr->mpDecimal = decimalVal;
	thisPtr->mPropType = DECIMAL;

	return TRUE;
}
