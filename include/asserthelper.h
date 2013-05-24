/**************************************************************************
 * @doc ISAPI
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

#ifndef __ASSERT_HELPER_H_
#define __ASSERT_HELPER_H_

// only for DEBUG builds

#include <errobj.h>
#include <NTLogger.h>

// this class wraps _CrtSetReportMode

class MTAssertHelper : public virtual ObjectWithError
{
private:
    MTAssertHelper(const MTAssertHelper&);
    MTAssertHelper& operator=(const MTAssertHelper&);
public:
    MTAssertHelper() : m_NumAsserts(0), m_NumWarns(0), m_NumErrors(0), m_bStopOnError(TRUE) {}
    MTAssertHelper(unsigned int aReportMode,const char* aTag, BOOL bStopOnError=TRUE)
	{ Init(aReportMode,aTag,bStopOnError);  } 
    virtual ~MTAssertHelper();

	void Init(unsigned int,const char*,BOOL = TRUE);
	int RealDebugHook(int reportType, char *message, int *returnValue);
	virtual void ExitHandler(std::string&);

	// statics
    static int DebugHook(int reportType, char *message, int *returnValue);

protected:
    unsigned int m_NumAsserts;
    unsigned int m_NumWarns;
    unsigned int m_NumErrors;
	BOOL	m_bStopOnError;
private:
	NTLogger m_DebugLogger;
};

#ifdef _DEBUG
#define ASSERT_HELPER(a) (MTAssertHelper a)
#define DERIVED_ASSERT_HELPER(a,b) a b
#define ASSERT_HELPER_FUNC(a,b) a.b
#else // RELEASE
#define ASSERT_HELPER(a)
#define DERIVED_ASSERT_HELPER(a,b)
#define ASSERT_HELPER_FUNC(a,b)
#endif // DEBUG


#endif // __ASSERT_HELPER_H_