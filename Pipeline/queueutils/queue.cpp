/**************************************************************************
 * @doc QUEUE
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

#include <mtcom.h>

#include "queue.h"

BOOL SetupQueue(MessageQueue & arQueue,
								const wchar_t * apQueueName, const wchar_t * apMachineName,
								const wchar_t * apLabelName, BOOL aJournal, BOOL aSendAccess,
								BOOL aPrivate, BOOL aTransactional, ErrorObject * * apError)
{
	ASSERT(apError);

	// don't pass in empty string for machine name
	if (apMachineName && wcslen(apMachineName) == 0)
		apMachineName = NULL;

	// attempt to create
	MessageQueueProps queueProps;

	queueProps.SetLabel(apLabelName);
	queueProps.SetJournal(aJournal);
	queueProps.SetTransactional(aTransactional);

	// assume it's already been created
	if (!arQueue.Init(apQueueName, aPrivate, apMachineName)
			|| !arQueue.Open(aSendAccess ? MQ_SEND_ACCESS : MQ_RECEIVE_ACCESS,
											 MQ_DENY_NONE))
	{
    if (arQueue.GetLastError()->GetCode() == MQ_ERROR_REMOTE_MACHINE_NOT_AVAILABLE)
    {
				*apError = new ErrorObject(*arQueue.GetLastError());
   			wchar_t buff[256];
        wsprintf(buff, L"error: 0x%x, This issue occurs because DNS entry for '%s' machine is either"\
                       L" missing or incorrect. Make sure specified machine name is correct.",
                MQ_ERROR_REMOTE_MACHINE_NOT_AVAILABLE,
                apMachineName);

        (*apError)->SetProgrammerDetail((char*) _bstr_t(buff));
				return FALSE;
    }

		if (!arQueue.CreateQueue(apQueueName,
														 aPrivate, queueProps, apMachineName))
		{
			if (arQueue.GetLastError()->GetCode() != MQ_ERROR_QUEUE_EXISTS)
			{
				*apError = new ErrorObject(*arQueue.GetLastError());
				return FALSE;
			}
		}

		if (!arQueue.Init(apQueueName, aPrivate, apMachineName)
				|| !arQueue.Open(aSendAccess ? MQ_SEND_ACCESS : MQ_RECEIVE_ACCESS,
												 MQ_DENY_NONE))
		{
			*apError = new ErrorObject(*arQueue.GetLastError());
			return FALSE;
		}
	}

	*apError = NULL;
	return TRUE;
}

BOOL SetupJournalQueue(MessageQueue & arQueue,
											 const wchar_t * apQueueName, const wchar_t * apMachineName,
											 const wchar_t * apLabelName, BOOL aSendAccess,
											 BOOL aPrivate, BOOL aTransactional, ErrorObject * * apError)
{
	ASSERT(apError);

	// don't pass in empty string for machine name
	if (apMachineName && wcslen(apMachineName) == 0)
		apMachineName = NULL;

	// attempt to create
	MessageQueueProps queueProps;

	queueProps.SetLabel(apLabelName);
	queueProps.SetJournal(TRUE);	// must be true
	queueProps.SetTransactional(aTransactional);

	// assume it's already been created
	if (!arQueue.InitJournal(apQueueName, aPrivate, apMachineName)
			|| !arQueue.Open(aSendAccess ? MQ_SEND_ACCESS : MQ_RECEIVE_ACCESS,
											 MQ_DENY_NONE))
	{
		if (!arQueue.CreateQueue(apQueueName,
														 aPrivate, queueProps, apMachineName))
		{
			if (arQueue.GetLastError()->GetCode() != MQ_ERROR_QUEUE_EXISTS)
			{
				*apError = new ErrorObject(*arQueue.GetLastError());
				return FALSE;
			}
		}

		if (!arQueue.InitJournal(apQueueName, aPrivate, apMachineName)
				|| !arQueue.Open(aSendAccess ? MQ_SEND_ACCESS : MQ_RECEIVE_ACCESS,
												 MQ_DENY_NONE))
		{
			*apError = new ErrorObject(*arQueue.GetLastError());
			return FALSE;
		}
	}

	*apError = NULL;
	return TRUE;
}
