/**************************************************************************
 * TIMESTAMPOVERRIDE
 *
 * Copyright 1997-2000 by MetraTech Corp.
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

#include <mtglobal_msg.h>

CLSID CLSID_TimestampOverride = { /* fd6e5f20-6d68-11d4-a409-00c04f484788 */
    0xfd6e5f20,
    0x6d68,
    0x11d4,
    {0xa4, 0x09, 0x00, 0xc0, 0x4f, 0x48, 0x47, 0x88}
  };


/////////////////////////////////////////////////////////////////////////////
// TimestampOverride
/////////////////////////////////////////////////////////////////////////////

class ATL_NO_VTABLE TimestampOverride
	: public MTPipelinePlugIn<TimestampOverride, &CLSID_TimestampOverride>
{
protected:
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

protected: 

private: // data
	MTPipelineLib::IMTLogPtr mLogger;

	long mTimestampID;
	long mSystemTimestampID;
};


PLUGIN_INFO(CLSID_TimestampOverride, TimestampOverride,
				"MetraPipeline.TimestampOverride.1", "MetraPipeline.TimestampOverride", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

HRESULT TimestampOverride::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
																	MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	const char * functionName = "TimestampOverride::PlugInConfigure";

  DECLARE_PROPNAME_MAP(inputs)
    DECLARE_PROPNAME("timestamp",&mTimestampID)
		DECLARE_PROPNAME_OPTIONAL("system_timestamp", &mSystemTimestampID)
  END_PROPNAME_MAP

  HRESULT hr = ProcessProperties(inputs, aPropSet, aNameID, aLogger, functionName);
	if (FAILED(hr))
		return hr;

	if (mSystemTimestampID == -1)
		mSystemTimestampID = aNameID->GetNameID("_Timestamp");

	return hr;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

HRESULT TimestampOverride::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	if (aSession->PropertyExists(mTimestampID,
															 MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE)
	{
		long theTime = aSession->GetDateTimeProperty(mTimestampID);

		// override the system timestamp
		aSession->SetDateTimeProperty(mSystemTimestampID, theTime);
	}
	else
	{
		// if this call fails, the exception will be the error.
		long theTime = aSession->GetDateTimeProperty(mSystemTimestampID);

		// set the missing property
		aSession->SetDateTimeProperty(mTimestampID, theTime);
	}

	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////

HRESULT TimestampOverride::PlugInShutdown()
{
	
	return S_OK;
}

