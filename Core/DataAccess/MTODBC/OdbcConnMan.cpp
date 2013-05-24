/**************************************************************************
 * ODBCCONNMAN
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
#include <OdbcConnMan.h>

#include <OdbcException.h>
#import <MTServerAccess.tlb>
#include <mtprogids.h>

COdbcConnectionManager::ConnectionInfoMap COdbcConnectionManager::mConnectionInfoCache;

const COdbcConnectionInfo &
COdbcConnectionManager::GetConnectionInfo(const char * apLogicalServerName)
{
	ConnectionInfoMap::iterator it = mConnectionInfoCache.find(apLogicalServerName);
	if (it != mConnectionInfoCache.end())
	{
		const COdbcConnectionInfo & connInfo = it->second;
		return connInfo;
	}

	COdbcConnectionInfo & storedConnInfo = mConnectionInfoCache[apLogicalServerName];

	// special case: NetMeterStage is a clone of the NetMeter entry
	// except for the catalog (database) name
	if (strcmpi(apLogicalServerName, "NetMeterStage") == 0)
	{
		COdbcConnectionInfo dbInfo("NetMeter");
		COdbcConnectionInfo stagingDbInfo("NetMeterStage");
		dbInfo.SetCatalog(stagingDbInfo.GetCatalog().c_str());
		storedConnInfo = dbInfo;
	}
	else
		storedConnInfo.Load(apLogicalServerName);

	return storedConnInfo;
}
