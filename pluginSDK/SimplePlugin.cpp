#include "PlugInSkeleton.h"

CLSID CLSID_SimplePlugin = // {79EFA060-F600-11d3-99EB-00C04F6DC482}
{
	0x79efa060, 
	0xf600, 
	0x11d3, 
	{ 0x99, 0xeb, 0x0, 0xc0, 0x4f, 0x6d, 0xc4, 0x82 } 
};

class ATL_NO_VTABLE SimplePlugin
	: public MTPipelinePlugIn<SimplePlugin, &CLSID_SimplePlugin>
{
protected:
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
																	MTPipelineLib::IMTSystemContextPtr aSysContext);
	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

	virtual HRESULT PlugInShutdown();

protected:
	MTPipelineLib::IMTLogPtr mLogger;
	// you can change the following code.
	long mFirstPropertyID, mSecondPropertyID, mOutputID;
};

///
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "Simple Plugin"
///
PLUGIN_INFO(CLSID_SimplePlugin, SimplePlugin,
						"MetraPipeline.SimplePlugin.1","MetraPipeline.SimplePlugin", "Free")


HRESULT SimplePlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																						MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																						MTPipelineLib::IMTNameIDPtr aNameID,
																						MTPipelineLib::IMTSystemContextPtr aSysContext)
{

	// add your code
	mLogger = aLogger;
	DECLARE_PROPNAME_MAP(inputs)
	DECLARE_PROPNAME("FirstProp", &mFirstPropertyID)
	DECLARE_PROPNAME("SecondProp", &mSecondPropertyID)
	DECLARE_PROPNAME("Output", &mOutputID)
	END_PROPNAME_MAP
	// You can change the above code.
	return ProcessProperties(inputs, aPropSet, aNameID, mLogger, PROCEDURE);
}

HRESULT SimplePlugin::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	// add your code
	return S_OK;
}

HRESULT SimplePlugin::PlugInShutdown()
{
	// add your code
 return S_OK;
}
