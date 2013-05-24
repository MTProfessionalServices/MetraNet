/**************************************************************************
 * @doc MSIX
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
 * @index | MSIX
 ***************************************************************************/

#ifndef _MSIX_H
#define _MSIX_H

#include <XMLParser.h>

class MTDecimalVal;
class MSIXSession;

typedef XMLString MSIXString;

#ifdef UNIX
typedef long long __int64;
#define _wcstoi64 wcstoll
inline long long wcstoll (const wchar_t *, wchar_t **, int)
{
  assert(0);  // no wcstoll until C++ 5.5 (ISO C99 support)
  return 0;
}
#endif

/************************************************ MSIXObject ***/

// NOTE: XMLUserObject has no member data, so
// deriving a class from it adds no size to the class

class MSIXObject : public XMLUserObject
{
public:
	virtual BOOL Parse(
		const char * apName,
		XMLObjectVector & arContents) = 0;

	// @cmember,mfunc ask if short/abbreviated tags should be used on output
	// @rdesc TRUE if short tags should be used
	static BOOL GetShortTags()
	{ return mShortTags; }

	// @cmember,mfunc call if you want to use short/abbreviated MSIX tags
	static void UseShortTags()
	{ mShortTags = TRUE; }

	// @cmember,mfunc call if you want to use full MSIX tags
	static void UseLongTags()
	{ mShortTags = FALSE; }

	static const char * ChooseTag(const char * apLong, const char * apShort)
	{
		return GetShortTags() ? apShort : apLong;
	}

private:
	// @cmember TRUE if you want to use short/abbreviated MSIX tags
	static BOOL mShortTags;
};


/***************************************** MSIXObjectFactory ***/

/* @class
 *
 * An object factory that knows how to parse MSIX tags.
 */
class MSIXObjectFactory : public XMLObjectFactory
{
// @access Public:
public:
	// @cmember constructor
	MSIXObjectFactory();

	XMLObject * CreateAggregate(
		const char * apName,
		XMLNameValueMap& apAttributes,
		XMLObjectVector & arContents);

	XMLObject * CreateData(const char * apData, int aLen,BOOL bCdataSection);

	MSIXObject * CreateMSIXObject(const char * apName);
};


/************************************************ MSIXParser ***/

class MSIXParser : public XMLParser
{
public:
	// @cmember destructor
	MSIXParser(int aBufferSize);
	virtual ~MSIXParser();

	MSIXObjectFactory mFactory;

	char * GetBuffer() const
	{ return mpParseBuffer; }

	int GetBufferSize() const
	{ return mBufferSize; }

private:
	char * mpParseBuffer;
	const int mBufferSize;
};


/***************************************** MSIXPropertyValue ***/

class MSIXPropertyValue
{
public:
	enum PropType
	{
		INVALID = 0,								// this value should never be used.
		STRING,											// Arbitrary-length character string
		UNISTRING,									// Arbitrary-length unicode character string
		INT32,											// String representation of 4-byte signed integer
		FLOAT,											// String representation of 4-byte IEEE floating
																// point number
		DOUBLE,											// String representation of 8-byte IEEE floating
																// point number
		TIMESTAMP,									// ISO8601 date string, as defined in appendix
		BOOLEAN,                    // boolean
		DECIMAL,
		UNKNOWN_AS_UNISTRING,				// type not yet determined.  stored as UNISTRING
		INT64											  // String representation of 8-byte signed integer
	};

public:
	MSIXPropertyValue();
	MSIXPropertyValue(const MSIXPropertyValue & arProp);
	virtual ~MSIXPropertyValue();

	MSIXPropertyValue & operator = (const MSIXPropertyValue & arProp);


	MSIXPropertyValue & operator =(const char * apAscii);
	MSIXPropertyValue & operator =(const string & arAscii);
	MSIXPropertyValue & operator =(const wchar_t * apUnicode);
	MSIXPropertyValue & operator =(const MSIXString & arUnicode);
	MSIXPropertyValue & operator =(int aInteger);
	MSIXPropertyValue & operator =(float aFloat);
	MSIXPropertyValue & operator =(double aDouble);
	MSIXPropertyValue & operator =(const MTDecimalVal & apDecimal);

	//non-overloaded assignment methods for use with new
	//property types that conflict with the exisiting
	//operator = methods (since BOOL is an int)
	void AssignBoolean(BOOL aBool);
  void AssignTimestamp(time_t aTimestamp);
  void AssignInt64(__int64 aInt64);


	void SetUnknownValue(const MSIXString & arUnicode);
	void SetUnknownValue(const wchar_t * apUnicode);

	void GetValueAsString(MSIXString & arString) const;

	void Output(char * apWorkArea, int workAreaSize,
							XMLWriter & arWriter) const;

	BOOL GetValue(const string * * apAscii) const;
	BOOL GetValue(const MSIXString * * apUnicode) const;
	BOOL GetValue(int & arInt) const;
	BOOL GetValue(float & arFloat) const;
	BOOL GetValue(double & arDouble) const;
	BOOL GetTimestampValue(time_t & arTime) const;
	BOOL GetValue(const MTDecimalVal * * apDecimal) const;
	BOOL GetBooleanValue(BOOL & arBool) const;
	BOOL GetInt64Value(__int64 & arInt) const;

	PropType GetType() const;

private:
	// !!!!!!!!!!!!!!!
	// NOTE: these functions need to be const because
	// GetValue needs to call them.  therefore the
	// data members are marked as mutable.  this
	// might not be the best solution to this problem

	void ClearValue() const;

	// conversions used when type is UNKNOWN_AS_UNISTRING
	BOOL ConvertToInt() const;
	BOOL ConvertToFloat() const;
	BOOL ConvertToDouble() const;
	BOOL ConvertToTimestamp() const;
	BOOL ConvertToUnistring() const;
	BOOL ConvertToAscii() const;
	BOOL ConvertToDecimal() const;
	BOOL ConvertToBoolean() const;
	BOOL ConvertToBigInt() const;

private:
	union
	{
		MSIXString * mpWString;			// UNISTRING
		string * mpAString;			// STRING
		int mInt;										// INT32
		float mFloat;								// FLOAT
		double mDouble;							// DOUBLE
		time_t mTimestamp;					// TIMESTAMP
		BOOL mBoolean;              // BOOLEAN
		MTDecimalVal * mpDecimal;	// DECIMAL
		__int64 mBigInt;							// INT64
	};

	PropType mPropType;
};


/*************************************************** MSIXUid ***/

class MSIXUid : public MSIXObject
{
public:
	MSIXUid()
	{ }

	MSIXUid(const MSIXUid & arUid)
	{ *this = arUid; }

	MSIXUid & operator =(const MSIXUid & arUid)
	{
		mUid = arUid.GetUid();
		return *this;
	}

	bool operator <(const MSIXUid & arUid) const
	{
		return GetUid() < arUid.GetUid();
	}

	bool operator ==(const MSIXUid & arUid) const
	{
		return GetUid() == arUid.GetUid();
	}

	void Generate();

	BOOL Init(const XMLString & arUid);

	BOOL Init(const char * apUid);

	void Clear();

	BOOL Parse(
		const char * apName,
		XMLObjectVector & arContents);

	const string & GetUid() const
	{ return mUid; }

	int GetTypeId() const
	{ return msTypeId; }

	static const char * msLongName;
	static const char * msShortName;
	static const int msTypeId;

	virtual void Output(XMLWriter & arWriter) const;

private:
	string mUid;
};


/****************************************** MSIXUidGenerator ***/

/*
<uid>	Element that makes a message or document unique. Base64 encoded.
Base64 encoding is described in RFC-1521.
16 bytes in length before base-64 encoding.
"+" denotes concatenation.  It is composed of:
  4 byte entity IP address + 
  4 byte current Unixtime value +
  4 byte arbitrary random number +
  4 byte counter, incrementing in each message sent by entity.
 The value is to be treated as an opaque string.
 Implementation may not extract data from this string for other uses.
*/

class MSIXUidGenerator
{
public:
	MSIXUidGenerator();
	virtual ~MSIXUidGenerator();

	static void Generate(string & arUid);
	static BOOL Decode(unsigned char * apID, const MSIXUid & arUid);
	static BOOL Decode(unsigned char * apID, const string & arUid);

	static void Encode(string & arUid, const unsigned char * apID);

	// IP address in string form
	//static dystring msIpAddress;
	static char msipaddr[20];

	// used for first four bytes of UID
	static unsigned char msIPBytes[4];

protected:
  //4 byte entity IP address + 
	//4 byte current Unixtime value +
  //4 byte arbitrary random number +
  //4 byte counter, incrementing in each message sent by entity.

	static unsigned int msCounter;
};

extern MSIXUidGenerator gGenerator;


/********************************************* MSIXTimestamp ***/

// ISO8601
// YYYY-MM-DDThh:mm:ssTZD
// ex: 1994-11-05T08:15:30-05:00
class MSIXTimestamp
{
public:
	// @cmember construct with the current time
	MSIXTimestamp();

	// @cmember construct with a given time
	MSIXTimestamp(time_t arTime);

	BOOL Parse(const char * aTimeString);

	void SetCurrentTime();

	void SetTime(time_t arTime);

	time_t GetTime() const;

	void GetStdString(string & arBuffer) const;
private:
	time_t mTime;
};


/************************************************ MSIXStatus ***/

//<status> Aggregate
//
//<status>	
//  <code> Matches <code> in <stype> aggregate.
//  [<severity>] Severity level: INFO, WARNING, ERROR.
//  [<message>] Human-readable status message.
//</status>	

class MSIXStatus : public MSIXObject
{
public:
	static const int msTypeId;

	// <status>
	static const char * msLongName;
	static const char * msShortName;

	// <code>
	static const char * msCodeLong;
	static const char * msCodeShort;

	// <message>
	static const char * msMessageLong;
	static const char * msMessageShort;

	// TODO: severity

	enum StatusSeverity
	{
		STATUS_INFO,
		STATUS_WARNING,
		STATUS_ERROR
	};

	MSIXStatus();

	MSIXStatus(const MSIXStatus & arStatus);

	MSIXStatus & operator =(const MSIXStatus & arStatus);

	ErrorObject::ErrorCode GetCode() const;
	void SetCode(ErrorObject::ErrorCode aCode);

	void SetMessage(const wchar_t * apMessage);
	const MSIXString & GetMessage() const;

	virtual void Output(XMLWriter & arWriter) const;

	BOOL Parse(
		const char * apName,
		XMLObjectVector & arContents);

	int GetTypeId() const
	{ return msTypeId; }

private:
	ErrorObject::ErrorCode mCode;

	MSIXString mMessage;

	// TODO: these aren't in the object right now - use a predefined set of
	// attributes
	//StatusSeverity mSeverity;
};


/***************************************** MSIXSessionStatus ***/

// NOTE: metratech extension to MSIX
//
//<sessionstatus> Aggregate
//
//<sessionstatus>
//  <code> Matches <code> in <stype> aggregate.
//  [<message>] Human-readable status message.
//  [<uid>] metered session this status refers to
//  [<error>..</error>] extended error information if an error occurred
//  [<beginsession>..</beginsession>] session properties after processing, if requested
//</status>	

class MSIXSessionStatus : public MSIXObject
{
public:
	// <sessionstatus>
	static const char * msLongName;
	static const char * msShortName;
	static const int msTypeId;
	
	// TODO: severity/message
	// <code>
	static const char * msCodeLong;
	static const char * msCodeShort;

	// <message>
	static const char * msMessageLong;
	static const char * msMessageShort;

	MSIXSessionStatus();
	virtual ~MSIXSessionStatus();

	ErrorObject::ErrorCode GetCode() const;

	void SetCode(ErrorObject::ErrorCode aCode);

	void SetStatusMessage(MSIXString & arMessage);
	const MSIXString & GetStatusMessage() const;

	void AttachSession(MSIXSession * apSession);
	MSIXSession * DetachSession();
	MSIXSession * GetSession();

	void SetUid(const MSIXUid & arUid);
	const MSIXUid & GetUid() const;

public:
	virtual void Output(XMLWriter & arWriter) const;

	BOOL Parse(
		const char * apName,
		XMLObjectVector & arContents);

	int GetTypeId() const
	{ return msTypeId; }

private:
	MSIXSessionStatus(const MSIXSessionStatus & arStatus);
	MSIXSessionStatus & operator =(const MSIXSessionStatus & arStatus);

	ErrorObject::ErrorCode mCode;
	MSIXString mMessage;

	MSIXSession * mpSession;

	// session this status refers to.
	// this is optional and isn't sent when only 1 session
	// is metered.  (this is necessary to be backwards compatible)
	MSIXUid mUid;

	// attributes
	//wstring mMessage;
	//StatusSeverity mSeverity;
};



/****************************************** MSIXUidAggregate ***/

// classes with only a uid

//<$(TAGNAME)>	
//  <uid>	UID </uid>
//</$(TAGNAME)>	

class MSIXUidAggregateBase : public MSIXObject
{
	virtual const char * GetTagName() const = 0;
	virtual const char * GetShortTagName() const = 0;

	virtual void Output(XMLWriter & arWriter) const;

	BOOL Parse(
		const char * apName,
		XMLObjectVector & arContents);

public:
	void SetUid(const MSIXUid & arUid);
	const MSIXUid & GetUid();

private:
	MSIXUid mUid;
};


/*********************************************** MSIXMessage ***/

/*
p4
Tag	Description
<msix>	
  [<signature>]	Optional digital signature.  Computed without this tag and value.
  <timestamp>	Time the message header is created.</timestamp>
  <version>	Protocol version.  Literal: "1.0"
  <uid>	Client-assigned flow ID.
  <entity>	Host name of entity creating this MSIX message
  <body></body>
  	One or more message body aggregates.
   The <body></body> tags are not literal: They are to be replaced
   with valid message aggregate tags, defined in this document's
   Protocol Message Sets section.
</msix>	
*/

typedef vector<MSIXObject *> MSIXObjectVector;

class MSIXMessage : public MSIXObject
{
public:
	// <msix>
	static const char * msLongName;
	static const char * msShortName;
	static const int msTypeId;

	// <timestamp>
	static const char * msTimestampLong;
	static const char * msTimestampShort;

	// <version>
	static const char * msVersionLong;
	static const char * msVersionShort;

	// <entity>
	static const char * msEntityLong;
	static const char * msEntityShort;

	// <transactionid>
	static const char * msTransactionIDLong;
	static const char * msTransactionIDShort;

	// <listenertransactionid>
	static const char * msListenerTransactionIDLong;
	static const char * msListenerTransactionIDShort;

	static const char * msSessionContextUserNameLong;
	static const char * msSessionContextUserNameShort;

	static const char * msSessionContextPasswordLong;
	static const char * msSessionContextPasswordShort;

	static const char * msSessionContextNamespaceLong;
	static const char * msSessionContextNamespaceShort;

	static const char * msSessionContextLong;
	static const char * msSessionContextShort;

	MSIXMessage();
	~MSIXMessage();

	virtual void Output(XMLWriter & arWriter) const;

	BOOL Parse(
		const char * apName,
		XMLObjectVector & arContents);

	int GetTypeId() const
	{ return msTypeId; }


	void DeleteBody(BOOL aDeleteFlag = TRUE);

	void SetCurrentTimestamp();

	const MSIXTimestamp & GetTimestamp() const
	{ return mTimestamp; }

	void SetVersion(const wchar_t * apVersion);

	const wchar_t * GetVersion() const
	{ return mVersion.GetBuffer(); }

	void GenerateUid();

	void SetUid(const char * apUid);

	const MSIXUid & GetUid() const
	{ return mUid; }

	void SetEntity(const wchar_t * apEntity);

	const wchar_t * GetEntity() const
	{ return mEntity.GetBuffer(); }

	void SetTransactionID(const wchar_t * apTransactionID);
	const wchar_t * GetTransactionID() const
	{ return mTransactionID.GetBuffer(); }

	void SetListenerTransactionID(const wchar_t * apTransactionID);
	const wchar_t * GetListenerTransactionID() const
	{ return mListenerTransactionID.GetBuffer(); }

	void SetSessionContext(const wchar_t * apSessionContext);
	void SetSessionContextUserName(const wchar_t * apUserName);
	void SetSessionContextPassword(const wchar_t * apPassword);
	void SetSessionContextNamespace(const wchar_t * apNamespace);



	void AddToBody(MSIXObject * apObject);

	const MSIXObjectVector & GetContents() const
	{ return mBody; }

	MSIXObjectVector & GetContents()
	{ return mBody; }

private:
	// TODO: signature is optional now so we'll leave it out
	//MSIXString mSignature;

	// @cmember timestamp of message
	MSIXTimestamp mTimestamp;

	// @cmember version of message
	// TODO: maybe this should be an int
	// 	     0x0100 = 1.0, 0x0101 = 1.1, ...
	FastBuffer<wchar_t, 10> mVersion;

	// @cmember client assigned flow ID
	MSIXUid mUid;
	// @cmember host name of entity creating this MSIX message
	FastBuffer<wchar_t, 64> mEntity;

	// transaction IDs 
	FastBuffer<wchar_t, 256> mTransactionID;
	FastBuffer<wchar_t, 256> mListenerTransactionID;

	// ----- 3.0 stuff ------ TODO: ask about the size?
	FastBuffer<wchar_t, 256> mSessionContext;
	FastBuffer<wchar_t, 256> mSessionContextUserName;
	FastBuffer<wchar_t, 256> mSessionContextPassword;
	FastBuffer<wchar_t, 256> mSessionContextNamespace;

	// @cmember one or more message body aggregates
	MSIXObjectVector mBody;

	// @cmember if TRUE, delete the objects in the body
	BOOL mDeleteBody;
};



/************************************** MSIXSessionReference ***/

/*
 * @class
 * base class for commitsession and beginsession.
 * both these message/objects contain the DN and uid
 */

class MSIXSessionReference : public MSIXObject
{
public:
	MSIXSessionReference();

	void SetName(const char * apName);

	const string & GetName() const;

	void GenerateUid();

	void SetUid(const MSIXUid & arUid);
	const MSIXUid & GetUid() const;

protected:
	string mDn;

	MSIXUid mUid;
};


/************************************************ PropMapKey ***/

class PropMapKey : public FastBuffer<char, 64>
{
public:
	PropMapKey()
	{ }

	PropMapKey(const char * apKey) : FastBuffer<char, 64>(apKey)
	{ }

	bool operator < (const PropMapKey & arOther) const
	{
		if (mtstrcasecmp(arOther.GetBuffer(), GetBuffer()) < 0)
			return TRUE;
		else
			return FALSE;
	}
	
	bool operator == (const PropMapKey & arOther) const
	{
		return (0 == mtstrcasecmp(arOther.GetBuffer(), GetBuffer()));
	}
};


/*********************************************** MSIXSession ***/

/*
p12
REQUEST: <beginsession>
Tag	Description
<beginsession>	
  <dn>	Distinguished Name of service
  <commit>	Y or N.  If Y, commit submission immediately
  <accountid>	String that uniquely identifies account to debit.
              MSIX treats account identifiers as opaque strings.
  [<parentid>]	UID of parent session, if defining compound service
  [<properties></properties>]	Contains one or more property aggregates
</beginsession>	
*/

class MSIXSession : public MSIXSessionReference
{
public:
	MSIXSession();
	virtual ~MSIXSession();

	MSIXSession(MSIXSession & arSession);

	MSIXSession & operator =(const MSIXSession & arSess);
	void Copy(const MSIXSession * apSession);

	// unknown version
	BOOL AddUnknownProperty(const char * apName,
													const MSIXString & arVal);
	// Unicode/direct version
	BOOL AddProperty(const char * apName,
									 const MSIXString & arVal);

	// ASCII helper function
	BOOL AddProperty(const char * apName,
									 const char * apAsciiVal);

	// INT32 version
	BOOL AddProperty(const char * apName,
									 int aInt32);

	// INT64 version
	BOOL AddInt64Property(const char * apName,
                           __int64 aInt64);

	// float version
	BOOL AddProperty(const char * apName,
									 float aFloat);

	// double version
	BOOL AddProperty(const char * apName,
									 double aDouble);

	// timestamp version
	BOOL AddTimestampProperty(const char * apName,
									 time_t aTimestamp);

	// decimal version
	BOOL AddProperty(const char * apName, 
									 const MTDecimalVal & arVal);
    
	// boolean version
	BOOL AddBooleanProperty(const char * apName,
													BOOL aBool);


	// Unicode/direct version
	BOOL SetProperty(const char * apName,
									 const MSIXString & arVal);

	// ASCII helper function
	BOOL SetProperty(const char * apName,
									 const char * apAsciiVal);

	// INT32 version
	BOOL SetProperty(const char * apName,
									 int aInt32);

	// INT64 version
	BOOL SetInt64Property(const char * apName,
									 __int64 aInt64);

	// float version
	BOOL SetProperty(const char * apName,
									 float aFloat);

	// double version
	BOOL SetProperty(const char * apName,
									 double aDouble);

	// timestamp version
	BOOL SetTimestampProperty(const char * apName,
									 time_t aTimestamp);
	
	// decimal version
	BOOL SetProperty(const char * apName, 
									 const MTDecimalVal & arVal);

	// boolean version
	BOOL SetBooleanProperty(const char * apName,
									 BOOL aBool);

	// Unicode/direct version
	BOOL GetProperty(const char * apName,
									 const MSIXString * * apVal) const;

	// ASCII helper function
	BOOL GetProperty(const char * apName,
									 const string * * apVal) const;

	// INT32 version
	BOOL GetProperty(const char * apName,
									 int & arInt32) const;

	// INT64 version
	BOOL GetInt64Property(const char * apName,
									 __int64 & arInt64) const;

	// float version
	BOOL GetProperty(const char * apName,
									 float & arFloat) const;

	// double version
	BOOL GetProperty(const char * apName,
									 double & arDouble) const;

	// timestamp version
	BOOL GetTimestampProperty(const char * apName,
									 time_t & arTimestamp) const;

	// decimal version
	BOOL GetProperty(const char * apName, 
									 const MTDecimalVal * * apVal) const;

	// boolean version
	BOOL GetBooleanProperty(const char * apName,
													BOOL & arBool) const;


	BOOL SetParentUid(const XMLString & arUid);

	BOOL SetParentUid(const MSIXUid & arUid);

	void ClearParentUid();

	const MSIXUid & GetParentUid() const;

	void SetCommit(BOOL aCommit)
	{ mCommit = aCommit; }

	BOOL GetCommit() const
	{ return mCommit; }


	enum InsertHint
	{
		Insert,
		Update,
		Unknown
	};

	void SetInsertHint(InsertHint aHint)
	{ mInsertHint = aHint; }

	InsertHint GetInsertHint() const
	{ return mInsertHint; }

	BOOL GetFeedbackRequested() const
	{ return mFeedback; }
		
	void SetFeedbackRequested(BOOL aFlag)
	{ mFeedback = aFlag; }

	// dn -> value mapping
	// NOTE: have to use MSIXPropertyValue pointers instead of values
	// because the HashDictionary doesn't work efficiently with values.
	// Because we use pointers, we also need to free all values from
	// the list on destruction, and copy all values when copying

	typedef map<PropMapKey, MSIXPropertyValue *> PropMap;

	// TODO: fix this
	PropMap & GetProperties()
	{
		return mProperties;
	}

	// TODO: fix this
	const PropMap & GetProperties() const
	{
		return mProperties;
	}

	int GetPropertyCount() const
	{
		return mProperties.size();
	}

private:
	// @cmember read properties into a name->value map
	BOOL ReadProperties(XMLAggregate * apAgg, PropMap & arMap);

public:
	BOOL Parse(
		const char * apName,
		XMLObjectVector & arContents);

	int GetTypeId() const
	{ return msTypeId; }

	virtual void Output(XMLWriter & arWriter) const;


public:
	static const int msTypeId;

	// <beginsession>
	static const char * msLongName;
	static const char * msShortName;

	// <dn>
	static const char * msDnLong;
	static const char * msDnShort;

	// <commit>
	static const char * msCommitLong;
	static const char * msCommitShort;

	// <insert>
	static const char * msInsertLong;
	static const char * msInsertShort;

	// <feedback>
	static const char * msFeedbackLong;
	static const char * msFeedbackShort;

	// <parentid>
	static const char * msParentIdLong;
	static const char * msParentIdShort;

	// <properties>
	static const char * msPropsLong;
	static const char * msPropsShort;

	// <property>
	static const char * msPropLong;
	static const char * msPropShort;

	// <value>
	static const char * msValueLong;
	static const char * msValueShort;

protected:
	PropMap mProperties;

	MSIXUid mParentUid;

private:
	// @cmember if TRUE, commit this session when it gets to the server
	BOOL mCommit;

	// @cmember if we know the server has seen the transaction, use Update.
	//          if we know it hasn't seen the transaction, use Insert.
	//          if we don't know, use Unknown.
	InsertHint mInsertHint;

	// @cmember TRUE if the SDK user wants the results of the computation
	//          done on this session.
	BOOL mFeedback;
};

/*
 * most compilers don't allow template members yet, so these have been brought
 * out of the MSIXSession class.
 */
template<class T> BOOL SetNewPropertyValue(MSIXSession::PropMap & arMap,
																					 const char * apName, const T & arVal);
template<class T> BOOL SetExistingPropertyValue(MSIXSession::PropMap & arMap,
																								const char * apName, const T & arVal);


/**************************************** MSIXBeginSessionRS ***/

/*
p12
<beginsessionrs>
  <uid> UID of <session> document
</beginsessionrs>
*/

class MSIXBeginSessionRS : public MSIXUidAggregateBase
{
public:
	static const char * msLongName;
	static const char * msShortName;
	static const int msTypeId;

	const char * GetTagName() const
	{ return msLongName; }

	const char * GetShortTagName() const
	{ return msShortName; }

	int GetTypeId() const
	{ return msTypeId; }
};

/***************************************** MSIXCommitSession ***/

/*
p13
<commitsession>	
  <dn> service name </dn>
  <uid>	UID of top-level (non-child) <session> document.
</commitsession>	
*/

class MSIXCommitSession : public MSIXSessionReference
{
public:
	static const char * msLongName;
	static const char * msShortName;
	static const int msTypeId;

	static const char * msDnLong;
	static const char * msDnShort;

	int GetTypeId() const
	{ return msTypeId; }

	virtual void Output(XMLWriter & arWriter) const;

	BOOL Parse(
		const char * apName,
		XMLObjectVector & arContents);
};


/*************************************** MSIXCommitSessionRS ***/

/*
p14
<commitsessionrs>	
  <uid>	UID of top-level <session> document
</commitsessionrs>	
*/

class MSIXCommitSessionRS : public MSIXUidAggregateBase
{
public:
	static const char * msLongName;
	static const char * msShortName;
	static const int msTypeId;

	const char * GetTagName() const
	{ return msLongName; }

	const char * GetShortTagName() const
	{ return msShortName; }

	int GetTypeId() const
	{ return msTypeId; }
};


// hack used temporarily to add an extra = to UIDs
#define ADD_EQUAL_SIGN

#ifdef ADD_EQUAL_SIGN
extern BOOL gAddEqualSign;
#endif // ADD_EQUAL_SIGN

#endif /* _MSIX_H */
