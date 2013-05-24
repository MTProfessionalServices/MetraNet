/**************************************************************************
 * @doc GENPARSER
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
 * $Header: genparser.cpp, 21, 9/11/2002 9:45:56 AM, Alon Becker$
 ***************************************************************************/

#ifndef _GENPARSER_TEMPLATE_H
#define _GENPARSER_TEMPLATE_H

#include <metra.h>
#include <mtprogids.h>
#include <mtcomerr.h>
#include <reservedproperties.h>

#include <MSIX.h>
#include <mtglobal_msg.h>
#include <ctype.h>
#include <MTDec.h>
#include <ConfigDir.h>
#include <limits.h>
#include <errno.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")

//
// NOTE:
// This file should only be included by genparser.h
// It contains the templated implementation of genparser
//





// ************************************** 
//
//   MSIXParserServiceDef
//
// ************************************** 

template <class _SessionBuilder> 
MSIXParserServiceDef<_SessionBuilder>::~MSIXParserServiceDef()
{
	// delete contents of the map
	PropIDMap::iterator it;
	for (it = mPropIDs.begin(); it != mPropIDs.end(); it++)
		delete it->second;
	mPropIDs.clear();

	mNonRequiredPropsVector.clear();
}

template <class _SessionBuilder> 
BOOL MSIXParserServiceDef<_SessionBuilder>::Init(CMSIXDefinition * apDef,
																								 MTPipelineLib::IMTNameIDPtr aNameID,
																								 _SessionBuilder ** apSessionBuilder,
																								 MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig,
																								 CMTCryptoAPI * apCrypto)
{
	const char * functionName = "MSIXParserServiceDef::Init";
	mEnumConfig = aEnumConfig;
	mpService = apDef;

	mName = ascii(mpService->GetName());
	mID = aNameID->GetNameID(apDef->GetName().c_str());

	MSIXPropertiesList & props = apDef->GetMSIXPropertiesList();

	// so far, no encrypted properties seen
	mRequiresEncryption = FALSE;

	mTotalRequiredProps = 0;
	mTotalNonRequiredProps = 0;
	mTotalNonRequiredStringProps = 0;

	// create mappings to name IDs
	MSIXPropertiesList::iterator it;
	for (it = props.begin(); it != props.end(); ++it)
	{
		CMSIXProperties * serviceProp = *it;

		const std::wstring & name = serviceProp->GetDN();
		if (0 == mtwcscasecmp(name.c_str(), MT_PROFILESTAGE_PROP)
				|| 0 == mtwcscasecmp(name.c_str(), MT_NEWPARENTID_PROP)
				|| 0 == mtwcscasecmp(name.c_str(), MT_NEWPARENTINTERNALID_PROP)
				|| 0 == mtwcscasecmp(name.c_str(), MT_COLLECTIONID_PROP)
				|| 0 == mtwcscasecmp(name.c_str(), MT_TRANSACTIONCOOKIE_PROP)
				|| 0 == mtwcscasecmp(name.c_str(), MT_INTERVALID_PROP))
		{
			std::string buffer = "special property ";
			buffer += ascii(name);
			buffer += " found in service definition ";
			buffer += ascii(apDef->GetName());

			SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName,
							 buffer.c_str());
			return FALSE;
		}

		// keep track of all properties that must be encrypted
		BOOL requiresEncryption = PropertyRequiresEncryption(name.c_str());
		if (requiresEncryption)
			mRequiresEncryption = TRUE;

		mEncryptedPropList.push_back(ascii(name.c_str()));

		int id = aNameID->GetNameID(name.c_str());

		CMSIXProperties * aProps = serviceProp;
		CMSIXProperties::PropertyType type = aProps->GetPropertyType();
		ServiceDefProp<_SessionBuilder> * svcDefProp = NULL;
		switch (type)
		{
		case CMSIXProperties::TYPE_INT32:
			svcDefProp = new IntServiceDefProp<_SessionBuilder>();
			break;
		
		case CMSIXProperties::TYPE_INT64:
			svcDefProp = new Int64ServiceDefProp<_SessionBuilder>();
			break;
		
		case CMSIXProperties::TYPE_FLOAT:
		case CMSIXProperties::TYPE_DOUBLE:
			svcDefProp = new DoubleServiceDefProp<_SessionBuilder>();
			break;

		case CMSIXProperties::TYPE_TIMESTAMP:
			svcDefProp = new TimestampServiceDefProp<_SessionBuilder>();
			break;

		case CMSIXProperties::TYPE_BOOLEAN:
			svcDefProp = new BooleanServiceDefProp<_SessionBuilder>();
			break;

		case CMSIXProperties::TYPE_ENUM:
			svcDefProp = new EnumServiceDefProp<_SessionBuilder>(mEnumConfig,
																													 aProps->GetEnumNamespace().c_str(),
																													 aProps->GetEnumEnumeration().c_str());
			break;
		
		case CMSIXProperties::TYPE_STRING:
		case CMSIXProperties::TYPE_WIDESTRING:
			if (requiresEncryption)
			{
				EncryptedStringServiceDefProp<_SessionBuilder> * encrypted;
				encrypted = new EncryptedStringServiceDefProp<_SessionBuilder>();
				encrypted->SetCrypto(apCrypto);
				svcDefProp = encrypted;
			}
			else
				svcDefProp = new StringServiceDefProp<_SessionBuilder>();
			break;

		case CMSIXProperties::TYPE_DECIMAL:
			svcDefProp = new DecimalServiceDefProp<_SessionBuilder>();
			break;


		default:
			// TODO:
			//SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
			svcDefProp = NULL;
			break;
		}

		if (!svcDefProp)
			return FALSE;

		// store the property ID
		svcDefProp->SetPropID(id);
		// .. and name for diagnostics
		svcDefProp->SetPropName(ascii(name).c_str());
		
		// store the reference to shared memory
		svcDefProp->SetSessionBuilder(apSessionBuilder);

		// keeps track of required/nonrequired properties for validation later 
		if (serviceProp->GetIsRequired())
		{
			svcDefProp->SetRequired(TRUE);
			mTotalRequiredProps++;
		}
		else 
		{
			svcDefProp->SetRequired(FALSE);
			std::wstring wideDefaultStr = serviceProp->GetDefault().c_str();

			// if there is a default value then add it to the 
			// special non-required prop vector, since we may need
			// to apply the value later
			if (wideDefaultStr.length() != 0)
			{
				std::string defaultStr;
				if (!WideStringToUTF8(wideDefaultStr, defaultStr))
				{
					std::string buffer = "Cannot convert multibyte string to UTF8!";
					SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName,
									 buffer.c_str());
					return FALSE;
				}
				if (!svcDefProp->InitDefault(defaultStr.c_str()))
				{
					std::string buffer = "Cannot initialize default value of property '";
					buffer += ascii(name) + "' from ";
					buffer += ascii(apDef->GetName());
					SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName,
									 buffer.c_str());
					return FALSE;
				}
				mNonRequiredPropsVector.push_back(svcDefProp);
				mTotalNonRequiredProps++;

				if (svcDefProp->IsString())
					mTotalNonRequiredStringProps++;
			}
		}



#ifdef DEBUG
		PropIDMap::iterator it = mPropIDs.find(ascii(name).c_str());
		if (it != mPropIDs.end())
			ASSERT(0);
#endif // DEBUG

		mPropIDs[ascii(name).c_str()] = svcDefProp;
	}

	//
	// add special properties to all service defs
	//


	int id = -1;
	ServiceDefProp<_SessionBuilder> * svcDefProp = NULL;

	// *** NOTE ***
	//When adding special properties below, make sure to update
  //the corresponding property counting mechanism in handler.cpp.
	//Without the corresponding change, the effectiveness of
	//"gracefully handle large sessions" is degraded.

	//handles special properties 
	//(properties which work across all service definitions)

	// _ProfileStage can have the value Y for TRUE, or N for false
	// if true, each stage will generate profiling information
	id = aNameID->GetNameID(MT_PROFILESTAGE_PROP);
	svcDefProp = new BooleanServiceDefProp<_SessionBuilder>;
	svcDefProp->SetPropID(id);
	svcDefProp->SetSessionBuilder(apSessionBuilder);
	svcDefProp->SetSpecial(TRUE);
	mPropIDs[MT_PROFILESTAGE_PROP_A] = svcDefProp;

	// _NewParentID will have a string value - the UID of the parent session
	id = aNameID->GetNameID(MT_NEWPARENTID_PROP);
	svcDefProp = new StringServiceDefProp<_SessionBuilder>;
	svcDefProp->SetPropID(id);
	svcDefProp->SetSessionBuilder(apSessionBuilder);
	svcDefProp->SetSpecial(TRUE);
	mPropIDs[MT_NEWPARENTID_PROP_A] = svcDefProp;

	// _NewParentInternalID will have an integer value - the database
	// ID of the parent session
	id = aNameID->GetNameID(MT_NEWPARENTINTERNALID_PROP);
	svcDefProp = new IntServiceDefProp<_SessionBuilder>;
	svcDefProp->SetPropID(id);
	svcDefProp->SetSessionBuilder(apSessionBuilder);
	svcDefProp->SetSpecial(TRUE);
	mPropIDs[MT_NEWPARENTINTERNALID_PROP_A] = svcDefProp;

	// _CollectionID will have a string value - a UID that identifies a
	// grouping of sessions. 
	id = aNameID->GetNameID(MT_COLLECTIONID_PROP);
	svcDefProp = new StringServiceDefProp<_SessionBuilder>;
	svcDefProp->SetPropID(id);
	svcDefProp->SetSessionBuilder(apSessionBuilder);
	svcDefProp->SetSpecial(TRUE);
	mPropIDs[MT_COLLECTIONID_PROP_A] = svcDefProp;

	// _TransactionCookie will have a string value - an opaque string
	// used to join into distributed transactions.
	id = aNameID->GetNameID(MT_TRANSACTIONCOOKIE_PROP);
	svcDefProp = new StringServiceDefProp<_SessionBuilder>;
	svcDefProp->SetPropID(id);
	svcDefProp->SetSessionBuilder(apSessionBuilder);
	svcDefProp->SetSpecial(TRUE);
	mPropIDs[MT_TRANSACTIONCOOKIE_PROP_A] = svcDefProp;


	// _IntervalID will have an integer value
	id = aNameID->GetNameID(MT_INTERVALID_PROP);
	svcDefProp = new IntServiceDefProp<_SessionBuilder>;
	svcDefProp->SetPropID(id);
	svcDefProp->SetSessionBuilder(apSessionBuilder);
	svcDefProp->SetSpecial(TRUE);
	mPropIDs[MT_INTERVALID_PROP_A] = svcDefProp;

	// _Resubmit will have a boolena value
	id = aNameID->GetNameID(MT_RESUBMIT_PROP);
	svcDefProp = new BooleanServiceDefProp<_SessionBuilder>;
	svcDefProp->SetPropID(id);
	svcDefProp->SetSessionBuilder(apSessionBuilder);
	svcDefProp->SetSpecial(TRUE);
	mPropIDs[MT_RESUBMIT_PROP_A] = svcDefProp;

	// *** NOTE ***
	//When adding special properties above, make sure to update
  //the corresponding property counting mechanism in handler.cpp.
	//Without the corresponding change, the effectiveness of
	//"gracefully handle large sessions" is degraded.

	return TRUE;
}

template <class _SessionBuilder> 
void MSIXParserServiceDef<_SessionBuilder>::GetRequiredPropsVector(ServiceDefPropVector & arRequiredProps) const
{
	PropIDMap::const_iterator it;
	for (it = mPropIDs.begin(); it != mPropIDs.end(); it++)
	{
		ServiceDefProp<_SessionBuilder> * prop = it->second;
		if (prop->IsRequired())
			arRequiredProps.push_back(prop);
	}
}





// ************************************** 
//
//   PipelineMSIXParser
//
// ************************************** 

// transition from one state to another
template <class _SessionBuilder> 
BOOL FASTCALL PipelineMSIXParser<_SessionBuilder>::TransitionState(const char * apTag, int aTagLen,
																																	 PipelineMSIXAction aAction,
																																	 BOOL & arActionRequired,
																																	 BOOL & arIgnore)
{
	const char * functionName = "PipelineMSIXParser::TransitionState";

	ASSERT(mState >= 0 && mState < NUMBER_OF_STATES);
	const ParserStateTransitions & trans = StateTransitions[mState];

	if (trans.mAction != CHAR_DATA && aAction == CHAR_DATA)
	{
#ifdef GENPARSER_VERBOSE
		if (mVerbose)
			printf("(whitespace ignored)\n");
#endif // GENPARSER_VERBOSE

		if (mStrict)
		{
			// TODO: verify it's all whitespace
		}

		arIgnore = TRUE;
		arActionRequired = FALSE;
		return TRUE;
	}

	if (trans.mAction == CHAR_DATA && aAction == CLOSE_TAG)
	{
		// this really means zero length character data
#ifdef GENPARSER_VERBOSE
		if (mVerbose)
			printf("(zero length character data)\n");
#endif // GENPARSER_VERBOSE

		PipelineMSIXParserState newState = trans.mNextState;

		mState = newState;
		// use tail recursion to re-enter after skipping that state
		return TransitionState(apTag, aTagLen, aAction, arActionRequired, arIgnore);
	}

	PipelineMSIXParserState newState = trans.mNextState;

#ifdef GENPARSER_VERBOSE
	if (mVerbose)
	{
		const char * startName = StateNames[mState];
		const char * nextName = StateNames[newState];
		const char * actionName = ActionNames[aAction];
		printf("%s: %s -> %s\n", actionName, startName, nextName);
	}
#endif // GENPARSER_VERBOSE

	if (aAction != trans.mAction)
	{
		const char * actionName = ActionNames[aAction];
		const char * expectedName = ActionNames[trans.mAction];

#ifdef GENPARSER_VERBOSE
		if (mVerbose)
			printf("saw action %s, expecting %s\n", actionName, expectedName);
#endif // GENPARSER_VERBOSE

		SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 (std::string("saw action ") + actionName + ", expecting " + expectedName).c_str());

		return FALSE;
	}

	if (mStrict && (aAction == OPEN_TAG || aAction == CLOSE_TAG))
	{
		if (0 != strncmp(apTag, trans.mTag, aTagLen) ||
        aTagLen != (int)strlen(trans.mTag))
		{
#ifdef GENPARSER_VERBOSE
			if (mVerbose)
				printf("saw unexpected tag %s\n", apTag);
#endif // GENPARSER_VERBOSE
			SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 (std::string("saw unexpected tag ") + apTag).c_str());
			return FALSE;
		}
		else
		{
#ifdef GENPARSER_VERBOSE
			if (mVerbose)
			{
				printf("tag %s verified\n", apTag);
			}
#endif // GENPARSER_VERBOSE
		}
	}

	mState = newState;
	arActionRequired = trans.mRequireProcessing;

	arIgnore = FALSE;
	return TRUE;
}

template <class _SessionBuilder> 
BOOL PipelineMSIXParser<_SessionBuilder>::ManuallyTransitionState(const char * apTag,
																																	PipelineMSIXParserState aSuspectedState)
{
	if (0 == strcmp(apTag, StateTransitions[aSuspectedState].mTag))
	{
		// it was really the state we suspected.  Move to the next state
		mState = StateTransitions[aSuspectedState].mNextState;

#ifdef GENPARSER_VERBOSE
		if (mVerbose)
		{
			printf("manually moved state to %s ", StateNames[mState]);
			printf("<%s>\n", apName);
		}
#endif // GENPARSER_VERBOSE
		return TRUE;
	}
	return FALSE;
}


template <class _SessionBuilder> 
int PipelineMSIXParser<_SessionBuilder>::StartElementHandler(void * apUserData,
																														 const char * apName,
																														 const char * * apAtts)
{
  PipelineMSIXParser * parser = (PipelineMSIXParser *) apUserData;

  return parser->HandleStartElement(apName, apAtts);
}

template <class _SessionBuilder> 
int PipelineMSIXParser<_SessionBuilder>::EndElementHandler(void * apUserData,
																													 const char * apName)
{
  PipelineMSIXParser * parser = (PipelineMSIXParser *) apUserData;
  int res = parser->HandleEndElement(apName);

	return res;
}

template <class _SessionBuilder> 
int PipelineMSIXParser<_SessionBuilder>::CharacterDataHandler(void * apUserData,
																															const char * apStr,
																															int aLen)
{
  PipelineMSIXParser * parser = (PipelineMSIXParser *) apUserData;

  return parser->HandleCharacterData(apStr, aLen);

}

template <class _SessionBuilder> 
void PipelineMSIXParser<_SessionBuilder>::ProcessingStartCData(void* apUserData)
{
	PipelineMSIXParser * parser = (PipelineMSIXParser *) apUserData;
	parser->mbCdataSection = TRUE;
}

template <class _SessionBuilder> 
void PipelineMSIXParser<_SessionBuilder>::ProcessingEndCData(void* apUserData)
{
	PipelineMSIXParser * parser = (PipelineMSIXParser *) apUserData;
	parser->mbCdataSection = FALSE;
}


/************************************************* callbacks ***/

template <class _SessionBuilder> 
int PipelineMSIXParser<_SessionBuilder>::HandleStartElement(const char * apName, const char * * apAtts)
{
	const char * functionName = "PipelineMSIXParser::HandleStartElement";

	// deal with any character data we've received
	int retVal = FinishCharacterData();
	if (!retVal)
		return retVal;

	if (mState == NEXT_PROPERTY)
	{
		// special case - we're expecting either an opening <property>
		// or closing  </properties>.
		// verify that this is <property> and move the state to OPEN_PROPERTY_DN manually
		if (mStrict && 0 != strcmp(apName, "property"))
		{
#ifdef GENPARSER_VERBOSE
			if (mVerbose)
			{
				printf("saw unexpected tag %s\n", apName);
			}
#endif // GENPARSER_VERBOSE
			SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 (std::string("saw unexpected tag ") + apName).c_str());
			return 0;
		}

#ifdef GENPARSER_VERBOSE
		if (mVerbose)
		{
			printf("manually moved state to OPEN_PROPERTY_DN");
			printf("<%s>\n", apName);
		}
#endif // GENPARSER_VERBOSE

		mState = OPEN_PROPERTY_DN;
		return 1;
	}
	else if (mState == NEXT_SESSION)
	{
		// special case - we're expecting either an opening <beginsession>
		// or closing  </msix>.
		// verify that this is <beginsession> and move the state to OPEN_SESSION_DN manually
		if (mStrict && 0 != strcmp(apName, "beginsession"))
		{
#ifdef GENPARSER_VERBOSE
			if (mVerbose)
			{
				printf("saw unexpected tag %s\n", apName);
			}
#endif // GENPARSER_VERBOSE
			SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 (std::string("saw unexpected tag ") + apName).c_str());
			return 0;
		}

#ifdef GENPARSER_VERBOSE
		if (mVerbose)
		{
			printf("manually moved state to OPEN_SESSION_DN");
			printf("<%s>\n", apName);
		}
#endif // GENPARSER_VERBOSE

		mState = OPEN_SESSION_DN;
		return 1;
	}

	BOOL requiresAction;
	BOOL ignore;
	PipelineMSIXParserState oldState = mState;
	BOOL res = TransitionState(apName, strlen(apName), OPEN_TAG, requiresAction, ignore);

	// <feedback> tag is optional.  If it's not found, manually move on
	// to the next tag
	if (!res && oldState == OPEN_FEEDBACK)
	{
		res = ManuallyTransitionState(apName, OPEN_PROPERTIES);
	}

	// <parentid> tag is optional.  If it's not found, manually move on
	// to the next tag
	else if (!res && oldState == OPEN_SESSION_PARENTID)
	{
		res = ManuallyTransitionState(apName, OPEN_COMMIT);
	}

	// <listenertransactionid> tag is optional.  If it's not found, manually move on
	// to the next tag
	else if (!res && oldState == OPEN_LISTENERTRANSACTIONID)
	{
		res = ManuallyTransitionState(apName, OPEN_BEGINSESSION);
		if (!res)
		{
			res = ManuallyTransitionState(apName, OPEN_TRANSACTIONID);
			if (!res)
			{
				res = ManuallyTransitionState(apName, OPEN_CONTEXTUSERNAME);
				if (!res)
				{
					res = ManuallyTransitionState(apName, OPEN_CONTEXTPASSWORD);
					if (!res)
					{
						res = ManuallyTransitionState(apName, OPEN_CONTEXTNAMESPACE);
						if (!res)
							res = ManuallyTransitionState(apName, OPEN_CONTEXT);
					}
				}
			}
		}
	}

	// <transactionid> tag is optional.  If it's not found, manually move on
	// to the next tag
	else if (!res && oldState == OPEN_TRANSACTIONID)
	{
		res = ManuallyTransitionState(apName, OPEN_BEGINSESSION);
		if (!res)
		{
			res = ManuallyTransitionState(apName, OPEN_CONTEXTUSERNAME);
			if (!res)
			{
				res = ManuallyTransitionState(apName, OPEN_CONTEXTPASSWORD);
				if (!res)
				{
					res = ManuallyTransitionState(apName, OPEN_CONTEXTNAMESPACE);
					if (!res)
						res = ManuallyTransitionState(apName, OPEN_CONTEXT);
				}
			}
		}
	}

	// <contextusername> tag is optional.  If it's not found, manually move on
	// to the next tag
	else if (!res && oldState == OPEN_CONTEXTUSERNAME)
	{
		res = ManuallyTransitionState(apName, OPEN_BEGINSESSION);
		if (!res)
		{
			res = ManuallyTransitionState(apName, OPEN_CONTEXTPASSWORD);
			if (!res)
			{
				res = ManuallyTransitionState(apName, OPEN_CONTEXTNAMESPACE);
				if (!res)
					res = ManuallyTransitionState(apName, OPEN_CONTEXT);
			}
		}
	}

	// <contextpassword> tag is optional.  If it's not found, manually move on
	// to the next tag
	else if (!res && oldState == OPEN_CONTEXTPASSWORD)
	{
		res = ManuallyTransitionState(apName, OPEN_BEGINSESSION);
		if (!res)
		{
			res = ManuallyTransitionState(apName, OPEN_CONTEXTNAMESPACE);
			if (!res)
				res = ManuallyTransitionState(apName, OPEN_CONTEXT);
		}
	}
	// <contextnamespace> tag is optional.  If it's not found, manually move on
	// to the next tag
	else if (!res && oldState == OPEN_CONTEXTNAMESPACE)
	{
		res = ManuallyTransitionState(apName, OPEN_BEGINSESSION);
		if (!res)
			res = ManuallyTransitionState(apName, OPEN_CONTEXT);
	}

	// <context> tag is optional.  If it's not found, manually move on
	// to the next tag
	else if (!res && oldState == OPEN_CONTEXT)
	{
		res = ManuallyTransitionState(apName, OPEN_BEGINSESSION);
	}

#ifdef GENPARSER_VERBOSE
	if (mVerbose)
	{
		printf("<%s>\n", apName);
	}
#endif // GENPARSER_VERBOSE

	if (!res)
		return 0;

	return 1;
}


template <class _SessionBuilder> 
int PipelineMSIXParser<_SessionBuilder>::HandleEndElement(const char * apName)
{
	const char * functionName = "PipelineMSIXParser::HandleEndElement";

	// deal with any character data we've received
	int retVal = FinishCharacterData();
	if (!retVal)
		return retVal;

	if (mState == NEXT_PROPERTY)
	{
		// special case - we're expecting either an opening <property>
		// or closing  </properties>.
		// verify that this is </properties> and move the state to CLOSE_BEGINSESSION manually
		if (mStrict && 0 != strcmp(apName, "properties"))
		{
#ifdef GENPARSER_VERBOSE
			if (mVerbose)
			{
				printf("saw unexpected tag %s\n", apName);
			}
#endif // GENPARSER_VERBOSE
			SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 (std::string("saw unexpected tag ") + apName).c_str());
			return 0;
		}
#ifdef GENPARSER_VERBOSE
		if (mVerbose)
		{
			printf("manually moved state to CLOSE_BEGINSESSION");
			printf("<%s>\n", apName);
		}
#endif // GENPARSER_VERBOSE

		mState = CLOSE_BEGINSESSION;
		return 1;
	}
	else if (mState == NEXT_SESSION)
	{
		// special case - we're expecting either a closing </msix>
		// or an opening <beginsession> (which would start another session)
		// verify that this is </msix> and move the state to TERMINATE_PARSE manually
		if (mStrict && 0 != strcmp(apName, "msix"))
		{
#ifdef GENPARSER_VERBOSE
			if (mVerbose)
			{
				printf("saw unexpected tag %s\n", apName);
			}
#endif // GENPARSER_VERBOSE
			SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 (std::string("saw unexpected tag ") + apName).c_str());
			return 0;
		}
#ifdef GENPARSER_VERBOSE
		if (mVerbose)
		{
			printf("manually moved state to TERMINATE_PARSE");
			printf("<%s>\n", apName);
		}
#endif // GENPARSER_VERBOSE

		mState = TERMINATE_PARSE;
		return 1;
	}

	BOOL requiresAction;
	BOOL ignore;

	PipelineMSIXParserState oldState = mState;
	BOOL res = TransitionState(apName, strlen(apName), CLOSE_TAG, requiresAction, ignore);

	// <properties> block can be empty if no properties are metered
	// TODO: use ManuallyTransitionState
	if (!res && oldState == OPEN_PROPERTY)
	{
		if (mStrict && 0 != strcmp(apName, "properties"))
		{
#ifdef GENPARSER_VERBOSE
			if (mVerbose)
			{
				printf("saw unexpected tag %s\n", apName);
			}
#endif // GENPARSER_VERBOSE
			SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 (std::string("saw unexpected tag ") + apName).c_str());
			return 0;
		}

#ifdef GENPARSER_VERBOSE
		if (mVerbose)
		{
			printf("manually moved state to CLOSE_BEGINSESSION");
			printf("<%s>\n", apName);
		}
#endif // GENPARSER_VERBOSE


		mState = CLOSE_BEGINSESSION;
		res = TRUE;
		return 1;
	}

#ifdef GENPARSER_VERBOSE
	if (mVerbose)
	{
		printf("</%s>\n", apName);
	}
#endif // GENPARSER_VERBOSE

	if (res && requiresAction)
	{
		switch (oldState)
		{
		case CLOSE_BEGINSESSION:
			// prepare for the next session if there is one
			if (!SessionComplete())
			{
				// if we're validating, get all errors
				if (!mValidateOnly)
					return FALSE;
			}
			break;

		case CLOSE_PROPERTY_VALUE:
		case VALUE_PROPERTY_VALUE:	// we get in this state on empty strings
			// if the property value is still unaccounted for, an empty string
			// was encountered
			if (mpProp != NULL)
			{
				// we still don't have a property value
				if (!HandlePropertyValue("", 0))
					return FALSE;
			}
			break;

		default:
			// we should handle all other cases
			ASSERT(0);
		}
		// TODO: hmm. nothing to do here
	}

	if (!res)
		return 0;

	return 1;
}


template <class _SessionBuilder> 
int FASTCALL PipelineMSIXParser<_SessionBuilder>::HandleCharacterData(const char * apStr, int aLen)
{
	const char * functionName = "PipelineMSIXParser::HandleCharacterData";

	if (mCharacterDataOffset == 0)
	{
		// first call
		mpLastCharacterData = apStr;
		mLastCharacterDataLength = aLen;
		mCharacterDataOffset = aLen;
		return 1;
	}
	else
	{
		// we've been called more than once.
		if (mpLastCharacterData)
		{
			// copy the data from the previous/first call.
			if (mLastCharacterDataLength >
					sizeof(mCharacterDataBuffer) / sizeof(mCharacterDataBuffer[0]))
			{
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
								 "Character data too long");
				return 0;
			}

			strncpy(mCharacterDataBuffer, mpLastCharacterData,
							mLastCharacterDataLength);

			// mCharacterDataOffset was already adjusted for this string
		}

		// append the current data
		if (mCharacterDataOffset + aLen > 
				sizeof(mCharacterDataBuffer) / sizeof(mCharacterDataBuffer[0]))
		{
			SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 "Character data too long");
			return 0;
		}

		strncpy(mCharacterDataBuffer + mCharacterDataOffset, apStr, aLen);
		mCharacterDataOffset += aLen;

		mpLastCharacterData = NULL;
		mLastCharacterDataLength = 0;
		return 1;
	}
}

template <class _SessionBuilder> 
int FASTCALL PipelineMSIXParser<_SessionBuilder>::FinishCharacterData()
{
	if (mCharacterDataOffset > 0)
	{
		int retVal;
		if (mpLastCharacterData)
		{
			// HandleCharacterData was only called once
			retVal = HandleAllCharacterData(mpLastCharacterData,
																			mLastCharacterDataLength);
		}
		else
		{
			// use the buffer we've constructed
			retVal = HandleAllCharacterData(mCharacterDataBuffer,
																			mCharacterDataOffset);
		}

		// reset for next time
		mCharacterDataOffset = 0;
		mpLastCharacterData = NULL;
		mLastCharacterDataLength = 0;

		return retVal;
	}
	else
		return 1;
}

template <class _SessionBuilder> 
int FASTCALL PipelineMSIXParser<_SessionBuilder>::HandleAllCharacterData(const char * apStr, int aLen)
{
	const char * functionName = "PipelineMSIXParser::HandleAllCharacterData";

	BOOL requiresAction;
	BOOL ignore;
	PipelineMSIXParserState oldState = mState;
	BOOL res = TransitionState(NULL, 0, CHAR_DATA, requiresAction, ignore);

#ifdef GENPARSER_VERBOSE
	if (mVerbose && !ignore)
	{
		std::string buffer(apStr, aLen);
		printf("[%s]\n", buffer.c_str());
	}
#endif // GENPARSER_VERBOSE

	if (res && requiresAction)
	{
		switch (oldState)
		{
		case VALUE_TIMESTAMP:
		{
			std::string buffer(apStr, aLen);
			if (!MTParseISOTime(buffer.c_str(), &mpValidationData->mMeteredTime))
			{
				std::string errorBuffer("Invalid timestamp: ");
				buffer.append(apStr, aLen);
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
								 errorBuffer.c_str());
				return FALSE;
			}
			mpSessionBuilder->SetMeteredTime(mpValidationData->mMeteredTime);
			break;
		}

		case VALUE_VERSION:
		{
			if (aLen > sizeof(mpValidationData->mSDKVersion))
			{
				std::string buffer("Invalid SDK version: ");
				buffer.append(apStr, aLen);
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
								 buffer.c_str());
				return FALSE;
			}
			strncpy(mpValidationData->mSDKVersion, apStr, aLen);
			mpValidationData->mSDKVersion[aLen] = '\0';
			break;
		}

		case VALUE_MESSAGE_UID:
		{
			if (aLen > sizeof(mpValidationData->mMessageID))
			{
				std::string buffer("Invalid message UID: ");
				buffer.append(apStr, aLen);
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
								 buffer.c_str());
				return FALSE;
			}
			strncpy(mpValidationData->mMessageID, apStr, aLen);
			mpValidationData->mMessageID[aLen] = '\0';
			break;
		}

		case VALUE_ENTITY:
		{
			if (aLen > sizeof(mpValidationData->mIPAddress))
			{
				std::string buffer("Invalid IP address: ");
				buffer.append(apStr, aLen);
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
								 buffer.c_str());
				return FALSE;
			}
			strncpy(mpValidationData->mIPAddress, apStr, aLen);
			mpValidationData->mIPAddress[aLen] = '\0';
			mpSessionBuilder->SetIPAddress(mpValidationData->mIPAddress);
			break;
		}

	  case VALUE_TRANSACTIONID:
		{
			if (aLen > sizeof(mpValidationData->mTransactionID) - 1) // > 255
			{
				char buffer[128];
				sprintf(buffer, "Transaction ID is too large! len = %d", aLen);
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
								 buffer);
				return FALSE;
			}

			strncpy(mpValidationData->mTransactionID, apStr, aLen);
			mpValidationData->mTransactionID[aLen] = '\0';
			mpSessionBuilder->SetTransactionID(mpValidationData->mTransactionID);
			break;
		}

	  case VALUE_LISTENERTRANSACTIONID:
		{
			std::string listenerTransactionID = std::string(apStr, aLen);
			mpSessionBuilder->SetListenerTransactionID(listenerTransactionID.c_str());
			break;
		}


	  case VALUE_CONTEXTUSERNAME:
		{
			
			if (aLen > sizeof(mpValidationData->mContextUsername) - 1) // > 255
			{
				char buffer[128];
				sprintf(buffer, "Session context username is too large! len = %d",
								aLen);
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
								 buffer);
				return FALSE;
			}

			strncpy(mpValidationData->mContextUsername, apStr, aLen);
			mpValidationData->mContextUsername[aLen] = '\0';
			mpSessionBuilder->SetSessionContextUsername(mpValidationData->mContextUsername);
			break;
		}

	  case VALUE_CONTEXTPASSWORD:
		{
				
			if (aLen > sizeof(mpValidationData->mContextPassword) - 1) // > 255
			{
				char buffer[128];
				sprintf(buffer, "Session context password is too large! len = %d",
								aLen);
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
								 buffer);
				return FALSE;
			}

			strncpy(mpValidationData->mContextPassword, apStr, aLen);
			mpValidationData->mContextPassword[aLen] = '\0';
			mpSessionBuilder->SetSessionContextPassword(mpValidationData->mContextPassword);
			break;
		}

	  case VALUE_CONTEXTNAMESPACE:
		{
			
			if (aLen > sizeof(mpValidationData->mContextNamespace) - 1) // > 255
			{
				char buffer[128];
				sprintf(buffer, "Session context namespace is too large! len = %d",
								aLen);
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
								 buffer);
				return FALSE;
			}

			strncpy(mpValidationData->mContextNamespace, apStr, aLen);
			mpValidationData->mContextNamespace[aLen] = '\0';
			mpSessionBuilder->SetSessionContextNamespace(mpValidationData->mContextNamespace);
			break;
		}

	  case VALUE_CONTEXT:
		{
			mpValidationData->mpSessionContext = new char[aLen + 1];
			strncpy(mpValidationData->mpSessionContext, apStr, aLen);
			mpValidationData->mpSessionContext[aLen] = '\0';
			mpSessionBuilder->SetSerializedSessionContext(mpValidationData->mpSessionContext);
			break;
		}

		case VALUE_SESSION_DN:
		{
			// figure out the service
			mpService = NULL;

			ServiceDefName key(apStr, aLen);
			ServiceDefMap::const_iterator it = mServiceDefMap.find(key);
			if (it == mServiceDefMap.end())
			{
				// TODO:
				std::string buffer("Unable to find service definition named ");
				buffer.append(apStr, aLen);
				SetError(MT_ERR_UNKNOWN_SERVICE, ERROR_MODULE, ERROR_LINE, functionName,
								 buffer.c_str());
				return FALSE;
			}

			const MSIXParserServiceDef<_SessionBuilder> & svcDef = it->second;

			mpService = &svcDef;
			break;
		}

		case VALUE_SESSION_UID:
		{
			std::string buffer(apStr, aLen);
			if (!MSIXUidGenerator::Decode(mSessionUID, buffer))
			{
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
				return FALSE;
			}

			break;
		}

		case VALUE_SESSION_PARENTID:
		{
			std::string buffer(apStr, aLen);
			if (!MSIXUidGenerator::Decode(mSessionParentUID, buffer))
			{
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
				return FALSE;
			}

			break;
		}

		case VALUE_COMMIT:
			// the commit tag is after both the uid (required) and parentuid (optional)
			// tags.  this is a good time to set up the session object which requires
			// both values
			if (!SetupSession())
				return FALSE;

			break;

		case VALUE_INSERT:
			if (aLen == 1 && *apStr == 'N')
				mRetry = TRUE;
			break;

		case VALUE_FEEDBACK:
			if (aLen == 1 && *apStr == 'Y')
				mFeedback = TRUE;
			break;

		case VALUE_PROPERTY_DN:
		{

			mpProp = mpService->GetProp(apStr, aLen);
			if (!mpProp)
			{
				std::string buffer = "Session has an unknown property: ";
				buffer.append(apStr, aLen);
				SetSessionError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName,
												buffer.c_str());

				// if we're validating, get all errors
				if (!mValidateOnly)
					return FALSE;
			}
				
			//mPropID = mpService->GetNameID(apStr, aLen);

			//std::string buffer(apStr, aLen);
			//printf("%s = %d\n", buffer.c_str(), mPropID);

			//mPropID = mNameID->GetNameID(buffer.c_str());
			break;
		}
		case VALUE_PROPERTY_VALUE:
		{
			if (!HandlePropertyValue(apStr, aLen))
			{
				// if we're validating, get all errors
				if (!mValidateOnly)
					return FALSE;
			}

			// property should have been cleared
			ASSERT(!mpProp);
			break;
		}
		default:
			break;
		}
	}


	if (!res)
		return 0;

	return 1;
}

/**************************************** PipelineMSIXParser ***/

template <class _SessionBuilder> 
PipelineMSIXParser<_SessionBuilder>::PipelineMSIXParser()
	: mParser(NULL), mpProp(NULL), mpHeader(NULL),
		mpValidationData(NULL), mpMappedView(NULL), mpSessionBuilder(NULL),
		mPipelineInfo(NULL)
{
	mState = OPEN_MSIX;
#ifdef GENPARSER_VERBOSE
	mVerbose = TRUE;
#endif // GENPARSER_VERBOSE
	mStrict = TRUE;

	mValidateOnly = FALSE;

	mCharacterDataOffset = 0;
	mpLastCharacterData = NULL;
	mLastCharacterDataLength = 0;

	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[genparser]");

}

template <class _SessionBuilder> 
PipelineMSIXParser<_SessionBuilder>::~PipelineMSIXParser()
{
	Clear();

	delete mpMappedView;
	mpMappedView = NULL;
}


// NOTE: this method is for debugging only
template <class _SessionBuilder> 
BOOL PipelineMSIXParser<_SessionBuilder>::InitForParse()
{
	const char * functionName = "PipelineMSIXParser::InitForParse";

	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		ASSERT(0);
		return FALSE;
	}

	PipelineInfo pipelineInfo;
	PipelineInfoReader pipelineReader;
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		SetError(pipelineReader.GetLastError());
		return FALSE;
	}

	return InitForParse(pipelineInfo);
}

template <class _SessionBuilder> 
BOOL PipelineMSIXParser<_SessionBuilder>::InitForParse(const PipelineInfo & arInfo)
{
	const char * functionName = "PipelineMSIXParser::InitForParse";

	Clear();

	// TODO: InitForParse isn't anything more then InitForValidation after the refactor
	//       should probably just be Init()

	try
	{
		// whatever initialization is done for validation is also needed by us
		if (!InitForValidate(arInfo))
			return FALSE;

		mpValidationData = NULL;


	}
	catch (_com_error & e)
	{
		ErrorObject * err = CreateErrorFromComError(e);
		SetError(err);
		delete err;
		return FALSE;
	}

	return TRUE;
}


template <class _SessionBuilder> 
BOOL PipelineMSIXParser<_SessionBuilder>::InitForValidate()
{
	const char * functionName = "PipelineMSIXParser::InitForValidate";

	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		ASSERT(0);
		return FALSE;
	}

	// reads the standard pipeline config file
	PipelineInfo pipelineInfo;
	PipelineInfoReader pipelineReader;
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		SetError(pipelineReader.GetLastError());
		return FALSE;
	}

	return InitForValidate(pipelineInfo);
}

template <class _SessionBuilder> 
BOOL PipelineMSIXParser<_SessionBuilder>::InitForValidate(const PipelineInfo & arInfo)
{
	const char * functionName = "PipelineMSIXParser::InitForValidate";

	Clear();

	mPipelineInfo = &arInfo;

	//
	// initialize the crypto functions
	//
	
	// Don't bother to create the keys here.  If they aren't created yet,
	// then there can't be any encryption keys!
	int result = mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_ServiceDefProp, "metratechpipeline", TRUE, "pipeline");
	if (result != 0)
	{
		// NOTE: this "result" code is not very useful so override it
		// with the crypto specific code
		SetError(CORE_ERR_CRYPTO_FAILURE, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	if (!InitializeSessionBuilder())
		return FALSE;

	HRESULT hr = mNameID.CreateInstance(MTPROGID_NAMEID);
	if (FAILED(hr))
	{
		// TODO: better error here
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	if (!mServices.Initialize())
	{
		// TODO: make sure mServices returns a good error in all cases
		const ErrorObject * err = mServices.GetLastError();
		ASSERT(err);
		if (err)
			SetError(err);
		else
			SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	hr = mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);
	if(FAILED(hr))
	{
		SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	MSIXDefCollection::MSIXDefinitionList::iterator it;
	for (it = mServices.GetDefList().begin(); it != mServices.GetDefList().end();
			 ++it)
	{
		CMSIXDefinition* pDef = *it;

#ifdef DEBUG
		ServiceDefMap::iterator it = mServiceDefMap.find(ascii(pDef->GetName()).c_str());
		if (it != mServiceDefMap.end())
			ASSERT(0);
#endif // DEBUG

		MSIXParserServiceDef<_SessionBuilder> & parserdef = mServiceDefMap[ascii(pDef->GetName()).c_str()];
		if (!parserdef.Init(pDef, mNameID, &mpSessionBuilder, mEnumConfig,
												&mCrypto))
		{
			SetError(parserdef);
			return FALSE;
		}
	}

	return TRUE;
}

template <class _SessionBuilder> 
BOOL PipelineMSIXParser<_SessionBuilder>::InitializeSessionBuilder()
{
	ASSERT(!mpSessionBuilder);
	try
	{
		mpSessionBuilder = new _SessionBuilder();
		mpSessionBuilder->Initialize(*mPipelineInfo, &mCrypto);
	}
	catch (MTException & e)
	{
		SetError(e);

		delete mpSessionBuilder;
		mpSessionBuilder = NULL;

		return FALSE;
	}
	
	return TRUE;
}

template <class _SessionBuilder> 
void PipelineMSIXParser<_SessionBuilder>::Clear()
{
	if (mParser)
		XML_ParserFree(mParser);
	mParser = NULL;

	mServiceDefMap.clear();
	mpValidationData = NULL;

	mCharacterDataOffset = 0;
	mpLastCharacterData = NULL;
	mLastCharacterDataLength = 0;

	if (mpSessionBuilder)
	{
		delete mpSessionBuilder;
		mpSessionBuilder = NULL;
	}
}

// this method is always called before Parse or Validate
template <class _SessionBuilder> 
BOOL PipelineMSIXParser<_SessionBuilder>::SetupParser()
{
	const char * functionName = "PipelineMSIXParser::SetupParser";

	ClearSessionState();

	mState = OPEN_MSIX;
	mpProp = NULL;
	mpValidationData = NULL;
	mConstrainedSvcID = -1;

	if (mParser)
	{
		XML_ParserFree(mParser);
		mParser = NULL;
	}

  mParser = XML_ParserCreate("UTF-8");
	if (!mParser)
	{
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to allocate parser");
		return FALSE;
	}


  // this value is passed as the userData argument to the callbacks
  // use it to get the this pointer back
  XML_SetUserData(mParser, this);

  XML_SetElementHandler(mParser, StartElementHandler,
												EndElementHandler);

  XML_SetCharacterDataHandler(mParser, CharacterDataHandler);

	XML_SetCdataSectionHandler(mParser,ProcessingStartCData,ProcessingEndCData);

	XML_SetParamEntityParsing(mParser,XML_PARAM_ENTITY_PARSING_ALWAYS);
	return TRUE;
}


//
// NOTE: Parse only needs to work with the classic MSMQ/shared memory configuration
//       It has been replaced by the new dbparser in v4.0.
//
template <class _SessionBuilder> 
BOOL PipelineMSIXParser<_SessionBuilder>::Parse(const char * apStr, int aLen,
																								ISessionProduct ** apProduct,
																								ValidationData & arValidationData)
{
	char * functionName = "PipelineMSIXParser<_SessionBuilder>::Parse";

	ASSERT(mParser);
	ASSERT(!mValidateOnly);

	ClearSessionState();

	mpValidationData = &arValidationData;

	try
	{
		mpSessionBuilder->StartProduction();
		
		if (!XML_Parse(mParser, apStr, aLen, TRUE))
		{
			mpSessionBuilder->AbortProduction();
			SetParseErrorDetail();
			return FALSE;
		}

		*apProduct = mpSessionBuilder->CompleteProduction();
	}
	catch(std::exception & e)
	{
		mpSessionBuilder->AbortProduction();

		std::string msg = "Parse failed with exception: ";
		msg += e.what();

		SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName, msg.c_str());
		return FALSE;
	}
	catch (_com_error & e)
	{
		mpSessionBuilder->AbortProduction();

		ErrorObject * err = CreateErrorFromComError(e);
		SetError(err);
		delete err;
		return FALSE;
	}
	catch (...)
	{
		mpSessionBuilder->AbortProduction();
		
		SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Parse failed with unknown exception!");
		// TODO: is there any info we can log here to make these easier to debug?
		return FALSE;
	}

	return TRUE;
}

template <class _SessionBuilder> 
BOOL PipelineMSIXParser<_SessionBuilder>::Validate(const char * apStr, int aLen,
																									 ISessionProduct ** apProduct,
																									 ValidationData & arValidationData)
{
	char * functionName = "PipelineMSIXParser<_SessionBuilder>::Validate";
	ASSERT(mValidateOnly);

	for (int dbFailureRetryCount = 0; dbFailureRetryCount < 5; dbFailureRetryCount++)
	{
		try  
		{
			mpValidationData = &arValidationData;
			mpValidationData->mRequiresFeedback = FALSE;
			mpValidationData->mIsRetry = FALSE;
			mpValidationData->mSDKVersion[0] = '\0';
			
			// if the builder isn't constructed at this point it means
			// we are recovering from a fatal database connectivity issue
			// the best we can do at this point is make another attempt to connect
			if (!mpSessionBuilder)
			{
				mLogger.LogVarArgs(LOG_WARNING, "No session builder available. Creating one...");
				
				if (!InitializeSessionBuilder())
					return FALSE;
			}

			mpSessionBuilder->StartProduction();
			
			if (!XML_Parse(mParser, apStr, aLen, TRUE))  	// last param is final
			{
				// since this is validation mode, errors are 
				// accumulated and this method shouldn't in practice return false
				mpSessionBuilder->AbortProduction();
				SetParseErrorDetail();
				return FALSE;
			}
			
			// checks if the parse really failed
			bool success = mpValidationData->mErrors.size() == 0;
			if (success)
			{
				if (apProduct)
					*apProduct = mpSessionBuilder->CompleteProduction();
			}
			else
				mpSessionBuilder->AbortProduction();
			
			if (mpValidationData->mpPropCount)
			{
				// count additional properties which are added in for every session
				// if new properties are added this will need to be
				// modified to reflect the change.
				mpValidationData->mpPropCount->total += 6;
				if (mpValidationData->mRequiresFeedback)
					mpValidationData->mpPropCount->total++;
				mpValidationData->mpPropCount->smallStr++;
			}
			
			return success;
		}
		catch(COdbcException & e)
		{
			//
			// Handles potential database connectivity loss
			//
			
			// an ODBC exception is assumed to be a connectivity issue
			// genparser will try up to 5 additional times to re-validate the message
			// each time the builder will be recreated and initialized (forcing connections to be re-established)
			mLogger.LogVarArgs(LOG_WARNING, "Potential database connectivity issue detected! (%s)", e.what());

			// try for up to 10 minutes (600 retries) to get a good builder
			int i;
			for (i = 0; i < 600; i++)
			{
				Sleep(1000);
				mLogger.LogVarArgs(LOG_WARNING, "Attempting to reestablish database connectivity (retry %d)...", i + 1);
				if (RecoverSessionBuilder())
					break;
			}

			// database is dead, give up!
			if (i == 600)
			{
				try 
				{
					mpSessionBuilder->AbortProduction();
					delete mpSessionBuilder;
					mpSessionBuilder = NULL;
				} catch(...) { }; // swallows any connectivity exceptions
				
				mLogger.LogVarArgs(LOG_FATAL, "Could not reestablish database connectivity after 10 minutes! Check the database server.");
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName, "Parse failed due to database connectivity issues!");
				return FALSE;
			}


			// resets data structures for revalidaiton
			arValidationData.Clear();
			
			if (!SetupParser())
				return FALSE;
			
			mLogger.LogVarArgs(LOG_WARNING, "Database connectivity reestablished! Attempting to revalidate the message (retry %d)",
												 dbFailureRetryCount + 1);
		}
		catch(std::exception & e)
		{
			mpSessionBuilder->AbortProduction();
			
			std::string msg = "Parse failed with exception: ";
			msg += e.what();
			SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName, msg.c_str());
			return FALSE;
		}
		catch (_com_error & e)
		{
			mpSessionBuilder->AbortProduction();
			
			ErrorObject * err = CreateErrorFromComError(e);
			SetError(err);
			delete err;
			return FALSE;
		}
		catch (...)
		{
			mpSessionBuilder->AbortProduction();
			
			SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 "Parse failed with unknown exception!");
			// TODO: is there any info we can log here to make these easier to debug?
			return FALSE;
		}
	}

	return FALSE;
}


template <class _SessionBuilder> 
BOOL PipelineMSIXParser<_SessionBuilder>::RecoverSessionBuilder()
{
	// aborts
	try
	{	
		mpSessionBuilder->AbortProduction(); 
	}
	catch(...) 
	{
		mLogger.LogVarArgs(LOG_WARNING, "Exception caught calling AbortProduction - moving on"); 
	}
	
	// deletes
	try 
	{
		delete mpSessionBuilder; 
	}
	catch(...) 
	{
		mLogger.LogVarArgs(LOG_WARNING, "Exception caught calling builder destructor - moving on");	
	}
	mpSessionBuilder = NULL;
			
	// initializes
	try 
	{
		if (!InitializeSessionBuilder())
			return FALSE;
	}
	catch(...) 
	{ 
		mLogger.LogVarArgs(LOG_ERROR, "Exception caught calling InitializeSessionBuilder!"); 
		return FALSE;
	}
		
	return TRUE;
}


template <class _SessionBuilder> 
void PipelineMSIXParser<_SessionBuilder>::SetSessionError(DWORD errorCode,
																													const char * module,
																													int line,
																													const char * functionName,
																													const char * errorMessage)
{
	mSessionParseHasFailed = TRUE;

	SetError(errorCode, module, line, functionName, errorMessage);

	std::string uidBuffer;
	MSIXUidGenerator::Encode(uidBuffer, mSessionUID);

	if (errorMessage != NULL)
	{
		ErrorObject & errObj = mpValidationData->mErrors[uidBuffer];
		errObj.Init(errorCode, module, line, functionName);
		errObj.GetProgrammerDetail() = errorMessage;
	}
}

template <class _SessionBuilder> 
void PipelineMSIXParser<_SessionBuilder>::SetParseErrorDetail()
{
	int code, line, col;
	long byt;
	const char * message;

	GetErrorInfo(code, message, line, col, byt);
	if (code == XML_ERROR_SEMANTIC_ERROR)
	{
		// semantic errors are stored on this object itself so we
		// don't need to do anything
		return;
	}

	// TODO: use a real error number!
	SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, "XMLParser::ParseFinal");

	ASSERT(mpLastError);
	string & detail = mpLastError->GetProgrammerDetail();
	detail = message;
	// TODO: not ANSI
	char buffer[20];
  sprintf(buffer, "%d", code);
#ifdef _WIN32
	_itoa(code, buffer, 10);
#endif
	detail += ", code=";
	detail += buffer;

  sprintf(buffer, "%d", line);
#ifdef _WIN32
	_itoa(code, buffer, 10);
#endif
	detail += ", line=";
	detail += buffer;

  sprintf(buffer, "%d", col);
#ifdef _WIN32
	_itoa(code, buffer, 10);
#endif
	detail += ", col=";
	detail += buffer;

  sprintf(buffer, "%ld", byt);
#ifdef _WIN32
	_itoa(code, buffer, 10);
#endif
	detail += ", byte=";
	detail += buffer;
}



template <class _SessionBuilder> 
BOOL PipelineMSIXParser<_SessionBuilder>::SetupSession()
{
	const char * functionName = "PipelineMSIXParser::SetupSession";

	if (mSessionParseHasFailed)
	{
		// if parsing it failed, don't even try to create the object
		ASSERT(GetLastError());
		return FALSE;
	}

	ASSERT(mpService);
	int svcID = mpService->GetID();


	//
	// gets the parent UID if any
	//
	unsigned char * parentUID;
	// all zeros means no UID
	static unsigned char nulluid[UID_LENGTH] =
		{ 0x00,0x00,0x00,0x00,
			0x00,0x00,0x00,0x00,
			0x00,0x00,0x00,0x00,
			0x00,0x00,0x00,0x00,
		};
	if (0 == memcmp(mSessionParentUID, nulluid, UID_LENGTH))
		parentUID = NULL;
	else
		parentUID = mSessionParentUID;


	BOOL isChild;

	try
	{
		if (!parentUID)
		{
			// top-level session: either a parent or an atomic
			isChild = FALSE;

			// enforces that all top-level sessions in a message are of the same type
			if (mConstrainedSvcID != svcID)
			{
				if (mConstrainedSvcID == -1)
					mConstrainedSvcID = svcID;
				else
				{
					SetError(PIPE_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
									 "Session set contains more than one type of top-level session!");
					return FALSE;
				}
			}

			mpSessionBuilder->CreateSession(mSessionUID, svcID);
		}
		else
		{
			isChild = TRUE;
			mpSessionBuilder->CreateChildSession(mSessionUID, svcID, parentUID);
		}
	}
	catch (_com_error & err)
	{
		// these calls can fail for only two reasons - out of shared memory or
		// duplicate session.
		ErrorObject * obj = CreateErrorFromComError(err);
		ASSERT(obj);
		if (obj->GetCode() == PIPE_ERR_DUPLICATE_SESSION)
			SetError(obj, "Unable to create session object - duplicate session UID");
		else if (obj->GetCode() == PIPE_ERR_SHARED_OBJECT_FAILURE)
			SetError(obj, "Unable to create session object - possible overflow of shared memory");
		else
			SetError(obj, "Unable to create session object");

		delete obj;
		return FALSE;
	}
	catch (MTException & e)
	{
		SetError(e);
		return FALSE;
	}

	return TRUE;
}

template <class _SessionBuilder> 
BOOL PipelineMSIXParser<_SessionBuilder>::SessionComplete()
{
	const char * functionName = "PipelineMSIXParser::SessionComplete";
	
	ASSERT(mpService);

	if (mpService->RequiresEncryption())
		mpValidationData->mHasServiceDefWithEncryptedProp = TRUE;
		
	if (mFeedback)
	{
		// at least this session requires feedback
		mpValidationData->mRequiresFeedback = TRUE;
		mpSessionBuilder->SetSynchronous(true);
	}
	
	if (mRetry)
		// pass up record of whether or not this is a retry
		mpValidationData->mIsRetry = TRUE;

	// checks that all required properties are present
	int missingProps = mTotalRequiredPropsAdded < mpService->GetTotalRequiredProps();
 	if ((missingProps > 0) && !mSessionParseHasFailed)
	{
		//
		// logs names of all missing properties and returns an error for
		// the last missing property
		//
		MSIXParserServiceDef<_SessionBuilder>::ServiceDefPropVector requiredProps;
		mpService->GetRequiredPropsVector(requiredProps);
		
		MSIXParserServiceDef<_SessionBuilder>::ServiceDefPropVector::iterator it;
		int i = 0;  // missing property index
		std::string buffer = "Session of type '";
		buffer += mpService->GetName();
		buffer += "' is missing the following required properties: ";
		for (it = requiredProps.begin(); it != requiredProps.end(); it++)
		{
			ServiceDefProp<_SessionBuilder> * prop = *it;
			
			if (!mpSessionBuilder->SessionPropertyExists(prop->GetPropID()))
			{
				if (i++ > 0)
					buffer +="; ";
				buffer += prop->GetName().c_str();
				SetSessionError(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName,
												buffer.c_str());
			}
		}

		mpSessionBuilder->CompleteSession();
		ClearSessionState();
		return FALSE;
	}

	ApplyDefaults();

	mpSessionBuilder->CompleteSession();

	ClearSessionState();
	return TRUE;
}

template <class _SessionBuilder> 
void PipelineMSIXParser<_SessionBuilder>::ApplyDefaults()
{
	// if non-required properties are not accounted for then we may need
	// to apply some default values
	if (mTotalNonRequiredPropsAdded < mpService->GetTotalNonRequiredProps())
	{
		if (!mValidateOnly && mpValidationData->mAddDefaultValues)
		{
			MSIXParserServiceDef<_SessionBuilder>::ServiceDefPropVector nonRequiredProps;
			nonRequiredProps = mpService->GetNonRequiredPropsVector();
			MSIXParserServiceDef<_SessionBuilder>::ServiceDefPropVector::iterator it;

			// iterates over non-required properties
			for (it = nonRequiredProps.begin(); it != nonRequiredProps.end(); it++)
				// applies the default if not found in session
				(*it)->SetDefault();
		}
		else if (mpValidationData->mpPropCount)
		{
			// track property counts!
				
			// total count always goes up
			mpValidationData->mpPropCount->total +=
				mpService->GetTotalNonRequiredProps() - mTotalNonRequiredPropsAdded;

			// we don't know which non-required properties are missing.
			// to be totally conservative, add one to each property pool.  this will
			// overcount but it's safe
			int possibleStrings =
				mpService->GetTotalNonRequiredStringProps() - mTotalNonRequiredStringPropsAdded;

			mpValidationData->mpPropCount->smallStr += possibleStrings;
			mpValidationData->mpPropCount->mediumStr += possibleStrings;
			mpValidationData->mpPropCount->largeStr += possibleStrings;
		}
	}
}

template <class _SessionBuilder> 
void PipelineMSIXParser<_SessionBuilder>::ClearSessionState()
{
	memset(mSessionUID, 0x00, UID_LENGTH);
	memset(mSessionParentUID, 0x00, UID_LENGTH);
	mSessionParseHasFailed = FALSE;
	mpProp = NULL;
	mpService = NULL;
	mFeedback = FALSE;
	mRetry = FALSE;
	mTotalRequiredPropsAdded = 0;
	mTotalNonRequiredPropsAdded = 0;
	mTotalNonRequiredStringPropsAdded = 0;
}


template <class _SessionBuilder> 
BOOL PipelineMSIXParser<_SessionBuilder>::HandlePropertyValue(const char * apStr, int aLen)
{
	const char * functionName = "PipelineMSIXParser::HandlePropertyValue";

	if (mSessionParseHasFailed && !mpProp)
		// can't set the property if it's unknown
		return FALSE;

	ASSERT(mpProp);

	if (mpValidationData->mpPropCount)
	{
		// track property counts!

		// total count always goes up
		mpValidationData->mpPropCount->total++;

		if (mpProp->IsString())
		{
			int characters = UTF8StringLength(apStr, aLen);
			if (!UpdateStringPropCount(*mpValidationData->mpPropCount,
																 characters))
			{
				std::string buffer("Property ");
				buffer += mpProp->GetName();
				buffer += " is longer than the maximum string length.";
				SetSessionError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName,
												buffer.c_str());
				mpProp = NULL;
				return FALSE;
			}
		}
	}

	if (!mpProp->SetProperty(apStr, aLen))
	{
		std::string buffer("Property ");
		buffer += mpProp->GetName();
		buffer += " (value=";
		buffer.append(apStr, aLen);
		buffer += ") could not be converted to the specified type";
		SetSessionError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName,
										buffer.c_str());
		mpProp = NULL;
		return FALSE;
	}

	// keeps a tally for efficient processing in SessionComplete
	if (mpProp->IsRequired())
		mTotalRequiredPropsAdded++;
	else if (!mpProp->IsSpecial() && mpProp->HasDefault())
	{
		mTotalNonRequiredPropsAdded++;
		if (mpProp->IsString())
			mTotalNonRequiredStringPropsAdded++;
	}
			
	mpProp = NULL;
	return TRUE;
}



template <class _SessionBuilder> 
bool PipelineMSIXParser<_SessionBuilder>::UpdateStringPropCount(PropertyCount & arPropCount,
																																int characters)
{
	//the string size maximums are in bytes not chars
	int bytes = characters * 2 + 1;  //add 1 for the terminating '\0'

	//tiny strings are counted in the total count so don't count them here
	if (bytes < SharedSessionHeader::TINY_STRING_MAX)
		return true;

	if (bytes <= SharedSessionHeader::SMALL_STRING_MAX)
		arPropCount.smallStr++;
	else if (bytes <= SharedSessionHeader::MEDIUM_STRING_MAX)
		arPropCount.mediumStr++;
	else if (bytes <= SharedSessionHeader::LARGE_STRING_MAX)
		arPropCount.largeStr++;
	else
		return false; //string is too big for largest of string pools
	
	return true;
}




/********************************** service def prop objects ***/

// ********
//   int
// ********
template <class _SessionBuilder> 
BOOL IntServiceDefProp<_SessionBuilder>::InitDefault(const char * apStr)
{
	if (!ConvertString(apStr, strlen(apStr), mDefaultVal))
		return FALSE;
	
	mHasDefault = TRUE;
	return TRUE;
}

template <class _SessionBuilder> 
inline BOOL IntServiceDefProp<_SessionBuilder>::ConvertString(const char * apStr, int aLen, long& arValue)
{
	char str[256];
	if (aLen + 1 > sizeof(str))
		return FALSE;								// too long!

	strncpy(str, apStr, aLen);
	str[aLen] = '\0';

	char * end;
	errno = 0;
	arValue = strtol(str, &end, 10);
	if (end != str + aLen)
		return FALSE;

	// overflow or underflow was detected
	if (errno == ERANGE)
		return FALSE;
	
	return TRUE;
}

template <class _SessionBuilder> 
BOOL IntServiceDefProp<_SessionBuilder>::SetDefault()
{
	// TODO: figure out throw semantics
	if (!(*mpSessionBuilder)->SessionPropertyExists(mPropID))
		(*mpSessionBuilder)->AddLongSessionProperty(mPropID, mDefaultVal);

	return TRUE;
}

template <class _SessionBuilder> 
BOOL IntServiceDefProp<_SessionBuilder>::SetProperty(const char * apStr, int aLen)
{
	long val;
	if (!ConvertString(apStr, aLen, val))
		return FALSE;

	// TODO: figure out throw semantics
	(*mpSessionBuilder)->AddLongSessionProperty(mPropID, val);

	return TRUE;
}


// ********
//   int64
// ********
template <class _SessionBuilder> 
BOOL Int64ServiceDefProp<_SessionBuilder>::InitDefault(const char * apStr)
{
	if (!ConvertString(apStr, strlen(apStr), mDefaultVal))
		return FALSE;
	
	mHasDefault = TRUE;
	return TRUE;
}

template <class _SessionBuilder> 
inline BOOL Int64ServiceDefProp<_SessionBuilder>::ConvertString(const char * apStr, int aLen, __int64& arValue)
{
	char str[256];
	if (aLen + 1 > sizeof(str))
		return FALSE;								// too long!

	strncpy(str, apStr, aLen);
	str[aLen] = '\0';

	char * end;
	arValue = _strtoi64(str, &end, 10);
	if (end != str + aLen)
		return FALSE;

	// overflow is signalled by setting the value to the max
	if ((arValue == _I64_MAX) || (arValue == _I64_MIN))
		return FALSE;

	return TRUE;
}

template <class _SessionBuilder> 
BOOL Int64ServiceDefProp<_SessionBuilder>::SetDefault()
{
	// TODO: figure out throw semantics
	if (!(*mpSessionBuilder)->SessionPropertyExists(mPropID))
		(*mpSessionBuilder)->AddLongLongSessionProperty(mPropID, mDefaultVal);

	return TRUE;
}

template <class _SessionBuilder> 
BOOL Int64ServiceDefProp<_SessionBuilder>::SetProperty(const char * apStr, int aLen)
{
	__int64 val;
	if (!ConvertString(apStr, aLen, val))
		return FALSE;

	// TODO: figure out throw semantics
	(*mpSessionBuilder)->AddLongLongSessionProperty(mPropID, val);

	return TRUE;
}


// ***********
//    double
// ***********
template <class _SessionBuilder> 
BOOL DoubleServiceDefProp<_SessionBuilder>::InitDefault(const char * apStr)
{
	if (!ConvertString(apStr, strlen(apStr), mDefaultVal))
		return FALSE;
	
	mHasDefault = TRUE;
	return TRUE;
}

template <class _SessionBuilder> 
inline BOOL DoubleServiceDefProp<_SessionBuilder>::ConvertString(const char * apStr, int aLen, double& arValue)
{
	char str[256];
	if (aLen + 1 > sizeof(str))
		return FALSE;								// too long!

	strncpy(str, apStr, aLen);
	str[aLen] = '\0';

	char * end;
	arValue = strtod(str, &end);
	if (end != str + aLen)
		return FALSE;

	// double can support larger values but ultimately these will be stored as numeric(22,10)
	// so make sure the values conform
	if ((arValue < -999999999999.999) || (arValue > 999999999999.999))
		return FALSE;

	return TRUE;
}

template <class _SessionBuilder> 
BOOL DoubleServiceDefProp<_SessionBuilder>::SetDefault()
{
	// TODO: figure out throw semantics
	if (!(*mpSessionBuilder)->SessionPropertyExists(mPropID))
		(*mpSessionBuilder)->AddDoubleSessionProperty(mPropID, mDefaultVal);

	return TRUE;
}

template <class _SessionBuilder> 
BOOL DoubleServiceDefProp<_SessionBuilder>::SetProperty(const char * apStr, int aLen)
{
	double val;
	if (!ConvertString(apStr, aLen, val))
		return FALSE;
				
	// TODO: figure out throw semantics
	(*mpSessionBuilder)->AddDoubleSessionProperty(mPropID, val);

	return TRUE;
}


// ***********
//   boolean
// ***********
template <class _SessionBuilder> 
BOOL BooleanServiceDefProp<_SessionBuilder>::InitDefault(const char * apStr)
{
	if (!ConvertString(apStr, strlen(apStr), mDefaultVal))
		return FALSE;
	
	mHasDefault = TRUE;
	return TRUE;
}

template <class _SessionBuilder> 
inline BOOL BooleanServiceDefProp<_SessionBuilder>::ConvertString(const char * apStr, int aLen, bool& arValue)
{
	// only one chararcter is expected
	if (aLen != 1) 
		return FALSE;

	// conforms strictly to the MSIX specification [tTfF]
	switch(apStr[0]) {
	case 'T': case 't':
		arValue = true;
		break;
	case 'F':	case 'f':
		arValue = false;
		break;
	default:
		return FALSE;
	}

	return TRUE;
}

template <class _SessionBuilder> 
BOOL BooleanServiceDefProp<_SessionBuilder>::SetDefault()
{
	// TODO: figure out throw semantics
	if (!(*mpSessionBuilder)->SessionPropertyExists(mPropID))
		(*mpSessionBuilder)->AddBoolSessionProperty(mPropID, mDefaultVal);

	return TRUE;
}

template <class _SessionBuilder> 
BOOL BooleanServiceDefProp<_SessionBuilder>::SetProperty(const char * apStr, int aLen)
{
	bool val;
	if (!ConvertString(apStr, aLen, val))
		return FALSE;

	// TODO: figure out throw semantics
	(*mpSessionBuilder)->AddBoolSessionProperty(mPropID, val);

	return TRUE;
}


// ***********
//  timestamp
// ***********
template <class _SessionBuilder> 
BOOL TimestampServiceDefProp<_SessionBuilder>::InitDefault(const char * apStr)
{
	if (!ConvertString(apStr, strlen(apStr), mDefaultVal))
		return FALSE;
	
	mHasDefault = TRUE;
	return TRUE;
}

template <class _SessionBuilder> 
inline BOOL TimestampServiceDefProp<_SessionBuilder>::ConvertString(const char * apStr, int aLen, time_t& arValue)
{
	char str[256];
	if (aLen + 1 > sizeof(str))
		return FALSE;								// too long!

	strncpy(str, apStr, aLen);
	str[aLen] = '\0';

	if (!::MTParseISOTime(str, &arValue))
		return FALSE;

	return TRUE;
}

template <class _SessionBuilder> 
BOOL TimestampServiceDefProp<_SessionBuilder>::SetDefault()
{
	// TODO: figure out throw semantics
	if (!(*mpSessionBuilder)->SessionPropertyExists(mPropID))
		(*mpSessionBuilder)->AddTimestampSessionProperty(mPropID, mDefaultVal);

	return TRUE;
}

template <class _SessionBuilder> 
BOOL TimestampServiceDefProp<_SessionBuilder>::SetProperty(const char * apStr, int aLen)
{
	time_t val;
	if (!ConvertString(apStr, aLen, val))
		return FALSE;
	
	// TODO: figure out throw semantics
	(*mpSessionBuilder)->AddTimestampSessionProperty(mPropID, val);

	return TRUE;
}


// ********
//  string
// ********
template <class _SessionBuilder> 
BOOL StringServiceDefProp<_SessionBuilder>::InitDefault(const char * apStr)
{
	if (!ConvertString(apStr, strlen(apStr), mDefaultVal,
										 sizeof(mDefaultVal) / sizeof(mDefaultVal[0])))
		return FALSE;
	
	mDefaultLen = wcslen(mDefaultVal);

	mHasDefault = TRUE;
	return TRUE;
}

template <class _SessionBuilder> 
inline BOOL StringServiceDefProp<_SessionBuilder>::ConvertString(const char * apStr, int aLen, wchar_t * apValue, int aBufferLen)
{
	// TODO: potential buffer overrun???
	int postLen = MultiByteToWideChar(
		CP_UTF8,										// code page
		0,													// character-type options
		apStr,											// address of string to map
		aLen,												// number of bytes in string
		apValue,									  // address of wide-character buffer
		aBufferLen);								// size of buffer

	if (aLen >= aBufferLen)
	{
		ASSERT(FALSE);
		return FALSE;
	}

	apValue[postLen] = L'\0';

	return TRUE;
}

template <class _SessionBuilder> 
BOOL StringServiceDefProp<_SessionBuilder>::SetDefault()
{
	// TODO: figure out throw semantics
	if (!(*mpSessionBuilder)->SessionPropertyExists(mPropID))
		(*mpSessionBuilder)->AddStringSessionProperty(mPropID, mDefaultVal);

	return TRUE;
}

template <class _SessionBuilder> 
BOOL StringServiceDefProp<_SessionBuilder>::SetProperty(const char * apStr, int aLen)
{
	wchar_t val[300]; // 256 + extra safety padding
	if (!ConvertString(apStr, aLen, val, sizeof(val) / sizeof(val[0])))
		return FALSE;

	// TODO: figure out throw semantics
	(*mpSessionBuilder)->AddStringSessionProperty(mPropID, val);

	return TRUE;
}

template <class _SessionBuilder> 
BOOL StringServiceDefProp<_SessionBuilder>::IsString() const
{
	// the upper level needs to know this is a string so it can count
	// the number of properties of each type.
	return TRUE;
}


// *******************
//  encrypted string
// *******************
template <class _SessionBuilder> 
BOOL EncryptedStringServiceDefProp<_SessionBuilder>::InitDefault(const char * apStr)
{
	if (!ConvertString(apStr, strlen(apStr), mDefaultVal, sizeof(mDefaultVal) / sizeof(mDefaultVal[0])))
		return FALSE;
	
	mDefaultLen = wcslen(mDefaultVal);

	mHasDefault = TRUE;
	return TRUE;
}

template <class _SessionBuilder> 
inline BOOL EncryptedStringServiceDefProp<_SessionBuilder>::ConvertString(
	const char * apStr,	int aLen, wchar_t * apValue, int aBufferLen)
{
	if (aLen == 0)
		return FALSE;

	// TODO: potential buffer overrun???
	int postLen = MultiByteToWideChar(
		CP_UTF8,										// code page
		0,													// character-type options
		apStr,											// address of string to map
		aLen,												// number of bytes in string
		apValue,									  // address of wide-character buffer
		aBufferLen);								// size of buffer

	if (postLen >= aBufferLen)
	{
		ASSERT(FALSE);
		return FALSE;
	}

	apValue[postLen] = L'\0';
	return TRUE;
}

template <class _SessionBuilder> 
BOOL EncryptedStringServiceDefProp<_SessionBuilder>::SetDefault()
{
	std::wstring value;

	// TODO: figure out throw semantics
	if (!(*mpSessionBuilder)->SessionPropertyExists(mPropID))
		(*mpSessionBuilder)->AddEncryptedStringSessionProperty(mPropID, mDefaultVal);

	return TRUE;
}

template <class _SessionBuilder> 
BOOL EncryptedStringServiceDefProp<_SessionBuilder>::SetProperty(const char * apStr, int aLen)
{
	wchar_t val[300]; // 256 + extra safety padding
	if (!ConvertString(apStr, aLen, val, sizeof(val) / sizeof(val[0])))
		return FALSE;

	// TODO: figure out throw semantics
	(*mpSessionBuilder)->AddEncryptedStringSessionProperty(mPropID, val);

	return TRUE;
}

template <class _SessionBuilder> 
BOOL EncryptedStringServiceDefProp<_SessionBuilder>::IsString() const
{
	// the upper level needs to know this is a string so it can count
	// the number of properties of each type.
	return TRUE;
}


// *********
//   enum
// ********
template <class _SessionBuilder> 
BOOL EnumServiceDefProp<_SessionBuilder>::InitDefault(const char * apStr)
{
	if (!ConvertString(apStr, strlen(apStr), mDefaultVal))
		return FALSE;
	
	mHasDefault = TRUE;
	return TRUE;
}

template <class _SessionBuilder> 
inline BOOL EnumServiceDefProp<_SessionBuilder>::ConvertString(const char * apStr, int aLen, long& arValue)
{
	char str[256];
	if (aLen + 1 > sizeof(str))
		return FALSE;								// too long!

	strncpy(str, apStr, aLen);
	str[aLen] = '\0';

	try 
	{
		// gets the enum id
		arValue = mEnumConfig->GetID(mNamespace, mEnumeration, _bstr_t(str));
	}
	catch (_com_error&)
	{
		return FALSE;
	}

	return TRUE;
}

template <class _SessionBuilder> 
BOOL EnumServiceDefProp<_SessionBuilder>::SetDefault()
{
	// TODO: figure out throw semantics
	if (!(*mpSessionBuilder)->SessionPropertyExists(mPropID))
		(*mpSessionBuilder)->AddEnumSessionProperty(mPropID, mDefaultVal);

	return TRUE;
}

template <class _SessionBuilder> 
BOOL EnumServiceDefProp<_SessionBuilder>::SetProperty(const char * apStr, int aLen)
{
	long val;
	if (!ConvertString(apStr, aLen, val))
		return FALSE;

	// TODO: figure out throw semantics
	(*mpSessionBuilder)->AddEnumSessionProperty(mPropID, val);

	return TRUE;
}


// *********
//  decimal
// *********
template <class _SessionBuilder> 
BOOL DecimalServiceDefProp<_SessionBuilder>::InitDefault(const char * apStr)
{
	if (!ConvertString(apStr, strlen(apStr), mDefaultVal))
		return FALSE;
	
	mHasDefault = TRUE;
	return TRUE;
}

template <class _SessionBuilder> 
inline BOOL DecimalServiceDefProp<_SessionBuilder>::ConvertString(const char * apStr, int aLen, DECIMAL& arValue)
{
	char str[256];
	if (aLen + 1 > sizeof(str))
		return FALSE;								// too long!

	strncpy(str, apStr, aLen);
	str[aLen] = '\0';

	MTDecimal mtdec;
	if (!mtdec.SetValue(str))
		return FALSE;

	if ((mtdec > METRANET_DECIMAL_MAX) || (mtdec < METRANET_DECIMAL_MIN))
		return FALSE;

	arValue = mtdec;
	ASSERT(sizeof(arValue) == SharedPropVal::DECIMAL_SIZE);

	return TRUE;
}

template <class _SessionBuilder> 
BOOL DecimalServiceDefProp<_SessionBuilder>::SetDefault()
{
	// TODO: figure out throw semantics
	if (!(*mpSessionBuilder)->SessionPropertyExists(mPropID))
		(*mpSessionBuilder)->AddDecimalSessionProperty(mPropID, mDefaultVal);

	return TRUE;
}

template <class _SessionBuilder> 
BOOL DecimalServiceDefProp<_SessionBuilder>::SetProperty(const char * apStr, int aLen)
{
	DECIMAL val;
	if (!ConvertString(apStr, aLen, val))
		return FALSE;

	// TODO: figure out throw semantics
	(*mpSessionBuilder)->AddDecimalSessionProperty(mPropID, val);

	return TRUE;
}


#endif /* _GENPARSER_TEMPLATE_H */
