/**************************************************************************
 * @doc MTOBSERVER
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
 * @index | MTOBSERVER
 ***************************************************************************/

#ifndef _MTOBSERVER_H
#define _MTOBSERVER_H

#include <NTThreadLock.h>
#include <list>

using std::list;

/********************************************** MTObservable ***/

template<class OBSERVER, class ARG>
class MTObservable
{
public:
	MTObservable();
	virtual ~MTObservable() { }

	void AddObserver(OBSERVER & arObserver);
	int CountObservers() const;
	void RemoveObservers();
	void RemoveObserver(OBSERVER & arObserver);
	BOOL HasChanged() const;
	void NotifyObservers();
	void NotifyObservers(ARG * apArg);

protected:
	void ClearChanged();
	void SetChanged();
private:
	typedef list<OBSERVER *> MTObserverList;

	MTObserverList mObserverList;
	mutable NTThreadLock mListLock;

	BOOL mHasChanged;
};


/********************************************** MTObservable ***/

template<class OBSERVER, class ARG>
MTObservable<OBSERVER,ARG>::MTObservable()
	: mHasChanged(FALSE)
{ }

template<class OBSERVER, class ARG>
void MTObservable<OBSERVER, ARG>::AddObserver(OBSERVER & arObserver)
{
	mListLock.Lock();
	// NOTE: if the observer already exists it will be added again
	mObserverList.push_back(&arObserver);
	mListLock.Unlock();
}

template<class OBSERVER, class ARG>
int MTObservable<OBSERVER, ARG>::CountObservers() const
{
	int count;
	mListLock.Lock();
	count = mObserverList.size();
	mListLock.Unlock();

	return count;
}

template<class OBSERVER, class ARG>
void MTObservable<OBSERVER, ARG>::RemoveObservers()
{
	mListLock.Lock();
	mObserverList.clear();
	mListLock.Unlock();
}

template<class OBSERVER, class ARG>
void MTObservable<OBSERVER, ARG>::RemoveObserver(OBSERVER & arObserver)
{
	mListLock.Lock();
	mObserverList.remove(&arObserver);
	mListLock.Unlock();
}

template<class OBSERVER, class ARG>
void MTObservable<OBSERVER, ARG>::NotifyObservers()
{
	NotifyObservers(NULL);
}

template<class OBSERVER, class ARG>
void MTObservable<OBSERVER, ARG>::NotifyObservers(ARG * arg)
{
	// do nothing if nothing has changed
	if (!HasChanged())
		return;

	mListLock.Lock();

	// tell each observer in the list about the change
	MTObserverList::iterator it;
	for (it = mObserverList.begin(); it != mObserverList.end(); ++it)
	{
		OBSERVER * observer = *it;
		ASSERT(observer);
		observer->Update(*this, arg);
	}

	mListLock.Unlock();
}

template<class OBSERVER, class ARG>
BOOL MTObservable<OBSERVER, ARG>::HasChanged() const
{
	return mHasChanged;
}

template<class OBSERVER, class ARG>
void MTObservable<OBSERVER, ARG>::ClearChanged()
{
	mHasChanged = FALSE;
}

template<class OBSERVER, class ARG>
void MTObservable<OBSERVER, ARG>::SetChanged()
{
	mHasChanged = TRUE;
}



#endif /* _MTOBSERVER_H */
