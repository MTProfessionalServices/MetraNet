/**************************************************************************
 * @doc STAGEINFO
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
 * @index | STAGEINFO
 ***************************************************************************/

#ifndef _STAGEINFO_H
#define _STAGEINFO_H

#include <autosessiontest.h>
#include <errobj.h>
#include <list>
#include <string>

using std::list;
using std::string;

/************************************************* StageInfo ***/

class StageInfo : public virtual ObjectWithError
{
	friend class StageInfoReader;
public:
	StageInfo()
	{ }
	virtual ~StageInfo()
	{ Clear(); }

	// clear all internal data structures
	virtual void Clear()
	{
		// these don't really need to be cleared but it doesn't hurt
		mNextStage.resize(0);
		mName.resize(0);
	}

	const std::string & GetName() const
	{ return mName; }

	const std::string & GetNextStageName() const
	{ return mNextStage; }

	BOOL IsFinalStage() const
	{ return mFinalStage; }

	BOOL IsStartStage() const
	{ return mStartStage; }

	// by default, the dependencies are ignored.  This enables
	// other code to get the stage info without having to provide
	// code to read the dependencies
	virtual BOOL ReadDependencies(MTPipelineLib::IMTConfigPropSetPtr & /* arDependencies */)
	{ return TRUE; }

	// maximum number of sessions that will be placed in a set before
	// processing begins
	BOOL GetMaxSetSize() const
	{ return mMaxSetSize; }

	// maximum amount of time to wait for a session before processing begins
	BOOL GetMaxWaitTime() const
	{ return mMaxWaitTime; }

	// machine to optionally route from
	const std::string & GetRouteFromMachine() const
	{ return mRouteFromMachine; }

	// queue to optionally route from
	const std::string & GetRouteFromQueue() const
	{ return mRouteFromQueue; }

	void SetRouteFromQueue(const char * apQueue)
	{ mRouteFromQueue = apQueue; }

	// return TRUE if this stage routes messages from listeners
	BOOL RoutesMessages() const
	{ return (mRouteFromQueue.length() > 0); }

protected:
	int mVersion;
	std::string mName;
	std::string mFullPathXml;

	BOOL mStartStage;
	BOOL mFinalStage;
	std::string mNextStage;

	//
	// stage autotests
	//

	// list of files to run autotests agains
	PipelineAutoTest::AutoTestList mAutoTestList;

	//
	// routing info
	//
	std::string mRouteFromMachine;
	std::string mRouteFromQueue;

	int mMaxSetSize;
	int mMaxWaitTime;
};

#endif /* _STAGEINFO_H */
