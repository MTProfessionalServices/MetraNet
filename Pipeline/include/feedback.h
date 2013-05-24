/**************************************************************************
 * @doc FEEDBACK
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
 * @index | FEEDBACK
 ***************************************************************************/

#ifndef _FEEDBACK_H
#define _FEEDBACK_H

#include <errobj.h>
#include <NTLogger.h>
#include <msmqlib.h>

#include <vector>
#include <map>

using std::map;

#include <MTDec.h>

class MeterRoutes;

/******************************************* SessionFeedback ***/

class MSIXSession;

class SessionFeedback : public ObjectWithError
{
public:
	SessionFeedback();
	virtual ~SessionFeedback();

	BOOL Init(const MeterRoutes & arRoutes, BOOL aPrivateQueues);

	BOOL RequiresFeedback(MTPipelineLib::IMTSessionPtr aSession);

	BOOL SendFeedback(const std::vector<MTPipelineLib::IMTSessionSetPtr> & arSessionSets,
										BOOL aError, BOOL aExpress);

private:

	BOOL GenerateMSIXSession(MTPipelineLib::IMTSessionPtr aSession,
													 MSIXSession & arMSIX);

	BOOL InitializeRoutes(const MeterRoutes & arRoutes, BOOL aPrivateQueues);

	static unsigned int LongHashKey(const long & arKey)
	{ return (unsigned int) (((arKey ^ 0x9862A5A5A5) << 16) ^ arKey); }

private:
	typedef map<long, MessageQueue> ListenerQueueMap;

	ListenerQueueMap mListenerQueueMap;

	NTLogger mLogger;

	MTPipelineLib::IMTNameIDPtr mNameID;
};

#endif /* _FEEDBACK_H */
