/**************************************************************************
 * @doc PIPESTARTSTOP
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
//#include <mtprogids.h>


// generate using uuidgen

CLSID CLSID_PipeStartStop = { /* c3f88150-ea3a-11d3-a3fe-00c04f484788 */
    0xc3f88150,
    0xea3a,
    0x11d3,
    {0xa3, 0xfe, 0x00, 0xc0, 0x4f, 0x48, 0x47, 0x88}
  };


class ATL_NO_VTABLE PipeStartStop :
  public MTHookSkeleton<PipeStartStop,&CLSID_PipeStartStop>
{
public:
 virtual HRESULT ExecuteHook(VARIANT var, long* pVal);


private:
	HRESULT PipelineStartup();
	HRESULT PipelineShutdown();
};

HOOK_INFO(CLSID_PipeStartStop, PipeStartStop,
						"MetraHook.PipelineStartStop.1", "MetraHook.PipelineStartStop", "free")


HRESULT PipeStartStop::ExecuteHook(VARIANT var, long* pVal)
{
	ASSERT(pVal);
	if (!pVal)
		return E_POINTER;

	enum
	{
		PIPELINE_STARUP = 1,
		PIPELINE_SHUTDOWN = 2,
	};

	if (*pVal == PIPELINE_STARUP)
		return PipelineStartup();
	else
		return PipelineShutdown();

  return S_OK;
}




HRESULT PipeStartStop::PipelineStartup()
{
	mLogger.LogThis(LOG_DEBUG, "Pipeline startup hook running");

	return S_OK;
}


HRESULT PipeStartStop::PipelineShutdown()
{
	mLogger.LogThis(LOG_DEBUG, "Pipeline shutdown hook running");

	return S_OK;
}
