	
// COMUserConfig.h : Declaration of the CCOMUserConfig

#ifndef __COMUSERCONFIG_H_
#define __COMUSERCONFIG_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <UserConfig.h>
#include <ComKioskLogging.h>
#include <autologger.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMUserConfig
class ATL_NO_VTABLE CCOMUserConfig : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMUserConfig, &CLSID_COMUserConfig>,
  public ISupportErrorInfo,
	public IDispatchImpl<ICOMUserConfig, &IID_ICOMUserConfig, &LIBID_COMKIOSKLib>
{
public:

	// Default constructors
	CCOMUserConfig();

	// Destructor
	virtual ~CCOMUserConfig();

DECLARE_REGISTRY_RESOURCEID(IDR_COMUSERCONFIG)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMUserConfig)
	COM_INTERFACE_ENTRY(ICOMUserConfig)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

  // ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMUserConfig
public:
  STDMETHOD(Initialize)();
	STDMETHOD(LoadDefaultUserConfiguration)(BSTR ExtensionName);
	STDMETHOD(GetConfigInfo)(BSTR login, BSTR name_space);
	STDMETHOD(get_LanguageCode)(/*[out, retval]*/ BSTR *pVal);
//	STDMETHOD(put_LanguageCode)(/*[in]*/ BSTR newVal);
	STDMETHOD(GetValue)(/*[in]*/ BSTR tagName, /*[out,retval]*/ BSTR* tagValue);
	STDMETHOD(SetValue)(/*[in]*/ BSTR tagName, /*[out,retval]*/ BSTR tagValue);
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(Add)(/*[in]*/BSTR login, /*[in]*/ BSTR name_space, BSTR langCode,
    /*[in]*/long lAccID, long TimezoneID, LPDISPATCH pRowset);
	STDMETHOD(Delete)(/*[in]*/BSTR login, /*[in]*/ BSTR name_space, BSTR langCode,
    /*[in]*/long lAccID, long TimezoneID, LPDISPATCH pRowset);
  STDMETHOD(UpdateUserLanguage)(/*[in]*/BSTR login, /*[in]*/ BSTR name_space, BSTR langCode);
	STDMETHOD(GetUserAccountInfo)(/*[out, retval]*/ LPDISPATCH *pInterface);

private:
	// pointer to user config object
	CUserConfig mUserConfig;

	// member to check at any time if the object initialised itself
	// properly
	BOOL mIsInitialized;
	MTAutoInstance<MTAutoLoggerImpl<szCOMKioskUserConfig,szComKioskLoggingDir> >	mLogger;
};

#endif //__COMUSERCONFIG_H_
