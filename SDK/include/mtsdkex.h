/**************************************************************************
 * @doc MTSDKEX
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
 * @index | MTSDKEX
 ***************************************************************************/

#ifndef _MTSDKEX_H
#define _MTSDKEX_H

// "expert" SDK interface.  not shipped with the standard SDK


#include <sdkcon.h>
#include <msixapi.h>

//
// directly set the UID of a session.
// NOTE: use with extreme caution!
//
inline void MTSetSessionIDEx(MTMeterSession * apSession, const char * apID)
{
	MSIXUid uid;
	uid.Init(apID);

	MeteringSessionImp * sess = dynamic_cast<MeteringSessionImp *>(apSession);
	if (sess)
		sess->SetUid(uid);
	else
	{
		StandaloneMeteringSessionImp * standAloneSess =
			dynamic_cast<StandaloneMeteringSessionImp *>(apSession);
		if (standAloneSess)
		{
			MTMeterSession * mtsession = standAloneSess->GetSession();
			MSIXMeteringSessionImp * internalSess =
				dynamic_cast<MSIXMeteringSessionImp *>(mtsession);
			ASSERT(internalSess);
			internalSess->SetUid(uid);
		}
		else
			ASSERT(0);
	}
}

//
// directly set the UID of the message used to send the given session.
// NOTE: use with extreme caution!
//
inline void MTSetSessionSetIDEx(MTMeterSession * apSession, const char * apID)
{
	StandaloneMeteringSessionImp * standAloneSess =
		dynamic_cast<StandaloneMeteringSessionImp *>(apSession);
	if (standAloneSess)
	{
		MTMeterSessionSet * mtsessionSet = standAloneSess->GetSessionSet();
		MeteringSessionSetImp * internalSessionSet =
			dynamic_cast<MeteringSessionSetImp *>(mtsessionSet);
		ASSERT(internalSessionSet);
		internalSessionSet->SetSessionSetID(apID);
	}
	else
		ASSERT(0);
}

//
// directly set the UID of the message used to send the given session set.
// NOTE: use with extreme caution!
//
inline void MTSetSessionSetIDEx(MTMeterSessionSet * apSessionSet, const char * apID)
{
	MeteringSessionSetImp * internalSessionSet =
		dynamic_cast<MeteringSessionSetImp *>(apSessionSet);
	ASSERT(internalSessionSet);
	internalSessionSet->SetSessionSetID(apID);
}


#endif /* _MTSDKEX_H */
