/**************************************************************************
 * @doc CLEARQUEUES
 *
 * Copyright 2000 by MetraTech Corporation
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
#import <MTConfigLib.tlb>
#include <HookSkeleton.h>
#include <mtprogids.h>
#include <ConfigDir.h>
#include <msmqlib.h>
#include <makeunique.h>

#import <MTConfigLib.tlb>

#include <pipelineconfig.h>


// generate using uuidgen

CLSID CLSID_RemoveSessionBin = { // {83CED760-1D43-11d4-99FA-00C04F6DC482}
	0x83ced760, 
	0x1d43, 
	0x11d4, 
	{ 0x99, 0xfa, 0x0, 0xc0, 0x4f, 0x6d, 0xc4, 0x82 } 
};


class ATL_NO_VTABLE RemoveSessionBin :
  public MTHookSkeleton<RemoveSessionBin,&CLSID_RemoveSessionBin>
{
public:
 virtual HRESULT ExecuteHook(VARIANT var, long* pVal);


private:
	HRESULT RemoveSessionBinAll();
};

HOOK_INFO(CLSID_RemoveSessionBin, RemoveSessionBin,
						"MetraHook.PipelineRemoveSessionBin.1", "MetraHook.PipelineRemoveSessionBin", "free")


HRESULT RemoveSessionBin::ExecuteHook(VARIANT var, long* pVal)
{
	ASSERT(pVal);
	if (!pVal)
		return E_POINTER;

	enum
	{
		PIPELINE_STARUP = 1,
		PIPELINE_SHUTDOWN = 2,
	};

	try
	{
		if (*pVal == PIPELINE_STARUP)
			mLogger.LogThis(LOG_DEBUG, "RemoveSessionBin hook running during startup");
		else
			mLogger.LogThis(LOG_DEBUG, "RemoveSessionBin hook running during shutdown");

		return RemoveSessionBinAll();
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

  return S_OK;
}


HRESULT RemoveSessionBin::RemoveSessionBinAll()
{
	//
	// read the main pipeline configuration file
	//

	std::string configDir;
	if (!GetMTConfigDir(configDir))
		return Error("No configuration directory found");

	mLogger.LogThis(LOG_DEBUG, "Reading pipeline configuration file");
	PipelineInfoReader pipelineReader;
	// TODO: have to convert from one namespace to another
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	PipelineInfo pipelineInfo;
	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		mLogger.LogErrorObject(LOG_ERROR, pipelineReader.GetLastError());
		return Error("Unable to read pipeline.xml configuration file");
	}

	// get the location of the session.bin
	std::string sharefilename = pipelineInfo.GetSharedSessionFile();
	// check where or not the file is there

	WIN32_FIND_DATAA	fileData;
	HANDLE hFile;
	hFile = FindFirstFileA(sharefilename.c_str(), &fileData); // ascii version

	if (hFile == INVALID_HANDLE_VALUE)
	{
		mLogger.LogThis(LOG_DEBUG, "The sessions.bin is not there");
		FindClose(hFile);
		return S_OK;
	}
	else
	{
		if(remove(sharefilename.c_str()))
		{
			mLogger.LogThis(LOG_WARNING, "Could not remove the share sessions.bin");
		}
	}
	return S_OK;
}
