/**************************************************************************
 * ROUNDROBIN
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
#include <vector>
#include <string>

#include <reservedproperties.h>

// generate using uuidgen
CLSID CLSID_RoundRobin = { /* 2de94b50-bf10-11d4-a430-00c04f484788 */
    0x2de94b50,
    0xbf10,
    0x11d4,
    {0xa4, 0x30, 0x00, 0xc0, 0x4f, 0x48, 0x47, 0x88}
  };

class ATL_NO_VTABLE RoundRobinPlugIn
	: public MTPipelinePlugIn<RoundRobinPlugIn, &CLSID_RoundRobin>
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

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

private:

	MTPipelineLib::IMTLogPtr mLogger;

	// list of stages we rotate through.  Pick first, then next, then next, etc.
	std::vector<std::wstring> mStageList;

	// pointer into mStageList for next stage to point to
	int mNext;

	int mNextStageID;
};


PLUGIN_INFO(CLSID_RoundRobin, RoundRobinPlugIn,
						"MetraPipeline.RoundRobin.1", "MetraPipeline.RoundRobin", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

HRESULT RoundRobinPlugIn::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	// save the logger
	mLogger = aLogger;

	// create the list of stages
	while (aPropSet->NextMatches("stage", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
	{
		_bstr_t stageNameBstr = aPropSet->NextStringWithName("stage");

		std::wstring stageName(stageNameBstr);

		mStageList.push_back(stageName);
	}

	// take the first stage on the first pass
	mNext = 0;

	// property to set
	mNextStageID = aNameID->GetNameID(MT_NEXTSTAGE_PROP);

	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

HRESULT RoundRobinPlugIn::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	ASSERT(mNext >= 0 && mNext < (int) mStageList.size());

	const std::wstring & stageName = mStageList[mNext];

	mNext = (mNext + 1) % mStageList.size();

	if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG) == VARIANT_TRUE)
	{
		_bstr_t buffer("Sending session to stage ");
		buffer += stageName.c_str();
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
	}

	aSession->SetStringProperty(mNextStageID, stageName.c_str());
  return S_OK;
}
