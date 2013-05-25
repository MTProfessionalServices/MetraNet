/**************************************************************************
 * QUEUESIZE
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
#include <queuesize.h>
#include <stdutils.h>

#include <pdhmsg.h>
#include <tchar.h>

QueueSize::QueueSize()
	: mhQuery(NULL),
		mpCurHand(NULL)
{ }

QueueSize::~QueueSize()
{
	if (mhQuery != NULL)
	{
		PDH_STATUS pdhStatus;

		pdhStatus = PdhCloseQuery(mhQuery);
		if(!(pdhStatus == ERROR_SUCCESS))
		{
			const long errCode = ::GetLastError();
			ASSERT(0);
		}
	}

	if (mpCurHand)
	{
		::GlobalFree(mpCurHand);
		mpCurHand = NULL;
	}
}


BOOL QueueSize::Init(const wchar_t * apMachineName, const wchar_t * apQueueName,
										 BOOL aPrivate, BOOL aJournal)
{
	const char * functionName = "QueueSize::Init";

	std::wstring computername = apMachineName;

	std::wstring queuename = apQueueName;

	if(0 == mtwcscasecmp(computername.c_str(), L"127.0.0.1")
		 || 0 == mtwcscasecmp(computername.c_str(), L"localhost")
		 || 0 == mtwcscasecmp(computername.c_str(), L""))
	{
		wchar_t temp[100];
		DWORD nSize = sizeof(temp) / sizeof(temp[0]);
		if (!GetComputerName(temp, &nSize))
		{
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}
		computername = temp;
	}	

	TCHAR StrCounters[1024];
//	wcscpy(StrCounters,
//				 L"\\\\FISSION\\MSMQ Queue(fission\\private$\\routingqueue)\\Bytes in Queue");

	swprintf(StrCounters, _T("\\\\%s\\MSMQ Queue(%s\\%s%s)\\Bytes in %sQueue"),
					 computername.c_str(),
					 computername.c_str(),
					 aPrivate ? L"private$\\" : L"",
					 queuename.c_str(),
					 aJournal ? L"Journal " : L"");

#if 0
	swprintf(StrCounters, _T("\\\\%s\\MSMQ Queue(Computer Queues/%s\\%s%s)\\Bytes in Queue"),
					 computername.c_str(),
					 computername.c_str(),
					 arPipelineInfo.UsePrivateQueues() ? L"\\private$\\" : L"",
					 queuename.c_str());
#endif
		
	// TODO: needs better error handling/leak checking

	PDH_STATUS pdhStatus;
	pdhStatus = PdhOpenQuery(0,0,&mhQuery);	

	if(!(pdhStatus==ERROR_SUCCESS))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
				 "PdhOpenQuery: Unable to initialize routing queue perfmon counter");
		return FALSE;
	}


	mpCurHand = (HCOUNTER *)GlobalAlloc(GPTR, (sizeof(HCOUNTER)));

	if(!mpCurHand)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
				 "GlobalAlloc: Unable to initialize routing queue perfmon counter");
		return FALSE;
	}

	pdhStatus = PdhAddCounter(mhQuery, StrCounters,	0, mpCurHand);

	if(!(pdhStatus == ERROR_SUCCESS))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
				 "PdhAddCounter: Unable to initialize routing queue perfmon counter"); 
		return FALSE;
	}

	return TRUE;
}

int QueueSize::GetCurrentQueueSize()
{
	const char * functionName = "QueueSize::GetCurrentQueueSize";

	DWORD ctrType;

	PDH_FMT_COUNTERVALUE fmtValue;

	PDH_STATUS pdhStatus;
	pdhStatus = PdhCollectQueryData(mhQuery);

	if(!(pdhStatus == ERROR_SUCCESS))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName); 
		return -1;
	}

	pdhStatus = PdhGetFormattedCounterValue(
		*mpCurHand, PDH_FMT_LONG,
		&ctrType,
		&fmtValue);

// A bug in the pdh.dll, if the journey is just created, the return of 
// PdhGetFormattedCounterValue will be INVALID_DATA

	if(pdhStatus != ERROR_SUCCESS && pdhStatus != PDH_INVALID_DATA)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName); 
		return -1;
	}

	return fmtValue.longValue;	
}
