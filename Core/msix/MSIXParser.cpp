/**************************************************************************
 * @doc MSIXPARSER
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
 ***************************************************************************/

#include <metra.h>
#include <MSIX.h>
#include <ctype.h>
#include "MSIXHash.h"

/************************************************ MSIXParser ***/


MSIXParser::MSIXParser(int aBufferSize) : mBufferSize(aBufferSize)
{
	// tell the parser how to construct MSIX objects
	SetObjectFactory(&mFactory);

	// maintain the character buffer ourself
	if (aBufferSize > 0)
	{
		mpParseBuffer = new char[aBufferSize];
		ASSERT(mpParseBuffer);
	}
	else
		mpParseBuffer = NULL;
}

MSIXParser::~MSIXParser()
{
	if (mBufferSize > 0)
	{
		ASSERT(mpParseBuffer);	
		delete [] mpParseBuffer;
	}
}

/************************************************ MSIXObject ***/

// use long tags by default
BOOL MSIXObject::mShortTags = FALSE;


/*************************************************** MSIXUid ***/

// grab an ID for the object
const int MSIXUid::msTypeId = XMLObjectFactory::GetUserObjectId();

const char * MSIXUid::msLongName = "uid";
const char * MSIXUid::msShortName = "uid";


BOOL MSIXUid::Parse(
	const char * apName,
	XMLObjectVector & arContents)
{
	// <uid>UID</uid>

	XMLString uid;
	if (!XMLAggregate::GetDataContents(uid, arContents))
		return FALSE;

	return Init(uid);
}


void MSIXUid::Output(XMLWriter & arWriter) const
{
	//  <uid>UID</uid>
	const char * tag = ChooseTag(msLongName, msShortName);
	arWriter.OutputSimpleAggregate(tag, mUid.c_str());
}


/***************************************** MSIXObjectFactory ***/

#if 0
void DumpContents(const XMLObjectVector & arObjects)
{
	cout << "Content dump: " << endl;

	for (int i = 0; i < (int) arObjects.GetEntries(); i++)
	{
		XMLObject * obj = arObjects[i];
		cout << " '" << *obj << '\'' << endl;
	}
	cout << "End content dump" << endl;
}
#endif

// @mfunc constructor
MSIXObjectFactory::MSIXObjectFactory()
{ }


XMLObject * MSIXObjectFactory::CreateAggregate(
	const char * apName,
	XMLNameValueMap& apAttributes,
	XMLObjectVector & arContents)
{
#if 0
	cout << "Aggregate: " << apName << endl;
	DumpContents(arContents);
#endif

	MSIXObject * obj = CreateMSIXObject(apName);
	if (obj)
	{
		// XMLParser deletes everything left in the arContents list when this
		// method returns.  Therefore, anything we need to hang onto from it
		// must be removed from the list.
		if (!obj->Parse(apName, arContents))
		{
			delete obj;
			return NULL;							// parse error!
		}
		return obj;
	}
	else
	{
		// we don't care about this tag - allow the default behaviour
		return XMLObjectFactory::CreateAggregate(apName, apAttributes, arContents);
	}
}

#ifdef WIN32
#define msix_isspace(_c) ( _pctype[_c] & _SPACE )
#else
#define msix_isspace(_c) isspace(_c)
#endif

XMLObject * MSIXObjectFactory::CreateData(const char * apData, int aLen,BOOL bCdataSection)
{
	// NOTE: this function is called a lot so it should be as fast as possible

	// ignore whitespace - return NULL if the string is made up
	// of whitespace only

	//BOOL allspace1 = (strspn(apData, " \t\r\n") == strlen(apData));

#if 0
	// most strings are all spaces (75% or more), so optimize for that case
	// first, then do special checking for tabs and newlines
	char allspaces[] = "                                                            ";

	if (aLen <= sizeof(allspaces))
	{
		if (0 == strncmp(apData, allspaces, aLen))
			return NULL;
	}
#endif

	BOOL allspace = TRUE;
	const char * ptr = apData;
	const char * endptr = apData + aLen;
	while (ptr != endptr)
	{
		if (!msix_isspace(*ptr++))
		{
			allspace = FALSE;
			break;
		}
	}

	if (allspace)
		return NULL;

	// FALSE argument indicates no CDATA section.
	return XMLObjectFactory::CreateData(apData, aLen,bCdataSection);
}


// NOTE: very important! The last argument is there so M appears in the
// function signature.  Otherwise only one instantiation of this function
// will appear no matter how many ways you call it.
template<class M> MSIXObject * CreateType(const char * apName, M *dummy)
{
	if (0 == strcmp(apName, M::msLongName)
			|| 0 == strcmp(apName, M::msShortName))
		return new M;
	else
		return NULL;
}


MSIXObject * MSIXObjectFactory::CreateMSIXObject(const char * apName)
{
	const MSIXHashEntry * hashEntry = FindMSIXTag(apName, strlen(apName));
	if (!hashEntry)
		return NULL;

	switch (hashEntry->tag)
	{
	case MSIX_Uid:
		return new MSIXUid;
	case MSIX_BeginSessionRS:
		return new MSIXBeginSessionRS;
	case MSIX_Session:
		return new MSIXSession;
	case MSIX_CommitSession:
		return new MSIXCommitSession;
	case MSIX_CommitSessionRS:
		return new MSIXCommitSessionRS;
	case MSIX_Msix:
		return new MSIXMessage;
	case MSIX_Status:
		return new MSIXStatus;
	case MSIX_SessionStatus:
		return new MSIXSessionStatus;
	default:
		return NULL;
	}

#if 0
	MSIXObject * obj;

  MSIXUid *msixuid = NULL;
	if ((obj = CreateType(apName, msixuid)))
		return obj;

  MSIXBeginSessionRS *msixbeginsessionrs = NULL;
  if ((obj = CreateType(apName, msixbeginsessionrs)))
		return obj;

  MSIXSession *msixsession = NULL;
  if ((obj = CreateType(apName, msixsession)))
		return obj;

  MSIXCommitSession *msixcommitsession = NULL;
  if ((obj = CreateType(apName, msixcommitsession)))
		return obj;

  MSIXCommitSessionRS *msixcommitsessionrs = NULL;
  if ((obj = CreateType(apName, msixcommitsessionrs)))
		return obj;

  MSIXMessage *msixmessage = NULL;
  if ((obj = CreateType(apName, msixmessage)))
		return obj;

  MSIXStatus *msixstatus = NULL;
  if ((obj = CreateType(apName, msixstatus)))
		return obj;

  MSIXSessionStatus *sessstatus = NULL;
  if ((obj = CreateType(apName, sessstatus)))
		return obj;

#endif
	return NULL;
}


/************************************************ MSIXStatus ***/

// grab an ID for the object
const int MSIXStatus::msTypeId = XMLObjectFactory::GetUserObjectId();

// <status>
const char * MSIXStatus::msLongName = "status";
const char * MSIXStatus::msShortName = "stat";

// <code>
const char * MSIXStatus::msCodeLong = "code";
const char * MSIXStatus::msCodeShort = "code";

// <message>
const char * MSIXStatus::msMessageLong = "message";
const char * MSIXStatus::msMessageShort = "ms";

// TODO: severity


BOOL MSIXStatus::Parse(
	const char * apName,
	XMLObjectVector & arContents)
{
	// TODO: verify that all required fields were discovered

	//<status>	
	//  <code> Matches <code> in <stype> aggregate.
	//  [<severity>] Severity level: INFO, WARNING, ERROR.
	//  [<message>] Human-readable status message.
	//</status>	

	for (int i = 0; i < (int) arContents.GetEntries(); i++)
	{
		XMLObject * obj = arContents[i];

		// should only contain aggregate
		if (obj->GetType() != AGGREGATE)
			return FALSE;

		XMLAggregate * agg = (XMLAggregate *) obj;
		const char * name = agg->GetName();
		if (0 == strcmp(name, msCodeShort) || 0 == strcmp(name, msCodeLong))
		{
			// <code> name </code>
			// read the code
			XMLString code;
			if (!agg->GetDataContents(code))
				return FALSE;
			string ascCode;
			BOOL res = XMLStringToAscii(ascCode, code);
			// TODO: how should we fail here?
			ASSERT(res);

			// convert from hex
			char * endp;
			mCode = strtoul(ascCode.c_str(), &endp, 16);
			if (endp != (ascCode.c_str()) + ascCode.length())
				return FALSE;
		}
		else if (0 == strcmp(name, msMessageShort) || 0 == strcmp(name, msMessageLong))
		{
			// <message>the message</message>
			if (!agg->GetDataContents(mMessage))
				return FALSE;
		}
		else
			// TODO: severity
			return FALSE;						// unknown aggregate name
	}
	return TRUE;
}

void MSIXStatus::Output(XMLWriter & arWriter) const
{
	//<status>
	//  <code> Matches <code> in <stype> aggregate.
	//  [<severity>] Severity level: INFO, WARNING, ERROR.
	//  [<message>] Human-readable status message.
	//</status>	

	// <beginsession>
	const char * topTag = ChooseTag(msLongName, msShortName);
	arWriter.OutputOpeningTag(topTag);

	// <code> 100 </code>
	const char * tag = ChooseTag(msCodeLong, msCodeShort);
	// output in hex for readability
	char buffer[20];
#ifdef UNIX
  // mCode appears to be 32-bits?  Is it planned to go to 64?
	// TODO: this isn't ANSI
  sprintf(buffer, "%llx", (unsigned long long)mCode);
#else  
	_ui64toa(mCode, buffer, 16);
#endif
	arWriter.OutputSimpleAggregate(tag, buffer);

	// <message>the message</message>
	tag = ChooseTag(msMessageLong, msMessageShort);
	arWriter.OutputSimpleAggregate(tag, mMessage);

	// </status>
	arWriter.OutputClosingTag(topTag);
}


/***************************************** MSIXSessionStatus ***/

// grab an ID for the object
const int MSIXSessionStatus::msTypeId = XMLObjectFactory::GetUserObjectId();

// <status>
const char * MSIXSessionStatus::msLongName = "sessionstatus";
const char * MSIXSessionStatus::msShortName = "sessstat";

// <code>
const char * MSIXSessionStatus::msCodeLong = "code";
const char * MSIXSessionStatus::msCodeShort = "code";

// <message>
const char * MSIXSessionStatus::msMessageLong = "message";
const char * MSIXSessionStatus::msMessageShort = "ms";

BOOL MSIXSessionStatus::Parse(
	const char * apName,
	XMLObjectVector & arContents)
{

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

	mUid.Clear();

	int i = 0;
	while (i < (int) arContents.GetEntries())
	{
		XMLObject * obj = arContents[i];

		MSIXUid * uid = NULL;
		uid = ConvertUserObject(obj, uid);
		if (uid)
		{
			// copy to our local version
			mUid = *uid;
			i++;
			continue;
		}

		MSIXSession * session = NULL;
		session = ConvertUserObject(obj, session);
		if (session)
		{
			mpSession = session;
			// remove the session so it doesn't get deleted
			arContents.Remove(i);
			continue;									// don't increment i here
		}

		// should only contain aggregate
		if (obj->GetType() != AGGREGATE)
			return FALSE;

		XMLAggregate * agg = (XMLAggregate *) obj;
		const char * name = agg->GetName();
		if (0 == strcmp(name, msCodeShort) || 0 == strcmp(name, msCodeLong))
		{
			// <code>123</code>
			// read the code
			XMLString code;
			if (!agg->GetDataContents(code))
				return FALSE;
			string ascCode;
			BOOL res = XMLStringToAscii(ascCode, code);
			// TODO: how should we fail here?
			ASSERT(res);

			// convert from hex
			char * endp;
			mCode = strtoul(ascCode.c_str(), &endp, 16);
			if (endp != ascCode.c_str() + ascCode.length())
				return FALSE;
		}
		else if (0 == strcmp(name, msMessageShort) || 0 == strcmp(name, msMessageLong))
		{
			if (!agg->GetDataContents(mMessage))
				return FALSE;
		}
		else
			return FALSE;						// unknown aggregate name

		i++;
	}
	return TRUE;
}

void MSIXSessionStatus::Output(XMLWriter & arWriter) const
{
	// NOTE: metratech extension to MSIX
	//
	//<sessionstatus> Aggregate
	//
	//<sessionstatus>
	//  <code> Matches <code> in <stype> aggregate.
	//  [<message>] Human-readable status message.
	//  [<error>..</error>] extended error information if an error occurred
	//  [<beginsession>..</beginsession>] session properties after processing, if requested
	//</status>	

	// <sessionstatus>
	const char * topTag = ChooseTag(msLongName, msShortName);
	arWriter.OutputOpeningTag(topTag);

	// <code>100</code>
	const char * tag = ChooseTag(msCodeLong, msCodeShort);
	// output in hex for readability
	// TODO: this isn't ANSI
	char buffer[20];
#ifdef UNIX
  // mCode appears to be 32-bits?  Is it planned to go to 64?
  sprintf(buffer, "%llx", (unsigned long long)mCode);
#else  
	_ui64toa(mCode, buffer, 16);
#endif
	arWriter.OutputSimpleAggregate(tag, buffer);

	//  [<message>] (optional) human-readable status message.
	if (mMessage.length() > 0)
	{
		tag = ChooseTag(msMessageLong, msMessageShort);
		arWriter.OutputSimpleAggregate(tag, mMessage);
	}

	//  [<uid>] metered session this status refers to (optional)
	if (mUid.GetUid().length() > 0)
		mUid.Output(arWriter);

	//  [<beginsession>..</beginsession>] session properties after processing, if requested
	if (mpSession)
		mpSession->Output(arWriter);

	// </sessionstatus>
	arWriter.OutputClosingTag(topTag);
}


/****************************************** MSIXUidAggregate ***/


BOOL MSIXUidAggregateBase::Parse(
	const char * apName,
	XMLObjectVector & arContents)
{
	ASSERT(0 == strcmp(apName, GetTagName()) || 0 == strcmp(apName, GetShortTagName()));

	//<$(TAGNAME)>
	//  <uid>UID</uid>
	//</$(TAGNAME)>

	// there should only be an aggregate named <uid> inside
	if (arContents.GetEntries() == 0)
		return FALSE;
	XMLObject * obj = arContents[0];

	MSIXUid * uid = NULL;
	uid = ConvertUserObject(obj, uid);
	if (!uid)
		return FALSE;

	mUid = *uid;

	// TODO: verify there's nothing else inside
	return TRUE;
//(++it == arContents.end());
}


void MSIXUidAggregateBase::Output(XMLWriter & arWriter) const
{
	//<$(TAGNAME)>
	//  <uid>UID</uid>
	//</$(TAGNAME)>

	//<$(TAGNAME)>
	const char * tag = ChooseTag(GetTagName(), GetShortTagName());
	arWriter.OutputOpeningTag(tag);

	//  <uid>UID</uid>
	mUid.Output(arWriter);

	//</$(TAGNAME)>
	arWriter.OutputClosingTag(tag);
}


/*********************************************** MSIXSession ***/

// grab an ID for the object
const int MSIXSession::msTypeId = XMLObjectFactory::GetUserObjectId();

const char * MSIXSession::msLongName = "beginsession";
const char * MSIXSession::msShortName = "bs";

// <dn>
const char * MSIXSession::msDnLong = "dn";
const char * MSIXSession::msDnShort = "dn";

// <commit>
const char * MSIXSession::msCommitLong = "commit";
const char * MSIXSession::msCommitShort = "c";

// NOTE: not a standard MSIX tag
// <insert>
const char * MSIXSession::msInsertLong = "insert";
const char * MSIXSession::msInsertShort = "i";

// NOTE: not a standard MSIX tag
// <feedback>
const char * MSIXSession::msFeedbackLong = "feedback";
const char * MSIXSession::msFeedbackShort = "f";

// <parentid>
const char * MSIXSession::msParentIdLong = "parentid";
const char * MSIXSession::msParentIdShort = "pid";

// <properties>
const char * MSIXSession::msPropsLong = "properties";
const char * MSIXSession::msPropsShort = "ps";

// <property>
const char * MSIXSession::msPropLong = "property";
const char * MSIXSession::msPropShort = "p";

// <value>
const char * MSIXSession::msValueLong = "value";
const char * MSIXSession::msValueShort = "v";


BOOL YNToBool(const XMLString & arStr, BOOL & arBool)
{
	if (0 == arStr.compare(L"Y"))
	{
		arBool = TRUE;
		return TRUE;
	}
	
	if (0 == arStr.compare(L"N"))
	{
		arBool = FALSE;
		return TRUE;
	}
	return FALSE;
}

// @mfunc read properties into a name->value map
// @parm properties aggregate
// @parm map to read into
// @rdesc TRUE if properties aggregate is well formed
BOOL MSIXSession::ReadProperties(XMLAggregate * apAgg,
                                 MSIXSession::PropMap & arMap)
{
	//
	// NOTE: this method must be kept fast.  It's a bottleneck for
	// parsing sessions.
	//

	string asciiDnBuffer;
	wstring propvalBuffer;
	const wchar_t * propValue;
	const wchar_t * name;

	// iterate through each <property> aggregate
	int size;
	XMLObject *const * contents = apAgg->GetContents(size);
	for (int i = 0; i < size; i++)
	{
		XMLObject * obj = contents[i];
		XMLAggregate * prop = XMLAggregate::Named(obj, msPropLong, msPropShort);
		if (!prop)
			return FALSE;

		BOOL dnFound = FALSE;
		BOOL valFound = FALSE;

		// the key is the name - it will be placed in the map
		// TODO: this extra copy will affect performance
		PropMapKey theKey;
		PropMapKey * key = &theKey;

		// iterate through contents of <property> aggregate
		int innerSize;
		XMLObject *const * inner = prop->GetContents(innerSize);

		for (int j = 0; j < innerSize; j++)
		{
			XMLObject * innerObj = inner[j];

			// look for <dn>
			XMLAggregate * dn = XMLAggregate::Named(innerObj, msDnLong, msDnShort);
			if (dn)
			{
				if (dnFound)
					return FALSE;					// duplicate dn found

				dnFound = TRUE;					// don't allow it to appear again

				// read the distinguished name

				int dnInnerSize;
				XMLObject *const * dnInner = dn->GetContents(dnInnerSize);

				if (dnInnerSize != 1) { return FALSE; }

				XMLData * data = XMLData::Data(dnInner[0]);
				ASSERT(data);

				name = data->GetData();


#ifdef WIN32
				// ascii conversion can be expensive here, so we optimize it for the
				// common case

				int namelen = wcslen(name);
				if (namelen < key->BufferSize() - 1)
				{
					char * buffer = key->DirectSetup();

					BOOL defaultUsed;
					int bytes = ::WideCharToMultiByte(
						CP_ACP,							// code page (ANSI)
						0,									// performance and mapping flags
						name,								// wide-character string
						namelen,						// number of chars in string
						buffer,							// buffer for new string
						key->BufferSize() - 1, // size of buffer
						"?",								// default for unmappable chars
						&defaultUsed);			// set when default char used

					// TODO: fix me
					ASSERT(bytes > 0);
					buffer[bytes] = '\0';
					//asciiDn = buffer;
				}
				else
				{
#endif // WIN32

					BOOL res = XMLStringToAscii(asciiDnBuffer, name);
					key->SetBuffer(asciiDnBuffer.c_str());

					// TODO: how should we fail here?
					ASSERT(res);

#ifdef WIN32
				}
#endif // WIN32
			}
			else											// look for <value>
			{
				XMLAggregate * val = XMLAggregate::Named(innerObj, msValueLong, msValueShort);
				if (!val || valFound)
					return FALSE;					// aggregate wasn't dn or value

				valFound = TRUE;				// don't allow it to appear again

				// read the property value
				int valInnerSize;
				XMLObject *const * valInner = val->GetContents(valInnerSize);

				if (valInnerSize == 0)
					propValue = L"";
				else
				{
					// TODO: this might not always work
					if (valInnerSize != 1)
					{
						if (!val->GetDataContents(propvalBuffer))
							return FALSE;					// unknown contents inside
						propValue = propvalBuffer.c_str();
					}
					else
					{
						XMLData * data = XMLData::Data(valInner[0]);
						ASSERT(data);
						propValue = data->GetData();
					}
				}

				//if (!val->GetDataContents(propValue))
				//	return FALSE;					// unknown contents inside
			}
		}

		if (!dnFound || !valFound)
			return FALSE;							// dn or val wasn't found

		// add to the prop/value map
		MSIXPropertyValue * val;

		// TODO: use this optimizations (in #if 0) or back out
#if 0
		MSIXSession::PropMap::iterator it = arMap.find(*key);

		std::pair<MSIXSession::PropMap::iterator, bool> thePair;
		thePair = arMap.insert(*key);
		if (thePair->second)
		{
			// newly inserted key
			val = new MSIXPropertyValue;
			thePair->first->second = val;
		}
		else
		{
			// key already existed
			val = thePair->first->second;
		}
#endif

#if 0
		// TODO: if the key already existed then we'll leak memory!
			// value doesn't exist - create a new value
			val = new MSIXPropertyValue;
			arMap[theKey] = val;
#endif

#if 1
		MSIXSession::PropMap::iterator it = arMap.find(*key);
		if (it == arMap.end())
		{
			// value doesn't exist - create a new value
			val = new MSIXPropertyValue;
			arMap[theKey] = val;
		}
		else
			val = it->second;
#endif

		// set the value

		// NOTE: the type will always become UNKNOWN_AS_UNISTRING when setting the property
		// this way.
		val->SetUnknownValue(propValue);
	}
	return TRUE;
}

BOOL MSIXSession::Parse(
	const char * apName,
	XMLObjectVector & arContents)
{
	// TODO: verify that all required fields were discovered
	/*
		<beginsession>	
		 <dn>	Distinguished Name of service
		 <commit>	Y or N.  If Y, commit submission immediately
		 <accountid>	String that uniquely identifies account to debit.
		    MSIX treats account identifiers as opaque strings.
		 [<parentid>]	UID of parent session, if defining compound service
		 [<properties>…</properties>]	Contains one or more property aggregates
		</beginsession>	
	*/

	// this is declared out of the loop so that we don't keep allocating and
	// deallocating the buffer.
	XMLString dataContents;

	for (int i = 0; i < (int) arContents.GetEntries(); i++)
	{
		XMLObject * obj = arContents[i];

		MSIXUid * uid = NULL;
		uid = ConvertUserObject(obj, uid);
		if (uid)
		{
			// copy to our local version
			mUid = *uid;
		}
		else
		{
			// should only contain aggregates now
			if (obj->GetType() != AGGREGATE)
				return FALSE;

			XMLAggregate * agg = (XMLAggregate *) obj;
			const char * name = agg->GetName();

			const MSIXHashEntry * hashEntry = FindMSIXTag(name, strlen(name));
			if (!hashEntry)
				return FALSE;						// unknown aggregate name

			// temp used in some cases..
			BOOL res;

			switch (hashEntry->tag)
			{
			case MSIX_Dn:
				// <dn> name </dn>
				// read the distinguished name
				if (!agg->GetDataContents(dataContents))
					return FALSE;
				res = XMLStringToAscii(mDn, dataContents);
				// TODO: how should we fail here?
				ASSERT(res);
				break;

			case MSIX_Session_Commit:
				// <commit>Y</commit>
				// turn the flag to TRUE/FALSE
				if (!agg->GetDataContents(dataContents))
					return FALSE;
				if (!YNToBool(dataContents, mCommit))
					return FALSE;
				break;

			case MSIX_Session_Insert:
				// NOTE: this is not a standard MSIX tag

				// <insert>Y</insert>
				// <insert>N</insert>
				// <insert>U</insert>
				if (!agg->GetDataContents(dataContents))
					return FALSE;
				if (0 == dataContents.compare(L"Y"))
					mInsertHint = Insert;
				else if (0 == dataContents.compare(L"N"))
					mInsertHint = Update;
				else if (0 == dataContents.compare(L"U"))
					mInsertHint = Unknown;
				else return FALSE;
				break;

			case MSIX_Session_Feedback:
				// NOTE: this is not a standard MSIX tag

				// <feedback>Y</feedback>
				if (!agg->GetDataContents(dataContents))
					return FALSE;
				if (!YNToBool(dataContents, mFeedback))
					return FALSE;
				break;

			case MSIX_Session_ParentId:
				// <parentid> uid </parentid>
				// read the parent UID
				if (!agg->GetDataContents(dataContents))
					return FALSE;
				res = mParentUid.Init(dataContents);
				// TODO: how should we fail here?
				ASSERT(res);
				break;

			case MSIX_Session_Props:
				//			else if (0 == strcmp(name, msPropsShort) || 0 == strcmp(name, msPropsLong))
				// <properties> ... </properties>
				if (!ReadProperties(agg, mProperties))
					return FALSE;
				break;

			default:
				return FALSE;						// unknown aggregate name
			}
		}
	}
	return TRUE;
}

void MSIXSession::Output(XMLWriter & arWriter) const
{
	/*
		<beginsession>
		 <dn>	Distinguished Name of service
		 <commit>	Y or N.  If Y, commit submission immediately
		 <accountid>	String that uniquely identifies account to debit.
		    MSIX treats account identifiers as opaque strings.
		 [<parentid>]	UID of parent session, if defining compound service
		 [<properties>…</properties>]	Contains one or more property aggregates
		</beginsession>
	*/

	// <beginsession>
	const char * topTag = ChooseTag(msLongName, msShortName);
	arWriter.OutputOpeningTag(topTag);

	//  <dn>	Distinguished Name of service </dn>
	const char * tag = ChooseTag(msDnLong, msDnShort);
	arWriter.OutputSimpleAggregate(tag, mDn.c_str());

	//  <uid>uid</uid>
	mUid.Output(arWriter);

	// <parentid> uid </parentid>
	// only write it if the parent ID has a value
	if (mParentUid.GetUid().length() > 0)
	{
		tag = ChooseTag(msParentIdLong, msParentIdShort);
		arWriter.OutputSimpleAggregate(tag, mParentUid.GetUid().c_str());
	}

	// convert BOOL to Y or N appropriately
	// <commit> Y or N. </commit>
	const char * yn = mCommit ? "Y" : "N";
	tag = ChooseTag(msCommitLong, msCommitShort);
	arWriter.OutputSimpleAggregate(tag, yn);

	// convert InsertHint to Y,N,U appropriately
	// <insert> Y or N or U. </insert>
	const char * ins;
	switch (mInsertHint)
	{
	case Insert:
		ins = "Y"; break;
	case Update:
		ins = "N"; break;
	case Unknown:
		ins = "U"; break;
	default:
		ASSERT(0);
	}
	tag = ChooseTag(msInsertLong, msInsertShort);
	arWriter.OutputSimpleAggregate(tag, ins);

	// request for feedback (only if requested)
	// <feedback>Y</feedback>
	if (GetFeedbackRequested())
	{
		// only send the tag if feedback is requested
		tag = ChooseTag(msFeedbackLong, msFeedbackShort);
		arWriter.OutputSimpleAggregate(tag, "Y");
	}

	// <properties>
	const char * propAggTag = ChooseTag(msPropsLong, msPropsShort);
	arWriter.OutputOpeningTag(propAggTag);

	char * workarea = new char[4096];
	int workareaSize = 4096;

	PropMap::const_iterator it;
	for (it = mProperties.begin(); it != mProperties.end(); it++)
	{
		const PropMapKey & name = it->first;
		MSIXPropertyValue * val = it->second;

		// <property>
		const char * ptag = ChooseTag(msPropLong, msPropShort);
		arWriter.OutputOpeningTag(ptag);

		// <dn>name</dn>
		tag = ChooseTag(msDnLong, msDnShort);
		// TODO: fix me!!!!!!!
		string nameCopy = name.GetBuffer();
		arWriter.OutputSimpleAggregate(tag, nameCopy.c_str());

		// <value>value</value>
		tag = ChooseTag(msValueLong, msValueShort);

		arWriter.OutputOpeningTag(tag);
		val->Output(workarea, workareaSize, arWriter);
		arWriter.OutputClosingTag(tag);

		// </property>
		arWriter.OutputClosingTag(ptag);
	}

	delete [] workarea;
	workarea = NULL;

	// </properties>
	arWriter.OutputClosingTag(propAggTag);

	// </beginsession>
	arWriter.OutputClosingTag(topTag);
}

/**************************************** MSIXBeginSessionRS ***/

const int MSIXBeginSessionRS::msTypeId = XMLObjectFactory::GetUserObjectId();

const char * MSIXBeginSessionRS::msLongName = "beginsessionrs";
const char * MSIXBeginSessionRS::msShortName = "bsrs";

/***************************************** MSIXCommitSession ***/

const int MSIXCommitSession::msTypeId = XMLObjectFactory::GetUserObjectId();

const char * MSIXCommitSession::msLongName = "commitsession";
const char * MSIXCommitSession::msShortName = "cs";

// <dn>
const char * MSIXCommitSession::msDnLong = "dn";
const char * MSIXCommitSession::msDnShort = "dn";


BOOL MSIXCommitSession::Parse(
	const char * apName,
	XMLObjectVector & arContents)
{
	//<commitsession>
	//  <dn> service name </dn>
	//  <uid> UID of top-level (non-child) <session> document.
	//</commitsession>

	for (int i = 0; i < (int) arContents.GetEntries(); i++)
	{
		XMLObject * obj = arContents[i];

		MSIXUid * uid = NULL;
		uid = ConvertUserObject(obj, uid);
		if (uid)
			mUid = *uid;
		else
		{
			// should only contain aggregates now
			if (obj->GetType() != AGGREGATE)
				return FALSE;

			XMLAggregate * agg = (XMLAggregate *) obj;
			const char * name = agg->GetName();

			if (0 == strcmp(name, msDnShort) || 0 == strcmp(name, msDnLong))
			{
				// <dn> name </dn>
				// read the distinguished name
				XMLString dn;
				if (!agg->GetDataContents(dn))
					return FALSE;
				BOOL res = XMLStringToAscii(mDn, dn);
				// TODO: how should we fail here?
				ASSERT(res);
			}
			else
				return FALSE;
		}
	}
	return TRUE;
}


void MSIXCommitSession::Output(XMLWriter & arWriter) const
{
	//<commitsession>	
	//  <dn> service name </dn>
	//  <uid>	UID of top-level (non-child) <session> document.
	//</commitsession>	

	//<commitsession>
	const char * topTag = ChooseTag(msLongName, msShortName);
	arWriter.OutputOpeningTag(topTag);

	//  <dn> service name </dn>
	const char * tag = ChooseTag(msDnLong, msDnShort);
	arWriter.OutputSimpleAggregate(tag, mDn.c_str());

	//  <uid>UID</uid>
	mUid.Output(arWriter);

	//</commitsession>
	arWriter.OutputClosingTag(topTag);
}




/*************************************** MSIXCommitSessionRS ***/

const int MSIXCommitSessionRS::msTypeId = XMLObjectFactory::GetUserObjectId();

const char * MSIXCommitSessionRS::msLongName = "commitsessionrs";
const char * MSIXCommitSessionRS::msShortName = "csrs";

/*********************************************** MSIXMessage ***/

const int MSIXMessage::msTypeId = XMLObjectFactory::GetUserObjectId();

const char * MSIXMessage::msLongName = "msix";
const char * MSIXMessage::msShortName = "msix";

const char * MSIXMessage::msTimestampLong = "timestamp";
const char * MSIXMessage::msTimestampShort = "time";

const char * MSIXMessage::msVersionLong = "version";
const char * MSIXMessage::msVersionShort = "v";

const char * MSIXMessage::msEntityLong = "entity";
const char * MSIXMessage::msEntityShort = "en";

const char * MSIXMessage::msTransactionIDLong = "transactionid";
const char * MSIXMessage::msTransactionIDShort = "txn";

const char * MSIXMessage::msListenerTransactionIDLong = "listenertransactionid";
const char * MSIXMessage::msListenerTransactionIDShort = "ltxn";

const char * MSIXMessage::msSessionContextUserNameLong = "sessioncontextusername";
const char * MSIXMessage::msSessionContextUserNameShort = "SCUN";

const char * MSIXMessage::msSessionContextPasswordLong = "sessioncontextpassword";
const char * MSIXMessage::msSessionContextPasswordShort = "SCPW";

const char * MSIXMessage::msSessionContextNamespaceLong = "sessioncontextnamespace";
const char * MSIXMessage::msSessionContextNamespaceShort = "SCNS";

const char * MSIXMessage::msSessionContextLong = "sessioncontext";
const char * MSIXMessage::msSessionContextShort = "SC";

BOOL MSIXMessage::Parse(
	const char * apName,
	XMLObjectVector & arContents)
{
	/*
		<msix>	
		 [<signature>]	Optional digital signature.  Computed without this tag and value.
		 <timestamp>	Time the message header is created.</timestamp>
		 <version>	Protocol version.  Literal: "1.0"
		 <uid>	Client-assigned flow ID.
		 <entity>	Host name of entity creating this MSIX message
	 	 <body> </body>
		   One or more message body aggregates.
		   The <body> </body> tags are not literal: They are to be replaced
			 with valid message aggregate tags, defined in this document's
			 Protocol Message Sets section.
		</msix>
	*/

	// NOTE: be careful iterating here.
	int i = 0;
	while (i < (int) arContents.GetEntries())
	{
		XMLObject * obj = arContents[i];

		MSIXUid * uid = NULL;
		uid = ConvertUserObject(obj, uid);

		// any user type other than <uid> is the body of the message
		if (obj->GetType() == USER && !uid)
		{
			// this is the user's message.

			// TODO: can we assume this cast is safe?  I think so
			MSIXObject * msix = (MSIXObject *) obj;
			// add it to the list of user messages
			mBody.push_back(msix);

			// remove it from the list so that it doesn't get
			// deleted after this function returns
			arContents.Remove(i);

			continue;									// we don't increment i here
		}

		if (uid)
		{
			// copy to our local version
			mUid = *uid;
		}
		else
		{
			// should only contain aggregates now
			if (obj->GetType() != AGGREGATE)
				return FALSE;

			XMLAggregate * agg = (XMLAggregate *) obj;
			const char * name = agg->GetName();

			if (0 == strcmp(name, msTimestampShort) || 0 == strcmp(name, msTimestampLong))
			{
				// <timestamp> time </timestamp>
				XMLString time;
				if (!agg->GetDataContents(time))
					return FALSE;
				string asciiTime;
				BOOL res = XMLStringToAscii(asciiTime, time);
				// TODO: how should we fail here?
				ASSERT(res);
				if (!mTimestamp.Parse(asciiTime.c_str()))
					return FALSE;						// invalid time stamp
			}
			else if (0 == strcmp(name, msVersionShort) || 0 == strcmp(name, msVersionLong))
			{
				// <version> 1.0 </version>
				XMLString version;
				if (!agg->GetDataContents(version))
					return FALSE;

				mVersion.SetBuffer(version.c_str());
				//BOOL res = XMLStringToAscii(mVersion, version);
				// TODO: how should we fail here?
				//ASSERT(res);
			}
			else if (0 == strcmp(name, msEntityShort) || 0 == strcmp(name, msEntityLong))
			{
				// <entity> hostname </entity>
				XMLString entity;
				if (!agg->GetDataContents(entity))
					return FALSE;
			
				mEntity.SetBuffer(entity.c_str());
				//BOOL res = XMLStringToAscii(mEntity, entity);
				// TODO: how should we fail here?
				//ASSERT(res);
			}
			else if (0 == strcmp(name, msTransactionIDShort) || 0 == strcmp(name, msTransactionIDLong))
			{
				// <transactionid> base64 string </transactionid>
				XMLString transactionID;
				if (!agg->GetDataContents(transactionID))
					return FALSE;
			
				mTransactionID.SetBuffer(transactionID.c_str());

			}
			else if (0 == strcmp(name, msListenerTransactionIDShort) || 0 == strcmp(name, msListenerTransactionIDLong))
			{
				// <listenertransactionid> base64 string </listenertransactionid>
				XMLString transactionID;
				if (!agg->GetDataContents(transactionID))
					return FALSE;
			
				mListenerTransactionID.SetBuffer(transactionID.c_str());

			}
			else if (0 == strcmp(name, msSessionContextUserNameShort) || 0 == strcmp(name, msSessionContextUserNameLong))
			{
				// <sessioncontextusername> ... </sessioncontextusername>
				XMLString username;
				if (!agg->GetDataContents(username))
					return FALSE;
			
				mSessionContextUserName.SetBuffer(username.c_str());
			}
			else if (0 == strcmp(name, msSessionContextPasswordShort) || 0 == strcmp(name, msSessionContextPasswordLong))
			{
				// <sessioncontextpassword> ... </sessioncontextpassword>
				XMLString password;
				if (!agg->GetDataContents(password))
					return FALSE;
			
				mSessionContextPassword.SetBuffer(password.c_str());
			}
			else if (0 == strcmp(name, msSessionContextNamespaceShort) || 0 == strcmp(name, msSessionContextNamespaceLong))
			{
				// <sessioncontextnamespace> ... </sessioncontextnamespace>
				XMLString namespaceStr;
				if (!agg->GetDataContents(namespaceStr))
					return FALSE;
			
				mSessionContextNamespace.SetBuffer(namespaceStr.c_str());
			}
			else if (0 == strcmp(name, msSessionContextShort) || 0 == strcmp(name, msSessionContextLong))
			{
				// <sessioncontext> ... </sessioncontext>
				XMLString context;
				if (!agg->GetDataContents(context))
					return FALSE;
			
				mSessionContext.SetBuffer(context.c_str());
			}
			else
				return FALSE;						// unknown aggregate name
		}

		// next element
		i++;
	}
	return TRUE;
}

void MSIXMessage::Output(XMLWriter & arWriter) const
{
	/*
		<msix>	
		 [<signature>] Optional digital signature.  Computed without this tag and value.
		 <timestamp> Time the message header is created.</timestamp>
		 <version> Protocol version.  Literal: "1.0"
		 <uid> Client-assigned flow ID.
		 <entity> Host name of entity creating this MSIX message
		 <listenertransactionid> Client-assigned listener transaction ID
		 <transactionid> Client-assigned pipeline transaction ID
	 	 <body> </body>
		   One or more message body aggregates.
		   The <body> </body> tags are not literal: They are to be replaced
	     with valid message aggregate tags, defined in this document's
			 Protocol Message Sets section.
		</msix>
	*/

	// <msix>
	const char * topTag = ChooseTag(msLongName, msShortName);
	arWriter.OutputOpeningTag(topTag);

	//  <timestamp> time </timestamp>
	const char * tag = ChooseTag(msTimestampLong, msTimestampShort);
	string time;
	mTimestamp.GetStdString(time);
	arWriter.OutputSimpleAggregate(tag, time.c_str());

	// <version> 1.0 </version>
	tag = ChooseTag(msVersionLong, msVersionShort);
	arWriter.OutputSimpleAggregate(tag, mVersion.GetBuffer());

	// <uid> uid </uid>
	mUid.Output(arWriter);

	// <entity> hostname </entity>
	tag = ChooseTag(msEntityLong, msEntityShort);
	arWriter.OutputSimpleAggregate(tag, mEntity.GetBuffer());

	// optional:
	// <listenertransactionid> base64 string </listenertransactionid>
	if (wcslen(mListenerTransactionID.GetBuffer()) != 0)
	{
		tag = ChooseTag(msListenerTransactionIDLong, msListenerTransactionIDShort);
		arWriter.OutputSimpleAggregate(tag, mListenerTransactionID.GetBuffer());
	}

	// optional:
	// <transactionid> base64 string </transactionid>
	if (wcslen(mTransactionID.GetBuffer()) != 0)
	{
		tag = ChooseTag(msTransactionIDLong, msTransactionIDShort);
		arWriter.OutputSimpleAggregate(tag, mTransactionID.GetBuffer());
	}

	// <SessionContext> serialized session context </SessionContext>
	if (mSessionContext.GetBuffer() != 0)
	{
		if(wcslen(mSessionContext.GetBuffer()) != 0)
		{
			tag = ChooseTag(msSessionContextLong, msSessionContextShort);
			arWriter.OutputSimpleAggregate(tag, mSessionContext.GetBuffer());
		}
	}

	// <SessionContextUserName> session context user name </SessionContextUserName>
	if (mSessionContextUserName.GetBuffer() != 0)
	{
		if(wcslen(mSessionContextUserName.GetBuffer()) != 0)
		{
			tag = ChooseTag(msSessionContextUserNameLong, msSessionContextUserNameShort);
			arWriter.OutputSimpleAggregate(tag, mSessionContextUserName.GetBuffer());
		}
	}

	// <SessionContextPassword> passwprd </SessionContextPassword>
	if (mSessionContextPassword.GetBuffer() != 0)
	{
		if(wcslen(mSessionContextPassword.GetBuffer()) != 0)
		{
			tag = ChooseTag(msSessionContextPasswordLong, msSessionContextPasswordShort);
			arWriter.OutputSimpleAggregate(tag, mSessionContextPassword.GetBuffer());
		}
	}

		// <SessionContextPassword> passwprd </SessionContextPassword>
	if (mSessionContextNamespace.GetBuffer() != 0)
	{
		if(wcslen(mSessionContextNamespace.GetBuffer()) != 0)
		{
			tag = ChooseTag(msSessionContextNamespaceLong, msSessionContextNamespaceShort);
			arWriter.OutputSimpleAggregate(tag, mSessionContextNamespace.GetBuffer());
		}
	}


	// body messages
	// HACK: casting away const
	for (int i = 0; i < (int) mBody.size(); i++)
	{
		MSIXObject * obj = mBody[i];
		obj->Output(arWriter);
	}

	// </msix>
	arWriter.OutputClosingTag(topTag);
}
