/**************************************************************************
 * @doc PERFMON
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
 ***************************************************************************/

//
// Loosely based on the MSDN sample:
//
//   Instrumenting Windows NT Applications with Performance Monitor
//   Steven Pratschner, 
//   Microsoft Consulting Services
//   September 30, 1997 
//


#include <metra.h>

#include "perfmon.h"
#include <NTRegistryIO.h>
#include <string>

/********************************************* PerfmonObject ***/
//
// PerfmonObject
//
PerfmonObject::PerfmonObject()
	: m_pPerfCounterDefs(NULL)
{ }

PerfmonObject::~PerfmonObject()
{
	if (m_pPerfCounterDefs)
	{
		delete [] m_pPerfCounterDefs;
		m_pPerfCounterDefs = NULL;
	}
}


BOOL PerfmonObject::Register(const char * apDLLName)
{
	if (!Init())
		return FALSE;

	PerfmonRegistration reg;
	if (!reg.Register(*this, apDLLName))
	{
		SetError(reg);
		return FALSE;
	}

	return TRUE;
}

#define MAX_FILENAME 1024

BOOL PerfmonObject::Register(HINSTANCE hDllInstance)
{
	char FileName[MAX_FILENAME];
	DWORD nResult;

	nResult = ::GetModuleFileNameA(hDllInstance,FileName,MAX_FILENAME);
	if(nResult != 0) {
		return Register(FileName);
	}
	return FALSE;
}

BOOL PerfmonObject::Unregister()
{
	if (!Init())
		return FALSE;

	PerfmonRegistration reg;
	if (!reg.Unregister(*this))
	{
		SetError(reg);
		return FALSE;
	}

	return TRUE;
}


BOOL PerfmonObject::ModuleInitialize()
{
	const char * functionName = "PerfmonObject::ModuleInitialize";

	// allow the subclass to do any initialization
	if (!Init())
		return FALSE;

	//
	// Initialize lpPerfmonData.  Read the first counter and help values
	// from the registry and initialize the object and counter data structures
	// for use during collection.
	//
	DWORD dwFirstCounter;
	DWORD dwFirstHelp;

	NTRegistryIO registry;

	const wchar_t * appName = L"Pipeline";

	std::wstring branch(L"SYSTEM\\CurrentControlSet\\Services\\");
	branch += appName;
	branch += L"\\Performance";

	if (!registry.OpenRegistryRaw(NTRegistryIO::LOCAL_MACHINE,
																branch.c_str(), RegistryIO::READ_ACCESS))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	BYTE * buffer = (BYTE *) &dwFirstCounter;
	DWORD size = sizeof(dwFirstCounter);
	if (!registry.ReadRegistryValue(L"First Counter", RegistryIO::STRING,
									buffer, size))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	buffer = (BYTE *) &dwFirstHelp;
	size = sizeof(dwFirstHelp);
	if (!registry.ReadRegistryValue(L"First Help", RegistryIO::STRING,
									buffer, size))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}
     
	InitializePerfmonData(dwFirstCounter, dwFirstHelp);

	return TRUE;
}

void PerfmonObject::InitializePerfmonData(DWORD dwFirstCounter, DWORD dwFirstHelp)
{
	long objectIndex = 0;
	HRESULT hRes = S_OK;

	//
	// Initialize PERF_OBJECT_TYPE. Get the object index and the number of counters from
	// the collection component
	//

	// NOTE: the index of the object is always zero.  counters then start at 2
	objectIndex = 0;
	int numCounters = GetNumCounters();

	//
	// This is the total length of the data passed to perfmon.  At this point we compute,
	// the length of the known structures.  Later, we will add the length of the data
	//
	long structureLength = sizeof(PERF_OBJECT_TYPE) + 
		                     (numCounters * sizeof(PERF_COUNTER_DEFINITION));

	m_perfObjectType.TotalByteLength      = structureLength;
	m_perfObjectType.DefinitionLength     = structureLength;
	m_perfObjectType.HeaderLength         = sizeof(PERF_OBJECT_TYPE);
	m_perfObjectType.ObjectNameTitleIndex = (objectIndex + dwFirstCounter);
	m_perfObjectType.ObjectNameTitle      = NULL;
	m_perfObjectType.ObjectHelpTitleIndex = (objectIndex + dwFirstHelp);
	m_perfObjectType.ObjectHelpTitle      = NULL;
	m_perfObjectType.DetailLevel          = PERF_DETAIL_NOVICE;
	m_perfObjectType.NumCounters          = numCounters;
	m_perfObjectType.DefaultCounter       = -1;
	m_perfObjectType.NumInstances         = -1;
	m_perfObjectType.CodePage             = 0;
	m_perfObjectType.PerfTime.LowPart     = 0; 
	m_perfObjectType.PerfTime.HighPart    = 0; 
	m_perfObjectType.PerfFreq.LowPart     = 0;
	m_perfObjectType.PerfTime.HighPart    = 0;
	
	//
	// Initialize the PERF_COUNTER_DEFINITION structures
	//
	_ASSERTE(!m_pPerfCounterDefs);
	m_pPerfCounterDefs = new PERF_COUNTER_DEFINITION[numCounters];

	//
	// enumerate through the counters
	//

	// The size of the data to be collected must include the PERF_COUNTER_BLOCK
	// structure
	long sizeofData = sizeof(PERF_COUNTER_BLOCK);

	PerfmonCounterList::iterator it;

	it = mCounters.begin();
	// index will be incremented before use
	long counterIndex = 0;
	for (long i = 0; it != mCounters.end(); i++)
	{
		PerfmonCounter * counter = *it;

		// if it's the same counter, retain the same index, otherwise
		// increment by 2
		if (!counter->SameAsLast())
			counterIndex += 2;
		else
			ASSERT(i > 0);						// first value can't be same as last

		int defaultScale = counter->DefaultScale();
		DWORD type = counter->GetType();

		m_pPerfCounterDefs[i].ByteLength             = sizeof(PERF_COUNTER_DEFINITION);
		m_pPerfCounterDefs[i].CounterNameTitleIndex  = (counterIndex + dwFirstCounter);
		m_pPerfCounterDefs[i].CounterNameTitle       = NULL;
		m_pPerfCounterDefs[i].CounterHelpTitleIndex  = (counterIndex + dwFirstHelp);
		m_pPerfCounterDefs[i].CounterHelpTitle       = NULL;
		m_pPerfCounterDefs[i].DefaultScale           = defaultScale;
		m_pPerfCounterDefs[i].DetailLevel            = PERF_DETAIL_NOVICE;
		m_pPerfCounterDefs[i].CounterType						 = type;

		int size = counter->GetSize();
		m_pPerfCounterDefs[i].CounterSize            = size;

		m_pPerfCounterDefs[i].CounterOffset          = sizeofData;

		sizeofData += size;
	}

	structureLength += sizeofData;

	//
	// Initialize the PERF_COUNTER_BLOCK structure and fix up the sizes we
	// couldn't finish before
	//
	m_perfCounterBlock.ByteLength = sizeofData;
	m_perfObjectType.TotalByteLength      = structureLength;

	//
	// Save the size needed so we don't have to recompute it during collection
	//
	m_sizeNeeded = structureLength;
}


BOOL PerfmonObject::ModuleShutdown()
{
	return TRUE;
}

BOOL PerfmonObject::CollectData(
    LPWSTR  lpValueName,
    LPVOID  *lppData,
    LPDWORD lpcbTotalBytes,
    LPDWORD lpNumObjectTypes)
{
	const char * functionName = "PerfmonObject::CollectData";

	PERF_OBJECT_TYPE *pObjectType = (PERF_OBJECT_TYPE *) *lppData;

	if (*lpcbTotalBytes < (unsigned) GetSizeNeeded())
	{
		*lpcbTotalBytes = (DWORD) 0;
		*lpNumObjectTypes = (DWORD) 0;

		SetError(ERROR_MORE_DATA, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	//
	// Copy the (constant, initialized) Object Type and counter definitions
	//  to the caller's data buffer
	//
	memmove(pObjectType, GetObjectType(), sizeof(PERF_OBJECT_TYPE));

	PERF_COUNTER_DEFINITION *pCounterDef = (PERF_COUNTER_DEFINITION *) (&pObjectType[1]);

	//memmove(pCounterDef, GetCounterDefs(),
	//      (sizeof(PERF_OBJECT_TYPE) * GetNumCounters()));

	memmove(pCounterDef, GetCounterDefs(),
					// bug fixed here!
       (sizeof(PERF_COUNTER_DEFINITION) * GetNumCounters()));


	//int PopulateCounterData(PERF_COUNTER_BLOCK * apPerfCounterBlock

	//PopulateCounterData(


	PERF_COUNTER_BLOCK *pPerfCounterBlock = (PERF_COUNTER_BLOCK *)
		(&pCounterDef[GetNumCounters()]);

	memmove(pPerfCounterBlock,
       GetCounterBlock(),
       sizeof(PERF_COUNTER_BLOCK));

	unsigned char * pCounterData = (unsigned char *) (&pPerfCounterBlock[1]);

	//
	// Get the data for each counter
	//

	PerfmonCounterList::iterator it = mCounters.begin();
	for (int i = 0; it != mCounters.end(); i++)
	{
		PerfmonCounter * counter = *it;

		// attempt to collect the data and fill in the type
		if (!counter->Collect(&pCounterData))
		{
			*lpcbTotalBytes = (DWORD) 0;
			*lpNumObjectTypes = (DWORD) 0;

			SetError(*counter);
			return FALSE;
		}
	}

	//
	// Aim the pointer given to us by perfmon at the next available
	// byte
	//

  // bug fixed here!
	//*lppData = ++pCounterData;
	*lppData = pCounterData;
 
	*lpNumObjectTypes = 1; //We only support one object

	*lpcbTotalBytes = GetSizeNeeded(); 

	return TRUE;
}
