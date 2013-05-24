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




// generate using uuidgen
//CLSID __declspec(uuid("f7aa4780-0d1d-11d3-a59d-00c04f579c39")) CLSID_MTServiceLevelPlugin;

CLSID CLSID_MTServiceLevelPlugin = { /* f7aa4780-0d1d-11d3-a59d-00c04f579c39 */
    0xf7aa4780,
    0x0d1d,
    0x11d3,
    {0xa5, 0x9d, 0x00, 0xc0, 0x4f, 0x57, 0x9c, 0x39}
  };


class ATL_NO_VTABLE MTServiceLevelPlugin
	: public MTPipelinePlugIn<MTServiceLevelPlugin, &CLSID_MTServiceLevelPlugin>
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
  MTPipelineLib::IMTSessionServerPtr mSessionServer;
  long mServiceLevelID,mSystemNameID;
};


PLUGIN_INFO(CLSID_MTServiceLevelPlugin, MTServiceLevelPlugin,
						"MetraPipeline.MTServiceLevelPlugin.1", "MetraPipeline.MTServiceLevelPlugin", "Free")




/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTServiceLevelPlugin::PlugInConfigure"
HRESULT MTServiceLevelPlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  mLogger = aLogger;

  DECLARE_PROPNAME_MAP(inputs)
    DECLARE_PROPNAME("ServiceLevel",&mServiceLevelID)
    DECLARE_PROPNAME("SystemName",&mSystemNameID)
  END_PROPNAME_MAP

  mSessionServer = MTPipelineLib::IMTSessionServerPtr(MTPROGID_SESSION_SERVER);
  if(mSessionServer == NULL)
    return Error("Failed to create session server object");

  return ProcessProperties(inputs,aPropSet,aNameID,mLogger,PROCEDURE);
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTServiceLevelPlugin::PlugInProcessSession"
HRESULT MTServiceLevelPlugin::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  long parentId = aSession->GetParentID();
  MTPipelineLib::IMTSessionPtr aParentSession;
  long aParentServiceLevel;
  _bstr_t aParentSystemName;

  if(parentId != -1) {
    aParentSession = mSessionServer->GetSession(parentId);
    aParentServiceLevel = aParentSession->GetEnumProperty(mServiceLevelID);
    aParentSystemName = aParentSession->GetBSTRProperty(mSystemNameID);

    aSession->SetEnumProperty(mServiceLevelID,aParentServiceLevel);
    aSession->SetBSTRProperty(mSystemNameID,aParentSystemName);
  }
#if 0
	// NOTE: allow the session to be processed even if there's no parent.
	// a default may have been setup
  else {
    return Error("SessionID was invalid (-1)");
  }
#endif
  return S_OK;
}


