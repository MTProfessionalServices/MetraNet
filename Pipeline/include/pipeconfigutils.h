/**************************************************************************
 * @doc PIPECONFIGUTILS
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
 * @index | PIPECONFIGUTILS
 ***************************************************************************/

#ifndef _PIPECONFIGUTILS_H
#define _PIPECONFIGUTILS_H

#include <string>
#include <list>

using std::wstring;
using std::list;

class RoutingQueueInfo
{
public:
	RoutingQueueInfo()
	{ }

	RoutingQueueInfo(const RoutingQueueInfo & arOther);

	RoutingQueueInfo(const wchar_t * apMachine,
									 const wchar_t * apQueue);

	RoutingQueueInfo & operator = (const RoutingQueueInfo & arOther);

	const wstring & GetMachineName() const
	{ return mMachineName; }

	const wstring & GetQueueName() const
	{ return mQueueName; }

	static unsigned Hash(const RoutingQueueInfo & arInfo);

	bool operator < (const RoutingQueueInfo & arQueueInfo) const;
	bool operator == (const RoutingQueueInfo & arQueueInfo) const;

private:
	wstring mMachineName;
	wstring mQueueName;
};

typedef list<RoutingQueueInfo> RoutingQueueList;


// return the list of all unique routing queues
BOOL GetAllRoutingQueues(RoutingQueueList & arQueueList,
												 ErrorObject & arError);


#endif /* _PIPECONFIGUTILS_H */
