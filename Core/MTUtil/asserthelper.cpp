/**************************************************************************
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
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 */


#include <metra.h>
#include <mtcom.h>
#ifdef _DEBUG

#import "MTConfigLib.tlb"

using namespace MTConfigLib;
#include <MTUtil.h>
#include <mtprogids.h>
#include <SharedDefs.h>
#include <loggerconfig.h>
#include <NTLogMacros.h>
#include <signal.h> // for raise
#include <asserthelper.h>

//
const char* WarningTag = "Warning: ";
const char* ErrorTag = "Error: ";
const char* AssertTag = "Assert: ";

MTAssertHelper* g_AssertHandler = 0;

extern _CRTIMP long _crtAssertBusy;

MTAssertHelper::~MTAssertHelper()
{
	if(m_NumAsserts > 0 && m_NumWarns > 0 && m_NumErrors > 0) {
		NTLogger myLogger;
		LoggerConfigReader cfgRdr;

		myLogger.Init(cfgRdr.ReadConfiguration(LISTENER_STR), LISTENER_TAG);
		myLogger.LogVarArgs (LOG_INFO,
			"Number of Asserts: %d\nNumber of Warnings: %d\n"
			"Number of errors: %d\n",m_NumAsserts,m_NumWarns,m_NumErrors);
	}
}

// set the default handling for asserts
// the arguments for this method is passed directly to _CrtSetReportMode.

void MTAssertHelper::Init(unsigned int aReportMode,const char* aTag,BOOL bStopOnError)
{
	ASSERT(aTag);
	g_AssertHandler = this;
	
	m_bStopOnError = bStopOnError;
	// we can't really do anything if these CRT calls fail.  Since this method
	// could be called by a staticly constructed object, we might not be able
	// to use the logging code.  At this time, the logging code below also has
	// problems with threading that causes a deadlock on startup.
	_CrtSetReportMode(_CRT_WARN,aReportMode);
	_CrtSetReportMode(_CRT_ERROR,aReportMode);
	_CrtSetReportMode(_CRT_ASSERT,aReportMode);

    // sdg the assert hook
    _CrtSetReportHook(DebugHook);

//	LoggerConfigReader cfgRdr ;
//	m_DebugLogger.Init(cfgRdr.ReadConfiguration(LISTENER_STR), LISTENER_TAG);
}

int MTAssertHelper::DebugHook(int reportType, char *message, int *returnValue)
{
	if(g_AssertHandler) {
		return g_AssertHandler->RealDebugHook(reportType,message,returnValue);
	}
	return FALSE;
}

int MTAssertHelper::RealDebugHook(int reportType, 
                                 char *message, 
                                 int *returnValue)
{
	std::string LogString;
	switch(reportType) {
	case _CRT_WARN:
		LogString = WarningTag;
		m_NumWarns++;
		break;
	case _CRT_ERROR:
		LogString = ErrorTag;
		m_NumErrors++;
		break;
	case _CRT_ASSERT:
		LogString = AssertTag;
		m_NumAsserts++;
		break;
	default:
		ASSERT(!"Bad reporttype");
	}
	LogString += message;

    // step 1: log the assert message
	MT_LOG_FATAL_STRING(LISTENER_STR,LISTENER_TAG,message);
	//m_DebugLogger.LogThis(LOG_DEBUG,message);

    // step 2: grab the stack and dump
	CONTEXT aContext;
	std::string DebugReport;

	if(MTStackTrace::CurrentContext(&aContext) && 
		MTStackTrace::GenerateExceptionReport(DebugReport,&aContext)) {
		MT_LOG_FATAL_STRING(LISTENER_STR,LISTENER_TAG,DebugReport.c_str());
		//m_DebugLogger.LogThis(LOG_DEBUG,DebugReport);
	}
	LogString += DebugReport;

	// decrement CRT semaphore; if we don't do this
	// _CrtDebugReport will think that we are asserting in the assertion
	// handling code or we have simulateous assertions in two different
	// threads.
	InterlockedDecrement(&_crtAssertBusy);

	ExitHandler(LogString);

	// returning FALSE causes _CrtDebugReport to be executed
	// setting *returnValue to true 
	*returnValue = TRUE;
	return TRUE;

}
// the default ExitHandler


void MTAssertHelper::ExitHandler(std::string& aDebugStr)
{
	if(m_bStopOnError) {
		// The VC CRT only aborts the program if CrtSetReportMode pops up a Message box instead of
		// logging to a file.  We must manually abort the program here.  Code stolen from
		// crtdbg.c.
		 raise(SIGABRT);
            /* We usually won't get here, but it's possible that
               SIGABRT was ignored.  So exit the program anyway. */
        _exit(3);
	}
}

#endif // _DEBUG
