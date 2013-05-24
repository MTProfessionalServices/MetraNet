/**************************************************************************
 * @doc AUTO
 *
 * Copyright 2000 by MetraTech Corporation
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
#include <mtcom.h>

#include <autosessiontest.h>

#include <MSIX.h>
#include <MTDec.h>
#include <mtglobal_msg.h>
#include <propids.h>
#include <loggerconfig.h>
#include <mttime.h>

#pragma warning(disable:4800)

BOOL PipelineAutoTest::Init()
{
	LoggerConfigReader configReader;
	return mLogger.Init(configReader.ReadConfiguration("logging"), "[AutoTest]");
}


BOOL PipelineAutoTest::ReadTestSetup(MTPipelineLib::IMTConfigPtr aConfig,
																		 TestSessions & arTestSessions,
																		 const char * apTestFile)
{
	TestSessionsReader testReader;
	if (!testReader.ReadConfiguration(apTestFile, arTestSessions))
	{
		SetError(testReader.GetLastError());
		return FALSE;
	}

	return TRUE;
}

BOOL PipelineAutoTest::ReadAutoTest(MTPipelineLib::IMTConfigPtr aConfig,
																		const AutoTestList & arTestList,
																		TestSessions & arTestSessions,
																		const char * apConfigDir, const char * apStageName)
{
	AutoTestList::const_iterator it;
	for (it = arTestList.begin(); it != arTestList.end(); it++)
	{
		string autotest = *it;
		mLogger.LogVarArgs(LOG_DEBUG, "Preparing test: %s", autotest.c_str());


		// TODO: fix how this path is created
		string testfile(apConfigDir);
		testfile += "\\";
		testfile += autotest;

		mLogger.LogVarArgs(LOG_DEBUG, "Test file: %s", testfile.c_str());

		if (!ReadTestSetup(aConfig, arTestSessions, testfile.c_str()))
			return FALSE;
	}
	return TRUE;
}


BOOL PipelineAutoTest::RunAutoTest(MTPipelineLib::IMTNameIDPtr aNameID,
																	 MTPipelineLib::IMTSessionServerPtr aSessionServer,
																	 TestSessions & arTestSessions)
{
	TestSessionList sessions = arTestSessions.GetTestSessions();
  TestSessionList::const_iterator sessit = sessions.begin();

	mLogger.LogThis(LOG_INFO, "Running autotest...");

	int testCount = 0;
	BOOL testOk = TRUE;
	while (sessit != sessions.end())
	{
		testCount++;
		TestSession * test = (*sessit);
    sessit++;

		MTPipelineLib::IMTSessionPtr session = CreateTestSession(aNameID, aSessionServer, *test, NULL);
		if (session == NULL)
			return FALSE;

		MTPipelineLib::IMTSessionSetPtr set = aSessionServer->CreateSessionSet();
		set->AddSession(session->GetSessionID(), session->GetServiceID());


		// do whatever needs to be done to test the session
		BOOL success = RunSession(*this, set);

		if (!success)
		{
			// RunSession will have called SetError on *this
			mLogger.LogThis(LOG_ERROR, "Unable to run test");			
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			testOk = FALSE;
		}

#if 0
		mLogger.LogVarArgs(LOG_DEBUG, "Executing plug-in: %s", (const char *) GetName());

		// run the plug in
		if (!ProcessSessions(set))
			return FALSE;
#endif

		if (testOk)
		{
			if (TestOutputProps(aNameID, session, *test))
				mLogger.LogThis(LOG_INFO, "Auto test passed.");
			else
			{							 
				mLogger.LogThis(LOG_ERROR, "Session test failed!");
				testOk = FALSE;
			}
		}
	}

	if (testCount == 0)
		mLogger.LogVarArgs(LOG_DEBUG, "No autotests.");
	else
		mLogger.LogVarArgs(LOG_INFO, "Autotest completed with %d test sessions", testCount);

	return testOk;
}


MTPipelineLib::IMTSessionPtr PipelineAutoTest::CreateTestSession(MTPipelineLib::IMTNameIDPtr aNameID,
                                                                 MTPipelineLib::IMTSessionServerPtr aSessionServer,
                                                                 TestSession & arSession,
                                                                 MTPipelineLib::IMTSessionPtr aParentSession)
{
	const char * functionName = "PipelineAutoTest::CreateTestSession";

	int serviceID = arSession.GetServiceID();
	if (serviceID == -1)
	{
		if (arSession.GetServiceName().length() == 0)
		{
			SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 "Service ID invalid or not specified");
			return NULL;
		}

		serviceID = aNameID->GetNameID(arSession.GetServiceName().c_str());
	}

	// generate a UID for this session.
	string uidString;
	unsigned char uid[16];
	MSIXUidGenerator::Generate(uidString);
	MSIXUidGenerator::Decode(uid, uidString);

	// create a parent or child session as appropriate
	MTPipelineLib::IMTSessionPtr session;
	if (aParentSession != NULL)
	{
		//long parentId = aParentSession->GetSessionID();
		unsigned char parentID[16];

		aParentSession->GetUID(parentID);

		session = aSessionServer->CreateChildSession(uid, serviceID, parentID);

		// increase the ref count so that it
		// doesn't get deleted before the parent
		session->IncreaseSharedRefCount();
	}
	else
	{
		session = aSessionServer->CreateSession(uid, serviceID);
	}

	// special properties: set _Timestamp and ServiceID
	long propid;
	propid = PipelinePropIDs::ServiceIDCode();
	session->SetLongProperty(propid, serviceID);

	// set time to current time
  _variant_t now = GetMTOLETime();
	propid = PipelinePropIDs::TimestampCode();
	session->SetOLEDateProperty(propid, (DATE)now);

	// now set properties listed in the file
	TestPropList & inputs = arSession.GetInputProps();
  TestPropList::const_iterator it = inputs.begin();
	while (it != inputs.end())
	{
		TestProp * testProp = (*it);
    it++;

		const std::string & name = testProp->GetName();
		propid = aNameID->GetNameID((const char *) name.c_str());

		mLogger.LogVarArgs(LOG_DEBUG, "Setting property %s", (const char *) name.c_str());

		switch (testProp->GetPropType())
		{
		case ValType::TYPE_INTEGER:
			session->SetLongProperty(propid, testProp->GetInt());
			break;
		case ValType::TYPE_DOUBLE:
			session->SetDoubleProperty(propid, testProp->GetDouble());
			break;
		case ValType::TYPE_DECIMAL:
			session->SetDecimalProperty(propid, DECIMAL(MTDecimal(testProp->GetDecimal())));
			break;
		case ValType::TYPE_STRING:
			session->SetBSTRProperty(propid, testProp->GetString().c_str());
			break;
		case ValType::TYPE_DATETIME:
			session->SetDateTimeProperty(propid, (long) testProp->GetDateTime());
			break;
		case ValType::TYPE_TIME:
			session->SetTimeProperty(propid, testProp->GetTime());
			break;
		case ValType::TYPE_BOOLEAN:
			session->SetBoolProperty(propid, (testProp->GetBool()) ? VARIANT_TRUE : VARIANT_FALSE);
			break;
		case ValType::TYPE_ENUM:
			session->SetEnumProperty(propid,testProp->GetEnum());
			break;
		default:
			mLogger.LogVarArgs(LOG_ERROR, "Unknown prop type for %s", (const char *) name.c_str());
			break;
		}
	}

	// create any child sessions
  TestSessionList subsessions =  arSession.GetSubSessions();
  TestSessionList::const_iterator childit = subsessions.begin();
	while (childit != subsessions.end())
	{
		mLogger.LogThis(LOG_DEBUG, "Creating child session.");
		TestSession * subsession = (*childit);
    childit++;
		MTPipelineLib::IMTSessionPtr childtest = CreateTestSession(aNameID, aSessionServer,
																								*subsession, session);
		if (childtest == NULL)
			return NULL;
	}

	return session;
}

BOOL PipelineAutoTest::TestOutputProps(MTPipelineLib::IMTNameIDPtr aNameID,
																			 MTPipelineLib::IMTSessionPtr aSession,
																			 TestSession & arSession)
{
	const char * functionName = "PlugInConfig::TestOutputProps";

	// now set properties listed in the file
	TestPropList & outputs = arSession.GetOutputProps();
  TestPropList::const_iterator it = outputs.begin();
	BOOL testPassed = TRUE;
	long propid;
	while (it != outputs.end())
	{
		TestProp * testProp = (*it);
    it++;

		const std::string & name = testProp->GetName();
		propid = aNameID->GetNameID((const char *) name.c_str());

		mLogger.LogVarArgs(LOG_DEBUG, "Testing property %s", (const char *) name.c_str());

		long longVal;
		_bstr_t bstrVal;
		time_t timeVal;
		double doubleVal;
		bool booleanVal;
		MTDecimal decimalVal;

		std::string printableValue;
		std::string printableExpected;

		BOOL matched;
		switch (testProp->GetPropType())
		{
			case ValType::TYPE_INTEGER:
			longVal = aSession->GetLongProperty(propid);
			matched = (longVal == testProp->GetInt());
			mLogger.LogVarArgs(LOG_DEBUG, "value = %ld expected %ld", longVal, testProp->GetInt());
			break;
		case ValType::TYPE_DOUBLE:
			doubleVal = aSession->GetDoubleProperty(propid);
			matched = (doubleVal == testProp->GetDouble());
			mLogger.LogVarArgs(LOG_DEBUG, "value = %f expected %f", doubleVal,
												 testProp->GetDouble());
			break;
		case ValType::TYPE_DECIMAL:
		{
			decimalVal = aSession->GetDecimalProperty(propid);
			matched = (decimalVal == MTDecimal(testProp->GetDecimal()));
			MTDecimal mtdec(testProp->GetDecimal());
			mLogger.LogVarArgs(LOG_DEBUG, "value = %s expected %s", decimalVal.Format().c_str(),
												 mtdec.Format().c_str());
			break;
		}
		case ValType::TYPE_STRING:
			bstrVal = aSession->GetBSTRProperty(propid);
			matched = (0 == wcscmp(bstrVal, testProp->GetString().c_str()));
			mLogger.LogVarArgs(LOG_DEBUG, "value = %s expected %s", (const char *) bstrVal,
												 (const char *) (_bstr_t) testProp->GetString().c_str());
			break;
		case ValType::TYPE_DATETIME:
			timeVal = aSession->GetDateTimeProperty(propid);
			matched = (timeVal == testProp->GetDateTime());
			::MTFormatISOTime(timeVal, printableValue);
			::MTFormatISOTime((long) testProp->GetDateTime(), printableExpected);
			mLogger.LogVarArgs(LOG_DEBUG, "value = %s expected %s", printableValue,
												 printableExpected);
			break;
		case ValType::TYPE_TIME:
			longVal = aSession->GetTimeProperty(propid);
			matched = (longVal == (long) testProp->GetTime());
			::MTFormatTime(longVal, printableValue);
			::MTFormatTime((long) testProp->GetTime(), printableExpected);
			mLogger.LogVarArgs(LOG_DEBUG, "value = %s expected %s", printableValue,
												 printableExpected);
			break;
		case ValType::TYPE_BOOLEAN:
			booleanVal = (aSession->GetBoolProperty(propid) == VARIANT_TRUE) ? true : false;
			matched = (booleanVal == (testProp->GetBool() ? true : false));
			mLogger.LogVarArgs(LOG_DEBUG, "value = %s expected %s",
												 (booleanVal ? "true" : "false"),
												 (testProp->GetBool() ? "true" : "false"));
			break;
		case ValType::TYPE_ENUM:
			longVal = aSession->GetEnumProperty(propid);
			matched = (longVal == testProp->GetEnum());
			mLogger.LogVarArgs(LOG_DEBUG, "value = %ld expected %ld", longVal, testProp->GetEnum());
			break;
		default:
			mLogger.LogVarArgs(LOG_ERROR, "Unknown prop type for %s", (const char *) name.c_str());
			matched = FALSE;
			break;
		}

		if (!matched)
		{
			testPassed = FALSE;
			mLogger.LogVarArgs(LOG_ERROR, "Mismatch: %s", (const char *) name.c_str());
			SetError(PIPE_ERR_AUTOTEST_OUTPUT_MISMATCH, ERROR_MODULE, ERROR_LINE, functionName,
							 name.c_str());
		}
		else
			mLogger.LogVarArgs(LOG_DEBUG, "Match: %s", (const char *) name.c_str());
	}
	return testPassed;
}

