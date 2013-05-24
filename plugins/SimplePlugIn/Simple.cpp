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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <PlugInSkeleton.h>

// generate using uuidgen
CLSID CLSID_SimplePlugIn = { /* a920e4b0-00c5-11d3-a1e8-006008c0e24a */
    0xa920e4b0,
    0x00c5,
    0x11d3,
    {0xa1, 0xe8, 0x00, 0x60, 0x08, 0xc0, 0xe2, 0x4a}
  };

class ATL_NO_VTABLE MTSimplePlugIn
	: public MTPipelinePlugIn<MTSimplePlugIn, &CLSID_SimplePlugIn>
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
	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

private:

};


PLUGIN_INFO(CLSID_SimplePlugIn, MTSimplePlugIn,
						"MetraPipeline.SimplePlugIn.1", "MetraPipeline.SimplePlugIn", "Free")

HRESULT MTSimplePlugIn::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
																				MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	return S_OK;
}

HRESULT MTSimplePlugIn::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	return S_OK;
}


HRESULT MTSimplePlugIn::PlugInShutdown()
{
	return S_OK;
}
