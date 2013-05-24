/**************************************************************************
 * @doc SIMPLE
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
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#include <comutil.h>
#include <mtcomerr.h>
#include <HookSkeleton.h>
#include <mtprogids.h>
#include <installutil.h>
#include <SetIterate.h>
#include <autologger.h>

#include <stdutils.h>
#import <RCD.tlb>
#include <RcdHelper.h>



CLSID CLSID_MTRegisterExtensionObjects = { // 35155dc0-960b-11d4-a64e-00c04f579c39
    0x35155dc0,
    0x960b,
    0x11d4,
    {0xA6,0x4E,0x00,0xC0,0x4F,0x57,0x9C,0x39}
  };

namespace {
	char pProgId[] = "MetraHook.RegisterExtensionObjects.1";
};


class ATL_NO_VTABLE MTRegisterExtensionObjects :
  public MTHookSkeleton<MTRegisterExtensionObjects,&CLSID_MTRegisterExtensionObjects>
{
public:
 virtual HRESULT ExecuteHook(VARIANT var,long* pVal);
	MTAutoInstance<MTAutoLoggerImpl<pProgId> >			mLogger;

};

HOOK_INFO(CLSID_MTRegisterExtensionObjects, MTRegisterExtensionObjects,
						"MetraHook.RegisterExtensionObjects.1", "MetraHook.RegisterExtensionObjects", "both")


/////////////////////////////////////////////////////////////////////////////
//MTTariffHook::ExecuteHook
/////////////////////////////////////////////////////////////////////////////

#define HANDLE_ERR(a,b)  \
  if(a) { \
  hr = Error(b); break; \
  } \


HRESULT MTRegisterExtensionObjects::ExecuteHook(VARIANT var,long* pVal)
{
	HRESULT hr = S_OK;
	try {

		// step 2: use the RCD to find a list of all the DLLs in the bin directory
		RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
		aRCD->Init();


		// step 1: the expected argument is the short or long name of an extension.  If nothing 
		// is specified, reregister all of the objects

		mtstring szExtension;
		RCDLib::IMTRcdFileListPtr aFileList;

		if(var.vt ==  VT_BSTR) {
			_bstr_t aSpecifiedExtension = _variant_t(var);
			if(aSpecifiedExtension.length() != 0) {
				szExtension = (const char*)aSpecifiedExtension;

				if(szExtension.find(":") == string::npos) {
				// if we did not find it
				mtstring szFullExtension = aRCD->GetExtensionDir();
				szFullExtension += DIR_SEP;
				szFullExtension += szExtension;
				szExtension = szFullExtension;
				}

				aFileList = aRCD->RunQueryInAlternateFolder("bin\\*.dll",VARIANT_TRUE,(const char*)szExtension);
			}
			else {
				szExtension = (const char*)aRCD->GetExtensionDir();
				aFileList = aRCD->RunQuery("*.dll",VARIANT_TRUE);
			}
		}
		else {
			szExtension = (const char*)aRCD->GetExtensionDir();
			aFileList = aRCD->RunQuery("*.dll",VARIANT_TRUE);
		}

		SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
		
		if(FAILED(it.Init(aFileList))) return FALSE;
		while (TRUE)
		{
			_variant_t aVariant= it.GetNext();
			_bstr_t afile = aVariant;
			if(afile == _bstr_t("")) break;

			// step 3: register them through installutil.  Do do any logging in installutil
			if(!RegisterComServer(afile,FALSE)) {
				mLogger->LogVarArgs(LOG_WARNING,"failed to register %s",(const char*)afile);
				hr = S_FALSE;
			}
		}
	}
	catch(_com_error& e) {
		hr = ReturnComError(e);
	}
	return hr;
}
