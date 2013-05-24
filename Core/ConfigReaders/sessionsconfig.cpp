/**************************************************************************
 * @doc SESSIONSCONFIG
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
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>

#include <errobj.h>

#include <sessionsconfig.h>

#ifdef WIN32
#include <mtglobal_msg.h>

#else // WIN32

//
// MessageId: CORE_ERR_CONFIGURATION_PARSE_ERROR
//
// MessageText:
//
//  Parse error while reading a configuration file.
//
#define CORE_ERR_CONFIGURATION_PARSE_ERROR ((DWORD)0xE1100004L)

#endif // WIN32

/*
 * UNIX TODO:
 *
 * generate mtglobal_msg.h to get the correct definition of error codes.
 */



/*********************************************** TestSession ***/

TestSession::TestSession()
	: mServiceID(-1)
{ }

TestSession::~TestSession()
{
	for_each(mInputProps.begin(), mInputProps.end(), destroyPtr<TestProp>);
	for_each(mOutputProps.begin(), mOutputProps.end(), destroyPtr<TestProp>);
	for_each(mSubSessions.begin(), mSubSessions.end(), destroyPtr<TestSession>);
}

/***************************************** TestSessionReader ***/


BOOL
TestSessionsReader::ReadConfiguration(const char * apFilename,
																			TestSessions & arSessions)
{
	XMLConfigParser parser(0);
	if (!parser.Init())
	{
		SetError(parser);
		return FALSE;
	}
	return ReadConfiguration(parser, apFilename, arSessions);
}


BOOL
TestSessionsReader::ReadConfiguration(XMLConfigParser & arParser,
																			const char * apFilename,
																			TestSessions & arSessions)
{
	XMLConfigPropSet * propset = arParser.ParseFile(apFilename);
	if (!propset)
	{
		SetError(arParser);
		return FALSE;
	}

	BOOL result = ReadConfiguration(*propset, arSessions);
	delete propset;
	return result;
}


TestSession * TestSessionsReader::ReadTestSession(XMLConfigPropSet & arSession)
{
	TestSession * session = new TestSession;

	XMLConfigPropSet::XMLConfigObjectIterator it;
	XMLConfigObject * obj;

	for (it = arSession.GetContents().begin(); it != arSession.GetContents().end(); it++)
	{
		obj = *it;

		const char * propName = obj->GetName();

		if (obj->IsNameVal())
		{
			XMLConfigNameVal * prop = obj->AsNameVal();
			ValType::Type type = prop->GetPropType();

			// service name
			if (type == ValType::TYPE_STRING)
			{
				if (0 == strcmp(propName, TEST_SESSION_TAG_SERVICENAME))
					session->mServiceName = ascii(prop->GetString()).c_str();
				// session ID
				else if (0 == strcmp(propName, TEST_SESSION_TAG_SESSIONID))
					session->mSessionID = ascii(prop->GetString()).c_str();
			}
			else if (type == ValType::TYPE_INTEGER)
			{
				// service ID
				if (0 == strcmp(propName, TEST_SESSION_TAG_SERVICEID))
					session->mServiceID = prop->GetInt();
				else
				{
					SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR,
									 ERROR_MODULE, ERROR_LINE,
									 "TestSessions::ReadConfiguration");
					mpLastError->GetProgrammerDetail() = "Bad tag :";
					mpLastError->GetProgrammerDetail() += propName;
				}
			}
		}
		else
		{
			if (0 == strcmp(propName, TEST_SESSION_TAG_INPUTS))
			{
				XMLConfigPropSet * inputs = obj->AsPropSet();

				// add all the properties listed in the inputs section
				if (!ReadPropList(*inputs, session->mInputProps))
				{
					delete session;
					return FALSE;
				}
			}
			else if (0 == strcmp(propName, TEST_SESSION_TAG_OUTPUTS))
			{
				XMLConfigPropSet * outputs = obj->AsPropSet();

				// add all the properties listed in the outputs section
				if (!ReadPropList(*outputs, session->mOutputProps))
				{
					delete session;
					return FALSE;
				}
			}
			else if (0 == strcmp(propName, TEST_SESSION_TAG_SESSION))
			{
				// recursive sub-session
				XMLConfigPropSet * subprops = obj->AsPropSet();

				TestSession * subsession = ReadTestSession(*subprops);
				if (!subsession)
				{
					delete session;
					return FALSE;
				}
				session->mSubSessions.push_back(subsession);
			}
			else
			{
				SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR,
								 ERROR_MODULE, ERROR_LINE,
								 "TestSessions::ReadConfiguration");
				mpLastError->GetProgrammerDetail() = "Bad tag: ";
				mpLastError->GetProgrammerDetail() += propName;
				delete session;
				return FALSE;
			}
		}
	}

	return session;
}

BOOL TestSessionsReader::ReadConfiguration(XMLConfigPropSet & arPropset,
																					 TestSessions & arSessions)
{
	XMLConfigPropSet::XMLConfigObjectIterator it = arPropset.GetContents().begin();
	XMLConfigPropSet::XMLConfigObjectIterator endit = arPropset.GetContents().end();

	while (it != endit)
	{
		XMLConfigObject * obj = *it++;

		if (0 == mtstrcasecmp(obj->GetName(), TEST_SESSION_TAG_SESSION))
		{
			// a session

			if (obj->IsNameVal())
			{
				SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR,
								 ERROR_MODULE, ERROR_LINE,
								 "TestSessionsReader::ReadConfiguration");
				mpLastError->GetProgrammerDetail() = "tag ";
				mpLastError->GetProgrammerDetail() += TEST_SESSION_TAG_SESSION;
				mpLastError->GetProgrammerDetail() += " is of the wrong type";
				return FALSE;
			}

			XMLConfigPropSet * propset = obj->AsPropSet();

			TestSession * session = ReadTestSession(*propset);
			if (!session)
				return FALSE;

			arSessions.AddTestSession(session);
		}
		else
		{
			XMLConfigNameVal * nameval = NULL;
			BOOL badTag = FALSE;
			if (obj->IsNameVal()
					&& (nameval = obj->AsNameVal())->GetPropType() == ValType::TYPE_STRING)
			{
				ASSERT(nameval);

				if (0 == mtstrcasecmp(nameval->GetName(), TEST_SESSION_TAG_AUTHUSERNAME))
					arSessions.SetAuthUsername(ascii(nameval->GetString()).c_str());

				else if (0 == mtstrcasecmp(nameval->GetName(), TEST_SESSION_TAG_AUTHPASSWORD))
					arSessions.SetAuthPassword(ascii(nameval->GetString()).c_str());

				else if (0 == mtstrcasecmp(nameval->GetName(), TEST_SESSION_TAG_AUTHNAMESPACE))
					arSessions.SetAuthNamespace(ascii(nameval->GetString()).c_str());

				else if (0 == mtstrcasecmp(nameval->GetName(), TEST_SESSION_TAG_AUTHCONTEXT))
					arSessions.SetAuthContext(ascii(nameval->GetString()).c_str());

				else
					badTag = TRUE;
			}
			else if (obj->IsNameVal()
					&& (nameval = obj->AsNameVal())->GetPropType() == ValType::TYPE_BOOLEAN)
			{
				ASSERT(nameval);
				if (0 == mtstrcasecmp(nameval->GetName(), TEST_SESSION_TAG_SERIALIZECONTEXT))
					arSessions.SetSerializeContext(nameval->GetBool());

				else
					badTag = TRUE;

			}
			else
				badTag = TRUE;

			if (badTag)
			{
				SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR,
								 ERROR_MODULE, ERROR_LINE,
								 "TestSessionsReader::ReadConfiguration");
				mpLastError->GetProgrammerDetail() = "unrecognized tag ";
				mpLastError->GetProgrammerDetail() += nameval->GetName();
				return FALSE;
			}
		}
	}

	return TRUE;
}


BOOL TestSessionsReader::ReadPropList(XMLConfigPropSet & arInputs,
																			TestPropList & arPropList)
{
	XMLConfigPropSet::XMLConfigObjectIterator it = arInputs.GetContents().begin();
	XMLConfigPropSet::XMLConfigObjectIterator endit = arInputs.GetContents().end();

	XMLConfigNameVal * inputProp;
	for (inputProp = NextVal(it, endit); inputProp != NULL;
			 inputProp = NextVal(it, endit))
	{
		TestProp * testProp = new TestProp(*inputProp);
		arPropList.push_back(testProp);
	}

	// currently there's no way this method can fail
	return TRUE;
}

