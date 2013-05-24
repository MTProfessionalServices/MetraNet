/**************************************************************************
 * @doc MTOBSERVER
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
#include <observedevent.h>
#include <makeunique.h>

/***************************************** ObservedEvent ***/

ObservedEvent::ObservedEvent()
	: mObservedEvent(NULL)
{ }

ObservedEvent::~ObservedEvent()
{
	if (mObservedEvent)
	{
		::CloseHandle(mObservedEvent);
		mObservedEvent = NULL;
	}
}

BOOL ObservedEvent::Init(const char * eventName)
{
	SECURITY_DESCRIPTOR securityDescriptor;
	if (!InitializeSecurityDescriptor(&securityDescriptor, SECURITY_DESCRIPTOR_REVISION)
		|| !SetSecurityDescriptorDacl(&securityDescriptor, TRUE, (PACL)NULL, FALSE))
	{
		HRESULT err = HRESULT_FROM_WIN32(::GetLastError());
		SetError(err, ERROR_MODULE, ERROR_LINE, "ObservedEvent::Init");
		return FALSE;
	}

	SECURITY_ATTRIBUTES securityAttributes;
	securityAttributes.nLength = sizeof(securityAttributes);
	securityAttributes.lpSecurityDescriptor = &securityDescriptor;
	securityAttributes.bInheritHandle = FALSE; // don't need to inherit the handle

	std::string uniqueEventName(eventName);
	MakeUnique(uniqueEventName);

	// make this globally unique across terminal services sessions.
	uniqueEventName.insert(0, "Global\\");

	mObservedEvent =
		::CreateEventA(&securityAttributes, // pointer to security attributes
									 TRUE, // flag for manual-reset event
									 FALSE, // flag for initial state
									 uniqueEventName.c_str());		// pointer to event-object name

	return TRUE;
}

HANDLE ObservedEvent::GetEvent() const
{
	return mObservedEvent;
}

BOOL ObservedEvent::Signal()
{
	if (!::PulseEvent(mObservedEvent))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "ObservedEvent::Signal");
		return FALSE;
	}

	return TRUE;
}


/******************************************* EventObservable ***/

EventObservable::~EventObservable()
{
  // stop the thread
  StopThread(INFINITE);
}

BOOL EventObservable::Init(const char * eventName)
{
	if (!mEvent.Init(eventName))
	{
		SetError(mEvent);
		return FALSE;
	}

	return TRUE;
}

int EventObservable::ThreadMain()
{
	const char * functionName = "EventObservable::ThreadMain";

	// wait for the "session ready" or the thread stop event.
	HANDLE events[2];
	events[0] = mEvent;
	ASSERT(events[0] != NULL);
	events[1] = StopEventHandle();
	ASSERT(events[1] != NULL);

	BOOL exitLoop = FALSE;
	while (!exitLoop)
	{
		DWORD waitResult = ::WaitForMultipleObjects(2, // number of handles
																								events, // pointer to the object-handles
																								FALSE, // wait flag (wait for any of them)
																								INFINITE); // time-out interval (ms)
		if (waitResult == WAIT_FAILED)
		{
			// TODO: pass win32 or hresult?
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
							 "Error while waiting for change event or stop event");
			return -1;
		}

		//
		// now we know _at least_ one event has triggered.
		// The return value of WaitForMultipleObjects is the index of the first one.
		//

		int event = waitResult - WAIT_OBJECT_0;
		switch (event)
		{
		case 0:
			// configuration has change
			ChangeSignalled();
			break;
		case 1:
			// stop signal
			exitLoop = TRUE;
			break;
		default:
			ASSERT(0);
			// TODO: pass win32 or hresult?
			SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,
							 "WaitForMultipleObjects returned an invalid event number");
			return -1;
		}
	}

	return 0;
}

void EventObservable::ChangeSignalled()
{
	// the easy part - notify all the observers
	SetChanged();
	NotifyObservers();
}


void EventObservable::AddObserver(EventObserver & arObserver)
{
	MTObservable<EventObserver, void>::AddObserver(arObserver);
}

/********************************************* EventObserver ***/

void EventObserver::Update(MTObservable<EventObserver, void> & arObservable,
																	void * apArg)
{
	// tell the object that the configuration has changed
	EventOccurred();
}
