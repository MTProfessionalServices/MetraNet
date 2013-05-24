/**************************************************************************
 * @doc TEST
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
#include <perfobj.h>

#include <pdh.h>

#include <iostream>
using namespace std;

void Browse()
{
	PDH_BROWSE_DLG_CONFIG browseConfig;

	browseConfig.bIncludeInstanceIndex = FALSE;
	browseConfig.bSingleCounterPerAdd = FALSE;
	browseConfig.bSingleCounterPerDialog = TRUE;
	browseConfig.bLocalCountersOnly = TRUE;
	browseConfig.bWildCardInstances = TRUE;
	browseConfig.bHideDetailBox = TRUE;
	browseConfig.bInitializePath = FALSE;
	browseConfig.bDisableMachineSelection = TRUE;
	browseConfig.bIncludeCostlyObjects = TRUE;
//	browseConfig.bShowObjectBrowser = TRUE;
	browseConfig.bReserved = FALSE;

	char buffer[1024];
	browseConfig.hWndOwner = NULL;
	browseConfig.szDataSource = NULL;
	browseConfig.szReturnPathBuffer = buffer;
	browseConfig.cchReturnPathLength = sizeof(buffer);
	browseConfig.pCallBack = NULL;
	browseConfig.dwCallBackArg = NULL;
	browseConfig.CallBackStatus = 0;
	browseConfig.dwDefaultDetailLevel = 0;
	browseConfig.szDialogBoxCaption = "Select performance counter";

	PDH_STATUS stat = ::PdhBrowseCounters(&browseConfig);
	cout << browseConfig.szReturnPathBuffer;
}

int main(int argc, char * argv[])
{
	if (argc < 2)
	{
		cout << "usage to register perfmon support: " << argv[0] << " -register" << endl;
		cout << "usage to unregister perfmon support: "<< argv[0] << " -unregister" << endl;
		return 1;
	}

	if (0 == strcmp(argv[1], "-unregister"))
	{
		cout << "Unregistering Pipeline perfmon counters" << endl;
		DWORD err = UnregisterPerfCounter();
		if (err != ERROR_SUCCESS)
		{
			cout << "Error uninstalling Pipeline perfmon counters: "
					 << hex << err << dec << endl;
			return -1;
		}
		cout << "Successfully uninstalled Pipeline perfmon counters" << endl;
		return 0;
	}
	else if (0 == strcmp(argv[1], "-browse"))
	{
		// undocumented option to print a pdh counter string from a browse window
		Browse();
		return 0;
	}

	cout << "Installing Pipeline perfmon counters" << endl;
	DWORD err = RegisterPerfCounter();
	if (err != ERROR_SUCCESS)
	{
		cout << "Error installing Pipeline perfmon counters:" << hex << err << dec << endl;
		return -1;
	}

	cout << "Successfully installed Pipeline perfmon counters" << endl;
	return 0;
}
