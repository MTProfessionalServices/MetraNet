/**************************************************************************
 * @doc AUTOSESSIONTEST
 *
 * @module |
 *
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
 *
 * @index | AUTOSESSIONTEST
 ***************************************************************************/

#ifndef _AUTOSESSIONTEST_H
#define _AUTOSESSIONTEST_H

#include <NTLogger.h>
#include <sessionsconfig.h>
#include <list>
#include <string>

using std::list;
using std::string;

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

class PipelineAutoTest : public virtual ObjectWithError
{
public:
	typedef std::list<string> AutoTestList;

	//
	// primary interface
	// 

	// initialize the object
	BOOL Init();

	// read a list of test session files
	BOOL ReadAutoTest(MTPipelineLib::IMTConfigPtr aConfig,
										const AutoTestList & arTestList,
										TestSessions & arTestSessions,
										const char * apConfigDir, const char * apStageName);

	// run all auto tests
	BOOL RunAutoTest(MTPipelineLib::IMTNameIDPtr aNameID,
									 MTPipelineLib::IMTSessionServerPtr aSessionServer,
									 TestSessions & arTestSessions);

public:
	//
	// lower level interface
	//

	// read a test session file
	BOOL ReadTestSetup(MTPipelineLib::IMTConfigPtr aConfig,
										 TestSessions & arTestSessions,
										 const char * apTestFile);

	// verify the output properties
	BOOL TestOutputProps(MTPipelineLib::IMTNameIDPtr aNameID,
											 MTPipelineLib::IMTSessionPtr aSession,
											 TestSession & arSession);

	// generate a populated test session
	MTPipelineLib::IMTSessionPtr
	CreateTestSession(MTPipelineLib::IMTNameIDPtr aNameID,
										MTPipelineLib::IMTSessionServerPtr aSessionServer,
										TestSession & arSession,
										MTPipelineLib::IMTSessionPtr aParentSession);


public:
	//
	// since any errors have to be set on this object, the ObjectWithError
	// methods must be made public.
	//
	void SetError(const ErrorObject * apError)
	{ ObjectWithError::SetError(apError); }

	void SetError(const ObjectWithError & arObject)
	{ ObjectWithError::SetError(arObject); }

	void SetError(const ErrorObject * apError, const char *apDetail)
	{ ObjectWithError::SetError(apError, apDetail); }

	void SetError(ErrorObject::ErrorCode aCode,
				const char * apModule, int aLine, const char * apProcedure)
	{ ObjectWithError::SetError(aCode, apModule, aLine, apProcedure); }

	void SetError(ErrorObject::ErrorCode aCode, const char * apModule,
								int aLine, const char * apProcedure, const char * apDetail)
	{ ObjectWithError::SetError(aCode, apModule, aLine, apProcedure, apDetail); }


protected:
	// override to run the test.  The set contains one session set up
	// appropriately.
	virtual BOOL RunSession(PipelineAutoTest & arTest,
													MTPipelineLib::IMTSessionSetPtr aSet) = 0;

private:
	NTLogger mLogger;
};


#endif /* _AUTOSESSIONTEST_H */
