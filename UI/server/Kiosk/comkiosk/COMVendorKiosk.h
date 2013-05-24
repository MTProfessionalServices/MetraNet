	
// COMVendorKiosk.h : Declaration of the CCOMVendorKiosk

#ifndef __COMVENDORKIOSK_H_
#define __COMVENDORKIOSK_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <VendorKiosk.h>
#include <UserConfig.h>
#include <KioskAuth.h>
#include <AccountMapper.h>
#include <ComKioskLogging.h>
#include <autologger.h>

#import <COMKiosk.tlb>

/////////////////////////////////////////////////////////////////////////////
// CCOMVendorKiosk
class ATL_NO_VTABLE CCOMVendorKiosk : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMVendorKiosk, &CLSID_COMVendorKiosk>,
  public ISupportErrorInfo,
	public IDispatchImpl<ICOMVendorKiosk, &IID_ICOMVendorKiosk, &LIBID_COMKIOSKLib>
{
public:
	// default constructor
	CCOMVendorKiosk();

	// destructor
	virtual ~CCOMVendorKiosk();


DECLARE_REGISTRY_RESOURCEID(IDR_COMVENDORKIOSK)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMVendorKiosk)
	COM_INTERFACE_ENTRY(ICOMVendorKiosk)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

  // ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMVendorKiosk
public:
	STDMETHOD(GetDefaultAuthenticationNamespace)(/*[out, retval]*/ BSTR *pVal);
  STDMETHOD(GetLanguageCollection)(BSTR aLangCode, LPDISPATCH * pInterface) ;
	STDMETHOD(AddUser)(/*[in]*/ LPDISPATCH pCredentials, long AccountStatus, BSTR aLanguage, long TimezoneID, LPDISPATCH pRowset,/*[out,retval]*/ LPDISPATCH* pInterface);
	STDMETHOD(GetUserConfig)(/*[in]*/ LPDISPATCH pCredentials, /*[out,retval]*/ LPDISPATCH* pInterface);
	STDMETHOD(GetSiteConfig)(/*[in]*/ BSTR languageCode, /*[out,retval]*/ LPDISPATCH* pInterface);
	STDMETHOD(Initialize)(BSTR providerName, int port);
	STDMETHOD(get_AuthMethod)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(GetTimezone)(BSTR langCode, /*[out, retval]*/ LPDISPATCH *pInterface);
#if 0
  STDMETHOD(GetColors)(/*[out, retval]*/ LPDISPATCH *pInterface);
#endif
	STDMETHOD(IsAuthentic)(/*[in]*/LPDISPATCH pCredentials, /*[out,retval]*/ VARIANT_BOOL* authValue);
	// STDMETHOD(UpdateCredentials)(/*[in]*/LPDISPATCH pCredentials);
	STDMETHOD(AddPresServerLogon)(/*[in]*/ BSTR Logon, BSTR Name_Space, BSTR Password, BSTR Language, long AccountID); 

private:
  // routine to tear down initialized memory ...
  void TearDown() ;

	// pointer to vendor kiosk object
	CVendorKiosk mVendorKiosk;
	
	// pointer to kiosk auth object
	ICOMKioskAuth* mpKioskAuth;

	// pointer to the account mapper object
	ICOMAccountMapper* mpAccountMapper;

	// pointer to the account object
    COMKIOSKLib::ICOMAccountPtr mpAccount;
	
	// member to check at any time if the object initialised itself
	// properly
	BOOL mIsInitialized;
	_bstr_t mExtensionName;
	MTAutoInstance<MTAutoLoggerImpl<szCOMKioskVendorKiosk,szComKioskLoggingDir> >	mLogger;
};

#endif //__COMVENDORKIOSK_H_
