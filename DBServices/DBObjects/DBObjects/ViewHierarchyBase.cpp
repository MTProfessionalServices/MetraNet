/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/

#include <metra.h>
#include <DBViewHierarchy.h>

#include <DBInMemRowset.h>
#include <MTUtil.h>

#include <mtprogids.h>
#include <DBSummaryView.h>
#include <DBProductView.h>
#include <DBDiscountView.h>
#include <DBDataAnalysisView.h>
#include <DBConstants.h>
#include <DBSQLRowset.h>
#include <mtglobal_msg.h>

#include <loggerconfig.h>
#include <DBUsageCycle.h>
#include <mtcomerr.h>
#include <SetIterate.h>
#include <vector>
#include <stdutils.h>
#include <MTDec.h>
#include <ConfigDir.h>
#include <SetIterate.h>
#include <autocritical.h>


// statics
PCAccViewMap MTPCHierarchyColl::mAccountMap;
DWORD MTPCHierarchyColl::msNumRefs = 0;
MTPCHierarchyColl* MTPCHierarchyColl::mpsInstance = 0;
NTThreadLock MTPCHierarchyColl::mLock;
DBViewHierarchy* MTPCHierarchyColl::pXmlViewHierarchy = NULL;
PiToViewIDMap MTPCHierarchyColl::mPiToViewIDMap;


MTPCHierarchyColl* MTPCHierarchyColl::GetInstance()
{
    // local variables

	// enter the critical section
	mLock.Lock();

	// if the object does not exist..., create a new one
	if (mpsInstance == 0)
	{
	    mpsInstance = new MTPCHierarchyColl;
		if (!mpsInstance->Init())
		{
		  delete mpsInstance;
		  mpsInstance = 0;
		  return NULL;
		}
	}

	// if we got a valid pointer.. increment...
	if (mpsInstance != 0)
	{
	    msNumRefs++;
	}

	// leave the critical section...
	mLock.Unlock();

	return (mpsInstance);
}

void MTPCHierarchyColl::ReleaseInstance()
{
	// enter the critical section ...
	mLock.Lock();

	// decrement the reference counter
	if (mpsInstance != 0)
	{
		msNumRefs--;
		// assert here for 0 msNumRefs
	}

	// if the number of references is 0, delete the pointer
	if (msNumRefs == 0)
	{
		delete mpsInstance;
		mpsInstance = 0;
	}

	// leave the critical section ...
	mLock.Unlock();
}

MTautoptr<MTPCViewHierarchy> MTPCHierarchyColl::GetAccHierarchy(const long accountID,
																																const long intervalID,
																																const wchar_t* languageCode)
{
	AutoCriticalSection alock(&mLock);
	std::pair<long,long> MatchPair(accountID,intervalID);

	PCAccViewMap::iterator it = mAccountMap.find(MatchPair);
	if(it != mAccountMap.end()) {
		return mAccountMap[MatchPair];
	}
	else {
		MTPCViewHierarchy* pHierarchy = new MTPCViewHierarchy;
		if(!pHierarchy->Initialize(accountID,intervalID,languageCode)) {
			delete pHierarchy;
			// return NULL entry
			return MTautoptr<MTPCViewHierarchy>();
		}
		mAccountMap[MatchPair] = pHierarchy;
		return mAccountMap[MatchPair];
	}
}

BOOL MTPCHierarchyColl::Init()
{
	pXmlViewHierarchy = DBViewHierarchy::GetInstance();
	return TRUE;
}


MTPCHierarchyColl::~MTPCHierarchyColl()
{
	// release the XML view hierarchy
	pXmlViewHierarchy->ReleaseInstance();

	AutoCriticalSection alock(&mLock);
	PCAccViewMap::iterator it;
	for (it=mAccountMap.begin(); 
	it!=mAccountMap.end();
	it++) {
		(*it).second = NULL;
	}
	mAccountMap.clear();
}

void MTPCHierarchyColl::ClearEntry(long accountID,long intervalID)
{
	AutoCriticalSection alock(&mLock);
	std::pair<long,long> MatchPair(accountID,intervalID);
	mAccountMap.erase(MatchPair);
}


BOOL MTPCHierarchyColl::TranslateID(const long aViewID,long& aNewViewID)
{
	long tempInViewID = (aViewID < 0) ? -aViewID : aViewID;
	PiToViewIDMap::iterator it = mPiToViewIDMap.find(tempInViewID);
	if(it != mPiToViewIDMap.end()) {
		aNewViewID = (*it).second;
	}
	else {
		return FALSE;
	}
	return TRUE;
}

void MTPCHierarchyColl::AddInstanceIdMapping(const long instanceID,const long viewID)
{
	// only add mapping if instance ID is less than 0.  Note
	// this is probably inefficient
	if(instanceID < 0) {
		mPiToViewIDMap.insert(std::pair<long,long>(-instanceID,viewID));
	}
}

