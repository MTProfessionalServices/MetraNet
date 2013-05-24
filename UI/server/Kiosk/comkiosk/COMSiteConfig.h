
// COMSiteConfig.h : Declaration of the CCOMSiteConfig

#ifndef __COMSITECONFIG_H_
#define __COMSITECONFIG_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <SiteConfig.h>
#include <ComKioskLogging.h>
#include <autologger.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMSiteConfig
class ATL_NO_VTABLE CCOMSiteConfig :
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMSiteConfig, &CLSID_COMSiteConfig>,
  public ISupportErrorInfo,
	public IDispatchImpl<ICOMSiteConfig, &IID_ICOMSiteConfig, &LIBID_COMKIOSKLib>
{
public:

	// Default constructor
	CCOMSiteConfig();

	// Destructor
	virtual ~CCOMSiteConfig();

DECLARE_REGISTRY_RESOURCEID(IDR_COMSITECONFIG)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMSiteConfig)
	COM_INTERFACE_ENTRY(ICOMSiteConfig)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

  // ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMSiteConfig
public:
	STDMETHOD(GetConfigInfo)(BSTR nameSpace, BSTR langCode) ;
	STDMETHOD(GetValue)(BSTR tagName, BSTR* tagValue);
	STDMETHOD(SetValue)(BSTR tagName, BSTR tagValue);

private:
	// pointer to site config object
	CSiteConfig mSiteConfig;

	// member to check at any time if the object initialised itself
	// properly
	BOOL mIsInitialized;
	MTAutoInstance<MTAutoLoggerImpl<szCOMKioskSiteConfig,szComKioskLoggingDir> >	mLogger;
};

#endif //__COMSITECONFIG_H_
