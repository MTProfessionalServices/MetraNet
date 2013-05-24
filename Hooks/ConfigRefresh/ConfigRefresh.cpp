/**************************************************************************
 * @doc CONFIGREFRESH
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
 * $Date: 12/1/2000 2:37:51 PM$
 * $Author: Carl Shimer$
 * $Revision: 6$
 ***************************************************************************/

#include <metra.h>

#include <mtcom.h>
#import <MTConfigLib.tlb>
#include <HookSkeleton.h>
#include <mtprogids.h>
#include <ConfigChange.h>


// generate using uuidgen
//CLSID __declspec(uuid("ca4d4950-00c0-11d3-a1e8-006008c0e24a")) CLSID_MTTotalConfCharge;

CLSID CLSID_ConfigRefresh = { /* 3ebbc0d0-23fc-11d3-8db3-00c04f484788 */
    0x3ebbc0d0,
    0x23fc,
    0x11d3,
    {0x8d, 0xb3, 0x00, 0xc0, 0x4f, 0x48, 0x47, 0x88}
  };

class ATL_NO_VTABLE ConfigRefresh :
  public MTHookSkeleton<ConfigRefresh,&CLSID_ConfigRefresh>
{
public:
 virtual HRESULT ExecuteHook(VARIANT var, long* pVal);

};

HOOK_INFO(CLSID_ConfigRefresh, ConfigRefresh,
						"MetraHook.ConfigRefresh.1", "MetraHook.ConfigRefresh", "free")


HRESULT ConfigRefresh::ExecuteHook(VARIANT var, long* pVal)
{
	mLogger.LogThis(LOG_INFO, "Signalling all components to refresh");
	BOOL bResult;

	ConfigChangeEvent event;


	if(var.vt ==  VT_BSTR) {
		_bstr_t aEventName = _variant_t(var);

		// only init with event name if we have a valid string
		if(aEventName.length() != 0) {	
			bResult = event.Init(aEventName);
		}
		else {
			bResult = event.Init();
		}
	}
	else {

		bResult = event.Init();
	}

	if(!bResult) {
		mLogger.LogThis(LOG_ERROR, "Could not initialize config change event");
		mLogger.LogErrorObject(LOG_ERROR, event.GetLastError());
		return event.GetLastError()->GetCode();
	}

	if (!event.Signal())
	{
		mLogger.LogThis(LOG_ERROR, "Could not signal config change event");
		mLogger.LogErrorObject(LOG_ERROR, event.GetLastError());
		return event.GetLastError()->GetCode();
	}
	// also signal the listener as well 
	{
		ConfigChangeEvent aListenerEvent;
		if(!aListenerEvent.Init(_bstr_t("MTServiceDefChangeEvent"))) {
			mLogger.LogThis(LOG_ERROR, "Could not initialize config change event for services collection");
			mLogger.LogErrorObject(LOG_ERROR, event.GetLastError());
			return aListenerEvent.GetLastError()->GetCode();

		}
		if(!aListenerEvent.Signal()) {
			mLogger.LogThis(LOG_ERROR, "Could not signal config change event for services collection");
			mLogger.LogErrorObject(LOG_ERROR, aListenerEvent.GetLastError());
			return aListenerEvent.GetLastError()->GetCode();
		}
		mLogger.LogThis(LOG_INFO,"Signaled the services collection to refresh");

	}

  return S_OK;
}

