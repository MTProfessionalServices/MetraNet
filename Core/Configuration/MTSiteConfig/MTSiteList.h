	
// MTSiteList.h : Declaration of the CMTSiteList

#ifndef __MTSITELIST_H_
#define __MTSITELIST_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <errobj.h>
#include <NTLogger.h>

#include <vector>
#include <string>

#include "MTSiteConfigDefs.h"

using std::vector;

#import <MTConfigLib.tlb> 
using namespace MTConfigLib ;

/////////////////////////////////////////////////////////////////////////////
// CMTSiteList
class ATL_NO_VTABLE CMTSiteList : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSiteList, &CLSID_MTSiteList>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSiteList, &IID_IMTSiteList, &LIBID_MTSITECONFIGLib>,
  public virtual ObjectWithError
{
public:
	CMTSiteList() ;
  virtual ~CMTSiteList() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTSITELIST)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTSiteList)
	COM_INTERFACE_ENTRY(IMTSiteList)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTSiteList
public:
	STDMETHOD(Remove)(/*[in]*/ BSTR aName, /*[in]*/ BSTR aProviderName, 
    /*[in]*/ BSTR aRelativeURL);
	STDMETHOD(CommitChanges)();
	STDMETHOD(Initialize)(/*[in]*/ BSTR aHostName, /*[in]*/ BSTR aRelativePath, 
    /*[in]*/ BSTR aRelativeFile);
	STDMETHOD(Add)(/*[in]*/ BSTR aName, /*[in]*/ BSTR aProviderName, 
  /*[in]*/ BSTR aRelativeURL, VARIANT_BOOL aNewSiteFlag);
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);

private:
  BOOL SetMTSysHeader (MTConfigLib::IMTConfigPropSetPtr aPropSet) ;
  BOOL SetSiteData (MTConfigLib::IMTConfigPropSetPtr aPropSet) ;
  BOOL CreateNewSite() ;
  BOOL CreateLocalizedSiteInfo(BSTR aProviderName) ;
  BOOL CreateSiteInfo(BSTR aProviderName) ;

  vector<CComVariant> mSiteList;
  long                  mSize;
  NTLogger              mLogger ;
  BOOL                  mInitialized ;
  std::wstring             mHostName ;
  std::wstring             mRelativePath ;
  std::wstring             mRelativeFile ;
  BOOL                  mCreateNewSite ;
};

#endif //__MTSITELIST_H_
