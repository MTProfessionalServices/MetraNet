	
// MTSiteBranding.h : Declaration of the CMTSiteBranding

#ifndef __MTSITEBRANDING_H_
#define __MTSITEBRANDING_H_

#include "resource.h"       // main symbols

// RogueWave includes
#include <comdef.h>
#include <errobj.h>
#include <NTLogger.h>
#include <string>
#include <map>

using std::map;

#import <MTConfigLib.tlb> 
using namespace MTConfigLib ;

/////////////////////////////////////////////////////////////////////////////
// CMTSiteBranding
class ATL_NO_VTABLE CMTSiteBranding : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSiteBranding, &CLSID_MTSiteBranding>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSiteBranding, &IID_IMTSiteBranding, &LIBID_MTSITECONFIGLib>,
  public virtual ObjectWithError
{
public:
	typedef map<wstring, wstring> SiteConfigColl;

	CMTSiteBranding() ;
  virtual ~CMTSiteBranding() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTSITEBRANDING)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTSiteBranding)
	COM_INTERFACE_ENTRY(IMTSiteBranding)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTSiteBranding
public:
	STDMETHOD(CommitChanges)();
	STDMETHOD(SetValue)(/*[in]*/ BSTR aTagName, /*[in]*/ BSTR aTagValue);
	STDMETHOD(GetValue)(/*[in]*/ BSTR apTagName, /*[out, retval]*/ BSTR *apTagValue);
	STDMETHOD(Initialize)(/*[in]*/ BSTR aHostName, /*[in]*/ BSTR aRelativePath, 
    /*[in]*/ BSTR aRelativeFile, /*[in]*/ BSTR aProviderName, /*[in]*/ BSTR aLanguage);
private:
  BOOL SetMTSysHeader (MTConfigLib::IMTConfigPropSetPtr aPropSet) ;
  BOOL SetSiteConfigData (MTConfigLib::IMTConfigPropSetPtr aPropSet) ;
  void TearDown() ;

  SiteConfigColl  mSiteConfigMap ;
  BOOL            mInitialized ;
  NTLogger        mLogger ;
  std::wstring       mHostName ;
  std::wstring       mProviderName ;
  std::wstring       mLangCode ;
  std::wstring       mRelativePath ;
  std::wstring       mRelativeFile ;
};

#endif //__MTSITEBRANDING_H_
