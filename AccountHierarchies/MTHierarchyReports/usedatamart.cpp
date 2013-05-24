/**************************************************************************
 * USEDATAMART
 *
 * Copyright 1997-2003 by MetraTech Corp.
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

#include <StdAfx.h>
#import <MetraTech.DataAccess.MaterializedViews.tlb>

// Global function used by the slice objects to decide whether or not
// to use the Materialized Views.
bool UseDataMart()
{
	static bool initialized = false;
	static bool useDM = false;

	if (!initialized)
	{
    MetraTech_DataAccess_MaterializedViews::IManagerPtr MVMgr;
    MVMgr = new MetraTech_DataAccess_MaterializedViews::IManagerPtr(__uuidof(MetraTech_DataAccess_MaterializedViews::Manager));
    MVMgr->Initialize();
    useDM = MVMgr->GetIsMetraViewSupportEnabled() == VARIANT_TRUE;
	  initialized = true;
	}

	return useDM;
}

// EOF