/**************************************************************************
 * @doc CMDMEM
 *
 * Copyright 1998 by MetraTech Corporation
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
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>

#include <sharedsess.h>
#include <MSIX.h>
#include <errutils.h>
#include <ConfigDir.h>
#include <mtprogids.h>
#include <multi.h>
#include <makeunique.h>

#import <MTConfigLib.tlb>
#include <pipelineconfig.h>
#include <mtcomerr.h>
using namespace MTConfigLib;

#include <iostream>

using std::cout;
using std::endl;
using std::hex;
using std::dec;

ComInitialize gComInitialize;


void DisplayUsage()
{
	cout << "Usage: cmdmem [-dump | -dumpprops | -sizes | -locks]" << endl;
	cout << endl;
	cout << "  no args     displays shared memory utilization statistics" << endl;
	cout << "  -dump       dumps a list of sessions in shared memory" << endl;
	cout << "  -dumpprops  dumps a list of properties in shared memory" << endl;
	cout << "  -sizes      lists raw sizes of internal data structures" << endl;
	cout << "  -locks      lists acquired UID->session bucket locks" << endl;
	cout << "  -leak       returns non-zero value if any memory is outstanding" << endl;
}


//
// dumps all properties in shared memory to the console (callback)
//
BOOL DumpScanProperties(void * apArg, SharedSessionHeader * apHeader,
												SharedPropVal * apProperty)
{
	const char * type = NULL;

	cout << "Property ID : " << apProperty->GetNameID() << endl;
	cout << "Data Type   : ";
	switch (apProperty->GetType())
	{
	case SharedPropVal::OLEDATE_PROPERTY:
	{
		cout << "OLEDATE" << endl;

		DATE val = apProperty->GetOLEDateValue();
		cout << "Value       : '" << (const char *) _bstr_t(_variant_t(val, VT_DATE)) << "'" << endl;
		break;
	}
	case SharedPropVal::TIMET_PROPERTY:
	{
		cout << "TIMET" << endl;

		time_t timeT = apProperty->GetDateTimeValue();
		DATE date;
		::OleDateFromTimet(&date, timeT);
		cout << "Value       : '" << (const char *) _bstr_t(_variant_t(date, VT_DATE)) << "'" << endl;

		break;
	}
	case SharedPropVal::TIME_PROPERTY:
		cout << "TIME" << endl;
		break;

	case SharedPropVal::UNICODE_PROPERTY:
	{
		cout << "UNICODE" << endl;

		long id = apProperty->GetUnicodeIDValue();
		const wchar_t * str = apHeader->GetWideString(id);
		cout << "Value       : '" << (const char *) _bstr_t(str) << "'" << endl;
		
		break;
	}
	case SharedPropVal::TINYSTRING_PROPERTY:
	{
		cout << "TINYSTRING" << endl;

		const wchar_t * str = apProperty->GetTinyStringValue();
		cout << "Value       : '" << (const char *) _bstr_t(str) << "'" << endl;
		
		break;
	}
	case SharedPropVal::EXTRA_LARGE_STRING_PROPERTY:
	{
		cout << "EXTRALARGESTRING" << endl;

		const wchar_t * str = apProperty->CopyExtraLargeStringValue(apHeader);
		cout << "Value       : '" << (const char *) _bstr_t(str) << "'" << endl;
		
		break;
	}

	case SharedPropVal::LONG_PROPERTY:
	{
		cout << "LONG" << endl;

		long val = apProperty->GetLongValue();
		cout << "Value       : " << val << endl;
		
		break;
	}

	case SharedPropVal::ENUM_PROPERTY:
	{
		cout << "ENUM" << endl;

		long val = apProperty->GetEnumValue();
		cout << "Value       : " << val << endl;
		
		break;
	}

	case SharedPropVal::DOUBLE_PROPERTY:
	{
		cout << "DOUBLE" << endl;

		double val = apProperty->GetDoubleValue();
		cout << "Value       : " << val << endl;
		break;
	}

	case SharedPropVal::BOOL_PROPERTY:
	{
		cout << "BOOL" << endl;
		BOOL val = apProperty->GetBooleanValue();
		cout << "Value       : " << val << endl;
		// TODO: implement me
		break;
	}

	case SharedPropVal::DECIMAL_PROPERTY:
	{
		cout << "DECIMAL" << endl;

		const unsigned char * buffer = apProperty->GetDecimalValue();
		DECIMAL val;
		memcpy(&val, buffer, sizeof(val));
		cout << "Value       : " << (const char *) _bstr_t(_variant_t(val)) << endl;
		
		// TODO: this doesn't seem to work

		break;
	}

	default:
		cout << "UNKNOWN" << endl;
	}
	cout << endl;

	return TRUE;
}


//
// dumps all sessions in shared memory to the console (callback)
//
BOOL DumpScan(void * apArg, SharedSessionHeader * apHeader,
							SharedSession * apSession)
{
	long id = apSession->GetSessionID(apHeader);
	long parent = apSession->GetParentID();
	long ref = apSession->GetRefCount();
	long service = apSession->GetServiceID();

	const char * statestr = NULL;
	SharedSession::SessionState state = apSession->GetCurrentState();
	switch (state)
	{
	case SharedSession::NEWLY_CREATED:
		statestr = "NEWLY_CREATED"; break;
	case SharedSession::IN_TRANSIT:
		statestr = "IN_TRANSIT"; break;
	case SharedSession::PROCESSING:
		statestr = "PROCESSING"; break;
	case SharedSession::ROLLEDBACK:
		statestr = "ROLLEDBACK"; break;
	case SharedSession::MARKED_AS_FAILED:
		statestr = "MARKED_AS_FAILED"; break;
	};

	const unsigned char * uid = apSession->GetUID();
	string uidString;
	MSIXUidGenerator::Encode(uidString, uid);

	char buffer[256];
	sprintf(buffer, "ID: %4d PID: %4d REF: %4d SVC: %4d %16s  UID: %s",
					id, parent, ref, service, statestr, uidString.c_str());
	cout << buffer << endl;

	return TRUE;
}

void DumpSessions(SharedSessionHeader * header)
{
	cout << "Sessions currently in shared memory:" << endl;
	header->AllSessions(DumpScan, NULL);
}

void DumpProperties(SharedSessionHeader * header)
{
	cout << "Properties currently in shared memory:" << endl;
	header->AllProperties(DumpScanProperties, NULL);
}

void DumpLocks(SharedSessionHeader * header)
{
	cout << "UID->session hash table locks:" << endl;

	const long * locks = NULL;
	int lockCount;
	header->GetLocksStats(&locks, lockCount);

	int locked = 0;
	for (int i = 0; i < lockCount; i++)
	{
		if (locks[i] == 1) {
			cout << "  bucket " << i << " is locked" << endl;
			locked++;
		}
	}
	cout << locked << " locks are currently aquired" << endl;
}

void DumpSizes()
{
	printf("SharedSession: %d\n", sizeof(SharedSession));
	printf("SharedSet: %d\n", sizeof(SharedSet));
	printf("SharedSetNode: %d\n", sizeof(SharedSetNode));
	printf("SharedPropVal: %d\n", sizeof(SharedPropVal));
	printf("SharedObjectOwner: %d\n", sizeof(SharedObjectOwner));
}

int main(int argc, char * argv[])
{
	//
	// parse command line args
	//
	BOOL dumpSessions = FALSE;
	BOOL dumpProperties = FALSE;
	BOOL dumpLocks = FALSE;
	BOOL dumpSizes = FALSE;
	BOOL leakMode = FALSE;

	// negative means test forever
	int i = 1;
	while (i < argc)
	{
		if (0 == strcmpi(argv[i], "-dump"))
			dumpSessions = TRUE;
		else if (0 == strcmpi(argv[i], "-dumpprops"))
			dumpProperties = TRUE;
		else if (0 == strcmpi(argv[i], "-sizes"))
			dumpSizes = TRUE;
		else if (0 == strcmpi(argv[i], "-locks"))
			dumpLocks = TRUE;
		else if (0 == strcmpi(argv[i], "-leak"))
			leakMode = TRUE;
		else if (0 == strcmpi(argv[i], "/?"))
		{
			DisplayUsage();
			return 1;
		}
		else if (0 == strcmp(argv[i], "--help"))
		{
			DisplayUsage();
			return 1;
		}
		else
		{
			cout << "argument not understood: " << argv[i] << endl;
			return 1;
		}

		i++;
	}

	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		cout << "Unable to read configuration directory" << endl;
		return -1;
	}

	SharedSessionMappedViewHandle mappedView;
	SharedSessionHeader * header;

	PipelineInfo pipelineInfo;

	try
	{
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

		PipelineInfoReader reader;
		ASSERT(configDir.length() != 0);
		if (!reader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
		{
			string buffer;
			StringFromError(buffer, "Unable to read pipeline configuration",
											reader.GetLastError());
			cout << buffer.c_str();
			return -1;
		}
	}
	catch (_com_error & err)
	{
		std::string str;
		StringFromComError(str, "Unable to read pipeline configuration", err);
		cout << str.c_str();
		return -1;
	}


	std::string shareName = pipelineInfo.GetShareName();
	MakeUnique(shareName);
	DWORD err = mappedView.Open(pipelineInfo.GetSharedSessionFile().c_str(),
															shareName.c_str(),
															pipelineInfo.GetSharedFileSize(), FALSE);

	if (err != NO_ERROR)
		cout << "Unable to open shared memory : " << hex << err << dec << endl;

	long spaceAvail = mappedView.GetAvailableSpace() - sizeof(SharedSessionHeader);

	header =
		SharedSessionHeader::Initialize(
			mappedView, mappedView.GetMemoryStart(),
			spaceAvail / 6,
			spaceAvail / 6,
			spaceAvail / 6,
			spaceAvail / 6,
			spaceAvail / 6,
			spaceAvail / 6,
			FALSE);

	if (!header)
	{
		cout << "Unable to init shared memory" << endl;
		return -1;
	}

	if (!mappedView.WaitForAccess(5000) != NULL)
	{
		cout << "Could not gain access to mutex" << endl;
		return -1;
	}

	if (dumpSizes)
	{
		DumpSizes();
		return 0;
	}

	FixedSizePoolStats stats;

	int currentPercent, maxPercent;
	int currentMax = 0, maxMax = 0;
	long allocatedMemory = 0;

	printf("Shared Memory Statistics\n\n");
	printf("                    used      max     size  used%%/max%%\n");

	printf("Session:       ");
	header->GetSessionPoolStats(stats);
	allocatedMemory += stats.mCurrentlyAllocated;
	currentPercent = (stats.mCurrentlyAllocated * 100) / stats.mSize;
	maxPercent = (stats.mMaxAllocated * 100) / stats.mSize;
	if (currentPercent > currentMax)
		currentMax = currentPercent;
	if (maxPercent > maxMax)
		maxMax = maxPercent;
	printf(" %8d %8d %8d   %3d%%/%3d%%\n",
				 stats.mCurrentlyAllocated, stats.mMaxAllocated, stats.mSize,
				 currentPercent, maxPercent);

	printf("Prop:          ");
	header->GetPropPoolStats(stats);
	allocatedMemory += stats.mCurrentlyAllocated;
	currentPercent = (stats.mCurrentlyAllocated * 100) / stats.mSize;
	maxPercent = (stats.mMaxAllocated * 100) / stats.mSize;
	if (currentPercent > currentMax)
		currentMax = currentPercent;
	if (maxPercent > maxMax)
		maxMax = maxPercent;
	printf(" %8d %8d %8d   %3d%%/%3d%%\n",
				 stats.mCurrentlyAllocated, stats.mMaxAllocated, stats.mSize,
				 currentPercent, maxPercent);


	printf("Set:           ");
	header->GetSetPoolStats(stats);
	allocatedMemory += stats.mCurrentlyAllocated;
	currentPercent = (stats.mCurrentlyAllocated * 100) / stats.mSize;
	maxPercent = (stats.mMaxAllocated * 100) / stats.mSize;
	if (currentPercent > currentMax)
		currentMax = currentPercent;
	if (maxPercent > maxMax)
		maxMax = maxPercent;
	printf(" %8d %8d %8d   %3d%%/%3d%%\n",
				 stats.mCurrentlyAllocated, stats.mMaxAllocated, stats.mSize,
				 currentPercent, maxPercent);

	printf("Set node:      ");
	header->GetSetNodePoolStats(stats);
	allocatedMemory += stats.mCurrentlyAllocated;
	currentPercent = (stats.mCurrentlyAllocated * 100) / stats.mSize;
	maxPercent = (stats.mMaxAllocated * 100) / stats.mSize;
	if (currentPercent > currentMax)
		currentMax = currentPercent;
	if (maxPercent > maxMax)
		maxMax = maxPercent;
	printf(" %8d %8d %8d   %3d%%/%3d%%\n",
				 stats.mCurrentlyAllocated, stats.mMaxAllocated, stats.mSize,
				 currentPercent, maxPercent);

	printf("Object owner:  ");
	header->GetObjectOwnerPoolStats(stats);
	allocatedMemory += stats.mCurrentlyAllocated;
	currentPercent = (stats.mCurrentlyAllocated * 100) / stats.mSize;
	maxPercent = (stats.mMaxAllocated * 100) / stats.mSize;
	if (currentPercent > currentMax)
		currentMax = currentPercent;
	if (maxPercent > maxMax)
		maxMax = maxPercent;
	printf(" %8d %8d %8d   %3d%%/%3d%%\n",
				 stats.mCurrentlyAllocated, stats.mMaxAllocated, stats.mSize,
				 currentPercent, maxPercent);

	printf("Small string:  ");
	header->GetSmallStringPoolStats(stats);
	allocatedMemory += stats.mCurrentlyAllocated;
	currentPercent = (stats.mCurrentlyAllocated * 100) / stats.mSize;
	maxPercent = (stats.mMaxAllocated * 100) / stats.mSize;
	if (currentPercent > currentMax)
		currentMax = currentPercent;
	if (maxPercent > maxMax)
		maxMax = maxPercent;
	printf(" %8d %8d %8d   %3d%%/%3d%%\n",
				 stats.mCurrentlyAllocated, stats.mMaxAllocated, stats.mSize,
				 currentPercent, maxPercent);

	printf("Medium string: ");
	header->GetMediumStringPoolStats(stats);
	allocatedMemory += stats.mCurrentlyAllocated;
	currentPercent = (stats.mCurrentlyAllocated * 100) / stats.mSize;
	maxPercent = (stats.mMaxAllocated * 100) / stats.mSize;
	if (currentPercent > currentMax)
		currentMax = currentPercent;
	if (maxPercent > maxMax)
		maxMax = maxPercent;
	printf(" %8d %8d %8d   %3d%%/%3d%%\n",
				 stats.mCurrentlyAllocated, stats.mMaxAllocated, stats.mSize,
				 currentPercent, maxPercent);

	printf("Large string:  ");
	header->GetLargeStringPoolStats(stats);
	allocatedMemory += stats.mCurrentlyAllocated;
	currentPercent = (stats.mCurrentlyAllocated * 100) / stats.mSize;
	maxPercent = (stats.mMaxAllocated * 100) / stats.mSize;
	if (currentPercent > currentMax)
		currentMax = currentPercent;
	if (maxPercent > maxMax)
		maxMax = maxPercent;
	printf(" %8d %8d %8d   %3d%%/%3d%%\n",
				 stats.mCurrentlyAllocated, stats.mMaxAllocated, stats.mSize,
				 currentPercent, maxPercent);

	printf("               ");
	printf("                              %3d%%/%3d%%\n",
				 currentMax, maxMax);

	cout << endl;

	if (leakMode)
	{
		if (allocatedMemory > 0)
		{
			printf("Leak detected: %d properties are outstanding!\n", allocatedMemory);
			return -1;
		}
		else
		{
			printf("No leaks detected!\n");
			return 0;
		}
	}

	if (dumpSessions)
	{
		DumpSessions(header);
	}

	if (dumpProperties)
	{
		DumpProperties(header);
	}

	if (dumpLocks)
	{
		DumpLocks(header);
	}

	mappedView.ReleaseAccess();

	return 0;
}
