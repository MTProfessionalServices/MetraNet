/**************************************************************************
 * @doc QUEUESIZE
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | QUEUESIZE
 ***************************************************************************/

#ifndef _QUEUESIZE_H
#define _QUEUESIZE_H

#include <errobj.h>

#include <pdh.h>

class QueueSize : public virtual ObjectWithError
{
public:
	QueueSize();
	virtual ~QueueSize();

	BOOL Init(const wchar_t * apMachineName, const wchar_t * apQueueName,
						BOOL aPrivate, BOOL aJournal);

	int GetCurrentQueueSize();

	BOOL IsInitialized() const
	{ return mpCurHand != NULL; }

private:
	HQUERY mhQuery;
	HCOUNTER * mpCurHand;
};

#endif /* _QUEUESIZE_H */
