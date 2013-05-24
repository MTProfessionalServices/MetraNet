/**************************************************************************
 * AUTHERR
 *
 * Copyright 1997-2002 by MetraTech Corp.
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
 ***************************************************************************/

#include <metra.h>
#include <autherr.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <mtprogids.h>

void AuditAuthFailures(_com_error & arError,
											 AuditEventsLib::MTAuditEvent aEvent,
											 int aUserID,	AuditEventsLib::MTAuditEntityType aEntity,
											 int aObjectID)
{
	if (arError.Error() == MTAUTH_ACCESS_DENIED)
	{
		try
		{
			AuditEventsLib::IAuditorPtr auditor(MTPROGID_AUDITOR);

			// auth failure - audit it
			auditor->FireFailureEvent(
				aEvent, aUserID, aEntity,
				aObjectID, arError.Description());
		}
		catch (_com_error & auditerr)
		{
			LoggerConfigReader configReader;
			NTLogger logger;
			if (!logger.Init(configReader.ReadConfiguration("logging"), "[Auth]"))
			{
				// nothing we can do here
				ASSERT(0);
				return;
			}

			std::string buffer;
			StringFromComError(buffer, "Unable to log authorization failure", auditerr);
			logger.LogThis(LOG_ERROR, buffer.c_str());
		}
	}
}

