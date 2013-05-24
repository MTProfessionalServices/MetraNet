/**************************************************************************
 * @doc QUEUE
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
 * @index | QUEUE
 ***************************************************************************/

#ifndef _QUEUE_H
#define _QUEUE_H

#include <msmqlib.h>

// create, init, and open a queue
BOOL SetupQueue(MessageQueue & arQueue,
								const wchar_t * apQueueName, const wchar_t * apMachineName,
								const wchar_t * apLabelName, BOOL aJournal, BOOL aSendAccess,
								BOOL aPrivate, BOOL aTransactional, ErrorObject * * apError);

BOOL SetupJournalQueue(MessageQueue & arQueue,
											 const wchar_t * apQueueName, const wchar_t * apMachineName,
											 const wchar_t * apLabelName, BOOL aSendAccess,
											 BOOL aPrivate, BOOL aTransactional, ErrorObject * * apError);

#endif /* _QUEUE_H */
