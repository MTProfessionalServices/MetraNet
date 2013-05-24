/**************************************************************************
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
 * Created by: Ralf Boeck
 *
 * $Header$
 ***************************************************************************/

#include <metra.h>
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <RowsetDefs.h>

#include <HookSkeleton.h>
#include <ParamTable.h>

#import <MTProductCatalogExec.tlb> rename ("EOF", "RowsetEOF") 

// generate using uuidgen
CLSID CLSID_ParamTableHook = // {FA6A0E2E-FDBF-48b6-B8D6-64210894C032}
		{ 0xfa6a0e2e, 0xfdbf, 0x48b6, { 0xb8, 0xd6, 0x64, 0x21, 0x8, 0x94, 0xc0, 0x32 } };


class ATL_NO_VTABLE ParamTableHook : public MTHookSkeleton<ParamTableHook,&CLSID_ParamTableHook>
{
	public:
		 virtual HRESULT ExecuteHook(VARIANT var, long* pVal);
};

HOOK_INFO(CLSID_ParamTableHook, ParamTableHook,
						"MetraHook.ParamTableHook.1", "MetraHook.ParamTableHook", "free")


HRESULT ParamTableHook::ExecuteHook(VARIANT var, long* pVal)
{
	try
	{
		mLogger.LogThis(LOG_INFO, "Starting hook execution.");

		_variant_t vtArg(var);
		if (vtArg.vt == VT_BOOL && (bool)vtArg == true)
		{
				mLogger.LogThis(LOG_INFO,"dropping parameter tables");

				ParamTableCollection paramTables;
				if(paramTables.Init())
				{
					if(!paramTables.DropTables())
					{
						// this is not an error, but log it.  Return S_FALSE
						// in case anybody really cares.
						mLogger.LogThis(LOG_WARNING,"Failure while dropping parameter tables");
						return S_FALSE;
					}
				}
				else
				{
					mLogger.LogThis(LOG_WARNING, "Failed to initialize param table collection");
					return Error("Failed to initialize param table collection");
				}
		}
		else
		{
			mLogger.LogThis(LOG_INFO, "Creating Product Catalog parameter tables");

			// TODO: this is NOT the right way to construct the session context.
			// We should really retrieve the credentials and login as the user invoking the script
			MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr
				context(MTPROGID_MTSESSIONCONTEXT);
			context->PutAccountID(0);

			//let the ParamTableDefinitionWriter do the work to have transactionality
			MTPRODUCTCATALOGEXECLib::IMTDDLWriterPtr writer (__uuidof(MTPRODUCTCATALOGEXECLib::MTDDLWriter));
			writer->SyncParameterTables(context);
		}
		
		mLogger.LogThis(LOG_DEBUG, "Finished Product Catalog parameter table hook");
	}
	catch (_com_error & err)
	{
		mLogger.LogThis(LOG_ERROR, "Failed to execute hook");
		return ReturnComError(err);
	}

	return S_OK;
}
