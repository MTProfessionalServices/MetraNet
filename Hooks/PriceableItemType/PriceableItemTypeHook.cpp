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
 * Created by: Kevin Boucher
 *
 * $Header$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#import <RCD.tlb>

#include <HookSkeleton.h>
#include <mtprogids.h>
#include <SetIterate.h>

#include <RcdHelper.h>

// Import Noah's VB Object - MTServiceWizard.tlh tells us what we need to import
#import <Msvbvm60.dll> rename("EOF", "EOFX") rename("RGB","RGBX")
#import <msxml3.dll>
#import <MTServiceWizard.dll>
using namespace MTServiceWizard;

// generate using uuidgen
//CLSID __declspec(uuid("289ad4ae-ec45-4f66-9327-fcfe3dea149f")) CLSID_PriceableItemTypeHook;

CLSID CLSID_PriceableItemTypeHook = { /* 289ad4ae-ec45-4f66-9327-fcfe3dea149f */
    0xc8d1a63e,
    0x678d,
    0x4db4,
    {0x93, 0x27, 0xfc, 0xfe, 0x3d, 0xea, 0x14, 0x9f}
  };

class ATL_NO_VTABLE PriceableItemTypeHook :
  public MTHookSkeleton<PriceableItemTypeHook,&CLSID_PriceableItemTypeHook>
{
public:
 virtual HRESULT ExecuteHook(VARIANT var, long* pVal);
 
 // ctor
 PriceableItemTypeHook(){}

protected:
 
private:
 RCDLib::IMTRcdPtr mRCD;
};

HOOK_INFO(CLSID_PriceableItemTypeHook, PriceableItemTypeHook,
						"MetraHook.PriceableItemTypeHook.1", "MetraHook.PriceableItemTypeHook", "free")

						
HRESULT PriceableItemTypeHook::ExecuteHook(VARIANT var, long* pVal)
{
	HRESULT hr = S_OK;
  
	try {
		 RCDLib::IMTRcdFileListPtr aFileList;
	   mRCD = RCDLib::IMTRcdPtr(MTPROGID_RCD);
		 const _bstr_t aQuery("config\\PriceableItems\\*.xml");

     // Welcome to the Priceable Item Hook
		 mLogger.LogThis(LOG_INFO, "Running PriceableItem Hook...");
		 
     aFileList = mRCD->RunQuery(aQuery,VARIANT_TRUE);
		 SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
     
		 hr = it.Init(aFileList);
		 if(FAILED(hr)) 
			 return hr;
		 

		 _PriceableItemPtr pobjPI("MTServiceWizard.PriceableItem");  // Get VB object... look in .tlh

		 // Load each priceable item type
		 while (TRUE)
		 {
			 _variant_t aVariant= it.GetNext();
			 _bstr_t afile = aVariant;

			 if(afile.length() == 0) break;
			 
			 mLogger.LogThis(LOG_INFO, BSTR(afile));  // log filename

			 // Load PriceableItem Type into Database	
			 pobjPI->LoadFromXML(BSTR(afile));
       pobjPI->SaveToDB(true);
		 }
     
		 mLogger.LogThis(LOG_INFO, "Success:  PriceableItem Hook Done!");  // log filename
		 
		}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}


	return S_OK;
}













