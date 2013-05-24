/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/
#include <metra.h>
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") rename ("IMTSecurity", "IMTSecurityPipe") no_function_mapping
#include <MTSessionBaseDef.h>
#include "PCCacheImpl.h"

int APIENTRY DllMain(HANDLE hModule, DWORD reasonForCall, LPVOID lpReserved)
{
	switch (reasonForCall)
	{
		case DLL_PROCESS_ATTACH:
			break;

		case DLL_THREAD_ATTACH:
			break;

		case DLL_THREAD_DETACH:
			break;

		case DLL_PROCESS_DETACH:
			PCCacheImpl::DeleteInstance();
			break;
	}
	return 1;
}

