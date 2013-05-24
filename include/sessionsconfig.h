/**************************************************************************
 * @doc SESSIONSCONFIG
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
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | SESSIONSCONFIG
 ***************************************************************************/

#ifndef _SESSIONSCONFIG_H
#define _SESSIONSCONFIG_H

#include <errobj.h>

#include <xmlconfig.h>

#if defined(DEFINING_CONFIGREADERS) && !defined(DLL_EXPORT_READERS) 
#define DLL_EXPORT_READERS __declspec( dllexport )
#else
#define DLL_EXPORT_READERS //__declspec( dllimport )
#endif


/*
 * tags used to read the file of sessions
 */

#define TEST_SESSION_TAG_SESSION "session"
#define TEST_SESSION_TAG_SERVICENAME "ServiceName"
#define TEST_SESSION_TAG_AUTHUSERNAME "AuthUserName"
#define TEST_SESSION_TAG_AUTHPASSWORD "AuthPassword"
#define TEST_SESSION_TAG_AUTHNAMESPACE "AuthNamespace"
#define TEST_SESSION_TAG_AUTHCONTEXT "AuthContext"
#define TEST_SESSION_TAG_SERIALIZECONTEXT "SerializeContext"
#define TEST_SESSION_TAG_SERVICEID "ServiceID"
#define TEST_SESSION_TAG_SESSIONID "SessionID"
#define TEST_SESSION_TAG_INPUTS "inputs"
#define TEST_SESSION_TAG_OUTPUTS "outputs"

/************************************************** TestProp ***/

typedef XMLConfigNameVal TestProp;
class TestSession;

typedef list<TestProp *> TestPropList;
typedef list<TestSession *> TestSessionList;

template void destroyPtr(TestProp *);
template void destroyPtr(TestSession *);

/*********************************************** TestSession ***/

class TestSession
{
	friend class TestSessionsReader;
public:
	DLL_EXPORT_READERS
	TestSession();

	TestSession(const TestSession & arTest)
	{
		*this = arTest;
	}

	//DLL_EXPORT_READERS
	//TestSession(IMTConfigPropSetPtr aProps);

	DLL_EXPORT_READERS
	virtual ~TestSession();

	BOOL operator == (const TestSession & arTest) const
	{
		return (mServiceID == arTest.mServiceID
						&& mSessionID == arTest.mSessionID) ? TRUE : FALSE;
	}

	int GetServiceID() const
	{ return mServiceID; }

	const std::string & GetServiceName() const
	{ return mServiceName; }

	const std::string & GetSessionID() const
	{ return mSessionID; }

	TestPropList & GetInputProps()
	{ return mInputProps; }

	TestPropList & GetOutputProps()
	{ return mOutputProps; }

	TestSessionList & GetSubSessions()
	{ return mSubSessions; }

private:
	TestSessionList mSubSessions;
	int mServiceID;
	std::string mServiceName;
	std::string mSessionID;
	TestPropList mInputProps;
	TestPropList mOutputProps;
};

/*********************************************** TestSession ***/

class TestSessions
{
	friend class TestSessionsReader;

public:
	TestSessions()
		: mSerializeContext(FALSE)
	{ }
		
	virtual ~TestSessions()
	{
		for_each(mTestSessions.begin(), mTestSessions.end(), destroyPtr<TestSession>);
	}

	void AddTestSession(TestSession * apSession)
	{ mTestSessions.push_back(apSession); }

	TestSessionList & GetTestSessions()
	{ return mTestSessions; }

	// authentication information
	const std::string & GetAuthUsername() const
	{ return mAuthUsername; }

	const std::string & GetAuthPassword() const
	{ return mAuthPassword; }

	const std::string & GetAuthNamespace() const
	{ return mAuthNamespace; }

	const std::string & GetAuthContext() const
	{ return mAuthContext; }

	BOOL GetSerializeContext() const
	{ return mSerializeContext; }

	void SetAuthUsername(const char * apUsername)
	{ mAuthUsername = apUsername; }

	void SetAuthPassword(const char * apPassword)
	{ mAuthPassword = apPassword; }

	void SetAuthNamespace(const char * apNamespace)
	{ mAuthNamespace = apNamespace; }

	void SetAuthContext(const char * apContext)
	{ mAuthContext = apContext; }

	void SetSerializeContext(BOOL aSerialize)
	{ mSerializeContext = aSerialize; }

private:
	TestSessionList mTestSessions;

	std::string mAuthUsername;
	std::string mAuthPassword;
	std::string mAuthNamespace;
	std::string mAuthContext;
	BOOL mSerializeContext;
};

class TestSessionsReader : public virtual ObjectWithError
{
public:
	DLL_EXPORT_READERS
	TestSession * ReadTestSession(XMLConfigPropSet & arSession);

	DLL_EXPORT_READERS
	BOOL ReadConfiguration(const char * apFilename,
												 TestSessions & arSessions);

	DLL_EXPORT_READERS
	BOOL ReadConfiguration(XMLConfigParser & arParser,
												 const char * apFilename,
												 TestSessions & arSessions);

	DLL_EXPORT_READERS
	BOOL ReadConfiguration(XMLConfigPropSet & arPropset,
												 TestSessions & arSessions);

private:
	static BOOL ReadPropList(XMLConfigPropSet & arInputs, TestPropList & arPropList);
};

#endif /* _SESSIONSCONFIG_H */
