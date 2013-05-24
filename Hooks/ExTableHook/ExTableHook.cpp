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
 * Created by: Carl Shimer
 *
 * $Header$
 ***************************************************************************/

#include <metra.h>

#include <mtcom.h>
#import <MTConfigLib.tlb>
#include <HookSkeleton.h>
#include <mtprogids.h>
#include <ExtendedProp.h>
#include <mtglobal_msg.h>

#import <MTProductCatalogExec.tlb> rename ("EOF", "RowsetEOF") 
#import <MTProductCatalog.tlb> rename ("EOF", "RowsetEOF") 

// generate using uuidgen
//CLSID __declspec(uuid("9e888dca-4794-43e3-8643-798f16c4a5ac")) CLSID_ExTableHook;

CLSID CLSID_ExTableHook = { /*9e888dca-4794-43e3-8643-798f16c4a5ac */
    0x9e888dca,
    0x4794,
    0x43e3,
    {0x86, 0x43, 0x79, 0x8f, 0x16, 0xc4, 0xa5, 0xac}
  };

class ATL_NO_VTABLE ExTableHook :
  public MTHookSkeleton<ExTableHook,&CLSID_ExTableHook>
{
public:
 virtual HRESULT ExecuteHook(VARIANT var, long* pVal);
 
 // ctor
 ExTableHook() {}

protected:
	ExtendedPropCollection mExtendedPropCol;
};

HOOK_INFO(CLSID_ExTableHook, ExTableHook,
						"MetraHook.ExTableHook.1", "MetraHook.ExTableHook", "free")


HRESULT ExTableHook::ExecuteHook(VARIANT var, long* pVal)
{
	HRESULT hr = E_FAIL;
	try {
		if(mExtendedPropCol.Init()) {
			_variant_t vtArg(var);
			if(vtArg.vt == VT_BOOL && (bool)vtArg == true) {
				mLogger.LogThis(LOG_INFO,"dropping extended property tables");
				if(!mExtendedPropCol.DropTables()) {
					// this is not an error, but log it.  Return S_FALSE
					// in case anybody really cares.
					mLogger.LogThis(LOG_WARNING,"Failure while dropping extended property tables");
					hr = S_FALSE;
				}
				else {
					hr = S_OK;
				}
			}
			else {
				mLogger.LogThis(LOG_INFO,"Synchronizing extended property tables");
				
				MTPRODUCTCATALOGEXECLib::IMTDDLWriterPtr writer (__uuidof(MTPRODUCTCATALOGEXECLib::MTDDLWriter));
				hr = writer->SyncExtendedPropertyTables(NULL); //TODO: replace NULL with SessionContext once we have one!!
				
				MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
				hr = pc->ClearCache();
			}
		}
		else {
			DWORD errorCode = mExtendedPropCol.GetLastErrorCode();
			if (errorCode == CORE_ERR_NOMSIXFILEFILES_FOUND)
			{	mLogger.LogThis(LOG_INFO,"Nothing to do, no extended property files found");
				hr = S_OK;
			}
			else
				mLogger.LogThis(LOG_ERROR,"Failed to initialize extended property collection");
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return hr;
}

