#include <PlugInSkeleton.h>
#include <MTPipelineLib.h>
#include <stdio.h>
#include <AdapterLogging.h>
#include <DBAccess.h>
#include <OLEDBContext.h>

// {19022FE1-F536-11d3-953B-00C04F0904E0}
CLSID CLSID_DTCGetWhereAboutsPlugin = 
{ 0x19022fe1, 0xf536, 0x11d3, { 0x95, 0x3b, 0x0, 0xc0, 0x4f, 0x9, 0x4, 0xe0 } };

//
class ATL_NO_VTABLE DTCGetWhereAboutsPlugin
: public MTPipelinePlugIn<DTCGetWhereAboutsPlugin, &CLSID_DTCGetWhereAboutsPlugin >
//	public ObjectWithError
{
public:
		DTCGetWhereAboutsPlugin();
protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
		MTPipelineLib::IMTConfigPropSetPtr aPropSet,
		MTPipelineLib::IMTNameIDPtr aNameID,
		MTPipelineLib::IMTSystemContextPtr aSysContext);
	// process the session
	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);
protected: // data
	NTLogger mLogger;
	MTPipelineLib::IMTLogPtr mLoggerPtr;
	long	m_WhereAboutsCookie ;
};
// this macro provides information to the plug-in skeleton on how the COM
// object should be registered, its CLSID, and its threading model.  If you are
// familiar with ATL COM objects, this macro basically provides all of the information
// to ATL so this class can act as a COM object
PLUGIN_INFO(CLSID_DTCGetWhereAboutsPlugin, DTCGetWhereAboutsPlugin,
						"MetraPipeline.DTCGetWhereAboutsPlugin.1",
						"MetraPipeline.DTCGetWhereAboutsPlugin", "Free")
						/////////////////////////////////////////////////////////////////////////////
						//PlugInConfigure
						/////////////////////////////////////////////////////////////////////////////
						HRESULT DTCGetWhereAboutsPlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
						MTPipelineLib::IMTConfigPropSetPtr aPropSet,
						MTPipelineLib::IMTNameIDPtr aNameID,
						MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	// grab an instance of the logger so we can use it in process sessions if
	// we need to 
	mLoggerPtr = aLogger;
	// Declare the list of properties we will read from the XML configuration
	// When ProcessProperties is called, it loads the property Ids into the
	// variable that was passed 
	DECLARE_PROPNAME_MAP(inputs)
		DECLARE_PROPNAME("WhereAboutsCookie",&m_WhereAboutsCookie)
		END_PROPNAME_MAP
		return ProcessProperties(inputs,aPropSet,aNameID,mLoggerPtr,/*PROCEDURE*/NULL);
}

// Constructor
// initialize the logger ...
DTCGetWhereAboutsPlugin::DTCGetWhereAboutsPlugin()
{
	LoggerConfigReader cfgRdr;
	mLogger.Init (cfgRdr.ReadConfiguration("DTCGetWhereAboutsPlugin"), "[DTCGetWhereAboutsPlugin]");
}
/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////
HRESULT DTCGetWhereAboutsPlugin::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	HRESULT nRetVal(S_OK);
  BOOL bOK = TRUE;
	_bstr_t bstrWhereAboutsCookie("failed");
	
  CGetWhereAbouts GetWhereAbouts;
  bOK = GetWhereAbouts.GetEncodedWhereAboutsDistributedTransaction( &bstrWhereAboutsCookie );

  if ( bOK == TRUE )
  {
    mLogger.LogVarArgs (LOG_DEBUG, "WhereAboutsCookie retrieved (Find) = <%s>", (char *)bstrWhereAboutsCookie);
	  aSession->SetStringProperty(m_WhereAboutsCookie, bstrWhereAboutsCookie);
	}
	else
	{
		nRetVal = E_ABORT;
    mLogger.LogThis(LOG_ERROR, "GetEncodedWhereAboutsDistributedTransaction failed");
		return Error("Error in code", IID_IMTPipelinePlugIn, nRetVal);
	}

	return nRetVal;
}
