/**************************************************************************
 * @doc AUTOSDKLIB
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
 ***************************************************************************/


#include <metra.h>
#include <autosdklib.h>

#include <threadtest.h>
#include <MTUtil.h>
#include <MTDec.h>

#ifdef WIN32
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTPipelineLibExt.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#include <mtprogids.h>
#include <mtcom.h>
#include <mtcomerr.h>
#endif

#include <sessionsconfig.h>

#include <iostream>
using std::cout;
using std::endl;
using std::cerr;
using std::hex;
using std::dec;
//using namespace std;

int AutoSDKBase::SimpleTest(int argc, char * * argv)
{
	mVerbose = TRUE;

	if (!Setup(argc, argv) || !Test())
		return -1;
	else
		return 0;
}

BOOL
AutoSDKBase::Setup(int argc, char** argv)
{
	if (!ConfigureSDK(argc, argv))
		return FALSE;

	ASSERT(mTestFilename.length() > 0);
	if (!ReadTestSetup(mTestFilename.c_str()))
		return FALSE;

	return TRUE;
}


BOOL
AutoSDKBase::Test()
{
#if 0
#ifdef WIN32
	mLock.Lock();
#endif // WIN32
#endif

	BOOL success = TRUE;

	TestSessionList & list = mTestSessions.GetTestSessions();
	TestSessionList::iterator sessit;
	for (sessit = list.begin(); sessit != list.end(); ++sessit)
	{
		TestSession * test = *sessit;

		MTMeterSession * session = CreateTestSession(NULL, *test);
		if (!session)
		{
			success = FALSE;
			break;
		}
		
		// if any outputs are specified, request output properties
		// to see if they match
		TestPropList & outputs = test->GetOutputProps();
		BOOL getFeedback = (outputs.size() > 0);

    //CR 7320, BP:
    //support sync metering on sessions within the set
    if (getFeedback)
    {
		  if (mVerbose) 
        cout << "Requesting session feedback..." << endl;
			 session->SetResultRequestFlag(); 
    }

		// send the session to the server
		if (mInBatches > 0)
		{
			if (mInCurrentBatch == mInBatches)
			{
       if (mVerbose)
    			cout << "Closing session set..." << endl;
				mInCurrentBatch = 0;
				ASSERT(mpBatch);
				if (!mpBatch->Close())
				{
					MTMeterError * err = mpBatch->GetLastErrorObject();
					PrintError("Unable to close SessionSet", err);
					success = FALSE;
					break;
				}
				delete mpBatch;
				mpBatch = NULL;
			}
		}
		else
		{
      if (mVerbose)
  			cout << "Closing session..." << endl;
			// send the session to the server
			if (!session->Close())
			{
				MTMeterError * err = session->GetLastErrorObject();
				delete session;
				PrintError("Unable to close session", err);
				delete err;

				//return -1; // DY
				success = FALSE;
				break;
			}

			if (mVerbose)
				cout << "Session closed." << endl;
		}

		if (mInBatches == 0 && getFeedback)
		{
			MTMeterSession * results = session->GetSessionResults();
			if (!results)
			{
				cout << "Output session expected, but not found!" << endl;
				success = FALSE;
			}
			else
			{
				if (ValidateSessionResults(results, outputs))
					cout << "All output properties match" << endl;
				else
				{
					cout << "Output property mismatch" << endl;
					success = FALSE;
				}
			}
		}

		if (mInBatches == 0)
		{
			// sessions created with CreateSession must be deleted.
			delete session;
		}
	}

#if 0
#ifdef WIN32
	mLock.Unlock();
#endif // WIN32
#endif

	return success;
}

BOOL AutoSDKBase::ValidateSessionResults(MTMeterSession * apResults,
																		 TestPropList & arOutputs)
{
	TestPropList::iterator it;
	for (it = arOutputs.begin(); it != arOutputs.end(); ++it)
	{
		TestProp * testProp = *it;

		const string & name = testProp->GetName();

		ValType::Type type = testProp->GetPropType();

		if (mVerbose)
			cout << " Testing property " << name << endl;


		int testInt;
		__int64 testInt64;
		double testDouble;
		const char * testString = NULL;
		time_t testTime;
		BOOL testBoolean;
		const MTDecimalValue * testDecimal;
		MTDecimal decimalHolder;

		BOOL status;
		BOOL match;
		switch (type)
		{
		case ValType::TYPE_INTEGER:
			status = apResults->GetProperty(name.c_str(), testInt);
			match = status && (testInt == testProp->GetInt());
			if (status && !match)
			{
				cout << "value = " << testInt << " expected " << testProp->GetInt() << endl;
			}
			break;
		case ValType::TYPE_BIGINTEGER:
			status = apResults->GetProperty(name.c_str(), testInt64, MTMeterSession::SDK_PROPTYPE_BIGINTEGER);
			match = status && (testInt64 == testProp->GetBigInt());
			if (status && !match)
			{
				cout << "value = " << testInt64 << " expected " << testProp->GetBigInt() << endl;
			}
			break;
		case ValType::TYPE_DOUBLE:
			status = apResults->GetProperty(name.c_str(), testDouble);
			match = status && (testDouble == testProp->GetDouble());
			if (status && !match)
			{
				cout << "value = " << testDouble << " expected " << testProp->GetDouble() << endl;
			}
			break;
		case ValType::TYPE_STRING:
			status = apResults->GetProperty(name.c_str(), &testString);
			match = status && (0 == strcmp(testString, ascii(testProp->GetString()).c_str()));
			if (status && !match)
			{
				cout << "value = \"" << testString << "\" expected \""
						 << ascii(testProp->GetString()) << "\"" << endl;
			}
			break;
		case ValType::TYPE_DATETIME:
			status = apResults->GetProperty(name.c_str(), testTime, MTMeterSession::SDK_PROPTYPE_DATETIME);
			match = status && (testTime == testProp->GetDateTime());
			if (status && !match)
			{
				std::string printableValue;
				::MTFormatISOTime(testTime, printableValue);
				cout << "value = " << printableValue << " expected ";
				time_t testPropVal = testProp->GetDateTime();
				::MTFormatISOTime(testPropVal, printableValue);
				cout << printableValue << endl;
			}
			break;
		case ValType::TYPE_BOOLEAN:
			status = apResults->GetProperty(name.c_str(), testBoolean, MTMeterSession::SDK_PROPTYPE_BOOLEAN);
			match = status && (testBoolean == testProp->GetBool());
			if (status && !match)
			{
				cout << "value = " << (testBoolean ? "TRUE" : "FALSE") << " expected ";
				cout << (testProp->GetBool() ? "TRUE" : "FALSE") << endl;
			}
			break;
		case ValType::TYPE_DECIMAL:
		{
			status = apResults->GetProperty(name.c_str(), &testDecimal);
			MTDecimal decimalHolder(*(testDecimal->mpDecimalVal));
			match = status && (decimalHolder == testProp->GetDecimal());
			MTDecimal propHolder(testProp->GetDecimal());
			if (status && !match)
			{
				cout << "value = " << decimalHolder.Format() << " expected ";
				cout << propHolder.Format() << endl;
			}
			break;
		}

		case ValType::TYPE_TIME:
		default:
			cout << "Unknown prop type for " << name << endl;
			break;
		}

		if (!status)
		{
			cout << "Property " << name << " doesn't exist or has an invalid type." << endl;
			return FALSE;
		}
		if (!match)
		{
			cout << "Value of output property " << name << " doesn't match expected value."
					 << endl;
			return FALSE;
		}
	}

	return TRUE;
}

BOOL AutoSDKBase::SetContext(MTMeterSessionSet * apSessionSet,
														 const char * apUsername,
														 const char * apPassword,
														 const char * apNamespace,
														 const char * apContext,
														 BOOL aSerialize)
{
	const char * functionName = "AutoSDKBase::SetContext";

	BOOL success = TRUE;
	if (apContext && strlen(apContext) > 0)
	{
		// we have the context already serialized
		apSessionSet->SetSessionContext(apContext);
	}
	else if (!aSerialize)
	{
		apSessionSet->SetSessionContextUserName(mTestSessions.GetAuthUsername().c_str());
		apSessionSet->SetSessionContextPassword(mTestSessions.GetAuthPassword().c_str());
		apSessionSet->SetSessionContextNamespace(mTestSessions.GetAuthNamespace().c_str());
	}
	else
	{
#ifdef WIN32
		ComInitialize cominit;

		try
		{
			MTPipelineLibExt::IMTLoginContextPtr loginCtx(MTPROGID_MTLOGINCONTEXT);
			MTPipelineLibExt::IMTSessionContextPtr ctx = loginCtx->Login(mTestSessions.GetAuthUsername().c_str(),
																																mTestSessions.GetAuthNamespace().c_str(),
																																mTestSessions.GetAuthPassword().c_str());
																																
			_bstr_t base64 = ctx->ToXML();
			apSessionSet->SetSessionContext(base64);
		}
		catch (_com_error & err)
		{
			std::string buffer;
			StringFromComError(buffer, "Unable to set session context", err);
			success = FALSE;
		}
#else
		// no supported on unix
		ASSERT(0);
#endif
	}

	if (!success)
		// TODO: better error info
		return FALSE;
	return TRUE;
}


MTMeterSession * AutoSDKBase::CreateTestSession(MTMeterSession * apParent,
																								TestSession & arSession)
{
	if (mVerbose)
		cout << "Session has service name " << arSession.GetServiceName() << endl;

	MTMeter & meter = GetMeter();

	MTMeterSession * session;
	if (apParent)
		session = apParent->CreateChildSession(arSession.GetServiceName().c_str());
	else
	{
		if (mInBatches > 0)
		{
			if (!mpBatch)
			{
				mpBatch = meter.CreateSessionSet();

				if (mTestSessions.GetAuthUsername().length() > 0
					|| mTestSessions.GetAuthContext().length() > 0)
				{
					if (!SetContext(mpBatch, 
													mTestSessions.GetAuthUsername().c_str(),
													mTestSessions.GetAuthPassword().c_str(),
													mTestSessions.GetAuthNamespace().c_str(),
													mTestSessions.GetAuthContext().c_str(),
													mTestSessions.GetSerializeContext()))
					{
						return NULL;
					}
				}
				ASSERT(mpBatch);
			}
			session = mpBatch->CreateSession(arSession.GetServiceName().c_str());
			mInCurrentBatch++;
		}
		else
		{
			session = meter.CreateSession(arSession.GetServiceName().c_str());
		}
	}

	if (!session)
		return NULL;

	// if the file wants to override the UID, do it.
	// NOTE: use this functionality with caution!
	if (arSession.GetSessionID().length() > 0)
		MTSetSessionIDEx(session, arSession.GetSessionID().c_str());

	// now set properties listed in the file
	TestPropList & inputs = arSession.GetInputProps();

	TestPropList::iterator it;
	for (it = inputs.begin(); it != inputs.end(); ++it)
	{
		TestProp * testProp = *it;

		const string & name = testProp->GetName();

		if (mVerbose)
			cout << " Setting property " << name << endl;

		BOOL status;
		switch (testProp->GetPropType())
		{
		case ValType::TYPE_INTEGER:
			status = session->InitProperty(name.c_str(), testProp->GetInt());
			break;
		case ValType::TYPE_BIGINTEGER:
			status = session->InitProperty(name.c_str(), testProp->GetBigInt(),
                                     MTMeterSession::SDK_PROPTYPE_BIGINTEGER);
			break;
		case ValType::TYPE_DOUBLE:
			status = session->InitProperty(name.c_str(), testProp->GetDouble());
			break;
		case ValType::TYPE_DECIMAL:
			status = session->InitProperty(name.c_str(), &MTDecimalValue(&testProp->GetDecimal(), FALSE));
			break;
		case ValType::TYPE_STRING:
			//status = session->InitProperty(name, testProp->GetString().toAscii());
			status = session->InitProperty(name.c_str(), testProp->GetString().c_str());
			break;
		case ValType::TYPE_DATETIME:
			status = session->InitProperty(name.c_str(), testProp->GetDateTime(),
                                     MTMeterSession::SDK_PROPTYPE_DATETIME);
			break;

		case ValType::TYPE_BOOLEAN:
			status = session->InitProperty(name.c_str(), testProp->GetBool(),
																		 MTMeterSession::SDK_PROPTYPE_BOOLEAN);
			break;

		case ValType::TYPE_TIME:
		default:
			cout << "Unknown prop type for " << name << endl;
			break;
		}

		if (!status)
		{
			MTMeterError * err = session->GetLastErrorObject();
			PrintError("Error setting property ", err);
			delete err;
			return NULL;
		}
	}

	TestSessionList & sub = arSession.GetSubSessions();
	TestSessionList::iterator childit;
	for (childit = sub.begin(); childit != sub.end(); ++childit)
	{
		TestSession * test = *childit;

		if (mVerbose)
			cout << "Creating child session..." << endl;
		TestSession * subsession = *childit;
		MTMeterSession * childtest = CreateTestSession(session, *subsession);
		if (!childtest)
		{
			// TODO: is this OK to do?
			delete session;
			return NULL;
		}
	}

	return session;
}


BOOL AutoSDKBase::ReadTestSetup(const char * apTestFile)
{
	TestSessionsReader testReader;

	BOOL success = FALSE;

	string fullTestPath;
	char * rootDir = ::getenv("ROOTDIR");
	if (rootDir && *rootDir)
	{
		fullTestPath = rootDir;
		fullTestPath += "\\test\\autosdk\\";
		fullTestPath += apTestFile;

		success = testReader.ReadConfiguration(fullTestPath.c_str(), mTestSessions);
	}

	if (!success && !testReader.ReadConfiguration(apTestFile, mTestSessions))
	{
		cout << "Unable to read test configuration " << apTestFile << endl;

		const ErrorObject * obj = testReader.GetLastError();
		if (obj)
			cout << "Details: " << obj->GetProgrammerDetail().c_str();

		success = FALSE;
	}
	else
		success = TRUE;

	if (success)
	{
		if (mTestSessions.GetTestSessions().size() > 1)
			mInBatches = mTestSessions.GetTestSessions().size();

		// if authentication info is present we must meter in batches
		if ((mTestSessions.GetAuthUsername().length() > 0
				|| mTestSessions.GetAuthContext().length() > 0) && mInBatches == 0)
			mInBatches = 1;
	}

	return success;
}

void AutoSDKBase::PrintError(const char * prefix, const MTMeterError * err)
{
	cerr << prefix << ": ";
	if (err)
	{
		int size = 0;
		err->GetErrorMessage((char *) NULL, size);
		char * msgbuf = new char[size + 1];
		err->GetErrorMessage(msgbuf, size);

		size = 0;
		err->GetErrorMessageEx((char *) NULL, size);
		char * msgexbuf = new char[size];
		err->GetErrorMessageEx(msgexbuf, size);

		cerr << hex << err->GetErrorCode() << dec << ": "
				 << msgbuf << ": " << msgexbuf << endl;

		delete [] msgbuf;
		delete [] msgexbuf;
	}
	else
		cerr << "*UNKNOWN ERROR*" << endl;
}

BOOL AutoSDKRaw::ReadAutoSdkFile(const char* pFileName)
{
	ASSERT(pFileName);
	if(!pFileName) return FALSE;

	TestSessionsReader testReader;
	if (testReader.ReadConfiguration(pFileName, mTestSessions)) {
		return TRUE;	
	}

	SetError(testReader.GetLastError());
	return FALSE;
}

BOOL AutoSDKRaw::Execute()
{
	static const char* pFuncName = "AutoSDKRaw::Execute()";
	BOOL success = TRUE;

	TestSessionList & list = mTestSessions.GetTestSessions();

	TestSessionList::iterator sessit;
	for (sessit = list.begin(); sessit != list.end(); ++sessit)
	{
		TestSession * test = *sessit;

		MTMeterSession * session = CreateTestSession(NULL, *test);
		if (!session)
		{
			success = FALSE;
			break;
		}

		// if any outputs are specified, request output properties
		// to see if they match
		TestPropList & outputs = test->GetOutputProps();
		BOOL getFeedback = (outputs.size() > 0);
		if (getFeedback)
		{
			session->SetResultRequestFlag();
		}

		// send the session to the server
		if (mInBatches > 0)
		{
			if (mInCurrentBatch == mInBatches)
			{
				mInCurrentBatch = 0;
				ASSERT(mpBatch);
				if (!mpBatch->Close())
				{
					// TODO: error handling here
					cout << "ERROR CLOSING SESSIONSET" << endl;
				}
				delete mpBatch;
				mpBatch = NULL;
			}
		}
		else
		{
			if (!session->Close())
			{
				MTMeterError * err = session->GetLastErrorObject();
				char buff[1024];
				int abuffersize = 1024;
				err->GetErrorMessage(buff,abuffersize);
				delete session;
				SetError(FALSE,ERROR_MODULE, ERROR_LINE,pFuncName,buff);
				delete err;

				//return -1; // DY
				success = FALSE;
				break;
			}

			if (getFeedback)
			{
				MTMeterSession * results = session->GetSessionResults();
				if (!results)
				{
					SetError(FALSE,ERROR_MODULE, ERROR_LINE,pFuncName,"Output session expected, but not found!");
					success = FALSE;
				}
				else
				{
					if (!ValidateSessionResults(results, outputs))
					{
						SetError(FALSE,ERROR_MODULE, ERROR_LINE,pFuncName,"Output property mismatch");
						success = FALSE;
					}
					// the session returned must be deleted.  It belongs to us
					delete results;
				}
			}
			// sessions created with CreateSession must be deleted.
			delete session;
		}
	}

#if 0
#ifdef WIN32
	mLock.Unlock();
#endif // WIN32
#endif

	return success;


}

