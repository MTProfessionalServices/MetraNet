/**************************************************************************
 * MISCTIMING
 *
 * Copyright 1997-2001 by MetraTech Corp.
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
#include "misctiming.h"

/************************************************ MiscTiming ***/

MiscTiming::MiscTiming()
	: mpStats(NULL)
{ }

BOOL MiscTiming::Init(const SharedStats & arStats,
											enum SharedStats::Timing aTiming,
											const char * apInternalName,
											const char * apDisplayName,
											const char * apHelpText,
											DWORD aType,
											int aDefaultScale)
{
	mpStats = &arStats;

	mTiming = aTiming;
	mpInternalName = apInternalName;
	mpDisplayName = apDisplayName;
	mpHelpText = apHelpText;
	
	mType = aType;
	mDefaultScale = aDefaultScale;

	return TRUE;
}

BOOL MiscTiming::Collect(DWORD & arValue)
{
	ASSERT(mpStats);

	arValue = mpStats->GetMiscTiming(mTiming);

	return TRUE;
}

