/**************************************************************************
 * @doc REGISTER
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

#include <metra.h>
#include <perfmon.h>

#include <loadperf.h>

#include <MTUtil.h>
#include <NTRegistryIO.h>
#include <mttemp.h>
#include <mtglobal_msg.h>

#include <shlwapi.h>

const char * PerfmonRegistration::sHdrFileName = "counters.h";
const char * PerfmonRegistration::sIniFileName = "counters.ini";
const char * PerfmonRegistration::sEnglish = "009";
const char * PerfmonRegistration::sDefine  = "#define ";
const char * PerfmonRegistration::sName  = "_name=";
const char * PerfmonRegistration::sHelp  = "_help=";

BOOL PerfmonRegistration::Register(PerfmonObject & arPerf, const char * apDLLName)
{
	const char * name = arPerf.GetInternalName();

	//const RWCString & name(arPerf.GetInternalName());
	std::wstring wideName;
	ASCIIToWide(wideName, name, strlen(name));


	std::wstring dll;
	ASCIIToWide(dll, apDLLName, strlen(apDLLName));

	return (AddPerformanceKey(wideName.c_str(), dll.c_str())
					&& AddPerformanceData(arPerf));
}

BOOL PerfmonRegistration::Unregister(PerfmonObject & arPerf)
{
	const char * functionName = "PerfmonRegistration::Unregister";

	const char * name = arPerf.GetInternalName();

	long result = UnlodCtr(name);
	if (result != 0)
	{
		// result is the winerror
		SetError(result, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	// NOTE: this assumes the service is already created
	std::string keyName("SYSTEM\\CurrentControlSet\\Services\\");
	keyName += name;
	keyName += "\\Performance";

	result = ::SHDeleteKeyA(HKEY_LOCAL_MACHINE, keyName.c_str());
	if (result != ERROR_SUCCESS)
	{
		SetError(result, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	return TRUE;
}


BOOL PerfmonRegistration::AddPerformanceKey(const wchar_t * apAppName,
																						const wchar_t * apDLLName)
{
	const char * functionName = "PerfmonRegistration::AddPerformanceKey";

	NTRegistryIO registry;

	// NOTE: this assumes the service is already created
	std::wstring keyName(L"SYSTEM\\CurrentControlSet\\Services\\");
	keyName += apAppName;
	keyName += L"\\Performance";
	if (!registry.CreateKey(NTRegistryIO::LOCAL_MACHINE, keyName.c_str(),
													NTRegistryIO::WRITE_ACCESS))
	{
		SetError(registry.GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}


	// add keys to hook the extcounters dll
	if (!(registry.WriteRegistryValue(L"Close", L"ClosePerfData")
				&& registry.WriteRegistryValue(L"Collect", L"CollectPerfData")
				&& registry.WriteRegistryValue(L"Open", L"OpenPerfData")
				&& registry.WriteRegistryValue(L"Library", apDLLName)))
	{
		SetError(registry.GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	return TRUE;
}

BOOL PerfmonRegistration::AddPerformanceData(PerfmonObject & arPerf)
{
	const char * functionName = "PerfmonRegistration::AddPerformanceData";

	// 
	// Generate the header file and the .ini file and call the lodctr api
	//
	std::string hdrFile;
	std::string iniFile;

	const char * name = arPerf.GetName();
	const char * internalName = arPerf.GetInternalName();
	const char * helpText = arPerf.GetHelpText();

	TemporaryFile hdrTempObj;
	const std::string & hdrName = hdrTempObj.GenerateName();

	//
	// Intro sections of .ini file
	//
	iniFile.append("[info]\n");

	iniFile.append("drivername=");
	iniFile.append(internalName);
	iniFile.append("\n");

	iniFile.append("symbolfile=");
	iniFile.append(hdrName);
	iniFile.append("\n\n");
	iniFile.append("[languages]\n");
	iniFile.append(sEnglish);
	iniFile.append("=English\n\n");
	iniFile.append("[text]\n");

	long objectIndex = 0;

	//
	// Object #define
	//
	hdrFile.append(sDefine);
	hdrFile.append(internalName); 

	char buffer[100];
	sprintf(buffer, " %ld\n", objectIndex);
	hdrFile.append(buffer);
	
	//
	// object name, and help
	//
	iniFile.append(internalName);
	iniFile.append("_");
	iniFile.append(sEnglish);
	iniFile.append(sName);
	iniFile.append(name);
	iniFile.append("\n");

	iniFile.append(internalName);
	iniFile.append("_");
	iniFile.append(sEnglish);
	iniFile.append(sHelp);
	iniFile.append(helpText);
	iniFile.append("\n");

	//
	// Iterate through each counter, adding entries to the header and ini files
	//

	PerfmonObject::PerfmonCounterList::iterator it;

	it = arPerf.GetCounters().begin();

	// index will be incremented before use
	long counterIndex = 0;

	for (int i = 0; it != arPerf.GetCounters().end(); i++)
	{
		PerfmonCounter * counter = *it;
		// they will be doubled up if they're in pairs
		if (counter->SameAsLast())
			continue;

		// if it's the same counter, retain the same index, otherwise
		// increment by 2
		if (!counter->SameAsLast())
			counterIndex += 2;
		else
			ASSERT(i > 0);						// first value can't be same as last

		name = counter->GetName();
		internalName = counter->GetInternalName();
		helpText = counter->GetHelpText();

		//
		// Counter #define
		//
		hdrFile.append(sDefine);
		hdrFile.append(internalName); 
		sprintf(buffer, " %ld\n", counterIndex);
		hdrFile.append(buffer);

		//
		// object name, and help
		//
		iniFile.append(internalName);
		iniFile.append("_");
		iniFile.append(sEnglish);
		iniFile.append(sName);
		iniFile.append(name);
		iniFile.append("\n");

		iniFile.append(internalName);
		iniFile.append("_");
		iniFile.append(sEnglish);
		iniFile.append(sHelp);
		iniFile.append(helpText);
		iniFile.append("\n");
	}


	TemporaryFile iniTempObj;
	FILE * iniTemp = iniTempObj.Open("w");
	if (!iniTemp || fwrite(iniFile.c_str(), iniFile.length(), 1, iniTemp) != 1)
	{
		SetError(CORE_ERR_UNKNOWN_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}
	fclose(iniTemp);

	FILE * hdrTemp = hdrTempObj.Open("w");
	if (!hdrTemp || fwrite(hdrFile.c_str(), hdrFile.length(), 1, hdrTemp) != 1)
	{
		SetError(CORE_ERR_UNKNOWN_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}
	fclose(hdrTemp);

	// unload (if they're there already), then reload the values
	internalName = arPerf.GetInternalName();

	// NOTE: result of unload is ignored since it may or may not already exist
	long result = UnlodCtr(internalName);

	// the program name has to be the first argument to the loadperfcounter functions
	std::string buf("lodctr ");
	buf += iniTempObj.GetFileName();
	char * cmdline = const_cast<char *>(buf.c_str());

	// NOTE: last argument to both these functions is the "quiet" flag
	result =
		::LoadPerfCounterTextStringsA(cmdline, TRUE);

	if (result != 0)
	{
		// result is the winerror
		SetError(result, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	return TRUE;
}

long PerfmonRegistration::UnlodCtr(const char * apInternalName)
{
	// the program name has to be the first argument to the unloadperfcounter functions
	std::string buf("unlodctr ");
	buf += apInternalName;
	char * cmdline = const_cast<char *>(buf.c_str());

	// NOTE: last argument to both these functions is the "quiet" flag
	return ::UnloadPerfCounterTextStringsA(cmdline, TRUE);
}
