/**************************************************************************
 * @doc AUTOSDK
 *
 * @module |
 *
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
 *
 * @index | AUTOSDK
 ***************************************************************************/

#ifndef _AUTOSDK_H
#define _AUTOSDK_H

/*
 * UNIX TODO:
 *
 * implement locking?
 */

#ifdef WIN32
#include <NTThreadLock.h>
#endif // WIN32

#include <mtsdk.h>
#include <mtsdkex.h>

#include <threadtest.h>

#include <sessionsconfig.h>
#include <errobj.h>

class AutoSDKBase : public ThreadTest
{
public:
	AutoSDKBase(int aThreads, int aSerialCount, int aParallelCount, BOOL aSSL)
	  : ThreadTest(aThreads, aSerialCount, aParallelCount),
			mVerbose(FALSE),
			mSSL(aSSL),
			mpBatch(NULL), mInBatches(0), mInCurrentBatch(0)
	{ }

	AutoSDKBase(BOOL aSSL = FALSE)
	  : ThreadTest(0, 0, 0),
			mVerbose(FALSE),
			mSSL(aSSL),
			mpBatch(NULL), mInBatches(0), mInCurrentBatch(0)
	{ }

	int SimpleTest(int argc, char * * argv);
	void PrintError(const char * prefix, const MTMeterError * err);


	void SetBatchSize(int aSize)
	{
		mInBatches = aSize;
		mInCurrentBatch = 0;
	}

protected:
	virtual BOOL Test();
	virtual BOOL Setup(int argc, char ** argv);

	BOOL ReadTestSetup(const char * apTestFile);

	MTMeterSession * CreateTestSession(MTMeterSession * apParent,
																		 TestSession & arSession);

	BOOL ValidateSessionResults(MTMeterSession * apResults,
															TestPropList & arOutputs);

	virtual MTMeter & GetMeter() = 0;
	virtual MTMeterConfig & GetMeterConfig() = 0;

	// set mTestFilename and configure the SDK objects appropriately
	virtual BOOL ConfigureSDK(int argc, char * argv[]) = 0;

	BOOL SetContext(MTMeterSessionSet * apSessionSet,
									const char * apAuthContext,
									const char * apUsername,
									const char * apPassword,
									const char * apNamespace,
									BOOL aSerialize);

protected:
	std::string mTestFilename;

	BOOL mSSL;

	TestSessions mTestSessions;

	int mInBatches;
	int mInCurrentBatch;

	MTMeterSessionSet * mpBatch;

#ifdef WIN32
	NTThreadLock mLock;
#endif // WIN32

	BOOL mVerbose;
};

class AutoSDKRaw : public AutoSDKBase,
	public virtual ObjectWithError

{
public:
	AutoSDKRaw(int aThreads, int aSerialCount, int aParallelCount, BOOL aSSL) : 
			AutoSDKBase(aThreads,aSerialCount,aParallelCount,aSSL) 
		{
		mVerbose = FALSE;
			
		}
	BOOL ReadAutoSdkFile(const char* pFileName);
	BOOL Execute();

};

#endif /* _AUTOSDK_H */
