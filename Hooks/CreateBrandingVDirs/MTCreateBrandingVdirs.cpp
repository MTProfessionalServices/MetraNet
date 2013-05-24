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
#include <comip.h>
#include <HookSkeleton.h>
#include <mtprogids.h>
#include <adsiutil.h>
#include <KioskDefs.h>
#include <comip.h>
#include <MTUtil.h>
#include <stdutils.h>

#include <ConfigDir.h>

// generate using uuidgen
//CLSID __declspec(uuid("ddec85d0-258f-11d3-a5a4-00c04f579c39")) CLSID_MTCreateBrandingVDirs;

CLSID CLSID_MTCreateBrandingVDirs = { // ddec85d0-258f-11d3-a5a4-00c04f579c39
    0xddec85d0,
    0x258f,
    0x11d3,
    {0xa5,0xa4,0x00,0xc0,0x4f,0x57,0x9c,0x39}
  };

class ATL_NO_VTABLE MTCreateBrandingVDirs :
  public MTHookSkeleton<MTCreateBrandingVDirs,&CLSID_MTCreateBrandingVDirs>
{
public:
 virtual HRESULT ExecuteHook(VARIANT var,long* pVal);

};

HOOK_INFO(CLSID_MTCreateBrandingVDirs, MTCreateBrandingVDirs,
						"MetraHook.MTCreateBrandingVDirs.1", "MetraHook.MTCreateBrandingVDirs", "free")

#define MPS_VDIR "mps"
#define CSR_VDIR "csr"

/////////////////////////////////////////////////////////////////////////////
//MTTariffHook::ExecuteHook
/////////////////////////////////////////////////////////////////////////////

#define HANDLE_ERR(a,b)  \
  if(a) { \
  hr = Error(b); break; \
  } \


#import <MTCLoader.tlb>

/////////////////////////////////////////////////////////////////////////////
// Function name	: MTCreateBrandingVDirs::ExecuteHook
// Description	    : 
// Return type		: HRESULT 
// Argument         : IUnknown* pUnk
// Argument         : unsigned long* pVal
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTCreateBrandingVDirs::ExecuteHook"
HRESULT MTCreateBrandingVDirs::ExecuteHook(VARIANT var, long* pVal)
{
  string strMPSPath ;
  string strCSRPath ;
  MTVdir aMPSVdir ;
  MTVdir aCSRVdir ;
  
  // step 0: get the path for the mps and csr vdir's ...
  if(FAILED(aMPSVdir.GetVdirPhysicalPath(MPS_VDIR, strMPSPath)))
  {
    mLogger.LogThis(LOG_WARNING,PROCEDURE " Failed to find physical path for mps vdir");
    return S_FALSE;
  }

  if(FAILED(aCSRVdir.GetVdirPhysicalPath(CSR_VDIR, strCSRPath)))
  {
    mLogger.LogThis(LOG_ERROR,PROCEDURE " Failed to find physical path for csr vdir");
    return E_FAIL;
  }
  
  CONFIGLOADERLib::IMTConfigLoaderPtr configLoader(MTPROGID_CONFIGLOADER);
  
  // step 1: initialize the configLoader
  configLoader->Init();
  string webURL, aProviderName; //,aConfigDir;
  HRESULT hTemp,hr(S_OK);

  // step 3: open the config file
  CONFIGLOADERLib::IMTConfigPropSetPtr confSet = 
    configLoader->GetEffectiveFile(PRES_SERVER_DIR, GATEWAY_CONFIG);
  
  // step 4: get the config data ...
  CONFIGLOADERLib::IMTConfigPropSetPtr subset ;
  while (((subset = confSet->NextSetWithName("site")) != NULL))
  {
    webURL = subset->NextStringWithName("WebURL");
    aProviderName = subset->NextStringWithName("provider_name");
    if(webURL[0] == HTTP_DIR_SEP[0]) {
      // step 5: if the WEB_URL has a leading \, strip it
      webURL.erase(0,1);
    }
    MTVdir aVirCreator; // this must be created every time because it maintains state!
    MTVdir aVirLookup; 
		MTVdir removeVirDir;

    // step 6: create the virtual directory
    string aPath;
    string aVirLookupPath;

    // if this is not the csr webURL ...
    if (strcasecmp<string>(webURL, CSR_VDIR) != 0)
    {
      aPath = strMPSPath ;
    }
    else
    {
      aPath = strCSRPath ;
    }

		// if the virtual dir is already exist
		if(SUCCEEDED(aVirLookup.GetVdirPhysicalPath(webURL, aVirLookupPath)))
		{
			removeVirDir.DeleteIISVdir(webURL);
		}

		if(FAILED((hTemp = aVirCreator.CreateIISVdir(webURL,aPath))))
		{
			mLogger.LogVarArgs(LOG_ERROR, PROCEDURE " Failed to create virtual directory %s with path %s",
					webURL.c_str(), aPath.c_str());
			hr = hTemp;
		}
		else
		{
			mLogger.LogVarArgs(LOG_INFO,PROCEDURE " Created virtual directory %s", webURL.c_str());
		}
  }

  return hr;
}
