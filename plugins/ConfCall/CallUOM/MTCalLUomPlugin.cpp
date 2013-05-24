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


#include <PlugInSkeleton.h>
#include <stdio.h>
#include <mtprogids.h>
#include <SetIterate.h>

#define MAX __max

// {F3D170C1-D8A1-47a9-BCDA-4AAC803BE696}
// CR 15449 - was using the same GUID as ParentCopyPlugin
CLSID CLSID_MTCallUomPlugin = { 
  0xf3d170c1,
  0xd8a1,
  0x47a9,
  {0xbc, 0xda, 0x4a, 0xac, 0x80, 0x3b, 0xe6, 0x96}
};


class ATL_NO_VTABLE MTCallUomPlugin 
	: public MTPipelinePlugIn<MTCallUomPlugin, &CLSID_MTCallUomPlugin>
{
protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

protected: // data
  MTPipelineLib::IMTLogPtr mLogger;
  long mParentUomID;

  _bstr_t mChildUomStr,mDefaultCurrencyStr;
};


PLUGIN_INFO(CLSID_MTCallUomPlugin, MTCallUomPlugin,
						"MetraPipeline.MTCallUomPlugin.1", "MetraPipeline.MTCallUomPlugin", "Free")




/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTCallUomPlugin ::PlugInConfigure"
HRESULT MTCallUomPlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  mLogger = aLogger;

  DECLARE_PROPNAME_MAP(inputs)
    DECLARE_PROPNAME("UOM",&mParentUomID)
  END_PROPNAME_MAP

  HRESULT hr = ProcessProperties(inputs,aPropSet,aNameID,mLogger,PROCEDURE);

  if(SUCCEEDED(hr))
    mChildUomStr = aPropSet->NextStringWithName("ParentUOM");
  mDefaultCurrencyStr = aPropSet->NextStringWithName("DefaultCurrency");

  return hr;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTCallUomPlugin ::PlugInProcessSession"
HRESULT MTCallUomPlugin::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  // LeaderName = username of child session whose UserRole = Chair

  MTPipelineLib::IMTSessionSetPtr aChildSet = aSession->SessionChildren();
  SetIterator<MTPipelineLib::IMTSessionSetPtr,MTPipelineLib::IMTSessionPtr> it;

  if(FAILED(it.Init(aChildSet)))
    return Error("Failed to initialize Childset iterator");

  while (TRUE)
  {
    MTPipelineLib::IMTSessionPtr aChildSession = it.GetNext();
		if (aChildSession == NULL)
			break;
	

		BSTR aChildUOMBSTR;
		if(SUCCEEDED(aChildSession->raw_GetBSTRProperty(mParentUomID,&aChildUOMBSTR))) {
			aSession->SetBSTRProperty(mParentUomID,aChildUOMBSTR);
			::SysFreeString(aChildUOMBSTR);
			return S_OK;
		}
  }

  aSession->SetBSTRProperty(mParentUomID,mDefaultCurrencyStr);
  return S_OK;
}


