/**************************************************************************
 * @doc PERFMON
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
 * @index | PERFMON
 ***************************************************************************/

//
// Loosely based on the MSDN sample:
//
//   Instrumenting Windows NT Applications with Performance Monitor
//   Steven Pratschner, 
//   Microsoft Consulting Services
//   September 30, 1997 
//

#ifndef _PERFMON_H
#define _PERFMON_H

#include <winperf.h>
#include <errobj.h>

class PerfmonObject;
class PerfmonRegistration;

/******************************************** PerfmonCounter ***/

// the interface all counters must conform to.
// NOTE: you can normally use SimplePerfmonCounter or PerfmonCounterImpl instead.
class PerfmonCounter : public virtual ObjectWithError
{
	// the object class has to call the methods
	friend PerfmonObject;
	friend PerfmonRegistration;

public:
	virtual ~PerfmonCounter()
	{ }

	// return the internal name
	virtual const char * GetInternalName() const = 0;

	// return the name displayed in perfmon
	virtual const char * GetName() const = 0;

	// return the help text displayed in perfmon
	virtual const char * GetHelpText() const = 0;

protected:
	// returns the type of the counter.  See winperf.h for examples
	virtual DWORD GetType() const = 0;

	// if true, this counter is "chained" to the previous one and uses the
	// same index.  For example, can be used for returning percentages where
	// PERF_RAW_FRACTION value must be followed by a PERF_RAW_BASE.
	virtual BOOL SameAsLast() const
	{ return FALSE; }

	// override to change the default scale.  0 = 10^0 = 1, 1 = 10^1 = 10, etc
	virtual int DefaultScale() const
	{ return 0; }

	// store your counter value in memory and advance the
	// pointer past it.
	virtual BOOL Collect(unsigned char * * apBuffer) = 0;

	// return the size of the counter value.
	virtual int GetSize() const = 0;
};


/**************************************** PerfmonCounterImpl ***/

// implementation of Collect and GetSize
template<class DATA_TYPE>
class PerfmonCounterImpl : public PerfmonCounter
{
private:
	// store your counter value in memory and advance the
	// pointer past it.
	BOOL Collect(unsigned char * * apBuffer)
	{
		DATA_TYPE * buffer = (DATA_TYPE *) *apBuffer;

		// call the Collect function appropriate to this type
		if (!Collect(*buffer))
			return FALSE;

		// size is constant
		*apBuffer += sizeof(DATA_TYPE);

		return TRUE;
	}

	// return the size of the counter value.
	int GetSize() const
	{ return sizeof(DATA_TYPE); }

protected:
	// sub class must now override this Collect
	virtual BOOL Collect(DATA_TYPE & arValue) = 0;
};


/**************************************** PerfmonCounterImpl ***/

// helper function that does everything PerfmonCounter does but also
// returns the type of the data, leaving only Collect to be implemented.

template<class DATA_TYPE, DWORD PERF_TYPE>
class SimplePerfmonCounter : public PerfmonCounterImpl<DATA_TYPE>
{
	// returns the type of the counter.  See winperf.h for examples
	virtual DWORD GetType() const
	{ return PERF_TYPE; }
};

//
// helper class for any counters that are the same as the previous counter
// (for example PERF_RAW_FRACTION followed by PERF_RAW_BASE)
//
template<class DATA_TYPE, DWORD PERF_TYPE>
class ChainedPerfmonCounter : public SimplePerfmonCounter<DATA_TYPE, PERF_TYPE>
{
private:
	BOOL SameAsLast() const
	{ return TRUE; }
};

//
// common uses of SimplePerfmonCounter
//

// used to display n/sec values
typedef SimplePerfmonCounter<DWORD, PERF_COUNTER_COUNTER> PerfmonPerSecondCounter;

// used to display raw values (counts) that have no suffix
typedef SimplePerfmonCounter<DWORD, PERF_COUNTER_RAWCOUNT> PerfmonRawCounter;

// these two go hand in hand.  A base must always be added to the perfmon
// object after the fraction.  combined to display (fraction / base) * 100 %
typedef SimplePerfmonCounter<DWORD, PERF_RAW_FRACTION> PerfmonFraction;
typedef ChainedPerfmonCounter<DWORD, PERF_RAW_BASE> PerfmonBase;

/******************************************* PerfmonInstance ***/

// An instance of an object.  Used to display counters
// for multiple things. (for example, memory use for each process).

#if 0
class PerfmonInstance
{
	friend PerfmonObject;

public:
	//PERF_INSTANCE_DEFINITION

	std::wstring & GetName() const
	{ return mInstanceName; }

	int GetUniqueID() const
	{ return mUniqueID; }

private:
	std::wstring & arName;
	int mUniqueID;
};
#endif

/********************************************* PerfmonObject ***/

//
// PerfmonObject represents a custom object being added as a perfmon
// counter.
//

class PerfmonObject : public ObjectWithError
{
	friend class PerfmonRegistration;
public:
	// list of counter objects
	typedef list<PerfmonCounter *> PerfmonCounterList;

public:
	PerfmonObject();
	virtual ~PerfmonObject(); 

	// add required keys to the registry and call lodctr
	BOOL Register(const char * apDLLName);
	BOOL Register(HINSTANCE hIstance);

	// call unlodctr
	BOOL Unregister();

	// called by DLL extry point to initialize the object
	BOOL ModuleInitialize();

	// called by DLL extry point to cleanup the object
	BOOL ModuleShutdown();

	// called by DLL extry point to collect the data
	BOOL CollectData(LPWSTR lpValueName, LPVOID *lppData, LPDWORD lpcbTotalBytes,
									 LPDWORD lpNumObjectTypes);

	// return the internal name
	virtual const char * GetInternalName() const = 0;

	// return the name displayed in perfmon
	virtual const char * GetName() const = 0;

	// return the help text displayed in perfmon
	virtual const char * GetHelpText() const = 0;

	PerfmonCounterList & GetCounters()
	{ return mCounters; }

protected:
	virtual BOOL Init() = 0;

	void AddCounter(PerfmonCounter & arCounter)
	{ mCounters.push_back(&arCounter); }

private:
	void InitializePerfmonData(DWORD dwFirstCounter, DWORD dwFirstHelp);

	long GetSizeNeeded() const
	{ return m_sizeNeeded; }

	PERF_OBJECT_TYPE *GetObjectType()
	{ return &m_perfObjectType; }

	PERF_COUNTER_DEFINITION *GetCounterDefs()
	{ return m_pPerfCounterDefs; }

	PERF_COUNTER_BLOCK *GetCounterBlock()
	{ return &m_perfCounterBlock; }

	int GetNumCounters() const
	{ return mCounters.size(); }

private:
	// the perfmon structure describing this object
	PERF_OBJECT_TYPE m_perfObjectType;

	// an array of perfmon structures describing each counter
	PERF_COUNTER_DEFINITION *m_pPerfCounterDefs;

	// the perfmon structure that is placed just before the counter data
	PERF_COUNTER_BLOCK m_perfCounterBlock;

	// the size of the block of memory handed to perfmon
	long m_sizeNeeded;

	PerfmonCounterList mCounters;
};

/************************************ DLL entry point macros ***/

// Example of use:
//
// PipelineCounters gCounters;
// DEFINE_PERF_ENTRIES(gCounters)

// NOTE: you must still be sure to export the functions
//       OpenPerfData, CollectPerfData, and ClosePerfData
#define CallConvention WINAPI
#define ExportDefinition __declspec(dllexport)



#define REGISTER_PERF_COUNTER(instance)											\
ExportDefinition DWORD CallConvention RegisterPerfCounter()	\
{																														\
  if (!instance.Register(hDllInstance))												\
    return instance.GetLastError()->GetCode();							\
																														\
	return ERROR_SUCCESS;																			\
}

#define UNREGISTER_PERF_COUNTER(instance)				\
ExportDefinition DWORD CallConvention UnregisterPerfCounter()					\
{																								\
  if (!instance.Unregister())										\
    return instance.GetLastError()->GetCode();	\
																								\
	return ERROR_SUCCESS;													\
}


#define OPEN_PERF_DATA(instance)									\
ExportDefinition DWORD CallConvention OpenPerfData(LPWSTR lpDeviceNames)	\
{																									\
	if (!instance.ModuleInitialize())								\
		return instance.GetLastError()->GetCode();		\
																									\
	return ERROR_SUCCESS;														\
}

#define COLLECT_PERF_DATA(instance)																										\
ExportDefinition DWORD CallConvention CollectPerfData(LPWSTR  lpValueName, LPVOID  *lppData,									\
    LPDWORD lpcbTotalBytes, LPDWORD lpNumObjectTypes)																	\
{																																											\
	if (!instance.CollectData(lpValueName, lppData, lpcbTotalBytes, lpNumObjectTypes))	\
		return instance.GetLastError()->GetCode();																				\
																																											\
	return ERROR_SUCCESS;																																\
}

#define CLOSE_PERF_DATA(instance)								\
ExportDefinition DWORD CallConvention ClosePerfData()									\
{																								\
	instance.ModuleShutdown();										\
	return 0;																			\
}

#define DEFINE_PERF_ENTRIES(object)							\
  REGISTER_PERF_COUNTER(object)									\
  UNREGISTER_PERF_COUNTER(object)								\
  OPEN_PERF_DATA(object)												\
  COLLECT_PERF_DATA(object)											\
  CLOSE_PERF_DATA(object)

#define DECLARE_PERF_ENTRIES()																				\
ExportDefinition DWORD CallConvention RegisterPerfCounter();						\
ExportDefinition DWORD CallConvention UnregisterPerfCounter();																\
ExportDefinition DWORD CallConvention OpenPerfData(LPWSTR lpDeviceNames);										\
ExportDefinition DWORD CallConvention CollectPerfData(LPWSTR  lpValueName, LPVOID  *lppData,	\
    LPDWORD lpcbTotalBytes, LPDWORD lpNumObjectTypes);								\
ExportDefinition DWORD CallConvention ClosePerfData();




/*************************************** PerfmonRegistration ***/

class PerfmonRegistration : public virtual ObjectWithError
{
public:
	BOOL Register(PerfmonObject & arPerf, const char * apDLLName);
	BOOL Unregister(PerfmonObject & arPerf);

private:
	static long UnlodCtr(const char * apInternalName);

	BOOL AddPerformanceData(PerfmonObject & arPerf);
	BOOL AddPerformanceKey(const wchar_t * apAppName,
												 const wchar_t * apDLLName);

private:
	static const char * sHdrFileName;
	static const char * sIniFileName;
	static const char * sEnglish;
	static const char * sDefine;
	static const char * sName;
	static const char * sHelp;
};

#endif /* _PERFMON_H */
