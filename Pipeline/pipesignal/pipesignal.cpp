/**************************************************************************
 * @doc PIPESIGNAL
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
 ***************************************************************************/

#include <metra.h>
#include <errobj.h>
#include <stdlib.h>							// _itoa

#include <pipesignal.h>
#include <string>

/********************************************* PipelineEvent ***/

const int PipelineEvent::mDefaultWait = PIPELINE_EVENT_DEFAULT_TIMEOUT;

PipelineEvent::PipelineEvent() : mEventHandle(NULL), mSuffix(0), mLocalUsers(0)
{
}

PipelineEvent::~PipelineEvent()
{
	if (mEventHandle)
	{
		// TODO: what if there are still threads waiting?
		::CloseHandle(mEventHandle);
		mEventHandle = NULL;
	}
}


BOOL PipelineEvent::Initialize(int aSuffix)
{
	const char * functionName = "PipelineEvent::Initialize";

	ASSERT(mEventHandle == NULL);

	mSuffix = aSuffix;

	std::string eventName(PIPELINE_EVENT_PREFIX);

	char buffer[20];
	_itoa(aSuffix, buffer, 10);
	eventName += buffer;

	// use a null security dacl
	// TODO: make this more restrictive

	SECURITY_DESCRIPTOR securityDescriptor;
	SECURITY_ATTRIBUTES securityAttributes;
	securityAttributes.nLength = sizeof(securityAttributes);
	securityAttributes.lpSecurityDescriptor = &securityDescriptor;
	// TODO: don't need to inherit the handle do we?
	securityAttributes.bInheritHandle = FALSE;

	if (!InitializeSecurityDescriptor(&securityDescriptor, SECURITY_DESCRIPTOR_REVISION)
			|| !SetSecurityDescriptorDacl(&securityDescriptor, TRUE, (PACL)NULL, FALSE))
	{
		// TODO: use HRESULT?
		DWORD err = ::GetLastError();
		SetError(err, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	mEventHandle = ::CreateEventA(&securityAttributes, // pointer to security attributes 
															 TRUE, // manual-reset event
															 FALSE,	// not initially signalled
															 eventName.c_str());

	if (!mEventHandle)
	{
		// TODO: use HRESULT?
		DWORD err = ::GetLastError();
		SetError(err, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	return TRUE;
}


BOOL PipelineEvent::Wait()
{
	return Wait(mDefaultWait);
}

BOOL PipelineEvent::Wait(DWORD aTimeout)
{
	// other possible return values: WAIT_TIMEOUT, WAIT_FAILED

	DWORD waitResult = ::WaitForSingleObject(mEventHandle, aTimeout);
	if (waitResult == WAIT_OBJECT_0)
		return TRUE;

	DWORD err = ::GetLastError();
	SetError(err, ERROR_MODULE, ERROR_LINE, "PipelineEvent::Wait");
	return FALSE;
}

BOOL PipelineEvent::WaitForever()
{
	return Wait(INFINITE);
}



/****************************************** PipelineEventSet ***/


PipelineEventSet::PipelineEventSet() : mpEventArray(NULL)
{
}

PipelineEventSet::~PipelineEventSet()
{
	if (mpEventArray)
	{
		delete [] mpEventArray;
		mpEventArray = NULL;
	}
}


BOOL PipelineEventSet::Initialize(int aNumEvents)
{
	mpEventArray = new PipelineEvent[aNumEvents];
	for (int i = 0; i < aNumEvents; i++)
	{
		if (!mpEventArray[i].Initialize(i))
		{
			SetError(mpEventArray[i].GetLastError());
			return FALSE;
		}
	}
	return TRUE;
}
