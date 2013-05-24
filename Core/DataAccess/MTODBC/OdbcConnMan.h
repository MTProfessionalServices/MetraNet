/**************************************************************************
 * @doc ODBCCONNMAN
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
 * @index | ODBCCONNMAN
 ***************************************************************************/

#ifndef _ODBCCONNMAN_H
#define _ODBCCONNMAN_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#include <OdbcConnection.h>

#include <string>
#include <map>

// TODO: remove undefs
#if defined(MTODBC_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

// helper methods for obtaining connection 
class COdbcConnectionManager
{
public:
	// return the connection info for the given logical server name.
	// this information is read out of config/serveraccess/servers.xml
	DllExport static const COdbcConnectionInfo & GetConnectionInfo(const char * apLogicalServerName);

private:	
	typedef std::map<std::string, COdbcConnectionInfo> ConnectionInfoMap;
	static ConnectionInfoMap mConnectionInfoCache;
};

#endif /* _ODBCCONNMAN_H */
