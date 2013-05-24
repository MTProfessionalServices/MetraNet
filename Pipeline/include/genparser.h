/**************************************************************************
 * @doc GENPARSER
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
 * Created by: 
 *
 * $Date: 9/11/2002 9:45:57 AM$
 * $Author: Alon Becker$
 * $Revision: 14$
 *
 * @index | GENPARSER
 ***************************************************************************/

#ifndef _GENPARSER_H
#define _GENPARSER_H

#include <errobj.h>
#include <xmlparse.h>

#include <ServicesCollection.h>
#include <pipemessages.h>
#import <MTConfigLib.tlb>
#include <pipelineconfig.h>
#include <mtcryptoapi.h>
#import <MTEnumConfigLib.tlb> 
#import <MTPipelineLib.tlb> rename("EOF", "XEOF")
#include <sharedsess.h>
#include <sessionbuilder.h>
#include <map>

using std::map;
using std::string;

// comment out the next line to enable verbose mode that prints
// debugging messages
//#define GENPARSER_VERBOSE

// use fastcall for methods that are called very frequently
#ifndef FASTCALL
#define FASTCALL __fastcall
#endif // FASTCALL

/********************************************* state machine ***/

enum PipelineMSIXParserState
{
//	START_STATE=0,							// first state

	OPEN_MSIX=0,								  // <msix>

	OPEN_TIMESTAMP,						  // <timestamp>2001-06-14T14:15:31Z</timestamp>
	VALUE_TIMESTAMP,
	CLOSE_TIMESTAMP,

	OPEN_VERSION,								// <version>1.1</version>
	VALUE_VERSION,
	CLOSE_VERSION,

	OPEN_MESSAGE_UID,						// <uid>fwAAAcB5UXjZhyyh4/9vOw==</uid>
	VALUE_MESSAGE_UID,
	CLOSE_MESSAGE_UID,

	OPEN_ENTITY,								// <entity>127.0.0.1</entity>
	VALUE_ENTITY,
	CLOSE_ENTITY,

	OPEN_LISTENERTRANSACTIONID,	// <listenertransactionid>base64 string</listenertransactionid>
	VALUE_LISTENERTRANSACTIONID,
	CLOSE_LISTENERTRANSACTIONID,

	OPEN_TRANSACTIONID,	  			// <transactionid>base64 string</transactionid>
	VALUE_TRANSACTIONID,
	CLOSE_TRANSACTIONID,

	OPEN_CONTEXTUSERNAME,				// <contextusername>name</contextusername>
	VALUE_CONTEXTUSERNAME,
	CLOSE_CONTEXTUSERNAME,

	OPEN_CONTEXTPASSWORD,				// <contextpassword>pass</contextpassword>
	VALUE_CONTEXTPASSWORD,
	CLOSE_CONTEXTPASSWORD,

	OPEN_CONTEXTNAMESPACE,			// <contextnamespace>pass</contextnamespace>
	VALUE_CONTEXTNAMESPACE,
	CLOSE_CONTEXTNAMESPACE,

	OPEN_CONTEXT,								// <context>pass</context>
	VALUE_CONTEXT,
	CLOSE_CONTEXT,

	OPEN_BEGINSESSION,					// <beginsession>

	OPEN_SESSION_DN,						//   <dn>metratech.com/TestService</dn>
	VALUE_SESSION_DN,
	CLOSE_SESSION_DN,

	OPEN_SESSION_UID,						//   <uid>fwAAAZDyT3hKEMQF4v9vOw==</uid>
	VALUE_SESSION_UID,
	CLOSE_SESSION_UID,

	OPEN_SESSION_PARENTID,			//   <parentid>fwAAAZDyT3hKEMQF4v9vOw==</parentid>
	VALUE_SESSION_PARENTID,
	CLOSE_SESSION_PARENTID,

	OPEN_COMMIT,								//   <commit>Y</commit>
	VALUE_COMMIT,
	CLOSE_COMMIT,

	OPEN_INSERT,								//   <insert>Y</insert>
	VALUE_INSERT,
	CLOSE_INSERT,

	OPEN_FEEDBACK,							//   <feedback>Y</feedback>  (optional)
	VALUE_FEEDBACK,
	CLOSE_FEEDBACK,


	OPEN_PROPERTIES,						//   <properties>

	OPEN_PROPERTY,							//     <property>

	OPEN_PROPERTY_DN,						//       <dn>Units</dn>
	VALUE_PROPERTY_DN,
	CLOSE_PROPERTY_DN,

	OPEN_PROPERTY_VALUE,				//       <value>1.003400000000000e+002</value>
	VALUE_PROPERTY_VALUE,
	CLOSE_PROPERTY_VALUE,


	CLOSE_PROPERTY,							//      </property>

	NEXT_PROPERTY,							//   another <property> or </properties>

	CLOSE_BEGINSESSION,					// </beginsession>

	NEXT_SESSION,								// another <beginsession> or </msix>

	TERMINATE_PARSE,						// no additional tags accepted 

	// terminator - must be last
	NUMBER_OF_STATES
};

enum PipelineMSIXAction
{
	OPEN_TAG,
	CLOSE_TAG,
	CHAR_DATA,
	ANY_ACTION,

	// terminator - must be last
	NUMBER_OF_ACTIONS
};


/******************************************** ServiceDefProp ***/

// base class for service def properties.  derived classes
// convert the string to the appropriate type and set the property appropriately.
template <class _SessionBuilder> 
class ServiceDefProp
{
public:
	ServiceDefProp()
		: mpSessionBuilder(NULL), mHasDefault(FALSE), mIsRequired(FALSE), mIsSpecial(FALSE)
	{ }

	virtual ~ServiceDefProp()
	{ }

	void SetPropID(int aID)
	{ mPropID = aID; }

	int GetPropID()
	{ return mPropID; }

	void SetPropName(const char * apName)
	{ mPropName = apName; }

	const std::string & GetName() const
	{ return mPropName; }

	void SetRequired(BOOL aRequired)
	{ mIsRequired = aRequired; }

	BOOL IsRequired()
	{ return mIsRequired; }

	void SetSpecial(BOOL aSpecial)
	{ mIsSpecial = aSpecial; }

	BOOL IsSpecial() const
	{ return mIsSpecial; }

	void SetSessionBuilder(_SessionBuilder ** apSessionBuilder)
	{ mpSessionBuilder = apSessionBuilder; }

	// return true if this is a string property.  used to update
	// property counts.
	virtual BOOL IsString() const
	{ return FALSE; }

	virtual BOOL SetProperty(const char * apStr, int aLen) = 0;

	// parses a string default value and converts it to the property's subclass type
	virtual BOOL InitDefault(const char * apStr) = 0;

	// sets the default in session if the property does not exist
	virtual BOOL SetDefault() = 0;
	
	BOOL HasDefault()
	{ return mHasDefault; }


protected:
	// ID of the property name, used for setting values in the session
	int mPropID;
	// property name, for logging and diagnostics only
	std::string mPropName;

	_SessionBuilder ** mpSessionBuilder;

	BOOL mIsRequired;
	BOOL mIsSpecial;
	BOOL mHasDefault; // set to TRUE if InitDefault succeeds
};

template <class _SessionBuilder> 
class IntServiceDefProp : public ServiceDefProp<_SessionBuilder>
{
	virtual BOOL SetProperty(const char * apStr, int aLen);
	virtual BOOL InitDefault(const char * apStr);
	virtual BOOL SetDefault();
	BOOL ConvertString(const char * apStr, int aLen, long& arValue);

private:
	long mDefaultVal;
	
};

template <class _SessionBuilder> 
class Int64ServiceDefProp : public ServiceDefProp<_SessionBuilder>
{
	virtual BOOL SetProperty(const char * apStr, int aLen);
	virtual BOOL InitDefault(const char * apStr);
	virtual BOOL SetDefault();
	BOOL ConvertString(const char * apStr, int aLen, __int64& arValue);

private:
	__int64 mDefaultVal;
	
};

template <class _SessionBuilder> 
class DoubleServiceDefProp : public ServiceDefProp<_SessionBuilder>
{
	virtual BOOL SetProperty(const char * apStr, int aLen);
	virtual BOOL InitDefault(const char * apStr);
	virtual BOOL SetDefault();
	BOOL ConvertString(const char * apStr, int aLen, double& arValue);

private:
	double mDefaultVal;
	
};

template <class _SessionBuilder> 
class BooleanServiceDefProp : public ServiceDefProp<_SessionBuilder>
{
	virtual BOOL SetProperty(const char * apStr, int aLen);
	virtual BOOL InitDefault(const char * apStr);
	virtual BOOL SetDefault();
	BOOL ConvertString(const char * apStr, int aLen, bool& arValue);

private:
	bool mDefaultVal;
	
};

template <class _SessionBuilder> 
class TimestampServiceDefProp : public ServiceDefProp<_SessionBuilder>
{
	virtual BOOL SetProperty(const char * apStr, int aLen);
	virtual BOOL InitDefault(const char * apStr);
	virtual BOOL SetDefault();
	BOOL ConvertString(const char * apStr, int aLen, time_t& arValue);

private:
	time_t mDefaultVal;
	
};

template <class _SessionBuilder> 
class StringServiceDefProp : public ServiceDefProp<_SessionBuilder>
{
	virtual BOOL SetProperty(const char * apStr, int aLen);
	virtual BOOL InitDefault(const char * apStr);
	virtual BOOL SetDefault();
	BOOL ConvertString(const char * apStr, int aLen,
										 wchar_t * apValue, int aBufferLen);
	
	BOOL IsString() const;

	BOOL SetStringInSession(const wchar_t * apStr, int aLen, SharedPropVal * prop);


private:
	wchar_t mDefaultVal[300]; // 256 + extra safety padding
	int mDefaultLen;
};

template <class _SessionBuilder> 
class EncryptedStringServiceDefProp : public ServiceDefProp<_SessionBuilder>
{
	virtual BOOL SetProperty(const char * apStr, int aLen);
	virtual BOOL InitDefault(const char * apStr);
	virtual BOOL SetDefault();
	BOOL ConvertString(const char * apStr, int aLen, wchar_t * apValue, int aBufferLen);
	BOOL SetStringInSession(const wchar_t * apStr, int aLen, SharedPropVal * prop);

	BOOL IsString() const;

	BOOL EncryptString(std::wstring & arEncrypted, const wchar_t * apStr, int aLen);
public:
	void SetCrypto(CMTCryptoAPI * apCrypto)
	{
		mpCrypto = apCrypto;
	}

private:
	// used for encrypting property values
  CMTCryptoAPI * mpCrypto;

	wchar_t mDefaultVal[300]; // 256 + extra safety padding
	int mDefaultLen;
};

template <class _SessionBuilder> 
class EnumServiceDefProp : public ServiceDefProp<_SessionBuilder>
{
public:
	EnumServiceDefProp(MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig,
										 const wchar_t * apNamespace,
										 const wchar_t * apEnumeration)
		: mEnumConfig(aEnumConfig), mNamespace(apNamespace), mEnumeration(apEnumeration)
	{ }

	virtual BOOL SetProperty(const char * apStr, int aLen);
	virtual BOOL InitDefault(const char * apStr);
	virtual BOOL SetDefault();
	BOOL ConvertString(const char * apStr, int aLen, long& arValue);

private:
	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
	_bstr_t mNamespace;
	_bstr_t mEnumeration;
	long mDefaultVal;
};


template <class _SessionBuilder> 
class DecimalServiceDefProp : public ServiceDefProp<_SessionBuilder>
{
public:
	DecimalServiceDefProp()
	{
		// decimals support larger values then how we represent them in the database (22,10)
		METRANET_DECIMAL_MIN.SetValue("-999999999999.9999999999");
		METRANET_DECIMAL_MAX.SetValue( "999999999999.9999999999");
	}

private:
	virtual BOOL SetProperty(const char * apStr, int aLen);
	virtual BOOL InitDefault(const char * apStr);
	virtual BOOL SetDefault();
	BOOL ConvertString(const char * apStr, int aLen, DECIMAL& arValue);

private:
	DECIMAL mDefaultVal;

	
	// TODO: should be static but had linking issues
	MTDecimal METRANET_DECIMAL_MIN;
	MTDecimal METRANET_DECIMAL_MAX;
};



/******************************************** ServiceDefName ***/

// used for a key into an STL map.  strings don't have to be null terminated.
// for lookups, the object doesn't allocate storage for the key (it does for inserts).

class ServiceDefName
{
public:
	// default constructor required by STL
	ServiceDefName()
		: mpBuffer(NULL), mpName(NULL), mLen(0)
	{ }

	~ServiceDefName()
	{
		delete [] mpBuffer;
		mpBuffer = NULL;
	}

	// copy constructor may be required by STL
	ServiceDefName(const ServiceDefName & arOther)
	{
		if (arOther.mpBuffer)
		{
			mpBuffer = new char[arOther.mLen + 1];
			strcpy(mpBuffer, arOther.mpName);
			mpName = mpBuffer;
		}
		else
			mpName = arOther.mpName;

		mLen = arOther.mLen;
	}


	// store a name.  used when we hold the hold string
	// in a prepopulated map
	// the object manages the memory.
	ServiceDefName(const char * apName)
	{
		mpBuffer = new char[strlen(apName) + 1];
		strcpy(mpBuffer, apName);
		mLen = strlen(apName);
		mpName = mpBuffer;
	}

	// hold a reference to the string.  The string is NOT null
	// terminated.
	// the object does not manage the memory.
	ServiceDefName(const char * apName, int aLen)
	{
		mpBuffer = NULL;
		mpName = apName;
		mLen = aLen;
	}

	// required for STL map use
	bool operator < (const ServiceDefName & arOther) const
	{
		int len = min(mLen, arOther.mLen);		
		int ret = strnicmp(mpName, arOther.mpName, len);
		if (ret == 0)
			return (mLen < arOther.mLen);

		return (ret < 0);
	}
	
	// required for STL map use
	BOOL operator == (const ServiceDefName & arOther) const
	{
		return (mLen == arOther.mLen
						&& 0 == strnicmp(mpName, arOther.mpName, mLen));
	}

	const char * mpName;
	char * mpBuffer;
	int mLen;
};





/************************************** MSIXParserServiceDef ***/

template <class _SessionBuilder> 
class MSIXParserServiceDef : public ObjectWithError
{
	typedef std::map<ServiceDefName, ServiceDefProp<_SessionBuilder> *> PropIDMap;
public:
	typedef std::vector<ServiceDefProp<_SessionBuilder> *> ServiceDefPropVector;
	
	~MSIXParserServiceDef();

	ServiceDefProp<_SessionBuilder> * GetProp(const char * apName, int aLen) const
	{
		ServiceDefName key(apName, aLen);
		PropIDMap::const_iterator it = mPropIDs.find(key);
		if (it == mPropIDs.end())
			// TODO;
			return NULL;

		return it->second;
	}

	BOOL Init(CMSIXDefinition * apDef,
						MTPipelineLib::IMTNameIDPtr aNameID,
						_SessionBuilder ** apSessionBuilder,
						MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig,
						CMTCryptoAPI * apCrypto);

	int GetID() const
	{ return mID; }

	const char * GetName() const
	{ return mName.c_str(); }

	BOOL RequiresEncryption() const
	{ return mRequiresEncryption; }

	const std::vector<std::string> & GetEncryptedPropList() const
	{ return mEncryptedPropList; }

	long GetTotalRequiredProps() const
	{ return mTotalRequiredProps; }

	long GetTotalNonRequiredProps() const
	{ return mTotalNonRequiredProps; }

	// number of optional properties that are strings
	long GetTotalNonRequiredStringProps() const
	{ return mTotalNonRequiredStringProps; }

	// slower than GetNonRequiredPropsVector since
	// this method is only used in error cases
	void GetRequiredPropsVector(ServiceDefPropVector &) const;

	const ServiceDefPropVector & GetNonRequiredPropsVector() const
	{ return mNonRequiredPropsVector; }

private:
	BOOL PropertyRequiresEncryption(const wchar_t * apName)
	{
		// encrypt if last character of property is '_'
		int len = wcslen(apName);
		if (len > 1 && apName[len - 1] == L'_')
			return TRUE;
		return FALSE;
	}

	
private:
	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;

	// if true, at least one property of this service def
	// is an encrypted property (ends with an underscore)
	BOOL mRequiresEncryption;

	// list of properties that must be encrypted.
	// these lists are used after validation to quickly walk through
	// the a group of sessions, encrypting properties
	std::vector<std::string> mEncryptedPropList;

	// the amount of required properties
	long mTotalRequiredProps;

	// the amount of non-required properties which have a non-null default
	// value and are not a special property
	long mTotalNonRequiredProps;

	// the amount of non-required string properties which have a non-null
	// default value and are not a special property
	long mTotalNonRequiredStringProps;

	// list of non-required properties *WITH* non-null defaults.
	// these lists are used after validation to quickly walk through
	// the a group of sessions, potentially applying defaults
	ServiceDefPropVector mNonRequiredPropsVector;

	int mID;
	std::string mName;

	PropIDMap mPropIDs;
	CMSIXDefinition * mpService;
};


/**************************************** PipelineMSIXParser ***/

// validation actually parses out some information as well.
// this info is returned through this struction
struct ValidationData
{

	ValidationData();
	~ValidationData();

	// reinitializes a ValidationData object to its initial state
	void Clear();

	// tracks whether message has sessions associated
	// with service defs that have encrypted properties
	BOOL mHasServiceDefWithEncryptedProp;

	// TRUE if feedback was requested for this message
	BOOL mRequiresFeedback;

	// TRUE if the message is being sent as a retry
	BOOL mIsRetry;

	// IP address sent with the message
	char mIPAddress[32];

	// time the session was metered, as Unix time
	time_t mMeteredTime;

	// encoded batch ID
	char mMessageID[32];

	// SDK version string
	char mSDKVersion[16];

	// transaction id
	char mTransactionID[256];

	// if false, don't set default values of optional properties
	BOOL mAddDefaultValues;

	// counts of each property type.  Used to determine
	// how big the session server will be after generating these sessions.
	// if null, property counts aren't tallied.
	PropertyCount * mpPropCount;

	// session context username
	char mContextUsername[256];

	// session context password
	char mContextPassword[256];

	// session context namespace
	char mContextNamespace[256];

	// serialized session context (allocated buffer)
	char * mpSessionContext;

	// list of errors seen during validation
	map<string, ErrorObject> mErrors;
};


template <class _SessionBuilder>
class PipelineMSIXParser : public ObjectWithError
{
public:
	PipelineMSIXParser();
	virtual ~PipelineMSIXParser();

	BOOL InitForParse();
	BOOL InitForParse(const PipelineInfo & arInfo);

	BOOL InitForValidate();
	BOOL InitForValidate(const PipelineInfo & arInfo);

	BOOL SetupParser();

	// parse the stream and create a session object
	BOOL Parse(const char * apStr, int aLen,
						 ISessionProduct ** apProduct,
						 ValidationData & arValidationData);

	// parse the stream only for validation
	BOOL Validate(const char * apStr, int aLen,
								ISessionProduct ** apProduct,
								ValidationData & arValidationData);

	// call to turn on validate only mode where sessions aren't created.
	// the syntax of the message is checked and the values are compared
	// against the service def
	void SetValidateOnly(BOOL aValidateOnly = TRUE)
	{ mValidateOnly = aValidateOnly; }


private:
  /*
   * callbacks called by the C code
   * the userData holds the PipelineMSIXParser pointer
   * use this to call the non-static member functions
   *
   * because they're callbacks, making them inline won't improve
   * efficiency at all.
   */
	// called when an opening tag is found
  static int StartElementHandler(void * apUserData,
																 const char * apName,
																 const char * * apAtts);

	// called when a closing tag is found
  static int EndElementHandler(void * apUserData,
															 const char * apName);

	// called when character data is found
  static int CharacterDataHandler(void * apUserData,
																	const char * apStr,
																	int aLen);

	// called when an opening tag is found
  // atts is array of name/value pairs, terminated by NULL;
	// names and values are '\0' terminated.
  int HandleStartElement(const char * apName, const char * * apAtts);

	// called when a closing tag is found
  int HandleEndElement(const char * apName);

	// called when character data is found
  int FASTCALL HandleCharacterData(const char * apStr, int aLen);

	// finish up any remaining character data handling
	int FASTCALL FinishCharacterData();

	// called once all character data has been collected together
  int FASTCALL HandleAllCharacterData(const char * apStr, int aLen);

	// called when an instruction is found
  int HandleProcessingInstruction(const char * apTarget, const char * apData);

	// called when an external entity (aka DTD) is found
	int HandleExternalEntityRefHandler( const char *context,
					    const char *base,
					    const char *systemId,
					    const char *publicId);



	// called when a CDATA section starts
	static void ProcessingStartCData(void* userData);
	// called when a CDATA section ends
	static void ProcessingEndCData(void* userData);


	BOOL FASTCALL TransitionState(const char * apTag, int aTagLen,
																PipelineMSIXAction aAction, BOOL & arActionRequired,
																BOOL & arIgnore);

	void SetParseErrorDetail();

  // @cmember Return error information.
	void GetErrorInfo(int & arCode, const char * & arpMessage,
										int & arLine, int & arColumn, long & arByte)
	{
		arCode = XML_GetErrorCode(mParser);
		arpMessage = XML_ErrorString(arCode);
		arLine = XML_GetErrorLineNumber(mParser);
		arColumn = XML_GetErrorColumnNumber(mParser);
		arByte = XML_GetErrorByteIndex(mParser);
	}

	void SetSessionError(DWORD errorCode, const char * module, int line,
											 const char * functionName, const char * errorMessage);
private:
	// called to prepare the session object
	BOOL SetupSession();
	// called when the session object is completely parsed
	BOOL SessionComplete();

	// adds any missing defaults to the current session
	void ApplyDefaults();

	// the value of the current property was found
	BOOL HandlePropertyValue(const char * apStr, int aLen);

	bool UpdateStringPropCount(
		PropertyCount & arPropCount, int characters);

	// clear all the intermediate state held about the session
	void ClearSessionState();

	void Clear();

	BOOL InitSharedSessions(const PipelineInfo & arInfo);

	SharedSession * CreateSession(const unsigned char * uid,
																long serviceId,
																const unsigned char * parentUid);

	// if the tag matches the suspected state, manually move into the correct
	// following state
	BOOL ManuallyTransitionState(const char * apTag,
															 PipelineMSIXParserState aSuspectedState);

	BOOL InitializeSessionBuilder();

	BOOL RecoverSessionBuilder();

private:
	PipelineMSIXParserState mState;

	XML_Parser mParser;
	BOOL mbCdataSection;

	// if true, print out debugging messages
#ifdef GENPARSER_VERBOSE
	BOOL mVerbose;
#endif // GENPARSER_VERBOSE

	// if TRUE, verify tags and whitespace
	BOOL mStrict;

	// if TRUE, don't actually create a session object,
	// just check it for syntax
	BOOL mValidateOnly;

private:
	enum { UID_LENGTH = 16 };

	unsigned char mSessionUID[UID_LENGTH];
	unsigned char mSessionParentUID[UID_LENGTH];
	BOOL mSessionParseHasFailed;

	const MSIXParserServiceDef<_SessionBuilder> * mpService;

	ServiceDefProp<_SessionBuilder> * mpProp;

	// true if the current session requires feedback
	BOOL mFeedback;

	// true if the current session is a retry
	BOOL mRetry;

	// the number of requried properties added for this session 
	long mTotalRequiredPropsAdded;

	// the number of non-requried, non-special properties with a non-null default
	// added for this session 
	long mTotalNonRequiredPropsAdded;

	// the number of non-requried, non-special string properties
	// with a non-null default added for this session 
	long mTotalNonRequiredStringPropsAdded;

	// pointer to data populated during validation.
	// If this is NULL, the data is discarded
	ValidationData * mpValidationData;

	// temporary buffer used for character data
	char mCharacterDataBuffer[4096];

	// out current offset within the buffer
	int mCharacterDataOffset;

	// record of the first call to HandleCharacterData.  If it's
	// only called once between XML tags we don't need to make any temporary
	// copies
	const char * mpLastCharacterData;
	int mLastCharacterDataLength;

	// the current service def that all top-level sessions are constrained to
	// or -1 if none have been seen yet
	int mConstrainedSvcID;

private:
	MTPipelineLib::IMTNameIDPtr mNameID;
  //NTLogger mLogger;

	SharedSessionMappedViewHandle * mpMappedView; // lock with mLock

	SharedSessionHeader * mpHeader;	// lock with mLock

	// used for encrypting property values
  CMTCryptoAPI mCrypto;	// initialized for use by pipeline

	CServicesCollection mServices;
	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;

	typedef std::map<ServiceDefName, MSIXParserServiceDef<_SessionBuilder> > ServiceDefMap;
	ServiceDefMap	mServiceDefMap;

	_SessionBuilder * mpSessionBuilder;

	const PipelineInfo * mPipelineInfo;


	NTLogger mLogger;
};


/********************************************* state machine ***/

struct ParserStateTransitions
{
	const char * mTag;
	PipelineMSIXAction mAction;
	PipelineMSIXParserState mNextState;
	BOOL mRequireProcessing;			// if TRUE, parser needs to do additional work
};

// NOTE: these must be in enum order
static ParserStateTransitions StateTransitions[NUMBER_OF_STATES] =
{
	{ /* OPEN */	"msix",					OPEN_TAG,				OPEN_TIMESTAMP,					0 },

	{ /* OPEN */	"timestamp",		OPEN_TAG,				VALUE_TIMESTAMP,				0 },
	{ /* VALUE */	"timestamp",		CHAR_DATA,			CLOSE_TIMESTAMP,				1 },
	{ /* CLOSE */	"timestamp",		CLOSE_TAG,			OPEN_VERSION,						0 },

	{ /* OPEN */	"version",			OPEN_TAG,				VALUE_VERSION,					0 },
	{ /* VALUE */ "version",			CHAR_DATA,			CLOSE_VERSION,					1 },
	{ /* CLOSE */	"version",			CLOSE_TAG,			OPEN_MESSAGE_UID,				0 },

	{ /* OPEN */	"uid",					OPEN_TAG,				VALUE_MESSAGE_UID,			0 },
	{ /* VALUE */	"uid",					CHAR_DATA,			CLOSE_MESSAGE_UID,			1 },
	{ /* CLOSE */	"uid",					CLOSE_TAG,			OPEN_ENTITY,						0 },

	{ /* OPEN */	"entity",				OPEN_TAG,				VALUE_ENTITY,						0 },
	{ /* VALUE */ "entity",				CHAR_DATA,			CLOSE_ENTITY,						1 },
	{ /* CLOSE */ "entity",				CLOSE_TAG,			OPEN_LISTENERTRANSACTIONID, 0 },

	{ /* OPEN */	"listenertransactionid", OPEN_TAG,	 VALUE_LISTENERTRANSACTIONID,		0 },
	{ /* VALUE */ "listenertransactionid", CHAR_DATA,  CLOSE_LISTENERTRANSACTIONID,  	1 },
	{ /* CLOSE */ "listenertransactionid", CLOSE_TAG,  OPEN_TRANSACTIONID,   		      0 },

	{ /* OPEN */	"transactionid",OPEN_TAG,				VALUE_TRANSACTIONID,		0 },
	{ /* VALUE */ "transactionid",CHAR_DATA,			CLOSE_TRANSACTIONID,  	1 },
	{ /* CLOSE */ "transactionid",CLOSE_TAG,			OPEN_CONTEXTUSERNAME,		0 },

	{ /* OPEN */  "sessioncontextusername",OPEN_TAG,			VALUE_CONTEXTUSERNAME,	0	},
	{ /* VALUE */ "sessioncontextusername",CHAR_DATA,		CLOSE_CONTEXTUSERNAME,	1 },
	{ /* CLOSE */ "sessioncontextusername",CLOSE_TAG,		OPEN_CONTEXTPASSWORD,		0 },

	{ /* OPEN */	"sessioncontextpassword",OPEN_TAG,			VALUE_CONTEXTPASSWORD,	0 },
	{ /* VALUE */ "sessioncontextpassword",CHAR_DATA,		CLOSE_CONTEXTPASSWORD,	1 },
	{ /* CLOSE */ "sessioncontextpassword",CLOSE_TAG,		OPEN_CONTEXTNAMESPACE,	0 },

	{ /* OPEN */	"sessioncontextnamespace",OPEN_TAG,		VALUE_CONTEXTNAMESPACE,	0 },
	{ /* VALUE */ "sessioncontextnamespace",CHAR_DATA,		CLOSE_CONTEXTNAMESPACE,	1 },
	{ /* CLOSE */ "sessioncontextnamespace",CLOSE_TAG,		OPEN_CONTEXT,						0 },

	{ /* OPEN */	"sessioncontext",			OPEN_TAG,				VALUE_CONTEXT,					0 },
	{ /* VALUE */ "sessioncontext",			CHAR_DATA,			CLOSE_CONTEXT,					1 },
	{ /* CLOSE */ "sessioncontext",			CLOSE_TAG,			OPEN_BEGINSESSION,			0 },

	{ /* OPEN */	"beginsession",	OPEN_TAG,				OPEN_SESSION_DN,				0 },

	{ /* OPEN */	"dn",						OPEN_TAG,				VALUE_SESSION_DN,				0 },
	{ /* VALUE */ "dn",						CHAR_DATA,			CLOSE_SESSION_DN,				1 },
	{ /* CLOSE */ "dn",						CLOSE_TAG,			OPEN_SESSION_UID,				0 },

	{ /* OPEN */	"uid",					OPEN_TAG,				VALUE_SESSION_UID,			0 },
	{ /* VALUE */	"uid",					CHAR_DATA,			CLOSE_SESSION_UID,			1 },
	{ /* CLOSE */	"uid",					CLOSE_TAG,			OPEN_SESSION_PARENTID,	0 },

	{ /* OPEN */	"parentid",			OPEN_TAG,				VALUE_SESSION_PARENTID, 0 },
	{ /* VALUE */	"parentid",			CHAR_DATA,			CLOSE_SESSION_PARENTID,	1 },
	{ /* CLOSE */	"parentid",			CLOSE_TAG,			OPEN_COMMIT,						0 },

	{ /* OPEN */	"commit",				OPEN_TAG,				VALUE_COMMIT,						0 },
	{ /* VALUE */ "commit",				CHAR_DATA,			CLOSE_COMMIT,						1 },
	{ /* CLOSE */ "commit",				CLOSE_TAG,			OPEN_INSERT,						0 },

	{ /* OPEN */	"insert",				OPEN_TAG,				VALUE_INSERT,						0 },
	{ /* VALUE */ "insert",				CHAR_DATA,			CLOSE_INSERT,						1 },
	{ /* CLOSE */ "insert",				CLOSE_TAG,			OPEN_FEEDBACK,					0 },

	{ /* OPEN */	"feedback",			OPEN_TAG,				VALUE_FEEDBACK,					0 },
	{ /* VALUE */ "feedback",			CHAR_DATA,			CLOSE_FEEDBACK,					1 },
	{ /* CLOSE */ "feedback",			CLOSE_TAG,			OPEN_PROPERTIES,				0 },

	{ /* OPEN */	"properties",		OPEN_TAG,				OPEN_PROPERTY,					0 },

	{ /* OPEN */	"property",			OPEN_TAG,				OPEN_PROPERTY_DN,				0 },

	{ /* OPEN */	"dn",						OPEN_TAG,				VALUE_PROPERTY_DN,			0 },
	{ /* VALUE */	"dn",						CHAR_DATA,			CLOSE_PROPERTY_DN,			1 },
	{ /* CLOSE */	"dn",						CLOSE_TAG,			OPEN_PROPERTY_VALUE,		0 },

	{ /* OPEN */	"value",				OPEN_TAG,				VALUE_PROPERTY_VALUE,		0 },
	{ /* VALUE */ "value",				CHAR_DATA,			CLOSE_PROPERTY_VALUE,		1 },
	{ /* CLOSE */	"value",				CLOSE_TAG,			CLOSE_PROPERTY,					1 },

	{ /* CLOSE */	"property",			CLOSE_TAG,			NEXT_PROPERTY,					0 },

	{							"property",			ANY_ACTION,			NEXT_PROPERTY,					1 },

	{ /* CLOSE */ "beginsession",	CLOSE_TAG,			NEXT_SESSION,						1 },

	{							"beginsession",	ANY_ACTION,			NEXT_SESSION,						1 },

/*{ / CLOSE /	  "msix",					CLOSE_TAG,			TERMINATE_PARSE,				0 }, */

	{							"msix",					ANY_ACTION,			TERMINATE_PARSE,				1 },
};

//
// used for debugging
//
static const char * StateNames[NUMBER_OF_STATES] =
{
	"OPEN_MSIX",

	"OPEN_TIMESTAMP",
	"VALUE_TIMESTAMP",
	"CLOSE_TIMESTAMP",

	"OPEN_VERSION",
	"VALUE_VERSION",
	"CLOSE_VERSION",

	"OPEN_MESSAGE_UID",
	"VALUE_MESSAGE_UID",
	"CLOSE_MESSAGE_UID",

	"OPEN_ENTITY",
	"VALUE_ENTITY",
	"CLOSE_ENTITY",

	"OPEN_LISTENERTRANSACTIONID",
	"VALUE_LISTENERTRANSACTIONID",
	"CLOSE_LISTENERTRANSACTIONID",

	"OPEN_TRANSACTIONID",
	"VALUE_TRANSACTIONID",
	"CLOSE_TRANSACTIONID",

	"OPEN_CONTEXTUSERNAME",
	"VALUE_CONTEXTUSERNAME",
	"CLOSE_CONTEXTUSERNAME",

	"OPEN_CONTEXTPASSWORD",
	"VALUE_CONTEXTPASSWORD",
	"CLOSE_CONTEXTPASSWORD",

	"OPEN_CONTEXTNAMESPACE",
	"VALUE_CONTEXTNAMESPACE",
	"CLOSE_CONTEXTNAMESPACE",

	"OPEN_CONTEXT",
	"VALUE_CONTEXT",
	"CLOSE_CONTEXT",

	"OPEN_BEGINSESSION",

	"OPEN_SESSION_DN",
	"VALUE_SESSION_DN",
	"CLOSE_SESSION_DN",

	"OPEN_SESSION_UID",
	"VALUE_SESSION_UID",
	"CLOSE_SESSION_UID",

	"OPEN_SESSION_PARENTID",
	"VALUE_SESSION_PARENTID",
	"CLOSE_SESSION_PARENTID",

	"OPEN_COMMIT",
	"VALUE_COMMIT",
	"CLOSE_COMMIT",

	"OPEN_INSERT",
	"VALUE_INSERT",
	"CLOSE_INSERT",

	"OPEN_FEEDBACK",
	"VALUE_FEEDBACK",
	"CLOSE_FEEDBACK",

	"OPEN_PROPERTIES",

	"OPEN_PROPERTY",

	"OPEN_PROPERTY_DN",
	"VALUE_PROPERTY_DN",
	"CLOSE_PROPERTY_DN",

	"OPEN_PROPERTY_VALUE",
	"VALUE_PROPERTY_VALUE",
	"CLOSE_PROPERTY_VALUE",

	"CLOSE_PROPERTY",

	"NEXT_PROPERTY",

	"CLOSE_BEGINSESSION",

	"NEXT_SESSION",

	"TERMINATE_PARSE",
};

static const char * ActionNames[NUMBER_OF_ACTIONS] =
{
	"OPEN_TAG",
	"CLOSE_TAG",
	"CHAR_DATA",
	"ANY_ACTION",
};


int UTF8StringLength(const char * apUTF8, int aLen);



// includes the templatized implemenation of PipelineMSIXParser
// NOTE: the implementation must be included so that clients outside of 
// this shared library can instantiate the template
#include <genparser_template.h>

#endif /* _GENPARSER_H */
